import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/core/dues/ageing.dart';

void main() {
  final asOf = DateTime(2026, 11, 12);
  DateTime ago(int days) => asOf.subtract(Duration(days: days));

  group('buckets and boundaries', () {
    test('a single debt falls in the right bucket at each boundary', () {
      AgeingBuckets of(int days) =>
          AgeingCalculator.age([AgeingEntry(ago(days), 1000)], asOf);
      expect(of(0).days0to30, 1000);
      expect(of(30).days0to30, 1000);
      expect(of(31).days31to60, 1000);
      expect(of(60).days31to60, 1000);
      expect(of(61).days61to90, 1000);
      expect(of(90).days61to90, 1000);
      expect(of(91).over90, 1000);
      expect(of(400).over90, 1000);
    });

    test('a future-dated entry counts as current', () {
      final b = AgeingCalculator.age([AgeingEntry(asOf.add(const Duration(days: 5)), 500)], asOf);
      expect(b.days0to30, 500);
    });

    test('time of day does not change the bucket', () {
      final late = DateTime(2026, 11, 12, 23, 59);
      final early = DateTime(2026, 10, 13, 0, 1); // 30 days before 12 Nov
      expect(AgeingCalculator.age([AgeingEntry(early, 100)], late).days0to30, 100);
    });
  });

  group('FIFO settlement', () {
    test('a payment settles the oldest debt first', () {
      final b = AgeingCalculator.age([
        AgeingEntry(ago(100), 10000), // 90+
        AgeingEntry(ago(40), 5000), // 31-60
        AgeingEntry(ago(5), 2000), // 0-30
        AgeingEntry(ago(2), -12000), // pays the 100-day debt and 2000 of the 40-day one
      ], asOf);
      expect(b.over90, 0);
      expect(b.days31to60, 3000);
      expect(b.days0to30, 2000);
      expect(b.totalDue, 5000);
      expect(b.advance, 0);
    });

    test('a partial payment leaves the remainder in the same bucket', () {
      final b = AgeingCalculator.age([
        AgeingEntry(ago(70), 8000),
        AgeingEntry(ago(10), -3000),
      ], asOf);
      expect(b.days61to90, 5000);
      expect(b.totalDue, 5000);
    });

    test('a payment bigger than all debts becomes an advance', () {
      final b = AgeingCalculator.age([
        AgeingEntry(ago(20), 4000),
        AgeingEntry(ago(1), -10000),
      ], asOf);
      expect(b.totalDue, 0);
      expect(b.advance, 6000);
      expect(b.net, -6000);
    });

    test('an advance paid first covers a later debt', () {
      final b = AgeingCalculator.age([
        AgeingEntry(ago(30), -5000), // advance
        AgeingEntry(ago(10), 3000), // fully covered
        AgeingEntry(ago(5), 4000), // 2000 covered, 2000 left
      ], asOf);
      expect(b.days0to30, 2000);
      expect(b.advance, 0);
      expect(b.totalDue, 2000);
    });

    test('opening balance is just a debt on its date', () {
      final b = AgeingCalculator.age([
        AgeingEntry(ago(200), 15000), // opening balance entered long ago
        AgeingEntry(ago(3), 500),
      ], asOf);
      expect(b.over90, 15000);
      expect(b.days0to30, 500);
    });

    test('entries in any order give the same answer', () {
      final a = [
        AgeingEntry(ago(50), 6000),
        AgeingEntry(ago(10), -2000),
        AgeingEntry(ago(80), 4000),
      ];
      final b1 = AgeingCalculator.age(a, asOf);
      final b2 = AgeingCalculator.age(a.reversed.toList(), asOf);
      expect(b1.days61to90, b2.days61to90);
      expect(b1.days31to60, b2.days31to60);
      expect(b1.totalDue, b2.totalDue);
      // 80-day 4000 settled by... payment is later than 50-day debt? order: 80d debt, 50d debt, 10d payment:
      // payment 2000 settles the 80-day debt first.
      expect(b1.days61to90, 2000);
      expect(b1.days31to60, 6000);
    });
  });

  group('totals match the ledger', () {
    test('net equals the plain sum of entries', () {
      final entries = [
        AgeingEntry(ago(120), 9000),
        AgeingEntry(ago(60), 2500),
        AgeingEntry(ago(45), -4000),
        AgeingEntry(ago(7), 1200),
        AgeingEntry(ago(1), -800),
      ];
      final sum = entries.fold<int>(0, (a, e) => a + e.amountPaise);
      expect(AgeingCalculator.age(entries, asOf).net, sum);
    });

    test('net equals the sum when there is an advance too', () {
      final entries = [
        AgeingEntry(ago(10), 1000),
        AgeingEntry(ago(2), -4000),
      ];
      final b = AgeingCalculator.age(entries, asOf);
      expect(b.net, -3000);
      expect(b.advance, 3000);
    });

    test('no entries means nothing owed', () {
      final b = AgeingCalculator.age(const [], asOf);
      expect(b.totalDue, 0);
      expect(b.advance, 0);
    });
  });

  group('payables (suppliers)', () {
    test('the shop owing a supplier ages the same way with flipped signs', () {
      // Ledger: purchase = negative (shop owes), supplier payment = positive.
      final b = AgeingCalculator.age([
        AgeingEntry(ago(75), -20000),
        AgeingEntry(ago(15), -6000),
        AgeingEntry(ago(5), 22000), // pays the 75-day bill and 2000 of the next
      ], asOf, payable: true);
      expect(b.days61to90, 0);
      expect(b.days0to30, 4000);
      expect(b.totalDue, 4000);
    });
  });
}
