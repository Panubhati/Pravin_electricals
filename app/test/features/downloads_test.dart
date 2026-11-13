import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/backup/backup_sharer.dart';
import 'package:shop_app/core/backup/database_location.dart';
import 'package:shop_app/core/db/repositories/invoice_repository.dart';
import 'package:shop_app/core/providers.dart';
import 'package:shop_app/core/sharing/file_saver.dart';
import 'package:shop_app/features/billing/bill_done_screen.dart';
import 'package:shop_app/features/bills/bills_screens.dart';
import 'package:shop_app/features/backup/backup_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/seed_today.dart';
import 'bills_sharing_test.dart' show FakeSharer, bytesStart, waitFor;

/// The phone's Downloads folder as the tests see it.
class FakeSaver implements FileSaver {
  FakeSaver({this.supported = true});
  bool supported;
  final saved = <({Uint8List bytes, String filename, String mime})>[];
  final opened = <String>[];

  @override
  Future<String?> saveToDownloads(Uint8List bytes, String filename, String mime) async {
    if (!supported) return null;
    saved.add((bytes: bytes, filename: filename, mime: mime));
    return 'content://downloads/${saved.length}';
  }

  @override
  Future<void> open(String uri, String mime) async => opened.add(uri);
}

class FakeBackupSharer implements BackupSharer {
  final files = <File>[];
  @override
  Future<void> shareFile(File file, {String? subject, String? text}) async => files.add(file);
}

/// A13: bills, credit notes and backups saved into the phone's Downloads folder.
void main() {
  Future<String> firstBill(Harness h, WidgetTester tester) async {
    await db(tester, () => seedToday(h.session));
    return (await tester.runAsync(() async => (await InvoiceRepository(h.session.ctx).list()).last.invoice.id))!;
  }

  harnessTest('Download PDF on a saved bill puts the PDF in Downloads, with Open', (tester, h) async {
    final id = await firstBill(h, tester);
    final saver = FakeSaver();
    await h.pump(tester, BillDoneScreen(invoiceId: id), overrides: [fileSaverProvider.overrideWithValue(saver)]);
    await tester.tap(find.byKey(const Key('downloadPdf')));
    await waitFor(tester, () => saver.saved.isNotEmpty);
    await settle(tester);
    final f = saver.saved.single;
    expect(bytesStart(f.bytes), '%PDF-');
    expect(f.filename, matches(RegExp(r'^Bill_A-0001_\d{4}-\d{2}-\d{2}\.pdf$')));
    expect(f.mime, 'application/pdf');
    expect(find.textContaining('Saved in Downloads: Bill_A-0001'), findsOneWidget);
    await tester.tap(find.text('Open'));
    expect(saver.opened, ['content://downloads/1']);
  }, sample: false);

  harnessTest('bill detail has Download too', (tester, h) async {
    final id = await firstBill(h, tester);
    final saver = FakeSaver();
    await h.pump(tester, BillDetailScreen(invoiceId: id), overrides: [fileSaverProvider.overrideWithValue(saver)]);
    await tester.tap(find.byKey(const Key('detailDownload')));
    await waitFor(tester, () => saver.saved.isNotEmpty);
    expect(saver.saved.single.filename, startsWith('Bill_A-0001_'));
  }, sample: false);

  harnessTest('an old phone that cannot save to Downloads shares the PDF instead', (tester, h) async {
    final id = await firstBill(h, tester);
    final sharer = FakeSharer();
    await h.pump(tester, BillDoneScreen(invoiceId: id), overrides: [
      fileSaverProvider.overrideWithValue(FakeSaver(supported: false)),
      billSharerProvider.overrideWithValue(sharer),
    ]);
    await tester.tap(find.byKey(const Key('downloadPdf')));
    await waitFor(tester, () => sharer.sheet.isNotEmpty);
    await settle(tester);
    expect(sharer.sheet.single.filename, startsWith('Bill_A-0001_'));
    expect(find.textContaining('cannot save to Downloads'), findsOneWidget);
  }, sample: false);

  harnessTest('a backup can be saved straight into Downloads', (tester, h) async {
    final saver = FakeSaver();
    final sharer = FakeBackupSharer();
    final dir = Directory.systemTemp.createTempSync('shop_downloads_');
    addTearDown(() => dir.deleteSync(recursive: true));
    await h.pump(tester, const BackupScreen(), overrides: [
      databaseLocationProvider.overrideWithValue(FolderDatabaseLocation(dir)),
      fileSaverProvider.overrideWithValue(saver),
      backupSharerProvider.overrideWithValue(sharer),
    ]);
    await tester.tap(find.byKey(const Key('backupDownload')));
    await waitFor(tester, () => saver.saved.isNotEmpty);
    expect(saver.saved.single.filename, startsWith('PravinElectricals_backup_'));
    expect(String.fromCharCodes(saver.saved.single.bytes.sublist(0, 15)), 'SQLite format 3');
    expect(sharer.files, isEmpty);
  });
}
