import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/features/auth/lock_gate.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/billing/bill_controller.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/items/items_screen.dart';
import 'package:shop_app/features/parties/dues_screen.dart';

import '../helpers/app_harness.dart';

class _FakeDeviceAuth implements DeviceAuth {
  _FakeDeviceAuth(this.ok);
  final bool ok;
  @override
  Future<bool> confirm(String reason) async => ok;
}

Future<void> enterPin(WidgetTester tester, String pin, {bool submit = true}) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_$d')));
    await tester.pump();
  }
  if (submit) {
    await tester.tap(find.byKey(const Key('pinOk')));
    await settle(tester);
  }
}

void main() {
  group('first run and lock screen', () {
    harnessTest('a fresh install asks for an owner PIN twice, then opens the app', (tester, h) async {
      final c = await h.pumpApp(tester);
      expect(find.text('Set the owner PIN'), findsOneWidget);
      expect(find.byKey(const Key('tile_bill')), findsNothing);

      await enterPin(tester, '4821');
      expect(find.text('Enter the PIN again to confirm'), findsOneWidget);
      await enterPin(tester, '4821');

      expect(find.byKey(const Key('tile_bill')), findsOneWidget);
      expect(c.read(currentUserProvider)?.role, 'owner');
      await db(tester, () async {
        expect(await AuthRepository(h.session.ctx).ownerHasPin(), isTrue);
      });
    }, sample: false);

    harnessTest('two different PINs start again and nothing is saved', (tester, h) async {
      final c = await h.pumpApp(tester);
      await enterPin(tester, '4821');
      await enterPin(tester, '1111');
      expect(find.text('The two PINs did not match. Start again.'), findsOneWidget);
      expect(find.text('Set the owner PIN'), findsOneWidget);
      expect(c.read(currentUserProvider), isNull);
      await db(tester, () async {
        expect(await AuthRepository(h.session.ctx).ownerHasPin(), isFalse);
      });
    }, sample: false);

    harnessTest('the lock screen hides the app until the right PIN', (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
      final c = await h.pumpApp(tester);
      expect(find.text('Enter PIN'), findsOneWidget);
      expect(find.byKey(const Key('tile_bill')), findsNothing); // hidden, not just covered

      await enterPin(tester, '0000');
      expect(find.text('Wrong PIN, try again'), findsOneWidget);
      expect(c.read(currentUserProvider), isNull);

      await enterPin(tester, '4821');
      expect(find.byKey(const Key('tile_bill')), findsOneWidget);
      expect(c.read(currentUserProvider)?.role, 'owner');
    });

    harnessTest('five wrong PINs lock the user out for a while', (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
      await h.pumpApp(tester);
      for (var i = 0; i < 5; i++) {
        await enterPin(tester, '0000');
      }
      expect(find.textContaining('Too many wrong tries'), findsOneWidget);
      await enterPin(tester, '4821'); // right PIN, but still locked out
      expect(find.byKey(const Key('tile_bill')), findsNothing);
    });

    harnessTest('with staff set up, the lock screen lists them and a counter PIN opens the counter view',
        (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
      await h.addCounterUser(tester);
      final c = await h.pumpApp(tester);

      await tester.tap(find.byKey(const Key('lockUser_Suresh')));
      await tester.pump();
      await enterPin(tester, '2468');
      expect(c.read(currentUserProvider)?.role, 'counter');
      expect(find.byKey(const Key('tile_bill')), findsOneWidget);
    });

    harnessTest('Lock puts the lock screen back and returns to the home screen', (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
      final c = await h.pumpApp(tester);
      await enterPin(tester, '4821');
      await tester.tap(find.byKey(const Key('tile_items')));
      await settle(tester);
      expect(find.byType(ItemsScreen), findsOneWidget);

      await tester.pump();
      lockApp(c);
      await settle(tester);
      expect(find.text('Enter PIN'), findsOneWidget);
      await enterPin(tester, '4821');
      expect(find.byType(ItemsScreen), findsNothing); // back at home, not on the old screen
      expect(find.byKey(const Key('tile_bill')), findsOneWidget);
    });

    harnessTest('forgot PIN: needs the phone lock, then sets a new owner PIN', (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));

      // Phone lock not confirmed: nothing changes.
      final c1 = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(_FakeDeviceAuth(false))]);
      await tester.tap(find.byKey(const Key('forgotPin')));
      await settle(tester);
      expect(find.text('Could not confirm with the phone lock'), findsOneWidget);
      expect(c1.read(currentUserProvider), isNull);
    });

    harnessTest('forgot PIN with the phone lock confirmed', (tester, h) async {
      await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
      final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(_FakeDeviceAuth(true))]);
      await tester.tap(find.byKey(const Key('forgotPin')));
      await settle(tester);
      await enterPin(tester, '7777');
      await enterPin(tester, '7777');
      expect(c.read(currentUserProvider)?.role, 'owner');
      await db(tester, () async {
        final auth = AuthRepository(h.session.ctx);
        expect((await auth.verify(h.session.userId, '7777')).ok, isTrue);
        expect((await auth.verify(h.session.userId, '4821')).ok, isFalse);
      });
    });
  });

  group('counter permissions', () {
    harnessTest('the counter home has no purchases, suppliers or import', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const HomeScreen(), user: counter);
      for (final k in ['tile_bill', 'tile_items', 'tile_stock', 'tile_customers', 'tile_dues']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      for (final k in ['tile_purchases', 'tile_suppliers', 'tile_import']) {
        expect(find.byKey(Key(k)), findsNothing, reason: k);
      }
    });

    harnessTest('the owner sees every tile', (tester, h) async {
      await h.pump(tester, const HomeScreen());
      for (final k in ['tile_purchases', 'tile_suppliers', 'tile_import']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
    });

    harnessTest('the counter sees receivables only: no payables tab', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const DuesScreen(), user: counter);
      expect(find.byKey(const Key('tabPayables')), findsNothing);
      await endTest(tester);

      await h.pump(tester, const DuesScreen());
      expect(find.byKey(const Key('tabPayables')), findsOneWidget);
    });

    harnessTest('the counter cannot add items; the owner can', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const ItemsScreen(), user: counter);
      expect(find.byKey(const Key('addItem')), findsNothing);
      await endTest(tester);
      await h.pump(tester, const ItemsScreen());
      expect(find.byKey(const Key('addItem')), findsOneWidget);
    });

    harnessTest('a counter discount over the limit is blocked; within it is fine', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      final c = await h.pump(tester, const BillScreen(), user: counter);

      await tester.enterText(find.byKey(const Key('searchField')), '1.5 sqmm');
      await settle(tester);
      await tester.tap(find.byKey(const Key('result_0')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('qty_0')), '1');
      await tester.pump();

      // 1 m at Rs 47.50: Rs 10 off is 21%, over the 5% staff limit.
      await tester.enterText(find.byKey(const Key('disc_0')), '10');
      await tester.pump();
      expect(find.byKey(const Key('discountError')), findsOneWidget);
      expect(find.text('Staff can give up to 5% discount. Ask the owner.'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('payButton'))).onPressed, isNull);
      await expectLater(
        c.read(billProvider.notifier).save([]),
        throwsA(isA<DomainException>().having((e) => e.message, 'message', contains('Staff can give up'))),
      );

      // Rs 2 off is 4.2%: allowed.
      await tester.enterText(find.byKey(const Key('disc_0')), '2');
      await tester.pump();
      expect(find.byKey(const Key('discountError')), findsNothing);
      expect(tester.widget<FilledButton>(find.byKey(const Key('payButton'))).onPressed, isNotNull);
    });

    harnessTest('the owner has no discount limit', (tester, h) async {
      await h.pump(tester, const BillScreen());
      await tester.enterText(find.byKey(const Key('searchField')), '1.5 sqmm');
      await settle(tester);
      await tester.tap(find.byKey(const Key('result_0')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('qty_0')), '1');
      await tester.enterText(find.byKey(const Key('disc_0')), '10');
      await tester.pump();
      expect(find.byKey(const Key('discountError')), findsNothing);
    });

    harnessTest('what a counter user saves is stamped with their id', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      final c = await h.pump(tester, const BillScreen(), user: counter);
      expect(c.read(actingUserIdProvider), counter.id);
    });
  });
}
