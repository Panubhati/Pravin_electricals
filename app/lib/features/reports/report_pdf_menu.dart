import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/printing/report_pdf.dart';
import '../../core/providers.dart';
import '../../core/sharing/file_saver.dart';
import '../../shared/downloads.dart';
import '../../shared/widgets.dart';
import '../../shared/strings.dart';

/// App-bar menu on a report: Download PDF and Share PDF (A13). [doc] reads the
/// report's data when tapped; [filename] is like "DailySales_2026-11-13.pdf".
class ReportPdfMenu extends ConsumerWidget {
  const ReportPdfMenu({super.key, required this.doc, required this.filename});
  final Future<ReportDoc> Function() doc;
  final String filename;

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final shop = ref.read(sessionProvider).requireValue.shop.name;
    await downloadFile(
      context,
      ref,
      bytes: () async => buildReportPdf(await doc(), shopName: shop),
      filename: filename,
      mime: pdfMime,
      fallbackShare: (b) => ref.read(billSharerProvider).sharePdf(bytes: b, filename: filename),
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final shop = ref.read(sessionProvider).requireValue.shop.name;
    try {
      final bytes = await buildReportPdf(await doc(), shopName: shop);
      await ref.read(billSharerProvider).sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (context.mounted) toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<int>(
      key: const Key('reportPdfMenu'),
      icon: const Icon(Icons.picture_as_pdf_outlined),
      tooltip: S.reportPdf,
      onSelected: (v) => v == 0 ? _download(context, ref) : _share(context, ref),
      itemBuilder: (_) => [
        PopupMenuItem(
          key: const Key('reportDownload'),
          value: 0,
          child: ListTile(leading: const Icon(Icons.download_outlined), title: Text(S.downloadPdf)),
        ),
        PopupMenuItem(
          key: const Key('reportShare'),
          value: 1,
          child: ListTile(leading: const Icon(Icons.share), title: Text(S.sharePdfShort)),
        ),
      ],
    );
  }
}
