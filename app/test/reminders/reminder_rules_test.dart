import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/reminder_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/shared/strings.dart';

/// A11 payment reminder rules, with dates set by hand. Settings: first
/// reminder after 15 days owed, then every 7 days, nothing under ₹100.
void main() {
  late AppDatabase db;
  late ShopSession s;
  late DateTime now;
  late RepoContext ctx;
  late ReminderRepository reminders;

  DateTime day(int d) => DateTime(2026, 11, d, 10);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = day(20);
    s = await ensureShopSession(db, clock: () => now);
    ctx = s.ctx;
    reminders = ReminderRepository(ctx);
    final settings = SettingsRepository(ctx);
    await settings.set(SettingKeys.remindersOn, '1');
  });
  tearDown(() => db.close());

  Future<String> customer(String name, {String? phone = '9876543210', int owes = 50000, required DateTime since}) async {
    final id = await PartyRepository(ctx).createParty(kind: 'customer', name: name, phone: phone);
    await LedgerRepository(ctx).addEntry(partyId: id, entryType: 'opening', amountPaise: owes, ts: since);
    return id;
  }

  test('owed 15 days or more: due; less: not yet', () async {
    await customer('Old', since: day(5)); // 15 days
    await customer('New', since: day(10)); // 10 days
    final due = await reminders.due(now: now);
    expect(due.map((d) => d.party.name), ['Old']);
    expect(due.single.daysOwed, 15);
    expect(due.single.number, '919876543210');
  });

  test('after a reminder, not again for 7 days, then again', () async {
    await customer('Ramesh', since: day(1));
    final first = (await reminders.due(now: now)).single;
    await reminders.record(first, channel: 'sms');
    now = day(26);
    expect(await reminders.due(now: now), isEmpty, reason: '6 days later');
    now = day(27);
    expect((await reminders.due(now: now)).single.party.name, 'Ramesh');
  });

  test('customers switched off, without a mobile number, or owing under the minimum are left out', () async {
    final off = await customer('NoReminders', since: day(1));
    await reminders.setRemindersOff(off, true);
    await customer('NoPhone', phone: null, since: day(1));
    await customer('Landline', phone: '0202345678', since: day(1));
    await customer('Small', owes: 5000, since: day(1)); // ₹50
    await customer('Due', since: day(1));
    expect((await reminders.due(now: now)).map((d) => d.party.name), ['Due']);
  });

  test('a customer who paid drops off; part payment counts from the oldest bill still unpaid', () async {
    final id = await customer('Paid', since: day(1));
    await LedgerRepository(ctx).addEntry(partyId: id, entryType: 'payment', amountPaise: -50000, ts: day(18));
    final part = await customer('Part', owes: 30000, since: day(1));
    await LedgerRepository(ctx).addEntry(partyId: part, entryType: 'opening', amountPaise: 20000, ts: day(12));
    await LedgerRepository(ctx).addEntry(partyId: part, entryType: 'payment', amountPaise: -30000, ts: day(15));
    // Part's 1 Nov bill is fully paid; the 12 Nov one (8 days) is not old enough yet.
    expect(await reminders.due(now: now), isEmpty);
  });

  test('skip today hides a customer on this phone until tomorrow', () async {
    final id = await customer('Ramesh', since: day(1));
    await reminders.skipToday(id, now: now);
    expect(await reminders.due(now: now), isEmpty);
    expect(await reminders.due(now: now, includeSkipped: true), hasLength(1));
    now = day(21);
    expect(await reminders.due(now: now), hasLength(1));
  });

  test('reminders off for the shop: settings say so (sending code checks it)', () async {
    await SettingsRepository(ctx).set(SettingKeys.remindersOn, '0');
    expect((await reminders.settings()).on, isFalse);
  });

  test('the message is polite, in the bill language, with English dates and the UPI ID', () async {
    await customer('Ramesh', owes: 1258000, since: day(1));
    final settings = SettingsRepository(ctx);
    await settings.setUpi(vpa: 'pravin@okhdfc');
    final r = (await reminders.due(now: now)).single;
    final en = await reminders.message(r, shopName: 'Pravin Electricals');
    expect(en, startsWith('Namaskar Ramesh, ₹12,580.00 is due at Pravin Electricals since 1 Nov 2026.'));
    // A13: the UPI ID as text (upi:// links are never tappable in WhatsApp or SMS).
    expect(en, contains('Please pay when convenient to UPI ID pravin@okhdfc. Thank you.'));
    expect(en, isNot(contains('upi://')));
    expect(await reminders.payLink(r, shopName: 'Pravin Electricals'), contains('am=12580.00'));
    await settings.setBillLanguage(AppLang.mr);
    final mr = await reminders.message(r, shopName: 'Pravin Electricals');
    expect(mr, startsWith('नमस्कार Ramesh, Pravin Electricals कडे 1 Nov 2026 पासून ₹12,580.00 बाकी आहे.'));
    expect(mr, contains('(UPI ID: pravin@okhdfc)'));
  });

  test('no UPI ID set: no UPI line and no QR', () async {
    await customer('Ramesh', owes: 1258000, since: day(1));
    final r = (await reminders.due(now: now)).single;
    final en = await reminders.message(r, shopName: 'Pravin Electricals');
    expect(en, endsWith('Please pay when convenient. Thank you.'));
    expect(await reminders.payLink(r, shopName: 'Pravin Electricals'), isNull);
  });

  test('a reminder recorded (as if on the other phone) is in the log and the audit', () async {
    final id = await customer('Ramesh', since: day(1));
    final r = (await reminders.due(now: now)).single;
    await reminders.record(r, channel: 'whatsapp', deviceId: 'phone-b', createdBy: s.userId);
    final log = await reminders.forParty(id);
    expect(log.single.channel, 'whatsapp');
    expect(log.single.amountPaise, 50000);
    final audit = await (db.select(db.auditLog)..where((a) => a.action.equals('payment_reminder'))).get();
    expect(audit, hasLength(1));
  });
}
