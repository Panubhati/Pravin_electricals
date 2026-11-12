import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/backup/database_location.dart';
import 'core/db/app_database.dart';
import 'core/db/connection.dart';
import 'core/i18n/app_language.dart';
import 'core/providers.dart';
import 'core/sync/device_identity.dart';
import 'features/auth/lock_gate.dart';
import 'features/home/home_screen.dart';
import 'shared/strings.dart';
import 'shared/theme.dart';

/// Holds the app's providers and the database. [restart] throws all of that
/// away and starts again from a fresh database connection, which is how a
/// restored backup takes effect.
class AppRoot extends StatefulWidget {
  const AppRoot({
    super.key,
    this.location = const DeviceDatabaseLocation(),
    this.extraOverrides = const [],
  });

  /// Where the database file lives. Tests point this at a temp folder.
  final ShopDatabaseLocation location;

  /// More provider overrides (tests replace the file picker, sharer...).
  final List<Override> extraOverrides;

  static void restart(BuildContext context) =>
      context.findAncestorStateOfType<_AppRootState>()?._restart();

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Key _key = UniqueKey();

  void _restart() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _key,
      overrides: [
        databaseLocationProvider.overrideWithValue(widget.location),
        deviceIdentityProvider.overrideWithValue(FileDeviceIdentity(widget.location)),
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(openShopDatabase(location: widget.location));
          ref.onDispose(db.close);
          return db;
        }),
        ...widget.extraOverrides,
      ],
      child: const ShopApp(),
    );
  }
}

class ShopApp extends ConsumerWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A new language rebuilds every screen (the key), keeping who is logged in
    // and any bill being made (those live in providers, above this).
    final lang = ref.watch(appLanguageProvider);
    return MaterialApp(
      key: ValueKey(lang),
      locale: localeOf(lang),
      supportedLocales: const [Locale('mr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      builder: (context, child) => LockGate(child: child ?? const SizedBox.shrink()),
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
