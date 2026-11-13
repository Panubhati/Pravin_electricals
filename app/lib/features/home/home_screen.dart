import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../reminders/reminders_screen.dart';
import '../sync/phones_screen.dart';
import '../../shared/strings.dart';
import '../../shared/theme.dart';
import '../../shared/widgets.dart';
import '../auth/lock_gate.dart';
import '../backup/backup_banner.dart';
import '../billing/bill_screen.dart';
import '../bills/bills_screens.dart';
import '../dashboard/dashboard_card.dart';
import '../datacheck/data_check_screen.dart';
import '../import/import_screen.dart';
import '../items/items_screen.dart';
import '../parties/dues_screen.dart';
import '../parties/parties_screen.dart';
import '../purchase/purchases_screen.dart';
import '../reports/reports_screens.dart';
import '../settings/settings_screen.dart';
import '../stock/stock_screen.dart';

/// One row on the home screen.
class _HomeTile {
  const _HomeTile(this.keyName, this.icon, this.label, this.builder, this.group, [this.allowed]);
  final String keyName;
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  /// Which section of the list it sits in.
  final String group;

  /// Who may see this row; null means everyone who is logged in.
  final bool Function(Permissions p)? allowed;
}

/// "New bill" is the big button on top; everything else is a grouped row.
// Getters, not finals: the labels must follow the language when it changes.
_HomeTile get _newBill => _HomeTile('tile_bill', Icons.receipt_long, S.newBill, (_) => const BillScreen(), 'sell');

List<_HomeTile> get _tiles => <_HomeTile>[
  _HomeTile('tile_bills', Icons.history, S.bills, (_) => const BillsScreen(), 'sell'),
  _HomeTile('tile_items', Icons.inventory_2_outlined, S.items, (_) => const ItemsScreen(), 'stock'),
  _HomeTile('tile_stock', Icons.warehouse_outlined, S.stock, (_) => const StockScreen(), 'stock'),
  _HomeTile('tile_purchases', Icons.local_shipping_outlined, S.purchases, (_) => const PurchasesScreen(), 'stock',
      (p) => p.canSeePurchases),
  _HomeTile('tile_customers', Icons.people_outline, S.customers, (_) => const PartiesScreen(kind: 'customer'), 'people'),
  _HomeTile('tile_suppliers', Icons.business_outlined, S.suppliers, (_) => const PartiesScreen(kind: 'supplier'), 'people',
      (p) => p.canSeePurchases),
  _HomeTile('tile_dues', Icons.account_balance_wallet_outlined, S.dues, (_) => const DuesScreen(), 'people'),
  _HomeTile('tile_reports', Icons.bar_chart_rounded, S.reports, (_) => const ReportsScreen(), 'shop',
      (p) => p.canSeeReports),
  _HomeTile('tile_import', Icons.upload_file_outlined, S.importData, (_) => const ImportScreen(), 'shop',
      (p) => p.canImport),
  _HomeTile('tile_settings', Icons.settings_outlined, S.settings, (_) => const SettingsScreen(), 'shop',
      (p) => p.canOpenSettings),
];

Map<String, String> get _groupTitles => {
  'sell': S.homeGroupSell,
  'stock': S.homeGroupStock,
  'people': S.homeGroupPeople,
  'shop': S.homeGroupShop,
};

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, _HomeTile t) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: t.builder));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final perms = ref.watch(permissionsProvider);
    final user = ref.watch(currentUserProvider);
    final tiles = [for (final t in _tiles) if (t.allowed?.call(perms) ?? true) t];
    return Scaffold(
      appBar: AppBar(
        title: Text(session.valueOrNull?.shop.name ?? S.appTitle),
        actions: [
          if (session.hasValue) const SyncStatusDot(),
          IconButton(
            key: const Key('lockNow'),
            icon: const Icon(Icons.lock_outline),
            tooltip: S.lockNow,
            onPressed: () => lockApp(ProviderScope.containerOf(context)),
          ),
        ],
      ),
      body: session.when(
        loading: () => const SkeletonList(),
        error: (e, _) => EmptyState(S.cannotOpenDb(e), icon: Icons.error_outline),
        data: (s) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 2),
                child: Text(
                  S.homeHello(user.name),
                  key: const Key('homeHello'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppPalette.muted),
                ),
              ),
            _NewBillButton(onTap: () => _open(context, _newBill)),
            const SizedBox(height: 16),
            if (perms.canOpenSettings) const DataCheckNote(),
            if (perms.canOpenSettings) const BackupBanner(),
            if (perms.canOpenSettings) const DuplicatePurchaseNote(),
            if (perms.canOpenSettings) const RemindersDueNote(),
            if (perms.canSeeReports) ...[
              const DashboardCard(),
              const SizedBox(height: 4),
            ],
            for (final group in _groupTitles.keys)
              if (tiles.any((t) => t.group == group)) ...[
                SectionTitle(_groupTitles[group]!),
                _GroupCard(
                  tiles: [for (final t in tiles) if (t.group == group) t],
                  onOpen: (t) => _open(context, t),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

/// The one thing staff do all day: a big, easy button.
class _NewBillButton extends StatelessWidget {
  const _NewBillButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppPalette.blue,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key(_newBill.keyName),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_newBill.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.newBill, style: t.titleLarge?.copyWith(color: Colors.white)),
                    Text(S.homeNewBillHint,
                        style: t.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// A white card holding a few rows, with a thin line between them.
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.tiles, required this.onOpen});
  final List<_HomeTile> tiles;
  final void Function(_HomeTile) onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            ListTile(
              key: Key(tiles[i].keyName),
              onTap: () => onOpen(tiles[i]),
              minVerticalPadding: 12,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppPalette.blueTint, borderRadius: BorderRadius.circular(10)),
                child: Icon(tiles[i].icon, size: 21, color: AppPalette.blue),
              ),
              title: Text(tiles[i].label, style: Theme.of(context).textTheme.titleMedium),
              trailing: const Icon(Icons.chevron_right, color: AppPalette.muted),
            ),
            if (i < tiles.length - 1) const Divider(indent: 70),
          ],
        ],
      ),
    );
  }
}
