import 'package:drift/drift.dart';

import '../app_database.dart';
import 'repo_context.dart';

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

  /// Adds one signed entry. Call inside a transaction when part of a larger write.
  Future<String> addEntry({
    required String partyId,
    required String entryType,
    required int amountPaise,
    String? refType,
    String? refId,
    String? note,
    DateTime? ts,
  }) async {
    if (!entryTypes.contains(entryType)) {
      throw DomainException('Unknown ledger entry type: $entryType');
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
          ),
          'ledger_entries',
          id,
        ));
    return id;
  }

  /// Customer pays money: reduces what they owe.
  Future<String> recordCustomerPayment(String partyId, int paise,
      {String? note}) {
    if (paise <= 0) throw DomainException('Payment must be > 0');
    return addEntry(
        partyId: partyId,
        entryType: 'payment',
        amountPaise: -paise,
        note: note);
  }

  /// Shop pays a supplier: reduces what the shop owes.
  Future<String> recordSupplierPayment(String partyId, int paise,
      {String? note}) {
    if (paise <= 0) throw DomainException('Payment must be > 0');
    return addEntry(
        partyId: partyId,
        entryType: 'supplier_payment',
        amountPaise: paise,
        note: note);
  }

  /// Opening balance, signed using the convention above.
  Future<String> addOpeningBalance(String partyId, int signedPaise) =>
      addEntry(
          partyId: partyId,
          entryType: 'opening',
          amountPaise: signedPaise,
          note: 'Opening balance');

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
}
