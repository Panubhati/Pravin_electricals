import 'package:drift/drift.dart';
import 'base.dart';

/// Append-only record of edits, deletions, discounts and price overrides
/// (plan section 2, rule 11).
class AuditLog extends Table with BaseColumns {
  TextColumn get userId => text().nullable()();

  /// e.g. discount | price_override | edit | delete
  TextColumn get action => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  DateTimeColumn get ts => dateTime()();
}
