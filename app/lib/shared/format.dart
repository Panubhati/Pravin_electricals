import '../core/db/app_database.dart';
import '../core/db/repositories/repo_context.dart';
import '../core/money.dart';
import '../core/units.dart';

/// Name of the unit prices and stock are shown in: metre for cable (stored in
/// millimetres), otherwise the base unit (pcs).
String pricingUnitName(Item item) {
  if (item.priceUnitFactor == 1) return item.baseUnit;
  if (item.baseUnit == 'mm' && item.priceUnitFactor == 1000) return 'm';
  return '${item.priceUnitFactor} ${item.baseUnit}';
}

/// "447.5 m" or "20 pcs" from a stored base-unit quantity.
String formatStock(Item item, int qtyBase) =>
    '${Units.formatQty(qtyBase, item.priceUnitFactor)} ${pricingUnitName(item)}';

/// "₹47.50 / m".
String formatRate(Item item, int ratePaise) =>
    '${Money.format(ratePaise)} / ${pricingUnitName(item)}';

/// Rupees as typed in a field ("12.5"), without symbol or grouping commas.
String rupeesForField(int paise) =>
    paise == 0 ? '' : Money.format(paise, symbol: false).replaceAll(',', '');

/// A plain message for an error from a repository, shown to staff.
String errorMessage(Object e) {
  if (e is DomainException) return e.message;
  if (e is FormatException) return e.message;
  // Storage problems from SQLite, in words staff can act on. A save is all or
  // nothing, so in every case nothing half-saved is left behind.
  final text = '$e'.toLowerCase();
  if (text.contains('disk is full') || text.contains('sqlite_full') || text.contains('no space left')) {
    return 'The phone is out of storage space. Free some space and try again. Nothing was saved.';
  }
  if (text.contains('disk i/o error') || text.contains('sqlite_ioerr')) {
    return 'The phone could not write to its storage. Nothing was saved. Try again, and restart the phone if it keeps happening.';
  }
  if (text.contains('database is locked') || text.contains('sqlite_busy')) {
    return 'The shop data is busy. Wait a moment and try again.';
  }
  return 'Something went wrong: $e';
}

/// "12 Nov 2026".
String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
