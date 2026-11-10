       01  ENR-RECORD.
           05  ENR-CORE.
           COPY CPTRNCOR REPLACING ==:PFX:== BY ==ENR==.
           05  ENR-ACCT-NUM                PIC X(12).
           05  ENR-MCC                     PIC 9(4).
           05  ENR-MERCH-NAME              PIC X(25).
           05  ENR-MERCH-COUNTRY           PIC X(3).
           05  ENR-MCC-CLASS               PIC X(2).
           05  ENR-PRESENCE                PIC X.
               88  ENR-PRESENT             VALUE 'P'.
               88  ENR-NOT-PRESENT         VALUE 'N'.
           05  ENR-DR-CR                   PIC X.
               88  ENR-DEBIT               VALUE 'D'.
               88  ENR-CREDIT              VALUE 'C'.
           05  FILLER                      PIC X(63).
