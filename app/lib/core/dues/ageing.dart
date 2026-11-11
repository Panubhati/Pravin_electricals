/// Ageing of what a party owes (or what the shop owes a supplier).
///
/// Payments and credits settle the **oldest** debts first (FIFO). What is left
/// is aged from the date of each debt into 0-30, 31-60, 61-90 and 90+ day
/// buckets. Money paid beyond what was owed is an [AgeingBuckets.advance].
/// Pure Dart: no database, so it is easy to test by hand.
library;

/// One ledger movement. [amountPaise] uses the ledger sign: positive means the
/// party owes the shop (a sale, an opening balance), negative reduces it (a
/// payment or return).
class AgeingEntry {
  const AgeingEntry(this.date, this.amountPaise);
  final DateTime date;
  final int amountPaise;
}

class AgeingBuckets {
  const AgeingBuckets({
    this.days0to30 = 0,
    this.days31to60 = 0,
    this.days61to90 = 0,
    this.over90 = 0,
    this.advance = 0,
  });

  final int days0to30;
  final int days31to60;
  final int days61to90;
  final int over90;

  /// Paid beyond what was owed (positive number). Not counted in [totalDue].
  final int advance;

  /// Total still owed.
  int get totalDue => days0to30 + days31to60 + days61to90 + over90;

  /// Owed for more than 30 days.
  int get overdue => days31to60 + days61to90 + over90;

  /// Net position: owed minus advance (matches the ledger balance).
  int get net => totalDue - advance;

  @override
  String toString() =>
      'AgeingBuckets(0-30: $days0to30, 31-60: $days31to60, 61-90: $days61to90, '
      '90+: $over90, advance: $advance)';
}

abstract final class AgeingCalculator {
  /// Ages [entries] as of [asOf].
  ///
  /// For a receivable (customer) pass entries as stored in the ledger. For a
  /// payable (supplier) set [payable] to true: the ledger stores what the shop
  /// owes as negative, so the signs are flipped and the same rules apply.
  static AgeingBuckets age(
    List<AgeingEntry> entries,
    DateTime asOf, {
    bool payable = false,
  }) {
    // Stable chronological order (equal dates keep their input order).
    final indexed = [
      for (var i = 0; i < entries.length; i++) (i, entries[i]),
    ]..sort((a, b) {
        final c = _day(a.$2.date).compareTo(_day(b.$2.date));
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });

    final open = <_Debt>[];
    var advance = 0;

    for (final (_, e) in indexed) {
      final amount = payable ? -e.amountPaise : e.amountPaise;
      if (amount > 0) {
        // A new debt is first covered by any advance already paid.
        final covered = amount < advance ? amount : advance;
        advance -= covered;
        if (amount - covered > 0) open.add(_Debt(_day(e.date), amount - covered));
      } else if (amount < 0) {
        var credit = -amount;
        for (final d in open) {
          if (credit == 0) break;
          final used = credit < d.remaining ? credit : d.remaining;
          d.remaining -= used;
          credit -= used;
        }
        open.removeWhere((d) => d.remaining == 0);
        advance += credit;
      }
    }

    var b0 = 0, b1 = 0, b2 = 0, b3 = 0;
    final today = _day(asOf);
    for (final d in open) {
      final days = today.difference(d.date).inDays;
      if (days <= 30) {
        b0 += d.remaining;
      } else if (days <= 60) {
        b1 += d.remaining;
      } else if (days <= 90) {
        b2 += d.remaining;
      } else {
        b3 += d.remaining;
      }
    }
    return AgeingBuckets(
      days0to30: b0,
      days31to60: b1,
      days61to90: b2,
      over90: b3,
      advance: advance,
    );
  }

  /// Calendar day without time, so "days ago" counts whole days.
  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}

class _Debt {
  _Debt(this.date, this.remaining);
  final DateTime date;
  int remaining;
}
