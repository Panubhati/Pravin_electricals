import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/items/items_screen.dart';
import 'package:shop_app/features/stock/stock_item_screen.dart';
import 'package:shop_app/features/stock/stock_screen.dart';

import '../helpers/app_harness.dart';

String _text(WidgetTester t, Key key) => t.widget<Text>(find.byKey(key)).data!;

void main() {
  harnessTest('home tiles open Items and Stock', (tester, h) async {
    await h.pump(tester, const HomeScreen());

    await tester.tap(find.byKey(const Key('tile_items')));
    await settle(tester);
    expect(find.byKey(const Key('addItem')), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    await tester.tap(find.byKey(const Key('tile_stock')));
    await settle(tester);
    expect(find.byKey(const Key('stockSearch')), findsOneWidget);
  });

  harnessTest('add a cable on the form, then find and bill it', (tester, h) async {
    await h.pump(tester, const ItemsScreen());

    await tester.tap(find.byKey(const Key('addItem')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('typeLength')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('itemName')), 'Test cable');
    await tester.enterText(find.byKey(const Key('itemBrand')), 'Acme');
    await tester.enterText(find.byKey(const Key('itemPack')), '90');
    await tester.enterText(find.byKey(const Key('itemRetail')), '47.50');
    await tester.enterText(find.byKey(const Key('itemContractor')), '44');
    await tester.enterText(find.byKey(const Key('itemCost')), '30');
    await tester.enterText(find.byKey(const Key('itemMin')), '100');
    await tester.enterText(find.byKey(const Key('itemOpening')), '90');
    await tester.enterText(find.byKey(const Key('itemBarcode')), '555');
    await tester.tap(find.byKey(const Key('saveItem')));
    await settle(tester);

    // Back on the list with the new item.
    expect(find.text('Test cable'), findsOneWidget);

    await db(tester, () async {
      final repo = ItemRepository(h.session.ctx);
      final e = (await repo.listItems(query: 'Test cable')).single;
      final d = await repo.getDetail(e.item.id);
      expect(d.item.baseUnit, 'mm');
      expect(d.item.priceUnitFactor, 1000);
      expect(d.units.map((u) => '${u.unitName}=${u.factorToBase}'), ['mm=1', 'm=1000', 'roll=90000']);
      expect(d.prices, {'retail': 4750, 'contractor': 4400});
      expect(d.costPaise, 3000);
      expect(d.item.minStockBase, 100000);
      expect(await StockRepository(h.session.ctx).balance(itemId: e.item.id), 90000);
      expect((await repo.search('555')).single.item.id, e.item.id);
    });

    // The new item can be billed straight away: 1 m at Rs 47.50 -> Rs 48 after rounding.
    await h.pump(tester, const BillScreen());
    await tester.enterText(find.byKey(const Key('searchField')), 'Test cable');
    await settle(tester);
    expect(find.textContaining('Stock: 90 m'), findsOneWidget);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    expect(_text(tester, const Key('grandTotal')), '₹48.00');
  });

  harnessTest('a price edited on the item form is used by the next bill', (tester, h) async {
    late String itemId;
    await db(tester, () async {
      itemId = (await ItemRepository(h.session.ctx).listItems(query: '6A switch')).single.item.id;
    });
    await h.pump(tester, const ItemsScreen());
    await tester.tap(find.byKey(Key('item_$itemId')));
    await settle(tester);
    expect(find.text('Edit item'), findsOneWidget);
    // The unit type cannot be changed once there is stock.
    expect(find.byKey(const Key('typeLength')), findsNothing);

    await tester.enterText(find.byKey(const Key('itemRetail')), '16');
    await tester.tap(find.byKey(const Key('saveItem')));
    await settle(tester);

    await db(tester, () async {
      final repo = ItemRepository(h.session.ctx);
      expect(await repo.priceFor(itemId: itemId, tier: 'retail'), 1600);
      final audits = await h.db.select(h.db.auditLog).get();
      expect(audits.where((a) => a.action == 'price_change'), hasLength(1));
    });

    await h.pump(tester, const BillScreen());
    await tester.enterText(find.byKey(const Key('searchField')), '6A switch');
    await settle(tester);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    expect(_text(tester, const Key('grandTotal')), '₹16.00');
  });

  harnessTest('stock list shows balances and the Low and Negative filters', (tester, h) async {
    late String mcbId;
    await db(tester, () async {
      final items = ItemRepository(h.session.ctx);
      mcbId = (await items.listItems(query: 'MCB')).single.item.id;
      await items.updateItem(itemId: mcbId, name: 'MCB 32A single pole', gstRateBp: 1800, minStockBase: 50);
    });
    await h.pump(tester, const StockScreen());

    expect(find.text('450 m'), findsOneWidget); // 5 rolls of 1.5 sqmm wire
    expect(find.text('200 pcs'), findsOneWidget); // switches
    expect(find.text('40 pcs'), findsOneWidget); // MCB

    await tester.tap(find.byKey(const Key('filter_low')));
    await settle(tester);
    expect(find.text('MCB 32A single pole'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('6A switch'), findsNothing);

    await tester.tap(find.byKey(const Key('filter_negative')));
    await settle(tester);
    expect(find.text('No items to show.'), findsOneWidget);

    // Sell more than there is: the item turns negative.
    await db(tester, () => StockRepository(h.session.ctx).record(
        itemId: mcbId, locationId: h.session.locationId, qtyBase: -50, movementType: 'sale'));
    await h.pump(tester, const StockScreen());
    await tester.tap(find.byKey(const Key('filter_negative')));
    await settle(tester);
    expect(find.text('Negative stock'), findsOneWidget);
    expect(find.text('-10 pcs'), findsOneWidget);
  });

  harnessTest('adjusting and counting change the balance and the history', (tester, h) async {
    late String mcbId;
    await db(tester, () async {
      mcbId = (await ItemRepository(h.session.ctx).listItems(query: 'MCB')).single.item.id;
    });
    await h.pump(tester, StockItemScreen(itemId: mcbId));
    expect(_text(tester, const Key('stockBalance')), '40 pcs');

    // Remove 3 as damaged.
    await tester.tap(find.byKey(const Key('adjustButton')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('adjustRemove')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('adjustQty')), '3');
    await tester.enterText(find.byKey(const Key('adjustNote')), 'dropped');
    await tester.tap(find.byKey(const Key('adjustSave')));
    await settle(tester);
    expect(_text(tester, const Key('stockBalance')), '37 pcs');
    expect(find.text('Adjustment'), findsOneWidget);
    expect(find.text('-3 pcs'), findsOneWidget);
    expect(find.textContaining('Damaged or lost: dropped'), findsOneWidget);

    // A shelf count of 30 books a difference of -7.
    await tester.tap(find.byKey(const Key('countButton')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('countQty')), '30');
    await tester.pump();
    expect(_text(tester, const Key('countDiff')), 'Difference: -7 pcs');
    await tester.tap(find.byKey(const Key('countSave')));
    await settle(tester);
    expect(_text(tester, const Key('stockBalance')), '30 pcs');
    expect(find.text('Stock count'), findsOneWidget);

    await db(tester, () async {
      final audits = await h.db.select(h.db.auditLog).get();
      expect(audits.map((a) => a.action).toSet(), {'stock_adjustment', 'stock_count'});
    });
  });

  harnessTest('the bill warns when asking for more than the stock, and still saves', (tester, h) async {
    await h.pump(tester, const BillScreen());

    await tester.enterText(find.byKey(const Key('searchField')), 'MCB');
    await settle(tester);
    expect(find.textContaining('Stock: 40 pcs'), findsOneWidget);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    expect(find.byKey(const Key('stockWarning_0')), findsNothing);

    await tester.enterText(find.byKey(const Key('qty_0')), '45');
    await settle(tester);
    expect(find.byKey(const Key('stockWarning_0')), findsOneWidget);
    expect(find.text('Only 40 pcs in stock'), findsOneWidget);
    // A warning, not a block: Pay is still available.
    expect(tester.widget<FilledButton>(find.byKey(const Key('payButton'))).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('payButton')));
    await settle(tester);
    await tester.tap(find.text('Save bill'));
    await settle(tester);
    expect(find.byKey(const Key('savedInvoiceNo')), findsOneWidget);

    await db(tester, () async {
      final mcb = (await ItemRepository(h.session.ctx).listItems(query: 'MCB')).single.item.id;
      expect(await StockRepository(h.session.ctx).balance(itemId: mcb), -5);
    });
  });
}
