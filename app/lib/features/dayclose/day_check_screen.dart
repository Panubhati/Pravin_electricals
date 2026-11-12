import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/reports_repository.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../backup/backup_actions.dart' show backupTime;
import 'stock_spot_check_screen.dart';
import '../../shared/theme.dart';

final dayCloseProvider = FutureProvider.autoDispose.family<DayClose, DateTime>(
  (ref, day) => ref.watch(reportsRepositoryProvider).dayClose(day),
);

/// The evening check: one screen of numbers to put beside the paper book.
class DayCheckScreen extends ConsumerStatefulWidget {
  const DayCheckScreen({super.key, this.day});

  /// The day to open on; today when null.
  final DateTime? day;

  @override
  ConsumerState<DayCheckScreen> createState() => _DayCheckScreenState();
}

class _DayCheckScreenState extends ConsumerState<DayCheckScreen> {
  late DateTime _day = startOfDay(widget.day ?? DateTime.now());

  void _move(int days) => setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _day = startOfDay(d));
  }

  Future<void> _share(DayClose d) async {
    try {
      final session = ref.read(sessionProvider).requireValue;
      final text = d.toSummary(session.shop.name, Money.format, formatDate(_day));
      final dir = await ref.read(databaseLocationProvider).workDirectory();
      final stamp = '${_day.year}${_day.month.toString().padLeft(2, '0')}${_day.day.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/DayCheck_$stamp.txt');
      await file.writeAsString(text);
      await ref.read(backupSharerProvider).shareFile(file, subject: '${session.shop.name} day check ${formatDate(_day)}');
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  Widget _line(String label, int paise, {bool bold = false, bool muted = false, Key? key, String? prefix}) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : (muted ? const TextStyle(color: AppPalette.muted) : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text('${prefix ?? ''}${Money.format(paise)}', key: key, style: style),
        ],
      ),
    );
  }

  Widget _count(String label, int n, {Key? key}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Flexible(child: Text(label)), const SizedBox(width: 8), Text('$n', key: key)],
        ),
      );

  /// One white card holding a group of rows.
  Widget _group(List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(children: rows),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dayCloseProvider(_day));
    final isToday = startOfDay(DateTime.now()) == _day;
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.dayCheckTitle),
        actions: [
          if (async.valueOrNull != null)
            IconButton(
              key: const Key('dayCheckShare'),
              tooltip: S.shareSummary,
              icon: const Icon(Icons.share),
              onPressed: () => _share(async.valueOrNull!),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(key: const Key('dcBack'), icon: const Icon(Icons.chevron_left), onPressed: () => _move(-1)),
              Flexible(
                child: TextButton(
                  key: const Key('dcPick'),
                  onPressed: _pick,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(isToday ? 'Today, ${formatDate(_day)}' : formatDate(_day),
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
              ),
              IconButton(
                key: const Key('dcForward'),
                icon: const Icon(Icons.chevron_right),
                onPressed: isToday ? null : () => _move(1),
              ),
            ],
          ),
          async.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => EmptyState(errorMessage(e)),
            data: (d) {
              final s = d.sales;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(S.dcSales),
                  _group([
                    _count(S.billsCount, s.billCount, key: const Key('dcBills')),
                    if (s.cancelCount > 0) _count(S.dcCancelled, s.cancelCount, key: const Key('dcCancelled')),
                    _line(S.dcSalesGross, s.grossPaise, key: const Key('dcGross')),
                    if (s.returnsPaise > 0) _line(S.dcReturns, s.returnsPaise, prefix: '- ', key: const Key('dcReturns')),
                    _line(S.dcNetSales, s.totalPaise, bold: true, key: const Key('dcNet')),
                  ]),
                  const SectionTitle(S.dcHowPaid),
                  _group([
                    _line(S.cash, s.mode('cash'), key: const Key('dcCash')),
                    _line('UPI', s.mode('upi'), key: const Key('dcUpi')),
                    if (s.mode('card') != 0) _line('Card', s.mode('card')),
                    _line(S.credit, s.mode('credit'), key: const Key('dcCredit')),
                  ]),
                  const SectionTitle(S.dcCollected),
                  _group([
                    _line(S.dcCollectedTotal, d.collectedPaise, bold: true, key: const Key('dcCollected')),
                    _line(S.cash, d.collectedByMode['cash'] ?? 0, muted: true),
                    _line('UPI', d.collectedByMode['upi'] ?? 0, muted: true),
                    _line('Bank', d.collectedByMode['bank'] ?? 0, muted: true),
                  ]),
                  const SectionTitle(S.dcPurchases),
                  _group([
                    _count(S.dcPurchasesEntered, d.purchaseCount, key: const Key('dcPurchaseCount')),
                    _line(S.dcPurchasesTotal, d.purchaseTotalPaise, key: const Key('dcPurchaseTotal')),
                    _line(S.dcPaidSuppliers, d.supplierPaidPaise, key: const Key('dcSupplierPaid')),
                  ]),
                  const SectionTitle(S.cashInHand),
                  _group([
                    _line(S.cashOpening, d.cash.openingPaise),
                    _line('+ ${S.cashSales}', d.cash.cashSalesPaise),
                    _line('+ ${S.cashReceived}', d.cash.cashReceiptsPaise),
                    _line('- ${S.cashPaidOut}', d.cash.cashPaidOutPaise),
                    if (d.cash.cashRefundsPaise > 0) _line('- ${S.dcCashRefunds}', d.cash.cashRefundsPaise),
                    const Divider(),
                    _line(S.cashClosing, d.cash.closingPaise, bold: true, key: const Key('dcCashClosing')),
                  ]),
                  const SizedBox(height: 16),
                  const Text(S.dcCompareHelp, style: TextStyle(color: AppPalette.muted)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('dcStockCheck'),
                    onPressed: () => Navigator.of(context)
                        .push<void>(MaterialPageRoute(builder: (_) => const StockSpotCheckScreen())),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text(S.stockSpotCheck),
                  ),
                  Text('${S.dcCheckedAt} ${backupTime(DateTime.now())}',
                      style: const TextStyle(color: AppPalette.muted, fontSize: 12)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
