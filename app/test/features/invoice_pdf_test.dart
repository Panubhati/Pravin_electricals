import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/debug/sample_data.dart';
import 'package:shop_app/core/printing/invoice_pdf.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/billing/bill_controller.dart';

pw.Font _font(String name) => pw.Font.ttf(
    ByteData.sublistView(File('assets/fonts/$name').readAsBytesSync()));

void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final s = await c.read(sessionProvider.future);
    // The owner is logged in (nobody logged in means no discounts at all).
    c.read(currentUserProvider.notifier).login(
        await (db.select(db.users)..where((t) => t.role.equals('owner'))).getSingle());
    await SampleData.load(s.ctx, locationId: s.locationId);
  });

  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<InvoiceDetails> postBill({bool withCustomer = false}) async {
    final bill = c.read(billProvider.notifier);
    final items = c.read(itemRepositoryProvider);
    if (withCustomer) {
      final p = (await c.read(partyRepositoryProvider).searchCustomers('Ramesh')).single;
      await bill.setCustomer(p);
    }
    await bill.addItem((await items.search('1.5 sqmm')).first);
    await bill.addItem((await items.search('6A switch')).first);
    bill.setQty(0, '2.5');
    bill.setDiscount(1, '10');
    final t = c.read(billResultProvider).totals!;
    final id = await bill.save(withCustomer
        ? [PaymentInput('cash', 10000), PaymentInput('credit', t.totalPaise - 10000)]
        : [PaymentInput('upi', t.totalPaise)]);
    return c.read(invoiceRepositoryProvider).details(id);
  }

  test('builds a valid PDF for a walk-in bill', () async {
    final d = await postBill();
    final bytes = await buildInvoicePdf(
        d, InvoiceFonts(_font('NotoSans-Regular.ttf'), _font('NotoSans-Bold.ttf')));
    expect(bytes.length, greaterThan(2000));
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(ascii.decode(bytes.sublist(bytes.length - 6)), contains('%%EOF'));
  });

  test('builds a valid PDF for a credit bill to a customer', () async {
    final d = await postBill(withCustomer: true);
    expect(d.party, isNotNull);
    final bytes = await buildInvoicePdf(
        d, InvoiceFonts(_font('NotoSans-Regular.ttf'), _font('NotoSans-Bold.ttf')));
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });

  test('the PDF is regenerated from data, not stored anywhere', () async {
    final d = await postBill();
    final fonts = InvoiceFonts(_font('NotoSans-Regular.ttf'), _font('NotoSans-Bold.ttf'));
    final a = await buildInvoicePdf(d, fonts, compress: false);
    final b = await buildInvoicePdf(d, fonts, compress: false);
    expect(a.length, b.length);
    // No PDF column or table exists in the schema.
    final tables = await db.customSelect("SELECT name FROM sqlite_master WHERE type='table'").get();
    expect(tables.map((r) => r.read<String>('name')).where((n) => n.contains('pdf')), isEmpty);
  });
}
