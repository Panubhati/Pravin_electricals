import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../bootstrap.dart';
import '../db/app_database.dart';
import 'pairing.dart';
import 'peer_finder.dart';
import 'phones.dart';
import 'sync_crypto.dart';
import 'sync_engine.dart';
import 'sync_transport.dart';

enum SyncHealth {
  /// No other phone has been paired.
  off,

  /// Paired, but the other phone has not answered yet (not on the Wi-Fi, app closed).
  searching,

  /// Everything from the other phone is here.
  synced,

  /// The other phone answered but something went wrong (shown to the owner).
  problem,
}

class SyncStatus {
  const SyncStatus({required this.state, this.lastSyncAt, this.message, this.clockSkew});
  final SyncHealth state;
  final DateTime? lastSyncAt;
  final String? message;

  /// How far the other phone's clock is from this one (warned above 2 minutes).
  final Duration? clockSkew;

  static const off = SyncStatus(state: SyncHealth.off);
}

/// Runs Wi-Fi sync while the app is open: listens for the other phone, pulls
/// its new changes every few seconds (and at once when it says it has some),
/// and tells it when this phone has new ones. Billing never waits for sync.
class SyncService {
  SyncService({
    required this.db,
    required this.session,
    required this.makeCopy,
    this.finder,
    this.interval = const Duration(seconds: 5),
    this.onDataChanged,
    this.listenPort = syncPort,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final ShopSession session;
  final Future<File> Function() makeCopy;
  final PeerFinder? finder;
  final Duration interval;
  final int listenPort;

  /// Called after changes from the other phone were saved here (screens refresh).
  final VoidCallback? onDataChanged;
  final DateTime Function() _clock;

  final status = ValueNotifier<SyncStatus>(SyncStatus.off);

  SyncServer? _server;
  Timer? _timer;
  StreamSubscription<void>? _outboxWatch;
  StreamSubscription<FoundPeer>? _found;
  Timer? _nudgeDebounce;
  bool _running = false;
  bool _again = false;
  int _lastNudgedSeq = -1;

  SyncStore get store => SyncStore(db);
  SyncEngine get engine => SyncEngine(session.ctx);
  PhoneInfo get me => PhoneInfo(
        deviceId: session.deviceId,
        label: _myLabel ?? 'Phone ${session.series}',
        series: session.series,
      );
  String? _myLabel;
  int get port => _server?.port ?? 0;

  /// Starts listening and syncing if this phone is paired (or [forPairing],
  /// when the owner is about to show the QR).
  Future<void> start({bool forPairing = false}) async {
    if (_running) return;
    final key = forPairing ? await store.ensureShopKey() : await store.shopKey();
    if (key == null) {
      status.value = SyncStatus.off;
      return;
    }
    _running = true;
    final mine = await (db.select(db.devices)..where((t) => t.id.equals(session.deviceId))).getSingleOrNull();
    _myLabel = mine == null ? null : phoneName(mine);
    _server = SyncServer(
      db: db,
      me: me,
      key: key,
      engine: engine,
      makeCopy: makeCopy,
      onNudge: (_) => syncNow(),
      clock: _clock,
    );
    await _server!.start(port: listenPort);
    if (finder != null) {
      try {
        await finder!.start(myDeviceId: session.deviceId, port: port);
        _found = finder!.found.listen((p) async {
          if (p.deviceId == session.deviceId) return;
          await store.upsertPeer(p.deviceId, address: p.host, port: p.port);
          unawaited(syncNow());
        });
      } catch (_) {
        // Discovery is a help, not a need: the last known address still works.
      }
    }
    _outboxWatch = db.tableUpdates(TableUpdateQuery.onTable(db.outbox)).listen((_) => _scheduleNudge());
    _timer = Timer.periodic(interval, (_) => syncNow());
    final peers = await store.peers();
    status.value = SyncStatus(state: peers.isEmpty ? SyncHealth.off : SyncHealth.searching);
    unawaited(syncNow());
  }

  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _nudgeDebounce?.cancel();
    await _outboxWatch?.cancel();
    await _found?.cancel();
    try {
      await finder?.stop();
    } catch (_) {}
    await _server?.stop();
    _server = null;
  }

  /// Pulls from every paired phone now. Safe to call often: a call during a
  /// running sync waits for it and one more round.
  Future<void> syncNow() {
    if (!_running) return Future.value();
    if (_current != null) {
      _again = true;
      return _current!;
    }
    return _current = _loop().whenComplete(() => _current = null);
  }

  Future<void>? _current;

  Future<void> _loop() async {
    do {
      _again = false;
      await _syncAll();
    } while (_again && _running);
  }

  Future<void> _syncAll() async {
    final key = await store.shopKey();
    if (key == null) return;
    final peers = await store.peers();
    if (peers.isEmpty) {
      status.value = SyncStatus.off;
      return;
    }
    final client = SyncClient(key: key, me: me, myPort: port);
    SyncStatus? best;
    for (final p in peers) {
      if (p.deviceId == session.deviceId || p.address == null || p.port == null) continue;
      final s = await _syncWith(client, p);
      if (best == null || s.state.index > best.state.index || s.state == SyncHealth.synced) best = s;
    }
    status.value = best ?? const SyncStatus(state: SyncHealth.searching);
  }

  Future<SyncStatus> _syncWith(SyncClient client, SyncPeer p) async {
    try {
      final hello = await client.hello(p.address!, p.port!);
      if (hello.info.deviceId != p.deviceId) {
        // Another phone answered on that address (the Wi-Fi gave it a new one).
        await store.upsertPeer(hello.info.deviceId, label: hello.info.label, address: p.address, port: p.port);
        await store.upsertPeer(p.deviceId, address: '', port: 0);
        return const SyncStatus(state: SyncHealth.searching);
      }
      await store.upsertPeer(p.deviceId, label: hello.info.label);
      final skew = Duration(milliseconds: hello.clockMs - _clock().millisecondsSinceEpoch);
      var changed = 0;
      while (true) {
        final batch = await client.pull(p.address!, p.port!, await engine.cursor());
        final r = await engine.apply(batch, peer: p.deviceId);
        changed += r.applied;
        if (!batch.hasMore) {
          await store.peerSynced(p.deviceId, at: _clock(), seenOfMe: batch.senderCursor[session.deviceId]);
          break;
        }
      }
      if (changed > 0) onDataChanged?.call();
      return SyncStatus(state: SyncHealth.synced, lastSyncAt: _clock(), clockSkew: skew);
    } on SocketException {
      return SyncStatus(state: SyncHealth.searching, lastSyncAt: p.lastSyncAt);
    } on TimeoutException {
      return SyncStatus(state: SyncHealth.searching, lastSyncAt: p.lastSyncAt);
    } on HttpException {
      return SyncStatus(state: SyncHealth.searching, lastSyncAt: p.lastSyncAt);
    } catch (e) {
      final message = switch (e) {
        SyncHttpException(:final message) => message,
        SyncAuthException(:final message) => message,
        SyncException(:final message) => message,
        _ => '$e',
      };
      await store.peerFailed(p.deviceId, message);
      return SyncStatus(state: SyncHealth.problem, lastSyncAt: p.lastSyncAt, message: message);
    }
  }

  void _scheduleNudge() {
    _nudgeDebounce?.cancel();
    _nudgeDebounce = Timer(const Duration(milliseconds: 400), _nudgePeers);
  }

  /// Tells the other phone about new changes made on this phone (not ones
  /// that just arrived from it).
  Future<void> _nudgePeers() async {
    if (!_running) return;
    final mine = (await engine.cursor())[session.deviceId] ?? 0;
    if (mine == _lastNudgedSeq) return;
    _lastNudgedSeq = mine;
    final key = await store.shopKey();
    if (key == null) return;
    final client = SyncClient(key: key, me: me, myPort: port, timeout: const Duration(seconds: 3));
    for (final p in await store.peers()) {
      if (p.address == null || p.address!.isEmpty || p.port == null) continue;
      try {
        await client.nudge(p.address!, p.port!);
      } catch (_) {
        // The regular pull catches up anyway.
      }
    }
  }

  /// Shows a pairing QR: makes sure this phone listens, and returns the invite.
  Future<PairingInvite> invite() async {
    await start(forPairing: true);
    final host = await localWifiAddress();
    if (host == null) throw SyncException('This phone is not on a Wi-Fi network.');
    return PairingInvite(
      shopId: session.shopId,
      host: host,
      port: port,
      key: (await store.shopKey())!,
      token: await store.startPairing(now: _clock()),
      ownerDeviceId: session.deviceId,
    );
  }
}

/// Text for the copy a joining phone receives (for logs and tests).
String describeJoin(JoinPackage p) => jsonEncode({'owner': p.owner.deviceId, 'bytes': p.database.length});
