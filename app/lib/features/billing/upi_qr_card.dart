import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/money.dart';
import '../../core/permissions.dart';
import '../../core/printing/upi_link.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';

/// A QR code for the customer to scan and pay [amountPaise] by UPI. Shows
/// nothing when the amount is zero. When the shop has no UPI ID yet, the owner
/// gets a hint to add one and staff see nothing.
class UpiQrCard extends ConsumerWidget {
  const UpiQrCard({super.key, required this.amountPaise});
  final int amountPaise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (amountPaise <= 0) return const SizedBox.shrink();
    final payee = ref.watch(upiPayeeProvider).valueOrNull;
    final link = UpiLink.build(payee, amountPaise: amountPaise);
    if (link == null) {
      if (!ref.watch(permissionsProvider).canOpenSettings) return const SizedBox.shrink();
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(S.upiOwnerHint, key: Key('upiHint'), style: TextStyle(color: AppPalette.muted)),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // White behind the code so any scanner reads it, in dark mode too.
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(
                // The key carries the link, so tests can check exactly what the code encodes.
                key: ValueKey('upiQr|$link'),
                data: link,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(S.upiScanToPay(Money.format(amountPaise)), key: const Key('upiQrCaption')),
            Text(payee!.name, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
