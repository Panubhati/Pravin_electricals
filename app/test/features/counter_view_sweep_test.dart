import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/features/home/home_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

/// Everything a person can read on the current screen: text, field labels and
/// hints, tooltips.
List<String> visibleText(WidgetTester tester) {
  final out = <String>[];
  for (final w in tester.widgetList(find.byType(Text))) {
    final t = w as Text;
    final s = t.data ?? t.textSpan?.toPlainText();
    if (s != null && s.isNotEmpty) out.add(s);
  }
  for (final w in tester.widgetList(find.byType(TextField))) {
    final d = (w as TextField).decoration;
    for (final s in [d?.labelText, d?.hintText, d?.helperText, d?.prefixText, d?.suffixText]) {
      if (s != null && s.isNotEmpty) out.add(s);
    }
  }
  for (final w in tester.widgetList(find.byType(IconButton))) {
    final m = (w as IconButton).tooltip;
    if (m != null) out.add(m);
  }
  return out;
}

/// Words and amounts a counter must never see (plan section 2, rule 10: no cost
/// price or profit anywhere). The current costs are set to Rs 31.75/m wire and
/// Rs 9.25 per switch (amounts that appear nowhere else); the selling prices
/// are Rs 47.50 and Rs 15.00.
final _forbidden = <Pattern>[
  RegExp(r'cost', caseSensitive: false),
  RegExp(r'profit', caseSensitive: false),
  RegExp(r'margin', caseSensitive: false),
  RegExp(r'stock value', caseSensitive: false),
  RegExp(r'purchase', caseSensitive: false),
  RegExp(r'supplier', caseSensitive: false),
  RegExp(r'payable', caseSensitive: false),
  '31.75',
  '9.25',
];

void expectClean(WidgetTester tester, String where) {
  final text = visibleText(tester);
  for (final p in _forbidden) {
    final hits = [for (final t in text) if (t.contains(p)) t];
    expect(hits, isEmpty, reason: '$where shows "$p": $hits');
  }
}


Future<void> db0(Harness h) async {
  await seedToday(h.session);
  final items = ItemRepository(h.session.ctx);
  for (final (name, rate) in const [('Copper wire 1.5', 4750), ('6A switch', 1500), ('LED bulb', 9000)]) {
    final found = (await items.search(name)).first.item;
    await items.setPrice(itemId: found.id, tier: 'retail', ratePaise: rate);
  }
  await items.setCost(itemId: (await items.search('Copper wire')).first.item.id, costPaise: 3175);
  await items.setCost(itemId: (await items.search('6A switch')).first.item.id, costPaise: 925);
}

void main() {
  harnessTest('a counter sees no cost, profit or supplier information on any screen', (tester, h) async {
    await db(tester, () => db0(h));
    final counter = await h.addCounterUser(tester);
    await h.pump(tester, const HomeScreen(), user: counter);

    Future<void> visit(String tile, String name, {Future<void> Function()? inside}) async {
      await tester.tap(find.byKey(Key(tile)));
      await settle(tester);
      expectClean(tester, name);
      if (inside != null) await inside();
      await tester.pageBack();
      await settle(tester);
    }

    expectClean(tester, 'home');
    expect(find.byKey(const Key('dashSales')), findsNothing);

    await visit('tile_bill', 'bill', inside: () async {
      await tester.enterText(find.byKey(const Key('searchField')), 'wire');
      await settle(tester);
      expectClean(tester, 'bill search results');
      await tester.tap(find.byKey(const Key('result_0')));
      await settle(tester);
      expectClean(tester, 'bill with an item');
    });

    await visit('tile_items', 'items list', inside: () async {
      final tile = find.byWidgetPredicate((w) => w.key.toString().startsWith("[<'item_"));
      expect(tile, findsWidgets);
      await tester.tap(tile.first);
      await settle(tester);
      expectClean(tester, 'item form');
      expect(find.byType(TextField), findsWidgets);
      await tester.pageBack();
      await settle(tester);
    });

    await visit('tile_stock', 'stock list', inside: () async {
      final tile = find.byWidgetPredicate((w) => w.key.toString().startsWith("[<'stock_"));
      expect(tile, findsWidgets);
      await tester.tap(tile.first);
      await settle(tester);
      expectClean(tester, 'stock item');
      await tester.pageBack();
      await settle(tester);
    });

    await visit('tile_customers', 'customers', inside: () async {
      await tester.tap(find.text('Ramesh'));
      await settle(tester);
      expectClean(tester, 'customer detail');
      await tester.pageBack();
      await settle(tester);
    });

    await visit('tile_dues', 'dues');
  }, sample: false);

  harnessTest('the same screens do show cost to the owner (so the sweep is meaningful)', (tester, h) async {
    await db(tester, () => db0(h));
    await h.pump(tester, const HomeScreen());
    await tester.tap(find.byKey(const Key('tile_items')));
    await settle(tester);
    final tile = find.byWidgetPredicate((w) => w.key.toString().startsWith("[<'item_"));
    await tester.tap(tile.first);
    await settle(tester);
    expect(visibleText(tester).any((t) => t.toLowerCase().contains('cost')), isTrue);
  }, sample: false);

  harnessTest('an item form saved by the owner keeps its cost when a counter views and saves nothing else',
      (tester, h) async {
    // The counter cannot edit prices or add items, so the cost row is untouched.
    await db(tester, () => db0(h));
    final counter = await h.addCounterUser(tester);
    await h.pump(tester, const HomeScreen(), user: counter);
    await tester.tap(find.byKey(const Key('tile_items')));
    await settle(tester);
    expect(find.byKey(const Key('addItem')), findsNothing);
    await db(tester, () async {
      final Item wire = (await ItemRepository(h.session.ctx).search('Copper wire')).first.item;
      expect(await ItemRepository(h.session.ctx).latestCost(wire.id), 3175);
    });
  }, sample: false);
}
