import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'db/app_database.dart';
import 'db/repositories/invoice_repository.dart';
import 'db/repositories/item_repository.dart';
import 'db/repositories/ledger_repository.dart';
import 'db/repositories/party_repository.dart';
import 'db/repositories/stock_repository.dart';

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
