import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../db/app_database.dart';
import '../db/connection.dart';
import '../bootstrap.dart';
import '../db/repositories/reports_repository.dart';
import '../db/repositories/settings_repository.dart';
import 'daily_summary.dart';

const _channelId = 'daily_summary';
const _taskName = 'dailySummary';
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
  Future<void> show(String title, String body) async {
    await _init();
    await _plugin.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily summary',
          channelDescription: "Today's sales, cash and dues",
          importance: Importance.defaultImportance,
          styleInformation: BigTextStyleInformation(''),
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
/// database itself, builds the summary and shows it, unless it was switched off.
@pragma('vm:entry-point')
void summaryCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return true;
    final db = AppDatabase(openShopDatabase());
    try {
      final session = await ensureShopSession(db);
      final on = await SettingsRepository(session.ctx).dailySummaryOn();
      if (!on) return true;
      final data = await ReportsRepository(session.ctx).dashboard();
      final s = DailySummary.from(session.shop.name, data);
      await DeviceNotificationService().show(s.title, s.body);
      return true;
    } finally {
      await db.close();
    }
  });
}

/// Call once at start-up (Android only).
Future<void> initBackgroundWork() =>
    Workmanager().initialize(summaryCallbackDispatcher);
