import 'package:drift/drift.dart';

import '../app_database.dart';
import 'audit_repository.dart';
import 'repo_context.dart';

/// Shop, users, devices and locations (first-run setup).
class SetupRepository {
  SetupRepository(this.ctx);
  final RepoContext ctx;

  /// The shop's id is the context's shopId.
  Future<String> createShop({
    required String name,
    String? gstin,
    String? address,
    String? stateCode,
    String? phone,
    String? terms,
  }) async {
    final now = ctx.clock();
    return ctx.db.transaction(() async {
      await ctx.insertRow(
        ctx.db.shops,
        ShopsCompanion.insert(
          id: ctx.shopId,
          shopId: ctx.shopId,
          createdAt: now,
          updatedAt: now,
          name: name,
          gstin: Value(gstin),
          address: Value(address),
          stateCode: Value(stateCode),
          phone: Value(phone),
          terms: Value(terms),
        ),
        'shops',
        ctx.shopId,
      );
      return ctx.shopId;
    });
  }

  Future<String> createUser({
    required String name,
    required String role,
    String? phone,
    String? pinHash,
  }) async {
    if (!const {'owner', 'counter', 'godown'}.contains(role)) {
      throw DomainException('Unknown role: $role');
    }
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.users,
          UsersCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            name: name,
            role: role,
            phone: Value(phone),
            pinHash: Value(pinHash),
          ),
          'users',
          id,
        ));
    return id;
  }

  Future<String> createDevice({
    required String label,
    required String invoiceSeriesPrefix,
    String? userId,
    String? id,
  }) async {
    final now = ctx.clock();
    final deviceId = id ?? ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.devices,
          DevicesCompanion.insert(
            id: deviceId,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            label: label,
            invoiceSeriesPrefix: invoiceSeriesPrefix,
            userId: Value(userId),
          ),
          'devices',
          deviceId,
        ));
    return deviceId;
  }

  /// Takes a phone out of the shop (A8): its bills stay, but it can no longer
  /// sync. Audited by the caller.
  Future<void> removeDevice(String deviceId) async {
    final now = ctx.clock();
    await ctx.db.transaction(() async {
      await (ctx.db.update(ctx.db.devices)..where((t) => t.id.equals(deviceId)))
          .write(DevicesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      final row = await (ctx.db.select(ctx.db.devices)..where((t) => t.id.equals(deviceId))).getSingle();
      await ctx.recordOutbox('devices', deviceId, 'upsert', row.toJson());
    });
  }

  /// Renames a phone (shown in Settings, Phones and on the other phone).
  Future<void> renameDevice(String deviceId, String label) async {
    if (label.trim().isEmpty) throw DomainException('A phone needs a name');
    final now = ctx.clock();
    await ctx.db.transaction(() async {
      await (ctx.db.update(ctx.db.devices)..where((t) => t.id.equals(deviceId)))
          .write(DevicesCompanion(label: Value(label.trim()), updatedAt: Value(now)));
      final row = await (ctx.db.select(ctx.db.devices)..where((t) => t.id.equals(deviceId))).getSingle();
      await ctx.recordOutbox('devices', deviceId, 'upsert', row.toJson());
    });
  }

  /// [name] is one of: shop, godown, vehicle.
  Future<String> createLocation(String name) async {
    if (!const {'shop', 'godown', 'vehicle'}.contains(name)) {
      throw DomainException('Unknown location: $name');
    }
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.locations,
          LocationsCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            name: name,
          ),
          'locations',
          id,
        ));
    return id;
  }

  /// Edits the shop's details (name, GSTIN, address, state code, phone, terms).
  /// Bills already saved keep the details they were printed with. Audited.
  Future<void> updateShop({
    required String name,
    String? gstin,
    String? address,
    String? stateCode,
    String? phone,
    String? terms,
    String? userId,
  }) async {
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final n = name.trim();
    if (n.isEmpty) throw DomainException('Enter the shop name.');
    final gst = clean(gstin)?.toUpperCase();
    if (gst != null && !RegExp(r'^[0-9A-Z]{15}$').hasMatch(gst)) {
      throw DomainException('GSTIN must be 15 letters and digits.');
    }
    final state = clean(stateCode);
    if (state != null && !RegExp(r'^\d{2}$').hasMatch(state)) {
      throw DomainException('State code must be 2 digits (for example 27 for Maharashtra).');
    }
    await ctx.db.transaction(() async {
      final before = await (ctx.db.select(ctx.db.shops)..where((t) => t.id.equals(ctx.shopId))).getSingle();
      await (ctx.db.update(ctx.db.shops)..where((t) => t.id.equals(ctx.shopId))).write(ShopsCompanion(
        name: Value(n),
        gstin: Value(gst),
        address: Value(clean(address)),
        stateCode: Value(state),
        phone: Value(clean(phone)),
        terms: Value(clean(terms)),
        updatedAt: Value(ctx.clock()),
      ));
      final after = await (ctx.db.select(ctx.db.shops)..where((t) => t.id.equals(ctx.shopId))).getSingle();
      await ctx.recordOutbox('shops', ctx.shopId, 'upsert', after.toJson());
      await AuditRepository(ctx).record(
        action: 'shop_updated',
        entity: 'shop',
        entityId: ctx.shopId,
        userId: userId,
        before: before.toJson(),
        after: after.toJson(),
      );
    });
  }
}
