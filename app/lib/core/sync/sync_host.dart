import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/sync/sync_providers.dart';
import '../providers.dart';

/// Starts Wi-Fi sync from the app's provider container, not from a screen
/// (A12). The phone's background service keeps the app running with no screen
/// (after the app is swiped away or the phone restarts), and Flutter builds no
/// screens then, so sync must not depend on one.
class SyncHost {
  SyncHost(this.container);
  final ProviderContainer container;

  bool _stopped = false;

  /// Waits for the shop data to open, then starts sync. Does nothing when this
  /// phone is not paired (the service stays off until a pairing starts it).
  Future<void> start() async {
    try {
      await container.read(sessionProvider.future);
    } catch (_) {
      // No session yet (the app asks which phone this is): the screens handle it,
      // and the app starts over (a new host) once it is answered.
      return;
    }
    if (_stopped) return;
    try {
      await container.read(syncServiceProvider).start();
      // Keeps sync going after the app is closed, while this phone is paired.
      if (!_stopped) container.read(backgroundSyncKeeperProvider);
    } catch (e) {
      debugPrint('Sync could not start: $e');
    }
  }

  /// The container is about to be thrown away (restart, restore).
  void stop() => _stopped = true;
}
