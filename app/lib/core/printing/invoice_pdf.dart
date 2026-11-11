import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../db/repositories/invoice_repository.dart';
import 'invoice_view.dart';
import 'upi_link.dart';

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
/// regenerated whenever it is shared (plan section 2, rule 2). When [upi] is
/// given, a UPI QR code is drawn for the amount still due (or the total).
Future<Uint8List> buildInvoicePdf(
  InvoiceDetails d,
  InvoiceFonts fonts, {
  UpiPayee? upi,
  bool compress = true,
}) async {
  final v = InvoiceView.from(d, upi: upi);

  final base = pw.TextStyle(font: fonts.regular, fontSize: 10);
  final bold = pw.TextStyle(font: fonts.bold, fontSize: 10);
  final small = pw.TextStyle(font: fonts.regular, fontSize: 8.5);

  pw.Widget cell(String text,
          {pw.TextStyle? style, pw.Alignment align = pw.Alignment.centerLeft}) =>
      pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(text, style: style ?? base),
      );
  const right = pw.Alignment.centerRight;

  // Column positions depend on which optional columns the bill needs.
  final cols = <int, pw.TableColumnWidth>{};
  var c = 0;
  cols[c++] = const pw.FixedColumnWidth(22); // #
  cols[c++] = const pw.FlexColumnWidth(4); // item
  if (v.showHsn) cols[c++] = const pw.FlexColumnWidth(1.4);
  cols[c++] = const pw.FlexColumnWidth(1.7); // qty
  cols[c++] = const pw.FlexColumnWidth(1.4); // rate
  if (v.showDiscount) cols[c++] = const pw.FlexColumnWidth(1.2);
  cols[c++] = const pw.FlexColumnWidth(1.7); // amount

  final doc = pw.Document(compress: compress);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 36),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: small),
      ),
      build: (ctx) => [
        pw.Center(
          child: pw.Text(v.shopName, style: pw.TextStyle(font: fonts.bold, fontSize: 16)),
        ),
        if (v.shopAddress != null) pw.Center(child: pw.Text(v.shopAddress!, style: small)),
        if (v.shopContact.isNotEmpty) pw.Center(child: pw.Text(v.shopContact, style: small)),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text('TAX INVOICE', style: bold)),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill to', style: small),
                  pw.Text(v.billToName, style: bold),
                  for (final l in v.billToLines) pw.Text(l, style: base),
                  if (v.placeOfSupply != null) pw.Text(v.placeOfSupply!, style: small),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Invoice no: ${v.invoiceNo}', style: bold),
                pw.Text('Date: ${v.dateText}', style: base),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          columnWidths: cols,
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('#', style: bold),
                cell('Item', style: bold),
                if (v.showHsn) cell('HSN', style: bold),
                cell('Qty', style: bold, align: right),
                cell('Rate', style: bold, align: right),
                if (v.showDiscount) cell('Disc.', style: bold, align: right),
                cell('Amount', style: bold, align: right),
              ],
            ),
            for (final l in v.lines)
              pw.TableRow(children: [
                cell(l.no),
                cell(l.name),
                if (v.showHsn) cell(l.hsn),
                cell(l.qty, align: right),
                cell(l.rate, align: right),
                if (v.showDiscount) cell(l.discount, align: right),
                cell(l.amount, align: right),
              ]),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(children: [
              _kv('Subtotal', v.subtotal, base),
              if (v.discount != null) _kv('Discount', v.discount!, base),
              if (v.roundOff != null) _kv('Round off', v.roundOff!, base),
              pw.Divider(height: 6),
              _kv('Total', v.total, pw.TextStyle(font: fonts.bold, fontSize: 12)),
            ]),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(v.words, style: bold),
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
                if (v.interState)
                  cell('IGST', style: bold, align: right)
                else ...[
                  cell('CGST', style: bold, align: right),
                  cell('SGST', style: bold, align: right),
                ],
              ],
            ),
            for (final r in v.gstRows)
              pw.TableRow(children: [
                cell(r.rate),
                cell(r.taxable, align: right),
                if (v.interState)
                  cell(r.igst, align: right)
                else ...[
                  cell(r.cgst, align: right),
                  cell(r.sgst, align: right),
                ],
              ]),
          ],
        ),
        pw.SizedBox(height: 10),
        // Keep the payment block and the QR together on one page.
        pw.Wrap(children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Payment', style: bold),
                    for (final p in v.payments) pw.Text(p, style: base),
                    if (v.dueText != null) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(v.dueText!, style: bold),
                    ],
                    if (v.terms != null) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(v.terms!, style: small),
                    ],
                  ],
                ),
              ),
              if (v.upiLink != null)
                pw.Container(
                  width: 120,
                  child: pw.Column(children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: v.upiLink!,
                      width: 90,
                      height: 90,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(v.upiCaption ?? '', style: small, textAlign: pw.TextAlign.center),
                  ]),
                ),
            ],
          ),
        ]),
        pw.SizedBox(height: 18),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('For ${v.shopName}', style: bold),
            pw.SizedBox(height: 26),
            pw.Text('Authorised signatory', style: small),
          ]),
        ),
        pw.SizedBox(height: 10),
        pw.Center(child: pw.Text('Thank you. Visit again.', style: small)),
        pw.Center(child: pw.Text('This is a computer generated invoice.', style: small)),
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
