import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/import/csv_table.dart';
import 'package:shop_app/core/import/item_import.dart';
import 'package:shop_app/core/import/party_import.dart';
import 'package:shop_app/core/import/value_parsers.dart';

void main() {
  group('CSV reader', () {
    test('handles BOM, CRLF, quoted commas and blank lines', () {
      const text = '﻿Name,Retail Price,Note\r\n'
          '"Wire, 1.5 sqmm",47.50,"says ""hi"""\r\n'
          '\r\n'
          '  ,  ,  \r\n'
          'Switch,15,\r\n';
      final t = parseCsv(text);
      expect(t.headers, ['name', 'retail_price', 'note']);
      expect(t.rows, hasLength(2));
      expect(t.rows[0].get('name'), 'Wire, 1.5 sqmm');
      expect(t.rows[0].get('note'), 'says "hi"');
      expect(t.rows[0].rowNumber, 2);
      expect(t.rows[1].get('name'), 'Switch');
      expect(t.rows[1].rowNumber, 5); // blank rows still count, so numbers match Excel
    });

    test('detects semicolons and tabs', () {
      final semi = parseCsv('name;price\nWire;47,50\n');
      expect(semi.headers, ['name', 'price']);
      expect(semi.rows.single.get('price'), '47,50');
      final tab = parseCsv('name\tprice\nWire\t47.5\n');
      expect(tab.rows.single.get('price'), '47.5');
    });

    test('keeps numbers as text and pads short rows', () {
      final t = parseCsv('a,b,c\n007,1.50\n');
      expect(t.rows.single.get('a'), '007');
      expect(t.rows.single.get('b'), '1.50');
      expect(t.rows.single.get('c'), '');
    });

    test('empty input gives an empty table', () {
      expect(parseCsv('').headers, isEmpty);
      expect(parseCsv('  \n\n').rows, isEmpty);
    });
  });

  group('value parsers', () {
    test('rupees', () {
      expect(parseRupees('47.50'), 4750);
      expect(parseRupees('₹ 1,250'), 125000);
      expect(parseRupees('Rs. 12'), 1200);
      expect(parseRupees('INR 5.5'), 550);
      expect(() => parseRupees(''), throwsFormatException);
      expect(() => parseRupees('1.234'), throwsFormatException);
      expect(() => parseRupees('abc'), throwsFormatException);
      expect(() => parseRupees('-5'), throwsFormatException);
      expect(parseRupees('-5', allowNegative: true), -500);
    });

    test('percent', () {
      expect(parsePercentToBp('18'), 1800);
      expect(parsePercentToBp('18%'), 1800);
      expect(parsePercentToBp('2.5'), 250);
      expect(parsePercentToBp('0.25'), 25);
      expect(() => parsePercentToBp('x'), throwsFormatException);
    });

    test('quantity and GSTIN', () {
      expect(cleanQuantity('1,200.5'), '1200.5');
      expect(() => cleanQuantity('-1'), throwsFormatException);
      expect(looksLikeGstin('27AAAAA0000A1Z5'), true);
      expect(looksLikeGstin('27aaaaa0000a1z5'), true);
      expect(looksLikeGstin('1234'), false);
    });
  });

  group('items import', () {
    late AppDatabase db;
    late RepoContext ctx;
    late ItemImportService service;
    late ItemRepository items;
    late StockRepository stock;
    late String loc;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      ctx = RepoContext(db, shopId: 'shop1', clock: () => DateTime(2026, 11, 12, 10));
      service = ItemImportService(ctx);
      items = ItemRepository(ctx);
      stock = StockRepository(ctx);
      final setup = SetupRepository(ctx);
      await setup.createShop(name: 'Test');
      loc = await setup.createLocation('shop');
    });

    tearDown(() => db.close());

    Future<ItemDetail> detailOf(String name) async {
      final e = (await items.listItems(query: name)).single;
      return items.getDetail(e.item.id);
    }

    test('the downloadable template imports cleanly with correct units, prices and stock', () async {
      final p = await service.preview(ItemImportService.templateCsv);
      expect(p.errors, isEmpty);
      expect(p.toCreate, hasLength(3));
      final r = await service.apply(p, locationId: loc);
      expect(r.created, 3);
      expect(r.skipped, 0);

      final wire = await detailOf('copper wire');
      expect(wire.item.baseUnit, 'mm');
      expect(wire.item.priceUnitFactor, 1000);
      expect(wire.item.gstRateBp, 1800);
      expect(wire.item.hsn, '8544');
      expect(wire.item.minStockBase, 100000); // 100 m
      expect(wire.units.map((u) => '${u.unitName}=${u.factorToBase}'), ['mm=1', 'm=1000', 'roll=90000']);
      expect(wire.prices, {'retail': 4750, 'contractor': 4400, 'dealer': 4200});
      expect(wire.costPaise, 3000);
      expect(wire.variants.single.barcode, '8901234567890');
      expect(wire.variants.single.label, kDefaultVariantLabel);
      expect(await stock.balance(itemId: wire.item.id), 450000); // 450 m

      final sw = await detailOf('6A switch');
      expect(sw.item.baseUnit, 'pcs');
      expect(sw.units.map((u) => '${u.unitName}=${u.factorToBase}'), ['pcs=1', 'box=10']);
      expect(sw.prices, {'retail': 1500, 'contractor': 1350});
      expect(sw.costPaise, 900);
      expect(await stock.balance(itemId: sw.item.id), 200);

      final led = await detailOf('LED');
      expect(led.item.gstRateBp, 1200);
      expect(await stock.balance(itemId: led.item.id), 40);
      expect(led.variants, isEmpty); // no barcode given

      // Opening stock is a movement with a note, not a stored number.
      final m = (await stock.movements(wire.item.id)).single;
      expect(m.movementType, 'adjustment');
      expect(m.note, 'Opening stock');
    });

    test('importing the same file again changes nothing', () async {
      final first = await service.preview(ItemImportService.templateCsv);
      await service.apply(first, locationId: loc);
      final movements = (await db.select(db.stockMovements).get()).length;
      final items0 = (await db.select(db.items).get()).length;

      final again = await service.preview(ItemImportService.templateCsv);
      expect(again.toCreate, isEmpty);
      expect(again.skipped, hasLength(3));
      expect(again.canImport, false);
      final r = await service.apply(again, locationId: loc);
      expect(r.created, 0);
      expect(r.skipped, 3);
      expect((await db.select(db.stockMovements).get()).length, movements);
      expect((await db.select(db.items).get()).length, items0);
    });

    test('bad rows are reported with their row number; good rows still import', () async {
      const csv = 'name,brand,type,gst_percent,retail_price,opening_stock,barcode\n'
          'Good item,A,piece,18,100,5,111\n' // row 2 ok
          ',A,piece,18,100,,\n' // row 3: no name
          'Bad GST,A,piece,180,100,,\n' // row 4
          'Bad type,A,kilogram,18,100,,\n' // row 5
          'No price,A,piece,18,,,\n' // row 6
          'Zero price,A,piece,18,0,,\n' // row 7
          'Half piece,A,piece,18,100,1.5,\n' // row 8: fractional pieces
          'Fine wire,A,length,18,47.50,12.3456,\n' // row 9: 4 decimals of a metre
          'Dup barcode,A,piece,18,100,,111\n'; // row 10: barcode of row 2
      final p = await service.preview(csv);
      expect(p.toCreate.map((r) => r.name), ['Good item']);
      final byRow = {for (final e in p.errors) e.rowNumber: e};
      expect(byRow.keys.toSet(), {3, 4, 5, 6, 7, 8, 9, 10});
      expect(byRow[3]!.column, 'name');
      expect(byRow[4]!.message, contains('GST'));
      expect(byRow[5]!.column, 'type');
      expect(byRow[6]!.column, 'retail_price');
      expect(byRow[7]!.message, contains('more than 0'));
      expect(byRow[8]!.column, 'opening_stock');
      expect(byRow[9]!.column, 'opening_stock');
      expect(byRow[10]!.message, contains('111'));

      final r = await service.apply(p, locationId: loc);
      expect(r.created, 1);
      expect(r.errors, 8);
      expect(await db.select(db.items).get(), hasLength(1));
    });

    test('duplicates inside the file are skipped, barcode clash with existing data is an error', () async {
      final existing = await items.createItem(name: 'Old', baseUnit: 'pcs');
      await items.addVariant(itemId: existing, label: 'x', barcode: '999');
      const csv = 'name,brand,type,gst_percent,retail_price,barcode\n'
          'Twin,Acme,piece,18,10,\n'
          'twin,ACME,piece,18,10,\n' // same name+brand ignoring case
          'Twin,Other,piece,18,10,\n' // different brand: fine
          'Clash,Acme,piece,18,10,999\n';
      final p = await service.preview(csv);
      expect(p.toCreate.map((r) => '${r.name}/${r.brand}'), ['Twin/Acme', 'Twin/Other']);
      expect(p.skipped.single.reason, contains('row 2'));
      expect(p.errors.single.message, contains('999'));
    });

    test('a missing required column or an empty file imports nothing', () async {
      final noPrice = await service.preview('name,type,gst_percent\nWire,length,18\n');
      expect(noPrice.canImport, false);
      expect(noPrice.errors.single.message, contains('retail_price'));
      final empty = await service.preview('');
      expect(empty.canImport, false);
      expect(empty.errors.single.rowNumber, 0);
    });

    test('Excel-style semicolon file with BOM and CRLF imports', () async {
      const csv = '﻿Name;Type;GST Percent;Retail Price;Opening Stock\r\n'
          'Switch;piece;18;15;100\r\n';
      final p = await service.preview(csv);
      expect(p.errors, isEmpty);
      await service.apply(p, locationId: loc);
      final sw = await detailOf('Switch');
      expect(sw.prices['retail'], 1500);
      expect(await stock.balance(itemId: sw.item.id), 100);
    });

    test('a failure part-way rolls the whole import back', () async {
      final p = await service.preview(ItemImportService.templateCsv);
      expect(p.toCreate, hasLength(3));
      // A bad stock location makes the opening-stock insert fail after items were created.
      await expectLater(service.apply(p, locationId: 'no-such-location'), throwsA(anything));
      expect(await db.select(db.items).get(), isEmpty);
      expect(await db.select(db.itemUnits).get(), isEmpty);
      expect(await db.select(db.itemPrices).get(), isEmpty);
      expect(await db.select(db.stockMovements).get(), isEmpty);
      // The outbox has no leftovers from the failed import (only the shop + location setup).
      final out = await db.select(db.outbox).get();
      expect(out.map((o) => o.entity).toSet(), {'shops', 'locations'});
    });

    test('imported items work in billing search and pricing straight away', () async {
      await service.apply(await service.preview(ItemImportService.templateCsv), locationId: loc);
      final byBarcode = await items.search('8901234567890');
      expect(byBarcode.single.item.name, '1.5 sqmm copper wire');
      expect(await items.priceFor(itemId: byBarcode.single.item.id, tier: 'dealer'), 4200);
      expect(await items.priceFor(itemId: byBarcode.single.item.id, tier: 'retail'), 4750);
    });
  });

  group('parties import', () {
    late AppDatabase db;
    late RepoContext ctx;
    late PartyImportService service;
    late LedgerRepository ledger;
    late PartyRepository parties;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      ctx = RepoContext(db, shopId: 'shop1', clock: () => DateTime(2026, 11, 12, 10));
      service = PartyImportService(ctx);
      ledger = LedgerRepository(ctx);
      parties = PartyRepository(ctx);
      await SetupRepository(ctx).createShop(name: 'Test');
    });

    tearDown(() => db.close());

    test('the template imports with the right sign for opening balances', () async {
      final p = await service.preview(PartyImportService.templateCsv);
      expect(p.errors, isEmpty);
      final r = await service.apply(p);
      expect(r.created, 3);

      final ramesh = (await parties.searchCustomers('Ramesh')).single;
      expect(ramesh.tier, 'contractor');
      expect(ramesh.creditLimitPaise, 1000000); // Rs 10,000
      expect(ramesh.stateCode, '27');
      expect(await ledger.balance(ramesh.id), 250000); // owes Rs 2,500

      final sunita = (await parties.searchCustomers('Sunita')).single;
      expect(await ledger.balance(sunita.id), 0);
      expect(await db.select(db.ledgerEntries).get(), hasLength(2)); // zero balance writes no entry

      final supplier = (await parties.searchSuppliers('Sample')).single;
      expect(await ledger.balance(supplier.id), -1500000); // the shop owes Rs 15,000
      expect(supplier.gstin, '27AAAAA0000A1Z5');
    });

    test('re-import skips existing parties and adds no second opening balance', () async {
      await service.apply(await service.preview(PartyImportService.templateCsv));
      final again = await service.preview(PartyImportService.templateCsv);
      expect(again.skipped, hasLength(3));
      final r = await service.apply(again);
      expect(r.created, 0);
      expect(await db.select(db.ledgerEntries).get(), hasLength(2));
    });

    test('bad rows are reported', () async {
      const csv = 'kind,name,phone,gstin,state_code,tier,credit_limit,opening_balance\n'
          'customer,Good,1,,,retail,0,0\n'
          'alien,Bad kind,2,,,retail,0,0\n'
          'customer,,3,,,retail,0,0\n'
          'customer,Bad GSTIN,4,12345,,retail,0,0\n'
          'customer,Bad state,5,,Maharashtra,retail,0,0\n'
          'customer,Bad tier,6,,,vip,0,0\n'
          'customer,Bad amount,7,,,retail,ten,0\n'
          'customer,Blank kind,8,,,,,\n';
      final p = await service.preview(csv);
      expect(p.toCreate.map((r) => r.name), ['Good', 'Blank kind']);
      expect({for (final e in p.errors) e.rowNumber}, {3, 4, 5, 6, 7, 8});
      expect(p.toCreate.last.kind, 'customer'); // blank kind defaults to customer
      expect(p.toCreate.last.tier, 'retail');
    });

    test('same name with a different phone is a different person', () async {
      const csv = 'name,phone\nRamesh,111\nRamesh,222\nRamesh,111\n';
      final p = await service.preview(csv);
      expect(p.toCreate, hasLength(2));
      expect(p.skipped.single.reason, contains('row 2'));
    });

    test('a missing name column or an empty file imports nothing', () async {
      expect((await service.preview('phone\n123\n')).canImport, false);
      expect((await service.preview('')).canImport, false);
    });
  });
}
