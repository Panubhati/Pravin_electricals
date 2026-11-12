import 'package:drift/drift.dart';

import '../../money.dart';
import '../app_database.dart';
import 'dues_repository.dart';
import 'repo_context.dart';
import 'settings_repository.dart';
import 'stock_repository.dart';

/// Start of the local calendar day containing [d].
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// One day's sales, net of what customers took back that day. Amounts are
/// paise; [byMode] splits what customers paid by payment mode (cash, upi, card,
/// credit) after refunds, so it adds up to [totalPaise].
class DailySales {
  const DailySales({
    required this.day,
    required this.billCount,
    required this.totalPaise,
    required this.discountPaise,
    required this.gstPaise,
    required this.byMode,
    this.grossPaise = 0,
    this.returnsPaise = 0,
    this.returnCount = 0,
    this.cancelCount = 0,
  });

  final DateTime day;

  /// Bills made that day, not counting ones that were cancelled.
  final int billCount;

  /// Net sales: [grossPaise] minus [returnsPaise].
  final int totalPaise;
  final int discountPaise;

  /// GST contained in the net total (informational; prices include GST).
  final int gstPaise;
  final Map<String, int> byMode;

  /// What the bills made that day came to, before any returns.
  final int grossPaise;

  /// Given back that day (returns and cancelled bills, whichever bill they were on).
  final int returnsPaise;

  /// Credit notes made that day for part of a bill.
  final int returnCount;

  /// Bills dated that day that were cancelled.
  final int cancelCount;

  int mode(String m) => byMode[m] ?? 0;
}

/// Cash for one day and the running cash in hand at the end of it.
class CashPosition {
  const CashPosition({
    required this.day,
    required this.cashSalesPaise,
    required this.cashReceiptsPaise,
    required this.cashPaidOutPaise,
    required this.openingPaise,
    this.cashRefundsPaise = 0,
  });

  final DateTime day;

  /// Cash taken on bills today.
  final int cashSalesPaise;

  /// Cash collected from customers against dues today.
  final int cashReceiptsPaise;

  /// Cash paid to suppliers today.
  final int cashPaidOutPaise;

  /// Cash handed back to customers for returns and cancelled bills today.
  final int cashRefundsPaise;

  /// Cash in hand at the start of the day.
  final int openingPaise;

  int get netPaise => cashSalesPaise + cashReceiptsPaise - cashPaidOutPaise - cashRefundsPaise;
  int get closingPaise => openingPaise + netPaise;
}

/// Profit for one item over a period. Only lines whose cost was known on the
/// bill's date count towards [costPaise] and [profitPaise]; the rest are shown
/// as [unknownCostSalesPaise] and never guessed.
class ItemProfitRow {
  const ItemProfitRow({
    required this.item,
    required this.qtyBase,
    required this.taxableSalesPaise,
    required this.costPaise,
    required this.unknownCostSalesPaise,
  });

  final Item item;

  /// Total quantity sold in base units (all lines).
  final int qtyBase;

  /// Sales ex-GST of lines with a known cost.
  final int taxableSalesPaise;
  final int costPaise;
  final int unknownCostSalesPaise;

  int get profitPaise => taxableSalesPaise - costPaise;
}

class ItemProfitReport {
  const ItemProfitReport(this.rows);

  /// Best profit first.
  final List<ItemProfitRow> rows;

  int get taxableSalesPaise => rows.fold(0, (a, r) => a + r.taxableSalesPaise);
  int get costPaise => rows.fold(0, (a, r) => a + r.costPaise);
  int get profitPaise => rows.fold(0, (a, r) => a + r.profitPaise);
  int get unknownCostSalesPaise => rows.fold(0, (a, r) => a + r.unknownCostSalesPaise);
}

class StockValueRow {
  const StockValueRow(this.item, this.balanceBase, this.costPaise);
  final Item item;
  final int balanceBase;

  /// Latest cost per pricing unit (ex-GST), or null when never set.
  final int? costPaise;

  int get valuePaise => costPaise == null
      ? 0
      : Money.divRoundHalfUp(balanceBase * costPaise!, item.priceUnitFactor);
}

class StockValueReport {
  const StockValueReport(this.rows);

  /// Items on hand (positive balance), biggest value first; unknown cost last.
  final List<StockValueRow> rows;

  int get totalPaise => rows.fold(0, (a, r) => a + r.valuePaise);
  List<StockValueRow> get unknownCost => [for (final r in rows) if (r.costPaise == null) r];
}

class LowStockEntry {
  const LowStockEntry(this.item, this.balanceBase);
  final Item item;
  final int balanceBase;
}

/// Everything the owner compares with the paper book at the end of a day.
class DayClose {
  const DayClose({
    required this.sales,
    required this.cash,
    required this.collectedByMode,
    required this.supplierPaidByMode,
    required this.purchaseCount,
    required this.purchaseTotalPaise,
  });

  /// Bills, returns and cancels, and how customers paid, all net of returns.
  final DailySales sales;
  final CashPosition cash;

  /// Money customers paid that day against what they owed (not on a bill): cash, upi, bank.
  final Map<String, int> collectedByMode;

  /// Money the shop paid suppliers that day: cash, upi, bank.
  final Map<String, int> supplierPaidByMode;

  /// Supplier bills entered that day, and what they came to.
  final int purchaseCount;
  final int purchaseTotalPaise;

  int get collectedPaise => collectedByMode.values.fold(0, (a, b) => a + b);
  int get supplierPaidPaise => supplierPaidByMode.values.fold(0, (a, b) => a + b);

  /// All money received that day: what customers paid on bills (cash, UPI) plus
  /// what they paid against old dues, less refunds.
  int get receivedPaise => sales.mode('cash') + sales.mode('upi') + sales.mode('card') + collectedPaise;

  /// A plain-text summary to send to your own phone or note down.
  String toSummary(String shopName, String Function(int paise) money, String dateText) {
    final s = sales;
    final lines = <String>[
      '$shopName - day check for $dateText',
      '',
      'Bills: ${s.billCount}${s.cancelCount > 0 ? ' (${s.cancelCount} cancelled)' : ''}',
      'Sales: ${money(s.grossPaise)}',
      if (s.returnsPaise > 0) 'Returns and cancels: -${money(s.returnsPaise)}',
      'Net sales: ${money(s.totalPaise)}',
      '  Cash: ${money(s.mode('cash'))}',
      '  UPI: ${money(s.mode('upi'))}',
      '  On credit (udhaar): ${money(s.mode('credit'))}',
      'Collected from customers: ${money(collectedPaise)}',
      '  Cash: ${money(collectedByMode['cash'] ?? 0)}, UPI: ${money(collectedByMode['upi'] ?? 0)}, Bank: ${money(collectedByMode['bank'] ?? 0)}',
      'Purchases entered: $purchaseCount, ${money(purchaseTotalPaise)}',
      'Paid to suppliers: ${money(supplierPaidPaise)}',
      '',
      'Cash in hand: start ${money(cash.openingPaise)}, now ${money(cash.closingPaise)}',
    ];
    return lines.join('\n');
  }
}

/// What the owner sees on the home screen.
class DashboardData {
  const DashboardData({
    required this.today,
    required this.cash,
    required this.lowStockCount,
    required this.negativeStockCount,
    required this.topDues,
    required this.totalDuePaise,
  });

  final DailySales today;
  final CashPosition cash;
  final int lowStockCount;
  final int negativeStockCount;
  final List<PartyDues> topDues;
  final int totalDuePaise;
}

/// Read-only numbers for the dashboard, reports and the daily summary. Money
/// logic is reused from the other repositories, so every screen agrees.
class ReportsRepository {
  ReportsRepository(this.ctx)
      : _dues = DuesRepository(ctx),
        _stock = StockRepository(ctx),
        _settings = SettingsRepository(ctx);

  final RepoContext ctx;
  final DuesRepository _dues;
  final StockRepository _stock;
  final SettingsRepository _settings;

  Future<DailySales> dailySales(DateTime day) async {
    final from = startOfDay(day);
    final to = DateTime(from.year, from.month, from.day + 1);
    final db = ctx.db;
    // Every bill dated that day, cancelled ones too: a cancel is a return made
    // on the day it happens, so the day it was sold on still shows the sale.
    final invoices = await (db.select(db.invoices)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.date.isBiggerOrEqualValue(from) &
              t.date.isSmallerThanValue(to)))
        .get();
    final ids = invoices.map((i) => i.id).toList();
    final byMode = <String, int>{};
    if (ids.isNotEmpty) {
      final payments = await (db.select(db.invoicePayments)
            ..where((t) => t.deletedAt.isNull() & t.invoiceId.isIn(ids)))
          .get();
      for (final p in payments) {
        byMode[p.mode] = (byMode[p.mode] ?? 0) + p.amountPaise;
      }
    }
    final returns = await (db.select(db.salesReturns)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.date.isBiggerOrEqualValue(from) &
              t.date.isSmallerThanValue(to)))
        .get();
    var refunded = 0, refundedTax = 0;
    for (final r in returns) {
      refunded += r.totalPaise;
      refundedTax += r.taxPaise;
      byMode['cash'] = (byMode['cash'] ?? 0) - r.refundCashPaise;
      byMode['upi'] = (byMode['upi'] ?? 0) - r.refundUpiPaise;
      byMode['credit'] = (byMode['credit'] ?? 0) - r.refundAccountPaise;
    }
    final gross = invoices.fold<int>(0, (a, i) => a + i.totalPaise);
    return DailySales(
      day: from,
      billCount: invoices.where((i) => i.status != 'cancelled').length,
      totalPaise: gross - refunded,
      discountPaise: invoices.fold(0, (a, i) => a + i.discountPaise),
      gstPaise: invoices.fold<int>(0, (a, i) => a + i.taxPaise) - refundedTax,
      byMode: byMode,
      grossPaise: gross,
      returnsPaise: refunded,
      returnCount: returns.where((r) => !r.isCancel).length,
      cancelCount: invoices.where((i) => i.status == 'cancelled').length,
    );
  }

  /// Cash movements on [day], and the cash in hand at its start (the opening
  /// cash from Settings plus the net cash of every earlier day).
  Future<CashPosition> cashPosition(DateTime day) async {
    final from = startOfDay(day);
    final to = DateTime(from.year, from.month, from.day + 1);
    // Customer payments are stored negative in the ledger (they reduce what the
    // customer owes); supplier payments positive. Cash in hand wants both as
    // positive amounts.
    final sales = await _cashSales(from: from, to: to);
    final receipts = -await _cashLedger('payment', from: from, to: to);
    final paidOut = await _cashLedger('supplier_payment', from: from, to: to);
    final refunds = await _cashRefunds(from: from, to: to);
    final beforeRefunds = await _cashRefunds(to: from);
    final beforeSales = await _cashSales(to: from);
    final beforeReceipts = -await _cashLedger('payment', to: from);
    final beforePaid = await _cashLedger('supplier_payment', to: from);
    final opening = await _settings.openingCashPaise() +
        beforeSales +
        beforeReceipts -
        beforePaid -
        beforeRefunds;
    return CashPosition(
      day: from,
      cashSalesPaise: sales,
      cashReceiptsPaise: receipts,
      cashPaidOutPaise: paidOut,
      openingPaise: opening,
      cashRefundsPaise: refunds,
    );
  }

  Future<int> _cashSales({DateTime? from, required DateTime to}) async {
    final db = ctx.db;
    final p = db.invoicePayments;
    final i = db.invoices;
    final sum = p.amountPaise.sum();
    final q = db.selectOnly(p).join([innerJoin(i, i.id.equalsExp(p.invoiceId))])
      ..addColumns([sum])
      ..where(p.deletedAt.isNull() &
          i.deletedAt.isNull() &
          p.mode.equals('cash') &
          i.date.isSmallerThanValue(to));
    if (from != null) q.where(i.date.isBiggerOrEqualValue(from));
    return (await q.getSingle()).read(sum) ?? 0;
  }

  /// Cash handed back to customers (returns and cancelled bills) by return date.
  Future<int> _cashRefunds({DateTime? from, required DateTime to}) async {
    final r = ctx.db.salesReturns;
    final sum = r.refundCashPaise.sum();
    final q = ctx.db.selectOnly(r)
      ..addColumns([sum])
      ..where(r.deletedAt.isNull() & r.date.isSmallerThanValue(to));
    if (from != null) q.where(r.date.isBiggerOrEqualValue(from));
    return (await q.getSingle()).read(sum) ?? 0;
  }

  Future<int> _cashLedger(String entryType, {DateTime? from, required DateTime to}) async {
    final l = ctx.db.ledgerEntries;
    final sum = l.amountPaise.sum();
    final q = ctx.db.selectOnly(l)
      ..addColumns([sum])
      ..where(l.deletedAt.isNull() &
          l.entryType.equals(entryType) &
          l.paymentMode.equals('cash') &
          l.ts.isSmallerThanValue(to));
    if (from != null) q.where(l.ts.isBiggerOrEqualValue(from));
    return (await q.getSingle()).read(sum) ?? 0;
  }

  /// Profit per item for bills dated from [from] up to and including the day of [to].
  Future<ItemProfitReport> itemProfit(DateTime from, DateTime to) async {
    final db = ctx.db;
    final start = startOfDay(from);
    final end = DateTime(to.year, to.month, to.day + 1);
    final rows = await (db.select(db.invoiceLines).join([
      innerJoin(db.invoices, db.invoices.id.equalsExp(db.invoiceLines.invoiceId)),
    ])
          ..where(db.invoiceLines.deletedAt.isNull() &
              db.invoices.deletedAt.isNull() &
              db.invoices.date.isBiggerOrEqualValue(start) &
              db.invoices.date.isSmallerThanValue(end)))
        .get();
    // What customers took back in the same period (by the day of the return),
    // with the bill line it came from, so the cost on the original bill date is used.
    final returned = await (db.select(db.salesReturnLines).join([
      innerJoin(db.salesReturns, db.salesReturns.id.equalsExp(db.salesReturnLines.returnId)),
      innerJoin(db.invoiceLines, db.invoiceLines.id.equalsExp(db.salesReturnLines.invoiceLineId)),
      innerJoin(db.invoices, db.invoices.id.equalsExp(db.invoiceLines.invoiceId)),
    ])
          ..where(db.salesReturnLines.deletedAt.isNull() &
              db.salesReturns.deletedAt.isNull() &
              db.salesReturns.date.isBiggerOrEqualValue(start) &
              db.salesReturns.date.isSmallerThanValue(end)))
        .get();
    if (rows.isEmpty && returned.isEmpty) return const ItemProfitReport([]);

    final itemIds = {
      for (final r in rows) r.readTable(db.invoiceLines).itemId,
      for (final r in returned) r.readTable(db.salesReturnLines).itemId,
    };
    final costRows = await (db.select(db.itemCosts)
          ..where((t) => t.deletedAt.isNull() & t.itemId.isIn(itemIds))
          ..orderBy([
            (t) => OrderingTerm.asc(t.effectiveFrom),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
        .get();
    final costs = <String, List<ItemCost>>{};
    for (final c in costRows) {
      (costs[c.itemId] ??= []).add(c);
    }
    final items = {
      for (final it in await (db.select(db.items)..where((t) => t.id.isIn(itemIds))).get())
        it.id: it
    };

    final acc = <String, _ProfitAcc>{};
    for (final r in rows) {
      final line = r.readTable(db.invoiceLines);
      final inv = r.readTable(db.invoices);
      final a = acc[line.itemId] ??= _ProfitAcc();
      a.qty += line.qtyBase;
      final taxable = line.lineTotalPaise - line.taxPaise;
      int? cost;
      for (final c in costs[line.itemId] ?? const <ItemCost>[]) {
        if (c.effectiveFrom.isAfter(inv.date)) break;
        cost = c.costPaise; // last one on or before the bill date wins
      }
      if (cost == null) {
        a.unknown += taxable;
      } else {
        a.taxable += taxable;
        a.cost += Money.divRoundHalfUp(line.qtyBase * cost, line.priceUnitFactor);
      }
    }
    // Take back what customers returned: less sales, less cost (at the cost in
    // force on the original bill's date), so profit only counts what was kept.
    for (final r in returned) {
      final line = r.readTable(db.salesReturnLines);
      final orig = r.readTable(db.invoiceLines);
      final inv = r.readTable(db.invoices);
      final a = acc[line.itemId] ??= _ProfitAcc();
      a.qty -= line.qtyBase;
      final taxable = line.lineTotalPaise - line.taxPaise;
      int? cost;
      for (final c in costs[line.itemId] ?? const <ItemCost>[]) {
        if (c.effectiveFrom.isAfter(inv.date)) break;
        cost = c.costPaise;
      }
      if (cost == null) {
        a.unknown -= taxable;
      } else {
        a.taxable -= taxable;
        a.cost -= Money.divRoundHalfUp(line.qtyBase * cost, orig.priceUnitFactor);
      }
    }
    final out = [
      for (final e in acc.entries)
        ItemProfitRow(
          item: items[e.key]!,
          qtyBase: e.value.qty,
          taxableSalesPaise: e.value.taxable,
          costPaise: e.value.cost,
          unknownCostSalesPaise: e.value.unknown,
        )
    ]..sort((a, b) => b.profitPaise.compareTo(a.profitPaise));
    return ItemProfitReport(out);
  }

  /// Stock on hand valued at the latest cost (ex-GST).
  Future<StockValueReport> stockValue() async {
    final db = ctx.db;
    final balances = await _stock.balancesByItem();
    final items = await (db.select(db.items)
          ..where((t) => t.deletedAt.isNull() & t.active.equals(true)))
        .get();
    final costRows = await (db.select(db.itemCosts)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.effectiveFrom),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
        .get();
    final latest = <String, int>{for (final c in costRows) c.itemId: c.costPaise};
    final rows = [
      for (final it in items)
        if ((balances[it.id] ?? 0) > 0)
          StockValueRow(it, balances[it.id]!, latest[it.id]),
    ]..sort((a, b) {
        if ((a.costPaise == null) != (b.costPaise == null)) {
          return a.costPaise == null ? 1 : -1;
        }
        return b.valuePaise.compareTo(a.valuePaise);
      });
    return StockValueReport(rows);
  }

  /// Items below their minimum (same rule as the Stock screen's Low filter),
  /// emptiest first.
  Future<List<LowStockEntry>> lowStock() async {
    final balances = await _stock.balancesByItem();
    final items = await (ctx.db.select(ctx.db.items)
          ..where((t) => t.deletedAt.isNull() & t.active.equals(true)))
        .get();
    return [
      for (final it in items)
        if (it.minStockBase > 0 &&
            (balances[it.id] ?? 0) >= 0 &&
            (balances[it.id] ?? 0) < it.minStockBase)
          LowStockEntry(it, balances[it.id] ?? 0),
    ]..sort((a, b) => a.balanceBase.compareTo(b.balanceBase));
  }

  Future<int> negativeStockCount() async {
    final balances = await _stock.balancesByItem();
    final active = {
      for (final it in await (ctx.db.select(ctx.db.items)
            ..where((t) => t.deletedAt.isNull() & t.active.equals(true)))
          .get())
        it.id
    };
    return balances.entries.where((e) => active.contains(e.key) && e.value < 0).length;
  }

  /// One screen of numbers for the evening, to compare with the paper book.
  Future<DayClose> dayClose(DateTime day) async {
    final from = startOfDay(day);
    final to = DateTime(from.year, from.month, from.day + 1);
    final db = ctx.db;

    Future<Map<String, int>> byMode(String entryType, {required bool negate}) async {
      final rows = await db.customSelect(
        'SELECT COALESCE(payment_mode, \'cash\') AS m, SUM(amount_paise) AS n FROM ledger_entries '
        'WHERE entry_type = ? AND deleted_at IS NULL AND ts >= ? AND ts < ? GROUP BY m',
        variables: [
          Variable.withString(entryType),
          Variable.withInt(from.millisecondsSinceEpoch ~/ 1000),
          Variable.withInt(to.millisecondsSinceEpoch ~/ 1000),
        ],
      ).get();
      return {
        for (final r in rows) r.data['m'] as String: (negate ? -1 : 1) * (r.data['n'] as num).toInt(),
      };
    }

    final purchases = await (db.select(db.purchases)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.status.equals('cancelled').not() &
              t.supplierInvoiceDate.isBiggerOrEqualValue(from) &
              t.supplierInvoiceDate.isSmallerThanValue(to)))
        .get();
    return DayClose(
      sales: await dailySales(day),
      cash: await cashPosition(day),
      collectedByMode: await byMode('payment', negate: true),
      supplierPaidByMode: await byMode('supplier_payment', negate: false),
      purchaseCount: purchases.length,
      purchaseTotalPaise: purchases.fold(0, (a, p) => a + p.totalPaise),
    );
  }

  Future<DashboardData> dashboard({DateTime? now, int topDues = 5}) async {
    final when = now ?? ctx.clock();
    final dues = await _dues.receivables(asOf: when);
    return DashboardData(
      today: await dailySales(when),
      cash: await cashPosition(when),
      lowStockCount: (await lowStock()).length,
      negativeStockCount: await negativeStockCount(),
      topDues: dues.take(topDues).toList(),
      totalDuePaise: DuesRepository.total(dues).totalDue,
    );
  }
}

class _ProfitAcc {
  int qty = 0;
  int taxable = 0;
  int cost = 0;
  int unknown = 0;
}
