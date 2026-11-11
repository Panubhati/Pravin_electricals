import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';

import '../generated_migrations/schema.dart';
import '../generated_migrations/schema_v1.dart' as v1;
import '../generated_migrations/schema_v2.dart' as v2;
import '../generated_migrations/schema_v3.dart' as v3;

/// A phone with shop data on schema v1 must upgrade to the current version without losing
/// anything (plan section 12, "Migration test").
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 to v4 keeps existing shop data and the schema matches', () async {
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
      4,
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

  test('v2 to v4 adds settings and keeps shop data', () async {
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
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 4);
    expect((await db.select(db.users).get()).single.role, 'owner');
    expect((await db.select(db.appSettings).get()), isEmpty);
    await db.close();
  });

  test('v3 to v4 adds the sold HSN to bill lines and keeps existing lines', () async {
    final schema = await verifier.schemaAt(3);
    final secs = DateTime(2026, 11, 12, 10).millisecondsSinceEpoch ~/ 1000;
    final old = v3.DatabaseAtV3(schema.newConnection());
    for (final sql in [
      "INSERT INTO shops (id, shop_id, created_at, updated_at, name) VALUES ('s', 's', $secs, $secs, 'Shop')",
      "INSERT INTO devices (id, shop_id, created_at, updated_at, label, invoice_series_prefix) VALUES ('d', 's', $secs, $secs, 'Phone', 'A')",
      "INSERT INTO items (id, shop_id, created_at, updated_at, name, base_unit, gst_rate_bp, price_unit_factor, track_serial, track_coil, min_stock_base, active) VALUES ('i', 's', $secs, $secs, 'Wire', 'mm', 1800, 1000, 0, 0, 0, 1)",
      "INSERT INTO invoices (id, shop_id, created_at, updated_at, device_id, series, number, invoice_no_text, date, subtotal_paise, discount_paise, tax_paise, round_off_paise, total_paise, paid_paise, status) VALUES ('inv', 's', $secs, $secs, 'd', 'A', 1, 'A-0001', $secs, 11875, 0, 1811, 25, 11900, 11900, 'posted')",
      "INSERT INTO invoice_lines (id, shop_id, created_at, updated_at, invoice_id, item_id, unit_name, qty_entered, qty_base, rate_paise, price_unit_factor, discount_paise, gst_rate_bp, tax_paise, line_total_paise) VALUES ('l', 's', $secs, $secs, 'inv', 'i', 'm', '2.5', 2500, 4750, 1000, 0, 1800, 1811, 11875)",
    ]) {
      await old.customStatement(sql);
    }
    await old.close();

    late AppDatabase db;
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 4);
    final line = (await db.select(db.invoiceLines).get()).single;
    expect(line.lineTotalPaise, 11875);
    expect(line.hsn, isNull); // old lines have no sold HSN; reprints fall back to the item's
    await db.close();
  });

  test('a fresh install creates the v4 schema directly', () async {
    final schema = await verifier.schemaAt(4);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });
}
