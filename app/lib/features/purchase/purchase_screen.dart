import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/item_repository.dart';
import '../../core/import/value_parsers.dart';
import '../../core/money.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../parties/parties_providers.dart';
import 'domain/purchase_calculator.dart';
import 'purchase_providers.dart';
import 'supplier_sheet.dart';
import '../../shared/theme.dart';

/// What was typed for one purchase line (kept as text until saved).
class _LineData {
  _LineData({
    required this.item,
    required this.variantId,
    required this.units,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.gst,
  });

  final Item item;
  final String? variantId;
  final List<ItemUnit> units;
  ItemUnit unit;
  String qty;
  String rate;
  String gst;
}

/// Enter a supplier bill: pick the supplier, add items in the units on the bill
/// (rolls, boxes, pieces), and save. Stock goes up, the supplier is owed the
/// total, and each item's cost price follows the bill.
class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  Party? _supplier;
  final _invoiceNo = TextEditingController();
  final _search = TextEditingController();
  DateTime _date = DateTime.now();
  List<ItemSearchResult> _results = const [];
  bool _searched = false;
  bool _saving = false;
  final List<_LineData> _lines = [];

  @override
  void dispose() {
    _invoiceNo.dispose();
    _search.dispose();
    super.dispose();
  }

  String _bpText(int bp) => bp % 100 == 0 ? '${bp ~/ 100}' : '${bp / 100}';

  Future<void> _query(String q) async {
    final r = await ref.read(itemRepositoryProvider).search(q);
    if (!mounted) return;
    setState(() {
      _results = r;
      _searched = q.trim().isNotEmpty;
    });
  }

  Future<void> _addItem(ItemSearchResult r) async {
    final items = ref.read(itemRepositoryProvider);
    final units = await items.unitsOf(r.item.id);
    // Bills usually list rolls or boxes: prefer a pack unit, then the pricing unit.
    final unit = units.firstWhere(
      (u) => u.factorToBase > 1 && u.factorToBase != r.item.priceUnitFactor,
      orElse: () => units.firstWhere(
        (u) => u.factorToBase == r.item.priceUnitFactor,
        orElse: () => units.first,
      ),
    );
    final cost = await items.latestCost(r.item.id);
    if (!mounted) return;
    _search.clear();
    setState(() {
      _lines.add(_LineData(
        item: r.item,
        variantId: r.variant?.id,
        units: units,
        unit: unit,
        qty: '1',
        rate: cost == null ? '' : rupeesForField(cost),
        gst: _bpText(r.item.gstRateBp),
      ));
      _results = const [];
      _searched = false;
    });
  }

  /// Totals for the lines as typed, or the first problem found.
  ({PurchaseTotals? totals, String? error}) _compute() {
    final cart = <PurchaseCartLine>[];
    for (final l in _lines) {
      try {
        if (l.rate.trim().isEmpty) {
          return (totals: null, error: 'Enter the rate for ${l.item.name}');
        }
        cart.add(PurchaseCartLine(
          itemId: l.item.id,
          itemName: l.item.name,
          variantId: l.variantId,
          unitName: l.unit.unitName,
          factorToBase: l.unit.factorToBase,
          qtyEntered: cleanQuantity(l.qty),
          ratePaise: parseRupees(l.rate),
          priceUnitFactor: l.item.priceUnitFactor,
          gstRateBp: parsePercentToBp(l.gst),
        ));
      } on FormatException catch (e) {
        return (totals: null, error: '${l.item.name}: ${e.message}');
      }
    }
    try {
      return (totals: PurchaseCalculator.calculate(cart), error: null);
    } on FormatException catch (e) {
      return (totals: null, error: e.message);
    }
  }

  Future<void> _pickSupplier() async {
    final p = await showSupplierSheet(context);
    if (p != null && mounted) setState(() => _supplier = p);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null && mounted) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (_saving) return;
    final result = _compute();
    if (_supplier == null) {
      toast(context, S.chooseSupplier);
      return;
    }
    if (_invoiceNo.text.trim().isEmpty) {
      toast(context, 'Enter the supplier bill number');
      return;
    }
    final totals = result.totals;
    if (totals == null || totals.isEmpty) {
      toast(context, result.error ?? S.purchaseHint);
      return;
    }
    setState(() => _saving = true);
    try {
      final session = ref.read(sessionProvider).requireValue;
      await ref.read(purchaseRepositoryProvider).postPurchase(
            PurchaseCalculator.toInput(
              totals,
              supplierId: _supplier!.id,
              supplierInvoiceNo: _invoiceNo.text.trim(),
              date: _date,
              locationId: session.locationId,
              createdBy: ref.read(actingUserIdProvider),
            ),
          );
      ref.invalidate(stockBalancesProvider);
      ref.invalidate(purchasesProvider);
      refreshBalances(ref);
      if (!mounted) return;
      toast(context, S.purchaseSaved);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        toastError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _compute();
    final totals = result.totals;

    return Scaffold(
      appBar: AppBar(title: const Text(S.newPurchase)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: const Key('supplierTile'),
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(_supplier?.name ?? S.chooseSupplier, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: _supplier?.gstin == null ? null : Text(_supplier!.gstin!),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickSupplier,
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: const Key('purchaseNo'),
                      controller: _invoiceNo,
                      decoration: const InputDecoration(
                          labelText: S.supplierInvoiceNo, border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      key: const Key('purchaseDate'),
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56), padding: const EdgeInsets.symmetric(horizontal: 8)),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(formatDate(_date), maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('purchaseSearch'),
                  controller: _search,
                  onChanged: _query,
                  decoration: const InputDecoration(
                    hintText: S.searchHint,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_searched)
                  if (_results.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text(S.noResults)),
                    )
                  else
                    for (var i = 0; i < _results.length; i++)
                      ListTile(
                        key: Key('presult_$i'),
                        title: Text(_results[i].item.name),
                        subtitle: _results[i].item.brand == null
                            ? null
                            : Text(_results[i].item.brand!),
                        onTap: () => _addItem(_results[i]),
                      )
                else if (_lines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text(S.purchaseHint, textAlign: TextAlign.center)),
                  ),
                for (var i = 0; i < _lines.length; i++)
                  _PurchaseLineTile(
                    key: ObjectKey(_lines[i]),
                    index: i,
                    data: _lines[i],
                    lineTotal: (totals != null && i < totals.lines.length)
                        ? totals.lines[i].totalPaise
                        : null,
                    onChanged: () => setState(() {}),
                    onRemove: () => setState(() => _lines.removeAt(i)),
                  ),
              ],
            ),
          ),
          Material(
            color: AppPalette.card,
            shape: const Border(top: BorderSide(color: AppPalette.line)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SafeArea(
                top: false,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (result.error != null && _lines.isNotEmpty)
                    Text(result.error!, style: const TextStyle(color: AppPalette.red)),
                  if (totals != null && !totals.isEmpty) ...[
                    _row(S.taxableTotal, Money.format(totals.subtotalPaise)),
                    _row(S.gstAmount, Money.format(totals.taxPaise)),
                  ],
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          totals == null ? '' : Money.format(totals.totalPaise),
                          key: const Key('purchaseTotal'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      child: FilledButton(
                        key: const Key('savePurchase'),
                        onPressed: _saving ? null : _save,
                        child: const Text(S.savePurchase, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(k), Text(v)],
      );
}

class _PurchaseLineTile extends StatefulWidget {
  const _PurchaseLineTile({
    super.key,
    required this.index,
    required this.data,
    required this.lineTotal,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _LineData data;
  final int? lineTotal;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_PurchaseLineTile> createState() => _PurchaseLineTileState();
}

class _PurchaseLineTileState extends State<_PurchaseLineTile> {
  late final _qty = TextEditingController(text: widget.data.qty);
  late final _rate = TextEditingController(text: widget.data.rate);
  late final _gst = TextEditingController(text: widget.data.gst);

  @override
  void dispose() {
    _qty.dispose();
    _rate.dispose();
    _gst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final i = widget.index;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(d.item.name, style: Theme.of(context).textTheme.titleMedium),
            ),
            IconButton(
              key: Key('premove_$i'),
              tooltip: S.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: widget.onRemove,
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(
              width: 90,
              child: TextField(
                key: Key('pqty_$i'),
                controller: _qty,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: S.qty, border: OutlineInputBorder()),
                onChanged: (t) {
                  d.qty = t;
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                key: Key('punit_$i'),
                isExpanded: true,
                value: d.unit.unitName,
                decoration: const InputDecoration(
                    labelText: S.unit, border: OutlineInputBorder()),
                items: [
                  for (final u in d.units)
                    DropdownMenuItem(value: u.unitName, child: Text(u.unitName)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  d.unit = d.units.firstWhere((u) => u.unitName == v);
                  widget.onChanged();
                },
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                key: Key('prate_$i'),
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${S.rateExGst} / ${pricingUnitName(d.item)}',
                  prefixText: '₹ ',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (t) {
                  d.rate = t;
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: TextField(
                key: Key('pgst_$i'),
                controller: _gst,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: S.gstPercent, border: OutlineInputBorder()),
                onChanged: (t) {
                  d.gst = t;
                  widget.onChanged();
                },
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.lineTotal == null ? '' : '${Money.format(widget.lineTotal!)} (with GST)',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }
}
