       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPMSTLD.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT ACCTIN-FILE ASSIGN TO ACCTIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-INPUT-STATUS.
           SELECT CARDIN-FILE ASSIGN TO CARDIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-INPUT-STATUS.
           SELECT MERCHIN-FILE ASSIGN TO MERCHIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-INPUT-STATUS.
           SELECT ACCTMAST-FILE ASSIGN TO ACCTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AM-ACCT-NUM
               ALTERNATE RECORD KEY IS AM-CUST-ID WITH DUPLICATES
               FILE STATUS IS WS-MASTER-STATUS.
           SELECT CARDXREF-FILE ASSIGN TO CARDXREF
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS XF-CARD-NUM
               FILE STATUS IS WS-MASTER-STATUS.
           SELECT MERCHMST-FILE ASSIGN TO MERCHMST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS MF-MERCH-ID
               FILE STATUS IS WS-MASTER-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CTLCARD-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  CTLCARD-REC                     PIC X(80).
       FD  ACCTIN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  ACCTIN-REC                      PIC X(200).
       FD  CARDIN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 50 CHARACTERS.
       01  CARDIN-REC                      PIC X(50).
       FD  MERCHIN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 100 CHARACTERS.
       01  MERCHIN-REC                     PIC X(100).
       FD  ACCTMAST-FILE
           RECORD CONTAINS 200 CHARACTERS.
       01  ACCTMAST-REC.
           05  AM-ACCT-NUM                 PIC X(12).
           05  AM-CUST-ID                  PIC X(10).
           05  FILLER                      PIC X(178).
       FD  CARDXREF-FILE
           RECORD CONTAINS 50 CHARACTERS.
       01  CARDXREF-REC.
           05  XF-CARD-NUM                 PIC X(16).
           05  FILLER                      PIC X(34).
       FD  MERCHMST-FILE
           RECORD CONTAINS 100 CHARACTERS.
       01  MERCHMST-REC.
           05  MF-MERCH-ID                 PIC X(15).
           05  FILLER                      PIC X(85).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05  WS-CTLCARD-STATUS           PIC X(2).
               88  CTLCARD-OK              VALUE '00'.
               88  CTLCARD-EOF             VALUE '10'.
           05  WS-INPUT-STATUS             PIC X(2).
               88  INPUT-OK                VALUE '00'.
               88  INPUT-EOF               VALUE '10'.
           05  WS-MASTER-STATUS            PIC X(2).
               88  MASTER-OK               VALUE '00' '02'.
               88  MASTER-SEQUENCE-ERROR   VALUE '21'.
               88  MASTER-DUPLICATE-KEY    VALUE '22'.

       01  WS-SWITCHES.
           05  WS-INPUT-EOF-SW             PIC X VALUE 'N'.
               88  END-OF-INPUT            VALUE 'Y'.
           05  WS-RECORD-SW                PIC X.
               88  RECORD-VALID            VALUE 'Y'.
               88  RECORD-INVALID          VALUE 'N'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-LOAD-TYPE                    PIC X(10) VALUE SPACES.
           88  LOAD-ACCOUNTS               VALUE 'ACCOUNTS'.
           88  LOAD-CARDS                  VALUE 'CARDS'.
           88  LOAD-MERCHANTS              VALUE 'MERCHANTS'.
           88  LOAD-TYPE-VALID             VALUE 'ACCOUNTS' 'CARDS'
                                                 'MERCHANTS'.

       01  WS-RECORD-KEY                   PIC X(16).
       01  WS-REJECT-REASON                PIC X(40).

       01  WS-COUNTERS.
           05  WS-READ-COUNT               PIC S9(9) COMP-3 VALUE 0.
           05  WS-LOAD-COUNT               PIC S9(9) COMP-3 VALUE 0.
           05  WS-REJECT-COUNT             PIC S9(9) COMP-3 VALUE 0.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  WS-DISPLAY-COUNT                PIC ZZZ,ZZZ,ZZ9.

           COPY CPACCEXT.
           COPY CPACCREC.
           COPY CPXRFREC.
           COPY CPMERREC.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-LOAD-RECORD
               UNTIL END-OF-INPUT
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           MOVE 'CPMSTLD' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-READ-CONTROL-CARDS
           PERFORM 1200-OPEN-FILES
           PERFORM 2900-READ-INPUT.

       1100-READ-CONTROL-CARDS.
           MOVE '1100-READ-CONTROL-CARDS' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           PERFORM 1110-READ-CARD
           PERFORM UNTIL CTLCARD-EOF
               IF CTLCARD-REC(1:1) NOT = '*'
                   PERFORM 1120-PARSE-CARD
               END-IF
               PERFORM 1110-READ-CARD
           END-PERFORM
           CLOSE CTLCARD-FILE
           IF NOT LOAD-TYPE-VALID
               MOVE 'LOAD CARD MUST BE ACCOUNTS, CARDS OR MERCHANTS'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           DISPLAY 'CPMSTLD  LOADING ' WS-LOAD-TYPE.

       1110-READ-CARD.
           READ CTLCARD-FILE
           IF NOT CTLCARD-OK AND NOT CTLCARD-EOF
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       1120-PARSE-CARD.
           MOVE SPACES TO WS-CC-KEYWORD WS-CC-VALUE
           UNSTRING CTLCARD-REC DELIMITED BY '=' OR ALL SPACES
               INTO WS-CC-KEYWORD WS-CC-VALUE
           END-UNSTRING
           EVALUATE WS-CC-KEYWORD
               WHEN SPACES
                   CONTINUE
               WHEN 'LOAD'
                   MOVE WS-CC-VALUE TO WS-LOAD-TYPE
               WHEN OTHER
                   MOVE SPACES TO ERR-MESSAGE
                   STRING 'UNRECOGNIZED CONTROL CARD KEYWORD '
                          WS-CC-KEYWORD DELIMITED BY SIZE
                     INTO ERR-MESSAGE
                   END-STRING
                   PERFORM 9900-ABEND
           END-EVALUATE.

       1200-OPEN-FILES.
           MOVE '1200-OPEN-FILES' TO ERR-PARAGRAPH
           EVALUATE TRUE
               WHEN LOAD-ACCOUNTS
                   OPEN INPUT ACCTIN-FILE
                   MOVE 'ACCTIN' TO ERR-FILE
               WHEN LOAD-CARDS
                   OPEN INPUT CARDIN-FILE
                   MOVE 'CARDIN' TO ERR-FILE
               WHEN LOAD-MERCHANTS
                   OPEN INPUT MERCHIN-FILE
                   MOVE 'MERCHIN' TO ERR-FILE
           END-EVALUATE
           IF NOT INPUT-OK
               MOVE WS-INPUT-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           EVALUATE TRUE
               WHEN LOAD-ACCOUNTS
                   OPEN OUTPUT ACCTMAST-FILE
                   MOVE 'ACCTMAST' TO ERR-FILE
               WHEN LOAD-CARDS
                   OPEN OUTPUT CARDXREF-FILE
                   MOVE 'CARDXREF' TO ERR-FILE
               WHEN LOAD-MERCHANTS
                   OPEN OUTPUT MERCHMST-FILE
                   MOVE 'MERCHMST' TO ERR-FILE
           END-EVALUATE
           IF NOT MASTER-OK
               MOVE WS-MASTER-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           MOVE SPACES TO ERR-FILE.

       2000-LOAD-RECORD.
           ADD 1 TO WS-READ-COUNT
           SET RECORD-VALID TO TRUE
           EVALUATE TRUE
               WHEN LOAD-ACCOUNTS
                   PERFORM 2100-LOAD-ACCOUNT
               WHEN LOAD-CARDS
                   PERFORM 2200-LOAD-CARD
               WHEN LOAD-MERCHANTS
                   PERFORM 2300-LOAD-MERCHANT
           END-EVALUATE
           IF RECORD-VALID
               PERFORM 2500-CHECK-WRITE-STATUS
           ELSE
               PERFORM 2600-REJECT-RECORD
           END-IF
           PERFORM 2900-READ-INPUT.

       2100-LOAD-ACCOUNT.
           MOVE AX-ACCT-NUM TO WS-RECORD-KEY
           MOVE AX-STATUS TO ACCT-STATUS
           EVALUATE TRUE
               WHEN AX-ACCT-NUM = SPACES
                   MOVE 'ACCOUNT NUMBER IS BLANK' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
               WHEN NOT ACCT-VALID-STATUS
                   MOVE 'ACCOUNT STATUS IS INVALID' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
               WHEN AX-CREDIT-LIMIT IS NOT NUMERIC
               WHEN AX-CASH-LIMIT IS NOT NUMERIC
               WHEN AX-CURR-BAL IS NOT NUMERIC
               WHEN AX-CASH-BAL IS NOT NUMERIC
               WHEN AX-CTD-PURCHASES IS NOT NUMERIC
               WHEN AX-CTD-CREDITS IS NOT NUMERIC
               WHEN AX-CTD-TXN-COUNT IS NOT NUMERIC
               WHEN AX-OPEN-DATE IS NOT NUMERIC
               WHEN AX-LAST-POST-DATE IS NOT NUMERIC
                   MOVE 'NON-NUMERIC MONETARY OR DATE FIELD'
                     TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
           END-EVALUATE
           IF RECORD-VALID
               MOVE SPACES TO ACCT-RECORD
               MOVE AX-ACCT-NUM TO ACCT-NUM
               MOVE AX-CUST-ID TO ACCT-CUST-ID
               MOVE AX-PRODUCT TO ACCT-PRODUCT
               MOVE AX-STATUS TO ACCT-STATUS
               MOVE AX-OPEN-DATE TO ACCT-OPEN-DATE
               MOVE AX-CREDIT-LIMIT TO ACCT-CREDIT-LIMIT
               MOVE AX-CASH-LIMIT TO ACCT-CASH-LIMIT
               MOVE AX-CURR-BAL TO ACCT-CURR-BAL
               MOVE AX-CASH-BAL TO ACCT-CASH-BAL
               MOVE AX-CTD-PURCHASES TO ACCT-CTD-PURCHASES
               MOVE AX-CTD-CREDITS TO ACCT-CTD-CREDITS
               MOVE AX-CTD-TXN-COUNT TO ACCT-CTD-TXN-COUNT
               MOVE AX-LAST-POST-DATE TO ACCT-LAST-POST-DATE
               MOVE ZERO TO ACCT-HWM-BUS-DATE
               MOVE SPACES TO ACCT-HWM-KEY
               MOVE WS-CURR-DATE TO ACCT-LAST-MAINT-DATE
               MOVE 'CPMSTLD' TO ACCT-LAST-MAINT-USER
               WRITE ACCTMAST-REC FROM ACCT-RECORD
           END-IF.

       2200-LOAD-CARD.
           MOVE XRF-CARD-NUM TO WS-RECORD-KEY
           EVALUATE TRUE
               WHEN XRF-CARD-NUM IS NOT NUMERIC
                   MOVE 'CARD NUMBER IS NOT NUMERIC'
                     TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
               WHEN XRF-ACCT-NUM = SPACES
                   MOVE 'ACCOUNT NUMBER IS BLANK' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
               WHEN XRF-EXPIRY IS NOT NUMERIC
                   MOVE 'EXPIRY IS NOT NUMERIC' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
           END-EVALUATE
           IF RECORD-VALID
               WRITE CARDXREF-REC FROM XRF-RECORD
           END-IF.

       2300-LOAD-MERCHANT.
           MOVE MER-MERCH-ID TO WS-RECORD-KEY
           EVALUATE TRUE
               WHEN MER-MERCH-ID = SPACES
                   MOVE 'MERCHANT ID IS BLANK' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
               WHEN MER-MCC IS NOT NUMERIC
                   MOVE 'MCC IS NOT NUMERIC' TO WS-REJECT-REASON
                   SET RECORD-INVALID TO TRUE
           END-EVALUATE
           IF RECORD-VALID
               WRITE MERCHMST-REC FROM MER-RECORD
           END-IF.

       2500-CHECK-WRITE-STATUS.
           EVALUATE TRUE
               WHEN MASTER-OK
                   ADD 1 TO WS-LOAD-COUNT
               WHEN MASTER-SEQUENCE-ERROR
                   MOVE 'KEY OUT OF SEQUENCE' TO WS-REJECT-REASON
                   PERFORM 2600-REJECT-RECORD
               WHEN MASTER-DUPLICATE-KEY
                   MOVE 'DUPLICATE KEY' TO WS-REJECT-REASON
                   PERFORM 2600-REJECT-RECORD
               WHEN OTHER
                   MOVE '2500-CHECK-WRITE-STATUS' TO ERR-PARAGRAPH
                   MOVE WS-LOAD-TYPE TO ERR-FILE
                   MOVE WS-MASTER-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       2600-REJECT-RECORD.
           ADD 1 TO WS-REJECT-COUNT
           DISPLAY 'CPMSTLD  REJECTED ' WS-RECORD-KEY ' '
                   WS-REJECT-REASON.

       2900-READ-INPUT.
           EVALUATE TRUE
               WHEN LOAD-ACCOUNTS
                   READ ACCTIN-FILE INTO AX-RECORD
               WHEN LOAD-CARDS
                   READ CARDIN-FILE INTO XRF-RECORD
               WHEN LOAD-MERCHANTS
                   READ MERCHIN-FILE INTO MER-RECORD
           END-EVALUATE
           EVALUATE TRUE
               WHEN INPUT-OK
                   CONTINUE
               WHEN INPUT-EOF
                   SET END-OF-INPUT TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-INPUT' TO ERR-PARAGRAPH
                   MOVE WS-LOAD-TYPE TO ERR-FILE
                   MOVE WS-INPUT-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           EVALUATE TRUE
               WHEN LOAD-ACCOUNTS
                   CLOSE ACCTIN-FILE ACCTMAST-FILE
               WHEN LOAD-CARDS
                   CLOSE CARDIN-FILE CARDXREF-FILE
               WHEN LOAD-MERCHANTS
                   CLOSE MERCHIN-FILE MERCHMST-FILE
           END-EVALUATE
           DISPLAY 'CPMSTLD  MASTER FILE LOAD SUMMARY'
           MOVE WS-READ-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  RECORDS READ         ' WS-DISPLAY-COUNT
           MOVE WS-LOAD-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  RECORDS LOADED       ' WS-DISPLAY-COUNT
           MOVE WS-REJECT-COUNT TO WS-DISPLAY-COUNT
           DISPLAY '  RECORDS REJECTED     ' WS-DISPLAY-COUNT
           IF WS-REJECT-COUNT > ZERO
               MOVE 4 TO RETURN-CODE
           ELSE
               MOVE ZERO TO RETURN-CODE
           END-IF.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
