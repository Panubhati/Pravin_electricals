import 'package:drift/drift.dart';

import '../../units.dart';
import '../app_database.dart';
import 'item_repository.dart';
import 'ledger_repository.dart';
import 'repo_context.dart';
import 'stock_repository.dart';

class InvoiceLineInput {
  const InvoiceLineInput({
    required this.itemId,
    required this.unitName,
    required this.qtyEntered,
    required this.qtyBase,
    required this.ratePaise,
    required this.priceUnitFactor,
    required this.taxPaise,
    required this.lineTotalPaise,
    this.variantId,
    this.discountPaise = 0,
    this.gstRateBp = 0,
  });

  final String itemId;
  final String? variantId;
  final String unitName;

  /// Quantity as typed by staff, e.g. "2.5".
  final String qtyEntered;
  final int qtyBase;

  /// Paise per pricing unit.
  final int ratePaise;
  final int priceUnitFactor;
  final int discountPaise;
  final int gstRateBp;
  final int taxPaise;

  /// amount - discount + tax, where amount = qtyBase x rate / priceUnitFactor.
  final int lineTotalPaise;
}

class PaymentInput {
  const PaymentInput(this.mode, this.amountPaise, {this.ref});

  /// cash | upi | credit | card
  final String mode;
  final int amountPaise;
  final String? ref;
}

class PostInvoiceInput {
  const PostInvoiceInput({
    required this.deviceId,
    required this.series,
    required this.number,
    required this.date,
    required this.locationId,
    required this.subtotalPaise,
    required this.discountPaise,
    required this.taxPaise,
    required this.roundOffPaise,
    required this.totalPaise,
    required this.lines,
    required this.payments,
    this.partyId,
    this.createdBy,
    this.shopSnapshotJson,
  });

  final String deviceId;
  final String series;
  final int number;
  final DateTime date;

  /// Where the stock is taken from.
  final String locationId;

  /// Null for a walk-in customer (then everything must be paid, no credit).
  final String? partyId;

  /// Sum of line amounts, before discount and tax.
  final int subtotalPaise;

  /// Sum of line discounts.
  final int discountPaise;
  final int taxPaise;
  final int roundOffPaise;

  /// subtotal - discount + tax + roundOff.
  final int totalPaise;
  final List<InvoiceLineInput> lines;

  /// Must add up to [totalPaise]; the 'credit' part becomes a receivable.
  final List<PaymentInput> payments;
  final String? createdBy;
  final String? shopSnapshotJson;
}

/// Posts sales invoices. A posted invoice is immutable: this class has no
/// update or delete. Corrections are returns or credit notes (reversing entries).
class InvoiceRepository {
  InvoiceRepository(this.ctx)
      : _items = ItemRepository(ctx),
        _stock = StockRepository(ctx),
        _ledger = LedgerRepository(ctx);

  final RepoContext ctx;
  final ItemRepository _items;
  final StockRepository _stock;
  final LedgerRepository _ledger;

  static String formatNumber(String series, int number) =>
      '$series-${number.toString().padLeft(4, '0')}';

  /// Next free number in this device's series (max + 1).
  Future<int> nextNumber(String deviceId, String series) async {
    final i = ctx.db.invoices;
    final maxNo = i.number.max();
    final q = ctx.db.selectOnly(i)
      ..addColumns([maxNo])
      ..where(i.deviceId.equals(deviceId) & i.series.equals(series));
    final row = await q.getSingle();
    return (row.read(maxNo) ?? 0) + 1;
  }

  /// Saves invoice, lines, payments, stock movements (sale), the receivable
  /// ledger entry for the credit part, and outbox rows, all in one transaction.
  /// Returns the invoice id.
  Future<String> postInvoice(PostInvoiceInput input) async {
    if (input.lines.isEmpty) throw DomainException('Invoice has no lines');
    final noText = formatNumber(input.series, input.number);
    final now = ctx.clock();
    final id = ctx.newId();

    try {
      await ctx.db.transaction(() async {
        await _validate(input);

        await ctx.insertRow(
          ctx.db.invoices,
          InvoicesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            deviceId: input.deviceId,
            series: input.series,
            number: input.number,
            invoiceNoText: noText,
            date: input.date,
            subtotalPaise: input.subtotalPaise,
            discountPaise: Value(input.discountPaise),
            taxPaise: input.taxPaise,
            roundOffPaise: Value(input.roundOffPaise),
            totalPaise: input.totalPaise,
            paidPaise: Value(_paid(input)),
            partyId: Value(input.partyId),
            shopSnapshotJson: Value(input.shopSnapshotJson),
            createdBy: Value(input.createdBy),
          ),
          'invoices',
          id,
        );

        for (final l in input.lines) {
          final lid = ctx.newId();
          await ctx.insertRow(
            ctx.db.invoiceLines,
            InvoiceLinesCompanion.insert(
              id: lid,
              shopId: ctx.shopId,
              createdAt: now,
              updatedAt: now,
              invoiceId: id,
              itemId: l.itemId,
              unitName: l.unitName,
              qtyEntered: l.qtyEntered,
              qtyBase: l.qtyBase,
              ratePaise: l.ratePaise,
              taxPaise: l.taxPaise,
              lineTotalPaise: l.lineTotalPaise,
              variantId: Value(l.variantId),
              priceUnitFactor: Value(l.priceUnitFactor),
              discountPaise: Value(l.discountPaise),
              gstRateBp: Value(l.gstRateBp),
            ),
            'invoice_lines',
            lid,
          );
        }

        for (final p in input.payments) {
          final pid = ctx.newId();
          await ctx.insertRow(
            ctx.db.invoicePayments,
            InvoicePaymentsCompanion.insert(
              id: pid,
              shopId: ctx.shopId,
              createdAt: now,
              updatedAt: now,
              invoiceId: id,
              mode: p.mode,
              amountPaise: p.amountPaise,
              ref: Value(p.ref),
            ),
            'invoice_payments',
            pid,
          );
        }

        for (final l in input.lines) {
          await _stock.record(
            itemId: l.itemId,
            variantId: l.variantId,
            locationId: input.locationId,
            qtyBase: -l.qtyBase,
            movementType: 'sale',
            refType: 'invoice',
            refId: id,
            createdBy: input.createdBy,
            ts: input.date,
          );
        }

        final credit = _credit(input);
        if (credit > 0) {
          await _ledger.addEntry(
            partyId: input.partyId!,
            entryType: 'invoice',
            amountPaise: credit,
            refType: 'invoice',
            refId: id,
            note: noText,
            ts: input.date,
          );
        }
      });
    } catch (e) {
      if (RepoContext.isUniqueViolation(e)) {
        throw DuplicateInvoiceNumberException(noText);
      }
      rethrow;
    }
    return id;
  }

  int _paid(PostInvoiceInput i) => i.payments
      .where((p) => p.mode != 'credit')
      .fold(0, (a, p) => a + p.amountPaise);

  int _credit(PostInvoiceInput i) => i.payments
      .where((p) => p.mode == 'credit')
      .fold(0, (a, p) => a + p.amountPaise);

  Future<void> _validate(PostInvoiceInput i) async {
    var subtotal = 0;
    var discount = 0;
    var tax = 0;
    for (final l in i.lines) {
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
      if (l.discountPaise < 0 || l.discountPaise > amount) {
        throw DomainException('Line for ${item.name}: bad discount');
      }
      if (l.lineTotalPaise != amount - l.discountPaise + l.taxPaise) {
        throw DomainException(
            'Line for ${item.name}: line total does not match amount - '
            'discount + tax');
      }
      subtotal += amount;
      discount += l.discountPaise;
      tax += l.taxPaise;
    }
    if (i.subtotalPaise != subtotal) {
      throw DomainException('Subtotal does not match the sum of lines');
    }
    if (i.discountPaise != discount) {
      throw DomainException('Discount does not match the sum of lines');
    }
    if (i.taxPaise != tax) {
      throw DomainException('Tax does not match the sum of lines');
    }
    if (i.totalPaise !=
        i.subtotalPaise - i.discountPaise + i.taxPaise + i.roundOffPaise) {
      throw DomainException(
          'Total must equal subtotal - discount + tax + round-off');
    }
    for (final p in i.payments) {
      if (p.amountPaise <= 0) throw DomainException('Payment must be > 0');
      if (!const {'cash', 'upi', 'credit', 'card'}.contains(p.mode)) {
        throw DomainException('Unknown payment mode: ${p.mode}');
      }
    }
    final paySum = i.payments.fold(0, (a, p) => a + p.amountPaise);
    if (paySum != i.totalPaise) {
      throw DomainException('Payments must add up to the invoice total');
    }
    if (_credit(i) > 0 && i.partyId == null) {
      throw DomainException('Credit sale needs a customer');
    }
  }
}
