import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/parties/party_detail_screen.dart';
import 'package:shop_app/features/reminders/reminder_settings_screen.dart';
import 'package:shop_app/features/reminders/reminders_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';
import 'package:shop_app/shared/strings.dart';

import '../features/bills_sharing_test.dart' show FakeSharer;
import '../helpers/app_harness.dart';

void main() {
  final noFinder = peerFinderProvider.overrideWithValue(null);

  Future<String> oldDebt(Harness h, WidgetTester t, {bool on = true}) async {
    return (await t.runAsync(() async {
      final ctx = h.session.ctx;
      if (on) await SettingsRepository(ctx).set(SettingKeys.remindersOn, '1');
      final id = await PartyRepository(ctx).createParty(kind: 'customer', name: 'Ramesh Patil', phone: '9876543210');
      await LedgerRepository(ctx).addEntry(
          partyId: id, entryType: 'opening', amountPaise: 1258000, ts: DateTime.now().subtract(const Duration(days: 30)));
      return id;
    }))!;
  }

  harnessTest('the list shows who is due; WhatsApp opens with the message and records the reminder', (tester, h) async {
    final id = await oldDebt(h, tester);
    final sharer = FakeSharer();
    await h.pump(tester, const RemindersScreen(), overrides: [noFinder, billSharerProvider.overrideWithValue(sharer)]);
    expect(find.text('Ramesh Patil'), findsOneWidget);
    await tester.tap(find.byKey(Key('remindWhatsApp_$id')));
    await settle(tester);
    expect(sharer.texts.single.$1, '919876543210');
    expect(sharer.texts.single.$2, startsWith('Namaskar Ramesh Patil, ₹12,580.00 is due'));
    expect(find.text(S.remindersNoneDue), findsOneWidget, reason: 'reminded, so off the list for 7 days');
    final log = await tester.runAsync(() => h.db.select(h.db.reminders).get());
    expect(log!.single.channel, 'whatsapp');
  }, sample: false);

  harnessTest('skip today takes a customer off the list', (tester, h) async {
    final id = await oldDebt(h, tester);
    await h.pump(tester, const RemindersScreen(), overrides: [noFinder]);
    await tester.tap(find.byKey(Key('remindSkip_$id')));
    await settle(tester);
    expect(find.text('Ramesh Patil'), findsNothing);
  }, sample: false);

  harnessTest('with reminders off the list says so', (tester, h) async {
    await oldDebt(h, tester, on: false);
    await h.pump(tester, const RemindersScreen(), overrides: [noFinder]);
    expect(find.text(S.remindersOffInfo), findsOneWidget);
  }, sample: false);

  harnessTest('the customer page switch leaves them out of reminders', (tester, h) async {
    final id = await oldDebt(h, tester);
    await h.pump(tester, PartyDetailScreen(partyId: id), overrides: [noFinder]);
    await tester.tap(find.byKey(const Key('remindersOffSwitch')));
    await settle(tester);
    final p = await tester.runAsync(() => (h.db.select(h.db.parties)..where((x) => x.id.equals(id))).getSingle());
    expect(p!.remindersOff, isTrue);
  }, sample: false);

  harnessTest('settings: switching on, and the message preview', (tester, h) async {
    await h.pump(tester, const ReminderSettingsScreen(), overrides: [noFinder]);
    await tester.tap(find.byKey(const Key('remindersOn')));
    await settle(tester);
    final on = await tester.runAsync(() => SettingsRepository(h.session.ctx).get(SettingKeys.remindersOn));
    expect(on, '1');
    final preview = tester.widget<Text>(find.byKey(const Key('reminderPreviewText'))).data!;
    expect(preview, contains('₹12,580.00'));
  }, sample: false);
}
