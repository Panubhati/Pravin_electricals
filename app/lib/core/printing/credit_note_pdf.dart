import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../db/repositories/return_repository.dart';
import 'credit_note_view.dart';
import 'invoice_pdf.dart';

/// Builds the credit note PDF from saved data (never stored; rebuilt when shared).
Future<Uint8List> buildCreditNotePdf(
  ReturnDetails d,
  InvoiceFonts fonts, {
  bool compress = true,
}) async {
  final v = CreditNoteView.from(d);
  final base = pw.TextStyle(font: fonts.regular, fontSize: 10);
  final bold = pw.TextStyle(font: fonts.bold, fontSize: 10);
  final small = pw.TextStyle(font: fonts.regular, fontSize: 8.5);

  pw.Widget cell(String text, {pw.TextStyle? style, pw.Alignment align = pw.Alignment.centerLeft}) =>
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
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 36),
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: small),
      ),
      build: (ctx) => [
        pw.Center(child: pw.Text(v.shopName, style: pw.TextStyle(font: fonts.bold, fontSize: 16))),
        if (v.shopAddress != null) pw.Center(child: pw.Text(v.shopAddress!, style: small)),
        if (v.shopContact.isNotEmpty) pw.Center(child: pw.Text(v.shopContact, style: small)),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text(v.title, style: bold)),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Customer', style: small),
                  pw.Text(v.customerName, style: bold),
                  for (final l in v.customerLines) pw.Text(l, style: base),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Credit note no: ${v.noteNo}', style: bold),
                pw.Text('Date: ${v.dateText}', style: base),
                pw.Text('Against bill ${v.againstBill} of ${v.billDateText}', style: base),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
          columnWidths: const {
            0: pw.FixedColumnWidth(22),
            1: pw.FlexColumnWidth(4),
            2: pw.FlexColumnWidth(1.7),
            3: pw.FlexColumnWidth(1.7),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('#', style: bold),
                cell('Item returned', style: bold),
                cell('Qty', style: bold, align: right),
                cell('Amount', style: bold, align: right),
              ],
            ),
            for (var i = 0; i < v.lines.length; i++)
              pw.TableRow(children: [
                cell('${i + 1}'),
                cell(v.lines[i].name),
                cell(v.lines[i].qty, align: right),
                cell(v.lines[i].amount, align: right),
              ]),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 220,
            child: pw.Column(children: [
              if (v.roundOff != null) _kv('Round off', v.roundOff!, base),
              pw.Divider(height: 6),
              _kv('Total refunded', v.total, pw.TextStyle(font: fonts.bold, fontSize: 12)),
              _kv('GST included', v.gstInside, small),
            ]),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(v.words, style: bold),
        pw.SizedBox(height: 10),
        pw.Text('Refund', style: bold),
        for (final r in v.refunds) pw.Text(r, style: base),
        if (v.reason != null) ...[
          pw.SizedBox(height: 6),
          pw.Text('Reason: ${v.reason}', style: small),
        ],
        pw.SizedBox(height: 22),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('For ${v.shopName}', style: bold),
            pw.SizedBox(height: 26),
            pw.Text('Authorised signatory', style: small),
          ]),
        ),
        pw.SizedBox(height: 10),
        pw.Center(child: pw.Text('This is a computer generated credit note.', style: small)),
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
