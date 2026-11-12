import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

/// Thrown when input breaks a business rule (bad totals, unknown unit, ...).
class DomainException implements Exception {
  DomainException(this.message);
  final String message;
  @override
  String toString() => 'DomainException: $message';
}

class DuplicateInvoiceNumberException extends DomainException {
  DuplicateInvoiceNumberException(String number)
      : super('Invoice number $number already exists on this device.');
}

class DuplicatePurchaseException extends DomainException {
  DuplicatePurchaseException(String no)
      : super('Supplier invoice $no was already entered.');
}

/// Shared state for repositories: database, shop, id and clock sources.
///
/// Every repository write goes through [insertRow] / [recordOutbox] so that the
/// local `outbox` always gets a row in the same transaction (plan section 12).
/// Wi-Fi sync (A8) sends outbox rows to the other phone.
class RepoContext {
  RepoContext(
    this.db, {
    required this.shopId,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : uuid = uuid ?? const Uuid(),
        clock = clock ?? DateTime.now;

  final AppDatabase db;
  final String shopId;
  final Uuid uuid;
  final DateTime Function() clock;

  /// This phone's device id, stamped on every outbox row. Set once the session
  /// knows which phone it is (see ensureShopSession).
  String? originDeviceId;

  String newId() => uuid.v4();

  /// The next number in this phone's change sequence.
  Future<int> _nextSeq(String origin) async {
    final row = await db.customSelect(
      'SELECT COALESCE(MAX(seq), 0) AS m FROM outbox WHERE origin_device_id = ?',
      variables: [Variable.withString(origin)],
      readsFrom: {db.outbox},
    ).getSingle();
    return (row.data['m'] as int) + 1;
  }

  Future<void> recordOutbox(
    String entity,
    String entityId,
    String op,
    Map<String, Object?> payload,
  ) async {
    final origin = originDeviceId;
    final seq = origin == null ? 0 : await _nextSeq(origin);
    final now = clock();
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          id: newId(),
          shopId: shopId,
          entity: entity,
          entityId: entityId,
          op: op,
          payloadJson: jsonEncode(payload),
          createdAt: now,
          originDeviceId: Value(origin),
          seq: Value(seq),
          changedAtMs: Value(now.millisecondsSinceEpoch),
        ));
  }

  /// Inserts [row] and writes the matching outbox row. Call inside a transaction.
  Future<void> insertRow<T extends Table, D extends DataClass>(
    TableInfo<T, D> table,
    Insertable<D> row,
    String entity,
    String entityId,
  ) async {
    final saved = await db.into(table).insertReturning(row);
    await recordOutbox(entity, entityId, 'upsert', saved.toJson());
  }

  /// True when [error] is a SQLite UNIQUE constraint failure.
  static bool isUniqueViolation(Object error) =>
      error.toString().contains('UNIQUE constraint failed');
}
