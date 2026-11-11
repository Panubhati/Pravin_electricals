import '../money.dart';

/// Parsers for numbers typed by people in a spreadsheet. All of them throw
/// [FormatException] with a plain message that can be shown next to the row.

String _clean(String raw) {
  var s = raw.trim();
  s = s.replaceFirst(RegExp(r'^(rs\.?|inr)\s*', caseSensitive: false), '');
  return s.replaceAll('₹', '').replaceAll(',', '').replaceAll(' ', '');
}

/// "1,250.50", "₹ 99", "Rs. 12" to paise. At most 2 decimals; not negative.
int parseRupees(String raw, {bool allowNegative = false}) {
  final s = _clean(raw);
  if (s.isEmpty) throw const FormatException('Amount is empty');
  try {
    final paise = Money.parse(s);
    if (paise < 0 && !allowNegative) {
      throw const FormatException('Amount cannot be negative');
    }
    return paise;
  } on FormatException catch (e) {
    if (e.message == 'Amount cannot be negative') rethrow;
    throw FormatException('"$raw" is not a valid amount (use up to 2 decimals)');
  }
}

/// "18", "18%", "2.5" to basis points (1800, 1800, 250).
int parsePercentToBp(String raw) {
  var s = _clean(raw);
  if (s.endsWith('%')) s = s.substring(0, s.length - 1);
  final m = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(s);
  if (m == null) throw FormatException('"$raw" is not a valid percentage');
  return int.parse(m.group(1)!) * 100 + int.parse((m.group(2) ?? '').padRight(2, '0'));
}

/// A plain non-negative decimal (quantity or length) with commas removed.
String cleanQuantity(String raw) {
  final s = raw.trim().replaceAll(',', '').replaceAll(' ', '');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(s)) {
    throw FormatException('"$raw" is not a valid quantity');
  }
  return s;
}

/// GST slabs allowed in India, as basis points.
const validGstRatesBp = {0, 25, 300, 500, 1200, 1800, 2800};

/// 15-character GSTIN shape check (does not verify the checksum).
bool looksLikeGstin(String s) =>
    RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$').hasMatch(s.toUpperCase());
