// Times every screen's data on a copy of the real shop (skipped when the copy
// is not on this computer). Run: flutter test test/perf/real_data_timing_test.dart
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/bootstrap.dart';
import 'package:shop_app/core/db/app_database.dart';
import 'package:shop_app/core/db/repositories/dues_repository.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/db/repositories/item_repository.dart';
import 'package:shop_app/core/db/repositories/ledger_repository.dart';
import 'package:shop_app/core/db/repositories/party_repository.dart';
import 'package:shop_app/core/db/repositories/purchase_repository.dart';
import 'package:shop_app/core/db/repositories/reminder_repository.dart';
import 'package:shop_app/core/db/repositories/reports_repository.dart';
import 'package:shop_app/core/db/repositories/stock_repository.dart';
import 'package:shop_app/core/db/repositories/settings_repository.dart';

void main() {
  test('timings on real shop data', () async {
    final tmp = File('${Directory.systemTemp.createTempSync('t_').path}/shop.sqlite');
    await File('E:/pravin_electricals/phone_backups/shop_before_A8_20261112.sqlite').copy(tmp.path);
    final db = AppDatabase(NativeDatabase(tmp));
    final s = await ensureShopSession(db);
    await SettingsRepository(s.ctx).set('reminders_on', '1');
    Future<void> t(String name, Future<Object?> Function() f) async {
      await f(); // warm
      final w = Stopwatch()..start();
      for (var i = 0; i < 3; i++) {
        await f();
      }
      // ignore: avoid_print
      print('TIME ${name.padRight(26)} ${(w.elapsedMilliseconds / 3).toStringAsFixed(0)} ms');
    }
    await t('dashboard', () => ReportsRepository(s.ctx).dashboard());
    final r = ReportsRepository(s.ctx);
    await t('  dash: receivables', () => DuesRepository(s.ctx).receivables());
    await t('  dash: dailySales', () => r.dailySales(DateTime.now()));
    await t('  dash: cashPosition', () => r.cashPosition(DateTime.now()));
    await t('  dash: lowStock', () => r.lowStock());
    await t('  dash: negativeStock', () => r.negativeStockCount());
    await t('stock balances', () => StockRepository(s.ctx).balancesByItem());
    await t('party balances', () => LedgerRepository(s.ctx).balancesByParty());
    await t('receivables (dues)', () => DuesRepository(s.ctx).receivables());
    await t('payables', () => DuesRepository(s.ctx).payables());
    await t('bills list', () => InvoiceRepository(s.ctx).list());
    await t('items list', () => ItemRepository(s.ctx).listItems(query: '', includeInactive: false));
    await t('item search "wire"', () => ItemRepository(s.ctx).search('wire'));
    await t('customers list', () => PartyRepository(s.ctx).list(kind: 'customer', query: ''));
    await t('purchases list', () => PurchaseRepository(s.ctx).list());
    await t('daily sales', () => ReportsRepository(s.ctx).dailySales(DateTime.now()));
    await t('day close', () => ReportsRepository(s.ctx).dayClose(DateTime.now()));
    await t('reminders due', () => ReminderRepository(s.ctx).due());
    await db.close();
  }, skip: !File('E:/pravin_electricals/phone_backups/shop_before_A8_20261112.sqlite').existsSync());
}
