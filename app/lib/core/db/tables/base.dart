import 'package:drift/drift.dart';

/// Columns every synced table carries (plan section 12): UUID key, shop_id,
/// timestamps and soft delete. Ids are generated on the phone.
mixin BaseColumns on Table {
  TextColumn get id => text()();
  TextColumn get shopId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
