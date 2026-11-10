       01  FEE-RECORD.
           05  FEE-TRAN-ID                 PIC X(16).
           05  FEE-ACCT-NUM                PIC X(12).
           05  FEE-NETWORK                 PIC X(4).
           05  FEE-PRODUCT                 PIC X(4).
           05  FEE-MCC-CLASS               PIC X(2).
           05  FEE-PRESENCE                PIC X.
           05  FEE-TRAN-TYPE               PIC X(2).
           05  FEE-DR-CR                   PIC X.
               88  FEE-DEBIT               VALUE 'D'.
               88  FEE-CREDIT              VALUE 'C'.
           05  FEE-AMOUNT                  PIC 9(9)V99.
           05  FEE-RATE                    PIC 9V9(4).
           05  FEE-PER-ITEM                PIC 9(3)V99.
           05  FEE-INTERCHANGE             PIC S9(7)V99
                                           SIGN LEADING SEPARATE.
           05  FEE-NET-AMOUNT              PIC S9(11)V99
                                           SIGN LEADING SEPARATE.
           05  FEE-SCHED-KEY               PIC X(11).
           05  FEE-MATCH-LEVEL             PIC 9.
           05  FEE-BUS-DATE                PIC 9(8).
           05  FILLER                      PIC X(43).
