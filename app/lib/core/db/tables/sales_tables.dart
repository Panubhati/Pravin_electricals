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

class SalesReturns extends Table with BaseColumns {
  TextColumn get invoiceId => text().references(Invoices, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalPaise => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get createdBy => text().nullable()();
}

class SalesReturnLines extends Table with BaseColumns {
  TextColumn get returnId => text().references(SalesReturns, #id)();
  TextColumn get invoiceLineId => text().references(InvoiceLines, #id)();
  TextColumn get itemId => text().references(Items, #id)();
  IntColumn get qtyBase => integer()();
  IntColumn get lineTotalPaise => integer()();
}
