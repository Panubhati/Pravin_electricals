import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/debug/sample_data.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/billing/bill_screen.dart';

void main() {
  testWidgets('bill flow: search, add, change unit, pay, save', (tester) async {
    late AppDatabase db;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      final s = await container.read(sessionProvider.future);
      await SampleData.load(s.ctx, locationId: s.locationId);
      container.dispose();
    });
    addTearDown(() => tester.runAsync(db.close));

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: BillScreen()),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    // Search and add the wire.
    await tester.enterText(find.byKey(const Key('searchField')), '1.5 sqmm');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('result_0')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    // 2.5 metres.
    await tester.enterText(find.byKey(const Key('qty_0')), '2.5');
    await tester.pump();
    expect(find.text('₹119.00'), findsWidgets); // 118.75 rounded to the rupee

    // Add switches and sell 2 boxes.
    await tester.enterText(find.byKey(const Key('searchField')), '6A switch');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('result_0')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.tap(find.byKey(const Key('unit_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('box').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('qty_1')), '2');
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('grandTotal'))).data, '₹419.00');

    // Pay all cash and save.
    await tester.tap(find.byKey(const Key('payButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save bill'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('savedInvoiceNo')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('savedInvoiceNo'))).data, 'A-0001');

    await tester.runAsync(() async {
      final inv = await db.select(db.invoices).get();
      expect(inv.single.totalPaise, 41900);
      final lines = await db.select(db.invoiceLines).get();
      expect(lines, hasLength(2));
      expect(lines.map((l) => l.qtyBase).toSet(), {2500, 20});
    });
  });
}
