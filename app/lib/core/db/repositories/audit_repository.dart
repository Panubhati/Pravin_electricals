import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

/// Append-only audit trail. No update or delete.
class AuditRepository {
  AuditRepository(this.ctx);
  final RepoContext ctx;

  /// Records one audit row. Joins the surrounding transaction when inside one.
  Future<String> record({
    required String action,
    required String entity,
    required String entityId,
    String? userId,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) async {
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.auditLog,
          AuditLogCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            action: action,
            entity: entity,
            entityId: entityId,
            ts: now,
            userId: Value(userId),
            beforeJson: Value(before == null ? null : jsonEncode(before)),
            afterJson: Value(after == null ? null : jsonEncode(after)),
          ),
          'audit_log',
          id,
        ));
    return id;
  }
}
