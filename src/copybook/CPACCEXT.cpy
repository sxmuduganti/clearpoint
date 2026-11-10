       01  AX-RECORD.
           05  AX-ACCT-NUM                 PIC X(12).
           05  AX-CUST-ID                  PIC X(10).
           05  AX-PRODUCT                  PIC X(4).
           05  AX-STATUS                   PIC X.
           05  AX-OPEN-DATE                PIC 9(8).
           05  AX-CREDIT-LIMIT             PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CASH-LIMIT               PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CURR-BAL                 PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CASH-BAL                 PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CTD-PURCHASES            PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CTD-CREDITS              PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  AX-CTD-TXN-COUNT            PIC 9(7).
           05  AX-LAST-POST-DATE           PIC 9(8).
           05  FILLER                      PIC X(78).
