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

    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.muted);

    Widget group(String title, List<Widget> rows, {String? note}) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: SectionTitle(title)),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  rows[i],
                ],
              ]),
            ),
            if (note != null) Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 0), child: Text(note, style: small)),
          ]),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group(S.backupGroupBackUp, [
          ListTile(
            key: const Key('backupNow'),
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text(S.backUpNow),
            subtitle: Text(
              lastAt == null
                  ? '${S.lastBackupLabel}: ${S.neverBackedUp}'
                  : '${S.lastBackupLabel}: ${backupTime(lastAt)}',
              key: const Key('lastBackupText'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: lastAt == null ? const TextStyle(color: AppPalette.red) : null,
            ),
            trailing: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right, color: AppPalette.muted),
            onTap: _busy ? null : () => _run(() => backUpNow(context, ref)),
          ),
        ], note: '${S.backUpNowHelp} ${S.backupFileWarning}'),
        group(S.backupGroupRestore, [
          ListTile(
            key: const Key('restoreBackup'),
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text(S.restoreFromBackup),
            trailing: const Icon(Icons.chevron_right, color: AppPalette.muted),
            onTap: _busy ? null : () => _run(() => restoreFromBackup(context, ref)),
          ),
          if (safety != null)
            ListTile(
              key: const Key('undoRestore'),
              leading: const Icon(Icons.undo),
              title: const Text(S.undoLastRestore),
              trailing: const Icon(Icons.chevron_right, color: AppPalette.muted),
              onTap: _busy ? null : () => _run(() => undoLastRestore(context, ref)),
            ),
        ], note: S.restoreFromBackupHelp),
        group(S.backupGroupReminder, [
          SwitchListTile(
            key: const Key('backupReminderSwitch'),
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text(S.backupReminder),
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
            leading: const Icon(Icons.send_outlined),
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
                  '${S.backupReminderNever} Open the app, Settings, Backup and restore.',
                  kind: NotificationKind.backupReminder,
                );
              } catch (e) {
                if (context.mounted) toastError(context, e);
              }
            },
          ),
        ], note: S.backupReminderHelp),
      ],
    );
  }
}
