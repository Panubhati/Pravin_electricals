import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';

import '../helpers/fail_injection.dart';

/// Returns and cancels, with the numbers worked out by hand.
///
/// The bill used throughout (A-0001, to Ramesh, GST 18% included in the prices):
///   2.5 m wire at Rs 47.50/m  = 118.75   GST inside 18.11
///   10 switches at Rs 15      = 150.00 less Rs 10 discount = 140.00   GST inside 21.36
///   subtotal 268.75 - discount 10.00 = 258.75, rounded to Rs 259.00 (round-off +0.25)
///   paid: Rs 50 cash + Rs 50 UPI + Rs 159 on credit (udhaar)
void main() {
  late AppDatabase db;
  late ShopSession s;
  late ItemRepository items;
  late StockRepository stock;
  late LedgerRepository ledger;
  late ReturnRepository returns;
  late String wire, sw, ramesh, sunita;
  late String invoiceId;

  Future<String> sellToRamesh({List<PaymentInput>? payments}) async {
    final cart = [
      CartLine(
        itemId: wire, itemName: 'Wire', unitName: 'm', factorToBase: 1000, qtyEntered: '2.5',
        ratePaise: 4750, priceUnitFactor: 1000, gstRateBp: 1800,
      ),
      CartLine(
        itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '10',
        ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800, discountPaise: 1000,
      ),
    ];
    final totals = BillCalculator.calculate(cart, interState: false);
    expect(totals.totalPaise, 25900);
    final number = await InvoiceRepository(s.ctx).nextNumber(s.deviceId, s.series);
    return InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: number,
      date: DateTime.now(),
      locationId: s.locationId,
      partyId: ramesh,
      payments: payments ??
          [PaymentInput('cash', 5000), PaymentInput('upi', 5000), PaymentInput('credit', 15900)],
    ));
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    items = ItemRepository(s.ctx);
    stock = StockRepository(s.ctx);
    ledger = LedgerRepository(s.ctx);
    returns = ReturnRepository(s.ctx);
    wire = await items.createItem(name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
        units: const [ItemUnitInput('m', 1000)]);
    sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800, units: const [ItemUnitInput('pcs', 1)]);
    await stock.adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
    await stock.adjust(itemId: sw, locationId: s.locationId, deltaBase: 50, reason: 'Opening stock');
    final parties = PartyRepository(s.ctx);
    ramesh = await parties.createParty(kind: 'customer', name: 'Ramesh');
    sunita = await parties.createParty(kind: 'customer', name: 'Sunita');
    invoiceId = await sellToRamesh();
  });
  tearDown(() => db.close());

  Future<String> lineOf(String itemId) async =>
      (await returns.returnable(invoiceId)).firstWhere((l) => l.line.itemId == itemId).line.id;

  Future<PostReturnInput> input(List<ReturnLineInput> lines, RefundSplit refund, {String? reason, String? by}) async =>
      PostReturnInput(
        invoiceId: invoiceId,
        deviceId: s.deviceId,
        series: s.series,
        lines: lines,
        refund: refund,
        reason: reason,
        createdBy: by ?? s.userId,
        approvedBy: s.userId,
      );

  Future<void> expectHealthy() async {
    final r = await DataCheckRepository(s.ctx).run();
    expect(r.errors, isEmpty, reason: r.errors.join('\n'));
  }

  group('what can be returned', () {
    test('every line starts fully returnable, in the unit it was sold in', () async {
      final lines = await returns.returnable(invoiceId);
      expect(lines.map((l) => (l.itemName, l.line.unitName, l.remainingBase)), [('Wire', 'm', 2500), ('Switch', 'pcs', 10)]);
      expect(lines.every((l) => !l.fullyReturned), isTrue);
    });
  });

  group('refund amounts (hand worked)', () {
    test('1 m of wire and 4 switches', () async {
      final q = await returns.quote(invoiceId, [
        ReturnLineInput(await lineOf(wire), '1'),
        ReturnLineInput(await lineOf(sw), '4'),
      ]);
      // wire: 11875 x 1000/2500 = 4750 (GST 1811 x 0.4 = 724.4 -> 724)
      // switches: 14000 x 4/10 = 5600 (GST 2136 x 0.4 = 854.4 -> 854)
      expect(q.lines.map((l) => l.refundPaise), [4750, 5600]);
      expect(q.lines.map((l) => l.taxPaise), [724, 854]);
      expect(q.linesTotalPaise, 10350);
      expect(q.taxPaise, 1578);
      expect(q.roundOffPaise, 0); // the bill is not finished yet
      expect(q.totalPaise, 10350);
      expect(q.completesBill, isFalse);
    });

    test('returning the rest completes the bill and gives back the round-off', () async {
      final wireLine = await lineOf(wire);
      final swLine = await lineOf(sw);
      await returns.postReturn(await input(
          [ReturnLineInput(wireLine, '1'), ReturnLineInput(swLine, '4')], const RefundSplit(accountPaise: 10350)));

      final q = await returns.quote(invoiceId, [ReturnLineInput(wireLine, '1.5'), ReturnLineInput(swLine, '6')]);
      // wire: 11875 - 4750 = 7125; switches: 14000 - 5600 = 8400; plus the bill's round-off 25
      expect(q.lines.map((l) => l.refundPaise), [7125, 8400]);
      expect(q.linesTotalPaise, 15525);
      expect(q.roundOffPaise, 25);
      expect(q.totalPaise, 15550);
      expect(q.completesBill, isTrue);
      // Both returns together are exactly what the customer paid: Rs 259.00.
      expect(10350 + q.totalPaise, 25900);
    });

    test('returning one line in pieces always adds up to exactly what it sold for', () async {
      // A line of 3 pieces for Rs 10.01: thirds are 3.34, 3.33, 3.34.
      final cart = [
        CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '3',
            ratePaise: 334, priceUnitFactor: 1, gstRateBp: 0),
      ];
      final totals = BillCalculator.calculate(cart, interState: false);
      final id = await InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
        deviceId: s.deviceId,
        series: s.series,
        number: await InvoiceRepository(s.ctx).nextNumber(s.deviceId, s.series),
        date: DateTime.now(),
        locationId: s.locationId,
        payments: [PaymentInput('cash', totals.totalPaise)],
      ));
      final line = (await returns.returnable(id)).single.line;
      expect(line.lineTotalPaise, 1002);

      var refunded = 0;
      for (var n = 0; n < 3; n++) {
        final q = await returns.quote(id, [ReturnLineInput(line.id, '1')]);
        refunded += q.linesTotalPaise;
        await returns.postReturn(PostReturnInput(
          invoiceId: id,
          deviceId: s.deviceId,
          series: s.series,
          lines: [ReturnLineInput(line.id, '1')],
          refund: RefundSplit(cashPaise: q.totalPaise),
          createdBy: s.userId,
          approvedBy: s.userId,
        ));
      }
      expect(refunded, line.lineTotalPaise);
    });
  });

  group('posting a return', () {
    test('puts the stock back, lowers what the customer owes, and numbers the credit note', () async {
      expect(await stock.balance(itemId: wire), 97500);
      expect(await stock.balance(itemId: sw), 40);
      expect(await ledger.balance(ramesh), 15900);

      final id = await returns.postReturn(await input(
        [ReturnLineInput(await lineOf(wire), '1'), ReturnLineInput(await lineOf(sw), '4')],
        const RefundSplit(cashPaise: 350, accountPaise: 10000),
        reason: 'Wrong size',
      ));

      expect(await stock.balance(itemId: wire), 98500); // 1 m back
      expect(await stock.balance(itemId: sw), 44);
      expect(await ledger.balance(ramesh), 5900); // 15,900 - 10,000 off what he owes

      final d = await returns.details(id);
      expect(d.ret.creditNoteNoText, 'CN-A-0001');
      expect(d.ret.totalPaise, 10350);
      expect(d.ret.refundCashPaise, 350);
      expect(d.ret.refundAccountPaise, 10000);
      expect(d.ret.note, 'Wrong size');
      expect(d.ret.isCancel, isFalse);
      expect(d.lines.map((l) => (l.qtyEntered, l.unitName, l.qtyBase, l.lineTotalPaise)),
          [('1', 'm', 1000, 4750), ('4', 'pcs', 4, 5600)]);
      expect(d.invoice.status, 'posted'); // a return does not cancel the bill

      final moves = await db.customSelect("SELECT movement_type, qty_base, location_id FROM stock_movements WHERE ref_type = 'sales_return'").get();
      expect(moves.map((m) => m.data['movement_type']), everyElement('sale_return'));
      expect(moves.map((m) => m.data['qty_base']), [1000, 4]);
      expect(moves.map((m) => m.data['location_id']).toSet(), {s.locationId});

      final entry = (await db.select(db.ledgerEntries).get()).firstWhere((e) => e.entryType == 'return');
      expect(entry.amountPaise, -10000);
      expect(entry.refId, id);
      await expectHealthy();
    });

    test('credit note numbers go up, and a second return can use the same bill', () async {
      final wireLine = await lineOf(wire);
      final a = await returns.postReturn(await input([ReturnLineInput(wireLine, '0.5')], const RefundSplit(cashPaise: 2375)));
      final b = await returns.postReturn(await input([ReturnLineInput(wireLine, '0.5')], const RefundSplit(cashPaise: 2375)));
      expect((await returns.details(a)).ret.creditNoteNoText, 'CN-A-0001');
      expect((await returns.details(b)).ret.creditNoteNoText, 'CN-A-0002');
      expect((await returns.forInvoice(invoiceId)).map((r) => r.number), [1, 2]);
      expect((await returns.returnable(invoiceId)).first.returnedBase, 1000);
      await expectHealthy();
    });

    test('a refund by UPI and a refund by cash are kept apart', () async {
      final id = await returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '2')],
          const RefundSplit(cashPaise: 1000, upiPaise: 1800)));
      final r = (await returns.details(id)).ret;
      expect((r.refundCashPaise, r.refundUpiPaise, r.refundAccountPaise), (1000, 1800, 0));
    });

    test('the audit log records who returned what and who approved it', () async {
      final counter = await db.customSelect("SELECT id FROM users LIMIT 1").getSingle();
      await returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '1')], const RefundSplit(cashPaise: 1400),
          reason: 'Faulty', by: counter.data['id'] as String));
      final audit = await AuditRepository(s.ctx).list(actions: {'sales_return'});
      expect(audit, hasLength(1));
      expect(audit.single.row.afterJson, contains('CN-A-0001'));
      expect(audit.single.row.afterJson, contains('Faulty'));
      expect(audit.single.row.afterJson, contains('approvedBy'));
    });

    test('every record reaches the outbox', () async {
      await returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '1')], const RefundSplit(accountPaise: 1400)));
      final outbox = (await db.select(db.outbox).get()).map((o) => o.entity).toList();
      expect(outbox, containsAll(['sales_returns', 'sales_return_lines', 'stock_movements', 'ledger_entries', 'audit_log']));
    });
  });

  group('what is refused', () {
    Future<void> refuses(Future<Object?> call, String message) => expectLater(
        call, throwsA(isA<DomainException>().having((e) => e.message, 'message', contains(message))));

    test('more than was sold, or more than is left', () async {
      final swLine = await lineOf(sw);
      await refuses(returns.postReturn(await input([ReturnLineInput(swLine, '11')], const RefundSplit(cashPaise: 15400))),
          'only 10 pcs can still be returned');
      await returns.postReturn(await input([ReturnLineInput(swLine, '8')], const RefundSplit(cashPaise: 11200)));
      await refuses(returns.postReturn(await input([ReturnLineInput(swLine, '3')], const RefundSplit(cashPaise: 4200))),
          'only 2 pcs can still be returned');
    });

    test('nothing, zero, negative, or not a number', () async {
      final swLine = await lineOf(sw);
      await refuses(returns.quote(invoiceId, []), 'Choose what is being returned');
      await refuses(returns.quote(invoiceId, [ReturnLineInput(swLine, '0')]), 'more than 0');
      await refuses(returns.quote(invoiceId, [ReturnLineInput(swLine, 'abc')]), 'not a valid quantity');
      await refuses(returns.quote(invoiceId, [ReturnLineInput(swLine, '-1')]), 'not a valid quantity');
    });

    test('the same line twice, or a line from another bill', () async {
      final swLine = await lineOf(sw);
      await refuses(returns.quote(invoiceId, [ReturnLineInput(swLine, '1'), ReturnLineInput(swLine, '1')]), 'listed twice');
      await refuses(returns.quote(invoiceId, [const ReturnLineInput('not-a-line', '1')]), 'not on bill');
    });

    test('a refund that does not add up to what is owed back', () async {
      await refuses(returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '1')], const RefundSplit(cashPaise: 1000))),
          'must add up to');
    });

    test('a refund to the account of a walk-in customer', () async {
      final cart = [
        CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '1',
            ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800),
      ];
      final totals = BillCalculator.calculate(cart, interState: false);
      final walkIn = await InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
        deviceId: s.deviceId,
        series: s.series,
        number: await InvoiceRepository(s.ctx).nextNumber(s.deviceId, s.series),
        date: DateTime.now(),
        locationId: s.locationId,
        payments: [PaymentInput('cash', totals.totalPaise)],
      ));
      final line = (await returns.returnable(walkIn)).single.line;
      await refuses(
        returns.postReturn(PostReturnInput(
          invoiceId: walkIn,
          deviceId: s.deviceId,
          series: s.series,
          lines: [ReturnLineInput(line.id, '1')],
          refund: RefundSplit(accountPaise: totals.totalPaise),
        )),
        'Only a bill with a customer',
      );
    });

    test('negative refund amounts', () async {
      await refuses(
          returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '1')], const RefundSplit(cashPaise: 2800, upiPaise: -1400))),
          'cannot be negative');
    });
  });

  group('cancel bill', () {
    test('everything goes back the way it came, and the bill is marked cancelled', () async {
      final id = await returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series, reason: 'Wrong customer', createdBy: s.userId, approvedBy: s.userId);

      final d = await returns.details(id);
      expect(d.ret.isCancel, isTrue);
      expect(d.ret.totalPaise, 25900); // exactly what was paid
      expect(d.ret.roundOffPaise, 25);
      expect((d.ret.refundCashPaise, d.ret.refundUpiPaise, d.ret.refundAccountPaise), (5000, 5000, 15900));
      expect(d.invoice.status, 'cancelled');

      expect(await stock.balance(itemId: wire), 100000); // all back
      expect(await stock.balance(itemId: sw), 50);
      expect(await ledger.balance(ramesh), 0); // he owes nothing again
      await expectHealthy();
    });

    test('a cancelled bill cannot be cancelled or returned again', () async {
      await returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
      await expectLater(returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series),
          throwsA(isA<DomainException>().having((e) => e.message, 'm', contains('already cancelled'))));
      await expectLater(returns.quote(invoiceId, [ReturnLineInput(await lineOf(sw), '1')]), throwsA(isA<DomainException>()));
    });

    test('after a part-return the rest is returned, not cancelled', () async {
      await returns.postReturn(await input([ReturnLineInput(await lineOf(sw), '1')], const RefundSplit(cashPaise: 1400)));
      await expectLater(returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series),
          throwsA(isA<DomainException>().having((e) => e.message, 'm', contains('already been returned'))));
    });

    test('a bill paid all in cash refunds all in cash', () async {
      final cashBill = await sellToRamesh(payments: [PaymentInput('cash', 25900)]);
      final id = await returns.cancelBill(cashBill, deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
      final r = (await returns.details(id)).ret;
      expect((r.refundCashPaise, r.refundUpiPaise, r.refundAccountPaise), (25900, 0, 0));
      expect(await ledger.balance(ramesh), 15900); // only the first bill's credit remains
    });

    test('the audit log says the bill was cancelled', () async {
      await returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series, reason: 'Duplicate', createdBy: s.userId, approvedBy: s.userId);
      final audit = await AuditRepository(s.ctx).list(actions: {'bill_cancelled'});
      expect(audit.single.row.afterJson, contains('Duplicate'));
    });
  });

  group('a return that fails part-way leaves nothing behind', () {
    for (final table in ['sales_returns', 'sales_return_lines', 'stock_movements', 'ledger_entries', 'audit_log', 'outbox']) {
      test('refused at the first write to $table', () async {
        final fail = FailInjection(db);
        final swLine = await lineOf(sw);
        final wireLine = await lineOf(wire);
        final before = await fail.snapshot();
        final trigger = await fail.failInsert(table);
        await expectLater(
          returns.postReturn(await input([ReturnLineInput(wireLine, '1'), ReturnLineInput(swLine, '4')], const RefundSplit(accountPaise: 10350))),
          throwsA(anything),
        );
        expect(await fail.snapshot(), before);
        await fail.remove(trigger);
        await returns.postReturn(await input([ReturnLineInput(wireLine, '1'), ReturnLineInput(swLine, '4')], const RefundSplit(accountPaise: 10350)));
        await expectHealthy();
      });
    }

    test('a cancel that fails after the bill was marked leaves the bill posted', () async {
      final fail = FailInjection(db);
      final trigger = await fail.failInsert('audit_log'); // the last thing a cancel writes
      await expectLater(
          returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId),
          throwsA(anything));
      final inv = await (db.select(db.invoices)..where((t) => t.id.equals(invoiceId))).getSingle();
      expect(inv.status, 'posted');
      await fail.remove(trigger);
      await returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
      expect((await (db.select(db.invoices)..where((t) => t.id.equals(invoiceId))).getSingle()).status, 'cancelled');
      await expectHealthy();
    });
  });

  test('a customer with nothing owing ends up with an advance when refunded to their account', () async {
    final cart = [
      CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '2',
          ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800),
    ];
    final totals = BillCalculator.calculate(cart, interState: false);
    final cashBill = await InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: await InvoiceRepository(s.ctx).nextNumber(s.deviceId, s.series),
      date: DateTime.now(),
      locationId: s.locationId,
      partyId: sunita,
      payments: [PaymentInput('cash', totals.totalPaise)],
    ));
    final line = (await returns.returnable(cashBill)).single.line;
    await returns.postReturn(PostReturnInput(
      invoiceId: cashBill,
      deviceId: s.deviceId,
      series: s.series,
      lines: [ReturnLineInput(line.id, '2')],
      refund: RefundSplit(accountPaise: totals.totalPaise),
      createdBy: s.userId,
      approvedBy: s.userId,
    ));
    expect(await ledger.balance(sunita), -3000); // the shop owes her Rs 30 (an advance)
    await expectHealthy();
  });
}
