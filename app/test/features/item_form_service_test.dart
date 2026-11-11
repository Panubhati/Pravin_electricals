import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/features/items/item_form_service.dart';

void main() {
  late AppDatabase db;
  late RepoContext ctx;
  late ItemFormService service;
  late ItemRepository items;
  late StockRepository stock;
  late String loc;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ctx = RepoContext(db, shopId: 'shop1', clock: () => DateTime(2026, 11, 12, 10));
    service = ItemFormService(ctx);
    items = ItemRepository(ctx);
    stock = StockRepository(ctx);
    final setup = SetupRepository(ctx);
    await setup.createShop(name: 'Test');
    loc = await setup.createLocation('shop');
  });

  tearDown(() => db.close());

  ItemFormData cable({String? itemId, int retail = 4750, int? roll = 90000, int? cost = 3000}) =>
      ItemFormData(
        itemId: itemId,
        name: 'Test cable',
        brand: 'Polycab',
        category: 'Wire',
        hsn: '8544',
        gstRateBp: 1800,
        isLength: true,
        packSize: roll,
        retailPaise: retail,
        contractorPaise: 4400,
        dealerPaise: 4200,
        costPaise: cost,
        minStockBase: 100000,
        openingStockBase: 90000,
        barcode: '8901',
      );

  test('creating a cable saves units, prices, cost, barcode and opening stock', () async {
    final id = await service.save(cable(), locationId: loc);
    final d = await items.getDetail(id);
    expect(d.item.baseUnit, 'mm');
    expect(d.item.priceUnitFactor, 1000);
    expect(d.units.map((u) => '${u.unitName}=${u.factorToBase}'), ['mm=1', 'm=1000', 'roll=90000']);
    expect(d.prices, {'retail': 4750, 'contractor': 4400, 'dealer': 4200});
    expect(d.costPaise, 3000);
    expect(d.variants.single.barcode, '8901');
    expect(await stock.balance(itemId: id), 90000);
    expect(d.item.minStockBase, 100000);
  });

  test('a piece item with a box', () async {
    final id = await service.save(
      const ItemFormData(
        name: 'Switch', gstRateBp: 1800, isLength: false, packSize: 10, retailPaise: 1500),
      locationId: loc,
    );
    final d = await items.getDetail(id);
    expect(d.item.baseUnit, 'pcs');
    expect(d.units.map((u) => '${u.unitName}=${u.factorToBase}'), ['pcs=1', 'box=10']);
    expect(d.costPaise, isNull);
    expect(await stock.balance(itemId: id), 0);
  });

  test('without permission to see cost, no cost is stored', () async {
    final id = await service.save(cable(), locationId: loc, canSeeCost: false);
    expect(await items.latestCost(id), isNull);
  });

  test('editing changes fields, prices and the roll size, and audits it', () async {
    final id = await service.save(cable(), locationId: loc);
    await service.save(
      ItemFormData(
        itemId: id,
        name: 'Test cable 2',
        gstRateBp: 1800,
        isLength: false, // ignored: the type is fixed after creation
        packSize: 180000,
        retailPaise: 5000,
        contractorPaise: null, // cleared
        dealerPaise: 4100,
        costPaise: 3200,
        minStockBase: 50000,
      ),
      locationId: loc,
      userId: 'u1',
    );
    final d = await items.getDetail(id);
    expect(d.item.name, 'Test cable 2');
    expect(d.item.baseUnit, 'mm'); // still a cable
    expect(d.prices, {'retail': 5000, 'dealer': 4100});
    expect(d.costPaise, 3200);
    expect(d.units.firstWhere((u) => u.unitName == 'roll').factorToBase, 180000);
    expect(d.item.minStockBase, 50000);
    // Opening stock is only for creation: no second movement.
    expect(await stock.balance(itemId: id), 90000);
    final audits = await db.select(db.auditLog).get();
    expect(audits.where((a) => a.action == 'edit').isNotEmpty, true);
    // Retail changed, contractor cleared, dealer changed: one audit row each.
    expect(audits.where((a) => a.action == 'price_change').length, 3);
  });

  test('editing can add and remove the roll unit', () async {
    final id = await service.save(cable(roll: null), locationId: loc);
    expect((await items.unitsOf(id)).any((u) => u.unitName == 'roll'), false);
    await service.save(cable(itemId: id, roll: 45000), locationId: loc);
    expect((await items.unitsOf(id)).firstWhere((u) => u.unitName == 'roll').factorToBase, 45000);
    await service.save(cable(itemId: id, roll: null), locationId: loc);
    expect((await items.unitsOf(id)).any((u) => u.unitName == 'roll'), false);
  });

  test('validation errors save nothing', () async {
    for (final bad in [
      const ItemFormData(name: ' ', gstRateBp: 1800, isLength: false, retailPaise: 100),
      const ItemFormData(name: 'x', gstRateBp: 999, isLength: false, retailPaise: 100),
      const ItemFormData(name: 'x', gstRateBp: 1800, isLength: false, retailPaise: 0),
      const ItemFormData(name: 'x', gstRateBp: 1800, isLength: false, retailPaise: 100, contractorPaise: 0),
      const ItemFormData(name: 'x', gstRateBp: 1800, isLength: false, retailPaise: 100, packSize: 1),
      const ItemFormData(name: 'x', gstRateBp: 1800, isLength: true, retailPaise: 100, packSize: 0),
    ]) {
      await expectLater(service.save(bad, locationId: loc), throwsA(isA<DomainException>()));
    }
    expect(await db.select(db.items).get(), isEmpty);
  });

  test('a failure part-way (duplicate barcode) rolls the whole item back', () async {
    await service.save(cable(), locationId: loc);
    final before = (await db.select(db.items).get()).length;
    await expectLater(
      service.save(
        const ItemFormData(
          name: 'Another', gstRateBp: 1800, isLength: false, retailPaise: 100, barcode: '8901'),
        locationId: loc,
      ),
      throwsA(isA<DomainException>()),
    );
    expect((await db.select(db.items).get()).length, before);
  });
}
