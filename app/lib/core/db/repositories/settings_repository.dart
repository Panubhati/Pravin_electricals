import 'package:drift/drift.dart';

import '../../printing/upi_link.dart';
import '../app_database.dart';
import 'audit_repository.dart';
import 'data_check_models.dart';
import 'repo_context.dart';

/// Well-known setting keys.
class SettingKeys {
  static const openingCashPaise = 'opening_cash_paise';
  static const counterMaxDiscountPct = 'counter_max_discount_pct';
  static const autoLockMinutes = 'auto_lock_minutes';
  static const dailySummaryOn = 'daily_summary_on';
  static const dailySummaryHour = 'daily_summary_hour';
  static const dataCheckLast = 'data_check_last';
  static const lastBackupAt = 'last_backup_at';
  static const backupReminderOn = 'backup_reminder_on';
  static const upiId = 'upi_id';
  static const upiName = 'upi_name';
}

/// Shop settings with defaults. Changes are written through the outbox.
class SettingsRepository {
  SettingsRepository(this.ctx);
  final RepoContext ctx;

  static const defaultCounterMaxDiscountPct = 5;
  static const defaultAutoLockMinutes = 2;
  static const defaultSummaryHour = 21;

  Future<String?> get(String key) async {
    final row = await (ctx.db.select(ctx.db.appSettings)
          ..where((t) => t.shopId.equals(ctx.shopId) & t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<int> getInt(String key, int fallback) async =>
      int.tryParse(await get(key) ?? '') ?? fallback;

  Future<void> set(String key, String value) async {
    final now = ctx.clock();
    await ctx.db.transaction(() async {
      final existing = await (ctx.db.select(ctx.db.appSettings)
            ..where((t) => t.shopId.equals(ctx.shopId) & t.key.equals(key)))
          .getSingleOrNull();
      if (existing == null) {
        final id = ctx.newId();
        await ctx.insertRow(
          ctx.db.appSettings,
          AppSettingsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            key: key,
            value: value,
          ),
          'app_settings',
          id,
        );
      } else if (existing.value != value) {
        await (ctx.db.update(ctx.db.appSettings)
              ..where((t) => t.id.equals(existing.id)))
            .write(AppSettingsCompanion(value: Value(value), updatedAt: Value(now)));
        final after = await (ctx.db.select(ctx.db.appSettings)
              ..where((t) => t.id.equals(existing.id)))
            .getSingle();
        await ctx.recordOutbox('app_settings', existing.id, 'upsert', after.toJson());
      }
    });
  }

  Future<int> openingCashPaise() => getInt(SettingKeys.openingCashPaise, 0);
  Future<int> counterMaxDiscountPct() =>
      getInt(SettingKeys.counterMaxDiscountPct, defaultCounterMaxDiscountPct);
  Future<int> autoLockMinutes() =>
      getInt(SettingKeys.autoLockMinutes, defaultAutoLockMinutes);
  Future<bool> dailySummaryOn() async => (await get(SettingKeys.dailySummaryOn)) == '1';
  Future<int> dailySummaryHour() =>
      getInt(SettingKeys.dailySummaryHour, defaultSummaryHour);

  /// Where customers' UPI payments go, or null when no UPI ID is set. The name
  /// customers see defaults to [shopName].
  Future<UpiPayee?> upiPayee(String shopName) async {
    final vpa = (await get(SettingKeys.upiId))?.trim() ?? '';
    if (vpa.isEmpty) return null;
    final name = (await get(SettingKeys.upiName))?.trim() ?? '';
    return UpiPayee(vpa: vpa, name: name.isEmpty ? shopName : name);
  }

  /// Sets (or clears, with an empty [vpa]) the shop's UPI ID and payee name.
  /// This decides where customers' money goes, so every change is audited.
  Future<void> setUpi({required String vpa, String name = '', String? userId}) async {
    final id = vpa.trim();
    final payee = name.trim();
    if (id.isNotEmpty && !UpiLink.isValidVpa(id)) {
      throw DomainException('UPI ID should look like shop@bank.');
    }
    await ctx.db.transaction(() async {
      final beforeId = (await get(SettingKeys.upiId))?.trim() ?? '';
      final beforeName = (await get(SettingKeys.upiName))?.trim() ?? '';
      if (beforeId == id && beforeName == payee) return;
      await set(SettingKeys.upiId, id);
      await set(SettingKeys.upiName, payee);
      await AuditRepository(ctx).record(
        action: 'upi_changed',
        entity: 'shop',
        entityId: ctx.shopId,
        userId: userId,
        before: {'upiId': beforeId, 'upiName': beforeName},
        after: {'upiId': id, 'upiName': payee},
      );
    });
  }

  /// When the owner last made (or restored from) a backup, or null if never.
  Future<DateTime?> lastBackupAt() async {
    final ms = int.tryParse(await get(SettingKeys.lastBackupAt) ?? '');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastBackupAt(DateTime when) =>
      set(SettingKeys.lastBackupAt, '${when.millisecondsSinceEpoch}');

  /// The backup reminder is on unless the owner turned it off.
  Future<bool> backupReminderOn() async => (await get(SettingKeys.backupReminderOn)) != '0';

  /// What the last "Check my data" found, or null if it was never run.
  Future<DataCheckSummary?> dataCheckSummary() async =>
      DataCheckSummary.fromJson(await get(SettingKeys.dataCheckLast));

  Future<void> setDataCheckSummary(DataCheckSummary summary) =>
      set(SettingKeys.dataCheckLast, summary.toJson());
}
