import 'package:drift/drift.dart';

import '../app_database.dart';
import 'audit_repository.dart';
import 'item_repository.dart';
import 'repo_context.dart';

/// Append-only stock movements. Balance is always the sum of movements; there
/// is no stored "current stock" and no update or delete here.
class StockRepository {
  StockRepository(this.ctx);
  final RepoContext ctx;
  late final AuditRepository _audit = AuditRepository(ctx);

  static const movementTypes = {
    'purchase',
    'sale',
    'sale_return',
    'purchase_return',
    'transfer_in',
    'transfer_out',
    'adjustment',
    'count',
  };

  /// Records one signed movement in base units. Joins the surrounding
  /// transaction when called from inside one.
  Future<String> record({
    required String itemId,
    required String locationId,
    required int qtyBase,
    required String movementType,
    String? variantId,
    String? refType,
    String? refId,
    String? createdBy,
    String? note,
    DateTime? ts,
  }) async {
    if (!movementTypes.contains(movementType)) {
      throw DomainException('Unknown movement type: $movementType');
    }
    if (qtyBase == 0) throw DomainException('Movement quantity cannot be 0');
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.stockMovements,
          StockMovementsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            itemId: itemId,
            locationId: locationId,
            qtyBase: qtyBase,
            movementType: movementType,
            ts: ts ?? now,
            variantId: Value(variantId),
            refType: Value(refType),
            refId: Value(refId),
            createdBy: Value(createdBy),
            note: Value(note),
          ),
          'stock_movements',
          id,
        ));
    return id;
  }

  /// Stock balance in base units = sum of movements.
  Future<int> balance({
    required String itemId,
    String? locationId,
    String? variantId,
  }) async {
    final m = ctx.db.stockMovements;
    final sum = m.qtyBase.sum();
    final q = ctx.db.selectOnly(m)
      ..addColumns([sum])
      ..where(m.itemId.equals(itemId) & m.deletedAt.isNull());
    if (locationId != null) q.where(m.locationId.equals(locationId));
    if (variantId != null) q.where(m.variantId.equals(variantId));
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Balance of every item that has movements, in one query (itemId -> base
  /// units). Items with no movements are absent, which means zero.
  Future<Map<String, int>> balancesByItem({String? locationId}) async {
    final m = ctx.db.stockMovements;
    final sum = m.qtyBase.sum();
    final q = ctx.db.selectOnly(m)
      ..addColumns([m.itemId, sum])
      ..where(m.deletedAt.isNull())
      ..groupBy([m.itemId]);
    if (locationId != null) q.where(m.locationId.equals(locationId));
    final rows = await q.get();
    return {for (final r in rows) r.read(m.itemId)!: r.read(sum) ?? 0};
  }

  /// Movement history for one item, newest first.
  Future<List<StockMovement>> movements(String itemId, {int limit = 200}) {
    return (ctx.db.select(ctx.db.stockMovements)
          ..where((t) => t.itemId.equals(itemId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.ts),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Signed correction with a reason (damage, found stock, correction...).
  /// Writes a stock movement and an audit row in one transaction.
  Future<String> adjust({
    required String itemId,
    required String locationId,
    required int deltaBase,
    required String reason,
    String? variantId,
    String? userId,
  }) async {
    if (deltaBase == 0) throw DomainException('Adjustment cannot be zero');
    final why = reason.trim();
    if (why.isEmpty) throw DomainException('A reason is required');
    late String id;
    await ctx.db.transaction(() async {
      await ItemRepository(ctx).getItem(itemId);
      final before = await balance(itemId: itemId, locationId: locationId);
      id = await record(
        itemId: itemId,
        variantId: variantId,
        locationId: locationId,
        qtyBase: deltaBase,
        movementType: 'adjustment',
        refType: 'adjustment',
        createdBy: userId,
        note: why,
      );
      await _audit.record(
        action: 'stock_adjustment',
        entity: 'item',
        entityId: itemId,
        userId: userId,
        before: {'balanceBase': before},
        after: {'balanceBase': before + deltaBase, 'reason': why},
      );
    });
    return id;
  }

  /// Stock count: sets the balance to [countedBase] by recording the difference
  /// as a 'count' movement. Returns the difference (0 means no change, and no
  /// movement is written).
  Future<int> recordCount({
    required String itemId,
    required String locationId,
    required int countedBase,
    String? userId,
    String? note,
  }) async {
    if (countedBase < 0) throw DomainException('Counted quantity cannot be negative');
    var diff = 0;
    await ctx.db.transaction(() async {
      await ItemRepository(ctx).getItem(itemId);
      final system = await balance(itemId: itemId, locationId: locationId);
      diff = countedBase - system;
      if (diff == 0) return;
      await record(
        itemId: itemId,
        locationId: locationId,
        qtyBase: diff,
        movementType: 'count',
        refType: 'count',
        createdBy: userId,
        note: note ?? 'Stock count',
      );
      await _audit.record(
        action: 'stock_count',
        entity: 'item',
        entityId: itemId,
        userId: userId,
        before: {'balanceBase': system},
        after: {'balanceBase': countedBase},
      );
    });
    return diff;
  }
}
