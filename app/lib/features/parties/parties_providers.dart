import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/dues_repository.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';

/// Parties for a list screen. The key is (kind 'customer' | 'supplier', search text).
final partyListProvider = FutureProvider.autoDispose
    .family<List<Party>, ({String kind, String query})>(
  (ref, key) => ref
      .watch(partyRepositoryProvider)
      .list(kind: key.kind, query: key.query),
);

/// Customers who owe money, with ageing, worst first.
final receivablesProvider = FutureProvider.autoDispose<List<PartyDues>>(
  (ref) => ref.watch(duesRepositoryProvider).receivables(),
);

/// Suppliers the shop owes, with ageing, worst first.
final payablesProvider = FutureProvider.autoDispose<List<PartyDues>>(
  (ref) => ref.watch(duesRepositoryProvider).payables(),
);

/// Re-reads everything that shows balances or dues. Call after a payment or an
/// opening balance.
void refreshBalances(WidgetRef ref) {
  ref.invalidate(partyBalancesProvider);
  ref.invalidate(receivablesProvider);
  ref.invalidate(payablesProvider);
  ref.invalidate(partyListProvider);
}

/// How a ledger balance reads for a person looking at it.
class BalanceLabel {
  const BalanceLabel(this.text, this.color);
  final String text;
  final Color? color;
}

/// Ledger balance as words. Customers: positive means they owe you. Suppliers:
/// negative means you owe them. Anything the other way round is an advance.
BalanceLabel balanceLabel(int balancePaise, {required bool supplierView}) {
  if (balancePaise == 0) return const BalanceLabel(S.settled, null);
  final owedToShop = balancePaise > 0;
  final abs = Money.format(balancePaise.abs());
  if (supplierView) {
    return owedToShop
        ? BalanceLabel('${S.advancePaid} $abs', Colors.green.shade800)
        : BalanceLabel('${S.youOwe} $abs', Colors.red.shade700);
  }
  return owedToShop
      ? BalanceLabel('${S.owes} $abs', Colors.red.shade700)
      : BalanceLabel('${S.advancePaid} $abs', Colors.green.shade800);
}
