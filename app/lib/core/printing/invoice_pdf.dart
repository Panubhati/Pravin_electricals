import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/billing/domain/bill_calculator.dart';
import '../db/repositories/invoice_repository.dart';
import '../money.dart';

/// Fonts that include the rupee sign (bundled, so this works offline).
class InvoiceFonts {
  const InvoiceFonts(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;

  static Future<InvoiceFonts> load() async => InvoiceFonts(
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')),
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf')),
      );
}

/// Builds the invoice PDF from saved data. The PDF is never stored: it is
/// regenerated whenever it is shared or printed (plan section 2, rule 2).
Future<Uint8List> buildInvoicePdf(
  InvoiceDetails d,
  InvoiceFonts fonts, {
  bool compress = true,
}) async {
  final inv = d.invoice;
  final shop = _snapshot(inv.shopSnapshotJson);
  final interState = BillCalculator.isInterState(
      shop['stateCode'] as String?, d.party?.stateCode);

  final breakdown = BillCalculator.taxBreakdown(
    [
      for (final l in d.lines)
        (rateBp: l.gstRateBp, grossPaise: l.lineTotalPaise, taxPaise: l.taxPaise),
    ],
    interState: interState,
  );

  final base = pw.TextStyle(font: fonts.regular, fontSize: 10);
  final bold = pw.TextStyle(font: fonts.bold, fontSize: 10);
  final small = pw.TextStyle(font: fonts.regular, fontSize: 8.5);

  String money(int p) => Money.format(p, symbol: false);
  final date = DateFormat('dd-MM-yyyy').format(inv.date);
  final anyDiscount = d.lines.any((l) => l.discountPaise > 0);

  pw.Widget cell(String text,
          {pw.TextStyle? style, pw.Alignment align = pw.Alignment.centerLeft}) =>
      pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(text, style: style ?? base),
      );
  const right = pw.Alignment.centerRight;

  final doc = pw.Document(compress: compress);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      build: (ctx) => [
        pw.Center(
          child: pw.Text(
            (shop['name'] as String?) ?? '',
            style: pw.TextStyle(font: fonts.bold, fontSize: 16),
          ),
        ),
        if ((shop['address'] as String?)?.isNotEmpty ?? false)
          pw.Center(child: pw.Text(shop['address'] as String, style: small)),
        pw.Center(
          child: pw.Text(
            [
              if ((shop['phone'] as String?)?.isNotEmpty ?? false)
                'Phone: ${shop['phone']}',
              if ((shop['gstin'] as String?)?.isNotEmpty ?? false)
                'GSTIN: ${shop['gstin']}',
            ].join('   '),
            style: small,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text('TAX INVOICE', style: bold)),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill to', style: small),
                pw.Text(d.party?.name ?? 'Walk-in customer', style: bold),
                if (d.party?.phone != null) pw.Text(d.party!.phone!, style: base),
                if (d.party?.gstin != null)
                  pw.Text('GSTIN: ${d.party!.gstin}', style: base),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Invoice no: ${inv.invoiceNoText}', style: bold),
                pw.Text('Date: $date', style: base),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(24),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(1.6),
            3: const pw.FlexColumnWidth(1.4),
            if (anyDiscount) 4: const pw.FlexColumnWidth(1.2),
            (anyDiscount ? 5 : 4): const pw.FlexColumnWidth(1.6),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('#', style: bold),
                cell('Item', style: bold),
                cell('Qty', style: bold, align: right),
                cell('Rate', style: bold, align: right),
                if (anyDiscount) cell('Disc.', style: bold, align: right),
                cell('Amount', style: bold, align: right),
              ],
            ),
            for (var i = 0; i < d.lines.length; i++)
              pw.TableRow(children: [
                cell('${i + 1}'),
                cell(d.itemNames[d.lines[i].itemId] ?? ''),
                cell('${d.lines[i].qtyEntered} ${d.lines[i].unitName}', align: right),
                cell(money(d.lines[i].ratePaise), align: right),
                if (anyDiscount)
                  cell(
                    d.lines[i].discountPaise > 0 ? money(d.lines[i].discountPaise) : '',
                    align: right,
                  ),
                cell(money(d.lines[i].lineTotalPaise), align: right),
              ]),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(children: [
              _kv('Subtotal', money(inv.subtotalPaise), base),
              if (inv.discountPaise > 0)
                _kv('Discount', '- ${money(inv.discountPaise)}', base),
              if (inv.roundOffPaise != 0)
                _kv(
                  'Round off',
                  '${inv.roundOffPaise < 0 ? '-' : '+'} ${money(inv.roundOffPaise.abs())}',
                  base,
                ),
              pw.Divider(height: 6),
              _kv('Total', Money.format(inv.totalPaise), pw.TextStyle(font: fonts.bold, fontSize: 12)),
            ]),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('GST included in the total', style: bold),
        pw.SizedBox(height: 3),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('Rate', style: bold),
                cell('Taxable value', style: bold, align: right),
                if (interState)
                  cell('IGST', style: bold, align: right)
                else ...[
                  cell('CGST', style: bold, align: right),
                  cell('SGST', style: bold, align: right),
                ],
              ],
            ),
            for (final r in breakdown)
              pw.TableRow(children: [
                cell('${(r.rateBp / 100).toStringAsFixed(r.rateBp % 100 == 0 ? 0 : 1)}%'),
                cell(money(r.taxableValuePaise), align: right),
                if (interState)
                  cell(money(r.igstPaise), align: right)
                else ...[
                  cell(money(r.cgstPaise), align: right),
                  cell(money(r.sgstPaise), align: right),
                ],
              ]),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Payment', style: bold),
        for (final p in d.payments)
          pw.Text(
            '${_modeLabel(p.mode)}: ${Money.format(p.amountPaise)}'
            '${p.mode == 'credit' ? '  (due)' : ''}',
            style: base,
          ),
        if ((shop['terms'] as String?)?.isNotEmpty ?? false) ...[
          pw.SizedBox(height: 10),
          pw.Text(shop['terms'] as String, style: small),
        ],
        pw.SizedBox(height: 14),
        pw.Center(child: pw.Text('Thank you. Visit again.', style: small)),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _kv(String k, String v, pw.TextStyle style) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(k, style: style), pw.Text(v, style: style)],
      ),
    );

String _modeLabel(String mode) => switch (mode) {
      'cash' => 'Cash',
      'upi' => 'UPI',
      'credit' => 'Credit',
      'card' => 'Card',
      _ => mode,
    };

Map<String, Object?> _snapshot(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    return (jsonDecode(json) as Map).cast<String, Object?>();
  } on FormatException {
    return const {};
  }
}
