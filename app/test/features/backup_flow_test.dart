import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/app.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/backup_sharer.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/import/file_service.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/home/home_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_rich_shop.dart';

class FakeSharer implements BackupSharer {
  final shared = <String>[];
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async => shared.add(file.path);
}

class FakePicker implements FileService {
  FakePicker(this.file);
  File? file;
  @override
  Future<File?> pickBackupFile() async => file;
  @override
  Future<String?> pickCsvText() async => null;
  @override
  Future<bool> saveText({required String fileName, required String content}) async => true;
}

/// Pumps until [done] (real async work: files, isolates), without pumpAndSettle.
Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 200}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_$d')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const Key('pinOk')));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('banner on the owner home', () {
    Future<void> openHome(WidgetTester tester, Harness h, {FakeSharer? sharer, dynamic user}) async {
      final dir = Directory.systemTemp.createTempSync('shop_banner_');
      addTearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold a file; the OS cleans temp.
        }
      });
      await h.pump(tester, const HomeScreen(), user: user, overrides: [
        databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(dir)),
        backupSharerProvider.overrideWithValue(sharer ?? FakeSharer()),
      ]);
    }

    harnessTest('shop data and no backup ever: the banner asks for one', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await openHome(tester, h);
      expect(find.byKey(const Key('backupBanner')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('backupBannerText'))).data, 'You have not made a backup yet.');
    }, sample: false);

    harnessTest('tapping Back up makes the backup and the banner goes away', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final sharer = FakeSharer();
      await openHome(tester, h, sharer: sharer);
      await tester.tap(find.byKey(const Key('backupBannerButton')));
      await waitUntil(tester, () => find.byKey(const Key('backupBanner')).evaluate().isEmpty);
      expect(sharer.shared, hasLength(1));
      expect(find.byKey(const Key('backupBanner')), findsNothing);
    }, sample: false);

    harnessTest('a backup 2 days ago: no banner; 5 days ago: the banner says so', (tester, h) async {
      await db(tester, () async {
        await seedRichShop(h.session);
        await SettingsRepository(h.session.ctx)
            .setLastBackupAt(DateTime.now().subtract(const Duration(days: 2)));
      });
      await openHome(tester, h);
      expect(find.byKey(const Key('backupBanner')), findsNothing);
      await endTest(tester);

      await db(tester, () => SettingsRepository(h.session.ctx)
          .setLastBackupAt(DateTime.now().subtract(const Duration(days: 5, hours: 1))));
      await openHome(tester, h);
      expect(tester.widget<Text>(find.byKey(const Key('backupBannerText'))).data, 'Your last backup was 5 days ago.');
    }, sample: false);

    harnessTest('with the reminder switched off there is no banner', (tester, h) async {
      await db(tester, () async {
        await seedRichShop(h.session);
        await SettingsRepository(h.session.ctx).set(SettingKeys.backupReminderOn, '0');
      });
      await openHome(tester, h);
      expect(find.byKey(const Key('backupBanner')), findsNothing);
    }, sample: false);

    harnessTest('a new shop with nothing in it has nothing to back up', (tester, h) async {
      await openHome(tester, h);
      expect(find.byKey(const Key('backupBanner')), findsNothing);
    }, sample: false);

    harnessTest('counter staff never see the banner', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final counter = await h.addCounterUser(tester, name: 'Anil');
      await openHome(tester, h, user: counter);
      expect(find.byKey(const Key('backupBanner')), findsNothing);
    }, sample: false);
  });

  group('the done-when path through the real app: fresh install, restore, log in', () {
    late Directory phone;
    late Directory other;

    setUp(() {
      phone = Directory.systemTemp.createTempSync('shop_fresh_phone_');
      other = Directory.systemTemp.createTempSync('shop_old_phone_');
    });
    tearDown(() {
      for (final d in [phone, other]) {
        try {
          if (d.existsSync()) d.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold a file; the OS cleans temp.
        }
      }
    });

    testWidgets('restore at the first-run screen, then the old owner PIN opens the same shop', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // The old phone: a seeded shop, owner PIN 4821, backed up.
      final file = (await tester.runAsync(() async {
        final loc = FolderDatabaseLocation(other);
        final db = AppDatabase(NativeDatabase(await loc.databaseFile()));
        final s = await ensureShopSession(db);
        await seedRichShop(s);
        final b = await BackupService(db, loc).createBackup();
        await db.close();
        return File(b.path);
      }))!;

      // The new phone: a fresh install. The app starts with no PIN set.
      await tester.pumpWidget(AppRoot(
        location: FolderDatabaseLocation(phone),
        extraOverrides: [fileServiceProvider.overrideWithValue(FakePicker(file))],
      ));
      await waitUntil(tester, () => find.text('Set the owner PIN').evaluate().isNotEmpty);
      expect(find.text('Set the owner PIN'), findsOneWidget);
      expect(find.byKey(const Key('firstRunRestore')), findsOneWidget);

      await tester.tap(find.byKey(const Key('firstRunRestore')));
      await waitUntil(tester, () => find.byKey(const Key('restoreConfirm')).evaluate().isNotEmpty);
      expect(tester.widget<Text>(find.byKey(const Key('restoreShop'))).data, 'Pravin Electricals');
      expect(tester.widget<Text>(find.byKey(const Key('restoreCounts'))).data, '3 bills, 1 customers, 3 items');
      await tester.tap(find.byKey(const Key('restoreConfirm')));

      // The app starts over on the restored data and asks for a PIN.
      await waitUntil(tester, () => find.byKey(const Key('lockUser_Owner')).evaluate().isNotEmpty);
      expect(find.text('Who is using the app?'), findsOneWidget); // two people, so choose first
      expect(find.byKey(const Key('lockUser_Suresh')), findsOneWidget); // staff came back too

      await tester.tap(find.byKey(const Key('lockUser_Owner')));
      await tester.pump();
      await enterPin(tester, '4821');
      await waitUntil(tester, () => find.byKey(const Key('tile_bill')).evaluate().isNotEmpty);

      // The same shop: today's seeded sales and what Ramesh owes.
      expect(find.byKey(const Key('tile_bill')), findsOneWidget);
      await waitUntil(tester, () => find.byKey(const Key('dashSales')).evaluate().isNotEmpty);
      expect(find.text('₹449.00'), findsOneWidget);
      await waitUntil(tester, () => find.byKey(const Key('dashTotalDue')).evaluate().isNotEmpty);
      expect(tester.widget<Text>(find.byKey(const Key('dashTotalDue'))).data, '₹70.00');
      // A restore counts as a backup made now, so no reminder.
      expect(find.byKey(const Key('backupBanner')), findsNothing);

      // Unmount so the app's database connection closes before the folder goes.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    });
  });
}
