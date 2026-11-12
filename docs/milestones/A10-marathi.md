# A10: Marathi and English (switchable), and bills in either language

## Purpose
The shop's staff read Marathi best. Every screen can now be shown in Marathi or English, chosen per phone, and the bills sent to
customers (PDF and WhatsApp) can be Marathi or English, chosen once for the whole shop.

## What was built
- **Language engine.** Every entry in `S` (`app/lib/shared/strings.dart`) is a getter that returns English or Marathi
  (`app/lib/shared/strings_mr.dart`, about 560 entries and 60 sentences with numbers or names). A missing Marathi entry shows English.
- **Per-phone choice**, stored in `language.txt` beside the phone's identity file (not in the database: known before the database
  opens, unchanged by a restore, never synced). A new install starts in Marathi; the phone already in use also opens in Marathi.
  Switching redraws every screen at once and keeps the person logged in and any bill being made.
- **Switches.** मराठी / English on the PIN screen and the first-run screen; Settings, Language: "भाषा / Language (this phone)" and
  "Bill language (PDF and WhatsApp)" (owner, whole shop, synced; English by default).
- **Font.** Noto Sans Devanagari is bundled (works offline) as the fallback font, so Marathi and English mix in one line.
- **Messages from deep in the app** (the shop's rules, backups, Check my data, Wi-Fi sync) are written in English where they are made
  and shown in Marathi through a table of patterns (`app/lib/shared/messages_mr.dart`) that keeps names and numbers.
- **Marathi bills.** The `pdf` package cannot join Devanagari letters (बिल became बलि in a test), so Marathi bills and credit notes are
  drawn with Flutter's own text engine (`painted_pdf.dart`, `marathi_bill.dart`) into 150 dpi A4 page pictures inside a PDF: same
  layout as the English bill (item table, totals, GST table, UPI QR, signature), about 60 KB a page. The amount in words is Marathi
  ("रुपये चोवीस हजार तीनशे एक्याण्णव फक्त"). The WhatsApp message follows the bill language. English bills are unchanged text PDFs.
- **Dates and numbers** stay as they were in both languages: English month names ("13 Nov 2026") and normal digits (₹1,250), the owner's choice.

## Tests
- `test/i18n/marathi_complete_test.dart`: every S entry has Marathi, no stale entries, Marathi entries are Devanagari, switching
  changes and restores the text, message patterns translate and keep names and numbers.
- `test/i18n/no_english_in_screens_test.dart`: fails when English is typed into a screen instead of `S`.
- `test/failures/screen_sizes_test.dart`: every screen also fits a small phone in Marathi at normal and 160% text.
- `test/printing/marathi_bill_test.dart`: Marathi amount in words, Marathi bill view, Marathi bill and credit note PDFs (valid, under 1 MB).
- `test/design/audit_shots_test.dart` with `AUDIT_LANG=mr`: pictures of every screen in Marathi on a copy of real shop data.
- All existing tests run in English and still pass.

## How to correct a word
`docs/marathi-review.md` lists every English line beside its Marathi with a column for a better word. Corrections go into
`app/lib/shared/strings_mr.dart` (screens), `app/lib/core/printing/bill_words.dart` (bills) or `app/lib/shared/messages_mr.dart` (messages).

## Limits
- Marathi bill PDFs are pictures: they print and read well but their text cannot be searched or copied.
- A few rare technical messages (programming errors) stay English.
- Item, customer and supplier names stay as they were typed.
