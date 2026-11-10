       01  INT-PARMS.
           05  INT-NETWORK                 PIC X(4).
           05  INT-PRODUCT                 PIC X(4).
           05  INT-MCC-CLASS               PIC X(2).
           05  INT-PRESENCE                PIC X.
           05  INT-DR-CR                   PIC X.
               88  INT-DEBIT               VALUE 'D'.
               88  INT-CREDIT              VALUE 'C'.
           05  INT-AMOUNT                  PIC 9(9)V99 COMP-3.
           05  INT-RATE                    PIC 9V9(4) COMP-3.
           05  INT-PER-ITEM                PIC 9(3)V99 COMP-3.
           05  INT-FEE                     PIC S9(7)V99 COMP-3.
           05  INT-MATCHED-KEY             PIC X(11).
           05  INT-MATCH-LEVEL             PIC 9.
               88  INT-NOT-FOUND           VALUE 0.
               88  INT-EXACT-MATCH         VALUE 1.
               88  INT-DEFAULTED           VALUE 2 THRU 6.
               88  INT-NETWORK-DEFAULT     VALUE 6.
