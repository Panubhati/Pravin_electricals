import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/units.dart';

void main() {
  group('Units.toBaseUnits', () {
    test('cable in metres to millimetres', () {
      expect(Units.toBaseUnits('2.5', 1000), 2500);
      expect(Units.toBaseUnits('0.5', 1000), 500);
      expect(Units.toBaseUnits('10', 1000), 10000);
      expect(Units.toBaseUnits('0.001', 1000), 1);
    });
    test('roll to metre to mm', () {
      expect(Units.toBaseUnits('1', 90000), 90000); // 1 roll = 90 m
      expect(Units.toBaseUnits('2', 90000), 180000);
      expect(Units.toBaseUnits('0.5', 90000), 45000);
    });
    test('box to pieces', () {
      expect(Units.toBaseUnits('3', 10), 30);
      expect(Units.toBaseUnits('12', 1), 12);
    });
    test('rejects non-integral base result', () {
      expect(() => Units.toBaseUnits('0.0005', 1000), throwsFormatException);
      expect(() => Units.toBaseUnits('1.5', 1), throwsFormatException);
    });
    test('rejects invalid text and factor', () {
      expect(() => Units.toBaseUnits('', 1000), throwsFormatException);
      expect(() => Units.toBaseUnits('-1', 1000), throwsFormatException);
      expect(() => Units.toBaseUnits('abc', 1000), throwsFormatException);
      expect(() => Units.toBaseUnits('1', 0), throwsArgumentError);
    });
  });

  group('Units.lineAmountPaise', () {
    test('cable priced per metre', () {
      // 2.5 m at Rs 47.50/m = Rs 118.75
      expect(
        Units.lineAmountPaise(qtyBase: 2500, ratePaise: 4750, priceUnitFactor: 1000),
        11875,
      );
      // 0.5 m at Rs 47.50/m = 23.75
      expect(
        Units.lineAmountPaise(qtyBase: 500, ratePaise: 4750, priceUnitFactor: 1000),
        2375,
      );
    });
    test('rounds half up per line', () {
      // 1 mm at Rs 47.50/m = 4.75 paise -> 5
      expect(
        Units.lineAmountPaise(qtyBase: 1, ratePaise: 4750, priceUnitFactor: 1000),
        5,
      );
      // 1 mm at Rs 0.40/m = 0.04 paise -> 0
      expect(
        Units.lineAmountPaise(qtyBase: 1, ratePaise: 40, priceUnitFactor: 1000),
        0,
      );
    });
    test('pieces', () {
      expect(
        Units.lineAmountPaise(qtyBase: 3, ratePaise: 2500, priceUnitFactor: 1),
        7500,
      );
    });
  });

  group('Units.formatQty', () {
    test('formats', () {
      expect(Units.formatQty(2500, 1000), '2.5');
      expect(Units.formatQty(500, 1000), '0.5');
      expect(Units.formatQty(10000, 1000), '10');
      expect(Units.formatQty(45000, 90000), '0.5');
      expect(Units.formatQty(12, 1), '12');
      expect(Units.formatQty(-2500, 1000), '-2.5');
    });
  });
}
