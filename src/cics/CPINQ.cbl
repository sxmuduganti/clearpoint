       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPINQ.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONSTANTS.
           05  WS-TRANSID                  PIC X(4)  VALUE 'CPIN'.
           05  WS-MAPSET                   PIC X(8)  VALUE 'CPINQM'.
           05  WS-MAP                      PIC X(8)  VALUE 'CPINQ1'.
           05  WS-ACCOUNT-FILE             PIC X(8)  VALUE 'CPACCT'.

       01  WS-WORK-FIELDS.
           05  WS-RESP                     PIC S9(8) COMP.
           05  WS-RESP2                    PIC S9(8) COMP.
           05  WS-ABSTIME                  PIC S9(15) COMP-3.
           05  WS-TODAY                    PIC X(10).
           05  WS-ACCT-KEY                 PIC X(12).
           05  WS-AVAILABLE                PIC S9(9)V99 COMP-3.
           05  WS-AMOUNT-EDIT              PIC ZZZ,ZZZ,ZZ9.99-.
           05  WS-DATE-EDIT                PIC 9999/99/99.
           05  WS-RESP-EDIT                PIC -(7)9.
           05  WS-MESSAGE                  PIC X(78).
           05  WS-END-MESSAGE              PIC X(40) VALUE
               'CLEARPOINT INQUIRY ENDED'.

       01  WS-COMMAREA.
           05  CA-LAST-ACCT                PIC X(12).
           05  CA-INQUIRY-COUNT            PIC S9(4) COMP.

           COPY CPINQM.
           COPY CPACCREC.
           COPY DFHAID.
           COPY DFHBMSCA.

       LINKAGE SECTION.
       01  DFHCOMMAREA                     PIC X(14).

       PROCEDURE DIVISION.
       0000-MAINLINE.
           EVALUATE TRUE
               WHEN EIBCALEN = ZERO
                   INITIALIZE WS-COMMAREA
                   MOVE SPACES TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
               WHEN EIBAID = DFHPF3
               WHEN EIBAID = DFHCLEAR
                   PERFORM 9000-END-CONVERSATION
               WHEN EIBAID = DFHENTER
                   MOVE DFHCOMMAREA TO WS-COMMAREA
                   PERFORM 2000-PROCESS-INQUIRY
               WHEN OTHER
                   MOVE DFHCOMMAREA TO WS-COMMAREA
                   MOVE 'INVALID KEY - PRESS ENTER TO INQUIRE OR PF3'
                     TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
           END-EVALUATE
           EXEC CICS RETURN
               TRANSID(WS-TRANSID)
               COMMAREA(WS-COMMAREA)
               LENGTH(LENGTH OF WS-COMMAREA)
           END-EXEC.

       1000-SEND-NEW-SCREEN.
           MOVE LOW-VALUES TO CPINQ1O
           PERFORM 8000-FORMAT-HEADER
           MOVE WS-MESSAGE TO MSGO
           MOVE -1 TO ACCTNOL
           EXEC CICS SEND
               MAP(WS-MAP)
               MAPSET(WS-MAPSET)
               FROM(CPINQ1O)
               ERASE
               CURSOR
           END-EXEC.

       2000-PROCESS-INQUIRY.
           EXEC CICS RECEIVE
               MAP(WS-MAP)
               MAPSET(WS-MAPSET)
               INTO(CPINQ1I)
               RESP(WS-RESP)
           END-EXEC
           EVALUATE TRUE
               WHEN WS-RESP = DFHRESP(MAPFAIL)
                   MOVE 'ENTER AN ACCOUNT NUMBER' TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
               WHEN WS-RESP NOT = DFHRESP(NORMAL)
                   PERFORM 9900-UNEXPECTED-RESPONSE
               WHEN ACCTNOL NOT = 12
               WHEN ACCTNOI IS NOT NUMERIC
                   MOVE 'ACCOUNT NUMBER MUST BE 12 DIGITS'
                     TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
               WHEN OTHER
                   MOVE ACCTNOI TO WS-ACCT-KEY
                   PERFORM 2100-READ-ACCOUNT
           END-EVALUATE.

       2100-READ-ACCOUNT.
           EXEC CICS READ
               FILE(WS-ACCOUNT-FILE)
               INTO(ACCT-RECORD)
               RIDFLD(WS-ACCT-KEY)
               RESP(WS-RESP)
               RESP2(WS-RESP2)
           END-EXEC
           EVALUATE WS-RESP
               WHEN DFHRESP(NORMAL)
                   MOVE WS-ACCT-KEY TO CA-LAST-ACCT
                   ADD 1 TO CA-INQUIRY-COUNT
                   PERFORM 3000-SEND-ACCOUNT
               WHEN DFHRESP(NOTFND)
                   MOVE 'ACCOUNT NOT FOUND' TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
               WHEN DFHRESP(NOTOPEN)
               WHEN DFHRESP(DISABLED)
                   MOVE 'ACCOUNT FILE UNAVAILABLE - BATCH WINDOW'
                     TO WS-MESSAGE
                   PERFORM 1000-SEND-NEW-SCREEN
               WHEN OTHER
                   PERFORM 9900-UNEXPECTED-RESPONSE
           END-EVALUATE.

       3000-SEND-ACCOUNT.
           MOVE LOW-VALUES TO CPINQ1O
           PERFORM 8000-FORMAT-HEADER
           MOVE ACCT-NUM TO ACCTNOO
           MOVE ACCT-CUST-ID TO CUSTIDO
           MOVE ACCT-PRODUCT TO PRODUCTO
           EVALUATE TRUE
               WHEN ACCT-ACTIVE
                   MOVE 'ACTIVE' TO ACSTATO
               WHEN ACCT-CLOSED
                   MOVE 'CLOSED' TO ACSTATO
               WHEN ACCT-FROZEN
                   MOVE 'FROZEN' TO ACSTATO
               WHEN ACCT-WRITTEN-OFF
                   MOVE 'CHARGED OFF' TO ACSTATO
               WHEN OTHER
                   MOVE 'UNKNOWN' TO ACSTATO
           END-EVALUATE
           MOVE ACCT-OPEN-DATE TO WS-DATE-EDIT
           MOVE WS-DATE-EDIT TO OPENDTO
           MOVE ACCT-CREDIT-LIMIT TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CRLIMITO
           MOVE ACCT-CURR-BAL TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CURBALO
           COMPUTE WS-AVAILABLE = ACCT-CREDIT-LIMIT - ACCT-CURR-BAL
           IF WS-AVAILABLE < ZERO
               MOVE ZERO TO WS-AVAILABLE
           END-IF
           MOVE WS-AVAILABLE TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO AVAILO
           MOVE ACCT-CASH-LIMIT TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CASHLIMO
           MOVE ACCT-CASH-BAL TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CASHBALO
           MOVE ACCT-CTD-PURCHASES TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CTDPURO
           MOVE ACCT-CTD-CREDITS TO WS-AMOUNT-EDIT
           MOVE WS-AMOUNT-EDIT TO CTDCRDO
           IF ACCT-LAST-POST-DATE > ZERO
               MOVE ACCT-LAST-POST-DATE TO WS-DATE-EDIT
               MOVE WS-DATE-EDIT TO LSTPOSTO
           END-IF
           IF ACCT-CURR-BAL > ACCT-CREDIT-LIMIT
               MOVE 'ACCOUNT IS OVER ITS CREDIT LIMIT' TO MSGO
           END-IF
           MOVE -1 TO ACCTNOL
           EXEC CICS SEND
               MAP(WS-MAP)
               MAPSET(WS-MAPSET)
               FROM(CPINQ1O)
               ERASE
               CURSOR
           END-EXEC.

       8000-FORMAT-HEADER.
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC
           EXEC CICS FORMATTIME
               ABSTIME(WS-ABSTIME)
               YYYYMMDD(WS-TODAY)
               DATESEP('/')
           END-EXEC
           MOVE WS-TODAY TO CURDATEO.

       9000-END-CONVERSATION.
           EXEC CICS SEND TEXT
               FROM(WS-END-MESSAGE)
               LENGTH(LENGTH OF WS-END-MESSAGE)
               ERASE
               FREEKB
           END-EXEC
           EXEC CICS RETURN END-EXEC.

       9900-UNEXPECTED-RESPONSE.
           MOVE WS-RESP TO WS-RESP-EDIT
           MOVE SPACES TO WS-MESSAGE
           STRING 'UNEXPECTED CICS RESPONSE ' WS-RESP-EDIT
                  ' - CONTACT SUPPORT'
                  DELIMITED BY SIZE
             INTO WS-MESSAGE
           END-STRING
           PERFORM 1000-SEND-NEW-SCREEN.
