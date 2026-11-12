import 'dart:convert';

import 'package:intl/intl.dart';

import '../../features/billing/domain/bill_calculator.dart';
import '../db/repositories/invoice_repository.dart';
import '../money.dart';
import 'bill_words.dart';
import 'upi_link.dart';

/// Everything printed on a tax invoice, as plain text, worked out from saved
/// data. The PDF only draws this; keeping the content here makes it easy to test
/// (the PDF's own text is stored as glyph codes and cannot be read back).
class InvoiceView {
  const InvoiceView({
    required this.shopName,
    required this.shopAddress,
    required this.shopContact,
    required this.billToName,
    required this.billToLines,
    required this.invoiceNo,
    required this.dateText,
    required this.lines,
    required this.showHsn,
    required this.showDiscount,
    required this.subtotal,
    required this.discount,
    required this.roundOff,
    required this.total,
    required this.interState,
    required this.gstRows,
    required this.payments,
    required this.dueText,
    required this.words,
    required this.terms,
    required this.upiLink,
    required this.upiCaption,
    this.placeOfSupply,
  });

  final String shopName;
  final String? shopAddress;

  /// "Phone: ...   GSTIN: ..." or empty.
  final String shopContact;
  final String billToName;
  final List<String> billToLines;
  final String? placeOfSupply;
  final String invoiceNo;
  final String dateText;
  final List<InvoiceViewLine> lines;
  final bool showHsn;
  final bool showDiscount;
  final String subtotal;
  final String? discount;
  final String? roundOff;
  final String total;
  final bool interState;
  final List<GstRowView> gstRows;
  final List<String> payments;

  /// "Balance due: ₹x" when part of the bill is on credit, otherwise null.
  final String? dueText;
  final String words;
  final String? terms;

  /// The `upi://pay` link to draw as a QR, or null when no UPI ID is set.
  final String? upiLink;
  final String? upiCaption;

  static InvoiceView from(InvoiceDetails d, {UpiPayee? upi, BillWords words = BillWords.en}) {
    final w = words;
    final inv = d.invoice;
    final shop = _snapshot(inv.shopSnapshotJson);
    final party = d.party;
    final interState = BillCalculator.isInterState(shop['stateCode'] as String?, party?.stateCode);
    String money(int p) => Money.format(p, symbol: false);

    final breakdown = BillCalculator.taxBreakdown(
      [
        for (final l in d.lines)
          (rateBp: l.gstRateBp, grossPaise: l.lineTotalPaise, taxPaise: l.taxPaise),
      ],
      interState: interState,
    );

    final lines = [
      for (var i = 0; i < d.lines.length; i++)
        InvoiceViewLine(
          no: '${i + 1}',
          name: d.itemNames[d.lines[i].itemId] ?? '',
          // The HSN the item had when it was sold; older bills fall back to today's.
          hsn: d.lines[i].hsn ?? d.itemHsn[d.lines[i].itemId] ?? '',
          qty: '${d.lines[i].qtyEntered} ${d.lines[i].unitName}',
          rate: money(d.lines[i].ratePaise),
          discount: d.lines[i].discountPaise > 0 ? money(d.lines[i].discountPaise) : '',
          amount: money(d.lines[i].lineTotalPaise),
        ),
    ];

    String? clean(Object? v) {
      final s = (v as String?)?.trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final due = inv.totalPaise - inv.paidPaise;
    final payTo = due > 0 ? due : inv.totalPaise;
    final link = UpiLink.build(upi, amountPaise: payTo, note: w.upiNote(inv.invoiceNoText));

    return InvoiceView(
      shopName: (shop['name'] as String?) ?? '',
      shopAddress: clean(shop['address']),
      shopContact: [
        if (clean(shop['phone']) != null) w.phone(clean(shop['phone'])!),
        if (clean(shop['gstin']) != null) w.gstin(clean(shop['gstin'])!),
      ].join('   '),
      billToName: party?.name ?? w.walkIn,
      billToLines: [
        if (clean(party?.phone) != null) clean(party?.phone)!,
        if (clean(party?.address) != null) clean(party?.address)!,
        if (clean(party?.gstin) != null) w.gstin(clean(party?.gstin)!),
      ],
      placeOfSupply: clean(party?.stateCode) == null ? null : w.placeOfSupply(clean(party?.stateCode)!),
      invoiceNo: inv.invoiceNoText,
      dateText: DateFormat('dd-MM-yyyy').format(inv.date),
      lines: lines,
      showHsn: lines.any((l) => l.hsn.isNotEmpty),
      showDiscount: lines.any((l) => l.discount.isNotEmpty),
      subtotal: money(inv.subtotalPaise),
      discount: inv.discountPaise > 0 ? '- ${money(inv.discountPaise)}' : null,
      roundOff: inv.roundOffPaise == 0
          ? null
          : '${inv.roundOffPaise < 0 ? '-' : '+'} ${money(inv.roundOffPaise.abs())}',
      total: Money.format(inv.totalPaise),
      interState: interState,
      gstRows: [
        for (final r in breakdown)
          GstRowView(
            rate: '${(r.rateBp / 100).toStringAsFixed(r.rateBp % 100 == 0 ? 0 : 1)}%',
            taxable: money(r.taxableValuePaise),
            cgst: money(r.cgstPaise),
            sgst: money(r.sgstPaise),
            igst: money(r.igstPaise),
          ),
      ],
      payments: [
        for (final p in d.payments)
          '${w.modeLabel(p.mode)}: ${Money.format(p.amountPaise)}${p.mode == 'credit' ? w.dueSuffix : ''}',
      ],
      dueText: due > 0 ? w.balanceDue(Money.format(due)) : null,
      words: w.words(inv.totalPaise),
      terms: clean(shop['terms']),
      upiLink: link,
      upiCaption: link == null
          ? null
          : (due > 0
              ? w.scanToPayBalance(Money.format(due))
              : w.payByUpi(Money.format(inv.totalPaise))),
    );
  }
}

class InvoiceViewLine {
  const InvoiceViewLine({
    required this.no,
    required this.name,
    required this.hsn,
    required this.qty,
    required this.rate,
    required this.discount,
    required this.amount,
  });
  final String no, name, hsn, qty, rate, discount, amount;
}

class GstRowView {
  const GstRowView({
    required this.rate,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });
  final String rate, taxable, cgst, sgst, igst;
}

Map<String, Object?> _snapshot(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    return (jsonDecode(json) as Map).cast<String, Object?>();
  } on FormatException {
    return const {};
  }
}
