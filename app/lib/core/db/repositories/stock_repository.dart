import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

/// Append-only stock movements. Balance is always the sum of movements; there
/// is no stored "current stock" and no update or delete here.
class StockRepository {
  StockRepository(this.ctx);
  final RepoContext ctx;

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
}
