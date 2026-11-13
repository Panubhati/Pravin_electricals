import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/reminder_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/reminders/reminder_sms.dart';

class FakeSms implements SmsSender {
  FakeSms({this.allowed = true, this.failFor = const {}});
  bool allowed;
  final Set<String> failFor;
  final sent = <(String, String)>[];
  @override
  Future<bool> hasPermission() async => allowed;
  @override
  Future<bool> requestPermission() async => allowed;
  @override
  Future<bool> send(String number, String text) async {
    if (failFor.contains(number)) return false;
    sent.add((number, text));
    return true;
  }
}

/// A11 automatic SMS: once a day, after the set hour, only on the phone where
/// it is switched on, capped, and every SMS sent is recorded.
void main() {
  late AppDatabase db;
  late ShopSession s;
  late ReminderRepository repo;
  late SettingsRepository settings;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db, clock: () => DateTime(2026, 11, 20, 9));
    repo = ReminderRepository(s.ctx);
    settings = SettingsRepository(s.ctx);
    await settings.set(SettingKeys.remindersOn, '1');
    await settings.set(SettingKeys.reminderSmsHere, '1');
  });
  tearDown(() => db.close());

  Future<void> customers(int n) async {
    for (var i = 0; i < n; i++) {
      final id = await PartyRepository(s.ctx).createParty(kind: 'customer', name: 'C$i', phone: '98765${i.toString().padLeft(5, '0')}');
      await LedgerRepository(s.ctx).addEntry(partyId: id, entryType: 'opening', amountPaise: 50000, ts: DateTime(2026, 10, 1));
    }
  }

  Future<ReminderSmsResult> run(FakeSms sms, DateTime now, {bool force = false}) => sendDueReminderSms(
        repo: repo, settings: settings, sms: sms, shopName: 'Pravin Electricals', deviceId: s.deviceId,
        now: now, force: force, gap: Duration.zero);

  test('before the set hour nothing is sent; after it, everyone due, once that day', () async {
    await customers(3);
    final sms = FakeSms();
    expect((await run(sms, DateTime(2026, 11, 20, 9))).ran, isFalse);
    final r = await run(sms, DateTime(2026, 11, 20, 11, 5));
    expect(r.sent, 3);
    expect(sms.sent.first.$2, startsWith('Namaskar C0,'));
    expect((await db.select(db.reminders).get()).map((x) => x.channel).toSet(), {'sms'});
    expect((await run(sms, DateTime(2026, 11, 20, 15))).ran, isFalse, reason: 'already ran today');
    expect(sms.sent, hasLength(3));
  });

  test('switched off for the shop, or not this phone: nothing', () async {
    await customers(1);
    final sms = FakeSms();
    await settings.set(SettingKeys.reminderSmsHere, '0');
    expect((await run(sms, DateTime(2026, 11, 20, 12))).ran, isFalse);
    await settings.set(SettingKeys.reminderSmsHere, '1');
    await settings.set(SettingKeys.remindersOn, '0');
    expect((await run(sms, DateTime(2026, 11, 20, 12))).ran, isFalse);
    expect(sms.sent, isEmpty);
  });

  test('without SMS permission nothing is sent and the day is not used up', () async {
    await customers(1);
    final sms = FakeSms(allowed: false);
    expect((await run(sms, DateTime(2026, 11, 20, 12))).ran, isFalse);
    sms.allowed = true;
    expect((await run(sms, DateTime(2026, 11, 20, 13))).sent, 1);
  });

  test('a failed SMS is not recorded, so that customer is tried again next time', () async {
    await customers(2);
    final sms = FakeSms(failFor: {'919876500000'});
    final r = await run(sms, DateTime(2026, 11, 20, 12));
    expect(r.sent, 1);
    expect(r.failed, 1);
    expect(await db.select(db.reminders).get(), hasLength(1));
  });

  test('no more than 25 a day', () async {
    await customers(30);
    final r = await run(FakeSms(), DateTime(2026, 11, 20, 12));
    expect(r.sent, maxReminderSmsPerDay);
  });

  test('"Send now" ignores the hour', () async {
    await customers(1);
    expect((await run(FakeSms(), DateTime(2026, 11, 20, 8), force: true)).sent, 1);
  });
}
