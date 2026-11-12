import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/backup/backup_models.dart';
import '../../core/backup/backup_service.dart';
import '../../core/backup/restore_service.dart';
import '../../core/bootstrap.dart';
import '../../core/db/app_database.dart';
import '../../core/db/connection.dart';
import '../../core/db/repositories/audit_repository.dart';
import '../../core/db/repositories/data_check_models.dart';
import '../../core/import/file_service.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/messages_mr.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../datacheck/data_check_screen.dart';
import '../../shared/theme.dart';

/// A copy of the data replaced by the last restore, if one is still kept (so
/// the owner can undo a wrong restore).
final safetyCopyProvider = FutureProvider.autoDispose<File?>(
  (ref) => RestoreService(ref.watch(databaseLocationProvider)).latestSafetyCopy(),
);

String backupTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${formatDate(d)}, $h12:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// Makes a verified backup of the shop and opens the share sheet so the owner
/// can send it to their own email or Drive. Returns false after telling the
/// owner why when it could not be done.
Future<bool> backUpNow(BuildContext context, WidgetRef ref) async {
  final session = ref.read(sessionProvider).requireValue;
  final db = ref.read(databaseProvider);
  final settings = ref.read(settingsRepositoryProvider);
  try {
    // A backup of broken data is worth little: look first, warn, but still allow it.
    final check = await runDataCheck(ref);
    if (!check.passed) {
      if (!context.mounted) return false;
      final go = await _confirmBackupDespiteProblems(context, check.errorCount);
      if (!go) return false;
    }
    final backup = await BackupService(db, ref.read(databaseLocationProvider),
            clock: session.ctx.clock)
        .createBackup();
    await ref.read(backupSharerProvider).shareFile(
          File(backup.path),
          subject: S.backupShareSubject(session.shop.name),
          text: S.backupShareBody(
              session.shop.name, backup.summary.bills, backup.summary.customers, backup.summary.items),
        );
    await settings.setLastBackupAt(session.ctx.clock());
    await AuditRepository(session.ctx).record(
      action: 'backup_made',
      entity: 'shop',
      entityId: session.shopId,
      userId: ref.read(actingUserIdProvider),
      after: {
        'name': backup.name,
        'bills': backup.summary.bills,
        'customers': backup.summary.customers,
        'items': backup.summary.items,
      },
    );
    ref.invalidate(lastBackupProvider);
    return true;
  } on BackupException catch (e) {
    if (context.mounted) toast(context, localizeMessage(e.message));
  } catch (e) {
    if (context.mounted) toast(context, '${S.backupFailed}: ${errorMessage(e)}');
  }
  return false;
}

/// Choose a backup file, show what is in it, and after the owner confirms
/// replace everything on this phone with it. Then the app starts over from the
/// restored data and asks for the PIN from that backup.
Future<void> restoreFromBackup(BuildContext context, WidgetRef ref) async {
  final loc = ref.read(databaseLocationProvider);
  final db = ref.read(databaseProvider);
  final restore = RestoreService(loc, clock: ref.read(sessionProvider).valueOrNull?.ctx.clock);

  File? file;
  try {
    file = await ref.read(fileServiceProvider).pickBackupFile();
  } catch (e) {
    if (context.mounted) toast(context, errorMessage(e));
    return;
  }
  if (file == null) return;

  late BackupSummary summary;
  try {
    summary = restore.inspect(file, currentSchemaVersion: db.schemaVersion);
  } on BackupException catch (e) {
    if (context.mounted) await _showProblem(context, localizeMessage(e.message));
    return;
  }
  if (!context.mounted) return;
  final ok = await _confirmRestore(context, summary, replacingData: true);
  if (!ok || !context.mounted) return;
  await _runRestore(context, ref, () => restore.replaceWith(file!, currentSchemaVersion: db.schemaVersion),
      summary: summary);
}

/// Puts back the data that the last restore replaced.
Future<void> undoLastRestore(BuildContext context, WidgetRef ref) async {
  final loc = ref.read(databaseLocationProvider);
  final db = ref.read(databaseProvider);
  final restore = RestoreService(loc);
  final copy = await restore.latestSafetyCopy();
  if (copy == null || !context.mounted) return;
  late BackupSummary summary;
  try {
    summary = restore.inspect(copy, currentSchemaVersion: db.schemaVersion);
  } on BackupException catch (e) {
    if (context.mounted) await _showProblem(context, localizeMessage(e.message));
    return;
  }
  if (!context.mounted) return;
  final ok = await _confirmRestore(context, summary, replacingData: true, undo: true);
  if (!ok || !context.mounted) return;
  await _runRestore(context, ref,
      () => restore.replaceWith(copy, currentSchemaVersion: db.schemaVersion),
      summary: summary);
}

Future<void> _runRestore(
  BuildContext context,
  WidgetRef ref,
  Future<RestoreResult> Function() replace, {
  required BackupSummary summary,
}) async {
  final loc = ref.read(databaseLocationProvider);
  final db = ref.read(databaseProvider);
  final restart = ref.read(appRestartProvider);
  final navigator = Navigator.of(context, rootNavigator: true);
  final messenger = ScaffoldMessenger.of(context);
  final restartContext = context;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(child: Text(S.restoring)),
        ]),
      ),
    ),
  );

  String? problem;
  DataCheckSummary? checkOutcome;
  final identity = ref.read(deviceIdentityProvider);
  try {
    // A phone that is not paired with another forgets which device it was: the
    // restored data then decides (it is phone A again after a lost phone).
    // A paired phone keeps its identity, and asks if the data does not know it.
    var paired = false;
    try {
      final phones = await db.customSelect('SELECT COUNT(*) AS n FROM devices WHERE deleted_at IS NULL').getSingle();
      paired = (phones.data['n'] as int) > 1;
    } catch (_) {
      // The connection is already closed (a second restore in a row, only in
      // tests): treated as one phone.
    }
    // Nothing may hold the database file open while it is swapped.
    await db.close();
    await replace();
    if (!paired) await identity?.clear();
    // Open the restored data once to upgrade an older backup, count the restore
    // as a backup made now, and write the audit entry.
    final restored = AppDatabase(openShopDatabase(location: loc));
    try {
      await finishRestore(restored, summary, identity: identity);
      checkOutcome = await checkRestoredData(restored, identity: identity);
    } on DeviceChoiceNeeded {
      // The app asks which phone this is when it starts again.
    } finally {
      await restored.close();
    }
  } on BackupException catch (e) {
    problem = localizeMessage(e.message);
  } catch (e) {
    problem = '${S.restoreFailed}: ${errorMessage(e)}';
  }

  navigator.pop(); // the progress dialog
  ref.invalidate(safetyCopyProvider);
  if (problem != null) {
    messenger.showSnackBar(SnackBar(content: Text(problem), duration: const Duration(seconds: 8)));
  } else {
    final bad = checkOutcome != null && !checkOutcome.passed;
    messenger.showSnackBar(SnackBar(
      content: Text(bad ? '${S.restoreDone} ${S.restoredWithProblems(checkOutcome.errors)}' : S.restoreDone),
      duration: Duration(seconds: bad ? 10 : 4),
    ));
  }
  // Either way the old database connection is closed, so start over from the
  // file on disk (the restored data, or the old data if the restore failed).
  if (restartContext.mounted) restart(restartContext);
}

Future<void> _showProblem(BuildContext context, String message) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.cannotUseBackup),
        content: Text(message, key: const Key('backupProblem')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(S.ok)),
        ],
      ),
    );

Future<bool> _confirmRestore(
  BuildContext context,
  BackupSummary s, {
  required bool replacingData,
  bool undo = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(undo ? S.undoRestoreTitle : S.restoreTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.backupContains),
            const SizedBox(height: 8),
            Text(s.shopName, style: const TextStyle(fontWeight: FontWeight.bold), key: const Key('restoreShop')),
            Text(S.backupCounts(s.bills, s.customers, s.items), key: const Key('restoreCounts')),
            if (s.lastBillAt != null) Text(S.lastBillAt(backupTime(s.lastBillAt!))),
            const SizedBox(height: 12),
            Text(replacingData ? S.restoreReplacesWarning : S.restoreFreshNote),
            const SizedBox(height: 8),
            Text(S.restoreOnePhone, style: TextStyle(color: AppPalette.muted)),
          ],
        ),
      ),
      actions: [
        TextButton(
            key: const Key('restoreCancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.cancel)),
        FilledButton(
          key: const Key('restoreConfirm'),
          style: FilledButton.styleFrom(backgroundColor: AppPalette.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(undo ? S.undoRestore : S.restoreNow),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> _confirmBackupDespiteProblems(BuildContext context, int problems) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(S.backupProblemsTitle),
      content: Text(S.backupProblemsBody(problems), key: const Key('backupProblemsBody')),
      actions: [
        TextButton(
          key: const Key('backupProblemsCancel'),
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(S.cancel),
        ),
        FilledButton(
          key: const Key('backupProblemsGo'),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(S.backUpAnyway),
        ),
      ],
    ),
  );
  return go == true;
}
