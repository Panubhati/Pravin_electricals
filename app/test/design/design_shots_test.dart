import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/features/auth/lock_screen.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/dayclose/day_check_screen.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/items/items_screen.dart';
import 'package:shop_app/features/parties/dues_screen.dart';
import 'package:shop_app/features/parties/parties_screen.dart';
import 'package:shop_app/features/reports/reports_screens.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:shop_app/features/stock/stock_screen.dart';
import 'package:shop_app/shared/theme.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

/// Takes pictures of screens with the real theme and font so the design can be
/// looked at without a phone. Only runs when asked: `SHOTS=1 flutter test test/design`.
/// Pictures go to build/shots/.
void main() {
  final enabled = Platform.environment.containsKey('SHOTS');

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

  Future<void> shot(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shotBoundary')));
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    final file = File('build/shots/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!);
  }

  /// A fresh shop (today's seeded sales, prices on the items) shown in a phone-sized frame.
  Future<void> phone(WidgetTester tester, Harness h, Widget screen) async {
    await tester.runAsync(loadFonts);
    await tester.runAsync(() async {
      await seedToday(h.session);
      final items = ItemRepository(h.session.ctx);
      for (final (name, rate) in const [('Copper wire 1.5', 4750), ('6A switch', 1500), ('LED bulb', 9000)]) {
        final found = (await items.search(name)).first.item;
        await items.setPrice(itemId: found.id, tier: 'retail', ratePaise: rate);
      }
    });
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 3;
    await h.pump(tester, RepaintBoundary(key: const Key('shotBoundary'), child: screen));
    await tester.pump(const Duration(milliseconds: 700));
  }

  void screen(String name, Widget Function() build, {Future<void> Function(WidgetTester)? act}) {
    harnessTest(name, (tester, h) async {
      await phone(tester, h, build());
      if (act != null) await act(tester);
      await shot(tester, name);
    }, sample: false, skip: !enabled);
  }

  Future<void> addToCart(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('searchField')), 'switch');
    await settle(tester);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('qty_0')), '2');
    await tester.enterText(find.byKey(const Key('searchField')), 'wire');
    await settle(tester);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
  }

  screen('home_owner', () => const HomeScreen());
  screen('bill_empty', () => const BillScreen());
  screen('bill_cart', () => const BillScreen(), act: addToCart);
  screen('pay_sheet', () => const BillScreen(), act: (t) async {
    await addToCart(t);
    await t.tap(find.byKey(const Key('payButton')));
    await settle(t);
  });
  screen('items', () => const ItemsScreen());
  screen('stock', () => const StockScreen());
  screen('customers', () => const PartiesScreen(kind: 'customer'));
  screen('dues', () => const DuesScreen());
  screen('bills', () => const BillsScreen());
  screen('reports', () => const ReportsScreen());
  screen('day_check', () => const DayCheckScreen());
  screen('settings', () => const SettingsScreen());
  screen('lock_pin', () => NewPinScreen(title: 'Set the owner PIN', help: 'Choose a 4 to 6 digit PIN.', onPin: (_) async {}));
}
