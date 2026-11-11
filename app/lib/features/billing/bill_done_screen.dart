import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/money.dart';
import '../../core/printing/invoice_pdf.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import 'bill_screen.dart';

/// Shown after a bill is saved: share the PDF or start the next bill.
class BillDoneScreen extends ConsumerStatefulWidget {
  const BillDoneScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<BillDoneScreen> createState() => _BillDoneScreenState();
}

class _BillDoneScreenState extends ConsumerState<BillDoneScreen> {
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final d =
          await ref.read(invoiceRepositoryProvider).details(widget.invoiceId);
      final bytes = await buildInvoicePdf(d, await InvoiceFonts.load());
      // The PDF is built from data each time and handed straight to the share
      // sheet; the app never keeps it.
      await Printing.sharePdf(bytes: bytes, filename: '${d.invoice.invoiceNoText}.pdf');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not share: $e')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(_detailsProvider(widget.invoiceId));
    return Scaffold(
      appBar: AppBar(title: const Text(S.billSaved), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: details.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (d) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 12),
                Text(
                  d.invoice.invoiceNoText,
                  key: const Key('savedInvoiceNo'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  Money.format(d.invoice.totalPaise),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('sharePdf'),
                  onPressed: _sharing ? null : _share,
                  icon: const Icon(Icons.share),
                  label: const Text(S.sharePdf),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('newBillAgain'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const BillScreen()),
                  ),
                  child: const Text(S.newBillAgain),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _detailsProvider = FutureProvider.family((ref, String id) =>
    ref.watch(invoiceRepositoryProvider).details(id));
