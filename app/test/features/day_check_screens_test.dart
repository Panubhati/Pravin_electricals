import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/backup_sharer.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/db/repositories/audit_repository.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/features/dayclose/day_check_screen.dart';
import 'package:shop_app/features/dayclose/stock_spot_check_screen.dart';
import 'package:shop_app/features/reports/reports_screens.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';

class FakeSharer implements BackupSharer {
  final texts = <String>[];
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async => texts.add(file.readAsStringSync());
}

Future<void> waitUntil(WidgetTester tester, bool Function() done, {int tries = 100}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _text(WidgetTester t, String key) => t.widget<Text>(find.byKey(Key(key))).data!;

/// Today's seeded shop (see seed_today.dart): 3 bills, Rs 449.00 of sales
/// (Rs 299 cash, Rs 50 UPI, Rs 100 credit), Rs 30 collected from Ramesh in cash,
/// opening cash Rs 1,000. No returns, purchases or supplier payments.
void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('shop_daycheck_'));
  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  Future<FakeSharer> open(WidgetTester tester, Harness h, Widget screen) async {
    final sharer = FakeSharer();
    await h.pump(tester, screen, overrides: [
      databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(dir)),
      backupSharerProvider.overrideWithValue(sharer),
    ]);
    return sharer;
  }

  group('Day check', () {
    harnessTest('shows the day the way the paper book does', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const DayCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dcNet')).evaluate().isNotEmpty);
      expect(_text(tester, 'dcBills'), '3');
      expect(_text(tester, 'dcGross'), '₹449.00');
      expect(find.byKey(const Key('dcReturns')), findsNothing); // nothing taken back today
      expect(_text(tester, 'dcNet'), '₹449.00');
      expect(_text(tester, 'dcCash'), '₹299.00');
      expect(_text(tester, 'dcUpi'), '₹50.00');
      expect(_text(tester, 'dcCredit'), '₹100.00');
      expect(_text(tester, 'dcCollected'), '₹30.00');
      expect(_text(tester, 'dcPurchaseCount'), '0');
      expect(_text(tester, 'dcCashClosing'), '₹1,329.00');
    }, sample: false);

    harnessTest('the date arrows move between days; yesterday is empty', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const DayCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dcNet')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('dcBack')));
      await waitUntil(tester, () => find.byKey(const Key('dcBills')).evaluate().isNotEmpty && _text(tester, 'dcBills') == '0');
      expect(_text(tester, 'dcNet'), '₹0.00');
      expect(_text(tester, 'dcCashClosing'), '₹1,000.00'); // the opening cash carried in
      expect(tester.widget<IconButton>(find.byKey(const Key('dcForward'))).onPressed, isNotNull);
    }, sample: false);

    harnessTest('Share summary sends the same numbers as plain text', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      final sharer = await open(tester, h, const DayCheckScreen());
      await waitUntil(tester, () => find.byKey(const Key('dcNet')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('dayCheckShare')));
      await waitUntil(tester, () => sharer.texts.isNotEmpty);
      final text = sharer.texts.single;
      expect(text, contains('day check for'));
      expect(text, contains('Bills: 3'));
      expect(text, contains('Net sales: ₹449.00'));
      expect(text, contains('Cash in hand: start ₹1,000.00, now ₹1,329.00'));
    }, sample: false);

    harnessTest('Reports has a Day check tile that opens it', (tester, h) async {
      await open(tester, h, const ReportsScreen());
      await tester.tap(find.byKey(const Key('reportDayCheck')));
      await waitUntil(tester, () => find.byKey(const Key('dcBills')).evaluate().isNotEmpty);
      expect(find.byKey(const Key('dcBills')), findsOneWidget);
    }, sample: false);
  });

  group('Stock spot check', () {
    harnessTest('compares what you count with the app and changes nothing until Apply', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const StockSpotCheckScreen());

      await tester.enterText(find.byKey(const Key('spotSearch')), '6A');
      await waitUntil(tester, () => find.byKey(const Key('spotResult_6A switch')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('spotResult_6A switch')));
      await waitUntil(tester, () => find.byKey(const Key('spotRow_6A switch')).evaluate().isNotEmpty);
      expect(_text(tester, 'spotApp_6A switch'), 'The app says: 13 pcs');

      await tester.enterText(find.byKey(const Key('spotCount_6A switch')), '13');
      await tester.pump();
      expect(_text(tester, 'spotDiff_6A switch'), 'Matches');
      expect(_text(tester, 'spotSummary'), 'Everything you counted matches');
      expect(tester.widget<FilledButton>(find.byKey(const Key('spotApply'))).onPressed, isNull);

      await tester.enterText(find.byKey(const Key('spotCount_6A switch')), '11');
      await tester.pump();
      expect(_text(tester, 'spotDiff_6A switch'), 'Difference: -2 pcs');
      expect(_text(tester, 'spotSummary'), '1 item differs from the app');

      // Nothing has been written yet.
      await db(tester, () async {
        final sw = (await ItemRepository(h.session.ctx).search('6A switch')).first.item;
        expect(await StockRepository(h.session.ctx).balance(itemId: sw.id), 13);
      });
    }, sample: false);

    harnessTest('cable is counted in metres', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const StockSpotCheckScreen());
      await tester.enterText(find.byKey(const Key('spotSearch')), 'Copper');
      await waitUntil(tester, () => find.byKey(const Key('spotResult_Copper wire 1.5')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('spotResult_Copper wire 1.5')));
      await waitUntil(tester, () => find.byKey(const Key('spotRow_Copper wire 1.5')).evaluate().isNotEmpty);
      expect(_text(tester, 'spotApp_Copper wire 1.5'), 'The app says: 97.5 m');
      await tester.enterText(find.byKey(const Key('spotCount_Copper wire 1.5')), '97.25');
      await tester.pump();
      expect(_text(tester, 'spotDiff_Copper wire 1.5'), 'Difference: -0.25 m');
    }, sample: false);

    harnessTest('Apply sets the stock to the count, as a stock count in the audit log, and the data stays healthy', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const StockSpotCheckScreen());
      await tester.enterText(find.byKey(const Key('spotSearch')), '6A');
      await waitUntil(tester, () => find.byKey(const Key('spotResult_6A switch')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('spotResult_6A switch')));
      await waitUntil(tester, () => find.byKey(const Key('spotRow_6A switch')).evaluate().isNotEmpty);
      await tester.enterText(find.byKey(const Key('spotCount_6A switch')), '11');
      await tester.pump();

      await tester.tap(find.byKey(const Key('spotApply')));
      await waitUntil(tester, () => find.textContaining('Set the stock of 1 item').evaluate().isNotEmpty);
      await tester.tap(find.text('Apply counts').last);
      await waitUntil(tester, () => find.text('Stock updated to your counts').evaluate().isNotEmpty);

      await db(tester, () async {
        final sw = (await ItemRepository(h.session.ctx).search('6A switch')).first.item;
        expect(await StockRepository(h.session.ctx).balance(itemId: sw.id), 11);
        final audit = await AuditRepository(h.session.ctx).list(actions: {'stock_count'});
        expect(audit, hasLength(1));
        final r = await DataCheckRepository(h.session.ctx).run();
        expect(r.errors, isEmpty);
      });
      // The row now shows the new stock and matches.
      expect(_text(tester, 'spotApp_6A switch'), 'The app says: 11 pcs');
      expect(_text(tester, 'spotDiff_6A switch'), 'Matches');
    }, sample: false);

    harnessTest('a bad number is flagged and cannot be applied', (tester, h) async {
      await db(tester, () => seedToday(h.session));
      await open(tester, h, const StockSpotCheckScreen());
      await tester.enterText(find.byKey(const Key('spotSearch')), '6A');
      await waitUntil(tester, () => find.byKey(const Key('spotResult_6A switch')).evaluate().isNotEmpty);
      await tester.tap(find.byKey(const Key('spotResult_6A switch')));
      await waitUntil(tester, () => find.byKey(const Key('spotRow_6A switch')).evaluate().isNotEmpty);
      await tester.enterText(find.byKey(const Key('spotCount_6A switch')), 'abc');
      await tester.pump();
      expect(find.text('Enter a valid quantity'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byKey(const Key('spotApply'))).onPressed, isNull);
    }, sample: false);
  });
}
