import 'package:drift/drift.dart';

import '../app_database.dart';
import 'audit_repository.dart';
import 'repo_context.dart';

class ItemUnitInput {
  const ItemUnitInput(this.name, this.factorToBase);
  final String name;
  final int factorToBase;
}

/// An item (optionally a specific variant) found by search or barcode scan.
class ItemSearchResult {
  const ItemSearchResult(this.item, this.variant);
  final Item item;
  final ItemVariant? variant;
}

/// Label of the single variant that only exists to hold a barcode (for example
/// items imported with a barcode). The bill hides this label.
const kDefaultVariantLabel = 'Standard';

/// One row of the item list: the item and its retail price (paise per pricing unit).
class ItemListEntry {
  const ItemListEntry(this.item, this.retailRatePaise);
  final Item item;
  final int? retailRatePaise;
}

/// Everything the item form needs.
class ItemDetail {
  const ItemDetail({
    required this.item,
    required this.units,
    required this.variants,
    required this.prices,
    required this.costPaise,
    required this.structureLocked,
  });

  final Item item;
  final List<ItemUnit> units;
  final List<ItemVariant> variants;

  /// Item-level price per tier (retail | contractor | dealer), paise per pricing unit.
  final Map<String, int> prices;

  /// Latest cost, paise per pricing unit, ex-GST.
  final int? costPaise;

  /// True once the item has stock movements or bill/purchase lines. The base
  /// unit and pricing-unit factor can no longer change (history would change meaning).
  final bool structureLocked;
}

/// Item master: items, units, variants, prices and costs.
///
/// Prices and costs are paise per *pricing unit* (per metre for cable, per piece
/// otherwise); an item's `priceUnitFactor` converts to base units.
class ItemRepository {
  ItemRepository(this.ctx);
  final RepoContext ctx;
  AppDatabase get _db => ctx.db;
  late final AuditRepository _audit = AuditRepository(ctx);

  /// Creates an item and its units. The base unit is added with factor 1 if absent.
  Future<String> createItem({
    required String name,
    required String baseUnit,
    int priceUnitFactor = 1,
    int gstRateBp = 0,
    String? hsn,
    String? brand,
    String? category,
    int minStockBase = 0,
    List<ItemUnitInput> units = const [],
  }) async {
    if (priceUnitFactor <= 0) {
      throw DomainException('priceUnitFactor must be > 0');
    }
    for (final u in units) {
      if (u.factorToBase <= 0) {
        throw DomainException('Unit ${u.name} factor must be > 0');
      }
    }
    final now = ctx.clock();
    final id = ctx.newId();
    await _db.transaction(() async {
      await ctx.insertRow(
        _db.items,
        ItemsCompanion.insert(
          id: id,
          shopId: ctx.shopId,
          createdAt: now,
          updatedAt: now,
          name: name,
          baseUnit: baseUnit,
          priceUnitFactor: Value(priceUnitFactor),
          gstRateBp: Value(gstRateBp),
          hsn: Value(hsn),
          brand: Value(brand),
          category: Value(category),
          minStockBase: Value(minStockBase),
        ),
        'items',
        id,
      );
      final all = [
        if (!units.any((u) => u.name == baseUnit)) ItemUnitInput(baseUnit, 1),
        ...units,
      ];
      for (final u in all) {
        final uid = ctx.newId();
        await ctx.insertRow(
          _db.itemUnits,
          ItemUnitsCompanion.insert(
            id: uid,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            itemId: id,
            unitName: u.name,
            factorToBase: u.factorToBase,
          ),
          'item_units',
          uid,
        );
      }
    });
    return id;
  }

  Future<Item> getItem(String itemId) async {
    final row = await (_db.select(_db.items)
          ..where((t) => t.id.equals(itemId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) throw DomainException('Unknown item: $itemId');
    return row;
  }

  /// Base units in one [unitName] of the item.
  Future<int> unitFactor(String itemId, String unitName) async {
    final row = await (_db.select(_db.itemUnits)
          ..where((t) =>
              t.itemId.equals(itemId) &
              t.unitName.equals(unitName) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) {
      throw DomainException('Item $itemId has no unit "$unitName"');
    }
    return row.factorToBase;
  }

  Future<String> addVariant({
    required String itemId,
    required String label,
    String? size,
    String? rating,
    String? colour,
    String? barcode,
    String? sku,
  }) async {
    await _requireFreeBarcode(barcode, exceptVariantId: null);
    final now = ctx.clock();
    final id = ctx.newId();
    await _db.transaction(() => ctx.insertRow(
          _db.itemVariants,
          ItemVariantsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            itemId: itemId,
            label: label,
            size: Value(size),
            rating: Value(rating),
            colour: Value(colour),
            barcode: Value(barcode),
            sku: Value(sku),
          ),
          'item_variants',
          id,
        ));
    return id;
  }

  /// Units defined for the item, base unit first.
  Future<List<ItemUnit>> unitsOf(String itemId) => (_db.select(_db.itemUnits)
        ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.factorToBase)]))
      .get();

  /// Search by item name or brand, and by variant barcode, SKU or label.
  /// An exact barcode match is returned alone. Newest-first is not needed;
  /// results are ordered by name.
  Future<List<ItemSearchResult>> search(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final exact = await findVariantByBarcode(q);
    if (exact != null) {
      return [ItemSearchResult(await getItem(exact.itemId), exact)];
    }

    final like = '%${q.replaceAll('%', '').replaceAll('_', '')}%';
    final byName = await (_db.select(_db.items)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.active.equals(true) &
              (t.name.like(like) | t.brand.like(like)))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit))
        .get();
    final byVariant = await (_db.select(_db.itemVariants)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sku.like(like) | t.label.like(like) | t.barcode.like(like)))
          ..limit(limit))
        .get();

    final out = <ItemSearchResult>[];
    final seen = <String>{};
    for (final v in byVariant) {
      final item = await getItem(v.itemId);
      if (item.active && seen.add('${item.id}/${v.id}')) {
        out.add(ItemSearchResult(item, v));
      }
    }
    for (final item in byName) {
      if (seen.add('${item.id}/')) out.add(ItemSearchResult(item, null));
    }
    return out.take(limit).toList();
  }

  Future<ItemVariant?> findVariantByBarcode(String barcode) =>
      (_db.select(_db.itemVariants)
            ..where((t) => t.barcode.equals(barcode) & t.deletedAt.isNull()))
          .getSingleOrNull();

  /// Sets (or changes) the price for [tier] (retail | contractor | dealer).
  Future<void> setPrice({
    required String itemId,
    required String tier,
    required int ratePaise,
    String? variantId,
    String? userId,
  }) async {
    if (!const {'retail', 'contractor', 'dealer'}.contains(tier)) {
      throw DomainException('Unknown tier: $tier');
    }
    if (ratePaise < 0) throw DomainException('Rate cannot be negative');
    final now = ctx.clock();
    await _db.transaction(() async {
      final existing = await _findPrice(itemId, tier, variantId);
      if (existing == null) {
        final id = ctx.newId();
        await ctx.insertRow(
          _db.itemPrices,
          ItemPricesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            itemId: itemId,
            tier: tier,
            ratePaise: ratePaise,
            variantId: Value(variantId),
          ),
          'item_prices',
          id,
        );
      } else if (existing.ratePaise != ratePaise) {
        await (_db.update(_db.itemPrices)
              ..where((t) => t.id.equals(existing.id)))
            .write(ItemPricesCompanion(
          ratePaise: Value(ratePaise),
          updatedAt: Value(now),
        ));
        final saved = await (_db.select(_db.itemPrices)
              ..where((t) => t.id.equals(existing.id)))
            .getSingle();
        await ctx.recordOutbox(
            'item_prices', existing.id, 'upsert', saved.toJson());
        // Changing an existing price is audited (plan rule 11); a first-time
        // price is not.
        await _audit.record(
          action: 'price_change',
          entity: 'item_price',
          entityId: existing.id,
          userId: userId,
          before: {'itemId': itemId, 'tier': tier, 'ratePaise': existing.ratePaise},
          after: {'itemId': itemId, 'tier': tier, 'ratePaise': ratePaise},
        );
      }
    });
  }

  Future<ItemPrice?> _findPrice(
      String itemId, String tier, String? variantId) {
    return (_db.select(_db.itemPrices)
          ..where((t) =>
              t.itemId.equals(itemId) &
              t.tier.equals(tier) &
              t.deletedAt.isNull() &
              (variantId == null
                  ? t.variantId.isNull()
                  : t.variantId.equals(variantId))))
        .getSingleOrNull();
  }

  /// Rate in paise per pricing unit: tier price, falling back to retail, with a
  /// variant-specific price preferred over the item-level one.
  Future<int?> priceFor({
    required String itemId,
    required String tier,
    String? variantId,
  }) async {
    for (final t in {tier, 'retail'}) {
      for (final v in {if (variantId != null) variantId, null}) {
        final row = await _findPrice(itemId, t, v);
        if (row != null) return row.ratePaise;
      }
    }
    return null;
  }

  /// Adds a cost-history row. Owner-only visibility (enforced in the UI in Stage A).
  Future<void> setCost({
    required String itemId,
    required int costPaise,
    String? variantId,
    DateTime? effectiveFrom,
  }) async {
    final now = ctx.clock();
    final id = ctx.newId();
    await _db.transaction(() => ctx.insertRow(
          _db.itemCosts,
          ItemCostsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            itemId: itemId,
            costPaise: costPaise,
            effectiveFrom: effectiveFrom ?? now,
            variantId: Value(variantId),
          ),
          'item_costs',
          id,
        ));
  }

  /// Latest cost in paise per pricing unit, or null.
  Future<int?> latestCost(String itemId) async {
    final row = await (_db.select(_db.itemCosts)
          ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)])
          ..limit(1))
        .getSingleOrNull();
    return row?.costPaise;
  }

  // ---- A3: item management ------------------------------------------------

  /// Items for the list screen, ordered by name, with the retail price.
  Future<List<ItemListEntry>> listItems({
    String query = '',
    bool includeInactive = false,
    int limit = 500,
  }) async {
    final q = query.trim().replaceAll('%', '').replaceAll('_', '');
    final like = '%$q%';
    final items = await (_db.select(_db.items)
          ..where((t) =>
              t.deletedAt.isNull() &
              (includeInactive ? const Constant(true) : t.active.equals(true)) &
              (q.isEmpty
                  ? const Constant(true)
                  : (t.name.like(like) | t.brand.like(like) | t.category.like(like))))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit))
        .get();
    if (items.isEmpty) return const [];
    final prices = await (_db.select(_db.itemPrices)
          ..where((t) =>
              t.itemId.isIn(items.map((i) => i.id).toList()) &
              t.tier.equals('retail') &
              t.variantId.isNull() &
              t.deletedAt.isNull()))
        .get();
    final byItem = {for (final p in prices) p.itemId: p.ratePaise};
    return [for (final i in items) ItemListEntry(i, byItem[i.id])];
  }

  Future<ItemDetail> getDetail(String itemId) async {
    final item = await getItem(itemId);
    final variants = await (_db.select(_db.itemVariants)
          ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final priceRows = await (_db.select(_db.itemPrices)
          ..where((t) =>
              t.itemId.equals(itemId) &
              t.variantId.isNull() &
              t.deletedAt.isNull()))
        .get();
    return ItemDetail(
      item: item,
      units: await unitsOf(itemId),
      variants: variants,
      prices: {for (final p in priceRows) p.tier: p.ratePaise},
      costPaise: await latestCost(itemId),
      structureLocked: await isStructureLocked(itemId),
    );
  }

  /// True once the item appears in stock movements, bills or purchases.
  Future<bool> isStructureLocked(String itemId) async {
    final mv = await (_db.select(_db.stockMovements)
          ..where((t) => t.itemId.equals(itemId))
          ..limit(1))
        .get();
    if (mv.isNotEmpty) return true;
    final il = await (_db.select(_db.invoiceLines)
          ..where((t) => t.itemId.equals(itemId))
          ..limit(1))
        .get();
    if (il.isNotEmpty) return true;
    final pl = await (_db.select(_db.purchaseLines)
          ..where((t) => t.itemId.equals(itemId))
          ..limit(1))
        .get();
    return pl.isNotEmpty;
  }

  /// Edits an item. [baseUnit] and [priceUnitFactor] may only change while
  /// [isStructureLocked] is false. Writes an audit row with before and after.
  Future<void> updateItem({
    required String itemId,
    required String name,
    required int gstRateBp,
    required int minStockBase,
    String? brand,
    String? category,
    String? hsn,
    String? baseUnit,
    int? priceUnitFactor,
    String? userId,
  }) async {
    if (name.trim().isEmpty) throw DomainException('Item name is required');
    if (gstRateBp < 0) throw DomainException('GST rate cannot be negative');
    if (minStockBase < 0) {
      throw DomainException('Minimum stock cannot be negative');
    }
    await _db.transaction(() async {
      final before = await getItem(itemId);
      final newBase = baseUnit ?? before.baseUnit;
      final newFactor = priceUnitFactor ?? before.priceUnitFactor;
      if (newFactor <= 0) {
        throw DomainException('Pricing unit factor must be > 0');
      }
      final structural =
          newBase != before.baseUnit || newFactor != before.priceUnitFactor;
      if (structural && await isStructureLocked(itemId)) {
        throw DomainException(
            'This item already has stock or bills, so its unit type cannot '
            'change. Deactivate it and create a new item instead.');
      }
      final now = ctx.clock();
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(
          name: Value(name.trim()),
          brand: Value(brand),
          category: Value(category),
          hsn: Value(hsn),
          gstRateBp: Value(gstRateBp),
          minStockBase: Value(minStockBase),
          baseUnit: Value(newBase),
          priceUnitFactor: Value(newFactor),
          updatedAt: Value(now),
        ),
      );
      if (newBase != before.baseUnit) {
        // Keep the factor-1 unit row in step with the base unit name.
        await (_db.update(_db.itemUnits)
              ..where((t) =>
                  t.itemId.equals(itemId) &
                  t.unitName.equals(before.baseUnit) &
                  t.factorToBase.equals(1)))
            .write(ItemUnitsCompanion(
                unitName: Value(newBase), updatedAt: Value(now)));
      }
      final after = await getItem(itemId);
      await ctx.recordOutbox('items', itemId, 'upsert', after.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'item',
        entityId: itemId,
        userId: userId,
        before: before.toJson(),
        after: after.toJson(),
      );
    });
  }

  /// Deactivated items disappear from billing and search but keep their history.
  Future<void> setActive(String itemId, bool active, {String? userId}) async {
    await _db.transaction(() async {
      final before = await getItem(itemId);
      if (before.active == active) return;
      await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
        ItemsCompanion(active: Value(active), updatedAt: Value(ctx.clock())),
      );
      final after = await getItem(itemId);
      await ctx.recordOutbox('items', itemId, 'upsert', after.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'item',
        entityId: itemId,
        userId: userId,
        before: {'active': before.active},
        after: {'active': after.active},
      );
    });
  }

  // Units

  Future<String> addUnit(String itemId, String unitName, int factorToBase,
      {String? userId}) async {
    final name = unitName.trim();
    if (name.isEmpty) throw DomainException('Unit name is required');
    if (factorToBase <= 0) throw DomainException('Unit size must be > 0');
    final now = ctx.clock();
    final id = ctx.newId();
    await _db.transaction(() async {
      await getItem(itemId);
      final dup = await (_db.select(_db.itemUnits)
            ..where((t) =>
                t.itemId.equals(itemId) &
                t.unitName.equals(name) &
                t.deletedAt.isNull()))
          .getSingleOrNull();
      if (dup != null) throw DomainException('Unit "$name" already exists');
      await ctx.insertRow(
        _db.itemUnits,
        ItemUnitsCompanion.insert(
          id: id,
          shopId: ctx.shopId,
          createdAt: now,
          updatedAt: now,
          itemId: itemId,
          unitName: name,
          factorToBase: factorToBase,
        ),
        'item_units',
        id,
      );
      await _audit.record(
        action: 'edit',
        entity: 'item',
        entityId: itemId,
        userId: userId,
        after: {'addedUnit': name, 'factorToBase': factorToBase},
      );
    });
    return id;
  }

  /// Changes how many base units one [unitId] holds. The base unit cannot change.
  Future<void> updateUnitFactor(String unitId, int factorToBase,
      {String? userId}) async {
    if (factorToBase <= 0) throw DomainException('Unit size must be > 0');
    await _db.transaction(() async {
      final unit = await _unit(unitId);
      final item = await getItem(unit.itemId);
      if (unit.unitName == item.baseUnit && unit.factorToBase == 1) {
        throw DomainException('The base unit cannot be changed');
      }
      if (unit.factorToBase == factorToBase) return;
      await (_db.update(_db.itemUnits)..where((t) => t.id.equals(unitId)))
          .write(ItemUnitsCompanion(
        factorToBase: Value(factorToBase),
        updatedAt: Value(ctx.clock()),
      ));
      final saved = await _unit(unitId);
      await ctx.recordOutbox('item_units', unitId, 'upsert', saved.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'item',
        entityId: unit.itemId,
        userId: userId,
        before: {'unit': unit.unitName, 'factorToBase': unit.factorToBase},
        after: {'unit': unit.unitName, 'factorToBase': factorToBase},
      );
    });
  }

  /// Removes a unit from the picker. Not allowed for the base unit or the
  /// pricing unit (the one bills default to).
  Future<void> removeUnit(String unitId, {String? userId}) async {
    await _db.transaction(() async {
      final unit = await _unit(unitId);
      final item = await getItem(unit.itemId);
      if (unit.unitName == item.baseUnit && unit.factorToBase == 1) {
        throw DomainException('The base unit cannot be removed');
      }
      if (unit.factorToBase == item.priceUnitFactor) {
        throw DomainException('The pricing unit cannot be removed');
      }
      final now = ctx.clock();
      await (_db.update(_db.itemUnits)..where((t) => t.id.equals(unitId)))
          .write(ItemUnitsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await ctx.recordOutbox('item_units', unitId, 'delete', {'id': unitId});
      await _audit.record(
        action: 'edit',
        entity: 'item',
        entityId: unit.itemId,
        userId: userId,
        before: {'unit': unit.unitName, 'factorToBase': unit.factorToBase},
        after: {'removedUnit': unit.unitName},
      );
    });
  }

  Future<ItemUnit> _unit(String unitId) async {
    final row = await (_db.select(_db.itemUnits)
          ..where((t) => t.id.equals(unitId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) throw DomainException('Unknown unit: $unitId');
    return row;
  }

  // Variants

  Future<void> updateVariant({
    required String variantId,
    required String label,
    String? size,
    String? rating,
    String? colour,
    String? barcode,
    String? sku,
    String? userId,
  }) async {
    if (label.trim().isEmpty) throw DomainException('Variant name is required');
    await _db.transaction(() async {
      final before = await _variant(variantId);
      await _requireFreeBarcode(barcode, exceptVariantId: variantId);
      final code = barcode?.trim();
      await (_db.update(_db.itemVariants)..where((t) => t.id.equals(variantId)))
          .write(ItemVariantsCompanion(
        label: Value(label.trim()),
        size: Value(size),
        rating: Value(rating),
        colour: Value(colour),
        barcode: Value(code == null || code.isEmpty ? null : code),
        sku: Value(sku),
        updatedAt: Value(ctx.clock()),
      ));
      final after = await _variant(variantId);
      await ctx.recordOutbox(
          'item_variants', variantId, 'upsert', after.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'item_variant',
        entityId: variantId,
        userId: userId,
        before: before.toJson(),
        after: after.toJson(),
      );
    });
  }

  Future<void> removeVariant(String variantId, {String? userId}) async {
    await _db.transaction(() async {
      final before = await _variant(variantId);
      final now = ctx.clock();
      await (_db.update(_db.itemVariants)..where((t) => t.id.equals(variantId)))
          .write(ItemVariantsCompanion(
              deletedAt: Value(now), updatedAt: Value(now)));
      await ctx.recordOutbox(
          'item_variants', variantId, 'delete', {'id': variantId});
      await _audit.record(
        action: 'delete',
        entity: 'item_variant',
        entityId: variantId,
        userId: userId,
        before: before.toJson(),
      );
    });
  }

  Future<ItemVariant> _variant(String variantId) async {
    final row = await (_db.select(_db.itemVariants)
          ..where((t) => t.id.equals(variantId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) throw DomainException('Unknown variant: $variantId');
    return row;
  }

  /// A barcode may belong to only one variant, otherwise scanning is ambiguous.
  Future<void> _requireFreeBarcode(String? barcode,
      {required String? exceptVariantId}) async {
    final code = barcode?.trim();
    if (code == null || code.isEmpty) return;
    final others = await (_db.select(_db.itemVariants)
          ..where((t) =>
              t.barcode.equals(code) &
              t.deletedAt.isNull() &
              (exceptVariantId == null
                  ? const Constant(true)
                  : t.id.equals(exceptVariantId).not())))
        .get();
    if (others.isNotEmpty) {
      throw DomainException('Barcode $code is already used by another item');
    }
  }

  // Prices

  /// Removes a tier price (for example clears the contractor price).
  Future<void> clearPrice({
    required String itemId,
    required String tier,
    String? variantId,
    String? userId,
  }) async {
    await _db.transaction(() async {
      final existing = await _findPrice(itemId, tier, variantId);
      if (existing == null) return;
      final now = ctx.clock();
      await (_db.update(_db.itemPrices)..where((t) => t.id.equals(existing.id)))
          .write(ItemPricesCompanion(
              deletedAt: Value(now), updatedAt: Value(now)));
      await ctx.recordOutbox(
          'item_prices', existing.id, 'delete', {'id': existing.id});
      await _audit.record(
        action: 'price_change',
        entity: 'item_price',
        entityId: existing.id,
        userId: userId,
        before: {'itemId': itemId, 'tier': tier, 'ratePaise': existing.ratePaise},
        after: {'itemId': itemId, 'tier': tier, 'ratePaise': null},
      );
    });
  }
}
