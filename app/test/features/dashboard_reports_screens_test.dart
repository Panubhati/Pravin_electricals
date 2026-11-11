import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/reports/reports_screens.dart';
import 'package:shop_app/features/stock/stock_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  group('dashboard', () {
    harnessTest('the owner home shows today\'s numbers from the seeded shop', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const HomeScreen());

      expect(find.byKey(const Key('tile_reports')), findsOneWidget);
      expect(find.text('₹449.00'), findsOneWidget); // today's sales
      expect(find.text('₹1,329.00'), findsOneWidget); // cash in hand
      expect(find.descendant(of: find.byKey(const Key('dashBills')), matching: find.text('3')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('dashLowStock')), matching: find.text('1')), findsOneWidget);
      expect(_text(tester, 'dashTotalDue'), '₹70.00');
      expect(find.byKey(const Key('dashDue_Ramesh')), findsOneWidget);
    }, sample: false);

    harnessTest('tapping Low stock opens the Stock list already filtered', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const HomeScreen());
      await tester.tap(find.byKey(const Key('dashLowStock')));
      await settle(tester);
      expect(find.byType(StockScreen), findsOneWidget);
      expect(find.text('6A switch'), findsOneWidget);
      expect(find.text('Copper wire 1.5'), findsNothing); // not low
    }, sample: false);

    harnessTest('the counter sees no dashboard and no Reports tile', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const HomeScreen(), user: counter);
      expect(find.byKey(const Key('dashSales')), findsNothing);
      expect(find.byKey(const Key('tile_reports')), findsNothing);
      expect(find.text('₹449.00'), findsNothing);
    }, sample: false);
  });

  group('reports', () {
    harnessTest('daily sales: totals, payment modes and cash in hand', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const DailySalesScreen());
      expect(_text(tester, 'salesBills'), '3');
      expect(_text(tester, 'salesTotal'), '₹449.00');
      expect(_text(tester, 'modeCash'), '₹299.00');
      expect(_text(tester, 'modeUpi'), '₹50.00');
      expect(_text(tester, 'modeCredit'), '₹100.00');
      expect(_text(tester, 'cashClosing'), '₹1,329.00');

      // Yesterday had nothing; the cash carried in is the opening cash only.
      await tester.tap(find.byKey(const Key('dayBack')));
      await settle(tester);
      expect(_text(tester, 'salesBills'), '0');
      expect(_text(tester, 'cashClosing'), '₹1,000.00');
    }, sample: false);

    harnessTest('item profit: totals, per-item rows, and unknown cost kept apart', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const ItemProfitScreen());
      expect(_text(tester, 'profitSales'), '₹227.76');
      expect(_text(tester, 'profitCost'), '₹165.00');
      expect(_text(tester, 'profitTotal'), '₹62.76');
      expect(find.byKey(const Key('profitRow_Copper wire 1.5')), findsOneWidget);
      expect(find.byKey(const Key('profitRow_6A switch')), findsOneWidget);
      // The bulbs have no cost price: listed apart, not counted as profit.
      expect(find.byKey(const Key('profitRow_LED bulb')), findsNothing);
      expect(find.byKey(const Key('unknownRow_LED bulb')), findsOneWidget);
      expect(find.text('₹160.71'), findsOneWidget);
    }, sample: false);

    harnessTest('stock value: balance x cost, and items with no cost listed apart', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const StockValueScreen());
      expect(_text(tester, 'stockValueTotal'), '₹3,042.00'); // 2,925.00 wire + 117.00 switches
      expect(find.byKey(const Key('valueRow_Copper wire 1.5')), findsOneWidget);
      expect(find.byKey(const Key('unknownValue_LED bulb')), findsOneWidget);
    }, sample: false);

    harnessTest('Reports opens each report', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await h.pump(tester, const ReportsScreen());
      for (final (key, title) in const [
        ('reportDailySales', 'Daily sales'),
        ('reportItemProfit', 'Item profit'),
        ('reportStockValue', 'Stock value'),
      ]) {
        await tester.tap(find.byKey(Key(key)));
        await settle(tester);
        expect(find.widgetWithText(AppBar, title), findsOneWidget, reason: title);
        await tester.pageBack();
        await settle(tester);
      }
    }, sample: false);
  });
}
