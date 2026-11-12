import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/sync/device_identity.dart';
import 'package:shop_app/core/sync/pairing.dart';
import 'package:shop_app/core/sync/sync_crypto.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:shop_app/features/sync/device_choice_screen.dart';
import 'package:shop_app/features/sync/join_shop_screen.dart';
import 'package:shop_app/features/sync/phones_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/shared/strings.dart';

import '../helpers/app_harness.dart';

void main() {
  final noFinder = peerFinderProvider.overrideWithValue(null);

  harnessTest('a one-phone shop shows no sync dot on Home', (tester, h) async {
    await h.pump(tester, const HomeScreen(), overrides: [noFinder]);
    expect(find.byKey(const Key('syncDot')), findsNothing);
  });

  harnessTest('Settings opens Phones, which lists this phone as phone A', (tester, h) async {
    await h.pump(tester, const SettingsScreen(), overrides: [noFinder]);
    await tester.tap(find.byKey(const Key('settingPhones')));
    await settle(tester);
    expect(find.text(S.phonesTitle), findsOneWidget);
    expect(find.byKey(const Key('phone_A')), findsOneWidget);
    expect(find.text(S.phonesThisPhone), findsOneWidget);
    expect(find.text(S.phonesNoneYet), findsOneWidget);
    expect(find.byKey(const Key('addPhone')), findsOneWidget);
  });

  harnessTest('the owner removes phone B: it is marked removed, audited, and leaves the list', (tester, h) async {
    await tester.runAsync(() => addThisPhone(h.db, MemoryDeviceIdentity(), label: 'Counter phone'));
    await h.pump(tester, const PhonesScreen(), overrides: [noFinder]);
    expect(find.byKey(const Key('phone_B')), findsOneWidget);
    expect(find.text('Counter phone'), findsOneWidget);

    await tester.tap(find.byKey(const Key('phoneMenu_B')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('removePhone_B')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('removePhoneConfirm')));
    await settle(tester);

    expect(find.byKey(const Key('phone_B')), findsNothing);
    final b = await tester.runAsync(() => (h.db.select(h.db.devices)..where((d) => d.invoiceSeriesPrefix.equals('B'))).getSingle());
    expect(b!.deletedAt, isNotNull);
    final audit = await tester.runAsync(() => (h.db.select(h.db.auditLog)..where((a) => a.action.equals('phone_removed'))).get());
    expect(audit, hasLength(1));
  });

  harnessTest('renaming this phone shows the new name', (tester, h) async {
    await h.pump(tester, const PhonesScreen(), overrides: [noFinder]);
    await tester.tap(find.byKey(const Key('phoneMenu_A')));
    await settle(tester);
    await tester.tap(find.text(S.phonesRename));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('phoneName')), 'Owner phone');
    await tester.tap(find.text(S.save));
    await settle(tester);
    expect(find.text('Owner phone'), findsOneWidget);
  });

  harnessTest('Join a shop refuses a code that is not a shop pairing code', (tester, h) async {
    await h.pump(tester, const JoinShopScreen(), overrides: [
      noFinder,
      pairingScannerProvider.overrideWithValue((_) async => '8901234567890'),
    ]);
    await tester.tap(find.byKey(const Key('joinScan')));
    await settle(tester);
    expect(find.text(S.joinNotShopCode), findsOneWidget);
  });

  test('a pairing invite survives the trip through the QR text', () {
    final invite = PairingInvite(
      shopId: 'shop', host: '192.168.1.20', port: 47821, key: ShopKey.random(), token: 'tok', ownerDeviceId: 'dev-a');
    final back = PairingInvite.tryDecode(invite.encode())!;
    expect(back.host, '192.168.1.20');
    expect(back.port, 47821);
    expect(back.key.text, invite.key.text);
    expect(back.token, 'tok');
    expect(PairingInvite.tryDecode('upi://pay?pa=x'), isNull);
    expect(PairingInvite.tryDecode('PESHOP1:not-base64!'), isNull);
  });

  harnessTest('which-phone screen: "This is a new phone" adds phone B and remembers it', (tester, h) async {
    final identity = MemoryDeviceIdentity();
    final devices = await tester.runAsync(() => h.db.select(h.db.devices).get());
    await h.pump(tester, DeviceChoiceScreen(devices: devices!), overrides: [
      noFinder,
      deviceIdentityProvider.overrideWithValue(identity),
    ]);
    expect(find.byKey(const Key('deviceChoice_A')), findsOneWidget);
    await tester.tap(find.byKey(const Key('deviceChoiceNew')));
    await settle(tester);
    final all = await tester.runAsync(() => h.db.select(h.db.devices).get());
    final b = all!.firstWhere((d) => d.invoiceSeriesPrefix == 'B');
    expect(identity.value, b.id);
  });

  harnessTest('which-phone screen: replacing phone A asks first, then takes over series A', (tester, h) async {
    final identity = MemoryDeviceIdentity();
    final devices = await tester.runAsync(() => h.db.select(h.db.devices).get());
    await h.pump(tester, DeviceChoiceScreen(devices: devices!), overrides: [
      noFinder,
      deviceIdentityProvider.overrideWithValue(identity),
    ]);
    await tester.tap(find.byKey(const Key('deviceChoice_A')));
    await settle(tester);
    expect(find.text(S.deviceReplaceWarn('A')), findsOneWidget);
    await tester.tap(find.byKey(const Key('deviceReplaceConfirm')));
    await settle(tester);
    expect(identity.value, devices.single.id);
  });

  harnessTest('the first-run screen offers Join a shop next to Restore', (tester, h) async {
    await h.pumpApp(tester, overrides: [noFinder]);
    expect(find.byKey(const Key('firstRunRestore')), findsOneWidget);
    expect(find.byKey(const Key('firstRunJoin')), findsOneWidget);
    await tester.tap(find.byKey(const Key('firstRunJoin')));
    await settle(tester);
    expect(find.text(S.joinHelp), findsOneWidget);
  }, sample: false);
}
