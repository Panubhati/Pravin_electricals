import 'package:drift/drift.dart';

import '../../money.dart';
import '../../units.dart';
import '../app_database.dart';
import 'audit_repository.dart';
import 'item_repository.dart';
import 'ledger_repository.dart';
import 'repo_context.dart';
import 'stock_repository.dart';

class PurchaseLineInput {
  const PurchaseLineInput({
    required this.itemId,
    required this.unitName,
    required this.qtyEntered,
    required this.qtyBase,
    required this.ratePaise,
    required this.priceUnitFactor,
    this.variantId,
    this.gstRateBp = 0,
  });

  final String itemId;
  final String? variantId;
  final String unitName;
  final String qtyEntered;
  final int qtyBase;

  /// Paise per pricing unit.
  final int ratePaise;
  final int priceUnitFactor;
  final int gstRateBp;
}

class PostPurchaseInput {
  const PostPurchaseInput({
    required this.supplierId,
    required this.supplierInvoiceNo,
    required this.supplierInvoiceDate,
    required this.locationId,
    required this.lines,
    this.source = 'manual',
    this.photoId,
    this.createdBy,
  });

  final String supplierId;
  final String supplierInvoiceNo;
  final DateTime supplierInvoiceDate;

  /// Where the stock is received.
  final String locationId;
  final List<PurchaseLineInput> lines;

  /// manual | photo
  final String source;
  final String? photoId;
  final String? createdBy;
}

/// Posts supplier purchases. Posted purchases are immutable (no update/delete).
/// Tax is computed per line (rounded half up); line total = qty x rate.
class PurchaseRepository {
  PurchaseRepository(this.ctx)
      : _items = ItemRepository(ctx),
        _stock = StockRepository(ctx),
        _ledger = LedgerRepository(ctx);

  final RepoContext ctx;
  final ItemRepository _items;
  final StockRepository _stock;
  final LedgerRepository _ledger;

  /// Saves purchase, lines, stock movements (purchase, +qty), the supplier
  /// ledger entry (-total: the shop owes the supplier) and outbox rows in one
  /// transaction. A repeated (supplier, supplier invoice no) is rejected.
  Future<String> postPurchase(PostPurchaseInput input) async {
    if (input.lines.isEmpty) throw DomainException('Purchase has no lines');
    if (input.supplierInvoiceNo.trim().isEmpty) {
      throw DomainException('Supplier invoice number is required');
    }
    final now = ctx.clock();
    final id = ctx.newId();

    try {
      await ctx.db.transaction(() async {
        // The same bill twice on this phone is refused (a cancelled one may be
        // entered again). A copy that arrives from the other phone is kept and
        // flagged by Check my data instead.
        final dup = await (ctx.db.select(ctx.db.purchases)
              ..where((t) =>
                  t.shopId.equals(ctx.shopId) &
                  t.supplierId.equals(input.supplierId) &
                  t.supplierInvoiceNo.equals(input.supplierInvoiceNo.trim()) &
                  t.status.equals('cancelled').not())
              ..limit(1))
            .getSingleOrNull();
        if (dup != null) throw DuplicatePurchaseException(input.supplierInvoiceNo.trim());
        final lineTotals = <int>[];
        var subtotal = 0;
        var tax = 0;
        for (final l in input.lines) {
          final item = await _items.getItem(l.itemId);
          if (item.priceUnitFactor != l.priceUnitFactor) {
            throw DomainException(
                'Line for ${item.name}: price unit factor does not match the item');
          }
          final factor = await _items.unitFactor(l.itemId, l.unitName);
          final expectedBase = Units.toBaseUnits(l.qtyEntered, factor);
          if (expectedBase != l.qtyBase) {
            throw DomainException(
                'Line for ${item.name}: ${l.qtyEntered} ${l.unitName} is '
                '$expectedBase base units, not ${l.qtyBase}');
          }
          if (l.qtyBase <= 0) throw DomainException('Quantity must be > 0');
          final amount = Units.lineAmountPaise(
            qtyBase: l.qtyBase,
            ratePaise: l.ratePaise,
            priceUnitFactor: l.priceUnitFactor,
          );
          lineTotals.add(amount);
          subtotal += amount;
          tax += Money.taxPaise(amount, l.gstRateBp);
        }
        final total = subtotal + tax;

        await ctx.insertRow(
          ctx.db.purchases,
          PurchasesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            supplierId: input.supplierId,
            supplierInvoiceNo: input.supplierInvoiceNo.trim(),
            supplierInvoiceDate: input.supplierInvoiceDate,
            subtotalPaise: subtotal,
            taxPaise: tax,
            totalPaise: total,
            source: Value(input.source),
            photoId: Value(input.photoId),
          ),
          'purchases',
          id,
        );

        for (var n = 0; n < input.lines.length; n++) {
          final l = input.lines[n];
          final lid = ctx.newId();
          await ctx.insertRow(
            ctx.db.purchaseLines,
            PurchaseLinesCompanion.insert(
              id: lid,
              shopId: ctx.shopId,
              createdAt: now,
              updatedAt: now,
              purchaseId: id,
              itemId: l.itemId,
              unitName: l.unitName,
              qtyEntered: l.qtyEntered,
              qtyBase: l.qtyBase,
              ratePaise: l.ratePaise,
              lineTotalPaise: lineTotals[n],
              variantId: Value(l.variantId),
              priceUnitFactor: Value(l.priceUnitFactor),
              gstRateBp: Value(l.gstRateBp),
            ),
            'purchase_lines',
            lid,
          );
          await _stock.record(
            itemId: l.itemId,
            variantId: l.variantId,
            locationId: input.locationId,
            qtyBase: l.qtyBase,
            movementType: 'purchase',
            refType: 'purchase',
            refId: id,
            createdBy: input.createdBy,
            ts: input.supplierInvoiceDate,
          );
          // The latest purchase price becomes the item's cost (ex-GST, paise
          // per metre/piece). History is kept; unchanged prices add no row.
          final latestCost = await _items.latestCost(l.itemId);
          if (latestCost != l.ratePaise) {
            await _items.setCost(
              itemId: l.itemId,
              variantId: l.variantId,
              costPaise: l.ratePaise,
              effectiveFrom: input.supplierInvoiceDate,
            );
          }
        }

        await _ledger.addEntry(
          partyId: input.supplierId,
          entryType: 'purchase',
          amountPaise: -total,
          refType: 'purchase',
          refId: id,
          note: input.supplierInvoiceNo.trim(),
          ts: input.supplierInvoiceDate,
        );
      });
    } catch (e) {
      if (RepoContext.isUniqueViolation(e)) {
        throw DuplicatePurchaseException(input.supplierInvoiceNo.trim());
      }
      rethrow;
    }
    return id;
  }

  /// Cancels a purchase entered by mistake (for example the same supplier bill
  /// entered on both phones). Nothing posted is edited: the stock goes back out
  /// as a purchase return, the supplier's account gets a reversing adjustment
  /// for the full total, and the purchase is marked cancelled. Audited.
  Future<void> cancelPurchase(
    String purchaseId, {
    String? reason,
    String? createdBy,
    String? approvedBy,
  }) async {
    await ctx.db.transaction(() async {
      final purchase = await (ctx.db.select(ctx.db.purchases)..where((t) => t.id.equals(purchaseId))).getSingleOrNull();
      if (purchase == null) throw DomainException('Unknown purchase: $purchaseId');
      if (purchase.status == 'cancelled') {
        throw DomainException('Purchase ${purchase.supplierInvoiceNo} is already cancelled.');
      }
      final now = ctx.clock();
      // Take back exactly what each line added, from where it was added.
      final added = await (ctx.db.select(ctx.db.stockMovements)
            ..where((t) =>
                t.refType.equals('purchase') &
                t.refId.equals(purchaseId) &
                t.movementType.equals('purchase') &
                t.deletedAt.isNull()))
          .get();
      for (final m in added) {
        await _stock.record(
          itemId: m.itemId,
          variantId: m.variantId,
          locationId: m.locationId,
          qtyBase: -m.qtyBase,
          movementType: 'purchase_return',
          refType: 'purchase',
          refId: purchaseId,
          createdBy: createdBy,
          note: 'Cancelled purchase ${purchase.supplierInvoiceNo}',
          ts: now,
        );
      }
      await _ledger.addEntry(
        partyId: purchase.supplierId,
        entryType: 'adjustment',
        amountPaise: purchase.totalPaise,
        refType: 'purchase',
        refId: purchaseId,
        note: 'Cancelled purchase ${purchase.supplierInvoiceNo}',
        ts: now,
      );
      await (ctx.db.update(ctx.db.purchases)..where((t) => t.id.equals(purchaseId)))
          .write(PurchasesCompanion(status: const Value('cancelled'), updatedAt: Value(now)));
      final after = await (ctx.db.select(ctx.db.purchases)..where((t) => t.id.equals(purchaseId))).getSingle();
      await ctx.recordOutbox('purchases', purchaseId, 'upsert', after.toJson());
      await AuditRepository(ctx).record(
        action: 'purchase_cancelled',
        entity: 'purchase',
        entityId: purchaseId,
        userId: createdBy,
        before: {'status': purchase.status},
        after: {
          'status': 'cancelled',
          'supplierInvoiceNo': purchase.supplierInvoiceNo,
          'totalPaise': purchase.totalPaise,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
          if (approvedBy != null && approvedBy != createdBy) 'approvedBy': approvedBy,
        },
      );
    });
  }

  /// Purchases of the same supplier bill (supplier and number) that are both
  /// still standing: entered twice, usually once on each phone.
  Future<Set<String>> duplicatedPurchaseIds() async {
    final rows = await ctx.db.customSelect(
      'SELECT p.id FROM purchases p JOIN ('
      '  SELECT supplier_id, supplier_invoice_no FROM purchases'
      "  WHERE deleted_at IS NULL AND status != 'cancelled'"
      '  GROUP BY supplier_id, supplier_invoice_no HAVING COUNT(*) > 1) d'
      ' ON d.supplier_id = p.supplier_id AND d.supplier_invoice_no = p.supplier_invoice_no'
      " WHERE p.deleted_at IS NULL AND p.status != 'cancelled'",
      readsFrom: {ctx.db.purchases},
    ).get();
    return {for (final r in rows) r.data['id'] as String};
  }

  /// Purchases for the list screen, newest first, with the supplier name.
  Future<List<PurchaseListEntry>> list({
    DateTime? from,
    DateTime? to,
    String? supplierId,
    int limit = 200,
  }) async {
    final p = ctx.db.purchases;
    final q = ctx.db.select(p).join([
      innerJoin(ctx.db.parties, ctx.db.parties.id.equalsExp(p.supplierId)),
    ])
      ..where(p.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.desc(p.supplierInvoiceDate),
        OrderingTerm.desc(p.createdAt),
      ])
      ..limit(limit);
    if (from != null) q.where(p.supplierInvoiceDate.isBiggerOrEqualValue(from));
    if (to != null) q.where(p.supplierInvoiceDate.isSmallerOrEqualValue(to));
    if (supplierId != null) q.where(p.supplierId.equals(supplierId));
    final rows = await q.get();
    return [
      for (final r in rows)
        PurchaseListEntry(r.readTable(p), r.readTable(ctx.db.parties).name),
    ];
  }

  /// A saved purchase with its lines, for the read-only detail screen.
  Future<PurchaseDetails> details(String purchaseId) async {
    final purchase = await (ctx.db.select(ctx.db.purchases)
          ..where((t) => t.id.equals(purchaseId)))
        .getSingleOrNull();
    if (purchase == null) throw DomainException('Unknown purchase: $purchaseId');
    final lines = await (ctx.db.select(ctx.db.purchaseLines)
          ..where((t) => t.purchaseId.equals(purchaseId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final names = <String, String>{};
    for (final l in lines) {
      names[l.itemId] = (await _items.getItem(l.itemId)).name;
    }
    final supplier = await (ctx.db.select(ctx.db.parties)
          ..where((t) => t.id.equals(purchase.supplierId)))
        .getSingle();
    return PurchaseDetails(
      purchase: purchase,
      lines: lines,
      itemNames: names,
      supplier: supplier,
    );
  }
}

class PurchaseListEntry {
  const PurchaseListEntry(this.purchase, this.supplierName);
  final Purchase purchase;
  final String supplierName;
}

class PurchaseDetails {
  const PurchaseDetails({
    required this.purchase,
    required this.lines,
    required this.itemNames,
    required this.supplier,
  });

  final Purchase purchase;
  final List<PurchaseLine> lines;

  /// itemId -> item name.
  final Map<String, String> itemNames;
  final Party supplier;
}
