import 'package:csv/csv.dart';

/// One data row of a CSV file. [rowNumber] is the line a person sees in Excel
/// (the header is row 1, the first data row is row 2).
class CsvRow {
  const CsvRow(this.rowNumber, this._cells);
  final int rowNumber;
  final Map<String, String> _cells;

  /// Trimmed cell text, or '' when the column is missing or empty.
  String get(String column) => (_cells[column] ?? '').trim();
}

/// A parsed CSV: normalised header names and the non-blank data rows.
class CsvTable {
  const CsvTable(this.headers, this.rows);
  final List<String> headers;
  final List<CsvRow> rows;

  bool hasColumn(String name) => headers.contains(name);
}

/// Reads CSV text exported from Excel or Google Sheets.
///
/// Handles a UTF-8 BOM, Windows (CRLF) or old Mac line endings, quoted fields
/// with commas or line breaks, and comma, semicolon or tab separators (Excel in
/// some regions saves with semicolons). Numbers are kept as text so values such
/// as "007" or "1.50" are never altered. Blank rows are dropped, and headers
/// are lower-cased with spaces turned into underscores.
CsvTable parseCsv(String text) {
  var s = text;
  if (s.startsWith('﻿')) s = s.substring(1);
  s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (s.trim().isEmpty) return const CsvTable([], []);

  final delimiter = _detectDelimiter(s);
  final raw = CsvToListConverter(
    fieldDelimiter: delimiter,
    eol: '\n',
    shouldParseNumbers: false,
    allowInvalid: true,
  ).convert(s);

  // Find the header: the first row that has any text.
  var headerIndex = 0;
  while (headerIndex < raw.length && _isBlank(raw[headerIndex])) {
    headerIndex++;
  }
  if (headerIndex >= raw.length) return const CsvTable([], []);

  final headers = [
    for (final h in raw[headerIndex]) _normalizeHeader(h.toString()),
  ];

  final rows = <CsvRow>[];
  for (var i = headerIndex + 1; i < raw.length; i++) {
    if (_isBlank(raw[i])) continue;
    final cells = <String, String>{};
    for (var c = 0; c < headers.length; c++) {
      if (headers[c].isEmpty) continue;
      cells[headers[c]] = c < raw[i].length ? raw[i][c].toString() : '';
    }
    rows.add(CsvRow(i - headerIndex + 1, cells));
  }
  return CsvTable(headers, rows);
}

bool _isBlank(List<dynamic> row) => row.every((c) => c.toString().trim().isEmpty);

String _normalizeHeader(String h) => h
    .replaceAll('﻿', '')
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[\s\-]+'), '_');

/// Picks the separator that appears most in the first non-empty line.
String _detectDelimiter(String text) {
  final first = text.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  final counts = {',': 0, ';': 0, '\t': 0};
  var inQuotes = false;
  for (final ch in first.split('')) {
    if (ch == '"') inQuotes = !inQuotes;
    if (!inQuotes && counts.containsKey(ch)) counts[ch] = counts[ch]! + 1;
  }
  var best = ',';
  for (final e in counts.entries) {
    if (e.value > counts[best]!) best = e.key;
  }
  return best;
}
