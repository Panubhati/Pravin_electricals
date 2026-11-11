import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

class PartyRepository {
  PartyRepository(this.ctx);
  final RepoContext ctx;

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
    if (!const {'customer', 'supplier', 'both'}.contains(kind)) {
      throw DomainException('Unknown party kind: $kind');
    }
    if (!const {'retail', 'contractor', 'dealer'}.contains(tier)) {
      throw DomainException('Unknown tier: $tier');
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
            name: name,
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

  /// Customers (kind customer or both) whose name or phone contains [query].
  Future<List<Party>> searchCustomers(String query, {int limit = 20}) {
    final q = query.trim().replaceAll('%', '').replaceAll('_', '');
    final like = '%$q%';
    return (ctx.db.select(ctx.db.parties)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.kind.isIn(const ['customer', 'both']) &
              (q.isEmpty
                  ? const Constant(true)
                  : (t.name.like(like) | t.phone.like(like))))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit))
        .get();
  }
}
