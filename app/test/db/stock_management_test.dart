import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

void main() {
  late AppDatabase db;
  late RepoContext ctx;
  late StockRepository stock;
  late String wireId;
  late String switchId;
  late String loc;
  var tick = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tick = 0;
    ctx = RepoContext(db,
        shopId: 'shop1',
        clock: () => DateTime(2026, 11, 12, 10).add(Duration(minutes: tick++)));
    stock = StockRepository(ctx);
    final items = ItemRepository(ctx);
    final setup = SetupRepository(ctx);
    await setup.createShop(name: 'Test');
    loc = await setup.createLocation('shop');
    wireId = await items.createItem(
        name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, units: const [ItemUnitInput('m', 1000)]);
    switchId = await items.createItem(name: 'Switch', baseUnit: 'pcs');
  });

  tearDown(() => db.close());

  test('balancesByItem sums movements per item in one query', () async {
    await stock.record(itemId: wireId, locationId: loc, qtyBase: 90000, movementType: 'purchase');
    await stock.record(itemId: wireId, locationId: loc, qtyBase: -2500, movementType: 'sale');
    await stock.record(itemId: switchId, locationId: loc, qtyBase: 20, movementType: 'purchase');
    final all = await stock.balancesByItem();
    expect(all, {wireId: 87500, switchId: 20});
    expect(await stock.balance(itemId: wireId), all[wireId]);
    expect(await stock.balancesByItem(locationId: 'other'), isEmpty);
  });

  test('items without movements are absent from the grouped balances', () async {
    expect(await stock.balancesByItem(), isEmpty);
    expect(await stock.balance(itemId: wireId), 0);
  });

  test('adjust writes a movement with its reason, and an audit row', () async {
    await stock.record(itemId: switchId, locationId: loc, qtyBase: 20, movementType: 'purchase');
    await stock.adjust(itemId: switchId, locationId: loc, deltaBase: -3, reason: 'Damaged', userId: 'u1');
    expect(await stock.balance(itemId: switchId), 17);
    final m = (await stock.movements(switchId)).first;
    expect(m.movementType, 'adjustment');
    expect(m.qtyBase, -3);
    expect(m.note, 'Damaged');
    final audit = (await db.select(db.auditLog).get()).single;
    expect(audit.action, 'stock_adjustment');
    expect(audit.beforeJson, contains('20'));
    expect(audit.afterJson, contains('17'));
    expect(audit.afterJson, contains('Damaged'));
    expect(audit.userId, 'u1');
  });

  test('adjust needs a reason, a non-zero amount and a real item', () async {
    expect(() => stock.adjust(itemId: switchId, locationId: loc, deltaBase: 0, reason: 'x'),
        throwsA(isA<DomainException>()));
    expect(() => stock.adjust(itemId: switchId, locationId: loc, deltaBase: 1, reason: '  '),
        throwsA(isA<DomainException>()));
    expect(() => stock.adjust(itemId: 'nope', locationId: loc, deltaBase: 1, reason: 'x'),
        throwsA(isA<DomainException>()));
    expect(await db.select(db.stockMovements).get(), isEmpty);
  });

  test('count records the difference so the balance equals the counted quantity', () async {
    await stock.record(itemId: switchId, locationId: loc, qtyBase: 20, movementType: 'purchase');
    // Shelf has 17: difference -3.
    expect(await stock.recordCount(itemId: switchId, locationId: loc, countedBase: 17), -3);
    expect(await stock.balance(itemId: switchId), 17);
    // Shelf has 25: difference +8.
    expect(await stock.recordCount(itemId: switchId, locationId: loc, countedBase: 25), 8);
    expect(await stock.balance(itemId: switchId), 25);
    final types = (await stock.movements(switchId)).map((m) => m.movementType).toList();
    expect(types.where((t) => t == 'count').length, 2);
  });

  test('a count that matches the system writes nothing', () async {
    await stock.record(itemId: switchId, locationId: loc, qtyBase: 20, movementType: 'purchase');
    final before = (await db.select(db.outbox).get()).length;
    expect(await stock.recordCount(itemId: switchId, locationId: loc, countedBase: 20), 0);
    expect((await db.select(db.stockMovements).get()), hasLength(1));
    expect((await db.select(db.outbox).get()).length, before);
    expect(await db.select(db.auditLog).get(), isEmpty);
  });

  test('count can bring negative stock back to a real number', () async {
    await stock.record(itemId: switchId, locationId: loc, qtyBase: -5, movementType: 'sale');
    expect(await stock.balance(itemId: switchId), -5);
    expect(await stock.recordCount(itemId: switchId, locationId: loc, countedBase: 10), 15);
    expect(await stock.balance(itemId: switchId), 10);
    expect(() => stock.recordCount(itemId: switchId, locationId: loc, countedBase: -1),
        throwsA(isA<DomainException>()));
  });

  test('movements are newest first and carry notes', () async {
    await stock.record(itemId: switchId, locationId: loc, qtyBase: 10, movementType: 'purchase', note: 'first');
    await stock.record(itemId: switchId, locationId: loc, qtyBase: -1, movementType: 'sale', note: 'second');
    final list = await stock.movements(switchId);
    expect(list.map((m) => m.note), ['second', 'first']);
  });

  test('every stock write also writes an outbox row', () async {
    await stock.adjust(itemId: switchId, locationId: loc, deltaBase: 5, reason: 'Found');
    final out = await db.select(db.outbox).get();
    expect(out.where((o) => o.entity == 'stock_movements'), hasLength(1));
    expect(out.where((o) => o.entity == 'audit_log'), hasLength(1));
  });
}
