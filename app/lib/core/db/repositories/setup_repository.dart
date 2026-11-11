import 'package:drift/drift.dart';

import '../app_database.dart';
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
  }) async {
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.devices,
          DevicesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            label: label,
            invoiceSeriesPrefix: invoiceSeriesPrefix,
            userId: Value(userId),
          ),
          'devices',
          id,
        ));
    return id;
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
}
