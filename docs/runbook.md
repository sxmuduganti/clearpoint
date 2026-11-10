# Operations Runbook

## Schedule

| Job        | When                                   | Depends on                          |
|------------|----------------------------------------|-------------------------------------|
| `CPNIGHT`  | Nightly, after acquirer file arrives    | `CP.PROD.TRANIN(0)` cataloged, `DATECARD` rolled |
| `CPRESTRT` | On demand                              | Failure in `POST` or any later step |
| `CPLOAD`   | One-time conversion / disaster recovery | `CPDEFINE`                          |

Before `CPNIGHT` starts, the scheduler must:

1. Update `CP.PROD.PARMLIB(DATECARD)` to the new business date.
2. Close `CPACCT` in every CICS region:
   `CEMT SET FILE(CPACCT) CLOSED DISABLED`.

After `ARCHIVE` completes, reopen with
`CEMT SET FILE(CPACCT) OPEN ENABLED`.

## Step reference

| Step      | Program   | RC 0          | RC 4                    | RC 12 / 16                         |
|-----------|-----------|---------------|-------------------------|------------------------------------|
| CLEANUP   | IDCAMS    | normal        | n/a (MAXCC reset)       | catalog problem                    |
| FEEUNL    | CPFEEUNL  | normal        | n/a                     | DB2 error or overlapping fee rows  |
| VALID     | CPVALID   | no rejects    | rejects written         | header/trailer/control card error  |
| ENRICH    | CPENRICH  | no rejects    | rejects written         | VSAM error on CARDXREF / MERCHMST  |
| SORTENR   | DFSORT    | normal        | n/a                     | sort failure                       |
| REJSUM    | ICETOOL   | normal        | n/a                     | informational only                 |
| DELPOST   | IDCAMS    | normal        | n/a (MAXCC reset)       | catalog problem                    |
| POST      | CPPOST    | no suspense   | suspense written        | run-control, sequence or VSAM error |
| FEECALC   | CPFEECAL  | normal        | n/a                     | fee table invalid or unresolved fee |
| SORTFEE   | DFSORT    | normal        | n/a                     | sort failure                       |
| SETTLE    | CPSETTLE  | normal        | n/a                     | input out of sequence              |
| RECON     | CPRECON   | in balance    | n/a                     | 12 out of balance, 16 missing data |
| REPORT    | CPRPT     | normal        | n/a                     | settlement file invalid            |
| ARCHIVE   | IDCAMS    | normal        | n/a                     | GDG allocation problem             |

RC 4 is expected on most nights and does not stop the cycle. Any RC
above 4 bypasses all later steps and triggers the `ALERT` step, which
notifies operations.

Every program reports a failure the same way through `CPABEND`:

```
************************************************************************
CLEARPOINT PROCESSING TERMINATED
  PROGRAM     : CPPOST
  PARAGRAPH   : 1510-START-NORMAL-RUN
  TIMESTAMP   : 20261109 021544
  REASON      : PRIOR RUN INCOMPLETE - USE MODE=RESTART
  RETURN CODE :   16
************************************************************************
```

## Recovery procedures

### Failure in CLEANUP through REJSUM

Nothing has touched the account master. Fix the cause and resubmit
`CPNIGHT` from the top. `CLEANUP` removes any work datasets the failed
run left behind.

### Failure in POST

1. Read the `CPPOST` SYSOUT. The run-control record is still
   `RUNNING`; this is expected.
2. Fix the cause (for example, a VSAM space problem on `ACCTMAST`).
3. Submit `CPRESTRT`. It restarts at `DELPOST` with
   `POSTMODE=POSTRSTR`, which supplies `MODE=RESTART` to `CPPOST`.
4. Confirm the SYSOUT shows `CHECKPOINT POSITION VERIFIED` and a
   non-zero `PREVIOUSLY APPLIED` count.

Do **not** resubmit `CPNIGHT`. `CPPOST` refuses a normal run while the
previous run is incomplete. The input to a restart must be the same
`WORK.ENRSORT` the failed run read. If it was lost, call the on-call
developer rather than rebuilding it: the checkpoint key check will
reject a regenerated file whose order differs.

### Failure in FEECALC through ARCHIVE

Posting is complete and marked `COMPLETE`. Submit `CPRESTRT` with the
job card `RESTART=` changed to the failing step (for example,
`RESTART=NIGHTLY.FEECALC`). Do not restart at `DELPOST`, because
`CPPOST` will refuse to post the same business date twice.

### RECON out of balance (RC 12)

No generation datasets have been created, and nothing has been sent
downstream. The `RECONRPT` dataset and the `RECON` SYSOUT show which
rule failed. A failure between two adjacent steps points to the step
in between (or the sort between them). Escalate to the on-call
developer; do not force the cycle.

## Business date rules

* `BUSDATE` must be a valid calendar date and must match the header of
  `TRANIN(0)`.
* Transactions dated after the business date, or more than 30 days
  before it, are rejected (`V010`, `V011`).
* `CPPOST` refuses a business date earlier than the last completed
  posting date.

## Reason codes

| Code | Step     | Meaning                                    |
|------|----------|--------------------------------------------|
| V001 | CPVALID  | Transaction id is blank                    |
| V002 | CPVALID  | Card number is not numeric                 |
| V003 | CPVALID  | Card number fails Luhn check digit         |
| V004 | CPVALID  | Merchant id is blank                       |
| V005 | CPVALID  | Amount is not numeric                      |
| V006 | CPVALID  | Amount is zero                             |
| V007 | CPVALID  | Amount exceeds single item limit (50,000)  |
| V008 | CPVALID  | Currency not supported                     |
| V009 | CPVALID  | Transaction date invalid                   |
| V010 | CPVALID  | Transaction date after business date       |
| V011 | CPVALID  | Outside 30 day presentment window          |
| V012 | CPVALID  | Transaction time invalid                   |
| V013 | CPVALID  | Transaction type invalid                   |
| V014 | CPVALID  | POS entry mode invalid                     |
| V015 | CPVALID  | Card network invalid                       |
| V016 | CPVALID  | Authorization code missing                 |
| E001 | CPENRICH | Card not on cross reference                |
| E002 | CPENRICH | Card reported lost or stolen               |
| E003 | CPENRICH | Card closed                                |
| E004 | CPENRICH | Card expired at transaction date           |
| E005 | CPENRICH | Merchant not on master                     |
| E006 | CPENRICH | Merchant terminated                        |
| S001 | CPPOST   | Account not on master                      |
| S002 | CPPOST   | Account closed                             |
| S003 | CPPOST   | Account charged off                        |
| S004 | CPPOST   | Debit to frozen account                    |
| S005 | CPPOST   | Duplicate transaction                      |
