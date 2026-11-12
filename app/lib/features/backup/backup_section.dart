import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/notifications/daily_summary.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'backup_actions.dart';
import 'backup_reminder.dart';
import '../../shared/theme.dart';

/// Back up, restore, undo a restore, and the reminder switch (owner only; it
/// lives inside Settings).
class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = ref.watch(lastBackupProvider);
    final safety = ref.watch(safetyCopyProvider).valueOrNull;
    final reminderOn = ref.watch(backupReminderOnProvider).valueOrNull ?? true;
    final lastAt = last.valueOrNull;

    return Column(
      children: [
        ListTile(
          key: const Key('backupNow'),
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text(S.backUpNow),
          subtitle: Text(
            lastAt == null
                ? '${S.lastBackupLabel}: ${S.neverBackedUp}'
                : '${S.lastBackupLabel}: ${backupTime(lastAt)}',
            key: const Key('lastBackupText'),
            style: lastAt == null ? const TextStyle(color: AppPalette.red) : null,
          ),
          trailing: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
          onTap: _busy ? null : () => _run(() => backUpNow(context, ref)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${S.backUpNowHelp}\n${S.backupFileWarning}', style: TextStyle(color: AppPalette.muted)),
          ),
        ),
        ListTile(
          key: const Key('restoreBackup'),
          leading: const Icon(Icons.settings_backup_restore),
          title: const Text(S.restoreFromBackup),
          subtitle: const Text(S.restoreFromBackupHelp),
          onTap: _busy ? null : () => _run(() => restoreFromBackup(context, ref)),
        ),
        if (safety != null)
          ListTile(
            key: const Key('undoRestore'),
            leading: const Icon(Icons.undo),
            title: const Text(S.undoLastRestore),
            subtitle: const Text(S.undoLastRestoreHelp),
            onTap: _busy ? null : () => _run(() => undoLastRestore(context, ref)),
          ),
        SwitchListTile(
          key: const Key('backupReminderSwitch'),
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text(S.backupReminder),
          subtitle: const Text(S.backupReminderHelp),
          value: reminderOn,
          onChanged: (on) async {
            try {
              await setBackupReminder(ref, on);
            } catch (e) {
              if (context.mounted) toastError(context, e);
            }
          },
        ),
        ListTile(
          key: const Key('backupReminderTest'),
          leading: const SizedBox(width: 24),
          title: const Text(S.sendTestReminder),
          onTap: () async {
            try {
              final notes = ref.read(notificationServiceProvider);
              if (!await notes.requestPermission()) {
                if (context.mounted) toast(context, S.notificationsBlocked);
                return;
              }
              await notes.show(
                S.backupReminderBanner,
                '${S.backupReminderNever} Open the app, Settings, Backup.',
                kind: NotificationKind.backupReminder,
              );
            } catch (e) {
              if (context.mounted) toastError(context, e);
            }
          },
        ),
      ],
    );
  }
}
