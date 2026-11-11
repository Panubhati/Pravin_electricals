import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';

/// Today's shop, worked out by hand (all amounts in paise, GST-inclusive sales):
///  - 2.5 m wire at Rs 47.50/m = 118.75 -> Rs 119 cash; taxable 100.64, cost 75.00, profit 25.64
///  - 10 switches at Rs 15: Rs 50 UPI + Rs 100 credit to Ramesh; taxable 127.12, cost 90.00, profit 37.12
///  - 2 bulbs at Rs 90 cash (no cost price known)
///  Sales 449.00 in 3 bills. Cash: opening 1,000 + 299 sales + 30 from Ramesh = 1,329.
///  Ramesh owes 100 - 30 cash - 0 = 70.00.
///  Stock after opening 100 m / 23 / 7: wire 97.5 m, switches 13 (below minimum 20), bulbs 5.
Future<void> seedToday(ShopSession s) async {
  final items = ItemRepository(s.ctx);
  final stock = StockRepository(s.ctx);
  final ledger = LedgerRepository(s.ctx);
  final longAgo = DateTime.now().subtract(const Duration(days: 40));

  final wire = await items.createItem(
      name: 'Copper wire 1.5', baseUnit: 'mm', priceUnitFactor: 1000, gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000)]);
  final sw = await items.createItem(
      name: '6A switch', baseUnit: 'pcs', gstRateBp: 1800, minStockBase: 20,
      units: const [ItemUnitInput('pcs', 1)]);
  final bulb = await items.createItem(
      name: 'LED bulb', baseUnit: 'pcs', gstRateBp: 1200, units: const [ItemUnitInput('pcs', 1)]);
  final ramesh = await PartyRepository(s.ctx).createParty(kind: 'customer', name: 'Ramesh');
  await items.setCost(itemId: wire, costPaise: 3000, effectiveFrom: longAgo);
  await items.setCost(itemId: sw, costPaise: 900, effectiveFrom: longAgo);
  await SettingsRepository(s.ctx).set(SettingKeys.openingCashPaise, '100000');

  await stock.adjust(itemId: wire, locationId: s.locationId, deltaBase: 100000, reason: 'Opening stock');
  await stock.adjust(itemId: sw, locationId: s.locationId, deltaBase: 23, reason: 'Opening stock');
  await stock.adjust(itemId: bulb, locationId: s.locationId, deltaBase: 7, reason: 'Opening stock');

  var n = 0;
  Future<void> bill(String itemId, String unit, String qty, int qtyBase, int rate, int factor,
      int gst, List<PaymentInput> Function(int) pay,
      {String? partyId, int roundOff = 0}) async {
    final amount = (qtyBase * rate / factor).round();
    final tax = (amount * gst / (10000 + gst)).round();
    final total = amount + roundOff;
    await InvoiceRepository(s.ctx).postInvoice(PostInvoiceInput(
      deviceId: s.deviceId,
      series: s.series,
      number: ++n,
      date: DateTime.now(),
      locationId: s.locationId,
      partyId: partyId,
      subtotalPaise: amount,
      discountPaise: 0,
      taxPaise: tax,
      roundOffPaise: roundOff,
      totalPaise: total,
      lines: [
        InvoiceLineInput(
          itemId: itemId,
          unitName: unit,
          qtyEntered: qty,
          qtyBase: qtyBase,
          ratePaise: rate,
          priceUnitFactor: factor,
          gstRateBp: gst,
          taxPaise: tax,
          lineTotalPaise: amount,
        ),
      ],
      payments: pay(total),
    ));
  }

  await bill(wire, 'm', '2.5', 2500, 4750, 1000, 1800, (t) => [PaymentInput('cash', t)], roundOff: 25);
  await bill(sw, 'pcs', '10', 10, 1500, 1, 1800,
      (t) => [PaymentInput('upi', 5000), PaymentInput('credit', 10000)], partyId: ramesh);
  await bill(bulb, 'pcs', '2', 2, 9000, 1, 1200, (t) => [PaymentInput('cash', t)]);
  await ledger.recordCustomerPayment(ramesh, 3000, mode: 'cash');
}
