import 'package:drift/drift.dart';

import 'tables/audit_tables.dart';
import 'tables/core_tables.dart';
import 'tables/item_tables.dart';
import 'tables/party_tables.dart';
import 'tables/purchase_tables.dart';
import 'tables/sales_tables.dart';
import 'tables/stock_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Shops,
  Users,
  Devices,
  Locations,
  Outbox,
  Items,
  ItemUnits,
  ItemVariants,
  ItemPrices,
  ItemCosts,
  Parties,
  LedgerEntries,
  Invoices,
  InvoiceLines,
  InvoicePayments,
  SalesReturns,
  SalesReturnLines,
  Purchases,
  PurchaseLines,
  StockMovements,
  AuditLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump on every schema change and add a step in [migration].
  /// Never edit a released schema version; add a new one.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Version 1 is the first release. Future upgrades go here, e.g.:
          // if (from < 2) { await m.addColumn(...); }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
