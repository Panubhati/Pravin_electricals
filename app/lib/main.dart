import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/app_database.dart';
import 'core/db/connection.dart';
import 'core/notifications/device_notifications.dart';
import 'core/providers.dart';
import 'features/auth/lock_gate.dart';
import 'features/home/home_screen.dart';
import 'shared/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lets Android run the daily summary when the app is closed.
  await initBackgroundWork();
  runApp(const AppRoot());
}

/// Holds the app's providers and the database. [restart] throws all of that
/// away and starts again from a fresh database connection, which is how a
/// restored backup takes effect.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

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
        databaseProvider.overrideWith((ref) {
          final db = AppDatabase(openShopDatabase());
          ref.onDispose(db.close);
          return db;
        }),
      ],
      child: const ShopApp(),
    );
  }
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appTitle,
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      builder: (context, child) => LockGate(child: child ?? const SizedBox.shrink()),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F5FA8),
        useMaterial3: true,
        // Large touch targets for fast counter use on cheap phones.
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
