# Stage A exit checklist

Stage B (the cloud, photo scan on a server, sync) starts only when all five are true (AGENTS.md section 12).

| # | Criterion | Status (2026-11-12) |
|---|---|---|
| 1 | All automated tests and invariant checks pass | **Done**: 660 tests, `flutter analyze` clean, Check my data (22 checks) proven by corruption tests; owner reports the phone checks passed |
| 2 | A week of parallel use with no unexplained mismatch in sales, stock or dues | **Open**: owner to run (log below) |
| 3 | Backup and restore proven on a second phone | **Partly**: proven on the owner's phone by uninstalling, reinstalling and restoring (A6); a second physical phone is not yet tried |
| 4 | The owner confirms the screens and flows are what they need | **Open**: owner sign-off after the week |
| 5 | Open decisions in AGENTS.md section 15 that affect the schema are answered | **Open**: see below |

## Open decisions that may touch the schema
- Keep supplier invoice photos after posting (affects the photo feature's tables).
- Below-cost selling: block, or allow with owner approval (affects the bill rules).
- Thermal printer model and paper width (no printer yet; printing is A5b).

Answered already: quantity representation (integer millimetres), GST rounding (per line, half up), supplier bills are clean printed GST invoices, staff phones (any Android phone joins by QR with its own bill series, A8).

## How to run the parallel week (about 5 minutes a day)
1. Keep paper billing exactly as now. Also bill every sale in the app.
2. In the evening open **Reports, Day check** for today.
3. Put the app beside the paper book and compare, line by line: **bills**, **net sales**, **cash / UPI / credit**, **money collected from customers**, **purchases entered**, **cash in hand**.
4. Count 3 to 5 items on the shelf in **Stock spot check**. Do not Apply until you know why a number differs.
5. Write the result in the log. If anything differs, find the bill or payment that explains it (Bills, Dues, Day check on that day) before the next day. Tell your developer anything you cannot explain.
6. Once a week run **Settings, Check my data** and make a backup.
7. On days both phones bill (A8), let them sync first (green dot on Home, or Settings, Phones and Wi-Fi sync, Sync now), then do the Day check on either phone: it covers both. Write "2 phones" in the note column.

## Evening log (copy a row per day)

| Date | Paper: total sales | App: net sales | Difference | Paper: cash in hand | App: cash in hand | Difference | Stock items counted / matched | What explained any difference |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |

A week passes when every difference is explained (for example a bill forgotten in one place, fixed with a note) and nothing is unexplained for the last three days in a row.
