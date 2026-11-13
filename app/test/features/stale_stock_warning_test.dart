import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/repositories/setup_repository.dart';
import 'package:shop_app/core/sync/pairing.dart';
import 'package:shop_app/features/billing/bill_screen.dart';
import 'package:shop_app/features/sync/sync_providers.dart';

import '../helpers/app_harness.dart';

/// A12: while billing, low-stock items warn when the other phone has not
/// synced for a while (it may have sold the same stock).
void main() {
  Future<void> pairedSyncedAgo(Harness h, Duration ago) async {
    final other = await SetupRepository(h.session.ctx).createDevice(label: 'Counter phone', invoiceSeriesPrefix: 'B');
    final store = SyncStore(h.db);
    await store.upsertPeer(other, address: '192.168.1.9', port: 47821);
    await store.peerSynced(other, at: DateTime.now().subtract(ago));
  }

  Future<void> addMcb(WidgetTester tester, String qty) async {
    await tester.enterText(find.byKey(const Key('searchField')), 'MCB');
    await settle(tester);
    await tester.tap(find.byKey(const Key('result_0')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('qty_0')), qty);
    await settle(tester);
  }

  harnessTest('synced 45 minutes ago and the sale takes the last pieces: warns', (tester, h) async {
    await db(tester, () => pairedSyncedAgo(h, const Duration(minutes: 45)));
    await h.pump(tester, const BillScreen(), overrides: [peerFinderProvider.overrideWithValue(null)]);
    await addMcb(tester, '40'); // 40 in stock
    expect(find.byKey(const Key('staleWarning_0')), findsOneWidget);
    expect(find.textContaining('Other phone last synced 45 min ago'), findsOneWidget);
  });

  harnessTest('plenty of stock left: no warning', (tester, h) async {
    await db(tester, () => pairedSyncedAgo(h, const Duration(minutes: 45)));
    await h.pump(tester, const BillScreen(), overrides: [peerFinderProvider.overrideWithValue(null)]);
    await addMcb(tester, '2');
    expect(find.byKey(const Key('staleWarning_0')), findsNothing);
  });

  harnessTest('synced 10 minutes ago: no warning', (tester, h) async {
    await db(tester, () => pairedSyncedAgo(h, const Duration(minutes: 10)));
    await h.pump(tester, const BillScreen(), overrides: [peerFinderProvider.overrideWithValue(null)]);
    await addMcb(tester, '40');
    expect(find.byKey(const Key('staleWarning_0')), findsNothing);
  });

  harnessTest('one phone alone: never warns', (tester, h) async {
    await h.pump(tester, const BillScreen(), overrides: [peerFinderProvider.overrideWithValue(null)]);
    await addMcb(tester, '40');
    expect(find.byKey(const Key('staleWarning_0')), findsNothing);
  });
}
