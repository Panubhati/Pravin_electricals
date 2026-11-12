import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../../shared/theme.dart';

/// A small page layout for documents the pdf package cannot write itself:
/// Marathi bills and credit notes (A10). The pdf package does not join
/// Devanagari letters, so each page is drawn with Flutter's own text engine
/// (which does) into a sharp picture, and the pictures become the PDF's pages.
///
/// A document is a list of [DocBlock]s laid out top to bottom on A4 pages; a
/// table may run onto the next page (its header is repeated).

sealed class DocBlock {
  const DocBlock();
}

class DocText extends DocBlock {
  const DocText(this.text, {this.size = 10, this.bold = false, this.align = TextAlign.left, this.muted = false});
  final String text;
  final double size;
  final bool bold;
  final TextAlign align;
  final bool muted;
}

/// Two columns of lines side by side (bill-to on the left, number and date on the right).
class DocColumns extends DocBlock {
  const DocColumns(this.left, this.right);
  final List<DocText> left;
  final List<DocText> right;
}

/// A label and a value on one line, inside a box of [width] points on the right.
class DocKeyValue extends DocBlock {
  const DocKeyValue(this.label, this.value, {this.size = 10, this.bold = false, this.width = 220});
  final String label;
  final String value;
  final double size;
  final bool bold;
  final double width;
}

class DocTable extends DocBlock {
  const DocTable({required this.flex, required this.rightAligned, required this.header, required this.rows});

  /// Relative column widths (a number column can be given a small value).
  final List<double> flex;
  final List<bool> rightAligned;
  final List<String> header;
  final List<List<String>> rows;
}

class DocDivider extends DocBlock {
  const DocDivider();
}

class DocSpace extends DocBlock {
  const DocSpace(this.height);
  final double height;
}

/// Lines on the left and, when [qrData] is given, a QR code with a caption on the right.
class DocWithQr extends DocBlock {
  const DocWithQr(this.left, {this.qrData, this.caption});
  final List<DocText> left;
  final String? qrData;
  final String? caption;
}

/// Page size and drawing scale. Points are PDF points (1/72 inch); pages are
/// drawn at 150 dots per inch, sharp for printing and small to share.
const _dpi = 150.0;
const _scale = _dpi / 72;
final _page = PdfPageFormat.a4;
const _margin = 28.0;
const _footer = 22.0;

double _px(double pt) => pt * _scale;

TextStyle _style(double size, {bool bold = false, bool muted = false}) => TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontFamilyFallback: const [AppTheme.marathiFont],
      fontSize: _px(size),
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: muted ? const Color(0xFF555555) : const Color(0xFF000000),
      height: 1.25,
    );

TextPainter _painter(String text, double size, {bool bold = false, bool muted = false, TextAlign align = TextAlign.left, double? width}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: _style(size, bold: bold, muted: muted)),
    textAlign: align,
    textDirection: TextDirection.ltr,
  );
  tp.layout(minWidth: width ?? 0, maxWidth: width ?? double.infinity);
  return tp;
}

/// One thing to draw at a vertical position on a page.
typedef _Draw = void Function(Canvas canvas, double y);

class _Item {
  _Item(this.height, this.draw, {this.tableHeader});
  final double height;
  final _Draw draw;

  /// For table rows: the header to repeat when the row starts a new page.
  final _Item? tableHeader;
}

/// Builds the PDF bytes for [blocks]. [footer] gives the text at the foot of
/// each page ("पान 1 / 2").
Future<Uint8List> buildPaintedPdf(List<DocBlock> blocks, {required String Function(int page, int pages) footer}) async {
  final width = _px(_page.width - 2 * _margin);
  final items = <_Item>[];
  for (final b in blocks) {
    items.addAll(_layout(b, width));
  }

  // Split into pages.
  final usable = _px(_page.height - 2 * _margin - _footer);
  final pages = <List<(double, _Item)>>[[]];
  var y = 0.0;
  for (final it in items) {
    if (y + it.height > usable && pages.last.isNotEmpty) {
      pages.add([]);
      y = 0;
      if (it.tableHeader != null) {
        pages.last.add((y, it.tableHeader!));
        y += it.tableHeader!.height;
      }
    }
    pages.last.add((y, it));
    y += it.height;
  }

  final doc = pw.Document(compress: true);
  final pw_ = _px(_page.width).round(), ph = _px(_page.height).round();
  for (var i = 0; i < pages.length; i++) {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec, Rect.fromLTWH(0, 0, pw_.toDouble(), ph.toDouble()));
    canvas.drawRect(Rect.fromLTWH(0, 0, pw_.toDouble(), ph.toDouble()), Paint()..color = const Color(0xFFFFFFFF));
    canvas.translate(_px(_margin), _px(_margin));
    for (final (top, it) in pages[i]) {
      it.draw(canvas, top);
    }
    final foot = _painter(footer(i + 1, pages.length), 8, muted: true, align: TextAlign.right, width: width);
    foot.paint(canvas, Offset(0, usable + _px(6)));
    final image = await rec.endRecording().toImage(pw_, ph);
    final png = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    image.dispose();
    doc.addPage(pw.Page(
      pageFormat: _page,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.fill),
    ));
  }
  return doc.save();
}

List<_Item> _layout(DocBlock b, double width) {
  switch (b) {
    case DocText():
      final tp = _painter(b.text, b.size, bold: b.bold, muted: b.muted, align: b.align, width: width);
      return [_Item(tp.height, (c, y) => tp.paint(c, Offset(0, y)))];
    case DocSpace():
      return [_Item(_px(b.height), (c, y) {})];
    case DocDivider():
      return [
        _Item(_px(8), (c, y) {
          c.drawLine(Offset(0, y + _px(4)), Offset(width, y + _px(4)), Paint()..color = const Color(0xFF999999)..strokeWidth = 1.5);
        })
      ];
    case DocColumns():
      final half = width / 2 - _px(6);
      final left = [for (final t in b.left) _painter(t.text, t.size, bold: t.bold, muted: t.muted, width: half)];
      final right = [
        for (final t in b.right) _painter(t.text, t.size, bold: t.bold, muted: t.muted, align: TextAlign.right, width: half)
      ];
      double sum(List<TextPainter> l) => l.fold(0.0, (a, p) => a + p.height);
      final h = [sum(left), sum(right)].reduce((a, c) => a > c ? a : c);
      return [
        _Item(h, (c, y) {
          var ly = y;
          for (final p in left) {
            p.paint(c, Offset(0, ly));
            ly += p.height;
          }
          var ry = y;
          for (final p in right) {
            p.paint(c, Offset(width - half, ry));
            ry += p.height;
          }
        })
      ];
    case DocKeyValue():
      final box = _px(b.width);
      final k = _painter(b.label, b.size, bold: b.bold, width: box * 0.55);
      final v = _painter(b.value, b.size, bold: b.bold, align: TextAlign.right, width: box * 0.45);
      final h = (k.height > v.height ? k.height : v.height) + _px(3);
      return [
        _Item(h, (c, y) {
          k.paint(c, Offset(width - box, y + _px(1.5)));
          v.paint(c, Offset(width - box * 0.45, y + _px(1.5)));
        })
      ];
    case DocTable():
      final total = b.flex.fold(0.0, (a, f) => a + f);
      final widths = [for (final f in b.flex) width * f / total];
      final pad = _px(4);
      _Item row(List<String> cells, {bool header = false}) {
        final ps = [
          for (var i = 0; i < cells.length; i++)
            _painter(cells[i], 10,
                bold: header, align: b.rightAligned[i] ? TextAlign.right : TextAlign.left, width: widths[i] - 2 * pad)
        ];
        final h = ps.fold(0.0, (a, p) => p.height > a ? p.height : a) + 2 * _px(3);
        return _Item(h, (c, y) {
          final line = Paint()
            ..color = const Color(0xFF777777)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          if (header) {
            c.drawRect(Rect.fromLTWH(0, y, width, h), Paint()..color = const Color(0xFFEEEEEE));
          }
          var x = 0.0;
          for (var i = 0; i < ps.length; i++) {
            c.drawRect(Rect.fromLTWH(x, y, widths[i], h), line);
            ps[i].paint(c, Offset(x + pad, y + _px(3)));
            x += widths[i];
          }
        });
      }

      final head = row(b.header, header: true);
      return [
        head,
        for (final r in b.rows) _Item(row(r).height, row(r).draw, tableHeader: head),
      ];
    case DocWithQr():
      const qrPt = 90.0;
      final qrBox = _px(120);
      final leftWidth = b.qrData == null ? width : width - qrBox - _px(8);
      final left = [for (final t in b.left) _painter(t.text, t.size, bold: t.bold, muted: t.muted, width: leftWidth)];
      final cap = b.qrData == null ? null : _painter(b.caption ?? '', 8, align: TextAlign.center, width: qrBox);
      final leftH = left.fold(0.0, (a, p) => a + p.height);
      final rightH = b.qrData == null ? 0.0 : _px(qrPt) + _px(4) + cap!.height;
      final h = leftH > rightH ? leftH : rightH;
      return [
        _Item(h, (c, y) {
          var ly = y;
          for (final p in left) {
            p.paint(c, Offset(0, ly));
            ly += p.height;
          }
          if (b.qrData != null) {
            final size = _px(qrPt);
            c.save();
            c.translate(width - qrBox + (qrBox - size) / 2, y);
            QrPainter(data: b.qrData!, version: QrVersions.auto, gapless: true).paint(c, Size(size, size));
            c.restore();
            cap!.paint(c, Offset(width - qrBox, y + size + _px(4)));
          }
        })
      ];
  }
}
