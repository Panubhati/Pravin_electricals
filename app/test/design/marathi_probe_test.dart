import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Step 1 probe (A10): can the pdf package draw Marathi, and does Flutter's
/// own text engine draw it correctly? Writes build/probe/*. Run with PROBE=1.
void main() {
  const sample = 'नवीन बिल • ग्राहकांकडून येणे ₹1,250.00 • स्वीच १६A • श्री गणेश इलेक्ट्रिकल्स • क्षमा • द्रव्य';
  final on = Platform.environment.containsKey('PROBE');

  test('pdf package with a Devanagari font', () async {
    final font = pw.Font.ttf(ByteData.sublistView(File('assets/fonts/NotoSansDevanagari-Regular.ttf').readAsBytesSync()));
    final doc = pw.Document();
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (_) => pw.Text(sample, style: pw.TextStyle(font: font, fontSize: 18))));
    File('build/probe/pdf_text.pdf')
      ..createSync(recursive: true)
      ..writeAsBytesSync(await doc.save());
  }, skip: !on);

  testWidgets('painted page in a PDF', (tester) async {
    await tester.runAsync(() async {
      final deva = FontLoader('Deva')
        ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/NotoSansDevanagari-Regular.ttf').readAsBytesSync())))
        ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/NotoSansDevanagari-Bold.ttf').readAsBytesSync())));
      await deva.load();
      final latin = FontLoader('Latin')
        ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync())))
        ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/NotoSans-Bold.ttf').readAsBytesSync())));
      await latin.load();
      final bytes = await paintedPdf();
      File('build/probe/painted.pdf').writeAsBytesSync(bytes);
    });
  }, skip: !on);

  testWidgets('Flutter text engine with the same font', (tester) async {
    await tester.runAsync(() async {
      final loader = FontLoader('Deva')
        ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/NotoSansDevanagari-Regular.ttf').readAsBytesSync())));
      await loader.load();
    });
    await tester.pumpWidget(const MaterialApp(
      home: RepaintBoundary(
        key: Key('b'),
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(sample, style: TextStyle(fontFamily: 'Deva', fontSize: 22, color: Colors.black)),
          ),
        ),
      ),
    ));
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('b')));
    final bytes = await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    });
    File('build/probe/flutter_text.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!);
  }, skip: !on);
}

/// Draws text with Flutter's engine onto an off-screen canvas (no widgets, no
/// screen) and puts the picture in a PDF page: the way Marathi bills will work.
Future<List<int>> paintedPdf() async {
  const w = 1240.0, h = 1754.0; // A4 at 150 dpi
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec, const Rect.fromLTWH(0, 0, w, h));
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFFFFF));
  var y = 80.0;
  void line(String t, {double size = 28, bool bold = false, double x = 80}) {
    final tp = TextPainter(
      text: TextSpan(
          text: t,
          style: TextStyle(
              fontFamily: 'Deva', fontFamilyFallback: const ['Latin'], fontSize: size,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: const Color(0xFF000000))),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 160);
    tp.paint(canvas, Offset(x, y));
    y += tp.height + 12;
  }
  line('श्री गणेश इलेक्ट्रिकल्स', size: 44, bold: true);
  line('कर बीजक (Tax invoice) • बिल क्र. A-0437 • 25 ऑक्टो 2026');
  line('ग्राहक: वर्मा एंटरप्रायझेस 93');
  line('1.5 sqmm copper wire Blue — 4.5 m × ₹33.95 = ₹152.78');
  line('एकूण ₹24,391.00', size: 36, bold: true);
  line('रुपये चोवीस हजार तीनशे एक्याण्णव फक्त');
  final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
  final png = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  final doc = pw.Document();
  doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.fill)));
  return doc.save();
}
