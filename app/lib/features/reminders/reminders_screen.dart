import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/repositories/reminder_repository.dart';
import '../../core/reminders/reminder_sms.dart';
import '../../core/money.dart';
import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../parties/party_detail_screen.dart';
import 'reminder_settings_screen.dart';

/// Sends SMS through the SIM. Tests replace it.
final smsSenderProvider = Provider<SmsSender>((ref) => const DeviceSmsSender());

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(sessionProvider).requireValue.ctx),
);

final reminderSettingsProvider = FutureProvider.autoDispose<ReminderSettings>(
  (ref) => ref.watch(reminderRepositoryProvider).settings(),
);

/// Customers due for a payment reminder today (empty while reminders are off).
final dueRemindersProvider = FutureProvider.autoDispose<List<DueReminder>>((
  ref,
) async {
  final repo = ref.watch(reminderRepositoryProvider);
  if (!(await repo.settings()).on) return const [];
  return repo.due();
});

/// The day's list: tap WhatsApp to open the chat with the message ready (the
/// person presses Send), or skip someone for today. Automatic SMS, when
/// switched on, also uses this list (A11).
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider).valueOrNull;
    final due = ref.watch(dueRemindersProvider);
    final owner = ref.watch(permissionsProvider).canOpenSettings;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.remindersTitle),
        actions: [
          if (owner)
            IconButton(
              key: const Key('reminderSettings'),
              tooltip: S.remindersSettingsTitle,
              icon: const Icon(Icons.tune),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const ReminderSettingsScreen(),
                  ),
                );
                ref.invalidate(reminderSettingsProvider);
                ref.invalidate(dueRemindersProvider);
              },
            ),
        ],
      ),
      body:
          settings != null && !settings.on
              ? EmptyState(
                S.remindersOffInfo,
                icon: Icons.notifications_off_outlined,
              )
              : due.when(
                loading: () => const SkeletonList(),
                error:
                    (e, _) =>
                        EmptyState(errorMessage(e), icon: Icons.error_outline),
                data:
                    (list) =>
                        list.isEmpty
                            ? EmptyState(
                              S.remindersNoneDue,
                              icon: Icons.check_circle_outline,
                            )
                            : ListView(
                              padding: const EdgeInsets.only(bottom: 24),
                              children: [
                                CardGroup(
                                  indent: 16,
                                  children: [for (final r in list) _DueTile(r)],
                                ),
                              ],
                            ),
              ),
    );
  }
}

class _DueTile extends ConsumerWidget {
  const _DueTile(this.r);
  final DueReminder r;

  Future<void> _whatsapp(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(reminderRepositoryProvider);
    final session = ref.read(sessionProvider).requireValue;
    final text = await repo.message(r, shopName: session.shop.name);
    final opened = await ref
        .read(billSharerProvider)
        .whatsAppText(number: r.number, text: text);
    if (!context.mounted) return;
    if (!opened) {
      toast(context, S.whatsAppMissing);
      return;
    }
    await repo.record(
      r,
      channel: 'whatsapp',
      deviceId: session.deviceId,
      createdBy: ref.read(actingUserIdProvider),
    );
    ref.invalidate(dueRemindersProvider);
    if (context.mounted) toast(context, S.reminderSent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Padding(
      key: Key('due_${r.party.id}'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap:
                () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => PartyDetailScreen(partyId: r.party.id),
                  ),
                ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    r.party.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Money.format(r.amountPaise),
                  style: AppText.amount(
                    context,
                  ).copyWith(color: AppPalette.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            S.reminderOwesSince(formatDate(r.oldestDue), r.daysOwed),
            style: text.bodySmall?.copyWith(color: AppPalette.muted),
          ),
          if (r.lastReminded != null)
            Text(
              S.reminderLast(formatDateTime(r.lastReminded!)),
              style: text.bodySmall?.copyWith(color: AppPalette.muted),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilledButton.icon(
                key: Key('remindWhatsApp_${r.party.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.green,
                  minimumSize: const Size(0, 40),
                ),
                onPressed: () => _whatsapp(context, ref),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(S.whatsapp),
              ),
              TextButton(
                key: Key('remindSkip_${r.party.id}'),
                onPressed: () async {
                  await ref
                      .read(reminderRepositoryProvider)
                      .skipToday(r.party.id);
                  ref.invalidate(dueRemindersProvider);
                },
                child: Text(S.reminderSkipToday),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A note on the owner's Home while customers are due for a reminder.
class RemindersDueNote extends ConsumerWidget {
  const RemindersDueNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(dueRemindersProvider).valueOrNull?.length ?? 0;
    if (n == 0) return const SizedBox.shrink();
    return Card(
      key: const Key('remindersDueNote'),
      color: AppPalette.blueTint,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.transparent,
        leading: const Icon(
          Icons.notifications_active_outlined,
          color: AppPalette.blue,
        ),
        title: Text(S.remindersDueNote(n)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const RemindersScreen()),
          );
          ref.invalidate(dueRemindersProvider);
        },
      ),
    );
  }
}
