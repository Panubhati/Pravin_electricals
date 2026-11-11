import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/repo_context.dart';
import '../../core/import/value_parsers.dart';
import '../../core/providers.dart';
import '../../core/units.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';

/// One item's stock: the balance, Adjust and Count actions, and the history of
/// every movement that made up the balance.
class StockItemScreen extends ConsumerStatefulWidget {
  const StockItemScreen({super.key, required this.itemId});
  final String itemId;

  @override
  ConsumerState<StockItemScreen> createState() => _StockItemScreenState();
}

class _StockItemScreenState extends ConsumerState<StockItemScreen> {
  Item? _item;
  int _balance = 0;
  List<StockMovement> _movements = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = await ref.read(itemRepositoryProvider).getItem(widget.itemId);
    final stock = ref.read(stockRepositoryProvider);
    final balance = await stock.balance(itemId: widget.itemId);
    final movements = await stock.movements(widget.itemId);
    if (!mounted) return;
    setState(() {
      _item = item;
      _balance = balance;
      _movements = movements;
    });
  }

  /// Quantity typed in the item's pricing unit (metres or pieces) to base units.
  int _toBase(String text) =>
      Units.toBaseUnits(cleanQuantity(text), _item!.priceUnitFactor);

  Future<void> _adjust() async {
    final item = _item!;
    final result = await showDialog<_AdjustResult>(
      context: context,
      builder: (_) => _AdjustDialog(item: item),
    );
    if (result == null || !mounted) return;
    try {
      final base = _toBase(result.qty);
      if (base <= 0) throw DomainException('Enter a quantity more than 0');
      final session = ref.read(sessionProvider).requireValue;
      await ref.read(stockRepositoryProvider).adjust(
            itemId: item.id,
            locationId: session.locationId,
            deltaBase: result.adding ? base : -base,
            reason: result.note.isEmpty ? result.reason : '${result.reason}: ${result.note}',
            userId: session.userId,
          );
      ref.invalidate(stockBalancesProvider);
      if (mounted) toast(context, S.stockSaved);
      await _load();
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  Future<void> _count() async {
    final item = _item!;
    final text = await showDialog<String>(
      context: context,
      builder: (_) => _CountDialog(item: item, systemBase: _balance),
    );
    if (text == null || !mounted) return;
    try {
      if (text.trim().isEmpty) throw DomainException('Enter the counted quantity');
      final session = ref.read(sessionProvider).requireValue;
      await ref.read(stockRepositoryProvider).recordCount(
            itemId: item.id,
            locationId: session.locationId,
            countedBase: _toBase(text),
            userId: session.userId,
          );
      ref.invalidate(stockBalancesProvider);
      if (mounted) toast(context, S.stockSaved);
      await _load();
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  static const _typeLabels = {
    'purchase': 'Purchase',
    'sale': 'Sale',
    'sale_return': 'Sale return',
    'purchase_return': 'Purchase return',
    'transfer_in': 'Transfer in',
    'transfer_out': 'Transfer out',
    'adjustment': 'Adjustment',
    'count': 'Stock count',
  };

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      appBar: AppBar(title: Text(item?.name ?? S.stockTitle)),
      body: item == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text(
                      formatStock(item, _balance),
                      key: const Key('stockBalance'),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _balance < 0 ? Colors.red : null,
                          ),
                    ),
                    if (item.minStockBase > 0)
                      Text('Minimum: ${formatStock(item, item.minStockBase)}'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('adjustButton'),
                          onPressed: _adjust,
                          child: const Text(S.adjustStock),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('countButton'),
                          onPressed: _count,
                          child: const Text(S.countStock),
                        ),
                      ),
                    ]),
                  ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _movements.isEmpty
                      ? const EmptyState(S.noHistory)
                      : ListView.separated(
                          itemCount: _movements.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final m = _movements[i];
                            final plus = m.qtyBase > 0;
                            return ListTile(
                              key: Key('move_$i'),
                              title: Text(_typeLabels[m.movementType] ?? m.movementType),
                              subtitle: Text([
                                formatDate(m.ts),
                                if (m.note != null) m.note,
                              ].join('  •  ')),
                              trailing: Text(
                                '${plus ? '+' : ''}${formatStock(item, m.qtyBase)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: plus ? Colors.green.shade800 : Colors.red.shade700,
                                ),
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

class _AdjustResult {
  const _AdjustResult(this.adding, this.qty, this.reason, this.note);
  final bool adding;
  final String qty;
  final String reason;
  final String note;
}

/// Add or remove stock with a reason. Owns its text controllers, so they are
/// disposed together with the dialog (not while it is still animating away).
class _AdjustDialog extends StatefulWidget {
  const _AdjustDialog({required this.item});
  final Item item;

  @override
  State<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends State<_AdjustDialog> {
  final _qty = TextEditingController();
  final _note = TextEditingController();
  bool _adding = true;
  String _reason = S.reasonDamaged;

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(S.adjustStock),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text(S.addStock, key: Key('adjustAdd'))),
              ButtonSegment(value: false, label: Text(S.removeStock, key: Key('adjustRemove'))),
            ],
            selected: {_adding},
            onSelectionChanged: (s) => setState(() {
              _adding = s.first;
              _reason = _adding ? S.reasonFound : S.reasonDamaged;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('adjustQty'),
            controller: _qty,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${S.quantity} (${pricingUnitName(widget.item)})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('adjustReason'),
            value: _reason,
            decoration: const InputDecoration(
                labelText: S.reason, border: OutlineInputBorder()),
            items: [
              for (final r in [S.reasonDamaged, S.reasonFound, S.reasonCorrection, S.reasonOther])
                DropdownMenuItem(value: r, child: Text(r)),
            ],
            onChanged: (v) => setState(() => _reason = v ?? _reason),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('adjustNote'),
            controller: _note,
            decoration: const InputDecoration(
                labelText: S.note, border: OutlineInputBorder()),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('adjustSave'),
          onPressed: () => Navigator.pop(
            context,
            _AdjustResult(_adding, _qty.text, _reason, _note.text.trim()),
          ),
          child: const Text(S.save),
        ),
      ],
    );
  }
}

/// Enter the counted quantity and see the difference before saving.
class _CountDialog extends StatefulWidget {
  const _CountDialog({required this.item, required this.systemBase});
  final Item item;
  final int systemBase;

  @override
  State<_CountDialog> createState() => _CountDialogState();
}

class _CountDialogState extends State<_CountDialog> {
  final _qty = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  String? _diffText() {
    if (_qty.text.trim().isEmpty) return null;
    try {
      final counted =
          Units.toBaseUnits(cleanQuantity(_qty.text), widget.item.priceUnitFactor);
      final d = counted - widget.systemBase;
      return '${d > 0 ? '+' : ''}${formatStock(widget.item, d)}';
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diff = _diffText();
    return AlertDialog(
      title: const Text(S.countStock),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${S.systemQty}: ${formatStock(widget.item, widget.systemBase)}'),
        const SizedBox(height: 12),
        TextField(
          key: const Key('countQty'),
          controller: _qty,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: '${S.countedQty} (${pricingUnitName(widget.item)})',
            border: const OutlineInputBorder(),
          ),
        ),
        if (diff != null) ...[
          const SizedBox(height: 12),
          Text('${S.difference}: $diff', key: const Key('countDiff')),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('countSave'),
          onPressed: () => Navigator.pop(context, _qty.text),
          child: const Text(S.confirmCount),
        ),
      ],
    );
  }
}
