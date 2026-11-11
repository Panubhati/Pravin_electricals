import 'package:drift/drift.dart';
import 'base.dart';

class Items extends Table with BaseColumns {
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get hsn => text().nullable()();
  IntColumn get gstRateBp => integer().withDefault(const Constant(0))();

  /// Smallest sold unit name, e.g. "mm" for cable, "pcs" for countable items.
  TextColumn get baseUnit => text()();

  /// Base units per pricing unit (1000 for cable priced per metre, 1 for pieces).
  /// Prices are paise per pricing unit; see docs/decisions.md.
  IntColumn get priceUnitFactor => integer().withDefault(const Constant(1))();
  BoolColumn get trackSerial => boolean().withDefault(const Constant(false))();
  BoolColumn get trackCoil => boolean().withDefault(const Constant(false))();
  IntColumn get minStockBase => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class ItemUnits extends Table with BaseColumns {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get unitName => text()();

  /// Integer base units in one of this unit (roll of 90 m = 90000 mm).
  IntColumn get factorToBase => integer()();
}

class ItemVariants extends Table with BaseColumns {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get label => text()();
  TextColumn get size => text().nullable()();
  TextColumn get rating => text().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
}

class ItemPrices extends Table with BaseColumns {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable().references(ItemVariants, #id)();

  /// retail | contractor | dealer
  TextColumn get tier => text()();

  /// Paise per pricing unit (per metre for cable, per piece otherwise).
  IntColumn get ratePaise => integer()();
}

/// Owner-only visibility (hidden from the counter role in the UI).
class ItemCosts extends Table with BaseColumns {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable().references(ItemVariants, #id)();

  /// Paise per pricing unit.
  IntColumn get costPaise => integer()();
  DateTimeColumn get effectiveFrom => dateTime()();
}
