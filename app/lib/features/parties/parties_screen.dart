import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import 'dues_screen.dart';
import 'party_detail_screen.dart';
import 'party_form_screen.dart';
import 'parties_providers.dart';

/// Customers or suppliers with what each owes (or is owed).
class PartiesScreen extends ConsumerStatefulWidget {
  const PartiesScreen({super.key, required this.kind});

  /// 'customer' or 'supplier'.
  final String kind;

  @override
  ConsumerState<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends ConsumerState<PartiesScreen> {
  String _query = '';

  bool get _suppliers => widget.kind == 'supplier';

  Future<void> _open(Future<Object?> Function() push) async {
    await push();
    if (mounted) refreshBalances(ref);
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(partyListProvider((kind: widget.kind, query: _query)));
    final balances = ref.watch(partyBalancesProvider).valueOrNull ?? const <String, int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(_suppliers ? S.suppliersTitle : S.customersTitle),
        actions: [
          IconButton(
            tooltip: S.dues,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => _open(() => Navigator.of(context)
                .push<void>(MaterialPageRoute(builder: (_) => const DuesScreen()))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addParty'),
        onPressed: () => _open(() => Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) => PartyFormScreen(defaultKind: widget.kind)))),
        icon: const Icon(Icons.person_add),
        label: Text(S.addParty),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('partySearch'),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: S.searchCustomer,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const LoadingView(),
              error: (e, _) => EmptyState(errorMessage(e)),
              data: (parties) {
                if (parties.isEmpty) return EmptyState(S.noParties);
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: parties.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = parties[i];
                    final label = balanceLabel(balances[p.id] ?? 0, supplierView: _suppliers);
                    return ListTile(
                      key: Key('party_${p.id}'),
                      title: Text(p.name),
                      subtitle: Text([
                        if (p.phone != null) p.phone,
                        if (p.tier != 'retail') p.tier,
                      ].join('  •  ')),
                      // A long balance shrinks to fit rather than pushing the name off.
                      trailing: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.45),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            label.text,
                            style: TextStyle(color: label.color, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: () => _open(() => Navigator.of(context).push<void>(
                          MaterialPageRoute(builder: (_) => PartyDetailScreen(partyId: p.id)))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
