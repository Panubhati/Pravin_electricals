import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../items/items_providers.dart';
import 'stock_item_screen.dart';

enum StockFilter { all, low, negative }

/// Stock on hand for every item, with Low and Negative filters.
class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key, this.initialFilter = StockFilter.all});

  /// Which filter to open on (the dashboard opens it on Low).
  final StockFilter initialFilter;

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  String _query = '';
  late StockFilter _filter = widget.initialFilter;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemListProvider((query: _query, inactive: false)));
    final balances = ref.watch(stockBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(S.stockTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('stockSearch'),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: S.searchStock,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(spacing: 8, children: [
              for (final (f, label) in [
                (StockFilter.all, S.filterAll),
                (StockFilter.low, S.filterLow),
                (StockFilter.negative, S.filterNegative),
              ])
                ChoiceChip(
                  key: Key('filter_${f.name}'),
                  label: Text(label),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                ),
            ]),
          ),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(errorMessage(e)),
              data: (list) {
                final bal = balances.valueOrNull ?? const <String, int>{};
                final shown = list.where((e) {
                  final qty = bal[e.item.id] ?? 0;
                  final low = e.item.minStockBase > 0 && qty >= 0 && qty < e.item.minStockBase;
                  return switch (_filter) {
                    StockFilter.all => true,
                    StockFilter.low => low,
                    StockFilter.negative => qty < 0,
                  };
                }).toList();
                if (shown.isEmpty) return const EmptyState(S.noStockItems);
                return ListView.separated(
                  itemCount: shown.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = shown[i].item;
                    final qty = bal[item.id] ?? 0;
                    final negative = qty < 0;
                    final low = item.minStockBase > 0 && !negative && qty < item.minStockBase;
                    return ListTile(
                      key: Key('stock_${item.id}'),
                      title: Text(item.name),
                      subtitle: Wrap(spacing: 6, children: [
                        if (item.brand != null) Text(item.brand!),
                        if (negative) const StatusChip(S.negativeStock, color: Colors.red),
                        if (low) const StatusChip(S.lowStock),
                      ]),
                      trailing: Text(
                        formatStock(item, qty),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: negative ? Colors.red : (low ? Colors.orange.shade800 : null),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(builder: (_) => StockItemScreen(itemId: item.id)),
                        );
                        if (mounted) ref.invalidate(stockBalancesProvider);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
