import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/sync/device_identity.dart';
import 'package:shop_app/core/sync/sync_engine.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';
import 'package:shop_app/features/sync/device_choice_screen.dart';

import '../helpers/seed_rich_shop.dart';

/// Two phones as two in-memory databases. The engine's batches are handed
/// from one to the other directly (the network comes in step 3). After every
/// scenario both phones must hold the same rows and pass Check my data.
class Phone {
  Phone(this.db, this.identity);
  final AppDatabase db;
  final MemoryDeviceIdentity identity;
  late ShopSession session;

  Future<void> open() async => session = await ensureShopSession(db, identity: identity);
  SyncEngine get engine => SyncEngine(session.ctx);
  String get id => session.deviceId;
}

/// One full round: each phone pulls everything new from the other, page by page.
Future<({int applied, int conflicts})> syncPair(Phone a, Phone b, {int limit = 500}) async {
  var applied = 0, conflicts = 0;
  for (final (from, to) in [(a, b), (b, a)]) {
    while (true) {
      final batch = await from.engine.changesAfter(await to.engine.cursor(), limit: limit);
      final r = await to.engine.apply(batch, peer: from.id);
      applied += r.applied;
      conflicts += r.conflicts;
      if (!batch.hasMore) break;
    }
  }
  return (applied: applied, conflicts: conflicts);
}

/// Every shared table as comparable JSON (settings by key; phone-only keys left out).
Future<Map<String, List<String>>> snapshot(AppDatabase db) async {
  final out = <String, List<String>>{};
  for (final t in db.allTables) {
    final name = t.actualTableName;
    if (localOnlyTables.contains(name)) continue;
    final rows = <String>[];
    for (final r in await db.select(t).get()) {
      final j = jsonDecode(jsonEncode((r as DataClass).toJson())) as Map<String, dynamic>;
      if (name == 'app_settings') {
        if (phoneOnlySettingKeys.contains(j['key'])) continue;
        rows.add('${j['key']}=${j['value']}');
      } else {
        rows.add(jsonEncode(j));
      }
    }
    rows.sort();
    out[name] = rows;
  }
  return out;
}

Future<void> expectSame(Phone a, Phone b) async {
  final sa = await snapshot(a.db), sb = await snapshot(b.db);
  for (final t in sa.keys) {
    expect(sb[t], sa[t], reason: 'table $t differs between the phones');
  }
  for (final p in [a, b]) {
    final check = await DataCheckRepository(p.session.ctx).run();
    expect(check.passed, isTrue, reason: 'Check my data on ${p.session.series}: ${check.errors.map((e) => e.message).join('; ')}');
  }
}

void main() {
  late Phone a, b;

  /// Phone A has a shop; phone B starts empty, takes everything from A through
  /// the engine, then becomes phone B (as pairing will do).
  Future<void> pair() async {
    a = Phone(AppDatabase(NativeDatabase.memory()), MemoryDeviceIdentity());
    await a.open();
    await seedRichShop(a.session);

    final dbB = AppDatabase(NativeDatabase.memory());
    final bId = 'device-b-${DateTime.now().microsecondsSinceEpoch}';
    final receiver = SyncEngine(RepoContext(dbB, shopId: a.session.shopId)..originDeviceId = bId);
    while (true) {
      final batch = await a.engine.changesAfter(await receiver.cursor());
      await receiver.apply(batch, peer: a.id);
      if (!batch.hasMore) break;
    }
    b = Phone(dbB, MemoryDeviceIdentity());
    await addThisPhone(dbB, b.identity, label: 'Counter phone');
    await b.open();
    await syncPair(a, b);
  }

  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  Future<String> sell(Phone p, {String item = 'switch', String qty = '2', int rate = 1500}) async {
    final found = (await ItemRepository(p.session.ctx).search(item)).first.item;
    final cart = [
      CartLine(
        itemId: found.id, itemName: found.name, unitName: found.baseUnit, factorToBase: 1, qtyEntered: qty,
        ratePaise: rate, priceUnitFactor: 1, gstRateBp: found.gstRateBp,
      ),
    ];
    final totals = BillCalculator.calculate(cart, interState: false);
    final repo = InvoiceRepository(p.session.ctx);
    return repo.postInvoice(totals.toInvoiceInput(
      deviceId: p.session.deviceId,
      series: p.session.series,
      number: await repo.nextNumber(p.session.deviceId, p.session.series),
      date: DateTime.now(),
      locationId: p.session.locationId,
      payments: [PaymentInput('cash', totals.totalPaise)],
    ));
  }

  test('a new phone that takes everything from phone A ends up identical, and is phone B', () async {
    await pair();
    expect(b.session.series, 'B');
    expect((await a.db.select(a.db.devices).get()).map((d) => d.invoiceSeriesPrefix).toSet(), {'A', 'B'});
    await expectSame(a, b);
  });

  test('bills made on both phones at once end up on both, each with its own numbers', () async {
    await pair();
    await sell(a);
    await sell(b);
    await sell(b, qty: '3');
    await syncPair(a, b);
    await expectSame(a, b);
    final numbers = (await a.db.select(a.db.invoices).get()).map((i) => i.invoiceNoText).toSet();
    expect(numbers, containsAll(['B-0001', 'B-0002']));
    final sw = (await ItemRepository(a.session.ctx).search('switch')).first.item;
    expect(await StockRepository(a.session.ctx).balance(itemId: sw.id), await StockRepository(b.session.ctx).balance(itemId: sw.id));
  });

  test('the same price edited on both phones before they sync: the later edit wins on both, and the clash is logged', () async {
    await pair();
    final sw = (await ItemRepository(a.session.ctx).search('switch')).first.item;
    var t = DateTime.now();
    // Phone A edits first, phone B a minute later.
    final ctxA = RepoContext(a.db, shopId: a.session.shopId, clock: () => t)..originDeviceId = a.id;
    await ItemRepository(ctxA).setPrice(itemId: sw.id, tier: 'retail', ratePaise: 1600);
    t = t.add(const Duration(minutes: 1));
    final ctxB = RepoContext(b.db, shopId: b.session.shopId, clock: () => t)..originDeviceId = b.id;
    await ItemRepository(ctxB).setPrice(itemId: sw.id, tier: 'retail', ratePaise: 1700);

    final r = await syncPair(a, b);
    expect(r.conflicts, greaterThanOrEqualTo(1));
    await syncPair(a, b); // the clash notes themselves travel too
    for (final p in [a, b]) {
      expect(await ItemRepository(p.session.ctx).priceFor(itemId: sw.id, tier: 'retail'), 1700);
      final notes = await (p.db.select(p.db.auditLog)..where((x) => x.action.equals('sync_conflict'))).get();
      expect(notes, isNotEmpty);
    }
    await expectSame(a, b);
  });

  for (final aFirst in [true, false]) {
    test('edits at the very same moment end the same on both phones (${aFirst ? 'A' : 'B'} pulls first)', () async {
      await pair();
      final sw = (await ItemRepository(a.session.ctx).search('switch')).first.item;
      final t = DateTime.now();
      for (final (p, rate) in [(a, 1601), (b, 1702)]) {
        final ctx = RepoContext(p.db, shopId: p.session.shopId, clock: () => t)..originDeviceId = p.id;
        await ItemRepository(ctx).updateItem(itemId: sw.id, name: 'Switch $rate', gstRateBp: sw.gstRateBp, minStockBase: rate);
      }
      if (aFirst) {
        await syncPair(a, b);
      } else {
        await syncPair(b, a);
      }
      await syncPair(a, b);
      final na = (await ItemRepository(a.session.ctx).getItem(sw.id)).name;
      final nb = (await ItemRepository(b.session.ctx).getItem(sw.id)).name;
      expect(na, nb);
      // The tie goes to the higher device id, the same on both phones.
      expect(na, a.id.compareTo(b.id) > 0 ? 'Switch 1601' : 'Switch 1702');
      await expectSame(a, b);
    });
  }

  test('an edit made after the phones synced is not a clash', () async {
    await pair();
    final sw = (await ItemRepository(a.session.ctx).search('switch')).first.item;
    await ItemRepository(a.session.ctx).setPrice(itemId: sw.id, tier: 'retail', ratePaise: 1600);
    await syncPair(a, b);
    await ItemRepository(b.session.ctx).setPrice(itemId: sw.id, tier: 'retail', ratePaise: 1650);
    final r = await syncPair(a, b);
    expect(r.conflicts, 0);
    expect(await ItemRepository(a.session.ctx).priceFor(itemId: sw.id, tier: 'retail'), 1650);
    expect(await (a.db.select(a.db.auditLog)..where((x) => x.action.equals('sync_conflict'))).get(), isEmpty);
    await expectSame(a, b);
  });

  test('the same batch arriving twice changes nothing the second time', () async {
    await pair();
    await sell(a);
    final batch = await a.engine.changesAfter(await b.engine.cursor());
    final first = await b.engine.apply(batch, peer: a.id);
    final second = await b.engine.apply(batch, peer: a.id);
    expect(first.applied, greaterThan(0));
    expect(second.applied, 0);
    await syncPair(a, b);
    await expectSame(a, b);
  });

  test('a bill made on phone A and cancelled on phone B shows cancelled on both', () async {
    await pair();
    final id = await sell(a);
    await syncPair(a, b);
    await ReturnRepository(b.session.ctx).cancelBill(id, deviceId: b.session.deviceId, series: b.session.series);
    await syncPair(a, b);
    final onA = await (a.db.select(a.db.invoices)..where((i) => i.id.equals(id))).getSingle();
    expect(onA.status, 'cancelled');
    expect((await a.db.select(a.db.salesReturns).get()).single.creditNoteNoText, 'CN-B-0001');
    await expectSame(a, b);
  });

  test('the same supplier bill entered on both phones is kept twice (to be flagged), not lost', () async {
    await pair();
    final supplier = (await (a.db.select(a.db.parties)..where((p) => p.kind.equals('supplier'))).get()).first;
    final sw = (await ItemRepository(a.session.ctx).search('switch')).first.item;
    for (final p in [a, b]) {
      await PurchaseRepository(p.session.ctx).postPurchase(PostPurchaseInput(
        supplierId: supplier.id,
        supplierInvoiceNo: 'HV-777',
        supplierInvoiceDate: DateTime.now(),
        locationId: p.session.locationId,
        lines: [PurchaseLineInput(itemId: sw.id, unitName: 'pcs', qtyEntered: '10', qtyBase: 10, ratePaise: 1000, priceUnitFactor: 1, gstRateBp: 1800)],
      ));
    }
    await syncPair(a, b);
    final copies = await (a.db.select(a.db.purchases)..where((x) => x.supplierInvoiceNo.equals('HV-777'))).get();
    expect(copies, hasLength(2));
    final sa = await snapshot(a.db), sb = await snapshot(b.db);
    expect(sb, sa);
  });

  test('phone-only settings (last backup, lock time) stay on their phone; shop settings travel', () async {
    await pair();
    final settingsA = SettingsRepository(a.session.ctx);
    await settingsA.set(SettingKeys.autoLockMinutes, '9');
    await settingsA.set(SettingKeys.upiId, 'newshop@upi');
    await syncPair(a, b);
    final settingsB = SettingsRepository(b.session.ctx);
    expect(await settingsB.get(SettingKeys.upiId), 'newshop@upi');
    expect(await settingsB.get(SettingKeys.autoLockMinutes), isNot('9'));
  });

  test('a long catch-up in small pages arrives complete and in order', () async {
    await pair();
    for (var i = 0; i < 30; i++) {
      await sell(i.isEven ? a : b);
    }
    await syncPair(a, b, limit: 7);
    await expectSame(a, b);
  });

  test('a batch with something this app does not know is refused whole: nothing is half-applied', () async {
    await pair();
    await sell(a);
    final batch = await a.engine.changesAfter(await b.engine.cursor());
    final poisoned = SyncBatch(
      changes: [
        ...batch.changes,
        SyncChange(
            id: 'x', origin: a.id, seq: 999999, entity: 'gift_cards', entityId: 'g', op: 'upsert',
            payloadJson: '{}', changedAtMs: 0),
      ],
      senderCursor: batch.senderCursor,
      hasMore: false,
    );
    final before = await snapshot(b.db);
    await expectLater(b.engine.apply(poisoned, peer: a.id), throwsA(isA<SyncException>()));
    expect(await snapshot(b.db), before);
  });
}
