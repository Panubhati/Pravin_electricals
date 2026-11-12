import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/repositories/settings_repository.dart';
import '../../core/money.dart';
import '../../core/notifications/daily_summary.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../audit/audit_screen.dart';
import '../backup/backup_actions.dart';
import '../backup/backup_screen.dart';
import '../datacheck/data_check_screen.dart';
import '../reports/reports_providers.dart';
import '../sync/phones_screen.dart';
import '../sync/sync_providers.dart';
import 'shop_details_screen.dart';
import 'staff_screen.dart';

/// All the settings the owner can change. Counter staff never see this.
final settingsValuesProvider = FutureProvider.autoDispose<SettingsValues>((ref) async {
  final s = ref.watch(settingsRepositoryProvider);
  return SettingsValues(
    openingCash: await s.openingCashPaise(),
    discountPct: await s.counterMaxDiscountPct(),
    autoLock: await s.autoLockMinutes(),
    summaryOn: await s.dailySummaryOn(),
    summaryHour: await s.dailySummaryHour(),
  );
});

class SettingsValues {
  const SettingsValues({
    required this.openingCash,
    required this.discountPct,
    required this.autoLock,
    required this.summaryOn,
    required this.summaryHour,
  });
  final int openingCash;
  final int discountPct;
  final int autoLock;
  final bool summaryOn;
  final int summaryHour;
}

String _hourLabel(int h) {
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12 ${h < 12 ? 'AM' : 'PM'}';
}

Future<String?> _ask(
  BuildContext context, {
  required String title,
  required String initial,
  String? help,
  String? prefix,
  String? suffix,
  bool decimal = false,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => ValueDialog(
        title: title,
        initial: initial,
        help: help,
        prefix: prefix,
        suffix: suffix,
        decimal: decimal,
      ),
    );

/// Saves one setting and refreshes what depends on it.
Future<void> _save(BuildContext context, WidgetRef ref, String key, String value) async {
  try {
    await ref.read(settingsRepositoryProvider).set(key, value);
    ref.invalidate(settingsValuesProvider);
    ref.invalidate(discountLimitProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(cashPositionProvider);
    if (context.mounted) toast(context, S.settingSaved);
  } catch (e) {
    if (context.mounted) toastError(context, e);
  }
}

/// A titled white card holding a group of rows, with thin lines between them.
class _Group extends StatelessWidget {
  const _Group(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: SectionTitle(title)),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  children[i],
                ],
              ]),
            ),
          ],
        ),
      );
}

/// One settings row: icon, title, an optional one-line note, and the current
/// value (or just an arrow) on the right. Long text is cut, never wrapped.
class _Row extends StatelessWidget {
  const _Row({
    required this.rowKey,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleKey,
    this.value,
    this.onTap,
  });
  final Key rowKey;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Key? subtitleKey;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTile(
      key: rowKey,
      leading: Icon(icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, key: subtitleKey, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (value != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(value!,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: text.bodyMedium?.copyWith(color: AppPalette.muted)),
          ),
        const Icon(Icons.chevron_right, color: AppPalette.muted),
      ]),
      onTap: onTap,
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(settingsValuesProvider);
    final session = ref.watch(sessionProvider).valueOrNull;
    final phones = ref.watch(phonesProvider).valueOrNull;
    final lastBackup = ref.watch(lastBackupProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: values.when(
        loading: () => const SkeletonList(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (v) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Group(S.settingsShop, [
              _Row(
                rowKey: const Key('settingShop'),
                icon: Icons.storefront_outlined,
                title: S.shopDetails,
                subtitle: session?.shop.name ?? S.settingsShopDetailsSub,
                onTap: () => _open(context, const ShopDetailsScreen()),
              ),
              _Row(
                rowKey: const Key('settingUpi'),
                icon: Icons.qr_code_2,
                title: S.upiSetting,
                value: ref.watch(upiPayeeProvider).valueOrNull?.vpa ?? S.upiNotSet,
                onTap: () => _editUpi(context, ref),
              ),
              _Row(
                rowKey: const Key('settingPhones'),
                icon: Icons.phonelink_ring_outlined,
                title: S.settingsPhonesRow,
                value: phones == null || phones.length < 2 ? S.settingsPhonesOne : S.settingsPhonesMany(phones.length),
                onTap: () => _open(context, const PhonesScreen()),
              ),
              _Row(
                rowKey: const Key('settingStaff'),
                icon: Icons.badge_outlined,
                title: S.staffAndPins,
                subtitle: S.settingsStaffSub,
                onTap: () => _open(context, const StaffScreen()),
              ),
            ]),
            _Group(S.settingsBillingRules, [
              _Row(
                rowKey: const Key('settingDiscount'),
                icon: Icons.percent,
                title: S.counterDiscountLimit,
                value: '${v.discountPct}%',
                onTap: () async {
                  final text = await _ask(context,
                      title: S.counterDiscountLimit, initial: '${v.discountPct}', help: S.counterDiscountHelp, suffix: '%');
                  if (text == null || !context.mounted) return;
                  final n = int.tryParse(text.trim());
                  if (n == null || n < 0 || n > 100) {
                    toast(context, S.enterWholeNumber0to100);
                    return;
                  }
                  await _save(context, ref, SettingKeys.counterMaxDiscountPct, '$n');
                },
              ),
              _Row(
                rowKey: const Key('settingOpeningCash'),
                icon: Icons.payments_outlined,
                title: S.openingCash,
                value: Money.format(v.openingCash),
                onTap: () async {
                  final text = await _ask(context,
                      title: S.openingCash,
                      initial: rupeesForField(v.openingCash),
                      help: S.openingCashHelp,
                      prefix: '₹ ',
                      decimal: true);
                  if (text == null || !context.mounted) return;
                  try {
                    final paise = text.trim().isEmpty ? 0 : Money.parse(text);
                    await _save(context, ref, SettingKeys.openingCashPaise, '$paise');
                  } on FormatException {
                    if (context.mounted) toast(context, S.enterAmount);
                  }
                },
              ),
              _Row(
                rowKey: const Key('settingAutoLock'),
                icon: Icons.lock_clock,
                title: S.autoLock,
                value: v.autoLock == 0 ? 'Always' : '${v.autoLock} min',
                onTap: () async {
                  final text = await _ask(context,
                      title: S.autoLock, initial: '${v.autoLock}', help: S.autoLockHelp, suffix: 'min');
                  if (text == null || !context.mounted) return;
                  final n = int.tryParse(text.trim());
                  if (n == null || n < 0 || n > 120) {
                    toast(context, S.enterWholeNumber0to120);
                    return;
                  }
                  await _save(context, ref, SettingKeys.autoLockMinutes, '$n');
                },
              ),
              _Row(
                rowKey: const Key('settingAlerts'),
                icon: Icons.notifications_outlined,
                title: S.settingsAlertsTitle,
                value: v.summaryOn ? _hourLabel(v.summaryHour) : S.settingsOff,
                onTap: () => _open(context, const AlertsScreen()),
              ),
            ]),
            _Group(S.settingsData, [
              _Row(
                rowKey: const Key('settingBackup'),
                icon: Icons.cloud_upload_outlined,
                title: S.settingsBackupTitle,
                subtitle:
                    lastBackup == null ? S.settingsNeverBackedUp : '${S.lastBackupLabel}: ${backupTime(lastBackup)}',
                onTap: () => _open(context, const BackupScreen()),
              ),
              _Row(
                rowKey: const Key('settingDataCheck'),
                icon: Icons.fact_check_outlined,
                title: S.dataCheckTitle,
                subtitle: dataCheckSubtitle(ref.watch(dataCheckSummaryProvider).valueOrNull),
                subtitleKey: const Key('dataCheckSubtitle'),
                onTap: () => _open(context, const DataCheckScreen()),
              ),
              _Row(
                rowKey: const Key('settingAudit'),
                icon: Icons.history,
                title: S.auditLog,
                subtitle: S.settingsAuditSub,
                onTap: () => _open(context, const AuditScreen()),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _editUpi(BuildContext context, WidgetRef ref) async {
    final current = ref.read(upiPayeeProvider).valueOrNull;
    final r = await showDialog<({String vpa, String name})>(
      context: context,
      builder: (_) => _UpiDialog(vpa: current?.vpa ?? '', name: current?.name ?? ''),
    );
    if (r == null) return;
    try {
      final shopName = ref.read(sessionProvider).requireValue.shop.name;
      // The payee name defaults to the shop name; do not store it when unchanged.
      await ref.read(settingsRepositoryProvider).setUpi(
            vpa: r.vpa,
            name: r.name.trim() == shopName ? '' : r.name,
            userId: ref.read(actingUserIdProvider),
          );
      ref.invalidate(upiPayeeProvider);
      if (context.mounted) toast(context, S.upiSaved);
    } catch (e) {
      if (context.mounted) toastError(context, e);
    }
  }
}

/// Settings, Daily summary: the evening notification and its time.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(settingsValuesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAlertsTitle)),
      body: values.when(
        loading: () => const SkeletonList(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (v) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                SwitchListTile(
                  key: const Key('settingSummary'),
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text(S.dailySummary),
                  value: v.summaryOn,
                  onChanged: (on) async {
                    try {
                      if (on) {
                        final allowed = await ref.read(notificationServiceProvider).requestPermission();
                        if (!allowed) {
                          if (context.mounted) toast(context, S.notificationsBlocked);
                          return;
                        }
                        await ref.read(summarySchedulerProvider).schedule(v.summaryHour);
                      } else {
                        await ref.read(summarySchedulerProvider).cancel();
                      }
                      if (context.mounted) await _save(context, ref, SettingKeys.dailySummaryOn, on ? '1' : '0');
                    } catch (e) {
                      if (context.mounted) toastError(context, e);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  key: const Key('settingSummaryHour'),
                  leading: const Icon(Icons.schedule),
                  title: const Text(S.summaryTime),
                  trailing: Text(_hourLabel(v.summaryHour)),
                  onTap: () async {
                    final text = await _ask(context,
                        title: S.summaryTime, initial: '${v.summaryHour}', help: S.summaryTimeHelp, suffix: 'hour');
                    if (text == null || !context.mounted) return;
                    final n = int.tryParse(text.trim());
                    if (n == null || n < 0 || n > 23) {
                      toast(context, S.enterWholeNumber0to23);
                      return;
                    }
                    try {
                      if (v.summaryOn) await ref.read(summarySchedulerProvider).schedule(n);
                      if (context.mounted) await _save(context, ref, SettingKeys.dailySummaryHour, '$n');
                    } catch (e) {
                      if (context.mounted) toastError(context, e);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  key: const Key('summaryTest'),
                  leading: const Icon(Icons.send_outlined),
                  title: const Text(S.summaryTestNow),
                  onTap: () async {
                    try {
                      final allowed = await ref.read(notificationServiceProvider).requestPermission();
                      if (!allowed) {
                        if (context.mounted) toast(context, S.notificationsBlocked);
                        return;
                      }
                      final session = ref.read(sessionProvider).requireValue;
                      final data = await ref.read(reportsRepositoryProvider).dashboard();
                      final summary = DailySummary.from(session.shop.name, data);
                      await ref.read(notificationServiceProvider).show(summary.title, summary.body);
                    } catch (e) {
                      if (context.mounted) toastError(context, e);
                    }
                  },
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Text(S.dailySummaryHelp,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.muted)),
          ],
        ),
      ),
    );
  }
}

/// One-value dialog. Owns its controller so it is disposed with the dialog.
class ValueDialog extends StatefulWidget {
  const ValueDialog({
    super.key,
    required this.title,
    required this.initial,
    this.help,
    this.prefix,
    this.suffix,
    this.decimal = false,
  });
  final String title;
  final String initial;
  final String? help;
  final String? prefix;
  final String? suffix;
  final bool decimal;

  @override
  State<ValueDialog> createState() => _ValueDialogState();
}

class _ValueDialogState extends State<ValueDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.help != null) ...[
            Text(widget.help!),
            const SizedBox(height: 12),
          ],
          TextField(
            key: const Key('valueField'),
            controller: _c,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
            decoration: InputDecoration(
              prefixText: widget.prefix,
              suffixText: widget.suffix,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('valueSave'),
          onPressed: () => Navigator.pop(context, _c.text),
          child: const Text(S.save),
        ),
      ],
    );
  }
}

class _UpiDialog extends StatefulWidget {
  const _UpiDialog({required this.vpa, required this.name});
  final String vpa;
  final String name;

  @override
  State<_UpiDialog> createState() => _UpiDialogState();
}

class _UpiDialogState extends State<_UpiDialog> {
  late final TextEditingController _vpa = TextEditingController(text: widget.vpa);
  late final TextEditingController _name = TextEditingController(text: widget.name);

  @override
  void dispose() {
    _vpa.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(S.upiSetting),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(S.upiHelp),
            const SizedBox(height: 12),
            TextField(
              key: const Key('upiIdField'),
              controller: _vpa,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: S.upiId, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('upiNameField'),
              controller: _name,
              decoration: const InputDecoration(labelText: S.upiName, border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
          FilledButton(
            key: const Key('upiSave'),
            onPressed: () => Navigator.pop(context, (vpa: _vpa.text, name: _name.text)),
            child: const Text(S.save),
          ),
        ],
      );
}
