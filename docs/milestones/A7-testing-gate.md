# A7: Testing gate

**Status:** tools and automated checks done, and the owner reports all phone checks passed (2026-11-12). 604 tests pass, `flutter analyze` is clean.
**Not yet closed:** the owner's week of parallel use beside paper billing. A7 is ticked in `AGENTS.md` only when that week passes
(see `docs/stage-a-exit.md`). The phone speed times were not sent back, so only the owner's "passed" is recorded for the phone.
Commits: `2c8b5d5` (Check my data, demo shop, speed check), `e2cb7c9` (failure tests, layouts), `039fcd2` (returns and cancel),
`77fa008` (Day check, stock spot check).

## Purpose
Prove the shop's numbers can be trusted before anything runs unattended (photo scan) or goes to the cloud, and fix the gaps found on the way.

## What was built

### Check my data (Settings, owner only)
20 read-only checks, each one SQL query that returns only the rows that are wrong. It never fixes anything. Findings are
**problems** (numbers that must agree do not) or **notes** (odd but possible: negative stock, a bill dated in the future, a missing bill number).
- Bills: total = subtotal - discount + round-off; header agrees with its lines and payments; each line = quantity x rate (half up) and its GST;
  the credit part is in the customer's account exactly once; no repeated numbers.
- Stock: every sale, purchase and return line has exactly its stock movement; movement directions; negative stock (note).
- Accounts: every entry points at a real bill, purchase or credit note; signs fit the entry type; purchases are in the supplier's account.
- Credit notes: totals, refund split, GST, nothing returned that was not sold, cancelled bills fully returned, refunds to accounts in the ledger.
- Items, users (one owner), SQLite's own integrity and foreign-key checks.

It runs from Settings, **before every backup** (warns, still lets you back up) and **after every restore**. A failed check puts a note on the owner's home screen.
Each check is proven by a test that damages exactly that rule and expects exactly that finding, and stays quiet on healthy data.

### Sales return and cancel bill (schema v5)
Open a bill in Bills: **Return items** (any quantity of any line, in the unit it was sold in) or **Cancel bill**. The original bill is never edited.
A credit note `CN-A-0001` is created, stock goes back where it came from, and the money goes back as cash, UPI, or off what the customer owes
(a customer with nothing owing ends up with an advance). Refunds follow the cumulative quantity, so returning a line in pieces always adds up to exactly what it sold for;
the bill's round-off is refunded with the return that finishes the bill. A cancel refunds the way the bill was paid and marks the bill cancelled.
A counter user must have the owner type their PIN; both people are recorded in the audit log. Credit notes can be shared as a PDF or on WhatsApp.
Reports follow: net sales, cash in hand (cash handed back), item profit (returned sales and cost taken off), Check my data, and the Bills list badges.

### Day check (Reports, owner only)
For any day: bills and net sales, returns and cancels, how customers paid (cash, UPI, credit), money collected against old dues, purchases and supplier payments,
cash in hand, **Share summary** as plain text, and a **Stock spot check** (count a few items, compare with the app, apply only if you choose).
This is the screen for the evening comparison with the paper book.

### Speed
A deterministic demo shop (400 items, 200 customers, 12 suppliers, about 1,200 bills over 30 days, weekly purchases, payments) built through the real repositories.
`SpeedCheck` times the screens and actions (the bill save is timed and rolled back, so nothing changes). It runs in automated tests and on the phone
(Home, **Speed test tools (debug)**; loading the demo shop is refused unless a backup was made in the last hour).

Laptop numbers on the demo shop (the test limit is half the phone target):

| Operation | Laptop | Phone target |
|---|---|---|
| Item search (5 words) | 7 ms | 200 ms |
| Item search (barcode) | 0 ms | 100 ms |
| Items screen | 18 ms | 1,000 ms |
| Stock screen | 27 ms | 1,000 ms |
| Dues: customers / suppliers | 15 / 1 ms | 1,000 ms |
| Bills list | 18 ms | 1,000 ms |
| Home summary | 61 ms | 1,000 ms |
| Daily sales report | 6 ms | 1,000 ms |
| Item profit (month) | 149 ms | 1,000 ms |
| Stock value | 29 ms | 1,000 ms |
| Save one bill | 5 ms | 400 ms |
| Check my data (about 8,800 records) | 196 ms (was 1,600 ms) | 5,000 ms |
| Make a backup | 179 ms | 5,000 ms |

The only slow query found was in Check my data (joining two big grouped lists); it was rewritten as one pass and is eight times faster.
On the phone the owner reported the speed check passed; the individual times were not recorded.

### Failures
Tested on a real file database: a bill, purchase, payment and return are each made to fail at every step (a trigger refuses the n-th write of each table);
a killed app (a half-written bill in a hot journal is rolled back on reopen); a full disk (real SQLite "disk is full"); a backup that cannot be written;
wrong clocks (back and forward: bill numbers stay unique and rising, future dates are a note, ageing copes, the backup reminder distrusts a future date).
After each, nothing is half-saved and Check my data passes. Storage errors now give plain messages ("The phone is out of storage space... Nothing was saved.").
Layouts: every main screen at a small phone (360x640), sideways and 160% text. This found and fixed seven overflows (Home tiles, Dues, Home summary, Daily sales date row,
Bill detail rows, New bill title bar, Pay sheet). A source scan proves no code uses the network and the manifest has no internet permission.

## Rules
- Posted bills are never edited; a cancel only sets the bill's status.
- Returned quantity can never exceed what was sold; refunds add up to the credit note total.
- Reports count a return on the day it is made.

## Owner's part
1. Phone checks (Check my data on real data, speed check, return and cancel, Day check, airplane mode, killing the app, restore of the real backup): **reported passed by the owner**.
2. **A week of parallel use**: each evening open Day check, compare with the paper book, and write the result in the log in `docs/stage-a-exit.md`. This is what closes A7.

## Known limits
- No exchange flow (return, then a new bill) and no purchase return to suppliers.
- A cancel needs the bill to have had no returns; otherwise return the rest.
- Phone speed times were not recorded; laptop numbers are a guide only.
- Bills list is ordered by date, so a bill made while the clock was wrong may appear out of order (its number is still right).
