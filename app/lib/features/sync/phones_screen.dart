import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../../core/sync/pairing.dart';
import '../../core/sync/phones.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/format.dart';
import '../../shared/messages_mr.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../audit/audit_screen.dart';
import 'sync_providers.dart';

/// Colour and words for a sync state.
({Color color, String label}) syncLook(SyncHealth s) => switch (s) {
      SyncHealth.off => (color: AppPalette.muted, label: S.syncOff),
      SyncHealth.searching => (color: AppPalette.muted, label: S.syncSearching),
      SyncHealth.synced => (color: AppPalette.green, label: S.syncSynced),
      SyncHealth.problem => (color: AppPalette.red, label: S.syncProblem),
    };

/// A small dot on Home showing whether the other phone is in sync. Hidden
/// until a second phone is paired.
class SyncStatusDot extends ConsumerWidget {
  const SyncStatusDot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(syncServiceProvider);
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: service.status,
      builder: (context, status, _) {
        if (status.state == SyncHealth.off) return const SizedBox.shrink();
        final look = syncLook(status.state);
        return IconButton(
          key: const Key('syncDot'),
          tooltip: look.label,
          onPressed: ref.watch(permissionsProvider).canOpenSettings
              ? () => Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const PhonesScreen()))
              : () => service.syncNow(),
          icon: Stack(
            alignment: Alignment.bottomRight,
            children: [
              const Icon(Icons.phonelink_ring_outlined),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: look.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Settings, Phones and Wi-Fi sync: the shop's phones, their sync state, and
/// adding or removing a phone (owner only).
class PhonesScreen extends ConsumerWidget {
  const PhonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(syncServiceProvider);
    final phones = ref.watch(phonesProvider);
    final clashes = ref.watch(recentClashesProvider).valueOrNull ?? 0;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(S.phonesTitle)),
      body: phones.when(
        loading: () => const SkeletonList(),
        error: (e, _) => EmptyState(errorMessage(e), icon: Icons.error_outline),
        data: (rows) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ValueListenableBuilder<SyncStatus>(
              valueListenable: service.status,
              builder: (context, status, _) => _StatusCard(status: status, onSyncNow: () async {
                await service.start();
                await service.syncNow();
                ref.invalidate(phonesProvider);
              }),
            ),
            const SizedBox(height: 16),
            SectionTitle(S.phonesSection),
            Card(
              child: Column(children: [
                for (final r in rows) _PhoneTile(row: r),
              ]),
            ),
            if (rows.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(S.phonesNoneYet, style: text.bodyMedium?.copyWith(color: AppPalette.muted)),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('addPhone'),
              onPressed: () async {
                await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const AddPhoneScreen()));
                ref.invalidate(phonesProvider);
              },
              icon: const Icon(Icons.add),
              label: Text(S.phonesAdd),
            ),
            if (clashes > 0) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  key: const Key('syncClashes'),
                  leading: const Icon(Icons.call_split, color: AppPalette.amber),
                  title: Text(S.phonesClashes),
                  subtitle: Text(S.phonesClashesHelp(clashes)),
                  onTap: () =>
                      Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const AuditScreen())),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.onSyncNow});
  final SyncStatus status;
  final Future<void> Function() onSyncNow;

  @override
  Widget build(BuildContext context) {
    final look = syncLook(status.state);
    final text = Theme.of(context).textTheme;
    final skewMinutes = status.clockSkew == null ? 0 : status.clockSkew!.inMinutes.abs();
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: look.color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(look.label, key: const Key('syncStateText'), style: text.titleMedium)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TextButton.icon(
                key: const Key('syncNow'),
                onPressed: onSyncNow,
                icon: const Icon(Icons.sync, size: 18),
                label: Text(S.phonesSyncNow),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          status.lastSyncAt == null ? S.phonesNeverSynced : S.phonesLastSync(formatDateTime(status.lastSyncAt!)),
          style: text.bodySmall?.copyWith(color: AppPalette.muted),
        ),
        if (status.state == SyncHealth.searching) ...[
          const SizedBox(height: 6),
          Text(S.syncSearchingHelp, style: text.bodySmall),
        ],
        if (status.state == SyncHealth.problem && status.message != null) ...[
          const SizedBox(height: 6),
          Text(localizeMessage(status.message!), style: text.bodySmall?.copyWith(color: AppPalette.red)),
        ],
        if (skewMinutes >= 2) ...[
          const SizedBox(height: 6),
          Text(S.phonesClockWarn(skewMinutes), style: text.bodySmall?.copyWith(color: AppPalette.amber)),
        ],
      ]),
    );
  }
}

class _PhoneTile extends ConsumerWidget {
  const _PhoneTile({required this.row});
  final PhoneRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = row.device;
    final last = row.peer?.lastSyncAt;
    return ListTile(
      key: Key('phone_${d.invoiceSeriesPrefix}'),
      leading: CircleAvatar(
        backgroundColor: AppPalette.blue.withValues(alpha: 0.1),
        child: Text(d.invoiceSeriesPrefix, style: const TextStyle(color: AppPalette.blue, fontWeight: FontWeight.w700)),
      ),
      title: Text(phoneName(d)),
      subtitle: Text(row.isThisPhone
          ? S.phonesThisPhone
          : last == null
              ? S.phonesNeverSynced
              : S.phonesLastSync(formatDateTime(last))),
      trailing: PopupMenuButton<String>(
        key: Key('phoneMenu_${d.invoiceSeriesPrefix}'),
        onSelected: (v) => v == 'rename' ? _rename(context, ref) : _remove(context, ref),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'rename', child: Text(S.phonesRename)),
          if (!row.isThisPhone)
            PopupMenuItem(key: Key('removePhone_${d.invoiceSeriesPrefix}'), value: 'remove', child: Text(S.phonesRemove)),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: phoneName(row.device));
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(S.phonesRenameTitle),
        content: TextField(key: const Key('phoneName'), controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(S.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text), child: Text(S.save)),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(setupRepositoryProvider).renameDevice(row.device.id, name);
      ref.invalidate(phonesProvider);
    } catch (e) {
      if (context.mounted) toastError(context, e);
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(S.phonesRemoveConfirm(phoneName(row.device))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(S.cancel)),
          FilledButton(
            key: const Key('removePhoneConfirm'),
            style: FilledButton.styleFrom(backgroundColor: AppPalette.red),
            onPressed: () => Navigator.pop(c, true),
            child: Text(S.phonesRemove),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(setupRepositoryProvider).removeDevice(row.device.id);
      await ref.read(auditRepositoryProvider).record(
            action: 'phone_removed',
            entity: 'device',
            entityId: row.device.id,
            userId: ref.read(actingUserIdProvider),
            before: {'label': row.device.label, 'series': row.device.invoiceSeriesPrefix},
          );
      await SyncStore(ref.read(databaseProvider)).removePeer(row.device.id);
      ref.invalidate(phonesProvider);
      if (context.mounted) toast(context, S.phonesRemoved);
    } catch (e) {
      if (context.mounted) toastError(context, e);
    }
  }
}

/// Shows the pairing QR until a new phone joins (or 10 minutes pass).
class AddPhoneScreen extends ConsumerStatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  ConsumerState<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends ConsumerState<AddPhoneScreen> {
  PairingInvite? _invite;
  String? _error;
  Set<String> _peersBefore = {};
  Timer? _watch;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final service = ref.read(syncServiceProvider);
    try {
      _peersBefore = {for (final p in await service.store.peers()) p.deviceId};
      final invite = await service.invite();
      if (!mounted) return;
      setState(() => _invite = invite);
      // The new phone calls in right after it joins: then this screen is done.
      _watch = Timer.periodic(const Duration(seconds: 1), (_) async {
        final now = await service.store.peers();
        final joined = now.where((p) => !_peersBefore.contains(p.deviceId)).toList();
        if (joined.isEmpty || !mounted) return;
        _watch?.cancel();
        ref.invalidate(phonesProvider);
        toast(context, S.addPhoneJoined(joined.first.label.isEmpty ? S.theNewPhone : joined.first.label));
        Navigator.of(context).pop();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().contains('Wi-Fi') ? S.addPhoneNoWifi : errorMessage(e));
    }
  }

  @override
  void dispose() {
    _watch?.cancel();
    final service = ref.read(syncServiceProvider);
    service.store.cancelPairing();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final invite = _invite;
    return Scaffold(
      appBar: AppBar(title: Text(S.addPhoneTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            EmptyState(_error!, icon: Icons.wifi_off)
          else if (invite == null)
            const Padding(padding: EdgeInsets.all(48), child: LoadingView())
          else ...[
            Text(S.addPhoneSteps, style: text.bodyLarge),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.line),
                ),
                child: QrImageView(
                  key: const ValueKey('pairingQr'),
                  data: invite.encode(),
                  size: 240,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(S.addPhoneExpires, style: text.bodySmall?.copyWith(color: AppPalette.muted), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
