import 'package:drift/drift.dart';
import 'base.dart';

class Parties extends Table with BaseColumns {
  /// customer | supplier | both
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get stateCode => text().nullable()();

  /// retail | contractor | dealer
  TextColumn get tier => text().withDefault(const Constant('retail'))();
  IntColumn get creditLimitPaise => integer().withDefault(const Constant(0))();

  /// A11: never send this customer payment reminders.
  BoolColumn get remindersOff => boolean().withDefault(const Constant(false))();
}

/// Append-only. Balance = sum(amountPaise). Corrections use reversing entries.
@TableIndex(name: 'ledger_entries_party', columns: {#partyId})
class LedgerEntries extends Table with BaseColumns {
  TextColumn get partyId => text().references(Parties, #id)();

  /// invoice | payment | return | opening | adjustment | purchase | supplier_payment
  TextColumn get entryType => text()();

  /// Signed: receivable from customer positive, payment negative.
  IntColumn get amountPaise => integer()();
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();
  TextColumn get note => text().nullable()();

  /// cash | upi | bank, for payments (added in schema v2). Null for other entries.
  TextColumn get paymentMode => text().nullable()();
  DateTimeColumn get ts => dateTime()();
}
