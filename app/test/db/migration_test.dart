import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';

import '../generated_migrations/schema.dart';
import '../generated_migrations/schema_v1.dart' as v1;
import '../generated_migrations/schema_v2.dart' as v2;

/// A phone with shop data on schema v1 must upgrade to the current version without losing
/// anything (plan section 12, "Migration test").
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 to v3 keeps existing shop data and the schema matches', () async {
    final schema = await verifier.schemaAt(1);

    // Build a v1 database holding data like an A2 phone: shop, party, ledger, stock.
    final old = v1.DatabaseAtV1(schema.newConnection());
    final now = DateTime(2026, 11, 11, 10);
    final secs = now.millisecondsSinceEpoch ~/ 1000;
    await old.customStatement(
        "INSERT INTO shops (id, shop_id, created_at, updated_at, name) "
        "VALUES ('shop1', 'shop1', $secs, $secs, 'Pravin Electricals')");
    await old.customStatement(
        "INSERT INTO parties (id, shop_id, created_at, updated_at, kind, name) "
        "VALUES ('p1', 'shop1', $secs, $secs, 'customer', 'Ramesh')");
    await old.customStatement(
        "INSERT INTO ledger_entries (id, shop_id, created_at, updated_at, party_id, "
        "entry_type, amount_paise, ts) "
        "VALUES ('l1', 'shop1', $secs, $secs, 'p1', 'invoice', 13500, $secs)");
    await old.close();

    // Open the same file with the current schema and migrate.
    late AppDatabase db;
    await verifier.migrateAndValidate(
      db = AppDatabase(schema.newConnection()),
      3,
    );

    // Old rows survived and new columns exist (null for old rows).
    final ledger = await db.select(db.ledgerEntries).get();
    expect(ledger, hasLength(1));
    expect(ledger.single.amountPaise, 13500);
    expect(ledger.single.paymentMode, isNull);
    expect((await db.select(db.parties).get()).single.name, 'Ramesh');

    // New columns accept data.
    await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
          id: 'l2', shopId: 'shop1', createdAt: now, updatedAt: now,
          partyId: 'p1', entryType: 'payment', amountPaise: -5000, ts: now,
          paymentMode: const Value('upi')));
    final paid = await (db.select(db.ledgerEntries)..where((t) => t.id.equals('l2'))).getSingle();
    expect(paid.paymentMode, 'upi');
    await db.close();
  });

  test('v2 to v3 adds settings and keeps shop data', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    final secs = DateTime(2026, 11, 12, 10).millisecondsSinceEpoch ~/ 1000;
    await old.customStatement(
        "INSERT INTO shops (id, shop_id, created_at, updated_at, name) "
        "VALUES ('shop1', 'shop1', $secs, $secs, 'Pravin Electricals')");
    await old.customStatement(
        "INSERT INTO users (id, shop_id, created_at, updated_at, name, role, active) "
        "VALUES ('u1', 'shop1', $secs, $secs, 'Owner', 'owner', 1)");
    await old.close();

    late AppDatabase db;
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 3);
    expect((await db.select(db.users).get()).single.role, 'owner');
    expect((await db.select(db.appSettings).get()), isEmpty);
    await db.close();
  });

  test('a fresh install creates the v3 schema directly', () async {
    final schema = await verifier.schemaAt(3);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });
}
