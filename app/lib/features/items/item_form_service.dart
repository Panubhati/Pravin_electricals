import '../../shared/strings.dart';
import '../../core/db/repositories/item_repository.dart';
import '../../core/db/repositories/repo_context.dart';
import '../../core/db/repositories/stock_repository.dart';
import '../../core/import/value_parsers.dart';

/// Everything entered on the item form, already converted to the app's units
/// (millimetres for cable, pieces otherwise) and paise.
class ItemFormData {
  const ItemFormData({
    required this.name,
    required this.gstRateBp,
    required this.isLength,
    required this.retailPaise,
    this.itemId,
    this.brand,
    this.category,
    this.hsn,
    this.packSize,
    this.contractorPaise,
    this.dealerPaise,
    this.costPaise,
    this.minStockBase = 0,
    this.openingStockBase = 0,
    this.barcode,
  });

  /// Null when creating a new item.
  final String? itemId;
  final String name;
  final String? brand;
  final String? category;
  final String? hsn;
  final int gstRateBp;

  /// Cable sold by length (stored in mm) or counted pieces. Fixed at creation.
  final bool isLength;

  /// Roll length in mm (length items) or pieces per box (piece items). Null = none.
  final int? packSize;

  /// Selling prices include GST, paise per metre or per piece.
  final int retailPaise;
  final int? contractorPaise;
  final int? dealerPaise;

  /// Cost excludes GST. Only stored when the user may see cost.
  final int? costPaise;
  final int minStockBase;

  /// Creation only: stock on hand today, recorded as an opening-stock movement.
  final int openingStockBase;

  /// Creation only: barcode of the item (kept on a default variant).
  final String? barcode;
}

/// Saves the item form in one transaction: a failure leaves nothing half-saved.
class ItemFormService {
  ItemFormService(this.ctx)
      : _items = ItemRepository(ctx),
        _stock = StockRepository(ctx);

  final RepoContext ctx;
  final ItemRepository _items;
  final StockRepository _stock;

  /// Returns the item id. Throws [DomainException] for invalid input.
  Future<String> save(
    ItemFormData d, {
    required String locationId,
    String? userId,
    bool canSeeCost = true,
  }) async {
    _validate(d);
    return ctx.db.transaction(
      () => d.itemId == null
          ? _create(d, locationId, userId, canSeeCost)
          : _update(d, userId, canSeeCost),
    );
  }

  void _validate(ItemFormData d) {
    if (d.name.trim().isEmpty) throw DomainException(S.itemNameRequired);
    if (!validGstRatesBp.contains(d.gstRateBp)) {
      throw DomainException(S.gstChoices);
    }
    if (d.retailPaise <= 0) {
      throw DomainException(S.retailMoreThanZero);
    }
    if ((d.contractorPaise ?? 1) <= 0 || (d.dealerPaise ?? 1) <= 0) {
      throw DomainException(S.pricesMoreThanZero);
    }
    final pack = d.packSize;
    if (pack != null) {
      if (d.isLength && pack <= 0) {
        throw DomainException(S.rollMoreThanZero);
      }
      if (!d.isLength && pack < 2) {
        throw DomainException(S.boxTwoOrMore);
      }
    }
    if (d.minStockBase < 0 || d.openingStockBase < 0) {
      throw DomainException(S.stockNotNegative);
    }
  }

  Future<String> _create(
      ItemFormData d, String locationId, String? userId, bool canSeeCost) async {
    final id = await _items.createItem(
      name: d.name.trim(),
      brand: _blank(d.brand),
      category: _blank(d.category),
      hsn: _blank(d.hsn),
      baseUnit: d.isLength ? 'mm' : 'pcs',
      priceUnitFactor: d.isLength ? 1000 : 1,
      gstRateBp: d.gstRateBp,
      minStockBase: d.minStockBase,
      units: [
        if (d.isLength) const ItemUnitInput('m', 1000),
        if (d.isLength && d.packSize != null) ItemUnitInput('roll', d.packSize!),
        if (!d.isLength && d.packSize != null) ItemUnitInput('box', d.packSize!),
      ],
    );
    await _items.setPrice(itemId: id, tier: 'retail', ratePaise: d.retailPaise, userId: userId);
    if (d.contractorPaise != null) {
      await _items.setPrice(itemId: id, tier: 'contractor', ratePaise: d.contractorPaise!, userId: userId);
    }
    if (d.dealerPaise != null) {
      await _items.setPrice(itemId: id, tier: 'dealer', ratePaise: d.dealerPaise!, userId: userId);
    }
    if (canSeeCost && d.costPaise != null) {
      await _items.setCost(itemId: id, costPaise: d.costPaise!);
    }
    final code = _blank(d.barcode);
    if (code != null) {
      await _items.addVariant(itemId: id, label: kDefaultVariantLabel, barcode: code);
    }
    if (d.openingStockBase > 0) {
      await _stock.record(
        itemId: id,
        locationId: locationId,
        qtyBase: d.openingStockBase,
        movementType: 'adjustment',
        refType: 'opening',
        note: 'Opening stock',
        createdBy: userId,
      );
    }
    return id;
  }

  Future<String> _update(ItemFormData d, String? userId, bool canSeeCost) async {
    final id = d.itemId!;
    final before = await _items.getItem(id);
    // The unit type is fixed after creation, so use the item's own.
    final isLength = before.baseUnit == 'mm' && before.priceUnitFactor == 1000;

    await _items.updateItem(
      itemId: id,
      name: d.name,
      brand: _blank(d.brand),
      category: _blank(d.category),
      hsn: _blank(d.hsn),
      gstRateBp: d.gstRateBp,
      minStockBase: d.minStockBase,
      userId: userId,
    );

    await _items.setPrice(itemId: id, tier: 'retail', ratePaise: d.retailPaise, userId: userId);
    await _tierPrice(id, 'contractor', d.contractorPaise, userId);
    await _tierPrice(id, 'dealer', d.dealerPaise, userId);

    if (canSeeCost && d.costPaise != null && d.costPaise != await _items.latestCost(id)) {
      await _items.setCost(itemId: id, costPaise: d.costPaise!);
    }

    // Roll or box size: add, change or remove that one unit.
    final packName = isLength ? 'roll' : 'box';
    final units = await _items.unitsOf(id);
    final existing = units.where((u) => u.unitName == packName).toList();
    if (d.packSize == null) {
      if (existing.isNotEmpty) await _items.removeUnit(existing.first.id, userId: userId);
    } else if (existing.isEmpty) {
      await _items.addUnit(id, packName, d.packSize!, userId: userId);
    } else if (existing.first.factorToBase != d.packSize) {
      await _items.updateUnitFactor(existing.first.id, d.packSize!, userId: userId);
    }
    return id;
  }

  Future<void> _tierPrice(String itemId, String tier, int? paise, String? userId) async {
    if (paise == null) {
      await _items.clearPrice(itemId: itemId, tier: tier, userId: userId);
    } else {
      await _items.setPrice(itemId: itemId, tier: tier, ratePaise: paise, userId: userId);
    }
  }

  static String? _blank(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
