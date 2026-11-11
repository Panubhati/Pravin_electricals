import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';
import 'db/repositories/repo_context.dart';
import 'db/repositories/setup_repository.dart';

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

/// Returns the existing session, or creates the shop, owner, device "A" and the
/// 'shop' location on first run. Shop details are edited later in Settings.
Future<ShopSession> ensureShopSession(
  AppDatabase db, {
  DateTime Function()? clock,
  Uuid? uuid,
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
  final device = await (db.select(db.devices)
        ..where((t) => t.shopId.equals(shop!.id) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
        ..limit(1))
      .getSingle();
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
