# A6: Local backup and restore

**Status:** done (2026-11-12). Tests: 348 passing, `flutter analyze` clean.
Phone check on the owner's Samsung SM A356E: back up, uninstall, reinstall, restore at the first-run screen, log in with the old PIN.
Commits: `50c4a9c` (engines), `a48fe42` (screens, first-run restore, banner, reminder).

## Purpose
All shop data lives in one file on one phone. A backup the owner sends to their own email or Drive, and a restore that works on a
brand-new install, mean a lost, broken or wiped phone no longer loses the shop.

## What people can do (owner only)
- **Settings, Backup, Back up now:** makes a copy of everything, checks it, and opens the share sheet (email, Drive, WhatsApp).
  Shows when the last backup was made. The screen says the file holds all bills, customers and PINs, so send it only to yourself.
- **Restore from a backup:** pick a file, see what it contains (shop, bills, customers, items, last bill), confirm, and the app
  replaces everything on the phone and starts over. Log in with the PIN from that backup.
- **Fresh install:** the first-run "Set the owner PIN" screen has **Restore from a backup instead**.
- **Undo last restore:** the data that was replaced is kept (three newest copies); one tap puts it back.
- **Reminder:** a yellow banner on the owner's home screen and a daily notification (about 10 AM) when there is shop data and the last
  backup is more than 3 days old, or there never was one. Switch on or off in Settings. "Send a test reminder now" tries it.
  Restoring counts as a backup made now.

## How it works
- `core/backup/backup_service.dart`: `createBackup()` uses SQLite `VACUUM INTO` for a clean snapshot while the app runs, then verifies the
  copy: integrity check, row counts of every table, and sums of stock, ledger, bills, bill lines and purchases against the live data
  (retries once if a bill was saved meanwhile). A copy that fails is deleted and never offered.
- `BackupInspector` reads a file with plain SQLite (read only, no upgrades) and says in plain words why it cannot be used: empty, not
  SQLite, another app's database, damaged, or made by a newer version of the app.
- `core/backup/restore_service.dart`: `replaceWith()` checks the file, keeps `before_restore_<time>.sqlite`, stages the backup next to
  the live file, re-checks the staged copy, deletes the live file and WAL/SHM leftovers, renames the staged file in. Any failure puts the old
  data back. Safety copy names are never overwritten (found by a test: Undo within the same second).
- `finishRestore()` (after reopening, which upgrades older backups): records the restore as a backup made now and writes an audit entry.
- `core/backup/database_location.dart`: one place for the database path, so opening, backing up and restoring agree. Tests use a temp folder.
- `AppRoot` (`lib/app.dart`) can restart the whole app on a fresh database connection; that is how a restore takes effect.
- Android: `MainActivity.kt` `shareFile` channel (only files inside the app's `backups` folder, via FileProvider).
- Reminder: WorkManager daily `backupCheck` task (opens the database itself, never creates a shop, honours the setting), `backup_reminder_rules.dart`.

## Rules
- Backup file: `PravinElectricals_backup_YYYY-MM-DD_HHMM.sqlite`, plain (owner's choice: no password). The temporary copy in the app is deleted on the next backup.
- Restore replaces everything, owner only, and always keeps a way back. A backup newer than the app is refused.
- Use one phone for billing at a time: a restored copy keeps the same bill-number series.

## Tests
Backup verification (matching data, damaged copy caught with what differs, empty shop, repeated backups, other files left alone); inspector
(missing, empty, text, other app's SQLite, newer version, cut-short file); **fresh-install restore reproduces every row of every table, balances,
dues, ageing, invoices, stock, PIN logins and settings**; restore from a v3 backup upgrades to v4; bad restores leave the live file untouched;
safety copies, undo, keeping three, restoring twice, WAL leftovers removed; settings screen (back up, share failure, reminder switch, restore
summary, cancel, bad and newer files, undo); 3-day rule and wording; home banner (never, overdue, recent, off, new shop, counter); and the whole
path through the real app root: fresh install, restore at the first-run screen, lock screen lists the restored users, the owner PIN opens the same shop.

## Known limits
- Backups are manual (the owner sends the file); no automatic cloud upload until Stage B.
- The file is not encrypted; a password can be added later without changing the format.
- Restoring on two phones at the same time is unsupported (duplicate bill numbers).
- The reminder notification needs notification permission and can be delayed by battery saving; the home banner is the dependable reminder.
- Out-of-space during backup or restore is handled with a clear message but only proven by reading the code, not by a test.
