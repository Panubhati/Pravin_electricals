import 'package:drift/drift.dart';

import 'tables/audit_tables.dart';
import 'tables/core_tables.dart';
import 'tables/item_tables.dart';
import 'tables/party_tables.dart';
import 'tables/purchase_tables.dart';
import 'tables/sales_tables.dart';
import 'tables/stock_tables.dart';
import 'tables/reminder_tables.dart';
import 'tables/sync_tables.dart';

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
  AppSettings,
  SyncPeers,
  SyncState,
  Reminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump on every schema change and add a step in [migration].
  /// Never edit a released schema version; add a new one.
  /// The schema this build of the app writes.
  static const currentSchemaVersion = 7;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2 (A3): stock movement note, ledger payment mode, lookup indexes.
          if (from < 2) {
            await m.addColumn(stockMovements, stockMovements.note);
            await m.addColumn(ledgerEntries, ledgerEntries.paymentMode);
            await m.createIndex(stockMovementsItem);
            await m.createIndex(ledgerEntriesParty);
            await m.createIndex(itemsName);
            await m.createIndex(itemVariantsBarcode);
            await m.createIndex(invoicesDate);
          }
          // v3 (A4): per-shop settings (opening cash, discount limit, alerts).
          if (from < 3) {
            await m.createTable(appSettings);
          }
          // v4 (A5): the HSN an item had when a bill line was sold.
          if (from < 4) {
            await m.addColumn(invoiceLines, invoiceLines.hsn);
          }
          // v5 (A7): credit notes. The two return tables existed since v1 but were
          // never written to, so they are rebuilt with the new columns.
          if (from < 5) {
            await m.drop(salesReturnLines);
            await m.drop(salesReturns);
            await m.createTable(salesReturns);
            await m.createTable(salesReturnLines);
          }
          // v6 (A8): outbox origin phone and sequence for Wi-Fi sync; purchases
          // lose the unique supplier bill key (rebuilt) and get a plain index; two
          // phone-only tables remember the paired phone and the shop key.
          // Existing outbox rows are claimed by this phone in ensureShopSession.
          if (from < 6) {
            await m.addColumn(outbox, outbox.originDeviceId);
            await m.addColumn(outbox, outbox.seq);
            await m.addColumn(outbox, outbox.changedAtMs);
            await m.createIndex(outboxOriginSeq);
            await m.alterTable(TableMigration(purchases));
            await m.createIndex(purchasesSupplierNo);
            await m.createTable(syncPeers);
            await m.createTable(syncState);
          }
          // v7 (A11): payment reminders, and a per-customer switch to opt out.
          if (from < 7) {
            await m.addColumn(parties, parties.remindersOff);
            await m.createTable(reminders);
            await m.createIndex(remindersParty);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
