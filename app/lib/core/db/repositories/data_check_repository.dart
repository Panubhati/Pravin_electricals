import 'package:drift/drift.dart';

import '../../money.dart';
import '../../units.dart';
import '../app_database.dart';
import 'data_check_models.dart';
import 'repo_context.dart';

/// "Check my data": proves that the numbers in the database agree with each
/// other (bill totals, stock, balances). It only reads; it never fixes anything.
///
/// Every check is one SQL query that returns only the rows that are wrong, so a
/// big shop is still quick. Each check is named so tests can prove it catches
/// the exact thing it is meant to catch.
class DataCheckRepository {
  DataCheckRepository(this.ctx, {this.maxPerCheck = 25});
  final RepoContext ctx;

  /// Most problems listed per check; the rest are only counted.
  final int maxPerCheck;

  AppDatabase get _db => ctx.db;

  Future<DataCheckResult> run({DateTime? now}) async {
    final watch = Stopwatch()..start();
    final when = now ?? ctx.clock();
    final issues = <DataIssue>[];
    var more = 0;
    var checks = 0;

    final timings = <String, int>{};
    Future<void> check(String name, Future<List<DataIssue>> Function() body) async {
      checks++;
      final lap = Stopwatch()..start();
      final found = await body();
      timings[name] = lap.elapsedMilliseconds;
      final errors = found.where((i) => i.isError).toList();
      final notes = found.where((i) => !i.isError).toList();
      // One check can find thousands of the same problem: list the first few, count the rest.
      issues.addAll(errors.take(maxPerCheck));
      more += errors.length > maxPerCheck ? errors.length - maxPerCheck : 0;
      issues.addAll(notes.take(maxPerCheck));
    }

    await check('invoice totals', _invoiceTotals);
    await check('invoice line math', _invoiceLineMath);
    await check('invoice numbers', _invoiceNumbers);
    await check('future dates', () => _futureDated(when));
    await check('sale stock', _saleStock);
    await check('purchase stock', _purchaseStock);
    await check('movement signs', _movementSigns);
    await check('negative stock', _negativeStock);
    await check('ledger refs', _ledgerRefs);
    await check('ledger signs', _ledgerSigns);
    await check('ledger kinds', _ledgerKinds);
    await check('purchase totals', _purchaseTotals);
    await check('purchase ledger', _purchaseLedger);
    await check('items', _items);
    await check('users', _users);
    await check('sqlite integrity', _sqliteIntegrity);

    watch.stop();
    return DataCheckResult(
      ranAt: when,
      checksRun: checks,
      records: await _recordCount(),
      issues: issues,
      moreIssues: more,
      elapsed: watch.elapsed,
      timingsMs: timings,
    );
  }

  // ---- helpers --------------------------------------------------------------

  Future<List<QueryRow>> _q(String sql, [List<Variable> vars = const []]) =>
      _db.customSelect(sql, variables: vars).get();

  static int _i(QueryRow r, String k) => (r.data[k] as num?)?.toInt() ?? 0;
  static String _s(QueryRow r, String k) => (r.data[k] as String?) ?? '';
  static String _m(int paise) => Money.format(paise);

  Future<int> _recordCount() async {
    final r = await _q('SELECT (SELECT COUNT(*) FROM invoices) + (SELECT COUNT(*) FROM invoice_lines) '
        '+ (SELECT COUNT(*) FROM stock_movements) + (SELECT COUNT(*) FROM ledger_entries) '
        '+ (SELECT COUNT(*) FROM purchases) + (SELECT COUNT(*) FROM purchase_lines) '
        '+ (SELECT COUNT(*) FROM items) + (SELECT COUNT(*) FROM parties) AS n');
    return _i(r.single, 'n');
  }

  static DataIssue _err(String code, String msg, [IssueRef ref = IssueRef.none, String? id]) =>
      DataIssue(code: code, severity: IssueSeverity.error, message: msg, refType: ref, refId: id);

  static DataIssue _warn(String code, String msg, [IssueRef ref = IssueRef.none, String? id]) =>
      DataIssue(code: code, severity: IssueSeverity.warning, message: msg, refType: ref, refId: id);

  // ---- bills ----------------------------------------------------------------

  /// Each bill: total = subtotal - discount + round-off; the header agrees with
  /// its lines and payments; a credit part has exactly one customer ledger entry.
  Future<List<DataIssue>> _invoiceTotals() async {
    final rows = await _q('''
SELECT i.id, i.invoice_no_text AS no, i.subtotal_paise AS sub, i.discount_paise AS disc,
       i.round_off_paise AS ro, i.total_paise AS total, i.tax_paise AS tax, i.paid_paise AS paid,
       i.party_id AS party,
       COALESCE(l.sub, 0) AS l_sub, COALESCE(l.disc, 0) AS l_disc, COALESCE(l.tax, 0) AS l_tax,
       COALESCE(l.n, 0) AS l_n,
       COALESCE(p.total, 0) AS p_total, COALESCE(p.paid, 0) AS p_paid, COALESCE(p.credit, 0) AS p_credit,
       COALESCE(e.amt, 0) AS e_amt, COALESCE(e.n, 0) AS e_n
FROM invoices i
LEFT JOIN (SELECT invoice_id, SUM(line_total_paise + discount_paise) AS sub, SUM(discount_paise) AS disc,
                  SUM(tax_paise) AS tax, COUNT(*) AS n
           FROM invoice_lines WHERE deleted_at IS NULL GROUP BY invoice_id) l ON l.invoice_id = i.id
LEFT JOIN (SELECT invoice_id, SUM(amount_paise) AS total,
                  SUM(CASE WHEN mode != 'credit' THEN amount_paise ELSE 0 END) AS paid,
                  SUM(CASE WHEN mode = 'credit' THEN amount_paise ELSE 0 END) AS credit
           FROM invoice_payments WHERE deleted_at IS NULL GROUP BY invoice_id) p ON p.invoice_id = i.id
LEFT JOIN (SELECT ref_id, SUM(amount_paise) AS amt, COUNT(*) AS n
           FROM ledger_entries WHERE ref_type = 'invoice' AND entry_type = 'invoice' AND deleted_at IS NULL
           GROUP BY ref_id) e ON e.ref_id = i.id
WHERE i.deleted_at IS NULL''');
    final out = <DataIssue>[];
    for (final r in rows) {
      final id = _s(r, 'id');
      final no = _s(r, 'no');
      void bad(String code, String text) => out.add(_err(code, 'Bill $no: $text', IssueRef.invoice, id));

      if (_i(r, 'total') != _i(r, 'sub') - _i(r, 'disc') + _i(r, 'ro')) {
        bad('invoice_total',
            'the total is ${_m(_i(r, 'total'))} but subtotal ${_m(_i(r, 'sub'))} - discount ${_m(_i(r, 'disc'))} + round-off ${_m(_i(r, 'ro'))} is ${_m(_i(r, 'sub') - _i(r, 'disc') + _i(r, 'ro'))}.');
      }
      if (_i(r, 'l_n') == 0) {
        bad('invoice_lines_missing', 'it has no item lines.');
      } else {
        if (_i(r, 'sub') != _i(r, 'l_sub')) {
          bad('invoice_lines_sum', 'the subtotal is ${_m(_i(r, 'sub'))} but its lines add up to ${_m(_i(r, 'l_sub'))}.');
        }
        if (_i(r, 'disc') != _i(r, 'l_disc')) {
          bad('invoice_lines_discount', 'the discount is ${_m(_i(r, 'disc'))} but its lines give ${_m(_i(r, 'l_disc'))}.');
        }
        if (_i(r, 'tax') != _i(r, 'l_tax')) {
          bad('invoice_lines_tax', 'the GST is ${_m(_i(r, 'tax'))} but its lines give ${_m(_i(r, 'l_tax'))}.');
        }
      }
      if (_i(r, 'p_total') != _i(r, 'total')) {
        bad('invoice_payments', 'it was paid ${_m(_i(r, 'p_total'))} in total but the bill is ${_m(_i(r, 'total'))}.');
      }
      if (_i(r, 'paid') != _i(r, 'p_paid')) {
        bad('invoice_paid', 'it says ${_m(_i(r, 'paid'))} was paid but the payments not on credit add up to ${_m(_i(r, 'p_paid'))}.');
      }
      final credit = _i(r, 'p_credit');
      if (credit > 0 && r.data['party'] == null) {
        bad('invoice_credit_no_customer', 'part is on credit but there is no customer.');
      }
      if (credit > 0 && (_i(r, 'e_n') != 1 || _i(r, 'e_amt') != credit)) {
        bad('invoice_credit_ledger',
            'its credit part ${_m(credit)} is not in the customer\'s account correctly (account shows ${_m(_i(r, 'e_amt'))} in ${_i(r, 'e_n')} entries).');
      }
      if (credit == 0 && _i(r, 'e_n') > 0) {
        bad('invoice_ledger_extra', 'nothing is on credit but the customer\'s account has an entry for this bill.');
      }
    }
    return out;
  }

  /// Each bill line: amount = quantity x rate / unit factor (rounded half up),
  /// and the GST inside is what the formula gives.
  Future<List<DataIssue>> _invoiceLineMath() async {
    final rows = await _q('''
SELECT l.id AS lid, i.id AS iid, i.invoice_no_text AS no, COALESCE(it.name, '?') AS name,
       l.qty_base AS qty, l.rate_paise AS rate, l.price_unit_factor AS factor,
       l.discount_paise AS disc, l.line_total_paise AS total, l.tax_paise AS tax, l.gst_rate_bp AS bp,
       (2 * l.qty_base * l.rate_paise + l.price_unit_factor) / (2 * l.price_unit_factor) AS amount,
       (2 * l.line_total_paise * l.gst_rate_bp + (10000 + l.gst_rate_bp)) / (2 * (10000 + l.gst_rate_bp)) AS gst
FROM invoice_lines l
JOIN invoices i ON i.id = l.invoice_id AND i.deleted_at IS NULL
LEFT JOIN items it ON it.id = l.item_id
WHERE l.deleted_at IS NULL AND l.price_unit_factor > 0
  AND ((2 * l.qty_base * l.rate_paise + l.price_unit_factor) / (2 * l.price_unit_factor) != l.line_total_paise + l.discount_paise
       OR (2 * l.line_total_paise * l.gst_rate_bp + (10000 + l.gst_rate_bp)) / (2 * (10000 + l.gst_rate_bp)) != l.tax_paise
       OR l.qty_base <= 0 OR l.line_total_paise < 0)''');
    final bad = await _q('SELECT l.id AS lid, i.id AS iid, i.invoice_no_text AS no, COALESCE(it.name, \'?\') AS name '
        'FROM invoice_lines l JOIN invoices i ON i.id = l.invoice_id '
        'LEFT JOIN items it ON it.id = l.item_id WHERE l.deleted_at IS NULL AND l.price_unit_factor <= 0');
    return [
      for (final r in rows)
        _err(
          'invoice_line_math',
          'Bill ${_s(r, 'no')}, ${_s(r, 'name')}: the line shows ${_m(_i(r, 'total') + _i(r, 'disc'))} before discount '
          '(GST ${_m(_i(r, 'tax'))}) but quantity x rate gives ${_m(_i(r, 'amount'))} (GST ${_m(_i(r, 'gst'))}).',
          IssueRef.invoice,
          _s(r, 'iid'),
        ),
      for (final r in bad)
        _err('invoice_line_factor', 'Bill ${_s(r, 'no')}, ${_s(r, 'name')}: the unit factor is not a positive number.',
            IssueRef.invoice, _s(r, 'iid')),
    ];
  }

  /// No bill number twice in a device series (a gap is only a note).
  Future<List<DataIssue>> _invoiceNumbers() async {
    final dup = await _q('SELECT series, number, COUNT(*) AS n FROM invoices '
        'GROUP BY device_id, series, number HAVING n > 1');
    final gaps = await _q('SELECT series, MIN(number) AS mn, MAX(number) AS mx, COUNT(*) AS n FROM invoices '
        'GROUP BY device_id, series HAVING mx - mn + 1 != n');
    return [
      for (final r in dup)
        _err('invoice_number_duplicate', 'Bill number ${_s(r, 'series')}-${_i(r, 'number')} is used ${_i(r, 'n')} times.'),
      for (final r in gaps)
        _warn('invoice_number_gap',
            'Series ${_s(r, 'series')}: numbers ${_i(r, 'mn')} to ${_i(r, 'mx')} should be ${_i(r, 'mx') - _i(r, 'mn') + 1} bills but ${_i(r, 'n')} exist.'),
    ];
  }

  /// A bill dated more than a day ahead usually means the phone's clock was wrong.
  Future<List<DataIssue>> _futureDated(DateTime now) async {
    final limit = now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
    final rows = await _q('SELECT id, invoice_no_text AS no FROM invoices WHERE deleted_at IS NULL AND date > ?',
        [Variable.withInt(limit)]);
    return [
      for (final r in rows)
        _warn('invoice_future_date', 'Bill ${_s(r, 'no')} is dated in the future (was the phone\'s clock wrong?).',
            IssueRef.invoice, _s(r, 'id')),
    ];
  }

  // ---- stock ----------------------------------------------------------------

  /// Every item sold on a bill took exactly that quantity out of stock.
  ///
  /// One pass: bill lines and their stock movements are added into the same
  /// (bill, item) groups, and only the groups where the two sides differ come back.
  /// (Joining two big grouped lists was ten times slower.)
  Future<List<DataIssue>> _saleStock() async {
    final rows = await _q('''
SELECT t.ref AS ref, t.sold AS sold, t.moved AS moved, i.invoice_no_text AS no,
       COALESCE(it.name, '?') AS name, it.id AS item, it.price_unit_factor AS factor, it.base_unit AS base
FROM (SELECT ref, item, SUM(sold) AS sold, SUM(moved) AS moved FROM (
        SELECT l.invoice_id AS ref, l.item_id AS item, l.qty_base AS sold, 0 AS moved
        FROM invoice_lines l WHERE l.deleted_at IS NULL
        UNION ALL
        SELECT m.ref_id, m.item_id, 0, -m.qty_base
        FROM stock_movements m
        WHERE m.ref_type = 'invoice' AND m.movement_type = 'sale' AND m.deleted_at IS NULL)
      GROUP BY ref, item HAVING SUM(sold) != SUM(moved)) t
LEFT JOIN invoices i ON i.id = t.ref
LEFT JOIN items it ON it.id = t.item''');
    final out = <DataIssue>[];
    for (final r in rows) {
      final sold = _i(r, 'sold');
      final moved = _i(r, 'moved');
      if (sold == 0) {
        out.add(_err('sale_stock_orphan',
            '${_s(r, 'name')}: stock was taken out (${_qty(moved, r)}) for a bill line that does not exist.',
            IssueRef.item, _s(r, 'item')));
      } else {
        out.add(_err(
          'sale_stock_mismatch',
          'Bill ${_s(r, 'no')}, ${_s(r, 'name')}: ${_qty(sold, r)} sold but ${_qty(moved, r)} left stock.',
          IssueRef.invoice,
          _s(r, 'ref'),
        ));
      }
    }
    return out;
  }

  /// Every item bought on a purchase added exactly that quantity to stock.
  Future<List<DataIssue>> _purchaseStock() async {
    final rows = await _q('''
SELECT t.ref AS ref, t.bought AS bought, t.moved AS moved, p.supplier_invoice_no AS no,
       COALESCE(it.name, '?') AS name, it.id AS item, it.price_unit_factor AS factor, it.base_unit AS base
FROM (SELECT ref, item, SUM(bought) AS bought, SUM(moved) AS moved FROM (
        SELECT l.purchase_id AS ref, l.item_id AS item, l.qty_base AS bought, 0 AS moved
        FROM purchase_lines l WHERE l.deleted_at IS NULL
        UNION ALL
        SELECT m.ref_id, m.item_id, 0, m.qty_base
        FROM stock_movements m
        WHERE m.ref_type = 'purchase' AND m.movement_type = 'purchase' AND m.deleted_at IS NULL)
      GROUP BY ref, item HAVING SUM(bought) != SUM(moved)) t
LEFT JOIN purchases p ON p.id = t.ref
LEFT JOIN items it ON it.id = t.item''');
    final out = <DataIssue>[];
    for (final r in rows) {
      final bought = _i(r, 'bought');
      final moved = _i(r, 'moved');
      if (bought == 0) {
        out.add(_err('purchase_stock_orphan',
            '${_s(r, 'name')}: stock was added (${_qty(moved, r)}) for a purchase line that does not exist.',
            IssueRef.item, _s(r, 'item')));
      } else {
        out.add(_err(
          'purchase_stock_mismatch',
          'Purchase ${_s(r, 'no')}, ${_s(r, 'name')}: ${_qty(bought, r)} bought but ${_qty(moved, r)} added to stock.',
          IssueRef.purchase,
          _s(r, 'ref'),
        ));
      }
    }
    return out;
  }

  /// A sale never adds stock and a purchase never removes it.
  Future<List<DataIssue>> _movementSigns() async {
    final rows = await _q('''
SELECT m.movement_type AS type, COALESCE(it.name, '?') AS name, m.item_id AS item, COUNT(*) AS n
FROM stock_movements m LEFT JOIN items it ON it.id = m.item_id
WHERE m.deleted_at IS NULL
  AND ((m.movement_type IN ('sale', 'purchase_return', 'transfer_out') AND m.qty_base > 0)
    OR (m.movement_type IN ('purchase', 'sale_return', 'transfer_in') AND m.qty_base < 0)
    OR m.qty_base = 0)
GROUP BY m.movement_type, m.item_id''');
    return [
      for (final r in rows)
        _err('movement_sign',
            '${_s(r, 'name')}: ${_i(r, 'n')} "${_s(r, 'type')}" stock movement(s) have the wrong direction or no quantity.',
            IssueRef.item, _s(r, 'item')),
    ];
  }

  /// Stock below zero (sold more than recorded) is possible in a shop, so only a note.
  Future<List<DataIssue>> _negativeStock() async {
    final rows = await _q('''
SELECT it.id AS item, it.name AS name, it.price_unit_factor AS factor, it.base_unit AS base, SUM(m.qty_base) AS bal
FROM stock_movements m JOIN items it ON it.id = m.item_id
WHERE m.deleted_at IS NULL AND it.deleted_at IS NULL
GROUP BY m.item_id HAVING bal < 0''');
    return [
      for (final r in rows)
        _warn('negative_stock', '${_s(r, 'name')}: stock is ${_qty(_i(r, 'bal'), r)} (below zero).', IssueRef.item,
            _s(r, 'item')),
    ];
  }

  /// "2.5 m" or "10 pcs" from base units, using the item's selling unit.
  static String _qty(int base, QueryRow r) {
    final factor = (r.data['factor'] as num?)?.toInt() ?? 1;
    final baseUnit = (r.data['base'] as String?) ?? '';
    final unit = factor == 1 ? baseUnit : (baseUnit == 'mm' && factor == 1000 ? 'm' : '$factor $baseUnit');
    return '${Units.formatQty(base, factor <= 0 ? 1 : factor)} $unit';
  }

  // ---- ledger ---------------------------------------------------------------

  /// A ledger entry that points at a bill or purchase must point at a real one.
  Future<List<DataIssue>> _ledgerRefs() async {
    final rows = await _q('''
SELECT e.id, e.entry_type AS type, e.ref_type AS rtype, COALESCE(p.name, '?') AS party, e.party_id AS pid
FROM ledger_entries e LEFT JOIN parties p ON p.id = e.party_id
WHERE e.deleted_at IS NULL
  AND ((e.ref_type = 'invoice' AND NOT EXISTS (SELECT 1 FROM invoices i WHERE i.id = e.ref_id))
    OR (e.ref_type = 'purchase' AND NOT EXISTS (SELECT 1 FROM purchases p2 WHERE p2.id = e.ref_id)))''');
    return [
      for (final r in rows)
        _err('ledger_orphan',
            '${_s(r, 'party')}: an account entry (${_s(r, 'type')}) points at a ${_s(r, 'rtype')} that does not exist.',
            IssueRef.party, _s(r, 'pid')),
    ];
  }

  /// Bills and purchases move a balance one way, payments the other.
  Future<List<DataIssue>> _ledgerSigns() async {
    final rows = await _q('''
SELECT e.entry_type AS type, e.party_id AS pid, COALESCE(p.name, '?') AS party, COUNT(*) AS n
FROM ledger_entries e LEFT JOIN parties p ON p.id = e.party_id
WHERE e.deleted_at IS NULL
  AND ((e.entry_type = 'invoice' AND e.amount_paise <= 0)
    OR (e.entry_type = 'payment' AND e.amount_paise >= 0)
    OR (e.entry_type = 'purchase' AND e.amount_paise >= 0)
    OR (e.entry_type = 'supplier_payment' AND e.amount_paise <= 0)
    OR (e.entry_type = 'return' AND e.amount_paise >= 0))
GROUP BY e.entry_type, e.party_id''');
    return [
      for (final r in rows)
        _err('ledger_sign',
            '${_s(r, 'party')}: ${_i(r, 'n')} "${_s(r, 'type')}" account entr${_i(r, 'n') == 1 ? 'y' : 'ies'} with the wrong sign.',
            IssueRef.party, _s(r, 'pid')),
    ];
  }

  /// A customer bill on a supplier, or a purchase on a customer, is odd.
  Future<List<DataIssue>> _ledgerKinds() async {
    final rows = await _q('''
SELECT p.id AS pid, p.name AS name, p.kind AS kind, COUNT(*) AS n
FROM ledger_entries e JOIN parties p ON p.id = e.party_id
WHERE e.deleted_at IS NULL
  AND ((p.kind = 'supplier' AND e.entry_type IN ('invoice', 'payment', 'return'))
    OR (p.kind = 'customer' AND e.entry_type IN ('purchase', 'supplier_payment')))
GROUP BY p.id''');
    return [
      for (final r in rows)
        _warn('ledger_party_kind',
            '${_s(r, 'name')} is a ${_s(r, 'kind')} but has ${_i(r, 'n')} account entries of the other kind.',
            IssueRef.party, _s(r, 'pid')),
    ];
  }

  // ---- purchases ------------------------------------------------------------

  Future<List<DataIssue>> _purchaseTotals() async {
    final rows = await _q('''
SELECT p.id, p.supplier_invoice_no AS no, p.subtotal_paise AS sub, p.tax_paise AS tax, p.total_paise AS total,
       COALESCE(l.sub, 0) AS l_sub, COALESCE(l.tax, 0) AS l_tax, COALESCE(l.n, 0) AS l_n
FROM purchases p
LEFT JOIN (SELECT purchase_id, SUM(line_total_paise) AS sub,
                  SUM((2 * line_total_paise * gst_rate_bp + 10000) / 20000) AS tax, COUNT(*) AS n
           FROM purchase_lines WHERE deleted_at IS NULL GROUP BY purchase_id) l ON l.purchase_id = p.id
WHERE p.deleted_at IS NULL''');
    final lineRows = await _q('''
SELECT p.id AS pid, p.supplier_invoice_no AS no, COALESCE(it.name, '?') AS name
FROM purchase_lines l JOIN purchases p ON p.id = l.purchase_id
LEFT JOIN items it ON it.id = l.item_id
WHERE l.deleted_at IS NULL AND l.price_unit_factor > 0
  AND (2 * l.qty_base * l.rate_paise + l.price_unit_factor) / (2 * l.price_unit_factor) != l.line_total_paise''');
    final out = <DataIssue>[];
    for (final r in rows) {
      final id = _s(r, 'id');
      final no = _s(r, 'no');
      void bad(String code, String text) => out.add(_err(code, 'Purchase $no: $text', IssueRef.purchase, id));
      if (_i(r, 'total') != _i(r, 'sub') + _i(r, 'tax')) {
        bad('purchase_total', 'the total is ${_m(_i(r, 'total'))} but subtotal + GST is ${_m(_i(r, 'sub') + _i(r, 'tax'))}.');
      }
      if (_i(r, 'l_n') == 0) {
        bad('purchase_lines_missing', 'it has no item lines.');
      } else {
        if (_i(r, 'sub') != _i(r, 'l_sub')) {
          bad('purchase_lines_sum', 'the subtotal is ${_m(_i(r, 'sub'))} but its lines add up to ${_m(_i(r, 'l_sub'))}.');
        }
        if (_i(r, 'tax') != _i(r, 'l_tax')) {
          bad('purchase_lines_tax', 'the GST is ${_m(_i(r, 'tax'))} but its lines give ${_m(_i(r, 'l_tax'))}.');
        }
      }
    }
    for (final r in lineRows) {
      out.add(_err('purchase_line_math',
          'Purchase ${_s(r, 'no')}, ${_s(r, 'name')}: a line does not equal quantity x rate.', IssueRef.purchase, _s(r, 'pid')));
    }
    return out;
  }

  /// Each purchase is in the supplier's account once, for the full total (owed to them).
  Future<List<DataIssue>> _purchaseLedger() async {
    final rows = await _q('''
SELECT p.id, p.supplier_invoice_no AS no, p.total_paise AS total,
       COALESCE(e.amt, 0) AS amt, COALESCE(e.n, 0) AS n
FROM purchases p
LEFT JOIN (SELECT ref_id, SUM(amount_paise) AS amt, COUNT(*) AS n FROM ledger_entries
           WHERE ref_type = 'purchase' AND entry_type = 'purchase' AND deleted_at IS NULL GROUP BY ref_id) e
  ON e.ref_id = p.id
WHERE p.deleted_at IS NULL AND (COALESCE(e.n, 0) != 1 OR COALESCE(e.amt, 0) != -p.total_paise)''');
    return [
      for (final r in rows)
        _err('purchase_ledger',
            'Purchase ${_s(r, 'no')}: ${_m(_i(r, 'total'))} should be owed to the supplier, but their account shows ${_m(-_i(r, 'amt'))} in ${_i(r, 'n')} entries.',
            IssueRef.purchase, _s(r, 'id')),
    ];
  }

  // ---- items, users, the database itself -----------------------------------

  Future<List<DataIssue>> _items() async {
    final noUnit = await _q('''
SELECT it.id, it.name FROM items it
WHERE it.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM item_units u WHERE u.item_id = it.id AND u.deleted_at IS NULL)''');
    final badFactor = await _q('''
SELECT it.id, it.name FROM items it
WHERE it.deleted_at IS NULL AND (it.price_unit_factor < 1 OR it.min_stock_base < 0)''');
    final badUnit = await _q('''
SELECT it.id, it.name FROM items it JOIN item_units u ON u.item_id = it.id
WHERE it.deleted_at IS NULL AND u.deleted_at IS NULL AND u.factor_to_base < 1''');
    final badPrice = await _q('''
SELECT it.id, it.name FROM items it
WHERE it.deleted_at IS NULL AND (
  EXISTS (SELECT 1 FROM item_prices p WHERE p.item_id = it.id AND p.deleted_at IS NULL AND p.rate_paise < 0)
  OR EXISTS (SELECT 1 FROM item_costs c WHERE c.item_id = it.id AND c.deleted_at IS NULL AND c.cost_paise < 0))''');
    return [
      for (final r in noUnit)
        _err('item_no_unit', '${_s(r, 'name')} has no selling unit.', IssueRef.item, _s(r, 'id')),
      for (final r in badFactor)
        _err('item_factor', '${_s(r, 'name')} has an invalid unit factor or minimum stock.', IssueRef.item, _s(r, 'id')),
      for (final r in badUnit)
        _err('item_unit_factor', '${_s(r, 'name')} has a unit that is not at least 1 base unit.', IssueRef.item, _s(r, 'id')),
      for (final r in badPrice)
        _err('item_negative_price', '${_s(r, 'name')} has a negative price or cost.', IssueRef.item, _s(r, 'id')),
    ];
  }

  /// One owner, and the owner has a PIN.
  Future<List<DataIssue>> _users() async {
    final owners = await _q("SELECT COUNT(*) AS n, SUM(CASE WHEN pin_hash IS NOT NULL THEN 1 ELSE 0 END) AS pins "
        "FROM users WHERE role = 'owner' AND deleted_at IS NULL AND active = 1");
    final r = owners.single;
    return [
      if (_i(r, 'n') != 1) _err('owner_count', 'There should be exactly one owner but there are ${_i(r, 'n')}.'),
      if (_i(r, 'n') == 1 && _i(r, 'pins') == 0) _warn('owner_no_pin', 'The owner has no PIN set.'),
    ];
  }

  /// SQLite's own checks: the file is not damaged and every link points at a real row.
  Future<List<DataIssue>> _sqliteIntegrity() async {
    final integrity = await _q('PRAGMA integrity_check');
    final fk = await _q('PRAGMA foreign_key_check');
    final bad = [for (final r in integrity) r.data.values.first.toString()]..removeWhere((s) => s == 'ok');
    return [
      for (final s in bad) _err('sqlite_integrity', 'The database file reports a problem: $s'),
      if (fk.isNotEmpty)
        _err('foreign_keys',
            '${fk.length} record(s) point at something that no longer exists (for example ${fk.first.data['table']}).'),
    ];
  }
}
