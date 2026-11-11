import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';

/// Pick a supplier, or add a new one on the spot. Returns the chosen party.
Future<Party?> showSupplierSheet(BuildContext context) =>
    showModalBottomSheet<Party>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SupplierSheet(),
    );

class _SupplierSheet extends ConsumerStatefulWidget {
  const _SupplierSheet();

  @override
  ConsumerState<_SupplierSheet> createState() => _SupplierSheetState();
}

class _SupplierSheetState extends ConsumerState<_SupplierSheet> {
  List<Party> _results = const [];
  bool _adding = false;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _gstin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _gstin.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final r = await ref.read(partyRepositoryProvider).searchSuppliers(q);
    if (mounted) setState(() => _results = r);
  }

  Future<void> _create() async {
    try {
      final repo = ref.read(partyRepositoryProvider);
      final id = await repo.createParty(
        kind: 'supplier',
        name: _name.text,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        gstin: _gstin.text.trim().isEmpty ? null : _gstin.text.trim().toUpperCase(),
      );
      final party = await repo.getParty(id);
      if (mounted) Navigator.of(context).pop(party);
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: _adding ? _form() : _list(),
      ),
    );
  }

  Widget _list() => Column(children: [
        TextField(
          key: const Key('supplierSearch'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: S.searchCustomer,
            border: OutlineInputBorder(),
          ),
          onChanged: _search,
        ),
        const SizedBox(height: 8),
        ListTile(
          key: const Key('addSupplier'),
          leading: const Icon(Icons.person_add),
          title: const Text('Add new supplier'),
          onTap: () => setState(() => _adding = true),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(children: [
            for (final p in _results)
              ListTile(
                key: Key('supplier_${p.id}'),
                title: Text(p.name),
                subtitle: p.gstin == null ? null : Text(p.gstin!),
                onTap: () => Navigator.of(context).pop(p),
              ),
          ]),
        ),
      ]);

  Widget _form() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(
          key: const Key('newSupplierName'),
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: S.partyName, border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
              labelText: S.phone, border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _gstin,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
              labelText: S.gstin, border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('saveNewSupplier'),
          onPressed: _create,
          child: const Text(S.save),
        ),
        TextButton(
          onPressed: () => setState(() => _adding = false),
          child: const Text(S.cancel),
        ),
      ]);
}
