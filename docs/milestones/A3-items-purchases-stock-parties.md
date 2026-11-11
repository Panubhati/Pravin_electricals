# A3: Items, purchases, stock, parties

**Status:** done (2026-11-12). Tests: 170 passing, `flutter analyze` clean.
Accepted on the owner's phone (Samsung SM A356E) with the sample CSVs in `sample_data/`.

## Purpose
Move the shop from debug sample data to its real catalogue, stock, suppliers and customer credit.

## What staff can do
Home is now a tile menu: **New bill, Items, Stock, Purchases, Customers, Suppliers, Dues, Import**.
- **Items:** search, add, edit, deactivate. Length items (cable, by metre, with roll length) or piece items (optional box size). GST %, HSN, retail/contractor/dealer prices (GST-inclusive), cost (ex-GST), minimum stock, variants with barcodes.
- **Stock:** balances shown in the selling unit (for example 447.5 m), Low and Negative filters, movement history per item, **Adjust** (signed, with a reason) and **Count** (enter what you counted; the difference is recorded).
- **Bill:** search results show stock; a warning appears when the quantity is above stock, but the bill can still be saved.
- **Customers / Suppliers:** lists with balances, add/edit, statement with running balance, record payments (cash, UPI, bank).
- **Dues:** receivables (customers owe the shop) and payables (shop owes suppliers) with ageing 0-30, 31-60, 61-90, 90+ days and advances.
- **Purchases:** pick or quick-add a supplier, supplier bill number and date, add items in roll/box/metre/piece, rate ex-GST prefilled from the last cost, live totals. Saving raises stock, updates cost and adds to the supplier's payable. A supplier bill number cannot be entered twice.
- **Import:** items (with opening stock) and parties (with opening balances) from CSV, with template download, a preview that lists every problem row, and all-or-nothing saving. Re-importing a file is safe (existing records are skipped).

## Rules enforced
- Unit type and pricing-unit factor are locked once an item has stock movements, invoice or purchase lines.
- Price, item and party edits write `audit_log` rows with before/after.
- Barcode is unique per variant. The default variant "Standard" is hidden on bills.
- Stock movements and ledger entries are append-only; every write also goes to the outbox for Stage B.
- Ageing is FIFO: payments settle the oldest debits first.

## Code map
- Data: `core/db/repositories/` (item, stock, ledger, dues, party, purchase), `core/dues/ageing.dart`, `core/import/*`, schema v2 in `app_database.dart`.
- Screens: `features/{items,stock,parties,purchase,import,home}/`. Shared helpers: `shared/{format,widgets,strings}.dart`.
- `core/permissions.dart`: stub (everything allowed) so A4 roles only swap the source.

## Tests
Unit and repository tests for money, units, ageing boundaries, CSV parsing, migration v1 to v2, item/stock/party/purchase rules; widget tests for each screen; `whole_flow_test.dart` runs import, cash and credit sales, purchase and payments, then checks stock, dues, ageing and invariants against hand calculations.

## Known limits
- CSV only (no Excel); one stock location, no transfers.
- Roles/permissions arrive in A4; discounts, rate edits and cost visibility are unrestricted for now.
- Installing a new debug build with `flutter install` uninstalls the old one and wipes local data (backup/restore comes in A6).
