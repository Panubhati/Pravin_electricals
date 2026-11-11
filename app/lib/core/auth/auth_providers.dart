import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../db/app_database.dart';
import '../providers.dart';

/// Who is logged in right now (null while the lock screen is showing).
class SessionUserNotifier extends StateNotifier<User?> {
  SessionUserNotifier([super.initial]);

  void login(User user) => state = user;
  void lock() => state = null;
}

final currentUserProvider =
    StateNotifierProvider<SessionUserNotifier, User?>((ref) => SessionUserNotifier());

/// The user id to stamp on what is being written (created_by, audit rows).
/// Falls back to the owner only before anyone has logged in (setup, tests).
final actingUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id ?? ref.watch(sessionProvider).requireValue.userId;
});

/// Counter staff's largest discount per line, in percent (Settings).
final discountLimitProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(settingsRepositoryProvider).counterMaxDiscountPct(),
);

/// Whether the owner has set a PIN yet. A fresh install has none.
final ownerHasPinProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(authRepositoryProvider).ownerHasPin(),
);

/// Users who can log in.
final loginUsersProvider = FutureProvider.autoDispose<List<User>>(
  (ref) => ref.watch(authRepositoryProvider).activeUsers(),
);

/// Confirms the person holding the phone using its own screen lock (PIN,
/// pattern or fingerprint). Used to recover a forgotten owner PIN.
abstract class DeviceAuth {
  Future<bool> confirm(String reason);
}

class LocalDeviceAuth implements DeviceAuth {
  @override
  Future<bool> confirm(String reason) async {
    try {
      final auth = LocalAuthentication();
      if (!await auth.isDeviceSupported()) return false;
      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      debugPrint('Device authentication failed: $e');
      return false;
    }
  }
}

final deviceAuthProvider = Provider<DeviceAuth>((ref) => LocalDeviceAuth());
