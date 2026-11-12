import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/repositories/auth_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';

import 'seed_today.dart';

/// A shop with a bit of everything a real backup must carry: items and prices,
/// bills (cash, UPI, credit), a customer who owes money, a purchase on credit
/// with a part payment to the supplier, a counter user, an owner PIN (4821) and
/// settings. Opening cash Rs 1,000 and the UPI ID are set.
Future<void> seedRichShop(ShopSession s) async {
  await seedToday(s);
  final items = ItemRepository(s.ctx);
  final parties = PartyRepository(s.ctx);
  final ledger = LedgerRepository(s.ctx);
  final settings = SettingsRepository(s.ctx);
  final auth = AuthRepository(s.ctx);

  final wire = (await items.search('Copper wire')).first.item;
  final supplier = await parties.createParty(kind: 'supplier', name: 'Polycab Distributor', phone: '9811100001');
  await PurchaseRepository(s.ctx).postPurchase(PostPurchaseInput(
    supplierId: supplier,
    supplierInvoiceNo: 'S-501',
    supplierInvoiceDate: DateTime.now(),
    locationId: s.locationId,
    lines: [
      PurchaseLineInput(
        itemId: wire.id,
        unitName: 'm',
        qtyEntered: '100',
        qtyBase: 100000,
        ratePaise: 3000,
        priceUnitFactor: 1000,
        gstRateBp: 1800,
      ),
    ],
  ));
  await ledger.recordSupplierPayment(supplier, 100000, mode: 'bank');

  await settings.setUpi(vpa: 'pravin@okhdfc', userId: s.userId);
  await auth.setPin(s.userId, '4821');
  await auth.createCounterUser(name: 'Suresh', pin: '2468', byUserId: s.userId);
}
