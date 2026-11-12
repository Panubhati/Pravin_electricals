import 'dart:typed_data';

import 'package:flutter/painting.dart' show TextAlign;

import '../db/repositories/invoice_repository.dart';
import '../db/repositories/return_repository.dart';
import 'bill_words.dart';
import 'credit_note_view.dart';
import 'invoice_view.dart';
import 'painted_pdf.dart';
import 'upi_link.dart';

/// The tax invoice in Marathi, laid out like the English PDF (A10). Drawn with
/// Flutter's text engine so Marathi letters join correctly.
Future<Uint8List> buildMarathiInvoicePdf(InvoiceDetails d, {UpiPayee? upi}) {
  const w = BillWords.mr;
  final v = InvoiceView.from(d, upi: upi, words: w);
  final flex = <double>[0.5, 4, if (v.showHsn) 1.4, 1.7, 1.4, if (v.showDiscount) 1.2, 1.7];
  final right = <bool>[false, false, if (v.showHsn) false, true, true, if (v.showDiscount) true, true];
  return buildPaintedPdf([
    DocText(v.shopName, size: 16, bold: true, align: TextAlign.center),
    if (v.shopAddress != null) DocText(v.shopAddress!, size: 8.5, align: TextAlign.center),
    if (v.shopContact.isNotEmpty) DocText(v.shopContact, size: 8.5, align: TextAlign.center),
    const DocSpace(6),
    DocText(w.taxInvoice, bold: true, align: TextAlign.center),
    const DocDivider(),
    DocColumns([
      DocText(w.billTo, size: 8.5, muted: true),
      DocText(v.billToName, bold: true),
      for (final l in v.billToLines) DocText(l),
      if (v.placeOfSupply != null) DocText(v.placeOfSupply!, size: 8.5),
    ], [
      DocText(w.invoiceNo(v.invoiceNo), bold: true),
      DocText(w.date(v.dateText)),
    ]),
    const DocSpace(8),
    DocTable(
      flex: flex,
      rightAligned: right,
      header: [
        '#',
        w.item,
        if (v.showHsn) w.hsn,
        w.qty,
        w.rate,
        if (v.showDiscount) w.disc,
        w.amount,
      ],
      rows: [
        for (final l in v.lines)
          [l.no, l.name, if (v.showHsn) l.hsn, l.qty, l.rate, if (v.showDiscount) l.discount, l.amount],
      ],
    ),
    const DocSpace(8),
    DocKeyValue(w.subtotal, v.subtotal),
    if (v.discount != null) DocKeyValue(w.discount, v.discount!),
    if (v.roundOff != null) DocKeyValue(w.roundOff, v.roundOff!),
    DocKeyValue(w.total, v.total, size: 12, bold: true),
    const DocSpace(4),
    DocText(v.words, bold: true),
    const DocSpace(10),
    DocText(w.gstIncludedInTotal, bold: true),
    const DocSpace(3),
    DocTable(
      flex: v.interState ? const [1, 2, 2] : const [1, 2, 1.5, 1.5],
      rightAligned: v.interState ? const [false, true, true] : const [false, true, true, true],
      header: [w.gstRate, w.taxableValue, if (v.interState) 'IGST' else ...['CGST', 'SGST']],
      rows: [
        for (final r in v.gstRows) [r.rate, r.taxable, if (v.interState) r.igst else ...[r.cgst, r.sgst]],
      ],
    ),
    const DocSpace(10),
    DocWithQr([
      DocText(w.payment, bold: true),
      for (final p in v.payments) DocText(p),
      if (v.dueText != null) DocText(v.dueText!, bold: true),
      if (v.terms != null) ...[const DocText(''), DocText(v.terms!, size: 8.5)],
    ], qrData: v.upiLink, caption: v.upiCaption),
    const DocSpace(18),
    DocText(w.forShop(v.shopName), bold: true, align: TextAlign.right),
    const DocSpace(26),
    DocText(w.signatory, size: 8.5, align: TextAlign.right),
    const DocSpace(10),
    DocText(w.thankYou, size: 8.5, align: TextAlign.center),
    DocText(w.computerInvoice, size: 8.5, align: TextAlign.center),
  ], footer: w.page);
}

/// The credit note in Marathi, laid out like the English one.
Future<Uint8List> buildMarathiCreditNotePdf(ReturnDetails d) {
  const w = BillWords.mr;
  final v = CreditNoteView.from(d, words: w);
  return buildPaintedPdf([
    DocText(v.shopName, size: 16, bold: true, align: TextAlign.center),
    if (v.shopAddress != null) DocText(v.shopAddress!, size: 8.5, align: TextAlign.center),
    if (v.shopContact.isNotEmpty) DocText(v.shopContact, size: 8.5, align: TextAlign.center),
    const DocSpace(6),
    DocText(v.title, bold: true, align: TextAlign.center),
    const DocDivider(),
    DocColumns([
      DocText(w.customer, size: 8.5, muted: true),
      DocText(v.customerName, bold: true),
      for (final l in v.customerLines) DocText(l),
    ], [
      DocText(w.creditNoteNo(v.noteNo), bold: true),
      DocText(w.date(v.dateText)),
      DocText(w.againstBill(v.againstBill, v.billDateText)),
    ]),
    const DocSpace(8),
    DocTable(
      flex: const [4, 1.7, 1.7],
      rightAligned: const [false, true, true],
      header: [w.itemReturned, w.qty, w.amount],
      rows: [for (final l in v.lines) [l.name, l.qty, l.amount]],
    ),
    const DocSpace(8),
    if (v.roundOff != null) DocKeyValue(w.roundOff, v.roundOff!),
    DocKeyValue(w.totalRefunded, v.total, size: 12, bold: true),
    DocKeyValue(w.gstIncluded, v.gstInside, size: 8.5),
    const DocSpace(4),
    DocText(v.words, bold: true),
    const DocSpace(10),
    DocText(w.refund, bold: true),
    for (final r in v.refunds) DocText(r),
    if (v.reason != null) DocText(w.reason(v.reason!), size: 8.5),
    const DocSpace(18),
    DocText(w.forShop(v.shopName), bold: true, align: TextAlign.right),
    const DocSpace(26),
    DocText(w.signatory, size: 8.5, align: TextAlign.right),
    const DocSpace(10),
    DocText(w.computerCreditNote, size: 8.5, align: TextAlign.center),
  ], footer: w.page);
}
