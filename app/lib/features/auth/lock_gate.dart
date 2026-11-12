import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bootstrap.dart';
import '../sync/device_choice_screen.dart';
import '../sync/join_shop_screen.dart';
import '../sync/sync_providers.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../backup/backup_actions.dart';
import '../billing/bill_controller.dart';
import 'lock_screen.dart';

/// Lets the app navigator be reset to the home screen when the app locks, so
/// the next person never lands on the previous person's screen.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Wraps the whole app (MaterialApp.builder). Shows the first-run PIN setup or
/// the lock screen until someone logs in, and locks again after the phone has
/// been in the background for the auto-lock time.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _maybeLock();
    }
  }

  Future<void> _maybeLock() async {
    final since = _pausedAt;
    _pausedAt = null;
    if (since == null || ref.read(currentUserProvider) == null) return;
    final minutes =
        await ref.read(settingsRepositoryProvider).autoLockMinutes();
    if (!mounted) return;
    if (DateTime.now().difference(since) >= Duration(minutes: minutes)) {
      lockApp(ProviderScope.containerOf(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    // A different person logging in starts with a clean bill.
    ref.listen(currentUserProvider, (prev, next) {
      if (next == null) return;
      if (_lastUserId != null && _lastUserId != next.id) {
        ref.invalidate(billProvider);
      }
      _lastUserId = next.id;
    });

    final session = ref.watch(sessionProvider);
    final user = ref.watch(currentUserProvider);
    return session.when(
      loading: () => const _Splash(),
      error:
          (e, _) =>
              e is DeviceChoiceNeeded
                  ? _Standalone(child: DeviceChoiceScreen(devices: e.devices))
                  : Center(child: Text('Could not open the database: $e')),
      data: (_) {
        final hasPin = ref.watch(ownerHasPinProvider);
        return hasPin.when(
          loading: () => const _Splash(),
          error: (e, _) => Center(child: Text('$e')),
          data: (has) {
            if (!has) return const _Standalone(child: _FirstRunPin());
            return SyncRunner(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Kept alive but hidden, so a short lock does not lose work.
                  Offstage(
                    offstage: user == null,
                    child: TickerMode(
                      enabled: user != null,
                      child: widget.child,
                    ),
                  ),
                  if (user == null) const _Standalone(child: LockScreen()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Locks the app now and returns the navigator to its first screen.
void lockApp(ProviderContainer container) {
  appNavigatorKey.currentState?.popUntil((r) => r.isFirst);
  container.read(currentUserProvider.notifier).lock();
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Colors.white,
    child: Center(child: CircularProgressIndicator()),
  );
}

/// Gives the lock and setup screens their own Navigator and Overlay (the gate
/// sits above the app's Navigator, so dialogs and snack bars need one here).
class _Standalone extends StatelessWidget {
  const _Standalone({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
    child: Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => child),
    ),
  );
}

class _FirstRunPin extends ConsumerWidget {
  const _FirstRunPin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NewPinScreen(
      title: S.setupPinTitle,
      help: S.setupPinHelp,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            key: const Key('firstRunRestore'),
            onPressed: () => restoreFromBackup(context, ref),
            child: const Text(S.restoreFromBackupFirstRun),
          ),
          TextButton(
            key: const Key('firstRunJoin'),
            onPressed:
                () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const JoinShopScreen()),
                ),
            child: const Text(S.joinShopFirstRun),
          ),
        ],
      ),
      onPin: (pin) async {
        final auth = ref.read(authRepositoryProvider);
        final owner = await auth.owner();
        await auth.setPin(owner.id, pin);
        ref.invalidate(ownerHasPinProvider);
        ref.invalidate(loginUsersProvider);
        ref
            .read(currentUserProvider.notifier)
            .login(await auth.getUser(owner.id));
      },
    );
  }
}
