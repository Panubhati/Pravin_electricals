import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/core/sharing/bill_sharer.dart';
import 'package:shop_app/features/billing/bill_done_screen.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/home/home_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

class FakeSharer implements BillSharer {
  FakeSharer({this.whatsappInstalled = true});
  bool whatsappInstalled;
  final sheet = <({Uint8List bytes, String filename})>[];
  final whatsapp = <({Uint8List bytes, String filename, String number, String? text})>[];

  @override
  Future<void> sharePdf({required Uint8List bytes, required String filename}) async =>
      sheet.add((bytes: bytes, filename: filename));

  @override
  Future<bool> sendToWhatsApp(
      {required Uint8List bytes, required String filename, required String number, String? text}) async {
    if (!whatsappInstalled) return false;
    whatsapp.add((bytes: bytes, filename: filename, number: number, text: text));
    return true;
  }
}

/// Building the PDF takes real time (fonts, layout), so wait for [done].
Future<void> waitFor(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  }
  await settle(tester);
}

String bytesStart(Uint8List b) => ascii.decode(b.sublist(0, 5));

void main() {
  Future<String> ramesh(Harness h, WidgetTester tester, {String? phone}) async {
    final p = await tester.runAsync(() async {
      final parties = PartyRepository(h.session.ctx);
      final found = (await parties.searchCustomers('Ramesh')).single;
      if (phone != null) {
        await parties.updateParty(
          partyId: found.id,
          kind: found.kind,
          name: found.name,
          tier: found.tier,
          creditLimitPaise: found.creditLimitPaise,
          phone: phone,
          userId: h.session.userId,
        );
      }
      return found.id;
    });
    return p!;
  }

  group('bills history', () {
    harnessTest('lists bills newest first with the customer and what is still due', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const BillsScreen());
      final titles = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title as Text).data).toList();
      expect(titles, hasLength(3));
      expect(titles, containsAll(['Ramesh', 'Walk-in customer']));
      expect(find.text('₹100.00 due'), findsOneWidget); // Ramesh's credit part
      expect(find.text('₹449.00'), findsNothing); // totals per bill, not the day
      expect(find.text('₹150.00'), findsOneWidget);
    }, sample: false);

    harnessTest('search by customer or by bill number', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const BillsScreen());
      await tester.enterText(find.byKey(const Key('billSearch')), 'ramesh');
      await settle(tester);
      expect(find.byType(ListTile), findsOneWidget);
      await tester.enterText(find.byKey(const Key('billSearch')), 'A-0003');
      await settle(tester);
      expect(find.byType(ListTile), findsOneWidget);
      await tester.enterText(find.byKey(const Key('billSearch')), 'nobody');
      await settle(tester);
      expect(find.text('No bills yet'), findsOneWidget);
    }, sample: false);

    harnessTest('opening a bill shows it as printed, with its due amount', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const BillsScreen());
      await tester.enterText(find.byKey(const Key('billSearch')), 'ramesh');
      await settle(tester);
      await tester.tap(find.byType(ListTile));
      await settle(tester);
      expect(find.byKey(const Key('detailInvoiceNo')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('detailTotal'))).data, '₹150.00');
      expect(tester.widget<Text>(find.byKey(const Key('detailDue'))).data, 'Balance due: ₹100.00');
      expect(find.text('Rupees One Hundred Fifty only'), findsOneWidget);
      expect(find.text('10 pcs at 15.00'), findsOneWidget);
    }, sample: false);

    harnessTest('the counter can open Bills too', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const HomeScreen(), user: counter);
      expect(find.byKey(const Key('tile_bills')), findsOneWidget);
    }, sample: false);
  });

  group('sharing', () {
    Future<FakeSharer> openDetail(WidgetTester tester, Harness h,
        {String? phone, bool installed = true}) async {
      final id = await ramesh(h, tester, phone: phone);
      final sharer = FakeSharer(whatsappInstalled: installed);
      final invoiceId = await tester.runAsync(() async {
        final all = await InvoiceRepository(h.session.ctx).list();
        return all.firstWhere((e) => e.partyName == 'Ramesh').invoice.id;
      });
      expect(id, isNotEmpty);
      await h.pump(tester, BillDetailScreen(invoiceId: invoiceId!),
          overrides: [billSharerProvider.overrideWithValue(sharer)]);
      return sharer;
    }

    harnessTest('Share PDF hands a real PDF named after the bill to the share sheet', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final sharer = await openDetail(tester, h);
      await tester.tap(find.byKey(const Key('detailShare')));
      await waitFor(tester, () => sharer.sheet.isNotEmpty);
      expect(sharer.sheet, hasLength(1));
      expect(sharer.sheet.single.filename, 'A-0002.pdf');
      expect(bytesStart(sharer.sheet.single.bytes), '%PDF-');
      expect(sharer.whatsapp, isEmpty);
    }, sample: false);

    harnessTest('WhatsApp goes straight to the customer\'s number with a short message', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final sharer = await openDetail(tester, h, phone: '98765 43210');
      await tester.tap(find.byKey(const Key('detailWhatsApp')));
      await waitFor(tester, () => sharer.whatsapp.isNotEmpty);
      expect(sharer.whatsapp, hasLength(1));
      final w = sharer.whatsapp.single;
      expect(w.number, '919876543210');
      expect(w.filename, 'A-0002.pdf');
      expect(bytesStart(w.bytes), '%PDF-');
      expect(w.text, contains('Bill A-0002'));
      expect(w.text, contains('₹150.00'));
      expect(w.text, contains('balance due ₹100.00'));
      expect(sharer.sheet, isEmpty);
    }, sample: false);

    harnessTest('no phone number: the share sheet opens and the owner is told why', (tester, h) async {
      await db(tester, () => seedToday(h.session)); // Ramesh has no phone in the seed
      final sharer = await openDetail(tester, h);
      await tester.tap(find.byKey(const Key('detailWhatsApp')));
      await waitFor(tester, () => sharer.sheet.isNotEmpty);
      expect(sharer.whatsapp, isEmpty);
      expect(sharer.sheet, hasLength(1));
      expect(find.text('This customer has no phone number saved, so the share sheet opened instead'),
          findsOneWidget);
    }, sample: false);

    harnessTest('WhatsApp not installed: the share sheet opens instead', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final sharer = await openDetail(tester, h, phone: '9876543210', installed: false);
      await tester.tap(find.byKey(const Key('detailWhatsApp')));
      await waitFor(tester, () => sharer.sheet.isNotEmpty);
      expect(sharer.whatsapp, isEmpty);
      expect(sharer.sheet, hasLength(1));
      expect(find.text('WhatsApp could not be opened, so the share sheet opened instead'), findsOneWidget);
    }, sample: false);

    harnessTest('the bill-saved screen has both buttons', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final sharer = FakeSharer();
      await ramesh(h, tester, phone: '9876543210');
      final invoiceId = (await tester.runAsync(() async {
        final all = await InvoiceRepository(h.session.ctx).list();
        return all.firstWhere((e) => e.partyName == 'Ramesh').invoice.id;
      }))!;
      await h.pump(tester, BillDoneScreen(invoiceId: invoiceId),
          overrides: [billSharerProvider.overrideWithValue(sharer)]);
      await tester.tap(find.byKey(const Key('whatsappPdf')));
      await waitFor(tester, () => sharer.whatsapp.isNotEmpty);
      expect(sharer.whatsapp.single.number, '919876543210');
      await tester.tap(find.byKey(const Key('sharePdf')));
      await waitFor(tester, () => sharer.sheet.isNotEmpty);
      expect(sharer.sheet.single.filename, 'A-0002.pdf');
    }, sample: false);
  });
}

