import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../shared/theme.dart';

/// A picture of the UPI payment QR, sent with a WhatsApp payment reminder
/// (A13). The customer pays from it: in GPay or PhonePe, Scan, then pick the
/// picture from the gallery. White background, the shop name and amount below.
Future<Uint8List> buildUpiQrPng({required String link, required String title, required String amount}) async {
  const w = 720.0, qr = 560.0, pad = 80.0;
  final heading = _text(title, 34, bold: true, width: w - 40);
  final money = _text(amount, 44, bold: true, width: w - 40);
  final h = pad + qr + 24 + heading.height + 8 + money.height + 48;

  final recorder = ui.PictureRecorder();
  final c = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));
  c.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFFFFF));
  c.save();
  c.translate((w - qr) / 2, pad / 2);
  QrPainter(data: link, version: QrVersions.auto, gapless: true).paint(c, const Size(qr, qr));
  c.restore();
  var y = pad / 2 + qr + 24;
  heading.paint(c, Offset((w - heading.width) / 2, y));
  y += heading.height + 8;
  money.paint(c, Offset((w - money.width) / 2, y));

  final image = await recorder.endRecording().toImage(w.toInt(), h.ceil());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

TextPainter _text(String s, double size, {bool bold = false, required double width}) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontFamilyFallback: const [AppTheme.marathiFont],
        fontSize: size,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: const Color(0xFF000000),
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    maxLines: 2,
  );
  tp.layout(maxWidth: width);
  return tp;
}
