import '../db/repositories/ledger_repository.dart';
import '../db/repositories/party_repository.dart';
import '../db/repositories/repo_context.dart';
import 'csv_table.dart';
import 'import_models.dart';
import 'value_parsers.dart';

/// One valid customer or supplier row.
class PartyImportRow {
  const PartyImportRow({
    required this.rowNumber,
    required this.kind,
    required this.name,
    required this.tier,
    required this.creditLimitPaise,
    required this.openingBalancePaise,
    this.phone,
    this.gstin,
    this.stateCode,
  });

  final int rowNumber;

  /// customer | supplier | both
  final String kind;
  final String name;
  final String? phone;
  final String? gstin;
  final String? stateCode;
  final String tier;
  final int creditLimitPaise;

  /// Amount already owed at the start, as a positive number: what a customer
  /// owes the shop, or what the shop owes a supplier. Converted to the ledger
  /// sign when saved.
  final int openingBalancePaise;
}

class PartyImportPreview {
  const PartyImportPreview({
    required this.totalRows,
    required this.toCreate,
    required this.skipped,
    required this.errors,
  });

  final int totalRows;
  final List<PartyImportRow> toCreate;
  final List<ImportSkip> skipped;
  final List<ImportIssue> errors;

  bool get canImport => toCreate.isNotEmpty;
}

/// Bulk import of customers and suppliers, with opening balances, from CSV.
/// Same safety rules as the items import: check first, report bad rows, save
/// the valid rows in one transaction, skip parties that already exist.
class PartyImportService {
  PartyImportService(this.ctx)
      : _parties = PartyRepository(ctx),
        _ledger = LedgerRepository(ctx);

  final RepoContext ctx;
  final PartyRepository _parties;
  final LedgerRepository _ledger;

  static const requiredColumns = ['name'];

  static const templateCsv =
      'kind,name,phone,gstin,state_code,tier,credit_limit,opening_balance\n'
      'customer,Ramesh Electricals,9800000001,,27,contractor,10000,2500\n'
      'customer,Sunita Sharma,9800000002,,,retail,0,0\n'
      'supplier,Sample Supplier,9800000003,27AAAAA0000A1Z5,27,retail,0,15000\n';

  Future<PartyImportPreview> preview(String csvText) async {
    final table = parseCsv(csvText);
    if (table.headers.isEmpty) {
      return const PartyImportPreview(
        totalRows: 0,
        toCreate: [],
        skipped: [],
        errors: [ImportIssue(0, 'The file is empty')],
      );
    }
    final missing = [
      for (final c in requiredColumns)
        if (!table.hasColumn(c)) ImportIssue(0, 'Column "$c" is missing from the file'),
    ];
    if (missing.isNotEmpty) {
      return PartyImportPreview(
          totalRows: table.rows.length, toCreate: const [], skipped: const [], errors: missing);
    }

    final existing = await _existingKeys();
    final seen = <String, int>{};
    final toCreate = <PartyImportRow>[];
    final skipped = <ImportSkip>[];
    final errors = <ImportIssue>[];

    for (final r in table.rows) {
      final issues = <ImportIssue>[];
      final row = _parseRow(r, issues);
      if (row == null) {
        errors.addAll(issues);
        continue;
      }
      final key = _key(row.name, row.phone);
      if (existing.contains(key)) {
        skipped.add(ImportSkip(row.rowNumber, row.name, 'Already in your parties'));
        continue;
      }
      final first = seen[key];
      if (first != null) {
        skipped.add(ImportSkip(row.rowNumber, row.name, 'Repeated in this file (row $first)'));
        continue;
      }
      seen[key] = row.rowNumber;
      toCreate.add(row);
    }
    return PartyImportPreview(
      totalRows: table.rows.length,
      toCreate: toCreate,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Saves the valid rows in one transaction; opening balances become 'opening'
  /// ledger entries (customer owes: +, shop owes supplier: -).
  Future<ImportResult> apply(PartyImportPreview preview) async {
    var created = 0;
    var skippedNow = preview.skipped.length;
    await ctx.db.transaction(() async {
      final existing = await _existingKeys();
      for (final r in preview.toCreate) {
        final key = _key(r.name, r.phone);
        if (existing.contains(key)) {
          skippedNow++;
          continue;
        }
        final id = await _parties.createParty(
          kind: r.kind,
          name: r.name,
          tier: r.tier,
          phone: r.phone,
          gstin: r.gstin,
          stateCode: r.stateCode,
          creditLimitPaise: r.creditLimitPaise,
        );
        if (r.openingBalancePaise != 0) {
          final signed =
              r.kind == 'supplier' ? -r.openingBalancePaise : r.openingBalancePaise;
          await _ledger.addOpeningBalance(id, signed);
        }
        existing.add(key);
        created++;
      }
    });
    return ImportResult(
      created: created,
      skipped: skippedNow,
      errors: preview.errors.map((e) => e.rowNumber).toSet().length,
    );
  }

  PartyImportRow? _parseRow(CsvRow r, List<ImportIssue> issues) {
    void bad(String column, String message) =>
        issues.add(ImportIssue(r.rowNumber, message, column: column));

    final name = r.get('name');
    if (name.isEmpty) bad('name', 'Name is required');

    var kind = r.get('kind').toLowerCase();
    if (kind.isEmpty) kind = 'customer';
    if (!PartyRepository.kinds.contains(kind)) {
      bad('kind', 'Kind must be customer, supplier or both');
    }

    var tier = r.get('tier').toLowerCase();
    if (tier.isEmpty) tier = 'retail';
    if (!PartyRepository.tiers.contains(tier)) {
      bad('tier', 'Tier must be retail, contractor or dealer');
    }

    final gstin = r.get('gstin').toUpperCase();
    if (gstin.isNotEmpty && !looksLikeGstin(gstin)) {
      bad('gstin', 'GSTIN should be 15 characters, like 27AAAAA0000A1Z5');
    }

    final state = r.get('state_code');
    if (state.isNotEmpty && !RegExp(r'^\d{2}$').hasMatch(state)) {
      bad('state_code', 'State code should be 2 digits, like 27');
    }

    int amount(String column, {bool allowNegative = false}) {
      final text = r.get(column);
      if (text.isEmpty) return 0;
      try {
        return parseRupees(text, allowNegative: allowNegative);
      } on FormatException catch (e) {
        bad(column, e.message);
        return 0;
      }
    }

    final limit = amount('credit_limit');
    final opening = amount('opening_balance');

    if (issues.isNotEmpty) return null;
    String? nullIfEmpty(String s) => s.isEmpty ? null : s;
    return PartyImportRow(
      rowNumber: r.rowNumber,
      kind: kind,
      name: name,
      phone: nullIfEmpty(r.get('phone')),
      gstin: nullIfEmpty(gstin),
      stateCode: nullIfEmpty(state),
      tier: tier,
      creditLimitPaise: limit,
      openingBalancePaise: opening,
    );
  }

  static String _key(String name, String? phone) =>
      '${name.trim().toLowerCase()}|${(phone ?? '').trim()}';

  Future<Set<String>> _existingKeys() async {
    final all = await _parties.list(limit: 100000);
    return {for (final p in all) _key(p.name, p.phone)};
  }
}
