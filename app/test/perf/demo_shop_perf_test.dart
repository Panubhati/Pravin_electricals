import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/data_check_repository.dart';
import 'package:shop_app/core/debug/demo_shop.dart';
import 'package:shop_app/core/debug/speed_check.dart';

/// A busy shop (about 400 items, 200 customers, 30 days of about 40 bills a
/// day) on a real database file, timed. The limits are the owner's-phone targets
/// scaled for a laptop, so a slow query shows up here as a failing test long
/// before it shows up on the phone. The numbers are printed so they can be
/// recorded in docs/milestones/A7-testing-gate.md.
void main() {
  late Directory dir;
  late FolderDatabaseLocation location;
  late AppDatabase db;
  late ShopSession session;
  late DemoShopStats stats;

  /// A laptop is several times faster than a mid-range phone: hold it to this
  /// fraction of the phone targets.
  const laptopScale = 0.5;

  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync('shop_perf_');
    location = FolderDatabaseLocation(dir);
    db = AppDatabase(NativeDatabase(await location.databaseFile()));
    session = await ensureShopSession(db);
    stats = await DemoShop.load(session);
    debugPrint('DEMO SHOP: $stats');
    debugPrint('SIZE: ${await shopSizeLine(session)}');
  });

  tearDownAll(() async {
    await db.close();
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a file; the OS cleans temp.
    }
  });

  test('the demo shop is the size the plan asks for', () {
    expect(stats.items, 400);
    expect(stats.customers, 200);
    expect(stats.bills, inInclusiveRange(30 * 32, 30 * 48));
    expect(stats.purchases, greaterThan(8));
    expect(stats.payments, greaterThan(100));
  });

  test('the demo shop is healthy: Check my data finds no problems', () async {
    final r = await DataCheckRepository(session.ctx).run();
    debugPrint('CHECK: ${r.checksRun} checks over ${r.records} records in ${r.elapsed.inMilliseconds} ms: ${r.timingsMs}');
    expect(r.errors, isEmpty, reason: r.errors.take(10).join('\n'));
  });

  test('every screen and action stays inside its time budget', () async {
    final results = await SpeedCheck.run(session, location: location);
    debugPrint('SPEED (laptop):\n${SpeedCheck.table(results)}');
    final slow = [for (final r in results) if (!r.passes(laptopScale)) r];
    expect(slow, isEmpty,
        reason: 'Too slow (laptop limit is ${(laptopScale * 100).round()}% of the phone target):\n${SpeedCheck.table(slow)}');
  });

  test('the speed check changes nothing in the shop', () async {
    Future<int> bills() async =>
        (await db.customSelect('SELECT COUNT(*) AS n FROM invoices').getSingle()).data['n'] as int;
    final before = await bills();
    await SpeedCheck.run(session, repeats: 1);
    expect(await bills(), before);
  });
}
