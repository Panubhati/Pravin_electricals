import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../bills/bill_sharing.dart';
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

  Future<void> _share({required bool whatsapp}) async {
    setState(() => _sharing = true);
    try {
      final outcome = await shareBill(ref, widget.invoiceId, whatsapp: whatsapp);
      final msg = shareOutcomeMessage(outcome);
      if (msg != null && mounted) toast(context, msg);
    } catch (e) {
      if (mounted) toast(context, '${S.shareFailed}: ${errorMessage(e)}');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(_detailsProvider(widget.invoiceId));
    return Scaffold(
      appBar: AppBar(title: Text(S.billSaved), automaticallyImplyLeading: false),
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
                const Center(child: SuccessTick()),
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
                  onPressed: _sharing ? null : () => _share(whatsapp: false),
                  icon: const Icon(Icons.share),
                  label: Text(S.sharePdf),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('whatsappPdf'),
                  onPressed: _sharing ? null : () => _share(whatsapp: true),
                  icon: const Icon(Icons.chat_outlined),
                  label: Text(S.whatsapp),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('newBillAgain'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const BillScreen()),
                  ),
                  child: Text(S.newBillAgain),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(S.home),
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
