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

  test('no backup yet, reminder on by default', () async {
    expect(await settings.lastBackupAt(), isNull);
    expect(await settings.backupReminderOn(), isTrue);
  });

  test('the last backup time round-trips', () async {
    final when = DateTime(2026, 11, 12, 21, 30);
    await settings.setLastBackupAt(when);
    expect(await settings.lastBackupAt(), when);
  });

  test('the reminder can be turned off and on', () async {
    await settings.set(SettingKeys.backupReminderOn, '0');
    expect(await settings.backupReminderOn(), isFalse);
    await settings.set(SettingKeys.backupReminderOn, '1');
    expect(await settings.backupReminderOn(), isTrue);
  });
}
