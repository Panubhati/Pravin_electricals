import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/dues_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';

/// Reports after returns, against hand-worked numbers. The bill (A-0001 to
/// Ramesh, prices include 18% GST) is the one from return_repository_test:
///   2.5 m wire at Rs 47.50 (118.75, GST 18.11) + 10 switches at Rs 15 less Rs 10 (140.00, GST 21.36)
///   = Rs 259.00 after round-off; Rs 50 cash + Rs 50 UPI + Rs 159 on credit.
/// Costs: wire Rs 30/m, switch Rs 9 each.
void main() {
  late AppDatabase db;
  late ShopSession s;
  late ReportsRepository reports;
  late ReturnRepository returns;
  late String wire, sw, ramesh, invoiceId;
  final day1 = DateTime(2026, 3, 10, 11);
  final day2 = DateTime(2026, 3, 11, 15);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    reports = ReportsRepository(s.ctx);
    returns = ReturnRepository(s.ctx);
    final items = ItemRepository(s.ctx);
    wire = await items.createItem(name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
        units: const [ItemUnitInput('m', 1000)]);
    sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800, units: const [ItemUnitInput('pcs', 1)]);
    await items.setCost(itemId: wire, costPaise: 3000, effectiveFrom: DateTime(2026, 3, 1));
    await items.setCost(itemId: sw, costPaise: 900, effectiveFrom: DateTime(2026, 3, 1));
    await StockRepository(s.ctx).adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
    await StockRepository(s.ctx).adjust(itemId: sw, locationId: s.locationId, deltaBase: 50, reason: 'Opening stock');
    ramesh = await PartyRepository(s.ctx).createParty(kind: 'customer', name: 'Ramesh');
    await SettingsRepository(s.ctx).set(SettingKeys.openingCashPaise, '100000');

    final totals = BillCalculator.calculate([
      CartLine(itemId: wire, itemName: 'Wire', unitName: 'm', factorToBase: 1000, qtyEntered: '2.5',
          ratePaise: 4750, priceUnitFactor: 1000, gstRateBp: 1800),
      CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '10',
          ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800, discountPaise: 1000),
    ], interState: false);
    invoiceId = await InvoiceRepository(s.ctx).postInvoice(totals.toInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: 1,
      date: day1,
      locationId: s.locationId,
      partyId: ramesh,
      payments: [PaymentInput('cash', 5000), PaymentInput('upi', 5000), PaymentInput('credit', 15900)],
    ));
  });
  tearDown(() => db.close());

  Future<String> lineOf(String itemId) async =>
      (await returns.returnable(invoiceId)).firstWhere((l) => l.line.itemId == itemId).line.id;

  /// 1 m of wire and 4 switches back: Rs 103.50 refunded as Rs 3.50 cash and Rs 100 off his account.
  Future<void> returnSome(DateTime when) async => returns.postReturn(PostReturnInput(
        invoiceId: invoiceId,
        deviceId: s.deviceId,
        series: s.series,
        lines: [ReturnLineInput(await lineOf(wire), '1'), ReturnLineInput(await lineOf(sw), '4')],
        refund: const RefundSplit(cashPaise: 350, accountPaise: 10000),
        createdBy: s.userId,
        approvedBy: s.userId,
        date: when,
      ));

  group('a return on the day of the sale', () {
    setUp(() => returnSome(day1.add(const Duration(hours: 3))));

    test('daily sales are net of the return, and the payment modes still add up', () async {
      final d = await reports.dailySales(day1);
      expect(d.grossPaise, 25900);
      expect(d.returnsPaise, 10350);
      expect(d.totalPaise, 15550);
      expect(d.billCount, 1);
      expect(d.returnCount, 1);
      expect(d.cancelCount, 0);
      expect(d.mode('cash'), 5000 - 350);
      expect(d.mode('upi'), 5000);
      expect(d.mode('credit'), 15900 - 10000);
      expect(d.byMode.values.fold<int>(0, (a, b) => a + b), d.totalPaise);
      expect(d.gstPaise, (1811 + 2136) - (724 + 854)); // GST inside, after the return
    });

    test('cash in hand drops by the cash handed back, not by the credit', () async {
      final c = await reports.cashPosition(day1);
      expect(c.cashSalesPaise, 5000);
      expect(c.cashRefundsPaise, 350);
      expect(c.openingPaise, 100000);
      expect(c.closingPaise, 100000 + 5000 - 350);
    });

    test('profit counts only what the customer kept', () async {
      final r = await reports.itemProfit(day1, day1);
      final w = r.rows.singleWhere((x) => x.item.name == 'Wire');
      // sold 2.5 m: sales 118.75 - GST 18.11 = 100.64, cost 75.00; 1 m back: 47.50 - GST 7.24 = 40.26, cost 30.00
      expect(w.taxableSalesPaise, 10064 - 4026);
      expect(w.costPaise, 7500 - 3000);
      expect(w.profitPaise, 6038 - 4500);
      expect(w.qtyBase, 1500);
      final x = r.rows.singleWhere((y) => y.item.name == 'Switch');
      // sold 10: 140.00 - 21.36 = 118.64, cost 90.00; 4 back: 56.00 - 8.54 = 47.46, cost 36.00
      expect(x.taxableSalesPaise, 11864 - 4746);
      expect(x.costPaise, 9000 - 3600);
      expect(x.qtyBase, 6);
    });

    test('Ramesh owes what is left, and it is dated as before', () async {
      final dues = await DuesRepository(s.ctx).receivables(asOf: day1.add(const Duration(days: 1)));
      expect(dues.single.buckets.totalDue, 5900);
    });
  });

  group('a cancelled bill', () {
    setUp(() async => returns.cancelBill(invoiceId, deviceId: s.deviceId, series: s.series,
        createdBy: s.userId, approvedBy: s.userId, date: day1.add(const Duration(hours: 1))));

    test('shows as cancelled with no sales, no GST and nothing in any payment mode', () async {
      final d = await reports.dailySales(day1);
      expect(d.billCount, 0); // not counted as a bill
      expect(d.cancelCount, 1);
      expect(d.grossPaise, 25900);
      expect(d.returnsPaise, 25900);
      expect(d.totalPaise, 0);
      expect(d.gstPaise, 0);
      expect(d.byMode.values, everyElement(0));
    });

    test('cash in hand is back to what it was', () async {
      final c = await reports.cashPosition(day1);
      expect(c.cashSalesPaise, 5000);
      expect(c.cashRefundsPaise, 5000);
      expect(c.closingPaise, 100000);
    });

    test('profit is nothing', () async {
      final r = await reports.itemProfit(day1, day1);
      expect(r.profitPaise, 0);
      expect(r.taxableSalesPaise, 0);
    });
  });

  group('a return on a later day than the sale', () {
    setUp(() => returnSome(day2));

    test('the day of the sale keeps its sales; the day of the return shows the refund', () async {
      final sold = await reports.dailySales(day1);
      expect(sold.totalPaise, 25900);
      expect(sold.returnsPaise, 0);

      final back = await reports.dailySales(day2);
      expect(back.billCount, 0);
      expect(back.grossPaise, 0);
      expect(back.returnsPaise, 10350);
      expect(back.totalPaise, -10350); // net sales that day are negative
      expect(back.returnCount, 1);
    });

    test('cash in hand carries the sale to the next day and takes the refund off then', () async {
      final c2 = await reports.cashPosition(day2);
      expect(c2.openingPaise, 100000 + 5000); // yesterday's cash sale
      expect(c2.cashRefundsPaise, 350);
      expect(c2.closingPaise, 100000 + 5000 - 350);
    });

    test('a profit report over both days nets out, but one over day 1 alone does not', () async {
      final both = await reports.itemProfit(day1, day2);
      final alone = await reports.itemProfit(day1, day1);
      expect(both.profitPaise, lessThan(alone.profitPaise));
      expect(alone.profitPaise, (10064 - 7500) + (11864 - 9000));
      expect(both.profitPaise, (6038 - 4500) + (11864 - 4746 - (9000 - 3600)));
    });
  });

  test('the home summary follows net sales', () async {
    await returnSome(day1.add(const Duration(hours: 3)));
    final dash = await reports.dashboard(now: day1.add(const Duration(hours: 6)));
    expect(dash.today.totalPaise, 15550);
    expect(dash.cash.closingPaise, 100000 + 5000 - 350);
  });
}
