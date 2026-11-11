# A2: Quick bill (offline)

**Status:** done (2026-11-11). **Commit:** `dfe3dab feat: A2 quick bill (offline)`.
Accepted on the owner's phone: the dual-unit bill total matched the hand calculation and billing works.

## Purpose
Let counter staff create a bill on the phone with no internet, save it, and share a PDF.

## How a bill works (staff view)
Home, then **New bill**:
1. Search by name, brand, SKU or barcode, or tap the scanner icon.
2. Tap the item. It is added in its pricing unit (metre for cable, piece otherwise) at the
   customer's tier price. Adding the same item again increases the quantity.
3. Type the quantity (for example 2.5), pick another unit if needed (roll, box), optionally a discount.
4. Choose a customer (top right) or leave **Walk-in**. Contractor and dealer customers get their tier prices.
5. **Pay**: cash, UPI, credit (udhaar) or a mix. The amounts must add up to the total.
6. **Save bill**, then **Share PDF** or **New bill**.

## Modules

### Bill calculator (`features/billing/domain/bill_calculator.dart`)
Pure Dart, no database. Selling prices **include GST**.
- Line: `amount = qtyBase x rate / priceUnitFactor` (half up); `gross = amount - discount`;
  GST inside = `gross x rate / (100% + rate)` (half up, per line).
- Bill: `subtotal` = sum of amounts; `total` = `subtotal - discount + round-off`, where the total is
  rounded to the nearest rupee.
- Tax breakdown per GST rate: CGST + SGST (odd paisa to SGST) when same state, IGST when the shop and
  customer state codes are both set and differ.
- Worked example: 2.5 m of wire at Rs 47.50/m = 118.75; 2 boxes (20 pcs) of switches at Rs 15 = 300.00;
  subtotal 418.75, rounds to **Rs 419.00** (round-off +0.25).

### Bill state (`features/billing/bill_controller.dart`)
Riverpod notifier holding the cart and customer. Re-prices the cart when the customer changes,
warns (does not block) when credit would pass the customer's limit, and `save()` posts the invoice
with the next number in this device's series (retries once on a number clash).

### First run and providers (`core/bootstrap.dart`, `core/providers.dart`)
First launch creates the shop "Pravin Electricals", an owner user, device series **A** and a
"shop" stock location. Invoice numbers look like `A-0001`.

### Screens (`features/billing/`, `features/home/`)
Home, bill screen (search, cart, totals bar), customer sheet (search, walk-in, quick-add),
payment sheet (cash/UPI/credit with remaining amount), barcode scanner, bill-saved screen.
All UI text is in `shared/strings.dart` for a later Marathi/Hindi translation.

### PDF (`core/printing/invoice_pdf.dart`)
Built on the phone from saved data each time and passed straight to the Android share sheet.
The app keeps no PDF. Contains shop details, customer, lines, totals, GST breakdown and payments.
Uses bundled Noto Sans (`assets/fonts/`, SIL Open Font License) so the rupee sign works offline.

### Audit log
Any bill with a discount writes an `audit_log` row (action `discount`), as the plan requires.

### Debug sample data (`core/debug/sample_data.dart`)
Debug builds only: **Load sample data** on Home adds wires, switches, LED bulbs, an MCB, two customers,
a supplier and opening stock (through a normal purchase). Item screens arrive in A3.

## What a save does (one database transaction)
Invoice, lines and payments are written; a `sale` stock movement (negative) per line; a receivable
ledger entry for any credit part; an audit row for discounts; and an outbox row for every record.
If any step fails, nothing is saved.

## Tests
`test/features/`: calculator (hand-calculated cases), bill flow through the real logic, PDF validity.
`test/widget_test.dart`: drives the screen: search, add wire in metres, add switches in boxes, pay, save.
Total suite at this milestone: 64 tests, `flutter analyze` clean.

## Decisions
See `docs/decisions.md`: GST-inclusive prices, round to nearest rupee, no rate override until roles (A4),
credit limit warns only, same-state default until shop state code exists.

## Known limits
- No item or customer management screens yet (A3), no returns screen yet.
- Shop name, GSTIN, address and state code are not editable yet (Settings, A4); the PDF shows no GSTIN.
- No thermal printing (the shop has no printer); UPI QR on the invoice comes in A5.
