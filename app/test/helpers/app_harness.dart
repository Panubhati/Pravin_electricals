import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/debug/sample_data.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/auth/lock_gate.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/shared/theme.dart';

/// An in-memory database with the shop set up, for widget tests.
class Harness {
  Harness(this.db, this.session);
  final AppDatabase db;
  final ShopSession session;

  /// Pumps [home] inside fresh app providers. The shop session is resolved
  /// first, as it is in the real app (the home screen waits for it).
  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget home, {
    List<Override> overrides = const [],
    User? user,
  }) async {
    // Everyone is logged in as the owner unless a test says otherwise.
    final who = user ?? (await tester.runAsync(() => ownerUser()))!;
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith((ref) => SessionUserNotifier(who)),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(sessionProvider.future));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light(), home: home),
    ));
    await settle(tester);
    return container;
  }

  /// Pumps the whole app shell (lock gate and home screen), nobody logged in.
  /// Returns the container so a test can read providers.
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db), ...overrides],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(sessionProvider.future));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        navigatorKey: appNavigatorKey,
        builder: (context, child) => LockGate(child: child ?? const SizedBox.shrink()),
        home: const HomeScreen(),
      ),
    ));
    await settle(tester);
    return container;
  }

  /// The owner account created at first run.
  Future<User> ownerUser() => (db.select(db.users)..where((t) => t.role.equals('owner'))).getSingle();

  /// Adds a counter-staff user (PIN 2468) and returns it.
  Future<User> addCounterUser(WidgetTester tester, {String name = 'Suresh'}) async {
    final id = await tester.runAsync(
        () => AuthRepository(session.ctx).createCounterUser(name: name, pin: '2468'));
    return (await tester.runAsync(
        () => (db.select(db.users)..where((t) => t.id.equals(id!))).getSingle()))!;
  }

  Future<void> close(WidgetTester tester) => tester.runAsync(db.close).then((_) {});
}

/// Creates the database (and sample data when [sample] is true).
Future<Harness> setupHarness(WidgetTester tester, {bool sample = true}) async {
  late Harness h;
  await tester.runAsync(() async {
    final db = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final session = await c.read(sessionProvider.future);
    if (sample) await SampleData.load(session.ctx, locationId: session.locationId);
    c.dispose();
    h = Harness(db, session);
  });
  // A tall screen so long forms are fully built (ListView builds lazily).
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(() => h.close(tester));
  return h;
}

/// Lets database futures and animations finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Runs [body] with real async so database calls complete, then settles.
Future<T> db<T>(WidgetTester tester, Future<T> Function() body) async {
  final r = await tester.runAsync(body);
  await settle(tester);
  return r as T;
}

/// Unmounts the screen and lets Riverpod's zero-length dispose timers run, so
/// the test does not end with a pending timer.
Future<void> endTest(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

/// A widget test with an in-memory shop database ready, cleaned up at the end.
void harnessTest(
  String description,
  Future<void> Function(WidgetTester tester, Harness h) body, {
  bool sample = true,
  bool skip = false,
}) {
  testWidgets(description, (tester) async {
    final h = await setupHarness(tester, sample: sample);
    await body(tester, h);
    await endTest(tester);
  }, skip: skip);
}
