import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

/// Well-known setting keys.
class SettingKeys {
  static const openingCashPaise = 'opening_cash_paise';
  static const counterMaxDiscountPct = 'counter_max_discount_pct';
  static const autoLockMinutes = 'auto_lock_minutes';
  static const dailySummaryOn = 'daily_summary_on';
  static const dailySummaryHour = 'daily_summary_hour';
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
        await ctx.recordOutbox('app_settings', existing.id, 'upsert', {
          'id': existing.id,
          'key': key,
          'value': value,
        });
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
}
