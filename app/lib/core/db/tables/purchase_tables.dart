import 'package:drift/drift.dart';
import 'base.dart';
import 'item_tables.dart';
import 'party_tables.dart';

/// Posted purchases are immutable. Duplicate supplier invoice numbers are blocked.
class Purchases extends Table with BaseColumns {
  TextColumn get supplierId => text().references(Parties, #id)();
  TextColumn get supplierInvoiceNo => text()();
  DateTimeColumn get supplierInvoiceDate => dateTime()();
  IntColumn get subtotalPaise => integer()();
  IntColumn get taxPaise => integer()();
  IntColumn get totalPaise => integer()();

  /// manual | photo
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get photoId => text().nullable()();

  /// posted | cancelled
  TextColumn get status => text().withDefault(const Constant('posted'))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {shopId, supplierId, supplierInvoiceNo},
      ];
}

class PurchaseLines extends Table with BaseColumns {
  TextColumn get purchaseId => text().references(Purchases, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable().references(ItemVariants, #id)();
  TextColumn get unitName => text()();
  TextColumn get qtyEntered => text()();
  IntColumn get qtyBase => integer()();

  /// Paise per pricing unit.
  IntColumn get ratePaise => integer()();
  IntColumn get priceUnitFactor => integer().withDefault(const Constant(1))();
  IntColumn get gstRateBp => integer().withDefault(const Constant(0))();
  IntColumn get lineTotalPaise => integer()();
}
