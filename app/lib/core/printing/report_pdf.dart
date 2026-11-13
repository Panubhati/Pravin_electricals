import 'dart:typed_data';

import 'package:flutter/painting.dart' show TextAlign;

import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../db/repositories/dues_repository.dart';
import '../db/repositories/invoice_repository.dart';
import '../db/repositories/reports_repository.dart';
import '../money.dart';
import 'painted_pdf.dart';

/// Report PDFs (A13), in the phone's screen language. Each report is a list of
/// [DocBlock]s (so tests can read what it says) drawn by [buildPaintedPdf],
/// which writes Marathi correctly.
class ReportDoc {
  const ReportDoc({required this.title, required this.period, required this.body});
  final String title;

  /// The day or range the report covers ("13 Nov 2026").
  final String period;
  final List<DocBlock> body;

  /// Every text in the report, for tests and searching.
  Iterable<String> get texts sync* {
    yield title;
    yield period;
    for (final b in body) {
      switch (b) {
        case DocText(:final text):
          yield text;
        case DocKeyValue(:final label, :final value):
          yield label;
          yield value;
        case DocTable(:final header, :final rows):
          yield* header;
          for (final r in rows) {
            yield* r;
          }
        default:
          break;
      }
    }
  }
}

Future<Uint8List> buildReportPdf(ReportDoc r, {required String shopName, DateTime? madeAt}) {
  return buildPaintedPdf([
    DocText(shopName, size: 14, bold: true, align: TextAlign.center),
    DocText(r.title, size: 12, bold: true, align: TextAlign.center),
    DocText(r.period, align: TextAlign.center),
    DocText(S.reportMadeOn(formatDateTime(madeAt ?? DateTime.now())), size: 8, muted: true, align: TextAlign.center),
    const DocDivider(),
    ...r.body,
  ], footer: (page, pages) => S.reportPage(page, pages));
}

String _time(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
}

DocBlock _section(String title) => DocText(title, size: 11, bold: true);

DocKeyValue _kv(String label, int paise, {bool bold = false, String prefix = ''}) =>
    DocKeyValue(label, '$prefix${Money.format(paise)}', bold: bold, width: 300);

/// Daily sales: totals, how customers paid, cash in hand, and every bill.
ReportDoc dailySalesDoc(DailySales s, CashPosition? cash, List<InvoiceListEntry> bills) => ReportDoc(
      title: S.dailySales,
      period: formatDate(s.day),
      body: [
        DocKeyValue(S.billsCount, '${s.billCount}', width: 300),
        _kv(S.salesTotal, s.totalPaise, bold: true),
        if (s.discountPaise > 0) _kv(S.discountLabel, s.discountPaise),
        _kv(S.gstIncluded, s.gstPaise),
        if (s.returnsPaise > 0) _kv(S.dcReturns, s.returnsPaise, prefix: '- '),
        const DocSpace(6),
        _section(S.paidBy),
        _kv(S.cash, s.mode('cash')),
        _kv(S.modeUpi, s.mode('upi')),
        if (s.mode('card') != 0) _kv(S.modeCard, s.mode('card')),
        _kv(S.credit, s.mode('credit')),
        if (cash != null) ...[
          const DocSpace(6),
          _section(S.cashInHand),
          _kv(S.cashOpening, cash.openingPaise),
          _kv('+ ${S.cashSales}', cash.cashSalesPaise),
          _kv('+ ${S.cashReceived}', cash.cashReceiptsPaise),
          _kv('- ${S.cashPaidOut}', cash.cashPaidOutPaise),
          _kv(S.cashClosing, cash.closingPaise, bold: true),
        ],
        const DocSpace(8),
        _section(S.reportBills),
        if (bills.isEmpty)
          DocText(S.reportNothing, muted: true)
        else
          DocTable(
            flex: const [1.4, 1.1, 3, 1.6, 1.6],
            rightAligned: const [false, false, false, true, true],
            header: [S.reportBillNo, S.reportTime, S.reportCustomer, S.total, S.reportDue],
            rows: [
              for (final b in bills)
                [
                  b.invoice.invoiceNoText,
                  _time(b.invoice.date),
                  (b.partyName ?? S.walkIn) + (b.cancelled ? ' (${S.reportCancelled})' : ''),
                  Money.format(b.invoice.totalPaise),
                  b.duePaise > 0 && !b.cancelled ? Money.format(b.duePaise) : '',
                ],
            ],
          ),
      ],
    );

/// Who owes the shop money, with how old it is.
ReportDoc duesDoc(List<PartyDues> dues, DateTime day) {
  final owing = [
    for (final d in dues)
      if (d.buckets.totalDue > 0) d,
  ];
  final total = owing.fold<int>(0, (a, d) => a + d.buckets.totalDue);
  String m(int p) => p == 0 ? '' : Money.format(p);
  return ReportDoc(
    title: S.reportDuesTitle,
    period: formatDate(day),
    body: [
      _kv(S.totalDue, total, bold: true),
      DocKeyValue(S.customers, '${owing.length}', width: 300),
      const DocSpace(8),
      if (owing.isEmpty)
        DocText(S.noDues, muted: true)
      else
        DocTable(
          flex: const [3, 1.8, 1.7, 1.5, 1.5, 1.5, 1.5],
          rightAligned: const [false, false, true, true, true, true, true],
          header: [S.reportCustomer, S.phone, S.reportOwes, S.bucket0, S.bucket31, S.bucket61, S.bucket90],
          rows: [
            for (final d in owing)
              [
                d.party.name,
                d.party.phone ?? '',
                Money.format(d.buckets.totalDue),
                m(d.buckets.days0to30),
                m(d.buckets.days31to60),
                m(d.buckets.days61to90),
                m(d.buckets.over90),
              ],
          ],
        ),
    ],
  );
}

/// Stock on hand with its value at cost, then items below their minimum.
/// [showCost] is false for counter staff (cost is the owner's).
ReportDoc stockDoc(StockValueReport r, List<LowStockEntry> low, DateTime day, {bool showCost = true}) {
  final rows = [...r.rows]..sort((a, b) => a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase()));
  return ReportDoc(
    title: S.reportStockTitle,
    period: formatDate(day),
    body: [
      if (showCost) ...[
        _kv(S.stockValueTotal, r.totalPaise, bold: true),
        DocText(S.stockValueNote, size: 8, muted: true),
      ],
      const DocSpace(8),
      _section(S.reportStockOnHand),
      if (rows.isEmpty)
        DocText(S.noStockOnHand, muted: true)
      else
        DocTable(
          flex: showCost ? const [4, 1.8, 1.8, 1.8] : const [4, 2],
          rightAligned: showCost ? const [false, true, true, true] : const [false, true],
          header: [S.reportItem, S.stock, if (showCost) S.reportCostRate, if (showCost) S.reportValue],
          rows: [
            for (final x in rows)
              [
                x.item.name,
                formatStock(x.item, x.balanceBase),
                if (showCost) x.costPaise == null ? '-' : formatRate(x.item, x.costPaise!),
                if (showCost) x.costPaise == null ? S.reportCostNotKnown : Money.format(x.valuePaise),
              ],
          ],
        ),
      const DocSpace(10),
      _section(S.lowStockItems),
      if (low.isEmpty)
        DocText(S.reportNoLowStock, muted: true)
      else
        DocTable(
          flex: const [4, 2, 2],
          rightAligned: const [false, true, true],
          header: [S.reportItem, S.stock, S.reportMinimum],
          rows: [
            for (final l in low)
              [l.item.name, formatStock(l.item, l.balanceBase), formatStock(l.item, l.item.minStockBase)],
          ],
        ),
    ],
  );
}

/// Profit per item for a range (owner only).
ReportDoc itemProfitDoc(ItemProfitReport r, DateTime from, DateTime to) {
  final known = [
    for (final x in r.rows)
      if (x.taxableSalesPaise > 0 || x.costPaise > 0) x,
  ];
  final unknown = [
    for (final x in r.rows)
      if (x.unknownCostSalesPaise > 0) x,
  ];
  final margin = r.taxableSalesPaise == 0 ? 0.0 : r.profitPaise * 100 / r.taxableSalesPaise;
  return ReportDoc(
    title: S.itemProfit,
    period: S.dateRange(formatDate(from), formatDate(to)),
    body: [
      _kv(S.salesExGst, r.taxableSalesPaise),
      _kv(S.costOfGoods, r.costPaise),
      _kv(S.profit, r.profitPaise, bold: true),
      DocKeyValue(S.margin, '${margin.toStringAsFixed(1)}%', width: 300),
      const DocSpace(8),
      _section(S.byItem),
      if (known.isEmpty)
        DocText(S.noSalesInPeriod, muted: true)
      else
        DocTable(
          flex: const [4, 1.6, 1.8, 1.8, 1.8],
          rightAligned: const [false, true, true, true, true],
          header: [S.reportItem, S.reportSold, S.reportSales, S.reportCost, S.profit],
          rows: [
            for (final x in known)
              [
                x.item.name,
                formatStock(x.item, x.qtyBase),
                Money.format(x.taxableSalesPaise),
                Money.format(x.costPaise),
                Money.format(x.profitPaise),
              ],
          ],
        ),
      if (unknown.isNotEmpty) ...[
        const DocSpace(8),
        _section(S.costUnknown),
        DocText(S.costUnknownHelp, size: 8, muted: true),
        DocTable(
          flex: const [4, 2],
          rightAligned: const [false, true],
          header: [S.reportItem, S.reportSales],
          rows: [
            for (final x in unknown) [x.item.name, Money.format(x.unknownCostSalesPaise)],
          ],
        ),
      ],
      const DocSpace(6),
      DocText(S.returnsNote, size: 8, muted: true),
    ],
  );
}

/// The evening Day check, line for line as on the screen.
ReportDoc dayCheckDoc(DayClose d, DateTime day) {
  final s = d.sales;
  return ReportDoc(
    title: S.dayCheckTitle,
    period: formatDate(day),
    body: [
      _section(S.dcSales),
      DocKeyValue(S.billsCount, '${s.billCount}', width: 300),
      if (s.cancelCount > 0) DocKeyValue(S.dcCancelled, '${s.cancelCount}', width: 300),
      _kv(S.dcSalesGross, s.grossPaise),
      if (s.returnsPaise > 0) _kv(S.dcReturns, s.returnsPaise, prefix: '- '),
      _kv(S.dcNetSales, s.totalPaise, bold: true),
      const DocSpace(6),
      _section(S.dcHowPaid),
      _kv(S.cash, s.mode('cash')),
      _kv(S.modeUpi, s.mode('upi')),
      if (s.mode('card') != 0) _kv(S.modeCard, s.mode('card')),
      _kv(S.credit, s.mode('credit')),
      const DocSpace(6),
      _section(S.dcCollected),
      _kv(S.dcCollectedTotal, d.collectedPaise, bold: true),
      _kv(S.cash, d.collectedByMode['cash'] ?? 0),
      _kv(S.modeUpi, d.collectedByMode['upi'] ?? 0),
      _kv(S.modeBank, d.collectedByMode['bank'] ?? 0),
      const DocSpace(6),
      _section(S.dcPurchases),
      DocKeyValue(S.dcPurchasesEntered, '${d.purchaseCount}', width: 300),
      _kv(S.dcPurchasesTotal, d.purchaseTotalPaise),
      _kv(S.dcPaidSuppliers, d.supplierPaidPaise),
      const DocSpace(6),
      _section(S.cashInHand),
      _kv(S.cashOpening, d.cash.openingPaise),
      _kv('+ ${S.cashSales}', d.cash.cashSalesPaise),
      _kv('+ ${S.cashReceived}', d.cash.cashReceiptsPaise),
      _kv('- ${S.cashPaidOut}', d.cash.cashPaidOutPaise),
      if (d.cash.cashRefundsPaise > 0) _kv('- ${S.dcCashRefunds}', d.cash.cashRefundsPaise),
      _kv(S.cashClosing, d.cash.closingPaise, bold: true),
      const DocSpace(8),
      DocText(S.dcCompareHelp, size: 8, muted: true),
    ],
  );
}
