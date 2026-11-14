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

## 2026-11-12 A3 decisions
- Schema v2 (first migration): `stock_movements.note`, `ledger_entries.payment_mode`, indexes on item name, barcode, stock item, ledger party, invoice date.
- Ageing is FIFO: payments/credits settle the oldest debits first; the rest is bucketed by entry date (0-30, 31-60, 61-90, 90+); net credit is shown as advance. Suppliers use flipped signs (ledger sign convention unchanged).
- Item unit type and price-unit factor are locked once any stock movement, invoice line or purchase line exists; the UI never changes item type after creation.
- Count records the difference as a `count` movement; adjust is a signed `adjustment` with a reason; imported opening stock is an adjustment ("Opening stock").
- Posting a purchase writes an `item_costs` row (ex-GST); latest cost wins, ties broken by effective date then rowid. Purchases are GST-exclusive, sales GST-inclusive.
- `Permissions` provider stub (canSeeCost, canEditPrices) until roles in A4.
- Screens read autoDispose providers and call `ref.invalidate` after writes (no streams).
- CSV import: all-or-nothing transaction, per-row error preview, duplicates skipped (items by name+brand or barcode; parties by name+phone); handles BOM, CRLF, semicolon/tab; Excel files get a plain message. New packages: `file_picker`, `csv`.
- Selling above stock only warns (owner's choice); stock location is the shop floor only.

## 2026-11-12 A4 decisions
- Schema v3: `app_settings(shop_id, key, value)` for opening cash, counter discount limit (5% default), auto-lock minutes, daily summary on/off and hour.
- PINs: 4 to 6 digits, salted SHA-256 in `users.pin_hash` (the salted hash is synced like any other column, never the PIN). 5 wrong tries lock 30 s, doubling to 15 min (counters are in memory). Owner recovery via the phone's screen lock (`local_auth`, needs FlutterFragmentActivity, AppCompat themes, USE_BIOMETRIC).
- `LockGate` wraps the app in `MaterialApp.builder` with its own Navigator for the lock screen; locking pops to the first route. A different user logging in starts with an empty bill; the same user keeps the cart.
- Roles (UI-level in Stage A): counter cannot see cost, profit, reports, settings, audit, purchases, suppliers, payables or import, cannot add or edit items or prices, and may discount up to the limit per line; "nobody logged in" is the most restrictive. Counter stock adjust and count is allowed (the owner did not restrict it).
- Profit uses the cost effective on the bill's date; unknown cost is listed apart, never guessed. Returns are not in reports yet. Stock value and cash in hand rules as in the A4 doc.
- Daily summary: WorkManager periodic task (24 h, first run delayed to the chosen hour), opens the DB in its own isolate. Inexact timing accepted. Only the daily summary is a notification; low stock and dues are on the dashboard (owner's choice).
- Audit log shows only changed fields in plain words; quantities use the item's selling unit.
- Updating on the phone: `adb install -r` keeps data; `flutter install` wipes it.

## 2026-11-12 A5 decisions
- Thermal printing deferred (the shop has no printer); will be A5b. The PDF can already be printed through the phone's share sheet.
- UPI ID and payee name are in `app_settings` (`upi_id`, `upi_name`), validated as `name@bank`, owner-only, every change audited (`upi_changed`). No UPI ID means no QR anywhere.
- QR rules: Pay screen shows a QR for the typed UPI amount; every PDF shows one QR for the balance due when there is credit, otherwise for the full total. Link uses only pa, pn, am, cu, tn.
- Schema v4: `invoice_lines.hsn` snapshots the item's HSN at sale so reprints match the original; older lines fall back to the item's current HSN.
- Printed content is built as plain text first (`InvoiceView`) and the PDF only draws it, so the content is testable.
- WhatsApp to a customer's number uses a small Android channel (jid extra on a WhatsApp or WhatsApp Business share intent, FileProvider); it falls back to the share sheet when there is no phone number or no WhatsApp. The PDF is a temporary cache file, deleted after a day.
- Bills history is open to counter staff too; it shows no cost. Posted bills are still never edited; cancel and return screens are not in A5.

## 2026-11-12 A6 decisions
- Backup is a plain copy of the database file (owner chose no password) made with SQLite `VACUUM INTO` and verified (integrity, row counts per table, sums of stock, ledger, bills and purchases) before it is offered. A failed copy is deleted, never shared.
- Restore is file-level: validate, keep `before_restore_*.sqlite` (three newest), stage, swap by rename, roll back on any failure. Older backups are upgraded by Drift when the app reopens; newer ones are refused. Safety copy names never overwrite.
- A restore counts as a backup made now and is audited (`backup_restored`); making one is audited (`backup_made`). `last_backup_at` and `backup_reminder_on` live in `app_settings`; no schema change.
- Restore takes effect by restarting the app's providers (`AppRoot.restart`), which opens a fresh database connection. After restore the PINs and users are the backup's.
- The first-run screen offers Restore so a fresh phone can restore before any PIN exists.
- Reminder: daily WorkManager task (about 10 AM) plus a home banner, when there is shop data and the last backup is over 3 days old (or never). The background task never creates a shop. Stage A backups are manual; automatic upload comes with Stage B.
- Using one backup on two phones at once is unsupported (same invoice series); the restore screen says so.

## 2026-11-12 A7 decisions
- Check my data is read-only and reports problems (numbers that must agree) and notes (negative stock, future dates, missing bill numbers). Each check is one SQL query; the sale and purchase stock checks add bill lines and their movements into the same groups in one pass (joining two big grouped lists was ten times slower).
- Schema v5: credit notes. `sales_returns` and `sales_return_lines` (never written before) were rebuilt with a credit note number (`CN-<series>-<n>`, unique per device), GST, round-off share, refund split (cash, UPI, to account), cancel flag and approver.
- Refunds use the cumulative quantity returned per line (half up), so pieces always add up to the line total. The bill's round-off is refunded with the return that completes the bill. A cancel is only allowed when nothing was returned yet; it refunds the way the bill was paid and sets `invoices.status = cancelled` (the only change ever made to a posted bill).
- A counter user needs the owner's PIN for a return or cancel; both people are recorded. Reports count returns on the day they are made; cancelled bills are not counted as bills.
- A backup whose "last backup" time is in the future (clock was wrong) is treated as overdue, not as recent.
- Storage errors (disk full, I/O error, database busy) map to plain messages; a save is all or nothing, proven by failing every write step on a real file database.
- The demo shop and speed check are debug-only; loading it is refused unless a backup was made in the last hour.
- A7 closes only after the owner's week of parallel use (docs/stage-a-exit.md).

## 2026-11-12 A8 decisions (shop Wi-Fi sync)
- The owner chose no paid server and no remote view; instead the shop's phones sync with each other over the shop Wi-Fi (replaces the cloud part of Stage B for now). Normally one phone bills, two in a rush, so it is built and tested for two phones.
- Built and used during the A7 parallel week (owner's choice). On two-phone days the Day check on either phone covers both, since both hold all data.
- Peer to peer, no hub: each phone runs a small HTTP server while the app is open and pulls from the other every 5 seconds and right after a nudge. No background sync.
- Security: a random 32-byte shop key shared only through the pairing QR; AES-256-GCM on every request and reply, bound to the request name, refused if older than 10 minutes. Pairing tokens are one-time and last 10 minutes. A removed phone is refused.
- Schema v6: outbox origin, per-phone seq and change time in milliseconds (table times are stored to the second, which was not enough to order two quick edits); phone-only `sync_peers` and `sync_state`; purchases' unique supplier bill key becomes an index.
- Conflict rule: the later change wins (same phone: later seq; otherwise later millisecond time; exact tie: higher device id). Clashes (an edit the other phone had not seen) are kept in the audit log. Prices and units made separately on both phones for the same thing: the later one stays, the other is soft-deleted, by the same rule on both phones.
- This phone's identity is a file outside the database. After a restore on an unpaired phone the restored data decides (phone A again); on a paired phone the app asks which phone it is if the data does not know it.
- The same supplier bill entered on both phones: both kept (data stays identical), flagged on Home, in Purchases and in Check my data; the owner cancels one with the new Cancel purchase (reversing stock movement as `purchase_return`, reversing supplier ledger `adjustment`, status cancelled). The same phone still refuses a duplicate while one stands.
- Two phones selling the last unit: both bills stand; stock shows negative and the existing warning flags it.
- Phone-only settings that never travel: last backup time, last data check, backup reminder, auto-lock minutes, daily summary on/hour.
- The optional OCR prototype is renumbered A9 in AGENTS.md.

## 2026-11-13 A10 decisions (Marathi)
- Screens in Marathi or English per phone; new installs start in Marathi; the choice is a file beside the device identity (not synced, not in backups, known before the database opens). Switching redraws the screens without logging out or losing a bill in progress.
- Bill language (PDF and WhatsApp) is a separate shop-wide setting chosen by the owner, English by default, synced to both phones.
- Digits stay normal and month names stay English in both languages (owner's correction on 2026-11-13).
- The pdf package cannot shape Devanagari, so Marathi bills are drawn by Flutter's text engine onto 150 dpi page pictures inside the PDF (about 60 KB a page). English bills remain text PDFs.
- Translations use everyday shop Marathi with the English words people use (बिल, स्टॉक, GST, UPI, PIN, बॅकअप); docs/marathi-review.md is the sheet for the shop to correct wording.
- Messages made deep in the app stay English at the source and are translated where they are shown, by whole-sentence patterns that keep names and numbers.

## 2026-11-13 A11 decisions (payment reminders)
- Both channels (owner's choice): automatic SMS from one chosen phone, and a WhatsApp one-tap list (WhatsApp cannot be sent automatically without a paid business service).
- Due = owes at least the minimum, oldest unpaid bill (FIFO ageing) at least N days old, mobile number present, not switched off, and not reminded on any phone within M days. Defaults 15, 7 and ₹100.
- Schema v7: parties.reminders_off and an append-only, synced reminders table, so two phones never double-remind.
- SMS: once a day after the chosen hour from the hourly background job, max 25, 3 s apart; the day is marked before sending so a crash never double-sends; a failed SMS is not recorded and is retried next day. Sent through our own send-only plugin (packages/shop_sms) instead of a third-party package that also reads SMS.
- Message in the bill language, English month names, with the UPI link for the amount owed.

## 2026-11-13 A12 decisions (sync while closed, fingerprint)
- Background sync by keeping the app's one Flutter engine alive in an Android foreground service (not a second engine or isolate), so screens and sync share one database connection. A 15-minute WorkManager job was rejected: two phones would have to wake at the same moment to reach each other.
- Service type `specialUse` (no 6-hours-a-day limit that `dataSync` has on Android 15); acceptable because the APK is not on the Play Store. Changes still go out at once (nudge); the 2-minute alarm is only a safety check (owner chose 2 minutes).
- A shop "mailbox" device (always-on old phone or laptop) was discussed and left for later; it would also cover the two phones not being in the shop at the same time.
- The app locks at once when closed, because the engine now outlives the screen.
- Fingerprint: per person, per phone (owner's choice), biometric only, tied to the person's current PIN hash so any PIN change switches it off. Owner approvals stay PIN only (owner's choice). Logins are not audited, as before.
- Stale stock warning after 30 minutes without a sync, only on lines that leave the item at or below its minimum stock (owner's choice).

## 2026-11-13 A13 decisions (downloads, report PDFs, reminders)
- Downloads go through Android's MediaStore (Android 10+, no storage permission). Older phones share instead of asking for storage permission.
- Report PDFs use the phone's screen language (they are for the shop), drawn with the painted-page engine so Marathi is correct; bills keep the shop's bill language.
- Counter staff never get cost columns in a stock PDF.
- Reminders carry the UPI ID as text and, on WhatsApp, a QR picture for the exact amount (owner's choice). upi:// links were dropped because WhatsApp and SMS never make them tappable; a tappable https pay link would need a paid payment-link service.
- File names stay English with ISO dates (Bill_A-0042_2026-11-13.pdf) so they sort by date in Files on every phone.


## 2026-11-14 Drawing engine
- Impeller switched off (AndroidManifest EnableImpeller=false, Flutter 3.29 falls back to Skia): on a Galaxy S24 Ultra screens opened with scrambled text and icons until another screen was opened. Skia is the long-proven renderer; revisit when Flutter is upgraded (later versions remove the switch).
