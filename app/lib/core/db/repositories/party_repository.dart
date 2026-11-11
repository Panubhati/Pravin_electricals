import 'package:drift/drift.dart';

import '../app_database.dart';
import 'audit_repository.dart';
import 'repo_context.dart';

class PartyRepository {
  PartyRepository(this.ctx);
  final RepoContext ctx;
  late final AuditRepository _audit = AuditRepository(ctx);

  static const kinds = {'customer', 'supplier', 'both'};
  static const tiers = {'retail', 'contractor', 'dealer'};

  /// [kind] is customer | supplier | both. [tier] is retail | contractor | dealer.
  Future<String> createParty({
    required String kind,
    required String name,
    String tier = 'retail',
    String? phone,
    String? gstin,
    String? address,
    String? stateCode,
    int creditLimitPaise = 0,
  }) async {
    if (!kinds.contains(kind)) {
      throw DomainException('Unknown party kind: $kind');
    }
    if (!tiers.contains(tier)) {
      throw DomainException('Unknown tier: $tier');
    }
    if (name.trim().isEmpty) throw DomainException('Name is required');
    if (creditLimitPaise < 0) {
      throw DomainException('Credit limit cannot be negative');
    }
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.parties,
          PartiesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            kind: kind,
            name: name.trim(),
            tier: Value(tier),
            phone: Value(phone),
            gstin: Value(gstin),
            address: Value(address),
            stateCode: Value(stateCode),
            creditLimitPaise: Value(creditLimitPaise),
          ),
          'parties',
          id,
        ));
    return id;
  }

  Future<Party> getParty(String partyId) async {
    final row = await (ctx.db.select(ctx.db.parties)
          ..where((t) => t.id.equals(partyId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) throw DomainException('Unknown party: $partyId');
    return row;
  }

  /// Edits a party. Writes an audit row with before and after.
  Future<void> updateParty({
    required String partyId,
    required String kind,
    required String name,
    required String tier,
    required int creditLimitPaise,
    String? phone,
    String? gstin,
    String? address,
    String? stateCode,
    String? userId,
  }) async {
    if (!kinds.contains(kind)) throw DomainException('Unknown party kind: $kind');
    if (!tiers.contains(tier)) throw DomainException('Unknown tier: $tier');
    if (name.trim().isEmpty) throw DomainException('Name is required');
    if (creditLimitPaise < 0) {
      throw DomainException('Credit limit cannot be negative');
    }
    await ctx.db.transaction(() async {
      final before = await getParty(partyId);
      await (ctx.db.update(ctx.db.parties)..where((t) => t.id.equals(partyId)))
          .write(PartiesCompanion(
        kind: Value(kind),
        name: Value(name.trim()),
        tier: Value(tier),
        creditLimitPaise: Value(creditLimitPaise),
        phone: Value(phone),
        gstin: Value(gstin),
        address: Value(address),
        stateCode: Value(stateCode),
        updatedAt: Value(ctx.clock()),
      ));
      final after = await getParty(partyId);
      await ctx.recordOutbox('parties', partyId, 'upsert', after.toJson());
      await _audit.record(
        action: 'edit',
        entity: 'party',
        entityId: partyId,
        userId: userId,
        before: before.toJson(),
        after: after.toJson(),
      );
    });
  }

  /// Parties for the list screens. [kind] filters: 'customer' gives customers
  /// and both, 'supplier' gives suppliers and both, null gives everyone.
  Future<List<Party>> list({String? kind, String query = '', int limit = 500}) {
    final q = query.trim().replaceAll('%', '').replaceAll('_', '');
    final like = '%$q%';
    final kindFilter = switch (kind) {
      'customer' => const ['customer', 'both'],
      'supplier' => const ['supplier', 'both'],
      _ => null,
    };
    return (ctx.db.select(ctx.db.parties)
          ..where((t) =>
              t.deletedAt.isNull() &
              (kindFilter == null ? const Constant(true) : t.kind.isIn(kindFilter)) &
              (q.isEmpty
                  ? const Constant(true)
                  : (t.name.like(like) | t.phone.like(like))))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit))
        .get();
  }

  /// Customers (kind customer or both) whose name or phone contains [query].
  Future<List<Party>> searchCustomers(String query, {int limit = 20}) =>
      list(kind: 'customer', query: query, limit: limit);

  /// Suppliers (kind supplier or both) whose name or phone contains [query].
  Future<List<Party>> searchSuppliers(String query, {int limit = 20}) =>
      list(kind: 'supplier', query: query, limit: limit);
}
