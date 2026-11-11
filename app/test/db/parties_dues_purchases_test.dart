import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/dues_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

void main() {
  late AppDatabase db;
  late RepoContext ctx;
  late PartyRepository parties;
  late LedgerRepository ledger;
  late DuesRepository dues;
  late PurchaseRepository purchases;
  late ItemRepository items;
  late String loc;

  final today = DateTime(2026, 11, 12, 10);
  DateTime ago(int d) => today.subtract(Duration(days: d));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ctx = RepoContext(db, shopId: 'shop1', clock: () => today);
    parties = PartyRepository(ctx);
    ledger = LedgerRepository(ctx);
    dues = DuesRepository(ctx);
    purchases = PurchaseRepository(ctx);
    items = ItemRepository(ctx);
    final setup = SetupRepository(ctx);
    await setup.createShop(name: 'Test');
    loc = await setup.createLocation('shop');
  });

  tearDown(() => db.close());

  group('ledger', () {
    test('statement lists entries oldest first with a running balance', () async {
      final p = await parties.createParty(kind: 'customer', name: 'Ramesh');
      await ledger.addEntry(partyId: p, entryType: 'invoice', amountPaise: 20000, ts: ago(10));
      await ledger.addOpeningBalance(p, 5000, ts: ago(30));
      await ledger.recordCustomerPayment(p, 8000, mode: 'upi', ts: ago(2));
      final s = await ledger.statement(p);
      expect(s.map((l) => l.entry.entryType), ['opening', 'invoice', 'payment']);
      expect(s.map((l) => l.runningBalancePaise), [5000, 25000, 17000]);
      expect(s.last.runningBalancePaise, await ledger.balance(p));
    });

    test('payments store their mode; bad modes and amounts are rejected', () async {
      final c = await parties.createParty(kind: 'customer', name: 'C');
      final s = await parties.createParty(kind: 'supplier', name: 'S');
      await ledger.recordCustomerPayment(c, 1000, mode: 'upi');
      await ledger.recordCustomerPayment(c, 500);
      await ledger.recordSupplierPayment(s, 700, mode: 'bank');
      final rows = await db.select(db.ledgerEntries).get();
      expect(rows.where((r) => r.paymentMode == 'upi').single.amountPaise, -1000);
      expect(rows.where((r) => r.paymentMode == 'cash').single.amountPaise, -500);
      final sp = rows.singleWhere((r) => r.entryType == 'supplier_payment');
      expect(sp.amountPaise, 700);
      expect(sp.paymentMode, 'bank');
      expect(() => ledger.recordCustomerPayment(c, 100, mode: 'cheque'), throwsA(isA<DomainException>()));
      expect(() => ledger.recordCustomerPayment(c, 0), throwsA(isA<DomainException>()));
      expect(() => ledger.recordSupplierPayment(s, -5), throwsA(isA<DomainException>()));
    });

    test('balancesByParty matches each party balance', () async {
      final a = await parties.createParty(kind: 'customer', name: 'A');
      final b = await parties.createParty(kind: 'customer', name: 'B');
      await ledger.addEntry(partyId: a, entryType: 'invoice', amountPaise: 1000);
      await ledger.addEntry(partyId: a, entryType: 'invoice', amountPaise: 2000);
      await ledger.addEntry(partyId: b, entryType: 'invoice', amountPaise: 500);
      await ledger.recordCustomerPayment(b, 800);
      final all = await ledger.balancesByParty();
      expect(all, {a: 3000, b: -300});
      expect(all[a], await ledger.balance(a));
      expect(all[b], await ledger.balance(b));
    });
  });

  group('dues and ageing from the ledger', () {
    test('receivables: FIFO ageing, sorted worst first, balances match the ledger', () async {
      final ramesh = await parties.createParty(kind: 'customer', name: 'Ramesh');
      final sunita = await parties.createParty(kind: 'customer', name: 'Sunita');
      final paidUp = await parties.createParty(kind: 'customer', name: 'Paid up');
      final advance = await parties.createParty(kind: 'customer', name: 'Advance');

      await ledger.addOpeningBalance(ramesh, 50000, ts: ago(100));
      await ledger.addEntry(partyId: ramesh, entryType: 'invoice', amountPaise: 20000, ts: ago(40));
      await ledger.recordCustomerPayment(ramesh, 30000, ts: ago(5));
      await ledger.addEntry(partyId: sunita, entryType: 'invoice', amountPaise: 1000, ts: ago(2));
      await ledger.addEntry(partyId: paidUp, entryType: 'invoice', amountPaise: 900, ts: ago(9));
      await ledger.recordCustomerPayment(paidUp, 900, ts: ago(8));
      await ledger.recordCustomerPayment(advance, 4000, ts: ago(3));

      final list = await dues.receivables(asOf: today);
      expect(list.map((d) => d.party.name), ['Ramesh', 'Sunita']);

      final r = list.first;
      expect(r.buckets.over90, 20000); // 50000 opening less 30000 payment
      expect(r.buckets.days31to60, 20000);
      expect(r.buckets.totalDue, 40000);
      expect(r.balancePaise, 40000);
      expect(r.balancePaise, await ledger.balance(ramesh));

      expect(list.last.buckets.days0to30, 1000);

      final total = DuesRepository.total(list);
      expect(total.totalDue, 41000);
      expect(total.over90, 20000);
    });

    test('payables: what the shop owes suppliers, aged the same way', () async {
      final s = await parties.createParty(kind: 'supplier', name: 'Havells dealer');
      await ledger.addEntry(partyId: s, entryType: 'purchase', amountPaise: -80000, ts: ago(70));
      await ledger.recordSupplierPayment(s, 30000, ts: ago(10));
      final list = await dues.payables(asOf: today);
      expect(list, hasLength(1));
      expect(list.single.buckets.days61to90, 50000);
      expect(list.single.balancePaise, -50000);
      // Suppliers never show up as receivables.
      expect(await dues.receivables(asOf: today), isEmpty);
    });

    test('ageingFor one party agrees with the list', () async {
      final p = await parties.createParty(kind: 'customer', name: 'X');
      await ledger.addEntry(partyId: p, entryType: 'invoice', amountPaise: 7000, ts: ago(61));
      final b = await dues.ageingFor(p, payable: false, asOf: today);
      expect(b.days61to90, 7000);
      expect(b.totalDue, (await dues.receivables(asOf: today)).single.buckets.totalDue);
    });
  });

  group('parties', () {
    test('updateParty saves changes and audits before and after', () async {
      final p = await parties.createParty(kind: 'customer', name: 'Ramesh', phone: '1');
      await parties.updateParty(
        partyId: p,
        kind: 'both',
        name: 'Ramesh Electricals',
        tier: 'contractor',
        creditLimitPaise: 500000,
        phone: '9800000001',
        gstin: '27AAAAA0000A1Z5',
        stateCode: '27',
        userId: 'u1',
      );
      final saved = await parties.getParty(p);
      expect(saved.name, 'Ramesh Electricals');
      expect(saved.tier, 'contractor');
      expect(saved.creditLimitPaise, 500000);
      expect(saved.kind, 'both');
      final audit = (await db.select(db.auditLog).get()).single;
      expect(audit.entity, 'party');
      expect(audit.beforeJson, contains('Ramesh'));
      expect(audit.afterJson, contains('Electricals'));
    });

    test('validation: name, kind, tier and credit limit', () async {
      expect(() => parties.createParty(kind: 'customer', name: ' '), throwsA(isA<DomainException>()));
      expect(() => parties.createParty(kind: 'alien', name: 'x'), throwsA(isA<DomainException>()));
      expect(() => parties.createParty(kind: 'customer', name: 'x', tier: 'vip'), throwsA(isA<DomainException>()));
      expect(() => parties.createParty(kind: 'customer', name: 'x', creditLimitPaise: -1),
          throwsA(isA<DomainException>()));
    });

    test('list filters by kind (both appears in each) and by name or phone', () async {
      await parties.createParty(kind: 'customer', name: 'Cust', phone: '111');
      await parties.createParty(kind: 'supplier', name: 'Supp', phone: '222');
      await parties.createParty(kind: 'both', name: 'Both', phone: '333');
      expect((await parties.list(kind: 'customer')).map((p) => p.name), ['Both', 'Cust']);
      expect((await parties.list(kind: 'supplier')).map((p) => p.name), ['Both', 'Supp']);
      expect(await parties.list(), hasLength(3));
      expect((await parties.list(query: '222')).single.name, 'Supp');
      expect((await parties.searchSuppliers('upp')).single.name, 'Supp');
      expect((await parties.searchCustomers('ust')).single.name, 'Cust');
    });
  });

  group('purchases', () {
    late String supplier;
    late String wire;
    late String sw;

    setUp(() async {
      supplier = await parties.createParty(kind: 'supplier', name: 'Supplier');
      wire = await items.createItem(
        name: 'Wire',
        baseUnit: 'mm',
        priceUnitFactor: 1000,
        gstRateBp: 1800,
        units: const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)],
      );
      sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800);
    });

    PostPurchaseInput bill(String no, {int wireRate = 3000, DateTime? date, String? supplierId}) =>
        PostPurchaseInput(
          supplierId: supplierId ?? supplier,
          supplierInvoiceNo: no,
          supplierInvoiceDate: date ?? today,
          locationId: loc,
          lines: [
            PurchaseLineInput(
              itemId: wire,
              unitName: 'roll',
              qtyEntered: '2',
              qtyBase: 180000,
              ratePaise: wireRate,
              priceUnitFactor: 1000,
              gstRateBp: 1800,
            ),
            const PurchaseLineInput(
              itemId: 'placeholder',
              unitName: 'pcs',
              qtyEntered: '10',
              qtyBase: 10,
              ratePaise: 900,
              priceUnitFactor: 1,
              gstRateBp: 1800,
            ),
          ].map((l) => l.itemId == 'placeholder'
              ? PurchaseLineInput(
                  itemId: sw,
                  unitName: l.unitName,
                  qtyEntered: l.qtyEntered,
                  qtyBase: l.qtyBase,
                  ratePaise: l.ratePaise,
                  priceUnitFactor: l.priceUnitFactor,
                  gstRateBp: l.gstRateBp,
                )
              : l).toList(),
        );

    test('a purchase sets the item cost; the same price adds no row, a new price does', () async {
      await purchases.postPurchase(bill('B1'));
      expect(await items.latestCost(wire), 3000);
      expect(await items.latestCost(sw), 900);
      expect(await db.select(db.itemCosts).get(), hasLength(2));

      await purchases.postPurchase(bill('B2')); // same prices
      expect(await db.select(db.itemCosts).get(), hasLength(2));

      await purchases.postPurchase(bill('B3', wireRate: 3200, date: today.add(const Duration(days: 1))));
      expect(await items.latestCost(wire), 3200);
      expect(await db.select(db.itemCosts).get(), hasLength(3)); // history kept
    });

    test('list is newest first and can filter by supplier and date', () async {
      final other = await parties.createParty(kind: 'supplier', name: 'Other');
      await purchases.postPurchase(bill('B1', date: ago(10)));
      await purchases.postPurchase(bill('B2', date: ago(1)));
      await purchases.postPurchase(bill('C1', date: ago(5), supplierId: other));

      final all = await purchases.list();
      expect(all.map((e) => e.purchase.supplierInvoiceNo), ['B2', 'C1', 'B1']);
      expect(all.first.supplierName, 'Supplier');
      expect((await purchases.list(supplierId: other)).single.purchase.supplierInvoiceNo, 'C1');
      expect((await purchases.list(from: ago(6))).map((e) => e.purchase.supplierInvoiceNo), ['B2', 'C1']);
      expect((await purchases.list(to: ago(6))).single.purchase.supplierInvoiceNo, 'B1');
    });

    test('details has lines, item names and the supplier; totals are hand-calculated', () async {
      final id = await purchases.postPurchase(bill('B1'));
      final d = await purchases.details(id);
      expect(d.supplier.name, 'Supplier');
      expect(d.lines, hasLength(2));
      expect(d.itemNames.values.toSet(), {'Wire', 'Switch'});
      // wire: 180 m x Rs 30 = 5400.00; switches: 10 x Rs 9 = 90.00; subtotal 5490.00
      expect(d.purchase.subtotalPaise, 549000);
      // GST 18% per line: 972.00 + 16.20 = 988.20
      expect(d.purchase.taxPaise, 98820);
      expect(d.purchase.totalPaise, 647820);
      expect(() => purchases.details('nope'), throwsA(isA<DomainException>()));
    });

    test('a purchase raises stock, owes the supplier, and a payment reduces it', () async {
      await purchases.postPurchase(bill('B1'));
      final stock = StockRepository(ctx);
      expect(await stock.balance(itemId: wire), 180000);
      expect(await stock.balance(itemId: sw), 10);
      expect(await ledger.balance(supplier), -647820);

      await ledger.recordSupplierPayment(supplier, 300000, mode: 'bank');
      expect(await ledger.balance(supplier), -347820);
      final p = await dues.payables(asOf: today);
      expect(p.single.buckets.totalDue, 347820);
    });

    test('a duplicate supplier invoice is rejected and changes nothing', () async {
      await purchases.postPurchase(bill('B1'));
      final costs = (await db.select(db.itemCosts).get()).length;
      await expectLater(purchases.postPurchase(bill('B1', wireRate: 9999)), throwsA(isA<DuplicatePurchaseException>()));
      expect(await db.select(db.purchases).get(), hasLength(1));
      expect(await db.select(db.itemCosts).get(), hasLength(costs));
      expect(await items.latestCost(wire), 3000);
    });
  });
}
