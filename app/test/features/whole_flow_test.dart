import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/import/item_import.dart';
import 'package:shop_app/core/import/party_import.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/billing/bill_controller.dart';

/// The "done when" scenario for A3, end to end and without screens: import the
/// shop's items and balances, sell (cash and credit), buy from a supplier, take
/// a payment, then check stock, dues and ageing against hand calculations and
/// against the data invariants from plan section 12 (A7).
void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    await c.read(sessionProvider.future);
  });

  tearDown(() async {
    c.dispose();
    await db.close();
  });

  test('import, sell, purchase, pay: stock, dues and ageing are all correct', () async {
    final session = await c.read(sessionProvider.future);
    final items = c.read(itemRepositoryProvider);
    final parties = c.read(partyRepositoryProvider);
    final stock = c.read(stockRepositoryProvider);
    final ledger = c.read(ledgerRepositoryProvider);

    // 1. Import items (with opening stock) and parties (with opening balances).
    final itemPreview = await c.read(itemImportServiceProvider).preview(ItemImportService.templateCsv);
    expect(itemPreview.errors, isEmpty);
    await c.read(itemImportServiceProvider).apply(itemPreview, locationId: session.locationId);
    final partyPreview = await c.read(partyImportServiceProvider).preview(PartyImportService.templateCsv);
    expect(partyPreview.errors, isEmpty);
    await c.read(partyImportServiceProvider).apply(partyPreview);

    final wire = (await items.search('1.5 sqmm')).single.item;
    final sw = (await items.search('6A switch')).single.item;
    final ramesh = (await parties.searchCustomers('Ramesh')).single;
    final supplier = (await parties.searchSuppliers('Sample')).single;

    // Opening position: imported opening stock and balances are correct.
    expect(await stock.balance(itemId: wire.id), 450000); // 450 m
    expect(await stock.balance(itemId: sw.id), 200);
    expect(await ledger.balance(ramesh.id), 250000); // Ramesh owes Rs 2,500
    expect(await ledger.balance(supplier.id), -1500000); // the shop owes Rs 15,000

    // 2a. Cash sale to a walk-in: 2.5 m of wire at Rs 47.50 = 118.75 -> Rs 119.
    final bill = c.read(billProvider.notifier);
    await bill.addItem((await items.search('1.5 sqmm')).single);
    bill.setQty(0, '2.5');
    var totals = c.read(billResultProvider).totals!;
    expect(totals.totalPaise, 11900);
    await bill.save([PaymentInput('cash', 11900)]);

    // 2b. Credit sale to Ramesh (contractor price Rs 13.50): 10 switches = Rs 135.
    await bill.addItem((await items.search('6A switch')).single);
    await bill.setCustomer(ramesh);
    bill.setQty(0, '10');
    totals = c.read(billResultProvider).totals!;
    expect(totals.totalPaise, 13500);
    expect(await bill.creditWarning(totals.totalPaise), isNull); // within the Rs 10,000 limit
    await bill.save([PaymentInput('credit', 13500)]);

    // 3. Purchase: 2 rolls of wire at Rs 30/m + 18% GST = Rs 6,372, on credit.
    await c.read(purchaseRepositoryProvider).postPurchase(PostPurchaseInput(
          supplierId: supplier.id,
          supplierInvoiceNo: 'S-501',
          supplierInvoiceDate: DateTime.now(),
          locationId: session.locationId,
          lines: [
            PurchaseLineInput(
              itemId: wire.id,
              unitName: 'roll',
              qtyEntered: '2',
              qtyBase: 180000,
              ratePaise: 3000,
              priceUnitFactor: 1000,
              gstRateBp: 1800,
            ),
          ],
        ));

    // 4. Ramesh pays Rs 100 by UPI; the shop pays the supplier Rs 1,000.
    await ledger.recordCustomerPayment(ramesh.id, 10000, mode: 'upi');
    await ledger.recordSupplierPayment(supplier.id, 100000, mode: 'bank');

    // ---- Stock: opening 450 m - 2.5 m sold + 180 m bought = 627.5 m; 200 - 10 = 190 switches.
    expect(await stock.balance(itemId: wire.id), 627500);
    expect(await stock.balance(itemId: sw.id), 190);

    // ---- Dues: Ramesh 2,500 + 135 - 100 = 2,535; the shop owes 15,000 + 6,372 - 1,000 = 20,372.
    expect(await ledger.balance(ramesh.id), 253500);
    expect(await ledger.balance(supplier.id), -2037200);

    final dues = c.read(duesRepositoryProvider);
    final receivables = await dues.receivables();
    expect(receivables.single.party.id, ramesh.id);
    expect(receivables.single.buckets.totalDue, 253500);
    expect(receivables.single.buckets.days0to30, 253500); // everything is from today
    expect(receivables.single.buckets.overdue, 0);
    final payables = await dues.payables();
    expect(payables.single.buckets.totalDue, 2037200);

    // The same dues, 45 days from now: the whole of it is 31-60 days old,
    // except what the payment settled (the payment clears the oldest first).
    final later = DateTime.now().add(const Duration(days: 45));
    final aged = (await dues.receivables(asOf: later)).single.buckets;
    expect(aged.days31to60, 253500);
    expect(aged.days0to30, 0);

    // Cost price followed the purchase (same Rs 30 as imported, so no extra row).
    expect(await items.latestCost(wire.id), 3000);

    // ---- Invariants (plan section 12, A7) -------------------------------------
    // Stock balance per item equals the sum of its movements.
    final movements = await db.select(db.stockMovements).get();
    for (final item in [wire, sw]) {
      final sum = movements.where((m) => m.itemId == item.id).fold<int>(0, (a, m) => a + m.qtyBase);
      expect(await stock.balance(itemId: item.id), sum);
    }
    // Each party balance equals the sum of its ledger entries.
    final entries = await db.select(db.ledgerEntries).get();
    for (final p in [ramesh, supplier]) {
      final sum = entries.where((e) => e.partyId == p.id).fold<int>(0, (a, e) => a + e.amountPaise);
      expect(await ledger.balance(p.id), sum);
    }
    // Each invoice total equals its lines, minus discount, plus round-off.
    final invoices = await db.select(db.invoices).get();
    final lines = await db.select(db.invoiceLines).get();
    expect(invoices, hasLength(2));
    for (final inv in invoices) {
      final sub = lines.where((l) => l.invoiceId == inv.id).fold<int>(0, (a, l) => a + l.lineTotalPaise);
      expect(inv.totalPaise, sub + inv.roundOffPaise);
    }
    // No duplicate invoice numbers in a device series.
    expect({for (final i in invoices) '${i.deviceId}/${i.series}/${i.number}'}, hasLength(invoices.length));
    // Every record reached the outbox for the future sync.
    final outbox = await db.select(db.outbox).get();
    expect(outbox.where((o) => o.entity == 'invoices'), hasLength(2));
    expect(outbox.where((o) => o.entity == 'purchases'), hasLength(1));
    expect(outbox.where((o) => o.entity == 'ledger_entries'), isNotEmpty);
  });

  test('stock and dues stay consistent when a save fails part-way', () async {
    final session = await c.read(sessionProvider.future);
    await c.read(itemImportServiceProvider).apply(
        await c.read(itemImportServiceProvider).preview(ItemImportService.templateCsv),
        locationId: session.locationId);
    final stock = c.read(stockRepositoryProvider);
    final items = c.read(itemRepositoryProvider);
    final wire = (await items.search('1.5 sqmm')).single.item;
    final before = await stock.balance(itemId: wire.id);
    final movements = (await db.select(db.stockMovements).get()).length;

    // A purchase from a supplier that does not exist fails inside the transaction.
    await expectLater(
      c.read(purchaseRepositoryProvider).postPurchase(PostPurchaseInput(
            supplierId: 'ghost',
            supplierInvoiceNo: 'X-1',
            supplierInvoiceDate: DateTime.now(),
            locationId: session.locationId,
            lines: [
              PurchaseLineInput(
                itemId: wire.id,
                unitName: 'roll',
                qtyEntered: '1',
                qtyBase: 90000,
                ratePaise: 3000,
                priceUnitFactor: 1000,
              ),
            ],
          )),
      throwsA(anything),
    );
    expect(await stock.balance(itemId: wire.id), before);
    expect((await db.select(db.stockMovements).get()).length, movements);
    expect(await db.select(db.purchases).get(), isEmpty);
  });
}
