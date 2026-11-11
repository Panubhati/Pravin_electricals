import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/billing/domain/bill_calculator.dart';

CartLine wire({String qty = '2.5', String unit = 'm', int factor = 1000, int discount = 0}) =>
    CartLine(
      itemId: 'wire',
      itemName: '1.5 sqmm wire',
      unitName: unit,
      factorToBase: factor,
      qtyEntered: qty,
      ratePaise: 4750, // Rs 47.50 per metre, GST included
      priceUnitFactor: 1000,
      gstRateBp: 1800,
      discountPaise: discount,
    );

CartLine switches({String qty = '2', String unit = 'box', int factor = 10, int discount = 0}) =>
    CartLine(
      itemId: 'sw',
      itemName: '6A switch',
      unitName: unit,
      factorToBase: factor,
      qtyEntered: qty,
      ratePaise: 1500, // Rs 15 per piece, GST included
      priceUnitFactor: 1,
      gstRateBp: 1800,
      discountPaise: discount,
    );

void main() {
  group('single lines (hand calculated)', () {
    test('2.5 m of wire at Rs 47.50/m', () {
      final t = BillCalculator.calculate([wire()], interState: false);
      // 2.5 x 47.50 = 118.75; GST inside = 18.11; round to 119.00
      expect(t.lines.single.qtyBase, 2500);
      expect(t.subtotalPaise, 11875);
      expect(t.taxPaise, 1811);
      expect(t.lines.single.taxableValuePaise, 11875 - 1811);
      expect(t.roundOffPaise, 25);
      expect(t.totalPaise, 11900);
    });

    test('same wire sold by the roll equals 90 m', () {
      final t = BillCalculator.calculate(
          [wire(qty: '1', unit: 'roll', factor: 90000)],
          interState: false);
      // 90 x 47.50 = 4275.00
      expect(t.lines.single.qtyBase, 90000);
      expect(t.totalPaise, 427500);
    });

    test('2 boxes of 10 switches at Rs 15 each', () {
      final t = BillCalculator.calculate([switches()], interState: false);
      // 20 x 15 = 300.00
      expect(t.lines.single.qtyBase, 20);
      expect(t.totalPaise, 30000);
      expect(t.roundOffPaise, 0);
      expect(t.taxPaise, 4576); // 300 x 18/118 = 45.76
    });
  });

  group('dual-unit bill', () {
    test('metres and boxes on one bill, with a discount', () {
      final t = BillCalculator.calculate(
        [wire(), switches(discount: 1000)],
        interState: false,
      );
      // wire 118.75 + switches 300.00 = 418.75 - 10.00 = 408.75 -> 409.00
      expect(t.subtotalPaise, 11875 + 30000);
      expect(t.discountPaise, 1000);
      expect(t.totalPaise, 40900);
      expect(t.roundOffPaise, 25);
      // GST inside the switches (290.00 after discount): 29000 x 18/118 = 44.24
      expect(t.lines[1].taxPaise, 4424);
      expect(t.taxPaise, 1811 + 4424);
    });
  });

  group('rounding', () {
    test('half a rupee rounds up, below half rounds down', () {
      // 0.5 m x 47.50 = 23.75 -> 24.00
      expect(BillCalculator.calculate([wire(qty: '0.5')], interState: false).totalPaise, 2400);
      // 1 m x 47.50 = 47.50 -> 48.00 (half up)
      expect(BillCalculator.calculate([wire(qty: '1')], interState: false).totalPaise, 4800);
      // 0.2 m = 9.50 -> 10.00
      expect(BillCalculator.calculate([wire(qty: '0.2')], interState: false).totalPaise, 1000);
    });

    test('totals invariant: total = subtotal - discount + round-off', () {
      for (final q in ['0.5', '1', '2.5', '3.333', '12']) {
        final t = BillCalculator.calculate([wire(qty: q, discount: 100)], interState: false);
        expect(t.totalPaise, t.subtotalPaise - t.discountPaise + t.roundOffPaise);
        expect(t.totalPaise % 100, 0);
        expect(t.roundOffPaise.abs(), lessThanOrEqualTo(50));
      }
    });
  });

  group('tax split', () {
    test('same state: CGST + SGST halves', () {
      final t = BillCalculator.calculate([switches()], interState: false);
      final r = t.taxBreakdown.single;
      expect(r.rateBp, 1800);
      expect(r.cgstPaise + r.sgstPaise, 4576);
      expect(r.cgstPaise, 2288);
      expect(r.sgstPaise, 2288);
      expect(r.igstPaise, 0);
      expect(r.taxableValuePaise, 30000 - 4576);
    });

    test('odd paisa goes to SGST', () {
      final t = BillCalculator.calculate([wire()], interState: false); // tax 1811
      final r = t.taxBreakdown.single;
      expect(r.cgstPaise, 905);
      expect(r.sgstPaise, 906);
    });

    test('other state: IGST only', () {
      final t = BillCalculator.calculate([switches()], interState: true);
      final r = t.taxBreakdown.single;
      expect(r.igstPaise, 4576);
      expect(r.cgstPaise, 0);
      expect(r.sgstPaise, 0);
    });

    test('isInterState compares state codes', () {
      expect(BillCalculator.isInterState('27', '27'), false);
      expect(BillCalculator.isInterState('27', '29'), true);
      expect(BillCalculator.isInterState('27', null), false);
      expect(BillCalculator.isInterState(null, '29'), false);
      expect(BillCalculator.isInterState('27', ''), false);
    });
  });

  group('validation', () {
    test('rejects a discount larger than the line', () {
      expect(() => BillCalculator.calculate([wire(discount: 999999)], interState: false),
          throwsArgumentError);
    });
    test('rejects bad or non-integral quantities', () {
      expect(() => BillCalculator.calculate([wire(qty: 'abc')], interState: false),
          throwsFormatException);
      expect(() => BillCalculator.calculate([switches(qty: '1.5', unit: 'pcs', factor: 1)], interState: false),
          throwsFormatException);
    });
    test('empty cart gives zero totals', () {
      final t = BillCalculator.calculate(const [], interState: false);
      expect(t.isEmpty, true);
      expect(t.totalPaise, 0);
    });
  });
}
