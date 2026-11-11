import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

/// One ledger entry with the running balance after it.
class StatementLine {
  const StatementLine(this.entry, this.runningBalancePaise);
  final LedgerEntry entry;
  final int runningBalancePaise;
}

/// Append-only party ledger. There is deliberately no update or delete here:
/// corrections are reversing entries.
///
/// Sign convention (same for customers and suppliers): positive means the party
/// owes the shop, negative means the shop owes the party. So a credit sale is
/// +, a customer payment is -, a purchase on credit is -, and a payment to a
/// supplier is +.
class LedgerRepository {
  LedgerRepository(this.ctx);
  final RepoContext ctx;

  static const entryTypes = {
    'invoice',
    'payment',
    'return',
    'opening',
    'adjustment',
    'purchase',
    'supplier_payment',
  };

  /// How a payment was made. Lets the dashboard split cash from UPI and bank.
  static const paymentModes = {'cash', 'upi', 'bank'};

  /// Adds one signed entry. Call inside a transaction when part of a larger write.
  Future<String> addEntry({
    required String partyId,
    required String entryType,
    required int amountPaise,
    String? refType,
    String? refId,
    String? note,
    String? paymentMode,
    DateTime? ts,
  }) async {
    if (!entryTypes.contains(entryType)) {
      throw DomainException('Unknown ledger entry type: $entryType');
    }
    if (paymentMode != null && !paymentModes.contains(paymentMode)) {
      throw DomainException('Unknown payment mode: $paymentMode');
    }
    final now = ctx.clock();
    final id = ctx.newId();
    await ctx.db.transaction(() => ctx.insertRow(
          ctx.db.ledgerEntries,
          LedgerEntriesCompanion.insert(
            id: id,
            shopId: ctx.shopId,
            createdAt: now,
            updatedAt: now,
            partyId: partyId,
            entryType: entryType,
            amountPaise: amountPaise,
            ts: ts ?? now,
            refType: Value(refType),
            refId: Value(refId),
            note: Value(note),
            paymentMode: Value(paymentMode),
          ),
          'ledger_entries',
          id,
        ));
    return id;
  }

  /// Customer pays money: reduces what they owe. [mode] is cash | upi | bank.
  Future<String> recordCustomerPayment(
    String partyId,
    int paise, {
    String mode = 'cash',
    String? note,
    DateTime? ts,
  }) {
    if (paise <= 0) throw DomainException('Payment must be > 0');
    return addEntry(
      partyId: partyId,
      entryType: 'payment',
      amountPaise: -paise,
      paymentMode: mode,
      note: note,
      ts: ts,
    );
  }

  /// Shop pays a supplier: reduces what the shop owes.
  Future<String> recordSupplierPayment(
    String partyId,
    int paise, {
    String mode = 'cash',
    String? note,
    DateTime? ts,
  }) {
    if (paise <= 0) throw DomainException('Payment must be > 0');
    return addEntry(
      partyId: partyId,
      entryType: 'supplier_payment',
      amountPaise: paise,
      paymentMode: mode,
      note: note,
      ts: ts,
    );
  }

  /// Opening balance, signed using the convention above.
  Future<String> addOpeningBalance(String partyId, int signedPaise,
          {DateTime? ts}) =>
      addEntry(
        partyId: partyId,
        entryType: 'opening',
        amountPaise: signedPaise,
        note: 'Opening balance',
        ts: ts,
      );

  /// Party balance = sum of its ledger entries (never stored).
  Future<int> balance(String partyId) async {
    final sum = ctx.db.ledgerEntries.amountPaise.sum();
    final q = ctx.db.selectOnly(ctx.db.ledgerEntries)
      ..addColumns([sum])
      ..where(ctx.db.ledgerEntries.partyId.equals(partyId) &
          ctx.db.ledgerEntries.deletedAt.isNull());
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Balance of every party that has entries, in one query (partyId -> paise).
  Future<Map<String, int>> balancesByParty() async {
    final e = ctx.db.ledgerEntries;
    final sum = e.amountPaise.sum();
    final q = ctx.db.selectOnly(e)
      ..addColumns([e.partyId, sum])
      ..where(e.deletedAt.isNull())
      ..groupBy([e.partyId]);
    final rows = await q.get();
    return {for (final r in rows) r.read(e.partyId)!: r.read(sum) ?? 0};
  }

  /// All entries of a party, oldest first, each with the running balance.
  Future<List<StatementLine>> statement(String partyId) async {
    final entries = await (ctx.db.select(ctx.db.ledgerEntries)
          ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.ts),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    var running = 0;
    return [
      for (final e in entries)
        StatementLine(e, running += e.amountPaise),
    ];
  }

  /// Ledger entries for many parties at once, grouped by party.
  Future<Map<String, List<LedgerEntry>>> entriesByParty(
      Iterable<String> partyIds) async {
    final ids = partyIds.toList();
    if (ids.isEmpty) return {};
    final rows = await (ctx.db.select(ctx.db.ledgerEntries)
          ..where((t) => t.partyId.isIn(ids) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.ts),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    final out = <String, List<LedgerEntry>>{};
    for (final r in rows) {
      (out[r.partyId] ??= []).add(r);
    }
    return out;
  }
}
