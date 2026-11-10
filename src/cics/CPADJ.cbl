       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPADJ.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONSTANTS.
           05  WS-TRANSID                  PIC X(4)  VALUE 'CPAJ'.
           05  WS-MAPSET                   PIC X(8)  VALUE 'CPADJM'.
           05  WS-MAP                      PIC X(8)  VALUE 'CPADJ1'.
           05  WS-ACCOUNT-FILE             PIC X(8)  VALUE 'CPACCT'.
           05  WS-MAX-ADJUSTMENT           PIC S9(9)V99 COMP-3
                                           VALUE 25000.00.

       01  WS-WORK-FIELDS.
           05  WS-RESP                     PIC S9(8) COMP.
           05  WS-RESP2                    PIC S9(8) COMP.
           05  WS-USERID                   PIC X(8).
           05  WS-ABSTIME                  PIC S9(15) COMP-3.
           05  WS-TODAY                    PIC X(10).
           05  WS-TODAY-NUMERIC            PIC X(8).
           05  WS-ACCT-KEY                 PIC X(12).
           05  WS-AMOUNT                   PIC S9(9)V99 COMP-3.
           05  WS-BEFORE-BAL               PIC S9(9)V99 COMP-3.
           05  WS-AMOUNT-EDIT              PIC ZZZ,ZZZ,ZZ9.99-.
           05  WS-ADJ-ID-EDIT              PIC 9(7).
           05  WS-SQLCODE-EDIT             PIC -(8)9.
           05  WS-RESP-EDIT                PIC -(7)9.
           05  WS-AUDIT-ACTION             PIC X(8).
           05  WS-MESSAGE                  PIC X(78).
           05  WS-END-MESSAGE              PIC X(40) VALUE
               'CLEARPOINT ADJUSTMENTS ENDED'.
           05  WS-REASON                   PIC X(4).
               88  VALID-REASON            VALUE 'WAIV' 'DISP'
                                                 'GOOD' 'CORR'.
           05  WS-ADJ-FOUND-SW             PIC X.
               88  ADJUSTMENT-FOUND        VALUE 'Y'.
               88  ADJUSTMENT-NOT-FOUND    VALUE 'N'.

       01  WS-COMMAREA.
           05  CA-LAST-FUNCTION            PIC X.
           05  CA-LAST-ADJ-ID              PIC S9(9) COMP.

           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE DCLADJ END-EXEC.
           EXEC SQL INCLUDE DCLAUD END-EXEC.

           COPY CPADJM.
           COPY CPACCREC.
           COPY DFHAID.
           COPY DFHBMSCA.

       LINKAGE SECTION.
       01  DFHCOMMAREA                     PIC X(5).

       PROCEDURE DIVISION.
       0000-MAINLINE.
           EVALUATE TRUE
               WHEN EIBCALEN = ZERO
                   INITIALIZE WS-COMMAREA
                   MOVE SPACES TO WS-MESSAGE
                   MOVE LOW-VALUES TO CPADJ1O
                   PERFORM 8900-SEND-SCREEN
               WHEN EIBAID = DFHPF3
               WHEN EIBAID = DFHCLEAR
                   PERFORM 9000-END-CONVERSATION
               WHEN EIBAID = DFHENTER
                   MOVE DFHCOMMAREA TO WS-COMMAREA
                   PERFORM 1000-PROCESS-REQUEST
               WHEN OTHER
                   MOVE DFHCOMMAREA TO WS-COMMAREA
                   MOVE 'INVALID KEY - PRESS ENTER OR PF3'
                     TO WS-MESSAGE
                   MOVE LOW-VALUES TO CPADJ1O
                   PERFORM 8900-SEND-SCREEN
           END-EVALUATE
           EXEC CICS RETURN
               TRANSID(WS-TRANSID)
               COMMAREA(WS-COMMAREA)
               LENGTH(LENGTH OF WS-COMMAREA)
           END-EXEC.

       1000-PROCESS-REQUEST.
           MOVE SPACES TO WS-MESSAGE
           EXEC CICS RECEIVE
               MAP(WS-MAP)
               MAPSET(WS-MAPSET)
               INTO(CPADJ1I)
               RESP(WS-RESP)
           END-EXEC
           IF WS-RESP = DFHRESP(MAPFAIL)
               MOVE 'ENTER A FUNCTION CODE' TO WS-MESSAGE
               MOVE LOW-VALUES TO CPADJ1O
               PERFORM 8900-SEND-SCREEN
           ELSE
               EXEC CICS ASSIGN USERID(WS-USERID) END-EXEC
               MOVE LOW-VALUES TO CPADJ1O
               EVALUATE FUNCI
                   WHEN 'S'
                       PERFORM 2000-SUBMIT-ADJUSTMENT
                   WHEN 'V'
                       PERFORM 3000-VIEW-ADJUSTMENT
                   WHEN 'A'
                       PERFORM 4000-APPROVE-ADJUSTMENT
                   WHEN 'R'
                       PERFORM 5000-REJECT-ADJUSTMENT
                   WHEN OTHER
                       MOVE 'FUNCTION MUST BE S, V, A OR R'
                         TO WS-MESSAGE
               END-EVALUATE
               MOVE FUNCI TO CA-LAST-FUNCTION
               PERFORM 8900-SEND-SCREEN
           END-IF.

       2000-SUBMIT-ADJUSTMENT.
           PERFORM 2100-EDIT-SUBMISSION
           IF WS-MESSAGE = SPACES
               PERFORM 7000-READ-ACCOUNT
           END-IF
           IF WS-MESSAGE = SPACES
              AND NOT ACCT-ACTIVE AND NOT ACCT-FROZEN
               MOVE 'ADJUSTMENTS NOT ALLOWED ON THIS ACCOUNT'
                 TO WS-MESSAGE
           END-IF
           IF WS-MESSAGE = SPACES
               PERFORM 2200-INSERT-ADJUSTMENT
           END-IF.

       2100-EDIT-SUBMISSION.
           MOVE REASONI TO WS-REASON
           EVALUATE TRUE
               WHEN ACCTNOL NOT = 12
               WHEN ACCTNOI IS NOT NUMERIC
                   MOVE 'ACCOUNT NUMBER MUST BE 12 DIGITS'
                     TO WS-MESSAGE
               WHEN ADJTYPEI NOT = 'D' AND ADJTYPEI NOT = 'C'
                   MOVE 'DEBIT/CREDIT MUST BE D OR C' TO WS-MESSAGE
               WHEN AMOUNTL = ZERO
                   MOVE 'AMOUNT IS REQUIRED' TO WS-MESSAGE
               WHEN FUNCTION TEST-NUMVAL(AMOUNTI(1:AMOUNTL))
                    NOT = ZERO
                   MOVE 'AMOUNT IS NOT A VALID NUMBER' TO WS-MESSAGE
               WHEN NOT VALID-REASON
                   MOVE 'REASON MUST BE WAIV, DISP, GOOD OR CORR'
                     TO WS-MESSAGE
               WHEN OTHER
                   COMPUTE WS-AMOUNT =
                       FUNCTION NUMVAL(AMOUNTI(1:AMOUNTL))
                   IF WS-AMOUNT NOT > ZERO
                      OR WS-AMOUNT > WS-MAX-ADJUSTMENT
                       MOVE 'AMOUNT MUST BE BETWEEN 0.01 AND 25,000.00'
                         TO WS-MESSAGE
                   END-IF
           END-EVALUATE
           MOVE ACCTNOI TO WS-ACCT-KEY.

       2200-INSERT-ADJUSTMENT.
           MOVE WS-ACCT-KEY TO HV-ADJ-ACCT-NUM
           MOVE ADJTYPEI TO HV-ADJ-TYPE
           MOVE WS-AMOUNT TO HV-ADJ-AMOUNT
           MOVE WS-REASON TO HV-ADJ-REASON-CODE
           MOVE WS-USERID TO HV-ADJ-MAKER-ID
           EXEC SQL
               SELECT ADJ_ID
                 INTO :HV-ADJ-ID
                 FROM FINAL TABLE
                      (INSERT INTO CP_ADJUSTMENT
                              (ACCT_NUM, ADJ_TYPE, AMOUNT,
                               REASON_CODE, STATUS, MAKER_ID,
                               MAKER_TS)
                       VALUES (:HV-ADJ-ACCT-NUM, :HV-ADJ-TYPE,
                               :HV-ADJ-AMOUNT, :HV-ADJ-REASON-CODE,
                               'P', :HV-ADJ-MAKER-ID,
                               CURRENT TIMESTAMP))
           END-EXEC
           IF SQLCODE NOT = ZERO
               PERFORM 9800-SQL-FAILURE
           ELSE
               MOVE 'SUBMIT' TO WS-AUDIT-ACTION
               MOVE ACCT-CURR-BAL TO WS-BEFORE-BAL
               PERFORM 6000-WRITE-AUDIT
               IF WS-MESSAGE = SPACES
                   EXEC CICS SYNCPOINT END-EXEC
                   MOVE HV-ADJ-ID TO WS-ADJ-ID-EDIT CA-LAST-ADJ-ID
                   STRING 'ADJUSTMENT ' WS-ADJ-ID-EDIT
                          ' SUBMITTED - AWAITING APPROVAL'
                          DELIMITED BY SIZE
                     INTO WS-MESSAGE
                   END-STRING
                   MOVE 'PENDING' TO ADJSTATO
                   MOVE WS-USERID TO MAKERO
                   MOVE WS-ADJ-ID-EDIT TO ADJIDO
                   PERFORM 8100-FORMAT-BALANCE
               END-IF
           END-IF.

       3000-VIEW-ADJUSTMENT.
           PERFORM 7100-FETCH-ADJUSTMENT
           IF ADJUSTMENT-FOUND
               PERFORM 8000-FORMAT-ADJUSTMENT
               MOVE HV-ADJ-ACCT-NUM TO WS-ACCT-KEY
               PERFORM 7000-READ-ACCOUNT
               IF WS-MESSAGE = SPACES
                   PERFORM 8100-FORMAT-BALANCE
               END-IF
           END-IF.

       4000-APPROVE-ADJUSTMENT.
           PERFORM 7100-FETCH-ADJUSTMENT
           IF ADJUSTMENT-FOUND
               PERFORM 7200-CHECK-REVIEWABLE
           END-IF
           IF ADJUSTMENT-FOUND AND WS-MESSAGE = SPACES
               PERFORM 4100-APPLY-TO-ACCOUNT
           END-IF
           IF ADJUSTMENT-FOUND AND WS-MESSAGE = SPACES
               EXEC SQL
                   UPDATE CP_ADJUSTMENT
                      SET STATUS     = 'A',
                          CHECKER_ID = :WS-USERID,
                          CHECKER_TS = CURRENT TIMESTAMP
                    WHERE ADJ_ID = :HV-ADJ-ID
                      AND STATUS = 'P'
               END-EXEC
               EVALUATE TRUE
                   WHEN SQLCODE NOT = ZERO
                       PERFORM 9800-SQL-FAILURE
                   WHEN SQLERRD(3) NOT = 1
                       EXEC CICS SYNCPOINT ROLLBACK END-EXEC
                       MOVE 'ADJUSTMENT WAS UPDATED BY ANOTHER USER'
                         TO WS-MESSAGE
                   WHEN OTHER
                       MOVE 'APPROVE' TO WS-AUDIT-ACTION
                       PERFORM 6000-WRITE-AUDIT
               END-EVALUATE
           END-IF
           IF ADJUSTMENT-FOUND AND WS-MESSAGE = SPACES
               EXEC CICS SYNCPOINT END-EXEC
               MOVE 'A' TO HV-ADJ-STATUS
               MOVE WS-USERID TO HV-ADJ-CHECKER-ID
               MOVE ZERO TO HI-ADJ-CHECKER-ID
               PERFORM 8000-FORMAT-ADJUSTMENT
               PERFORM 8100-FORMAT-BALANCE
               MOVE 'ADJUSTMENT APPROVED AND APPLIED TO ACCOUNT'
                 TO WS-MESSAGE
           END-IF.

       4100-APPLY-TO-ACCOUNT.
           MOVE HV-ADJ-ACCT-NUM TO WS-ACCT-KEY
           EXEC CICS READ
               FILE(WS-ACCOUNT-FILE)
               INTO(ACCT-RECORD)
               RIDFLD(WS-ACCT-KEY)
               UPDATE
               RESP(WS-RESP)
               RESP2(WS-RESP2)
           END-EXEC
           IF WS-RESP NOT = DFHRESP(NORMAL)
               PERFORM 9900-CICS-FAILURE
           ELSE
               PERFORM 8200-GET-TODAY
               MOVE ACCT-CURR-BAL TO WS-BEFORE-BAL
               IF HV-ADJ-TYPE = 'D'
                   ADD HV-ADJ-AMOUNT TO ACCT-CURR-BAL
               ELSE
                   SUBTRACT HV-ADJ-AMOUNT FROM ACCT-CURR-BAL
               END-IF
               MOVE WS-TODAY-NUMERIC TO ACCT-LAST-MAINT-DATE
               MOVE WS-USERID TO ACCT-LAST-MAINT-USER
               EXEC CICS REWRITE
                   FILE(WS-ACCOUNT-FILE)
                   FROM(ACCT-RECORD)
                   RESP(WS-RESP)
                   RESP2(WS-RESP2)
               END-EXEC
               IF WS-RESP NOT = DFHRESP(NORMAL)
                   PERFORM 9900-CICS-FAILURE
               END-IF
           END-IF.

       5000-REJECT-ADJUSTMENT.
           PERFORM 7100-FETCH-ADJUSTMENT
           IF ADJUSTMENT-FOUND
               PERFORM 7200-CHECK-REVIEWABLE
           END-IF
           IF ADJUSTMENT-FOUND AND WS-MESSAGE = SPACES
               EXEC SQL
                   UPDATE CP_ADJUSTMENT
                      SET STATUS     = 'R',
                          CHECKER_ID = :WS-USERID,
                          CHECKER_TS = CURRENT TIMESTAMP
                    WHERE ADJ_ID = :HV-ADJ-ID
                      AND STATUS = 'P'
               END-EXEC
               EVALUATE TRUE
                   WHEN SQLCODE NOT = ZERO
                       PERFORM 9800-SQL-FAILURE
                   WHEN SQLERRD(3) NOT = 1
                       EXEC CICS SYNCPOINT ROLLBACK END-EXEC
                       MOVE 'ADJUSTMENT WAS UPDATED BY ANOTHER USER'
                         TO WS-MESSAGE
                   WHEN OTHER
                       MOVE 'REJECT' TO WS-AUDIT-ACTION
                       MOVE ZERO TO WS-BEFORE-BAL ACCT-CURR-BAL
                       PERFORM 6000-WRITE-AUDIT
               END-EVALUATE
           END-IF
           IF ADJUSTMENT-FOUND AND WS-MESSAGE = SPACES
               EXEC CICS SYNCPOINT END-EXEC
               MOVE 'R' TO HV-ADJ-STATUS
               MOVE WS-USERID TO HV-ADJ-CHECKER-ID
               MOVE ZERO TO HI-ADJ-CHECKER-ID
               PERFORM 8000-FORMAT-ADJUSTMENT
               MOVE 'ADJUSTMENT REJECTED' TO WS-MESSAGE
           END-IF.

       6000-WRITE-AUDIT.
           MOVE WS-USERID TO HV-AUD-USER-ID
           MOVE WS-ACCT-KEY TO HV-AUD-ACCT-NUM
           MOVE WS-AUDIT-ACTION TO HV-AUD-ACTION
           MOVE HV-ADJ-ID TO HV-AUD-REF-ID
           MOVE WS-BEFORE-BAL TO HV-AUD-BEFORE-BAL
           MOVE ACCT-CURR-BAL TO HV-AUD-AFTER-BAL
           EXEC SQL
               INSERT INTO CP_AUDIT_LOG
                      (USER_ID, ACCT_NUM, ACTION, REF_ID,
                       BEFORE_BAL, AFTER_BAL)
               VALUES (:HV-AUD-USER-ID, :HV-AUD-ACCT-NUM,
                       :HV-AUD-ACTION, :HV-AUD-REF-ID,
                       :HV-AUD-BEFORE-BAL, :HV-AUD-AFTER-BAL)
           END-EXEC
           IF SQLCODE NOT = ZERO
               PERFORM 9800-SQL-FAILURE
           END-IF.

       7000-READ-ACCOUNT.
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
                   MOVE 'ACCOUNT NOT FOUND' TO WS-MESSAGE
               WHEN OTHER
                   PERFORM 9900-CICS-FAILURE
           END-EVALUATE.

       7100-FETCH-ADJUSTMENT.
           SET ADJUSTMENT-NOT-FOUND TO TRUE
           IF ADJIDL = ZERO OR ADJIDI IS NOT NUMERIC
               MOVE 'ENTER A 7 DIGIT ADJUSTMENT ID' TO WS-MESSAGE
           ELSE
               MOVE ADJIDI TO WS-ADJ-ID-EDIT
               MOVE WS-ADJ-ID-EDIT TO HV-ADJ-ID
               EXEC SQL
                   SELECT ACCT_NUM, ADJ_TYPE, AMOUNT, REASON_CODE,
                          STATUS, MAKER_ID, CHAR(MAKER_TS),
                          CHECKER_ID, CHAR(CHECKER_TS)
                     INTO :HV-ADJ-ACCT-NUM, :HV-ADJ-TYPE,
                          :HV-ADJ-AMOUNT, :HV-ADJ-REASON-CODE,
                          :HV-ADJ-STATUS, :HV-ADJ-MAKER-ID,
                          :HV-ADJ-MAKER-TS,
                          :HV-ADJ-CHECKER-ID :HI-ADJ-CHECKER-ID,
                          :HV-ADJ-CHECKER-TS :HI-ADJ-CHECKER-TS
                     FROM CP_ADJUSTMENT
                    WHERE ADJ_ID = :HV-ADJ-ID
               END-EXEC
               EVALUATE SQLCODE
                   WHEN ZERO
                       SET ADJUSTMENT-FOUND TO TRUE
                       MOVE HV-ADJ-ACCT-NUM TO WS-ACCT-KEY
                       MOVE HV-ADJ-ID TO CA-LAST-ADJ-ID
                   WHEN +100
                       MOVE 'ADJUSTMENT NOT FOUND' TO WS-MESSAGE
                   WHEN OTHER
                       PERFORM 9800-SQL-FAILURE
               END-EVALUATE
           END-IF.

       7200-CHECK-REVIEWABLE.
           EVALUATE TRUE
               WHEN HV-ADJ-STATUS NOT = 'P'
                   MOVE 'ADJUSTMENT IS NOT PENDING REVIEW'
                     TO WS-MESSAGE
                   PERFORM 8000-FORMAT-ADJUSTMENT
               WHEN HV-ADJ-MAKER-ID = WS-USERID
                   MOVE 'SUBMITTER CANNOT REVIEW THEIR OWN ADJUSTMENT'
                     TO WS-MESSAGE
                   PERFORM 8000-FORMAT-ADJUSTMENT
           END-EVALUATE.

       8000-FORMAT-ADJUSTMENT.
           MOVE HV-ADJ-ID TO WS-ADJ-ID-EDIT
           MOVE WS-ADJ-ID-EDIT TO ADJIDO
           MOVE HV-ADJ-ACCT-NUM TO ACCTNOO
           MOVE HV-ADJ-TYPE TO ADJTYPEO
           MOVE HV-ADJ-AMOUNT TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO AMOUNTO
           MOVE HV-ADJ-REASON-CODE TO REASONO
           MOVE HV-ADJ-MAKER-ID TO MAKERO
           IF HI-ADJ-CHECKER-ID < ZERO
               MOVE SPACES TO CHECKERO
           ELSE
               MOVE HV-ADJ-CHECKER-ID TO CHECKERO
           END-IF
           EVALUATE HV-ADJ-STATUS
               WHEN 'P'
                   MOVE 'PENDING' TO ADJSTATO
               WHEN 'A'
                   MOVE 'APPROVED' TO ADJSTATO
               WHEN 'R'
                   MOVE 'REJECTED' TO ADJSTATO
               WHEN OTHER
                   MOVE HV-ADJ-STATUS TO ADJSTATO
           END-EVALUATE.

       8100-FORMAT-BALANCE.
           MOVE ACCT-CURR-BAL TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CURBALO.

       8200-GET-TODAY.
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
           EXEC CICS FORMATTIME
               ABSTIME(WS-ABSTIME)
               YYYYMMDD(WS-TODAY-NUMERIC)
           END-EXEC.

       8900-SEND-SCREEN.
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
           EXEC CICS FORMATTIME
               ABSTIME(WS-ABSTIME)
               YYYYMMDD(WS-TODAY)
               DATESEP('/')
           END-EXEC
           MOVE WS-TODAY TO CURDATEO
           MOVE WS-MESSAGE TO MSGO
           MOVE -1 TO FUNCL
           EXEC CICS SEND
               MAP(WS-MAP)
               MAPSET(WS-MAPSET)
               FROM(CPADJ1O)
               ERASE
               CURSOR
           END-EXEC.

       9000-END-CONVERSATION.
           EXEC CICS SEND TEXT
               FROM(WS-END-MESSAGE)
               LENGTH(LENGTH OF WS-END-MESSAGE)
               ERASE
               FREEKB
           END-EXEC
           EXEC CICS RETURN END-EXEC.

       9800-SQL-FAILURE.
           EXEC CICS SYNCPOINT ROLLBACK END-EXEC
           MOVE SQLCODE TO WS-SQLCODE-EDIT
           MOVE SPACES TO WS-MESSAGE
           STRING 'DATABASE ERROR SQLCODE ' WS-SQLCODE-EDIT
                  ' - CHANGES BACKED OUT'
                  DELIMITED BY SIZE
             INTO WS-MESSAGE
           END-STRING.

       9900-CICS-FAILURE.
           EXEC CICS SYNCPOINT ROLLBACK END-EXEC
           MOVE WS-RESP TO WS-RESP-EDIT
           MOVE SPACES TO WS-MESSAGE
           STRING 'ACCOUNT FILE ERROR RESP ' WS-RESP-EDIT
                  ' - CHANGES BACKED OUT'
                  DELIMITED BY SIZE
             INTO WS-MESSAGE
           END-STRING.
