import 'dart:io';

import '../backup/database_location.dart';

/// Remembers which device row is this phone. Stored in a small file outside
/// the database, so restoring a backup or copying the shop from the other
/// phone never turns this phone into a different one.
abstract class DeviceIdentity {
  Future<String?> read();
  Future<void> write(String deviceId);

  /// Forget (used when a one-phone shop restores a backup: the restored data
  /// decides which phone this is).
  Future<void> clear();
}

/// The real store: a one-line text file next to the app's private files.
class FileDeviceIdentity implements DeviceIdentity {
  FileDeviceIdentity(this.location);
  final ShopDatabaseLocation location;

  @override
  Future<String?> read() async {
    final f = await location.deviceIdentityFile();
    if (!await f.exists()) return null;
    final text = (await f.readAsString()).trim();
    return text.isEmpty ? null : text;
  }

  @override
  Future<void> write(String deviceId) async {
    final f = await location.deviceIdentityFile();
    await f.parent.create(recursive: true);
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(deviceId, flush: true);
    await tmp.rename(f.path);
  }

  @override
  Future<void> clear() async {
    final f = await location.deviceIdentityFile();
    if (await f.exists()) await f.delete();
  }
}

/// For tests.
class MemoryDeviceIdentity implements DeviceIdentity {
  MemoryDeviceIdentity([this.value]);
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String deviceId) async => value = deviceId;

  @override
  Future<void> clear() async => value = null;
}
