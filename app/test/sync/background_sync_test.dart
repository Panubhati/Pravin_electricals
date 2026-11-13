import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/core/sync/pairing.dart';
import 'package:shop_app/core/sync/sync_host.dart';
import 'package:shop_app/features/sync/sync_providers.dart';

import '../features/login_roles_test.dart' show enterPin;
import '../helpers/app_harness.dart';

/// A12: sync keeps running with the app closed, and the app locks when closed.
void main() {
  test('sync starts from the container, with no screen at all', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      peerFinderProvider.overrideWithValue(null),
    ]);
    addTearDown(() async {
      await c.read(syncServiceProvider).stop();
      c.dispose();
      await db.close();
    });
    // A paired phone has a shop key.
    await c.read(sessionProvider.future);
    await SyncStore(db).ensureShopKey();

    await SyncHost(c).start();
    expect(c.read(syncServiceProvider).isRunning, isTrue);
  });

  test('a phone that is not paired does not start sync', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      peerFinderProvider.overrideWithValue(null),
    ]);
    addTearDown(() async {
      c.dispose();
      await db.close();
    });
    await SyncHost(c).start();
    expect(c.read(syncServiceProvider).isRunning, isFalse);
  });

  test('a stopped host does not start sync later', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      peerFinderProvider.overrideWithValue(null),
    ]);
    addTearDown(() async {
      c.dispose();
      await db.close();
    });
    await SyncStore(db).ensureShopKey();
    final host = SyncHost(c);
    final starting = host.start();
    host.stop(); // the app restarts before the session opened
    await starting;
    expect(c.read(syncServiceProvider).isRunning, isFalse);
  });

  harnessTest('closing the app slows sync down and keeps it running', (tester, h) async {
    await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
    await db(tester, () => SyncStore(h.db).ensureShopKey());
    final c = await h.pumpApp(tester, overrides: [peerFinderProvider.overrideWithValue(null)]);
    final sync = c.read(syncServiceProvider);
    await tester.runAsync(sync.start);
    expect(sync.pace, const Duration(seconds: 5));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(sync.isRunning, isTrue);
    expect(sync.pace, const Duration(minutes: 2));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(sync.pace, const Duration(seconds: 5));
    await tester.runAsync(sync.stop);
  });

  harnessTest('closing the app locks it at once', (tester, h) async {
    await db(tester, () => AuthRepository(h.session.ctx).setPin(h.session.userId, '4821'));
    final c = await h.pumpApp(tester, overrides: [peerFinderProvider.overrideWithValue(null)]);
    await enterPin(tester, '4821');
    expect(c.read(currentUserProvider), isNotNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
    await settle(tester);
    expect(c.read(currentUserProvider), isNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(find.text('Enter PIN'), findsOneWidget);
  });
}
