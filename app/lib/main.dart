import 'package:flutter/material.dart';

import 'app.dart';
import 'core/backup/database_location.dart';
import 'core/i18n/app_language.dart';
import 'shared/strings.dart';
import 'core/notifications/device_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lets Android run the daily summary when the app is closed.
  await initBackgroundWork();
  // This phone's language (Marathi unless changed), before the first screen.
  S.lang = await LanguageStore(const DeviceDatabaseLocation()).read();
  runApp(const AppRoot());
}
