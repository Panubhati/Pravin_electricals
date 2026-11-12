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

/// Every change made on any phone, in order. Wi-Fi sync (A8) sends the rows a
/// phone has not seen yet. [originDeviceId] and [seq] say which phone made the
/// change and its place in that phone's sequence; rows received from the other
/// phone keep their original origin and seq.
@TableIndex(name: 'outbox_origin_seq', columns: {#originDeviceId, #seq}, unique: true)
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

  /// The phone that made the change (null only in tests without a device).
  TextColumn get originDeviceId => text().nullable()();

  /// 1, 2, 3... per origin phone.
  IntColumn get seq => integer().withDefault(const Constant(0))();

  /// When the change was made, in milliseconds (the table times are stored to
  /// the second). Sync keeps the version with the later time.
  IntColumn get changedAtMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-shop settings as key/value text (opening cash, discount limit, alerts...).
/// One row per (shop, key).
class AppSettings extends Table with BaseColumns {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {shopId, key},
      ];
}
