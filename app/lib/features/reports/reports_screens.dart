import '../../core/providers.dart';
import '../../core/permissions.dart';
import '../../core/printing/report_pdf.dart';
import '../../core/sharing/file_saver.dart';
import 'report_pdf_menu.dart';
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
    Widget tile(
      Key key,
      IconData icon,
      String title,
      String sub,
      Widget screen,
    ) => ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right, color: AppPalette.muted),
      onTap:
          () => Navigator.of(
            context,
          ).push<void>(MaterialPageRoute(builder: (_) => screen)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(S.reportsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CardGroup(
            children: [
              tile(
                const Key('reportDailySales'),
                Icons.today_outlined,
                S.dailySales,
                S.reportDailySalesSub,
                const DailySalesScreen(),
              ),
              tile(
                const Key('reportDayCheck'),
                Icons.fact_check_outlined,
                S.dayCheckTitle,
                S.reportDayCheckSub,
                const DayCheckScreen(),
              ),
            ],
          ),
          CardGroup(
            children: [
              tile(
                const Key('reportItemProfit'),
                Icons.trending_up,
                S.itemProfit,
                S.reportItemProfitSub,
                const ItemProfitScreen(),
              ),
              tile(
                const Key('reportStockValue'),
                Icons.inventory_outlined,
                S.stockValue,
                S.reportStockValueSub,
                const StockValueScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _line(
  String label,
  String value, {
  bool bold = false,
  bool muted = false,
  Key? key,
}) {
  final style =
      bold
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
      appBar: AppBar(title: Text(S.dailySales), actions: [
        ReportPdfMenu(
          filename: FileNames.dailySales(_day),
          doc: () async {
            final reports = ref.read(reportsRepositoryProvider);
            final bills = await ref.read(invoiceRepositoryProvider).list(from: _day, to: _day, limit: 100000);
            return dailySalesDoc(await reports.dailySales(_day), await reports.cashPosition(_day), bills.reversed.toList());
          },
        ),
      ]),
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
                    child: Text(
                      isToday
                          ? S.todayDate(formatDate(_day))
                          : formatDate(_day),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
            loading: () => const LoadingView(),
            error: (e, _) => EmptyState(errorMessage(e)),
            data:
                (d) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(
                      S.billsCount,
                      '${d.billCount}',
                      key: const Key('salesBills'),
                    ),
                    _line(
                      S.salesTotal,
                      Money.format(d.totalPaise),
                      bold: true,
                      key: const Key('salesTotal'),
                    ),
                    if (d.discountPaise > 0)
                      _line(S.discountLabel, Money.format(d.discountPaise)),
                    _line(S.gstIncluded, Money.format(d.gstPaise), muted: true),
                    SectionTitle(S.paidBy),
                    _line(
                      S.cash,
                      Money.format(d.mode('cash')),
                      key: const Key('modeCash'),
                    ),
                    _line(
                      S.modeUpi,
                      Money.format(d.mode('upi')),
                      key: const Key('modeUpi'),
                    ),
                    if (d.mode('card') > 0)
                      _line(S.modeCard, Money.format(d.mode('card'))),
                    _line(
                      S.credit,
                      Money.format(d.mode('credit')),
                      key: const Key('modeCredit'),
                    ),
                  ],
                ),
          ),
          cash.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => EmptyState(errorMessage(e)),
            data:
                (c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(S.cashInHand),
                    _line(S.cashOpening, Money.format(c.openingPaise)),
                    _line('+ ${S.cashSales}', Money.format(c.cashSalesPaise)),
                    _line(
                      '+ ${S.cashReceived}',
                      Money.format(c.cashReceiptsPaise),
                    ),
                    _line(
                      '- ${S.cashPaidOut}',
                      Money.format(c.cashPaidOutPaise),
                    ),
                    const Divider(),
                    _line(
                      S.cashClosing,
                      Money.format(c.closingPaise),
                      bold: true,
                      key: const Key('cashClosing'),
                    ),
                    const SizedBox(height: 8),
                    Text(S.cashNote, style: TextStyle(color: AppPalette.muted)),
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
        return (
          from: DateTime(today.year, today.month, today.day - 6),
          to: today,
        );
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
      appBar: AppBar(title: Text(S.itemProfit), actions: [
        ReportPdfMenu(
          filename: FileNames.itemProfit(range.from, range.to),
          doc: () async =>
              itemProfitDoc(await ref.read(reportsRepositoryProvider).itemProfit(range.from, range.to), range.from, range.to),
        ),
      ]),
      // Built lazily: a month can have hundreds of items sold.
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final (p, label) in [
                            (_Period.today, S.periodToday),
                            (_Period.week, S.periodWeek),
                            (_Period.month, S.periodMonth),
                          ])
                            ChoiceChip(
                              key: Key('period_${p.name}'),
                              label: Text(label),
                              selected: _period == p,
                              onSelected: (_) => setState(() => _period = p),
                            ),
                          ChoiceChip(
                            key: const Key('period_custom'),
                            label: Text(S.pickDates),
                            selected: _period == _Period.custom,
                            onSelected: (_) => _pickRange(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.dateRange(
                          formatDate(range.from),
                          formatDate(range.to),
                        ),
                        style: const TextStyle(color: AppPalette.muted),
                      ),
                    ],
                  ),
                ),
                report.when(
                  loading:
                      () => const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: LoadingView(),
                        ),
                      ),
                  error:
                      (e, _) => SliverToBoxAdapter(
                        child: EmptyState(errorMessage(e)),
                      ),
                  data: (r) {
                    if (r.rows.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyState(S.noSalesInPeriod),
                      );
                    }
                    final margin =
                        r.taxableSalesPaise == 0
                            ? 0.0
                            : r.profitPaise * 100 / r.taxableSalesPaise;
                    final known = [
                      for (final x in r.rows)
                        if (x.taxableSalesPaise > 0 || x.costPaise > 0) x,
                    ];
                    final unknown = [
                      for (final x in r.rows)
                        if (x.unknownCostSalesPaise > 0) x,
                    ];
                    final profitKeys = RowKeys(), unknownKeys = RowKeys();
                    // Names worked out once: rows are built (and rebuilt) lazily.
                    final knownNames = [
                      for (final x in known)
                        profitKeys.of(x.item.name, x.item.id),
                    ];
                    final unknownNames = [
                      for (final x in unknown)
                        unknownKeys.of(x.item.name, x.item.id),
                    ];
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _line(
                                        S.salesExGst,
                                        Money.format(r.taxableSalesPaise),
                                        key: const Key('profitSales'),
                                      ),
                                      _line(
                                        S.costOfGoods,
                                        Money.format(r.costPaise),
                                        key: const Key('profitCost'),
                                      ),
                                      const Divider(),
                                      _line(
                                        S.profit,
                                        Money.format(r.profitPaise),
                                        bold: true,
                                        key: const Key('profitTotal'),
                                      ),
                                      _line(
                                        S.margin,
                                        '${margin.toStringAsFixed(1)}%',
                                        muted: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SectionTitle(S.byItem),
                            ],
                          ),
                        ),
                        SliverCardGroup(
                          count: known.length,
                          itemBuilder: (_, i) {
                            final x = known[i];
                            return ListTile(
                              key: Key('profitRow_${knownNames[i]}'),
                              title: Text(
                                x.item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                S.soldQtySales(
                                  formatStock(x.item, x.qtyBase),
                                  Money.format(x.taxableSalesPaise),
                                ),
                              ),
                              trailing: Text(
                                Money.format(x.profitPaise),
                                style: TextStyle(
                                  color:
                                      x.profitPaise < 0 ? AppPalette.red : null,
                                ),
                              ),
                            );
                          },
                        ),
                        if (unknown.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                SectionTitle(S.costUnknown),
                                Text(
                                  S.costUnknownHelp,
                                  style: TextStyle(color: AppPalette.muted),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          SliverCardGroup(
                            count: unknown.length,
                            itemBuilder: (_, i) {
                              final x = unknown[i];
                              return ListTile(
                                key: Key('unknownRow_${unknownNames[i]}'),
                                title: Text(
                                  x.item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  Money.format(x.unknownCostSalesPaise),
                                ),
                              );
                            },
                          ),
                        ],
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.returnsNote,
                              style: TextStyle(color: AppPalette.muted),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
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
      appBar: AppBar(title: Text(S.stockValue), actions: [
        ReportPdfMenu(
          filename: FileNames.stock(DateTime.now()),
          doc: () async {
            final reports = ref.read(reportsRepositoryProvider);
            return stockDoc(await reports.stockValue(), await reports.lowStock(), DateTime.now(),
                showCost: ref.read(permissionsProvider).canSeeCost);
          },
        ),
      ]),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (r) {
          if (r.rows.isEmpty) return EmptyState(S.noStockOnHand);
          final known = [
            for (final x in r.rows)
              if (x.costPaise != null) x,
          ];
          final unknown = r.unknownCost;
          final valueKeys = RowKeys(), unknownValueKeys = RowKeys();
          // Names worked out once: rows are built (and rebuilt) lazily.
          final valueNames = [
            for (final x in known) valueKeys.of(x.item.name, x.item.id),
          ];
          final unknownNames = [
            for (final x in unknown)
              unknownValueKeys.of(x.item.name, x.item.id),
          ];
          // Built lazily: a shop can have hundreds of items in stock.
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _line(
                                S.stockValueTotal,
                                Money.format(r.totalPaise),
                                bold: true,
                                key: const Key('stockValueTotal'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              S.stockValueNote,
                              style: TextStyle(color: AppPalette.muted),
                            ),
                          ),
                          SectionTitle(S.byItem),
                        ],
                      ),
                    ),
                    SliverCardGroup(
                      count: known.length,
                      itemBuilder: (_, i) {
                        final x = known[i];
                        return ListTile(
                          key: Key('valueRow_${valueNames[i]}'),
                          title: Text(
                            x.item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            S.qtyAtRate(
                              formatStock(x.item, x.balanceBase),
                              formatRate(x.item, x.costPaise!),
                            ),
                          ),
                          trailing: Text(Money.format(x.valuePaise)),
                        );
                      },
                    ),
                    if (unknown.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SectionTitle(S.costUnknown),
                            Text(
                              S.costUnknownStockHelp,
                              style: TextStyle(color: AppPalette.muted),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      SliverCardGroup(
                        count: unknown.length,
                        itemBuilder: (_, i) {
                          final x = unknown[i];
                          return ListTile(
                            key: Key('unknownValue_${unknownNames[i]}'),
                            title: Text(
                              x.item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(formatStock(x.item, x.balanceBase)),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
