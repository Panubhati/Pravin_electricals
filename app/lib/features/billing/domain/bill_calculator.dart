import '../../../core/db/repositories/invoice_repository.dart';
import '../../../core/money.dart';
import '../../../core/units.dart';

/// One line in the cart, as staff see it.
class CartLine {
  const CartLine({
    required this.itemId,
    required this.itemName,
    required this.unitName,
    required this.factorToBase,
    required this.qtyEntered,
    required this.ratePaise,
    required this.priceUnitFactor,
    this.variantId,
    this.gstRateBp = 0,
    this.discountPaise = 0,
  });

  final String itemId;
  final String itemName;
  final String? variantId;
  final String unitName;

  /// Base units in one [unitName] (1000 for metre, 90000 for a 90 m roll).
  final int factorToBase;

  /// Quantity as typed, e.g. "2.5".
  final String qtyEntered;

  /// Paise per pricing unit (per metre for cable, per piece otherwise).
  /// Selling prices include GST.
  final int ratePaise;
  final int priceUnitFactor;
  final int gstRateBp;
  final int discountPaise;

  CartLine copyWith({
    String? unitName,
    int? factorToBase,
    String? qtyEntered,
    int? discountPaise,
    int? ratePaise,
  }) =>
      CartLine(
        itemId: itemId,
        itemName: itemName,
        variantId: variantId,
        unitName: unitName ?? this.unitName,
        factorToBase: factorToBase ?? this.factorToBase,
        qtyEntered: qtyEntered ?? this.qtyEntered,
        ratePaise: ratePaise ?? this.ratePaise,
        priceUnitFactor: priceUnitFactor,
        gstRateBp: gstRateBp,
        discountPaise: discountPaise ?? this.discountPaise,
      );
}

/// A cart line after the maths. All money is integer paise.
class CalculatedLine {
  const CalculatedLine({
    required this.cart,
    required this.qtyBase,
    required this.amountPaise,
    required this.grossPaise,
    required this.taxPaise,
  });

  final CartLine cart;
  final int qtyBase;

  /// qtyBase x rate / priceUnitFactor, before discount (GST included).
  final int amountPaise;

  /// What the customer pays for the line: amount - discount (GST included).
  final int grossPaise;

  /// GST contained in [grossPaise].
  final int taxPaise;

  /// Value before GST.
  int get taxableValuePaise => grossPaise - taxPaise;
}

/// GST summary for one tax rate, split CGST+SGST (same state) or IGST.
class TaxBreakdownRow {
  const TaxBreakdownRow({
    required this.rateBp,
    required this.taxableValuePaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
  });

  final int rateBp;
  final int taxableValuePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  int get totalTaxPaise => cgstPaise + sgstPaise + igstPaise;
}

class BillTotals {
  const BillTotals({
    required this.lines,
    required this.subtotalPaise,
    required this.discountPaise,
    required this.taxPaise,
    required this.roundOffPaise,
    required this.totalPaise,
    required this.taxBreakdown,
    required this.interState,
  });

  final List<CalculatedLine> lines;

  /// Sum of line amounts, before discount (GST included).
  final int subtotalPaise;
  final int discountPaise;

  /// GST contained in the total.
  final int taxPaise;

  /// Added to reach a whole rupee (can be negative).
  final int roundOffPaise;

  /// What the customer pays: subtotal - discount + round-off.
  final int totalPaise;
  final List<TaxBreakdownRow> taxBreakdown;
  final bool interState;

  bool get isEmpty => lines.isEmpty;

  /// Builds the input for [InvoiceRepository.postInvoice].
  PostInvoiceInput toInvoiceInput({
    required String deviceId,
    required String series,
    required int number,
    required DateTime date,
    required String locationId,
    required List<PaymentInput> payments,
    String? partyId,
    String? createdBy,
    String? shopSnapshotJson,
  }) {
    return PostInvoiceInput(
      deviceId: deviceId,
      series: series,
      number: number,
      date: date,
      locationId: locationId,
      partyId: partyId,
      subtotalPaise: subtotalPaise,
      discountPaise: discountPaise,
      taxPaise: taxPaise,
      roundOffPaise: roundOffPaise,
      totalPaise: totalPaise,
      payments: payments,
      createdBy: createdBy,
      shopSnapshotJson: shopSnapshotJson,
      lines: [
        for (final l in lines)
          InvoiceLineInput(
            itemId: l.cart.itemId,
            variantId: l.cart.variantId,
            unitName: l.cart.unitName,
            qtyEntered: l.cart.qtyEntered,
            qtyBase: l.qtyBase,
            ratePaise: l.cart.ratePaise,
            priceUnitFactor: l.cart.priceUnitFactor,
            discountPaise: l.cart.discountPaise,
            gstRateBp: l.cart.gstRateBp,
            taxPaise: l.taxPaise,
            lineTotalPaise: l.grossPaise,
          ),
      ],
    );
  }
}

/// Pure bill maths. Prices include GST (docs/decisions.md). Rounding is per
/// line (half up) and the final total is rounded to the nearest rupee.
abstract final class BillCalculator {
  /// Throws [FormatException] for an invalid quantity and [ArgumentError] for a
  /// discount larger than the line amount.
  static BillTotals calculate(List<CartLine> cart, {required bool interState}) {
    final lines = <CalculatedLine>[];
    var subtotal = 0;
    var discount = 0;
    var tax = 0;

    for (final c in cart) {
      final qtyBase = Units.toBaseUnits(c.qtyEntered, c.factorToBase);
      final amount = Units.lineAmountPaise(
        qtyBase: qtyBase,
        ratePaise: c.ratePaise,
        priceUnitFactor: c.priceUnitFactor,
      );
      if (c.discountPaise < 0 || c.discountPaise > amount) {
        throw ArgumentError.value(
            c.discountPaise, 'discountPaise', 'must be between 0 and $amount');
      }
      final gross = amount - c.discountPaise;
      final lineTax = Money.taxIncluded(gross, c.gstRateBp);
      lines.add(CalculatedLine(
        cart: c,
        qtyBase: qtyBase,
        amountPaise: amount,
        grossPaise: gross,
        taxPaise: lineTax,
      ));
      subtotal += amount;
      discount += c.discountPaise;
      tax += lineTax;
    }

    final beforeRound = subtotal - discount;
    final total = Money.roundToRupee(beforeRound);
    return BillTotals(
      lines: lines,
      subtotalPaise: subtotal,
      discountPaise: discount,
      taxPaise: tax,
      roundOffPaise: total - beforeRound,
      totalPaise: total,
      taxBreakdown: taxBreakdown(
        [
          for (final l in lines)
            (
              rateBp: l.cart.gstRateBp,
              grossPaise: l.grossPaise,
              taxPaise: l.taxPaise,
            ),
        ],
        interState: interState,
      ),
      interState: interState,
    );
  }

  /// Groups line taxes by rate. Same-state sales split each rate's tax into
  /// CGST and SGST (an odd paisa goes to SGST); other-state sales use IGST.
  static List<TaxBreakdownRow> taxBreakdown(
    List<({int rateBp, int grossPaise, int taxPaise})> lines, {
    required bool interState,
  }) {
    final gross = <int, int>{};
    final taxes = <int, int>{};
    for (final l in lines) {
      gross[l.rateBp] = (gross[l.rateBp] ?? 0) + l.grossPaise;
      taxes[l.rateBp] = (taxes[l.rateBp] ?? 0) + l.taxPaise;
    }
    final rates = gross.keys.toList()..sort();
    return [
      for (final r in rates)
        TaxBreakdownRow(
          rateBp: r,
          taxableValuePaise: gross[r]! - taxes[r]!,
          cgstPaise: interState ? 0 : taxes[r]! ~/ 2,
          sgstPaise: interState ? 0 : taxes[r]! - taxes[r]! ~/ 2,
          igstPaise: interState ? taxes[r]! : 0,
        ),
    ];
  }

  /// Same-state unless both state codes are known and differ.
  static bool isInterState(String? shopStateCode, String? partyStateCode) {
    if (shopStateCode == null || partyStateCode == null) return false;
    if (shopStateCode.isEmpty || partyStateCode.isEmpty) return false;
    return shopStateCode != partyStateCode;
  }
}
