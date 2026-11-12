import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../auth/owner_approval.dart';
import '../parties/parties_providers.dart';
import '../reports/reports_providers.dart';
import 'purchase_providers.dart';
import 'purchase_screen.dart';

/// Supplier purchases, newest first.
class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(purchasesProvider);
    final twice = ref.watch(duplicatePurchasesProvider).valueOrNull ?? const <String>{};
    return Scaffold(
      appBar: AppBar(title: const Text(S.purchasesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('newPurchase'),
        onPressed: () async {
          await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const PurchaseScreen()));
          ref.invalidate(purchasesProvider);
          ref.invalidate(duplicatePurchasesProvider);
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
              final cancelled = p.purchase.status == 'cancelled';
              return ListTile(
                key: Key('purchase_${p.purchase.id}'),
                title: Text(p.supplierName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.purchase.supplierInvoiceNo}  •  ${formatDate(p.purchase.supplierInvoiceDate)}'),
                    if (cancelled || twice.contains(p.purchase.id))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: cancelled
                            ? const StatusChip(S.cancelledBadge, color: AppPalette.red)
                            : StatusChip(S.purchaseTwiceBadge, key: Key('twice_${p.purchase.id}')),
                      ),
                  ],
                ),
                trailing: Text(
                  Money.format(p.purchase.totalPaise),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                    color: cancelled ? AppPalette.muted : null,
                  ),
                ),
                onTap: () async {
                  await Navigator.of(context).push<void>(MaterialPageRoute(
                      builder: (_) => PurchaseDetailScreen(purchaseId: p.purchase.id)));
                  ref.invalidate(purchasesProvider);
                  ref.invalidate(duplicatePurchasesProvider);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// A saved purchase (read-only: posted purchases are never edited, only
/// cancelled by reversing entries).
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({super.key, required this.purchaseId});
  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(purchaseDetailsProvider(purchaseId));
    final twice = ref.watch(duplicatePurchasesProvider).valueOrNull?.contains(purchaseId) ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text(S.purchasesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(errorMessage(e)),
        data: (d) {
          final cancelled = d.purchase.status == 'cancelled';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(d.supplier.name, style: Theme.of(context).textTheme.titleLarge),
              Text('${d.purchase.supplierInvoiceNo}  •  ${formatDate(d.purchase.supplierInvoiceDate)}'),
              if (cancelled || twice)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: cancelled
                        ? const StatusChip(S.cancelledBadge, color: AppPalette.red)
                        : const StatusChip(S.purchaseTwiceBadge),
                  ),
                ),
              const SizedBox(height: 16),
              CardGroup(margin: EdgeInsets.zero, indent: 16, children: [
                for (final l in d.lines)
                  ListTile(
                    title: Text(d.itemNames[l.itemId] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${l.qtyEntered} ${l.unitName} at ${Money.format(l.ratePaise)}  •  GST ${l.gstRateBp ~/ 100}%'),
                    trailing: Text(Money.format(l.lineTotalPaise)),
                  ),
              ]),
              const SizedBox(height: 16),
              _row(S.taxableTotal, d.purchase.subtotalPaise),
              _row(S.gstAmount, d.purchase.taxPaise),
              _row(S.grandTotal, d.purchase.totalPaise, bold: true),
              if (!cancelled) ...[
                const SizedBox(height: 24),
                Text(S.purchaseCancelHelp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.muted)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('cancelPurchase'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppPalette.red),
                  onPressed: () => _cancel(context, ref, d.purchase.supplierInvoiceNo, d.purchase.totalPaise),
                  icon: const Icon(Icons.undo),
                  label: const Text(S.purchaseCancel),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, String no, int total) async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(S.purchaseCancelConfirm(no, Money.format(total))),
          const SizedBox(height: 12),
          TextField(
            key: const Key('cancelPurchaseReason'),
            controller: reason,
            decoration: const InputDecoration(labelText: S.purchaseCancelReason, border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text(S.cancel)),
          FilledButton(
            key: const Key('cancelPurchaseConfirm'),
            style: FilledButton.styleFrom(backgroundColor: AppPalette.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text(S.purchaseCancel),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final approver = await askOwnerApproval(context, ref, what: S.purchaseCancelWhat(no));
    if (approver == null) return;
    try {
      await ref.read(purchaseRepositoryProvider).cancelPurchase(
            purchaseId,
            reason: reason.text,
            createdBy: ref.read(actingUserIdProvider),
            approvedBy: approver,
          );
      ref.invalidate(purchaseDetailsProvider(purchaseId));
      ref.invalidate(purchasesProvider);
      ref.invalidate(duplicatePurchasesProvider);
      ref.invalidate(stockBalancesProvider);
      ref.invalidate(dashboardProvider);
      refreshBalances(ref);
      if (context.mounted) toast(context, S.purchaseCancelled);
    } catch (e) {
      if (context.mounted) toastError(context, e);
    }
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

/// A warning on Home while a supplier bill stands twice (usually once from
/// each phone). Owner only.
class DuplicatePurchaseNote extends ConsumerWidget {
  const DuplicatePurchaseNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(duplicatePurchasesProvider).valueOrNull ?? const <String>{};
    if (ids.isEmpty) return const SizedBox.shrink();
    // Each bill entered twice has two ids standing.
    final bills = (ids.length / 2).ceil();
    return Card(
      key: const Key('purchaseTwiceNote'),
      color: AppPalette.amberTint,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.content_copy_outlined, color: AppPalette.amber),
        title: Text(S.purchaseTwiceNote(bills)),
        subtitle: const Text(S.purchaseTwiceHelp),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => const PurchasesScreen()));
          ref.invalidate(duplicatePurchasesProvider);
        },
      ),
    );
  }
}
