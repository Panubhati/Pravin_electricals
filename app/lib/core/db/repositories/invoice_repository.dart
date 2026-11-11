import 'package:drift/drift.dart';

import '../../money.dart';
import '../../units.dart';
import '../app_database.dart';
import 'audit_repository.dart';
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

  /// GST contained in [lineTotalPaise] (informational, not added on top).
  final int taxPaise;

  /// What the customer pays for the line, GST included: amount - discount,
  /// where amount = qtyBase x rate / priceUnitFactor. [taxPaise] is the GST
  /// contained in this figure (prices include GST).
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

  /// Sum of line amounts (GST-inclusive), before discount.
  final int subtotalPaise;

  /// Sum of line discounts.
  final int discountPaise;

  /// GST contained in the total (sum of line taxes). Not added on top.
  final int taxPaise;
  final int roundOffPaise;

  /// subtotal - discount + roundOff.
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
        _ledger = LedgerRepository(ctx),
        _audit = AuditRepository(ctx);

  final RepoContext ctx;
  final ItemRepository _items;
  final StockRepository _stock;
  final LedgerRepository _ledger;
  final AuditRepository _audit;

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
          final hsn = (await _items.getItem(l.itemId)).hsn;
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
              hsn: Value(hsn),
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

        if (input.discountPaise > 0) {
          await _audit.record(
            action: 'discount',
            entity: 'invoice',
            entityId: id,
            userId: input.createdBy,
            after: {
              'invoice': noText,
              'discountPaise': input.discountPaise,
              'lines': [
                for (final l in input.lines)
                  if (l.discountPaise > 0)
                    {'itemId': l.itemId, 'discountPaise': l.discountPaise},
              ],
            },
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

  /// Saved bills for the history screen, newest first. [query] matches the bill
  /// number or the customer's name; [from] and [to] limit by day (inclusive).
  Future<List<InvoiceListEntry>> list({
    String query = '',
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final db = ctx.db;
    final q = query.trim().replaceAll('%', '').replaceAll('_', '');
    final select = db.select(db.invoices).join([
      leftOuterJoin(db.parties, db.parties.id.equalsExp(db.invoices.partyId)),
    ])
      ..where(db.invoices.deletedAt.isNull() & db.invoices.shopId.equals(ctx.shopId))
      ..orderBy([
        OrderingTerm.desc(db.invoices.date),
        OrderingTerm.desc(db.invoices.number),
      ])
      ..limit(limit);
    if (q.isNotEmpty) {
      select.where(db.invoices.invoiceNoText.like('%$q%') | db.parties.name.like('%$q%'));
    }
    if (from != null) {
      select.where(db.invoices.date
          .isBiggerOrEqualValue(DateTime(from.year, from.month, from.day)));
    }
    if (to != null) {
      select.where(db.invoices.date
          .isSmallerThanValue(DateTime(to.year, to.month, to.day + 1)));
    }
    return [
      for (final r in await select.get())
        InvoiceListEntry(r.readTable(db.invoices), r.readTableOrNull(db.parties)?.name),
    ];
  }

  /// Everything needed to print or review a saved invoice.
  Future<InvoiceDetails> details(String invoiceId) async {
    final db = ctx.db;
    final invoice = await (db.select(db.invoices)
          ..where((t) => t.id.equals(invoiceId)))
        .getSingleOrNull();
    if (invoice == null) throw DomainException('Unknown invoice: $invoiceId');
    final lines = await (db.select(db.invoiceLines)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final names = <String, String>{};
    final hsns = <String, String>{};
    for (final l in lines) {
      final item = await _items.getItem(l.itemId);
      names[l.itemId] = item.name;
      if (item.hsn != null && item.hsn!.isNotEmpty) hsns[l.itemId] = item.hsn!;
    }
    final payments = await (db.select(db.invoicePayments)
          ..where((t) => t.invoiceId.equals(invoiceId)))
        .get();
    Party? party;
    if (invoice.partyId != null) {
      party = await (db.select(db.parties)
            ..where((t) => t.id.equals(invoice.partyId!)))
          .getSingleOrNull();
    }
    return InvoiceDetails(
      invoice: invoice,
      lines: lines,
      itemNames: names,
      itemHsn: hsns,
      payments: payments,
      party: party,
    );
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
      final gross = amount - l.discountPaise;
      if (l.lineTotalPaise != gross) {
        throw DomainException(
            'Line for ${item.name}: line total must equal amount - discount '
            '(prices include GST)');
      }
      if (l.taxPaise != Money.taxIncluded(gross, l.gstRateBp)) {
        throw DomainException(
            'Line for ${item.name}: GST does not match the rate');
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
    if (i.totalPaise != i.subtotalPaise - i.discountPaise + i.roundOffPaise) {
      throw DomainException('Total must equal subtotal - discount + round-off');
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

/// One row of the bills list.
class InvoiceListEntry {
  const InvoiceListEntry(this.invoice, this.partyName);
  final Invoice invoice;

  /// Null for a walk-in customer.
  final String? partyName;

  /// Still to be collected from the customer (the credit part of the bill).
  int get duePaise => invoice.totalPaise - invoice.paidPaise;
}

/// A saved invoice with its lines, payments and customer, for printing.
class InvoiceDetails {
  const InvoiceDetails({
    required this.invoice,
    required this.lines,
    required this.itemNames,
    required this.payments,
    this.itemHsn = const {},
    this.party,
  });

  final Invoice invoice;
  final List<InvoiceLine> lines;

  /// itemId -> item name.
  final Map<String, String> itemNames;

  /// itemId -> the item's current HSN, used only for lines saved before schema v4.
  final Map<String, String> itemHsn;
  final List<InvoicePayment> payments;
  final Party? party;
}
