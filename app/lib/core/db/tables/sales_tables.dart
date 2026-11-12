import 'package:drift/drift.dart';
import 'base.dart';
import 'core_tables.dart';
import 'item_tables.dart';
import 'party_tables.dart';

/// Posted invoices are immutable. Corrections are returns or credit notes.
@TableIndex(name: 'invoices_date', columns: {#date})
class Invoices extends Table with BaseColumns {
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get series => text()();
  IntColumn get number => integer()();
  TextColumn get invoiceNoText => text()();
  TextColumn get partyId => text().nullable().references(Parties, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get subtotalPaise => integer()();
  IntColumn get discountPaise => integer().withDefault(const Constant(0))();
  IntColumn get taxPaise => integer()();
  IntColumn get roundOffPaise => integer().withDefault(const Constant(0))();
  IntColumn get totalPaise => integer()();
  IntColumn get paidPaise => integer().withDefault(const Constant(0))();

  /// posted | cancelled
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get shopSnapshotJson => text().nullable()();
  TextColumn get createdBy => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {deviceId, series, number},
      ];
}

class InvoiceLines extends Table with BaseColumns {
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable().references(ItemVariants, #id)();
  TextColumn get unitName => text()();

  /// Quantity exactly as staff entered it, as decimal text (e.g. "2.5").
  TextColumn get qtyEntered => text()();
  IntColumn get qtyBase => integer()();

  /// Paise per pricing unit.
  IntColumn get ratePaise => integer()();
  IntColumn get priceUnitFactor => integer().withDefault(const Constant(1))();
  IntColumn get discountPaise => integer().withDefault(const Constant(0))();
  IntColumn get gstRateBp => integer().withDefault(const Constant(0))();
  IntColumn get taxPaise => integer()();
  IntColumn get lineTotalPaise => integer()();
  TextColumn get coilId => text().nullable()();
  TextColumn get serial => text().nullable()();

  /// HSN code the item had when it was sold (schema v4), so a reprint shows
  /// what the bill showed. Null on older lines.
  TextColumn get hsn => text().nullable()();
}

class InvoicePayments extends Table with BaseColumns {
  TextColumn get invoiceId => text().references(Invoices, #id)();

  /// cash | upi | credit | card
  TextColumn get mode => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get ref => text().nullable()();
}

/// A credit note: part or all of a posted bill taken back (schema v5 gave it its
/// own number, GST, round-off and the way the money went back). The original bill
/// is never edited; this record reverses part of it.
class SalesReturns extends Table with BaseColumns {
  TextColumn get invoiceId => text().references(Invoices, #id)();

  /// Credit note number in this device's series, e.g. "CN-A-0001".
  TextColumn get deviceId => text().references(Devices, #id)();
  TextColumn get series => text()();
  IntColumn get number => integer()();
  TextColumn get creditNoteNoText => text()();
  DateTimeColumn get date => dateTime()();

  /// Everything given back to the customer (lines + round-off share).
  IntColumn get totalPaise => integer()();

  /// GST contained in the lines returned (informational; prices include GST).
  IntColumn get taxPaise => integer().withDefault(const Constant(0))();

  /// Share of the bill's round-off, refunded with the return that completes the bill.
  IntColumn get roundOffPaise => integer().withDefault(const Constant(0))();

  /// How the money went back: handed over in cash, sent by UPI, or taken off
  /// what the customer owes (a credit to their account). They add up to [totalPaise].
  IntColumn get refundCashPaise => integer().withDefault(const Constant(0))();
  IntColumn get refundUpiPaise => integer().withDefault(const Constant(0))();
  IntColumn get refundAccountPaise => integer().withDefault(const Constant(0))();

  /// True when the whole bill was cancelled (the bill is then marked cancelled).
  BoolColumn get isCancel => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  TextColumn get createdBy => text().nullable()();

  /// The owner who approved it (the same person when the owner did it).
  TextColumn get approvedBy => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {deviceId, series, number},
      ];
}

class SalesReturnLines extends Table with BaseColumns {
  TextColumn get returnId => text().references(SalesReturns, #id)();
  TextColumn get invoiceLineId => text().references(InvoiceLines, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get variantId => text().nullable()();

  /// Quantity as the line was sold (e.g. "1.5" with unit "m").
  TextColumn get unitName => text()();
  TextColumn get qtyEntered => text()();
  IntColumn get qtyBase => integer()();

  /// What this part of the line refunds (GST included, discount already taken off).
  IntColumn get lineTotalPaise => integer()();
  IntColumn get taxPaise => integer().withDefault(const Constant(0))();
}
