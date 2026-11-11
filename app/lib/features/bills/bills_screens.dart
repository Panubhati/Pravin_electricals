import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/invoice_repository.dart';
import '../../core/money.dart';
import '../../core/printing/invoice_view.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'bill_sharing.dart';

typedef BillsQuery = ({String query, DateTime? from, DateTime? to});

final billsProvider = FutureProvider.autoDispose.family<List<InvoiceListEntry>, BillsQuery>(
  (ref, q) => ref.watch(invoiceRepositoryProvider).list(query: q.query, from: q.from, to: q.to),
);

final invoiceDetailsProvider = FutureProvider.autoDispose.family<InvoiceDetails, String>(
  (ref, id) => ref.watch(invoiceRepositoryProvider).details(id),
);

String _time(DateTime d) =>
    '${formatDate(d)}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Saved bills, newest first. Find one by number or customer and share it again.
class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  String _query = '';
  DateTimeRange? _range;

  Future<void> _pick() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(billsProvider((query: _query, from: _range?.start, to: _range?.end)));
    return Scaffold(
      appBar: AppBar(title: const Text(S.billsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('billSearch'),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: S.searchBills,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ActionChip(
                  key: const Key('billDates'),
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(_range == null
                      ? S.pickDates
                      : '${formatDate(_range!.start)} - ${formatDate(_range!.end)}'),
                  onPressed: _pick,
                ),
                if (_range != null)
                  IconButton(
                    key: const Key('billClearDates'),
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _range = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(errorMessage(e)),
              data: (bills) {
                if (bills.isEmpty) return const EmptyState(S.noBills);
                return ListView.separated(
                  itemCount: bills.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final b = bills[i];
                    return ListTile(
                      key: Key('bill_${b.invoice.id}'),
                      title: Text(b.partyName ?? S.walkIn),
                      subtitle: Text('${b.invoice.invoiceNoText}  •  ${_time(b.invoice.date)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Money.format(b.invoice.totalPaise),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (b.duePaise > 0)
                            Text('${Money.format(b.duePaise)} ${S.dueLabel}',
                                style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push<void>(MaterialPageRoute(
                          builder: (_) => BillDetailScreen(invoiceId: b.invoice.id))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// One saved bill, as printed, with buttons to share it again.
class BillDetailScreen extends ConsumerStatefulWidget {
  const BillDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  bool _busy = false;

  Future<void> _share({required bool whatsapp}) async {
    setState(() => _busy = true);
    try {
      final outcome = await shareBill(ref, widget.invoiceId, whatsapp: whatsapp);
      final msg = shareOutcomeMessage(outcome);
      if (msg != null && mounted) toast(context, msg);
    } catch (e) {
      if (mounted) toast(context, '${S.shareFailed}: ${errorMessage(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(invoiceDetailsProvider(widget.invoiceId));
    final upi = ref.watch(upiPayeeProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text(S.billDetail)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (d) {
          final v = InvoiceView.from(d, upi: upi);
          final style = Theme.of(context).textTheme;
          Widget row(String k, String val, {bool bold = false, Key? key}) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(k, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
                    Text(val,
                        key: key, style: bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18) : null),
                  ],
                ),
              );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(v.invoiceNo, key: const Key('detailInvoiceNo'), style: style.headlineSmall),
              Text(_time(d.invoice.date)),
              const SizedBox(height: 8),
              Text(v.billToName, style: style.titleMedium),
              for (final l in v.billToLines) Text(l),
              const Divider(height: 24),
              for (final l in v.lines)
                ListTile(
                  key: Key('line_${l.no}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.name),
                  subtitle: Text('${l.qty} at ${l.rate}${l.hsn.isEmpty ? '' : '  •  HSN ${l.hsn}'}'
                      '${l.discount.isEmpty ? '' : '  •  discount ${l.discount}'}'),
                  trailing: Text(l.amount),
                ),
              const Divider(height: 24),
              row('Subtotal', v.subtotal),
              if (v.discount != null) row('Discount', v.discount!),
              if (v.roundOff != null) row('Round off', v.roundOff!),
              row('Total', v.total, bold: true, key: const Key('detailTotal')),
              const SizedBox(height: 4),
              Text(v.words, style: style.bodySmall),
              const SectionTitle('Payment'),
              for (final p in v.payments) Text(p),
              if (v.dueText != null)
                Text(v.dueText!,
                    key: const Key('detailDue'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('detailShare'),
                onPressed: _busy ? null : () => _share(whatsapp: false),
                icon: const Icon(Icons.share),
                label: const Text(S.sharePdf),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('detailWhatsApp'),
                onPressed: _busy ? null : () => _share(whatsapp: true),
                icon: const Icon(Icons.chat_outlined),
                label: const Text(S.whatsapp),
              ),
            ],
          );
        },
      ),
    );
  }
}
