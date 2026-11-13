import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import 'pin_entry.dart';

/// Whether this phone has a fingerprint (or face) saved.
final canUseFingerprintProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(deviceAuthProvider).canUseFingerprint(),
);

/// Who unlocks with a fingerprint on this phone.
final fingerprintOnProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final fp = ref.watch(fingerprintLoginProvider);
  final users = await ref.watch(loginUsersProvider.future);
  return {
    for (final u in users)
      if (await fp.isOn(u)) u.id,
  };
});

/// Settings, Fingerprint unlock (A12): each person on this phone, with a switch.
/// Switching someone on needs their PIN, then their finger.
class FingerprintScreen extends ConsumerWidget {
  const FingerprintScreen({super.key});

  Future<void> _switch(BuildContext context, WidgetRef ref, User user, bool on) async {
    final fp = ref.read(fingerprintLoginProvider);
    if (on) {
      final pinOk = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => _ConfirmPin(user: user)),
      );
      if (pinOk != true) return;
      if (!await ref.read(deviceAuthProvider).fingerprint(S.fingerprintReason)) {
        if (context.mounted) toast(context, S.fingerprintFailed);
        return;
      }
    }
    await fp.setOn(user, on);
    ref.invalidate(fingerprintOnProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final can = ref.watch(canUseFingerprintProvider);
    final users = ref.watch(loginUsersProvider);
    final on = ref.watch(fingerprintOnProvider).valueOrNull ?? const {};
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(S.fingerprintTitle)),
      body: can.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState('$e'),
        data: (can) => users.when(
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState('$e'),
          data: (list) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(S.fingerprintHelp, style: text.bodyMedium),
              const SizedBox(height: 12),
              if (!can)
                Card(
                  child: ListTile(
                    key: const Key('fingerprintNone'),
                    leading: const Icon(Icons.info_outline, color: AppPalette.amber),
                    title: Text(S.fingerprintNoSensor),
                  ),
                ),
              Card(
                child: Column(children: [
                  for (final u in list)
                    SwitchListTile(
                      key: Key('fingerprint_${u.name}'),
                      secondary: const Icon(Icons.fingerprint),
                      title: Text(u.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      value: on.contains(u.id),
                      onChanged: can || on.contains(u.id) ? (v) => _switch(context, ref, u, v) : null,
                    ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(S.fingerprintWarning, style: text.bodySmall?.copyWith(color: AppPalette.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The person types their own PIN before fingerprint is switched on for them.
class _ConfirmPin extends ConsumerStatefulWidget {
  const _ConfirmPin({required this.user});
  final User user;

  @override
  ConsumerState<_ConfirmPin> createState() => _ConfirmPinState();
}

class _ConfirmPinState extends ConsumerState<_ConfirmPin> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.fingerprintTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: PinEntry(
              title: S.fingerprintEnterPinFor(widget.user.name),
              message: _message,
              onSubmit: (pin) async {
                final r = await ref.read(authRepositoryProvider).verify(widget.user.id, pin);
                if (!context.mounted) return;
                if (r.ok) {
                  Navigator.pop(context, true);
                } else {
                  setState(() => _message = r.isLocked ? S.fingerprintTryLater : S.wrongPin);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
