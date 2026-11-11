import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/debug/sample_data.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../billing/bill_screen.dart';
import '../import/import_screen.dart';
import '../items/items_screen.dart';
import '../parties/dues_screen.dart';
import '../parties/parties_screen.dart';
import '../purchase/purchases_screen.dart';
import '../stock/stock_screen.dart';

/// One tile on the home screen.
class _HomeTile {
  const _HomeTile(this.keyName, this.icon, this.label, this.builder);
  final String keyName;
  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// All home tiles in one place; later milestones add theirs here.
final _tiles = <_HomeTile>[
  _HomeTile('tile_bill', Icons.receipt_long, S.newBill, (_) => const BillScreen()),
  _HomeTile('tile_items', Icons.inventory_2_outlined, S.items, (_) => const ItemsScreen()),
  _HomeTile('tile_stock', Icons.warehouse_outlined, S.stock, (_) => const StockScreen()),
  _HomeTile('tile_purchases', Icons.local_shipping_outlined, S.purchases,
      (_) => const PurchasesScreen()),
  _HomeTile('tile_customers', Icons.people_outline, S.customers,
      (_) => const PartiesScreen(kind: 'customer')),
  _HomeTile('tile_suppliers', Icons.business_outlined, S.suppliers,
      (_) => const PartiesScreen(kind: 'supplier')),
  _HomeTile('tile_dues', Icons.account_balance_wallet_outlined, S.dues,
      (_) => const DuesScreen()),
  _HomeTile('tile_import', Icons.upload_file_outlined, S.importData,
      (_) => const ImportScreen()),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(session.valueOrNull?.shop.name ?? S.appTitle)),
      body: session.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not open the database: $e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                for (final t in _tiles)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: Key(t.keyName),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: t.builder)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(t.icon, size: 36),
                          const SizedBox(height: 8),
                          Text(t.label, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final loaded = await SampleData.load(
                    s.ctx,
                    locationId: s.locationId,
                  );
                  ref.invalidate(stockBalancesProvider);
                  messenger.showSnackBar(SnackBar(
                    content: Text(loaded
                        ? S.sampleDataLoaded
                        : 'Items already exist, nothing loaded'),
                  ));
                },
                child: const Text(S.loadSampleData),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
