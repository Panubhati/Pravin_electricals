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
/// Nothing reads the outbox in Stage A; Stage B sync will.
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

  String newId() => uuid.v4();

  Future<void> recordOutbox(
    String entity,
    String entityId,
    String op,
    Map<String, Object?> payload,
  ) async {
    await db.into(db.outbox).insert(OutboxCompanion.insert(
          id: newId(),
          shopId: shopId,
          entity: entity,
          entityId: entityId,
          op: op,
          payloadJson: jsonEncode(payload),
          createdAt: clock(),
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
