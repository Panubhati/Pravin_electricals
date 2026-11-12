import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/backup_sharer.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/import/file_service.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/settings/settings_screen.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import '../helpers/app_harness.dart';
import '../helpers/seed_rich_shop.dart';

class FakeSharer implements BackupSharer {
  final shared = <({String path, String? subject, String? text})>[];
  Object? error;
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async {
    if (error != null) throw error!;
    shared.add((path: file.path, subject: subject, text: text));
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

class Opened {
  Opened(this.sharer, this.restarts, this.container);
  final FakeSharer sharer;
  final int Function() restarts;
  final ProviderContainer container;
}

String _text(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data!;

/// Lets real async work (files, database, isolates) finish.
Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 80}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  // A progress spinner may be animating forever, so never pumpAndSettle here.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late Directory phone; // where "this phone's" database file would live
  late Directory other; // the old phone the backup comes from
  late FolderDatabaseLocation location;

  setUp(() {
    phone = Directory.systemTemp.createTempSync('shop_screen_phone_');
    other = Directory.systemTemp.createTempSync('shop_screen_other_');
    location = FolderDatabaseLocation(phone);
  });
  tearDown(() {
    for (final d in [phone, other]) {
      if (d.existsSync()) {
        try {
          d.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold a file for a moment; the OS cleans temp.
        }
      }
    }
  });

  /// A backup file of a seeded shop, made on "another phone".
  Future<File> makeBackup() async {
    final loc = FolderDatabaseLocation(other);
    final db = AppDatabase(NativeDatabase(await loc.databaseFile()));
    final s = await ensureShopSession(db);
    await seedRichShop(s);
    final b = await BackupService(db, loc).createBackup();
    await db.close();
    return File(b.path);
  }

  Future<Opened> open(WidgetTester tester, Harness h, {File? pick}) async {
    final sharer = FakeSharer();
    var restarts = 0;
    final c = await h.pump(tester, const SettingsScreen(), overrides: [
      databaseLocationProvider.overrideWithValue(location),
      backupSharerProvider.overrideWithValue(sharer),
      fileServiceProvider.overrideWithValue(FakePicker(pick)),
      appRestartProvider.overrideWithValue((_) => restarts++),
    ]);
    return Opened(sharer, () => restarts, c);
  }

  group('Back up now', () {
    harnessTest('makes a verified backup, shares it, and remembers when', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final o = await open(tester, h);
      expect(_text(tester, 'lastBackupText'), 'Last backup: Never');

      await tester.tap(find.byKey(const Key('backupNow')));
      await waitUntil(tester, () => o.sharer.shared.isNotEmpty);

      expect(o.sharer.shared, hasLength(1));
      final shared = o.sharer.shared.single;
      expect(p.basename(shared.path), startsWith('PravinElectricals_backup_'));
      expect(shared.subject, 'Pravin Electricals backup');
      expect(shared.text, contains('3 bills'));
      expect(shared.text, contains('contains all shop data'));
      // The file handed over is a real, complete backup of this shop.
      final copy = sq.sqlite3.open(shared.path, mode: sq.OpenMode.readOnly);
      expect(copy.select('SELECT COUNT(*) FROM invoices').first.values.first, 3);
      expect(copy.select('PRAGMA integrity_check').first.values.first, 'ok');
      copy.dispose();

      await waitUntil(tester, () => !_text(tester, 'lastBackupText').contains('Never'));
      expect(_text(tester, 'lastBackupText'), startsWith('Last backup: '));
      expect(_text(tester, 'lastBackupText'), isNot(contains('Never')));
      await db(tester, () async {
        expect(await SettingsRepository(h.session.ctx).lastBackupAt(), isNotNull);
        final audit = await AuditRepository(h.session.ctx).list(actions: {'backup_made'});
        expect(audit, hasLength(1));
        expect(audit.single.row.afterJson, contains('"bills":3'));
      });
    }, sample: false);

    harnessTest('if sharing fails the owner is told and the last-backup time does not change', (tester, h) async {
      await db(tester, () => seedRichShop(h.session));
      final o = await open(tester, h);
      o.sharer.error = StateError('no share target');
      await tester.tap(find.byKey(const Key('backupNow')));
      await waitUntil(tester, () => find.textContaining('Could not make the backup').evaluate().isNotEmpty);
      expect(find.textContaining('Could not make the backup'), findsOneWidget);
      expect(_text(tester, 'lastBackupText'), 'Last backup: Never');
    }, sample: false);

    harnessTest('the reminder switch is on by default and can be turned off', (tester, h) async {
      await open(tester, h);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('backupReminderSwitch'))).value, isTrue);
      await tester.tap(find.byKey(const Key('backupReminderSwitch')));
      await settle(tester);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('backupReminderSwitch'))).value, isFalse);
      await db(tester, () async {
        expect(await SettingsRepository(h.session.ctx).backupReminderOn(), isFalse);
      });
    }, sample: false);
  });

  group('Restore', () {
    harnessTest('shows what is in the backup, and Cancel changes nothing', (tester, h) async {
      final file = await tester.runAsync(makeBackup);
      final o = await open(tester, h, pick: file);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('restoreShop')).evaluate().isNotEmpty);

      expect(_text(tester, 'restoreShop'), 'Pravin Electricals');
      expect(_text(tester, 'restoreCounts'), '3 bills, 1 customers, 3 items');
      expect(find.textContaining('will be replaced'), findsOneWidget);
      expect(find.textContaining('only one phone'), findsOneWidget);

      await tester.tap(find.byKey(const Key('restoreCancel')));
      await settle(tester);
      expect(o.restarts(), 0);
      expect((await location.databaseFile()).existsSync(), isFalse);
    }, sample: false);

    harnessTest('Restore replaces the data, counts as a backup, and starts the app over', (tester, h) async {
      final file = await tester.runAsync(makeBackup);
      final o = await open(tester, h, pick: file);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('restoreConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('restoreConfirm')));
      await waitUntil(tester, () => o.restarts() > 0);

      expect(o.restarts(), 1);
      // The live file on this phone is now the backup, with the restore recorded.
      final live = sq.sqlite3.open((await location.databaseFile()).path, mode: sq.OpenMode.readOnly);
      expect(live.select('SELECT COUNT(*) FROM invoices').first.values.first, 3);
      expect(live.select("SELECT COUNT(*) FROM audit_log WHERE action = 'backup_restored'").first.values.first, 1);
      expect(live.select("SELECT COUNT(*) FROM app_settings WHERE key = 'last_backup_at'").first.values.first, 1);
      live.dispose();
    }, sample: false);

    harnessTest('a file that is not a backup is refused with a plain message and nothing is replaced', (tester, h) async {
      final junk = File(p.join(other.path, 'holiday.jpg'))..writeAsBytesSync(List.filled(4000, 3));
      final o = await open(tester, h, pick: junk);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('backupProblem')).evaluate().isNotEmpty);
      expect(find.text('This file cannot be used'), findsOneWidget);
      expect(_text(tester, 'backupProblem'), contains('not a backup made by this app'));
      expect(o.restarts(), 0);
      expect((await location.databaseFile()).existsSync(), isFalse);
    }, sample: false);

    harnessTest('a backup from a newer app version says to update first', (tester, h) async {
      final file = (await tester.runAsync(makeBackup))!;
      final d = sq.sqlite3.open(file.path);
      d.execute('PRAGMA user_version = 99');
      d.dispose();
      await open(tester, h, pick: file);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('backupProblem')).evaluate().isNotEmpty);
      expect(_text(tester, 'backupProblem'), contains('newer version of the app'));
    }, sample: false);

    harnessTest('cancelling the file picker does nothing', (tester, h) async {
      final o = await open(tester, h, pick: null);
      await tester.tap(find.byKey(const Key('restoreBackup')));
      await settle(tester);
      expect(find.byKey(const Key('restoreShop')), findsNothing);
      expect(o.restarts(), 0);
    }, sample: false);

    harnessTest('after a restore over existing data, Undo brings the old data back', (tester, h) async {
      // This phone already has its own shop file.
      final liveFile = await location.databaseFile();
      await tester.runAsync(() async {
        final mine = AppDatabase(NativeDatabase(liveFile));
        await ensureShopSession(mine);
        await mine.customStatement("UPDATE shops SET name = 'My Own Shop'");
        await mine.close();
      });

      final file = await tester.runAsync(makeBackup);
      final o = await open(tester, h, pick: file);
      expect(find.byKey(const Key('undoRestore')), findsNothing);

      await tester.tap(find.byKey(const Key('restoreBackup')));
      await waitUntil(tester, () => find.byKey(const Key('restoreConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('restoreConfirm')));
      await waitUntil(tester, () => o.restarts() > 0);
      expect(o.restarts(), 1);

      String shopName() {
        final d = sq.sqlite3.open(liveFile.path, mode: sq.OpenMode.readOnly);
        final n = d.select('SELECT name FROM shops').first.values.first as String;
        d.dispose();
        return n;
      }

      expect(shopName(), 'Pravin Electricals'); // the backup's shop
      // The Undo tile is at the bottom of a long list: scroll so it gets built.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2500));
      await waitUntil(tester, () => find.byKey(const Key('undoRestore')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('undoRestore')), findsOneWidget);

      await tester.tap(find.byKey(const Key('undoRestore')));
      await waitUntil(tester, () => find.byKey(const Key('restoreConfirm')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('restoreConfirm')));
      await waitUntil(tester, () => o.restarts() > 1);
      expect(o.restarts(), 2);
      expect(shopName(), 'My Own Shop');
    }, sample: false);
  });

  group('counter staff', () {
    harnessTest('have no Settings tile, so no way to Backup or Restore', (tester, h) async {
      final counter = await h.addCounterUser(tester);
      await h.pump(tester, const HomeScreen(), user: counter);
      expect(find.byKey(const Key('tile_settings')), findsNothing);
    }, sample: false);
  });
}
