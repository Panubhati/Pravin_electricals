import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/reports_repository.dart';
import '../../core/providers.dart';

/// Everything on the owner's home screen. It re-reads whenever stock or party
/// balances are refreshed, which every bill, purchase, payment and import does.
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) {
  ref.watch(stockBalancesProvider);
  ref.watch(partyBalancesProvider);
  return ref.watch(reportsRepositoryProvider).dashboard();
});

final dailySalesProvider =
    FutureProvider.autoDispose.family<DailySales, DateTime>(
  (ref, day) => ref.watch(reportsRepositoryProvider).dailySales(day),
);

final cashPositionProvider =
    FutureProvider.autoDispose.family<CashPosition, DateTime>(
  (ref, day) => ref.watch(reportsRepositoryProvider).cashPosition(day),
);

final itemProfitProvider = FutureProvider.autoDispose
    .family<ItemProfitReport, ({DateTime from, DateTime to})>(
  (ref, range) =>
      ref.watch(reportsRepositoryProvider).itemProfit(range.from, range.to),
);

final stockValueProvider = FutureProvider.autoDispose<StockValueReport>(
  (ref) => ref.watch(reportsRepositoryProvider).stockValue(),
);
