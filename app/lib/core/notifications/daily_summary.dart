import '../db/repositories/reports_repository.dart';
import '../money.dart';

/// The text of the evening notification. It is built from the same numbers as
/// the dashboard, so the two can never disagree.
class DailySummary {
  const DailySummary(this.title, this.body);
  final String title;
  final String body;

  static DailySummary from(String shopName, DashboardData d) {
    final bills = d.today.billCount;
    final parts = <String>[
      'Sales ${Money.format(d.today.totalPaise)} ($bills ${bills == 1 ? 'bill' : 'bills'})',
      'Cash in hand ${Money.format(d.cash.closingPaise)}',
      'Customers owe ${Money.format(d.totalDuePaise)}',
    ];
    final low = d.lowStockCount + d.negativeStockCount;
    if (low > 0) parts.add('$low ${low == 1 ? 'item needs' : 'items need'} restocking');
    return DailySummary("Today at $shopName", parts.join('  •  '));
  }
}

/// Shows a notification on the phone. Faked in tests.
abstract class NotificationService {
  /// Asks for permission to show notifications (Android 13 and later).
  /// Returns true when allowed.
  Future<bool> requestPermission();

  Future<void> show(String title, String body, {NotificationKind kind = NotificationKind.dailySummary});
}

/// The notifications this app can show (each has its own channel on the phone).
enum NotificationKind { dailySummary, backupReminder }

/// Runs the summary once a day. Faked in tests.
abstract class SummaryScheduler {
  /// Schedules the summary for about [hour]:00 every day (replacing any earlier time).
  Future<void> schedule(int hour);
  Future<void> cancel();
}

/// How long from [now] until the next [hour]:00.
Duration delayUntilHour(DateTime now, int hour) {
  var next = DateTime(now.year, now.month, now.day, hour);
  if (!next.isAfter(now)) next = DateTime(now.year, now.month, now.day + 1, hour);
  return next.difference(now);
}
