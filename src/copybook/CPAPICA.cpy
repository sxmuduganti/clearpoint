       01  API-COMMAREA.
           05  API-REQUEST.
               10  API-ACCT-NUM            PIC X(12).
           05  API-RESPONSE.
               10  API-RETURN-CODE         PIC 9(2).
                   88  API-OK              VALUE 00.
                   88  API-NOT-FOUND       VALUE 04.
                   88  API-INVALID-REQUEST VALUE 08.
                   88  API-UNAVAILABLE     VALUE 12.
                   88  API-SYSTEM-ERROR    VALUE 16.
               10  API-MESSAGE             PIC X(60).
               10  API-ACCOUNT.
                   15  API-CUST-ID         PIC X(10).
                   15  API-PRODUCT         PIC X(4).
                   15  API-STATUS          PIC X(12).
                   15  API-OPEN-DATE       PIC X(10).
                   15  API-CREDIT-LIMIT    PIC S9(9)V99 COMP-3.
                   15  API-CURRENT-BALANCE PIC S9(9)V99 COMP-3.
                   15  API-AVAILABLE-CREDIT
                                           PIC S9(9)V99 COMP-3.
                   15  API-CASH-LIMIT      PIC S9(9)V99 COMP-3.
                   15  API-CASH-BALANCE    PIC S9(9)V99 COMP-3.
                   15  API-OVER-LIMIT      PIC X.
                   15  API-LAST-POST-DATE  PIC X(10).
