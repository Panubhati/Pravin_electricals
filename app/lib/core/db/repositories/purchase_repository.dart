import 'package:drift/drift.dart';

import '../../money.dart';
import '../../units.dart';
import '../app_database.dart';
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
}
