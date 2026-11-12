import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, BooleanExpressionOperators, ComparableExpr;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/backup/backup_service.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/sync/pairing.dart';
import '../../core/sync/peer_finder.dart';
import '../../core/sync/sync_service.dart';
import '../audit/audit_screen.dart';
import '../bills/bills_screens.dart';
import '../dayclose/day_check_screen.dart';
import '../items/items_providers.dart';
import '../parties/parties_providers.dart';
import '../purchase/purchase_providers.dart';
import '../reports/reports_providers.dart';
import '../returns/return_screens.dart';

/// Finds the other phone on the Wi-Fi. Tests replace it (or set null).
final peerFinderProvider = Provider<PeerFinder?>((ref) => NsdPeerFinder());

/// Wi-Fi sync for this phone. Started and stopped by [SyncRunner] with the app.
final syncServiceProvider = Provider<SyncService>((ref) {
  final session = ref.watch(sessionProvider).requireValue;
  final db = ref.watch(databaseProvider);
  final location = ref.watch(databaseLocationProvider);
  final service = SyncService(
    db: db,
    session: session,
    makeCopy: () async => File((await BackupService(db, location).createBackup()).path),
    finder: ref.watch(peerFinderProvider),
    onDataChanged: () => refreshAfterSync(ref),
  );
  ref.onDispose(service.stop);
  return service;
});

/// Every list and summary that shows shop data reads again after changes
/// arrive from the other phone. A bill being typed is not touched.
void refreshAfterSync(Ref ref) {
  for (final p in <ProviderOrFamily>[
    stockBalancesProvider,
    partyBalancesProvider,
    receivablesProvider,
    payablesProvider,
    partyListProvider,
    itemListProvider,
    itemDetailProvider,
    billsProvider,
    invoiceDetailsProvider,
    purchasesProvider,
    purchaseDetailsProvider,
    duplicatePurchasesProvider,
    dashboardProvider,
    itemProfitProvider,
    stockValueProvider,
    dayCloseProvider,
    returnDetailsProvider,
    returnableProvider,
    invoiceReturnsProvider,
    auditProvider,
    loginUsersProvider,
    upiPayeeProvider,
    discountLimitProvider,
    billLanguageProvider,
    phonesProvider,
  ]) {
    ref.invalidate(p);
  }
}

/// The shop's phones with what this phone knows about each.
class PhoneRow {
  const PhoneRow({required this.device, required this.isThisPhone, this.peer});
  final Device device;
  final bool isThisPhone;
  final SyncPeer? peer;
}

final phonesProvider = FutureProvider.autoDispose<List<PhoneRow>>((ref) async {
  final session = ref.watch(sessionProvider).requireValue;
  final db = ref.watch(databaseProvider);
  final devices = await (db.select(db.devices)
        ..where((t) => t.shopId.equals(session.shopId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.invoiceSeriesPrefix)]))
      .get();
  final peers = {for (final p in await SyncStore(db).peers()) p.deviceId: p};
  return [
    for (final d in devices) PhoneRow(device: d, isThisPhone: d.id == session.deviceId, peer: peers[d.id]),
  ];
});

/// Clashes (the same thing changed on both phones before they synced) in the last week.
final recentClashesProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final since = DateTime.now().subtract(const Duration(days: 7));
  final rows = await (db.select(db.auditLog)
        ..where((t) => t.action.equals('sync_conflict') & t.ts.isBiggerOrEqualValue(since)))
      .get();
  return rows.length;
});

/// Starts sync when the app opens or comes back, and stops it when the app
/// goes to the background (Android would stop it anyway).
class SyncRunner extends ConsumerStatefulWidget {
  const SyncRunner({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SyncRunner> createState() => _SyncRunnerState();
}

class _SyncRunnerState extends ConsumerState<SyncRunner> with WidgetsBindingObserver {
  late final SyncService _service;

  @override
  void initState() {
    super.initState();
    _service = ref.read(syncServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    _service.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _service.start().then((_) => _service.syncNow());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _service.stop();
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _service.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
