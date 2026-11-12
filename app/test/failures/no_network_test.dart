import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Airplane mode must be harmless: billing, stock, dues, reports, backup and
/// restore never touch the network. This reads the app's own source and fails if
/// any file reaches for it. (Sharing and WhatsApp go through the phone's own apps.)
/// The one exception is Wi-Fi sync (A8) in lib/core/sync/, which only talks to
/// the shop's other phone on the local Wi-Fi and never blocks a bill.
void main() {
  final forbidden = <String, Pattern>{
    'package:dio': RegExp(r"package:dio/"),
    'package:http': RegExp(r"package:http/"),
    'connectivity_plus': RegExp(r"package:connectivity_plus/"),
    'HttpClient': RegExp(r'\bHttpClient\b'),
    'WebSocket': RegExp(r'\bWebSocket\b'),
    'Socket.connect': RegExp(r'\bSocket\.connect\b'),
    'InternetAddress.lookup': RegExp(r'InternetAddress\.lookup'),
    'http URL': RegExp(r"""['"]https?://(?!schemas\.android\.com|www\.w3\.org)"""),
  };

  test('no source file under lib/ uses the network', () {
    final problems = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      if (f.path.endsWith('.g.dart')) continue;
      if (f.path.replaceAll(r'\', '/').contains('lib/core/sync/')) continue;
      final lines = f.readAsLinesSync();
      for (var n = 0; n < lines.length; n++) {
        final line = lines[n];
        if (line.trimLeft().startsWith('//')) continue;
        for (final e in forbidden.entries) {
          if (line.contains(e.value)) problems.add('${f.path}:${n + 1} uses ${e.key}: ${line.trim()}');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('only Wi-Fi sync code may use the network', () {
    // Names that would mean a network call outside lib/core/sync/.
    final outside = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final path = f.path.replaceAll(r'\', '/');
      if (path.contains('lib/core/sync/') || path.endsWith('.g.dart')) continue;
      final text = f.readAsStringSync();
      for (final name in ['HttpServer', 'SyncClient(', 'SyncServer(', 'package:nsd/']) {
        if (text.contains(name)) outside.add('$path uses $name');
      }
    }
    expect(outside, isEmpty, reason: outside.join('\n'));
  });

  test('the Android manifest asks only for local network permissions (A8 Wi-Fi sync)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    // INTERNET is Android's name for any socket, including the shop Wi-Fi.
    expect(manifest.contains('android.permission.INTERNET'), isTrue);
    expect(manifest.contains('CHANGE_WIFI_MULTICAST_STATE'), isTrue);
    // No location or background data permissions.
    expect(manifest.contains('ACCESS_FINE_LOCATION'), isFalse);
    expect(manifest.contains('ACCESS_BACKGROUND_LOCATION'), isFalse);
  });
}
