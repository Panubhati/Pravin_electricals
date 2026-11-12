import 'dart:math';

import '../../features/billing/domain/bill_calculator.dart';
import '../bootstrap.dart';
import '../db/repositories/invoice_repository.dart';
import '../db/repositories/item_repository.dart';
import '../db/repositories/ledger_repository.dart';
import '../db/repositories/party_repository.dart';
import '../db/repositories/purchase_repository.dart';
import '../db/repositories/stock_repository.dart';

/// How big the fake shop is. The defaults are the A7 plan: about 400 items, 200
/// customers and 30 days of about 40 bills a day.
class DemoShopConfig {
  const DemoShopConfig({
    this.seed = 42,
    this.items = 400,
    this.customers = 200,
    this.suppliers = 12,
    this.days = 30,
    this.billsPerDay = 40,
  });

  final int seed;
  final int items;
  final int customers;
  final int suppliers;
  final int days;
  final int billsPerDay;
}

/// What was created.
class DemoShopStats {
  const DemoShopStats({
    required this.items,
    required this.customers,
    required this.suppliers,
    required this.bills,
    required this.purchases,
    required this.payments,
    required this.elapsed,
  });
  final int items, customers, suppliers, bills, purchases, payments;
  final Duration elapsed;

  @override
  String toString() =>
      '$items items, $customers customers, $suppliers suppliers, $bills bills, $purchases purchases, '
      '$payments payments in ${elapsed.inSeconds}s';
}

/// Fills an empty shop with realistic, repeatable fake data, using the same
/// repositories as the real screens, so the result is a true copy of what a busy
/// shop's database looks like. For speed tests only; debug builds and tests.
class DemoShop {
  static const _wireSizes = ['1.0', '1.5', '2.5', '4', '6', '10'];
  static const _wireBrands = ['Polycab', 'Havells', 'Finolex', 'RR Kabel', 'Anchor'];
  static const _wireColours = ['Red', 'Black', 'Blue'];
  static const _switchTypes = [
    '6A switch', '16A switch', '2-way switch', '6A socket', '16A socket', 'Modular plate 2M',
    'Modular plate 4M', 'Fan regulator', 'Bell push', 'Dimmer', 'USB socket', 'Blank plate',
  ];
  static const _switchBrands = ['Anchor', 'Legrand', 'Havells', 'Schneider', 'Crabtree'];
  static const _mcbRatings = ['6A', '10A', '16A', '20A', '25A', '32A', '40A', '63A'];
  static const _mcbBrands = ['Havells', 'Schneider', 'Legrand', 'L&T'];
  static const _lightWatts = ['3W', '5W', '7W', '9W', '12W', '15W', '18W', '22W', '30W', '40W'];
  static const _lightBrands = ['Philips', 'Syska', 'Wipro', 'Havells', 'Crompton', 'Bajaj'];
  static const _accessories = [
    'Junction box', 'Conduit pipe', 'Insulation tape', 'Cable tie', 'Batten holder', 'Extension board',
    'Doorbell', 'Fuse wire', 'Earthing rod', 'Clamp', 'Gang box', 'Cable clip', 'Terminal block',
    'Wire connector', 'Switch board', 'Meter box', 'PVC elbow', 'PVC coupler', 'Cable gland', 'Lug',
  ];
  static const _firstNames = [
    'Ramesh', 'Suresh', 'Anil', 'Kiran', 'Sunita', 'Patil', 'Deshmukh', 'Shinde', 'Jadhav', 'More',
    'Kulkarni', 'Pawar', 'Gaikwad', 'Joshi', 'Bhosale', 'Sharma', 'Verma', 'Khan', 'Shaikh', 'Naik',
  ];
  static const _suffixes = ['Electricals', 'Traders', 'Wiring Works', 'Hardware', 'Builders', 'Electric Co', 'Enterprises'];

  /// Creates the whole demo shop. [onProgress] gets a 0 to 1 fraction and a short label.
  static Future<DemoShopStats> load(
    ShopSession s, {
    DemoShopConfig config = const DemoShopConfig(),
    void Function(double fraction, String label)? onProgress,
  }) async {
    final watch = Stopwatch()..start();
    final rng = Random(config.seed);
    final items = ItemRepository(s.ctx);
    final parties = PartyRepository(s.ctx);
    final stock = StockRepository(s.ctx);
    final ledger = LedgerRepository(s.ctx);
    final invoices = InvoiceRepository(s.ctx);
    final purchases = PurchaseRepository(s.ctx);
    final db = s.ctx.db;
    void say(double f, String l) => onProgress?.call(f, l);

    // ---- items ---------------------------------------------------------------
    say(0.0, 'Creating items');
    final specs = _itemSpecs(config.items, rng);
    final demoItems = <_DemoItem>[];
    await db.transaction(() async {
      for (var n = 0; n < specs.length; n++) {
        final sp = specs[n];
        final id = await items.createItem(
          name: sp.name,
          brand: sp.brand,
          category: sp.category,
          hsn: sp.length ? '8544' : '8536',
          baseUnit: sp.length ? 'mm' : 'pcs',
          priceUnitFactor: sp.length ? 1000 : 1,
          gstRateBp: sp.gst,
          minStockBase: sp.length ? 50000 : 10,
          units: sp.length ? const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)] : const [ItemUnitInput('box', 10)],
        );
        final retail = sp.retail;
        await items.setPrice(itemId: id, tier: 'retail', ratePaise: retail);
        await items.setPrice(itemId: id, tier: 'contractor', ratePaise: retail * 93 ~/ 100);
        await items.setPrice(itemId: id, tier: 'dealer', ratePaise: retail * 88 ~/ 100);
        await items.setCost(itemId: id, costPaise: retail * 70 ~/ 100, effectiveFrom: DateTime.now().subtract(Duration(days: config.days + 30)));
        // Every fifth item has a barcode, as when a shop scans some of its stock.
        if (n % 5 == 0) {
          await items.addVariant(itemId: id, label: 'Standard', barcode: '89${(1000000000 + n).toString()}');
        }
        final opening = sp.length ? (100 + rng.nextInt(700)) * 1000 : 20 + rng.nextInt(280);
        await stock.adjust(
            itemId: id, locationId: s.locationId, deltaBase: opening, reason: 'Opening stock');
        demoItems.add(_DemoItem(id, sp));
      }
    });

    // ---- people --------------------------------------------------------------
    say(0.1, 'Creating customers and suppliers');
    final customers = <_DemoCustomer>[];
    await db.transaction(() async {
      for (var n = 0; n < config.customers; n++) {
        final tier = rng.nextInt(10) < 6 ? 'retail' : (rng.nextInt(10) < 7 ? 'contractor' : 'dealer');
        final name = '${_firstNames[rng.nextInt(_firstNames.length)]} ${_suffixes[rng.nextInt(_suffixes.length)]} ${n + 1}';
        final id = await parties.createParty(
          kind: 'customer',
          name: name,
          tier: tier,
          phone: '98${(10000000 + n).toString().padLeft(8, '0')}',
          creditLimitPaise: tier == 'retail' ? 500000 : 5000000,
        );
        customers.add(_DemoCustomer(id, tier));
      }
    });
    final suppliers = <String>[];
    await db.transaction(() async {
      for (var n = 0; n < config.suppliers; n++) {
        suppliers.add(await parties.createParty(
            kind: 'supplier', name: 'Supplier ${n + 1} Distributors', phone: '97${(10000000 + n).toString().padLeft(8, '0')}'));
      }
    });

    // ---- days of trading -------------------------------------------------------
    var billCount = 0, purchaseCount = 0, paymentCount = 0;
    var number = await invoices.nextNumber(s.deviceId, s.series);
    final owing = <String, int>{}; // customer id -> paise owed from demo credit bills
    final today = DateTime.now();

    for (var d = config.days - 1; d >= 0; d--) {
      say(0.15 + 0.8 * (config.days - 1 - d) / config.days, 'Day ${config.days - d} of ${config.days}');
      final day = DateTime(today.year, today.month, today.day - d);
      final bills = config.billsPerDay - 8 + rng.nextInt(17);
      await db.transaction(() async {
        // Weekly restock from suppliers (never on the very first day).
        if ((config.days - 1 - d) % 7 == 3) {
          for (var p = 0; p < 3; p++) {
            final lines = <PurchaseLineInput>[];
            for (var l = 0; l < 8; l++) {
              final it = demoItems[rng.nextInt(demoItems.length)];
              if (lines.any((x) => x.itemId == it.id)) continue;
              final qty = it.spec.length ? 90 + rng.nextInt(180) : 20 + rng.nextInt(100);
              lines.add(PurchaseLineInput(
                itemId: it.id,
                unitName: it.spec.length ? 'm' : 'pcs',
                qtyEntered: '$qty',
                qtyBase: it.spec.length ? qty * 1000 : qty,
                ratePaise: it.spec.retail * 70 ~/ 100,
                priceUnitFactor: it.spec.length ? 1000 : 1,
                gstRateBp: it.spec.gst,
              ));
            }
            await purchases.postPurchase(PostPurchaseInput(
              supplierId: suppliers[rng.nextInt(suppliers.length)],
              supplierInvoiceNo: 'D${config.days - d}-${p + 1}',
              supplierInvoiceDate: day.add(const Duration(hours: 10)),
              locationId: s.locationId,
              lines: lines,
            ));
            purchaseCount++;
          }
        }

        for (var b = 0; b < bills; b++) {
          final when = day.add(Duration(minutes: 9 * 60 + (b * 660 ~/ bills) + rng.nextInt(5)));
          final customer = rng.nextInt(100) < 45 ? customers[rng.nextInt(customers.length)] : null;
          final tier = customer?.tier ?? 'retail';
          final lineCount = 1 + rng.nextInt(4);
          final chosen = <_DemoItem>{};
          while (chosen.length < lineCount) {
            chosen.add(demoItems[rng.nextInt(demoItems.length)]);
          }
          final cart = <CartLine>[];
          for (final it in chosen) {
            final rate = it.spec.retail * (tier == 'retail' ? 100 : (tier == 'contractor' ? 93 : 88)) ~/ 100;
            cart.add(CartLine(
              itemId: it.id,
              itemName: it.spec.name,
              unitName: it.spec.length ? 'm' : 'pcs',
              factorToBase: it.spec.length ? 1000 : 1,
              qtyEntered: it.spec.length ? '${1 + rng.nextInt(30)}${rng.nextBool() ? '.5' : ''}' : '${1 + rng.nextInt(12)}',
              ratePaise: rate,
              priceUnitFactor: it.spec.length ? 1000 : 1,
              gstRateBp: it.spec.gst,
              discountPaise: rng.nextInt(20) == 0 ? 100 : 0,
            ));
          }
          final totals = BillCalculator.calculate(cart, interState: false);
          final total = totals.totalPaise;
          final payments = _payments(rng, total, customer != null);
          final credit = payments.where((p) => p.mode == 'credit').fold<int>(0, (a, p) => a + p.amountPaise);
          await invoices.postInvoice(totals.toInvoiceInput(
            deviceId: s.deviceId,
            series: s.series,
            number: number++,
            date: when,
            locationId: s.locationId,
            payments: payments,
            partyId: customer?.id,
            createdBy: s.userId,
          ));
          billCount++;
          if (credit > 0) owing[customer!.id] = (owing[customer.id] ?? 0) + credit;
        }

        // A few customers settle part or all of what they owe each day.
        final debtors = owing.keys.toList();
        for (var p = 0; p < 6 && debtors.isNotEmpty; p++) {
          final id = debtors[rng.nextInt(debtors.length)];
          final owed = owing[id]!;
          if (owed <= 0) continue;
          final pay = rng.nextBool() ? owed : (owed ~/ 2).clamp(100, owed);
          await ledger.recordCustomerPayment(id, pay,
              mode: rng.nextBool() ? 'cash' : 'upi', ts: day.add(const Duration(hours: 18)));
          owing[id] = owed - pay;
          paymentCount++;
        }
      });
    }

    watch.stop();
    say(1.0, 'Done');
    return DemoShopStats(
      items: demoItems.length,
      customers: customers.length,
      suppliers: suppliers.length,
      bills: billCount,
      purchases: purchaseCount,
      payments: paymentCount,
      elapsed: watch.elapsed,
    );
  }

  static List<PaymentInput> _payments(Random rng, int total, bool hasCustomer) {
    final r = rng.nextInt(100);
    if (!hasCustomer) {
      return r < 70 ? [PaymentInput('cash', total)] : [PaymentInput('upi', total)];
    }
    if (r < 40) return [PaymentInput('cash', total)];
    if (r < 60) return [PaymentInput('upi', total)];
    if (r < 85) return [PaymentInput('credit', total)];
    final cash = total ~/ 3;
    return [if (cash > 0) PaymentInput('cash', cash), PaymentInput('credit', total - cash)];
  }

  static List<_ItemSpec> _itemSpecs(int count, Random rng) {
    final out = <_ItemSpec>[];
    for (final size in _wireSizes) {
      for (final brand in _wireBrands) {
        for (final colour in _wireColours) {
          out.add(_ItemSpec('$size sqmm copper wire $colour', brand, 'Wire', true, 1800,
              (double.parse(size) * 2100 + rng.nextInt(500)).round()));
        }
      }
    }
    for (final t in _switchTypes) {
      for (final b in _switchBrands) {
        out.add(_ItemSpec('$t $b', b, 'Switches', false, 1800, 1200 + rng.nextInt(12000)));
      }
    }
    for (final r in _mcbRatings) {
      for (final b in _mcbBrands) {
        out.add(_ItemSpec('MCB $r SP $b', b, 'MCB', false, 1800, 15000 + rng.nextInt(120000)));
      }
    }
    for (final w in _lightWatts) {
      for (final b in _lightBrands) {
        out.add(_ItemSpec('LED bulb $w $b', b, 'Lighting', false, 1200, 5000 + rng.nextInt(60000)));
      }
    }
    var n = 1;
    while (out.length < count) {
      final a = _accessories[rng.nextInt(_accessories.length)];
      out.add(_ItemSpec('$a size $n', 'Generic', 'Accessories', false, 1800, 1500 + rng.nextInt(40000)));
      n++;
    }
    return out.take(count).toList();
  }
}

class _ItemSpec {
  const _ItemSpec(this.name, this.brand, this.category, this.length, this.gst, this.retail);
  final String name, brand, category;

  /// Cable sold by the metre (stored in millimetres), otherwise pieces.
  final bool length;
  final int gst;

  /// Retail price in paise per metre or piece.
  final int retail;
}

class _DemoItem {
  const _DemoItem(this.id, this.spec);
  final String id;
  final _ItemSpec spec;
}

class _DemoCustomer {
  const _DemoCustomer(this.id, this.tier);
  final String id, tier;
}
