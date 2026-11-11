import 'money.dart';

/// Unit and quantity helpers. Stock maths is always in integer base units
/// (millimetres for cable/length items, pieces for countable items).
abstract final class Units {
  /// Converts a quantity typed by staff (decimal string, e.g. "2.5") in a unit
  /// worth [factorToBase] base units into integer base units, without floats.
  ///
  /// 2.5 metre (factor 1000) -> 2500. 1 roll of 90 m (factor 90000) -> 90000.
  /// Throws [FormatException] if the text is invalid or the result is not a
  /// whole number of base units.
  static int toBaseUnits(String qty, int factorToBase) {
    if (factorToBase <= 0) {
      throw ArgumentError.value(factorToBase, 'factorToBase', 'must be > 0');
    }
    final s = qty.trim();
    final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(s);
    if (match == null) throw FormatException('Invalid quantity', qty);
    final whole = match.group(1)!;
    final frac = match.group(2) ?? '';
    if (frac.length > 9) throw FormatException('Too many decimals', qty);
    final numerator = int.parse('$whole$frac') * factorToBase;
    var denominator = 1;
    for (var i = 0; i < frac.length; i++) {
      denominator *= 10;
    }
    if (numerator % denominator != 0) {
      throw FormatException('Quantity is not a whole number of base units', qty);
    }
    return numerator ~/ denominator;
  }

  /// Line amount in paise: qtyBase x ratePaise / priceUnitFactor, rounded half up.
  /// [ratePaise] is paise per pricing unit (per metre, per piece); [priceUnitFactor]
  /// is base units per pricing unit (1000 for cable priced per metre, 1 for pieces).
  static int lineAmountPaise({
    required int qtyBase,
    required int ratePaise,
    required int priceUnitFactor,
  }) {
    if (priceUnitFactor <= 0) {
      throw ArgumentError.value(priceUnitFactor, 'priceUnitFactor', 'must be > 0');
    }
    return Money.mulDivRoundHalfUp(qtyBase, ratePaise, priceUnitFactor);
  }

  /// Display text for [qtyBase] in a unit worth [factorToBase] base units,
  /// up to 3 decimals with trailing zeros removed (2500 mm, factor 1000 -> "2.5").
  static String formatQty(int qtyBase, int factorToBase) {
    if (factorToBase <= 0) {
      throw ArgumentError.value(factorToBase, 'factorToBase', 'must be > 0');
    }
    final negative = qtyBase < 0;
    final abs = negative ? -qtyBase : qtyBase;
    final scaled = Money.divRoundHalfUp(abs * 1000, factorToBase);
    final whole = scaled ~/ 1000;
    var frac = (scaled % 1000).toString().padLeft(3, '0');
    frac = frac.replaceFirst(RegExp(r'0+$'), '');
    final text = frac.isEmpty ? '$whole' : '$whole.$frac';
    return negative ? '-$text' : text;
  }
}
