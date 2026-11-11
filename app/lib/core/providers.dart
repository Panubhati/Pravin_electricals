import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'db/app_database.dart';
import 'db/repositories/auth_repository.dart';
import 'db/repositories/reports_repository.dart';
import 'db/repositories/settings_repository.dart';
import 'db/repositories/dues_repository.dart';
import 'db/repositories/invoice_repository.dart';
import 'db/repositories/item_repository.dart';
import 'db/repositories/ledger_repository.dart';
import 'db/repositories/party_repository.dart';
import 'db/repositories/purchase_repository.dart';
import 'db/repositories/stock_repository.dart';
import 'import/item_import.dart';
import 'import/party_import.dart';

/// Overridden in main() with the on-phone database, and in tests with an
/// in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Shop, device and location. Creates them on first run.
final sessionProvider = FutureProvider<ShopSession>((ref) async {
  return ensureShopSession(ref.watch(databaseProvider));
});

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => ItemRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final partyRepositoryProvider = Provider<PartyRepository>(
  (ref) => PartyRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => StockRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final invoiceRepositoryProvider = Provider<InvoiceRepository>(
  (ref) => InvoiceRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => PurchaseRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final duesRepositoryProvider = Provider<DuesRepository>(
  (ref) => DuesRepository(ref.watch(sessionProvider).requireValue.ctx),
);
final itemImportServiceProvider = Provider<ItemImportService>(
  (ref) => ItemImportService(ref.watch(sessionProvider).requireValue.ctx),
);
final partyImportServiceProvider = Provider<PartyImportService>(
  (ref) => PartyImportService(ref.watch(sessionProvider).requireValue.ctx),
);

// Lists. These are autoDispose, so they are read again each time a screen
// opens, and screens call ref.invalidate after a write. That keeps billing,
// stock and the ledger consistent across screens without streams.

/// Stock balance per item in base units (items with no movements are absent).
final stockBalancesProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.watch(stockRepositoryProvider).balancesByItem(),
);

/// Ledger balance per party in paise (positive: the party owes the shop).
final partyBalancesProvider = FutureProvider.autoDispose<Map<String, int>>(
  (ref) => ref.watch(ledgerRepositoryProvider).balancesByParty(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sessionProvider).requireValue.ctx),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(sessionProvider).requireValue.ctx),
);

final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ReportsRepository(ref.watch(sessionProvider).requireValue.ctx),
);
