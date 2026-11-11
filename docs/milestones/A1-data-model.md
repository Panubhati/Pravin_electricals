# A1: Data model and local database

**Status:** done (2026-11-11). **Commit:** `37215c7 feat: A1 data model and local database`
(later extended in A2 with the audit log and GST-inclusive checks).

## Purpose
The whole on-phone database and the rules that protect the shop's numbers, with no screens.
Billing, stock and credit in later milestones all sit on this layer.

## Modules

### Money (`app/lib/core/money.dart`)
All money is integer **paise** (never double).
- `Money.parse("12.50")` gives 1250; `Money.format(12345650)` gives `₹1,23,456.50` (Indian grouping).
- `divRoundHalfUp` and `mulDivRoundHalfUp`: integer rounding, half away from zero.
- `taxPaise` adds GST on top (used for supplier purchases); `taxIncluded` extracts GST from a
  GST-inclusive amount (used for sales); `roundToRupee` rounds a total to the nearest rupee.

### Units (`app/lib/core/units.dart`)
Stock is stored in **base units**: millimetres for cable (so 0.5 m is 500), pieces for countable items.
- `toBaseUnits("2.5", 1000)` gives 2500 with no floating point; fractional base units are rejected.
- `lineAmountPaise` = `qtyBase x ratePaise / priceUnitFactor`, rounded half up per line.
- Prices are paise per **pricing unit** (per metre, per piece). `priceUnitFactor` is base units
  per pricing unit (1000 for cable, 1 for pieces). Example: 2.5 m at Rs 47.50/m = 2500 x 4750 / 1000 = 11875 paise.

### Tables (`app/lib/core/db/tables/`)
Names follow plan section 7. Every table has a UUID `id`, `shop_id`, `created_at`, `updated_at`
and `deleted_at` (soft delete).

| Group | Tables |
|---|---|
| Core | shops, users, devices, locations, outbox |
| Items | items, item_units, item_variants, item_prices, item_costs |
| Parties | parties, ledger_entries |
| Sales | invoices, invoice_lines, invoice_payments, sales_returns, sales_return_lines |
| Purchases | purchases, purchase_lines |
| Stock | stock_movements |
| Audit (added in A2) | audit_log |

Unique rules: invoice number per device and series; supplier invoice number per supplier.
Schema version is 1 (`app_database.dart`); the database opens with foreign keys on.

### Repositories (`app/lib/core/db/repositories/`)
All writes go through these, never scattered DAO calls. Each write also inserts an **outbox** row
in the same transaction (unused in Stage A; Stage B sync will read it).

| Repository | Does |
|---|---|
| `SetupRepository` | shop, users, devices, locations |
| `ItemRepository` | items, units, variants, barcode, prices (tier with retail fallback), costs, search |
| `PartyRepository` | customers and suppliers, search |
| `LedgerRepository` | append-only party ledger; balance = sum of entries |
| `StockRepository` | append-only stock movements; balance = sum of movements |
| `InvoiceRepository` | validates and posts a sale in one transaction |
| `PurchaseRepository` | posts a supplier purchase in one transaction |
| `AuditRepository` | append-only audit trail |

## Rules enforced
- Stock balance is always the sum of movements; there is no stored "current stock".
- Ledger sign convention (customers and suppliers alike): positive means the party owes the shop.
  Credit sale +, customer payment -, purchase on credit -, payment to a supplier +.
- Posted invoices, purchases, stock movements and ledger entries have **no update or delete** methods.
  Corrections will be reversing entries.
- Invoice posting validates quantities against the item's units, line totals, GST, payments adding
  up to the total, and "credit needs a customer". A failed save rolls everything back.
- A duplicate supplier invoice or invoice number is rejected with a clear error.

## Tests
`app/test/core/` (money, units) and `app/test/db/repositories_test.dart` (in-memory SQLite):
outbox rows per write, rollback on failure, duplicates rejected, stock and ledger balances match
the sum of their rows, price tier fallback, discount audit.

## Known limits
- Sales return posting, stock adjustment/transfer/count, CSV import: not yet (A2 to A4).
- Immutability is by API design, not database triggers.
