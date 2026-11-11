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

  /// Newest first. [actions] limits to those actions, [from]/[to] to a range of
  /// days (inclusive). Names of the user and of the item/party/user it was about
  /// are filled in when they can be found.
  Future<List<AuditEntry>> list({
    Set<String>? actions,
    DateTime? from,
    DateTime? to,
    int limit = 300,
  }) async {
    final db = ctx.db;
    final q = db.select(db.auditLog)
      ..where((t) => t.shopId.equals(ctx.shopId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.ts),
        (t) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
      ])
      ..limit(limit);
    if (actions != null && actions.isNotEmpty) {
      q.where((t) => t.action.isIn(actions));
    }
    if (from != null) {
      q.where((t) => t.ts.isBiggerOrEqualValue(DateTime(from.year, from.month, from.day)));
    }
    if (to != null) {
      q.where((t) => t.ts.isSmallerThanValue(DateTime(to.year, to.month, to.day + 1)));
    }
    final rows = await q.get();
    if (rows.isEmpty) return const [];

    // What an entry is about: its own entity id, or the item/party named in its data.
    String? refId(AuditLogData r, String key) {
      for (final json in [r.afterJson, r.beforeJson]) {
        if (json == null) continue;
        try {
          final v = (jsonDecode(json) as Map)[key];
          if (v is String) return v;
        } catch (_) {}
      }
      return null;
    }

    final names = <String, String>{};
    final itemsById = <String, Item>{};
    final userIds = {for (final r in rows) if (r.userId != null) r.userId!};
    final entityIds = <String>{};
    for (final r in rows) {
      entityIds.add(r.entityId);
      final item = refId(r, 'itemId');
      final party = refId(r, 'partyId');
      if (item != null) entityIds.add(item);
      if (party != null) entityIds.add(party);
    }
    for (final u in await (db.select(db.users)..where((t) => t.id.isIn({...userIds, ...entityIds}))).get()) {
      names[u.id] = u.name;
    }
    for (final i in await (db.select(db.items)..where((t) => t.id.isIn(entityIds))).get()) {
      names[i.id] = i.name;
      itemsById[i.id] = i;
    }
    for (final p in await (db.select(db.parties)..where((t) => t.id.isIn(entityIds))).get()) {
      names[p.id] = p.name;
    }
    return [
      for (final r in rows)
        AuditEntry(
          row: r,
          userName: r.userId == null ? null : names[r.userId],
          entityName: names[r.entityId] ?? _named(names, refId(r, 'itemId')) ?? _named(names, refId(r, 'partyId')),
          item: itemsById[r.entityId] ?? _itemOf(itemsById, refId(r, 'itemId')),
        ),
    ];
  }
}

String? _named(Map<String, String> names, String? id) => id == null ? null : names[id];
Item? _itemOf(Map<String, Item> items, String? id) => id == null ? null : items[id];

/// One audit row with the names looked up.
class AuditEntry {
  const AuditEntry({required this.row, this.userName, this.entityName, this.item});
  final AuditLogData row;
  final String? userName;
  final String? entityName;

  /// The item this entry is about, when it is about one (to show quantities in
  /// metres or pieces rather than raw base units).
  final Item? item;
}
