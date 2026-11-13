import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/sync/device_identity.dart';

import '../generated_migrations/schema.dart';
import '../generated_migrations/schema_v1.dart' as v1;
import '../generated_migrations/schema_v2.dart' as v2;
import '../generated_migrations/schema_v3.dart' as v3;
import '../generated_migrations/schema_v4.dart' as v4;
import '../generated_migrations/schema_v5.dart' as v5;
import '../generated_migrations/schema_v6.dart' as v6;

/// A phone with shop data on schema v1 must upgrade to the current version without losing
/// anything (plan section 12, "Migration test").
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 to v7 keeps existing shop data and the schema matches', () async {
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
      7,
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

  test('v2 to v7 adds settings and keeps shop data', () async {
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
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 7);
    expect((await db.select(db.users).get()).single.role, 'owner');
    expect((await db.select(db.appSettings).get()), isEmpty);
    await db.close();
  });

  test('v3 upgrades to v7: the sold HSN column appears and existing bill lines are kept', () async {
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
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 7);
    final line = (await db.select(db.invoiceLines).get()).single;
    expect(line.lineTotalPaise, 11875);
    expect(line.hsn, isNull); // old lines have no sold HSN; reprints fall back to the item's
    await db.close();
  });

  test('v4 to v7 rebuilds the credit note tables and keeps every bill', () async {
    final schema = await verifier.schemaAt(4);
    final secs = DateTime(2026, 11, 12, 10).millisecondsSinceEpoch ~/ 1000;
    final old = v4.DatabaseAtV4(schema.newConnection());
    for (final sql in [
      "INSERT INTO shops (id, shop_id, created_at, updated_at, name) VALUES ('s', 's', $secs, $secs, 'Shop')",
      "INSERT INTO devices (id, shop_id, created_at, updated_at, label, invoice_series_prefix) VALUES ('d', 's', $secs, $secs, 'Phone', 'A')",
      "INSERT INTO invoices (id, shop_id, created_at, updated_at, device_id, series, number, invoice_no_text, date, subtotal_paise, discount_paise, tax_paise, round_off_paise, total_paise, paid_paise, status) VALUES ('inv', 's', $secs, $secs, 'd', 'A', 1, 'A-0001', $secs, 11875, 0, 1811, 25, 11900, 11900, 'posted')",
    ]) {
      await old.customStatement(sql);
    }
    await old.close();

    late AppDatabase db;
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 7);
    expect((await db.select(db.invoices).get()).single.invoiceNoText, 'A-0001');
    expect(await db.select(db.salesReturns).get(), isEmpty);
    // The rebuilt tables accept a credit note.
    await db.customStatement(
        "INSERT INTO sales_returns (id, shop_id, created_at, updated_at, invoice_id, device_id, series, number, "
        "credit_note_no_text, date, total_paise) VALUES ('r', 's', $secs, $secs, 'inv', 'd', 'A', 1, 'CN-A-0001', $secs, 100)");
    expect((await db.select(db.salesReturns).get()).single.creditNoteNoText, 'CN-A-0001');
    await db.close();
  });

  test('v5 to v7: outbox rows are claimed by this phone in order, and purchases keep their rows', () async {
    final schema = await verifier.schemaAt(5);
    final secs = DateTime(2026, 11, 12, 10).millisecondsSinceEpoch ~/ 1000;
    final old = v5.DatabaseAtV5(schema.newConnection());
    for (final sql in [
      "INSERT INTO shops (id, shop_id, created_at, updated_at, name) VALUES ('s', 's', $secs, $secs, 'Shop')",
      "INSERT INTO users (id, shop_id, created_at, updated_at, name, role) VALUES ('u', 's', $secs, $secs, 'Owner', 'owner')",
      "INSERT INTO devices (id, shop_id, created_at, updated_at, label, invoice_series_prefix) VALUES ('d', 's', $secs, $secs, 'Phone', 'A')",
      "INSERT INTO locations (id, shop_id, created_at, updated_at, name) VALUES ('loc', 's', $secs, $secs, 'shop')",
      "INSERT INTO parties (id, shop_id, created_at, updated_at, kind, name) VALUES ('sup', 's', $secs, $secs, 'supplier', 'Havells')",
      "INSERT INTO purchases (id, shop_id, created_at, updated_at, supplier_id, supplier_invoice_no, supplier_invoice_date, subtotal_paise, tax_paise, total_paise) VALUES ('pu', 's', $secs, $secs, 'sup', 'H-1', $secs, 100, 18, 118)",
      "INSERT INTO outbox (id, shop_id, entity, entity_id, op, payload_json, created_at) VALUES ('o1', 's', 'shops', 's', 'upsert', '{}', $secs)",
      "INSERT INTO outbox (id, shop_id, entity, entity_id, op, payload_json, created_at) VALUES ('o2', 's', 'parties', 'sup', 'upsert', '{}', $secs)",
      "INSERT INTO outbox (id, shop_id, entity, entity_id, op, payload_json, created_at) VALUES ('o3', 's', 'purchases', 'pu', 'upsert', '{}', $secs)",
    ]) {
      await old.customStatement(sql);
    }
    await old.close();

    late AppDatabase db;
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 7);
    expect((await db.select(db.purchases).get()).single.supplierInvoiceNo, 'H-1');

    final identity = MemoryDeviceIdentity();
    final session = await ensureShopSession(db, identity: identity);
    expect(session.deviceId, 'd');
    expect(identity.value, 'd', reason: 'the one phone of a pre-A8 shop is phone A');
    final rows = await (db.select(db.outbox)..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    expect(rows.map((r) => r.id), ['o1', 'o2', 'o3']);
    expect(rows.every((r) => r.originDeviceId == 'd'), isTrue);
    expect(rows.map((r) => r.seq).toSet(), hasLength(3));

    // New writes continue the same sequence.
    await SettingsRepository(session.ctx).set('upi_id', 'shop@upi');
    final last = await (db.select(db.outbox)..orderBy([(t) => OrderingTerm.desc(t.seq)])..limit(1)).getSingle();
    expect(last.entity, 'app_settings');
    expect(last.seq, greaterThan(rows.last.seq));
    await db.close();
  });

  test('v6 to v7: customers get the reminders switch (off by default) and the reminder log is empty', () async {
    final schema = await verifier.schemaAt(6);
    final secs = DateTime(2026, 11, 13, 10).millisecondsSinceEpoch ~/ 1000;
    final old = v6.DatabaseAtV6(schema.newConnection());
    await old.customStatement(
        "INSERT INTO parties (id, shop_id, created_at, updated_at, kind, name) VALUES ('p1', 's', $secs, $secs, 'customer', 'Ramesh')");
    await old.close();
    late AppDatabase db;
    await verifier.migrateAndValidate(db = AppDatabase(schema.newConnection()), 7);
    final p = (await db.select(db.parties).get()).single;
    expect(p.remindersOff, isFalse);
    expect(await db.select(db.reminders).get(), isEmpty);
    await db.close();
  });

  test('a fresh install creates the v7 schema directly', () async {
    final schema = await verifier.schemaAt(7);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);
    await db.close();
  });
}
