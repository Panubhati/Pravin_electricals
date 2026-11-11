import '../../../core/db/repositories/purchase_repository.dart';
import '../../../core/money.dart';
import '../../../core/units.dart';

/// One line of a supplier purchase as typed. Supplier bills list rates
/// **without GST**, so tax is added on top (unlike shop sales, which include it).
class PurchaseCartLine {
  const PurchaseCartLine({
    required this.itemId,
    required this.itemName,
    required this.unitName,
    required this.factorToBase,
    required this.qtyEntered,
    required this.ratePaise,
    required this.priceUnitFactor,
    required this.gstRateBp,
    this.variantId,
  });

  final String itemId;
  final String itemName;
  final String? variantId;
  final String unitName;

  /// Base units in one [unitName] (90000 for a 90 m roll, 10 for a box).
  final int factorToBase;
  final String qtyEntered;

  /// Paise per pricing unit (per metre, per piece), excluding GST.
  final int ratePaise;
  final int priceUnitFactor;
  final int gstRateBp;
}

class PurchaseLineCalc {
  const PurchaseLineCalc(this.cart, this.qtyBase, this.amountPaise, this.taxPaise);
  final PurchaseCartLine cart;
  final int qtyBase;

  /// qty x rate, before GST.
  final int amountPaise;
  final int taxPaise;
  int get totalPaise => amountPaise + taxPaise;
}

class PurchaseTotals {
  const PurchaseTotals(this.lines, this.subtotalPaise, this.taxPaise);
  final List<PurchaseLineCalc> lines;

  /// Sum of line amounts, before GST.
  final int subtotalPaise;

  /// Sum of per-line GST.
  final int taxPaise;
  int get totalPaise => subtotalPaise + taxPaise;
  bool get isEmpty => lines.isEmpty;
}

/// Pure purchase maths, identical to what [PurchaseRepository.postPurchase]
/// stores: per-line amount (half up), per-line GST on top (half up).
abstract final class PurchaseCalculator {
  /// Throws [FormatException] for an invalid quantity.
  static PurchaseTotals calculate(List<PurchaseCartLine> cart) {
    final lines = <PurchaseLineCalc>[];
    var subtotal = 0;
    var tax = 0;
    for (final c in cart) {
      final qtyBase = Units.toBaseUnits(c.qtyEntered, c.factorToBase);
      final amount = Units.lineAmountPaise(
        qtyBase: qtyBase,
        ratePaise: c.ratePaise,
        priceUnitFactor: c.priceUnitFactor,
      );
      final lineTax = Money.taxPaise(amount, c.gstRateBp);
      lines.add(PurchaseLineCalc(c, qtyBase, amount, lineTax));
      subtotal += amount;
      tax += lineTax;
    }
    return PurchaseTotals(lines, subtotal, tax);
  }

  static PostPurchaseInput toInput(
    PurchaseTotals totals, {
    required String supplierId,
    required String supplierInvoiceNo,
    required DateTime date,
    required String locationId,
    String? createdBy,
  }) {
    return PostPurchaseInput(
      supplierId: supplierId,
      supplierInvoiceNo: supplierInvoiceNo,
      supplierInvoiceDate: date,
      locationId: locationId,
      createdBy: createdBy,
      lines: [
        for (final l in totals.lines)
          PurchaseLineInput(
            itemId: l.cart.itemId,
            variantId: l.cart.variantId,
            unitName: l.cart.unitName,
            qtyEntered: l.cart.qtyEntered,
            qtyBase: l.qtyBase,
            ratePaise: l.cart.ratePaise,
            priceUnitFactor: l.cart.priceUnitFactor,
            gstRateBp: l.cart.gstRateBp,
          ),
      ],
    );
  }
}
