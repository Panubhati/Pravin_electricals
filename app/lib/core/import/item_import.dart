import 'package:drift/drift.dart';

import '../db/repositories/item_repository.dart';
import '../db/repositories/repo_context.dart';
import '../db/repositories/stock_repository.dart';
import '../units.dart';
import 'csv_table.dart';
import 'import_models.dart';
import 'value_parsers.dart';

/// One valid item row, converted to the app's units (millimetres for cable,
/// pieces otherwise) and paise.
class ItemImportRow {
  const ItemImportRow({
    required this.rowNumber,
    required this.name,
    required this.gstRateBp,
    required this.isLength,
    required this.retailPaise,
    required this.minStockBase,
    required this.openingStockBase,
    this.brand,
    this.category,
    this.hsn,
    this.rollLengthBase,
    this.boxSize,
    this.contractorPaise,
    this.dealerPaise,
    this.costPaise,
    this.barcode,
  });

  final int rowNumber;
  final String name;
  final String? brand;
  final String? category;
  final String? hsn;
  final int gstRateBp;

  /// True for cable sold by length (stored in mm), false for pieces.
  final bool isLength;

  /// Length of one roll in mm (length items only).
  final int? rollLengthBase;

  /// Pieces in one box (piece items only).
  final int? boxSize;

  /// Selling prices include GST, paise per metre or per piece.
  final int retailPaise;
  final int? contractorPaise;
  final int? dealerPaise;

  /// Cost excludes GST, paise per metre or per piece.
  final int? costPaise;
  final int minStockBase;
  final int openingStockBase;
  final String? barcode;
}

/// What an items file would do, shown before anything is saved.
class ItemImportPreview {
  const ItemImportPreview({
    required this.totalRows,
    required this.toCreate,
    required this.skipped,
    required this.errors,
  });

  final int totalRows;
  final List<ItemImportRow> toCreate;
  final List<ImportSkip> skipped;
  final List<ImportIssue> errors;

  bool get canImport => toCreate.isNotEmpty;
}

/// Bulk import of items (with prices, cost and opening stock) from CSV.
///
/// Rows are checked first and bad rows are reported, never half-imported. The
/// valid rows are then saved in a single transaction, so a failure leaves
/// nothing behind. Items that already exist (same name and brand) are skipped,
/// which makes re-importing the same file safe.
class ItemImportService {
  ItemImportService(this.ctx)
      : _items = ItemRepository(ctx),
        _stock = StockRepository(ctx);

  final RepoContext ctx;
  final ItemRepository _items;
  final StockRepository _stock;

  static const requiredColumns = ['name', 'type', 'gst_percent', 'retail_price'];

  static const templateCsv =
      'name,brand,category,hsn,gst_percent,type,roll_length_m,box_size,'
      'retail_price,contractor_price,dealer_price,cost_price,min_stock,'
      'opening_stock,barcode\n'
      '1.5 sqmm copper wire,Polycab,Wire,8544,18,length,90,,47.50,44,42,30,100,450,8901234567890\n'
      '6A switch,Anchor,Switches,8536,18,piece,,10,15,13.50,,9,20,200,\n'
      'LED bulb 9W,Philips,Lighting,8539,12,piece,,10,90,,,60,10,40,\n';

  /// Reads [csvText] and reports what would happen, without saving anything.
  Future<ItemImportPreview> preview(String csvText) async {
    final table = parseCsv(csvText);
    final errors = <ImportIssue>[];

    if (table.headers.isEmpty) {
      return ItemImportPreview(
        totalRows: 0,
        toCreate: const [],
        skipped: const [],
        errors: [const ImportIssue(0, 'The file is empty')],
      );
    }
    for (final c in requiredColumns) {
      if (!table.hasColumn(c)) {
        errors.add(ImportIssue(0, 'Column "$c" is missing from the file'));
      }
    }
    if (errors.isNotEmpty) {
      return ItemImportPreview(
          totalRows: table.rows.length, toCreate: const [], skipped: const [], errors: errors);
    }

    final existing = await _existing();
    final seenKeys = <String, int>{};
    final seenBarcodes = <String, int>{};
    final toCreate = <ItemImportRow>[];
    final skipped = <ImportSkip>[];

    for (final r in table.rows) {
      final issues = <ImportIssue>[];
      final row = _parseRow(r, issues);
      if (row == null) {
        errors.addAll(issues);
        continue;
      }
      final key = _key(row.name, row.brand);
      if (existing.keys.contains(key)) {
        skipped.add(ImportSkip(row.rowNumber, row.name, 'Already in your items'));
        continue;
      }
      final firstRow = seenKeys[key];
      if (firstRow != null) {
        skipped.add(ImportSkip(row.rowNumber, row.name, 'Repeated in this file (row $firstRow)'));
        continue;
      }
      final code = row.barcode;
      if (code != null) {
        if (existing.barcodes.contains(code)) {
          errors.add(ImportIssue(row.rowNumber, 'Barcode $code is already used by another item',
              column: 'barcode'));
          continue;
        }
        final other = seenBarcodes[code];
        if (other != null) {
          errors.add(ImportIssue(row.rowNumber, 'Barcode $code is already used in row $other',
              column: 'barcode'));
          continue;
        }
        seenBarcodes[code] = row.rowNumber;
      }
      seenKeys[key] = row.rowNumber;
      toCreate.add(row);
    }

    return ItemImportPreview(
      totalRows: table.rows.length,
      toCreate: toCreate,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Saves the valid rows of [preview] in one transaction. Rows that became
  /// duplicates since the preview are skipped. Throws on any database failure
  /// after rolling everything back.
  Future<ImportResult> apply(
    ItemImportPreview preview, {
    required String locationId,
    String? userId,
  }) async {
    var created = 0;
    var skippedNow = preview.skipped.length;
    await ctx.db.transaction(() async {
      final existing = await _existing();
      for (final r in preview.toCreate) {
        if (existing.keys.contains(_key(r.name, r.brand))) {
          skippedNow++;
          continue;
        }
        final id = await _items.createItem(
          name: r.name,
          brand: r.brand,
          category: r.category,
          hsn: r.hsn,
          baseUnit: r.isLength ? 'mm' : 'pcs',
          priceUnitFactor: r.isLength ? 1000 : 1,
          gstRateBp: r.gstRateBp,
          minStockBase: r.minStockBase,
          units: [
            if (r.isLength) const ItemUnitInput('m', 1000),
            if (r.isLength && r.rollLengthBase != null)
              ItemUnitInput('roll', r.rollLengthBase!),
            if (!r.isLength && r.boxSize != null) ItemUnitInput('box', r.boxSize!),
          ],
        );
        await _items.setPrice(itemId: id, tier: 'retail', ratePaise: r.retailPaise);
        if (r.contractorPaise != null) {
          await _items.setPrice(itemId: id, tier: 'contractor', ratePaise: r.contractorPaise!);
        }
        if (r.dealerPaise != null) {
          await _items.setPrice(itemId: id, tier: 'dealer', ratePaise: r.dealerPaise!);
        }
        if (r.costPaise != null) {
          await _items.setCost(itemId: id, costPaise: r.costPaise!);
        }
        if (r.barcode != null) {
          await _items.addVariant(
              itemId: id, label: kDefaultVariantLabel, barcode: r.barcode);
        }
        if (r.openingStockBase > 0) {
          await _stock.record(
            itemId: id,
            locationId: locationId,
            qtyBase: r.openingStockBase,
            movementType: 'adjustment',
            refType: 'opening',
            note: 'Opening stock',
            createdBy: userId,
          );
        }
        existing.keys.add(_key(r.name, r.brand));
        created++;
      }
    });
    return ImportResult(
      created: created,
      skipped: skippedNow,
      errors: preview.errors.map((e) => e.rowNumber).toSet().length,
    );
  }

  // ---- row parsing --------------------------------------------------------

  static const _lengthWords = {'length', 'cable', 'wire', 'metre', 'meter', 'm', 'mtr'};
  static const _pieceWords = {'piece', 'pieces', 'pcs', 'pc', 'nos', 'unit', 'each'};

  ItemImportRow? _parseRow(CsvRow r, List<ImportIssue> issues) {
    void bad(String column, String message) =>
        issues.add(ImportIssue(r.rowNumber, message, column: column));

    final name = r.get('name');
    if (name.isEmpty) bad('name', 'Name is required');

    int gst = 0;
    try {
      gst = parsePercentToBp(r.get('gst_percent'));
      if (!validGstRatesBp.contains(gst)) {
        bad('gst_percent', 'GST must be one of 0, 0.25, 3, 5, 12, 18 or 28');
      }
    } on FormatException catch (e) {
      bad('gst_percent', e.message);
    }

    final typeText = r.get('type').toLowerCase();
    bool? isLength;
    if (_lengthWords.contains(typeText)) {
      isLength = true;
    } else if (_pieceWords.contains(typeText)) {
      isLength = false;
    } else {
      bad('type', 'Type must be "length" (sold by the metre) or "piece"');
    }

    int? rollBase;
    int? boxSize;
    if (isLength == true && r.get('roll_length_m').isNotEmpty) {
      try {
        rollBase = Units.toBaseUnits(cleanQuantity(r.get('roll_length_m')), 1000);
        if (rollBase <= 0) {
          bad('roll_length_m', 'Roll length must be more than 0');
          rollBase = null;
        }
      } on FormatException catch (e) {
        bad('roll_length_m', e.message);
      }
    }
    if (isLength == false && r.get('box_size').isNotEmpty) {
      try {
        boxSize = Units.toBaseUnits(cleanQuantity(r.get('box_size')), 1);
        if (boxSize < 2) {
          bad('box_size', 'Box size must be 2 or more pieces');
          boxSize = null;
        }
      } on FormatException catch (e) {
        bad('box_size', e.message);
      }
    }

    int price(String column, {bool required = false}) {
      final text = r.get(column);
      if (text.isEmpty) {
        if (required) bad(column, 'Required');
        return -1;
      }
      try {
        final p = parseRupees(text);
        if (p == 0 && column != 'cost_price') {
          bad(column, 'Price must be more than 0');
          return -1;
        }
        return p;
      } on FormatException catch (e) {
        bad(column, e.message);
        return -1;
      }
    }

    final retail = price('retail_price', required: true);
    final contractor = price('contractor_price');
    final dealer = price('dealer_price');
    final cost = price('cost_price');

    int qty(String column) {
      final text = r.get(column);
      if (text.isEmpty || isLength == null) return 0;
      try {
        return Units.toBaseUnits(cleanQuantity(text), isLength ? 1000 : 1);
      } on FormatException catch (e) {
        bad(column, isLength
            ? 'Use metres with up to 3 decimals'
            : 'Use a whole number of pieces (${e.message})');
        return 0;
      }
    }

    final minStock = qty('min_stock');
    final opening = qty('opening_stock');

    if (issues.isNotEmpty || isLength == null) return null;
    final barcode = r.get('barcode');
    String? nullIfEmpty(String s) => s.isEmpty ? null : s;
    return ItemImportRow(
      rowNumber: r.rowNumber,
      name: name,
      brand: nullIfEmpty(r.get('brand')),
      category: nullIfEmpty(r.get('category')),
      hsn: nullIfEmpty(r.get('hsn')),
      gstRateBp: gst,
      isLength: isLength,
      rollLengthBase: rollBase,
      boxSize: boxSize,
      retailPaise: retail,
      contractorPaise: contractor < 0 ? null : contractor,
      dealerPaise: dealer < 0 ? null : dealer,
      costPaise: cost < 0 ? null : cost,
      minStockBase: minStock,
      openingStockBase: opening,
      barcode: barcode.isEmpty ? null : barcode,
    );
  }

  // ---- existing data ------------------------------------------------------

  static String _key(String name, String? brand) =>
      '${name.trim().toLowerCase()}|${(brand ?? '').trim().toLowerCase()}';

  Future<_Existing> _existing() async {
    final db = ctx.db;
    final items = await (db.select(db.items)..where((t) => t.deletedAt.isNull())).get();
    final variants = await (db.select(db.itemVariants)
          ..where((t) => t.deletedAt.isNull() & t.barcode.isNotNull()))
        .get();
    return _Existing(
      {for (final i in items) _key(i.name, i.brand)},
      {for (final v in variants) v.barcode!},
    );
  }
}

class _Existing {
  _Existing(this.keys, this.barcodes);
  final Set<String> keys;
  final Set<String> barcodes;
}
