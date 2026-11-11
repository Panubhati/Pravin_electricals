import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'purchase_providers.dart';
import 'purchase_screen.dart';

/// Supplier purchases, newest first.
class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(purchasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.purchasesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('newPurchase'),
        onPressed: () async {
          await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const PurchaseScreen()));
          ref.invalidate(purchasesProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text(S.newPurchase),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (purchases) {
          if (purchases.isEmpty) return const EmptyState(S.noPurchases);
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: purchases.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = purchases[i];
              return ListTile(
                key: Key('purchase_${p.purchase.id}'),
                title: Text(p.supplierName),
                subtitle: Text(
                    '${p.purchase.supplierInvoiceNo}  •  ${formatDate(p.purchase.supplierInvoiceDate)}'),
                trailing: Text(
                  Money.format(p.purchase.totalPaise),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.of(context).push<void>(MaterialPageRoute(
                    builder: (_) => PurchaseDetailScreen(purchaseId: p.purchase.id))),
              );
            },
          );
        },
      ),
    );
  }
}

/// A saved purchase (read-only: posted purchases are never edited).
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({super.key, required this.purchaseId});
  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(purchaseDetailsProvider(purchaseId));
    return Scaffold(
      appBar: AppBar(title: const Text(S.purchasesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(d.supplier.name, style: Theme.of(context).textTheme.titleLarge),
            Text('${d.purchase.supplierInvoiceNo}  •  ${formatDate(d.purchase.supplierInvoiceDate)}'),
            const Divider(height: 24),
            for (final l in d.lines)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(d.itemNames[l.itemId] ?? ''),
                subtitle: Text(
                    '${l.qtyEntered} ${l.unitName} at ${Money.format(l.ratePaise)}  •  GST ${l.gstRateBp / 100}%'),
                trailing: Text(Money.format(l.lineTotalPaise)),
              ),
            const Divider(height: 24),
            _row(S.taxableTotal, d.purchase.subtotalPaise),
            _row(S.gstAmount, d.purchase.taxPaise),
            _row(S.grandTotal, d.purchase.totalPaise, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, int paise, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(k, style: style), Text(Money.format(paise), style: style)],
      ),
    );
  }
}
