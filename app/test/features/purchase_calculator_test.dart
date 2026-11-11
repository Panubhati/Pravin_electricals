import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/features/purchase/domain/purchase_calculator.dart';

PurchaseCartLine wireRolls(String qty, {int rate = 3000}) => PurchaseCartLine(
      itemId: 'wire',
      itemName: 'Wire',
      unitName: 'roll',
      factorToBase: 90000,
      qtyEntered: qty,
      ratePaise: rate, // Rs 30 per metre, without GST
      priceUnitFactor: 1000,
      gstRateBp: 1800,
    );

PurchaseCartLine switchBoxes(String qty) => PurchaseCartLine(
      itemId: 'sw',
      itemName: 'Switch',
      unitName: 'box',
      factorToBase: 10,
      qtyEntered: qty,
      ratePaise: 900, // Rs 9 per piece
      priceUnitFactor: 1,
      gstRateBp: 1800,
    );

void main() {
  test('2 rolls of 90 m at Rs 30/m plus 18% GST', () {
    final t = PurchaseCalculator.calculate([wireRolls('2')]);
    final l = t.lines.single;
    expect(l.qtyBase, 180000); // 180 m in mm
    expect(l.amountPaise, 540000); // 180 x 30 = Rs 5,400
    expect(l.taxPaise, 97200); // 18% = Rs 972
    expect(t.subtotalPaise, 540000);
    expect(t.taxPaise, 97200);
    expect(t.totalPaise, 637200);
  });

  test('GST is added on top and rounded per line', () {
    final t = PurchaseCalculator.calculate([wireRolls('2'), switchBoxes('1')]);
    // switches: 10 pcs x Rs 9 = 90.00; GST 16.20 (not rounded away)
    expect(t.lines[1].amountPaise, 9000);
    expect(t.lines[1].taxPaise, 1620);
    expect(t.subtotalPaise, 549000);
    expect(t.taxPaise, 98820);
    expect(t.totalPaise, 647820);
  });

  test('per-line rounding of GST (half up)', () {
    // 1 mm... use a tiny amount: 1 piece at Rs 0.05 -> 5 paise, GST 0.9 -> 1
    final t = PurchaseCalculator.calculate([
      const PurchaseCartLine(
        itemId: 'x',
        itemName: 'x',
        unitName: 'pcs',
        factorToBase: 1,
        qtyEntered: '1',
        ratePaise: 5,
        priceUnitFactor: 1,
        gstRateBp: 1800,
      ),
    ]);
    expect(t.taxPaise, 1);
    expect(t.totalPaise, 6);
  });

  test('fractions of a roll work when they are whole base units', () {
    final t = PurchaseCalculator.calculate([wireRolls('0.5')]);
    expect(t.lines.single.qtyBase, 45000); // 45 m
    expect(t.lines.single.amountPaise, 135000);
  });

  test('bad quantities are rejected', () {
    expect(() => PurchaseCalculator.calculate([wireRolls('abc')]), throwsFormatException);
    expect(() => PurchaseCalculator.calculate([switchBoxes('0.05')]), throwsFormatException); // half a piece
  });

  test('empty purchase has zero totals', () {
    final t = PurchaseCalculator.calculate(const []);
    expect(t.isEmpty, true);
    expect(t.totalPaise, 0);
  });

  test('toInput carries the computed base quantities', () {
    final t = PurchaseCalculator.calculate([wireRolls('2')]);
    final input = PurchaseCalculator.toInput(
      t,
      supplierId: 's1',
      supplierInvoiceNo: 'B-1',
      date: DateTime(2026, 11, 12),
      locationId: 'loc',
    );
    expect(input.lines.single.qtyBase, 180000);
    expect(input.lines.single.unitName, 'roll');
    expect(input.supplierInvoiceNo, 'B-1');
  });
}
