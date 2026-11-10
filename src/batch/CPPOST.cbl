       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPPOST.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT ENRSORT-FILE ASSIGN TO ENRSORT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ENRSORT-STATUS.
           SELECT ACCTMAST-FILE ASSIGN TO ACCTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AM-ACCT-NUM
               ALTERNATE RECORD KEY IS AM-CUST-ID WITH DUPLICATES
               FILE STATUS IS WS-ACCTMAST-STATUS.
           SELECT RSTCTL-FILE ASSIGN TO RSTCTL
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS RF-KEY
               FILE STATUS IS WS-RSTCTL-STATUS.
           SELECT POSTED-FILE ASSIGN TO POSTOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-POSTED-STATUS.
           SELECT SUSPENSE-FILE ASSIGN TO SUSPENSE
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-SUSPENSE-STATUS.
           SELECT CTL-FILE ASSIGN TO CTLOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTL-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CTLCARD-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  CTLCARD-REC                     PIC X(80).
       FD  ENRSORT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  ENRSORT-REC                     PIC X(200).
       FD  ACCTMAST-FILE
           RECORD CONTAINS 200 CHARACTERS.
       01  ACCTMAST-REC.
           05  AM-ACCT-NUM                 PIC X(12).
           05  AM-CUST-ID                  PIC X(10).
           05  FILLER                      PIC X(178).
       FD  RSTCTL-FILE
           RECORD CONTAINS 100 CHARACTERS.
       01  RSTCTL-REC.
           05  RF-KEY                      PIC X(8).
           05  FILLER                      PIC X(92).
       FD  POSTED-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 250 CHARACTERS.
       01  POSTED-REC                      PIC X(250).
       FD  SUSPENSE-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 250 CHARACTERS.
       01  SUSPENSE-REC                    PIC X(250).
       FD  CTL-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 120 CHARACTERS.
       01  CTL-REC                         PIC X(120).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05  WS-CTLCARD-STATUS           PIC X(2).
               88  CTLCARD-OK              VALUE '00'.
               88  CTLCARD-EOF             VALUE '10'.
           05  WS-ENRSORT-STATUS           PIC X(2).
               88  ENRSORT-OK              VALUE '00'.
               88  ENRSORT-EOF             VALUE '10'.
           05  WS-ACCTMAST-STATUS          PIC X(2).
               88  ACCTMAST-OK             VALUE '00' '02'.
               88  ACCTMAST-NOT-FOUND      VALUE '23'.
           05  WS-RSTCTL-STATUS            PIC X(2).
               88  RSTCTL-OK               VALUE '00'.
               88  RSTCTL-NOT-FOUND        VALUE '23'.
               88  RSTCTL-NOT-PRESENT      VALUE '35'.
           05  WS-POSTED-STATUS            PIC X(2).
               88  POSTED-OK               VALUE '00'.
           05  WS-SUSPENSE-STATUS          PIC X(2).
               88  SUSPENSE-OK             VALUE '00'.
           05  WS-CTL-STATUS               PIC X(2).
               88  CTL-OK                  VALUE '00'.

       01  WS-SWITCHES.
           05  WS-ENRSORT-EOF-SW           PIC X VALUE 'N'.
               88  END-OF-INPUT            VALUE 'Y'.
           05  WS-ACCOUNT-FOUND-SW         PIC X VALUE 'N'.
               88  ACCOUNT-FOUND           VALUE 'Y'.
               88  ACCOUNT-NOT-FOUND       VALUE 'N'.
           05  WS-ACCOUNT-CHANGED-SW       PIC X VALUE 'N'.
               88  ACCOUNT-CHANGED         VALUE 'Y'.
               88  ACCOUNT-UNCHANGED       VALUE 'N'.
           05  WS-DUPLICATE-SW             PIC X VALUE 'N'.
               88  DUPLICATE-TRANSACTION   VALUE 'Y'.
               88  NOT-DUPLICATE           VALUE 'N'.
           05  WS-RUN-CONTROL-SW           PIC X VALUE 'N'.
               88  RUN-CONTROL-EXISTS      VALUE 'Y'.
               88  RUN-CONTROL-NEW         VALUE 'N'.
           05  WS-CHECKPOINT-VERIFIED-SW   PIC X VALUE 'N'.
               88  CHECKPOINT-VERIFIED     VALUE 'Y'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).
           05  WS-CC-LENGTH                PIC S9(4) COMP.
           05  WS-CC-NUMBER                PIC 9(9).

       01  WS-RUN-OPTIONS.
           05  WS-BUS-DATE                 PIC 9(8) VALUE ZERO.
           05  WS-RUN-MODE                 PIC X(8) VALUE 'NORMAL'.
               88  MODE-NORMAL             VALUE 'NORMAL'.
               88  MODE-RESTART            VALUE 'RESTART'.
           05  WS-CHECKPOINT-INTERVAL      PIC 9(7) VALUE 1000.
           05  WS-ABEND-AT                 PIC 9(9) VALUE ZERO.

       01  WS-RESTART-POINT.
           05  WS-CHKP-RECS                PIC 9(9) VALUE ZERO.
           05  WS-CHKP-KEY                 PIC X(42) VALUE SPACES.

       01  WS-SORT-KEY.
           05  WS-SK-ACCT-NUM              PIC X(12).
           05  WS-SK-POST-KEY.
               10  WS-SK-TRAN-DATE         PIC 9(8).
               10  WS-SK-TRAN-TIME         PIC 9(6).
               10  WS-SK-TRAN-ID           PIC X(16).
       01  WS-PREV-SORT-KEY                PIC X(42) VALUE LOW-VALUES.
       01  WS-CURR-ACCT                    PIC X(12) VALUE LOW-VALUES.

       01  WS-POSTING-FIELDS.
           05  WS-OVERLIMIT-FLAG           PIC X.
           05  WS-POST-STATUS              PIC X.
           05  WS-SUSPENSE-CODE            PIC X(4).
               88  NO-SUSPENSE             VALUE SPACES.
           05  WS-SUSPENSE-TEXT            PIC X(30).

       01  WS-COUNTERS.
           05  WS-READ-COUNT               PIC S9(9) COMP-3 VALUE 0.
           05  WS-IN-AMOUNT                PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-POSTED-COUNT             PIC S9(9) COMP-3 VALUE 0.
           05  WS-POSTED-AMOUNT            PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-SUSP-COUNT               PIC S9(9) COMP-3 VALUE 0.
           05  WS-SUSP-AMOUNT              PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-BYPASS-COUNT             PIC S9(9) COMP-3 VALUE 0.
           05  WS-ACCTS-UPDATED            PIC S9(9) COMP-3 VALUE 0.
           05  WS-OVERLIMIT-COUNT          PIC S9(9) COMP-3 VALUE 0.
           05  WS-RECS-SINCE-CHKP          PIC S9(9) COMP-3 VALUE 0.
           05  WS-CHECKPOINT-COUNT         PIC S9(9) COMP-3 VALUE 0.

       01  WS-RSN-SUB                      PIC S9(4) COMP.
       01  WS-REASON-VALUES.
           05  FILLER  PIC X(4)  VALUE 'S001'.
           05  FILLER  PIC X(30) VALUE 'ACCOUNT NOT ON MASTER'.
           05  FILLER  PIC X(4)  VALUE 'S002'.
           05  FILLER  PIC X(30) VALUE 'ACCOUNT IS CLOSED'.
           05  FILLER  PIC X(4)  VALUE 'S003'.
           05  FILLER  PIC X(30) VALUE 'ACCOUNT IS CHARGED OFF'.
           05  FILLER  PIC X(4)  VALUE 'S004'.
           05  FILLER  PIC X(30) VALUE 'DEBIT TO FROZEN ACCOUNT'.
           05  FILLER  PIC X(4)  VALUE 'S005'.
           05  FILLER  PIC X(30) VALUE 'DUPLICATE TRANSACTION'.
       01  WS-REASON-TABLE REDEFINES WS-REASON-VALUES.
           05  WS-REASON-ENTRY             OCCURS 5 TIMES
                                           INDEXED BY WS-RSN-IDX.
               10  WS-REASON-CODE          PIC X(4).
               10  WS-REASON-TEXT          PIC X(30).
       01  WS-REASON-COUNTS.
           05  WS-REASON-COUNT             PIC S9(9) COMP-3
                                           OCCURS 5 TIMES.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  WS-DISPLAY-FIELDS.
           05  WS-DISPLAY-COUNT            PIC ZZZ,ZZZ,ZZ9.
           05  WS-DISPLAY-AMOUNT           PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.

           COPY CPENRREC.
           COPY CPACCREC.
           COPY CPRSTREC.
           COPY CPPSTREC.
           COPY CPSUSREC.
           COPY CPCTLREC.
           COPY CPDTPARM.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-POST-TRANSACTION
               UNTIL END-OF-INPUT
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           INITIALIZE WS-REASON-COUNTS
           MOVE 'CPPOST' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-OPEN-FILES
           PERFORM 1200-READ-CONTROL-CARDS
           PERFORM 1500-ESTABLISH-RUN-CONTROL
           PERFORM 2900-READ-INPUT.

       1100-OPEN-FILES.
           MOVE '1100-OPEN-FILES' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT ENRSORT-FILE
           IF NOT ENRSORT-OK
               MOVE 'ENRSORT' TO ERR-FILE
               MOVE WS-ENRSORT-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN I-O ACCTMAST-FILE
           IF NOT ACCTMAST-OK
               MOVE 'ACCTMAST' TO ERR-FILE
               MOVE WS-ACCTMAST-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN I-O RSTCTL-FILE
           IF RSTCTL-NOT-PRESENT
               OPEN OUTPUT RSTCTL-FILE
               CLOSE RSTCTL-FILE
               OPEN I-O RSTCTL-FILE
           END-IF
           IF NOT RSTCTL-OK
               MOVE 'RSTCTL' TO ERR-FILE
               MOVE WS-RSTCTL-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT POSTED-FILE
           IF NOT POSTED-OK
               MOVE 'POSTOUT' TO ERR-FILE
               MOVE WS-POSTED-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT SUSPENSE-FILE
           IF NOT SUSPENSE-OK
               MOVE 'SUSPENSE' TO ERR-FILE
               MOVE WS-SUSPENSE-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT CTL-FILE
           IF NOT CTL-OK
               MOVE 'CTLOUT' TO ERR-FILE
               MOVE WS-CTL-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF.

       1200-READ-CONTROL-CARDS.
           MOVE '1200-READ-CONTROL-CARDS' TO ERR-PARAGRAPH
           PERFORM 1210-READ-CARD
           PERFORM UNTIL CTLCARD-EOF
               IF CTLCARD-REC(1:1) NOT = '*'
                   PERFORM 1220-PARSE-CARD
               END-IF
               PERFORM 1210-READ-CARD
           END-PERFORM
           CLOSE CTLCARD-FILE
           SET DT-VALIDATE TO TRUE
           MOVE WS-BUS-DATE TO DT-DATE-1
           CALL 'CPDATEU' USING DT-PARMS
           IF WS-BUS-DATE = ZERO OR NOT DT-OK
               MOVE 'A VALID BUSDATE CONTROL CARD IS REQUIRED'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           IF WS-CHECKPOINT-INTERVAL = ZERO
               MOVE 'CHKPINT MUST BE GREATER THAN ZERO'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF.

       1210-READ-CARD.
           READ CTLCARD-FILE
           IF NOT CTLCARD-OK AND NOT CTLCARD-EOF
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       1220-PARSE-CARD.
           MOVE SPACES TO WS-CC-KEYWORD WS-CC-VALUE
           UNSTRING CTLCARD-REC DELIMITED BY '=' OR ALL SPACES
               INTO WS-CC-KEYWORD WS-CC-VALUE
           END-UNSTRING
           EVALUATE WS-CC-KEYWORD
               WHEN SPACES
                   CONTINUE
               WHEN 'BUSDATE'
                   IF WS-CC-VALUE(1:8) IS NUMERIC
                       MOVE WS-CC-VALUE(1:8) TO WS-BUS-DATE
                   ELSE
                       PERFORM 1290-INVALID-CARD
                   END-IF
               WHEN 'MODE'
                   MOVE WS-CC-VALUE TO WS-RUN-MODE
                   IF NOT MODE-NORMAL AND NOT MODE-RESTART
                       PERFORM 1290-INVALID-CARD
                   END-IF
               WHEN 'CHKPINT'
                   PERFORM 1230-NUMERIC-VALUE
                   IF WS-CC-NUMBER > 9999999
                       PERFORM 1290-INVALID-CARD
                   END-IF
                   MOVE WS-CC-NUMBER TO WS-CHECKPOINT-INTERVAL
               WHEN 'ABENDAT'
                   PERFORM 1230-NUMERIC-VALUE
                   MOVE WS-CC-NUMBER TO WS-ABEND-AT
               WHEN OTHER
                   PERFORM 1290-INVALID-CARD
           END-EVALUATE.

       1230-NUMERIC-VALUE.
           MOVE ZERO TO WS-CC-LENGTH
           INSPECT WS-CC-VALUE TALLYING WS-CC-LENGTH
               FOR CHARACTERS BEFORE INITIAL SPACE
           IF WS-CC-LENGTH = ZERO OR WS-CC-LENGTH > 9
               PERFORM 1290-INVALID-CARD
           END-IF
           IF WS-CC-VALUE(1:WS-CC-LENGTH) IS NOT NUMERIC
               PERFORM 1290-INVALID-CARD
           END-IF
           MOVE WS-CC-VALUE(1:WS-CC-LENGTH) TO WS-CC-NUMBER.

       1290-INVALID-CARD.
           MOVE SPACES TO ERR-MESSAGE
           STRING 'INVALID CONTROL CARD: ' CTLCARD-REC
                  DELIMITED BY SIZE
             INTO ERR-MESSAGE
           END-STRING
           PERFORM 9900-ABEND.

       1500-ESTABLISH-RUN-CONTROL.
           MOVE '1500-ESTABLISH-RUN-CONTROL' TO ERR-PARAGRAPH
           MOVE 'CPPOST' TO RF-KEY
           READ RSTCTL-FILE INTO RST-RECORD
           EVALUATE TRUE
               WHEN RSTCTL-OK
                   SET RUN-CONTROL-EXISTS TO TRUE
               WHEN RSTCTL-NOT-FOUND
                   SET RUN-CONTROL-NEW TO TRUE
               WHEN OTHER
                   MOVE 'RSTCTL' TO ERR-FILE
                   MOVE WS-RSTCTL-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE
           IF MODE-RESTART
               PERFORM 1520-START-RESTART-RUN
           ELSE
               PERFORM 1510-START-NORMAL-RUN
           END-IF.

       1510-START-NORMAL-RUN.
           IF RUN-CONTROL-EXISTS
               EVALUATE TRUE
                   WHEN RST-RUNNING
                       MOVE 'PRIOR RUN INCOMPLETE - USE MODE=RESTART'
                         TO ERR-MESSAGE
                       PERFORM 9900-ABEND
                   WHEN RST-BUS-DATE = WS-BUS-DATE
                       MOVE 'POSTING ALREADY COMPLETE FOR BUSDATE'
                         TO ERR-MESSAGE
                       PERFORM 9900-ABEND
                   WHEN RST-BUS-DATE > WS-BUS-DATE
                       MOVE 'BUSDATE PRECEDES LAST POSTED DATE'
                         TO ERR-MESSAGE
                       PERFORM 9900-ABEND
               END-EVALUATE
           END-IF
           MOVE SPACES TO RST-RECORD
           MOVE 'CPPOST' TO RST-KEY
           SET RST-RUNNING TO TRUE
           MOVE WS-BUS-DATE TO RST-BUS-DATE
           MOVE WS-CURR-DATE TO RST-START-DATE RST-CHKP-DATE
           MOVE WS-CURR-TIME TO RST-START-TIME RST-CHKP-TIME
           MOVE ZERO TO RST-RECS-READ
           MOVE 1 TO RST-RUN-COUNT
           IF RUN-CONTROL-EXISTS
               REWRITE RSTCTL-REC FROM RST-RECORD
           ELSE
               WRITE RSTCTL-REC FROM RST-RECORD
           END-IF
           IF NOT RSTCTL-OK
               MOVE 'RSTCTL' TO ERR-FILE
               MOVE WS-RSTCTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           DISPLAY 'CPPOST   NORMAL RUN FOR BUSINESS DATE '
                   WS-BUS-DATE.

       1520-START-RESTART-RUN.
           IF RUN-CONTROL-NEW OR NOT RST-RUNNING
               MOVE 'NO INCOMPLETE RUN FOUND - RESTART NOT VALID'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           IF RST-BUS-DATE NOT = WS-BUS-DATE
               MOVE 'BUSDATE DOES NOT MATCH THE INCOMPLETE RUN'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE RST-RECS-READ TO WS-CHKP-RECS
           MOVE RST-LAST-KEY TO WS-CHKP-KEY
           ADD 1 TO RST-RUN-COUNT
           REWRITE RSTCTL-REC FROM RST-RECORD
           IF NOT RSTCTL-OK
               MOVE 'RSTCTL' TO ERR-FILE
               MOVE WS-RSTCTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           MOVE WS-CHKP-RECS TO WS-DISPLAY-COUNT
           DISPLAY 'CPPOST   RESTART RUN FOR BUSINESS DATE '
                   WS-BUS-DATE
           DISPLAY 'CPPOST   LAST CHECKPOINT AT RECORD    '
                   WS-DISPLAY-COUNT
           DISPLAY 'CPPOST   LAST CHECKPOINT KEY          '
                   WS-CHKP-KEY.

       2000-POST-TRANSACTION.
           ADD 1 TO WS-READ-COUNT
           ADD ENR-AMOUNT TO WS-IN-AMOUNT
           PERFORM 2100-CHECK-SEQUENCE
           IF ENR-ACCT-NUM NOT = WS-CURR-ACCT
               PERFORM 2200-ACCOUNT-BREAK
           END-IF
           IF MODE-RESTART AND WS-READ-COUNT = WS-CHKP-RECS
               PERFORM 2150-VERIFY-CHECKPOINT
           END-IF
           PERFORM 2300-DETERMINE-DISPOSITION
           IF NO-SUSPENSE
               PERFORM 2400-POST-TO-ACCOUNT
           ELSE
               PERFORM 2600-WRITE-SUSPENSE
           END-IF
           ADD 1 TO WS-RECS-SINCE-CHKP
           MOVE WS-SORT-KEY TO WS-PREV-SORT-KEY
           IF WS-ABEND-AT > ZERO AND WS-READ-COUNT = WS-ABEND-AT
               MOVE '2000-POST-TRANSACTION' TO ERR-PARAGRAPH
               MOVE 'PROCESSING HALTED BY ABENDAT CONTROL CARD'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           PERFORM 2900-READ-INPUT.

       2100-CHECK-SEQUENCE.
           MOVE ENR-ACCT-NUM TO WS-SK-ACCT-NUM
           MOVE ENR-TRAN-DATE TO WS-SK-TRAN-DATE
           MOVE ENR-TRAN-TIME TO WS-SK-TRAN-TIME
           MOVE ENR-TRAN-ID TO WS-SK-TRAN-ID
           SET NOT-DUPLICATE TO TRUE
           EVALUATE TRUE
               WHEN WS-SORT-KEY < WS-PREV-SORT-KEY
                   MOVE '2100-CHECK-SEQUENCE' TO ERR-PARAGRAPH
                   MOVE 'INPUT NOT IN ACCOUNT/DATE/TIME/ID SEQUENCE'
                     TO ERR-MESSAGE
                   PERFORM 9900-ABEND
               WHEN WS-SORT-KEY = WS-PREV-SORT-KEY
                   SET DUPLICATE-TRANSACTION TO TRUE
           END-EVALUATE.

       2150-VERIFY-CHECKPOINT.
           IF WS-SORT-KEY NOT = WS-CHKP-KEY
               MOVE '2150-VERIFY-CHECKPOINT' TO ERR-PARAGRAPH
               DISPLAY 'CPPOST   CHECKPOINT KEY : ' WS-CHKP-KEY
               DISPLAY 'CPPOST   INPUT KEY      : ' WS-SORT-KEY
               MOVE 'INPUT FILE DOES NOT MATCH LAST CHECKPOINT'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           SET CHECKPOINT-VERIFIED TO TRUE
           DISPLAY 'CPPOST   CHECKPOINT POSITION VERIFIED'.

       2200-ACCOUNT-BREAK.
           PERFORM 2210-SAVE-ACCOUNT
           IF WS-RECS-SINCE-CHKP >= WS-CHECKPOINT-INTERVAL
               PERFORM 2250-TAKE-CHECKPOINT
           END-IF
           MOVE ENR-ACCT-NUM TO WS-CURR-ACCT
           PERFORM 2220-READ-ACCOUNT.

       2210-SAVE-ACCOUNT.
           IF ACCOUNT-CHANGED
               REWRITE ACCTMAST-REC FROM ACCT-RECORD
               IF NOT ACCTMAST-OK
                   MOVE '2210-SAVE-ACCOUNT' TO ERR-PARAGRAPH
                   MOVE 'ACCTMAST' TO ERR-FILE
                   MOVE WS-ACCTMAST-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
               END-IF
               ADD 1 TO WS-ACCTS-UPDATED
               SET ACCOUNT-UNCHANGED TO TRUE
           END-IF.

       2220-READ-ACCOUNT.
           MOVE ENR-ACCT-NUM TO AM-ACCT-NUM
           READ ACCTMAST-FILE INTO ACCT-RECORD
               KEY IS AM-ACCT-NUM
           EVALUATE TRUE
               WHEN ACCTMAST-OK
                   SET ACCOUNT-FOUND TO TRUE
               WHEN ACCTMAST-NOT-FOUND
                   SET ACCOUNT-NOT-FOUND TO TRUE
               WHEN OTHER
                   MOVE '2220-READ-ACCOUNT' TO ERR-PARAGRAPH
                   MOVE 'ACCTMAST' TO ERR-FILE
                   MOVE WS-ACCTMAST-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       2250-TAKE-CHECKPOINT.
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           COMPUTE RST-RECS-READ = WS-READ-COUNT - 1
           MOVE WS-PREV-SORT-KEY TO RST-LAST-KEY
           MOVE WS-CURR-DATE TO RST-CHKP-DATE
           MOVE WS-CURR-TIME TO RST-CHKP-TIME
           REWRITE RSTCTL-REC FROM RST-RECORD
           IF NOT RSTCTL-OK
               MOVE '2250-TAKE-CHECKPOINT' TO ERR-PARAGRAPH
               MOVE 'RSTCTL' TO ERR-FILE
               MOVE WS-RSTCTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           MOVE ZERO TO WS-RECS-SINCE-CHKP
           ADD 1 TO WS-CHECKPOINT-COUNT.

       2300-DETERMINE-DISPOSITION.
           MOVE SPACES TO WS-SUSPENSE-CODE
           EVALUATE TRUE
               WHEN DUPLICATE-TRANSACTION
                   MOVE 'S005' TO WS-SUSPENSE-CODE
               WHEN ACCOUNT-NOT-FOUND
                   MOVE 'S001' TO WS-SUSPENSE-CODE
               WHEN ACCT-CLOSED
                   MOVE 'S002' TO WS-SUSPENSE-CODE
               WHEN ACCT-WRITTEN-OFF
                   MOVE 'S003' TO WS-SUSPENSE-CODE
               WHEN ACCT-FROZEN AND ENR-DEBIT
                   MOVE 'S004' TO WS-SUSPENSE-CODE
           END-EVALUATE.

       2400-POST-TO-ACCOUNT.
           IF ACCT-HWM-BUS-DATE = WS-BUS-DATE
              AND WS-SK-POST-KEY NOT > ACCT-HWM-KEY
               MOVE SPACE TO WS-OVERLIMIT-FLAG
               MOVE 'R' TO WS-POST-STATUS
               ADD 1 TO WS-BYPASS-COUNT
           ELSE
               PERFORM 2410-APPLY-TRANSACTION
               MOVE 'P' TO WS-POST-STATUS
           END-IF
           PERFORM 2500-WRITE-POSTED.

       2410-APPLY-TRANSACTION.
           MOVE 'N' TO WS-OVERLIMIT-FLAG
           EVALUATE TRUE
               WHEN ENR-PURCHASE
                   ADD ENR-AMOUNT TO ACCT-CURR-BAL
                                     ACCT-CTD-PURCHASES
                   IF ACCT-CURR-BAL > ACCT-CREDIT-LIMIT
                       MOVE 'Y' TO WS-OVERLIMIT-FLAG
                   END-IF
               WHEN ENR-CASH-ADVANCE
                   ADD ENR-AMOUNT TO ACCT-CURR-BAL
                                     ACCT-CASH-BAL
                   IF ACCT-CASH-BAL > ACCT-CASH-LIMIT
                      OR ACCT-CURR-BAL > ACCT-CREDIT-LIMIT
                       MOVE 'Y' TO WS-OVERLIMIT-FLAG
                   END-IF
               WHEN ENR-REFUND
               WHEN ENR-REVERSAL
                   SUBTRACT ENR-AMOUNT FROM ACCT-CURR-BAL
                   ADD ENR-AMOUNT TO ACCT-CTD-CREDITS
           END-EVALUATE
           ADD 1 TO ACCT-CTD-TXN-COUNT
           MOVE WS-BUS-DATE TO ACCT-LAST-POST-DATE
                               ACCT-HWM-BUS-DATE
           MOVE WS-SK-POST-KEY TO ACCT-HWM-KEY
           SET ACCOUNT-CHANGED TO TRUE
           IF WS-OVERLIMIT-FLAG = 'Y'
               ADD 1 TO WS-OVERLIMIT-COUNT
           END-IF.

       2500-WRITE-POSTED.
           MOVE SPACES TO PST-RECORD
           MOVE ENR-RECORD TO PST-ENRICHED
           MOVE ACCT-PRODUCT TO PST-PRODUCT
           MOVE WS-BUS-DATE TO PST-POST-DATE
           MOVE ACCT-CURR-BAL TO PST-NEW-BALANCE
           MOVE WS-OVERLIMIT-FLAG TO PST-OVERLIMIT
           MOVE WS-POST-STATUS TO PST-POST-STATUS
           WRITE POSTED-REC FROM PST-RECORD
           IF NOT POSTED-OK
               MOVE '2500-WRITE-POSTED' TO ERR-PARAGRAPH
               MOVE 'POSTOUT' TO ERR-FILE
               MOVE WS-POSTED-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-POSTED-COUNT
           ADD ENR-AMOUNT TO WS-POSTED-AMOUNT.

       2600-WRITE-SUSPENSE.
           MOVE 'UNDEFINED REASON CODE' TO WS-SUSPENSE-TEXT
           SET WS-RSN-IDX TO 1
           SEARCH WS-REASON-ENTRY
               WHEN WS-REASON-CODE(WS-RSN-IDX) = WS-SUSPENSE-CODE
                   MOVE WS-REASON-TEXT(WS-RSN-IDX)
                     TO WS-SUSPENSE-TEXT
                   SET WS-RSN-SUB TO WS-RSN-IDX
                   ADD 1 TO WS-REASON-COUNT(WS-RSN-SUB)
           END-SEARCH
           MOVE SPACES TO SUS-RECORD
           MOVE ENR-RECORD TO SUS-ENRICHED
           MOVE WS-BUS-DATE TO SUS-BUS-DATE
           MOVE WS-SUSPENSE-CODE TO SUS-REASON-CODE
           MOVE WS-SUSPENSE-TEXT TO SUS-REASON-TEXT
           WRITE SUSPENSE-REC FROM SUS-RECORD
           IF NOT SUSPENSE-OK
               MOVE '2600-WRITE-SUSPENSE' TO ERR-PARAGRAPH
               MOVE 'SUSPENSE' TO ERR-FILE
               MOVE WS-SUSPENSE-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-SUSP-COUNT
           ADD ENR-AMOUNT TO WS-SUSP-AMOUNT.

       2900-READ-INPUT.
           READ ENRSORT-FILE INTO ENR-RECORD
           EVALUATE TRUE
               WHEN ENRSORT-OK
                   CONTINUE
               WHEN ENRSORT-EOF
                   SET END-OF-INPUT TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-INPUT' TO ERR-PARAGRAPH
                   MOVE 'ENRSORT' TO ERR-FILE
                   MOVE WS-ENRSORT-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           MOVE '3000-FINALIZE' TO ERR-PARAGRAPH
           PERFORM 2210-SAVE-ACCOUNT
           IF MODE-RESTART AND WS-CHKP-RECS > ZERO
              AND NOT CHECKPOINT-VERIFIED
               MOVE 'INPUT ENDED BEFORE THE LAST CHECKPOINT'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           PERFORM 3100-COMPLETE-RUN-CONTROL
           PERFORM 3200-WRITE-CONTROL-TOTALS
           CLOSE ENRSORT-FILE
                 ACCTMAST-FILE
                 RSTCTL-FILE
                 POSTED-FILE
                 SUSPENSE-FILE
                 CTL-FILE
           PERFORM 3300-DISPLAY-STATISTICS
           IF WS-SUSP-COUNT > ZERO
               MOVE 4 TO RETURN-CODE
           ELSE
               MOVE ZERO TO RETURN-CODE
           END-IF.

       3100-COMPLETE-RUN-CONTROL.
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           SET RST-COMPLETE TO TRUE
           MOVE WS-READ-COUNT TO RST-RECS-READ
           MOVE WS-PREV-SORT-KEY TO RST-LAST-KEY
           MOVE WS-CURR-DATE TO RST-CHKP-DATE
           MOVE WS-CURR-TIME TO RST-CHKP-TIME
           REWRITE RSTCTL-REC FROM RST-RECORD
           IF NOT RSTCTL-OK
               MOVE 'RSTCTL' TO ERR-FILE
               MOVE WS-RSTCTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       3200-WRITE-CONTROL-TOTALS.
           MOVE SPACES TO CTL-RECORD
           MOVE 'CPPOST' TO CTL-STEP
           MOVE WS-BUS-DATE TO CTL-BUS-DATE
           MOVE WS-READ-COUNT TO CTL-IN-COUNT
           MOVE WS-IN-AMOUNT TO CTL-IN-AMOUNT
           MOVE WS-POSTED-COUNT TO CTL-OUT-COUNT
           MOVE WS-POSTED-AMOUNT TO CTL-OUT-AMOUNT
           MOVE WS-SUSP-COUNT TO CTL-REJ-COUNT
           MOVE WS-SUSP-AMOUNT TO CTL-REJ-AMOUNT
           MOVE WS-CURR-DATE TO CTL-RUN-DATE
           MOVE WS-CURR-TIME TO CTL-RUN-TIME
           WRITE CTL-REC FROM CTL-RECORD
           IF NOT CTL-OK
               MOVE 'CTLOUT' TO ERR-FILE
               MOVE WS-CTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       3300-DISPLAY-STATISTICS.
           DISPLAY 'CPPOST   ACCOUNT POSTING SUMMARY'
           DISPLAY '  RUN MODE             ' WS-RUN-MODE
           MOVE WS-READ-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-IN-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS READ         ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-POSTED-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-POSTED-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS POSTED       ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-SUSP-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-SUSP-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS SUSPENDED    ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           PERFORM VARYING WS-RSN-SUB FROM 1 BY 1
                   UNTIL WS-RSN-SUB > 5
               IF WS-REASON-COUNT(WS-RSN-SUB) > ZERO
                   MOVE WS-REASON-COUNT(WS-RSN-SUB)
                     TO WS-DISPLAY-COUNT
                   DISPLAY '    ' WS-REASON-CODE(WS-RSN-SUB) ' '
                           WS-REASON-TEXT(WS-RSN-SUB)
                           WS-DISPLAY-COUNT
               END-IF
           END-PERFORM
           MOVE WS-BYPASS-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  PREVIOUSLY APPLIED   ' WS-DISPLAY-COUNT
           MOVE WS-ACCTS-UPDATED TO WS-DISPLAY-COUNT
           DISPLAY '  ACCOUNTS UPDATED     ' WS-DISPLAY-COUNT
           MOVE WS-OVERLIMIT-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  OVERLIMIT POSTINGS   ' WS-DISPLAY-COUNT
           MOVE WS-CHECKPOINT-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  CHECKPOINTS TAKEN    ' WS-DISPLAY-COUNT.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
