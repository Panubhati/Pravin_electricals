import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository((await ensureShopSession(db)).ctx);
  });
  tearDown(() => db.close());

  test('defaults apply until a value is set', () async {
    expect(await settings.openingCashPaise(), 0);
    expect(await settings.counterMaxDiscountPct(), 5);
    expect(await settings.autoLockMinutes(), 2);
    expect(await settings.dailySummaryOn(), isFalse);
    expect(await settings.dailySummaryHour(), 21);
  });

  test('set stores, overwrites in place, and reaches the outbox', () async {
    await settings.set(SettingKeys.openingCashPaise, '500000');
    await settings.set(SettingKeys.openingCashPaise, '700000');
    await settings.set(SettingKeys.openingCashPaise, '700000'); // no change
    expect(await settings.openingCashPaise(), 700000);
    expect(await db.select(db.appSettings).get(), hasLength(1));
    final outbox = (await db.select(db.outbox).get()).where((o) => o.entity == 'app_settings');
    expect(outbox, hasLength(2)); // insert + one real update
  });
}
