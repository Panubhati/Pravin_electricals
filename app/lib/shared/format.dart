import 'strings.dart';
import 'messages_mr.dart';
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

/// A plain message for an error from a repository, shown to staff, in the
/// screen language.
String errorMessage(Object e) => localizeMessage(_errorMessageEn(e));

String _errorMessageEn(Object e) {
  if (e is DomainException) return e.message;
  if (e is FormatException) return e.message;
  // Storage problems from SQLite, in words staff can act on. A save is all or
  // nothing, so in every case nothing half-saved is left behind.
  final text = '$e'.toLowerCase();
  if (text.contains('disk is full') || text.contains('sqlite_full') || text.contains('no space left')) {
    return S.diskFull;
  }
  if (text.contains('disk i/o error') || text.contains('sqlite_ioerr')) {
    return S.diskIoError;
  }
  if (text.contains('database is locked') || text.contains('sqlite_busy')) {
    return S.dataBusy;
  }
  return S.somethingWentWrong('$e');
}

/// "12 Nov 2026".
String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  // Month names stay English in both languages (owner's choice, A10).
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// "12 Nov 2026, 3:05 pm" (today: "today 3:05 pm").
String formatDateTime(DateTime d, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final time = '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
  final sameDay = d.year == n.year && d.month == n.month && d.day == n.day;
  return sameDay ? 'today $time' : '${formatDate(d)}, $time';
}
