import 'package:flutter/material.dart';

import 'app.dart';
import 'core/notifications/device_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lets Android run the daily summary when the app is closed.
  await initBackgroundWork();
  runApp(const AppRoot());
}
