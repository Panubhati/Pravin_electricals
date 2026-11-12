import 'dart:convert';

/// How serious a finding is.
enum IssueSeverity {
  /// Two numbers that must agree do not (a total, a balance, a missing stock
  /// movement). Needs looking at.
  error,

  /// Unusual but possible (negative stock, a bill dated in the future).
  warning,
}

/// What kind of record an issue is about, so the screen can open it.
enum IssueRef { invoice, purchase, item, party, none }

/// One thing the data check found, in plain words.
class DataIssue {
  const DataIssue({
    required this.code,
    required this.severity,
    required this.message,
    this.refType = IssueRef.none,
    this.refId,
  });

  /// Short stable name of the check, for tests (for example `invoice_total`).
  final String code;
  final IssueSeverity severity;
  final String message;
  final IssueRef refType;
  final String? refId;

  bool get isError => severity == IssueSeverity.error;

  @override
  String toString() => '${isError ? 'ERROR' : 'warning'} [$code] $message';
}

/// The outcome of one run of "Check my data".
class DataCheckResult {
  const DataCheckResult({
    required this.ranAt,
    required this.checksRun,
    required this.records,
    required this.issues,
    required this.moreIssues,
    required this.elapsed,
    this.timingsMs = const {},
  });

  final DateTime ranAt;

  /// How many different checks were run.
  final int checksRun;

  /// How many records were looked at in total (bills, lines, movements...).
  final int records;
  final List<DataIssue> issues;

  /// Issues not listed because one check found a great many (so the list stays readable).
  final int moreIssues;
  final Duration elapsed;

  /// How long each check took, by name (for finding a slow one).
  final Map<String, int> timingsMs;

  List<DataIssue> get errors => [for (final i in issues) if (i.isError) i];
  List<DataIssue> get warnings => [for (final i in issues) if (!i.isError) i];
  int get errorCount => errors.length + moreIssues;
  int get warningCount => warnings.length;

  /// No errors (warnings alone do not fail the check).
  bool get passed => errorCount == 0;

  DataCheckSummary get summary => DataCheckSummary(
        ranAt: ranAt,
        checks: checksRun,
        records: records,
        errors: errorCount,
        warnings: warningCount,
      );

  /// A plain-text report the owner can send to someone.
  String toReport(String shopName) {
    final b = StringBuffer()
      ..writeln('Data check for $shopName')
      ..writeln('Run at $ranAt')
      ..writeln('$checksRun checks over $records records: '
          '${passed ? 'all numbers agree' : '$errorCount problem(s)'}'
          '${warningCount > 0 ? ', $warningCount warning(s)' : ''}.')
      ..writeln();
    for (final i in issues) {
      b.writeln('- ${i.isError ? 'PROBLEM' : 'Note'}: ${i.message}');
    }
    if (moreIssues > 0) b.writeln('- ...and $moreIssues more problems of the same kind.');
    return b.toString();
  }
}

/// What is remembered about the last run (shown in Settings and on Home).
class DataCheckSummary {
  const DataCheckSummary({
    required this.ranAt,
    required this.checks,
    required this.records,
    required this.errors,
    required this.warnings,
  });

  final DateTime ranAt;
  final int checks;
  final int records;
  final int errors;
  final int warnings;

  bool get passed => errors == 0;

  String toJson() => jsonEncode({
        'at': ranAt.millisecondsSinceEpoch,
        'checks': checks,
        'records': records,
        'errors': errors,
        'warnings': warnings,
      });

  static DataCheckSummary? fromJson(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final m = jsonDecode(text) as Map;
      return DataCheckSummary(
        ranAt: DateTime.fromMillisecondsSinceEpoch(m['at'] as int),
        checks: m['checks'] as int,
        records: m['records'] as int,
        errors: m['errors'] as int,
        warnings: m['warnings'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}
