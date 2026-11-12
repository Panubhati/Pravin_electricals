import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'item_form_screen.dart';
import 'items_providers.dart';
import '../../shared/theme.dart';

/// The item master: search, add and edit items.
class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  String _query = '';
  bool _inactive = false;

  void _refresh() {
    ref.invalidate(itemListProvider);
    ref.invalidate(stockBalancesProvider);
  }

  Future<void> _open({String? itemId}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ItemFormScreen(itemId: itemId)),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(itemListProvider((query: _query, inactive: _inactive)));
    final balances = ref.watch(stockBalancesProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text(S.itemsTitle),
        actions: [
          PopupMenuButton<bool>(
            tooltip: S.showInactive,
            onSelected: (v) => setState(() => _inactive = v),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: !_inactive,
                checked: _inactive,
                child: const Text(S.showInactive),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: ref.watch(permissionsProvider).canEditPrices
          ? FloatingActionButton.extended(
              key: const Key('addItem'),
              onPressed: () => _open(),
              icon: const Icon(Icons.add),
              label: const Text(S.addItem),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('itemSearch'),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: S.searchItems,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(errorMessage(e)),
              data: (items) {
                if (items.isEmpty) return const EmptyState(S.noItems);
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = items[i];
                    final item = e.item;
                    final qty = balances[item.id] ?? 0;
                    final sub = [
                      if (item.brand != null) item.brand,
                      if (item.category != null) item.category,
                    ].join('  •  ');
                    return ListTile(
                      key: Key('item_${item.id}'),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sub.isNotEmpty) Text(sub),
                          Wrap(spacing: 6, children: [
                            if (!item.active) const StatusChip(S.inactive, color: AppPalette.muted),
                            if (e.retailRatePaise == null)
                              const StatusChip(S.noPriceChip, color: AppPalette.red),
                            if (item.active && qty < 0)
                              const StatusChip(S.negativeStock, color: AppPalette.red)
                            else if (item.active && item.minStockBase > 0 && qty < item.minStockBase)
                              const StatusChip(S.lowStock),
                          ]),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (e.retailRatePaise != null)
                            Text(formatRate(item, e.retailRatePaise!)),
                          Text(formatStock(item, qty),
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      onTap: () => _open(itemId: item.id),
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
