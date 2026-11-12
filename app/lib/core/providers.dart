import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup/backup_sharer.dart';
import 'backup/database_location.dart';
import '../app.dart';
import 'bootstrap.dart';
import 'db/app_database.dart';
import 'db/repositories/audit_repository.dart';
import 'db/repositories/auth_repository.dart';
import 'db/repositories/reports_repository.dart';
import 'db/repositories/settings_repository.dart';
import 'db/repositories/dues_repository.dart';
import 'db/repositories/invoice_repository.dart';
import 'db/repositories/item_repository.dart';
import 'db/repositories/ledger_repository.dart';
import 'db/repositories/party_repository.dart';
import 'db/repositories/purchase_repository.dart';
import 'db/repositories/setup_repository.dart';
import 'db/repositories/stock_repository.dart';
import 'import/item_import.dart';
import 'notifications/daily_summary.dart';
import 'printing/upi_link.dart';
import 'sharing/bill_sharer.dart';
import 'notifications/device_notifications.dart';
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

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepository(ref.watch(sessionProvider).requireValue.ctx),
);

final setupRepositoryProvider = Provider<SetupRepository>(
  (ref) => SetupRepository(ref.watch(sessionProvider).requireValue.ctx),
);

/// Overridden in tests with fakes. The real ones talk to Android.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => DeviceNotificationService(),
);

final summarySchedulerProvider = Provider<SummaryScheduler>(
  (ref) => WorkmanagerSummaryScheduler(),
);

/// Where customers' UPI payments go (the QR code on the Pay screen and on every
/// PDF), or null when no UPI ID has been set in Settings.
final upiPayeeProvider = FutureProvider.autoDispose<UpiPayee?>((ref) {
  final session = ref.watch(sessionProvider).requireValue;
  return ref.watch(settingsRepositoryProvider).upiPayee(session.shop.name);
});

/// Hands bill PDFs to WhatsApp or the share sheet. Overridden in tests.
final billSharerProvider = Provider<BillSharer>((ref) => DeviceBillSharer());

/// Where the database file lives (the real phone folder; tests override it).
final databaseLocationProvider = Provider<ShopDatabaseLocation>(
  (ref) => const DeviceDatabaseLocation(),
);

/// Starts the app over with a fresh database connection (used after a restore).
/// The real one is `AppRoot.restart`; tests replace it to watch for the call.
final appRestartProvider = Provider<void Function(BuildContext)>((ref) {
  return (context) => AppRoot.restart(context);
});

/// Sends backup files to the share sheet. Overridden in tests.
final backupSharerProvider = Provider<BackupSharer>((ref) => DeviceBackupSharer());

/// When the last backup was made or restored, or null if never.
final lastBackupProvider = FutureProvider.autoDispose<DateTime?>(
  (ref) => ref.watch(settingsRepositoryProvider).lastBackupAt(),
);
