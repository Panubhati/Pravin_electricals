import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/item_repository.dart';
import '../../core/money.dart';
import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../../core/units.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import 'bill_controller.dart';
import 'bill_done_screen.dart';
import 'domain/bill_calculator.dart';
import 'customer_sheet.dart';
import 'payment_sheet.dart';
import 'scan_screen.dart';
import '../../shared/theme.dart';

class BillScreen extends ConsumerStatefulWidget {
  const BillScreen({super.key});

  @override
  ConsumerState<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends ConsumerState<BillScreen> {
  final _search = TextEditingController();
  List<ItemSearchResult> _results = const [];
  bool _searched = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Start every bill empty.
    Future.microtask(() => ref.read(billProvider.notifier).clear());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _onQuery(String q) async {
    final r = await ref.read(itemRepositoryProvider).search(q);
    if (!mounted) return;
    setState(() {
      _results = r;
      _searched = q.trim().isNotEmpty;
    });
  }

  Future<void> _add(ItemSearchResult r) async {
    final err = await ref.read(billProvider.notifier).addItem(r);
    if (!mounted) return;
    if (err != null) {
      _toast(err);
      return;
    }
    _search.clear();
    setState(() {
      _results = const [];
      _searched = false;
    });
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (code == null || !mounted) return;
    final found = await ref.read(itemRepositoryProvider).search(code);
    if (!mounted) return;
    if (found.length == 1) {
      await _add(found.single);
    } else {
      _search.text = code;
      await _onQuery(code);
      if (found.isEmpty && mounted) _toast(S.noResults);
    }
  }

  Future<void> _chooseCustomer() async {
    final choice = await showCustomerSheet(context);
    if (choice == null || !mounted) return;
    await ref.read(billProvider.notifier).setCustomer(choice.party);
  }

  Future<void> _pay() async {
    final totals = ref.read(billResultProvider).totals;
    if (totals == null || totals.isEmpty || _saving) return;
    final payments = await showPaymentSheet(context, totalPaise: totals.totalPaise);
    if (payments == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final id = await ref.read(billProvider.notifier).save(payments);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => BillDoneScreen(invoiceId: id)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast(S.couldNotSaveBill(errorMessage(e)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = ref.watch(billProvider);
    final result = ref.watch(billResultProvider);
    final totals = result.totals;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.billTitle),
        actions: [
          TextButton.icon(
            onPressed: _chooseCustomer,
            icon: const Icon(Icons.person),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(
                bill.customer?.name ?? S.walkIn,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('searchField'),
              controller: _search,
              onChanged: _onQuery,
              decoration: InputDecoration(
                hintText: S.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: S.scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scan,
                ),
              ),
            ),
          ),
          Expanded(child: _searched ? _resultsList() : _cart(bill)),
          _totalsBar(result, totals),
        ],
      ),
    );
  }

  Widget _resultsList() {
    if (_results.isEmpty) {
      return Center(child: Text(S.noResults));
    }
    final balances = ref.watch(stockBalancesProvider).valueOrNull;
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = _results[i];
        final qty = balances?[r.item.id] ?? 0;
        final subtitle = [
          if (r.item.brand != null) r.item.brand,
          if (r.variant != null && r.variant!.label != kDefaultVariantLabel)
            r.variant!.label,
          if (balances != null) '${S.stock}: ${formatStock(r.item, qty)}',
        ].join('  •  ');
        return ListTile(
          key: Key('result_$i'),
          title: Text(r.item.name),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  style: balances != null && qty <= 0
                      ? const TextStyle(color: AppPalette.amber)
                      : null,
                ),
          onTap: () => _add(r),
        );
      },
    );
  }

  Widget _cart(BillState bill) {
    if (bill.cart.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(S.cartEmpty, textAlign: TextAlign.center),
        ),
      );
    }
    // Total asked for per item (an item can be on two lines), against stock.
    final balances = ref.watch(stockBalancesProvider).valueOrNull;
    final calc = ref.watch(billResultProvider).totals;
    final requested = <String, int>{};
    if (calc != null) {
      for (final l in calc.lines) {
        requested[l.cart.itemId] = (requested[l.cart.itemId] ?? 0) + l.qtyBase;
      }
    }
    return ListView.builder(
      itemCount: bill.cart.length,
      itemBuilder: (_, i) {
        final id = bill.cart[i].line.itemId;
        return _CartTile(
          key: ValueKey('$id/${bill.cart[i].line.variantId}/$i'),
          index: i,
          entry: bill.cart[i],
          requestedBase: requested[id] ?? 0,
          // Null while stock is still loading: no warning until it is known.
          availableBase: balances == null ? null : (balances[id] ?? 0),
        );
      },
    );
  }

  Widget _totalsBar(BillResult result, BillTotals? totals) {
    final discountError = discountProblem(totals, ref.watch(permissionsProvider));
    return Material(
      color: AppPalette.card,
      shape: const Border(top: BorderSide(color: AppPalette.line)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.error != null)
                Text(result.error!, style: const TextStyle(color: AppPalette.red)),
              if (discountError != null)
                Text(discountError,
                    key: const Key('discountError'),
                    style: const TextStyle(color: AppPalette.red)),
              if (totals != null && !totals.isEmpty) ...[
                _row(S.subtotal, Money.format(totals.subtotalPaise)),
                if (totals.discountPaise > 0)
                  _row(S.discountLabel, '- ${Money.format(totals.discountPaise)}'),
                if (totals.roundOffPaise != 0)
                  _row(
                    S.roundOff,
                    '${totals.roundOffPaise < 0 ? '-' : '+'} '
                    '${Money.format(totals.roundOffPaise.abs())}',
                  ),
                _row(S.gstIncluded, Money.format(totals.taxPaise),
                    muted: true),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      totals == null ? '' : Money.format(totals.totalPaise),
                      key: const Key('grandTotal'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton(
                    key: const Key('payButton'),
                    onPressed: (totals == null ||
                            totals.isEmpty ||
                            _saving ||
                            discountError != null)
                        ? null
                        : _pay,
                    child: Text(S.pay, style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool muted = false}) {
    final style = muted
        ? Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).hintColor)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(k, style: style)),
        const SizedBox(width: 8),
        Text(v, style: style),
      ],
    );
  }
}

class _CartTile extends ConsumerStatefulWidget {
  const _CartTile({
    super.key,
    required this.index,
    required this.entry,
    required this.requestedBase,
    required this.availableBase,
  });
  final int index;
  final CartEntry entry;

  /// Total of this item on the bill, in base units.
  final int requestedBase;

  /// Stock on hand in base units, or null while unknown.
  final int? availableBase;

  @override
  ConsumerState<_CartTile> createState() => _CartTileState();
}

class _CartTileState extends ConsumerState<_CartTile> {
  late final TextEditingController _qty;
  late final TextEditingController _disc;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: widget.entry.line.qtyEntered);
    _disc = TextEditingController(text: _discText(widget.entry.line.discountPaise));
  }

  String _discText(int paise) =>
      paise == 0 ? '' : Money.format(paise, symbol: false).replaceAll(',', '');

  @override
  void didUpdateWidget(covariant _CartTile old) {
    super.didUpdateWidget(old);
    // The quantity can change from outside (the same item added again).
    if (_qty.text != widget.entry.line.qtyEntered) {
      _qty.text = widget.entry.line.qtyEntered;
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _disc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = ref.read(billProvider.notifier);
    final line = widget.entry.line;
    final calc = ref.watch(billResultProvider).totals;
    final lineCalc = (calc != null && widget.index < calc.lines.length)
        ? calc.lines[widget.index]
        : null;
    final units = widget.entry.units;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(line.itemName,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: S.remove,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => bill.removeAt(widget.index),
                ),
              ],
            ),
            Text(
              '${Money.format(line.ratePaise)} / '
              '${_pricingUnit(units, line.priceUnitFactor)}  ${S.gstInclShort}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.availableBase != null &&
                widget.requestedBase > widget.availableBase!)
              Padding(
                key: Key('stockWarning_${widget.index}'),
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.availableBase! <= 0
                      ? S.outOfStock
                      : '${S.onlyInStock} '
                          '${Units.formatQty(widget.availableBase!, line.priceUnitFactor)} '
                          '${_pricingUnit(units, line.priceUnitFactor)} ${S.inStockSuffix}',
                  style: const TextStyle(color: AppPalette.amber),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 84,
                  child: TextField(
                    key: Key('qty_${widget.index}'),
                    controller: _qty,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: S.qty,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (t) => bill.setQty(widget.index, t),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: Key('unit_${widget.index}'),
                    isExpanded: true,
                    value: line.unitName,
                    decoration: InputDecoration(
                      labelText: S.unit,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final u in units)
                        DropdownMenuItem(value: u.unitName, child: Text(u.unitName)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      bill.setUnit(
                          widget.index, units.firstWhere((u) => u.unitName == v));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: TextField(
                    key: Key('disc_${widget.index}'),
                    controller: _disc,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: S.discount,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (t) => bill.setDiscount(widget.index, t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                lineCalc == null ? '' : Money.format(lineCalc.grossPaise),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Name of the unit prices are quoted in (metre for cable, piece otherwise).
  String _pricingUnit(List<ItemUnit> units, int priceUnitFactor) =>
      units
          .firstWhere((u) => u.factorToBase == priceUnitFactor,
              orElse: () => units.first)
          .unitName;
}
