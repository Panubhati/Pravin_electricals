import 'package:drift/drift.dart';
import 'base.dart';

class Shops extends Table with BaseColumns {
  TextColumn get name => text()();
  TextColumn get gstin => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get stateCode => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get terms => text().nullable()();
}

class Users extends Table with BaseColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();

  /// owner | counter | godown
  TextColumn get role => text()();
  TextColumn get pinHash => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Devices extends Table with BaseColumns {
  TextColumn get userId => text().nullable()();
  TextColumn get label => text()();

  /// Per-device invoice series prefix, e.g. "A".
  TextColumn get invoiceSeriesPrefix => text()();
}

class Locations extends Table with BaseColumns {
  /// shop | godown | vehicle
  TextColumn get name => text()();
}

/// Local-only queue that Stage B sync will read. Nothing reads it in Stage A.
class Outbox extends Table {
  TextColumn get id => text()();
  TextColumn get shopId => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// upsert | delete
  TextColumn get op => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
