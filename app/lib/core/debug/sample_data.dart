import '../db/repositories/item_repository.dart';
import '../db/repositories/party_repository.dart';
import '../db/repositories/purchase_repository.dart';
import '../db/repositories/repo_context.dart';
import '../db/repositories/setup_repository.dart';

/// Sample items, prices, customers and opening stock for testing billing before
/// the item screens exist (A3). Shown only in debug builds.
abstract final class SampleData {
  /// Loads the data once. Returns false if items already exist.
  static Future<bool> load(RepoContext ctx, {required String locationId}) async {
    final existing = await ctx.db.select(ctx.db.items).get();
    if (existing.isNotEmpty) return false;

    final items = ItemRepository(ctx);
    final parties = PartyRepository(ctx);
    final purchases = PurchaseRepository(ctx);
    // ignore: unused_local_variable
    final setup = SetupRepository(ctx);

    // Cable: base unit mm, priced per metre, sold by metre or 90 m roll.
    final wire15 = await items.createItem(
      name: '1.5 sqmm copper wire',
      brand: 'Polycab',
      category: 'Wire',
      hsn: '8544',
      baseUnit: 'mm',
      priceUnitFactor: 1000,
      gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)],
    );
    await items.addVariant(itemId: wire15, label: 'Red', barcode: '8900000000011');
    await items.addVariant(itemId: wire15, label: 'Black', barcode: '8900000000028');
    await items.setPrice(itemId: wire15, tier: 'retail', ratePaise: 4750);
    await items.setPrice(itemId: wire15, tier: 'contractor', ratePaise: 4400);
    await items.setPrice(itemId: wire15, tier: 'dealer', ratePaise: 4200);

    final wire25 = await items.createItem(
      name: '2.5 sqmm copper wire',
      brand: 'Polycab',
      category: 'Wire',
      hsn: '8544',
      baseUnit: 'mm',
      priceUnitFactor: 1000,
      gstRateBp: 1800,
      units: const [ItemUnitInput('m', 1000), ItemUnitInput('roll', 90000)],
    );
    await items.setPrice(itemId: wire25, tier: 'retail', ratePaise: 7200);
    await items.setPrice(itemId: wire25, tier: 'contractor', ratePaise: 6800);

    // Countable items: base unit pieces, some sold by the box of 10.
    final sw = await items.createItem(
      name: '6A switch',
      brand: 'Anchor',
      category: 'Switches',
      hsn: '8536',
      baseUnit: 'pcs',
      gstRateBp: 1800,
      units: const [ItemUnitInput('box', 10)],
    );
    await items.addVariant(itemId: sw, label: 'White', barcode: '8900000000035');
    await items.setPrice(itemId: sw, tier: 'retail', ratePaise: 1500);
    await items.setPrice(itemId: sw, tier: 'contractor', ratePaise: 1350);

    final led = await items.createItem(
      name: 'LED bulb 9W',
      brand: 'Philips',
      category: 'Lighting',
      hsn: '8539',
      baseUnit: 'pcs',
      gstRateBp: 1200,
      units: const [ItemUnitInput('box', 10)],
    );
    await items.setPrice(itemId: led, tier: 'retail', ratePaise: 9000);

    final mcb = await items.createItem(
      name: 'MCB 32A single pole',
      brand: 'Havells',
      category: 'Protection',
      hsn: '8536',
      baseUnit: 'pcs',
      gstRateBp: 1800,
    );
    await items.setPrice(itemId: mcb, tier: 'retail', ratePaise: 35000);

    // Costs are ex-GST (supplier bills), paise per pricing unit.
    await items.setCost(itemId: wire15, costPaise: 3000);
    await items.setCost(itemId: wire25, costPaise: 5000);
    await items.setCost(itemId: sw, costPaise: 900);
    await items.setCost(itemId: led, costPaise: 6000);
    await items.setCost(itemId: mcb, costPaise: 24000);

    await parties.createParty(
      kind: 'customer',
      name: 'Ramesh Electricals',
      phone: '9800000001',
      tier: 'contractor',
      creditLimitPaise: 1000000,
    );
    await parties.createParty(
      kind: 'customer',
      name: 'Sunita Sharma',
      phone: '9800000002',
    );
    final supplier = await parties.createParty(
      kind: 'supplier',
      name: 'Sample Supplier',
      gstin: '27AAAAA0000A1Z5',
    );

    // Opening stock through a normal purchase so stock is movements, not a number.
    await purchases.postPurchase(PostPurchaseInput(
      supplierId: supplier,
      supplierInvoiceNo: 'SAMPLE-001',
      supplierInvoiceDate: ctx.clock(),
      locationId: locationId,
      lines: [
        PurchaseLineInput(
          itemId: wire15,
          unitName: 'roll',
          qtyEntered: '5',
          qtyBase: 450000,
          ratePaise: 3000,
          priceUnitFactor: 1000,
          gstRateBp: 1800,
        ),
        PurchaseLineInput(
          itemId: wire25,
          unitName: 'roll',
          qtyEntered: '3',
          qtyBase: 270000,
          ratePaise: 5000,
          priceUnitFactor: 1000,
          gstRateBp: 1800,
        ),
        PurchaseLineInput(
          itemId: sw,
          unitName: 'box',
          qtyEntered: '20',
          qtyBase: 200,
          ratePaise: 900,
          priceUnitFactor: 1,
          gstRateBp: 1800,
        ),
        PurchaseLineInput(
          itemId: led,
          unitName: 'box',
          qtyEntered: '10',
          qtyBase: 100,
          ratePaise: 6000,
          priceUnitFactor: 1,
          gstRateBp: 1200,
        ),
        PurchaseLineInput(
          itemId: mcb,
          unitName: 'pcs',
          qtyEntered: '40',
          qtyBase: 40,
          ratePaise: 24000,
          priceUnitFactor: 1,
          gstRateBp: 1800,
        ),
      ],
    ));
    return true;
  }
}
