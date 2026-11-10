# Design Notes

The decisions below are the ones that matter most for running a
clearing cycle against a production account master. Each one comes
from a failure mode that a nightly batch system has to survive.

## 1. Restartable, idempotent posting

`CPPOST` is the only step that updates the account master in place,
so it's the only step where a rerun can do damage. Three mechanisms
work together.

**Per-account high-water mark.** Every account carries
`ACCT-HWM-BUS-DATE` and `ACCT-HWM-KEY` (transaction date + time + id).
The input is sorted by account, then date, time and id. If a
transaction's key is not greater than the account's high-water mark
for the same business date, it was already applied and is bypassed.
The balance and the high-water mark are written in the same `REWRITE`,
so they can never disagree.

**Rewrite on account break.** All activity for an account is applied
in storage and written once, when the account number changes. That
cuts master I/O to one read and one rewrite per active account
instead of one per transaction. It also means a failure part-way
through an account loses nothing: the balance and high-water mark on
disk are still from before that account was touched.

**Run-control record (`RSTCTL`).** A one-record-per-program VSAM file
records `RUNNING` / `COMPLETE`, the business date, and the last
checkpoint (records processed and sort key). It enforces three rules:

| Situation                                    | Behavior                       |
|----------------------------------------------|--------------------------------|
| Normal run, previous run still `RUNNING`     | Refused (RC 16): use `MODE=RESTART` |
| Normal run, business date already `COMPLETE` | Refused (RC 16): no double posting |
| Restart, input differs from checkpoint       | Refused (RC 16): wrong input file |

On restart the program re-reads from the top. It regenerates its
sequential outputs, verifies that the record at the checkpoint
position carries the checkpoint key, and lets the high-water mark skip
master updates that already happened. `scripts/test-restart.sh` proves
it in CI: it stops a run part-way through an account, resubmits
normally (refused), restarts, and compares the account master
byte-for-byte with an uninterrupted run.

## 2. Control totals at every hand-off

Every step writes one control record (`CPCTLREC`) with counts and
amounts in, out and rejected. `CPRECON` reads all five through a JCL
concatenation and proves:

* each step balances internally (in = out + rejected),
* each step received exactly what the previous step produced, which
  also proves the DFSORT steps dropped nothing,
* end to end: cycle input = settled + all rejects + all suspense.

The transaction file's own trailer (record count and hash total) is
checked by `CPVALID` before any downstream step runs.

## 3. Publish only when in balance

Intermediate datasets are `WORK` datasets. Generation data groups
(rejects, suspense, fee detail, settlement, reports) are created only
by the `REPORT` and `ARCHIVE` steps. Those steps are conditioned on
`CPRECON` returning 0, so an out-of-balance cycle never produces a
generation that a downstream system could pick up. A restart from
`DELPOST` reuses the same relative generation numbers because nothing
was catalogued by the failed run.

## 4. Defensive input handling

* Header business date must match the `BUSDATE` control card.
* Data after the trailer, a second header, or an unknown record type
  stops the run. These mean a corrupt file, not a bad transaction.
* Bad transactions are rejected individually with a reason code, so
  one bad record never stops the cycle.
* `CPPOST` and `CPSETTLE` verify their input sequence and abend rather
  than post or settle from unsorted data.
* `CPFEECAL` verifies the fee schedule is in strict ascending key
  order before relying on `SEARCH ALL`. It also checks that every
  network has a default rate, so no transaction can fall through
  unpriced.

## 5. Table-driven interchange

The fee schedule lives in DB2 (`CP_FEE_SCHEDULE`) with effective
dating. `CPFEEUNL` unloads the rows effective on the business date at
the start of the cycle, and `CPFEECAL` loads them into an
`OCCURS DEPENDING ON` table. `CPINTCH` resolves each transaction
through a six-level fallback using a binary search:

| Level | Product      | Category | Card present |
|-------|--------------|----------|--------------|
| 1     | exact        | exact    | exact        |
| 2     | exact        | exact    | any          |
| 3     | exact        | any      | any          |
| 4     | any (`****`) | exact    | exact        |
| 5     | any          | exact    | any          |
| 6     | any          | any      | any          |

The matched level is written to every fee detail record, so finance
can see which transactions were priced at a default rate.

## 6. Data representation

* Master files hold money as `COMP-3`, the natural format for VSAM and
  arithmetic.
* Interface files between steps use zoned decimal with
  `SIGN LEADING SEPARATE`. They stay readable in a browse, sort cleanly
  as `CH`, and carry no packed data across a platform boundary.
* All record layouts are copybooks. The transaction core is one
  copybook included with `REPLACING ==:PFX:==`, so the input, enriched
  and posted views of a transaction can't drift apart.

## 7. Separation of online and batch

CICS programs never update the master during the batch window. The
`CPACCT` file is closed to CICS before `POST` and reopened after
`ARCHIVE`, and `CPINQ`, `CPADJ` and `CPACCAPI` all handle `NOTOPEN` /
`DISABLED` with a clear message. Online adjustments use
maker/checker: the submitter is stored in DB2, the approver must be a
different user ID (enforced in the program and by a check constraint),
and the account `REWRITE`, the status update and the audit insert
commit or roll back together as one unit of work.
