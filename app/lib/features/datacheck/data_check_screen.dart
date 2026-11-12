import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/repositories/data_check_models.dart';
import '../../core/db/repositories/data_check_repository.dart';
import '../../core/providers.dart';
import '../../shared/messages_mr.dart';
import '../../shared/format.dart';
import '../../shared/strings.dart';
import '../../shared/widgets.dart';
import '../backup/backup_actions.dart';
import '../bills/bills_screens.dart';
import '../items/item_form_screen.dart';
import '../parties/party_detail_screen.dart';
import '../purchase/purchases_screen.dart';
import '../../shared/theme.dart';

/// Runs "Check my data" and keeps the result so Settings and Home can show it.
/// Returns the full result of this run.
Future<DataCheckResult> runDataCheck(WidgetRef ref) async {
  final session = ref.read(sessionProvider).requireValue;
  final result = await DataCheckRepository(session.ctx).run();
  await ref.read(settingsRepositoryProvider).setDataCheckSummary(result.summary);
  ref.invalidate(dataCheckSummaryProvider);
  return result;
}

/// Shows whether all the numbers in the shop's data agree, and what does not.
class DataCheckScreen extends ConsumerStatefulWidget {
  const DataCheckScreen({super.key});

  @override
  ConsumerState<DataCheckScreen> createState() => _DataCheckScreenState();
}

class _DataCheckScreenState extends ConsumerState<DataCheckScreen> {
  DataCheckResult? _result;
  Object? _error;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // Run as soon as the screen opens; it takes a moment, not minutes.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final r = await runDataCheck(ref);
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _share(DataCheckResult r) async {
    try {
      final session = ref.read(sessionProvider).requireValue;
      final dir = await ref.read(databaseLocationProvider).workDirectory();
      final stamp = '${r.ranAt.year}${r.ranAt.month.toString().padLeft(2, '0')}${r.ranAt.day.toString().padLeft(2, '0')}_'
          '${r.ranAt.hour.toString().padLeft(2, '0')}${r.ranAt.minute.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/DataCheck_$stamp.txt');
      await file.writeAsString(r.toReport(session.shop.name));
      await ref.read(backupSharerProvider).shareFile(file, subject: S.dataCheckShareSubject(session.shop.name));
    } catch (e) {
      if (mounted) toastError(context, e);
    }
  }

  void _open(DataIssue i) {
    final id = i.refId;
    if (id == null) return;
    final screen = switch (i.refType) {
      IssueRef.invoice => BillDetailScreen(invoiceId: id),
      IssueRef.purchase => PurchaseDetailScreen(purchaseId: id),
      IssueRef.party => PartyDetailScreen(partyId: id),
      IssueRef.item => ItemFormScreen(itemId: id),
      IssueRef.none => null,
    };
    if (screen != null) {
      Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final issueKeys = RowKeys();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.dataCheckTitle),
        actions: [
          if (r != null)
            IconButton(
              key: const Key('dataCheckShare'),
              tooltip: S.shareReport,
              icon: const Icon(Icons.share),
              onPressed: () => _share(r),
            ),
        ],
      ),
      body: _error != null
          ? EmptyState('${S.dataCheckFailed}: ${errorMessage(_error!)}')
          : r == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: r.passed ? AppPalette.greenTint : AppPalette.redTint,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(r.passed ? Icons.verified_outlined : Icons.error_outline,
                                size: 36, color: r.passed ? AppPalette.green : AppPalette.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.passed ? S.dataCheckPassed : S.dataCheckProblems(r.errorCount),
                                    key: const Key('dataCheckHeadline'),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(S.dataCheckScope(r.checksRun, r.records),
                                      key: const Key('dataCheckScope')),
                                  if (r.warningCount > 0)
                                    Text(S.dataCheckNotes(r.warningCount), key: const Key('dataCheckNotes')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('dataCheckAgain'),
                      onPressed: _running ? null : _run,
                      icon: const Icon(Icons.refresh),
                      label: Text(S.runAgain),
                    ),
                    if (r.errors.isNotEmpty) SectionTitle(S.problemsFound),
                    if (r.errors.isNotEmpty)
                      CardGroup(margin: EdgeInsets.zero, children: [
                        for (final i in r.errors) _IssueTile(i, keyName: issueKeys.of(i.code, i.refId ?? i.message), onTap: () => _open(i)),
                      ]),
                    if (r.moreIssues > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(S.andMoreProblems(r.moreIssues), key: const Key('dataCheckMore')),
                      ),
                    if (r.warnings.isNotEmpty) SectionTitle(S.notesFound),
                    if (r.warnings.isNotEmpty)
                      CardGroup(margin: EdgeInsets.zero, children: [
                        for (final i in r.warnings) _IssueTile(i, keyName: issueKeys.of(i.code, i.refId ?? i.message), onTap: () => _open(i)),
                      ]),
                    if (!r.passed) ...[
                      const SizedBox(height: 16),
                      Text(S.dataCheckAdvice, style: TextStyle(color: AppPalette.muted)),
                    ],
                  ],
                ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile(this.issue, {required this.keyName, required this.onTap});
  final DataIssue issue;
  final String keyName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        key: Key('issue_$keyName'),
        leading: Icon(issue.isError ? Icons.error_outline : Icons.info_outline,
            color: issue.isError ? AppPalette.red : AppPalette.amber),
        title: Text(localizeMessage(issue.message)),
        trailing: issue.refId == null ? null : const Icon(Icons.chevron_right),
        onTap: issue.refId == null ? null : onTap,
      );
}

/// Remembered result of the last run (null if never run).
final dataCheckSummaryProvider = FutureProvider.autoDispose<DataCheckSummary?>(
  (ref) => ref.watch(settingsRepositoryProvider).dataCheckSummary(),
);

/// Note on the owner's home screen when the last check found problems.
class DataCheckNote extends ConsumerWidget {
  const DataCheckNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dataCheckSummaryProvider).valueOrNull;
    if (s == null || s.passed) return const SizedBox.shrink();
    return Card(
      key: const Key('dataCheckNote'),
      color: AppPalette.redTint,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: AppPalette.red),
        title: Text(S.dataCheckProblems(s.errors)),
        subtitle: Text(S.dataCheckNoteHelp),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context)
            .push<void>(MaterialPageRoute(builder: (_) => const DataCheckScreen())),
      ),
    );
  }
}

/// How the last result reads in Settings.
String dataCheckSubtitle(DataCheckSummary? s) {
  if (s == null) return S.dataCheckNeverRun;
  final when = backupTime(s.ranAt);
  return s.passed
      ? '${S.dataCheckPassedShort} ($when)'
      : '${S.dataCheckProblems(s.errors)} ($when)';
}
