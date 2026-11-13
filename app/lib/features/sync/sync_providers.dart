import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, BooleanExpressionOperators, ComparableExpr;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/backup/backup_service.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/sync/pairing.dart';
import '../../core/sync/background_sync.dart';
import '../../core/sync/peer_finder.dart';
import '../../core/sync/sync_service.dart';
import '../audit/audit_screen.dart';
import '../bills/bills_screens.dart';
import '../dayclose/day_check_screen.dart';
import '../items/items_providers.dart';
import '../parties/parties_providers.dart';
import '../purchase/purchase_providers.dart';
import '../reminders/reminders_screen.dart';
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

/// The phone's background service (A12). Tests replace it with a fake.
final backgroundSyncControlProvider = Provider<BackgroundSyncControl>((ref) => DeviceBackgroundSync());

/// Keeps the background service on while this phone is paired (A12). Started
/// by [SyncHost] with sync.
final backgroundSyncKeeperProvider = Provider<BackgroundSyncKeeper>((ref) {
  final keeper = BackgroundSyncKeeper(
    sync: ref.watch(syncServiceProvider),
    control: ref.watch(backgroundSyncControlProvider),
    settings: ref.watch(settingsRepositoryProvider),
  )..attach();
  ref.onDispose(keeper.detach);
  return keeper;
});

/// "Keep syncing when the app is closed" on this phone.
final backgroundSyncOnProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).backgroundSyncOn(),
);

/// Whether Android lets the app run in the background without limits.
final batteryUnrestrictedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(backgroundSyncControlProvider).batteryUnrestricted(),
);

/// Stops sync before the database file is replaced (restore, joining a shop),
/// so the other phone cannot read or write it during the swap.
Future<void> stopSync(WidgetRef ref) async {
  try {
    await ref.read(syncServiceProvider).stop();
  } catch (_) {
    // No shop session yet: sync never started.
  }
}

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
    dueRemindersProvider,
    reminderSettingsProvider,
    phonesProvider,
    otherPhoneStaleProvider,
  ]) {
    ref.invalidate(p);
  }
}

/// After this long without a sync, the bill warns on low-stock items (A12).
const staleSyncAfter = Duration(minutes: 30);

/// How long ago this phone last synced with the other phone, when that is
/// longer than [staleSyncAfter]; null when it is recent, never synced, or the
/// phone is not paired.
final otherPhoneStaleProvider = FutureProvider.autoDispose<Duration?>((ref) async {
  final session = ref.watch(sessionProvider).requireValue;
  final peers = (await SyncStore(ref.watch(databaseProvider)).peers()).where((p) => p.deviceId != session.deviceId);
  DateTime? last;
  for (final p in peers) {
    final at = p.lastSyncAt;
    if (at != null && (last == null || at.isAfter(last))) last = at;
  }
  if (last == null) return null;
  final age = DateTime.now().difference(last);
  return age > staleSyncAfter ? age : null;
});

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

/// Changes sync's pace with the app: every few seconds on screen, every two
/// minutes in the background (A12). Sync itself is started by [SyncHost] and
/// keeps running when the app is closed; this widget never stops it.
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
    _service.setBackground(false);
    _service.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _service.setBackground(false);
        _service.start().then((_) => _service.syncNow());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _service.setBackground(true);
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
