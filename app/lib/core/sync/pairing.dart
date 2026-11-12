import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'sync_crypto.dart';

/// What the owner's phone shows as a QR so a new phone can join the shop.
class PairingInvite {
  const PairingInvite({
    required this.shopId,
    required this.host,
    required this.port,
    required this.key,
    required this.token,
    required this.ownerDeviceId,
  });

  final String shopId;
  final String host;
  final int port;
  final ShopKey key;
  final String token;
  final String ownerDeviceId;

  static const _prefix = 'PESHOP1:';

  String encode() => _prefix +
      base64Url.encode(utf8.encode(jsonEncode({
        's': shopId,
        'h': host,
        'p': port,
        'k': key.text,
        't': token,
        'd': ownerDeviceId,
      })));

  /// Null when [text] is not a shop pairing code (some other QR or barcode).
  static PairingInvite? tryDecode(String text) {
    if (!text.startsWith(_prefix)) return null;
    try {
      final j = jsonDecode(utf8.decode(base64Url.decode(text.substring(_prefix.length)))) as Map<String, dynamic>;
      return PairingInvite(
        shopId: j['s'] as String,
        host: j['h'] as String,
        port: j['p'] as int,
        key: ShopKey.fromText(j['k'] as String),
        token: j['t'] as String,
        ownerDeviceId: j['d'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Phone-only sync state kept in the `sync_state` and `sync_peers` tables.
class SyncStore {
  SyncStore(this.db);
  final AppDatabase db;

  static const _shopKey = 'shop_key';
  static const _pairToken = 'pair_token';
  static const _pairExpires = 'pair_expires_ms';
  static const pairingValidFor = Duration(minutes: 10);

  Future<String?> _get(String key) async =>
      (await (db.select(db.syncState)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String value) =>
      db.into(db.syncState).insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));

  Future<void> _clear(String key) => (db.delete(db.syncState)..where((t) => t.key.equals(key))).go();

  Future<ShopKey?> shopKey() async {
    final t = await _get(_shopKey);
    return t == null ? null : ShopKey.fromText(t);
  }

  /// The shop's key, made the first time the owner adds a phone.
  Future<ShopKey> ensureShopKey() async {
    final existing = await shopKey();
    if (existing != null) return existing;
    final k = ShopKey.random();
    await setShopKey(k);
    return k;
  }

  Future<void> setShopKey(ShopKey k) => _set(_shopKey, k.text);

  /// A new one-time pairing token, valid for [pairingValidFor].
  Future<String> startPairing({DateTime? now}) async {
    final token = newPairingToken();
    await _set(_pairToken, token);
    await _set(_pairExpires, '${(now ?? DateTime.now()).add(pairingValidFor).millisecondsSinceEpoch}');
    return token;
  }

  /// True once for the current token while it is fresh; the token is then spent.
  Future<bool> usePairingToken(String token, {DateTime? now}) async {
    final want = await _get(_pairToken);
    final expires = int.tryParse(await _get(_pairExpires) ?? '') ?? 0;
    final ok = want != null && want == token && (now ?? DateTime.now()).millisecondsSinceEpoch <= expires;
    if (ok) {
      await _clear(_pairToken);
      await _clear(_pairExpires);
    }
    return ok;
  }

  Future<void> cancelPairing() async {
    await _clear(_pairToken);
    await _clear(_pairExpires);
  }

  Future<List<SyncPeer>> peers() => db.select(db.syncPeers).get();

  Future<SyncPeer?> peer(String deviceId) =>
      (db.select(db.syncPeers)..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();

  Future<void> upsertPeer(String deviceId, {String? label, String? address, int? port}) async {
    final existing = await peer(deviceId);
    if (existing == null) {
      await db.into(db.syncPeers).insert(SyncPeersCompanion.insert(
            deviceId: deviceId,
            label: Value(label ?? ''),
            address: Value(address),
            port: Value(port),
          ));
    } else {
      await (db.update(db.syncPeers)..where((t) => t.deviceId.equals(deviceId))).write(SyncPeersCompanion(
        label: label == null ? const Value.absent() : Value(label),
        address: address == null ? const Value.absent() : Value(address),
        port: port == null ? const Value.absent() : Value(port),
      ));
    }
  }

  Future<void> peerSynced(String deviceId, {required DateTime at, int? seenOfMe}) =>
      (db.update(db.syncPeers)..where((t) => t.deviceId.equals(deviceId))).write(SyncPeersCompanion(
        lastSyncAt: Value(at),
        lastError: const Value(null),
        seenOfMe: seenOfMe == null ? const Value.absent() : Value(seenOfMe),
      ));

  Future<void> peerSeen(String deviceId, int seenOfMe) =>
      (db.update(db.syncPeers)..where((t) => t.deviceId.equals(deviceId)))
          .write(SyncPeersCompanion(seenOfMe: Value(seenOfMe)));

  Future<void> peerFailed(String deviceId, String error) =>
      (db.update(db.syncPeers)..where((t) => t.deviceId.equals(deviceId)))
          .write(SyncPeersCompanion(lastError: Value(error)));

  Future<void> removePeer(String deviceId) =>
      (db.delete(db.syncPeers)..where((t) => t.deviceId.equals(deviceId))).go();

  /// After a copy of another phone's data is installed here: its own peers
  /// list means nothing on this phone.
  Future<void> forgetAllPeers() => db.delete(db.syncPeers).go();
}

/// This phone's address on the shop Wi-Fi (a private IPv4), or null when it
/// is not on a network.
Future<String?> localWifiAddress() async {
  final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
  String? fallback;
  for (final i in interfaces) {
    for (final a in i.addresses) {
      if (a.isLoopback) continue;
      final parts = a.address.split('.').map(int.parse).toList();
      final private = parts[0] == 10 ||
          (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) ||
          (parts[0] == 192 && parts[1] == 168);
      if (!private) continue;
      // Prefer the Wi-Fi interface (wlan) over hotspot or mobile ones.
      if (i.name.toLowerCase().contains('wlan')) return a.address;
      fallback ??= a.address;
    }
  }
  return fallback;
}
