import 'package:flutter/material.dart';

import 'format.dart';
import 'strings.dart';

/// Shows [message] at the bottom of the screen.
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Shows a plain-language error for [error].
void toastError(BuildContext context, Object error) =>
    toast(context, errorMessage(error));

/// Asks a yes/no question. Returns true only when the user confirms.
Future<bool> confirm(
  BuildContext context, {
  required String message,
  String confirmLabel = 'Yes',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(S.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// A centred message for an empty list.
class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}

/// A small coloured label such as "Low stock".
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, {super.key, this.color = Colors.orange});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12)),
      );
}

/// A section title inside a form.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}
