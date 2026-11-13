import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/repositories/invoice_repository.dart';
import '../../core/db/repositories/return_repository.dart';
import '../../core/money.dart';
import '../../core/printing/credit_note_view.dart';
import '../../core/providers.dart';
import '../../core/units.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../auth/owner_approval.dart';
import '../bills/bill_sharing.dart';
import '../bills/bills_screens.dart';
import '../../shared/theme.dart';

final returnDetailsProvider = FutureProvider.autoDispose.family<ReturnDetails, String>(
  (ref, id) => ref.watch(returnRepositoryProvider).details(id),
);

final returnableProvider = FutureProvider.autoDispose.family<List<ReturnableLine>, String>(
  (ref, invoiceId) => ref.watch(returnRepositoryProvider).returnable(invoiceId),
);

/// Pick what the customer is bringing back and how the money goes back.
class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final _qty = <String, TextEditingController>{};
  final _cash = TextEditingController();
  final _upi = TextEditingController();
  final _account = TextEditingController();
  final _reason = TextEditingController();

  ReturnQuote? _quote;
  String? _quoteError;
  int _quoteSeq = 0;
  bool _saving = false;
  bool _split = false; // true once the person typed their own split

  @override
  void dispose() {
    for (final c in [..._qty.values, _cash, _upi, _account, _reason]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String lineId) =>
      _qty.putIfAbsent(lineId, () => TextEditingController());

  int _paise(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return 0;
    try {
      return Money.parse(t);
    } on FormatException {
      return -1;
    }
  }

  List<ReturnLineInput> _inputs() => [
        for (final e in _qty.entries)
          if (e.value.text.trim().isNotEmpty && e.value.text.trim() != '0') ReturnLineInput(e.key, e.value.text.trim()),
      ];

  /// Re-works the refund whenever a quantity changes.
  Future<void> _recompute(InvoiceDetails details) async {
    final seq = ++_quoteSeq;
    final inputs = _inputs();
    if (inputs.isEmpty) {
      if (mounted) {
        setState(() {
          _quote = null;
          _quoteError = null;
          if (!_split) _fill(0, 0, 0);
        });
      }
      return;
    }
    try {
      final q = await ref.read(returnRepositoryProvider).quote(widget.invoiceId, inputs);
      if (!mounted || seq != _quoteSeq) return;
      setState(() {
        _quote = q;
        _quoteError = null;
        if (!_split) _suggest(q.totalPaise, details);
      });
    } catch (e) {
      if (!mounted || seq != _quoteSeq) return;
      setState(() {
        _quote = null;
        _quoteError = errorMessage(e);
      });
    }
  }

  void _fill(int cash, int upi, int account) {
    String f(int p) => p == 0 ? '' : rupeesForField(p);
    _cash.text = f(cash);
    _upi.text = f(upi);
    _account.text = f(account);
  }

  /// A sensible starting split: what is still owed on the bill comes off the
  /// customer's account first, the rest goes back the way they paid.
  void _suggest(int total, InvoiceDetails d) {
    final credit = d.payments.where((p) => p.mode == 'credit').fold<int>(0, (a, p) => a + p.amountPaise);
    final account = d.invoice.partyId == null ? 0 : (total < credit ? total : credit);
    final rest = total - account;
    final paidUpi = d.payments.where((p) => p.mode != 'cash' && p.mode != 'credit').fold<int>(0, (a, p) => a + p.amountPaise);
    final paidCash = d.payments.where((p) => p.mode == 'cash').fold<int>(0, (a, p) => a + p.amountPaise);
    if (paidUpi > paidCash) {
      _fill(0, rest, account);
    } else {
      _fill(rest, 0, account);
    }
  }

  Future<void> _confirm(InvoiceDetails details) async {
    final q = _quote;
    if (q == null || _saving) return;
    final cash = _paise(_cash), upi = _paise(_upi), account = _paise(_account);
    setState(() => _saving = true);
    try {
      final approver = await askOwnerApproval(context, ref, what: S.returnApprovalWhat(Money.format(q.totalPaise)));
      if (approver == null || !mounted) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      final session = ref.read(sessionProvider).requireValue;
      final id = await ref.read(returnRepositoryProvider).postReturn(PostReturnInput(
            invoiceId: widget.invoiceId,
            deviceId: session.deviceId,
            series: session.series,
            lines: _inputs(),
            refund: RefundSplit(cashPaise: cash, upiPaise: upi, accountPaise: account),
            reason: _reason.text,
            createdBy: ref.read(actingUserIdProvider),
            approvedBy: approver,
          ));
      refreshAfterReturn(ref, widget.invoiceId);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => CreditNoteScreen(returnId: id)));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        toastError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(returnableProvider(widget.invoiceId));
    final details = ref.watch(invoiceDetailsProvider(widget.invoiceId));
    return Scaffold(
      appBar: AppBar(title: Text(S.returnTitle)),
      body: lines.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (list) => details.when(
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState(errorMessage(e)),
          data: (d) => _form(list, d),
        ),
      ),
    );
  }

  Widget _form(List<ReturnableLine> list, InvoiceDetails d) {
    final q = _quote;
    final cash = _paise(_cash), upi = _paise(_upi), account = _paise(_account);
    final split = (cash < 0 || upi < 0 || account < 0) ? -1 : cash + upi + account;
    final matches = q != null && split == q.totalPaise;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${S.returnAgainst} ${d.invoice.invoiceNoText}', style: Theme.of(context).textTheme.titleMedium),
        if (d.party != null) Text(d.party!.name),
        const SizedBox(height: 4),
        Text(S.returnHow, style: TextStyle(color: AppPalette.muted)),
        const Divider(height: 24),
        for (final l in list)
          if (!l.fullyReturned)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${S.returnSold} ${l.line.qtyEntered} ${l.line.unitName}'
                          '${l.returnedBase > 0 ? ', ${S.returnAlready} ${Units.formatQty(l.returnedBase, l.factorToBase)}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      key: Key('retQty_${l.line.itemId}'),
                      controller: _controllerFor(l.line.id),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${S.returnQty} (${l.line.unitName})',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => _recompute(d),
                    ),
                  ),
                  IconButton(
                    key: Key('retAll_${l.line.itemId}'),
                    tooltip: S.returnAll,
                    icon: const Icon(Icons.done_all),
                    onPressed: () {
                      _controllerFor(l.line.id).text = Units.formatQty(l.remainingBase, l.factorToBase);
                      _recompute(d);
                    },
                  ),
                ],
              ),
            ),
        if (_quoteError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_quoteError!, key: const Key('returnError'), style: const TextStyle(color: AppPalette.red)),
          ),
        if (q != null) ...[
          const Divider(height: 24),
          _row(S.returnLinesTotal, Money.format(q.linesTotalPaise)),
          if (q.roundOffPaise != 0) _row(S.roundOff, '${q.roundOffPaise < 0 ? '-' : '+'} ${Money.format(q.roundOffPaise.abs())}'),
          _row(S.returnRefundTotal, Money.format(q.totalPaise), bold: true, key: const Key('returnTotal')),
          if (q.completesBill) Text(S.returnCompletes, style: TextStyle(color: AppPalette.muted)),
          const SizedBox(height: 12),
          Text(S.returnGiveBack, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ActionChip(
              key: const Key('refundAllCash'),
              label: Text(S.refundAllCash),
              onPressed: () => setState(() {
                _split = true;
                _fill(q.totalPaise, 0, 0);
              }),
            ),
            ActionChip(
              key: const Key('refundAllUpi'),
              label: Text(S.refundAllUpi),
              onPressed: () => setState(() {
                _split = true;
                _fill(0, q.totalPaise, 0);
              }),
            ),
            if (d.invoice.partyId != null)
              ActionChip(
                key: const Key('refundAllAccount'),
                label: Text(S.refundAllAccount),
                onPressed: () => setState(() {
                  _split = true;
                  _fill(0, 0, q.totalPaise);
                }),
              ),
          ]),
          const SizedBox(height: 8),
          _money('refundCash', S.refundCash, _cash),
          _money('refundUpi', S.refundUpi, _upi),
          if (d.invoice.partyId != null) _money('refundAccount', S.refundAccount, _account),
          Text(
            matches ? S.refundAddsUp : S.refundRemaining(Money.format(q.totalPaise - (split < 0 ? 0 : split))),
            key: const Key('refundStatus'),
            style: TextStyle(fontWeight: FontWeight.bold, color: matches ? AppPalette.green : AppPalette.red),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('returnReason'),
            controller: _reason,
            decoration: InputDecoration(labelText: S.returnReason, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('returnConfirm'),
            onPressed: (matches && !_saving) ? () => _confirm(d) : null,
            child: Text(S.returnConfirm),
          ),
        ],
      ],
    );
  }

  Widget _money(String key, String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          key: Key(key),
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, prefixText: '₹ ', border: const OutlineInputBorder()),
          onChanged: (_) => setState(() => _split = true),
        ),
      );

  Widget _row(String k, String v, {bool bold = false, Key? key}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(k, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null)),
            const SizedBox(width: 8),
            Text(v, key: key, style: bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18) : null),
          ],
        ),
      );
}

/// Makes the lists that show this bill read again after a return or cancel.
void refreshAfterReturn(WidgetRef ref, String invoiceId) {
  ref.invalidate(returnableProvider(invoiceId));
  ref.invalidate(invoiceDetailsProvider(invoiceId));
  ref.invalidate(billsProvider);
  ref.invalidate(stockBalancesProvider);
  ref.invalidate(partyBalancesProvider);
  ref.invalidate(invoiceReturnsProvider(invoiceId));
}

/// Credit notes made on a bill (for the bill's detail screen).
final invoiceReturnsProvider = FutureProvider.autoDispose.family<List<SalesReturnSummary>, String>((ref, id) async {
  final list = await ref.watch(returnRepositoryProvider).forInvoice(id);
  return [for (final r in list) SalesReturnSummary(r.id, r.creditNoteNoText, r.totalPaise, r.isCancel, r.date)];
});

class SalesReturnSummary {
  const SalesReturnSummary(this.id, this.noteNo, this.totalPaise, this.isCancel, this.date);
  final String id, noteNo;
  final int totalPaise;
  final bool isCancel;
  final DateTime date;
}

/// A saved credit note, with buttons to send it to the customer.
class CreditNoteScreen extends ConsumerStatefulWidget {
  const CreditNoteScreen({super.key, required this.returnId});
  final String returnId;

  @override
  ConsumerState<CreditNoteScreen> createState() => _CreditNoteScreenState();
}

class _CreditNoteScreenState extends ConsumerState<CreditNoteScreen> {
  bool _busy = false;

  Future<void> _share({required bool whatsapp}) async {
    setState(() => _busy = true);
    try {
      final outcome = await shareCreditNote(ref, widget.returnId, whatsapp: whatsapp);
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
    final async = ref.watch(returnDetailsProvider(widget.returnId));
    return Scaffold(
      appBar: AppBar(title: Text(S.creditNoteTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (d) {
          final v = CreditNoteView.from(d);
          Widget row(String k, String val, {bool bold = false, Key? key}) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(k, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null)),
                    const SizedBox(width: 8),
                    Text(val, key: key, style: bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18) : null),
                  ],
                ),
              );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(v.noteNo, key: const Key('creditNoteNo'), style: Theme.of(context).textTheme.headlineSmall),
              if (v.isCancel) Text(S.billCancelledNote, style: TextStyle(color: AppPalette.red)),
              Text('${S.returnAgainst} ${v.againstBill}  •  ${v.dateText}'),
              Text(v.customerName, style: Theme.of(context).textTheme.titleMedium),
              const Divider(height: 24),
              for (final l in v.lines)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.transparent,
                  title: Text(l.name),
                  subtitle: Text(l.qty),
                  trailing: Text(l.amount),
                ),
              const Divider(height: 24),
              if (v.roundOff != null) row(S.roundOff, v.roundOff!),
              row(S.returnRefundTotal, v.total, bold: true, key: const Key('creditNoteTotal')),
              Text(v.words, style: Theme.of(context).textTheme.bodySmall),
              SectionTitle(S.returnGiveBack),
              for (final r in v.refunds) Text(r),
              if (v.reason != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${S.returnReason}: ${v.reason}')),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('creditNoteShare'),
                onPressed: _busy ? null : () => _share(whatsapp: false),
                icon: const Icon(Icons.share),
                label: Text(S.sharePdf),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('creditNoteWhatsApp'),
                onPressed: _busy ? null : () => _share(whatsapp: true),
                icon: const Icon(Icons.chat_outlined),
                label: Text(S.whatsapp),
              ),
            ],
          );
        },
      ),
    );
  }
}
