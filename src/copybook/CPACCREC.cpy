       01  ACCT-RECORD.
           05  ACCT-NUM                    PIC X(12).
           05  ACCT-CUST-ID                PIC X(10).
           05  ACCT-PRODUCT                PIC X(4).
           05  ACCT-STATUS                 PIC X.
               88  ACCT-ACTIVE             VALUE 'A'.
               88  ACCT-CLOSED             VALUE 'C'.
               88  ACCT-FROZEN             VALUE 'F'.
               88  ACCT-WRITTEN-OFF        VALUE 'W'.
               88  ACCT-VALID-STATUS       VALUE 'A' 'C' 'F' 'W'.
           05  ACCT-OPEN-DATE              PIC 9(8).
           05  ACCT-CREDIT-LIMIT           PIC S9(9)V99 COMP-3.
           05  ACCT-CASH-LIMIT             PIC S9(9)V99 COMP-3.
           05  ACCT-CURR-BAL               PIC S9(9)V99 COMP-3.
           05  ACCT-CASH-BAL               PIC S9(9)V99 COMP-3.
           05  ACCT-CTD-PURCHASES          PIC S9(9)V99 COMP-3.
           05  ACCT-CTD-CREDITS            PIC S9(9)V99 COMP-3.
           05  ACCT-CTD-TXN-COUNT          PIC S9(7) COMP-3.
           05  ACCT-LAST-POST-DATE         PIC 9(8).
           05  ACCT-HWM-BUS-DATE           PIC 9(8).
           05  ACCT-HWM-KEY                PIC X(30).
           05  ACCT-LAST-MAINT-DATE        PIC 9(8).
           05  ACCT-LAST-MAINT-USER        PIC X(8).
           05  FILLER                      PIC X(63).
