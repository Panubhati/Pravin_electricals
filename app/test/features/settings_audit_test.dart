import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/audit/audit_screen.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:shop_app/features/settings/shop_details_screen.dart';
import 'package:shop_app/features/settings/staff_screen.dart';

import '../helpers/app_harness.dart';

void main() {
  group('audit: describing changes', () {
    test('only changed fields, money in rupees, noise hidden', () {
      final lines = describeChange(
        {'tier': 'retail', 'ratePaise': 4750, 'updatedAt': 1},
        {'tier': 'retail', 'ratePaise': 5000, 'updatedAt': 2},
      );
      expect(lines, ['Rate: ₹47.50 to ₹50.00']);
    });

    test('a record with only an after shows its values; camelCase becomes words', () {
      expect(describeChange(null, {'balanceBase': 8, 'reason': 'Opening stock'}),
          ['Balance: 8', 'Reason: Opening stock']);
    });

    test('booleans and missing values read plainly', () {
      expect(describeChange({'active': true}, {'active': false}), ['Active: yes to no']);
      expect(describeChange({'hsn': null}, {'hsn': '8544'}), ['Hsn: none to 8544']);
      // A field the old record did not have is just shown, not "none to ...".
      expect(describeChange({'a': 1}, {'a': 1, 'reason': 'x'}), ['Reason: x']);
    });

    test('the PIN hash is never shown', () {
      expect(describeChange({'pinHash': 'a'}, {'pinHash': 'b'}), isEmpty);
    });
  });

  group('audit repository', () {
    late AppDatabase db;
    late ShopSession s;
    late String itemId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      s = await ensureShopSession(db);
      final items = ItemRepository(s.ctx);
      itemId = await items.createItem(
          name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, units: const [ItemUnitInput('m', 1000)]);
      await items.setPrice(itemId: itemId, tier: 'retail', ratePaise: 4750, userId: s.userId);
      await items.setPrice(itemId: itemId, tier: 'retail', ratePaise: 5000, userId: s.userId);
      await StockRepository(s.ctx).adjust(
          itemId: itemId, locationId: s.locationId, deltaBase: 1000, reason: 'Found', userId: s.userId);
    });
    tearDown(() => db.close());

    test('newest first, with the user and item names filled in', () async {
      final all = await AuditRepository(s.ctx).list();
      expect(all.map((e) => e.row.action).toList(), ['stock_adjustment', 'price_change']);
      expect(all.first.userName, 'Owner');
      expect(all.first.entityName, 'Wire');
    });

    test('filters by action group and by date', () async {
      final repo = AuditRepository(s.ctx);
      final prices = await repo.list(actions: auditGroups['prices']);
      expect(prices.map((e) => e.row.action), ['price_change']);
      final today = DateTime.now();
      expect(await repo.list(from: today, to: today), hasLength(2));
      final yesterday = today.subtract(const Duration(days: 1));
      expect(await repo.list(from: yesterday, to: yesterday), isEmpty);
    });
  });

  group('settings screen', () {
    harnessTest('only the owner has a Settings tile', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const HomeScreen(), user: counter);
      expect(find.byKey(const Key('tile_settings')), findsNothing);
      await endTest(tester);
      await h.pump(tester, const HomeScreen());
      expect(find.byKey(const Key('tile_settings')), findsOneWidget);
    }, sample: false);

    harnessTest('opening cash and the counter discount limit are saved', (tester, h) async {
      final c = await h.pump(tester, const SettingsScreen());

      await tester.tap(find.byKey(const Key('settingOpeningCash')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), '2500.50');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(find.text('₹2,500.50'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingDiscount')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), '10');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(find.text('10%'), findsOneWidget);

      await db(tester, () async {
        final repo = SettingsRepository(h.session.ctx);
        expect(await repo.openingCashPaise(), 250050);
        expect(await repo.counterMaxDiscountPct(), 10);
        expect(await c.read(discountLimitProvider.future), 10);
      });
    }, sample: false);

    harnessTest('a limit outside 0 to 100 is refused and nothing changes', (tester, h) async {
      await h.pump(tester, const SettingsScreen());
      await tester.tap(find.byKey(const Key('settingDiscount')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), '150');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(find.text('Enter a whole number from 0 to 100'), findsOneWidget);
      expect(find.text('5%'), findsOneWidget);
    }, sample: false);

    harnessTest('a badly typed opening cash is refused', (tester, h) async {
      await h.pump(tester, const SettingsScreen());
      await tester.tap(find.byKey(const Key('settingOpeningCash')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), 'abc');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(find.text('Enter an amount like 5000 or 5000.50'), findsOneWidget);
    }, sample: false);

    harnessTest('Audit log opens from Settings', (tester, h) async {
      await h.pump(tester, const SettingsScreen());
      await tester.tap(find.byKey(const Key('settingAudit')));
      await settle(tester);
      expect(find.text('Nothing recorded yet'), findsOneWidget);
    }, sample: false);
  });

  group('shop details', () {
    harnessTest('saving changes the shop, is audited, and a bill would use the new name', (tester, h) async {
      final c = await h.pump(tester, const ShopDetailsScreen());
      await tester.enterText(find.byKey(const Key('shopName')), 'Pravin Electricals & Co');
      await tester.enterText(find.byKey(const Key('shopGstin')), '27aabcp1234f1z5');
      await tester.enterText(find.byKey(const Key('shopState')), '27');
      await tester.tap(find.byKey(const Key('saveShop')));
      await settle(tester);

      final shop = (await tester.runAsync(() => c.read(sessionProvider.future)))!.shop;
      expect(shop.name, 'Pravin Electricals & Co');
      expect(shop.gstin, '27AABCP1234F1Z5'); // upper-cased
      expect(shop.stateCode, '27');
      await db(tester, () async {
        final audit = await AuditRepository(h.session.ctx).list(actions: {'shop_updated'});
        expect(audit, hasLength(1));
        expect(audit.single.userName, 'Owner');
      });
    }, sample: false);

    harnessTest('a bad GSTIN or state code is refused with a plain message', (tester, h) async {
      final c = await h.pump(tester, const ShopDetailsScreen());
      await tester.enterText(find.byKey(const Key('shopGstin')), '123');
      await tester.tap(find.byKey(const Key('saveShop')));
      await settle(tester);
      expect(find.text('GSTIN must be 15 letters and digits.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('shopGstin')), '');
      await tester.enterText(find.byKey(const Key('shopState')), 'MH');
      await tester.tap(find.byKey(const Key('saveShop')));
      await settle(tester);
      expect(find.textContaining('State code must be 2 digits'), findsOneWidget);
      expect((await tester.runAsync(() => c.read(sessionProvider.future)))!.shop.name, 'Pravin Electricals');
    }, sample: false);
  });

  group('staff', () {
    harnessTest('add a counter user, who can then log in; remove them again', (tester, h) async {
      await h.pump(tester, const StaffScreen());
      await tester.tap(find.byKey(const Key('addStaff')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('staffNameField')), 'Suresh');
      await tester.enterText(find.byKey(const Key('staffPinField')), '1357');
      await tester.tap(find.byKey(const Key('staffSave')));
      await settle(tester);
      expect(find.byKey(const Key('staff_Suresh')), findsOneWidget);

      await db(tester, () async {
        final auth = AuthRepository(h.session.ctx);
        final u = (await auth.activeUsers()).firstWhere((u) => u.name == 'Suresh');
        expect(u.role, 'counter');
        expect((await auth.verify(u.id, '1357')).ok, isTrue);
      });

      await tester.tap(find.byKey(const Key('staffMenu_Suresh')));
      await settle(tester);
      await tester.tap(find.text('Remove').last);
      await settle(tester);
      await tester.tap(find.text('Remove').last); // the confirm button
      await settle(tester);
      await db(tester, () async {
        final active = await AuthRepository(h.session.ctx).activeUsers();
        expect(active.map((u) => u.name), ['Owner']);
      });
    }, sample: false);

    harnessTest('a too-short PIN and a duplicate name are refused', (tester, h) async {
      await h.addCounterUser(tester, name: 'Suresh');
      await h.pump(tester, const StaffScreen());
      await tester.tap(find.byKey(const Key('addStaff')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('staffNameField')), 'Anil');
      await tester.enterText(find.byKey(const Key('staffPinField')), '12');
      await tester.tap(find.byKey(const Key('staffSave')));
      await settle(tester);
      expect(find.text('PIN must be 4 to 6 digits.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('addStaff')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('staffNameField')), 'suresh');
      await tester.enterText(find.byKey(const Key('staffPinField')), '1357');
      await tester.tap(find.byKey(const Key('staffSave')));
      await settle(tester);
      expect(find.textContaining('already exists'), findsOneWidget);
    }, sample: false);

    harnessTest('the owner can set a staff member a new PIN', (tester, h) async {
      final counter = await h.addCounterUser(tester, name: 'Suresh');
      await h.pump(tester, const StaffScreen());
      await tester.tap(find.byKey(const Key('staffMenu_Suresh')));
      await settle(tester);
      await tester.tap(find.text('Set new PIN'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('newPinField')), '9753');
      await tester.tap(find.byKey(const Key('pinSave')));
      await settle(tester);
      await db(tester, () async {
        final auth = AuthRepository(h.session.ctx);
        expect((await auth.verify(counter.id, '9753')).ok, isTrue);
        expect((await auth.verify(counter.id, '2468')).ok, isFalse);
      });
    }, sample: false);
  });

  group('audit screen', () {
    Future<void> seed(Harness h) => h.db.transaction(() async {}).then((_) async {
          final s = h.session;
          final items = ItemRepository(s.ctx);
          final id = await items.createItem(
              name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, units: const [ItemUnitInput('m', 1000)]);
          await items.setPrice(itemId: id, tier: 'retail', ratePaise: 4750, userId: s.userId);
          await items.setPrice(itemId: id, tier: 'retail', ratePaise: 5000, userId: s.userId);
          await StockRepository(s.ctx).adjust(
              itemId: id, locationId: s.locationId, deltaBase: 1000, reason: 'Found stock', userId: s.userId);
        });

    harnessTest('shows who changed what, in plain words, and the filters work', (tester, h) async {
      await db(tester, () => seed(h));
      await h.pump(tester, const AuditScreen());

      expect(find.text('Price changed: Wire'), findsOneWidget);
      expect(find.text('Rate: ₹47.50 to ₹50.00'), findsOneWidget);
      expect(find.text('Stock adjusted: Wire'), findsOneWidget);
      expect(find.textContaining('Owner'), findsWidgets);
      expect(find.text('Reason: Found stock'), findsOneWidget);
      // Cable stock is shown in metres, not raw millimetres.
      expect(find.text('Balance: 0 m to 1 m'), findsOneWidget);

      await tester.tap(find.byKey(const Key('auditGroup_prices')));
      await settle(tester);
      expect(find.text('Price changed: Wire'), findsOneWidget);
      expect(find.text('Stock adjusted: Wire'), findsNothing);

      await tester.tap(find.byKey(const Key('auditGroup_discounts')));
      await settle(tester);
      expect(find.text('Nothing recorded yet'), findsOneWidget);
    }, sample: false);
  });
}
