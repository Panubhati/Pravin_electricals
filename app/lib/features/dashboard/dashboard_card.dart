import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
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
      loading: () => const Card(child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => AppCard(child: Text(errorMessage(e))),
      data: (d) {
        void open(Widget screen) =>
            Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
        final text = Theme.of(context).textTheme;

        Widget stat(Key key, String label, String value, {VoidCallback? onTap, Color? color, bool big = false}) =>
            Expanded(
              child: InkWell(
                key: key,
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: text.bodySmall?.copyWith(color: AppPalette.muted)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: (big ? text.headlineSmall : text.titleLarge)?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color ?? AppPalette.text,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                  child: Text(S.homeToday, style: text.labelLarge?.copyWith(color: AppPalette.muted)),
                ),
                Row(children: [
                  stat(const Key('dashSales'), S.todaySales, Money.format(d.today.totalPaise),
                      big: true, onTap: () => open(const DailySalesScreen())),
                  stat(const Key('dashCash'), S.dashboardCash, Money.format(d.cash.closingPaise),
                      big: true, onTap: () => open(const DailySalesScreen())),
                ]),
                Row(children: [
                  stat(const Key('dashBills'), S.billsCount, '${d.today.billCount}',
                      onTap: () => open(const DailySalesScreen())),
                  stat(
                    const Key('dashLowStock'),
                    S.lowStockItems,
                    '$low',
                    color: low > 0 ? AppPalette.amber : null,
                    onTap: () => open(const StockScreen(initialFilter: StockFilter.low)),
                  ),
                ]),
                const Divider(),
                InkWell(
                  key: const Key('dashDues'),
                  onTap: () => open(const DuesScreen()),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(S.totalDues, style: text.titleSmall)),
                        const SizedBox(width: 8),
                        Text(Money.format(d.totalDuePaise),
                            key: const Key('dashTotalDue'),
                            style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
                      ],
                    ),
                  ),
                ),
                if (d.topDues.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Text(S.noDuesYet, style: text.bodyMedium?.copyWith(color: AppPalette.muted)),
                  )
                else
                  for (final p in d.topDues)
                    ListTile(
                      key: Key('dashDue_${p.party.name}'),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(p.party.name),
                      subtitle: p.buckets.overdue > 0
                          ? Text('${Money.format(p.buckets.overdue)} overdue (over 30 days)',
                              style: const TextStyle(color: AppPalette.red))
                          : null,
                      trailing: Text(Money.format(p.buckets.totalDue), style: AppText.amount(context)),
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
