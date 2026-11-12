import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/repo_context.dart';
import 'package:shop_app/features/home/home_screen.dart';
import 'package:shop_app/features/purchase/purchases_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';
import 'package:shop_app/shared/strings.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_rich_shop.dart';

void main() {
  final noFinder = peerFinderProvider.overrideWithValue(null);

  harnessTest('the owner cancels a purchase from its detail screen', (tester, h) async {
    await tester.runAsync(() => seedRichShop(h.session));
    final p = (await tester.runAsync(() => h.db.select(h.db.purchases).get()))!.single;
    await h.pump(tester, PurchaseDetailScreen(purchaseId: p.id), overrides: [noFinder]);

    await tester.scrollUntilVisible(find.byKey(const Key('cancelPurchase')), 200);
    await tester.tap(find.byKey(const Key('cancelPurchase')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('cancelPurchaseReason')), 'Wrong supplier');
    await tester.tap(find.byKey(const Key('cancelPurchaseConfirm')));
    await settle(tester);

    expect(find.text(S.cancelledBadge), findsOneWidget);
    expect(find.byKey(const Key('cancelPurchase')), findsNothing);
    final after = (await tester.runAsync(() => h.db.select(h.db.purchases).get()))!.single;
    expect(after.status, 'cancelled');
  }, sample: false);

  harnessTest('a supplier bill entered twice shows a warning on Home and a badge in the list', (tester, h) async {
    await tester.runAsync(() async {
      await seedRichShop(h.session);
      final p = (await h.db.select(h.db.purchases).get()).single;
      final lines = await (h.db.select(h.db.purchaseLines)..where((l) => l.purchaseId.equals(p.id))).get();
      // The same bill, as if it came from the other phone.
      final other = RepoContext(h.db, shopId: h.session.shopId)..originDeviceId = 'phone-b';
      await h.db.customStatement("UPDATE purchases SET supplier_invoice_no = 'tmp' WHERE id = '${p.id}'");
      await PurchaseRepository(other).postPurchase(PostPurchaseInput(
        supplierId: p.supplierId,
        supplierInvoiceNo: 'S-501',
        supplierInvoiceDate: p.supplierInvoiceDate,
        locationId: h.session.locationId,
        lines: [
          for (final l in lines)
            PurchaseLineInput(
              itemId: l.itemId, unitName: l.unitName, qtyEntered: l.qtyEntered, qtyBase: l.qtyBase,
              ratePaise: l.ratePaise, priceUnitFactor: l.priceUnitFactor, gstRateBp: l.gstRateBp),
        ],
      ));
      await h.db.customStatement("UPDATE purchases SET supplier_invoice_no = 'S-501' WHERE id = '${p.id}'");
    });

    await h.pump(tester, const HomeScreen(), overrides: [noFinder]);
    expect(find.byKey(const Key('purchaseTwiceNote')), findsOneWidget);
    expect(find.text(S.purchaseTwiceNote(1)), findsOneWidget);

    await tester.tap(find.byKey(const Key('purchaseTwiceNote')));
    await settle(tester);
    expect(find.text(S.purchaseTwiceBadge), findsNWidgets(2));
  }, sample: false);
}
