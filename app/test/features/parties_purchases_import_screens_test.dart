import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/import/file_service.dart';
import 'package:shop_app/core/import/item_import.dart';
import 'package:shop_app/core/import/party_import.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/import/import_screen.dart';
import 'package:shop_app/features/parties/dues_screen.dart';
import 'package:shop_app/features/parties/parties_screen.dart';
import 'package:shop_app/features/purchase/purchases_screen.dart';

import '../helpers/app_harness.dart';

String _text(WidgetTester t, Key key) => t.widget<Text>(find.byKey(key)).data!;

/// A file picker that returns canned text instead of opening Android dialogs.
class FakeFileService implements FileService {
  FakeFileService({this.csv, this.error});
  String? csv;
  Object? error;
  String? savedName;
  String? savedContent;

  @override
  Future<String?> pickCsvText() async {
    if (error != null) throw error!;
    return csv;
  }

  @override
  Future<bool> saveText({required String fileName, required String content}) async {
    savedName = fileName;
    savedContent = content;
    return true;
  }
}

void main() {
  group('home', () {
    harnessTest('every A3 tile opens its screen', (tester, h) async {
      await h.pump(tester, const HomeScreen());
      for (final (tile, marker) in [
        ('tile_purchases', const Key('newPurchase')),
        ('tile_customers', const Key('addParty')),
        ('tile_suppliers', const Key('addParty')),
        ('tile_import', const Key('importItemsTile')),
      ]) {
        await tester.tap(find.byKey(Key(tile)));
        await settle(tester);
        expect(find.byKey(marker), findsOneWidget, reason: tile);
        await tester.pageBack();
        await settle(tester);
      }
      await tester.tap(find.byKey(const Key('tile_dues')));
      await settle(tester);
      expect(find.byKey(const Key('tabReceivables')), findsOneWidget);
    });
  });

  group('customers, payments and dues', () {
    harnessTest('add a customer with an opening balance, then record a UPI payment', (tester, h) async {
      await h.pump(tester, const PartiesScreen(kind: 'customer'));
      expect(find.text('Ramesh Electricals'), findsOneWidget);

      await tester.tap(find.byKey(const Key('addParty')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('partyName')), 'New Customer');
      await tester.enterText(find.byKey(const Key('partyPhone')), '9990001111');
      await tester.enterText(find.byKey(const Key('partyOpening')), '2500');
      await tester.tap(find.byKey(const Key('saveParty')));
      await settle(tester);

      // Back on the list: the new customer owes Rs 2,500.
      expect(find.text('New Customer'), findsOneWidget);
      expect(find.text('Owes you ₹2,500.00'), findsOneWidget);

      late String id;
      await db(tester, () async {
        final p = (await PartyRepository(h.session.ctx).searchCustomers('New Customer')).single;
        id = p.id;
        expect(await LedgerRepository(h.session.ctx).balance(id), 250000);
      });

      await tester.tap(find.byKey(Key('party_$id')));
      await settle(tester);
      expect(_text(tester, const Key('partyBalance')), 'Owes you ₹2,500.00');

      await tester.tap(find.byKey(const Key('paymentButton')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('payAmount')), '1000');
      await tester.tap(find.byKey(const Key('mode_upi')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('paySave')));
      await settle(tester);

      expect(_text(tester, const Key('partyBalance')), 'Owes you ₹1,500.00');
      expect(find.text('Payment received'), findsOneWidget);
      expect(find.text('Opening balance'), findsOneWidget);

      await db(tester, () async {
        final rows = await h.db.select(h.db.ledgerEntries).get();
        final pay = rows.singleWhere((r) => r.entryType == 'payment');
        expect(pay.amountPaise, -100000);
        expect(pay.paymentMode, 'upi');
      });

      // Back on the list the balance has updated too.
      await tester.pageBack();
      await settle(tester);
      expect(find.text('Owes you ₹1,500.00'), findsOneWidget);
    });

    harnessTest('a 40-day-old credit sale shows in the 31-60 bucket; paying it clears the dues', (tester, h) async {
      late String ramesh;
      await db(tester, () async {
        ramesh = (await PartyRepository(h.session.ctx).searchCustomers('Ramesh')).single.id;
        await LedgerRepository(h.session.ctx).addEntry(
          partyId: ramesh,
          entryType: 'invoice',
          amountPaise: 20000,
          ts: DateTime.now().subtract(const Duration(days: 40)),
        );
      });
      await h.pump(tester, const DuesScreen());

      expect(_text(tester, const Key('duesTotal_receivables')), '₹200.00');
      expect(find.text('31-60 days: ₹200.00'), findsWidgets);
      expect(find.text('Ramesh Electricals'), findsOneWidget);

      await tester.tap(find.byKey(Key('due_$ramesh')));
      await settle(tester);
      expect(_text(tester, const Key('partyBalance')), 'Owes you ₹200.00');
      await tester.tap(find.byKey(const Key('paymentButton')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('payAmount')), '200');
      await tester.tap(find.byKey(const Key('paySave')));
      await settle(tester);
      expect(_text(tester, const Key('partyBalance')), 'Settled');

      await tester.pageBack();
      await settle(tester);
      expect(find.text('Nothing outstanding.'), findsWidgets);
    });

    harnessTest('suppliers: the shop owes the supplier after a purchase, and paying reduces it', (tester, h) async {
      await h.pump(tester, const PartiesScreen(kind: 'supplier'));
      // Sample data bought stock from this supplier on credit.
      expect(find.textContaining('You owe'), findsOneWidget);

      late String id;
      await db(tester, () async {
        id = (await PartyRepository(h.session.ctx).searchSuppliers('Sample')).single.id;
      });
      await tester.tap(find.byKey(Key('party_$id')));
      await settle(tester);
      expect(find.byKey(const Key('supplierPaymentButton')), findsOneWidget);
      expect(find.byKey(const Key('paymentButton')), findsNothing);
      final before = await tester.runAsync(() => LedgerRepository(h.session.ctx).balance(id));

      await tester.tap(find.byKey(const Key('supplierPaymentButton')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('payAmount')), '1000');
      await tester.tap(find.byKey(const Key('mode_bank')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('paySave')));
      await settle(tester);
      final after = await tester.runAsync(() => LedgerRepository(h.session.ctx).balance(id));
      expect(after, before! + 100000); // the debt shrinks by Rs 1,000
      expect(find.text('Payment made'), findsOneWidget);
    });
  });

  group('purchases', () {
    harnessTest('enter a supplier bill in rolls: stock, supplier balance and cost follow', (tester, h) async {
      late String wireId;
      late String supplierId;
      late int stockBefore;
      late int owedBefore;
      await db(tester, () async {
        wireId = (await ItemRepository(h.session.ctx).search('1.5 sqmm')).first.item.id;
        supplierId = (await PartyRepository(h.session.ctx).searchSuppliers('Sample')).single.id;
        stockBefore = await StockRepository(h.session.ctx).balance(itemId: wireId);
        owedBefore = await LedgerRepository(h.session.ctx).balance(supplierId);
      });

      await h.pump(tester, const PurchasesScreen());
      await tester.tap(find.byKey(const Key('newPurchase')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('supplierTile')));
      await settle(tester);
      await tester.tap(find.text('Sample Supplier'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('purchaseNo')), 'P-100');
      await tester.enterText(find.byKey(const Key('purchaseSearch')), '1.5 sqmm');
      await settle(tester);
      await tester.tap(find.byKey(const Key('presult_0')));
      await settle(tester);

      // Defaults: the roll unit, the last cost (Rs 30/m) and the item's GST (18%).
      expect(tester.widget<TextField>(find.byKey(const Key('prate_0'))).controller!.text, '30.00');
      expect(tester.widget<TextField>(find.byKey(const Key('pgst_0'))).controller!.text, '18');
      await tester.enterText(find.byKey(const Key('pqty_0')), '2');
      await tester.pump();
      // 2 rolls = 180 m x Rs 30 = 5,400 + 18% GST 972 = 6,372
      expect(_text(tester, const Key('purchaseTotal')), '₹6,372.00');

      await tester.tap(find.byKey(const Key('savePurchase')));
      await settle(tester);

      // Back on the list: the sample purchase and the new one, newest first.
      expect(find.text('Sample Supplier'), findsNWidgets(2));
      expect(find.text('P-100  •  ${_today()}'), findsOneWidget);

      await db(tester, () async {
        expect(await StockRepository(h.session.ctx).balance(itemId: wireId), stockBefore + 180000);
        expect(await LedgerRepository(h.session.ctx).balance(supplierId), owedBefore - 637200);
      });

      // Detail screen is read-only and shows the lines and totals.
      await tester.tap(find.text('Sample Supplier').first);
      await settle(tester);
      expect(find.text('1.5 sqmm copper wire'), findsOneWidget);
      expect(find.textContaining('2 roll'), findsOneWidget);
      expect(find.text('₹6,372.00'), findsWidgets);
    });

    harnessTest('the same supplier bill number cannot be entered twice', (tester, h) async {
      await h.pump(tester, const PurchasesScreen());
      Future<void> enter(String no) async {
        await tester.tap(find.byKey(const Key('newPurchase')));
        await settle(tester);
        await tester.tap(find.byKey(const Key('supplierTile')));
        await settle(tester);
        await tester.tap(find.text('Sample Supplier'));
        await settle(tester);
        await tester.enterText(find.byKey(const Key('purchaseNo')), no);
        await tester.enterText(find.byKey(const Key('purchaseSearch')), 'MCB');
        await settle(tester);
        await tester.tap(find.byKey(const Key('presult_0')));
        await settle(tester);
        ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last)).hideCurrentSnackBar();
        await settle(tester);
        await tester.tap(find.byKey(const Key('savePurchase')));
        await settle(tester);
      }

      await enter('DUP-1');
      expect(find.text('DUP-1  •  ${_today()}'), findsOneWidget);
      await enter('DUP-1');
      // Still on the form, with a plain message; nothing was saved twice.
      expect(find.text('Supplier invoice DUP-1 was already entered.'), findsOneWidget);
      expect(find.byKey(const Key('savePurchase')), findsOneWidget);
      await db(tester, () async {
        final dups = (await h.db.select(h.db.purchases).get()).where((p) => p.supplierInvoiceNo == 'DUP-1');
        expect(dups, hasLength(1));
      });
    });

    harnessTest('a purchase needs a supplier, a bill number and a rate', (tester, h) async {
      await h.pump(tester, const PurchasesScreen());
      await tester.tap(find.byKey(const Key('newPurchase')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('savePurchase')));
      await settle(tester);
      expect(find.text('Choose supplier'), findsWidgets); // toast + tile text
      await tester.tap(find.byKey(const Key('supplierTile')));
      await settle(tester);
      await tester.tap(find.text('Sample Supplier'));
      await settle(tester);
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last)).hideCurrentSnackBar();
      await settle(tester);
      await tester.tap(find.byKey(const Key('savePurchase')));
      await settle(tester);
      expect(find.text('Enter the supplier bill number'), findsOneWidget);
    });
  });

  group('import screens', () {
    harnessTest('template download works, and items that already exist are skipped', (tester, h) async {
      final files = FakeFileService(csv: ItemImportService.templateCsv);
      await h.pump(tester, const ImportFlowScreen(kind: ImportKind.items),
          overrides: [fileServiceProvider.overrideWithValue(files)]);

      await tester.tap(find.byKey(const Key('downloadTemplate')));
      await settle(tester);
      expect(files.savedName, 'items_template.csv');
      expect(files.savedContent, ItemImportService.templateCsv);

      // The sample shop already has these three items.
      await tester.tap(find.byKey(const Key('chooseFile')));
      await settle(tester);
      expect(_text(tester, const Key('importSummary')),
          '3 rows in the file: 0 will be imported, 3 skipped, 0 need fixing.');
      expect(tester.widget<FilledButton>(find.byKey(const Key('importNow'))).onPressed, isNull);
    });

    harnessTest('items on a fresh shop: 3 created with opening stock', (tester, h) async {
      final files = FakeFileService(csv: ItemImportService.templateCsv);
      await h.pump(tester, const ImportFlowScreen(kind: ImportKind.items),
          overrides: [fileServiceProvider.overrideWithValue(files)]);
      await tester.tap(find.byKey(const Key('chooseFile')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('importNow')));
      await settle(tester);
      expect(_text(tester, const Key('importResult')), contains('Imported 3.'));
      await db(tester, () async {
        final stock = await StockRepository(h.session.ctx).balancesByItem();
        expect(stock.values.toSet(), {450000, 200, 40});
      });
    }, sample: false);

    harnessTest('a file with problems lists each one and imports only the good rows', (tester, h) async {
      const csv = 'name,type,gst_percent,retail_price\n'
          'Good,piece,18,100\n'
          'Bad GST,piece,180,100\n'
          'No price,piece,18,\n';
      final files = FakeFileService(csv: csv);
      await h.pump(tester, const ImportFlowScreen(kind: ImportKind.items),
          overrides: [fileServiceProvider.overrideWithValue(files)]);
      await tester.tap(find.byKey(const Key('chooseFile')));
      await settle(tester);
      expect(_text(tester, const Key('importSummary')),
          '3 rows in the file: 1 will be imported, 0 skipped, 2 need fixing.');
      expect(find.textContaining('Row 3 (gst_percent)'), findsOneWidget);
      expect(find.textContaining('Row 4 (retail_price)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('importNow')));
      await settle(tester);
      expect(_text(tester, const Key('importResult')), contains('Imported 1.'));
      expect(_text(tester, const Key('importResult')), contains('2 rows had problems'));
    }, sample: false);

    harnessTest('picking an Excel file gives a plain message and nothing is shown', (tester, h) async {
      final files = FakeFileService(error: const FormatException('This looks like an Excel file.'));
      await h.pump(tester, const ImportFlowScreen(kind: ImportKind.items),
          overrides: [fileServiceProvider.overrideWithValue(files)]);
      await tester.tap(find.byKey(const Key('chooseFile')));
      await settle(tester);
      expect(find.text('This looks like an Excel file.'), findsOneWidget);
      expect(find.byKey(const Key('importNow')), findsNothing);
    }, sample: false);

    harnessTest('customers and suppliers: opening balances land in the ledger with the right sign', (tester, h) async {
      final files = FakeFileService(csv: PartyImportService.templateCsv);
      await h.pump(tester, const ImportFlowScreen(kind: ImportKind.parties),
          overrides: [fileServiceProvider.overrideWithValue(files)]);
      await tester.tap(find.byKey(const Key('chooseFile')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('importNow')));
      await settle(tester);
      expect(_text(tester, const Key('importResult')), contains('Imported 3.'));
      await db(tester, () async {
        final ledger = LedgerRepository(h.session.ctx);
        final parties = PartyRepository(h.session.ctx);
        expect(await ledger.balance((await parties.searchCustomers('Ramesh')).single.id), 250000);
        expect(await ledger.balance((await parties.searchSuppliers('Sample')).single.id), -1500000);
      });
    }, sample: false);

    harnessTest('importing the same parties file again is safe', (tester, h) async {
      final files = FakeFileService(csv: PartyImportService.templateCsv);
      Future<void> run() async {
        await h.pump(tester, const ImportFlowScreen(kind: ImportKind.parties),
            overrides: [fileServiceProvider.overrideWithValue(files)]);
        await tester.tap(find.byKey(const Key('chooseFile')));
        await settle(tester);
        if (find.byKey(const Key('importNow')).evaluate().isNotEmpty) {
          final b = tester.widget<FilledButton>(find.byKey(const Key('importNow')));
          if (b.onPressed != null) {
            await tester.tap(find.byKey(const Key('importNow')));
            await settle(tester);
          }
        }
      }

      await run();
      await run();
      expect(_text(tester, const Key('importSummary')),
          '3 rows in the file: 0 will be imported, 3 skipped, 0 need fixing.');
      await db(tester, () async {
        expect(await h.db.select(h.db.parties).get(), hasLength(3));
        expect(await h.db.select(h.db.ledgerEntries).get(), hasLength(2));
      });
    }, sample: false);
  });
}

String _today() {
  final d = DateTime.now();
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
