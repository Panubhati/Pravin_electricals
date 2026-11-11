# A5: Sharing, UPI QR, PDF polish, bills history

**Status:** done (2026-11-12). Tests: 299 passing, `flutter analyze` clean.
Accepted on the owner's phone (Samsung SM A356E), upgrading in place from A4 (schema v3 to v4).
Commits: `e18c699` (data and helpers), `9d54c6c` (PDF, QR, bills, sharing).
**Thermal printing was deferred** at the owner's request (the shop has no printer yet). It becomes A5b when a printer is bought.

## Purpose
Make a saved bill easy to send (WhatsApp or any app), get paid by UPI QR, and find and re-send any old bill.

## What people can do
- **UPI QR.** The owner sets the shop's UPI ID (and an optional payee name, default the shop name) in Settings. Then:
  - the **Pay screen** shows a QR for the UPI amount typed, so the customer can scan before the bill is saved;
  - **every PDF** carries a QR: for the balance due when part of the bill is on credit, otherwise for the full total.
  No UPI ID means no QR anywhere (the owner sees a hint on the Pay screen). Changing the UPI ID is audited.
- **Better PDF.** HSN column (the HSN the item had when it was sold), customer address and place of supply, amount in words
  (Indian style), balance due, "For <shop>" signature line, page numbers, GST breakdown, terms.
- **WhatsApp.** From the bill-saved screen or a bill's detail, **WhatsApp** opens the customer's chat with the PDF attached and a
  short message. No phone number, or WhatsApp not installed: the normal share sheet opens instead and says why.
- **Bills** tile (everyone): saved bills newest first, search by bill number or customer, filter by dates, open a bill as printed,
  share it again. No cost or profit appears on it.

## How it works
- `core/printing/invoice_view.dart`: everything printed, as plain text, built from saved data (`InvoiceView.from`). The PDF only
  draws it, which makes the content testable.
- `core/printing/invoice_pdf.dart`: draws the view; QR through the `pdf` package's barcode widget.
- `core/printing/{amount_in_words,upi_link}.dart`, `core/sharing/{phone_number,bill_sharer}.dart`: pure helpers and the share
  abstraction (`BillSharer`, faked in tests).
- `core/db/repositories/{settings,invoice}_repository.dart`: `upiPayee`, `setUpi` (validated, audited), `InvoiceRepository.list`.
- Schema v4: `invoice_lines.hsn`, set when a bill is saved (older lines fall back to the item's current HSN).
- Android: `MainActivity.kt` method channel `sendToWhatsApp` (WhatsApp, then WhatsApp Business), `FileProvider` and
  `res/xml/share_paths.xml`. The temporary PDF is in the app cache and files over a day old are deleted on the next send.
- `features/bills/` (list, detail, `shareBill`), `features/billing/upi_qr_card.dart`.

## Rules
- The PDF is never stored by the app: it is rebuilt from data each time.
- UPI link uses only the standard fields: `upi://pay?pa=<id>&pn=<name>&am=<rupees.paise>&cu=INR&tn=Bill <no>`.
- WhatsApp numbers: digits only; 10-digit Indian mobiles (start 6-9) get 91; leading 0 and 00 dropped.

## Tests
Amount in words (lakh/crore, paise), UPI link (encoding, paise, bad IDs), phone numbers; migration v3 to v4; UPI settings
(validation, audit, clear); sold HSN kept after the item changes; bills list (order, search, dates, due); invoice view text for
mixed, walk-in, discounted, inter-state and no-HSN bills; QR rules (none without an ID, balance when credit, total when paid);
PDF renders with and without QR and across pages; Pay screen QR follows the UPI amount; Settings UPI screen; bills screens;
Share and WhatsApp through a fake sharer (number, filename, message, both fallbacks); counter sweep extended to Bills and bill detail.

## Known limits
- No thermal printing yet (A5b). The PDF can be printed through the phone's share sheet.
- No cancel or return of a posted bill.
- PDF text is English only (Hindi or Marathi later).
- Native WhatsApp code is proved by the phone check, not by Flutter tests. UPI apps may read the QR slightly differently.
