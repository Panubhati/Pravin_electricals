import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when a message cannot be opened: wrong shop key, changed on the
/// way, or too old (replayed).
class SyncAuthException implements Exception {
  SyncAuthException(this.message);
  final String message;
  @override
  String toString() => 'SyncAuthException: $message';
}

/// The shop's secret, shared by its phones through the pairing QR. Every
/// message between phones is encrypted and signed with it (AES-256-GCM), so
/// another phone on the same Wi-Fi can neither read nor change anything.
class ShopKey {
  ShopKey(List<int> bytes) : bytes = Uint8List.fromList(bytes) {
    if (bytes.length != 32) throw ArgumentError('A shop key is 32 bytes');
  }

  factory ShopKey.random() {
    final r = Random.secure();
    return ShopKey(List.generate(32, (_) => r.nextInt(256)));
  }

  factory ShopKey.fromText(String text) => ShopKey(base64Url.decode(text));

  final Uint8List bytes;
  String get text => base64Url.encode(bytes);

  static final _algo = AesGcm.with256bits();
  static const _nonceLength = 12;

  /// Encrypts [plain]. [label] (the request name) is bound in, so a message
  /// for one request cannot be replayed as another.
  Future<Uint8List> seal(List<int> plain, {required String label}) async {
    final nonce = _algo.newNonce();
    final box = await _algo.encrypt(plain,
        secretKey: SecretKey(bytes), nonce: nonce, aad: utf8.encode(label));
    return Uint8List.fromList([...nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  Future<Uint8List> open(List<int> sealed, {required String label}) async {
    if (sealed.length < _nonceLength + 16) throw SyncAuthException('Message too short');
    final nonce = sealed.sublist(0, _nonceLength);
    final mac = Mac(sealed.sublist(sealed.length - 16));
    final cipher = sealed.sublist(_nonceLength, sealed.length - 16);
    try {
      final plain = await _algo.decrypt(SecretBox(cipher, nonce: nonce, mac: mac),
          secretKey: SecretKey(bytes), aad: utf8.encode(label));
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw SyncAuthException('This message was not made with this shop\'s key');
    }
  }

  /// A JSON message with the sender's clock, so an old message replayed later
  /// is refused.
  Future<Uint8List> sealJson(Map<String, Object?> body, {required String label, DateTime? now}) =>
      seal(utf8.encode(jsonEncode({...body, '_ts': (now ?? DateTime.now()).millisecondsSinceEpoch})), label: label);

  Future<Map<String, dynamic>> openJson(List<int> sealed,
      {required String label, DateTime? now, Duration maxAge = const Duration(minutes: 10)}) async {
    final body = jsonDecode(utf8.decode(await open(sealed, label: label))) as Map<String, dynamic>;
    final ts = body['_ts'] as int? ?? 0;
    final age = (now ?? DateTime.now()).millisecondsSinceEpoch - ts;
    if (age.abs() > maxAge.inMilliseconds) {
      throw SyncAuthException('The two phones\' clocks differ by more than ${maxAge.inMinutes} minutes, or the message is old');
    }
    return body;
  }
}

/// A random one-time pairing token (shown inside the QR).
String newPairingToken() {
  final r = Random.secure();
  return base64Url.encode(List.generate(18, (_) => r.nextInt(256)));
}
