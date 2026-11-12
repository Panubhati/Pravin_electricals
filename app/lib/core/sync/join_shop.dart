import 'dart:io';

import 'package:path/path.dart' as p;

import '../backup/database_location.dart';
import '../backup/restore_service.dart';
import '../db/app_database.dart';
import '../db/connection.dart';
import 'device_identity.dart';
import 'pairing.dart';
import 'phones.dart';
import 'sync_engine.dart';
import 'sync_transport.dart';

/// Asks the owner's phone (from its QR) for a full copy of the shop's data.
Future<JoinPackage> fetchShopCopy(PairingInvite invite, {required String label}) =>
    SyncClient(key: invite.key, me: PhoneInfo(deviceId: 'joining', label: label, series: '?')).join(invite);

/// Installs the shop copy received from the owner's phone on this phone and
/// makes this phone a new member of the shop (its own bill series, B, C...).
/// The live database must be closed first; the app restarts afterwards.
///
/// Uses the A6 restore path, so the old data on this phone is kept as a
/// safety copy and the swap is all or nothing.
Future<Device> installJoinedShop({
  required JoinPackage package,
  required PairingInvite invite,
  required ShopDatabaseLocation location,
  required DeviceIdentity identity,
  required String label,
}) async {
  final work = await location.workDirectory();
  final copy = File(p.join(work.path, 'joined_shop.sqlite'));
  await copy.writeAsBytes(package.database, flush: true);
  try {
    await RestoreService(location).replaceWith(copy, currentSchemaVersion: AppDatabase.currentSchemaVersion);
  } finally {
    if (copy.existsSync()) copy.deleteSync();
  }

  final db = AppDatabase(openShopDatabase(location: location));
  try {
    // The copy carries the owner phone's own sync list and phone-only
    // settings (its last backup time...); none of that is true here.
    final store = SyncStore(db);
    await store.forgetAllPeers();
    await db.customStatement(
      'DELETE FROM app_settings WHERE key IN (${phoneOnlySettingKeys.map((k) => "'$k'").join(', ')})',
    );
    await store.cancelPairing();
    await store.setShopKey(invite.key);
    final device = await addThisPhone(db, identity, label: label);
    await store.upsertPeer(package.owner.deviceId,
        label: package.owner.label, address: invite.host, port: invite.port);
    return device;
  } finally {
    await db.close();
  }
}
