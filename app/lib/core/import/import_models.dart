/// A problem found in one row, to show next to it in the preview.
class ImportIssue {
  const ImportIssue(this.rowNumber, this.message, {this.column});

  /// Row as seen in Excel (header = 1). 0 means the whole file (for example a
  /// missing column).
  final int rowNumber;
  final String message;
  final String? column;

  @override
  String toString() => rowNumber == 0
      ? message
      : 'Row $rowNumber${column == null ? '' : ' ($column)'}: $message';
}

/// A row that is valid but will not be imported, usually because it already exists.
class ImportSkip {
  const ImportSkip(this.rowNumber, this.name, this.reason);
  final int rowNumber;
  final String name;
  final String reason;
}

/// What an import did.
class ImportResult {
  const ImportResult({
    required this.created,
    required this.skipped,
    required this.errors,
  });

  /// Rows saved.
  final int created;

  /// Valid rows left out (already exist, or repeated in the file).
  final int skipped;

  /// Rows with problems that were not imported.
  final int errors;
}
