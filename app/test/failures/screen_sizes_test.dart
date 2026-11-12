import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/auth/lock_screen.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/datacheck/data_check_screen.dart';
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
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:shop_app/features/stock/stock_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_rich_shop.dart';

/// Every main screen must fit a small phone, a phone turned sideways, and large
/// text (many shop owners raise the font size). Flutter reports any text or
/// button that does not fit as an overflow error, which fails the test.
void main() {
  const sizes = <String, Size>{
    'small phone (360x640)': Size(360, 640),
    'phone sideways (640x360)': Size(640, 360),
  };
  const textScales = [1.0, 1.6];

  /// (label, screen builder given ids found in the seeded shop)
  final screens = <String, Widget Function(_Ids)>{
    'Home (owner)': (_) => const HomeScreen(),
    'New bill': (_) => const BillScreen(),
    'Bills list': (_) => const BillsScreen(),
    'Bill detail': (i) => BillDetailScreen(invoiceId: i.invoiceId),
    'Items': (_) => const ItemsScreen(),
    'Item form': (i) => ItemFormScreen(itemId: i.itemId),
    'Stock': (_) => const StockScreen(),
    'Customers': (_) => const PartiesScreen(kind: 'customer'),
    'Customer detail': (i) => PartyDetailScreen(partyId: i.partyId),
    'Dues': (_) => const DuesScreen(),
    'Purchases': (_) => const PurchasesScreen(),
    'New purchase': (_) => const PurchaseScreen(),
    'Reports': (_) => const ReportsScreen(),
    'Daily sales': (_) => const DailySalesScreen(),
    'Item profit': (_) => const ItemProfitScreen(),
    'Stock value': (_) => const StockValueScreen(),
    'Settings': (_) => const SettingsScreen(),
    'Check my data': (_) => const DataCheckScreen(),
    'Import': (_) => const ImportScreen(),
    'PIN set-up': (_) => NewPinScreen(title: 'Set the owner PIN', help: 'Choose a PIN.', onPin: (_) async {}),
  };

  for (final size in sizes.entries) {
    for (final scale in textScales) {
      for (final screen in screens.entries) {
        harnessTest('${screen.key} fits a ${size.key} at text size ${(scale * 100).round()}%', (tester, h) async {
          await tester.runAsync(() => seedRichShop(h.session));
          final ids = await tester.runAsync(() => _Ids.load(h));
          tester.view.physicalSize = size.value;
          tester.view.devicePixelRatio = 1.0;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final dir = Directory.systemTemp.createTempSync('shop_size_');
          addTearDown(() {
            try {
              dir.deleteSync(recursive: true);
            } on FileSystemException {
              // Windows may still hold a file; the OS cleans temp.
            }
          });
          await h.pump(tester, screen.value(ids!), overrides: [
            databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(dir)),
          ]);
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull, reason: '${screen.key} overflowed');
        }, sample: false);
      }
    }
  }

  // The parts that open on top: the Pay sheet is the busiest.
  for (final size in sizes.entries) {
    harnessTest('the Pay sheet fits a ${size.key} with large text', (tester, h) async {
      await tester.runAsync(() async {
        await seedRichShop(h.session);
        final items = ItemRepository(h.session.ctx);
        final sw = (await items.search('6A switch')).first.item;
        await items.setPrice(itemId: sw.id, tier: 'retail', ratePaise: 1500);
      });
      tester.view.physicalSize = size.value;
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await h.pump(tester, const BillScreen());
      await tester.enterText(find.byKey(const Key('searchField')), 'switch');
      await settle(tester);
      await tester.tap(find.byKey(const Key('result_0')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('payButton')));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'the Pay sheet overflowed');
      expect(find.text('Save bill'), findsOneWidget);
    }, sample: false);
  }
}

class _Ids {
  const _Ids(this.invoiceId, this.itemId, this.partyId);
  final String invoiceId, itemId, partyId;

  static Future<_Ids> load(Harness h) async {
    Future<String> first(String sql) async =>
        (await h.db.customSelect(sql).getSingle()).data.values.first as String;
    return _Ids(
      await first('SELECT id FROM invoices ORDER BY number LIMIT 1'),
      await first("SELECT id FROM items WHERE name = '6A switch'"),
      await first("SELECT id FROM parties WHERE name = 'Ramesh'"),
    );
  }
}
