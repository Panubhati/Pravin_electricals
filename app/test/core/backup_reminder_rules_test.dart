import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/backup_reminder_rules.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);

  group('the 3-day rule', () {
    test('a backup made today or up to 3 days ago is fine', () {
      for (final ago in [Duration.zero, const Duration(hours: 5), const Duration(days: 2), const Duration(days: 3)]) {
        expect(backupStatus(lastBackupAt: now.subtract(ago), now: now, hasData: true), BackupStatus.ok,
            reason: '$ago');
      }
    });

    test('more than 3 days old is overdue', () {
      expect(backupStatus(lastBackupAt: now.subtract(const Duration(days: 3, minutes: 1)), now: now, hasData: true),
          BackupStatus.overdue);
      expect(backupStatus(lastBackupAt: now.subtract(const Duration(days: 30)), now: now, hasData: true),
          BackupStatus.overdue);
    });

    test('data and no backup ever is "never"', () {
      expect(backupStatus(lastBackupAt: null, now: now, hasData: true), BackupStatus.never);
    });

    test('a shop with nothing in it needs no backup, ever or not', () {
      expect(backupStatus(lastBackupAt: null, now: now, hasData: false), BackupStatus.ok);
      expect(backupStatus(lastBackupAt: now.subtract(const Duration(days: 90)), now: now, hasData: false),
          BackupStatus.ok);
    });
  });

  group('wording', () {
    test('never and overdue', () {
      expect(backupStatusMessage(BackupStatus.never, null, now), 'You have not made a backup yet.');
      expect(backupStatusMessage(BackupStatus.overdue, now.subtract(const Duration(days: 5, hours: 3)), now),
          'Your last backup was 5 days ago.');
      expect(backupStatusMessage(BackupStatus.ok, now, now), '');
    });

    test('shouldRemind needs the switch on and a status that is not ok', () {
      expect(const BackupReminderState(BackupStatus.overdue, 'x', true).shouldRemind, isTrue);
      expect(const BackupReminderState(BackupStatus.overdue, 'x', false).shouldRemind, isFalse);
      expect(const BackupReminderState(BackupStatus.ok, '', true).shouldRemind, isFalse);
    });
  });
}
