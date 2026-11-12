import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/debug/demo_shop.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/speed/speed_screen.dart';

import '../helpers/app_harness.dart';

/// A small fake shop, so the screen test stays quick.
const _small = DemoShopConfig(items: 60, customers: 12, suppliers: 3, days: 3, billsPerDay: 8);

Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 400}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _text(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('shop_speed_'));
  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  Future<void> open(WidgetTester tester, Harness h) => h.pump(tester, const SpeedScreen(config: _small), overrides: [
        databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(dir)),
      ]);

  harnessTest('loading is refused until a backup was made in the last hour', (tester, h) async {
    await open(tester, h);
    await tester.tap(find.byKey(const Key('speedLoad')));
    await waitUntil(tester, () => find.byKey(const Key('speedStatus')).evaluate().isNotEmpty);
    expect(_text(tester, 'speedStatus'), contains('Make a backup first'));
    await db(tester, () async {
      expect((await h.db.select(h.db.items).get()), isEmpty); // nothing was added
    });
  }, sample: false);

  harnessTest('an old backup does not count', (tester, h) async {
    await db(tester, () => SettingsRepository(h.session.ctx)
        .setLastBackupAt(DateTime.now().subtract(const Duration(hours: 3))));
    await open(tester, h);
    await tester.tap(find.byKey(const Key('speedLoad')));
    await waitUntil(tester, () => find.byKey(const Key('speedStatus')).evaluate().isNotEmpty);
    expect(_text(tester, 'speedStatus'), contains('Make a backup first'));
  }, sample: false);

  harnessTest('after a recent backup and a confirmation the demo shop loads, then the speed check runs', (tester, h) async {
    await db(tester, () => SettingsRepository(h.session.ctx).setLastBackupAt(DateTime.now()));
    await open(tester, h);
    expect(_text(tester, 'speedSize'), contains('0 items'));

    await tester.tap(find.byKey(const Key('speedLoad')));
    await waitUntil(tester, () => find.textContaining('adds hundreds of fake').evaluate().isNotEmpty);
    await tester.tap(find.text('Load demo shop'));
    await waitUntil(tester, () => find.byKey(const Key('speedStatus')).evaluate().isNotEmpty &&
        _text(tester, 'speedStatus').startsWith('Demo shop loaded'));
    expect(_text(tester, 'speedStatus'), contains('60 items, 12 customers'));
    expect(_text(tester, 'speedSize'), contains('60 items'));

    await tester.tap(find.byKey(const Key('speedRun')));
    await waitUntil(tester, () => find.byKey(const Key('speed_Check my data')).evaluate().isNotEmpty);
    for (final name in ['Item search (words)', 'Items screen', 'Home summary', 'Save one bill', 'Check my data', 'Make a backup']) {
      expect(find.byKey(Key('speed_$name')), findsOneWidget, reason: name);
    }
    expect(find.textContaining('restore your backup'), findsNothing); // only after results...
    expect(find.textContaining('Restore from a backup'), findsOneWidget);
  }, sample: false);

  harnessTest('cancelling the warning adds nothing', (tester, h) async {
    await db(tester, () => SettingsRepository(h.session.ctx).setLastBackupAt(DateTime.now()));
    await open(tester, h);
    await tester.tap(find.byKey(const Key('speedLoad')));
    await waitUntil(tester, () => find.text('Cancel').evaluate().isNotEmpty);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    await db(tester, () async {
      expect((await h.db.select(h.db.items).get()), isEmpty);
    });
  }, sample: false);
}
