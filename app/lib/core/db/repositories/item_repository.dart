import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

class ItemUnitInput {
  const ItemUnitInput(this.name, this.factorToBase);
  final String name;
  final int factorToBase;
}

/// Item master: items, units, variants, prices and costs.
///
/// Prices and costs are paise per *pricing unit* (per metre for cable, per piece
/// otherwise); an item's `priceUnitFactor` converts to base units.
class ItemRepository {
  ItemRepository(this.ctx);
  final RepoContext ctx;
  AppDatabase get _db => ctx.db;

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
      } else {
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
}
