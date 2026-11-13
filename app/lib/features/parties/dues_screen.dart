import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/dues_repository.dart';
import '../../core/dues/ageing.dart';
import '../../core/money.dart';
import '../../core/permissions.dart';
import '../reminders/reminders_screen.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'parties_providers.dart';
import 'party_detail_screen.dart';
import '../../shared/theme.dart';

/// Who owes the shop and whom the shop owes, with ageing (0-30, 31-60, 61-90,
/// 90+ days). Payments settle the oldest debts first.
class DuesScreen extends ConsumerWidget {
  const DuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // What the shop owes suppliers reveals its buying cost: owner only.
    final showPayables = ref.watch(permissionsProvider).canSeePurchases;
    if (!showPayables) {
      return Scaffold(
        appBar: AppBar(title: Text(S.duesTitle)),
        body: const _DuesList(payable: false),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.duesTitle),
          actions: [
            IconButton(
              key: const Key('openReminders'),
              tooltip: S.remindersTitle,
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed:
                  () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const RemindersScreen()),
                  ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(key: Key('tabReceivables'), text: S.receivables),
              Tab(key: Key('tabPayables'), text: S.payables),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DuesList(payable: false), _DuesList(payable: true)],
        ),
      ),
    );
  }
}

class _DuesList extends ConsumerWidget {
  const _DuesList({required this.payable});
  final bool payable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(payable ? payablesProvider : receivablesProvider);
    final name = payable ? 'payables' : 'receivables';
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => EmptyState(errorMessage(e)),
      data: (list) {
        if (list.isEmpty) return EmptyState(S.noDues);
        final total = DuesRepository.total(list);
        // Built lazily: the header card, then one row per person.
        return ListView.builder(
          itemCount: list.length + 1,
          itemBuilder: (context, i) {
            if (i > 0) return _row(context, ref, list[i - 1]);
            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.totalDue,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      Money.format(total.totalDue),
                      key: Key('duesTotal_$name'),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _bucketRow(S.bucket0, total.days0to30),
                    _bucketRow(S.bucket31, total.days31to60),
                    _bucketRow(S.bucket61, total.days61to90),
                    _bucketRow(S.bucket90, total.over90, bad: true),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _row(BuildContext context, WidgetRef ref, PartyDues d) => ListTile(
    key: Key('due_${d.party.id}'),
    title: Text(d.party.name),
    subtitle: Text(_summary(d.buckets)),
    trailing: Text(
      Money.format(d.buckets.totalDue),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: d.buckets.over90 > 0 ? AppPalette.red : null,
      ),
    ),
    onTap: () async {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => PartyDetailScreen(partyId: d.party.id),
        ),
      );
      refreshBalances(ref);
    },
  );

  Widget _bucketRow(String label, int paise, {bool bad = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label)),
        const SizedBox(width: 8),
        Text(
          Money.format(paise),
          style: TextStyle(color: bad && paise > 0 ? AppPalette.red : null),
        ),
      ],
    ),
  );

  String _summary(AgeingBuckets b) => [
    if (b.days0to30 > 0) '${S.bucket0}: ${Money.format(b.days0to30)}',
    if (b.days31to60 > 0) '${S.bucket31}: ${Money.format(b.days31to60)}',
    if (b.days61to90 > 0) '${S.bucket61}: ${Money.format(b.days61to90)}',
    if (b.over90 > 0) '${S.bucket90}: ${Money.format(b.over90)}',
  ].join('  •  ');
}
