import 'package:drift/drift.dart';

import '../../dues/ageing.dart';
import '../app_database.dart';
import 'ledger_repository.dart';
import 'repo_context.dart';

/// A party with what they owe (or are owed) and its ageing.
class PartyDues {
  const PartyDues({
    required this.party,
    required this.balancePaise,
    required this.buckets,
  });

  final Party party;

  /// Ledger balance (positive: party owes the shop).
  final int balancePaise;
  final AgeingBuckets buckets;
}

/// Dues and ageing for customers (receivables) and suppliers (payables), built
/// from the same ledger as everything else, so numbers always agree with the
/// bill's credit warning and the party statements.
class DuesRepository {
  DuesRepository(this.ctx) : _ledger = LedgerRepository(ctx);
  final RepoContext ctx;
  final LedgerRepository _ledger;

  /// Customers (kind customer or both) who still owe money, worst first.
  Future<List<PartyDues>> receivables({DateTime? asOf}) =>
      _load(const ['customer', 'both'], payable: false, asOf: asOf);

  /// Suppliers (kind supplier or both) the shop still owes, worst first.
  Future<List<PartyDues>> payables({DateTime? asOf}) =>
      _load(const ['supplier', 'both'], payable: true, asOf: asOf);

  /// One party's ageing, e.g. for the party screen.
  Future<AgeingBuckets> ageingFor(String partyId,
      {required bool payable, DateTime? asOf}) async {
    final entries = (await _ledger.entriesByParty([partyId]))[partyId] ?? [];
    return AgeingCalculator.age(
      [for (final e in entries) AgeingEntry(e.ts, e.amountPaise)],
      asOf ?? ctx.clock(),
      payable: payable,
    );
  }

  /// Sum of buckets across [list], e.g. for the dashboard's total dues.
  static AgeingBuckets total(List<PartyDues> list) => AgeingBuckets(
        days0to30: list.fold(0, (a, d) => a + d.buckets.days0to30),
        days31to60: list.fold(0, (a, d) => a + d.buckets.days31to60),
        days61to90: list.fold(0, (a, d) => a + d.buckets.days61to90),
        over90: list.fold(0, (a, d) => a + d.buckets.over90),
        advance: list.fold(0, (a, d) => a + d.buckets.advance),
      );

  Future<List<PartyDues>> _load(
    List<String> kinds, {
    required bool payable,
    DateTime? asOf,
  }) async {
    final when = asOf ?? ctx.clock();
    final parties = await (ctx.db.select(ctx.db.parties)
          ..where((t) => t.deletedAt.isNull() & t.kind.isIn(kinds)))
        .get();
    final entries = await _ledger.entriesByParty(parties.map((p) => p.id));

    final out = <PartyDues>[];
    for (final p in parties) {
      final list = entries[p.id] ?? const <LedgerEntry>[];
      final buckets = AgeingCalculator.age(
        [for (final e in list) AgeingEntry(e.ts, e.amountPaise)],
        when,
        payable: payable,
      );
      if (buckets.totalDue <= 0) continue;
      out.add(PartyDues(
        party: p,
        balancePaise: list.fold(0, (a, e) => a + e.amountPaise),
        buckets: buckets,
      ));
    }
    out.sort((a, b) {
      final c = b.buckets.over90.compareTo(a.buckets.over90);
      if (c != 0) return c;
      final d = b.buckets.overdue.compareTo(a.buckets.overdue);
      if (d != 0) return d;
      return b.buckets.totalDue.compareTo(a.buckets.totalDue);
    });
    return out;
  }
}
