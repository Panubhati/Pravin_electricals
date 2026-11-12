import 'package:drift/drift.dart';

import '../../money.dart';
import '../../units.dart';
import '../app_database.dart';
import 'audit_repository.dart';
import 'ledger_repository.dart';
import 'repo_context.dart';
import 'stock_repository.dart';

/// One line the customer is bringing back: which bill line, and how much of it,
/// in the unit it was sold in ("1.5" for 1.5 m).
class ReturnLineInput {
  const ReturnLineInput(this.invoiceLineId, this.qtyEntered, {this.qtyBase});
  final String invoiceLineId;
  final String qtyEntered;

  /// Exact base units, when known (a cancel returns exactly what was sold).
  /// Otherwise the quantity is read from [qtyEntered] in the line's own unit.
  final int? qtyBase;
}

/// How the money goes back. The three add up to the refund total.
class RefundSplit {
  const RefundSplit({this.cashPaise = 0, this.upiPaise = 0, this.accountPaise = 0});
  final int cashPaise;
  final int upiPaise;

  /// Taken off what the customer owes (needs a customer on the bill).
  final int accountPaise;

  int get totalPaise => cashPaise + upiPaise + accountPaise;
}

/// A bill line with how much of it can still be returned.
class ReturnableLine {
  const ReturnableLine({
    required this.line,
    required this.itemName,
    required this.factorToBase,
    required this.returnedBase,
  });
  final InvoiceLine line;
  final String itemName;

  /// Base units in one [InvoiceLine.unitName] (1000 for metres).
  final int factorToBase;
  final int returnedBase;

  int get remainingBase => line.qtyBase - returnedBase;
  bool get fullyReturned => remainingBase <= 0;
}

/// What a return would refund, worked out but not yet saved.
class ReturnQuote {
  const ReturnQuote({
    required this.lines,
    required this.linesTotalPaise,
    required this.roundOffPaise,
    required this.taxPaise,
    required this.completesBill,
  });
  final List<QuotedLine> lines;
  final int linesTotalPaise;

  /// The bill's round-off, given back with the return that completes the bill.
  final int roundOffPaise;
  final int taxPaise;

  /// True when nothing of the bill is left to return after this.
  final bool completesBill;

  int get totalPaise => linesTotalPaise + roundOffPaise;
}

class QuotedLine {
  const QuotedLine({
    required this.invoiceLine,
    required this.itemName,
    required this.qtyEntered,
    required this.qtyBase,
    required this.refundPaise,
    required this.taxPaise,
  });
  final InvoiceLine invoiceLine;
  final String itemName;
  final String qtyEntered;
  final int qtyBase;
  final int refundPaise;
  final int taxPaise;
}

class PostReturnInput {
  const PostReturnInput({
    required this.invoiceId,
    required this.deviceId,
    required this.series,
    required this.lines,
    required this.refund,
    this.reason,
    this.createdBy,
    this.approvedBy,
    this.date,
  });
  final String invoiceId;

  /// This phone's bill series, for the credit note number.
  final String deviceId;
  final String series;
  final List<ReturnLineInput> lines;
  final RefundSplit refund;
  final String? reason;
  final String? createdBy;
  final String? approvedBy;
  final DateTime? date;
}

/// A saved credit note with its lines, for showing and printing.
class ReturnDetails {
  const ReturnDetails({required this.ret, required this.lines, required this.itemNames, required this.invoice, this.party});
  final SalesReturn ret;
  final List<SalesReturnLine> lines;
  final Map<String, String> itemNames;
  final Invoice invoice;
  final Party? party;
}

/// Takes sold goods back: part of a bill (a return) or all of it (cancel).
///
/// A posted bill is never edited. A return adds a credit note, puts the stock
/// back, and gives the money back (cash or UPI) or lowers what the customer owes.
/// Everything is one transaction, so it all happens or none of it does.
class ReturnRepository {
  ReturnRepository(this.ctx)
      : _stock = StockRepository(ctx),
        _ledger = LedgerRepository(ctx),
        _audit = AuditRepository(ctx);

  final RepoContext ctx;
  final StockRepository _stock;
  final LedgerRepository _ledger;
  final AuditRepository _audit;

  AppDatabase get _db => ctx.db;

  static String formatNumber(String series, int number) =>
      'CN-$series-${number.toString().padLeft(4, '0')}';

  /// Next free credit note number in this device's series.
  Future<int> nextNumber(String deviceId, String series) async {
    final r = _db.salesReturns;
    final maxNo = r.number.max();
    final row = await (_db.selectOnly(r)
          ..addColumns([maxNo])
          ..where(r.deviceId.equals(deviceId) & r.series.equals(series)))
        .getSingle();
    return (row.read(maxNo) ?? 0) + 1;
  }

  /// The bill's lines with how much of each can still be returned.
  Future<List<ReturnableLine>> returnable(String invoiceId) async {
    final lines = await (_db.select(_db.invoiceLines)
          ..where((t) => t.invoiceId.equals(invoiceId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt), (t) => OrderingTerm.asc(const CustomExpression<int>('rowid'))]))
        .get();
    final returned = <String, int>{};
    final rows = await _db.customSelect(
      'SELECT rl.invoice_line_id AS id, SUM(rl.qty_base) AS q FROM sales_return_lines rl '
      'JOIN sales_returns r ON r.id = rl.return_id '
      'WHERE r.invoice_id = ? AND rl.deleted_at IS NULL AND r.deleted_at IS NULL GROUP BY rl.invoice_line_id',
      variables: [Variable.withString(invoiceId)],
    ).get();
    for (final r in rows) {
      returned[r.data['id'] as String] = (r.data['q'] as num).toInt();
    }
    final out = <ReturnableLine>[];
    for (final l in lines) {
      final item = await (_db.select(_db.items)..where((t) => t.id.equals(l.itemId))).getSingle();
      final unit = await (_db.select(_db.itemUnits)
            ..where((t) => t.itemId.equals(l.itemId) & t.unitName.equals(l.unitName) & t.deletedAt.isNull()))
          .getSingleOrNull();
      out.add(ReturnableLine(
        line: l,
        itemName: item.name,
        factorToBase: unit?.factorToBase ?? 1,
        returnedBase: returned[l.id] ?? 0,
      ));
    }
    return out;
  }

  /// Half-up share of [amount] for [part] of [whole] base units.
  static int _share(int amount, int part, int whole) => Money.divRoundHalfUp(amount * part, whole);

  /// Works out what returning [lines] of [invoiceId] refunds, or explains why it cannot be done.
  /// Refunds follow the cumulative quantity returned, so returning a line in
  /// pieces always adds up to exactly what the line sold for.
  Future<ReturnQuote> quote(String invoiceId, List<ReturnLineInput> lines) async {
    final invoice = await _invoice(invoiceId);
    if (invoice.status == 'cancelled') throw DomainException('Bill ${invoice.invoiceNoText} is already cancelled.');
    if (lines.isEmpty) throw DomainException('Choose what is being returned.');
    final available = {for (final r in await returnable(invoiceId)) r.line.id: r};

    final asked = <String, int>{};
    final quoted = <QuotedLine>[];
    var total = 0, tax = 0;
    for (final input in lines) {
      final r = available[input.invoiceLineId];
      if (r == null) throw DomainException('That item is not on bill ${invoice.invoiceNoText}.');
      if (asked.containsKey(input.invoiceLineId)) throw DomainException('${r.itemName} is listed twice.');
      final int qty;
      try {
        qty = input.qtyBase ?? Units.toBaseUnits(input.qtyEntered, r.factorToBase);
      } on FormatException {
        throw DomainException('${r.itemName}: "${input.qtyEntered}" is not a valid quantity.');
      }
      if (qty <= 0) throw DomainException('${r.itemName}: the quantity must be more than 0.');
      if (qty > r.remainingBase) {
        throw DomainException(
            '${r.itemName}: only ${Units.formatQty(r.remainingBase, r.factorToBase)} ${r.line.unitName} can still be returned.');
      }
      asked[input.invoiceLineId] = qty;
      final before = r.returnedBase;
      final after = before + qty;
      final whole = r.line.qtyBase;
      final refund = _share(r.line.lineTotalPaise, after, whole) - _share(r.line.lineTotalPaise, before, whole);
      final gst = _share(r.line.taxPaise, after, whole) - _share(r.line.taxPaise, before, whole);
      quoted.add(QuotedLine(
        invoiceLine: r.line,
        itemName: r.itemName,
        qtyEntered: input.qtyEntered.trim(),
        qtyBase: qty,
        refundPaise: refund,
        taxPaise: gst,
      ));
      total += refund;
      tax += gst;
    }

    final completes = available.values.every((r) => r.remainingBase - (asked[r.line.id] ?? 0) == 0);
    var roundOff = 0;
    if (completes) {
      final prior = await _db.customSelect(
        'SELECT COALESCE(SUM(round_off_paise), 0) AS n FROM sales_returns WHERE invoice_id = ? AND deleted_at IS NULL',
        variables: [Variable.withString(invoiceId)],
      ).getSingle();
      roundOff = invoice.roundOffPaise - (prior.data['n'] as num).toInt();
    }
    return ReturnQuote(
      lines: quoted,
      linesTotalPaise: total,
      roundOffPaise: roundOff,
      taxPaise: tax,
      completesBill: completes,
    );
  }

  /// Saves a return: credit note, stock back, refund, all or nothing.
  Future<String> postReturn(PostReturnInput input) => _post(input, isCancel: false);

  /// Cancels a whole bill that has had nothing returned yet: every line comes
  /// back and the money goes back the way it came (cash to cash, UPI to UPI,
  /// the credit part off the customer's account). The bill is then marked cancelled.
  Future<String> cancelBill(
    String invoiceId, {
    required String deviceId,
    required String series,
    String? reason,
    String? createdBy,
    String? approvedBy,
    DateTime? date,
  }) async {
    final invoice = await _invoice(invoiceId);
    if (invoice.status == 'cancelled') throw DomainException('Bill ${invoice.invoiceNoText} is already cancelled.');
    final lines = await returnable(invoiceId);
    if (lines.any((l) => l.returnedBase > 0)) {
      throw DomainException(
          'Some of bill ${invoice.invoiceNoText} has already been returned. Return the rest instead of cancelling.');
    }
    final payments = await (_db.select(_db.invoicePayments)
          ..where((t) => t.invoiceId.equals(invoiceId) & t.deletedAt.isNull()))
        .get();
    var cash = 0, upi = 0, account = 0;
    for (final p in payments) {
      switch (p.mode) {
        case 'cash':
          cash += p.amountPaise;
        case 'credit':
          account += p.amountPaise;
        default: // upi and card go back by UPI
          upi += p.amountPaise;
      }
    }
    return _post(
      PostReturnInput(
        invoiceId: invoiceId,
        deviceId: deviceId,
        series: series,
        lines: [for (final l in lines) ReturnLineInput(l.line.id, l.line.qtyEntered, qtyBase: l.line.qtyBase)],
        refund: RefundSplit(cashPaise: cash, upiPaise: upi, accountPaise: account),
        reason: reason,
        createdBy: createdBy,
        approvedBy: approvedBy,
        date: date,
      ),
      isCancel: true,
    );
  }

  Future<String> _post(PostReturnInput input, {required bool isCancel}) async {
    final now = ctx.clock();
    final when = input.date ?? now;
    final id = ctx.newId();
    final reason = input.reason?.trim();
    late String noText;

    try {
      await _db.transaction(() async {
        final invoice = await _invoice(input.invoiceId);
        final q = await quote(input.invoiceId, input.lines);
        final split = input.refund;

        if (split.cashPaise < 0 || split.upiPaise < 0 || split.accountPaise < 0) {
          throw DomainException('Refund amounts cannot be negative.');
        }
        if (split.totalPaise != q.totalPaise) {
          throw DomainException(
              'The refund (${Money.format(split.totalPaise)}) must add up to ${Money.format(q.totalPaise)}.');
        }
        if (split.accountPaise > 0 && invoice.partyId == null) {
          throw DomainException('Only a bill with a customer can be refunded to their account.');
        }

        final number = await nextNumber(input.deviceId, input.series);
        noText = formatNumber(input.series, number);

        await ctx.insertRow(
          _db.salesReturns,
          SalesReturnsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            invoiceId: input.invoiceId,
            deviceId: input.deviceId,
            series: input.series,
            number: number,
            creditNoteNoText: noText,
            date: when,
            totalPaise: q.totalPaise,
            taxPaise: Value(q.taxPaise),
            roundOffPaise: Value(q.roundOffPaise),
            refundCashPaise: Value(split.cashPaise),
            refundUpiPaise: Value(split.upiPaise),
            refundAccountPaise: Value(split.accountPaise),
            isCancel: Value(isCancel),
            note: Value(reason == null || reason.isEmpty ? null : reason),
            createdBy: Value(input.createdBy),
            approvedBy: Value(input.approvedBy),
          ),
          'sales_returns',
          id,
        );

        for (final l in q.lines) {
          final lid = ctx.newId();
          await ctx.insertRow(
            _db.salesReturnLines,
            SalesReturnLinesCompanion.insert(
              id: lid,
              shopId: ctx.shopId,
              createdAt: now,
              updatedAt: now,
              returnId: id,
              invoiceLineId: l.invoiceLine.id,
              itemId: l.invoiceLine.itemId,
              variantId: Value(l.invoiceLine.variantId),
              unitName: l.invoiceLine.unitName,
              qtyEntered: l.qtyEntered,
              qtyBase: l.qtyBase,
              lineTotalPaise: l.refundPaise,
              taxPaise: Value(l.taxPaise),
            ),
            'sales_return_lines',
            lid,
          );
          await _stock.record(
            itemId: l.invoiceLine.itemId,
            variantId: l.invoiceLine.variantId,
            locationId: await _saleLocation(input.invoiceId, l.invoiceLine.itemId),
            qtyBase: l.qtyBase,
            movementType: 'sale_return',
            refType: 'sales_return',
            refId: id,
            createdBy: input.createdBy,
            note: noText,
            ts: when,
          );
        }

        if (split.accountPaise > 0) {
          await _ledger.addEntry(
            partyId: invoice.partyId!,
            entryType: 'return',
            amountPaise: -split.accountPaise,
            refType: 'sales_return',
            refId: id,
            note: noText,
            ts: when,
          );
        }

        if (isCancel) {
          await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id))).write(
            InvoicesCompanion(status: const Value('cancelled'), updatedAt: Value(now)),
          );
          final after = await _invoice(invoice.id);
          await ctx.recordOutbox('invoices', invoice.id, 'upsert', after.toJson());
        }

        await _audit.record(
          action: isCancel ? 'bill_cancelled' : 'sales_return',
          entity: 'invoice',
          entityId: invoice.id,
          userId: input.createdBy,
          after: {
            'invoice': invoice.invoiceNoText,
            'creditNote': noText,
            'totalPaise': q.totalPaise,
            'refundCashPaise': split.cashPaise,
            'refundUpiPaise': split.upiPaise,
            'refundAccountPaise': split.accountPaise,
            'reason': reason,
            'approvedBy': input.approvedBy,
          },
        );
      });
    } catch (e) {
      if (RepoContext.isUniqueViolation(e)) {
        throw DomainException('That credit note number was just used. Please try again.');
      }
      rethrow;
    }
    return id;
  }

  Future<Invoice> _invoice(String id) async {
    final i = await (_db.select(_db.invoices)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (i == null) throw DomainException('Unknown bill.');
    return i;
  }

  /// Where the item left stock when it was sold, so a return puts it back there.
  Future<String> _saleLocation(String invoiceId, String itemId) async {
    final m = await (_db.select(_db.stockMovements)
          ..where((t) =>
              t.refType.equals('invoice') &
              t.refId.equals(invoiceId) &
              t.itemId.equals(itemId) &
              t.movementType.equals('sale') &
              t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (m == null) throw DomainException('The stock for this sale could not be found.');
    return m.locationId;
  }

  /// Credit notes made against a bill, oldest first.
  Future<List<SalesReturn>> forInvoice(String invoiceId) => (_db.select(_db.salesReturns)
        ..where((t) => t.invoiceId.equals(invoiceId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.number)]))
      .get();

  Future<ReturnDetails> details(String returnId) async {
    final ret = await (_db.select(_db.salesReturns)..where((t) => t.id.equals(returnId))).getSingleOrNull();
    if (ret == null) throw DomainException('Unknown credit note.');
    final lines = await (_db.select(_db.salesReturnLines)
          ..where((t) => t.returnId.equals(returnId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt), (t) => OrderingTerm.asc(const CustomExpression<int>('rowid'))]))
        .get();
    final names = <String, String>{};
    for (final l in lines) {
      names[l.itemId] = (await (_db.select(_db.items)..where((t) => t.id.equals(l.itemId))).getSingle()).name;
    }
    final invoice = await _invoice(ret.invoiceId);
    final party = invoice.partyId == null
        ? null
        : await (_db.select(_db.parties)..where((t) => t.id.equals(invoice.partyId!))).getSingleOrNull();
    return ReturnDetails(ret: ret, lines: lines, itemNames: names, invoice: invoice, party: party);
  }
}
