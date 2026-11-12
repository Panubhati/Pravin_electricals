import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

/// Cancel purchase (A8), worked by hand:
///   10 switches at Rs 10.00 ex-GST, GST 18%  ->  taxable 100.00 + GST 18.00 = Rs 118.00
///   The supplier is owed Rs 118 (ledger -11800). Stock +10.
///   Cancelling: stock -10 (purchase return), supplier account +11800 (adjustment),
///   so both are back where they were, and the purchase reads "cancelled".
void main() {
  late AppDatabase db;
  late ShopSession s;
  late PurchaseRepository purchases;
  late String supplier, sw;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    purchases = PurchaseRepository(s.ctx);
    supplier = await PartyRepository(s.ctx).createParty(kind: 'supplier', name: 'Havells Distributor');
    sw = await ItemRepository(s.ctx).createItem(name: '6A switch', baseUnit: 'pcs', gstRateBp: 1800);
  });
  tearDown(() => db.close());

  Future<String> buy({String no = 'HV-101', DateTime? date}) => purchases.postPurchase(PostPurchaseInput(
        supplierId: supplier,
        supplierInvoiceNo: no,
        supplierInvoiceDate: date ?? DateTime.now(),
        locationId: s.locationId,
        lines: [
          PurchaseLineInput(itemId: sw, unitName: 'pcs', qtyEntered: '10', qtyBase: 10, ratePaise: 1000, priceUnitFactor: 1, gstRateBp: 1800),
        ],
      ));

  test('cancelling takes the stock back out and clears what the supplier is owed', () async {
    final id = await buy();
    final stock = StockRepository(s.ctx), ledger = LedgerRepository(s.ctx);
    expect(await stock.balance(itemId: sw), 10);
    expect(await ledger.balance(supplier), -11800);

    await purchases.cancelPurchase(id, reason: 'Entered on both phones', createdBy: s.userId);

    expect(await stock.balance(itemId: sw), 0);
    expect(await ledger.balance(supplier), 0);
    final p = (await purchases.details(id)).purchase;
    expect(p.status, 'cancelled');
    final audit = await (db.select(db.auditLog)..where((a) => a.action.equals('purchase_cancelled'))).getSingle();
    expect(audit.afterJson, contains('Entered on both phones'));
    final check = await DataCheckRepository(s.ctx).run();
    expect(check.passed, isTrue, reason: check.errors.map((e) => e.message).join('; '));
  });

  test('a purchase cannot be cancelled twice', () async {
    final id = await buy();
    await purchases.cancelPurchase(id);
    await expectLater(purchases.cancelPurchase(id), throwsA(isA<DomainException>()));
  });

  test('after cancelling, the same supplier bill can be entered again; while standing it cannot', () async {
    final id = await buy();
    await expectLater(buy(), throwsA(isA<DuplicatePurchaseException>()));
    await purchases.cancelPurchase(id);
    await buy();
    expect(await StockRepository(s.ctx).balance(itemId: sw), 10);
  });

  test('the same bill arriving from the other phone is flagged, and cancelling one clears the flag', () async {
    final a = await buy();
    // A copy made on the other phone (it arrives through sync, not postPurchase).
    final other = RepoContext(db, shopId: s.shopId)..originDeviceId = 'phone-b';
    await db.customStatement("UPDATE purchases SET supplier_invoice_no = 'HV-temp' WHERE id = '$a'");
    final b = await PurchaseRepository(other).postPurchase(PostPurchaseInput(
      supplierId: supplier,
      supplierInvoiceNo: 'HV-101',
      supplierInvoiceDate: DateTime.now(),
      locationId: s.locationId,
      lines: [PurchaseLineInput(itemId: sw, unitName: 'pcs', qtyEntered: '10', qtyBase: 10, ratePaise: 1000, priceUnitFactor: 1, gstRateBp: 1800)],
    ));
    await db.customStatement("UPDATE purchases SET supplier_invoice_no = 'HV-101' WHERE id = '$a'");

    expect(await purchases.duplicatedPurchaseIds(), {a, b});
    final check = await DataCheckRepository(s.ctx).run();
    expect(check.warnings.map((w) => w.code), contains('purchase_duplicate'));
    expect(check.passed, isTrue, reason: 'a duplicate is a warning, not an error');

    await purchases.cancelPurchase(b);
    expect(await purchases.duplicatedPurchaseIds(), isEmpty);
    expect(await StockRepository(s.ctx).balance(itemId: sw), 10);
    expect(await LedgerRepository(s.ctx).balance(supplier), -11800);
  });

  test('the day check counts only purchases still standing', () async {
    final keep = await buy(no: 'HV-1');
    final drop = await buy(no: 'HV-2');
    await purchases.cancelPurchase(drop);
    final day = await ReportsRepository(s.ctx).dayClose(DateTime.now());
    expect(day.purchaseCount, 1);
    expect(day.purchaseTotalPaise, 11800);
    expect(keep, isNotEmpty);
  });

  test('Check my data notices a cancelled purchase that was not fully reversed', () async {
    final id = await buy();
    await purchases.cancelPurchase(id);
    await db.customStatement("DELETE FROM ledger_entries WHERE entry_type = 'adjustment' AND ref_id = '$id'");
    final check = await DataCheckRepository(s.ctx).run();
    expect(check.errors.map((e) => e.code), contains('purchase_cancel'));
  });
}
