import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/repositories/audit_repository.dart';
import '../db/repositories/repo_context.dart';
import '../db/repositories/settings_repository.dart';

/// Tables that never travel between phones (they have no outbox rows).
const localOnlyTables = {'outbox', 'sync_peers', 'sync_state'};

/// Settings that belong to one phone, not the shop: when this phone last made
/// a backup or checked its data, and its own reminder, lock and summary choices.
const phoneOnlySettingKeys = {
  SettingKeys.lastBackupAt,
  SettingKeys.dataCheckLast,
  SettingKeys.backupReminderOn,
  SettingKeys.autoLockMinutes,
  SettingKeys.dailySummaryOn,
  SettingKeys.dailySummaryHour,
};

/// Rows that must be unique while not deleted, though each phone makes its own
/// id: two phones can both create "the retail price of this switch" or "the box
/// unit of this wire". When both arrive, the later one stays and the other is
/// marked deleted. Every phone applies the same rule, so they agree without
/// sending anything more.
const naturalKeys = {
  'item_prices': ['item_id', 'tier', 'variant_id'],
  'item_units': ['item_id', 'unit_name'],
};

/// An outbox row stored but not applied because a newer version of the same
/// row was already here. Kept so the sequence has no holes.
const supersededOp = 'superseded';

class SyncException implements Exception {
  SyncException(this.message);
  final String message;
  @override
  String toString() => 'SyncException: $message';
}

/// One change as it travels: an outbox row with its origin phone and seq.
class SyncChange {
  const SyncChange({
    required this.id,
    required this.origin,
    required this.seq,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payloadJson,
    required this.changedAtMs,
  });

  final String id;
  final String origin;
  final int seq;
  final String entity;
  final String entityId;
  final String op;
  final String payloadJson;
  final int changedAtMs;

  Map<String, Object?> toJson() => {
        'id': id,
        'o': origin,
        's': seq,
        'e': entity,
        'ei': entityId,
        'op': op,
        'p': payloadJson,
        'c': changedAtMs,
      };

  factory SyncChange.fromJson(Map<String, dynamic> j) => SyncChange(
        id: j['id'] as String,
        origin: j['o'] as String,
        seq: j['s'] as int,
        entity: j['e'] as String,
        entityId: j['ei'] as String,
        op: j['op'] as String,
        payloadJson: j['p'] as String,
        changedAtMs: j['c'] as int,
      );

  factory SyncChange.fromRow(OutboxData o) => SyncChange(
        id: o.id,
        origin: o.originDeviceId!,
        seq: o.seq,
        entity: o.entity,
        entityId: o.entityId,
        op: o.op,
        payloadJson: o.payloadJson,
        changedAtMs: o.changedAtMs,
      );
}

/// A page of changes plus what the sender has seen (its cursor), so the
/// receiver learns which of its own changes the sender already has.
class SyncBatch {
  const SyncBatch({required this.changes, required this.senderCursor, required this.hasMore});
  final List<SyncChange> changes;
  final Map<String, int> senderCursor;
  final bool hasMore;

  Map<String, Object?> toJson() => {
        'changes': [for (final c in changes) c.toJson()],
        'cursor': senderCursor,
        'more': hasMore,
      };

  factory SyncBatch.fromJson(Map<String, dynamic> j) => SyncBatch(
        changes: [for (final c in j['changes'] as List) SyncChange.fromJson(c as Map<String, dynamic>)],
        senderCursor: (j['cursor'] as Map).map((k, v) => MapEntry(k as String, v as int)),
        hasMore: j['more'] as bool,
      );
}

class ApplyResult {
  const ApplyResult({this.applied = 0, this.skipped = 0, this.conflicts = 0});
  final int applied;
  final int skipped;
  final int conflicts;
}

/// Reads and applies changes. Knows nothing about the network: the transport
/// asks [changesAfter] on one phone and hands the batch to [apply] on the other.
///
/// Rules (docs/decisions.md, A8):
/// - A change already here (same origin and seq) does nothing.
/// - Every row keeps the version with the later updated_at; on a tie the phone
///   with the higher device id wins, so both phones pick the same version.
///   Bills, payments, stock and ledger rows are only ever added (a bill's
///   status is the one field that changes), so they never clash.
/// - Settings match by key, and phone-only keys never travel.
/// - When an incoming edit and an edit on this phone that the other phone had
///   not seen touch the same row, an audit row `sync_conflict` keeps both.
class SyncEngine {
  SyncEngine(this.ctx) : assert(ctx.originDeviceId != null);

  final RepoContext ctx;
  AppDatabase get db => ctx.db;
  String get me => ctx.originDeviceId!;

  /// For each phone, the highest seq of its changes this phone has.
  Future<Map<String, int>> cursor() async {
    final rows = await db.customSelect(
      'SELECT origin_device_id AS o, MAX(seq) AS s FROM outbox '
      'WHERE origin_device_id IS NOT NULL GROUP BY origin_device_id',
      readsFrom: {db.outbox},
    ).get();
    return {for (final r in rows) r.data['o'] as String: r.data['s'] as int};
  }

  /// Changes the other phone does not have yet ([theirs] is its cursor), in the
  /// order this phone stored them, which keeps every row after the rows it
  /// points to (an item before the bill that sells it).
  Future<SyncBatch> changesAfter(Map<String, int> theirs, {int limit = 500}) async {
    final where = StringBuffer('origin_device_id IS NOT NULL AND (');
    final vars = <Variable>[];
    if (theirs.isEmpty) {
      where.write('1 = 1');
    } else {
      var first = true;
      for (final e in theirs.entries) {
        if (!first) where.write(' OR ');
        first = false;
        where.write('(origin_device_id = ? AND seq > ?)');
        vars
          ..add(Variable.withString(e.key))
          ..add(Variable.withInt(e.value));
      }
      where.write(' OR origin_device_id NOT IN (${List.filled(theirs.length, '?').join(', ')})');
      vars.addAll(theirs.keys.map(Variable.withString));
    }
    where.write(')');
    final rows = await db.customSelect(
      'SELECT * FROM outbox WHERE $where ORDER BY rowid LIMIT ?',
      variables: [...vars, Variable.withInt(limit)],
      readsFrom: {db.outbox},
    ).get();
    final changes = <SyncChange>[];
    for (final r in rows) {
      final o = await db.outbox.mapFromRow(r);
      if (_isPhoneOnly(o.entity, o.payloadJson)) continue;
      changes.add(SyncChange.fromRow(o));
    }
    return SyncBatch(changes: changes, senderCursor: await cursor(), hasMore: rows.length == limit);
  }

  /// Applies a batch from [peer] in one transaction: all of it or none.
  /// [peerSeenOfMe] is the highest seq of this phone's changes the peer has.
  Future<ApplyResult> apply(SyncBatch batch, {required String peer, int? peerSeenOfMe}) async {
    final seen = peerSeenOfMe ?? batch.senderCursor[me] ?? 0;
    var applied = 0, skipped = 0, conflicts = 0;
    await db.transaction(() async {
      for (final c in batch.changes) {
        if (c.origin == me || await _have(c)) {
          skipped++;
          continue;
        }
        final (outcome, storedAs) = _isPhoneOnly(c.entity, c.payloadJson)
            ? (_Outcome.superseded, c.entityId)
            : await _applyRow(c, peerSeenOfMe: seen);
        if (outcome == _Outcome.conflictKeptLocal || outcome == _Outcome.conflictTookIncoming) conflicts++;
        final stored = outcome == _Outcome.superseded || outcome == _Outcome.conflictKeptLocal;
        await db.into(db.outbox).insert(
              OutboxCompanion.insert(
                id: c.id,
                shopId: ctx.shopId,
                entity: c.entity,
                entityId: storedAs,
                op: stored ? supersededOp : c.op,
                payloadJson: c.payloadJson,
                createdAt: DateTime.fromMillisecondsSinceEpoch(c.changedAtMs),
                originDeviceId: Value(c.origin),
                seq: Value(c.seq),
                changedAtMs: Value(c.changedAtMs),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        if (stored) {
          skipped++;
        } else {
          applied++;
        }
      }
    });
    return ApplyResult(applied: applied, skipped: skipped, conflicts: conflicts);
  }

  Future<bool> _have(SyncChange c) async {
    final r = await db.customSelect(
      'SELECT 1 FROM outbox WHERE origin_device_id = ? AND seq = ? LIMIT 1',
      variables: [Variable.withString(c.origin), Variable.withInt(c.seq)],
    ).getSingleOrNull();
    return r != null;
  }

  bool _isPhoneOnly(String entity, String payloadJson) {
    if (localOnlyTables.contains(entity)) return true;
    if (entity != 'app_settings') return false;
    final key = (jsonDecode(payloadJson) as Map)['key'];
    return phoneOnlySettingKeys.contains(key);
  }

  TableInfo _table(String entity) {
    for (final t in db.allTables) {
      if (t.actualTableName == entity) return t;
    }
    throw SyncException('The other phone sent "$entity", which this app does not know. Update the app on both phones.');
  }

  /// Returns what happened and the row id the change was filed under (a
  /// setting from the other phone is filed under this phone's row for its key).
  Future<(_Outcome, String)> _applyRow(SyncChange c, {required int peerSeenOfMe}) async {
    final table = _table(c.entity);
    final incoming = jsonDecode(c.payloadJson) as Map<String, dynamic>;

    // Settings are one row per key; both phones may have made the same key.
    var localId = c.entityId;
    if (c.entity == 'app_settings') {
      final byKey = await db.customSelect(
        'SELECT id FROM app_settings WHERE shop_id = ? AND key = ?',
        variables: [Variable.withString(incoming['shopId'] as String), Variable.withString(incoming['key'] as String)],
      ).getSingleOrNull();
      if (byKey != null) localId = byKey.data['id'] as String;
    }

    final localRow = await db.customSelect(
      'SELECT * FROM ${table.actualTableName} WHERE id = ?',
      variables: [Variable.withString(localId)],
    ).getSingleOrNull();
    if (localRow == null) {
      await _write(table, incoming, insert: true);
      final clashed = await _resolveDuplicates(c, incoming);
      return (clashed ? _Outcome.conflictTookIncoming : _Outcome.applied, localId);
    }

    final local = jsonDecode(jsonEncode(((await table.map(localRow.data)) as DataClass).toJson())) as Map<String, dynamic>;
    final current = await _currentVersionOrigin(c.entity, localId);
    final incomingWins = current == null
        ? (incoming['updatedAt'] as int? ?? 0) > (local['updatedAt'] as int? ?? 0)
        : _wins(c, current);
    final differs = _differs(incoming, local);
    // An edit made here that the other phone had not seen when it made its own.
    final clash = differs && current != null && current.origin == me && current.seq > peerSeenOfMe;

    if (incomingWins) {
      if (differs) {
        await _write(table, incoming, insert: false, keepId: localId);
        await _resolveDuplicates(c, incoming);
      }
      if (clash) await _logConflict(c, local: local, incoming: incoming, kept: "the other phone's change (it was later)");
      return (clash ? _Outcome.conflictTookIncoming : _Outcome.applied, localId);
    }
    if (clash) await _logConflict(c, local: local, incoming: incoming, kept: "this phone's change (it was later)");
    return (clash ? _Outcome.conflictKeptLocal : _Outcome.superseded, localId);
  }

  /// Applies [naturalKeys]: among live rows with the same key, the one with the
  /// later updated_at (tie: larger id) stays. Returns true when two phones had
  /// made different rows for the same thing (logged as a clash).
  Future<bool> _resolveDuplicates(SyncChange c, Map<String, dynamic> incoming) async {
    final key = naturalKeys[c.entity];
    if (key == null) return false;
    final cond = [for (final k in key) '"$k" IS ?'].join(' AND ');
    final rows = await db.customSelect(
      'SELECT * FROM ${c.entity} WHERE deleted_at IS NULL AND $cond ORDER BY updated_at DESC, id DESC',
      variables: [for (final k in key) _variableFor(incoming[_jsonKey(k)])],
    ).get();
    if (rows.length < 2) return false;
    final table = _table(c.entity);
    final winner = rows.first.data;
    final winnerJson = jsonDecode(jsonEncode(((await table.map(winner)) as DataClass).toJson())) as Map<String, dynamic>;
    var clashed = false;
    for (final r in rows.skip(1)) {
      final loser = jsonDecode(jsonEncode(((await table.map(r.data)) as DataClass).toJson())) as Map<String, dynamic>;
      await db.customUpdate(
        'UPDATE ${c.entity} SET deleted_at = updated_at WHERE id = ?',
        variables: [Variable.withString(loser['id'] as String)],
        updates: {table},
        updateKind: UpdateKind.update,
      );
      if (_differs(loser, winnerJson)) {
        clashed = true;
        await _logConflict(c, local: loser, incoming: winnerJson, kept: 'the later one');
      }
    }
    return clashed;
  }

  static Variable _variableFor(Object? v) => switch (v) {
        null => const Variable(null),
        final String s => Variable.withString(s),
        final int i => Variable.withInt(i),
        _ => Variable(v),
      };

  /// The outbox row that produced the version now in the table: the newest
  /// stored change for this row that was not set aside.
  Future<({String origin, int seq, int ms})?> _currentVersionOrigin(String entity, String entityId) async {
    final r = await db.customSelect(
      'SELECT origin_device_id AS o, seq AS s, changed_at_ms AS t FROM outbox '
      'WHERE entity = ? AND entity_id = ? AND op != ? AND origin_device_id IS NOT NULL '
      'ORDER BY rowid DESC LIMIT 1',
      variables: [Variable.withString(entity), Variable.withString(entityId), Variable.withString(supersededOp)],
    ).getSingleOrNull();
    if (r == null) return null;
    return (origin: r.data['o'] as String, seq: r.data['s'] as int, ms: r.data['t'] as int);
  }

  /// The version order every phone agrees on: a later change from the same
  /// phone replaces its earlier one; otherwise the later time wins, and on an
  /// exact tie the higher device id.
  static bool _wins(SyncChange c, ({String origin, int seq, int ms}) current) {
    if (c.origin == current.origin) return c.seq > current.seq;
    if (c.changedAtMs != current.ms) return c.changedAtMs > current.ms;
    return c.origin.compareTo(current.origin) > 0;
  }

  /// True when the two versions differ in anything but the id.
  static bool _differs(Map<String, dynamic> a, Map<String, dynamic> b) {
    for (final k in {...a.keys, ...b.keys}) {
      if (k == 'id') continue;
      if (a.containsKey(k) && jsonEncode(a[k]) != jsonEncode(b[k])) return true;
    }
    return false;
  }

  Future<void> _write(TableInfo table, Map<String, dynamic> json, {required bool insert, String? keepId}) async {
    final cols = <String>[];
    final vars = <Variable>[];
    for (final col in table.$columns) {
      final key = _jsonKey(col.$name);
      if (!json.containsKey(key)) continue; // sent by an older app: keep the default
      if (!insert && col.$name == 'id') continue;
      cols.add(col.$name);
      vars.add(_variable(col, json[key]));
    }
    if (insert) {
      await db.customInsert(
        'INSERT INTO ${table.actualTableName} (${cols.map((c) => '"$c"').join(', ')}) '
        'VALUES (${List.filled(cols.length, '?').join(', ')})',
        variables: vars,
        updates: {table},
      );
    } else {
      await db.customUpdate(
        'UPDATE ${table.actualTableName} SET ${cols.map((c) => '"$c" = ?').join(', ')} WHERE id = ?',
        variables: [...vars, Variable.withString(keepId!)],
        updates: {table},
        updateKind: UpdateKind.update,
      );
    }
  }

  static String _jsonKey(String sqlName) {
    final parts = sqlName.split('_');
    return parts.first + parts.skip(1).map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join();
  }

  static Variable _variable(GeneratedColumn col, Object? v) {
    if (v == null) return const Variable(null);
    switch (col.type) {
      case DriftSqlType.dateTime:
        return Variable<DateTime>(DateTime.fromMillisecondsSinceEpoch(v as int));
      case DriftSqlType.bool:
        return Variable<bool>(v as bool);
      case DriftSqlType.int:
        return Variable<int>(v as int);
      case DriftSqlType.double:
        return Variable<double>((v as num).toDouble());
      case DriftSqlType.string:
        return Variable<String>(v as String);
      default:
        return Variable(v);
    }
  }

  Future<void> _logConflict(SyncChange c,
      {required Map<String, dynamic> local, required Map<String, dynamic> incoming, required String kept}) {
    return AuditRepository(ctx).record(
      action: 'sync_conflict',
      entity: c.entity,
      entityId: c.entityId,
      before: {'thisPhone': local, 'kept': kept},
      after: {'otherPhone': incoming, 'otherPhoneId': c.origin},
    );
  }
}

enum _Outcome { applied, superseded, conflictKeptLocal, conflictTookIncoming }
