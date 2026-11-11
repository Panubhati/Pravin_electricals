import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/repo_context.dart';
import '../../core/import/value_parsers.dart';
import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'parties_providers.dart';

/// Add a customer or supplier, or edit one when [partyId] is given.
class PartyFormScreen extends ConsumerStatefulWidget {
  const PartyFormScreen({super.key, this.partyId, this.defaultKind = 'customer'});
  final String? partyId;
  final String defaultKind;

  @override
  ConsumerState<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends ConsumerState<PartyFormScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _credit = TextEditingController();
  final _gstin = TextEditingController();
  final _state = TextEditingController();
  final _address = TextEditingController();
  final _opening = TextEditingController();
  late String _kind = widget.defaultKind;
  String _tier = 'retail';
  bool _loading = false;
  bool _saving = false;

  bool get _editing => widget.partyId != null;

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
    for (final c in [_name, _phone, _credit, _gstin, _state, _address, _opening]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ref.read(partyRepositoryProvider).getParty(widget.partyId!);
    if (!mounted) return;
    setState(() {
      _name.text = p.name;
      _phone.text = p.phone ?? '';
      _credit.text = rupeesForField(p.creditLimitPaise);
      _gstin.text = p.gstin ?? '';
      _state.text = p.stateCode ?? '';
      _address.text = p.address ?? '';
      _kind = p.kind;
      _tier = p.tier;
      _loading = false;
    });
  }

  String? _blank(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final gstin = _blank(_gstin)?.toUpperCase();
      if (gstin != null && !looksLikeGstin(gstin)) {
        throw DomainException('GSTIN should be 15 characters, like 27AAAAA0000A1Z5');
      }
      final state = _blank(_state);
      if (state != null && !RegExp(r'^\d{2}$').hasMatch(state)) {
        throw DomainException('State code should be 2 digits, like 27');
      }
      final credit = _credit.text.trim().isEmpty ? 0 : parseRupees(_credit.text);
      final session = ref.read(sessionProvider).requireValue;
      final parties = ref.read(partyRepositoryProvider);

      if (_editing) {
        await parties.updateParty(
          partyId: widget.partyId!,
          kind: _kind,
          name: _name.text,
          tier: _tier,
          creditLimitPaise: credit,
          phone: _blank(_phone),
          gstin: gstin,
          address: _blank(_address),
          stateCode: state,
          userId: session.userId,
        );
      } else {
        final opening = _opening.text.trim().isEmpty ? 0 : parseRupees(_opening.text);
        await session.ctx.db.transaction(() async {
          final id = await parties.createParty(
            kind: _kind,
            name: _name.text,
            tier: _tier,
            phone: _blank(_phone),
            gstin: gstin,
            address: _blank(_address),
            stateCode: state,
            creditLimitPaise: credit,
          );
          if (opening != 0) {
            // Typed as "how much do they owe / do you owe": the ledger sign
            // is + for a customer who owes, - for a supplier you owe.
            await ref
                .read(ledgerRepositoryProvider)
                .addOpeningBalance(id, _kind == 'supplier' ? -opening : opening);
          }
        });
      }
      refreshBalances(ref);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        toastError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplier = _kind == 'supplier';
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? S.editParty : S.addParty),
        actions: [
          TextButton(
            key: const Key('saveParty'),
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
                  key: const Key('partyName'),
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      labelText: S.partyName, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('partyPhone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: S.phone, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('partyKind'),
                  value: _kind,
                  decoration: const InputDecoration(
                      labelText: S.kind, border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text(S.kindCustomer)),
                    DropdownMenuItem(value: 'supplier', child: Text(S.kindSupplier)),
                    DropdownMenuItem(value: 'both', child: Text(S.kindBoth)),
                  ],
                  onChanged: (v) => setState(() => _kind = v ?? _kind),
                ),
                if (_kind != 'supplier') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('partyTier'),
                    value: _tier,
                    decoration: const InputDecoration(
                        labelText: S.tier, border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'retail', child: Text('Retail')),
                      DropdownMenuItem(value: 'contractor', child: Text('Contractor')),
                      DropdownMenuItem(value: 'dealer', child: Text('Dealer')),
                    ],
                    onChanged: (v) => setState(() => _tier = v ?? _tier),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('partyCredit'),
                    controller: _credit,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: S.creditLimit,
                        prefixText: '₹ ',
                        border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  key: const Key('partyGstin'),
                  controller: _gstin,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: S.gstin, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('partyState'),
                  controller: _state,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: S.stateCode, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('partyAddress'),
                  controller: _address,
                  decoration: const InputDecoration(
                      labelText: S.address, border: OutlineInputBorder()),
                ),
                if (!_editing) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('partyOpening'),
                    controller: _opening,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: supplier
                          ? '${S.openingBalance}: ${S.youOwe} (Rs)'
                          : '${S.openingBalance}: ${S.owes} (Rs)',
                      prefixText: '₹ ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
