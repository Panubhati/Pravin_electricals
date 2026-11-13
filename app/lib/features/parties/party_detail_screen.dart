import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/ledger_repository.dart';
import '../../core/dues/ageing.dart';
import '../../core/import/value_parsers.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/permissions.dart';
import '../reminders/reminders_screen.dart';
import 'parties_providers.dart';
import 'party_form_screen.dart';
import '../../shared/theme.dart';

/// One customer or supplier: balance, ageing, payments and the full statement.
class PartyDetailScreen extends ConsumerStatefulWidget {
  const PartyDetailScreen({super.key, required this.partyId});
  final String partyId;

  @override
  ConsumerState<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends ConsumerState<PartyDetailScreen> {
  Party? _party;
  List<StatementLine> _statement = const [];
  AgeingBuckets? _ageing;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final party = await ref.read(partyRepositoryProvider).getParty(widget.partyId);
    final ledger = ref.read(ledgerRepositoryProvider);
    final statement = await ledger.statement(widget.partyId);
    final ageing = await ref
        .read(duesRepositoryProvider)
        .ageingFor(widget.partyId, payable: party.kind == 'supplier');
    if (!mounted) return;
    setState(() {
      _party = party;
      _statement = statement;
      _ageing = ageing;
      _balance = statement.isEmpty ? 0 : statement.last.runningBalancePaise;
    });
  }

  Future<void> _pay({required bool toSupplier}) async {
    final result = await showDialog<_PaymentResult>(
      context: context,
      builder: (_) => _PaymentDialog(
        title: toSupplier ? S.recordSupplierPayment : S.recordPayment,
      ),
    );
    if (result == null || !mounted) return;
    try {
      final ledger = ref.read(ledgerRepositoryProvider);
      final paise = parseRupees(result.amount);
      if (toSupplier) {
        await ledger.recordSupplierPayment(widget.partyId, paise,
            mode: result.mode, note: result.note);
      } else {
        await ledger.recordCustomerPayment(widget.partyId, paise,
            mode: result.mode, note: result.note);
      }
      refreshBalances(ref);
      if (mounted) toast(context, S.paymentSaved);
      await _load();
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  static Map<String, String> get _typeLabels => {
    'invoice': S.ledgerBill,
    'payment': S.ledgerPayment,
    'return': S.ledgerReturn,
    'opening': S.ledgerOpening,
    'adjustment': S.ledgerAdjustment,
    'purchase': S.ledgerPurchase,
    'supplier_payment': S.ledgerSupplierPayment,
  };

  @override
  Widget build(BuildContext context) {
    final p = _party;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingView(),
      );
    }
    final supplier = p.kind == 'supplier';
    final label = balanceLabel(_balance, supplierView: supplier);
    final a = _ageing;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            key: const Key('editParty'),
            tooltip: S.editParty,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push<bool>(MaterialPageRoute(
                  builder: (_) => PartyFormScreen(partyId: p.id)));
              if (mounted) _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if (p.phone != null) Text(p.phone!),
              const SizedBox(height: 8),
              Text(
                label.text,
                key: const Key('partyBalance'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: label.color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (a != null && a.totalDue > 0) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (a.days0to30 > 0)
                    StatusChip('${S.bucket0}: ${Money.format(a.days0to30)}', color: AppPalette.green),
                  if (a.days31to60 > 0)
                    StatusChip('${S.bucket31}: ${Money.format(a.days31to60)}'),
                  if (a.days61to90 > 0)
                    StatusChip('${S.bucket61}: ${Money.format(a.days61to90)}', color: AppPalette.amber),
                  if (a.over90 > 0)
                    StatusChip('${S.bucket90}: ${Money.format(a.over90)}', color: AppPalette.red),
                ]),
              ],
              const SizedBox(height: 12),
              Row(children: [
                if (p.kind != 'supplier')
                  Expanded(
                    child: FilledButton(
                      key: const Key('paymentButton'),
                      onPressed: () => _pay(toSupplier: false),
                      child: Text(S.recordPayment),
                    ),
                  ),
                if (p.kind == 'both') const SizedBox(width: 12),
                if (p.kind != 'customer')
                  Expanded(
                    child: FilledButton.tonal(
                      key: const Key('supplierPaymentButton'),
                      onPressed: () => _pay(toSupplier: true),
                      child: Text(S.recordSupplierPayment),
                    ),
                  ),
              ]),
              // A11: leave this customer out of payment reminders (owner only).
              if (p.kind != 'supplier' && ref.watch(permissionsProvider).canOpenSettings)
                SwitchListTile(
                  key: const Key('remindersOffSwitch'),
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.transparent,
                  title: Text(S.remindersOffForCustomer),
                  subtitle: p.remindersOff ? Text(S.remindersOffForCustomerHelp) : null,
                  value: p.remindersOff,
                  onChanged: (off) async {
                    await ref
                        .read(reminderRepositoryProvider)
                        .setRemindersOff(p.id, off, userId: ref.read(actingUserIdProvider));
                    ref.invalidate(dueRemindersProvider);
                    await _load();
                  },
                ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: _statement.isEmpty
                ? EmptyState(S.noHistory)
                : ListView.separated(
                    itemCount: _statement.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      // Newest first.
                      final line = _statement[_statement.length - 1 - i];
                      final e = line.entry;
                      final plus = e.amountPaise > 0;
                      return ListTile(
                        key: Key('entry_$i'),
                        title: Text(_typeLabels[e.entryType] ?? e.entryType),
                        subtitle: Text([
                          formatDate(e.ts),
                          if (e.paymentMode != null) e.paymentMode!.toUpperCase(),
                          if (e.note != null) e.note,
                        ].join('  •  ')),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${plus ? '+' : '-'}${Money.format(e.amountPaise.abs())}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: plus ? AppPalette.red : AppPalette.green,
                              ),
                            ),
                            Text(
                              '${S.balance}: ${Money.format(line.runningBalancePaise)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentResult {
  const _PaymentResult(this.amount, this.mode, this.note);
  final String amount;
  final String mode;
  final String? note;
}

/// Amount, how it was paid, and an optional note. Owns its controllers.
class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.title});
  final String title;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _mode = 'cash';

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            key: const Key('payAmount'),
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: S.amount, prefixText: '₹ ', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final m in LedgerRepository.paymentModes)
              ChoiceChip(
                key: Key('mode_$m'),
                label: Text(m.toUpperCase()),
                selected: _mode == m,
                onSelected: (_) => setState(() => _mode = m),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(
            key: const Key('payNote'),
            controller: _note,
            decoration: InputDecoration(
                labelText: S.note, border: OutlineInputBorder()),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(S.cancel)),
        FilledButton(
          key: const Key('paySave'),
          onPressed: () {
            if (_amount.text.trim().isEmpty) {
              toast(context, S.enterAmountShort);
              return;
            }
            Navigator.pop(
              context,
              _PaymentResult(
                _amount.text,
                _mode,
                _note.text.trim().isEmpty ? null : _note.text.trim(),
              ),
            );
          },
          child: Text(S.save),
        ),
      ],
    );
  }
}
