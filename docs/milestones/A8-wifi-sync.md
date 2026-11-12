# A8: Shop Wi-Fi sync between two phones (no server)

## Purpose
In a rush, a second phone bills at the same time as the first. Both phones must show the same bills, stock, dues and reports.
The owner does not want a paid server or to see the shop from home, so the phones talk to each other directly over the shop's
Wi-Fi. Nothing leaves the shop.

## What was built
- **Schema v6.** `outbox` gains `origin_device_id`, `seq` (1, 2, 3... per phone) and `changed_at_ms`, with a unique index on
  (origin, seq). Two phone-only tables: `sync_peers` (the other phone's address, last sync, how much of this phone's changes it has)
  and `sync_state` (the shop key, the one-time pairing token). Purchases lose the unique supplier-bill key (now an index) so a copy
  from the other phone can be stored and flagged. Outbox rows from before v6 are claimed by this phone, oldest first.
- **Which phone am I.** The phone's own device id lives in `this_device.txt` next to the app's private files, never in the database,
  so a backup or a copy from the other phone never changes it. A one-phone shop is phone A automatically. If the data holds several
  phones and this phone cannot tell which it is (a backup restored on a new phone), the app asks: "replace phone A" or "this is a new
  phone" (next free letter). New installs call phone A "Owner phone".
- **Sync engine** (`lib/core/sync/sync_engine.dart`, no network). Reads changes the other phone does not have (in storage order, so
  an item always arrives before the bill that sells it), and applies a batch in one transaction.
- **Transport** (`sync_transport.dart`, `sync_crypto.dart`). A small HTTP server in the app on port 47821 while the app is open.
  Requests: hello, pull, nudge, join. Every request and reply is encrypted and signed with the 32-byte shop key (AES-256-GCM), bound
  to its request name and time-stamped (older than 10 minutes is refused).
- **Finding the other phone** (`peer_finder.dart`): Android network service discovery (`_peshop._tcp`), plus the last known address.
- **Sync service** (`sync_service.dart`): pulls from the other phone every 5 seconds and straight after it says it has news (a "nudge"
  sent 0.4 s after any local save). Runs only while the app is open; billing never waits for it.
- **Pairing.** Owner: Settings, Phones and Wi-Fi sync, Add a phone shows a QR (shop id, address, port, shop key, one-time token; 10
  minutes). New phone: first screen, Join a shop, scan. The owner's phone sends a verified copy made by the A6 backup code; the new
  phone installs it through the A6 restore path (safety copy kept), drops the owner phone's phone-only settings and peer list, adds
  itself as the next phone (B) and starts syncing. Users and PINs come with the copy, so staff log in with their own PIN.
- **Screens.** Phones and Wi-Fi sync (status, last sync, Sync now, clock warning, clashes in the last 7 days, add, rename, remove);
  a status dot on Home (hidden for a one-phone shop); Which phone is this; Join a shop.
- **Cancel purchase.** For a supplier bill entered by mistake (for example on both phones): stock goes back out as a purchase return,
  the supplier's account gets a reversing adjustment for the full total, the purchase is marked cancelled, audited; a counter user
  needs the owner's PIN. A cancelled supplier bill can be entered again.
- **Supplier bill entered twice** (same supplier and number, both standing): a warning on Home, an "Entered twice" badge in
  Purchases, and a Check my data note. Cancel the extra one.

## How it works
- A change is an outbox row: table, row id, the whole row as JSON, the phone that made it, its seq and the time in milliseconds.
- Each phone keeps, for every phone, the highest seq it has (its cursor). Pull = "send me what comes after A:120, B:37".
- Applying a change:
  - a change already here (same origin and seq) does nothing;
  - a new row is inserted;
  - an existing row keeps the newer version: a later change from the same phone always wins; otherwise the later time wins; on an
    exact tie the higher device id wins. Every phone applies the same order, so both end with the same row whichever way the changes
    travel;
  - prices (item, tier, variant) and units (item, unit name) created separately on both phones for the same thing: the later one stays,
    the other is marked deleted (same rule on both phones, nothing extra is sent);
  - settings match by key, and phone-only keys (last backup, last data check, backup reminder, auto-lock, daily summary) never travel;
  - a version that loses is stored marked `superseded`, so the sequence has no holes;
  - a clash (this phone changed the row and the other phone had not seen that change) writes an audit row `sync_conflict` with both
    versions and which was kept.
- Bills, payments, stock movements and ledger entries are only ever added, so two phones never clash on them. Cancelling a bill
  or a purchase changes only its status and adds reversing rows.

## Rules
- The phones must be on the same Wi-Fi with the app open. Airplane mode with Wi-Fi on works; no internet is needed.
- Only `lib/core/sync/` may touch the network (enforced by a test). Android permissions: INTERNET (Android's name for any socket),
  network and Wi-Fi state, Wi-Fi multicast (for discovery). No location permission.
- A removed phone is refused (its bills stay). To use it again, add it again.
- Each phone has its own bill numbers (A-0001, B-0001) and credit notes (CN-A-0001, CN-B-0001).

## Tests
- `test/db/migration_test.dart`: v1 to v6 and v5 to v6 (outbox rows claimed in order, new writes continue the sequence).
- `test/sync/outbox_completeness_test.dart`: after a busy day (bills, edits, removals, a cancel), every row of every table equals
  its newest outbox payload, and the sequence strictly increases.
- `test/sync/device_identity_test.dart`: new install is A; second phone is B; ambiguous data asks; file store.
- `test/sync/sync_engine_test.dart`: two in-memory phones: full copy, bills on both, price edited on both (later wins, clash logged),
  edits at the same moment in both orders, an edit after sync is not a clash, same batch twice, cancel across phones, duplicate
  supplier bill, phone-only settings, paged catch-up, a batch with an unknown table refused whole. Every scenario ends with both
  phones row-for-row identical and passing Check my data.
- `test/sync/transport_test.dart`: two real servers on 127.0.0.1: join with the invite, sync both ways, the nudge, one-time and
  expiring codes, wrong key, changed message, a message replayed as another request, removed phone, the other phone away and back.
- `test/db/cancel_purchase_test.dart`, `test/features/cancel_purchase_screen_test.dart`, `test/features/sync_screens_test.dart`,
  screen-size tests for Phones and Join a shop.

## Decisions
See `docs/decisions.md`, "A8 decisions".

## Limits
- Sync runs only while the app is open on both phones (Android stops apps in the background). A phone catches up when it is opened.
- "Latest change wins" uses the phones' clocks; the Phones screen warns when they differ by 2 minutes or more. Keep automatic date and time on.
- Some routers block phones from talking to each other ("client isolation" or "AP isolation"). It must be off for the shop Wi-Fi.
- A shop name edited on the other phone shows after the app is reopened (bills already use the name saved on them).
- Tested with two phones; a third phone should work (changes are relayed) but is not tested.
- No remote viewing and no cloud backup (by the owner's choice). Backups are still made by hand on either phone.
