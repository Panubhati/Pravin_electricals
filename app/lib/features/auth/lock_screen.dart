import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/db/repositories/auth_repository.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../language/language_switch.dart';
import '../../shared/widgets.dart';
import 'pin_entry.dart';

/// Choose who you are, then enter the PIN. Nothing else is reachable until
/// this succeeds.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _userId;
  String? _message;

  Future<void> _submit(List<User> users, String pin) async {
    final user = users.firstWhere((u) => u.id == _userId);
    final result = await ref.read(authRepositoryProvider).verify(user.id, pin);
    if (!mounted) return;
    if (result.ok) {
      ref.read(currentUserProvider.notifier).login(user);
      return;
    }
    setState(() {
      _message = result.isLocked
          ? S.lockedWait(_secondsUntil(result))
          : S.wrongPin;
    });
  }

  int _secondsUntil(PinResult r) {
    final now = ref.read(sessionProvider).requireValue.ctx.clock();
    final s = r.lockedUntil!.difference(now).inSeconds;
    return s < 1 ? 1 : s;
  }

  Future<void> _forgot(User owner) async {
    final ok = await ref.read(deviceAuthProvider).confirm(S.forgotPinReason);
    if (!mounted) return;
    if (!ok) {
      toast(context, S.forgotPinFailed);
      return;
    }
    await Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => NewPinScreen(
        title: S.setupPinTitle,
        onPin: (pin) async {
          await ref.read(authRepositoryProvider).resetOwnerPin(pin);
          ref.read(currentUserProvider.notifier).login(owner);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(loginUsersProvider);
    return Scaffold(
      body: SafeArea(
        child: users.when(
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState('$e'),
          data: (list) {
            if (list.isEmpty) return EmptyState(S.noUsers);
            final selected = list.length == 1 ? list.first.id : _userId;
            if (_userId == null && selected != null) _userId = selected;
            final user = selected == null ? null : list.firstWhere((u) => u.id == selected);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LanguageSwitch(),
                    const SizedBox(height: 24),
                    const Icon(Icons.lock_outline, size: 40),
                    const SizedBox(height: 8),
                    Text(S.appTitle, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    if (list.length > 1)
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final u in list)
                            ChoiceChip(
                              key: Key('lockUser_${u.name}'),
                              label: Text(u.name),
                              selected: u.id == _userId,
                              onSelected: (_) => setState(() {
                                _userId = u.id;
                                _message = null;
                              }),
                            ),
                        ],
                      )
                    else
                      Text(list.first.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    if (user == null)
                      Text(S.lockTitle)
                    else ...[
                      PinEntry(
                        key: ValueKey(user.id),
                        title: S.enterPin,
                        message: _message,
                        onSubmit: (pin) => _submit(list, pin),
                      ),
                      if (user.role == 'owner')
                        TextButton(
                          key: const Key('forgotPin'),
                          onPressed: () => _forgot(user),
                          child: Text(S.forgotPin),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Enter a new PIN twice. Used for the first-run owner PIN and for recovery.
class NewPinScreen extends StatefulWidget {
  const NewPinScreen({super.key, required this.title, required this.onPin, this.help, this.footer});
  final String title;
  final String? help;

  /// Extra content below the PIN pad (the first-run screen offers Restore).
  final Widget? footer;

  /// Called once with the confirmed PIN.
  final Future<void> Function(String pin) onPin;

  @override
  State<NewPinScreen> createState() => _NewPinScreenState();
}

class _NewPinScreenState extends State<NewPinScreen> {
  String? _first;
  String? _message;

  Future<void> _entered(String pin) async {
    if (!AuthRepository.isValidPin(pin)) {
      setState(() => _message = S.pinRules);
      return;
    }
    if (_first == null) {
      setState(() {
        _first = pin;
        _message = null;
      });
      return;
    }
    if (_first != pin) {
      setState(() {
        _first = null;
        _message = S.pinMismatch;
      });
      return;
    }
    try {
      await widget.onPin(pin);
      if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _first = null;
          _message = errorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.help != null) ...[
                  Text(widget.help!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                ],
                PinEntry(
                  key: ValueKey(_first == null),
                  title: _first == null ? S.newPin : S.confirmPin,
                  message: _message,
                  submitLabel: S.unlock,
                  onSubmit: _entered,
                ),
                if (widget.footer != null) ...[
                  const SizedBox(height: 8),
                  widget.footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
