import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/repositories/settings_repository.dart';
import '../../core/money.dart';
import '../../core/notifications/daily_summary.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../audit/audit_screen.dart';
import '../reports/reports_providers.dart';
import 'shop_details_screen.dart';
import 'staff_screen.dart';

/// All the settings the owner can change. Counter staff never see this.
final _settingsValuesProvider = FutureProvider.autoDispose<_Values>((ref) async {
  final s = ref.watch(settingsRepositoryProvider);
  return _Values(
    openingCash: await s.openingCashPaise(),
    discountPct: await s.counterMaxDiscountPct(),
    autoLock: await s.autoLockMinutes(),
    summaryOn: await s.dailySummaryOn(),
    summaryHour: await s.dailySummaryHour(),
  );
});

class _Values {
  const _Values({
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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(_settingsValuesProvider);
    final settings = ref.read(settingsRepositoryProvider);

    Future<void> save(String key, String value) async {
      try {
        await settings.set(key, value);
        ref.invalidate(_settingsValuesProvider);
        ref.invalidate(discountLimitProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(cashPositionProvider);
        if (context.mounted) toast(context, S.settingSaved);
      } catch (e) {
        if (context.mounted) toastError(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsTitle)),
      body: values.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (v) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SectionTitle(S.settingsShop),
            ),
            ListTile(
              key: const Key('settingShop'),
              leading: const Icon(Icons.storefront_outlined),
              title: const Text(S.shopDetails),
              subtitle: const Text('Name, GSTIN, address, state, phone, bill terms'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const ShopDetailsScreen())),
            ),
            ListTile(
              key: const Key('settingUpi'),
              leading: const Icon(Icons.qr_code_2),
              title: const Text(S.upiSetting),
              subtitle: const Text(S.upiHelp),
              trailing: Text(ref.watch(upiPayeeProvider).valueOrNull?.vpa ?? S.upiNotSet),
              onTap: () async {
                final current = ref.read(upiPayeeProvider).valueOrNull;
                final r = await showDialog<({String vpa, String name})>(
                  context: context,
                  builder: (_) => _UpiDialog(vpa: current?.vpa ?? '', name: current?.name ?? ''),
                );
                if (r == null) return;
                try {
                  final shopName = ref.read(sessionProvider).requireValue.shop.name;
                  // The payee name defaults to the shop name; do not store it when unchanged.
                  await settings.setUpi(
                    vpa: r.vpa,
                    name: r.name.trim() == shopName ? '' : r.name,
                    userId: ref.read(actingUserIdProvider),
                  );
                  ref.invalidate(upiPayeeProvider);
                  if (context.mounted) toast(context, S.upiSaved);
                } catch (e) {
                  if (context.mounted) toastError(context, e);
                }
              },
            ),
            ListTile(
              key: const Key('settingStaff'),
              leading: const Icon(Icons.badge_outlined),
              title: const Text(S.staffAndPins),
              subtitle: const Text('Add counter staff, reset PINs'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .push<void>(MaterialPageRoute(builder: (_) => const StaffScreen())),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SectionTitle(S.settingsRules),
            ),
            ListTile(
              key: const Key('settingDiscount'),
              leading: const Icon(Icons.percent),
              title: const Text(S.counterDiscountLimit),
              subtitle: const Text(S.counterDiscountHelp),
              trailing: Text('${v.discountPct}%'),
              onTap: () async {
                final text = await _ask(context,
                    title: S.counterDiscountLimit,
                    initial: '${v.discountPct}',
                    help: S.counterDiscountHelp,
                    suffix: '%');
                if (text == null) return;
                final n = int.tryParse(text.trim());
                if (n == null || n < 0 || n > 100) {
                  if (context.mounted) toast(context, S.enterWholeNumber0to100);
                  return;
                }
                await save(SettingKeys.counterMaxDiscountPct, '$n');
              },
            ),
            ListTile(
              key: const Key('settingOpeningCash'),
              leading: const Icon(Icons.payments_outlined),
              title: const Text(S.openingCash),
              subtitle: const Text(S.openingCashHelp),
              trailing: Text(Money.format(v.openingCash)),
              onTap: () async {
                final text = await _ask(context,
                    title: S.openingCash,
                    initial: rupeesForField(v.openingCash),
                    help: S.openingCashHelp,
                    prefix: '₹ ',
                    decimal: true);
                if (text == null) return;
                try {
                  final paise = text.trim().isEmpty ? 0 : Money.parse(text);
                  await save(SettingKeys.openingCashPaise, '$paise');
                } on FormatException {
                  if (context.mounted) toast(context, S.enterAmount);
                }
              },
            ),
            ListTile(
              key: const Key('settingAutoLock'),
              leading: const Icon(Icons.lock_clock),
              title: const Text(S.autoLock),
              subtitle: const Text(S.autoLockHelp),
              trailing: Text(v.autoLock == 0 ? 'Always' : '${v.autoLock} min'),
              onTap: () async {
                final text = await _ask(context,
                    title: S.autoLock, initial: '${v.autoLock}', help: S.autoLockHelp, suffix: 'min');
                if (text == null) return;
                final n = int.tryParse(text.trim());
                if (n == null || n < 0 || n > 120) {
                  if (context.mounted) toast(context, S.enterWholeNumber0to120);
                  return;
                }
                await save(SettingKeys.autoLockMinutes, '$n');
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SectionTitle(S.settingsAlerts),
            ),
            SwitchListTile(
              key: const Key('settingSummary'),
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text(S.dailySummary),
              subtitle: const Text(S.dailySummaryHelp),
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
                  await save(SettingKeys.dailySummaryOn, on ? '1' : '0');
                } catch (e) {
                  if (context.mounted) toastError(context, e);
                }
              },
            ),
            ListTile(
              key: const Key('settingSummaryHour'),
              leading: const SizedBox(width: 24),
              title: const Text(S.summaryTime),
              trailing: Text(_hourLabel(v.summaryHour)),
              onTap: () async {
                final text = await _ask(context,
                    title: S.summaryTime,
                    initial: '${v.summaryHour}',
                    help: S.summaryTimeHelp,
                    suffix: 'hour');
                if (text == null) return;
                final n = int.tryParse(text.trim());
                if (n == null || n < 0 || n > 23) {
                  if (context.mounted) toast(context, S.enterWholeNumber0to23);
                  return;
                }
                try {
                  if (v.summaryOn) await ref.read(summarySchedulerProvider).schedule(n);
                  await save(SettingKeys.dailySummaryHour, '$n');
                } catch (e) {
                  if (context.mounted) toastError(context, e);
                }
              },
            ),
            ListTile(
              key: const Key('summaryTest'),
              leading: const SizedBox(width: 24),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SectionTitle(S.settingsRecords),
            ),
            ListTile(
              key: const Key('settingAudit'),
              leading: const Icon(Icons.history),
              title: const Text(S.auditLog),
              subtitle: const Text(S.auditHelp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .push<void>(MaterialPageRoute(builder: (_) => const AuditScreen())),
            ),
            const SizedBox(height: 24),
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
