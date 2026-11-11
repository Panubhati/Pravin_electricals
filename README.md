# Shop App (Pravin Electricals)

Offline-first Android app for an electrical shop: billing, stock, purchases and customer credit.
The full build plan is in [AGENTS.md](AGENTS.md); design decisions are in [docs/decisions.md](docs/decisions.md); one document per finished milestone is in [docs/milestones/](docs/milestones/README.md).

**Current stage:** Stage A (local SQLite only, no server). Milestones A0 to A3 (items, purchases, stock, parties) are done.

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
