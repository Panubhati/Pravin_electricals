# A12: Sync while the app is closed, fingerprint unlock

## Purpose
- **Sync while the app is closed.** A8 sync only ran while the app was open on both phones at once. Bills made on one phone stayed there until both apps happened to be open together. Now each phone keeps a quiet listener running, and the phone that makes a change sends it straight away.
- **Fingerprint unlock.** People can unlock with a fingerprint instead of typing their PIN every time.
- **Stale stock warning.** When the other phone has not synced for a while, the bill warns on low-stock items, so the same last piece is not sold twice.

## How it works
**Background sync**
- **One engine.** The app's one Flutter engine is cached (`ShopEngine.kt`), and the screen reuses it (`MainActivity` uses the cached engine and does not destroy it). Sync starts from the provider container (`SyncHost`), not from a screen, so it keeps running with no screen.
- **The service.** `ShopSyncService.kt` is an Android foreground service (type `specialUse` on Android 14+, which has no daily time limit; our APK is not on the Play Store).
  - It shows a quiet "Shop sync on · Last synced 10:42" notification.
  - It holds a Wi-Fi lock.
  - It wakes the app about every 2 minutes for a safety check. Android may space this out in deep sleep.
  - It starts again after a phone restart or an app update (`BootReceiver.kt`).
- **Sending changes.** A change is still sent within a second: the phone that saves it calls the other phone, which pulls at once (A8's nudge). The 2-minute check only catches anything missed.
- **When it runs.** `BackgroundSyncKeeper` runs the service only while this phone is paired and **Keep syncing when the app is closed** is on. The switch is on the Phones screen, per phone, and on by default.
- **Battery.** The Phones screen warns when Android's battery saver may stop sync, and has an **Allow** button that opens Android's own question.
- **Pace.** On screen the phone checks every 5 seconds; in the background, every 2 minutes.
- **Swapping data.** Restore and joining a shop stop sync before the database file is swapped.
- **Lock.** Because the engine now outlives the screen, the app locks at once when it is closed (swiped away). Nobody reopens it still logged in.

**Fingerprint unlock**
- **Per person, per phone.** After a PIN login on a phone with a saved finger, the app asks once: "Unlock with fingerprint next time?". The owner can also use **Settings, Fingerprint unlock**: it lists everyone, and switching someone on needs their PIN, then their finger.
- **Lock screen.** Choose your name, and the fingerprint prompt opens by itself. **Use fingerprint** tries again. The PIN always works.
- **Biometric only.** The phone's own PIN or pattern does not count.
- **Tied to the PIN.** Each switch-on is tied to that person's current PIN (a short tag of the stored hash, kept as a phone-only setting). If the PIN changes on either phone, or the owner resets it, fingerprint switches off for that person until they turn it on again. Removed people are no longer on the lock screen.
- **Approvals.** Owner approvals and owner PIN recovery are unchanged and stay PIN only.

**Stale stock warning**
- A bill line shows "Other phone last synced 45 min ago; stock may be different." when all of these are true:
  - this phone is paired,
  - the last sync with the other phone is over 30 minutes ago, and
  - the stock left after the bill is at or below the item's minimum stock (0 when none is set).
- It never blocks the bill.

## Settings
These settings are phone-only and never synced: `background_sync_on`, `fingerprint_users`, `fingerprint_offered`.

## Tests
- `test/sync/background_sync_test.dart`: sync starts with no screen; a phone that is not paired does not start it; a stopped host does not start it; pace changes on pause and resume; the app locks when closed.
- `test/sync/background_keeper_test.dart`: the service runs only when paired; the switch turns it off and on; the 2-minute check runs a sync; notification text; Phones screen switch and battery warning.
- `test/features/fingerprint_test.dart`: on, off, and switched off by a PIN change; unlock without the PIN; a finger that does not match falls back to the PIN; per person; the one-time offer; a phone with no finger saved; the Settings screen needs the PIN and the finger.
- `test/features/stale_stock_warning_test.dart`: warns, plenty of stock, recent sync, one phone alone.
- The Fingerprint unlock screen is in the screen-size tests (English and Marathi).

## Limits (to check on the phones)
- **The Android parts can't be tested on the laptop.** The service, the Wi-Fi lock, the boot start and the battery question have to be checked on the phones.
- **Phone makers can still stop the service.** Samsung and Xiaomi may do so when battery is not "Unrestricted".
- **When nothing can sync:**
  - a phone is switched off,
  - a phone is away from the shop Wi-Fi, or
  - the app was force-stopped.
  Nothing is lost; it syncs when both phones are back on the Wi-Fi.
- **Battery use** must be measured on the owner phone over a day and noted here.
- **Fingerprint can't tell people apart.** Any finger saved in the phone's settings opens the app as a person who switched fingerprint on there. The app says this when someone switches it on.
