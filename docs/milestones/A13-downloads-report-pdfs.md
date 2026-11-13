# A13: Download PDFs, report PDFs, and a payment reminder customers can pay from

## Purpose
The owner found three gaps:
- After saving a bill, the PDF could only be shared. There was no way to keep it on the phone.
- Reports could only be looked at on screen.
- The payment link in reminder messages could not be tapped, because WhatsApp and SMS never make `upi://` links clickable.

## What was built
- **Download PDF** saves the PDF into the phone's **Downloads** folder (visible in Files), then shows "Saved in Downloads: ..." with **Open**. It is on:
  - the bill-saved screen and an opened bill: `Bill_A-0042_2026-11-13.pdf`
  - credit notes: `CreditNote_..._date.pdf`
  - the backup screen: **Save a backup to Downloads**
- **How the saving works.** Android 10 and later save through `MediaStore.Downloads` with no permission, in `MainActivity.saveToDownloads`. On Android 6 to 9 the app says it can't, and opens the share sheet instead.
- **Report PDFs.** An app-bar PDF menu (**Download PDF** / **Share PDF**) is on:
  - Daily sales: totals, how paid, cash in hand, and every bill
  - Dues: each customer's balance with 0-30 / 31-60 / 61-90 / 90+
  - Stock value: stock and cost value, then items below their minimum. Cost columns are left out for counter staff.
  - Item profit: per item, plus items whose cost is not known
  - Day check: this replaces the old .txt share
- **How the PDFs are made.** Reports are written in the phone's screen language and drawn with the same engine as Marathi bills (`buildPaintedPdf`), so Marathi prints correctly. Each page has the shop name, the period, when the report was made, and page n of m.
- **Payment reminders:**
  - The message carries the **UPI ID as text**: "...Please pay when convenient to UPI ID shop@okhdfc." / "(UPI ID: shop@okhdfc)". A long press copies it.
  - On WhatsApp, the reminder is a **QR picture** for the exact amount, with the shop name and amount under it, and the message as its caption. The customer pays from it: GPay or PhonePe, Scan, then pick the photo from the gallery.
  - If the picture can't be sent, the text alone is sent.
  - SMS gets the text only.

## Files
- `lib/core/sharing/file_saver.dart`: FileSaver and file names.
- `lib/shared/downloads.dart`: save, Open, and the fallback.
- `lib/core/printing/report_pdf.dart`: the report documents.
- `lib/features/reports/report_pdf_menu.dart`
- `lib/core/printing/upi_qr_image.dart`
- `BillSharer.sendToWhatsApp(mime:)`

## Tests
- `test/features/downloads_test.dart`:
  - bill done screen and bill detail
  - Open
  - the old-phone fallback to share
  - a backup saved into Downloads
- `test/printing/report_pdf_test.dart`:
  - what each report says
  - cost hidden for counter staff
  - a real PDF in English and Marathi
  - the menus save and share
- `test/features/day_check_screens_test.dart`: the Day check PDF.
- `test/reminders/`:
  - the UPI ID in both languages
  - no link
  - no UPI ID set
  - the WhatsApp QR picture with its caption, recorded once

## Limits
- **Android 9 and older:** these phones can't save into Downloads, so the app shares instead.
- **Large reports:** reports are page pictures (about 60 KB a page). Very long ranges make large files.
- **Paying from the QR picture:** the customer must open their UPI app and pick the picture from the gallery. No message can pay with one tap without a paid payment-link service.
