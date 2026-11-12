import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/notifications/daily_summary.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/settings/settings_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

class FakeNotifications implements NotificationService {
  FakeNotifications({this.allowed = true});
  bool allowed;
  final shown = <(String, String)>[];
  final kinds = <NotificationKind>[];
  int permissionAsks = 0;

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return allowed;
  }

  @override
  Future<void> show(String title, String body,
      {NotificationKind kind = NotificationKind.dailySummary}) async {
    shown.add((title, body));
    kinds.add(kind);
  }
}

class FakeScheduler implements SummaryScheduler {
  final scheduled = <int>[];
  int cancels = 0;
  @override
  Future<void> schedule(int hour) async => scheduled.add(hour);
  @override
  Future<void> cancel() async => cancels++;
}

Future<DashboardData> _dashboard(WidgetTester tester, Harness h) async {
  final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(h.db)]);
  addTearDown(c.dispose);
  return db(tester, () async {
    await c.read(sessionProvider.future);
    return c.read(reportsRepositoryProvider).dashboard();
  });
}

void main() {
  group('timing', () {
    test('delay until the next 9 PM', () {
      expect(delayUntilHour(DateTime(2026, 3, 10, 20), 21), const Duration(hours: 1));
      expect(delayUntilHour(DateTime(2026, 3, 10, 21, 30), 21), const Duration(hours: 23, minutes: 30));
      expect(delayUntilHour(DateTime(2026, 3, 10, 21), 21), const Duration(hours: 24)); // exactly now: tomorrow
      expect(delayUntilHour(DateTime(2026, 3, 10, 0, 5), 0), const Duration(hours: 23, minutes: 55));
    });
  });

  group('summary text', () {
    harnessTest('uses the same numbers as the dashboard', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final data = await _dashboard(tester, h);
      final s = DailySummary.from('Pravin Electricals', data);
      expect(s.title, 'Today at Pravin Electricals');
      expect(s.body, contains('Sales ₹449.00 (3 bills)'));
      expect(s.body, contains('Cash in hand ₹1,329.00'));
      expect(s.body, contains('Customers owe ₹70.00'));
      expect(s.body, contains('1 item needs restocking')); // the switches are below minimum
    }, sample: false);

    harnessTest('a quiet day reads cleanly: 0 bills, nothing to restock', (tester, h) async {
      final data = await _dashboard(tester, h);
      final s = DailySummary.from('Shop', data);
      expect(s.body, 'Sales ₹0.00 (0 bills)  •  Cash in hand ₹0.00  •  Customers owe ₹0.00');
    }, sample: false);
  });

  group('settings: daily summary', () {
    Future<(FakeNotifications, FakeScheduler)> open(WidgetTester tester, Harness h,
        {bool allowed = true}) async {
      final n = FakeNotifications(allowed: allowed);
      final sch = FakeScheduler();
      await h.pump(tester, const SettingsScreen(), overrides: [
        notificationServiceProvider.overrideWithValue(n),
        summarySchedulerProvider.overrideWithValue(sch),
      ]);
      return (n, sch);
    }

    harnessTest('switching on asks permission, schedules 9 PM and remembers it', (tester, h) async {
      final (n, sch) = await open(tester, h);
      await tester.tap(find.byKey(const Key('settingSummary')));
      await settle(tester);
      expect(n.permissionAsks, 1);
      expect(sch.scheduled, [21]);
      await db(tester, () async {
        expect(await SettingsRepository(h.session.ctx).dailySummaryOn(), isTrue);
      });
      expect(find.text('9 PM'), findsOneWidget);
    }, sample: false);

    harnessTest('switching off cancels the schedule', (tester, h) async {
      final (_, sch) = await open(tester, h);
      await tester.tap(find.byKey(const Key('settingSummary')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('settingSummary')));
      await settle(tester);
      expect(sch.cancels, 1);
      await db(tester, () async {
        expect(await SettingsRepository(h.session.ctx).dailySummaryOn(), isFalse);
      });
    }, sample: false);

    harnessTest('if notifications are blocked nothing is scheduled and the owner is told', (tester, h) async {
      final (_, sch) = await open(tester, h, allowed: false);
      await tester.tap(find.byKey(const Key('settingSummary')));
      await settle(tester);
      expect(sch.scheduled, isEmpty);
      expect(find.text('Allow notifications for this app in the phone settings first'), findsOneWidget);
      await db(tester, () async {
        expect(await SettingsRepository(h.session.ctx).dailySummaryOn(), isFalse);
      });
    }, sample: false);

    harnessTest('changing the time reschedules when the summary is on', (tester, h) async {
      final (_, sch) = await open(tester, h);
      await tester.tap(find.byKey(const Key('settingSummary')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('settingSummaryHour')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), '20');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(sch.scheduled, [21, 20]);
      expect(find.text('8 PM'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settingSummaryHour')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('valueField')), '24');
      await tester.tap(find.byKey(const Key('valueSave')));
      await settle(tester);
      expect(find.text('Enter a whole number from 0 to 23'), findsOneWidget);
      expect(sch.scheduled, [21, 20]); // refused, unchanged
    }, sample: false);

    harnessTest("the test button shows today's summary right now", (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final (n, _) = await open(tester, h);
      await tester.tap(find.byKey(const Key('summaryTest')));
      await settle(tester);
      expect(n.shown, hasLength(1));
      expect(n.shown.single.$1, startsWith('Today at '));
      expect(n.shown.single.$2, contains('Sales ₹449.00 (3 bills)'));
    }, sample: false);
  });
}
