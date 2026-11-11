import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/debug/sample_data.dart';
import 'package:shop_app/core/auth/auth_providers.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/billing/bill_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  late ShopSession session;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    session = await c.read(sessionProvider.future);
    // The owner is logged in (nobody logged in means no discounts at all).
    c.read(currentUserProvider.notifier).login(
        await (db.select(db.users)..where((t) => t.role.equals('owner'))).getSingle());
    await SampleData.load(session.ctx, locationId: session.locationId);
  });

  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<ItemSearchResult> find(String q) async {
    final r = await c.read(itemRepositoryProvider).search(q);
    expect(r, isNotEmpty, reason: 'search "$q"');
    return r.first;
  }

  group('first run', () {
    test('creates shop, device A, location and owner once', () async {
      expect(session.series, 'A');
      final again = await ensureShopSession(db);
      expect(again.shopId, session.shopId);
      expect(again.deviceId, session.deviceId);
      expect(await db.select(db.shops).get(), hasLength(1));
      expect(await db.select(db.devices).get(), hasLength(1));
    });

    test('sample data loads only once', () async {
      expect(await SampleData.load(session.ctx, locationId: session.locationId), false);
    });
  });

  group('search', () {
    test('by name, brand, variant label and barcode', () async {
      final items = c.read(itemRepositoryProvider);
      expect((await items.search('wire')).length, 2);
      expect((await items.search('anchor')).single.item.name, '6A switch');
      expect((await items.search('Red')).single.variant?.label, 'Red');
      final byBarcode = await items.search('8900000000028');
      expect(byBarcode.single.variant?.label, 'Black');
      expect(await items.search('zzzz'), isEmpty);
      expect(await items.search('  '), isEmpty);
    });
  });

  group('bill flow', () {
    test('dual-unit cash bill: metres and boxes, posted in one go', () async {
      final bill = c.read(billProvider.notifier);
      expect(await bill.addItem(await find('1.5 sqmm')), isNull);
      expect(await bill.addItem(await find('6A switch')), isNull);

      // Wire defaults to metres, switch to pieces.
      var cart = c.read(billProvider).cart;
      expect(cart[0].line.unitName, 'm');
      expect(cart[1].line.unitName, 'pcs');

      bill.setQty(0, '2.5');
      final box = cart[1].units.firstWhere((u) => u.unitName == 'box');
      bill.setUnit(1, box);
      bill.setQty(1, '2');

      final t = c.read(billResultProvider).totals!;
      // wire 2.5 m x 47.50 = 118.75; 2 boxes = 20 pcs x 15 = 300.00 => 418.75 -> 419
      expect(t.subtotalPaise, 11875 + 30000);
      expect(t.totalPaise, 41900);
      expect(t.roundOffPaise, 25);

      final id = await bill.save([PaymentInput('cash', t.totalPaise)]);
      expect(c.read(billProvider).cart, isEmpty);

      final d = await c.read(invoiceRepositoryProvider).details(id);
      expect(d.invoice.invoiceNoText, 'A-0001');
      expect(d.invoice.totalPaise, 41900);
      expect(d.lines, hasLength(2));

      final stock = c.read(stockRepositoryProvider);
      final wireId = d.lines[0].itemId;
      final swId = d.lines[1].itemId;
      expect(await stock.balance(itemId: wireId), 450000 - 2500);
      expect(await stock.balance(itemId: swId), 200 - 20);
    });

    test('credit sale to a contractor uses contractor price and a ledger entry', () async {
      final customers = await c.read(partyRepositoryProvider).searchCustomers('Ramesh');
      final ramesh = customers.single;
      final bill = c.read(billProvider.notifier);

      await bill.addItem(await find('6A switch'));
      expect(c.read(billProvider).cart.single.line.ratePaise, 1500); // retail
      await bill.setCustomer(ramesh);
      expect(c.read(billProvider).cart.single.line.ratePaise, 1350); // contractor
      bill.setQty(0, '10');

      final t = c.read(billResultProvider).totals!;
      expect(t.totalPaise, 13500); // 10 x 13.50
      expect(await bill.creditWarning(t.totalPaise), isNull);

      final id = await bill.save([PaymentInput('credit', t.totalPaise)]);
      final ledger = c.read(ledgerRepositoryProvider);
      expect(await ledger.balance(ramesh.id), 13500);
      final d = await c.read(invoiceRepositoryProvider).details(id);
      expect(d.party?.name, 'Ramesh Electricals');
    });

    test('credit warning appears over the limit but does not block', () async {
      final ramesh = (await c.read(partyRepositoryProvider).searchCustomers('Ramesh')).single;
      final bill = c.read(billProvider.notifier);
      await bill.setCustomer(ramesh);
      expect(await bill.creditWarning(1000001), isNotNull);
      expect(await bill.creditWarning(1000000), isNull);
    });

    test('mixed payment: cash plus credit', () async {
      final ramesh = (await c.read(partyRepositoryProvider).searchCustomers('Ramesh')).single;
      final bill = c.read(billProvider.notifier);
      await bill.setCustomer(ramesh);
      await bill.addItem(await find('MCB'));
      bill.setQty(0, '2');
      final t = c.read(billResultProvider).totals!;
      expect(t.totalPaise, 70000);
      await bill.save([PaymentInput('cash', 20000), PaymentInput('upi', 10000), PaymentInput('credit', 40000)]);
      expect(await c.read(ledgerRepositoryProvider).balance(ramesh.id), 40000);
    });

    test('invoice numbers increase per device', () async {
      final bill = c.read(billProvider.notifier);
      for (var n = 1; n <= 3; n++) {
        await bill.addItem(await find('MCB'));
        final t = c.read(billResultProvider).totals!;
        final id = await bill.save([PaymentInput('cash', t.totalPaise)]);
        final d = await c.read(invoiceRepositoryProvider).details(id);
        expect(d.invoice.invoiceNoText, 'A-000$n');
      }
    });

    test('adding the same item again bumps the quantity', () async {
      final bill = c.read(billProvider.notifier);
      await bill.addItem(await find('MCB'));
      await bill.addItem(await find('MCB'));
      final cart = c.read(billProvider).cart;
      expect(cart, hasLength(1));
      expect(cart.single.line.qtyEntered, '2');
    });

    test('item without a price is refused', () async {
      final newId = await c.read(itemRepositoryProvider).createItem(name: 'Unpriced thing', baseUnit: 'pcs');
      expect(newId, isNotEmpty);
      final r = await c.read(itemRepositoryProvider).search('Unpriced');
      final msg = await c.read(billProvider.notifier).addItem(r.single);
      expect(msg, isNotNull);
      expect(c.read(billProvider).cart, isEmpty);
    });

    test('invalid quantity gives an error instead of totals', () async {
      final bill = c.read(billProvider.notifier);
      await bill.addItem(await find('MCB'));
      bill.setQty(0, 'abc');
      final r = c.read(billResultProvider);
      expect(r.totals, isNull);
      expect(r.error, isNotNull);
    });

    test('a discount is saved and audited', () async {
      final bill = c.read(billProvider.notifier);
      await bill.addItem(await find('MCB'));
      bill.setDiscount(0, '50');
      final t = c.read(billResultProvider).totals!;
      expect(t.discountPaise, 5000);
      expect(t.totalPaise, 30000);
      await bill.save([PaymentInput('cash', t.totalPaise)]);
      expect(await db.select(db.auditLog).get(), hasLength(1));
    });
  });
}
