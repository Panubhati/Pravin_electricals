import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shop_app/core/backup/backup_models.dart';
import 'package:shop_app/core/backup/backup_service.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/dues/ageing.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';
import 'package:shop_app/shared/format.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import '../helpers/fail_injection.dart';
import '../helpers/seed_rich_shop.dart';

/// What happens when saving goes wrong half-way: a full disk, a dying battery,
/// a crash, a wrong clock. The rule: a save is all or nothing, the data still
/// passes "Check my data", and the owner is told in plain words.
void main() {
  late Directory dir;
  late FolderDatabaseLocation location;
  late AppDatabase db;
  late ShopSession s;
  late FailInjection fail;
  late String wireId, switchId, rameshId, supplierId;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('shop_fail_');
    location = FolderDatabaseLocation(dir);
    db = AppDatabase(NativeDatabase(await location.databaseFile()));
    s = await ensureShopSession(db);
    await seedRichShop(s);
    fail = FailInjection(db);
    final items = ItemRepository(s.ctx);
    wireId = (await items.search('Copper wire')).first.item.id;
    switchId = (await items.search('6A switch')).first.item.id;
    rameshId = (await PartyRepository(s.ctx).searchCustomers('Ramesh')).single.id;
    supplierId = (await PartyRepository(s.ctx).searchSuppliers('Polycab')).single.id;
  });

  tearDown(() async {
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  /// A two-line bill with a discount, paid part cash and part credit, so a save
  /// touches every table a bill can touch.
  Future<PostInvoiceInput> bigBill({DateTime? date}) async {
    final items = ItemRepository(s.ctx);
    final cart = <CartLine>[];
    for (final (id, name, qty, discount) in [(wireId, 'Copper wire 1.5', '2.5', 0), (switchId, '6A switch', '10', 200)]) {
      final units = await items.unitsOf(id);
      final item = await items.getItem(id);
      final u = units.firstWhere((x) => x.factorToBase == item.priceUnitFactor, orElse: () => units.first);
      cart.add(CartLine(
        itemId: id,
        itemName: name,
        unitName: u.unitName,
        factorToBase: u.factorToBase,
        qtyEntered: qty,
        ratePaise: await items.priceFor(itemId: id, tier: 'retail') ?? 1000,
        priceUnitFactor: item.priceUnitFactor,
        gstRateBp: item.gstRateBp,
        discountPaise: discount,
      ));
    }
    final totals = BillCalculator.calculate(cart, interState: false);
    final number = await InvoiceRepository(s.ctx).nextNumber(s.deviceId, s.series);
    return totals.toInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: number,
      date: date ?? DateTime.now(),
      locationId: s.locationId,
      partyId: rameshId,
      createdBy: s.userId,
      payments: [PaymentInput('cash', 5000), PaymentInput('credit', totals.totalPaise - 5000)],
    );
  }

  PostPurchaseInput purchase(String no) => PostPurchaseInput(
        supplierId: supplierId,
        supplierInvoiceNo: no,
        supplierInvoiceDate: DateTime.now(),
        locationId: s.locationId,
        lines: [
          PurchaseLineInput(
              itemId: wireId, unitName: 'm', qtyEntered: '50', qtyBase: 50000, ratePaise: 3100, priceUnitFactor: 1000, gstRateBp: 1800),
          PurchaseLineInput(
              itemId: switchId, unitName: 'pcs', qtyEntered: '40', qtyBase: 40, ratePaise: 950, priceUnitFactor: 1, gstRateBp: 1800),
        ],
      );

  Future<void> expectHealthy() async {
    final r = await DataCheckRepository(s.ctx).run();
    expect(r.errors, isEmpty, reason: r.errors.join('\n'));
  }

  group('a bill that fails at every step leaves nothing behind', () {
    // The tables a bill writes once (one invoice, one credit entry, one discount
    // audit row) can only fail at the first write; the others also at the second.
    const writesOnce = {'invoices', 'ledger_entries', 'audit_log'};
    for (final table in ['invoices', 'invoice_lines', 'invoice_payments', 'stock_movements', 'ledger_entries', 'audit_log', 'outbox']) {
      for (final nth in writesOnce.contains(table) ? [1] : [1, 2]) {
        test('refused at write #$nth to $table', () async {
          final input = await bigBill();
          final before = await fail.snapshot();
          final trigger = await fail.failInsert(table, nth: nth);

          await expectLater(InvoiceRepository(s.ctx).postInvoice(input), throwsA(anything));

          expect(await fail.snapshot(), before, reason: 'something from the failed bill was left behind');
          await fail.remove(trigger);
          await expectHealthy();

          // The same bill saves fine once the problem is gone, with the same number.
          final id = await InvoiceRepository(s.ctx).postInvoice(input);
          expect(id, isNotEmpty);
          await expectHealthy();
        });
      }
    }
  });

  group('a purchase that fails at every step leaves nothing behind', () {
    for (final table in ['purchases', 'purchase_lines', 'stock_movements', 'item_costs', 'ledger_entries', 'outbox']) {
      test('refused at the first write to $table', () async {
        final before = await fail.snapshot();
        final trigger = await fail.failInsert(table);
        await expectLater(PurchaseRepository(s.ctx).postPurchase(purchase('F-1')), throwsA(anything));
        expect(await fail.snapshot(), before);
        await fail.remove(trigger);
        await expectHealthy();
        await PurchaseRepository(s.ctx).postPurchase(purchase('F-1')); // not blocked as a duplicate
        await expectHealthy();
      });
    }
  });

  group('a payment that fails', () {
    for (final table in ['ledger_entries', 'outbox']) {
      test('refused at the first write to $table: the balance does not move', () async {
        final ledger = LedgerRepository(s.ctx);
        final balance = await ledger.balance(rameshId);
        final before = await fail.snapshot();
        final trigger = await fail.failInsert(table);
        await expectLater(ledger.recordCustomerPayment(rameshId, 1000, mode: 'cash'), throwsA(anything));
        expect(await ledger.balance(rameshId), balance);
        expect(await fail.snapshot(), before);
        await fail.remove(trigger);
        await ledger.recordCustomerPayment(rameshId, 1000, mode: 'cash');
        expect(await ledger.balance(rameshId), balance - 1000);
        await expectHealthy();
      });
    }
  });

  group('the app is killed in the middle of a save', () {
    test('a half-written bill in a hot journal is rolled back when the app reopens', () async {
      final live = await location.databaseFile();
      await db.close(); // start from a quiet file
      final before = await _fingerprintOf(live);

      // A second connection starts a big write and is left mid-transaction. With
      // a tiny cache SQLite has already written pages to the file and holds the
      // undo journal, exactly the state a killed app leaves behind.
      final raw = sq.sqlite3.open(live.path);
      raw.execute('PRAGMA cache_size = 2');
      raw.execute('BEGIN');
      final shop = raw.select('SELECT id FROM shops LIMIT 1').first['id'] as String;
      final item = raw.select('SELECT id FROM items LIMIT 1').first['id'] as String;
      final loc = raw.select('SELECT id FROM locations LIMIT 1').first['id'] as String;
      for (var i = 0; i < 3000; i++) {
        raw.execute(
            "INSERT INTO stock_movements (id, shop_id, created_at, updated_at, item_id, location_id, qty_base, movement_type, ts) "
            "VALUES ('half$i', '$shop', 1, 1, '$item', '$loc', -1, 'sale', 1)");
      }
      final journal = File('${live.path}-journal');
      expect(journal.existsSync(), isTrue, reason: 'the test needs a journal to look like a crash');

      // "Power off": copy exactly what is on disk right now, then drop the connection.
      final crashed = Directory.systemTemp.createTempSync('shop_crashed_');
      addTearDown(() {
        try {
          crashed.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold a file; the OS cleans temp.
        }
      });
      final copy = File(p.join(crashed.path, 'shop.sqlite'));
      live.copySync(copy.path);
      journal.copySync('${copy.path}-journal');
      raw.dispose();

      // Reopening the crashed copy rolls the half-written bill back.
      final reopened = AppDatabase(NativeDatabase(copy));
      addTearDown(reopened.close);
      final session = await ensureShopSession(reopened);
      expect(await liveFingerprint(reopened), before);
      final r = await DataCheckRepository(session.ctx).run();
      expect(r.errors, isEmpty, reason: r.errors.join('\n'));
      final half = await reopened.customSelect("SELECT COUNT(*) AS n FROM stock_movements WHERE id LIKE 'half%'").getSingle();
      expect(half.data['n'], 0);
    });
  });

  group('the phone runs out of storage', () {
    test('saves stop with a clear message, every saved bill is whole, nothing is half-saved', () async {
      // Limit the file to a few pages above what it has now (a real "disk full").
      final pages = (await db.customSelect('PRAGMA page_count').getSingle()).data.values.first as int;
      await db.customStatement('PRAGMA max_page_count = ${pages + 3}');

      Object? failure;
      var saved = 0;
      for (var i = 0; i < 200 && failure == null; i++) {
        try {
          await InvoiceRepository(s.ctx).postInvoice(await bigBill());
          saved++;
        } catch (e) {
          failure = e;
        }
      }
      expect(failure, isNotNull, reason: 'the disk limit was never reached');
      expect(errorMessage(failure!), startsWith('The phone is out of storage space'));
      expect(errorMessage(failure), contains('Nothing was saved'));

      // Whatever was saved before the disk filled is complete and consistent.
      await db.customStatement('PRAGMA max_page_count = 1073741823');
      await expectHealthy();
      final bills = await db.customSelect('SELECT COUNT(*) AS n FROM invoices').getSingle();
      expect(bills.data['n'], 3 + saved);

      // After space is freed the shop carries on with the next number.
      final id = await InvoiceRepository(s.ctx).postInvoice(await bigBill());
      expect(id, isNotEmpty);
      await expectHealthy();
    });

    test('a backup that cannot be written fails cleanly and leaves no half file', () async {
      // Something that is not a file sits where the backup would be written.
      final work = await location.workDirectory();
      final name = backupFileName(DateTime(2026, 11, 12, 21, 30));
      Directory(p.join(work.path, name)).createSync();
      await expectLater(
        BackupService(db, location, clock: () => DateTime(2026, 11, 12, 21, 30)).createBackup(),
        throwsA(isA<BackupException>()),
      );
      expect(work.listSync().whereType<File>().where((f) => f.path.contains('PravinElectricals_backup_')), isEmpty);
      await expectHealthy(); // the live shop is untouched
    });

    test('plain messages for the other storage errors', () {
      expect(errorMessage(StateError('disk I/O error')), contains('could not write to its storage'));
      expect(errorMessage(StateError('database is locked')), contains('busy'));
      expect(errorMessage(StateError('something odd')), startsWith('Something went wrong'));
    });
  });

  group('the phone\'s clock is wrong', () {
    test('clock set back: bills still get the next numbers, with no repeats', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 3));
      final first = await InvoiceRepository(s.ctx).postInvoice(await bigBill(date: yesterday));
      final second = await InvoiceRepository(s.ctx).postInvoice(await bigBill());
      final numbers = await db.customSelect('SELECT number FROM invoices ORDER BY number').get();
      final list = [for (final r in numbers) r.data['number'] as int];
      expect(list, [1, 2, 3, 4, 5]); // 3 from the seed, then the two new ones
      expect(list.toSet(), hasLength(list.length));
      expect(first, isNot(second));
      await expectHealthy();
    });

    test('a bill dated in the future is only a note, and ageing does not choke on it', () async {
      final future = DateTime.now().add(const Duration(days: 40));
      await InvoiceRepository(s.ctx).postInvoice(await bigBill(date: future));
      final r = await DataCheckRepository(s.ctx).run();
      expect(r.errors, isEmpty);
      expect(r.warnings.map((i) => i.code), contains('invoice_future_date'));

      // Debts dated in the future count as new (0 to 30 days) rather than breaking.
      final buckets = AgeingCalculator.age(
        [AgeingEntry(future, 10000)],
        DateTime.now(),
      );
      expect(buckets.days0to30, 10000);
      expect(buckets.overdue, 0);
    });

    test('a customer payment dated before the bill it pays still balances', () async {
      final ledger = LedgerRepository(s.ctx);
      final balance = await ledger.balance(rameshId);
      await ledger.recordCustomerPayment(rameshId, 500, mode: 'cash', ts: DateTime.now().subtract(const Duration(days: 90)));
      expect(await ledger.balance(rameshId), balance - 500);
      await expectHealthy();
    });
  });
}

Future<dynamic> _fingerprintOf(File file) async {
  final db = AppDatabase(NativeDatabase(file));
  try {
    return await liveFingerprint(db);
  } finally {
    await db.close();
  }
}
