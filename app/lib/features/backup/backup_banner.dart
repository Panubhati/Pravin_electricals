import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backup/backup_reminder_rules.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import 'backup_actions.dart';
import 'backup_reminder.dart';
import '../../shared/theme.dart';

/// What the banner and the reminder need to know right now. It re-reads when
/// the last-backup time or the reminder switch changes.
final backupReminderStateProvider = FutureProvider.autoDispose<BackupReminderState>((ref) {
  ref.watch(lastBackupProvider);
  ref.watch(backupReminderOnProvider);
  final session = ref.watch(sessionProvider).requireValue;
  return backupReminderState(ref.watch(databaseProvider), session);
});

/// A note at the top of the owner's home screen when it is time to back up.
class BackupBanner extends ConsumerStatefulWidget {
  const BackupBanner({super.key});

  @override
  ConsumerState<BackupBanner> createState() => _BackupBannerState();
}

class _BackupBannerState extends ConsumerState<BackupBanner> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupReminderStateProvider).valueOrNull;
    if (state == null || !state.shouldRemind) return const SizedBox.shrink();
    return Card(
      key: const Key('backupBanner'),
      color: AppPalette.amberTint,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppPalette.amber.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppPalette.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(S.backupReminderBanner, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(state.message, key: const Key('backupBannerText')),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('backupBannerButton'),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await backUpNow(context, ref);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: const Text(S.backupNowShort),
            ),
          ],
        ),
      ),
    );
  }
}
