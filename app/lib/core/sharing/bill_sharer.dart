
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

/// Hands a bill PDF to another app. The real one talks to Android; tests use a
/// fake. The app never keeps the PDF (it is regenerated from data each time).
abstract class BillSharer {
  /// Opens the phone's share sheet (WhatsApp, Gmail, Drive, print...).
  Future<void> sharePdf({required Uint8List bytes, required String filename});

  /// Opens WhatsApp on the chat with [number] (country code, digits only) with
  /// the file attached ([mime]: a PDF bill, or a QR picture). Returns false
  /// when WhatsApp is not installed.
  Future<bool> sendToWhatsApp({
    required Uint8List bytes,
    required String filename,
    required String number,
    String? text,
    String mime = 'application/pdf',
  });

  /// Opens WhatsApp on the chat with [number] with [text] typed in (no file).
  /// Returns false when WhatsApp is not installed.
  Future<bool> whatsAppText({required String number, required String text});
}

class DeviceBillSharer implements BillSharer {
  static const _channel = MethodChannel('com.pravinelectricals.shop_app/share');

  @override
  Future<void> sharePdf({required Uint8List bytes, required String filename}) =>
      Printing.sharePdf(bytes: bytes, filename: filename);

  @override
  Future<bool> sendToWhatsApp({
    required Uint8List bytes,
    required String filename,
    required String number,
    String? text,
    String mime = 'application/pdf',
  }) async {
    final ok = await _channel.invokeMethod<bool>('sendToWhatsApp', {
      'bytes': bytes,
      'filename': filename,
      'number': number,
      'text': text,
      'mime': mime,
    });
    return ok ?? false;
  }

  @override
  Future<bool> whatsAppText({required String number, required String text}) async =>
      await _channel.invokeMethod<bool>('whatsAppText', {'number': number, 'text': text}) ?? false;
}
