import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/printing/credit_note_pdf.dart';
import '../../core/printing/invoice_pdf.dart';
import '../../core/providers.dart';
import '../../core/sharing/phone_number.dart';
import '../../shared/strings.dart';

/// How a bill ended up being shared.
enum ShareOutcome {
  /// WhatsApp opened on the customer's chat.
  whatsapp,

  /// The normal share sheet opened (what was asked, or the fallback below).
  sheet,

  /// WhatsApp was asked for but the customer has no usable phone number.
  sheetNoPhone,

  /// WhatsApp was asked for but is not installed.
  sheetNoWhatsApp,
}

/// Plain message for an outcome that needs one, or null when all went as asked.
String? shareOutcomeMessage(ShareOutcome o) => switch (o) {
      ShareOutcome.sheetNoPhone => S.sharedNoPhone,
      ShareOutcome.sheetNoWhatsApp => S.sharedNoWhatsApp,
      _ => null,
    };

/// Builds the bill's PDF from saved data and shares it. With [whatsapp] it goes
/// straight to the customer's WhatsApp chat; if that is not possible it falls
/// back to the share sheet so the bill is never stuck.
Future<ShareOutcome> shareBill(
  WidgetRef ref,
  String invoiceId, {
  bool whatsapp = false,
}) async {
  final d = await ref.read(invoiceRepositoryProvider).details(invoiceId);
  final payee = await ref.read(upiPayeeProvider.future);
  final bytes = await buildInvoicePdf(d, await InvoiceFonts.load(), upi: payee);
  final filename = '${d.invoice.invoiceNoText}.pdf';
  final sharer = ref.read(billSharerProvider);

  if (!whatsapp) {
    await sharer.sharePdf(bytes: bytes, filename: filename);
    return ShareOutcome.sheet;
  }

  final number = whatsappNumber(d.party?.phone);
  if (number == null) {
    await sharer.sharePdf(bytes: bytes, filename: filename);
    return ShareOutcome.sheetNoPhone;
  }
  final shop = ref.read(sessionProvider).requireValue.shop.name;
  final due = d.invoice.totalPaise - d.invoice.paidPaise;
  final text = 'Bill ${d.invoice.invoiceNoText} from $shop: ${Money.format(d.invoice.totalPaise)}'
      '${due > 0 ? ' (balance due ${Money.format(due)})' : ''}. Thank you!';
  bool sent;
  try {
    sent = await sharer.sendToWhatsApp(bytes: bytes, filename: filename, number: number, text: text);
  } catch (e) {
    debugPrint('WhatsApp send failed: $e');
    sent = false;
  }
  if (sent) return ShareOutcome.whatsapp;
  await sharer.sharePdf(bytes: bytes, filename: filename);
  return ShareOutcome.sheetNoWhatsApp;
}

/// Builds a credit note's PDF from saved data and shares it, like [shareBill].
Future<ShareOutcome> shareCreditNote(WidgetRef ref, String returnId, {bool whatsapp = false}) async {
  final d = await ref.read(returnRepositoryProvider).details(returnId);
  final bytes = await buildCreditNotePdf(d, await InvoiceFonts.load());
  final filename = '${d.ret.creditNoteNoText}.pdf';
  final sharer = ref.read(billSharerProvider);

  if (!whatsapp) {
    await sharer.sharePdf(bytes: bytes, filename: filename);
    return ShareOutcome.sheet;
  }
  final number = whatsappNumber(d.party?.phone);
  if (number == null) {
    await sharer.sharePdf(bytes: bytes, filename: filename);
    return ShareOutcome.sheetNoPhone;
  }
  final shop = ref.read(sessionProvider).requireValue.shop.name;
  final text = 'Credit note ${d.ret.creditNoteNoText} from $shop for bill ${d.invoice.invoiceNoText}: '
      '${Money.format(d.ret.totalPaise)} refunded. Thank you!';
  bool sent;
  try {
    sent = await sharer.sendToWhatsApp(bytes: bytes, filename: filename, number: number, text: text);
  } catch (e) {
    debugPrint('WhatsApp send failed: $e');
    sent = false;
  }
  if (sent) return ShareOutcome.whatsapp;
  await sharer.sharePdf(bytes: bytes, filename: filename);
  return ShareOutcome.sheetNoWhatsApp;
}
