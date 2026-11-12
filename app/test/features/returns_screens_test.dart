import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/printing/credit_note_view.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/core/sharing/bill_sharer.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';
import 'package:shop_app/features/returns/return_screens.dart';

import '../helpers/app_harness.dart';

class FakeSharer implements BillSharer {
  final sheet = <String>[];
  final whatsapp = <({String filename, String number})>[];
  @override
  Future<void> sharePdf({required Uint8List bytes, required String filename}) async => sheet.add(filename);
  @override
  Future<bool> sendToWhatsApp({required Uint8List bytes, required String filename, required String number, String? text}) async {
    whatsapp.add((filename: filename, number: number));
    return true;
  }
}

Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 120}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _text(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data!;

Future<void> pinIn(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_$d')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const Key('pinOk')));
  await tester.pump(const Duration(milliseconds: 200));
}

/// One bill (A-0001) to Ramesh, as in the repository tests: Rs 259.00 =
/// Rs 50 cash + Rs 50 UPI + Rs 159 on credit, with 2.5 m wire and 10 switches.
Future<String> seedBill(ShopSession s) async {
  final items = ItemRepository(s.ctx);
  final wire = await items.createItem(name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000)]);
  final sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800, units: const [ItemUnitInput('pcs', 1)]);
  await StockRepository(s.ctx).adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
  await StockRepository(s.ctx).adjust(itemId: sw, locationId: s.locationId, deltaBase: 50, reason: 'Opening stock');
  final ramesh = await PartyRepository(s.ctx).createParty(kind: 'customer', name: 'Ramesh', phone: '9876543210');
  final totals = BillCalculator.calculate([
    CartLine(itemId: wire, itemName: 'Wire', unitName: 'm', factorToBase: 1000, qtyEntered: '2.5',
        ratePaise: 4750, priceUnitFactor: 1000, gstRateBp: 1800),
    CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '10',
        ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800, discountPaise: 1000),
  ], interState: false);
  return InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
    deviceId: s.deviceId,
    series: s.series,
    number: 1,
    date: DateTime.now(),
    locationId: s.locationId,
    partyId: ramesh,
    payments: [PaymentInput('cash', 5000), PaymentInput('upi', 5000), PaymentInput('credit', 15900)],
  ));
}

void main() {
  group('Bills list and detail show returns', () {
    harnessTest('a returned bill shows a Returned badge; a cancelled bill is struck through', (tester, h) async {
      final id = await tester.runAsync(() => seedBill(h.session));
      await h.pump(tester, const BillsScreen());
      expect(find.textContaining('Returned'), findsNothing);
      await endTest(tester);

      await tester.runAsync(() => partialReturn(h, id!));
      await h.pump(tester, const BillsScreen());
      await waitUntil(tester, () => find.textContaining('Returned').evaluate().isNotEmpty);
      expect(find.text('Returned ₹103.50'), findsOneWidget);
    }, sample: false);
  });

  group('Return screen', () {
    harnessTest('1 m of wire and 4 switches: refund worked out, suggested split, saved, credit note shown', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      final sharer = FakeSharer();
      await h.pump(tester, ReturnScreen(invoiceId: id), overrides: [billSharerProvider.overrideWithValue(sharer)]);

      final wireItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Wire')))!.first.item.id;
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$wireItem')), '1');
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '4');
      await waitUntil(tester, () => find.byKey(const Key('returnTotal')).evaluate().isNotEmpty &&
          _text(tester, 'returnTotal') == '₹103.50');
      expect(_text(tester, 'returnTotal'), '₹103.50');
      // The bill had Rs 159 still on credit, so the refund comes off his account first.
      expect(tester.widget<TextField>(find.byKey(const Key('refundAccount'))).controller!.text, '103.50');
      expect(_text(tester, 'refundStatus'), 'The refund adds up');

      await tester.tap(find.byKey(const Key('returnConfirm')));
      await waitUntil(tester, () => find.byKey(const Key('creditNoteNo')).evaluate().isNotEmpty);
      expect(_text(tester, 'creditNoteNo'), 'CN-A-0001');
      expect(_text(tester, 'creditNoteTotal'), '₹103.50');

      await db(tester, () async {
        expect(await LedgerRepository(h.session.ctx).balance(
            (await PartyRepository(h.session.ctx).searchCustomers('Ramesh')).single.id), 15900 - 10350);
        final r = await DataCheckRepository(h.session.ctx).run();
        expect(r.errors, isEmpty, reason: r.errors.join(', '));
      });

      await tester.tap(find.byKey(const Key('creditNoteWhatsApp')));
      await waitUntil(tester, () => sharer.whatsapp.isNotEmpty);
      expect(sharer.whatsapp.single.filename, 'CN-A-0001.pdf');
      expect(sharer.whatsapp.single.number, '919876543210');
    }, sample: false);

    harnessTest('asking for more than is left is refused in plain words and nothing can be confirmed', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await h.pump(tester, ReturnScreen(invoiceId: id));
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '11');
      await waitUntil(tester, () => find.byKey(const Key('returnError')).evaluate().isNotEmpty);
      expect(_text(tester, 'returnError'), contains('only 10 pcs can still be returned'));
      expect(find.byKey(const Key('returnConfirm')), findsNothing);
    }, sample: false);

    harnessTest('"All that is left" fills the whole line, and the rest of the bill returns the round-off', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await h.pump(tester, ReturnScreen(invoiceId: id));
      final wireItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Wire')))!.first.item.id;
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.tap(find.byKey(Key('retAll_$wireItem')));
      await tester.tap(find.byKey(Key('retAll_$swItem')));
      await waitUntil(tester, () => find.byKey(const Key('returnTotal')).evaluate().isNotEmpty &&
          _text(tester, 'returnTotal') == '₹259.00');
      expect(_text(tester, 'returnTotal'), '₹259.00'); // exactly what was paid, round-off included
      expect(find.textContaining('round-off is given back'), findsOneWidget);
    }, sample: false);

    harnessTest('a refund that does not add up cannot be confirmed', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await h.pump(tester, ReturnScreen(invoiceId: id));
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '2');
      await waitUntil(tester, () => find.byKey(const Key('returnTotal')).evaluate().isNotEmpty);
      await tester.enterText(find.byKey(const Key('refundAccount')), '5');
      await tester.pump();
      expect(_text(tester, 'refundStatus'), startsWith('Still to give back'));
      expect(tester.widget<FilledButton>(find.byKey(const Key('returnConfirm'))).onPressed, isNull);
    }, sample: false);
  });

  group('counter staff need the owner\'s PIN', () {
    Future<void> setUpOwnerPin(WidgetTester tester, Harness h) => tester.runAsync(() async {
          await AuthRepository(h.session.ctx).setPin(h.session.userId, '4821');
        });

    harnessTest('a wrong owner PIN stops the return; the right one lets it through, with both people recorded', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await setUpOwnerPin(tester, h);
      final counter = await h.addCounterUser(tester, name: 'Anil');
      await h.pump(tester, ReturnScreen(invoiceId: id), user: counter);
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '2');
      await waitUntil(tester, () => find.byKey(const Key('returnConfirm')).evaluate().isNotEmpty);

      await tester.tap(find.byKey(const Key('returnConfirm')));
      await waitUntil(tester, () => find.byKey(const Key('ownerApprovalDialog')).evaluate().isNotEmpty);
      expect(find.textContaining('The owner must approve a return of'), findsOneWidget);

      await pinIn(tester, '0000');
      await waitUntil(tester, () => find.text('Wrong PIN, try again').evaluate().isNotEmpty);
      expect(find.byKey(const Key('creditNoteNo')), findsNothing);
      await db(tester, () async {
        expect(await h.db.select(h.db.salesReturns).get(), isEmpty); // nothing was returned
      });

      await pinIn(tester, '4821');
      await waitUntil(tester, () => find.byKey(const Key('creditNoteNo')).evaluate().isNotEmpty);
      await db(tester, () async {
        final ret = (await h.db.select(h.db.salesReturns).get()).single;
        expect(ret.createdBy, counter.id);
        expect(ret.approvedBy, h.session.userId);
        final audit = await AuditRepository(h.session.ctx).list(actions: {'sales_return'});
        expect(audit.single.userName, 'Anil');
      });
    }, sample: false);

    harnessTest('the owner needs no PIN', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await h.pump(tester, ReturnScreen(invoiceId: id));
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '2');
      await waitUntil(tester, () => find.byKey(const Key('returnConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('returnConfirm')));
      await waitUntil(tester, () => find.byKey(const Key('creditNoteNo')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('ownerApprovalDialog')), findsNothing);
    }, sample: false);

    harnessTest('cancelling the owner dialog returns nothing', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await setUpOwnerPin(tester, h);
      final counter = await h.addCounterUser(tester, name: 'Anil');
      await h.pump(tester, ReturnScreen(invoiceId: id), user: counter);
      final swItem = (await tester.runAsync(() => ItemRepository(h.session.ctx).search('Switch')))!.first.item.id;
      await tester.enterText(find.byKey(Key('retQty_$swItem')), '2');
      await waitUntil(tester, () => find.byKey(const Key('returnConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('returnConfirm')));
      await waitUntil(tester, () => find.byKey(const Key('ownerApprovalCancel')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('ownerApprovalCancel')));
      await waitUntil(tester, () => find.byKey(const Key('ownerApprovalDialog')).evaluate().isEmpty);
      await db(tester, () async {
        expect(await h.db.select(h.db.salesReturns).get(), isEmpty);
      });
    }, sample: false);
  });

  group('Cancel bill', () {
    harnessTest('Keep the bill does nothing; Cancel bill reverses everything and marks the bill', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await h.pump(tester, BillDetailScreen(invoiceId: id));

      await tester.tap(find.byKey(const Key('detailCancel')));
      await waitUntil(tester, () => find.byKey(const Key('cancelConfirm')).evaluate().isNotEmpty);
      expect(find.textContaining('takes the whole bill back'), findsOneWidget);
      await tester.tap(find.byKey(const Key('cancelKeep')));
      await waitUntil(tester, () => find.byKey(const Key('cancelConfirm')).evaluate().isEmpty);
      await db(tester, () async {
        expect(await h.db.select(h.db.salesReturns).get(), isEmpty);
      });

      await tester.tap(find.byKey(const Key('detailCancel')));
      await waitUntil(tester, () => find.byKey(const Key('cancelReason')).evaluate().isNotEmpty);
      await tester.enterText(find.byKey(const Key('cancelReason')), 'Wrong customer');
      await tester.tap(find.byKey(const Key('cancelConfirm')));
      await waitUntil(tester, () => find.byKey(const Key('creditNoteNo')).evaluate().isNotEmpty);
      expect(_text(tester, 'creditNoteTotal'), '₹259.00');
      expect(find.text('This bill was cancelled'), findsWidgets); // on the credit note and on the bill underneath

      await db(tester, () async {
        final inv = await (h.db.select(h.db.invoices)..where((t) => t.id.equals(id))).getSingle();
        expect(inv.status, 'cancelled');
        final ramesh = (await PartyRepository(h.session.ctx).searchCustomers('Ramesh')).single;
        expect(await LedgerRepository(h.session.ctx).balance(ramesh.id), 0);
        final r = await DataCheckRepository(h.session.ctx).run();
        expect(r.errors, isEmpty, reason: r.errors.join(', '));
      });
    }, sample: false);

    harnessTest('after a cancel the bill shows it, lists its credit note, and offers no more returns', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await tester.runAsync(() => cancelWholeBill(h, id)); // cancel through the repository, then open the bill
      await h.pump(tester, BillDetailScreen(invoiceId: id));
      await waitUntil(tester, () => find.byKey(const Key('detailCancelled')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('detailCancelled')), findsOneWidget);
      expect(find.byKey(const Key('note_CN-A-0001')), findsOneWidget);
      expect(find.byKey(const Key('detailReturn')), findsNothing);
      expect(find.byKey(const Key('detailCancel')), findsNothing);
    }, sample: false);
  });

  group('credit note PDF', () {
    harnessTest('the credit note says what was returned, the refund split and the bill it belongs to', (tester, h) async {
      final id = (await tester.runAsync(() => seedBill(h.session)))!;
      await tester.runAsync(() => partialReturn(h, id));
      await h.pump(tester, const BillsScreen());
      final noteId = (await tester.runAsync(() async =>
          (await h.db.select(h.db.salesReturns).getSingle()).id))!;
      final view = await tester.runAsync(
          () async => CreditNoteView.from(await ReturnRepository(h.session.ctx).details(noteId)));
      expect(view!.noteNo, 'CN-A-0001');
      expect(view.againstBill, 'A-0001');
      expect(view.total, '₹103.50');
      expect(view.refunds, ['Taken off your account: ₹103.50']);
      expect(view.lines.map((l) => (l.name, l.qty, l.amount)), [('Wire', '1 m', '47.50'), ('Switch', '4 pcs', '56.00')]);
      expect(view.words, 'Rupees One Hundred Three and Fifty Paise only');
      expect(view.isCancel, isFalse);
    }, sample: false);
  });
}

/// 1 m wire + 4 switches taken back and refunded off Ramesh's account.
Future<void> partialReturn(Harness h, String invoiceId) async {
  final s = h.session;
  final r = ReturnRepository(s.ctx);
  final lines = await r.returnable(invoiceId);
  await r.postReturn(PostReturnInput(
    invoiceId: invoiceId,
    deviceId: s.deviceId,
    series: s.series,
    lines: [for (final l in lines) ReturnLineInput(l.line.id, l.itemName == 'Wire' ? '1' : '4')],
    refund: const RefundSplit(accountPaise: 10350),
    createdBy: s.userId,
    approvedBy: s.userId,
  ));
}

Future<void> cancelWholeBill(Harness h, String invoiceId) async {
  final s = h.session;
  await ReturnRepository(s.ctx).cancelBill(invoiceId,
      deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
}
