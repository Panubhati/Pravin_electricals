import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import 'pin_entry.dart';

/// Gets the owner's go-ahead for something only the owner should decide (taking
/// a sale back). When the owner is the one logged in, that is already the
/// approval; otherwise the owner types their PIN at the counter. Returns the
/// owner's id, or null if cancelled.
Future<String?> askOwnerApproval(BuildContext context, WidgetRef ref, {required String what}) async {
  final user = ref.read(currentUserProvider);
  final auth = ref.read(authRepositoryProvider);
  final owner = await auth.owner();
  if (user?.role == 'owner') return owner.id;
  if (!context.mounted) return null;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _OwnerPinDialog(what: what, ownerId: owner.id),
  );
  return ok == true ? owner.id : null;
}

class _OwnerPinDialog extends ConsumerStatefulWidget {
  const _OwnerPinDialog({required this.what, required this.ownerId});
  final String what;
  final String ownerId;

  @override
  ConsumerState<_OwnerPinDialog> createState() => _OwnerPinDialogState();
}

class _OwnerPinDialogState extends ConsumerState<_OwnerPinDialog> {
  String? _message;

  Future<void> _submit(String pin) async {
    final result = await ref.read(authRepositoryProvider).verify(widget.ownerId, pin);
    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(true);
      return;
    }
    final now = ref.read(sessionProvider).requireValue.ctx.clock();
    setState(() => _message = result.isLocked
        ? S.lockedWait((result.lockedUntil!.difference(now).inSeconds).clamp(1, 900))
        : S.wrongPin);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('ownerApprovalDialog'),
      title: Text(S.ownerApprovalTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.ownerApprovalBody(widget.what), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            PinEntry(title: S.ownerPinLabel, message: _message, onSubmit: _submit),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('ownerApprovalCancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(S.cancel),
        ),
      ],
    );
  }
}
