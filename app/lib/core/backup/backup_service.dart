import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;

import '../db/app_database.dart';
import 'backup_models.dart';
import 'database_location.dart';

const _filePrefix = 'PravinElectricals_backup_';

/// Tables a database must have to be this app's (they exist in every schema version).
const _requiredTables = [
  'shops', 'users', 'parties', 'items', 'invoices', 'invoice_lines',
  'ledger_entries', 'stock_movements',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// `PravinElectricals_backup_2026-11-12_2130.sqlite`
String backupFileName(DateTime t) =>
    '$_filePrefix${t.year}-${_two(t.month)}-${_two(t.day)}_${_two(t.hour)}${_two(t.minute)}.sqlite';

/// Reads a database file with plain SQLite (no migrations, read only) and
/// reports what is in it, or why it cannot be used. Used to check a backup
/// right after it is made and again before restoring one.
class BackupInspector {
  /// A summary of [file], or a [BackupException] saying in plain words why it
  /// cannot be used. [currentSchemaVersion] is this app's database version.
  static BackupSummary inspect(File file, {required int currentSchemaVersion}) {
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw BackupException('That file is empty.');
    }
    sq.Database? d;
    try {
      d = sq.sqlite3.open(file.path, mode: sq.OpenMode.readOnly);
      return _inspectOpen(d, file, currentSchemaVersion);
    } on BackupException {
      rethrow;
    } on sq.SqliteException {
      throw BackupException(
          'This is not a backup made by this app, or the file is damaged.');
    } finally {
      d?.dispose();
    }
  }

  static BackupSummary _inspectOpen(sq.Database d, File file, int current) {
    // Reading any table proves the file is a real, readable database.
    final tables = {
      for (final r in d.select("SELECT name FROM sqlite_master WHERE type='table'")) r['name'] as String
    };
    final missing = _requiredTables.where((t) => !tables.contains(t));
    if (missing.isNotEmpty) {
      throw BackupException('This is not a backup made by this app.');
    }
    final integrity = d.select('PRAGMA integrity_check').first.values.first;
    if (integrity != 'ok') {
      throw BackupException('This backup file is damaged and cannot be used.');
    }
    final version = d.select('PRAGMA user_version').first.values.first as int;
    if (version > current) {
      throw BackupException(
          'This backup was made by a newer version of the app. Update the app first, then restore.');
    }
    if (version < 1) {
      throw BackupException('This is not a backup made by this app.');
    }
    int count(String t, [String where = '']) =>
        d.select('SELECT COUNT(*) FROM $t $where').first.values.first as int;

    final shops = d.select('SELECT name FROM shops WHERE deleted_at IS NULL LIMIT 1');
    if (shops.isEmpty) throw BackupException('This backup has no shop in it.');
    final last = d.select('SELECT MAX(date) FROM invoices').first.values.first;
    return BackupSummary(
      shopName: shops.first['name'] as String,
      schemaVersion: version,
      bills: count('invoices', 'WHERE deleted_at IS NULL'),
      customers: count('parties', "WHERE deleted_at IS NULL AND kind IN ('customer','both')"),
      items: count('items', 'WHERE deleted_at IS NULL'),
      sizeBytes: file.lengthSync(),
      lastBillAt: last is int ? DateTime.fromMillisecondsSinceEpoch(last * 1000) : null,
    );
  }

  /// Row counts and key sums for [path], read with plain SQLite.
  static DbFingerprint fingerprintOf(File file, List<String> tables) {
    final d = sq.sqlite3.open(file.path, mode: sq.OpenMode.readOnly);
    try {
      final existing = {
        for (final r in d.select("SELECT name FROM sqlite_master WHERE type='table'")) r['name'] as String
      };
      final counts = {
        for (final t in tables)
          t: existing.contains(t) ? d.select('SELECT COUNT(*) FROM $t').first.values.first as int : -1,
      };
      final sums = {
        for (final (name, table, column) in fingerprintSums)
          name: existing.contains(table)
              ? (d.select('SELECT COALESCE(SUM($column), 0) FROM $table').first.values.first as num).toInt()
              : -1,
      };
      return DbFingerprint(counts, sums);
    } finally {
      d.dispose();
    }
  }
}

/// The live database's fingerprint, read through Drift.
Future<DbFingerprint> liveFingerprint(AppDatabase db) async {
  Future<int> scalar(String sql) async =>
      (await db.customSelect(sql).getSingle()).data.values.first as int;
  final counts = <String, int>{
    for (final t in db.allTables) t.actualTableName: await scalar('SELECT COUNT(*) FROM ${t.actualTableName}'),
  };
  final sums = <String, int>{
    for (final (name, table, column) in fingerprintSums)
      name: await scalar('SELECT COALESCE(SUM($column), 0) FROM $table'),
  };
  return DbFingerprint(counts, sums);
}

/// Makes verified backup files of the live database.
class BackupService {
  BackupService(this.db, this.location, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final ShopDatabaseLocation location;
  final DateTime Function() _clock;

  /// Copies the whole database to a new file in the app's private folder and
  /// checks the copy against the live data. Only a copy that passes is returned;
  /// a bad one is deleted and a [BackupException] explains.
  ///
  /// The copy is made with SQLite `VACUUM INTO`, which takes a clean snapshot
  /// while the app keeps running (no half-written bill).
  Future<BackupFile> createBackup() async {
    final dir = await location.workDirectory();
    await deleteOldBackups(dir);
    final name = backupFileName(_clock());
    final file = File(p.join(dir.path, name));

    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        if (file.existsSync()) file.deleteSync();
        final before = await liveFingerprint(db);
        await db.customStatement("VACUUM INTO '${file.path.replaceAll("'", "''")}'");
        final after = await liveFingerprint(db);
        // A bill saved while copying would make a fair copy look wrong: try again.
        if (before != after) {
          if (attempt == 1) throw BackupException('The data kept changing while backing up. Try again.');
          continue;
        }
        final tables = [for (final t in db.allTables) t.actualTableName];
        final copy = BackupInspector.fingerprintOf(file, tables);
        if (copy != before) {
          throw BackupException(
              'The backup did not match your data, so it was not used. (${copy.describeDifference(before)})');
        }
        final summary = BackupInspector.inspect(file, currentSchemaVersion: db.schemaVersion);
        return BackupFile(path: file.path, name: name, summary: summary);
      }
      throw BackupException('Could not make a backup. Try again.');
    } on BackupException {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    } on FileSystemException catch (e) {
      if (file.existsSync()) file.deleteSync();
      throw BackupException(_fileProblem(e));
    } catch (e) {
      if (file.existsSync()) file.deleteSync();
      throw BackupException('Could not make a backup: $e');
    }
  }

  /// Deletes backup files left from earlier runs (they are only temporary).
  static Future<void> deleteOldBackups(Directory dir) async {
    if (!dir.existsSync()) return;
    for (final f in dir.listSync().whereType<File>()) {
      if (p.basename(f.path).startsWith(_filePrefix)) {
        try {
          f.deleteSync();
        } on FileSystemException {
          // In use by the share sheet: leave it, it goes next time.
        }
      }
    }
  }
}

String _fileProblem(FileSystemException e) {
  final text = '${e.message} ${e.osError?.message ?? ''}'.toLowerCase();
  if (text.contains('space') || text.contains('no room')) {
    return 'The phone is out of storage space. Free some space and try again.';
  }
  return 'Could not write the backup file: ${e.message}';
}
