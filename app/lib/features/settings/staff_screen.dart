import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';

final _allUsersProvider = FutureProvider.autoDispose<List<User>>(
  (ref) => ref.watch(authRepositoryProvider).allUsers(),
);

/// Counter staff and PINs. Only the owner gets here.
class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(_allUsersProvider);
    ref.invalidate(loginUsersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(_allUsersProvider);
    final me = ref.watch(currentUserProvider);
    final auth = ref.read(authRepositoryProvider);

    Future<void> setPin(User u, {String? title}) async {
      final pin = await showDialog<String>(
        context: context,
        builder: (_) => _PinDialog(title: title ?? '${S.resetPin}: ${u.name}'),
      );
      if (pin == null) return;
      try {
        await auth.setPin(u.id, pin, byUserId: me?.id);
        _refresh(ref);
        if (context.mounted) toast(context, S.pinChanged);
      } catch (e) {
        if (context.mounted) toastError(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text(S.staffAndPins)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addStaff'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text(S.addStaff),
        onPressed: () async {
          final r = await showDialog<({String name, String pin})>(
            context: context,
            builder: (_) => const _StaffDialog(),
          );
          if (r == null) return;
          try {
            await auth.createCounterUser(name: r.name, pin: r.pin, byUserId: me?.id);
            _refresh(ref);
            if (context.mounted) toast(context, S.staffAdded);
          } catch (e) {
            if (context.mounted) toastError(context, e);
          }
        },
      ),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (list) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            for (final u in list)
              ListTile(
                key: Key('staff_${u.name}'),
                leading: Icon(u.role == 'owner' ? Icons.verified_user_outlined : Icons.person_outline),
                title: Text(u.name),
                subtitle: Text(u.role == 'owner'
                    ? S.ownerRole
                    : (u.active ? S.counterRole : '${S.counterRole} (${S.removedLabel})')),
                trailing: !u.active
                    ? null
                    : PopupMenuButton<String>(
                        key: Key('staffMenu_${u.name}'),
                        onSelected: (v) async {
                          if (v == 'pin') {
                            await setPin(u, title: u.id == me?.id ? S.changeMyPin : null);
                          } else if (v == 'remove') {
                            final ok = await confirm(context,
                                message: S.removeStaffConfirm, confirmLabel: S.removeStaff);
                            if (!ok || !context.mounted) return;
                            try {
                              await auth.deactivate(u.id, byUserId: me?.id);
                              _refresh(ref);
                            } catch (e) {
                              if (context.mounted) toastError(context, e);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Text(u.id == me?.id ? S.changeMyPin : S.resetPin),
                          ),
                          if (u.role != 'owner')
                            const PopupMenuItem(value: 'remove', child: Text(S.removeStaff)),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title});
  final String title;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          key: const Key('newPinField'),
          controller: _pin,
          autofocus: true,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.staffPin, border: OutlineInputBorder(), counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
          FilledButton(
            key: const Key('pinSave'),
            onPressed: () => Navigator.pop(context, _pin.text),
            child: const Text(S.save),
          ),
        ],
      );
}

class _StaffDialog extends StatefulWidget {
  const _StaffDialog();

  @override
  State<_StaffDialog> createState() => _StaffDialogState();
}

class _StaffDialogState extends State<_StaffDialog> {
  final _name = TextEditingController();
  final _pin = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(S.addStaff),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('staffNameField'),
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: S.staffName, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('staffPinField'),
              controller: _pin,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: S.staffPin, border: OutlineInputBorder(), counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
          FilledButton(
            key: const Key('staffSave'),
            onPressed: () => Navigator.pop(context, (name: _name.text, pin: _pin.text)),
            child: const Text(S.save),
          ),
        ],
      );
}
