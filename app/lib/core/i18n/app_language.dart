import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../shared/strings.dart';
import '../backup/database_location.dart';
import '../providers.dart';

/// This phone's screen language (A10). Kept in a small file beside the
/// device identity, outside the database: it is known before the database
/// opens, a restore never changes it, and sync never sends it.
class LanguageStore {
  LanguageStore(this.location);
  final ShopDatabaseLocation location;

  Future<File> _file() async => File(p.join((await location.deviceIdentityFile()).parent.path, 'language.txt'));

  /// The saved choice, or Marathi when none was made yet (the shop's default).
  Future<AppLang> read() async {
    final f = await _file();
    if (!await f.exists()) return AppLang.mr;
    return (await f.readAsString()).trim() == 'en' ? AppLang.en : AppLang.mr;
  }

  Future<void> write(AppLang lang) async {
    final f = await _file();
    await f.parent.create(recursive: true);
    await f.writeAsString(lang.name, flush: true);
  }
}

/// The language the screens are showing. Watching it rebuilds the app.
final appLanguageProvider = StateProvider<AppLang>((ref) => S.lang);

/// Switches this phone's language now and remembers it.
Future<void> setAppLanguage(WidgetRef ref, AppLang lang) async {
  S.lang = lang;
  ref.read(appLanguageProvider.notifier).state = lang;
  await LanguageStore(ref.read(databaseLocationProvider)).write(lang);
}

Locale localeOf(AppLang lang) => Locale(lang == AppLang.mr ? 'mr' : 'en');
