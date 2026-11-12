import 'dart:convert';

import 'package:intl/intl.dart';

import '../db/repositories/return_repository.dart';
import '../money.dart';
import 'amount_in_words.dart';

/// Everything printed on a credit note, as plain text, from saved data. The PDF
/// only draws it (and tests read it).
class CreditNoteView {
  const CreditNoteView({
    required this.shopName,
    required this.shopAddress,
    required this.shopContact,
    required this.noteNo,
    required this.dateText,
    required this.againstBill,
    required this.billDateText,
    required this.customerName,
    required this.customerLines,
    required this.lines,
    required this.roundOff,
    required this.total,
    required this.gstInside,
    required this.refunds,
    required this.words,
    required this.reason,
    required this.isCancel,
  });

  final String shopName;
  final String? shopAddress;
  final String shopContact;
  final String noteNo;
  final String dateText;
  final String againstBill;
  final String billDateText;
  final String customerName;
  final List<String> customerLines;
  final List<CreditNoteLineView> lines;

  /// "+ 0.25" when part of the bill's round-off is given back, else null.
  final String? roundOff;
  final String total;
  final String gstInside;

  /// "Cash: ₹50.00", "UPI: ...", "Taken off your account: ..."
  final List<String> refunds;
  final String words;
  final String? reason;
  final bool isCancel;

  String get title => isCancel ? 'CREDIT NOTE (BILL CANCELLED)' : 'CREDIT NOTE';

  static CreditNoteView from(ReturnDetails d) {
    final shop = _snapshot(d.invoice.shopSnapshotJson);
    String? clean(Object? v) {
      final s = (v as String?)?.trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    String money(int p) => Money.format(p, symbol: false);
    final r = d.ret;
    final party = d.party;
    return CreditNoteView(
      shopName: (shop['name'] as String?) ?? '',
      shopAddress: clean(shop['address']),
      shopContact: [
        if (clean(shop['phone']) != null) 'Phone: ${clean(shop['phone'])}',
        if (clean(shop['gstin']) != null) 'GSTIN: ${clean(shop['gstin'])}',
      ].join('   '),
      noteNo: r.creditNoteNoText,
      dateText: DateFormat('dd-MM-yyyy').format(r.date),
      againstBill: d.invoice.invoiceNoText,
      billDateText: DateFormat('dd-MM-yyyy').format(d.invoice.date),
      customerName: party?.name ?? 'Walk-in customer',
      customerLines: [
        if (clean(party?.phone) != null) clean(party?.phone)!,
        if (clean(party?.gstin) != null) 'GSTIN: ${clean(party?.gstin)}',
      ],
      lines: [
        for (final l in d.lines)
          CreditNoteLineView(
            name: d.itemNames[l.itemId] ?? '',
            qty: '${l.qtyEntered} ${l.unitName}',
            amount: money(l.lineTotalPaise),
          ),
      ],
      roundOff: r.roundOffPaise == 0
          ? null
          : '${r.roundOffPaise < 0 ? '-' : '+'} ${money(r.roundOffPaise.abs())}',
      total: Money.format(r.totalPaise),
      gstInside: money(r.taxPaise),
      refunds: [
        if (r.refundCashPaise > 0) 'Cash: ${Money.format(r.refundCashPaise)}',
        if (r.refundUpiPaise > 0) 'UPI: ${Money.format(r.refundUpiPaise)}',
        if (r.refundAccountPaise > 0) 'Taken off your account: ${Money.format(r.refundAccountPaise)}',
      ],
      words: amountInWords(r.totalPaise),
      reason: clean(r.note),
      isCancel: r.isCancel,
    );
  }
}

class CreditNoteLineView {
  const CreditNoteLineView({required this.name, required this.qty, required this.amount});
  final String name, qty, amount;
}

Map<String, Object?> _snapshot(String? json) {
  if (json == null || json.isEmpty) return const {};
  try {
    return (jsonDecode(json) as Map).cast<String, Object?>();
  } on FormatException {
    return const {};
  }
}
