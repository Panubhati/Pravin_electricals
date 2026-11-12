import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shop_app/core/backup/backup_models.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/backup/restore_service.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/dues_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import '../helpers/seed_rich_shop.dart';

/// Every row of every table, in a stable order, as text. Two databases with the
/// same dump hold exactly the same shop.
Future<String> dumpAll(AppDatabase db) async {
  final out = <String, Object?>{};
  for (final t in db.allTables) {
    final rows = await db.customSelect('SELECT * FROM ${t.actualTableName} ORDER BY rowid').get();
    out[t.actualTableName] = [for (final r in rows) r.data];
  }
  return jsonEncode(out);
}

void main() {
  late Directory phoneA; // the old phone
  late Directory phoneB; // a fresh install
  late FolderDatabaseLocation locA;
  late FolderDatabaseLocation locB;
  final at = DateTime(2026, 11, 12, 21, 30);

  setUp(() async {
    phoneA = await Directory.systemTemp.createTemp('shop_phone_a_');
    phoneB = await Directory.systemTemp.createTemp('shop_phone_b_');
    locA = FolderDatabaseLocation(phoneA);
    locB = FolderDatabaseLocation(phoneB);
  });

  tearDown(() {
    for (final d in [phoneA, phoneB]) {
      if (d.existsSync()) d.deleteSync(recursive: true);
    }
  });

  Future<AppDatabase> open(FolderDatabaseLocation loc) async =>
      AppDatabase(NativeDatabase(await loc.databaseFile()));

  /// A seeded shop on phone A, backed up. Phone A's database is left closed.
  Future<({BackupFile backup, String dump, DashboardData dashboard})> shopOnPhoneA() async {
    final db = await open(locA);
    final s = await ensureShopSession(db);
    await seedRichShop(s);
    final dashboard = await ReportsRepository(s.ctx).dashboard();
    final dump = await dumpAll(db);
    final backup = await BackupService(db, locA, clock: () => at).createBackup();
    await db.close();
    return (backup: backup, dump: dump, dashboard: dashboard);
  }

  group('the done-when test: restore onto a fresh install', () {
    test('every row, balance, bill, PIN and setting comes back identical', () async {
      final a = await shopOnPhoneA();

      // Phone B has nothing yet: a fresh install.
      expect(File(p.join(phoneB.path, 'shop.sqlite')).existsSync(), isFalse);
      final result = await RestoreService(locB, clock: () => at)
          .replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      expect(result.summary.bills, 3);
      expect(result.safetyCopy, isNull); // nothing to keep on a fresh phone

      final b = await open(locB);
      addTearDown(b.close);
      expect(await dumpAll(b), a.dump); // every row of every table, byte for byte

      // ...and it behaves like the same shop.
      final s = await ensureShopSession(b);
      final ledger = LedgerRepository(s.ctx);
      final parties = PartyRepository(s.ctx);
      final ramesh = (await parties.searchCustomers('Ramesh')).single;
      final supplier = (await parties.searchSuppliers('Polycab')).single;
      expect(await ledger.balance(ramesh.id), 7000); // Ramesh owes Rs 70.00
      expect(await ledger.balance(supplier.id), -(100000 * 3000 ~/ 1000 * 118 ~/ 100) + 100000); // owes less the Rs 1,000 paid

      final dash = await ReportsRepository(s.ctx).dashboard();
      expect(dash.today.totalPaise, a.dashboard.today.totalPaise);
      expect(dash.cash.closingPaise, a.dashboard.cash.closingPaise);
      expect(dash.totalDuePaise, a.dashboard.totalDuePaise);
      expect(dash.lowStockCount, a.dashboard.lowStockCount);

      final stock = await StockRepository(s.ctx).balancesByItem();
      expect(stock.values.fold<int>(0, (x, y) => x + y), isNonZero);
      expect((await DuesRepository(s.ctx).receivables()).single.buckets.totalDue, 7000);
      expect(await InvoiceRepository(s.ctx).list(), hasLength(3));

      final auth = AuthRepository(s.ctx);
      expect((await auth.verify(s.userId, '4821')).ok, isTrue); // the owner's PIN
      final counter = (await auth.activeUsers()).firstWhere((u) => u.role == 'counter');
      expect((await auth.verify(counter.id, '2468')).ok, isTrue);
      expect((await SettingsRepository(s.ctx).upiPayee('x'))!.vpa, 'pravin@okhdfc');
      expect(await SettingsRepository(s.ctx).openingCashPaise(), 100000);
    });

    test('finishing a restore counts it as a backup made now and writes the audit entry', () async {
      final a = await shopOnPhoneA();
      await RestoreService(locB).replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      final b = await open(locB);
      addTearDown(b.close);
      final restoredAt = DateTime(2026, 11, 20, 9);
      final s = await finishRestore(b, a.backup.summary, now: restoredAt);
      expect(await SettingsRepository(s.ctx).lastBackupAt(), restoredAt);
      final audit = await b.select(b.auditLog).get();
      final entry = audit.singleWhere((x) => x.action == 'backup_restored');
      expect(entry.afterJson, contains('"bills":3'));
    });
  });

  group('older backups', () {
    test('a backup from schema v3 restores and is upgraded to v4 with its data intact', () async {
      final a = await shopOnPhoneA();
      // Make the file look like one made by the previous version: no hsn column.
      final d = sq.sqlite3.open(a.backup.path);
      d.execute('ALTER TABLE invoice_lines DROP COLUMN hsn');
      d.execute('PRAGMA user_version = 3');
      d.dispose();

      final restore = RestoreService(locB);
      expect(restore.inspect(File(a.backup.path), currentSchemaVersion: 4).schemaVersion, 3);
      await restore.replaceWith(File(a.backup.path), currentSchemaVersion: 4);

      final b = await open(locB); // opening runs the v3 to v4 upgrade
      addTearDown(b.close);
      final s = await ensureShopSession(b);
      final lines = await b.select(b.invoiceLines).get();
      expect(lines, hasLength(3));
      expect(lines.every((l) => l.hsn == null), isTrue);
      expect(await InvoiceRepository(s.ctx).list(), hasLength(3));
      final ledger = LedgerRepository(s.ctx);
      final ramesh = (await PartyRepository(s.ctx).searchCustomers('Ramesh')).single;
      expect(await ledger.balance(ramesh.id), 7000);
      expect((await b.customSelect('PRAGMA user_version').getSingle()).data.values.first, 4);
    });
  });

  group('a bad restore never harms the data already on the phone', () {
    Future<List<int>> liveBytes() async => (await locA.databaseFile()).readAsBytesSync();

    test('a file that is not a backup is refused and the live file is untouched', () async {
      await shopOnPhoneA();
      final before = await liveBytes();
      final junk = File(p.join(phoneB.path, 'photo.jpg'))..writeAsBytesSync(List.filled(5000, 7));
      await expectLater(RestoreService(locA).replaceWith(junk, currentSchemaVersion: 4),
          throwsA(isA<BackupException>()));
      expect(await liveBytes(), before);
      expect(File('${(await locA.databaseFile()).path}.restoring').existsSync(), isFalse);
    });

    test('a backup from a newer app version is refused', () async {
      final a = await shopOnPhoneA();
      final before = await liveBytes();
      final d = sq.sqlite3.open(a.backup.path);
      d.execute('PRAGMA user_version = 99');
      d.dispose();
      await expectLater(
        RestoreService(locA).replaceWith(File(a.backup.path), currentSchemaVersion: 4),
        throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('newer version'))),
      );
      expect(await liveBytes(), before);
    });

    test('a damaged backup (cut short) is refused', () async {
      final a = await shopOnPhoneA();
      final before = await liveBytes();
      final bytes = File(a.backup.path).readAsBytesSync();
      final cut = File(p.join(phoneB.path, 'cut.sqlite'))..writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 2));
      await expectLater(RestoreService(locA).replaceWith(cut, currentSchemaVersion: 4),
          throwsA(isA<BackupException>()));
      expect(await liveBytes(), before);
    });
  });

  group('safety copies and undo', () {
    test('the data replaced is kept, and Undo puts it back exactly', () async {
      final a = await shopOnPhoneA();

      // Phone B already has its own, different shop.
      final dbB = await open(locB);
      final sB = await ensureShopSession(dbB);
      await seedRichShop(sB);
      await sB.ctx.db.customStatement("UPDATE shops SET name = 'Another Shop'");
      final dumpB = await dumpAll(dbB);
      await dbB.close();

      final restore = RestoreService(locB, clock: () => at);
      final result = await restore.replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      expect(result.safetyCopy, isNotNull);
      expect(p.basename(result.safetyCopy!.path), startsWith('before_restore_20261112_213000'));

      var db = await open(locB);
      expect(await dumpAll(db), a.dump); // phone B now holds A's shop
      await db.close();

      // Undo: B's own shop comes back exactly.
      final safety = await restore.latestSafetyCopy();
      expect(safety, isNotNull);
      await restore.restoreSafetyCopy(safety!, currentSchemaVersion: 4);
      db = await open(locB);
      addTearDown(db.close);
      expect(await dumpAll(db), dumpB);
    });

    test('only the three newest safety copies are kept', () async {
      final a = await shopOnPhoneA();
      for (var i = 0; i < 5; i++) {
        await RestoreService(locB, clock: () => at.add(Duration(minutes: i)))
            .replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      }
      final work = await locB.workDirectory();
      final kept = work.listSync().whereType<File>().map((f) => p.basename(f.path)).where((n) => n.startsWith('before_restore_')).toList()
        ..sort();
      expect(kept, hasLength(3));
      expect(kept.last, contains('2130'.substring(0, 2))); // the newest is among them
    });

    test('restoring the same backup twice works', () async {
      final a = await shopOnPhoneA();
      final restore = RestoreService(locB);
      await restore.replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      await restore.replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      final b = await open(locB);
      addTearDown(b.close);
      expect(await dumpAll(b), a.dump);
    });

    test('leftover WAL and journal files from the old database are removed', () async {
      final a = await shopOnPhoneA();
      final live = await locB.databaseFile();
      live.writeAsBytesSync(File(a.backup.path).readAsBytesSync()); // some old database
      final wal = File('${live.path}-wal')..writeAsBytesSync([1, 2, 3]);
      final shm = File('${live.path}-shm')..writeAsBytesSync([1, 2, 3]);
      await RestoreService(locB).replaceWith(File(a.backup.path), currentSchemaVersion: 4);
      expect(wal.existsSync(), isFalse);
      expect(shm.existsSync(), isFalse);
      final b = await open(locB);
      addTearDown(b.close);
      expect(await dumpAll(b), a.dump);
    });
  });
}
