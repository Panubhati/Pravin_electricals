import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/item_repository.dart';
import '../../core/db/repositories/repo_context.dart';
import '../../core/import/value_parsers.dart';
import '../../core/money.dart';
import '../../core/permissions.dart';
import '../../core/providers.dart';
import '../../core/units.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../billing/scan_screen.dart';
import 'item_form_service.dart';
import 'items_providers.dart';

/// Add a new item, or edit an existing one when [itemId] is given.
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.itemId});
  final String? itemId;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _category = TextEditingController();
  final _hsn = TextEditingController();
  final _retail = TextEditingController();
  final _contractor = TextEditingController();
  final _dealer = TextEditingController();
  final _cost = TextEditingController();
  final _pack = TextEditingController();
  final _min = TextEditingController();
  final _opening = TextEditingController();
  final _barcode = TextEditingController();

  int _gstBp = 1800;
  bool _isLength = false;
  bool _loading = false;
  bool _saving = false;
  ItemDetail? _detail;

  bool get _editing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _loading = true;
      _load();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _category, _hsn, _retail, _contractor, _dealer,
      _cost, _pack, _min, _opening, _barcode,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final d = await ref.read(itemRepositoryProvider).getDetail(widget.itemId!);
    if (!mounted) return;
    final item = d.item;
    final isLength = item.baseUnit == 'mm' && item.priceUnitFactor == 1000;
    final packName = isLength ? 'roll' : 'box';
    final pack = d.units.where((u) => u.unitName == packName).toList();
    setState(() {
      _detail = d;
      _isLength = isLength;
      _gstBp = item.gstRateBp;
      _name.text = item.name;
      _brand.text = item.brand ?? '';
      _category.text = item.category ?? '';
      _hsn.text = item.hsn ?? '';
      _retail.text = rupeesForField(d.prices['retail'] ?? 0);
      _contractor.text = rupeesForField(d.prices['contractor'] ?? 0);
      _dealer.text = rupeesForField(d.prices['dealer'] ?? 0);
      _cost.text = rupeesForField(d.costPaise ?? 0);
      _pack.text = pack.isEmpty
          ? ''
          : (isLength
              ? Units.formatQty(pack.first.factorToBase, 1000)
              : '${pack.first.factorToBase}');
      _min.text = item.minStockBase == 0
          ? ''
          : Units.formatQty(item.minStockBase, item.priceUnitFactor);
      _loading = false;
    });
  }

  int? _money(TextEditingController c) =>
      c.text.trim().isEmpty ? null : parseRupees(c.text);

  int _qty(TextEditingController c) => c.text.trim().isEmpty
      ? 0
      : Units.toBaseUnits(cleanQuantity(c.text), _isLength ? 1000 : 1);

  Future<void> _save() async {
    if (_saving) return;
    final perms = ref.read(permissionsProvider);
    setState(() => _saving = true);
    try {
      final retail = _money(_retail);
      if (retail == null) throw DomainException('Retail price is required');
      final data = ItemFormData(
        itemId: widget.itemId,
        name: _name.text,
        brand: _brand.text,
        category: _category.text,
        hsn: _hsn.text,
        gstRateBp: _gstBp,
        isLength: _isLength,
        packSize: _pack.text.trim().isEmpty ? null : _qty(_pack),
        retailPaise: retail,
        contractorPaise: _money(_contractor),
        dealerPaise: _money(_dealer),
        costPaise: perms.canSeeCost ? _money(_cost) : null,
        minStockBase: _qty(_min),
        openingStockBase: _editing ? 0 : _qty(_opening),
        barcode: _editing ? null : _barcode.text,
      );
      final session = ref.read(sessionProvider).requireValue;
      await ref.read(itemFormServiceProvider).save(
            data,
            locationId: session.locationId,
            userId: session.userId,
            canSeeCost: perms.canSeeCost,
          );
      ref.invalidate(itemListProvider);
      ref.invalidate(itemDetailProvider);
      ref.invalidate(stockBalancesProvider);
      if (!mounted) return;
      toast(context, S.itemSaved);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        toastError(context, e);
      }
    }
  }

  Future<void> _toggleActive(bool value) async {
    if (!value &&
        !await confirm(context, message: S.deactivateConfirm, confirmLabel: 'Hide')) {
      return;
    }
    try {
      await ref.read(itemRepositoryProvider).setActive(widget.itemId!, value,
          userId: ref.read(sessionProvider).requireValue.userId);
      await _load();
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  Future<void> _variantDialog({ItemVariant? variant}) async {
    final result = await showDialog<_VariantResult>(
      context: context,
      builder: (_) => _VariantDialog(
        variant: variant,
        onRemove: variant == null
            ? null
            : () => ref.read(itemRepositoryProvider).removeVariant(variant.id,
                userId: ref.read(sessionProvider).requireValue.userId),
      ),
    );
    if (result == null || !mounted) return;
    if (!result.removed) {
      final repo = ref.read(itemRepositoryProvider);
      final userId = ref.read(sessionProvider).requireValue.userId;
      try {
        if (variant == null) {
          await repo.addVariant(
            itemId: widget.itemId!,
            label: result.label.trim().isEmpty ? kDefaultVariantLabel : result.label.trim(),
            barcode: result.barcode,
          );
        } else if (result.label.trim().isNotEmpty) {
          await repo.updateVariant(
              variantId: variant.id,
              label: result.label,
              barcode: result.barcode,
              userId: userId);
        }
      } catch (e) {
        if (mounted) toastError(context, e);
      }
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    final slabs = {0, 500, 1200, 1800, 2800, _gstBp}.toList()..sort();
    final unit = _isLength ? 'm' : 'pcs';

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? S.editItem : S.addItem),
        actions: [
          TextButton(
            key: const Key('saveItem'),
            onPressed: _saving || _loading ? null : _save,
            child: const Text(S.save),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  key: const Key('itemName'),
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: S.itemName, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      key: const Key('itemBrand'),
                      controller: _brand,
                      decoration: const InputDecoration(
                          labelText: S.brand, border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const Key('itemCategory'),
                      controller: _category,
                      decoration: const InputDecoration(
                          labelText: S.category, border: OutlineInputBorder()),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: _hsn,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: S.hsn, border: OutlineInputBorder()),
                ),
                const SectionTitle(S.gstRate),
                Wrap(spacing: 8, children: [
                  for (final bp in slabs)
                    ChoiceChip(
                      key: Key('gst_$bp'),
                      label: Text(bp % 100 == 0 ? '${bp ~/ 100}%' : '${bp / 100}%'),
                      selected: _gstBp == bp,
                      onSelected: (_) => setState(() => _gstBp = bp),
                    ),
                ]),
                const SectionTitle(S.itemType),
                if (_editing)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_isLength ? S.typeLength : S.typePiece),
                    subtitle: const Text(S.typeFixed),
                  )
                else
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                          value: true,
                          label: Text(S.typeLength, key: Key('typeLength')),
                          icon: Icon(Icons.cable)),
                      ButtonSegment(
                          value: false,
                          label: Text(S.typePiece, key: Key('typePiece')),
                          icon: Icon(Icons.lightbulb_outline)),
                    ],
                    selected: {_isLength},
                    onSelectionChanged: (s) => setState(() => _isLength = s.first),
                  ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('itemPack'),
                  controller: _pack,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _isLength ? S.rollLength : S.boxSize,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SectionTitle(S.prices),
                _moneyField(const Key('itemRetail'), _retail,
                    '${S.retailPrice} (per $unit)', perms.canEditPrices),
                const SizedBox(height: 12),
                _moneyField(const Key('itemContractor'), _contractor,
                    '${S.contractorPrice} (per $unit)', perms.canEditPrices),
                const SizedBox(height: 12),
                _moneyField(const Key('itemDealer'), _dealer,
                    '${S.dealerPrice} (per $unit)', perms.canEditPrices),
                if (perms.canSeeCost) ...[
                  const SizedBox(height: 12),
                  _moneyField(const Key('itemCost'), _cost,
                      '${S.costPrice} (per $unit)', perms.canEditPrices),
                ],
                const SectionTitle(S.stock),
                TextField(
                  key: const Key('itemMin'),
                  controller: _min,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${S.minStock} ($unit)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (!_editing) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('itemOpening'),
                    controller: _opening,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${S.openingStock} ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('itemBarcode'),
                    controller: _barcode,
                    decoration: const InputDecoration(
                        labelText: S.barcode, border: OutlineInputBorder()),
                  ),
                ],
                if (_editing && _detail != null) ..._editOnlySections(_detail!),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _moneyField(Key key, TextEditingController c, String label, bool enabled) =>
      TextField(
        key: key,
        controller: c,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
        ),
      );

  List<Widget> _editOnlySections(ItemDetail d) => [
        const SectionTitle(S.variants),
        for (final v in d.variants)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(v.label == kDefaultVariantLabel ? S.barcode.replaceAll(' (optional)', '') : v.label),
            subtitle: Text(v.barcode ?? ''),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _variantDialog(variant: v),
          ),
        OutlinedButton.icon(
          key: const Key('addVariant'),
          onPressed: () => _variantDialog(),
          icon: const Icon(Icons.add),
          label: const Text(S.addVariant),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          key: const Key('activeSwitch'),
          contentPadding: EdgeInsets.zero,
          title: const Text(S.activeSwitch),
          value: d.item.active,
          onChanged: _toggleActive,
        ),
        if (d.structureLocked)
          Text(
            'This item already has stock or bills.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        Text(
          'Cost today: ${d.costPaise == null || !ref.read(permissionsProvider).canSeeCost ? '-' : Money.format(d.costPaise!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ];
}

class _VariantResult {
  const _VariantResult(this.label, this.barcode, {this.removed = false});
  final String label;
  final String barcode;
  final bool removed;
}

/// Add or edit a variant and its barcode. Owns its text controllers so they are
/// disposed with the dialog, not while it is still animating away.
class _VariantDialog extends StatefulWidget {
  const _VariantDialog({this.variant, this.onRemove});
  final ItemVariant? variant;
  final Future<void> Function()? onRemove;

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  late final TextEditingController _label =
      TextEditingController(text: widget.variant?.label ?? '');
  late final TextEditingController _code =
      TextEditingController(text: widget.variant?.barcode ?? '');

  @override
  void dispose() {
    _label.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.variant == null ? S.addVariant : S.editItem),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('variantName'),
            controller: _label,
            decoration: const InputDecoration(labelText: S.variantName),
          ),
          TextField(
            key: const Key('variantBarcode'),
            controller: _code,
            decoration: InputDecoration(
              labelText: S.barcode,
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  final scanned = await Navigator.of(context).push<String>(
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                  if (scanned != null) _code.text = scanned;
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (widget.onRemove != null)
          TextButton(
            onPressed: () async {
              await widget.onRemove!();
              if (context.mounted) {
                Navigator.pop(context, const _VariantResult('', '', removed: true));
              }
            },
            child: const Text(S.remove),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text(S.cancel)),
        FilledButton(
          key: const Key('saveVariant'),
          onPressed: () =>
              Navigator.pop(context, _VariantResult(_label.text, _code.text)),
          child: const Text(S.save),
        ),
      ],
    );
  }
}
