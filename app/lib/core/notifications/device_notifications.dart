import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../db/app_database.dart';
import '../db/connection.dart';
import '../bootstrap.dart';
import '../backup/database_location.dart';
import '../sync/device_identity.dart';
import '../backup/backup_reminder_rules.dart';
import '../db/repositories/reports_repository.dart';
import '../db/repositories/settings_repository.dart';
import 'daily_summary.dart';

const _channelId = 'daily_summary';
const _backupChannelId = 'backup_reminder';
const _taskName = 'dailySummary';
const _backupTaskName = 'backupCheck';
const _backupUniqueName = 'backup-check';
const _uniqueName = 'daily-summary';

/// Shows notifications with the Android notification system.
class DeviceNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> show(String title, String body,
      {NotificationKind kind = NotificationKind.dailySummary}) async {
    await _init();
    final reminder = kind == NotificationKind.backupReminder;
    await _plugin.show(
      reminder ? 2 : 1,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          reminder ? _backupChannelId : _channelId,
          reminder ? 'Backup reminder' : 'Daily summary',
          channelDescription:
              reminder ? 'Reminds you to back up your shop data' : "Today's sales, cash and dues",
          importance: Importance.defaultImportance,
          styleInformation: const BigTextStyleInformation(''),
        ),
      ),
    );
  }
}

/// Schedules the summary with Android WorkManager: one run a day, at about the
/// chosen hour (Android may delay it a little to save battery).
class WorkmanagerSummaryScheduler implements SummaryScheduler {
  @override
  Future<void> schedule(int hour) => Workmanager().registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: const Duration(hours: 24),
        initialDelay: delayUntilHour(DateTime.now(), hour),
        existingWorkPolicy: ExistingWorkPolicy.update,
      );

  @override
  Future<void> cancel() => Workmanager().cancelByUniqueName(_uniqueName);
}

/// Called by Android in the background (the app need not be open). Opens the
/// database itself, and runs whichever job was asked for.
@pragma('vm:entry-point')
void summaryCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName && task != _backupTaskName) return true;
    final db = AppDatabase(openShopDatabase());
    try {
      // A phone that has not been set up yet has nothing to report, and the
      // background job must never create the shop itself.
      final shops = await db.customSelect('SELECT COUNT(*) AS n FROM shops').getSingle();
      if ((shops.data['n'] as int) == 0) return true;
      final ShopSession session;
      try {
        session = await ensureShopSession(db,
            identity: FileDeviceIdentity(const DeviceDatabaseLocation()));
      } on DeviceChoiceNeeded {
        return true; // the owner has not said which phone this is yet
      }

      if (task == _taskName) {
        if (!await SettingsRepository(session.ctx).dailySummaryOn()) return true;
        final data = await ReportsRepository(session.ctx).dashboard();
        final s = DailySummary.from(session.shop.name, data);
        await DeviceNotificationService().show(s.title, s.body);
      } else {
        final state = await backupReminderState(db, session);
        if (state.shouldRemind) {
          await DeviceNotificationService().show(
            'Back up your shop data',
            '${state.message} Open the app, Settings, Backup.',
            kind: NotificationKind.backupReminder,
          );
        }
      }
      return true;
    } finally {
      await db.close();
    }
  });
}

/// Call once at start-up (Android only). Also makes sure the daily backup check
/// is scheduled (about 10 AM). It does nothing when already scheduled, and each
/// run looks at the reminder setting, so turning the reminder off needs no cancelling.
Future<void> initBackgroundWork() async {
  await Workmanager().initialize(summaryCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _backupUniqueName,
    _backupTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: delayUntilHour(DateTime.now(), 10),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
