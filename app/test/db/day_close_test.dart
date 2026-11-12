import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/return_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/money.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';

/// One whole day worked out on paper, then compared with the Day check:
///
///   Bill A-0001 to Ramesh Rs 259.00 (2.5 m wire + 10 switches, Rs 10 off): Rs 50 cash, Rs 50 UPI, Rs 159 credit
///   Bill A-0002 walk-in, 2 switches Rs 30.00, all cash
///   Return: 1 m wire + 4 switches (Rs 103.50) off Ramesh's account, plus nothing in cash
///   Ramesh pays Rs 30 cash and Rs 20 UPI against his old dues
///   Purchase S-1: 100 m wire at Rs 30 + 18% GST = Rs 3,540.00
///   Paid to the supplier: Rs 1,000 by bank and Rs 200 cash
///   Opening cash Rs 1,000
void main() {
  late AppDatabase db;
  late ShopSession s;
  late ReportsRepository reports;
  final day = DateTime(2026, 3, 10, 11);
  final at = day.add(const Duration(hours: 5));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    s = await ensureShopSession(db);
    reports = ReportsRepository(s.ctx);
    final items = ItemRepository(s.ctx);
    final wire = await items.createItem(name: 'Wire', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
        units: const [ItemUnitInput('m', 1000)]);
    final sw = await items.createItem(name: 'Switch', baseUnit: 'pcs', gstRateBp: 1800, units: const [ItemUnitInput('pcs', 1)]);
    await StockRepository(s.ctx).adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
    await StockRepository(s.ctx).adjust(itemId: sw, locationId: s.locationId, deltaBase: 50, reason: 'Opening stock');
    final parties = PartyRepository(s.ctx);
    final ramesh = await parties.createParty(kind: 'customer', name: 'Ramesh');
    final supplier = await parties.createParty(kind: 'supplier', name: 'Polycab');
    await SettingsRepository(s.ctx).set(SettingKeys.openingCashPaise, '100000');

    final invoices = InvoiceRepository(s.ctx);
    final big = BillCalculator.calculate([
      CartLine(itemId: wire, itemName: 'Wire', unitName: 'm', factorToBase: 1000, qtyEntered: '2.5',
          ratePaise: 4750, priceUnitFactor: 1000, gstRateBp: 1800),
      CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '10',
          ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800, discountPaise: 1000),
    ], interState: false);
    final a1 = await invoices.postInvoice(big.toInvoiceInput(
      deviceId: s.deviceId, series: s.series, number: 1, date: day, locationId: s.locationId, partyId: ramesh,
      payments: [PaymentInput('cash', 5000), PaymentInput('upi', 5000), PaymentInput('credit', 15900)],
    ));
    final small = BillCalculator.calculate([
      CartLine(itemId: sw, itemName: 'Switch', unitName: 'pcs', factorToBase: 1, qtyEntered: '2',
          ratePaise: 1500, priceUnitFactor: 1, gstRateBp: 1800),
    ], interState: false);
    await invoices.postInvoice(small.toInvoiceInput(
      deviceId: s.deviceId, series: s.series, number: 2, date: day.add(const Duration(hours: 1)), locationId: s.locationId,
      payments: [PaymentInput('cash', small.totalPaise)],
    ));

    final returns = ReturnRepository(s.ctx);
    final lines = await returns.returnable(a1);
    await returns.postReturn(PostReturnInput(
      invoiceId: a1,
      deviceId: s.deviceId,
      series: s.series,
      lines: [for (final l in lines) ReturnLineInput(l.line.id, l.itemName == 'Wire' ? '1' : '4')],
      refund: const RefundSplit(accountPaise: 10350),
      createdBy: s.userId,
      approvedBy: s.userId,
      date: at,
    ));

    final ledger = LedgerRepository(s.ctx);
    await ledger.recordCustomerPayment(ramesh, 3000, mode: 'cash', ts: at);
    await ledger.recordCustomerPayment(ramesh, 2000, mode: 'upi', ts: at);
    await PurchaseRepository(s.ctx).postPurchase(PostPurchaseInput(
      supplierId: supplier,
      supplierInvoiceNo: 'S-1',
      supplierInvoiceDate: at,
      locationId: s.locationId,
      lines: [
        PurchaseLineInput(itemId: wire, unitName: 'm', qtyEntered: '100', qtyBase: 100000, ratePaise: 3000,
            priceUnitFactor: 1000, gstRateBp: 1800),
      ],
    ));
    await ledger.recordSupplierPayment(supplier, 100000, mode: 'bank', ts: at);
    await ledger.recordSupplierPayment(supplier, 20000, mode: 'cash', ts: at);
  });
  tearDown(() => db.close());

  test('the whole day against the paper', () async {
    final d = await reports.dayClose(day);

    // Sales: A-0001 Rs 259.00 + A-0002 Rs 30.00 = Rs 289.00, less the Rs 103.50 return
    expect(d.sales.billCount, 2);
    expect(d.sales.grossPaise, 25900 + 3000);
    expect(d.sales.returnsPaise, 10350);
    expect(d.sales.totalPaise, 18550);
    expect(d.sales.returnCount, 1);

    // How customers paid on the bills: cash 50 + 30, UPI 50, credit 159 less the 103.50 taken off
    expect(d.sales.mode('cash'), 5000 + 3000);
    expect(d.sales.mode('upi'), 5000);
    expect(d.sales.mode('credit'), 15900 - 10350);

    // Money from customers against old dues
    expect(d.collectedByMode, {'cash': 3000, 'upi': 2000});
    expect(d.collectedPaise, 5000);

    // Purchases and supplier payments
    expect(d.purchaseCount, 1);
    expect(d.purchaseTotalPaise, 354000);
    expect(d.supplierPaidByMode, {'bank': 100000, 'cash': 20000});
    expect(d.supplierPaidPaise, 120000);

    // Cash in hand: 1,000 + 80 cash sales + 30 collected - 200 paid out
    expect(d.cash.openingPaise, 100000);
    expect(d.cash.cashSalesPaise, 8000);
    expect(d.cash.cashReceiptsPaise, 3000);
    expect(d.cash.cashPaidOutPaise, 20000);
    expect(d.cash.closingPaise, 100000 + 8000 + 3000 - 20000);

    // All money in: cash + UPI on bills, plus what customers paid against dues
    expect(d.receivedPaise, 8000 + 5000 + 5000);
  });

  test('a day with nothing on it is all zero (opening cash carried)', () async {
    final d = await reports.dayClose(DateTime(2026, 3, 20));
    expect(d.sales.billCount, 0);
    expect(d.sales.totalPaise, 0);
    expect(d.collectedByMode, isEmpty);
    expect(d.purchaseCount, 0);
    expect(d.cash.closingPaise, 100000 + 8000 + 3000 - 20000); // the 10th's close is the 20th's open
  });

  test('the shareable summary reads like the paper book', () async {
    final d = await reports.dayClose(day);
    final text = d.toSummary('Pravin Electricals', Money.format, '10 Mar 2026');
    expect(text, startsWith('Pravin Electricals - day check for 10 Mar 2026'));
    expect(text, contains('Bills: 2'));
    expect(text, contains('Sales: ₹289.00'));
    expect(text, contains('Returns and cancels: -₹103.50'));
    expect(text, contains('Net sales: ₹185.50'));
    expect(text, contains('On credit (udhaar): ₹55.50'));
    expect(text, contains('Collected from customers: ₹50.00'));
    expect(text, contains('Purchases entered: 1, ₹3,540.00'));
    expect(text, contains('Paid to suppliers: ₹1,200.00'));
    expect(text, contains('Cash in hand: start ₹1,000.00, now ₹910.00'));
  });
}
