       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPRPT.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT SETTLE-FILE ASSIGN TO SETLIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-SETTLE-STATUS.
           SELECT REPORT-FILE ASSIGN TO RPTOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CTLCARD-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 80 CHARACTERS.
       01  CTLCARD-REC                     PIC X(80).
       FD  SETTLE-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 150 CHARACTERS.
       01  SETTLE-REC                      PIC X(150).
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
           05  WS-SETTLE-STATUS            PIC X(2).
               88  SETTLE-OK               VALUE '00'.
               88  SETTLE-EOF              VALUE '10'.
           05  WS-REPORT-STATUS            PIC X(2).
               88  REPORT-OK               VALUE '00'.

       01  WS-SWITCHES.
           05  WS-SETTLE-EOF-SW            PIC X VALUE 'N'.
               88  END-OF-SETTLE           VALUE 'Y'.
           05  WS-GRAND-TOTAL-SW           PIC X VALUE 'N'.
               88  GRAND-TOTAL-PRINTED     VALUE 'Y'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-BUS-DATE                     PIC 9(8) VALUE ZERO.

       01  WS-PAGE-CONTROL.
           05  WS-PAGE-NUMBER              PIC S9(4) COMP VALUE 0.
           05  WS-LINE-COUNT               PIC S9(4) COMP VALUE 99.
           05  WS-LINES-PER-PAGE           PIC S9(4) COMP VALUE 55.
           05  WS-LINES-NEEDED             PIC S9(4) COMP.
           05  WS-NEXT-ASA                 PIC X VALUE SPACE.

       01  WS-COUNTERS.
           05  WS-RECORDS-READ             PIC S9(7) COMP-3 VALUE 0.
           05  WS-LINES-WRITTEN            PIC S9(7) COMP-3 VALUE 0.
       01  WS-DISPLAY-COUNT                PIC ZZZ,ZZZ,ZZ9.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  RPT-TITLE.
           05  FILLER                      PIC X     VALUE '1'.
           05  FILLER                      PIC X(10) VALUE 'CPRPT'.
           05  FILLER                      PIC X(50) VALUE
               'CLEARPOINT DAILY ISSUER SETTLEMENT REPORT'.
           05  FILLER                      PIC X(14)
                                           VALUE 'BUSINESS DATE'.
           05  RT-BUS-DATE                 PIC 9999/99/99.
           05  FILLER                      PIC X(38) VALUE SPACES.
           05  FILLER                      PIC X(5)  VALUE 'PAGE'.
           05  RT-PAGE                     PIC ZZZ9.
           05  FILLER                      PIC X     VALUE SPACE.

       01  RPT-SUBTITLE.
           05  FILLER                      PIC X     VALUE SPACE.
           05  FILLER                      PIC X(10) VALUE SPACES.
           05  FILLER                      PIC X(50) VALUE
               'AMOUNTS IN USD - NET IS DUE TO CARD NETWORKS'.
           05  FILLER                      PIC X(14) VALUE 'RUN DATE'.
           05  RS-RUN-DATE                 PIC 9999/99/99.
           05  FILLER                      PIC X(48) VALUE SPACES.

       01  RPT-COLUMNS.
           05  FILLER                      PIC X     VALUE '0'.
           05  FILLER                      PIC X(4)  VALUE 'NTWK'.
           05  FILLER                      PIC X(2)  VALUE SPACES.
           05  FILLER                      PIC X(19) VALUE 'CATEGORY'.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(11) VALUE
               '   DR COUNT'.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(20) VALUE
               '           DR AMOUNT'.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(11) VALUE
               '   CR COUNT'.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(20) VALUE
               '           CR AMOUNT'.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(18) VALUE
               '      INTERCHANGE '.
           05  FILLER                      PIC X(1)  VALUE SPACES.
           05  FILLER                      PIC X(21) VALUE
               '      NET SETTLEMENT '.

       01  RPT-UNDERLINE.
           05  FILLER                      PIC X     VALUE SPACE.
           05  FILLER                      PIC X(132) VALUE ALL '-'.

       01  RPT-DETAIL.
           05  RD-ASA                      PIC X.
           05  RD-NETWORK                  PIC X(4).
           05  FILLER                      PIC X(2).
           05  RD-MCC-CLASS                PIC X(2).
           05  FILLER                      PIC X.
           05  RD-DESCRIPTION              PIC X(16).
           05  FILLER                      PIC X.
           05  RD-DR-COUNT                 PIC ZZZ,ZZZ,ZZ9.
           05  FILLER                      PIC X.
           05  RD-DR-AMOUNT                PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                      PIC X.
           05  RD-CR-COUNT                 PIC ZZZ,ZZZ,ZZ9.
           05  FILLER                      PIC X.
           05  RD-CR-AMOUNT                PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  FILLER                      PIC X.
           05  RD-INTERCHANGE              PIC ZZ,ZZZ,ZZZ,ZZ9.99-.
           05  FILLER                      PIC X.
           05  RD-NET-SETTLEMENT           PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99-.

       01  RPT-END.
           05  FILLER                      PIC X     VALUE '0'.
           05  FILLER                      PIC X(132) VALUE
               '*** END OF REPORT ***'.

           COPY CPSTLREC.
           COPY CPDTPARM.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PRINT-SETTLEMENT
               UNTIL END-OF-SETTLE
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           MOVE 'CPRPT' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-OPEN-FILES
           PERFORM 1200-READ-CONTROL-CARDS
           MOVE WS-BUS-DATE TO RT-BUS-DATE
           MOVE WS-CURR-DATE TO RS-RUN-DATE
           PERFORM 2900-READ-SETTLEMENT.

       1100-OPEN-FILES.
           MOVE '1100-OPEN-FILES' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT SETTLE-FILE
           IF NOT SETTLE-OK
               MOVE 'SETLIN' TO ERR-FILE
               MOVE WS-SETTLE-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT REPORT-FILE
           IF NOT REPORT-OK
               MOVE 'RPTOUT' TO ERR-FILE
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

       2000-PRINT-SETTLEMENT.
           ADD 1 TO WS-RECORDS-READ
           IF STL-BUS-DATE NOT = WS-BUS-DATE
               MOVE '2000-PRINT-SETTLEMENT' TO ERR-PARAGRAPH
               MOVE 'SETTLEMENT FILE IS FOR A DIFFERENT DATE'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE SPACES TO RPT-DETAIL
           PERFORM 2100-FORMAT-AMOUNTS
           EVALUATE TRUE
               WHEN STL-CATEGORY
                   MOVE STL-NETWORK TO RD-NETWORK
                   MOVE STL-MCC-CLASS TO RD-MCC-CLASS
                   PERFORM 2200-DESCRIBE-CATEGORY
                   MOVE 1 TO WS-LINES-NEEDED
                   PERFORM 2500-PRINT-LINE
               WHEN STL-NETWORK-TOTAL
                   MOVE STL-NETWORK TO RD-NETWORK
                   MOVE 'NETWORK TOTAL' TO RD-DESCRIPTION
                   MOVE '0' TO WS-NEXT-ASA
                   MOVE 2 TO WS-LINES-NEEDED
                   PERFORM 2500-PRINT-LINE
                   MOVE '0' TO WS-NEXT-ASA
               WHEN STL-GRAND-TOTAL
                   MOVE 'ALL' TO RD-NETWORK
                   MOVE 'GRAND TOTAL' TO RD-DESCRIPTION
                   MOVE '-' TO WS-NEXT-ASA
                   MOVE 3 TO WS-LINES-NEEDED
                   PERFORM 2500-PRINT-LINE
                   SET GRAND-TOTAL-PRINTED TO TRUE
               WHEN OTHER
                   MOVE '2000-PRINT-SETTLEMENT' TO ERR-PARAGRAPH
                   MOVE 'INVALID SETTLEMENT RECORD TYPE'
                     TO ERR-MESSAGE
                   PERFORM 9900-ABEND
           END-EVALUATE
           PERFORM 2900-READ-SETTLEMENT.

       2100-FORMAT-AMOUNTS.
           MOVE STL-DR-COUNT TO RD-DR-COUNT
           MOVE STL-DR-AMOUNT TO RD-DR-AMOUNT
           MOVE STL-CR-COUNT TO RD-CR-COUNT
           MOVE STL-CR-AMOUNT TO RD-CR-AMOUNT
           MOVE STL-INTERCHANGE TO RD-INTERCHANGE
           MOVE STL-NET-SETTLEMENT TO RD-NET-SETTLEMENT.

       2200-DESCRIBE-CATEGORY.
           EVALUATE STL-MCC-CLASS
               WHEN 'SM'
                   MOVE 'SUPERMARKET' TO RD-DESCRIPTION
               WHEN 'FU'
                   MOVE 'FUEL' TO RD-DESCRIPTION
               WHEN 'TR'
                   MOVE 'TRAVEL' TO RD-DESCRIPTION
               WHEN 'RS'
                   MOVE 'RESTAURANT' TO RD-DESCRIPTION
               WHEN 'UT'
                   MOVE 'UTILITIES' TO RD-DESCRIPTION
               WHEN 'CA'
                   MOVE 'CASH ADVANCE' TO RD-DESCRIPTION
               WHEN 'GN'
                   MOVE 'GENERAL RETAIL' TO RD-DESCRIPTION
               WHEN OTHER
                   MOVE 'UNCLASSIFIED' TO RD-DESCRIPTION
           END-EVALUATE.

       2500-PRINT-LINE.
           IF WS-LINE-COUNT + WS-LINES-NEEDED > WS-LINES-PER-PAGE
               PERFORM 2600-PRINT-HEADINGS
           END-IF
           MOVE WS-NEXT-ASA TO RD-ASA
           MOVE RPT-DETAIL TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           ADD WS-LINES-NEEDED TO WS-LINE-COUNT
           MOVE SPACE TO WS-NEXT-ASA.

       2600-PRINT-HEADINGS.
           ADD 1 TO WS-PAGE-NUMBER
           MOVE WS-PAGE-NUMBER TO RT-PAGE
           MOVE RPT-TITLE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE RPT-SUBTITLE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE RPT-COLUMNS TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE RPT-UNDERLINE TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           MOVE 5 TO WS-LINE-COUNT
           MOVE SPACE TO WS-NEXT-ASA.

       2900-READ-SETTLEMENT.
           READ SETTLE-FILE INTO STL-RECORD
           EVALUATE TRUE
               WHEN SETTLE-OK
                   CONTINUE
               WHEN SETTLE-EOF
                   SET END-OF-SETTLE TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-SETTLEMENT' TO ERR-PARAGRAPH
                   MOVE 'SETLIN' TO ERR-FILE
                   MOVE WS-SETTLE-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           IF NOT GRAND-TOTAL-PRINTED
               MOVE '3000-FINALIZE' TO ERR-PARAGRAPH
               MOVE 'SETTLEMENT FILE HAS NO GRAND TOTAL RECORD'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE RPT-END TO REPORT-REC
           PERFORM 8000-WRITE-REPORT
           CLOSE SETTLE-FILE
                 REPORT-FILE
           DISPLAY 'CPRPT    SETTLEMENT REPORT COMPLETE'
           MOVE WS-RECORDS-READ TO WS-DISPLAY-COUNT
           DISPLAY '  RECORDS READ         ' WS-DISPLAY-COUNT
           MOVE WS-PAGE-NUMBER TO WS-DISPLAY-COUNT
           DISPLAY '  PAGES PRINTED        ' WS-DISPLAY-COUNT
           MOVE ZERO TO RETURN-CODE.

       8000-WRITE-REPORT.
           WRITE REPORT-REC
           IF NOT REPORT-OK
               MOVE '8000-WRITE-REPORT' TO ERR-PARAGRAPH
               MOVE 'RPTOUT' TO ERR-FILE
               MOVE WS-REPORT-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-LINES-WRITTEN.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
