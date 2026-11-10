       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPFEEUNL.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT FEESCHED-FILE ASSIGN TO FEESCHED
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FEESCHED-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CTLCARD-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  CTLCARD-REC                     PIC X(80).
       FD  FEESCHED-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  FEESCHED-REC                    PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05  WS-CTLCARD-STATUS           PIC X(2).
               88  CTLCARD-OK              VALUE '00'.
               88  CTLCARD-EOF             VALUE '10'.
           05  WS-FEESCHED-STATUS          PIC X(2).
               88  FEESCHED-OK             VALUE '00'.

       01  WS-SWITCHES.
           05  WS-CURSOR-EOF-SW            PIC X VALUE 'N'.
               88  END-OF-CURSOR           VALUE 'Y'.
           05  WS-CURSOR-OPEN-SW           PIC X VALUE 'N'.
               88  CURSOR-IS-OPEN          VALUE 'Y'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-BUS-DATE                     PIC 9(8) VALUE ZERO.
       01  WS-BUS-DATE-R REDEFINES WS-BUS-DATE.
           05  WS-BUS-CCYY                 PIC X(4).
           05  WS-BUS-MM                   PIC X(2).
           05  WS-BUS-DD                   PIC X(2).
       01  WS-BUS-DATE-ISO                 PIC X(10).
       01  WS-PREV-KEY                     PIC X(11) VALUE LOW-VALUES.
       01  WS-EFF-DATE                     PIC X(8).
       01  WS-ROW-COUNT                    PIC S9(7) COMP-3 VALUE 0.
       01  WS-DISPLAY-COUNT                PIC ZZZ,ZZ9.

       01  WS-SQLCODE-DISPLAY              PIC -(8)9.
       01  WS-DSNTIAR-MESSAGE.
           05  WS-DSNTIAR-LENGTH           PIC S9(4) COMP VALUE +960.
           05  WS-DSNTIAR-LINE             PIC X(120)
                                           OCCURS 8 TIMES
                                           INDEXED BY WS-MSG-IDX.
       01  WS-DSNTIAR-LINE-LENGTH          PIC S9(9) COMP VALUE +120.

           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE DCLFEE END-EXEC.

           COPY CPFEEREC.
           COPY CPDTPARM.
           COPY CPERRWS.

           EXEC SQL DECLARE FEE_CSR CURSOR FOR
               SELECT NETWORK,
                      PRODUCT,
                      MCC_CLASS,
                      PRESENCE,
                      RATE,
                      PER_ITEM,
                      MAX_FEE,
                      CHAR(EFF_DATE, ISO)
                 FROM CP_FEE_SCHEDULE
                WHERE EFF_DATE <= DATE(:WS-BUS-DATE-ISO)
                  AND (END_DATE IS NULL
                       OR END_DATE > DATE(:WS-BUS-DATE-ISO))
                ORDER BY NETWORK, PRODUCT, MCC_CLASS, PRESENCE
                 WITH UR
           END-EXEC.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-UNLOAD-FEE-ROW
               UNTIL END-OF-CURSOR
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           MOVE 'CPFEEUNL' TO ERR-PROGRAM
           PERFORM 1100-READ-CONTROL-CARDS
           STRING WS-BUS-CCYY '-' WS-BUS-MM '-' WS-BUS-DD
                  DELIMITED BY SIZE
             INTO WS-BUS-DATE-ISO
           END-STRING
           OPEN OUTPUT FEESCHED-FILE
           IF NOT FEESCHED-OK
               MOVE '1000-INITIALIZE' TO ERR-PARAGRAPH
               MOVE 'FEESCHED' TO ERR-FILE
               MOVE WS-FEESCHED-STATUS TO ERR-STATUS
               MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           EXEC SQL OPEN FEE_CSR END-EXEC
           IF SQLCODE NOT = ZERO
               MOVE '1000-INITIALIZE' TO ERR-PARAGRAPH
               MOVE 'OPEN CURSOR FEE_CSR FAILED' TO ERR-MESSAGE
               PERFORM 9800-SQL-ERROR
           END-IF
           SET CURSOR-IS-OPEN TO TRUE
           PERFORM 2900-FETCH-FEE-ROW.

       1100-READ-CONTROL-CARDS.
           MOVE '1100-READ-CONTROL-CARDS' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           READ CTLCARD-FILE
           PERFORM UNTIL CTLCARD-EOF
               MOVE SPACES TO WS-CC-KEYWORD WS-CC-VALUE
               UNSTRING CTLCARD-REC DELIMITED BY '=' OR ALL SPACES
                   INTO WS-CC-KEYWORD WS-CC-VALUE
               END-UNSTRING
               IF WS-CC-KEYWORD = 'BUSDATE'
                  AND WS-CC-VALUE(1:8) IS NUMERIC
                   MOVE WS-CC-VALUE(1:8) TO WS-BUS-DATE
               END-IF
               READ CTLCARD-FILE
           END-PERFORM
           CLOSE CTLCARD-FILE
           SET DT-VALIDATE TO TRUE
           MOVE WS-BUS-DATE TO DT-DATE-1
           CALL 'CPDATEU' USING DT-PARMS
           IF WS-BUS-DATE = ZERO OR NOT DT-OK
               MOVE 'A VALID BUSDATE CONTROL CARD IS REQUIRED'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF.

       2000-UNLOAD-FEE-ROW.
           MOVE SPACES TO FS-RECORD
           MOVE HV-FEE-NETWORK TO FS-NETWORK
           MOVE HV-FEE-PRODUCT TO FS-PRODUCT
           MOVE HV-FEE-MCC-CLASS TO FS-MCC-CLASS
           MOVE HV-FEE-PRESENCE TO FS-PRESENCE
           IF FS-KEY = WS-PREV-KEY
               MOVE '2000-UNLOAD-FEE-ROW' TO ERR-PARAGRAPH
               DISPLAY 'CPFEEUNL OVERLAPPING EFFECTIVE ROWS ' FS-KEY
               MOVE 'FEE SCHEDULE HAS OVERLAPPING EFFECTIVE DATES'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE FS-KEY TO WS-PREV-KEY
           MOVE HV-FEE-RATE TO FS-RATE
           MOVE HV-FEE-PER-ITEM TO FS-PER-ITEM
           MOVE HV-FEE-MAX-FEE TO FS-MAX-FEE
           STRING HV-FEE-EFF-DATE(1:4)
                  HV-FEE-EFF-DATE(6:2)
                  HV-FEE-EFF-DATE(9:2)
                  DELIMITED BY SIZE
             INTO WS-EFF-DATE
           END-STRING
           MOVE WS-EFF-DATE TO FS-EFF-DATE
           WRITE FEESCHED-REC FROM FS-RECORD
           IF NOT FEESCHED-OK
               MOVE '2000-UNLOAD-FEE-ROW' TO ERR-PARAGRAPH
               MOVE 'FEESCHED' TO ERR-FILE
               MOVE WS-FEESCHED-STATUS TO ERR-STATUS
               MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           ADD 1 TO WS-ROW-COUNT
           PERFORM 2900-FETCH-FEE-ROW.

       2900-FETCH-FEE-ROW.
           EXEC SQL
               FETCH FEE_CSR
                INTO :HV-FEE-NETWORK,
                     :HV-FEE-PRODUCT,
                     :HV-FEE-MCC-CLASS,
                     :HV-FEE-PRESENCE,
                     :HV-FEE-RATE,
                     :HV-FEE-PER-ITEM,
                     :HV-FEE-MAX-FEE,
                     :HV-FEE-EFF-DATE
           END-EXEC
           EVALUATE SQLCODE
               WHEN ZERO
                   CONTINUE
               WHEN +100
                   SET END-OF-CURSOR TO TRUE
               WHEN OTHER
                   MOVE '2900-FETCH-FEE-ROW' TO ERR-PARAGRAPH
                   MOVE 'FETCH FROM FEE_CSR FAILED' TO ERR-MESSAGE
                   PERFORM 9800-SQL-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           EXEC SQL CLOSE FEE_CSR END-EXEC
           CLOSE FEESCHED-FILE
           IF WS-ROW-COUNT = ZERO
               MOVE '3000-FINALIZE' TO ERR-PARAGRAPH
               MOVE 'NO EFFECTIVE FEE SCHEDULE ROWS FOUND'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE WS-ROW-COUNT TO WS-DISPLAY-COUNT
           DISPLAY 'CPFEEUNL FEE SCHEDULE UNLOAD COMPLETE'
           DISPLAY '  BUSINESS DATE        ' WS-BUS-DATE-ISO
           DISPLAY '  ROWS UNLOADED        ' WS-DISPLAY-COUNT
           MOVE ZERO TO RETURN-CODE.

       9800-SQL-ERROR.
           MOVE SQLCODE TO WS-SQLCODE-DISPLAY
           DISPLAY 'CPFEEUNL SQLCODE ' WS-SQLCODE-DISPLAY
                   ' SQLSTATE ' SQLSTATE
           CALL 'DSNTIAR' USING SQLCA
                                WS-DSNTIAR-MESSAGE
                                WS-DSNTIAR-LINE-LENGTH
           PERFORM VARYING WS-MSG-IDX FROM 1 BY 1
                   UNTIL WS-MSG-IDX > 8
               IF WS-DSNTIAR-LINE(WS-MSG-IDX) NOT = SPACES
                   DISPLAY WS-DSNTIAR-LINE(WS-MSG-IDX)
               END-IF
           END-PERFORM
           IF CURSOR-IS-OPEN
               EXEC SQL CLOSE FEE_CSR END-EXEC
           END-IF
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
