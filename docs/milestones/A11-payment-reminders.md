# A11: Payment reminders to customers who owe money

## Purpose
Customers on credit (udhaar) forget to pay. Customers who have owed money for a set number of days get a polite reminder, again every
few days until they pay. Some customers never get one.

## What was built
- **Rules** (`ReminderRepository.due`): a customer is due when reminders are on, they owe at least the minimum, their oldest unpaid bill
  (FIFO, the same ageing as the Dues screen) is at least **N days** old, they have a 10-digit mobile number, the customer's **No
  reminders** switch is off, and nobody reminded them (on either phone) in the last **M days**. "Skip today" hides one for the day.
  Defaults: N 15, M 7, minimum ₹100.
- **Schema v7:** `parties.reminders_off` and an append-only `reminders` table (who, SMS or WhatsApp, amount, oldest date, when, which
  phone). Both sync, so the second phone never reminds the same customer again within M days.
- **WhatsApp:** Dues, bell icon (or the Home note "N customers are due for a payment reminder") lists who is due; tap WhatsApp and the
  chat opens with the message typed; the person presses Send and the reminder is recorded.
- **Automatic SMS:** on the one phone where "Send SMS automatically from this phone" is switched on, once a day after the chosen hour
  (default 11 AM), the daily background job texts everyone due from the phone's own SIM: at most 25 a day, 3 seconds apart, each one
  recorded; a notification tells the owner how many went out. "Send today's SMS now" and "Send a test SMS" are in the settings. Sending
  uses our own small plugin (`packages/shop_sms`, Android SmsManager, send only, never reads SMS); SEND_SMS is asked for once.
- **Message** in the shop's bill language, dates with English months, with the UPI pay link for the amount when a UPI ID is set:
  "Namaskar Ramesh, ₹12,580.00 is due at Pravin Electricals since 1 Nov 2026. Please pay when convenient: upi://... Thank you." /
  "नमस्कार Ramesh, Pravin Electricals कडे 1 Nov 2026 पासून ₹12,580.00 बाकी आहे. सोयीनुसार भरावे: upi://... धन्यवाद."
- **Settings, Payment reminders** (owner): on/off, N, M, minimum, the SMS part, and a message preview. Every reminder is in the activity log.

## Tests
- `test/reminders/reminder_rules_test.dart`: N days, every M days, switched-off customer, no mobile, landline, small amount, paid and
  part-paid customers, skip today, message text in both languages with UPI link, recording and audit.
- `test/reminders/reminder_sms_test.dart`: before the hour, once a day, off for the shop or this phone, no permission, failed SMS not
  recorded, 25-a-day cap, send now.
- `test/reminders/reminder_screens_test.dart`: WhatsApp tap opens the text and records it, skip today, reminders off, the customer switch, settings.
- `test/db/migration_test.dart` v6 to v7; screen sizes in English and Marathi for both new screens.

## Limits
- WhatsApp needs a tap per customer (Android and WhatsApp do not allow apps to send for you without a paid business service).
- SMS costs follow the SIM plan; Android may still ask the owner to allow many SMS on some phones.
- SMS goes out when the phone runs its background job (usually within the hour after the set time; later if the phone is in deep sleep).
