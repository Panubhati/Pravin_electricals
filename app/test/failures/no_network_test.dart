import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Airplane mode must be harmless: billing, stock, dues, reports, backup and
/// restore never touch the network. This reads the app's own source and fails if
/// any file reaches for it. (Sharing and WhatsApp go through the phone's own apps.)
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

  test('the Android manifest asks for no internet permission', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest.contains('android.permission.INTERNET'), isFalse);
  });
}
