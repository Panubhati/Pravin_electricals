import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';

/// What the customer sheet returns. [party] null means walk-in.
class CustomerChoice {
  const CustomerChoice(this.party);
  final Party? party;
}

Future<CustomerChoice?> showCustomerSheet(BuildContext context) =>
    showModalBottomSheet<CustomerChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CustomerSheet(),
    );

class _CustomerSheet extends ConsumerStatefulWidget {
  const _CustomerSheet();

  @override
  ConsumerState<_CustomerSheet> createState() => _CustomerSheetState();
}

class _CustomerSheetState extends ConsumerState<_CustomerSheet> {
  List<Party> _results = const [];
  bool _adding = false;
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final r = await ref.read(partyRepositoryProvider).searchCustomers(q);
    if (mounted) setState(() => _results = r);
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(partyRepositoryProvider);
    final phone = _phone.text.trim();
    final id = await repo.createParty(
      kind: 'customer',
      name: name,
      phone: phone.isEmpty ? null : phone,
    );
    final party = await repo.getParty(id);
    if (mounted) Navigator.of(context).pop(CustomerChoice(party));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: _adding ? _addForm() : _list(),
      ),
    );
  }

  Widget _list() => Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: S.searchCustomer,
              border: OutlineInputBorder(),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.directions_walk),
            title: const Text(S.walkIn),
            onTap: () => Navigator.of(context).pop(const CustomerChoice(null)),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text(S.addCustomer),
            onTap: () => setState(() => _adding = true),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                for (final p in _results)
                  ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      [p.phone, if (p.tier != 'retail') p.tier]
                          .whereType<String>()
                          .join('  •  '),
                    ),
                    onTap: () => Navigator.of(context).pop(CustomerChoice(p)),
                  ),
              ],
            ),
          ),
        ],
      );

  Widget _addForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: S.customerName,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: S.customerPhone,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _create, child: const Text(S.save)),
          TextButton(
            onPressed: () => setState(() => _adding = false),
            child: const Text(S.cancel),
          ),
        ],
      );
}
