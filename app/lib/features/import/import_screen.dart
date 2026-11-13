import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/import/file_service.dart';
import '../../core/import/import_models.dart';
import '../../core/import/item_import.dart';
import '../../core/import/party_import.dart';
import '../../core/auth/auth_providers.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../items/items_providers.dart';
import '../parties/parties_providers.dart';
import '../../shared/theme.dart';

/// Choose what to import: items (with prices, cost and opening stock) or
/// customers and suppliers (with opening balances).
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.importTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.importHelp),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              key: const Key('importItemsTile'),
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(S.importItems),
              subtitle: Text(S.importItemsSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => const ImportFlowScreen(kind: ImportKind.items))),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('importPartiesTile'),
              leading: const Icon(Icons.people_outline),
              title: Text(S.importParties),
              subtitle: Text(S.importPartiesSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(MaterialPageRoute(
                  builder: (_) => const ImportFlowScreen(kind: ImportKind.parties))),
            ),
          ),
        ],
      ),
    );
  }
}

enum ImportKind { items, parties }

/// What a preview says, whichever kind of file it was.
class _PreviewView {
  const _PreviewView(this.total, this.toCreate, this.skipped, this.errors);
  final int total;
  final int toCreate;
  final List<ImportSkip> skipped;
  final List<ImportIssue> errors;
}

/// Pick a file, see exactly what would happen (including every problem row),
/// then import. Nothing is saved until "Import now".
class ImportFlowScreen extends ConsumerStatefulWidget {
  const ImportFlowScreen({super.key, required this.kind});
  final ImportKind kind;

  @override
  ConsumerState<ImportFlowScreen> createState() => _ImportFlowScreenState();
}

class _ImportFlowScreenState extends ConsumerState<ImportFlowScreen> {
  ItemImportPreview? _items;
  PartyImportPreview? _parties;
  ImportResult? _result;
  bool _busy = false;

  bool get _isItems => widget.kind == ImportKind.items;

  _PreviewView? get _view {
    final i = _items, p = _parties;
    if (_isItems && i != null) return _PreviewView(i.totalRows, i.toCreate.length, i.skipped, i.errors);
    if (!_isItems && p != null) return _PreviewView(p.totalRows, p.toCreate.length, p.skipped, p.errors);
    return null;
  }

  bool get _canImport => _isItems ? (_items?.canImport ?? false) : (_parties?.canImport ?? false);

  Future<void> _downloadTemplate() async {
    try {
      final saved = await ref.read(fileServiceProvider).saveText(
            fileName: _isItems ? 'items_template.csv' : 'parties_template.csv',
            content: _isItems ? ItemImportService.templateCsv : PartyImportService.templateCsv,
          );
      if (saved && mounted) toast(context, S.templateSaved);
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  Future<void> _choose() async {
    setState(() => _busy = true);
    try {
      final text = await ref.read(fileServiceProvider).pickCsvText();
      if (text == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      if (_isItems) {
        final p = await ref.read(itemImportServiceProvider).preview(text);
        if (mounted) setState(() { _items = p; _parties = null; _result = null; });
      } else {
        final p = await ref.read(partyImportServiceProvider).preview(text);
        if (mounted) setState(() { _parties = p; _items = null; _result = null; });
      }
    } catch (e) {
      if (mounted) toastError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final session = ref.read(sessionProvider).requireValue;
      final result = _isItems
          ? await ref.read(itemImportServiceProvider).apply(_items!,
              locationId: session.locationId, userId: ref.read(actingUserIdProvider))
          : await ref.read(partyImportServiceProvider).apply(_parties!);
      ref.invalidate(itemListProvider);
      ref.invalidate(stockBalancesProvider);
      refreshBalances(ref);
      if (mounted) {
        setState(() {
          _result = result;
          _items = null;
          _parties = null;
        });
      }
    } catch (e) {
      if (mounted) toastError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _view;
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text(_isItems ? S.importItems : S.importParties)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(S.importHelp),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('downloadTemplate'),
            onPressed: _busy ? null : _downloadTemplate,
            icon: const Icon(Icons.download),
            label: Text(S.downloadTemplate),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('chooseFile'),
            onPressed: _busy ? null : _choose,
            icon: const Icon(Icons.upload_file),
            label: Text(S.chooseFile),
          ),
          if (_busy) const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingView(),
          ),
          if (r != null) ...[
            SectionTitle(S.importDone),
            Text(
              S.importResult(r.created, r.skipped, r.errors),
              key: const Key('importResult'),
            ),
          ],
          if (v != null) ...[
            SectionTitle(S.importCheckFirst),
            Text(
              S.importSummary(v.total, v.toCreate, v.skipped.length, v.errors.length),
              key: const Key('importSummary'),
            ),
            if (v.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(S.importFixThese,
                  style: Theme.of(context).textTheme.titleSmall),
              for (final e in v.errors.take(100))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.transparent,
                  leading: const Icon(Icons.error_outline, color: AppPalette.red),
                  title: Text(e.toString()),
                ),
              if (v.errors.length > 100) Text(S.andMore(v.errors.length - 100)),
            ],
            if (v.skipped.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(S.skippedCount(v.skipped.length)),
                children: [
                  for (final s in v.skipped.take(100))
                    ListTile(
                      dense: true,
                      title: Text(S.rowName(s.rowNumber, s.name)),
                      subtitle: Text(s.reason),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('importNow'),
              onPressed: (_busy || !_canImport) ? null : _import,
              child: Text('${S.importNow} (${v.toCreate})'),
            ),
          ],
        ],
      ),
    );
  }
}
