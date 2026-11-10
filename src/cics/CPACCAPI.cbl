       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPACCAPI.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-ACCOUNT-FILE                 PIC X(8)  VALUE 'CPACCT'.
       01  WS-RESP                         PIC S9(8) COMP.
       01  WS-RESP2                        PIC S9(8) COMP.
       01  WS-ACCT-KEY                     PIC X(12).
       01  WS-DATE-WORK                    PIC 9(8).
       01  WS-DATE-WORK-R REDEFINES WS-DATE-WORK.
           05  WS-DATE-CCYY                PIC X(4).
           05  WS-DATE-MM                  PIC X(2).
           05  WS-DATE-DD                  PIC X(2).
       01  WS-ISO-DATE                     PIC X(10).
       01  WS-RESP-EDIT                    PIC -(7)9.

           COPY CPACCREC.

       LINKAGE SECTION.
           COPY CPAPICA REPLACING ==API-COMMAREA== BY ==DFHCOMMAREA==.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           IF EIBCALEN < LENGTH OF DFHCOMMAREA
               EXEC CICS ABEND ABCODE('CPA1') NODUMP END-EXEC
           END-IF
           INITIALIZE API-RESPONSE
           PERFORM 1000-VALIDATE-REQUEST
           IF API-OK
               PERFORM 2000-READ-ACCOUNT
           END-IF
           IF API-OK
               PERFORM 3000-BUILD-RESPONSE
           END-IF
           EXEC CICS RETURN END-EXEC.

       1000-VALIDATE-REQUEST.
           IF API-ACCT-NUM IS NOT NUMERIC
               SET API-INVALID-REQUEST TO TRUE
               MOVE 'ACCOUNT NUMBER MUST BE 12 NUMERIC DIGITS'
                 TO API-MESSAGE
           ELSE
               SET API-OK TO TRUE
               MOVE API-ACCT-NUM TO WS-ACCT-KEY
           END-IF.

       2000-READ-ACCOUNT.
           EXEC CICS READ
               FILE(WS-ACCOUNT-FILE)
               INTO(ACCT-RECORD)
               RIDFLD(WS-ACCT-KEY)
               RESP(WS-RESP)
               RESP2(WS-RESP2)
           END-EXEC
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   CONTINUE
               WHEN DFHRESP(NOTFND)
                   SET API-NOT-FOUND TO TRUE
                   MOVE 'ACCOUNT NOT FOUND' TO API-MESSAGE
               WHEN DFHRESP(NOTOPEN)
               WHEN DFHRESP(DISABLED)
                   SET API-UNAVAILABLE TO TRUE
                   MOVE 'ACCOUNT SERVICE UNAVAILABLE - RETRY LATER'
                     TO API-MESSAGE
               WHEN OTHER
                   SET API-SYSTEM-ERROR TO TRUE
                   MOVE WS-RESP TO WS-RESP-EDIT
                   STRING 'ACCOUNT FILE ERROR RESP ' WS-RESP-EDIT
                          DELIMITED BY SIZE
                     INTO API-MESSAGE
                   END-STRING
           END-EVALUATE.

       3000-BUILD-RESPONSE.
           MOVE 'ACCOUNT RETRIEVED' TO API-MESSAGE
           MOVE ACCT-CUST-ID TO API-CUST-ID
           MOVE ACCT-PRODUCT TO API-PRODUCT
           EVALUATE TRUE
               WHEN ACCT-ACTIVE
                   MOVE 'ACTIVE' TO API-STATUS
               WHEN ACCT-CLOSED
                   MOVE 'CLOSED' TO API-STATUS
               WHEN ACCT-FROZEN
                   MOVE 'FROZEN' TO API-STATUS
               WHEN ACCT-WRITTEN-OFF
                   MOVE 'CHARGED_OFF' TO API-STATUS
               WHEN OTHER
                   MOVE 'UNKNOWN' TO API-STATUS
           END-EVALUATE
           MOVE ACCT-OPEN-DATE TO WS-DATE-WORK
           PERFORM 3100-FORMAT-ISO-DATE
           MOVE WS-ISO-DATE TO API-OPEN-DATE
           MOVE ACCT-CREDIT-LIMIT TO API-CREDIT-LIMIT
           MOVE ACCT-CURR-BAL TO API-CURRENT-BALANCE
           MOVE ACCT-CASH-LIMIT TO API-CASH-LIMIT
           MOVE ACCT-CASH-BAL TO API-CASH-BALANCE
           IF ACCT-CURR-BAL > ACCT-CREDIT-LIMIT
               MOVE ZERO TO API-AVAILABLE-CREDIT
               MOVE 'Y' TO API-OVER-LIMIT
           ELSE
               COMPUTE API-AVAILABLE-CREDIT =
                   ACCT-CREDIT-LIMIT - ACCT-CURR-BAL
               MOVE 'N' TO API-OVER-LIMIT
           END-IF
           IF ACCT-LAST-POST-DATE > ZERO
               MOVE ACCT-LAST-POST-DATE TO WS-DATE-WORK
               PERFORM 3100-FORMAT-ISO-DATE
               MOVE WS-ISO-DATE TO API-LAST-POST-DATE
           END-IF.

       3100-FORMAT-ISO-DATE.
           STRING WS-DATE-CCYY '-' WS-DATE-MM '-' WS-DATE-DD
                  DELIMITED BY SIZE
             INTO WS-ISO-DATE
           END-STRING.
