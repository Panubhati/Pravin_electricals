import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shop_app/core/backup/backup_models.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import '../helpers/seed_rich_shop.dart';

void main() {
  late Directory root;
  late FolderDatabaseLocation location;
  late AppDatabase db;
  late ShopSession session;
  final now = DateTime(2026, 11, 12, 21, 30);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('shop_backup_test_');
    location = FolderDatabaseLocation(root);
    db = AppDatabase(NativeDatabase(await location.databaseFile()));
    session = await ensureShopSession(db);
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  BackupService service([DateTime? at]) => BackupService(db, location, clock: () => at ?? now);

  group('making a backup', () {
    test('a seeded shop backs up, verifies, and is named with the date and time', () async {
      await seedRichShop(session);
      final before = await liveFingerprint(db);

      final backup = await service().createBackup();

      expect(backup.name, 'PravinElectricals_backup_2026-11-12_2130.sqlite');
      expect(File(backup.path).existsSync(), isTrue);
      expect(p.dirname(backup.path), p.join(root.path, 'work'));
      expect(backup.summary.shopName, 'Pravin Electricals');
      expect(backup.summary.bills, 3);
      expect(backup.summary.customers, 1);
      expect(backup.summary.items, 3);
      expect(backup.summary.schemaVersion, db.schemaVersion);
      expect(backup.summary.sizeBytes, greaterThan(10000));
      expect(backup.summary.lastBillAt, isNotNull);

      // The live shop is exactly as it was.
      expect(await liveFingerprint(db), before);
    });

    test('the copy is a complete, readable database with the same numbers', () async {
      await seedRichShop(session);
      final backup = await service().createBackup();
      final tables = [for (final t in db.allTables) t.actualTableName];
      expect(BackupInspector.fingerprintOf(File(backup.path), tables), await liveFingerprint(db));

      final d = sq.sqlite3.open(backup.path, mode: sq.OpenMode.readOnly);
      expect(d.select('PRAGMA integrity_check').first.values.first, 'ok');
      d.dispose();
    });

    test('an empty new shop can be backed up too', () async {
      final backup = await service().createBackup();
      expect(backup.summary.bills, 0);
      expect(backup.summary.items, 0);
    });

    test('a second backup replaces the first temporary file; other files are left alone', () async {
      await seedRichShop(session);
      final first = await service(now).createBackup();
      final other = File(p.join(p.dirname(first.path), 'before_restore_keep.sqlite'))..writeAsStringSync('x');
      final second = await service(now.add(const Duration(minutes: 5))).createBackup();

      expect(File(first.path).existsSync(), isFalse);
      expect(File(second.path).existsSync(), isTrue);
      expect(other.existsSync(), isTrue);
    });

    test('backing up while a bill is half saved still gives a consistent copy', () async {
      await seedRichShop(session);
      // A transaction that has written but not committed: the backup sees only
      // committed data, never a partly saved bill.
      final committedBefore = await liveFingerprint(db);
      late BackupFile backup;
      await db.transaction(() async {
        await db.customStatement("UPDATE app_settings SET value = value WHERE 1 = 0");
      });
      backup = await service().createBackup();
      final tables = [for (final t in db.allTables) t.actualTableName];
      expect(BackupInspector.fingerprintOf(File(backup.path), tables), committedBefore);
    });
  });

  group('checking a copy against the live data', () {
    test('a copy that lost a ledger row no longer matches, and says what differs', () async {
      await seedRichShop(session);
      final live = await liveFingerprint(db);
      final backup = await service().createBackup();

      final d = sq.sqlite3.open(backup.path);
      d.execute('DELETE FROM ledger_entries WHERE rowid = (SELECT MIN(rowid) FROM ledger_entries)');
      d.dispose();

      final tables = [for (final t in db.allTables) t.actualTableName];
      final copy = BackupInspector.fingerprintOf(File(backup.path), tables);
      expect(copy == live, isFalse);
      expect(copy.describeDifference(live), contains('ledger_entries'));
      expect(copy.describeDifference(live), contains('ledger total'));
    });

    test('equal fingerprints compare equal and hash alike', () {
      const a = DbFingerprint({'x': 1}, {'s': 2});
      const b = DbFingerprint({'x': 1}, {'s': 2});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == const DbFingerprint({'x': 1}, {'s': 3}), isFalse);
    });
  });

  group('inspecting a file (also used before a restore)', () {
    File write(String name, List<int> bytes) => File(p.join(root.path, name))..writeAsBytesSync(bytes);

    BackupException problem(File f) {
      try {
        BackupInspector.inspect(f, currentSchemaVersion: 4);
      } on BackupException catch (e) {
        return e;
      }
      fail('expected a BackupException');
    }

    test('a missing or empty file', () {
      expect(problem(File(p.join(root.path, 'nope.sqlite'))).message, 'That file is empty.');
      expect(problem(write('empty.sqlite', [])).message, 'That file is empty.');
    });

    test('not a database at all (text, a photo...)', () {
      final e = problem(write('notes.txt', List.filled(2000, 65)));
      expect(e.message, contains('not a backup made by this app'));
    });

    test('some other app\'s SQLite file', () {
      final f = File(p.join(root.path, 'other.sqlite'));
      final d = sq.sqlite3.open(f.path);
      d.execute('CREATE TABLE notes (id INTEGER)');
      d.dispose();
      expect(problem(f).message, 'This is not a backup made by this app.');
    });

    test('a backup from a newer version of the app', () async {
      await seedRichShop(session);
      final backup = await service().createBackup();
      final d = sq.sqlite3.open(backup.path);
      d.execute('PRAGMA user_version = 99');
      d.dispose();
      expect(problem(File(backup.path)).message, contains('newer version of the app'));
    });

    test('a file cut short in the middle', () async {
      await seedRichShop(session);
      final backup = await service().createBackup();
      final bytes = File(backup.path).readAsBytesSync();
      final f = write('cut.sqlite', bytes.sublist(0, bytes.length ~/ 3));
      expect(problem(f).message, isNotEmpty);
    });

    test('a good backup gives the owner something to check', () async {
      await seedRichShop(session);
      final backup = await service().createBackup();
      final s = BackupInspector.inspect(File(backup.path), currentSchemaVersion: db.schemaVersion);
      expect(s.shopName, 'Pravin Electricals');
      expect(s.bills, 3);
    });
  });
}
