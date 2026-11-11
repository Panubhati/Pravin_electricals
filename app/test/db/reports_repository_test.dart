import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

/// Dashboard and report numbers against a small dataset worked out by hand.
///
/// Day 1 (10 Mar 2026), three bills:
///  1. 2.5 m wire at Rs 47.50/m = 118.75, rounded to 119.00, cash.
///     GST inside 18.11, taxable 100.64, cost 2.5 m x Rs 30 = 75.00, profit 25.64.
///  2. 10 switches at Rs 15 = 150.00: Rs 50 UPI + Rs 100 credit to Ramesh.
///     GST inside 22.88, taxable 127.12, cost 10 x Rs 9 = 90.00, profit 37.12.
///  3. 2 bulbs at Rs 90 (12% GST) = 180.00 cash. GST inside 19.29, no cost known.
/// Day 2: the switch cost rises to Rs 10 (effective that morning), then
///  4. 5 switches at Rs 15 = 75.00 cash. GST inside 11.44, taxable 63.56,
///     cost 5 x Rs 10 = 50.00, profit 13.56.
void main() {
  late AppDatabase db;
  late ShopSession s;
  late ItemRepository items;
  late StockRepository stock;
  late LedgerRepository ledger;
  late ReportsRepository reports;
  late SettingsRepository settings;
  late String wire, sw, bulb, ramesh, supplier;

  final d1 = DateTime(2026, 3, 10, 10);
  final d2 = DateTime(2026, 3, 11, 11);
  var n = 0;

  Future<void> bill(
    DateTime date,
    String itemId,
    String qty,
    int qtyBase,
    int rate,
    int factor,
    int gst,
    List<PaymentInput> Function(int total) pay, {
    String? partyId,
    int roundOff = 0,
  }) async {
    final amount = (qtyBase * rate / factor).round();
    final tax = (amount * gst / (10000 + gst)).round();
    final total = amount + roundOff;
    await InvoiceRepository(s.ctx).postInvoice(PostInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: ++n,
      date: date,
      locationId: s.locationId,
      partyId: partyId,
      subtotalPaise: amount,
      discountPaise: 0,
      taxPaise: tax,
      roundOffPaise: roundOff,
      totalPaise: total,
      lines: [
        InvoiceLineInput(
          itemId: itemId,
          unitName: factor == 1000 ? 'm' : 'pcs',
          qtyEntered: qty,
          qtyBase: qtyBase,
          ratePaise: rate,
          priceUnitFactor: factor,
          gstRateBp: gst,
          taxPaise: tax,
          lineTotalPaise: amount,
        ),
      ],
      payments: pay(total),
    ));
  }

  setUp(() async {
    n = 0;
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    items = ItemRepository(s.ctx);
    stock = StockRepository(s.ctx);
    ledger = LedgerRepository(s.ctx);
    reports = ReportsRepository(s.ctx);
    settings = SettingsRepository(s.ctx);
    final parties = PartyRepository(s.ctx);

    wire = await items.createItem(name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
        units: const [ItemUnitInput('m', 1000)]);
    sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800, minStockBase: 20,
        units: const [ItemUnitInput('pcs', 1)]);
    bulb = await items.createItem(name: 'Bulb', baseUnit: 'pcs', gstRateBp: 1200, units: const [ItemUnitInput('pcs', 1)]);
    ramesh = await parties.createParty(kind: 'customer', name: 'Ramesh');
    supplier = await parties.createParty(kind: 'supplier', name: 'Polycab');

    await items.setCost(itemId: wire, costPaise: 3000, effectiveFrom: DateTime(2026, 3, 1));
    await items.setCost(itemId: sw, costPaise: 900, effectiveFrom: DateTime(2026, 3, 1));
    await items.setCost(itemId: sw, costPaise: 1000, effectiveFrom: DateTime(2026, 3, 11, 9));

    await bill(d1, wire, '2.5', 2500, 4750, 1000, 1800, (t) => [PaymentInput('cash', t)], roundOff: 25);
    await bill(d1.add(const Duration(hours: 1)), sw, '10', 10, 1500, 1, 1800,
        (t) => [PaymentInput('upi', 5000), PaymentInput('credit', 10000)],
        partyId: ramesh);
    await bill(d1.add(const Duration(hours: 2)), bulb, '2', 2, 9000, 1, 1200,
        (t) => [PaymentInput('cash', t)]);
    await bill(d2, sw, '5', 5, 1500, 1, 1800, (t) => [PaymentInput('cash', t)]);
  });

  tearDown(() => db.close());

  group('daily sales', () {
    test('day 1 totals, GST and the payment-mode split', () async {
      final d = await reports.dailySales(DateTime(2026, 3, 10, 23, 59));
      expect(d.billCount, 3);
      expect(d.totalPaise, 11900 + 15000 + 18000);
      expect(d.gstPaise, 1811 + 2288 + 1929);
      expect(d.mode('cash'), 11900 + 18000);
      expect(d.mode('upi'), 5000);
      expect(d.mode('credit'), 10000);
      expect(d.byMode.values.fold<int>(0, (a, b) => a + b), d.totalPaise);
    });

    test('day 2 holds only its own bill; an empty day is zero', () async {
      expect((await reports.dailySales(d2)).totalPaise, 7500);
      final empty = await reports.dailySales(DateTime(2026, 3, 12));
      expect(empty.billCount, 0);
      expect(empty.totalPaise, 0);
    });

    test('a bill at 00:00 belongs to its own day, not the one before', () async {
      await bill(DateTime(2026, 3, 12), sw, '1', 1, 1500, 1, 1800, (t) => [PaymentInput('cash', t)]);
      expect((await reports.dailySales(DateTime(2026, 3, 12))).billCount, 1);
      expect((await reports.dailySales(DateTime(2026, 3, 11, 23, 59))).billCount, 1);
    });
  });

  group('cash in hand', () {
    test('cash sales + cash receipts - cash paid out, on top of opening cash', () async {
      await settings.set(SettingKeys.openingCashPaise, '100000');
      await ledger.recordCustomerPayment(ramesh, 3000, mode: 'cash', ts: d1.add(const Duration(hours: 4)));
      await ledger.recordCustomerPayment(ramesh, 2000, mode: 'upi', ts: d1.add(const Duration(hours: 4)));
      await ledger.recordSupplierPayment(supplier, 4000, mode: 'cash', ts: d1.add(const Duration(hours: 5)));
      await ledger.recordSupplierPayment(supplier, 1000, mode: 'bank', ts: d1.add(const Duration(hours: 5)));

      final c1 = await reports.cashPosition(d1);
      expect(c1.cashSalesPaise, 29900);
      expect(c1.cashReceiptsPaise, 3000); // UPI is not cash
      expect(c1.cashPaidOutPaise, 4000); // bank is not cash
      expect(c1.openingPaise, 100000);
      expect(c1.closingPaise, 100000 + 29900 + 3000 - 4000);

      final c2 = await reports.cashPosition(d2);
      expect(c2.openingPaise, c1.closingPaise); // yesterday's close is today's open
      expect(c2.cashSalesPaise, 7500);
      expect(c2.closingPaise, 128900 + 7500);
    });

    test('before any bill the cash is just the opening cash', () async {
      await settings.set(SettingKeys.openingCashPaise, '250000');
      final c = await reports.cashPosition(DateTime(2026, 3, 9));
      expect(c.closingPaise, 250000);
    });
  });

  group('item profit', () {
    test('profit uses the cost in force on each bill date', () async {
      final r = await reports.itemProfit(d1, d2);
      final byName = {for (final row in r.rows) row.item.name: row};

      final w = byName['Wire']!;
      expect(w.taxableSalesPaise, 11875 - 1811);
      expect(w.costPaise, 7500);
      expect(w.profitPaise, 2564);
      expect(w.qtyBase, 2500);

      // Switches: 10 sold at the old cost (900), 5 at the new one (1000).
      final x = byName['Switch']!;
      expect(x.taxableSalesPaise, (15000 - 2288) + (7500 - 1144));
      expect(x.costPaise, 9000 + 5000);
      expect(x.profitPaise, 3712 + 1356);
      expect(x.qtyBase, 15);
    });

    test('items without a known cost are flagged, never guessed', () async {
      final r = await reports.itemProfit(d1, d2);
      final b = r.rows.singleWhere((row) => row.item.name == 'Bulb');
      expect(b.unknownCostSalesPaise, 18000 - 1929);
      expect(b.costPaise, 0);
      expect(b.taxableSalesPaise, 0);
      expect(b.profitPaise, 0); // not counted as profit
      expect(r.unknownCostSalesPaise, 16071);
    });

    test('totals, ordering and the date range', () async {
      final both = await reports.itemProfit(d1, d2);
      expect(both.profitPaise, 2564 + 3712 + 1356);
      expect(both.rows.first.item.name, 'Switch'); // best profit first

      final dayOne = await reports.itemProfit(d1, d1);
      expect(dayOne.rows.singleWhere((r) => r.item.name == 'Switch').profitPaise, 3712);
      expect((await reports.itemProfit(DateTime(2026, 4, 1), DateTime(2026, 4, 2))).rows, isEmpty);
    });

    test('a cost set only after the sale does not apply backwards', () async {
      final late = await items.createItem(name: 'Late', baseUnit: 'pcs', gstRateBp: 0, units: const [ItemUnitInput('pcs', 1)]);
      await bill(d1, late, '1', 1, 1000, 1, 0, (t) => [PaymentInput('cash', t)]);
      await items.setCost(itemId: late, costPaise: 400, effectiveFrom: d2);
      final r = await reports.itemProfit(d1, d1);
      final row = r.rows.singleWhere((x) => x.item.name == 'Late');
      expect(row.unknownCostSalesPaise, 1000);
      expect(row.profitPaise, 0);
    });
  });

  group('stock value and low stock', () {
    test('value is balance x latest cost; unknown cost is listed apart', () async {
      // Opening stock: 100 m wire, 8 switches, 5 bulbs.
      await stock.adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
      await stock.adjust(itemId: sw, locationId: s.locationId, deltaBase: 23, reason: 'Opening stock');
      await stock.adjust(itemId: bulb, locationId: s.locationId, deltaBase: 7, reason: 'Opening stock');
      // Balances after the bills: wire 100000-2500, switches 23-15=8, bulbs 7-2=5.
      final v = await reports.stockValue();
      final byName = {for (final r in v.rows) r.item.name: r};
      expect(byName['Wire']!.balanceBase, 97500);
      expect(byName['Wire']!.valuePaise, 97500 * 3000 ~/ 1000); // 292,500
      expect(byName['Switch']!.valuePaise, 8 * 1000); // latest cost Rs 10
      expect(v.totalPaise, 292500 + 8000);
      expect(v.unknownCost.map((r) => r.item.name), ['Bulb']);
      expect(v.rows.last.item.name, 'Bulb'); // unknown cost sorts last
    });

    test('low stock matches the Stock screen rule and ignores negatives', () async {
      await stock.adjust(itemId: sw, locationId: s.locationId, deltaBase: 28, reason: 'x'); // 28-15 = 13 < 20
      final low = await reports.lowStock();
      expect(low.map((e) => e.item.name), ['Switch']);
      expect(low.single.balanceBase, 13);
      // Wire and bulbs are negative (sold without stock), not "low".
      expect(await reports.negativeStockCount(), 2);
    });
  });

  group('dashboard', () {
    test('brings today, cash, stock flags and the biggest dues together', () async {
      final dash = await reports.dashboard(now: d1.add(const Duration(hours: 6)));
      expect(dash.today.totalPaise, 44900);
      expect(dash.cash.cashSalesPaise, 29900);
      expect(dash.topDues.single.party.id, ramesh);
      expect(dash.topDues.single.buckets.totalDue, 10000);
      expect(dash.totalDuePaise, 10000);
      expect(dash.lowStockCount, 0);
      expect(dash.negativeStockCount, 3); // nothing was ever stocked in this fixture
    });
  });
}
