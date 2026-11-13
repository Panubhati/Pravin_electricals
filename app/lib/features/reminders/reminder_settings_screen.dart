import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/reminder_repository.dart';
import '../../core/db/repositories/settings_repository.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../../core/reminders/reminder_sms.dart';
import '../../core/sharing/phone_number.dart';
import '../settings/settings_screen.dart' show ValueDialog;
import 'reminders_screen.dart';

/// Settings, Payment reminders (owner): on/off, after how many days, how
/// often, the smallest amount, and a preview of the message (A11).
class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  Future<void> _number(
    BuildContext context,
    WidgetRef ref, {
    required String key,
    required String title,
    required int current,
    required int min,
    String? help,
  }) async {
    final text = await showDialog<String>(
      context: context,
      builder:
          (_) => ValueDialog(
            title: title,
            initial: '$current',
            help: help,
            suffix: S.reminderDaysField,
          ),
    );
    if (text == null || !context.mounted) return;
    final n = int.tryParse(text.trim());
    if (n == null || n < min || n > 365) {
      toast(context, S.enterWholeNumber0to120);
      return;
    }
    await ref.read(settingsRepositoryProvider).set(key, '$n');
    ref.invalidate(reminderSettingsProvider);
    ref.invalidate(dueRemindersProvider);
  }

  Future<void> _minimum(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final text = await showDialog<String>(
      context: context,
      builder:
          (_) => ValueDialog(
            title: S.reminderMinimum,
            initial: rupeesForField(current),
            prefix: '₹ ',
            decimal: true,
          ),
    );
    if (text == null || !context.mounted) return;
    try {
      final paise = text.trim().isEmpty ? 0 : Money.parse(text);
      await ref
          .read(settingsRepositoryProvider)
          .set(SettingKeys.reminderMinPaise, '$paise');
      ref.invalidate(reminderSettingsProvider);
      ref.invalidate(dueRemindersProvider);
    } on FormatException {
      if (context.mounted) toast(context, S.enterAmount);
    }
  }

  static String _hour(int h) =>
      '${h % 12 == 0 ? 12 : h % 12} ${h < 12 ? 'AM' : 'PM'}';

  Future<void> _testSms(BuildContext context, WidgetRef ref) async {
    final number = await showDialog<String>(
      context: context,
      builder: (_) => ValueDialog(title: S.reminderSmsTestNumber, initial: ''),
    );
    final to = whatsappNumber(number);
    if (to == null || !context.mounted) return;
    final sms = ref.read(smsSenderProvider);
    if (!await sms.requestPermission()) {
      if (context.mounted) toast(context, S.reminderSmsNoPermission);
      return;
    }
    final session = ref.read(sessionProvider).requireValue;
    final text = await ref
        .read(reminderRepositoryProvider)
        .message(_sample(session.shopId), shopName: session.shop.name);
    final ok = await sms.send(to, text);
    if (context.mounted) {
      toast(context, ok ? S.reminderSmsTestSent : S.reminderSmsNotSent);
    }
  }

  Future<void> _sendNow(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider).requireValue;
    final r = await sendDueReminderSms(
      repo: ref.read(reminderRepositoryProvider),
      settings: ref.read(settingsRepositoryProvider),
      sms: ref.read(smsSenderProvider),
      shopName: session.shop.name,
      deviceId: session.deviceId,
      force: true,
    );
    ref.invalidate(dueRemindersProvider);
    if (context.mounted) toast(context, S.reminderSmsNowResult(r.sent));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reminderSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(S.remindersSettingsTitle)),
      body: async.when(
        loading: () => const SkeletonList(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data:
            (s) => ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                CardGroup(
                  children: [
                    SwitchListTile(
                      key: const Key('remindersOn'),
                      secondary: const Icon(
                        Icons.notifications_active_outlined,
                      ),
                      title: Text(S.remindersTurnOn),
                      value: s.on,
                      onChanged: (on) async {
                        await ref
                            .read(settingsRepositoryProvider)
                            .set(SettingKeys.remindersOn, on ? '1' : '0');
                        ref.invalidate(reminderSettingsProvider);
                        ref.invalidate(dueRemindersProvider);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    S.remindersHelp,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppPalette.muted),
                  ),
                ),
                CardGroup(
                  children: [
                    ListTile(
                      key: const Key('reminderFirst'),
                      leading: const Icon(Icons.hourglass_bottom),
                      title: Text(S.reminderFirstAfter),
                      trailing: Text(S.reminderDaysValue(s.firstAfterDays)),
                      onTap:
                          () => _number(
                            context,
                            ref,
                            key: SettingKeys.reminderFirstDays,
                            title: S.reminderFirstAfter,
                            current: s.firstAfterDays,
                            min: 1,
                            help: S.reminderDaysHelp,
                          ),
                    ),
                    ListTile(
                      key: const Key('reminderRepeat'),
                      leading: const Icon(Icons.repeat),
                      title: Text(S.reminderRepeatEvery),
                      trailing: Text(S.reminderDaysValue(s.repeatEveryDays)),
                      onTap:
                          () => _number(
                            context,
                            ref,
                            key: SettingKeys.reminderRepeatDays,
                            title: S.reminderRepeatEvery,
                            current: s.repeatEveryDays,
                            min: 1,
                          ),
                    ),
                    ListTile(
                      key: const Key('reminderMinimum'),
                      leading: const Icon(Icons.currency_rupee),
                      title: Text(S.reminderMinimum),
                      trailing: Text(Money.format(s.minimumPaise)),
                      onTap: () => _minimum(context, ref, s.minimumPaise),
                    ),
                  ],
                ),
                CardGroup(
                  title: S.reminderSmsSection,
                  children: [
                    SwitchListTile(
                      key: const Key('reminderSmsHere'),
                      secondary: const Icon(Icons.sms_outlined),
                      title: Text(S.reminderSmsHere),
                      value: s.smsFromThisPhone,
                      onChanged: (on) async {
                        if (on &&
                            !await ref
                                .read(smsSenderProvider)
                                .requestPermission()) {
                          if (context.mounted) {
                            toast(context, S.reminderSmsNoPermission);
                          }
                          return;
                        }
                        await ref
                            .read(settingsRepositoryProvider)
                            .set(SettingKeys.reminderSmsHere, on ? '1' : '0');
                        ref.invalidate(reminderSettingsProvider);
                      },
                    ),
                    ListTile(
                      key: const Key('reminderSmsHour'),
                      leading: const Icon(Icons.schedule),
                      title: Text(S.reminderSmsTime),
                      trailing: Text(_hour(s.smsHour)),
                      onTap: () async {
                        final text = await showDialog<String>(
                          context: context,
                          builder:
                              (_) => ValueDialog(
                                title: S.reminderSmsTime,
                                initial: '${s.smsHour}',
                                help: S.summaryTimeHelp,
                                suffix: 'hour',
                              ),
                        );
                        final n = int.tryParse(text?.trim() ?? '');
                        if (n == null || n < 0 || n > 23) return;
                        await ref
                            .read(settingsRepositoryProvider)
                            .set(SettingKeys.reminderSmsHour, '$n');
                        ref.invalidate(reminderSettingsProvider);
                      },
                    ),
                    ListTile(
                      key: const Key('reminderSmsTest'),
                      leading: const Icon(Icons.send_outlined),
                      title: Text(S.reminderSmsTest),
                      onTap: () => _testSms(context, ref),
                    ),
                    if (s.on && s.smsFromThisPhone)
                      ListTile(
                        key: const Key('reminderSmsNow'),
                        leading: const Icon(Icons.outgoing_mail),
                        title: Text(S.reminderSmsSendNow),
                        onTap: () => _sendNow(context, ref),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    S.reminderSmsHelp,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppPalette.muted),
                  ),
                ),
                const _Preview(),
              ],
            ),
      ),
    );
  }
}

/// The message a customer would get, with sample values.
class _Preview extends ConsumerWidget {
  const _Preview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).requireValue;
    final sample = _sample(session.shopId);
    return FutureBuilder<String>(
      future: ref
          .read(reminderRepositoryProvider)
          .message(sample, shopName: session.shop.name),
      builder:
          (context, snap) => CardGroup(
            title: S.reminderPreview,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snap.data ?? '',
                  key: const Key('reminderPreviewText'),
                ),
              ),
            ],
          ),
    );
  }
}

/// A made-up customer for the preview and the test SMS.
DueReminder _sample(String shopId) => DueReminder(
  party: Party(
    id: 'sample',
    shopId: shopId,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    kind: 'customer',
    name: S.reminderSampleName,
    tier: 'retail',
    creditLimitPaise: 0,
    remindersOff: false,
  ),
  amountPaise: 1258000,
  oldestDue: DateTime.now().subtract(const Duration(days: 20)),
  daysOwed: 20,
  number: '',
);
