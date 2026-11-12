import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/debug/sample_data.dart';
import 'package:shop_app/core/printing/bill_words.dart';
import 'package:shop_app/core/printing/invoice_view.dart';
import 'package:shop_app/core/printing/marathi_bill.dart';
import 'package:shop_app/core/printing/upi_link.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/billing/bill_controller.dart';
import 'package:shop_app/shared/theme.dart';

/// A10: Marathi bills. The PDF pages are pictures drawn by Flutter (the pdf
/// package cannot join Marathi letters). Writes build/probe/marathi_*.pdf.
void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Future<ByteData> f(String n) async => ByteData.sublistView(File('assets/fonts/$n').readAsBytesSync());
    await (FontLoader(AppTheme.fontFamily)..addFont(f('NotoSans-Regular.ttf'))..addFont(f('NotoSans-Bold.ttf'))).load();
    await (FontLoader(AppTheme.marathiFont)
          ..addFont(f('NotoSansDevanagari-Regular.ttf'))
          ..addFont(f('NotoSansDevanagari-Bold.ttf')))
        .load();
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final s = await c.read(sessionProvider.future);
    c.read(currentUserProvider.notifier).login(
        await (db.select(db.users)..where((t) => t.role.equals('owner'))).getSingle());
    await SampleData.load(s.ctx, locationId: s.locationId);
  });

  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<InvoiceDetails> postBill() async {
    final bill = c.read(billProvider.notifier);
    final items = c.read(itemRepositoryProvider);
    await bill.setCustomer((await c.read(partyRepositoryProvider).searchCustomers('Ramesh')).single);
    await bill.addItem((await items.search('1.5 sqmm')).first);
    await bill.addItem((await items.search('6A switch')).first);
    bill.setQty(0, '2.5');
    bill.setDiscount(1, '10');
    final t = c.read(billResultProvider).totals!;
    final id = await bill.save([PaymentInput('cash', 10000), PaymentInput('credit', t.totalPaise - 10000)]);
    return c.read(invoiceRepositoryProvider).details(id);
  }

  test('Marathi amounts in words', () {
    expect(amountInWordsMr(2439100), 'रुपये चोवीस हजार तीनशे एक्याण्णव फक्त');
    expect(amountInWordsMr(10000), 'रुपये शंभर फक्त');
    expect(amountInWordsMr(12550), 'रुपये एकशे पंचवीस आणि पन्नास पैसे फक्त');
    expect(amountInWordsMr(1500000000), 'रुपये एक कोटी पन्नास लाख फक्त');
    expect(amountInWordsMr(0), 'रुपये शून्य फक्त');
  });

  test('the bill view in Marathi uses Marathi words and keeps numbers and names', () async {
    final d = await postBill();
    final v = InvoiceView.from(d, words: BillWords.mr);
    expect(v.payments.first, startsWith('रोख: ₹'));
    expect(v.dueText, startsWith('बाकी: ₹'));
    expect(v.words, startsWith('रुपये '));
    expect(v.billToName, 'Ramesh Electricals');
    final en = InvoiceView.from(d);
    expect(en.payments.first, startsWith('Cash: ₹'), reason: 'English bills are unchanged');
  });

  test('a Marathi bill and credit note become small, valid PDFs', () async {
    final d = await postBill();
    final bytes = await buildMarathiInvoicePdf(d,
        upi: const UpiPayee(vpa: 'pravin@okhdfc', name: 'Pravin Electricals'));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, lessThan(1024 * 1024));
    File('build/probe/marathi_bill.pdf')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    final returns = c.read(returnRepositoryProvider);
    final s = c.read(sessionProvider).requireValue;
    final retId = await returns.cancelBill(d.invoice.id, deviceId: s.deviceId, series: s.series);
    final note = await buildMarathiCreditNotePdf(await returns.details(retId));
    expect(String.fromCharCodes(note.take(5)), '%PDF-');
    File('build/probe/marathi_credit_note.pdf').writeAsBytesSync(note);
  });
}
