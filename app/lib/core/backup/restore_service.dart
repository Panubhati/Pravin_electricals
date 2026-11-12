import 'dart:io';

import 'package:path/path.dart' as p;

import '../bootstrap.dart';
import '../sync/device_identity.dart';
import '../db/app_database.dart';
import '../db/repositories/audit_repository.dart';
import '../db/repositories/data_check_models.dart';
import '../db/repositories/settings_repository.dart';
import '../db/repositories/data_check_repository.dart';
import 'backup_models.dart';
import 'backup_service.dart';
import 'database_location.dart';

const _safetyPrefix = 'before_restore_';

/// What a finished restore leaves behind.
class RestoreResult {
  const RestoreResult({required this.summary, this.safetyCopy});
  final BackupSummary summary;

  /// The data that was on the phone before the restore, kept so a wrong restore
  /// can be undone. Null when there was nothing to keep (a fresh install).
  final File? safetyCopy;
}

/// Replaces the shop's database file with a backup. Works on files only: the
/// caller must close the live database first and reopen it afterwards (reopening
/// upgrades an older backup to this app's schema).
class RestoreService {
  RestoreService(this.location, {DateTime Function()? clock, this.keepSafetyCopies = 3})
      : _clock = clock ?? DateTime.now;

  final ShopDatabaseLocation location;
  final DateTime Function() _clock;
  final int keepSafetyCopies;

  /// What [backup] contains, or a [BackupException] saying why it cannot be used.
  BackupSummary inspect(File backup, {required int currentSchemaVersion}) =>
      BackupInspector.inspect(backup, currentSchemaVersion: currentSchemaVersion);

  /// Checks [backup], keeps a copy of the current data, then swaps the backup in.
  /// If anything goes wrong the old data is put back and a [BackupException]
  /// explains; the phone is never left without a database.
  Future<RestoreResult> replaceWith(File backup, {required int currentSchemaVersion}) async {
    final summary = inspect(backup, currentSchemaVersion: currentSchemaVersion);

    final live = await location.databaseFile();
    final work = await location.workDirectory();
    await live.parent.create(recursive: true);

    final hadData = live.existsSync() && live.lengthSync() > 0;
    File? safety;
    final staged = File('${live.path}.restoring');
    try {
      if (hadData) {
        // Never overwrite an existing copy: it may be the very file being restored
        // (Undo), or an earlier safety copy made in the same second.
        final stamp = '$_safetyPrefix${_stamp(_clock())}';
        var candidate = File(p.join(work.path, '$stamp.sqlite'));
        for (var n = 2; candidate.existsSync(); n++) {
          candidate = File(p.join(work.path, '${stamp}_$n.sqlite'));
        }
        safety = candidate;
        await live.copy(safety.path);
      }

      // Copy next to the live file first, so the swap is a rename, not a long copy.
      if (staged.existsSync()) staged.deleteSync();
      await backup.copy(staged.path);
      // The copy must be as good as the original before anything is deleted.
      BackupInspector.inspect(staged, currentSchemaVersion: currentSchemaVersion);

      _deleteLiveFiles(live);
      await staged.rename(live.path);
    } on BackupException {
      await _rollback(live, safety, staged);
      rethrow;
    } on FileSystemException catch (e) {
      await _rollback(live, safety, staged);
      throw BackupException(_fileProblem(e));
    } catch (e) {
      await _rollback(live, safety, staged);
      throw BackupException('Could not restore the backup: $e');
    }

    await _pruneSafetyCopies(work);
    return RestoreResult(summary: summary, safetyCopy: safety);
  }

  /// The newest safety copy kept from an earlier restore, if any.
  Future<File?> latestSafetyCopy() async {
    final work = await location.workDirectory();
    final copies = _safetyCopies(work);
    return copies.isEmpty ? null : copies.last;
  }

  /// Puts a safety copy back as the live database (undo a restore). The caller
  /// must have closed the live database.
  Future<void> restoreSafetyCopy(File copy, {required int currentSchemaVersion}) async {
    await replaceWith(copy, currentSchemaVersion: currentSchemaVersion);
  }

  void _deleteLiveFiles(File live) {
    for (final suffix in const ['', '-wal', '-shm', '-journal']) {
      final f = File('${live.path}$suffix');
      if (f.existsSync()) f.deleteSync();
    }
  }

  Future<void> _rollback(File live, File? safety, File staged) async {
    try {
      if (staged.existsSync()) staged.deleteSync();
      if (safety != null && safety.existsSync() && !live.existsSync()) {
        await safety.copy(live.path);
      }
    } catch (_) {
      // Best effort: the safety copy is still in the work folder.
    }
  }

  List<File> _safetyCopies(Directory work) {
    if (!work.existsSync()) return [];
    final files = work
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith(_safetyPrefix))
        .toList()
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    return files;
  }

  Future<void> _pruneSafetyCopies(Directory work) async {
    final copies = _safetyCopies(work);
    for (final old in copies.take((copies.length - keepSafetyCopies).clamp(0, copies.length))) {
      try {
        old.deleteSync();
      } on FileSystemException {
        // Leave it; it goes next time.
      }
    }
  }

  static String _stamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }

  static String _fileProblem(FileSystemException e) {
    final text = '${e.message} ${e.osError?.message ?? ''}'.toLowerCase();
    if (text.contains('space') || text.contains('no room')) {
      return 'The phone is out of storage space. Free some space and try again. Your current data was not changed.';
    }
    return 'Could not restore the backup: ${e.message}. Your current data was not changed.';
  }
}

/// After the restored database has been reopened: counts the restore as a
/// backup made now and records it in the audit log. Returns the session.
Future<ShopSession> finishRestore(AppDatabase db, BackupSummary summary,
    {DateTime? now, DeviceIdentity? identity}) async {
  final session = await ensureShopSession(db, identity: identity);
  final settings = SettingsRepository(session.ctx);
  await settings.setLastBackupAt(now ?? session.ctx.clock());
  await AuditRepository(session.ctx).record(
    action: 'backup_restored',
    entity: 'shop',
    entityId: session.shopId,
    userId: session.userId,
    after: {
      'shop': summary.shopName,
      'bills': summary.bills,
      'customers': summary.customers,
      'items': summary.items,
      'schemaVersion': summary.schemaVersion,
    },
  );
  return session;
}

/// Runs "Check my data" on the freshly restored database and remembers the
/// result (so Settings and Home show it after the app restarts).
Future<DataCheckSummary> checkRestoredData(AppDatabase db, {DeviceIdentity? identity}) async {
  final session = await ensureShopSession(db, identity: identity);
  final result = await DataCheckRepository(session.ctx).run();
  await SettingsRepository(session.ctx).setDataCheckSummary(result.summary);
  return result.summary;
}
