import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../db/repositories/settings_repository.dart';
import 'sync_service.dart';

/// The phone's background service that keeps the app running while it is
/// closed (A12, `ShopSyncService.kt`). Tests use a fake.
abstract class BackgroundSyncControl {
  Future<void> start(String title, String text);
  Future<void> update(String title, String text);
  Future<void> stop();

  /// Whether Android lets the app run in the background without limits.
  Future<bool> batteryUnrestricted();

  /// Opens Android's question "Let the app always run in the background?".
  Future<void> askBattery();

  /// Called every 2 minutes by the service (only while it runs).
  set onTick(VoidCallback? f);
}

class DeviceBackgroundSync implements BackgroundSyncControl {
  DeviceBackgroundSync() {
    if (_supported) _channel.setMethodCallHandler(_handle);
  }

  static const _channel = MethodChannel('com.pravinelectricals.shop_app/background_sync');
  static bool get _supported => !kIsWeb && Platform.isAndroid;

  VoidCallback? _onTick;
  @override
  set onTick(VoidCallback? f) => _onTick = f;

  Future<dynamic> _handle(MethodCall call) async {
    if (call.method == 'tick') _onTick?.call();
  }

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } catch (e) {
      debugPrint('Background sync: $method failed: $e');
      return null;
    }
  }

  @override
  Future<void> start(String title, String text) => _call('start', {'title': title, 'text': text});
  @override
  Future<void> update(String title, String text) => _call('update', {'title': title, 'text': text});
  @override
  Future<void> stop() => _call('stop');
  @override
  Future<bool> batteryUnrestricted() async => await _call<bool>('batteryUnrestricted') ?? true;
  @override
  Future<void> askBattery() => _call('askBattery');
}

/// Turns the background service on while this phone is paired and the owner has
/// not switched it off, keeps its notification text current ("last synced
/// 10:42"), and syncs when the service's 2-minute check comes.
class BackgroundSyncKeeper {
  BackgroundSyncKeeper({required this.sync, required this.control, required this.settings});

  final SyncService sync;
  final BackgroundSyncControl control;
  final SettingsRepository settings;

  bool _on = false;
  String? _shown;
  bool _closed = false;

  /// True while the background service is running for this phone.
  bool get isOn => _on;

  void attach() {
    control.onTick = () => unawaited(sync.syncNow());
    sync.status.addListener(_changed);
    _changed();
  }

  void detach() {
    _closed = true;
    sync.status.removeListener(_changed);
    control.onTick = null;
  }

  void _changed() => unawaited(refresh());

  /// Checks again whether the service should run (after a setting changes).
  Future<void> refresh() async {
    if (_closed) return;
    final status = sync.status.value;
    final want = sync.isRunning && status.state != SyncHealth.off && await settings.backgroundSyncOn();
    if (_closed) return;
    if (!want) {
      if (_on) {
        _on = false;
        _shown = null;
        await control.stop();
      }
      return;
    }
    final text = describe(status);
    if (!_on) {
      _on = true;
      _shown = text;
      await control.start(S.bgSyncTitle, text);
    } else if (text != _shown) {
      _shown = text;
      await control.update(S.bgSyncTitle, text);
    }
  }

  /// The notification's second line.
  static String describe(SyncStatus s) {
    final last = s.lastSyncAt;
    return switch (s.state) {
      SyncHealth.synced when last != null => S.phonesLastSync(formatDateTime(last)),
      SyncHealth.problem => S.syncProblem,
      _ => last == null ? S.syncSearching : '${S.syncSearching} · ${S.phonesLastSync(formatDateTime(last))}',
    };
  }
}
