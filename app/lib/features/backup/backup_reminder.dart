import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/settings_repository.dart';
import '../../core/providers.dart';

/// Whether the backup reminder is on (it is, until the owner turns it off).
final backupReminderOnProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).backupReminderOn(),
);

/// Turns the reminder on or off and starts or stops the daily check.
Future<void> setBackupReminder(WidgetRef ref, bool on) async {
  await ref.read(settingsRepositoryProvider).set(SettingKeys.backupReminderOn, on ? '1' : '0');
  ref.invalidate(backupReminderOnProvider);
}
