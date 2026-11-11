import 'package:drift/drift.dart';
import 'base.dart';
import 'core_tables.dart';
import 'item_tables.dart';

/// Append-only. Balance = sum(qtyBase). Never store a mutable stock number.
@TableIndex(name: 'stock_movements_item', columns: {#itemId})
class StockMovements extends Table with BaseColumns {
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable().references(ItemVariants, #id)();
  TextColumn get locationId => text().references(Locations, #id)();

  /// Signed, in base units.
  IntColumn get qtyBase => integer()();

  /// purchase | sale | sale_return | purchase_return | transfer_in |
  /// transfer_out | adjustment | count
  TextColumn get movementType => text()();
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();
  DateTimeColumn get ts => dateTime()();
  TextColumn get createdBy => text().nullable()();

  /// Reason or remark, e.g. "Damaged", "Opening stock" (added in schema v2).
  TextColumn get note => text().nullable()();
}
