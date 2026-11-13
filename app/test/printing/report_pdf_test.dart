import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/dues_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/printing/report_pdf.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/parties/dues_screen.dart';
import 'package:shop_app/features/reports/reports_screens.dart';
import 'package:shop_app/shared/strings.dart';

import '../features/bills_sharing_test.dart' show FakeSharer, waitFor;
import '../features/downloads_test.dart' show FakeSaver;
import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

/// A13: report PDFs. The content is checked on the report's blocks; the PDF
/// itself is checked to be a real PDF in both languages.
void main() {
  late AppDatabase db0;
  late ShopSession session;
  late ReportsRepository reports;
  final today = DateTime.now();
  final day = DateTime(today.year, today.month, today.day);

  setUp(() async {
    db0 = AppDatabase(NativeDatabase.memory());
    final c = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db0)]);
    session = await c.read(sessionProvider.future);
    await seedToday(session);
    reports = c.read(reportsRepositoryProvider);
    addTearDown(c.dispose);
  });
  tearDown(() async {
    S.lang = AppLang.en;
    await db0.close();
  });

  test('Daily sales lists the totals and every bill', () async {
    final bills = await InvoiceRepository(session.ctx).list(from: day, to: day);
    final doc = dailySalesDoc(await reports.dailySales(day), await reports.cashPosition(day), bills.reversed.toList());
    final t = doc.texts.toList();
    expect(t, contains('Daily sales'));
    expect(t, containsAll(['A-0001', 'A-0002', 'A-0003']));
    expect(t, contains('₹449.00')); // net sales, as on the screen
    expect(t, contains('Ramesh'));
  });

  test('Dues lists who owes, with ageing', () async {
    final doc = duesDoc(await DuesRepository(session.ctx).receivables(), day);
    final t = doc.texts.toList();
    expect(t, contains('Ramesh'));
    expect(t, contains('₹70.00'));
    expect(t, contains('0-30 days'));
  });

  test('Stock hides cost for counter staff', () async {
    final owner = stockDoc(await reports.stockValue(), await reports.lowStock(), day).texts.toList();
    final counter = stockDoc(await reports.stockValue(), await reports.lowStock(), day, showCost: false).texts.toList();
    expect(owner, contains('Value'));
    expect(counter, isNot(contains('Value')));
    expect(counter, isNot(contains('Cost rate')));
  });

  test('Item profit and Day check build', () async {
    final p = itemProfitDoc(await reports.itemProfit(day, day), day, day);
    expect(p.texts, contains('Profit'));
    final d = dayCheckDoc(await reports.dayClose(day), day);
    expect(d.texts, contains('₹449.00'));
  });

  testWidgets('the PDF is a real PDF in English and in Marathi', (tester) async {
    final docs = await tester.runAsync(() async => [
          dailySalesDoc(await reports.dailySales(day), null, await InvoiceRepository(session.ctx).list(from: day, to: day)),
          duesDoc(await DuesRepository(session.ctx).receivables(), day),
        ]);
    for (final lang in AppLang.values) {
      S.lang = lang;
      for (final doc in docs!) {
        final bytes = await tester.runAsync(() => buildReportPdf(doc, shopName: 'Pravin Electricals'));
        expect(String.fromCharCodes(bytes!.sublist(0, 5)), '%PDF-');
      }
    }
  });

  group('report screens', () {
    harnessTest('Daily sales: Download PDF and Share PDF', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final saver = FakeSaver();
      final sharer = FakeSharer();
      await h.pump(tester, const DailySalesScreen(), overrides: [
        fileSaverProvider.overrideWithValue(saver),
        billSharerProvider.overrideWithValue(sharer),
      ]);
      await tester.tap(find.byKey(const Key('reportPdfMenu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reportDownload')));
      await waitFor(tester, () => saver.saved.isNotEmpty);
      expect(saver.saved.single.filename, startsWith('DailySales_'));

      await tester.tap(find.byKey(const Key('reportPdfMenu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reportShare')));
      await waitFor(tester, () => sharer.sheet.isNotEmpty);
      expect(sharer.sheet.single.filename, startsWith('DailySales_'));
    }, sample: false);

    harnessTest('Dues, Stock value and Item profit have the PDF menu', (tester, h) async {
      for (final screen in const <Widget>[DuesScreen(), StockValueScreen(), ItemProfitScreen()]) {
        await h.pump(tester, screen);
        expect(find.byKey(const Key('reportPdfMenu')), findsOneWidget, reason: '$screen');
      }
    });
  });
}
