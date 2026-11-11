import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/money.dart';
import 'package:shop_app/core/units.dart';

void main() {
  late AppDatabase db;
  late RepoContext ctx;
  late ItemRepository items;
  late PartyRepository parties;
  late LedgerRepository ledger;
  late StockRepository stock;
  late InvoiceRepository invoices;
  late PurchaseRepository purchases;

  late String deviceId;
  late String shopLoc;
  late String cableId; // base unit mm, priced per metre
  late String switchId; // base unit pcs
  late String supplierId;
  late String customerId;

  final day = DateTime(2026, 11, 11, 10);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ctx = RepoContext(db, shopId: 'shop1', clock: () => day);
    items = ItemRepository(ctx);
    parties = PartyRepository(ctx);
    ledger = LedgerRepository(ctx);
    stock = StockRepository(ctx);
    invoices = InvoiceRepository(ctx);
    purchases = PurchaseRepository(ctx);

    final setup = SetupRepository(ctx);
    await setup.createShop(name: 'Pravin Electricals');
    deviceId = await setup.createDevice(label: 'Counter', invoiceSeriesPrefix: 'A');
    shopLoc = await setup.createLocation('shop');

    cableId = await items.createItem(
      name: '1.5 sqmm wire',
      baseUnit: 'mm',
      priceUnitFactor: 1000,
      gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)],
    );
    switchId = await items.createItem(
      name: '6A switch',
      baseUnit: 'pcs',
      gstRateBp: 1800,
      units: const [ItemUnitInput('box', 10)],
    );
    supplierId = await parties.createParty(kind: 'supplier', name: 'Havells dealer');
    customerId = await parties.createParty(kind: 'customer', name: 'Ramesh');
  });

  tearDown(() => db.close());

  Future<int> outboxCount([String? entity]) async {
    final q = db.select(db.outbox);
    if (entity != null) q.where((t) => t.entity.equals(entity));
    return (await q.get()).length;
  }

  Future<int> rows(TableInfo table) async =>
      (await db.select(table).get()).length;

  const factors = {'mm': 1, 'm': 1000, 'roll': 90000, 'pcs': 1, 'box': 10};

  InvoiceLineInput lineFor(
    String itemId,
    String unit,
    String qty, {
    required int rate,
    required int priceUnitFactor,
    int gst = 1800,
    int discount = 0,
  }) {
    final qtyBase = Units.toBaseUnits(qty, factors[unit]!);
    final amount = Units.lineAmountPaise(
        qtyBase: qtyBase, ratePaise: rate, priceUnitFactor: priceUnitFactor);
    final tax = Money.taxPaise(amount - discount, gst);
    return InvoiceLineInput(
      itemId: itemId,
      unitName: unit,
      qtyEntered: qty,
      qtyBase: qtyBase,
      ratePaise: rate,
      priceUnitFactor: priceUnitFactor,
      discountPaise: discount,
      gstRateBp: gst,
      taxPaise: tax,
      lineTotalPaise: amount - discount + tax,
    );
  }

  PostInvoiceInput invoiceFrom(
    List<InvoiceLineInput> lines, {
    int number = 1,
    int roundOff = 0,
    String? partyId,
    String? locationId,
    List<PaymentInput> Function(int total)? payments,
  }) {
    var subtotal = 0, discount = 0, tax = 0;
    for (final l in lines) {
      subtotal += Units.lineAmountPaise(
          qtyBase: l.qtyBase,
          ratePaise: l.ratePaise,
          priceUnitFactor: l.priceUnitFactor);
      discount += l.discountPaise;
      tax += l.taxPaise;
    }
    final total = subtotal - discount + tax + roundOff;
    return PostInvoiceInput(
      deviceId: deviceId,
      series: 'A',
      number: number,
      date: day,
      locationId: locationId ?? shopLoc,
      partyId: partyId,
      subtotalPaise: subtotal,
      discountPaise: discount,
      taxPaise: tax,
      roundOffPaise: roundOff,
      totalPaise: total,
      lines: lines,
      payments: (payments ?? (t) => [PaymentInput('cash', t)])(total),
    );
  }

  PostPurchaseInput purchaseOf(String invoiceNo, {String? locationId}) =>
      PostPurchaseInput(
        supplierId: supplierId,
        supplierInvoiceNo: invoiceNo,
        supplierInvoiceDate: day,
        locationId: locationId ?? shopLoc,
        lines: const [
          PurchaseLineInput(
            itemId: 'placeholder',
            unitName: 'roll',
            qtyEntered: '2',
            qtyBase: 180000,
            ratePaise: 4000,
            priceUnitFactor: 1000,
            gstRateBp: 1800,
          ),
        ],
      ).copyWithItem(cableId);

  group('outbox', () {
    test('creating an item writes outbox rows for item and units', () async {
      expect(await outboxCount('items'), 2); // cable + switch
      // cable: mm(auto) + m + roll = 3, switch: pcs(auto) + box = 2
      expect(await outboxCount('item_units'), 5);
      expect(await rows(db.itemUnits), 5);
    });

    test('outbox payload is JSON of the saved row', () async {
      final row = await (db.select(db.outbox)
            ..where((t) => t.entity.equals('parties') & t.entityId.equals(customerId)))
          .getSingle();
      expect(row.op, 'upsert');
      expect(row.payloadJson, contains('Ramesh'));
      expect(row.shopId, 'shop1');
      expect(row.attemptCount, 0);
    });
  });

  group('purchases', () {
    test('a purchase raises stock and creates a supplier payable', () async {
      await purchases.postPurchase(purchaseOf('INV-100'));
      // 2 rolls x 90 m = 180 m = 180000 mm
      expect(await stock.balance(itemId: cableId), 180000);
      // 180 m x Rs 40 = Rs 7200 = 720000 paise + 18% = 129600
      expect(await ledger.balance(supplierId), -849600);
      expect(await outboxCount('purchases'), 1);
      expect(await outboxCount('purchase_lines'), 1);
      expect(await outboxCount('stock_movements'), 1);
      expect(await outboxCount('ledger_entries'), 1);
    });

    test('duplicate supplier invoice is rejected and changes nothing', () async {
      await purchases.postPurchase(purchaseOf('INV-100'));
      final before = await outboxCount();
      await expectLater(
        purchases.postPurchase(purchaseOf('INV-100')),
        throwsA(isA<DuplicatePurchaseException>()),
      );
      expect(await stock.balance(itemId: cableId), 180000);
      expect(await rows(db.purchases), 1);
      expect(await outboxCount(), before);
    });

    test('a failing save rolls everything back', () async {
      final before = await outboxCount();
      await expectLater(
        purchases.postPurchase(purchaseOf('INV-200', locationId: 'no-such-location')),
        throwsA(anything),
      );
      expect(await rows(db.purchases), 0);
      expect(await rows(db.purchaseLines), 0);
      expect(await rows(db.stockMovements), 0);
      expect(await rows(db.ledgerEntries), 0);
      expect(await outboxCount(), before);
    });

    test('wrong qtyBase for the entered unit is rejected', () async {
      final bad = PostPurchaseInput(
        supplierId: supplierId,
        supplierInvoiceNo: 'INV-300',
        supplierInvoiceDate: day,
        locationId: shopLoc,
        lines: [
          PurchaseLineInput(
            itemId: cableId,
            unitName: 'roll',
            qtyEntered: '2',
            qtyBase: 2000, // should be 180000
            ratePaise: 4000,
            priceUnitFactor: 1000,
          ),
        ],
      );
      await expectLater(
          purchases.postPurchase(bad), throwsA(isA<DomainException>()));
      expect(await rows(db.purchases), 0);
    });
  });

  group('sales', () {
    setUp(() async {
      await purchases.postPurchase(purchaseOf('INV-100'));
    });

    test('cash sale of 2.5 m: totals, stock and outbox', () async {
      final line = lineFor(cableId, 'm', '2.5', rate: 4750, priceUnitFactor: 1000);
      // 2.5 m x Rs 47.50 = 118.75; GST 18% = 21.375 -> 21.38 (per line half up)
      expect(line.lineTotalPaise, 11875 + 2138);
      final input = invoiceFrom([line], roundOff: -13);
      expect(input.totalPaise, 14000);

      final id = await invoices.postInvoice(input);
      final inv = await (db.select(db.invoices)..where((t) => t.id.equals(id))).getSingle();
      expect(inv.invoiceNoText, 'A-0001');
      expect(inv.totalPaise, 14000);
      expect(inv.paidPaise, 14000);
      // 180000 - 2500
      expect(await stock.balance(itemId: cableId), 177500);
      expect(await outboxCount('invoices'), 1);
      expect(await outboxCount('invoice_lines'), 1);
      expect(await outboxCount('invoice_payments'), 1);
    });

    test('credit sale creates a receivable; payment reduces it', () async {
      final line = lineFor(switchId, 'box', '2', rate: 1500, priceUnitFactor: 1);
      // 2 boxes = 20 pcs x Rs 15 = 300.00; GST 54.00 -> 354.00
      final input = invoiceFrom(
        [line],
        partyId: customerId,
        payments: (t) => [PaymentInput('cash', 10000), PaymentInput('credit', t - 10000)],
      );
      expect(input.totalPaise, 35400);
      await invoices.postInvoice(input);

      expect(await ledger.balance(customerId), 25400);
      await ledger.recordCustomerPayment(customerId, 5400);
      expect(await ledger.balance(customerId), 20000);
    });

    test('invariants: balances equal the sum of their rows', () async {
      await invoices.postInvoice(invoiceFrom(
        [lineFor(cableId, 'm', '0.5', rate: 4750, priceUnitFactor: 1000)],
        partyId: customerId,
        payments: (t) => [PaymentInput('credit', t)],
      ));
      await ledger.recordCustomerPayment(customerId, 1000);

      final movSum = (await db
              .customSelect('SELECT SUM(qty_base) AS s FROM stock_movements WHERE item_id = ?',
                  variables: [Variable<String>(cableId)])
              .getSingle())
          .read<int>('s');
      expect(await stock.balance(itemId: cableId), movSum);

      final ledSum = (await db
              .customSelect('SELECT SUM(amount_paise) AS s FROM ledger_entries WHERE party_id = ?',
                  variables: [Variable<String>(customerId)])
              .getSingle())
          .read<int>('s');
      expect(await ledger.balance(customerId), ledSum);
    });

    test('a failing save rolls everything back', () async {
      final before = await outboxCount();
      final movements = await rows(db.stockMovements);
      await expectLater(
        invoices.postInvoice(invoiceFrom(
          [lineFor(cableId, 'm', '1', rate: 4750, priceUnitFactor: 1000)],
          locationId: 'no-such-location',
        )),
        throwsA(anything),
      );
      expect(await rows(db.invoices), 0);
      expect(await rows(db.invoiceLines), 0);
      expect(await rows(db.invoicePayments), 0);
      expect(await rows(db.stockMovements), movements);
      expect(await outboxCount(), before);
    });

    test('duplicate invoice number on a device is rejected', () async {
      final line = lineFor(switchId, 'pcs', '1', rate: 1500, priceUnitFactor: 1);
      await invoices.postInvoice(invoiceFrom([line]));
      final before = await outboxCount();
      await expectLater(
        invoices.postInvoice(invoiceFrom([line])),
        throwsA(isA<DuplicateInvoiceNumberException>()),
      );
      expect(await rows(db.invoices), 1);
      expect(await outboxCount(), before);
    });

    test('nextNumber follows the device series', () async {
      expect(await invoices.nextNumber(deviceId, 'A'), 1);
      final line = lineFor(switchId, 'pcs', '1', rate: 1500, priceUnitFactor: 1);
      await invoices.postInvoice(invoiceFrom([line]));
      expect(await invoices.nextNumber(deviceId, 'A'), 2);
    });

    test('inconsistent totals are rejected', () async {
      final line = lineFor(switchId, 'pcs', '1', rate: 1500, priceUnitFactor: 1);
      final good = invoiceFrom([line]);
      final bad = PostInvoiceInput(
        deviceId: good.deviceId,
        series: good.series,
        number: good.number,
        date: good.date,
        locationId: good.locationId,
        subtotalPaise: good.subtotalPaise,
        discountPaise: good.discountPaise,
        taxPaise: good.taxPaise,
        roundOffPaise: good.roundOffPaise,
        totalPaise: good.totalPaise + 1, // wrong
        lines: good.lines,
        payments: [PaymentInput('cash', good.totalPaise + 1)],
      );
      await expectLater(
          invoices.postInvoice(bad), throwsA(isA<DomainException>()));
      expect(await rows(db.invoices), 0);
    });

    test('credit sale without a customer is rejected', () async {
      final line = lineFor(switchId, 'pcs', '1', rate: 1500, priceUnitFactor: 1);
      await expectLater(
        invoices.postInvoice(invoiceFrom([line],
            payments: (t) => [PaymentInput('credit', t)])),
        throwsA(isA<DomainException>()),
      );
      expect(await rows(db.invoices), 0);
    });
  });

  group('prices', () {
    test('tier price falls back to retail', () async {
      await items.setPrice(itemId: cableId, tier: 'retail', ratePaise: 4750);
      await items.setPrice(itemId: cableId, tier: 'dealer', ratePaise: 4200);
      expect(await items.priceFor(itemId: cableId, tier: 'dealer'), 4200);
      expect(await items.priceFor(itemId: cableId, tier: 'contractor'), 4750);
      await items.setPrice(itemId: cableId, tier: 'retail', ratePaise: 4800);
      expect(await items.priceFor(itemId: cableId, tier: 'retail'), 4800);
      expect(await rows(db.itemPrices), 2);
    });
  });
}

extension on PostPurchaseInput {
  /// Test helper: point every line at [itemId].
  PostPurchaseInput copyWithItem(String itemId) => PostPurchaseInput(
        supplierId: supplierId,
        supplierInvoiceNo: supplierInvoiceNo,
        supplierInvoiceDate: supplierInvoiceDate,
        locationId: locationId,
        lines: [
          for (final l in lines)
            PurchaseLineInput(
              itemId: itemId,
              unitName: l.unitName,
              qtyEntered: l.qtyEntered,
              qtyBase: l.qtyBase,
              ratePaise: l.ratePaise,
              priceUnitFactor: l.priceUnitFactor,
              gstRateBp: l.gstRateBp,
            ),
        ],
      );
}
