import 'package:drift/drift.dart';

import 'base.dart';
import 'party_tables.dart';

/// Append-only (A11): every payment reminder sent to a customer, by SMS or
/// WhatsApp, from either phone. Synced, so the other phone does not remind the
/// same customer again within the repeat interval.
@TableIndex(name: 'reminders_party', columns: {#partyId})
class Reminders extends Table with BaseColumns {
  TextColumn get partyId => text().references(Parties, #id)();

  /// sms | whatsapp
  TextColumn get channel => text()();

  /// What they owed when reminded.
  IntColumn get amountPaise => integer()();

  /// Date of their oldest unpaid bill at the time.
  DateTimeColumn get oldestDueAt => dateTime()();
  DateTimeColumn get sentAt => dateTime()();

  /// The phone that sent it, and who (a person for WhatsApp; null for automatic SMS).
  TextColumn get deviceId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
}
