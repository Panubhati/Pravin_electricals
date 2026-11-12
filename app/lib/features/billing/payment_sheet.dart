import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/invoice_repository.dart';
import '../../core/money.dart';
import '../../shared/strings.dart';
import 'bill_controller.dart';
import 'upi_qr_card.dart';
import '../../shared/theme.dart';

/// Asks how the customer pays (cash, UPI, credit or a mix) and returns the
/// payments, which always add up to the bill total. Null if cancelled.
Future<List<PaymentInput>?> showPaymentSheet(
  BuildContext context, {
  required int totalPaise,
}) =>
    showModalBottomSheet<List<PaymentInput>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentSheet(totalPaise: totalPaise),
    );

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.totalPaise});
  final int totalPaise;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  late final TextEditingController _cash;
  final _upi = TextEditingController();
  final _credit = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cash = TextEditingController(text: _fmt(widget.totalPaise));
  }

  @override
  void dispose() {
    _cash.dispose();
    _upi.dispose();
    _credit.dispose();
    super.dispose();
  }

  String _fmt(int paise) =>
      paise == 0 ? '' : Money.format(paise, symbol: false).replaceAll(',', '');

  int _paise(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return 0;
    try {
      return Money.parse(t);
    } on FormatException {
      return -1;
    }
  }

  void _fill({int cash = 0, int upi = 0, int credit = 0}) {
    setState(() {
      _cash.text = _fmt(cash);
      _upi.text = _fmt(upi);
      _credit.text = _fmt(credit);
    });
  }

  Future<void> _save() async {
    final cash = _paise(_cash), upi = _paise(_upi), credit = _paise(_credit);
    final bill = ref.read(billProvider.notifier);
    if (credit > 0) {
      final warning = await bill.creditWarning(credit);
      if (warning != null && mounted) {
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(warning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(S.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(S.continueAnyway),
              ),
            ],
          ),
        );
        if (go != true) return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop([
      if (cash > 0) PaymentInput('cash', cash),
      if (upi > 0) PaymentInput('upi', upi),
      if (credit > 0) PaymentInput('credit', credit),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(billProvider).customer;
    final cash = _paise(_cash), upi = _paise(_upi), credit = _paise(_credit);
    final invalid = cash < 0 || upi < 0 || credit < 0;
    final remaining = widget.totalPaise - (invalid ? 0 : cash + upi + credit);
    final needsCustomer = !invalid && credit > 0 && customer == null;
    final canSave = !invalid && remaining == 0 && !needsCustomer;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    Widget field(String label, TextEditingController c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              prefixText: '₹ ',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(S.paymentTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${S.total}: ${Money.format(widget.totalPaise)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text(S.fullCash),
                onPressed: () => _fill(cash: widget.totalPaise),
              ),
              ActionChip(
                label: const Text(S.fullUpi),
                onPressed: () => _fill(upi: widget.totalPaise),
              ),
              ActionChip(
                label: const Text(S.fullCredit),
                onPressed: () => _fill(credit: widget.totalPaise),
              ),
            ],
          ),
          const SizedBox(height: 12),
          field(S.cash, _cash),
          field(S.upi, _upi),
          field(S.credit, _credit),
          // A QR for the UPI part, so the customer can pay before the bill is saved.
          if (!invalid) UpiQrCard(amountPaise: upi),
          if (needsCustomer)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(S.creditNeedsCustomer,
                  style: TextStyle(color: AppPalette.red)),
            ),
          Text(
            '${S.remaining}: ${Money.format(remaining)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: remaining == 0 ? AppPalette.green : AppPalette.red,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: canSave ? _save : null,
            child: const Text(S.saveBill),
          ),
        ],
      ),
    );
  }
}
