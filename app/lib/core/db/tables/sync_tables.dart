import 'package:drift/drift.dart';

/// Phone-only (A8): what this phone knows about each paired phone. Never sent
/// to the other phone and has no outbox rows.
class SyncPeers extends Table {
  TextColumn get deviceId => text()();
  TextColumn get label => text().withDefault(const Constant(''))();

  /// Last address the phone answered on (an IP on the shop Wi-Fi) and port.
  TextColumn get address => text().nullable()();
  IntColumn get port => integer().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  /// The highest seq of this phone's own changes that the peer already has.
  /// A local edit above it was not seen by the peer, so the peer's edit of the
  /// same row is a real clash (logged).
  IntColumn get seenOfMe => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

/// Phone-only key/value state for sync (the shop key, the pairing token...).
class SyncState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
