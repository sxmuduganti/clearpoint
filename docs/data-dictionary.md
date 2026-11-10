# Data Dictionary

All positions are 1-based. `S` fields in sequential files are
`SIGN LEADING SEPARATE`; `P` fields are `COMP-3`.

## Daily transaction file: `CPTRNREC` (TRANIN, LRECL 150)

| Pos | Len | Field            | Notes                                  |
|-----|-----|------------------|----------------------------------------|
| 1   | 1   | Record type      | `H` header, `D` detail, `T` trailer    |

**Header**

| Pos | Len | Field          | Notes                    |
|-----|-----|----------------|--------------------------|
| 2   | 8   | File id        | `CPTRAN`                 |
| 10  | 8   | Business date  | CCYYMMDD                 |
| 18  | 8   | Source         | Acquirer gateway id      |

**Detail** (`CPTRNCOR`, prefix `TRN`)

| Pos | Len | Field          | Notes                               |
|-----|-----|----------------|-------------------------------------|
| 2   | 16  | Transaction id |                                     |
| 18  | 16  | Card number    | Luhn validated                      |
| 34  | 15  | Merchant id    |                                     |
| 49  | 2   | Type           | `PU` `RF` `CA` `RV`                 |
| 51  | 11  | Amount         | 9(9)V99                             |
| 62  | 3   | Currency       | `USD`                               |
| 65  | 8   | Date           | CCYYMMDD                            |
| 73  | 6   | Time           | HHMMSS                              |
| 79  | 6   | Auth code      | required for `PU`, `CA`             |
| 85  | 2   | Entry mode     | `01` keyed `05` chip `07` contactless `81` e-commerce |
| 87  | 4   | Network        | `VISA` `MCRD` `AMEX` `DISC`         |

**Trailer**

| Pos | Len | Field        | Notes                          |
|-----|-----|--------------|--------------------------------|
| 2   | 9   | Record count | detail records                 |
| 11  | 15  | Hash total   | sum of detail amounts, 9(13)V99 |

## Enriched transaction: `CPENRREC` (LRECL 200)

| Pos | Len | Field           | Notes                                  |
|-----|-----|-----------------|----------------------------------------|
| 1   | 89  | Transaction core| `CPTRNCOR`, prefix `ENR`               |
| 90  | 12  | Account number  | from card cross reference              |
| 102 | 4   | MCC             | from merchant master                   |
| 106 | 25  | Merchant name   |                                        |
| 131 | 3   | Merchant country|                                        |
| 134 | 2   | MCC class       | `SM` `FU` `TR` `RS` `UT` `CA` `GN`     |
| 136 | 1   | Presence        | `P` card present, `N` not present      |
| 137 | 1   | Debit/credit    | `D` / `C`                              |

Sort for posting: `90,12,CH,A,64,8,CH,A,72,6,CH,A,1,16,CH,A`.

## Posted transaction: `CPPSTREC` (LRECL 250)

| Pos | Len | Field         | Notes                                      |
|-----|-----|---------------|--------------------------------------------|
| 1   | 200 | Enriched data | `CPENRREC`                                 |
| 201 | 4   | Product       | from account master                        |
| 205 | 8   | Post date     | business date                              |
| 213 | 12  | New balance   | S9(9)V99                                   |
| 225 | 1   | Overlimit     | `Y` / `N`                                  |
| 226 | 1   | Post status   | `P` applied, `R` previously applied (restart) |

## Fee detail: `CPFEEDTL` (LRECL 150)

| Pos | Len | Field          | Notes                         |
|-----|-----|----------------|-------------------------------|
| 1   | 16  | Transaction id |                               |
| 17  | 12  | Account        |                               |
| 29  | 4   | Network        | sort key 1                    |
| 33  | 4   | Product        |                               |
| 37  | 2   | MCC class      | sort key 2                    |
| 39  | 1   | Presence       |                               |
| 40  | 2   | Type           |                               |
| 42  | 1   | Debit/credit   |                               |
| 43  | 11  | Amount         | 9(9)V99                       |
| 54  | 5   | Rate           | 9V9(4)                        |
| 59  | 5   | Per item       | 9(3)V99                       |
| 64  | 10  | Interchange    | S9(7)V99                      |
| 74  | 14  | Net amount     | S9(11)V99                     |
| 88  | 11  | Schedule key   | entry that priced the item    |
| 99  | 1   | Match level    | 1 exact … 6 network default   |
| 100 | 8   | Business date  |                               |

## Settlement: `CPSTLREC` (LRECL 150)

| Pos | Len | Field          | Notes                                      |
|-----|-----|----------------|--------------------------------------------|
| 1   | 1   | Record type    | `C` category, `N` network total, `G` grand |
| 2   | 8   | Business date  |                                            |
| 10  | 4   | Network        |                                            |
| 14  | 2   | MCC class      |                                            |
| 16  | 9   | Debit count    |                                            |
| 25  | 15  | Debit amount   | 9(13)V99                                   |
| 40  | 9   | Credit count   |                                            |
| 49  | 15  | Credit amount  | 9(13)V99                                   |
| 64  | 14  | Interchange    | S9(11)V99                                  |
| 78  | 16  | Net settlement | S9(13)V99, due to network                  |

## Control totals: `CPCTLREC` (LRECL 120)

| Pos | Len | Field        |
|-----|-----|--------------|
| 1   | 8   | Step         |
| 9   | 8   | Business date|
| 17  | 9   | In count     |
| 26  | 15  | In amount    |
| 41  | 9   | Out count    |
| 50  | 15  | Out amount   |
| 65  | 9   | Reject count |
| 74  | 15  | Reject amount|
| 89  | 8   | Run date     |
| 97  | 6   | Run time     |

## Account master: `CPACCREC` (VSAM KSDS, LRECL 200)

Key: positions 1-12. Alternate index on customer id (13-22, non-unique)
via path `CP.PROD.ACCTMAST.CUSTPATH`.

| Pos | Len | Field              | Pic                 |
|-----|-----|--------------------|---------------------|
| 1   | 12  | Account number     | X(12)               |
| 13  | 10  | Customer id        | X(10)               |
| 23  | 4   | Product            | `PLAT` `GOLD` `CLSC`|
| 27  | 1   | Status             | `A` `C` `F` `W`     |
| 28  | 8   | Open date          | 9(8)                |
| 36  | 6   | Credit limit       | P S9(9)V99          |
| 42  | 6   | Cash limit         | P S9(9)V99          |
| 48  | 6   | Current balance    | P S9(9)V99          |
| 54  | 6   | Cash balance       | P S9(9)V99          |
| 60  | 6   | Cycle purchases    | P S9(9)V99          |
| 66  | 6   | Cycle credits      | P S9(9)V99          |
| 72  | 4   | Cycle txn count    | P S9(7)             |
| 76  | 8   | Last post date     | 9(8)                |
| 84  | 8   | HWM business date  | 9(8)                |
| 92  | 30  | HWM key            | date + time + tran id |
| 122 | 8   | Last maint date    | 9(8)                |
| 130 | 8   | Last maint user    | X(8)                |

## Run control: `CPRSTREC` (VSAM KSDS, LRECL 100)

| Pos | Len | Field            | Notes                       |
|-----|-----|------------------|-----------------------------|
| 1   | 8   | Program          | key                         |
| 9   | 1   | Status           | `R` running, `C` complete   |
| 10  | 8   | Business date    |                             |
| 18  | 14  | Start timestamp  |                             |
| 32  | 14  | Checkpoint timestamp |                         |
| 46  | 9   | Records processed| at last checkpoint          |
| 55  | 42  | Last key         | account + date + time + id  |
| 97  | 3   | Run count        | 1 + number of restarts      |

## DB2 tables

See `src/ddl/CPTABLES.sql`.

| Table             | Purpose                                         |
|-------------------|-------------------------------------------------|
| `CP_FEE_SCHEDULE` | Effective-dated interchange rates               |
| `CP_ADJUSTMENT`   | Maker/checker balance adjustments               |
| `CP_AUDIT_LOG`    | Every online change with before/after balance   |
