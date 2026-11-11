import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';

void main() {
  late AppDatabase db;
  late RepoContext ctx;
  late ItemRepository items;
  late String wireId;
  late String switchId;
  late String locationId;
  late String supplierId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ctx = RepoContext(db, shopId: 'shop1', clock: () => DateTime(2026, 11, 12, 10));
    items = ItemRepository(ctx);
    final setup = SetupRepository(ctx);
    await setup.createShop(name: 'Test shop');
    locationId = await setup.createLocation('shop');
    supplierId = await PartyRepository(ctx).createParty(kind: 'supplier', name: 'Supplier');
    wireId = await items.createItem(
      name: 'Wire 1.5',
      brand: 'Polycab',
      baseUnit: 'mm',
      priceUnitFactor: 1000,
      gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)],
    );
    switchId = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800);
    await items.setPrice(itemId: wireId, tier: 'retail', ratePaise: 4750);
  });

  tearDown(() => db.close());

  Future<int> auditCount([String? action]) async {
    final q = db.select(db.auditLog);
    if (action != null) q.where((t) => t.action.equals(action));
    return (await q.get()).length;
  }

  Future<void> postPurchaseOfWire() => PurchaseRepository(ctx).postPurchase(
        PostPurchaseInput(
          supplierId: supplierId,
          supplierInvoiceNo: 'P1',
          supplierInvoiceDate: DateTime(2026, 11, 12),
          locationId: locationId,
          lines: [
            PurchaseLineInput(
              itemId: wireId,
              unitName: 'm',
              qtyEntered: '10',
              qtyBase: 10000,
              ratePaise: 3000,
              priceUnitFactor: 1000,
              gstRateBp: 1800,
            ),
          ],
        ),
      );

  group('listing and detail', () {
    test('lists active items by name with the retail price', () async {
      final all = await items.listItems();
      expect(all.map((e) => e.item.name), ['Switch', 'Wire 1.5']);
      expect(all.last.retailRatePaise, 4750);
      expect(all.first.retailRatePaise, isNull);
      expect((await items.listItems(query: 'poly')).single.item.name, 'Wire 1.5');
      expect(await items.listItems(query: 'zzz'), isEmpty);
    });

    test('inactive items are hidden unless asked for', () async {
      await items.setActive(switchId, false);
      expect((await items.listItems()).map((e) => e.item.name), ['Wire 1.5']);
      expect(await items.listItems(includeInactive: true), hasLength(2));
      expect(await items.search('Switch'), isEmpty);
      await items.setActive(switchId, true);
      expect(await items.search('Switch'), hasLength(1));
    });

    test('detail has units, variants, prices, cost and lock state', () async {
      await items.addVariant(itemId: wireId, label: 'Red', barcode: '111');
      await items.setCost(itemId: wireId, costPaise: 3000);
      final d = await items.getDetail(wireId);
      expect(d.units.map((u) => u.unitName), ['mm', 'm', 'roll']);
      expect(d.variants.single.label, 'Red');
      expect(d.prices, {'retail': 4750});
      expect(d.costPaise, 3000);
      expect(d.structureLocked, false);
    });
  });

  group('editing', () {
    test('updateItem changes fields and writes an audit row with before and after', () async {
      await items.updateItem(
        itemId: wireId,
        name: 'Wire 1.5 sqmm',
        brand: 'Havells',
        hsn: '8544',
        gstRateBp: 1800,
        minStockBase: 90000,
        userId: 'u1',
      );
      final item = await items.getItem(wireId);
      expect(item.name, 'Wire 1.5 sqmm');
      expect(item.brand, 'Havells');
      expect(item.minStockBase, 90000);
      final audit = (await db.select(db.auditLog).get()).single;
      expect(audit.action, 'edit');
      expect(audit.userId, 'u1');
      expect(audit.beforeJson, contains('Wire 1.5'));
      expect(audit.afterJson, contains('Havells'));
      final out = await (db.select(db.outbox)
            ..where((t) => t.entity.equals('items') & t.entityId.equals(wireId)))
          .get();
      expect(out.length, 2); // create + update
    });

    test('empty name and negative values are rejected', () async {
      expect(() => items.updateItem(itemId: wireId, name: ' ', gstRateBp: 0, minStockBase: 0),
          throwsA(isA<DomainException>()));
      expect(() => items.updateItem(itemId: wireId, name: 'x', gstRateBp: -1, minStockBase: 0),
          throwsA(isA<DomainException>()));
      expect(() => items.updateItem(itemId: wireId, name: 'x', gstRateBp: 0, minStockBase: -5),
          throwsA(isA<DomainException>()));
    });

    test('base unit can change while the item is unused, and the unit row follows', () async {
      await items.updateItem(
        itemId: switchId,
        name: 'Switch',
        gstRateBp: 1800,
        minStockBase: 0,
        baseUnit: 'nos',
      );
      expect((await items.getItem(switchId)).baseUnit, 'nos');
      expect((await items.unitsOf(switchId)).single.unitName, 'nos');
    });

    test('unit type is locked once the item has stock; other edits still work', () async {
      await postPurchaseOfWire();
      expect((await items.getDetail(wireId)).structureLocked, true);
      await expectLater(
        items.updateItem(
            itemId: wireId, name: 'Wire', gstRateBp: 1800, minStockBase: 0, priceUnitFactor: 1),
        throwsA(isA<DomainException>()),
      );
      await expectLater(
        items.updateItem(
            itemId: wireId, name: 'Wire', gstRateBp: 1800, minStockBase: 0, baseUnit: 'm'),
        throwsA(isA<DomainException>()),
      );
      // Name and GST changes are fine.
      await items.updateItem(itemId: wireId, name: 'Wire renamed', gstRateBp: 1200, minStockBase: 0);
      final item = await items.getItem(wireId);
      expect(item.name, 'Wire renamed');
      expect(item.gstRateBp, 1200);
      expect(item.priceUnitFactor, 1000);
    });
  });

  group('units', () {
    test('add, change size, remove; base and pricing units are protected', () async {
      final box = await items.addUnit(switchId, 'box', 10);
      expect((await items.unitsOf(switchId)).map((u) => u.unitName), ['pcs', 'box']);
      await items.updateUnitFactor(box, 12);
      expect((await items.unitsOf(switchId)).last.factorToBase, 12);
      await expectLater(items.addUnit(switchId, 'box', 5), throwsA(isA<DomainException>()));
      await expectLater(items.addUnit(switchId, ' ', 5), throwsA(isA<DomainException>()));
      await expectLater(items.addUnit(switchId, 'x', 0), throwsA(isA<DomainException>()));

      final base = (await items.unitsOf(switchId)).first;
      await expectLater(items.removeUnit(base.id), throwsA(isA<DomainException>()));
      await expectLater(items.updateUnitFactor(base.id, 2), throwsA(isA<DomainException>()));

      await items.removeUnit(box);
      expect((await items.unitsOf(switchId)).map((u) => u.unitName), ['pcs']);
    });

    test('the pricing unit of a cable cannot be removed', () async {
      final m = (await items.unitsOf(wireId)).firstWhere((u) => u.unitName == 'm');
      await expectLater(items.removeUnit(m.id), throwsA(isA<DomainException>()));
      final roll = (await items.unitsOf(wireId)).firstWhere((u) => u.unitName == 'roll');
      await items.removeUnit(roll.id); // fine
      expect((await items.unitsOf(wireId)).map((u) => u.unitName), ['mm', 'm']);
    });
  });

  group('variants and barcodes', () {
    test('a barcode can belong to only one variant', () async {
      final red = await items.addVariant(itemId: wireId, label: 'Red', barcode: '111');
      await expectLater(
        items.addVariant(itemId: switchId, label: 'White', barcode: '111'),
        throwsA(isA<DomainException>()),
      );
      final white = await items.addVariant(itemId: switchId, label: 'White', barcode: '222');
      await expectLater(
        items.updateVariant(variantId: white, label: 'White', barcode: '111'),
        throwsA(isA<DomainException>()),
      );
      // Re-saving a variant with its own barcode is fine.
      await items.updateVariant(variantId: red, label: 'Red', barcode: '111', colour: 'red');
      expect((await items.findVariantByBarcode('111'))!.colour, 'red');
    });

    test('removing a variant hides it from search and frees its barcode', () async {
      final red = await items.addVariant(itemId: wireId, label: 'Red', barcode: '111');
      expect((await items.search('111')).single.variant?.id, red);
      await items.removeVariant(red);
      expect(await items.search('111'), isEmpty);
      await items.addVariant(itemId: switchId, label: 'Other', barcode: '111'); // now free
      expect(await auditCount('delete'), 1);
    });
  });

  group('prices', () {
    test('a first price is not audited; changing it is', () async {
      expect(await auditCount('price_change'), 0); // setUp set retail 4750
      await items.setPrice(itemId: wireId, tier: 'retail', ratePaise: 4750); // same: no change
      expect(await auditCount('price_change'), 0);
      await items.setPrice(itemId: wireId, tier: 'retail', ratePaise: 5000, userId: 'u1');
      final a = (await db.select(db.auditLog).get()).single;
      expect(a.action, 'price_change');
      expect(a.beforeJson, contains('4750'));
      expect(a.afterJson, contains('5000'));
      expect(await items.priceFor(itemId: wireId, tier: 'retail'), 5000);
    });

    test('clearing a tier price falls back to retail', () async {
      await items.setPrice(itemId: wireId, tier: 'dealer', ratePaise: 4200);
      expect(await items.priceFor(itemId: wireId, tier: 'dealer'), 4200);
      await items.clearPrice(itemId: wireId, tier: 'dealer');
      expect(await items.priceFor(itemId: wireId, tier: 'dealer'), 4750);
      expect((await items.getDetail(wireId)).prices.containsKey('dealer'), false);
      expect(await auditCount('price_change'), 1);
    });
  });
}
