import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../parties/dues_screen.dart';
import '../parties/party_detail_screen.dart';
import '../reports/reports_providers.dart';
import '../reports/reports_screens.dart';
import '../stock/stock_screen.dart';

/// The owner's summary at the top of the home screen: today's sales, cash in
/// hand, low stock and the biggest dues. Hidden for counter staff.
class DashboardCard extends ConsumerWidget {
  const DashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    return async.when(
      loading: () => const Card(
        child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(errorMessage(e)))),
      data: (d) {
        void open(Widget screen) =>
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
        Widget stat(Key key, String label, String value, {VoidCallback? onTap, Color? color}) =>
            Expanded(
              child: InkWell(
                key: key,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 2),
                      Text(value,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
              ),
            );

        final low = d.lowStockCount + d.negativeStockCount;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  stat(const Key('dashSales'), S.todaySales, Money.format(d.today.totalPaise),
                      onTap: () => open(const DailySalesScreen())),
                  stat(const Key('dashCash'), S.dashboardCash, Money.format(d.cash.closingPaise),
                      onTap: () => open(const DailySalesScreen())),
                ]),
                Row(children: [
                  stat(const Key('dashBills'), S.billsCount, '${d.today.billCount}',
                      onTap: () => open(const DailySalesScreen())),
                  stat(
                    const Key('dashLowStock'),
                    S.lowStockItems,
                    '$low',
                    color: low > 0 ? Colors.orange.shade800 : null,
                    onTap: () => open(const StockScreen(initialFilter: StockFilter.low)),
                  ),
                ]),
                const Divider(),
                InkWell(
                  key: const Key('dashDues'),
                  onTap: () => open(const DuesScreen()),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(S.totalDues, style: Theme.of(context).textTheme.titleSmall)),
                        const SizedBox(width: 8),
                        Text(Money.format(d.totalDuePaise),
                            key: const Key('dashTotalDue'),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (d.topDues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(S.noDuesYet, style: TextStyle(color: Colors.grey)),
                  )
                else
                  for (final p in d.topDues)
                    ListTile(
                      key: Key('dashDue_${p.party.name}'),
                      dense: true,
                      title: Text(p.party.name),
                      subtitle: p.buckets.overdue > 0
                          ? Text('${Money.format(p.buckets.overdue)} overdue (over 30 days)',
                              style: const TextStyle(color: Colors.red))
                          : null,
                      trailing: Text(Money.format(p.buckets.totalDue)),
                      onTap: () => open(PartyDetailScreen(partyId: p.party.id)),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
