import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/features/auth/lock_screen.dart';
import 'package:shop_app/features/backup/backup_screen.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/datacheck/data_check_screen.dart';
import 'package:shop_app/features/dayclose/day_check_screen.dart';
import 'package:shop_app/features/dayclose/stock_spot_check_screen.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/import/import_screen.dart';
import 'package:shop_app/features/items/item_form_screen.dart';
import 'package:shop_app/features/items/items_screen.dart';
import 'package:shop_app/features/parties/dues_screen.dart';
import 'package:shop_app/features/parties/parties_screen.dart';
import 'package:shop_app/features/parties/party_detail_screen.dart';
import 'package:shop_app/features/purchase/purchase_screen.dart';
import 'package:shop_app/features/purchase/purchases_screen.dart';
import 'package:shop_app/features/reports/reports_screens.dart';
import 'package:shop_app/features/returns/return_screens.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:shop_app/features/settings/shop_details_screen.dart';
import 'package:shop_app/features/settings/staff_screen.dart';
import 'package:shop_app/features/stock/stock_screen.dart';
import 'package:shop_app/features/sync/join_shop_screen.dart';
import 'package:shop_app/features/sync/phones_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';
import 'package:shop_app/features/audit/audit_screen.dart';
import 'package:shop_app/shared/theme.dart';

import '../helpers/app_harness.dart';

/// UI audit: every screen drawn at the owner's phone size (384 x 832 dp) with
/// a copy of real shop data, saved to build/audit/. Overflows are listed.
///   AUDIT_DB=path/to/copy/of/shop.sqlite flutter test test/design/audit_shots_test.dart
void main() {
  final dbPath = Platform.environment['AUDIT_DB'];
  final tall = Platform.environment['AUDIT_TALL'] != null;

  Future<void> loadFonts() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(File('C:/src/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b)));
    await icons.load();
    final loader = FontLoader(AppTheme.fontFamily)
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    await loader.load();
  }

  final problems = <String>[];
  tearDownAll(() {
    // ignore: avoid_print
    print('AUDIT PROBLEMS:\n${problems.isEmpty ? 'none' : problems.join('\n')}');
  });

  Future<Harness> open(WidgetTester tester) async {
    late Harness h;
    await tester.runAsync(() async {
      await loadFonts();
      final copy = File('${Directory.systemTemp.createTempSync('audit_').path}/shop.sqlite');
      await File(dbPath!).copy(copy.path);
      final db = AppDatabase(NativeDatabase(copy));
      h = Harness(db, await ensureShopSession(db));
    });
    tester.view.physicalSize = Size(384 * 2.8125, (tall ? 1900 : 832) * 2.8125);
    tester.view.devicePixelRatio = 2.8125;
    addTearDown(tester.view.reset);
    return h;
  }

  Future<String> one(Harness h, WidgetTester tester, String sql) async =>
      (await tester.runAsync(() => h.db.customSelect(sql).getSingle()))!.data.values.first as String;

  void shot(String name, Future<Widget> Function(WidgetTester, Harness) build,
      {Future<void> Function(WidgetTester)? act, bool counter = false}) {
    testWidgets(name, (tester) async {
      final h = await open(tester);
      final screen = await build(tester, h);
      final who = counter ? await h.addCounterUser(tester) : null;
      FlutterError.onError = (d) {
        final m = d.exceptionAsString();
        problems.add('$name: ${m.split('\n').first}');
        if (!m.contains('overflowed')) {
          // ignore: avoid_print
          print('ERROR in $name: $m\n${d.stack.toString().split('\n').take(12).join('\n')}');
        }
      };
      await h.pump(tester, RepaintBoundary(key: const Key('shot'), child: screen),
          user: who, overrides: [peerFinderProvider.overrideWithValue(null)]);
      await tester.pump(const Duration(milliseconds: 600));
      if (act != null) await act(tester);
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.4);
        return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      });
      File('build/audit/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!);
      FlutterError.onError = FlutterError.presentError;
      await endTest(tester);
      await h.close(tester);
    }, skip: dbPath == null);
  }

  Widget w(Widget x) => x;
  Future<Widget> s(Widget x) async => x;

  shot('01_home_owner', (t, h) => s(const HomeScreen()));
  shot('02_home_counter', (t, h) => s(const HomeScreen()), counter: true);
  shot('03_bill_empty', (t, h) => s(const BillScreen()));
  shot('04_bill_cart', (t, h) => s(const BillScreen()), act: (t) async {
    for (final q in ['copper wire', 'switch', 'mcb']) {
      await t.enterText(find.byKey(const Key('searchField')), q);
      await settle(t);
      if (find.byKey(const Key('result_0')).evaluate().isEmpty) continue;
      await t.tap(find.byKey(const Key('result_0')));
      await settle(t);
    }
  });
  shot('05_pay_sheet', (t, h) => s(const BillScreen()), act: (t) async {
    await t.enterText(find.byKey(const Key('searchField')), 'copper wire');
    await settle(t);
    await t.tap(find.byKey(const Key('result_0')));
    await settle(t);
    await t.tap(find.byKey(const Key('payButton')));
    await settle(t);
  });
  shot('06_bills', (t, h) => s(const BillsScreen()));
  shot('07_bill_detail', (t, h) async => BillDetailScreen(
      invoiceId: await one(h, t, "SELECT id FROM invoices WHERE party_id IS NOT NULL ORDER BY total_paise DESC LIMIT 1")));
  shot('08_return', (t, h) async => ReturnScreen(
      invoiceId: await one(h, t, "SELECT id FROM invoices WHERE status = 'posted' AND party_id IS NOT NULL ORDER BY total_paise DESC LIMIT 1")));
  shot('09_items', (t, h) => s(const ItemsScreen()));
  shot('10_item_new', (t, h) => s(const ItemFormScreen()));
  shot('11_item_edit', (t, h) async =>
      ItemFormScreen(itemId: await one(h, t, "SELECT id FROM items ORDER BY length(name) DESC LIMIT 1")));
  shot('12_stock', (t, h) => s(const StockScreen()));
  shot('13_customers', (t, h) => s(const PartiesScreen(kind: 'customer')));
  shot('14_suppliers', (t, h) => s(const PartiesScreen(kind: 'supplier')));
  shot('15_customer_detail', (t, h) async => PartyDetailScreen(
      partyId: await one(h, t,
          "SELECT party_id FROM ledger_entries GROUP BY party_id ORDER BY SUM(amount_paise) DESC LIMIT 1")));
  shot('16_dues', (t, h) => s(const DuesScreen()));
  shot('17_purchases', (t, h) => s(const PurchasesScreen()));
  shot('18_purchase_new', (t, h) => s(const PurchaseScreen()));
  shot('19_purchase_detail', (t, h) async =>
      PurchaseDetailScreen(purchaseId: await one(h, t, 'SELECT id FROM purchases ORDER BY total_paise DESC LIMIT 1')));
  shot('20_reports', (t, h) => s(const ReportsScreen()));
  shot('21_daily_sales', (t, h) => s(const DailySalesScreen()));
  shot('22_item_profit', (t, h) => s(const ItemProfitScreen()));
  shot('23_stock_value', (t, h) => s(const StockValueScreen()));
  shot('24_day_check', (t, h) => s(const DayCheckScreen()));
  shot('25_spot_check', (t, h) => s(const StockSpotCheckScreen()));
  shot('26_settings', (t, h) => s(const SettingsScreen()));
  shot('27_shop_details', (t, h) => s(const ShopDetailsScreen()));
  shot('28_staff', (t, h) => s(const StaffScreen()));
  shot('29_backup', (t, h) => s(const BackupScreen()));
  shot('30_alerts', (t, h) => s(const AlertsScreen()));
  shot('31_data_check', (t, h) => s(const DataCheckScreen()));
  shot('32_audit', (t, h) => s(const AuditScreen()));
  shot('33_import', (t, h) => s(const ImportScreen()));
  shot('34_phones', (t, h) => s(const PhonesScreen()));
  shot('35_join', (t, h) => s(const JoinShopScreen()));
  shot('36_lock_pin', (t, h) =>
      s(NewPinScreen(title: 'Set the owner PIN', help: 'Choose a 4 to 6 digit PIN.', onPin: (_) async {})));
  w(const SizedBox());
}
