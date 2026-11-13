import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/sync/background_sync.dart';
import 'package:shop_app/core/sync/pairing.dart';
import 'package:shop_app/core/sync/sync_service.dart';
import 'package:shop_app/features/sync/phones_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';

import '../helpers/app_harness.dart';

/// The phone's background service as the tests see it.
class FakeBackgroundSync implements BackgroundSyncControl {
  final calls = <String>[];
  bool running = false;
  String? text;
  bool unrestricted = true;
  VoidCallback? tick;

  @override
  set onTick(VoidCallback? f) => tick = f;
  @override
  Future<void> start(String title, String text) async {
    calls.add('start');
    running = true;
    this.text = text;
  }

  @override
  Future<void> update(String title, String text) async {
    calls.add('update');
    this.text = text;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    running = false;
  }

  @override
  Future<bool> batteryUnrestricted() async => unrestricted;
  @override
  Future<void> askBattery() async => calls.add('askBattery');
}

/// A12: the background service runs only while this phone is paired and the
/// owner has not switched it off.
void main() {
  late AppDatabase db;
  late ShopSession session;
  late SyncService sync;
  late FakeBackgroundSync control;
  late BackgroundSyncKeeper keeper;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    session = await ensureShopSession(db);
    sync = SyncService(
      db: db,
      session: session,
      makeCopy: () async => File('unused'),
      listenPort: 0,
      interval: const Duration(hours: 1),
      backgroundInterval: const Duration(hours: 1),
    );
    control = FakeBackgroundSync();
    keeper = BackgroundSyncKeeper(sync: sync, control: control, settings: SettingsRepository(session.ctx));
  });

  tearDown(() async {
    keeper.detach();
    await sync.stop();
    await db.close();
  });

  /// Pairs this phone with a second one that is not on the Wi-Fi.
  Future<void> pair() async {
    await SyncStore(db).ensureShopKey();
    final other = await SetupRepository(session.ctx).createDevice(label: 'Counter phone', invoiceSeriesPrefix: 'B');
    await SyncStore(db).upsertPeer(other, address: '127.0.0.1', port: 1);
  }

  Future<void> settleKeeper() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('one phone alone: no background service', () async {
    keeper.attach();
    await sync.start();
    await settleKeeper();
    expect(control.calls, isNot(contains('start')));
  });

  test('a paired phone starts it and shows what sync is doing', () async {
    await pair();
    keeper.attach();
    await sync.start();
    await sync.syncNow(); // the other phone is not there
    await settleKeeper();
    expect(control.running, isTrue);
    // The other phone is not there, so the note says so (not "last synced").
    expect(control.text, anyOf('Looking for the other phone', 'Sync problem'));
  });

  test('switched off on this phone: stops, and starts again when switched on', () async {
    await pair();
    keeper.attach();
    await sync.start();
    await settleKeeper();
    expect(control.running, isTrue);

    await SettingsRepository(session.ctx).setBackgroundSyncOn(false);
    await keeper.refresh();
    expect(control.running, isFalse);

    await SettingsRepository(session.ctx).setBackgroundSyncOn(true);
    await keeper.refresh();
    expect(control.running, isTrue);
  });

  test('the 2-minute check runs a sync', () async {
    await pair();
    keeper.attach();
    await sync.start();
    await settleKeeper();
    final before = (await SyncStore(db).peers()).single.lastSyncAt;
    expect(control.tick, isNotNull);
    control.tick!();
    await sync.syncNow();
    // The other phone is away, so nothing synced, but the check ran without error.
    expect((await SyncStore(db).peers()).single.lastSyncAt, before);
  });

  test('the notification text', () {
    final at = DateTime.now();
    expect(BackgroundSyncKeeper.describe(SyncStatus(state: SyncHealth.synced, lastSyncAt: at)), startsWith('Last synced today'));
    expect(BackgroundSyncKeeper.describe(const SyncStatus(state: SyncHealth.problem)), 'Sync problem');
    expect(BackgroundSyncKeeper.describe(const SyncStatus(state: SyncHealth.searching)), 'Looking for the other phone');
  });

  group('Phones screen', () {
    harnessTest('two phones: the switch is there and the battery warning offers Allow', (tester, h) async {
      final fake = FakeBackgroundSync()..unrestricted = false;
      await db2(tester, () => SetupRepository(h.session.ctx).createDevice(label: 'Counter phone', invoiceSeriesPrefix: 'B'));
      await h.pump(tester, const PhonesScreen(), overrides: [
        peerFinderProvider.overrideWithValue(null),
        backgroundSyncControlProvider.overrideWithValue(fake),
      ]);
      await tester.scrollUntilVisible(find.byKey(const Key('backgroundSyncSwitch')), 200);
      expect(find.text('Keep syncing when the app is closed'), findsOneWidget);
      expect(find.byKey(const Key('batteryLimited')), findsOneWidget);
      await tester.tap(find.byKey(const Key('batteryAllow')));
      await settle(tester);
      expect(fake.calls, contains('askBattery'));

      await tester.tap(find.byKey(const Key('backgroundSyncSwitch')));
      await settle(tester);
      expect(await tester.runAsync(() => SettingsRepository(h.session.ctx).backgroundSyncOn()), isFalse);
      expect(find.byKey(const Key('batteryLimited')), findsNothing);
    });

    harnessTest('one phone: no switch', (tester, h) async {
      await h.pump(tester, const PhonesScreen(), overrides: [
        peerFinderProvider.overrideWithValue(null),
        backgroundSyncControlProvider.overrideWithValue(FakeBackgroundSync()),
      ]);
      expect(find.byKey(const Key('backgroundSyncSwitch')), findsNothing);
    });
  });
}

Future<T> db2<T>(WidgetTester tester, Future<T> Function() body) async => (await tester.runAsync(body)) as T;
