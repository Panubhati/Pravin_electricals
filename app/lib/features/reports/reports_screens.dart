import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/reports_repository.dart';
import '../../core/money.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../dayclose/day_check_screen.dart';
import 'reports_providers.dart';
import '../../shared/theme.dart';

/// Owner-only list of reports.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(Key key, IconData icon, String title, String sub, Widget screen) => Card(
          child: ListTile(
            key: key,
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(sub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .push<void>(MaterialPageRoute(builder: (_) => screen)),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text(S.reportsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          tile(const Key('reportDailySales'), Icons.today_outlined, S.dailySales,
              'Bills, payment modes and cash in hand for a day', const DailySalesScreen()),
          tile(const Key('reportDayCheck'), Icons.fact_check_outlined, S.dayCheckTitle,
              'Everything to compare with your paper book', const DayCheckScreen()),
          tile(const Key('reportItemProfit'), Icons.trending_up, S.itemProfit,
              'What each item earned over a period', const ItemProfitScreen()),
          tile(const Key('reportStockValue'), Icons.inventory_outlined, S.stockValue,
              'Stock on hand at cost price', const StockValueScreen()),
        ],
      ),
    );
  }
}

Widget _line(String label, String value, {bool bold = false, bool muted = false, Key? key}) {
  final style = bold
      ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
      : (muted ? const TextStyle(color: AppPalette.muted) : null);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, key: key, style: style),
      ],
    ),
  );
}

// ---- Daily sales ------------------------------------------------------------

class DailySalesScreen extends ConsumerStatefulWidget {
  const DailySalesScreen({super.key, this.day});

  /// The day to open on; today when null.
  final DateTime? day;

  @override
  ConsumerState<DailySalesScreen> createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends ConsumerState<DailySalesScreen> {
  late DateTime _day = startOfDay(widget.day ?? DateTime.now());

  void _move(int days) =>
      setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _day = startOfDay(d));
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(dailySalesProvider(_day));
    final cash = ref.watch(cashPositionProvider(_day));
    final isToday = startOfDay(DateTime.now()) == _day;
    return Scaffold(
      appBar: AppBar(title: const Text(S.dailySales)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('dayBack'),
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _move(-1),
              ),
              Flexible(
                child: TextButton(
                  key: const Key('dayPick'),
                  onPressed: _pick,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(isToday ? 'Today, ${formatDate(_day)}' : formatDate(_day),
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
              ),
              IconButton(
                key: const Key('dayForward'),
                icon: const Icon(Icons.chevron_right),
                onPressed: isToday ? null : () => _move(1),
              ),
            ],
          ),
          sales.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(errorMessage(e)),
            data: (d) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(S.billsCount, '${d.billCount}', key: const Key('salesBills')),
                _line(S.salesTotal, Money.format(d.totalPaise), bold: true, key: const Key('salesTotal')),
                if (d.discountPaise > 0) _line(S.discountLabel, Money.format(d.discountPaise)),
                _line(S.gstIncluded, Money.format(d.gstPaise), muted: true),
                const SectionTitle(S.paidBy),
                _line(S.cash, Money.format(d.mode('cash')), key: const Key('modeCash')),
                _line('UPI', Money.format(d.mode('upi')), key: const Key('modeUpi')),
                if (d.mode('card') > 0) _line('Card', Money.format(d.mode('card'))),
                _line(S.credit, Money.format(d.mode('credit')), key: const Key('modeCredit')),
              ],
            ),
          ),
          cash.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => EmptyState(errorMessage(e)),
            data: (c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(S.cashInHand),
                _line(S.cashOpening, Money.format(c.openingPaise)),
                _line('+ ${S.cashSales}', Money.format(c.cashSalesPaise)),
                _line('+ ${S.cashReceived}', Money.format(c.cashReceiptsPaise)),
                _line('- ${S.cashPaidOut}', Money.format(c.cashPaidOutPaise)),
                const Divider(),
                _line(S.cashClosing, Money.format(c.closingPaise), bold: true, key: const Key('cashClosing')),
                const SizedBox(height: 8),
                const Text(S.cashNote, style: TextStyle(color: AppPalette.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Item profit ---------------------------------------------------------------

enum _Period { today, week, month, custom }

class ItemProfitScreen extends ConsumerStatefulWidget {
  const ItemProfitScreen({super.key});

  @override
  ConsumerState<ItemProfitScreen> createState() => _ItemProfitScreenState();
}

class _ItemProfitScreenState extends ConsumerState<ItemProfitScreen> {
  _Period _period = _Period.month;
  DateTimeRange? _custom;

  ({DateTime from, DateTime to}) get _range {
    final now = DateTime.now();
    final today = startOfDay(now);
    switch (_period) {
      case _Period.today:
        return (from: today, to: today);
      case _Period.week:
        return (from: DateTime(today.year, today.month, today.day - 6), to: today);
      case _Period.month:
        return (from: DateTime(today.year, today.month, 1), to: today);
      case _Period.custom:
        final c = _custom ?? DateTimeRange(start: today, end: today);
        return (from: startOfDay(c.start), to: startOfDay(c.end));
    }
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _custom,
    );
    if (r != null) {
      setState(() {
        _custom = r;
        _period = _Period.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final report = ref.watch(itemProfitProvider(range));
    return Scaffold(
      appBar: AppBar(title: const Text(S.itemProfit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final (p, label) in const [
                (_Period.today, 'Today'),
                (_Period.week, 'Last 7 days'),
                (_Period.month, 'This month'),
              ])
                ChoiceChip(
                  key: Key('period_${p.name}'),
                  label: Text(label),
                  selected: _period == p,
                  onSelected: (_) => setState(() => _period = p),
                ),
              ChoiceChip(
                key: const Key('period_custom'),
                label: const Text('Pick dates'),
                selected: _period == _Period.custom,
                onSelected: (_) => _pickRange(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${formatDate(range.from)} to ${formatDate(range.to)}',
              style: const TextStyle(color: AppPalette.muted)),
          report.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => EmptyState(errorMessage(e)),
            data: (r) {
              if (r.rows.isEmpty) return const EmptyState(S.noSalesInPeriod);
              final margin = r.taxableSalesPaise == 0
                  ? 0.0
                  : r.profitPaise * 100 / r.taxableSalesPaise;
              final known = [for (final x in r.rows) if (x.taxableSalesPaise > 0 || x.costPaise > 0) x];
              final unknown = [for (final x in r.rows) if (x.unknownCostSalesPaise > 0) x];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _line(S.salesExGst, Money.format(r.taxableSalesPaise), key: const Key('profitSales')),
                        _line(S.costOfGoods, Money.format(r.costPaise), key: const Key('profitCost')),
                        const Divider(),
                        _line(S.profit, Money.format(r.profitPaise),
                            bold: true, key: const Key('profitTotal')),
                        _line(S.margin, '${margin.toStringAsFixed(1)}%', muted: true),
                      ]),
                    ),
                  ),
                  const SectionTitle(S.byItem),
                  for (final x in known)
                    ListTile(
                      key: Key('profitRow_${x.item.name}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(x.item.name),
                      subtitle: Text('Sold ${formatStock(x.item, x.qtyBase)}  •  '
                          'sales ${Money.format(x.taxableSalesPaise)}'),
                      trailing: Text(Money.format(x.profitPaise),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: x.profitPaise < 0 ? AppPalette.red : null,
                          )),
                    ),
                  if (unknown.isNotEmpty) ...[
                    const SectionTitle(S.costUnknown),
                    const Text(S.costUnknownHelp, style: TextStyle(color: AppPalette.muted)),
                    for (final x in unknown)
                      ListTile(
                        key: Key('unknownRow_${x.item.name}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(x.item.name),
                        trailing: Text(Money.format(x.unknownCostSalesPaise)),
                      ),
                  ],
                  const SizedBox(height: 12),
                  const Text(S.returnsNote, style: TextStyle(color: AppPalette.muted)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---- Stock value -----------------------------------------------------------------

class StockValueScreen extends ConsumerWidget {
  const StockValueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stockValueProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.stockValue)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (r) {
          if (r.rows.isEmpty) return const EmptyState(S.noStockOnHand);
          final known = [for (final x in r.rows) if (x.costPaise != null) x];
          final unknown = r.unknownCost;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _line(S.stockValueTotal, Money.format(r.totalPaise),
                      bold: true, key: const Key('stockValueTotal')),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(S.stockValueNote, style: TextStyle(color: AppPalette.muted)),
              ),
              const SectionTitle(S.byItem),
              for (final x in known)
                ListTile(
                  key: Key('valueRow_${x.item.name}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(x.item.name),
                  subtitle: Text('${formatStock(x.item, x.balanceBase)} at '
                      '${formatRate(x.item, x.costPaise!)}'),
                  trailing: Text(Money.format(x.valuePaise),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              if (unknown.isNotEmpty) ...[
                const SectionTitle(S.costUnknown),
                const Text(S.costUnknownStockHelp, style: TextStyle(color: AppPalette.muted)),
                for (final x in unknown)
                  ListTile(
                    key: Key('unknownValue_${x.item.name}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(x.item.name),
                    trailing: Text(formatStock(x.item, x.balanceBase)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
