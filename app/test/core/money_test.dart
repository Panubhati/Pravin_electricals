import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/money.dart';

void main() {
  group('Money.parse', () {
    test('parses rupees and paise', () {
      expect(Money.parse('12.50'), 1250);
      expect(Money.parse('12.5'), 1250);
      expect(Money.parse('12'), 1200);
      expect(Money.parse('0.05'), 5);
      expect(Money.parse('₹1,234.00'), 123400);
      expect(Money.parse('-3.05'), -305);
    });
    test('rejects bad input', () {
      expect(() => Money.parse(''), throwsFormatException);
      expect(() => Money.parse('1.234'), throwsFormatException);
      expect(() => Money.parse('abc'), throwsFormatException);
      expect(() => Money.parse('1.'), throwsFormatException);
    });
  });

  group('Money.format', () {
    test('Indian grouping', () {
      expect(Money.format(0), '₹0.00');
      expect(Money.format(5), '₹0.05');
      expect(Money.format(99900), '₹999.00');
      expect(Money.format(100000), '₹1,000.00');
      expect(Money.format(12345650), '₹1,23,456.50');
      expect(Money.format(1000000000), '₹1,00,00,000.00');
      expect(Money.format(-12345650), '-₹1,23,456.50');
      expect(Money.format(12345650, symbol: false), '1,23,456.50');
    });
  });

  group('rounding', () {
    test('divRoundHalfUp rounds half away from zero', () {
      expect(Money.divRoundHalfUp(5, 2), 3);
      expect(Money.divRoundHalfUp(4, 2), 2);
      expect(Money.divRoundHalfUp(1, 3), 0);
      expect(Money.divRoundHalfUp(2, 3), 1);
      expect(Money.divRoundHalfUp(-5, 2), -3);
      expect(Money.divRoundHalfUp(5, 3), 2);
      expect(Money.divRoundHalfUp(3, 6), 1); // exactly 0.5
      expect(Money.divRoundHalfUp(7, 5), 1);
      expect(Money.divRoundHalfUp(5, 5), 1);
    });
    test('divRoundHalfUp rejects non-positive denominator', () {
      expect(() => Money.divRoundHalfUp(1, 0), throwsArgumentError);
    });
    test('taxPaise per line', () {
      expect(Money.taxPaise(10000, 1800), 1800); // 100.00 @18%
      expect(Money.taxPaise(1999, 1800), 360); // 359.82 -> 360
      expect(Money.taxPaise(5, 1800), 1); // 0.9 -> 1
      expect(Money.taxPaise(2, 1800), 0); // 0.36 -> 0
    });
    test('taxIncluded extracts GST from a GST-inclusive amount', () {
      expect(Money.taxIncluded(11800, 1800), 1800); // 118.00 incl 18% -> 18.00
      expect(Money.taxIncluded(11875, 1800), 1811); // 18.114
      expect(Money.taxIncluded(30000, 1800), 4576); // 45.762
      expect(Money.taxIncluded(10000, 0), 0);
      expect(Money.taxIncluded(10500, 500), 500); // 105 incl 5% -> 5
    });
    test('roundToRupee rounds half up to a whole rupee', () {
      expect(Money.roundToRupee(11875), 11900);
      expect(Money.roundToRupee(11849), 11800);
      expect(Money.roundToRupee(11850), 11900);
      expect(Money.roundToRupee(100), 100);
      expect(Money.roundToRupee(0), 0);
    });
  });
}
