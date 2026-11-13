import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/auth/fingerprint_login.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/features/auth/fingerprint_screen.dart';

import '../helpers/app_harness.dart';
import 'login_roles_test.dart' show enterPin;

/// The phone's fingerprint sensor as the tests see it.
class FakeFingerprint implements DeviceAuth {
  FakeFingerprint({this.saved = true, this.matches = true});
  bool saved;
  bool matches;
  int asked = 0;

  @override
  Future<bool> confirm(String reason) async => false;
  @override
  Future<bool> canUseFingerprint() async => saved;
  @override
  Future<bool> fingerprint(String reason) async {
    asked++;
    return saved && matches;
  }
}

/// A12: fingerprint unlock, per person and per phone, tied to the person's PIN.
void main() {
  FingerprintLogin fpOf(Harness h) => FingerprintLogin(SettingsRepository(h.session.ctx));

  harnessTest('switched on, then off, and a changed PIN switches it off', (tester, h) async {
    await db(tester, () async {
      final auth = AuthRepository(h.session.ctx);
      await auth.setPin(h.session.userId, '4821');
      final fp = fpOf(h);
      var owner = await auth.getUser(h.session.userId);
      expect(await fp.isOn(owner), isFalse);
      await fp.setOn(owner, true);
      expect(await fp.isOn(owner), isTrue);

      // A new PIN (here or on the other phone): fingerprint must be switched on again.
      await auth.setPin(h.session.userId, '1357');
      owner = await auth.getUser(h.session.userId);
      expect(await fp.isOn(owner), isFalse);

      await fp.setOn(owner, true);
      await fp.setOn(owner, false);
      expect(await fp.isOn(owner), isFalse);
    });
  });

  harnessTest('the lock screen opens with a fingerprint, without the PIN', (tester, h) async {
    await db(tester, () async {
      final auth = AuthRepository(h.session.ctx);
      await auth.setPin(h.session.userId, '4821');
      await fpOf(h).setOn(await auth.getUser(h.session.userId), true);
    });
    final sensor = FakeFingerprint();
    final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(sensor)]);
    await settle(tester);
    expect(sensor.asked, 1); // opened by itself
    expect(c.read(currentUserProvider)?.role, 'owner');
  });

  harnessTest('a finger that does not match leaves the PIN, which still works', (tester, h) async {
    await db(tester, () async {
      final auth = AuthRepository(h.session.ctx);
      await auth.setPin(h.session.userId, '4821');
      await fpOf(h).setOn(await auth.getUser(h.session.userId), true);
    });
    final sensor = FakeFingerprint(matches: false);
    final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(sensor)]);
    await settle(tester);
    expect(c.read(currentUserProvider), isNull);
    expect(find.textContaining('Fingerprint not used'), findsOneWidget);

    // The button tries again.
    sensor.matches = true;
    await tester.tap(find.byKey(const Key('fingerprintLogin')));
    await settle(tester);
    expect(c.read(currentUserProvider), isNotNull);
  });

  harnessTest('fingerprint is per person: another person on the phone still types a PIN', (tester, h) async {
    final suresh = await h.addCounterUser(tester);
    await db(tester, () async {
      final auth = AuthRepository(h.session.ctx);
      await auth.setPin(h.session.userId, '4821');
      await fpOf(h).setOn(await auth.getUser(h.session.userId), true);
      await fpOf(h).markOffered(suresh); // already asked once
    });
    final sensor = FakeFingerprint();
    final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(sensor)]);
    await tester.tap(find.byKey(const Key('lockUser_Suresh')));
    await settle(tester);
    expect(sensor.asked, 0);
    expect(find.byKey(const Key('fingerprintLogin')), findsNothing);
    await enterPin(tester, '2468');
    expect(c.read(currentUserProvider)?.name, 'Suresh');
  });

  harnessTest('after a PIN login it asks once whether to use a fingerprint next time', (tester, h) async {
    await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
    final sensor = FakeFingerprint();
    final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(sensor)]);
    await enterPin(tester, '4821');
    expect(find.text('Unlock with fingerprint next time?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('fingerprintYes')));
    await settle(tester);
    expect(c.read(currentUserProvider), isNotNull);
    expect(sensor.asked, 1); // the finger is checked once when switching on
    final on = await tester.runAsync(() async =>
        fpOf(h).isOn(await AuthRepository(h.session.ctx).getUser(h.session.userId)));
    expect(on, isTrue);
  });

  harnessTest('"Not now" is not asked again, and a phone with no finger saved never asks', (tester, h) async {
    await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
    final c = await h.pumpApp(tester, overrides: [deviceAuthProvider.overrideWithValue(FakeFingerprint(saved: false))]);
    await enterPin(tester, '4821');
    expect(find.text('Unlock with fingerprint next time?'), findsNothing);
    expect(c.read(currentUserProvider), isNotNull);

    final owner = (await tester.runAsync(() => AuthRepository(h.session.ctx).getUser(h.session.userId)))!;
    expect(await tester.runAsync(() => fpOf(h).wasOffered(owner)), isFalse);
  });

  harnessTest('Settings: switching someone on needs their PIN and finger', (tester, h) async {
    await h.addCounterUser(tester);
    final sensor = FakeFingerprint();
    await h.pump(tester, const FingerprintScreen(), overrides: [deviceAuthProvider.overrideWithValue(sensor)]);
    await tester.tap(find.byKey(const Key('fingerprint_Suresh')));
    await settle(tester);
    expect(find.text("Enter Suresh's PIN"), findsOneWidget);
    await enterPin(tester, '1111');
    expect(find.text('Wrong PIN, try again'), findsOneWidget);
    await enterPin(tester, '2468');
    expect(sensor.asked, 1);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('fingerprint_Suresh'))).value, isTrue);

    // Off needs nothing.
    await tester.tap(find.byKey(const Key('fingerprint_Suresh')));
    await settle(tester);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('fingerprint_Suresh'))).value, isFalse);
  });

  harnessTest('Settings on a phone with no finger saved explains it', (tester, h) async {
    await h.pump(tester, const FingerprintScreen(),
        overrides: [deviceAuthProvider.overrideWithValue(FakeFingerprint(saved: false))]);
    expect(find.byKey(const Key('fingerprintNone')), findsOneWidget);
  });
}
