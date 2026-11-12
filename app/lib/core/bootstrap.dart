import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';
import 'db/repositories/repo_context.dart';
import 'db/repositories/setup_repository.dart';
import 'sync/device_identity.dart';

/// The shop, this phone's device and the default stock location, resolved once
/// at start-up. Everything the app writes goes through [ctx].
class ShopSession {
  const ShopSession({
    required this.ctx,
    required this.shop,
    required this.deviceId,
    required this.series,
    required this.locationId,
    required this.userId,
  });

  final RepoContext ctx;
  final Shop shop;

  /// This phone. It owns its own invoice series so offline phones never collide.
  final String deviceId;
  final String series;

  /// Default stock location (the shop floor) that bills take stock from.
  final String locationId;
  final String userId;

  String get shopId => shop.id;
}

/// The database holds more than one phone and this phone does not know which
/// one it is (a backup was restored on a new phone, or this phone's own file
/// was lost). The app asks the owner before anything is billed, so two phones
/// never use the same bill series.
class DeviceChoiceNeeded implements Exception {
  DeviceChoiceNeeded(this.devices);
  final List<Device> devices;
  @override
  String toString() => 'DeviceChoiceNeeded(${devices.map((d) => d.invoiceSeriesPrefix).join(', ')})';
}

/// Returns the existing session, or creates the shop, owner, device "A" and the
/// 'shop' location on first run. Shop details are edited later in Settings.
///
/// [identity] says which device row is this phone (A8). Without it (tests and
/// one-phone use before A8) the oldest device is this phone.
Future<ShopSession> ensureShopSession(
  AppDatabase db, {
  DateTime Function()? clock,
  Uuid? uuid,
  DeviceIdentity? identity,
}) async {
  var shop = await (db.select(db.shops)
        ..where((t) => t.deletedAt.isNull())
        ..limit(1))
      .getSingleOrNull();

  if (shop == null) {
    final shopId = (uuid ?? const Uuid()).v4();
    final ctx = RepoContext(db, shopId: shopId, uuid: uuid, clock: clock);
    final setup = SetupRepository(ctx);
    await db.transaction(() async {
      await setup.createShop(name: 'Pravin Electricals');
      await setup.createUser(name: 'Owner', role: 'owner');
      await setup.createDevice(label: 'This phone', invoiceSeriesPrefix: 'A');
      await setup.createLocation('shop');
    });
    shop = await (db.select(db.shops)..where((t) => t.id.equals(shopId)))
        .getSingle();
  }

  final ctx = RepoContext(db, shopId: shop.id, uuid: uuid, clock: clock);
  final devices = await (db.select(db.devices)
        ..where((t) => t.shopId.equals(shop!.id) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();
  final device = await _thisDevice(devices, identity);
  ctx.originDeviceId = device.id;
  await claimUnstampedOutbox(db, device.id);
  final location = await (db.select(db.locations)
        ..where((t) =>
            t.shopId.equals(shop!.id) &
            t.name.equals('shop') &
            t.deletedAt.isNull())
        ..limit(1))
      .getSingle();
  final user = await (db.select(db.users)
        ..where((t) => t.shopId.equals(shop!.id) & t.role.equals('owner'))
        ..limit(1))
      .getSingle();

  return ShopSession(
    ctx: ctx,
    shop: shop,
    deviceId: device.id,
    series: device.invoiceSeriesPrefix,
    locationId: location.id,
    userId: user.id,
  );
}

Future<Device> _thisDevice(List<Device> devices, DeviceIdentity? identity) async {
  if (identity == null) return devices.first;
  final known = await identity.read();
  if (known != null) {
    for (final d in devices) {
      if (d.id == known) return d;
    }
  } else if (devices.length == 1) {
    // A new install, or the one phone the shop had before A8: it is phone A.
    await identity.write(devices.single.id);
    return devices.single;
  }
  // Several phones and this one does not know which it is, or its own phone is
  // not in this data (a backup from before it joined was restored).
  throw DeviceChoiceNeeded(devices);
}

/// Outbox rows written before A8 (or by a context that had no device yet) get
/// this phone as their origin and a place in its sequence, oldest first.
Future<void> claimUnstampedOutbox(AppDatabase db, String deviceId) async {
  final pending = await db.customSelect(
    'SELECT COUNT(*) AS n FROM outbox WHERE origin_device_id IS NULL',
    readsFrom: {db.outbox},
  ).getSingle();
  if ((pending.data['n'] as int) == 0) return;
  await db.transaction(() async {
    final max = await db.customSelect(
      'SELECT COALESCE(MAX(seq), 0) AS m FROM outbox WHERE origin_device_id = ?',
      variables: [Variable.withString(deviceId)],
    ).getSingle();
    final base = max.data['m'] as int;
    // rowid follows insertion order, so seq does too (gaps are fine).
    await db.customUpdate(
      'UPDATE outbox SET origin_device_id = ?, seq = ? + rowid, '
      'changed_at_ms = CASE WHEN changed_at_ms = 0 THEN created_at * 1000 ELSE changed_at_ms END '
      'WHERE origin_device_id IS NULL',
      variables: [Variable.withString(deviceId), Variable.withInt(base)],
      updates: {db.outbox},
    );
  });
}

/// Makes this phone the given device (after the owner chose it, or after this
/// phone joined a shop and got its own device row).
Future<void> chooseThisDevice(DeviceIdentity identity, String deviceId) => identity.write(deviceId);
