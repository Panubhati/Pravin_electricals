import '../bootstrap.dart';
import '../db/app_database.dart';
import '../db/repositories/settings_repository.dart';

/// How many days without a backup before the owner is reminded.
const backupReminderDays = 3;

/// Where the owner stands on backups.
enum BackupStatus {
  /// Recently backed up, or there is nothing worth backing up yet.
  ok,

  /// There is shop data and no backup has ever been made.
  never,

  /// The last backup is more than [backupReminderDays] days old.
  overdue,
}

/// The backup rule: remind when there is shop data and the last backup is more
/// than 3 days old (or there never was one). A shop with no items and no bills
/// has nothing to lose, so no reminder.
BackupStatus backupStatus({
  required DateTime? lastBackupAt,
  required DateTime now,
  required bool hasData,
}) {
  if (!hasData) return BackupStatus.ok;
  if (lastBackupAt == null) return BackupStatus.never;
  return now.difference(lastBackupAt) > const Duration(days: backupReminderDays)
      ? BackupStatus.overdue
      : BackupStatus.ok;
}

/// "You have not made a backup yet." or "Your last backup was 5 days ago."
String backupStatusMessage(BackupStatus status, DateTime? lastBackupAt, DateTime now) {
  switch (status) {
    case BackupStatus.ok:
      return '';
    case BackupStatus.never:
      return 'You have not made a backup yet.';
    case BackupStatus.overdue:
      final days = now.difference(lastBackupAt!).inDays;
      return 'Your last backup was $days days ago.';
  }
}

/// True once the shop has any item or bill.
Future<bool> shopHasData(AppDatabase db) async {
  final rows = await db
      .customSelect('SELECT (SELECT COUNT(*) FROM items) + (SELECT COUNT(*) FROM invoices) AS n')
      .getSingle();
  return (rows.data['n'] as int) > 0;
}

/// Everything the home banner and the background reminder need, in one place.
class BackupReminderState {
  const BackupReminderState(this.status, this.message, this.reminderOn);
  final BackupStatus status;
  final String message;
  final bool reminderOn;

  bool get shouldRemind => reminderOn && status != BackupStatus.ok;
}

/// Reads the settings and the data and works out whether to remind.
Future<BackupReminderState> backupReminderState(AppDatabase db, ShopSession session,
    {DateTime? now}) async {
  final settings = SettingsRepository(session.ctx);
  final when = now ?? session.ctx.clock();
  final last = await settings.lastBackupAt();
  final status = backupStatus(lastBackupAt: last, now: when, hasData: await shopHasData(db));
  return BackupReminderState(
      status, backupStatusMessage(status, last, when), await settings.backupReminderOn());
}
