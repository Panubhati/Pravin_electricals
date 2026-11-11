# A4: Owner dashboard, reports, local alerts, roles with PIN

**Status:** done (2026-11-12). Tests: 245 passing, `flutter analyze` clean.
Accepted on the owner's phone (Samsung SM A356E), upgrading in place from A3 (schema v2 to v3).
Commits: `a628c89` (data layer), `cc01eac` (PIN lock and roles), `05eed26` (screens, notification, tests).

## Purpose
Give the owner a daily picture of the shop, protect cost and profit from counter staff, and keep a
readable history of changes.

## What people can do
- **Everyone logs in with a PIN.** First launch asks the owner to set a 4 to 6 digit PIN. The lock screen lists
  the people who can log in. The app locks again after it has been in the background for 2 minutes (setting) and
  from the lock icon on Home. Locking returns to the home screen, so the next person never lands on someone
  else's screen. Forgotten owner PIN: confirm with the phone's own screen lock, then set a new PIN.
- **Owner home:** a summary card (today's sales, cash in hand, bills, low stock, customers owe, biggest dues, each
  tappable) above the tiles. New tiles: **Reports** and **Settings**.
- **Reports (owner only):** Daily sales (any day: bills, GST, split by cash, UPI, credit; cash in hand with opening,
  cash sales, cash received, cash paid out, closing); Item profit (today, 7 days, this month or any dates; items with
  no cost price listed separately); Stock value (balance x latest cost, items with no cost listed separately).
- **Settings (owner only):** shop details (name, GSTIN, address, state code, phone, bill terms), staff and PINs,
  counter discount limit (default 5% per line), opening cash, auto-lock minutes, daily summary on/off, time and a
  "send a test summary now" button, and the audit log.
- **Audit log (owner only):** newest first, filter by prices, discounts, stock, edits, users and shop, or by dates;
  shows who, when, on which item or person, and what changed (only changed fields, money in rupees, cable stock in metres).
- **Daily summary:** a phone notification at about 9 PM (time is a setting): sales and bills, cash in hand,
  customers owe, items to restock. Built from the same numbers as the dashboard.
- **Counter staff** see: New bill, Items (view only), Stock, Customers, Dues (receivables only). They do not see
  Reports, Settings, Purchases, Suppliers, Import, the dashboard, or any cost, profit or margin. Discounts above the
  limit are blocked on the bill ("Staff can give up to 5% discount. Ask the owner.") and the controller refuses to save them.

## How it works
- `core/db/repositories/reports_repository.dart`: `dailySales`, `cashPosition`, `itemProfit`, `stockValue`,
  `lowStock`, `dashboard`. Reuses `DuesRepository` and `StockRepository`, so every screen agrees.
- `core/db/repositories/auth_repository.dart`: salted SHA-256 PINs, 5 wrong tries lock for 30 seconds (doubling to 15
  minutes), counter users (unique names, audited, the owner can never be removed), owner recovery.
- `core/db/repositories/settings_repository.dart`: `app_settings` key/value table (schema v3) with defaults.
- `core/permissions.dart`: role-driven `Permissions` (canSeeCost, canEditPrices, canSeeReports, canOpenSettings,
  canSeeAudit, canSeePurchases, canImport, maxDiscountPercent). "Nobody logged in" means nothing allowed.
- `core/auth/auth_providers.dart`: `currentUserProvider`, `actingUserIdProvider` (stamps `created_by` and audit rows with
  the logged-in person), device-lock confirmation (`local_auth`).
- `features/auth/`: PIN pad, lock screen, first-run PIN setup, `LockGate` (wraps the whole app in `MaterialApp.builder`).
- `features/{dashboard,reports,settings,audit}/`.
- `core/notifications/`: summary text, notification service and scheduler (both faked in tests), and an Android
  WorkManager task that opens the database in the background and shows the notification.

## Rules and formulas
- **Profit** = sales without GST (line total minus GST inside) minus quantity x cost. The cost for a bill line is the
  latest cost price effective on or before the bill's date. Lines with no cost then are shown as "cost not known" and
  never guessed.
- **Cash in hand** for a day = cash on bills + cash received from customers - cash paid to suppliers, on top of the
  opening cash and every earlier day.
- **Stock value** = balance on hand x latest cost (without GST).
- Low stock uses the same rule as the Stock screen's Low filter.

## Tests
Reports against a hand-calculated dataset (profit with a cost change between sales, missing cost, day boundaries, cash
modes); auth (hashing, lockout doubling, recovery, outbox never holds a plain PIN); migration v1 to v3 and v2 to v3; lock
gate flows (first-run PIN, wrong and locked-out PINs, staff login, lock returns home, forgot PIN); counter permissions per
screen; discount cap on screen and in the controller; settings, shop details, staff and audit screens; summary text equal to
the dashboard and the scheduling logic; a **counter-view sweep** that walks every counter-reachable screen and fails on any
cost, profit, margin, supplier or purchase text or on known cost amounts (it found and fixed a "Cost today: -" label on the
item form); a whole-flow test with owner and counter (`created_by`, discount refusal, audit under the owner's name).

## Known limits
- Hiding cost and profit is UI-level only (the data is on the phone); server-enforced hiding comes in Stage B.
- Wrong-PIN counters reset when the app restarts.
- Cash in hand has no expenses, and sales returns are not in reports yet.
- The summary time is approximate (Android may delay background work to save battery).
- A "both" customer/supplier shows purchase entries in their statement to anyone who can open them.
- Counter staff can adjust and count stock; only the owner can add or edit items and prices.
- `adb install -r` keeps data; `flutter install` uninstalls first and wipes it (backup and restore come in A6).
