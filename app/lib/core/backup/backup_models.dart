import 'package:flutter/foundation.dart';

/// A plain-language reason a backup could not be made or used. Shown to the owner as is.
class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => 'BackupException: $message';
}

/// What a backup file contains, for the owner to check before restoring.
class BackupSummary {
  const BackupSummary({
    required this.shopName,
    required this.schemaVersion,
    required this.bills,
    required this.customers,
    required this.items,
    required this.sizeBytes,
    this.lastBillAt,
  });

  final String shopName;

  /// Database version of the app that made it (older files are upgraded on restore).
  final int schemaVersion;
  final int bills;
  final int customers;
  final int items;
  final int sizeBytes;
  final DateTime? lastBillAt;
}

/// A finished, verified backup file ready to hand to the share sheet.
class BackupFile {
  const BackupFile({required this.path, required this.name, required this.summary});
  final String path;
  final String name;
  final BackupSummary summary;
}

/// A summary of a database that is cheap to compare: how many rows each table
/// has, and the sums that matter to the shop (stock, ledger, bill totals). Two
/// databases with the same fingerprint hold the same shop.
@immutable
class DbFingerprint {
  const DbFingerprint(this.counts, this.sums);
  final Map<String, int> counts;
  final Map<String, int> sums;

  @override
  bool operator ==(Object other) =>
      other is DbFingerprint && mapEquals(counts, other.counts) && mapEquals(sums, other.sums);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(counts.entries.map((e) => Object.hash(e.key, e.value))),
        Object.hashAll(sums.entries.map((e) => Object.hash(e.key, e.value))),
      );

  /// What differs from [other], for an error message or a test failure.
  String describeDifference(DbFingerprint other) {
    final out = <String>[];
    for (final k in {...counts.keys, ...other.counts.keys}) {
      if (counts[k] != other.counts[k]) out.add('$k rows ${counts[k]} vs ${other.counts[k]}');
    }
    for (final k in {...sums.keys, ...other.sums.keys}) {
      if (sums[k] != other.sums[k]) out.add('$k total ${sums[k]} vs ${other.sums[k]}');
    }
    return out.join('; ');
  }

  @override
  String toString() => 'DbFingerprint($counts, $sums)';
}

/// The sums included in every fingerprint: (name, table, column).
const fingerprintSums = <(String, String, String)>[
  ('stock', 'stock_movements', 'qty_base'),
  ('ledger', 'ledger_entries', 'amount_paise'),
  ('invoices', 'invoices', 'total_paise'),
  ('invoice_lines', 'invoice_lines', 'line_total_paise'),
  ('purchases', 'purchases', 'total_paise'),
];
