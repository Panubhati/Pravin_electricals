import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/invoice_repository.dart';
import '../../core/money.dart';
import '../../core/printing/invoice_view.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../auth/owner_approval.dart';
import '../returns/return_screens.dart';
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.invoice.invoiceNoText}  •  ${_time(b.invoice.date)}'),
                          if (b.cancelled || b.returnedPaise > 0 || (b.duePaise > 0 && !b.cancelled))
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (b.cancelled)
                                  const StatusChip(S.cancelledBadge, color: Colors.red)
                                else if (b.returnedPaise > 0)
                                  StatusChip('${S.returnedBadge} ${Money.format(b.returnedPaise)}'),
                                if (b.duePaise > 0 && !b.cancelled)
                                  Text('${Money.format(b.duePaise)} ${S.dueLabel}',
                                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ),
                        ],
                      ),
                      trailing: Text(
                        Money.format(b.invoice.totalPaise),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: b.cancelled ? TextDecoration.lineThrough : null,
                        ),
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

  Future<void> _openReturn() async {
    await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => ReturnScreen(invoiceId: widget.invoiceId)));
    refreshAfterReturn(ref, widget.invoiceId);
  }

  /// Cancel the whole bill: ask why, get the owner's go-ahead, then reverse it.
  Future<void> _cancelBill(InvoiceDetails d) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _CancelDialog(invoiceNo: d.invoice.invoiceNoText, total: Money.format(d.invoice.totalPaise)),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final approver = await askOwnerApproval(context, ref,
          what: S.cancelApprovalWhat(d.invoice.invoiceNoText));
      if (approver == null || !mounted) return;
      final session = ref.read(sessionProvider).requireValue;
      final id = await ref.read(returnRepositoryProvider).cancelBill(
            widget.invoiceId,
            deviceId: session.deviceId,
            series: session.series,
            reason: reason,
            createdBy: ref.read(actingUserIdProvider),
            approvedBy: approver,
          );
      refreshAfterReturn(ref, widget.invoiceId);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => CreditNoteScreen(returnId: id)));
    } catch (e) {
      if (mounted) toastError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<Widget> _creditNotes() {
    final notes = ref.watch(invoiceReturnsProvider(widget.invoiceId)).valueOrNull ?? const [];
    if (notes.isEmpty) return const [];
    return [
      const SectionTitle(S.creditNotes),
      for (final n in notes)
        ListTile(
          key: Key('note_${n.noteNo}'),
          contentPadding: EdgeInsets.zero,
          leading: Icon(n.isCancel ? Icons.cancel_outlined : Icons.assignment_return_outlined),
          title: Text(n.noteNo),
          subtitle: Text(_time(n.date)),
          trailing: Text(Money.format(n.totalPaise)),
          onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => CreditNoteScreen(returnId: n.id))),
        ),
    ];
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
                    Flexible(child: Text(k, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                    const SizedBox(width: 8),
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
              if (d.invoice.status == 'cancelled')
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(S.billCancelledNote, key: Key('detailCancelled'), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ..._creditNotes(),
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
              if (d.invoice.status != 'cancelled') ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  key: const Key('detailReturn'),
                  onPressed: _busy ? null : () => _openReturn(),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text(S.returnItems),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('detailCancel'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                  onPressed: _busy ? null : () => _cancelBill(d),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(S.cancelBill),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Asks why the bill is being cancelled. Returns the reason (may be empty), or
/// null if the person backed out.
class _CancelDialog extends StatefulWidget {
  const _CancelDialog({required this.invoiceNo, required this.total});
  final String invoiceNo;
  final String total;

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('${S.cancelBill} ${widget.invoiceNo}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.cancelBillWarning(widget.total)),
            const SizedBox(height: 12),
            TextField(
              key: const Key('cancelReason'),
              controller: _reason,
              decoration: const InputDecoration(labelText: S.returnReason, border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('cancelKeep'),
            onPressed: () => Navigator.pop(context),
            child: const Text(S.keepBill),
          ),
          FilledButton(
            key: const Key('cancelConfirm'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, _reason.text),
            child: const Text(S.cancelBill),
          ),
        ],
      );
}
