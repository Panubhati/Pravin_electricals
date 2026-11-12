import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/units.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../../shared/theme.dart';

class _SpotRow {
  _SpotRow(this.item, this.systemBase);
  final Item item;

  /// What the app says is in stock (base units).
  final int systemBase;
  final counted = TextEditingController();

  /// The counted quantity in base units, null while blank, -1 when not a number.
  int? get countedBase {
    final t = counted.text.trim();
    if (t.isEmpty) return null;
    try {
      return Units.toBaseUnits(t, item.priceUnitFactor);
    } on FormatException {
      return -1;
    }
  }

  int? get difference {
    final c = countedBase;
    return (c == null || c < 0) ? null : c - systemBase;
  }
}

/// Count a few items on the shelf and compare with the app's stock. Nothing
/// changes unless you tap Apply.
class StockSpotCheckScreen extends ConsumerStatefulWidget {
  const StockSpotCheckScreen({super.key});

  @override
  ConsumerState<StockSpotCheckScreen> createState() => _StockSpotCheckScreenState();
}

class _StockSpotCheckScreenState extends ConsumerState<StockSpotCheckScreen> {
  final _rows = <_SpotRow>[];
  final _search = TextEditingController();
  List<Item> _results = const [];
  bool _applying = false;

  @override
  void dispose() {
    _search.dispose();
    for (final r in _rows) {
      r.counted.dispose();
    }
    super.dispose();
  }

  Future<void> _onQuery(String q) async {
    final found = await ref.read(itemRepositoryProvider).search(q, limit: 8);
    if (mounted) setState(() => _results = [for (final r in found) r.item]);
  }

  Future<void> _add(Item item) async {
    if (_rows.any((r) => r.item.id == item.id)) return;
    final session = ref.read(sessionProvider).requireValue;
    final bal = await ref.read(stockRepositoryProvider).balance(itemId: item.id, locationId: session.locationId);
    if (!mounted) return;
    setState(() {
      _rows.add(_SpotRow(item, bal));
      _results = const [];
      _search.clear();
    });
  }

  List<_SpotRow> get _differing => [for (final r in _rows) if ((r.difference ?? 0) != 0) r];

  Future<void> _apply() async {
    final changes = _differing;
    if (changes.isEmpty || _applying) return;
    final ok = await confirm(context, message: S.spotApplyConfirm(changes.length), confirmLabel: S.spotApply);
    if (!ok || !mounted) return;
    setState(() => _applying = true);
    try {
      final session = ref.read(sessionProvider).requireValue;
      final stock = ref.read(stockRepositoryProvider);
      for (final r in changes) {
        await stock.recordCount(
          itemId: r.item.id,
          locationId: session.locationId,
          countedBase: r.countedBase!,
          userId: ref.read(actingUserIdProvider),
          note: 'Spot check',
        );
      }
      ref.invalidate(stockBalancesProvider);
      final fresh = <_SpotRow>[];
      for (final r in _rows) {
        final bal = await stock.balance(itemId: r.item.id, locationId: session.locationId);
        final n = _SpotRow(r.item, bal)..counted.text = r.counted.text;
        fresh.add(n);
        r.counted.dispose();
      }
      if (!mounted) return;
      setState(() {
        _rows
          ..clear()
          ..addAll(fresh);
      });
      toast(context, S.spotApplied);
    } catch (e) {
      if (mounted) toastError(context, e);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultKeys = RowKeys(), rowKeys = RowKeys();
    final diffs = _differing;
    return Scaffold(
      appBar: AppBar(title: Text(S.stockSpotCheck)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.spotIntro),
          const SizedBox(height: 12),
          TextField(
            key: const Key('spotSearch'),
            controller: _search,
            onChanged: _onQuery,
            decoration: InputDecoration(
              hintText: S.spotAddItem,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          for (final i in _results)
            ListTile(
              key: Key('spotResult_${resultKeys.of(i.name, i.id)}'),
              dense: true,
              title: Text(i.name),
              subtitle: i.brand == null ? null : Text(i.brand!),
              onTap: () => _add(i),
            ),
          const SizedBox(height: 8),
          for (final r in _rows) _rowTile(r, rowKeys.of(r.item.name, r.item.id)),
          if (_rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              diffs.isEmpty ? S.spotAllMatch : S.spotDifferences(diffs.length),
              key: const Key('spotSummary'),
              style: TextStyle(fontWeight: FontWeight.bold, color: diffs.isEmpty ? AppPalette.green : AppPalette.amber),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('spotApply'),
              onPressed: (diffs.isEmpty || _applying) ? null : _apply,
              child: Text(S.spotApply),
            ),
            const SizedBox(height: 4),
            Text(S.spotApplyHelp, style: TextStyle(color: AppPalette.muted)),
          ],
        ],
      ),
    );
  }

  Widget _rowTile(_SpotRow r, String keyName) {
    final diff = r.difference;
    final bad = r.countedBase == -1;
    return Card(
      key: Key('spotRow_$keyName'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(r.item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                tooltip: S.remove,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _rows.remove(r)),
              ),
            ]),
            Text('${S.spotAppSays}: ${formatStock(r.item, r.systemBase)}', key: Key('spotApp_${r.item.name}')),
            const SizedBox(height: 8),
            TextField(
              key: Key('spotCount_${r.item.name}'),
              controller: r.counted,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${S.spotCounted} (${pricingUnitName(r.item)})',
                border: const OutlineInputBorder(),
                errorText: bad ? S.invalidQty : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (diff != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  diff == 0
                      ? S.spotMatches
                      : '${S.spotDifference}: ${diff > 0 ? '+' : '-'}${formatStock(r.item, diff.abs())}',
                  key: Key('spotDiff_${r.item.name}'),
                  style: TextStyle(color: diff == 0 ? AppPalette.green : AppPalette.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
