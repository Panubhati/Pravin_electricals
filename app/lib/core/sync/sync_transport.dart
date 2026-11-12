import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../db/app_database.dart';
import 'pairing.dart';
import 'sync_crypto.dart';
import 'sync_engine.dart';

/// The port phones listen on for each other (any free port is used if taken;
/// the other phone finds it through discovery or the pairing QR).
const syncPort = 47821;

/// A refusal or failure reported by the other phone.
class SyncHttpException implements Exception {
  SyncHttpException(this.status, this.message);
  final int status;
  final String message;
  bool get refused => status == HttpStatus.forbidden;
  @override
  String toString() => 'SyncHttpException($status): $message';
}

/// Who this phone is, as told to the other phone.
class PhoneInfo {
  const PhoneInfo({required this.deviceId, required this.label, required this.series});
  final String deviceId;
  final String label;
  final String series;
}

/// What the owner's phone sends a joining phone: who it is, and a full copy
/// of the shop's data (a verified backup file).
class JoinPackage {
  const JoinPackage({required this.owner, required this.database});
  final PhoneInfo owner;
  final Uint8List database;
}

/// Listens on the shop Wi-Fi for the other phone. Every request and reply is
/// sealed with the shop key; a phone that was removed from the shop is refused.
class SyncServer {
  SyncServer({
    required this.db,
    required this.me,
    required this.key,
    required this.engine,
    required this.makeCopy,
    this.onNudge,
    this.onPeerSeen,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final PhoneInfo me;
  final ShopKey key;
  final SyncEngine engine;

  /// A verified copy of the whole database (for a joining phone).
  final Future<File> Function() makeCopy;

  /// The other phone has new changes: pull from it now.
  final void Function(String deviceId)? onNudge;

  /// The other phone talked to us (so we know its address).
  final void Function(String deviceId)? onPeerSeen;
  final DateTime Function() _clock;

  HttpServer? _server;
  int get port => _server?.port ?? 0;

  Future<void> start({int port = syncPort, InternetAddress? address}) async {
    final bindTo = address ?? InternetAddress.anyIPv4;
    try {
      _server = await HttpServer.bind(bindTo, port);
    } on SocketException {
      _server = await HttpServer.bind(bindTo, 0);
    }
    _server!.listen(_handle, onError: (_) {});
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest req) async {
    final op = req.uri.pathSegments.length == 2 && req.uri.pathSegments.first == 'v1' ? req.uri.pathSegments[1] : '';
    try {
      if (req.method != 'POST' || !const {'hello', 'pull', 'nudge', 'join'}.contains(op)) {
        return _fail(req, HttpStatus.notFound, 'Unknown request');
      }
      final raw = await _readAll(req);
      final body = await key.openJson(raw, label: op, now: _clock());
      final store = SyncStore(db);
      if (op == 'join') return await _join(req, body, store);

      final from = body['from'] as String? ?? '';
      if (await _removed(from)) {
        return _fail(req, HttpStatus.forbidden, 'This phone was removed from the shop. Pair it again from the owner\'s phone.');
      }
      final address = req.connectionInfo?.remoteAddress.address;
      await store.upsertPeer(from,
          label: body['label'] as String?, address: address, port: body['port'] as int?);
      onPeerSeen?.call(from);

      switch (op) {
        case 'hello':
          return _reply(req, op, {
            'deviceId': me.deviceId,
            'label': me.label,
            'series': me.series,
            'clockMs': _clock().millisecondsSinceEpoch,
          });
        case 'pull':
          final theirs = (body['cursor'] as Map).map((k, v) => MapEntry(k as String, v as int));
          await store.peerSeen(from, theirs[me.deviceId] ?? 0);
          final batch = await engine.changesAfter(theirs, limit: body['limit'] as int? ?? 500);
          return _reply(req, op, batch.toJson());
        case 'nudge':
          onNudge?.call(from);
          return _reply(req, op, {'ok': true});
      }
    } on SyncAuthException catch (e) {
      return _fail(req, HttpStatus.forbidden, e.message);
    } catch (e) {
      return _fail(req, HttpStatus.internalServerError, '$e');
    }
  }

  Future<void> _join(HttpRequest req, Map<String, dynamic> body, SyncStore store) async {
    if (!await store.usePairingToken(body['token'] as String? ?? '', now: _clock())) {
      return _fail(req, HttpStatus.forbidden, 'This pairing code has expired or was already used. Show a new one on the owner\'s phone.');
    }
    final file = await makeCopy();
    final bytes = await file.readAsBytes();
    try {
      await file.delete();
    } catch (_) {}
    final header = utf8.encode(jsonEncode({'deviceId': me.deviceId, 'label': me.label, 'series': me.series}));
    final framed = BytesBuilder(copy: false)
      ..add((ByteData(4)..setUint32(0, header.length)).buffer.asUint8List())
      ..add(header)
      ..add(bytes);
    final sealed = await key.seal(framed.takeBytes(), label: 'join-reply');
    req.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.binary
      ..add(sealed);
    await req.response.close();
  }

  Future<bool> _removed(String deviceId) async {
    final d = await (db.select(db.devices)..where((t) => t.id.equals(deviceId))).getSingleOrNull();
    return d != null && d.deletedAt != null;
  }

  Future<void> _reply(HttpRequest req, String op, Map<String, Object?> body) async {
    final sealed = await key.sealJson(body, label: '$op-reply', now: _clock());
    req.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.binary
      ..add(sealed);
    await req.response.close();
  }

  Future<void> _fail(HttpRequest req, int status, String message) async {
    try {
      req.response
        ..statusCode = status
        ..headers.contentType = ContentType.text
        ..write(message);
      await req.response.close();
    } catch (_) {}
  }
}

Future<Uint8List> _readAll(Stream<List<int>> s) async {
  final b = BytesBuilder(copy: false);
  await for (final chunk in s) {
    b.add(chunk);
  }
  return b.takeBytes();
}

/// Talks to the other phone's [SyncServer].
class SyncClient {
  SyncClient({required this.key, required this.me, this.myPort, this.timeout = const Duration(seconds: 15)});

  final ShopKey key;
  final PhoneInfo me;

  /// Where this phone listens, so the other phone can call back.
  final int? myPort;
  final Duration timeout;

  Future<Map<String, dynamic>> _call(String host, int port, String op, Map<String, Object?> body) async {
    final payload = {...body, 'from': me.deviceId, 'label': me.label, 'port': myPort};
    final bytes = await _post(host, port, op, await key.sealJson(payload, label: op));
    return key.openJson(bytes, label: '$op-reply');
  }

  Future<Uint8List> _post(String host, int port, String op, List<int> body) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.post(host, port, '/v1/$op').timeout(timeout);
      req.headers.contentType = ContentType.binary;
      req.add(body);
      final res = await req.close().timeout(timeout);
      final data = await _readAll(res).timeout(const Duration(minutes: 5));
      if (res.statusCode != HttpStatus.ok) {
        throw SyncHttpException(res.statusCode, utf8.decode(data, allowMalformed: true));
      }
      return data;
    } finally {
      client.close(force: true);
    }
  }

  /// Who is at that address (and their clock, to warn about a wrong time).
  Future<({PhoneInfo info, int clockMs})> hello(String host, int port) async {
    final r = await _call(host, port, 'hello', {});
    return (
      info: PhoneInfo(deviceId: r['deviceId'] as String, label: r['label'] as String, series: r['series'] as String),
      clockMs: r['clockMs'] as int,
    );
  }

  /// One page of changes this phone does not have yet.
  Future<SyncBatch> pull(String host, int port, Map<String, int> myCursor, {int limit = 500}) async {
    final r = await _call(host, port, 'pull', {'cursor': myCursor, 'limit': limit});
    return SyncBatch.fromJson(r);
  }

  /// Tells the other phone this one has new changes.
  Future<void> nudge(String host, int port) => _call(host, port, 'nudge', {});

  /// Asks the owner's phone for a full copy of the shop's data.
  Future<JoinPackage> join(PairingInvite invite) async {
    final body = await key.sealJson({'token': invite.token, 'label': me.label}, label: 'join');
    final sealed = await _post(invite.host, invite.port, 'join', body);
    final framed = await key.open(sealed, label: 'join-reply');
    final headerLength = ByteData.sublistView(framed, 0, 4).getUint32(0);
    final header = jsonDecode(utf8.decode(framed.sublist(4, 4 + headerLength))) as Map<String, dynamic>;
    return JoinPackage(
      owner: PhoneInfo(
          deviceId: header['deviceId'] as String, label: header['label'] as String, series: header['series'] as String),
      database: Uint8List.sublistView(framed, 4 + headerLength),
    );
  }
}
