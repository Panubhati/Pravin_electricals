import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/data_check_models.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

import '../helpers/seed_rich_shop.dart';

/// "Check my data" must stay quiet on a healthy shop, and each check must catch
/// exactly the corruption it exists for. Each test damages one thing with plain
/// SQL (as a bug or a bad restore might) and expects that check to speak up.
void main() {
  late AppDatabase db;
  late ShopSession s;
  late DataCheckRepository checker;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    await seedRichShop(s);
    checker = DataCheckRepository(s.ctx);
  });
  tearDown(() => db.close());

  Future<DataCheckResult> run() => checker.run();
  Future<void> sql(String statement) => db.customStatement(statement);
  Future<void> noForeignKeys() => db.customStatement('PRAGMA foreign_keys = OFF');

  Set<String> codes(DataCheckResult r) => {for (final i in r.issues) i.code};
  DataIssue issue(DataCheckResult r, String code) => r.issues.firstWhere((i) => i.code == code,
      orElse: () => fail('expected "$code", found ${codes(r)}'));

  group('a healthy shop', () {
    test('passes with nothing to report and counts what it looked at', () async {
      final r = await run();
      expect(r.issues, isEmpty, reason: r.issues.join('\n'));
      expect(r.passed, isTrue);
      expect(r.checksRun, 20);
      expect(r.records, greaterThan(20));
      expect(r.errorCount, 0);
      expect(r.warningCount, 0);
    });

    test('an empty new shop passes too', () async {
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(fresh.close);
      final r = await DataCheckRepository((await ensureShopSession(fresh)).ctx).run();
      expect(r.errors, isEmpty);
    });

    test('a shop with a return-free history of many edits still passes (stock adjusted, counted)', () async {
      final stock = StockRepository(s.ctx);
      final row = await db.customSelect('SELECT id FROM items LIMIT 1').getSingle();
      await stock.adjust(itemId: row.read<String>('id'), locationId: s.locationId, deltaBase: 5, reason: 'Found');
      await stock.recordCount(itemId: row.read<String>('id'), locationId: s.locationId, countedBase: 50);
      expect((await run()).issues, isEmpty);
    });
  });

  group('bills', () {
    test('a total that is not subtotal - discount + round-off', () async {
      await sql("UPDATE invoices SET total_paise = total_paise + 100 WHERE invoice_no_text = 'A-0001'");
      final r = await run();
      expect(issue(r, 'invoice_total').message, contains('Bill A-0001'));
      expect(r.passed, isFalse);
      expect(r.errorCount, greaterThan(0));
    });

    test('a bill whose lines no longer add up to its subtotal', () async {
      await sql("UPDATE invoice_lines SET line_total_paise = line_total_paise + 5 "
          "WHERE invoice_id = (SELECT id FROM invoices WHERE invoice_no_text = 'A-0001')");
      final r = await run();
      expect(codes(r), containsAll(['invoice_lines_sum', 'invoice_line_math']));
    });

    test('a line whose rate was changed after the fact', () async {
      await sql("UPDATE invoice_lines SET rate_paise = rate_paise + 100 "
          "WHERE invoice_id = (SELECT id FROM invoices WHERE invoice_no_text = 'A-0001')");
      expect(codes(await run()), contains('invoice_line_math'));
    });

    test('GST that does not match the formula', () async {
      await sql("UPDATE invoice_lines SET tax_paise = tax_paise + 1 "
          "WHERE invoice_id = (SELECT id FROM invoices WHERE invoice_no_text = 'A-0001')");
      final r = await run();
      expect(codes(r), containsAll(['invoice_line_math', 'invoice_lines_tax']));
    });

    test('a bill with its discount missing from the lines', () async {
      await sql("UPDATE invoices SET discount_paise = 50, total_paise = total_paise - 50 WHERE invoice_no_text = 'A-0001'");
      expect(codes(await run()), contains('invoice_lines_discount'));
    });

    test('a bill with no lines at all', () async {
      await noForeignKeys();
      await sql("DELETE FROM invoice_lines WHERE invoice_id = (SELECT id FROM invoices WHERE invoice_no_text = 'A-0003')");
      expect(codes(await run()), contains('invoice_lines_missing'));
    });

    test('payments that do not add up to the bill', () async {
      await sql("DELETE FROM invoice_payments WHERE id = (SELECT id FROM invoice_payments WHERE mode = 'upi' LIMIT 1)");
      final r = await run();
      expect(codes(r), contains('invoice_payments'));
    });

    test('a paid amount that disagrees with the non-credit payments', () async {
      await sql("UPDATE invoices SET paid_paise = paid_paise + 1 WHERE invoice_no_text = 'A-0002'");
      expect(codes(await run()), contains('invoice_paid'));
    });

    test('a credit sale whose customer account entry is gone', () async {
      await sql("DELETE FROM ledger_entries WHERE entry_type = 'invoice'");
      final r = await run();
      expect(issue(r, 'invoice_credit_ledger').message, contains('A-0002'));
    });

    test('a customer account entry for a bill that was not on credit', () async {
      final party = await db.customSelect("SELECT id FROM parties WHERE name = 'Ramesh'").getSingle();
      final cash = await db.customSelect("SELECT id FROM invoices WHERE invoice_no_text = 'A-0001'").getSingle();
      await sql("INSERT INTO ledger_entries (id, shop_id, created_at, updated_at, party_id, entry_type, amount_paise, ref_type, ref_id, ts) "
          "VALUES ('x1', '${s.shopId}', 1, 1, '${party.read<String>('id')}', 'invoice', 500, 'invoice', '${cash.read<String>('id')}', 1)");
      expect(codes(await run()), contains('invoice_ledger_extra'));
    });

    test('two bills with the same number cannot exist at all (the database refuses)', () async {
      await expectLater(
        db.customStatement("INSERT INTO invoices (id, shop_id, created_at, updated_at, device_id, series, number, invoice_no_text, "
            "date, subtotal_paise, tax_paise, total_paise) "
            "SELECT 'dup', shop_id, 1, 1, device_id, series, number, invoice_no_text, 1, 0, 0, 0 FROM invoices LIMIT 1"),
        throwsA(anything),
      );
    });

    test('a missing bill number is a note, not a failure', () async {
      await noForeignKeys();
      final id = await db.customSelect("SELECT id FROM invoices WHERE invoice_no_text = 'A-0002'").getSingle();
      final i = id.read<String>('id');
      for (final t in ['invoice_lines', 'invoice_payments']) {
        await sql("DELETE FROM $t WHERE invoice_id = '$i'");
      }
      await sql("DELETE FROM stock_movements WHERE ref_id = '$i'");
      await sql("DELETE FROM ledger_entries WHERE ref_id = '$i'");
      await sql("DELETE FROM invoices WHERE id = '$i'");
      final r = await run();
      expect(issue(r, 'invoice_number_gap').severity, IssueSeverity.warning);
      expect(r.passed, isTrue);
    });

    test('a bill dated in the future (wrong phone clock) is a note', () async {
      final soon = DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;
      await sql("UPDATE invoices SET date = $soon WHERE invoice_no_text = 'A-0003'");
      final r = await run();
      expect(issue(r, 'invoice_future_date').severity, IssueSeverity.warning);
      expect(r.passed, isTrue);
    });
  });

  group('stock', () {
    test('a sale that took the wrong quantity out of stock', () async {
      await sql("UPDATE stock_movements SET qty_base = qty_base - 1 WHERE movement_type = 'sale' "
          "AND rowid = (SELECT MIN(rowid) FROM stock_movements WHERE movement_type = 'sale')");
      expect(codes(await run()), contains('sale_stock_mismatch'));
    });

    test('a sale with no stock movement at all', () async {
      await sql("DELETE FROM stock_movements WHERE movement_type = 'sale' "
          "AND rowid = (SELECT MIN(rowid) FROM stock_movements WHERE movement_type = 'sale')");
      expect(codes(await run()), contains('sale_stock_mismatch'));
    });

    test('stock taken out for a bill line that does not exist', () async {
      final item = await db.customSelect('SELECT id FROM items LIMIT 1').getSingle();
      final inv = await db.customSelect('SELECT id FROM invoices LIMIT 1').getSingle();
      final loc = await db.customSelect('SELECT id FROM locations LIMIT 1').getSingle();
      await db.customStatement(
          "INSERT INTO stock_movements (id, shop_id, created_at, updated_at, item_id, location_id, qty_base, movement_type, ref_type, ref_id, ts) "
          "VALUES ('ghost', '${s.shopId}', 1, 1, '${item.read<String>('id')}', '${loc.read<String>('id')}', -3, 'sale', 'invoice', "
          "'${inv.read<String>('id')}-nope', 1)");
      expect(codes(await run()), contains('sale_stock_orphan'));
    });

    test('a purchase that added the wrong quantity', () async {
      await sql("UPDATE stock_movements SET qty_base = qty_base + 1000 WHERE movement_type = 'purchase'");
      expect(issue(await run(), 'purchase_stock_mismatch').message, contains('S-501'));
    });

    test('a sale that adds stock, or a purchase that removes it', () async {
      await sql("UPDATE stock_movements SET qty_base = -qty_base WHERE movement_type = 'purchase'");
      final r = await run();
      expect(codes(r), contains('movement_sign'));
    });

    test('stock below zero is only a note', () async {
      final item = await db.customSelect("SELECT id FROM items WHERE name = '6A switch'").getSingle();
      await StockRepository(s.ctx).adjust(
          itemId: item.read<String>('id'), locationId: s.locationId, deltaBase: -100, reason: 'Lost');
      final r = await run();
      expect(issue(r, 'negative_stock').message, contains('6A switch'));
      expect(r.passed, isTrue);
    });
  });

  group('accounts (ledger)', () {
    test('an entry that points at a bill that does not exist', () async {
      final party = await db.customSelect("SELECT id FROM parties WHERE name = 'Ramesh'").getSingle();
      await sql("INSERT INTO ledger_entries (id, shop_id, created_at, updated_at, party_id, entry_type, amount_paise, ref_type, ref_id, ts) "
          "VALUES ('o1', '${s.shopId}', 1, 1, '${party.read<String>('id')}', 'invoice', 100, 'invoice', 'no-such-bill', 1)");
      expect(codes(await run()), contains('ledger_orphan'));
    });

    test('a customer payment that adds to what they owe', () async {
      await sql("UPDATE ledger_entries SET amount_paise = -amount_paise WHERE entry_type = 'payment'");
      expect(codes(await run()), contains('ledger_sign'));
    });

    test('a purchase entry on a customer is a note', () async {
      final party = await db.customSelect("SELECT id FROM parties WHERE name = 'Ramesh'").getSingle();
      await sql("INSERT INTO ledger_entries (id, shop_id, created_at, updated_at, party_id, entry_type, amount_paise, ts) "
          "VALUES ('k1', '${s.shopId}', 1, 1, '${party.read<String>('id')}', 'supplier_payment', 100, 1)");
      final r = await run();
      expect(issue(r, 'ledger_party_kind').severity, IssueSeverity.warning);
    });
  });

  group('purchases', () {
    test('a total that is not subtotal + GST', () async {
      await sql('UPDATE purchases SET total_paise = total_paise + 100');
      final r = await run();
      expect(codes(r), containsAll(['purchase_total', 'purchase_ledger']));
    });

    test('lines that do not add up to the purchase', () async {
      await sql('UPDATE purchase_lines SET line_total_paise = line_total_paise + 100');
      final r = await run();
      expect(codes(r), containsAll(['purchase_lines_sum', 'purchase_line_math']));
    });

    test('a purchase missing from the supplier account', () async {
      await sql("DELETE FROM ledger_entries WHERE entry_type = 'purchase'");
      expect(issue(await run(), 'purchase_ledger').message, contains('S-501'));
    });
  });

  group('items, users and the database file', () {
    test('an item with no selling unit', () async {
      await noForeignKeys();
      final id = await db.customSelect("SELECT id FROM items WHERE name = 'LED bulb'").getSingle();
      await sql("DELETE FROM item_units WHERE item_id = '${id.read<String>('id')}'");
      expect(issue(await run(), 'item_no_unit').message, contains('LED bulb'));
    });

    test('a negative price or cost', () async {
      final id = await db.customSelect("SELECT id FROM items WHERE name = '6A switch'").getSingle();
      await sql("UPDATE item_costs SET cost_paise = -1 WHERE item_id = '${id.read<String>('id')}'");
      expect(codes(await run()), contains('item_negative_price'));
    });

    test('an item with a bad unit factor', () async {
      await sql("UPDATE items SET price_unit_factor = 0 WHERE name = '6A switch'");
      final r = await run();
      expect(codes(r), contains('item_factor'));
    });

    test('no owner, or an owner without a PIN', () async {
      await sql('UPDATE users SET pin_hash = NULL WHERE role = \'owner\'');
      final noPin = await run();
      expect(issue(noPin, 'owner_no_pin').severity, IssueSeverity.warning);
      await sql("UPDATE users SET role = 'counter' WHERE role = 'owner'");
      expect(codes(await run()), contains('owner_count'));
    });

    test('a record pointing at something that is not there', () async {
      await noForeignKeys();
      await sql("INSERT INTO invoice_payments (id, shop_id, created_at, updated_at, invoice_id, mode, amount_paise) "
          "VALUES ('p9', '${s.shopId}', 1, 1, 'missing-bill', 'cash', 100)");
      expect(codes(await run()), contains('foreign_keys'));
    });
  });

  group('credit notes (returns and cancelled bills)', () {
    late ReturnRepository returns;
    late String invoiceId, switchLine;

    setUp(() async {
      returns = ReturnRepository(s.ctx);
      // Ramesh's bill A-0002 (10 switches: Rs 50 UPI + Rs 100 credit). Take 4 back.
      final row = await db.customSelect("SELECT id FROM invoices WHERE invoice_no_text = 'A-0002'").getSingle();
      invoiceId = row.read<String>('id');
      switchLine = (await returns.returnable(invoiceId)).single.line.id;
      await returns.postReturn(PostReturnInput(
        invoiceId: invoiceId,
        deviceId: s.deviceId,
        series: s.series,
        lines: [ReturnLineInput(switchLine, '4')],
        refund: const RefundSplit(upiPaise: 2000, accountPaise: 4000),
        createdBy: s.userId,
        approvedBy: s.userId,
      ));
    });

    test('a healthy shop with a return and a cancelled bill passes', () async {
      final cashBill = await db.customSelect("SELECT id FROM invoices WHERE invoice_no_text = 'A-0003'").getSingle();
      await returns.cancelBill(cashBill.read<String>('id'),
          deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
      final r = await run();
      expect(r.issues, isEmpty, reason: r.issues.join(', '));
    });

    test('a credit note whose total no longer matches its lines', () async {
      await sql('UPDATE sales_returns SET total_paise = total_paise + 100');
      final r = await run();
      expect(codes(r), containsAll(['return_total', 'return_refund_split']));
    });

    test('a refund split that does not add up', () async {
      await sql('UPDATE sales_returns SET refund_upi_paise = refund_upi_paise + 5');
      expect(codes(await run()), contains('return_refund_split'));
    });

    test('GST that does not match the returned lines', () async {
      await sql('UPDATE sales_returns SET tax_paise = tax_paise + 1');
      expect(codes(await run()), contains('return_tax'));
    });

    test('a credit note with no lines', () async {
      await noForeignKeys();
      await sql('DELETE FROM sales_return_lines');
      expect(codes(await run()), contains('return_lines_missing'));
    });

    test('more returned than was sold', () async {
      await sql('UPDATE sales_return_lines SET qty_base = 99');
      final r = await run();
      expect(codes(r), contains('return_over'));
    });

    test('stock that did not go back when something was returned', () async {
      await sql("DELETE FROM stock_movements WHERE movement_type = 'sale_return'");
      expect(issue(await run(), 'return_stock_mismatch').message, contains('CN-A-0001'));
    });

    test('stock added for a returned line that does not exist', () async {
      final item = await db.customSelect("SELECT id FROM items WHERE name = '6A switch'").getSingle();
      final loc = await db.customSelect('SELECT id FROM locations LIMIT 1').getSingle();
      await sql("INSERT INTO stock_movements (id, shop_id, created_at, updated_at, item_id, location_id, qty_base, movement_type, ref_type, ref_id, ts) "
          "VALUES ('rg', '${s.shopId}', 1, 1, '${item.read<String>('id')}', '${loc.read<String>('id')}', 3, 'sale_return', 'sales_return', 'nothing', 1)");
      expect(codes(await run()), contains('return_stock_orphan'));
    });

    test('a refund to the account that is missing from the customer account', () async {
      await sql("DELETE FROM ledger_entries WHERE entry_type = 'return'");
      expect(codes(await run()), contains('return_ledger'));
    });

    test('an account entry for a credit note that does not exist', () async {
      final party = await db.customSelect("SELECT id FROM parties WHERE name = 'Ramesh'").getSingle();
      await sql("INSERT INTO ledger_entries (id, shop_id, created_at, updated_at, party_id, entry_type, amount_paise, ref_type, ref_id, ts) "
          "VALUES ('z', '${s.shopId}', 1, 1, '${party.read<String>('id')}', 'return', -100, 'sales_return', 'no-such-note', 1)");
      expect(codes(await run()), contains('ledger_orphan'));
    });

    test('a bill marked cancelled when only part of it was returned', () async {
      await sql("UPDATE invoices SET status = 'cancelled' WHERE invoice_no_text = 'A-0002'");
      final r = await run();
      expect(codes(r), containsAll(['cancel_not_complete', 'cancel_no_credit_note']));
    });

    test('a cancelling credit note on a bill that is not marked cancelled', () async {
      final cashBill = await db.customSelect("SELECT id FROM invoices WHERE invoice_no_text = 'A-0003'").getSingle();
      await returns.cancelBill(cashBill.read<String>('id'),
          deviceId: s.deviceId, series: s.series, createdBy: s.userId, approvedBy: s.userId);
      await sql("UPDATE invoices SET status = 'posted' WHERE invoice_no_text = 'A-0003'");
      expect(codes(await run()), contains('cancel_not_marked'));
    });
  });

  group('reporting', () {
    test('too many of the same problem are listed briefly and counted', () async {
      await sql('UPDATE invoices SET total_paise = total_paise + 1');
      final brief = await DataCheckRepository(s.ctx, maxPerCheck: 1).run();
      final totals = brief.issues.where((i) => i.code == 'invoice_total');
      expect(totals, hasLength(1));
      expect(brief.moreIssues, greaterThan(0));
      expect(brief.errorCount, brief.errors.length + brief.moreIssues);
      expect(brief.toReport('Pravin Electricals'), contains('more problems of the same kind'));
    });

    test('the report is plain text with the shop name and each problem', () async {
      await sql("UPDATE invoices SET total_paise = total_paise + 100 WHERE invoice_no_text = 'A-0001'");
      final text = (await run()).toReport('Pravin Electricals');
      expect(text, startsWith('Data check for Pravin Electricals'));
      expect(text, contains('PROBLEM: Bill A-0001'));
      expect(text, contains('problem(s)'));
    });

    test('a passing report says all numbers agree', () async {
      expect((await run()).toReport('Shop'), contains('all numbers agree'));
    });

    test('the remembered summary survives being saved and read back', () async {
      await sql("UPDATE invoices SET total_paise = total_paise + 100 WHERE invoice_no_text = 'A-0001'");
      final summary = (await run()).summary;
      final back = DataCheckSummary.fromJson(summary.toJson())!;
      expect(back.errors, summary.errors);
      expect(back.checks, 20);
      expect(back.passed, isFalse);
      expect(DataCheckSummary.fromJson('garbage'), isNull);
      expect(DataCheckSummary.fromJson(null), isNull);
    });
  });
}
