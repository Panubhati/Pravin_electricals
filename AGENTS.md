# AGENTS.md: Electrical Shop App (build plan for the coding agent)

Read this file fully before writing any code. Follow the milestones in order. Do not skip ahead. Do not add features that are not listed here.

---

## 1. Project summary

A mobile app (Android first) for a small electrical shop (about 30 to 40 customers a day). Staff and owner use it for billing, stock, purchases and customer credit. It must work **offline**. A headline feature: photographing a **supplier purchase invoice** updates stock after a quick human review.

Roles:

| Role | Device | Uses |
|---|---|---|
| owner | phone | dashboard, dues, stock, approvals, reports, settings |
| counter | phone or tablet | quick bill, returns, customer lookup |
| godown | phone | receive stock, invoice photo, stock count |


### Build stages

- **Stage A: local only (SQLite, no server, no cloud).** One phone, everything stored in the on-phone SQLite database. Build it, test it properly, and use it in the shop for a trial before any cloud work.
- **Stage B: cloud.** Only after the Stage A exit criteria (section 12) are met: add the FastAPI backend, PostgreSQL, sync, the invoice photo OCR feature, push alerts and deployment.

Stage A must be built so that moving to the cloud is **an addition, not a rewrite** (see "Design for cloud from day one" in section 12).

---

## 2. Hard constraints (never violate)

1. **No Firebase** or any Google push service dependency. Push alerts use self-hosted **ntfy** (UnifiedPush) for the owner, plus local notifications.
2. **Do not store invoice PDFs.** Generate PDFs on the phone from invoice data when needed (share or print). Regenerate on demand.
3. **No paid AI for invoice reading.** Use free OCR (PaddleOCR, Tesseract as fallback) plus OpenCV quality checks. Unreadable photos are **rejected** with a message, plus a manual entry option.
4. **Money is stored as integer paise.** Never use float or double for money, quantity-times-rate, tax or totals.
5. **Stock is movements.** Never store a mutable "current stock" number as the source of truth. Balance = sum of `stock_movements`. A cached balance is allowed only as a derived value.
6. **Every table has `shop_id`.** (Single shop now, multi-shop ready.)
7. **Offline first.** Billing, stock lookup and customer ledger must work with no internet. The phone writes to local SQLite first. In Stage A nothing syncs anywhere; in Stage B the phone syncs to the server in the background.
8. **Posted invoices and purchases are immutable.** Corrections happen through returns, credit notes or reversing entries, never by editing posted records.
9. **Never update stock from OCR without human confirmation.**
10. **Cost price is hidden** from the `counter` role (enforce on the server, not only in the UI).
11. **Audit log** all edits, deletions, discounts and price overrides.

---

## 3. Tech stack

| Layer | Choice |
|---|---|
| Mobile | Flutter (Dart), Android first |
| Local DB | SQLite via Drift |
| Backend | Python 3.11+, FastAPI |
| ORM and migrations | SQLAlchemy 2.x, Alembic |
| Server DB | PostgreSQL 16 |
| Jobs | Celery + Redis |
| OCR | PaddleOCR (fallback Tesseract), OpenCV, Pillow |
| Auth | JWT (access + refresh), role-based permissions, PIN or biometric lock in the app |
| Push | ntfy (self-hosted), flutter_local_notifications, workmanager |
| PDF and print | Flutter `pdf` and `printing` packages, Bluetooth thermal printing |
| Scan | `mobile_scanner` (camera barcode and QR) |
| Hosting | One VPS, Docker Compose, Caddy or Nginx for HTTPS |
| Errors | GlitchTip (Sentry-compatible), self-hosted |
| Backups | Daily `pg_dump` to separate storage, tested restore |

Check each package's current docs and Android setup notes before adding it. Versions change.

---

## 4. Prerequisites (developer machine)

- Flutter SDK (includes Dart), Android Studio (for Android SDK and emulator), run `flutter doctor` and fix all issues.
- Python 3.11+, Git, Docker Desktop.
- VS Code extensions: Flutter, Dart, Python, Pylance, Docker, SQLTools + PostgreSQL driver, Thunder Client or REST Client.
- A real, cheap Android phone for testing (USB debugging on).

---

## 5. Folder structure

```
shop-app/
  AGENTS.md
  README.md
  .gitignore
  .env.example
  docker-compose.yml
  docs/
    Electrical_Shop_App_Project_Plan.pdf
    sample_invoices/            # 30-50 real supplier bills (do not commit client data to a public repo)
    decisions.md                # log of design decisions
  backend/
    pyproject.toml              # or requirements.txt
    alembic.ini
    alembic/
      versions/
    app/
      main.py
      config.py                 # settings from env
      db.py                     # engine, session
      security.py               # JWT, password/PIN hashing, role checks
      models/                   # SQLAlchemy models, one file per area
      schemas/                  # Pydantic request/response models
      api/
        auth.py
        items.py
        parties.py              # customers and suppliers
        invoices.py             # sales
        purchases.py
        stock.py
        sync.py
        photos.py               # invoice photo upload and status
        reports.py
        admin.py
      services/
        stock_service.py        # movements and balances
        ledger_service.py       # dues, payments, ageing
        invoice_service.py      # numbering, totals, GST
        gst.py                  # HSN, tax split CGST/SGST/IGST
        sync_service.py
        photo_quality.py        # OpenCV checks
        ocr_service.py          # PaddleOCR wrapper
        invoice_parser.py       # text to structured lines
        matching.py             # alias + fuzzy item matching
        validators.py           # GSTIN, totals checks
        notify.py               # ntfy client
      workers/
        celery_app.py
        tasks.py                # process_invoice_photo, daily_summary, reminders
    tests/
  app/                          # Flutter project (create with flutter create)
    lib/
      main.dart
      core/
        db/                     # Drift database, tables, DAOs
        sync/                   # push/pull, queue, conflict rules
        api/                    # dio client, auth interceptor
        auth/                   # login, PIN/biometric lock, role guard
        money.dart              # paise helpers, formatting
        units.dart              # unit conversion helpers
        printing/               # PDF builder, Bluetooth thermal printer
      features/
        billing/                # quick bill
        items/
        purchase/
        stock/
        parties/                # customers, suppliers, ledger
        dashboard/              # owner view
        invoice_photo/          # camera, quality check, review screen
        coils/                  # phase 2
        warranty/               # phase 2
        settings/
      shared/                   # widgets, theme
    test/
```

---

## 6. Setup steps (do these first)

**Stage A needs only 6.1, 6.2 and 6.6 (Flutter).** Skip Docker, the backend and PostgreSQL (6.3 to 6.5) until Stage B.

### 6.1 Repo and folders
```bash
mkdir shop-app && cd shop-app
git init
mkdir -p docs/sample_invoices backend
flutter create --org com.yourname --project-name shop_app app
```

### 6.2 `.gitignore` must include
```
.venv/
__pycache__/
.env
*.pyc
docs/sample_invoices/
backend/uploads/
app/build/
```

### 6.3 `.env.example`
```
POSTGRES_USER=shop
POSTGRES_PASSWORD=change_me
POSTGRES_DB=shopdb
DATABASE_URL=postgresql+psycopg2://shop:change_me@localhost:5432/shopdb
REDIS_URL=redis://localhost:6379/0
JWT_SECRET=change_me_long_random
JWT_ACCESS_MINUTES=30
JWT_REFRESH_DAYS=30
UPLOAD_DIR=./uploads
NTFY_URL=http://localhost:8080
NTFY_TOPIC=shop-owner-alerts
```

### 6.4 `docker-compose.yml` (start with db and redis; Stage B only; add ntfy at B5)
```yaml
services:
  db:
    image: postgres:16
    env_file: .env
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]
  redis:
    image: redis:7
    ports: ["6379:6379"]
volumes:
  pgdata:
```
Run: `docker compose up -d`

### 6.5 Backend environment
```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate    Mac/Linux: source .venv/bin/activate
pip install fastapi "uvicorn[standard]" sqlalchemy alembic psycopg2-binary pydantic-settings \
            python-jose passlib[bcrypt] celery redis python-multipart pytest httpx
alembic init alembic
```
OCR dependencies (add at B4): `opencv-python-headless pillow paddleocr rapidfuzz` (plus `paddlepaddle` as required by PaddleOCR; check current install docs).

### 6.6 Flutter packages
```bash
cd app
flutter pub add drift sqlite3_flutter_libs path_provider path dio mobile_scanner pdf printing \
  flutter_local_notifications workmanager uuid intl flutter_riverpod local_auth \
  image_picker camera flutter_secure_storage connectivity_plus
flutter pub add --dev drift_dev build_runner flutter_test
```
Add a Bluetooth thermal printer package at A5 after checking which printer model the shop has.

### 6.7 Verify
- `uvicorn app.main:app --reload` from `backend/` serves `http://localhost:8000/docs`.
- `flutter run` launches on the connected phone.
- Commit: "chore: project scaffold".

---

## 7. Data model

All ids are UUIDs generated on the client where the record can be created offline. All tables have `shop_id`, `created_at`, `updated_at`, and `deleted_at` (soft delete) unless noted. Amounts are integer paise. Quantities in stock movements are stored in the item's **base unit** (as integer or fixed-decimal such as milli-metres; decide at M1 and write it in `docs/decisions.md`).

### Core
- `shops(id, name, gstin, address, state_code, phone, terms)`
- `users(id, shop_id, name, phone, role[owner|counter|godown], pin_hash, active)`
- `devices(id, shop_id, user_id, label, invoice_series_prefix)` (per-device invoice series: A, B, C)

### Items
- `items(id, shop_id, name, brand, category, hsn, gst_rate_bp, base_unit, track_serial bool, track_coil bool, min_stock_base, active)`
- `item_units(id, item_id, unit_name, factor_to_base)` e.g. roll = 90 m, box = 10 pcs
- `item_variants(id, item_id, label, size, rating, colour, barcode, sku)`
- `item_prices(id, item_id, variant_id, tier[retail|contractor|dealer], rate_paise_per_base_unit)`
- `item_costs(id, item_id, variant_id, cost_paise_per_base_unit, effective_from)` (owner-only visibility)

### Parties and ledger
- `parties(id, shop_id, kind[customer|supplier|both], name, phone, gstin, address, tier, credit_limit_paise)`
- `ledger_entries(id, shop_id, party_id, entry_type[invoice|payment|return|opening|adjustment|purchase|supplier_payment], amount_paise signed, ref_type, ref_id, note, ts)`

### Sales
- `invoices(id, shop_id, device_id, series, number, invoice_no_text, party_id, date, subtotal_paise, discount_paise, tax_paise, round_off_paise, total_paise, paid_paise, status[posted|cancelled], shop_snapshot_json, created_by)`
- `invoice_lines(id, invoice_id, item_id, variant_id, unit_name, qty_entered, qty_base, rate_paise_per_base_unit, discount_paise, gst_rate_bp, tax_paise, line_total_paise, coil_id null, serial null)`
- `invoice_payments(id, invoice_id, mode[cash|upi|credit|card], amount_paise, ref)`
- `sales_returns` and `sales_return_lines` (same idea; creates reversing stock and ledger entries)

### Purchases
- `purchases(id, shop_id, supplier_id, supplier_invoice_no, supplier_invoice_date, subtotal_paise, tax_paise, total_paise, source[manual|photo], photo_id null, status[posted|cancelled])`
  - unique on (`shop_id`, `supplier_id`, `supplier_invoice_no`) to block duplicates
- `purchase_lines(id, purchase_id, item_id, variant_id, unit_name, qty_entered, qty_base, rate_paise, gst_rate_bp, line_total_paise)`

### Stock
- `locations(id, shop_id, name[shop|godown|vehicle])`
- `stock_movements(id, shop_id, item_id, variant_id, location_id, qty_base signed, movement_type[purchase|sale|sale_return|purchase_return|transfer_in|transfer_out|adjustment|count], ref_type, ref_id, ts, created_by)`

### Phase 2
- `coils(id, shop_id, item_id, batch_no, original_len_base, remaining_len_base, status)`
- `serials(id, shop_id, item_id, serial_no, purchase_id, sale_invoice_id null, warranty_months, warranty_until null, status)`
- `warranty_claims(id, serial_id, supplier_id, status, notes)`

### Invoice photo feature
- `invoice_photos(id, shop_id, uploaded_by, file_path, page_no, status[queued|processing|rejected|needs_review|posted|manual], reject_code, reject_message, ocr_json, extracted_json, purchase_id null)`
- `supplier_aliases(id, shop_id, supplier_id, alias_text_normalized, item_id, variant_id null, unit_name, confirmed_by, times_used)`

### Sync and audit
- `change_log(id bigserial, shop_id, entity, entity_id, op[upsert|delete], payload_json, device_id, ts)` (server-side cursor for pull)
- `audit_log(id, shop_id, user_id, action, entity, entity_id, before_json, after_json, ts)`

---

## 8. Business rules

### Units
- Every item has a `base_unit` (smallest sold unit: metre, piece). `item_units` define conversions. All stock maths is in base units.
- Bill screen lets staff pick any defined unit; store `qty_entered`, `unit_name` and computed `qty_base`.

### Pricing
- Price = tier price for the customer's tier, falling back to retail. Staff may override rate only if the role permits. If rate is below cost, require owner approval or block (configurable).

### GST
- Use HSN and `gst_rate_bp` (basis points) per line. Intra-state: CGST+SGST split; inter-state: IGST (compare shop and party state codes). Round at line or invoice level consistently and write the choice in `docs/decisions.md`.

### Invoice numbering
- Per-device series: `{prefix}-{zero-padded sequence}` (e.g. `A-0001`). The device owns its sequence, so offline devices never collide.

### Credit
- Credit sale creates a positive receivable ledger entry. Payment creates a negative one. Ageing buckets: 0-30, 31-60, 61-90, 90+ days. Warn or block above `credit_limit_paise`.

### Coils (Phase 2)
- Selling cable by length from a coil: choose coil, enter length, create a sale movement and reduce `remaining_len_base`. Block selling more than remaining.

### Serial and warranty (Phase 2)
- On sale of a serial-tracked item, scan the serial, link it to the invoice, compute `warranty_until`.

---

## 9. Sync design (offline-first)

**Stage B.** Do not build the sync service in Stage A, but do create the outbox table and write to it (see section 12).

- Phone writes everything to local SQLite first with client-generated UUIDs.
- A local `outbox` table records each pending change (entity, id, op, payload, attempt count).
- **Push**: `POST /sync/push` with a batch of changes. Server applies each change idempotently (same UUID twice does nothing) inside a transaction, writes to `change_log`, and returns per-change results.
- **Pull**: `GET /sync/pull?cursor=N` returns changes after the cursor plus a new cursor. Phone applies them locally.
- **Conflicts**:
  - Posted invoices, purchases and stock movements are append-only, so they cannot conflict.
  - Master data (items, prices, parties): last write wins by server timestamp. Log overwritten values to `audit_log`.
- Background sync with `workmanager` plus a manual "Sync now" button and a visible sync status indicator.
- Server rejects pushes for entities the user's role may not write.

---

## 10. API outline (FastAPI)

Auth: `POST /auth/login`, `POST /auth/refresh`, `POST /auth/pin-verify`
Master data: `GET/POST/PATCH /items`, `/items/{id}/units`, `/items/{id}/variants`, `/items/{id}/prices`, `GET/POST/PATCH /parties`
Sales: `POST /invoices`, `GET /invoices?from&to&party`, `POST /invoices/{id}/return`
Purchases: `POST /purchases`, `GET /purchases`
Stock: `GET /stock/balances?location`, `POST /stock/adjust`, `POST /stock/transfer`, `POST /stock/count`
Ledger: `GET /parties/{id}/ledger`, `POST /payments`, `GET /reports/dues-ageing`
Sync: `POST /sync/push`, `GET /sync/pull`
Photos: `POST /photos` (multipart), `GET /photos/{id}` (status, rejection, extracted lines), `POST /photos/{id}/confirm` (staff-corrected lines; creates the purchase), `POST /photos/{id}/manual`
Reports: `GET /reports/daily-sales`, `/reports/item-profit`, `/reports/stock-value`, `/reports/low-stock`
Admin: `GET/POST /users`, `GET /audit-log`

Role checks on every route. Cost fields are omitted from responses for `counter`.

---

## 11. Invoice photo pipeline

### On the phone (before upload)
1. Camera screen with frame overlay. Allow multiple pages.
2. Local checks, fail fast with a hint:
   - blur (Laplacian variance), brightness (mean grey), resolution, page edges visible
3. Auto-crop and straighten, compress, queue for upload (works offline, uploads when connected).

### On the server (`process_invoice_photo` Celery task)
1. Re-run quality checks (server is the source of truth).
2. OCR with PaddleOCR; keep per-word text, box and confidence.
3. Check required fields present: supplier name or GSTIN, invoice number, date, item table, total.
4. Parse item table into lines (description, HSN, qty, unit, rate, GST, amount).
5. Validate numbers: qty x rate = line amount (small tolerance), lines sum to invoice total (tolerance Rs. 2), valid GSTIN format, duplicate (supplier + invoice no).
6. Match each line to an item: supplier alias first, then fuzzy match (rapidfuzz) with a confidence score. Apply unit conversion.
7. Set status: `rejected` (with `reject_code`) or `needs_review` (with extracted lines).

### Starting thresholds (tune on real bills; record results in `docs/decisions.md`)
| Check | Start value |
|---|---|
| Blur | Laplacian variance below ~100 rejects |
| Brightness | mean grey outside ~60 to 200 rejects |
| Resolution | long side below ~1600 px rejects |
| OCR confidence | mean below ~0.80 rejects |
| Totals tolerance | difference above Rs. 2 rejects |

### Rejection messages (exact wording)
| Code | Message |
|---|---|
| `NOT_READABLE` | Text not readable. Please upload a clear picture. |
| `BLURRY` | Hold the phone steady and retake. |
| `DARK_OR_BRIGHT` | Take the photo in better light. |
| `CUT_OFF` | Make sure the whole bill is in the frame. |
| `TOTALS_MISMATCH` | Some numbers could not be read. Please retake the photo. |
| `DUPLICATE` | This invoice was already entered. |

Every rejection screen has an **Enter manually** button (keeps the photo attached).

### Review screen (mandatory)
- Original photo beside extracted lines.
- Lines coloured by match confidence. Unmatched lines: "pick existing item" or "create new item".
- Staff edits, then taps Confirm. Only then: create purchase, stock movements and supplier ledger entry in one transaction.
- When staff correct a match, save a `supplier_aliases` row so the next bill from that supplier matches automatically.

### Known limit
OCR can misread a digit while reporting high confidence. Human review is the safety net. Never skip it.

---

## 12. Milestones (build in this order)

Each milestone has tasks and acceptance criteria. Finish and test one before starting the next. Commit after each milestone.

### Design for cloud from day one (applies to all of Stage A)

So that Stage B does not force a rewrite:

- Every primary key is a **UUID generated on the phone** (never autoincrement ints for synced entities).
- Every table has `shop_id`, `created_at`, `updated_at`, `deleted_at` (soft delete).
- Each phone has a `device_id` and an invoice series prefix; invoice numbers are per device (`A-0001`).
- All writes go through **repository classes** (not scattered DAO calls in widgets). Each repository write also inserts a row into a local `outbox` table (entity, id, op, payload, created_at). Nothing reads the outbox in Stage A; Stage B's sync will.
- Financial records are **append-only** (stock movements, ledger entries, posted invoices). Corrections use reversing entries.
- Drift **schema versioning and migrations** from the first release, so a phone with shop data can upgrade safely.
- Keep the Drift tables identical in names and meaning to section 7, so the Postgres schema can mirror them.

### Stage A: local only (SQLite)

#### A0: Scaffold
- Create folders, `.gitignore`, Flutter project, packages from 6.6 (skip backend and Docker).
- **Done when:** the app runs on a real phone and `flutter test` runs (even with one placeholder test).

#### A1: Data model and local database
- Drift tables and DAOs for section 7 (core, items, parties, ledger, sales, purchases, stock) plus `outbox` and `devices`.
- `core/money.dart` (paise maths, formatting) and `core/units.dart` (conversion) with tests.
- Decide base-unit quantity representation (for example integer millimetres vs fixed decimal) and log it in `docs/decisions.md`.
- **Done when:** DAO tests pass against an in-memory SQLite database; unit tests cover paise maths and conversions (roll to metre, box to piece).

#### A2: Quick bill (offline)
- Item search and camera barcode scan, unit picker, rate by tier, discount, customer or walk-in, payment mode (cash, UPI, credit, mixed).
- Totals with GST, per-device invoice number, save to local DB, create stock movements and ledger entries in one database transaction.
- Generate the invoice PDF on the phone from data; share via the Android share sheet. Do not store the PDF.
- **Done when:** a dual-unit bill takes under 30 seconds, works in airplane mode, and totals match a hand calculation.

#### A3: Items, purchases, stock, parties
- Item master screens (units, variants, barcodes, prices, min stock). CSV/Excel import for items, customers and opening balances.
- Manual purchase entry with unit conversion. Stock list, adjustment, transfer, stock count.
- Customer and supplier ledger, payments, dues with ageing.
- **Done when:** imported opening stock and balances are correct; a purchase raises stock; a payment reduces dues; the ageing report is correct.

#### A4: Owner dashboard, reports, local alerts
- Dashboard: today's sales, cash in hand, low stock, top dues. Reports: daily sales, item profit, stock value.
- Local notifications (daily summary, low stock, overdue dues).
- Local roles with PIN login (owner, counter). Hide cost price and profit from `counter` in the UI. **Note:** in Stage A this is UI-level only (the data is on the phone); server-enforced hiding arrives in Stage B.
- Audit log screen for the owner.
- **Done when:** counter login shows no cost or profit anywhere; reports match seeded test data.

#### A5: Printing and sharing
- Bluetooth thermal printer (58 mm or 80 mm), UPI QR on the invoice, PDF layout polish.
- **Done when:** a receipt prints on the shop's printer and the PDF opens correctly in WhatsApp.

#### A6: Local backup and restore
Because all data lives on one phone in Stage A, losing the phone means losing the shop's data.
- Export a backup file of the database (and restore from it) from the Settings screen, saved to phone storage and shareable to the owner's own email or drive.
- Scheduled reminder to back up (local notification).
- **Done when:** restoring a backup onto a fresh install reproduces identical balances and bills.

#### A7: Testing gate (do this before any cloud work)
Automated:
- Unit tests: money, units, GST, billing totals, stock balance, ledger and ageing.
- DAO and repository tests on in-memory SQLite, including transaction rollback when a save fails midway.
- Widget and integration tests for the full bill flow (search, unit, payment, save, PDF).
- **Invariant checks** (write as a test and as a hidden "Verify data" action in Settings):
  - stock balance per item equals the sum of its `stock_movements`
  - each party's balance equals the sum of its `ledger_entries`
  - each invoice total equals the sum of its lines plus tax, minus discount, plus round-off
  - no duplicate invoice numbers within a device series
- Seed script: generate realistic data (for example hundreds of items, about 200 customers, 30 days of about 40 bills a day) and check screens stay responsive. Set a search-time target and test on a cheap Android phone.
- Failure tests: kill the app mid-bill, low battery, full storage, change the phone clock, rotate screen, airplane mode.
- Migration test: install the previous schema version with data, upgrade, confirm nothing is lost.

Manual (with the owner):
- Walk through real scenarios from the shop: cash sale, credit sale, mixed payment, return, partial payment, purchase, stock count, month-end dues.
- Parallel run: use the app beside paper billing for at least one week; compare daily totals and stock each evening.

**Stage A exit criteria (all must be true before Stage B):**
1. All automated tests and invariant checks pass.
2. A week of parallel use with no unexplained mismatch in sales, stock or dues.
3. Backup and restore proven on a second phone.
4. The owner confirms the screens and flows are what they need.
5. Open decisions in section 15 that affect the schema are answered.

#### A8 (optional, can run in parallel): OCR feasibility prototype
- A standalone Python script on the laptop (no app, no backend): runs the photo quality checks and PaddleOCR on the collected sample invoices and records pass/fail, confidence and parsing accuracy in `docs/decisions.md`.
- **Done when:** there is a measured answer to "is free OCR good enough for this shop's bills?" and starting thresholds are tuned. This decides how much effort Stage B's photo feature needs.

### Stage B: cloud (start only after Stage A exit criteria)

#### B1: Backend, database and auth
- FastAPI project, PostgreSQL via Docker, Alembic migrations that **mirror the Drift schema**, JWT auth with roles.
- A schema parity check (script or test) comparing table and column names between Drift and Postgres.
- **Done when:** `/docs` loads, migrations apply cleanly, login works for each role, and cost fields are omitted from `counter` responses (server-enforced).

#### B2: Sync
- `/sync/push` (idempotent, per-change results) and `/sync/pull` (cursor) with `change_log`.
- In the app: a sync service that reads the outbox, plus a status indicator, background sync with `workmanager`, and a "Sync now" button.
- **First sync of existing data:** upload the Stage A phone's existing data through the same push path (backfill the outbox from current tables), and verify counts and balances match on the server.
- **Done when:** the shop phone's existing data appears on the server with identical stock balances, ledger balances and invoice totals (run the A7 invariant checks on the server too).

#### B3: Multi-device test
- Two phones create bills offline, both sync, both see each other's data.
- **Done when:** no duplicate invoice numbers, no lost records, stock and dues agree on both phones and the server.

#### B4: Invoice photo to stock
- Camera screen, on-phone quality checks, upload queue. Server: quality checks, PaddleOCR, parser, validators, matching, alias learning, Celery task.
- Review screen and confirm flow; rejection screens with the exact messages; manual entry button.
- **Done when:** results on the sample invoices are recorded; bad photos are rejected with the right message; a confirmed photo creates the purchase and stock correctly; a duplicate invoice is blocked; no stock changes without confirmation.

#### B5: Push alerts and operations
- Add ntfy to Docker Compose; owner alerts (large due, stock-out, daily summary).
- GlitchTip for errors; daily `pg_dump` backup job and a **tested restore**.
- HTTPS with Caddy or Nginx; deploy to the VPS.
- **Done when:** an alert reaches the owner's phone and a restore from backup is proven on a fresh database.

#### B6: Cloud pilot
- Run on the cloud with 1 or 2 shop phones for 2 to 4 weeks. Fix issues, tune OCR thresholds.
- **Done when:** the owner signs off that daily numbers match their records.

### Phase 2 (after the cloud pilot)
- **P2-A Coils:** coil records, partial length sales, remaining length.
- **P2-B Serial and warranty:** scan at sale, warranty lookup, supplier claim tracking.
- **P2-C Price tiers with margin check** and approval flow.
- Later: Tally export, WhatsApp official API, GST return reports, iOS.

---

## 13. Conventions

- **Backend:** type hints everywhere, Pydantic schemas for all I/O, business logic in `services/` (not in route functions), Alembic migration for every schema change, never edit an applied migration.
- **App:** feature folders, Riverpod for state, Drift DAOs for all DB access, no business logic in widgets. UI text goes in one place to allow Marathi/Hindi later.
- **Tests:** pytest for services (stock, ledger, GST, validators, matching, photo quality); Flutter unit tests for money, units, billing totals, sync outbox. Add a test with every bug fix.
- **Git:** one branch per milestone, small commits, message style `feat:`, `fix:`, `chore:`, `docs:`.
- **Secrets:** never commit `.env`, client invoices or customer data.
- **Decisions:** record every non-obvious decision in `docs/decisions.md` with date and reason.
- **UI:** large touch targets, few taps per bill, works on cheap Android phones. Test on a low-end device.

---

## 14. Working rules for the agent

1. Work on one milestone at a time. State the plan briefly, make the changes, run the tests, then summarise what changed.
2. If a requirement is unclear or two options conflict with section 2, **ask before coding**. Do not guess on money, stock, tax or sync behaviour.
3. Do not add dependencies outside section 3 without asking, and never add Firebase or any Google push library.
4. Do not change the schema without writing a migration and updating the Drift tables to match.
5. Never delete or rewrite posted financial records in code paths. Use reversing entries.
6. After each milestone, update `README.md` with how to run and test, and tick off the milestone in a checklist at the end of this file.
   Also write `docs/milestones/<milestone>.md` (purpose, what was built, how it works, rules, tests, decisions, limits) and add it to `docs/milestones/README.md`.
7. Flag anything you could not verify (for example a package setup step or an OCR accuracy claim) instead of stating it as fact.
8. **Do not start Stage B until the Stage A exit criteria in section 12 are met.** In Stage A, do not create backend code, Docker services or network sync. Do follow "Design for cloud from day one".
9. Each milestone ends with tests written and passing. If a milestone cannot be tested, say why instead of marking it done.

---

## 15. Open decisions (ask the owner/developer; record answers in `docs/decisions.md`)

- [ ] Keep supplier invoice photos after posting? (Recommended: yes, compressed. Confirm retention rules with the shop's accountant.)
- [ ] Thermal printer model and paper width the shop uses. (Owner has no printer yet; printing deferred to A5b.)
- [ ] Supplier bills: mostly clean printed GST invoices, or many handwritten? (Decides how often photos are rejected.)
- [ ] Staff use their own phones or shop devices?
- [ ] Quantity representation for cable length (millimetres as integer vs fixed decimal).
- [ ] Rounding rule for GST (per line or per invoice).
- [ ] Below-cost selling: block, or allow with owner approval?
- [ ] Biggest owner pain (stock mismatch, credit recovery, slow billing, warranty claims). Build that differentiator first in Phase 2.

---

## 16. Progress checklist

**Stage A (local, SQLite)**
- [x] A0 Scaffold
- [x] A1 Data model and local database
- [x] A2 Quick bill (offline)
- [x] A3 Items, purchases, stock, parties
- [x] A4 Owner dashboard, reports, local alerts
- [x] A5 Printing and sharing (sharing, UPI QR, bills history done; thermal printing deferred to A5b)
- [ ] A6 Local backup and restore
- [ ] A7 Testing gate and exit criteria
- [ ] A8 OCR feasibility prototype (optional)

**Stage B (cloud)**
- [ ] B1 Backend, database and auth
- [ ] B2 Sync (including first sync of existing data)
- [ ] B3 Multi-device test
- [ ] B4 Invoice photo to stock
- [ ] B5 Push alerts and operations
- [ ] B6 Cloud pilot

**Phase 2**
- [ ] P2-A Coils
- [ ] P2-B Serial and warranty
- [ ] P2-C Price tiers with margin check
