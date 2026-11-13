# Shop App (Pravin Electricals)

Offline-first Android app for an electrical shop: billing, stock, purchases and customer credit.
The full build plan is in [AGENTS.md](AGENTS.md); design decisions are in [docs/decisions.md](docs/decisions.md); one document per finished milestone is in [docs/milestones/](docs/milestones/README.md).

**Current stage:** Stage A (local SQLite, no server). Milestones A0 to A6 are done; A7 (testing gate) has its tools finished and the owner's week of parallel use in progress; A8 (two phones syncing over the shop Wi-Fi, no server) is built and tested on the laptop, with the two-phone test in the shop pending. Thermal printing waits for a printer.

## Requirements
- Flutter 3.29 (Dart 3.7), Android Studio with Android SDK 36, a JDK from Android Studio.
- Android licenses accepted: `flutter doctor --android-licenses`.
- A phone with USB debugging for real-device runs (minimum Android 6.0).

## Run
```bash
cd app
flutter pub get
flutter run            # on a connected phone
```

## Test
```bash
cd app
flutter test           # unit tests (money, units) and repository tests on in-memory SQLite
flutter analyze
```

## Regenerate database code
After changing any table in `app/lib/core/db/tables/`:
```bash
cd app
dart run build_runner build
```
Also bump `schemaVersion` in `app/lib/core/db/app_database.dart` and add a migration step.

## Using the app (A2)
Home -> **New bill**: search by name, brand, SKU or barcode (or scan), pick the unit (metre, roll,
box, piece), type the quantity (e.g. 2.5), optionally a discount, choose a customer or leave
walk-in, tap **Pay** (cash, UPI, credit or a mix), **Save bill**, then **Share PDF**.
Everything works offline. Selling prices include GST; the total is rounded to the nearest rupee.
In debug builds, **Load sample data** on the home screen adds sample items, prices, customers and
stock for testing (or import `sample_data/*.csv` from the Import tile).

## Logging in and roles (A4)
First launch asks the owner for a 4 to 6 digit PIN. The owner adds counter staff (own PIN) under Settings,
Staff and PINs. Counter staff see billing, items, stock, customers and receivables, never cost or profit.
The owner home shows today's summary and Reports; Settings holds shop details, limits, the daily 9 PM
summary notification and the audit log. Update the phone with `adb install -r` to keep data.

## Sharing bills and UPI (A5)
Settings, **UPI ID for QR codes**: customers scan a QR on the Pay screen and on every PDF. After saving a bill tap **Share PDF** or
**WhatsApp** (straight to the customer's number). **Bills** on Home lists old bills to share again.

## Backup and restore (A6)
Settings, **Backup**: **Back up now** makes a checked copy and opens the share sheet; send it to your own email or Drive every few days
(the home screen reminds you after 3 days). To restore, on a new phone tap **Restore from a backup instead** on the first screen, or use
Settings, **Restore from a backup**; then log in with the PIN you had. `flutter install` and uninstalling wipe the data; `adb install -r` keeps it.

## Testing gate (A7)
**Settings, Check my data** proves stock, balances and bill totals agree (it also runs before each backup and after each restore). In Bills, open a bill to **Return items** or **Cancel bill**
(a counter user needs the owner's PIN). **Reports, Day check** is the evening screen to compare with the paper book; the week's log is in `docs/stage-a-exit.md`.

## Two phones on the shop Wi-Fi (A8)
Owner: **Settings, Phones and Wi-Fi sync, Add a phone** shows a QR. Second phone: install the app, connect to the shop Wi-Fi, tap
**Join a shop (second phone)** on the first screen and scan. It gets a copy of the shop and its own bill numbers (B-0001...). While the
app is open on both phones on the same Wi-Fi they share bills, stock, dues and edits within seconds; a dot on Home shows the state.
The same supplier bill entered on both phones is flagged; open it in Purchases and **Cancel this purchase**. Details:
`docs/milestones/A8-wifi-sync.md`.

## Marathi and English (A10)
The app starts in Marathi. Switch with **मराठी / English** on the PIN screen, or Settings, **भाषा / Language**. The owner chooses the
**Bill language** (PDF and WhatsApp) for the whole shop in Settings. To improve a word, see `docs/marathi-review.md`.

## Payment reminders (A11)
Settings, **Payment reminders**: switch on, choose after how many days and how often, and the smallest amount. On one phone switch on
**Send SMS automatically from this phone** (it asks for SMS permission) and pick the time. Dues, bell icon shows who is due today, with a
WhatsApp button for each. A customer's page has a **No payment reminders** switch.

## Sync while closed and fingerprint (A12)
Once two phones are paired, sync keeps running with the app closed (a quiet **Shop sync on** note shows). On the Phones screen, switch
**Keep syncing when the app is closed** and tap **Allow** if it warns about the battery saver. Fingerprint: say Yes when asked after a
PIN login, or Settings, **Fingerprint unlock** (each person's PIN, then their finger). The PIN always works. Details:
`docs/milestones/A12-background-sync-fingerprint.md`.

## Downloads and report PDFs (A13)
After a bill is saved, **Download PDF** keeps it in the phone's Downloads folder (also on an opened bill, credit notes, and Backup,
**Save a backup to Downloads**). Daily sales, Dues, Stock value, Item profit and Day check have a PDF button at the top: **Download
PDF** or **Share PDF**. Payment reminders now show the shop's UPI ID, and on WhatsApp they come with a QR picture to pay from.

## Layout
- `app/lib/core/money.dart`: integer paise maths, parsing, Indian-style formatting.
- `app/lib/core/units.dart`: quantity to base units (cable in millimetres), line amounts.
- `app/lib/core/db/`: Drift tables, `AppDatabase`, and `repositories/` (all writes go through
  these and also write an `outbox` row for the future sync).
- `app/lib/core/bootstrap.dart`, `providers.dart`: first-run shop/device setup and Riverpod providers.
- `app/lib/core/printing/invoice_pdf.dart`: builds the invoice PDF from saved data (never stored).
- `app/lib/features/billing/`: bill calculator (pure maths), bill state, and the bill screens.
- `app/assets/fonts/`: bundled Noto Sans (OFL) so the PDF shows the rupee sign offline.

## Rules to remember
Money is integer paise. Stock is the sum of movements. Posted invoices and purchases are never
edited; corrections are reversing entries. Every table has `shop_id`.
