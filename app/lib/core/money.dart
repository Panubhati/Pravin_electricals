/// Money helpers. All money is an integer number of paise (1 rupee = 100 paise).
/// Never use double for money, rates, tax or totals.
abstract final class Money {
  /// Integer division rounding half away from zero. [denominator] must be > 0.
  static int divRoundHalfUp(int numerator, int denominator) {
    if (denominator <= 0) {
      throw ArgumentError.value(denominator, 'denominator', 'must be > 0');
    }
    final negative = numerator < 0;
    final n = negative ? -numerator : numerator;
    // floor((2n + d) / 2d) is exact half-up for any positive d.
    final q = (n * 2 + denominator) ~/ (denominator * 2);
    return negative ? -q : q;
  }

  /// (a * b) / c rounded half away from zero, using integers only.
  static int mulDivRoundHalfUp(int a, int b, int c) =>
      divRoundHalfUp(a * b, c);

  /// Tax on [taxablePaise] at [rateBp] basis points (1800 = 18%), rounded per line.
  static int taxPaise(int taxablePaise, int rateBp) =>
      divRoundHalfUp(taxablePaise * rateBp, 10000);

  /// Parses "12.50", "12.5", "12", "-3.05", "₹1,234.00" into paise.
  /// Throws [FormatException] for more than 2 decimals or invalid text.
  static int parse(String input) {
    var s = input.trim().replaceAll('₹', '').replaceAll(',', '').trim();
    if (s.isEmpty) throw FormatException('Empty amount', input);
    var negative = false;
    if (s.startsWith('-')) {
      negative = true;
      s = s.substring(1);
    } else if (s.startsWith('+')) {
      s = s.substring(1);
    }
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(s);
    if (match == null) throw FormatException('Invalid amount', input);
    final rupees = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    final paise = rupees * 100 + int.parse(fraction.isEmpty ? '0' : fraction);
    return negative ? -paise : paise;
  }

  /// Formats paise as ₹ with Indian digit grouping, e.g. 12345650 -> "₹1,23,456.50".
  static String format(int paise, {bool symbol = true}) {
    final negative = paise < 0;
    final abs = negative ? -paise : paise;
    final rupees = (abs ~/ 100).toString();
    final pp = (abs % 100).toString().padLeft(2, '0');
    final grouped = _indianGroup(rupees);
    return '${negative ? '-' : ''}${symbol ? '₹' : ''}$grouped.$pp';
  }

  static String _indianGroup(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}
