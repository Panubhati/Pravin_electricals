import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/repositories/invoice_repository.dart';
import '../../core/db/repositories/item_repository.dart';
import '../../core/db/repositories/repo_context.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../shared/strings.dart';
import 'domain/bill_calculator.dart';

/// A cart line plus the units staff can pick for it.
class CartEntry {
  const CartEntry(this.line, this.units);
  final CartLine line;
  final List<ItemUnit> units;

  CartEntry withLine(CartLine l) => CartEntry(l, units);
}

class BillState {
  const BillState({this.cart = const [], this.customer});
  final List<CartEntry> cart;

  /// Null means a walk-in customer.
  final Party? customer;

  BillState copyWith({List<CartEntry>? cart, Party? customer, bool clearCustomer = false}) =>
      BillState(
        cart: cart ?? this.cart,
        customer: clearCustomer ? null : (customer ?? this.customer),
      );
}

/// Totals for the current cart, or an [error] message when an input is invalid.
class BillResult {
  const BillResult({this.totals, this.error});
  final BillTotals? totals;
  final String? error;
}

final billProvider =
    NotifierProvider<BillNotifier, BillState>(BillNotifier.new);

final billResultProvider = Provider<BillResult>((ref) {
  final session = ref.watch(sessionProvider).valueOrNull;
  return computeBill(ref.watch(billProvider), session?.shop.stateCode);
});

/// Totals for [bill]. A plain function (not a provider read) so the notifier
/// can use it too without a circular dependency.
BillResult computeBill(BillState bill, String? shopStateCode) {
  final interState =
      BillCalculator.isInterState(shopStateCode, bill.customer?.stateCode);
  try {
    return BillResult(
      totals: BillCalculator.calculate(
        [for (final e in bill.cart) e.line],
        interState: interState,
      ),
    );
  } on FormatException {
    return const BillResult(error: S.invalidQty);
  } on ArgumentError {
    return const BillResult(error: 'Discount is more than the line amount');
  }
}

class BillNotifier extends Notifier<BillState> {
  @override
  BillState build() => const BillState();

  ItemRepository get _items => ref.read(itemRepositoryProvider);

  /// Adds the item to the bill at the customer's tier price. Returns an error
  /// message, or null on success.
  Future<String?> addItem(ItemSearchResult r) async {
    final tier = state.customer?.tier ?? 'retail';
    final rate = await _items.priceFor(
      itemId: r.item.id,
      tier: tier,
      variantId: r.variant?.id,
    );
    if (rate == null) return S.noPrice;

    final units = await _items.unitsOf(r.item.id);
    // Sell in the pricing unit (metre for cable, piece otherwise) by default.
    final unit = units.firstWhere(
      (u) => u.factorToBase == r.item.priceUnitFactor,
      orElse: () => units.first,
    );

    final idx = state.cart.indexWhere((e) =>
        e.line.itemId == r.item.id &&
        e.line.variantId == r.variant?.id &&
        e.line.unitName == unit.unitName);
    if (idx >= 0) {
      final q = int.tryParse(state.cart[idx].line.qtyEntered);
      if (q != null) {
        setQty(idx, '${q + 1}');
        return null;
      }
    }

    final name = (r.variant == null || r.variant!.label == kDefaultVariantLabel)
        ? r.item.name
        : '${r.item.name} (${r.variant!.label})';
    state = state.copyWith(cart: [
      ...state.cart,
      CartEntry(
        CartLine(
          itemId: r.item.id,
          itemName: name,
          variantId: r.variant?.id,
          unitName: unit.unitName,
          factorToBase: unit.factorToBase,
          qtyEntered: '1',
          ratePaise: rate,
          priceUnitFactor: r.item.priceUnitFactor,
          gstRateBp: r.item.gstRateBp,
        ),
        units,
      ),
    ]);
    return null;
  }

  void _replace(int i, CartLine Function(CartLine) f) {
    final cart = [...state.cart];
    cart[i] = cart[i].withLine(f(cart[i].line));
    state = state.copyWith(cart: cart);
  }

  void setQty(int i, String text) =>
      _replace(i, (l) => l.copyWith(qtyEntered: text.trim()));

  void setUnit(int i, ItemUnit u) => _replace(
      i, (l) => l.copyWith(unitName: u.unitName, factorToBase: u.factorToBase));

  /// [rupees] is typed text like "10" or "12.50"; blank or invalid means 0.
  void setDiscount(int i, String rupees) {
    var paise = 0;
    try {
      paise = rupees.trim().isEmpty ? 0 : Money.parse(rupees);
    } on FormatException {
      paise = 0;
    }
    _replace(i, (l) => l.copyWith(discountPaise: paise));
  }

  void removeAt(int i) {
    final cart = [...state.cart]..removeAt(i);
    state = state.copyWith(cart: cart);
  }

  void clear() => state = const BillState();

  /// Sets the customer (null = walk-in) and re-prices the cart at their tier.
  Future<void> setCustomer(Party? customer) async {
    final tier = customer?.tier ?? 'retail';
    final cart = <CartEntry>[];
    for (final e in state.cart) {
      final rate = await _items.priceFor(
        itemId: e.line.itemId,
        tier: tier,
        variantId: e.line.variantId,
      );
      cart.add(rate == null ? e : e.withLine(e.line.copyWith(ratePaise: rate)));
    }
    state = BillState(cart: cart, customer: customer);
  }

  /// A warning when selling [creditPaise] on credit would pass the customer's
  /// credit limit, otherwise null. The limit warns; it does not block.
  Future<String?> creditWarning(int creditPaise) async {
    final p = state.customer;
    if (p == null || creditPaise <= 0 || p.creditLimitPaise <= 0) return null;
    final balance = await ref.read(ledgerRepositoryProvider).balance(p.id);
    return balance + creditPaise > p.creditLimitPaise ? S.overCreditLimit : null;
  }

  /// Posts the bill (invoice, lines, payments, stock, ledger) in one
  /// transaction, clears the cart and returns the invoice id.
  Future<String> save(List<PaymentInput> payments) async {
    final session = ref.read(sessionProvider).requireValue;
    final result = computeBill(state, session.shop.stateCode);
    final totals = result.totals;
    if (totals == null || totals.isEmpty) {
      throw DomainException(result.error ?? 'The bill is empty');
    }
    final invoices = ref.read(invoiceRepositoryProvider);
    final shop = session.shop;
    final snapshot = jsonEncode({
      'name': shop.name,
      'gstin': shop.gstin,
      'address': shop.address,
      'stateCode': shop.stateCode,
      'phone': shop.phone,
      'terms': shop.terms,
    });

    String? id;
    for (var attempt = 0; attempt < 2 && id == null; attempt++) {
      final number = await invoices.nextNumber(session.deviceId, session.series);
      try {
        id = await invoices.postInvoice(totals.toInvoiceInput(
          deviceId: session.deviceId,
          series: session.series,
          number: number,
          date: session.ctx.clock(),
          locationId: session.locationId,
          payments: payments,
          partyId: state.customer?.id,
          createdBy: session.userId,
          shopSnapshotJson: snapshot,
        ));
      } on DuplicateInvoiceNumberException {
        if (attempt == 1) rethrow;
      }
    }
    clear();
    return id!;
  }
}
