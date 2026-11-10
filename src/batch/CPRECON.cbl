       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPRECON.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT CTLIN-FILE ASSIGN TO CTLIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLIN-STATUS.
           SELECT REPORT-FILE ASSIGN TO RECONRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CTLCARD-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  CTLCARD-REC                     PIC X(80).
       FD  CTLIN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 120 CHARACTERS.
       01  CTLIN-REC                       PIC X(120).
       FD  REPORT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 133 CHARACTERS.
       01  REPORT-REC                      PIC X(133).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUSES.
           05  WS-CTLCARD-STATUS           PIC X(2).
               88  CTLCARD-OK              VALUE '00'.
               88  CTLCARD-EOF             VALUE '10'.
           05  WS-CTLIN-STATUS             PIC X(2).
               88  CTLIN-OK                VALUE '00'.
               88  CTLIN-EOF               VALUE '10'.
           05  WS-REPORT-STATUS            PIC X(2).
               88  REPORT-OK               VALUE '00'.

       01  WS-SWITCHES.
           05  WS-CTLIN-EOF-SW             PIC X VALUE 'N'.
               88  END-OF-CTLIN            VALUE 'Y'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-BUS-DATE                     PIC 9(8) VALUE ZERO.

       01  WS-STEP-NUMBERS.
           05  WS-VALID                    PIC S9(4) COMP VALUE 1.
           05  WS-ENRICH                   PIC S9(4) COMP VALUE 2.
           05  WS-POST                     PIC S9(4) COMP VALUE 3.
           05  WS-FEECAL                   PIC S9(4) COMP VALUE 4.
           05  WS-SETTLE                   PIC S9(4) COMP VALUE 5.
           05  WS-STEP-COUNT               PIC S9(4) COMP VALUE 5.
       01  WS-STEP-SUB                     PIC S9(4) COMP.

       01  WS-STEP-NAME-VALUES             PIC X(40) VALUE
           'CPVALID CPENRICHCPPOST  CPFEECALCPSETTLE'.
       01  WS-STEP-NAME-TABLE REDEFINES WS-STEP-NAME-VALUES.
           05  WS-STEP-NAME-VALUE          PIC X(8) OCCURS 5 TIMES.

       01  WS-STEP-TABLE.
           05  WS-STEP-ENTRY               OCCURS 5 TIMES
                                           INDEXED BY WS-STEP-IDX.
               10  WS-STEP-NAME            PIC X(8).
               10  WS-STEP-LOADED          PIC X.
                   88  STEP-LOADED         VALUE 'Y'.
                   88  STEP-NOT-LOADED     VALUE 'N'.
               10  WS-STEP-IN-COUNT        PIC S9(9) COMP-3.
               10  WS-STEP-IN-AMOUNT       PIC S9(13)V99 COMP-3.
               10  WS-STEP-OUT-COUNT       PIC S9(9) COMP-3.
               10  WS-STEP-OUT-AMOUNT      PIC S9(13)V99 COMP-3.
               10  WS-STEP-REJ-COUNT       PIC S9(9) COMP-3.
               10  WS-STEP-REJ-AMOUNT      PIC S9(13)V99 COMP-3.

       01  WS-CHECK-FIELDS.
           05  WS-CHECK-NUMBER             PIC S9(4) COMP VALUE 0.
           05  WS-CHECK-DESC               PIC X(46).
           05  WS-EXP-COUNT                PIC S9(9) COMP-3.
           05  WS-ACT-COUNT                PIC S9(9) COMP-3.
           05  WS-EXP-AMOUNT               PIC S9(13)V99 COMP-3.
           05  WS-ACT-AMOUNT               PIC S9(13)V99 COMP-3.

       01  WS-RESULT-COUNTERS.
           05  WS-CHECKS-PASSED            PIC S9(4) COMP VALUE 0.
           05  WS-CHECKS-FAILED            PIC S9(4) COMP VALUE 0.
           05  WS-DATA-ERRORS              PIC S9(4) COMP VALUE 0.
           05  WS-CTL-RECORDS              PIC S9(4) COMP VALUE 0.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  RPT-TITLE.
           05  FILLER                      PIC X     VALUE '1'.
           05  FILLER                      PIC X(10) VALUE 'CPRECON'.
           05  FILLER                      PIC X(46) VALUE
               'CLEARPOINT DAILY CYCLE RECONCILIATION'.
           05  FILLER                      PIC X(15)
                                           VALUE 'BUSINESS DATE'.
           05  RT-BUS-DATE                 PIC 9999/99/99.
           05  FILLER                      PIC X(10) VALUE SPACES.
           05  FILLER                      PIC X(9)  VALUE 'RUN DATE'.
           05  RT-RUN-DATE                 PIC 9999/99/99.
           05  FILLER                      PIC X(22) VALUE SPACES.

       01  RPT-COLUMNS.
           05  FILLER                      PIC X     VALUE '0'.
           05  FILLER                      PIC X(4)  VALUE 'NO'.
           05  FILLER                      PIC X(46) VALUE
               'RECONCILIATION RULE'.
           05  FILLER                      PIC X(13) VALUE
               '    EXP COUNT'.
           05  FILLER                      PIC X(13) VALUE
               '    ACT COUNT'.
           05  FILLER                      PIC X(22) VALUE
               '     EXPECTED AMOUNT  '.
           05  FILLER                      PIC X(22) VALUE
               '       ACTUAL AMOUNT  '.
           05  FILLER                      PIC X(12) VALUE 'RESULT'.

       01  RPT-UNDERLINE.
           05  FILLER                      PIC X     VALUE SPACE.
           05  FILLER                      PIC X(132) VALUE ALL '-'.

       01  RPT-DETAIL.
           05  RD-ASA                      PIC X.
           05  RD-CHECK-NUMBER             PIC Z9.
           05  FILLER                      PIC X(2).
           05  RD-DESCRIPTION              PIC X(46).
           05  RD-EXP-COUNT                PIC ZZZ,ZZZ,ZZ9.
           05  FILLER                      PIC X(2).
           05  RD-ACT-COUNT                PIC ZZZ,ZZZ,ZZ9.
           05  FILLER                      PIC X(2).
           05  RD-EXP-AMOUNT               PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                      PIC X(2).
           05  RD-ACT-AMOUNT               PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                      PIC X(2).
           05  RD-RESULT                   PIC X(12).

       01  RPT-MESSAGE.
           05  RM-ASA                      PIC X.
           05  FILLER                      PIC X(4) VALUE SPACES.
           05  RM-TEXT                     PIC X(128).

           COPY CPCTLREC.
           COPY CPDTPARM.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-LOAD-CONTROL-TOTALS
               UNTIL END-OF-CTLIN
           PERFORM 2500-CHECK-COMPLETENESS
           IF WS-DATA-ERRORS = ZERO
               PERFORM 3000-RECONCILE
           END-IF
           PERFORM 4000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           MOVE 'CPRECON' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-OPEN-FILES
           PERFORM 1200-READ-CONTROL-CARDS
           PERFORM 1300-INITIALIZE-STEP-TABLE
           PERFORM 1400-WRITE-HEADINGS
           PERFORM 2900-READ-CTLIN.

       1100-OPEN-FILES.
           MOVE '1100-OPEN-FILES' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT CTLIN-FILE
           IF NOT CTLIN-OK
               MOVE 'CTLIN' TO ERR-FILE
               MOVE WS-CTLIN-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT REPORT-FILE
           IF NOT REPORT-OK
               MOVE 'RECONRPT' TO ERR-FILE
               MOVE WS-REPORT-STATUS TO ERR-STATUS
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
                       MOVE 'BUSDATE VALUE MUST BE CCYYMMDD'
                         TO ERR-MESSAGE
                       PERFORM 9900-ABEND
                   END-IF
               WHEN OTHER
                   MOVE SPACES TO ERR-MESSAGE
                   STRING 'UNRECOGNIZED CONTROL CARD KEYWORD '
                          WS-CC-KEYWORD DELIMITED BY SIZE
                     INTO ERR-MESSAGE
                   END-STRING
                   PERFORM 9900-ABEND
           END-EVALUATE.

       1300-INITIALIZE-STEP-TABLE.
           INITIALIZE WS-STEP-TABLE
           PERFORM VARYING WS-STEP-SUB FROM 1 BY 1
                   UNTIL WS-STEP-SUB > WS-STEP-COUNT
               MOVE WS-STEP-NAME-VALUE(WS-STEP-SUB)
                 TO WS-STEP-NAME(WS-STEP-SUB)
               SET STEP-NOT-LOADED(WS-STEP-SUB) TO TRUE
           END-PERFORM.

       1400-WRITE-HEADINGS.
           MOVE WS-BUS-DATE TO RT-BUS-DATE
           MOVE WS-CURR-DATE TO RT-RUN-DATE
           MOVE RPT-TITLE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE RPT-COLUMNS TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE RPT-UNDERLINE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT.

       2000-LOAD-CONTROL-TOTALS.
           ADD 1 TO WS-CTL-RECORDS
           SET WS-STEP-IDX TO 1
           SEARCH WS-STEP-ENTRY
               AT END
                   MOVE SPACES TO RM-TEXT
                   STRING 'UNEXPECTED CONTROL RECORD FOR STEP '
                          CTL-STEP DELIMITED BY SIZE
                     INTO RM-TEXT
                   END-STRING
                   PERFORM 8100-WRITE-ERROR-MESSAGE
               WHEN WS-STEP-NAME(WS-STEP-IDX) = CTL-STEP
                   PERFORM 2100-STORE-CONTROL-TOTALS
           END-SEARCH
           PERFORM 2900-READ-CTLIN.

       2100-STORE-CONTROL-TOTALS.
           EVALUATE TRUE
               WHEN STEP-LOADED(WS-STEP-IDX)
                   MOVE SPACES TO RM-TEXT
                   STRING 'DUPLICATE CONTROL RECORD FOR STEP '
                          CTL-STEP DELIMITED BY SIZE
                     INTO RM-TEXT
                   END-STRING
                   PERFORM 8100-WRITE-ERROR-MESSAGE
               WHEN CTL-BUS-DATE NOT = WS-BUS-DATE
                   MOVE SPACES TO RM-TEXT
                   STRING 'CONTROL RECORD FOR ' CTL-STEP
                          ' CARRIES BUSINESS DATE ' CTL-BUS-DATE
                          DELIMITED BY SIZE
                     INTO RM-TEXT
                   END-STRING
                   PERFORM 8100-WRITE-ERROR-MESSAGE
               WHEN OTHER
                   SET STEP-LOADED(WS-STEP-IDX) TO TRUE
                   MOVE CTL-IN-COUNT TO WS-STEP-IN-COUNT(WS-STEP-IDX)
                   MOVE CTL-IN-AMOUNT
                     TO WS-STEP-IN-AMOUNT(WS-STEP-IDX)
                   MOVE CTL-OUT-COUNT
                     TO WS-STEP-OUT-COUNT(WS-STEP-IDX)
                   MOVE CTL-OUT-AMOUNT
                     TO WS-STEP-OUT-AMOUNT(WS-STEP-IDX)
                   MOVE CTL-REJ-COUNT
                     TO WS-STEP-REJ-COUNT(WS-STEP-IDX)
                   MOVE CTL-REJ-AMOUNT
                     TO WS-STEP-REJ-AMOUNT(WS-STEP-IDX)
           END-EVALUATE.

       2500-CHECK-COMPLETENESS.
           PERFORM VARYING WS-STEP-SUB FROM 1 BY 1
                   UNTIL WS-STEP-SUB > WS-STEP-COUNT
               IF STEP-NOT-LOADED(WS-STEP-SUB)
                   MOVE SPACES TO RM-TEXT
                   STRING 'NO CONTROL RECORD RECEIVED FROM STEP '
                          WS-STEP-NAME(WS-STEP-SUB)
                          DELIMITED BY SIZE
                     INTO RM-TEXT
                   END-STRING
                   PERFORM 8100-WRITE-ERROR-MESSAGE
               END-IF
           END-PERFORM.

       2900-READ-CTLIN.
           READ CTLIN-FILE INTO CTL-RECORD
           EVALUATE TRUE
               WHEN CTLIN-OK
                   CONTINUE
               WHEN CTLIN-EOF
                   SET END-OF-CTLIN TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-CTLIN' TO ERR-PARAGRAPH
                   MOVE 'CTLIN' TO ERR-FILE
                   MOVE WS-CTLIN-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-RECONCILE.
           MOVE 'CPVALID  READ = ACCEPTED + REJECTED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-VALID) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-VALID) TO WS-EXP-AMOUNT
           COMPUTE WS-ACT-COUNT = WS-STEP-OUT-COUNT(WS-VALID)
                                + WS-STEP-REJ-COUNT(WS-VALID)
           COMPUTE WS-ACT-AMOUNT = WS-STEP-OUT-AMOUNT(WS-VALID)
                                 + WS-STEP-REJ-AMOUNT(WS-VALID)
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPENRICH READ = CPVALID ACCEPTED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-OUT-COUNT(WS-VALID) TO WS-EXP-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-VALID) TO WS-EXP-AMOUNT
           MOVE WS-STEP-IN-COUNT(WS-ENRICH) TO WS-ACT-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-ENRICH) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPENRICH READ = ENRICHED + REJECTED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-ENRICH) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-ENRICH) TO WS-EXP-AMOUNT
           COMPUTE WS-ACT-COUNT = WS-STEP-OUT-COUNT(WS-ENRICH)
                                + WS-STEP-REJ-COUNT(WS-ENRICH)
           COMPUTE WS-ACT-AMOUNT = WS-STEP-OUT-AMOUNT(WS-ENRICH)
                                 + WS-STEP-REJ-AMOUNT(WS-ENRICH)
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPPOST   READ = CPENRICH ENRICHED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-OUT-COUNT(WS-ENRICH) TO WS-EXP-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-ENRICH) TO WS-EXP-AMOUNT
           MOVE WS-STEP-IN-COUNT(WS-POST) TO WS-ACT-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-POST) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPPOST   READ = POSTED + SUSPENDED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-POST) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-POST) TO WS-EXP-AMOUNT
           COMPUTE WS-ACT-COUNT = WS-STEP-OUT-COUNT(WS-POST)
                                + WS-STEP-REJ-COUNT(WS-POST)
           COMPUTE WS-ACT-AMOUNT = WS-STEP-OUT-AMOUNT(WS-POST)
                                 + WS-STEP-REJ-AMOUNT(WS-POST)
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPFEECAL READ = CPPOST POSTED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-OUT-COUNT(WS-POST) TO WS-EXP-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-POST) TO WS-EXP-AMOUNT
           MOVE WS-STEP-IN-COUNT(WS-FEECAL) TO WS-ACT-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-FEECAL) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPFEECAL READ = FEE RECORDS WRITTEN'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-FEECAL) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-FEECAL) TO WS-EXP-AMOUNT
           MOVE WS-STEP-OUT-COUNT(WS-FEECAL) TO WS-ACT-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-FEECAL) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPSETTLE READ = CPFEECAL WRITTEN'
             TO WS-CHECK-DESC
           MOVE WS-STEP-OUT-COUNT(WS-FEECAL) TO WS-EXP-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-FEECAL) TO WS-EXP-AMOUNT
           MOVE WS-STEP-IN-COUNT(WS-SETTLE) TO WS-ACT-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-SETTLE) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CPSETTLE READ = GRAND TOTAL SETTLED'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-SETTLE) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-SETTLE) TO WS-EXP-AMOUNT
           MOVE WS-STEP-OUT-COUNT(WS-SETTLE) TO WS-ACT-COUNT
           MOVE WS-STEP-OUT-AMOUNT(WS-SETTLE) TO WS-ACT-AMOUNT
           PERFORM 3900-EVALUATE-CHECK

           MOVE 'CYCLE INPUT = SETTLED + ALL EXCEPTIONS'
             TO WS-CHECK-DESC
           MOVE WS-STEP-IN-COUNT(WS-VALID) TO WS-EXP-COUNT
           MOVE WS-STEP-IN-AMOUNT(WS-VALID) TO WS-EXP-AMOUNT
           COMPUTE WS-ACT-COUNT = WS-STEP-OUT-COUNT(WS-SETTLE)
                                + WS-STEP-REJ-COUNT(WS-VALID)
                                + WS-STEP-REJ-COUNT(WS-ENRICH)
                                + WS-STEP-REJ-COUNT(WS-POST)
           COMPUTE WS-ACT-AMOUNT = WS-STEP-OUT-AMOUNT(WS-SETTLE)
                                 + WS-STEP-REJ-AMOUNT(WS-VALID)
                                 + WS-STEP-REJ-AMOUNT(WS-ENRICH)
                                 + WS-STEP-REJ-AMOUNT(WS-POST)
           PERFORM 3900-EVALUATE-CHECK.

       3900-EVALUATE-CHECK.
           ADD 1 TO WS-CHECK-NUMBER
           MOVE SPACES TO RPT-DETAIL
           MOVE SPACE TO RD-ASA
           MOVE WS-CHECK-NUMBER TO RD-CHECK-NUMBER
           MOVE WS-CHECK-DESC TO RD-DESCRIPTION
           MOVE WS-EXP-COUNT TO RD-EXP-COUNT
           MOVE WS-ACT-COUNT TO RD-ACT-COUNT
           MOVE WS-EXP-AMOUNT TO RD-EXP-AMOUNT
           MOVE WS-ACT-AMOUNT TO RD-ACT-AMOUNT
           IF WS-EXP-COUNT = WS-ACT-COUNT
              AND WS-EXP-AMOUNT = WS-ACT-AMOUNT
               MOVE 'IN BALANCE' TO RD-RESULT
               ADD 1 TO WS-CHECKS-PASSED
           ELSE
               MOVE '** OUT **' TO RD-RESULT
               ADD 1 TO WS-CHECKS-FAILED
           END-IF
           MOVE RPT-DETAIL TO REPORT-REC
           PERFORM 8000-WRITE-REPORT.

       4000-FINALIZE.
           MOVE SPACES TO RPT-MESSAGE
           MOVE '0' TO RM-ASA
           EVALUATE TRUE
               WHEN WS-DATA-ERRORS > ZERO
                   MOVE 'CONTROL DATA INCOMPLETE - NOT RECONCILED'
                     TO RM-TEXT
                   MOVE 16 TO RETURN-CODE
               WHEN WS-CHECKS-FAILED > ZERO
                   MOVE 'CYCLE IS OUT OF BALANCE - DO NOT RELEASE'
                     TO RM-TEXT
                   MOVE 12 TO RETURN-CODE
               WHEN OTHER
                   MOVE 'CYCLE IS IN BALANCE - OUTPUTS RELEASED'
                     TO RM-TEXT
                   MOVE ZERO TO RETURN-CODE
           END-EVALUATE
           MOVE RPT-MESSAGE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           DISPLAY 'CPRECON  ' RM-TEXT
           CLOSE CTLIN-FILE
                 REPORT-FILE.

       8000-WRITE-REPORT.
           WRITE REPORT-REC
           IF NOT REPORT-OK
               MOVE '8000-WRITE-REPORT' TO ERR-PARAGRAPH
               MOVE 'RECONRPT' TO ERR-FILE
               MOVE WS-REPORT-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       8100-WRITE-ERROR-MESSAGE.
           ADD 1 TO WS-DATA-ERRORS
           MOVE SPACE TO RM-ASA
           MOVE RPT-MESSAGE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           DISPLAY 'CPRECON  ' RM-TEXT.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
