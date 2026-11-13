import 'package:shop_sms/shop_sms.dart';

import '../db/repositories/reminder_repository.dart';
import '../db/repositories/settings_repository.dart';

/// Sends SMS through the phone's SIM. Tests use a fake.
abstract class SmsSender {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<bool> send(String number, String text);
}

class DeviceSmsSender implements SmsSender {
  const DeviceSmsSender();
  @override
  Future<bool> hasPermission() => ShopSms.hasPermission();
  @override
  Future<bool> requestPermission() => ShopSms.requestPermission();
  @override
  Future<bool> send(String number, String text) => ShopSms.send(number, text);
}

class ReminderSmsResult {
  const ReminderSmsResult({this.sent = 0, this.failed = 0, this.ran = false});
  final int sent;
  final int failed;

  /// False when nothing was due to run (switched off, too early, already ran today).
  final bool ran;
}

/// At most this many SMS a day: Android blocks apps that send many quickly.
const maxReminderSmsPerDay = 25;

/// Sends today's payment reminder SMS, once a day, from the phone where
/// automatic SMS is switched on, after the chosen hour (A11). Each SMS sent is
/// recorded (and synced), so nobody gets a second one within the repeat interval.
/// [force] skips the once-a-day and hour checks (the owner tapped "Send now").
Future<ReminderSmsResult> sendDueReminderSms({
  required ReminderRepository repo,
  required SettingsRepository settings,
  required SmsSender sms,
  required String shopName,
  required String deviceId,
  DateTime? now,
  bool force = false,
  Duration gap = const Duration(seconds: 3),
}) async {
  final when = now ?? DateTime.now();
  final s = await repo.settings();
  if (!s.on || !s.smsFromThisPhone) return const ReminderSmsResult();
  final today = '${when.year}-${when.month}-${when.day}';
  if (!force) {
    if (when.hour < s.smsHour) return const ReminderSmsResult();
    if (await settings.get(SettingKeys.reminderSmsLastDay) == today) return const ReminderSmsResult();
  }
  if (!await sms.hasPermission()) return const ReminderSmsResult();
  // Marked first, so a crash half way never sends the same SMS twice in a day.
  await settings.set(SettingKeys.reminderSmsLastDay, today);

  var sent = 0, failed = 0;
  final due = await repo.due(now: when);
  for (final r in due.take(maxReminderSmsPerDay)) {
    final text = await repo.message(r, shopName: shopName);
    if (await sms.send(r.number, text)) {
      await repo.record(r, channel: 'sms', deviceId: deviceId);
      sent++;
    } else {
      failed++;
    }
    if (gap > Duration.zero) await Future<void>.delayed(gap);
  }
  return ReminderSmsResult(sent: sent, failed: failed, ran: true);
}
