import '../../features/billing/domain/bill_calculator.dart';
import '../backup/backup_service.dart';
import '../backup/database_location.dart';
import '../bootstrap.dart';
import '../db/repositories/data_check_repository.dart';
import '../db/repositories/dues_repository.dart';
import '../db/repositories/invoice_repository.dart';
import '../db/repositories/item_repository.dart';
import '../db/repositories/reports_repository.dart';
import '../db/repositories/stock_repository.dart';

/// One timed operation.
class SpeedResult {
  const SpeedResult(this.name, this.millis, this.targetMillis);
  final String name;

  /// Median time over a few runs.
  final int millis;

  /// What this operation should stay under on the owner's phone.
  final int targetMillis;

  bool passes([double scale = 1.0]) => millis <= targetMillis * scale;

  @override
  String toString() => '${name.padRight(28)} ${millis.toString().padLeft(6)} ms   (target $targetMillis ms)';
}

class _Rollback implements Exception {}

/// Times the operations that matter in a busy shop. The same code runs in the
/// automated speed tests on the laptop and on the phone (Settings, debug builds).
/// Nothing is changed: the bill save is rolled back after it is timed.
class SpeedCheck {
  static Future<List<SpeedResult>> run(
    ShopSession s, {
    ShopDatabaseLocation? location,
    int repeats = 3,
  }) async {
    final items = ItemRepository(s.ctx);
    final stock = StockRepository(s.ctx);
    final reports = ReportsRepository(s.ctx);
    final dues = DuesRepository(s.ctx);
    final invoices = InvoiceRepository(s.ctx);
    final results = <SpeedResult>[];

    Future<void> time(String name, int target, Future<void> Function() op, {int? runs}) async {
      final times = <int>[];
      for (var i = 0; i < (runs ?? repeats); i++) {
        final w = Stopwatch()..start();
        await op();
        w.stop();
        times.add(w.elapsedMilliseconds);
      }
      times.sort();
      results.add(SpeedResult(name, times[times.length ~/ 2], target));
    }

    final someBarcode = (await s.ctx.db
            .customSelect('SELECT barcode FROM item_variants WHERE barcode IS NOT NULL LIMIT 1')
            .getSingleOrNull())
        ?.data['barcode'] as String?;

    await time('Item search (words)', 200, () async {
      for (final q in ['wire', 'mcb', 'led', '6a', 'polycab']) {
        await items.search(q);
      }
    });
    if (someBarcode != null) {
      await time('Item search (barcode)', 100, () async => items.search(someBarcode));
    }
    await time('Items screen', 1000, () async => items.listItems());
    await time('Stock screen', 1000, () async {
      await stock.balancesByItem();
      await items.listItems();
    });
    await time('Dues: customers', 1000, () async => dues.receivables());
    await time('Dues: suppliers', 1000, () async => dues.payables());
    await time('Bills list', 1000, () async => invoices.list());
    await time('Home summary', 1000, () async => reports.dashboard());
    await time('Daily sales report', 1000, () async {
      await reports.dailySales(DateTime.now());
      await reports.cashPosition(DateTime.now());
    });
    await time('Item profit (month)', 1000, () async {
      final n = DateTime.now();
      await reports.itemProfit(DateTime(n.year, n.month, 1), n);
    });
    await time('Stock value', 1000, () async => reports.stockValue());

    // Saving a bill, timed, then rolled back so the speed check changes nothing.
    final item = (await items.search('wire')).firstOrNull ?? (await items.search('led')).first;
    final units = await items.unitsOf(item.item.id);
    final unit = units.firstWhere((u) => u.factorToBase == item.item.priceUnitFactor, orElse: () => units.first);
    final rate = await items.priceFor(itemId: item.item.id, tier: 'retail') ?? 1000;
    await time('Save one bill', 400, () async {
      final totals = BillCalculator.calculate([
        CartLine(
          itemId: item.item.id,
          itemName: item.item.name,
          unitName: unit.unitName,
          factorToBase: unit.factorToBase,
          qtyEntered: '2',
          ratePaise: rate,
          priceUnitFactor: item.item.priceUnitFactor,
          gstRateBp: item.item.gstRateBp,
        ),
      ], interState: false);
      final number = await invoices.nextNumber(s.deviceId, s.series);
      try {
        await s.ctx.db.transaction(() async {
          await invoices.postInvoice(totals.toInvoiceInput(
            deviceId: s.deviceId,
            series: s.series,
            number: number,
            date: DateTime.now(),
            locationId: s.locationId,
            payments: [PaymentInput('cash', totals.totalPaise)],
          ));
          throw _Rollback();
        });
      } on _Rollback {
        // Timed, now undone.
      }
    });

    await time('Check my data', 5000, () async => DataCheckRepository(s.ctx).run(), runs: 1);
    if (location != null) {
      await time('Make a backup', 5000, () async {
        final b = await BackupService(s.ctx.db, location).createBackup();
        await BackupService.deleteOldBackups(await location.workDirectory());
        assert(b.summary.bills >= 0);
      }, runs: 1);
    }
    return results;
  }

  /// "Item search (words)   42 ms   (target 200 ms)" lines, for a log or the screen.
  static String table(List<SpeedResult> r) => r.map((x) => x.toString()).join('\n');
}

/// Counts of what is in the shop, for the header of the speed check.
Future<String> shopSizeLine(ShopSession s) async {
  Future<int> n(String t) async =>
      (await s.ctx.db.customSelect('SELECT COUNT(*) AS n FROM $t').getSingle()).data['n'] as int;
  return '${await n('items')} items, ${await n('parties')} people, ${await n('invoices')} bills, '
      '${await n('ledger_entries')} account entries, ${await n('stock_movements')} stock movements';
}

