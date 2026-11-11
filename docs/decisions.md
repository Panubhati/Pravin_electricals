# Design decisions

## 2026-11-11 Cable length representation
Cable (and any length item) uses the metre as its display unit, stored as an **integer number of millimetres** in base units (0.5 m = 500, 2.5 m = 2500). Reason: shop sells fractions such as 0.5 m and 2.5 m; integers avoid floating-point errors in stock maths.

## 2026-11-11 GST rounding
GST is rounded **per line** (to the nearest paisa), and the invoice tax is the sum of rounded line taxes. Reason: standard billing practice, matches per-line HSN reporting.

## 2026-11-11 Printer
The shop has no thermal printer yet. A5 is limited to PDF generation and sharing; Bluetooth thermal printing is deferred until a printer is bought.

## 2026-11-11 Riverpod pinned to 2.x
Installed Flutter is 3.29 (Dart 3.7). flutter_riverpod 3.x and drift_dev could not be resolved together on that SDK, so flutter_riverpod is pinned to ^2.6.1. Revisit if Flutter is upgraded.

## 2026-11-11 Gradle heap reduced
Default -Xmx8G caused a JVM crash (access violation in jvm.dll) on a 15 GB dev PC during first Android build. Set to -Xmx3G / Metaspace 1G in app/android/gradle.properties.

## 2026-11-11 Kotlin Gradle plugin bumped to 2.1.0
mobile_scanner 7.5.0 failed to build on the template's Kotlin 1.8.22 (unresolved compilerOptions). Bumped in app/android/settings.gradle.kts.

## 2026-11-11 Android Gradle plugin 8.9.1, Gradle 8.11.1, compileSdk 36
Latest androidx libs pulled in by plugins (core 1.18.0) require AGP >= 8.9.1 and compileSdk 36. Updated settings.gradle.kts, gradle-wrapper.properties and app/build.gradle.kts.

## 2026-11-11 NDK 27 and core library desugaring
Plugins require NDK 27.0.12077973 and flutter_local_notifications requires core library desugaring (desugar_jdk_libs 2.1.4). Set in app/build.gradle.kts.

## 2026-11-11 minSdk 23
mobile_scanner requires minSdk 23 (Android 6.0). App will not install on older phones.

## 2026-11-11 Prices are paise per pricing unit (changes AGENTS.md section 7)
Cable is stored in millimetres, so a price of Rs 47.50 per metre would be 4.75 paise per mm, which is not an integer. Prices and costs (item_prices, item_costs, invoice_lines, purchase_lines) are therefore stored as integer paise per *pricing unit* (per metre for cable, per piece otherwise). Each item stores `price_unit_factor` (base units per pricing unit: 1000 for cable, 1 for pieces). Line amount = round_half_up(qty_base x rate_paise / price_unit_factor), rounded per line. Columns are named `rate_paise` / `cost_paise` rather than `rate_paise_per_base_unit`.

## 2026-11-11 Invoice total arithmetic (A1)
Per line: amount = qty_base x rate / price_unit_factor (half up); line_total = amount - line discount + line tax. Per invoice: subtotal = sum of line amounts; discount = sum of line discounts; tax = sum of line taxes; total = subtotal - discount + tax + round_off. Payments must add up to the total; the 'credit' part becomes the receivable. Invoice-level discounts, if needed, are allocated to lines in A2. A1 assumed tax-exclusive prices; this is SUPERSEDED by the next entry.

## 2026-11-11 Selling prices include GST (answered by the owner)
Shop selling prices are GST-inclusive. Per line: gross = amount - line discount (this is what the customer pays); tax inside = round_half_up(gross x rate_bp / (10000 + rate_bp)); taxable value = gross - tax. Invoice: subtotal = sum of line amounts, discount = sum of line discounts, tax_paise = GST contained in the total (informational), total = subtotal - discount + round_off. `line_total_paise` = amount - discount (no tax added). Supplier purchase bills list rates excluding GST, so purchases stay tax-exclusive (line total + tax); compare cost and selling price on the same basis when margin is shown. A2 includes the code change to A1's invoice validation and tests.

## 2026-11-11 Ledger sign convention
Positive = the party owes the shop; negative = the shop owes the party, for customers and suppliers alike. Credit sale +, customer payment -, purchase on credit -, payment to supplier +.

## 2026-11-11 A1 scope notes
audit_log, sales return posting (tables exist, no repository yet), stock adjustment/transfer/count and CSV import are not in A1; they come in the milestones that need them (A2/A3/A4). Immutability is by API design (repositories expose no update/delete for invoices, purchases, stock movements or ledger entries), not by database triggers.

## 2026-11-11 A2 quick bill decisions
- Total is rounded to the nearest rupee (half up); the difference is stored as `round_off_paise`.
- Rate override is not available on the bill until roles exist (A4). Per-line discounts are allowed and every discounted bill writes an `audit_log` row (action `discount`).
- Credit limit only warns (continue anyway); it does not block. Revisit when roles arrive in A4.
- Default sale unit is the item's pricing unit (metre for cable, piece otherwise).
- CGST/SGST split is per tax rate on the invoice total (odd paisa goes to SGST); IGST when shop and customer state codes are both set and differ. Shop state code is empty until Settings (A4) exists, so bills are treated as same-state for now.
- Invoice PDF is built on the phone from saved data and handed to the Android share sheet; the app keeps no PDF. Noto Sans Regular/Bold (OFL, about 620 KB each) is bundled for the rupee sign.
- First run creates shop "Pravin Electricals", an owner user, device series "A" and a 'shop' stock location; these are edited in Settings later.
- A2 acceptance on the owner's phone (Samsung SM A356E): dual-unit bill totals matched the hand calculation (Rs 419.00) and billing worked.
