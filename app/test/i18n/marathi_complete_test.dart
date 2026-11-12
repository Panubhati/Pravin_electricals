import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/shared/messages_mr.dart';
import 'package:shop_app/shared/strings.dart';
import 'package:shop_app/shared/strings_mr.dart';

/// A10: every entry in S has Marathi, and the Marathi map has nothing stale.
void main() {
  final source = File('lib/shared/strings.dart').readAsStringSync();
  final keys = RegExp(r"_t\(\s*'(\w+)'").allMatches(source).map((m) => m.group(1)!).toSet();

  // Entries that are the same word in both languages on purpose.
  const sameInBoth = {'upi', 'modeUpi', 'whatsapp', 'gstPercent', 'gstAmount', 'refundUpi'};

  test('every S entry has a Marathi text', () {
    final missing = keys.where((k) => !mrStrings.containsKey(k)).toList()..sort();
    expect(missing, isEmpty, reason: 'Add these to lib/shared/strings_mr.dart:\n${missing.join('\n')}');
  });

  test('the Marathi map has no entries S does not use', () {
    final extra = mrStrings.keys.where((k) => !keys.contains(k)).toList()..sort();
    expect(extra, isEmpty, reason: extra.join('\n'));
  });

  test('Marathi texts are Marathi (Devanagari), apart from words shared by both', () {
    final devanagari = RegExp(r'[ऀ-ॿ]');
    final english = [
      for (final e in mrStrings.entries)
        if (!devanagari.hasMatch(e.value) && !sameInBoth.contains(e.key)) e.key,
    ];
    expect(english, isEmpty, reason: english.join('\n'));
  });

  test('switching language changes what S returns, and back', () {
    addTearDown(() => S.lang = AppLang.en);
    S.lang = AppLang.mr;
    expect(S.newBill, 'नवीन बिल');
    expect(S.homeHello('Ramesh'), 'नमस्कार, Ramesh');
    expect(S.lockedWait(30), contains('30'));
    S.lang = AppLang.en;
    expect(S.newBill, 'New bill');
    expect(S.homeHello('Ramesh'), 'Hello, Ramesh');
  });

  test('messages from deep in the app are shown in Marathi, keeping names and numbers', () {
    addTearDown(() => S.lang = AppLang.en);
    S.lang = AppLang.mr;
    expect(localizeMessage('MCB 20A SP Havells: stock is -9 pcs (below zero).'), 'MCB 20A SP Havells: स्टॉक -9 pcs (शून्याखाली).');
    expect(localizeMessage('Supplier invoice HV-77 was already entered.'), 'पुरवठादार बिल HV-77 आधीच नोंदवले आहे.');
    expect(localizeMessage('Your last backup was 4 days ago.'), 'तुमचा शेवटचा बॅकअप 4 दिवसांपूर्वी घेतला होता.');
    expect(localizeMessage('Some message nobody translated'), 'Some message nobody translated');
    S.lang = AppLang.en;
    expect(localizeMessage('Supplier invoice HV-77 was already entered.'), 'Supplier invoice HV-77 was already entered.');
  });

  test('every message pattern is a valid pattern', () {
    for (final (p, _) in messagePatternsMr) {
      expect(() => RegExp('^$p\$'), returnsNormally, reason: p);
    }
  });
}
