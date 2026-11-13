import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Saves files into the phone's Downloads folder (A13). The real one talks to
/// Android; tests use a fake.
abstract class FileSaver {
  /// Saves [bytes] as [filename] in Downloads and returns the saved file's
  /// address, or null when this phone cannot (Android 9 and older; the app
  /// shares the file instead).
  Future<String?> saveToDownloads(Uint8List bytes, String filename, String mime);

  /// Opens a saved file in a viewer app.
  Future<void> open(String uri, String mime);
}

class DeviceFileSaver implements FileSaver {
  static const _channel = MethodChannel('com.pravinelectricals.shop_app/share');

  @override
  Future<String?> saveToDownloads(Uint8List bytes, String filename, String mime) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    return _channel.invokeMethod<String>('saveToDownloads', {'bytes': bytes, 'filename': filename, 'mime': mime});
  }

  @override
  Future<void> open(String uri, String mime) => _channel.invokeMethod<void>('openDownload', {'uri': uri, 'mime': mime});
}

const pdfMime = 'application/pdf';
const backupMime = 'application/octet-stream';

/// "2026-11-13", for file names (sorts by date in Files).
String fileDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// File names for saved and shared files (A13). Kept here, in English, so they
/// sort and read the same on every phone.
abstract final class FileNames {
  static String dailySales(DateTime d) => 'DailySales_${fileDate(d)}.pdf';
  static String dues(DateTime d) => 'Dues_${fileDate(d)}.pdf';
  static String stock(DateTime d) => 'Stock_${fileDate(d)}.pdf';
  static String itemProfit(DateTime from, DateTime to) => 'ItemProfit_${fileDate(from)}_to_${fileDate(to)}.pdf';
  static String dayCheck(DateTime d) => 'DayCheck_${fileDate(d)}.pdf';
  static String payQr(int amountPaise) => 'Pay_${amountPaise ~/ 100}.png';
}
