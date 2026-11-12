import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/audit_repository.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';

typedef AuditQuery = ({String group, DateTime? from, DateTime? to});

/// Action groups for the filter chips.
const auditGroups = <String, Set<String>>{
  'prices': {'price_change', 'price_override'},
  'discounts': {'discount'},
  'stock': {'stock_adjustment', 'stock_count'},
  'edits': {'edit', 'delete'},
  'users': {'pin_set', 'pin_changed', 'pin_reset', 'user_created', 'user_deactivated', 'shop_updated', 'upi_changed', 'backup_made', 'backup_restored'},
};

final auditProvider = FutureProvider.autoDispose.family<List<AuditEntry>, AuditQuery>(
  (ref, q) => ref.watch(auditRepositoryProvider).list(
        actions: auditGroups[q.group],
        from: q.from,
        to: q.to,
      ),
);

Map<String, String> get _actionLabels => {
  'price_change': S.auditPriceChange,
  'price_override': S.auditPriceOverride,
  'discount': S.auditDiscount,
  'stock_adjustment': S.auditStockAdjust,
  'stock_count': S.auditStockCount,
  'edit': S.auditEdit,
  'delete': S.auditDelete,
  'pin_set': S.auditPinSet,
  'pin_changed': S.auditPinChanged,
  'pin_reset': S.auditPinReset,
  'user_created': S.auditUserCreated,
  'user_deactivated': S.auditUserDeactivated,
  'shop_updated': S.auditShopUpdated,
  'upi_changed': S.auditUpiChanged,
  'backup_made': S.auditBackupMade,
  'backup_restored': S.auditBackupRestored,
  'backup_made_with_problems': S.auditBackupProblems,
  'sales_return': S.auditSalesReturn,
  'bill_cancelled': S.auditBillCancelled,
  'purchase_cancelled': S.auditPurchaseCancelled,
  'sync_conflict': S.auditSyncConflict,
  'phone_removed': S.auditPhoneRemoved,
};

String auditActionLabel(String action) => _actionLabels[action] ?? action;

// Fields that change on every save and say nothing useful.
const _hidden = {'id', 'shopId', 'createdAt', 'updatedAt', 'deletedAt', 'pinHash'};

/// Plain-language lines for what changed: "Name: A to B". Only fields whose
/// value differs are shown; money fields (…Paise) are shown in rupees.
List<String> describeChange(Map<String, Object?>? before, Map<String, Object?>? after, {Item? item}) {
  final b = before ?? const {};
  final a = after ?? const {};
  // Internal ids and lists (bill lines, whole rows) mean nothing to a person.
  bool readable(String k) =>
      !_hidden.contains(k) && !k.endsWith('Id') && b[k] is! Map && b[k] is! List && a[k] is! Map && a[k] is! List;
  final keys = {...b.keys, ...a.keys}.where(readable).toList()..sort();
  final out = <String>[];
  for (final k in keys) {
    final from = b[k];
    final to = a[k];
    if (from == to) continue;
    final label = _label(k);
    if (!b.containsKey(k)) {
      out.add('$label: ${_value(k, to, item)}');
    } else if (!a.containsKey(k)) {
      continue;
    } else {
      out.add(S.changedFromTo(label, _value(k, from, item), _value(k, to, item)));
    }
  }
  return out;
}

String _label(String key) {
  var k = key;
  for (final suffix in const ['Paise', 'Base']) {
    if (k.endsWith(suffix)) k = k.substring(0, k.length - suffix.length);
  }
  k = k.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]!.toLowerCase()}');
  k = k.replaceAll('_', ' ').trim();
  return k.isEmpty ? key : '${k[0].toUpperCase()}${k.substring(1)}';
}

String _value(String key, Object? v, Item? item) {
  if (v == null) return 'none';
  if (key.endsWith('Paise') && v is int) return Money.format(v);
  // Quantities are stored in base units (mm for cable); show metres or pieces.
  if (key.endsWith('Base') && v is int && item != null) return formatStock(item, v);
  if (v is bool) return v ? 'yes' : 'no';
  return '$v';
}

/// Owner-only history of changes, newest first.
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  String _group = 'all';
  DateTimeRange? _range;

  Future<void> _pick() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  @override
  Widget build(BuildContext context) {
    final q = (group: _group, from: _range?.start, to: _range?.end);
    final entries = ref.watch(auditProvider(q));
    return Scaffold(
      appBar: AppBar(title: Text(S.auditLog)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                for (final (g, label) in [
                  ('all', S.filterAll),
                  ('prices', S.auditPrices),
                  ('discounts', S.auditDiscounts),
                  ('stock', S.auditStock),
                  ('edits', S.auditEdits),
                  ('users', S.auditUsers),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('auditGroup_$g'),
                      label: Text(label),
                      selected: _group == g,
                      onSelected: (_) => setState(() => _group = g),
                    ),
                  ),
                ActionChip(
                  key: const Key('auditDates'),
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(_range == null
                      ? S.pickDates
                      : '${formatDate(_range!.start)} - ${formatDate(_range!.end)}'),
                  onPressed: _pick,
                ),
                if (_range != null)
                  IconButton(
                    key: const Key('auditClearDates'),
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _range = null),
                  ),
              ],
            ),
          ),
          Expanded(
            child: entries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(errorMessage(e)),
              data: (list) {
                if (list.isEmpty) return EmptyState(S.auditEmpty);
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _AuditTile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile(this.e);
  final AuditEntry e;

  Map<String, Object?>? _parse(String? json) {
    if (json == null) return null;
    try {
      return Map<String, Object?>.from(jsonDecode(json) as Map);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = describeChange(_parse(e.row.beforeJson), _parse(e.row.afterJson), item: e.item);
    final when = e.row.ts;
    final time = '${formatDate(when)}, '
        '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
    return ListTile(
      key: Key('audit_${e.row.id}'),
      title: Text('${auditActionLabel(e.row.action)}'
          '${e.entityName == null ? '' : ': ${e.entityName}'}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$time  •  ${e.userName ?? S.auditUnknownUser}'),
          for (final l in lines.take(8)) Text(l),
          if (lines.length > 8) Text(S.andMore(lines.length - 8)),
        ],
      ),
    );
  }
}
