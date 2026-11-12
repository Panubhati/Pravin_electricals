import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/backup_sharer.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/import/file_service.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/datacheck/data_check_screen.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/backup/backup_screen.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import '../helpers/app_harness.dart';
import '../helpers/seed_rich_shop.dart';

class FakeSharer implements BackupSharer {
  final shared = <File>[];
  final texts = <String>[];
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    shared.add(file);
    if (file.path.endsWith('.txt')) texts.add(file.readAsStringSync());
  }
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

Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 100}) async {
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
  late Directory work;

  setUp(() => work = Directory.systemTemp.createTempSync('shop_check_'));
  tearDown(() {
    try {
      if (work.existsSync()) work.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  Future<FakeSharer> open(WidgetTester tester, Harness h, Widget home, {dynamic user, File? pick}) async {
    final sharer = FakeSharer();
    await h.pump(tester, home, user: user, overrides: [
      databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(work)),
      backupSharerProvider.overrideWithValue(sharer),
      fileServiceProvider.overrideWithValue(FakePicker(pick)),
      appRestartProvider.overrideWithValue((_) {}),
    ]);
    return sharer;
  }

  Future<void> corrupt(Harness h) => db0(h, "UPDATE invoices SET total_paise = total_paise + 100 WHERE invoice_no_text = 'A-0001'");

  group('the screen', () {
    harnessTest('a healthy shop: all numbers agree, with what was checked', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await open(tester, h, const DataCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dataCheckHeadline')).evaluate().isNotEmpty);
      expect(_text(tester, 'dataCheckHeadline'), 'All your numbers agree');
      expect(_text(tester, 'dataCheckScope'), startsWith('22 checks over '));
      expect(find.text('Problems'), findsNothing);
    }, sample: false);

    harnessTest('a problem is listed in plain words, opens the bill, and can be shared', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await db(tester, () => corrupt(h));
      final sharer = await open(tester, h, const DataCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dataCheckHeadline')).evaluate().isNotEmpty);
      expect(_text(tester, 'dataCheckHeadline'), startsWith('Found '));
      expect(find.byKey(const Key('issue_invoice_total')), findsOneWidget);
      expect(find.textContaining('Bill A-0001: the total is'), findsOneWidget);
      expect(find.textContaining('Do not change anything yet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dataCheckShare')));
      await waitUntil(tester, () => sharer.texts.isNotEmpty);
      expect(sharer.texts.single, contains('Data check for Pravin Electricals'));
      expect(sharer.texts.single, contains('PROBLEM: Bill A-0001'));

      await tester.tap(find.byKey(const Key('issue_invoice_total')));
      await waitUntil(tester, () => find.byKey(const Key('detailInvoiceNo')).evaluate().isNotEmpty);
      expect(_text(tester, 'detailInvoiceNo'), 'A-0001');
    }, sample: false);

    harnessTest('Check again re-runs and sees a fix', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await db(tester, () => corrupt(h));
      await open(tester, h, const DataCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dataCheckHeadline')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('issue_invoice_total')), findsOneWidget);

      await db(tester, () => db0(h, "UPDATE invoices SET total_paise = total_paise - 100 WHERE invoice_no_text = 'A-0001'"));
      await tester.tap(find.byKey(const Key('dataCheckAgain')));
      await waitUntil(tester, () => find.byKey(const Key('issue_invoice_total')).evaluate().isEmpty);
      expect(_text(tester, 'dataCheckHeadline'), 'All your numbers agree');
    }, sample: false);
  });

  group('Settings and Home remember the result', () {
    harnessTest('Settings says never run, then shows the result; the owner home shows a note only when it failed', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await open(tester, h, const SettingsScreen());
      expect(_text(tester, 'dataCheckSubtitle'), startsWith('Never run'));

      await tester.tap(find.byKey(const Key('settingDataCheck')));
      await waitUntil(tester, () => find.byKey(const Key('dataCheckHeadline')).evaluate().isNotEmpty);
      await tester.pageBack();
      await waitUntil(tester, () => _text(tester, 'dataCheckSubtitle').startsWith('All numbers agree'));
      expect(_text(tester, 'dataCheckSubtitle'), startsWith('All numbers agree'));
    }, sample: false);

    harnessTest('a failed check puts a note on the owner home, not on a healthy one', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await open(tester, h, const HomeScreen());
      expect(find.byKey(const Key('dataCheckNote')), findsNothing);
      await endTest(tester);

      await db(tester, () => corrupt(h));
      await db(tester, () async {
        final r = await h.session.ctx.db.customSelect('SELECT 1').get();
        expect(r, isNotEmpty);
      });
      // Run the check the way the Settings screen does, then open Home.
      await open(tester, h, const DataCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dataCheckHeadline')).evaluate().isNotEmpty);
      await endTest(tester);
      await open(tester, h, const HomeScreen());
      await waitUntil(tester, () => find.byKey(const Key('dataCheckNote')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('dataCheckNote')), findsOneWidget);
      expect(find.textContaining('Found 2 problems'), findsWidgets);
    }, sample: false);

    harnessTest('counter staff never see the note', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final counter = await h.addCounterUser(tester, name: 'Anil');
      await open(tester, h, const HomeScreen(), user: counter);
      expect(find.byKey(const Key('dataCheckNote')), findsNothing);
    }, sample: false);
  });

  group('before a backup', () {
    harnessTest('healthy data: the backup goes ahead with no question', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final sharer = await open(tester, h, const BackupScreen());
      await tester.tap(find.byKey(const Key('backupNow')));
      await waitUntil(tester, () => sharer.shared.isNotEmpty);
      expect(sharer.shared, hasLength(1));
      expect(find.byKey(const Key('backupProblemsBody')), findsNothing);
    }, sample: false);

    harnessTest('problems found: warns, Cancel makes no backup, Back up anyway does', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      await db(tester, () => corrupt(h));
      final sharer = await open(tester, h, const BackupScreen());

      await tester.tap(find.byKey(const Key('backupNow')));
      await waitUntil(tester, () => find.byKey(const Key('backupProblemsBody')).evaluate().isNotEmpty);
      expect(_text(tester, 'backupProblemsBody'), contains('found 2 problems'));
      await tester.tap(find.byKey(const Key('backupProblemsCancel')));
      await waitUntil(tester, () => find.byKey(const Key('backupProblemsBody')).evaluate().isEmpty);
      expect(sharer.shared, isEmpty);

      await tester.tap(find.byKey(const Key('backupNow')));
      await waitUntil(tester, () => find.byKey(const Key('backupProblemsGo')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('backupProblemsGo')));
      await waitUntil(tester, () => sharer.shared.isNotEmpty);
      expect(sharer.shared, hasLength(1));
    }, sample: false);
  });

  group('after a restore', () {
    harnessTest('the restored data is checked and the result is remembered in it', (tester, h) async {
      // A backup that already has a problem in it.
      final other = Directory.systemTemp.createTempSync('shop_check_other_');
      addTearDown(() {
        try {
          other.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold a file; the OS cleans temp.
        }
      });
      final file = (await tester.runAsync(() async {
        final loc = FolderDatabaseLocation(other);
        final db = AppDatabase(NativeDatabase(await loc.databaseFile()));
        final s = await ensureShopSession(db);
        await seedRichShop(s);
        await db.customStatement(
            "UPDATE invoices SET total_paise = total_paise + 100 WHERE invoice_no_text = 'A-0001'");
        final b = await BackupService(db, loc).createBackup();
        await db.close();
        return File(b.path);
      }))!;

      await open(tester, h, const BackupScreen(), pick: file);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('restoreConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('restoreConfirm')));
      final live = File('${work.path}/shop.sqlite');
      await waitUntil(tester, () {
        if (!live.existsSync()) return false;
        try {
          final d = sq.sqlite3.open(live.path, mode: sq.OpenMode.readOnly);
          final n = d.select("SELECT COUNT(*) FROM app_settings WHERE key = 'data_check_last'").first.values.first as int;
          d.dispose();
          return n > 0;
        } catch (_) {
          return false;
        }
      });

      final d = sq.sqlite3.open(live.path, mode: sq.OpenMode.readOnly);
      final saved = d.select("SELECT value FROM app_settings WHERE key = 'data_check_last'").first.values.first as String;
      d.dispose();
      expect(saved, contains('"errors":'));
      expect(saved, isNot(contains('"errors":0')));
    }, sample: false);
  });
}

Future<void> db0(Harness h, String sql) => h.db.customStatement(sql);
