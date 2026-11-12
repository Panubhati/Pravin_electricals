import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A10: every word a person reads must come from S (so it can be Marathi).
/// This reads the screens' source and fails on English phrases typed in place.
void main() {
  // Phrases that are allowed where they are, with the reason.
  const allowed = <String, String>{
    'Spot check': 'stock movement note saved in the data, not shown as a label',
    'Opening stock': 'stock movement note saved in the data',
    'English': 'the language switch names each language in itself',
    'Wi-Fi': 'matched inside an error message, not shown',
    'Id': 'field-name suffix in the activity log',
    'Paise': 'field-name suffix',
    'Base': 'field-name suffix',
  };
  // Files where English stays on purpose.
  const allowedFiles = {
    'speed/speed_screen.dart': 'debug-only speed check, never in the shop build',
    'bills/bill_sharing.dart': 'only a debug log line; customer messages come from BillWords',
    'billing/domain/bill_calculator.dart': 'programming error text, never shown',
  };

  test('no English phrases typed into screens', () {
    final lit = RegExp(r"'((?:[^'\\]|\\.)*)'");
    final problems = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart')) continue;
      if (allowedFiles.keys.any(path.endsWith)) continue;
      final lines = f.readAsLinesSync();
      for (var n = 0; n < lines.length; n++) {
        final line = lines[n];
        final t = line.trim();
        if (t.startsWith('//') || t.startsWith('import ')) continue;
        if (line.contains('padLeft') || line.contains('SELECT ')) continue;
        for (final m in lit.allMatches(line)) {
          final s = m.group(1)!;
          // A piece cut out of a nested '${a ? 'x' : 'y'}' (quotes inside quotes).
          if ('{'.allMatches(s).length != '}'.allMatches(s).length) continue;
          final before = line.substring(0, m.start).trimRight();
          if (before.endsWith('Key(') || before.endsWith('ValueKey(')) continue;
          final plain = s.replaceAll(RegExp(r'\$\{[^}]*\}|\$\w+'), '');
          if (!RegExp(r'[A-Za-z]{2,}').hasMatch(plain)) continue;
          if (!s.contains(' ') && !RegExp(r'^[A-Z]').hasMatch(s)) continue; // keys, codes
          if (allowed.containsKey(s.trim())) continue;
          // Pure joins of S entries and values ("${S.x}: $y") are fine.
          if (RegExp(r'^[\s•:,()+\-]*$').hasMatch(plain.replaceAll(RegExp(r'\b(GST|HSN|ms)\b'), ''))) continue;
          problems.add('$path:${n + 1}: $s');
        }
      }
    }
    expect(problems, isEmpty, reason: 'Move these into S (lib/shared/strings.dart):\n${problems.join('\n')}');
  });
}
