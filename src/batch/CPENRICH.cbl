       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPENRICH.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT VALID-FILE ASSIGN TO VALIDIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-VALID-STATUS.
           SELECT CARDXREF-FILE ASSIGN TO CARDXREF
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS XF-CARD-NUM
               FILE STATUS IS WS-XREF-STATUS.
           SELECT MERCHMST-FILE ASSIGN TO MERCHMST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS MF-MERCH-ID
               FILE STATUS IS WS-MERCH-STATUS.
           SELECT ENRICHED-FILE ASSIGN TO ENROUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-ENRICHED-STATUS.
           SELECT REJECT-FILE ASSIGN TO REJECTS
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REJECT-STATUS.
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
       FD  VALID-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 150 CHARACTERS.
       01  VALID-REC                       PIC X(150).
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
       FD  ENRICHED-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 200 CHARACTERS.
       01  ENRICHED-REC                    PIC X(200).
       FD  REJECT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 210 CHARACTERS.
       01  REJECT-REC                      PIC X(210).
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
           05  WS-VALID-STATUS             PIC X(2).
               88  VALID-OK                VALUE '00'.
               88  VALID-EOF               VALUE '10'.
           05  WS-XREF-STATUS              PIC X(2).
               88  XREF-OK                 VALUE '00'.
               88  XREF-NOT-FOUND          VALUE '23'.
           05  WS-MERCH-STATUS             PIC X(2).
               88  MERCH-OK                VALUE '00'.
               88  MERCH-NOT-FOUND         VALUE '23'.
           05  WS-ENRICHED-STATUS          PIC X(2).
               88  ENRICHED-OK             VALUE '00'.
           05  WS-REJECT-STATUS            PIC X(2).
               88  REJECT-OK               VALUE '00'.
           05  WS-CTL-STATUS               PIC X(2).
               88  CTL-OK                  VALUE '00'.

       01  WS-SWITCHES.
           05  WS-VALID-EOF-SW             PIC X VALUE 'N'.
               88  END-OF-VALID            VALUE 'Y'.
           05  WS-MERCH-CACHE-SW           PIC X VALUE 'N'.
               88  MERCHANT-CACHED         VALUE 'Y'.
               88  MERCHANT-NOT-CACHED     VALUE 'N'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-BUS-DATE                     PIC 9(8) VALUE ZERO.
       01  WS-TRAN-YYYYMM                  PIC 9(6).
       01  WS-CACHED-MERCH-ID              PIC X(15) VALUE SPACES.

       01  WS-MCC                          PIC 9(4).
           88  MCC-SUPERMARKET             VALUE 5411 5422 5441 5451
                                                 5462 5499.
           88  MCC-FUEL                    VALUE 5541 5542 5983.
           88  MCC-TRAVEL                  VALUE 3000 THRU 3999
                                                 4111 4112 4121 4131
                                                 4411 4511 7011 7512.
           88  MCC-RESTAURANT              VALUE 5811 THRU 5814.
           88  MCC-UTILITY                 VALUE 4900.

       01  WS-COUNTERS.
           05  WS-IN-COUNT                 PIC S9(9) COMP-3 VALUE 0.
           05  WS-IN-AMOUNT                PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-OUT-COUNT                PIC S9(9) COMP-3 VALUE 0.
           05  WS-OUT-AMOUNT               PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-REJ-COUNT                PIC S9(9) COMP-3 VALUE 0.
           05  WS-REJ-AMOUNT               PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-XREF-READS               PIC S9(9) COMP-3 VALUE 0.
           05  WS-MERCH-READS              PIC S9(9) COMP-3 VALUE 0.
           05  WS-MERCH-CACHE-HITS         PIC S9(9) COMP-3 VALUE 0.

       01  WS-REJECT-CODE                  PIC X(4) VALUE SPACES.
           88  RECORD-ACCEPTED             VALUE SPACES.
       01  WS-REJECT-TEXT                  PIC X(40).
       01  WS-RSN-SUB                      PIC S9(4) COMP.

       01  WS-REASON-VALUES.
           05  FILLER  PIC X(4)  VALUE 'E001'.
           05  FILLER  PIC X(40) VALUE 'CARD NOT ON CROSS REFERENCE'.
           05  FILLER  PIC X(4)  VALUE 'E002'.
           05  FILLER  PIC X(40) VALUE 'CARD REPORTED LOST OR STOLEN'.
           05  FILLER  PIC X(4)  VALUE 'E003'.
           05  FILLER  PIC X(40) VALUE 'CARD IS CLOSED'.
           05  FILLER  PIC X(4)  VALUE 'E004'.
           05  FILLER  PIC X(40) VALUE
               'CARD EXPIRED AT TRANSACTION DATE'.
           05  FILLER  PIC X(4)  VALUE 'E005'.
           05  FILLER  PIC X(40) VALUE 'MERCHANT NOT ON MASTER'.
           05  FILLER  PIC X(4)  VALUE 'E006'.
           05  FILLER  PIC X(40) VALUE 'MERCHANT IS TERMINATED'.
       01  WS-REASON-TABLE REDEFINES WS-REASON-VALUES.
           05  WS-REASON-ENTRY             OCCURS 6 TIMES
                                           INDEXED BY WS-RSN-IDX.
               10  WS-REASON-CODE          PIC X(4).
               10  WS-REASON-TEXT          PIC X(40).
       01  WS-REASON-COUNTS.
           05  WS-REASON-COUNT             PIC S9(9) COMP-3
                                           OCCURS 6 TIMES.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  WS-DISPLAY-FIELDS.
           05  WS-DISPLAY-COUNT            PIC ZZZ,ZZZ,ZZ9.
           05  WS-DISPLAY-AMOUNT           PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.

           COPY CPTRNREC.
           COPY CPENRREC.
           COPY CPXRFREC.
           COPY CPMERREC.
           COPY CPRJTREC.
           COPY CPCTLREC.
           COPY CPDTPARM.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-ENRICH-TRANSACTION
               UNTIL END-OF-VALID
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           INITIALIZE WS-REASON-COUNTS
           MOVE 'CPENRICH' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-OPEN-FILES
           PERFORM 1200-READ-CONTROL-CARDS
           PERFORM 2900-READ-VALID.

       1100-OPEN-FILES.
           MOVE '1100-OPEN-FILES' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT VALID-FILE
           IF NOT VALID-OK
               MOVE 'VALIDIN' TO ERR-FILE
               MOVE WS-VALID-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT CARDXREF-FILE
           IF NOT XREF-OK
               MOVE 'CARDXREF' TO ERR-FILE
               MOVE WS-XREF-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT MERCHMST-FILE
           IF NOT MERCH-OK
               MOVE 'MERCHMST' TO ERR-FILE
               MOVE WS-MERCH-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT ENRICHED-FILE
           IF NOT ENRICHED-OK
               MOVE 'ENROUT' TO ERR-FILE
               MOVE WS-ENRICHED-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT REJECT-FILE
           IF NOT REJECT-OK
               MOVE 'REJECTS' TO ERR-FILE
               MOVE WS-REJECT-STATUS TO ERR-STATUS
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

       2000-ENRICH-TRANSACTION.
           ADD 1 TO WS-IN-COUNT
           ADD TRN-AMOUNT TO WS-IN-AMOUNT
           MOVE SPACES TO WS-REJECT-CODE
           PERFORM 2100-LOOKUP-CARD
           IF RECORD-ACCEPTED
               PERFORM 2200-LOOKUP-MERCHANT
           END-IF
           IF RECORD-ACCEPTED
               PERFORM 2300-BUILD-ENRICHED-RECORD
               PERFORM 2400-WRITE-ENRICHED
           ELSE
               PERFORM 2500-WRITE-REJECT
           END-IF
           PERFORM 2900-READ-VALID.

       2100-LOOKUP-CARD.
           MOVE TRN-CARD-NUM TO XF-CARD-NUM
           READ CARDXREF-FILE INTO XRF-RECORD
           ADD 1 TO WS-XREF-READS
           EVALUATE TRUE
               WHEN XREF-OK
                   MOVE TRN-TRAN-DATE(1:6) TO WS-TRAN-YYYYMM
                   EVALUATE TRUE
                       WHEN XRF-CARD-LOST
                           MOVE 'E002' TO WS-REJECT-CODE
                       WHEN XRF-CARD-CLOSED
                           MOVE 'E003' TO WS-REJECT-CODE
                       WHEN XRF-EXPIRY < WS-TRAN-YYYYMM
                           MOVE 'E004' TO WS-REJECT-CODE
                   END-EVALUATE
               WHEN XREF-NOT-FOUND
                   MOVE 'E001' TO WS-REJECT-CODE
               WHEN OTHER
                   MOVE '2100-LOOKUP-CARD' TO ERR-PARAGRAPH
                   MOVE 'CARDXREF' TO ERR-FILE
                   MOVE WS-XREF-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       2200-LOOKUP-MERCHANT.
           IF MERCHANT-CACHED
              AND TRN-MERCH-ID = WS-CACHED-MERCH-ID
               ADD 1 TO WS-MERCH-CACHE-HITS
           ELSE
               SET MERCHANT-NOT-CACHED TO TRUE
               MOVE TRN-MERCH-ID TO MF-MERCH-ID
               READ MERCHMST-FILE INTO MER-RECORD
               ADD 1 TO WS-MERCH-READS
               EVALUATE TRUE
                   WHEN MERCH-OK
                       SET MERCHANT-CACHED TO TRUE
                       MOVE TRN-MERCH-ID TO WS-CACHED-MERCH-ID
                   WHEN MERCH-NOT-FOUND
                       MOVE 'E005' TO WS-REJECT-CODE
                   WHEN OTHER
                       MOVE '2200-LOOKUP-MERCHANT' TO ERR-PARAGRAPH
                       MOVE 'MERCHMST' TO ERR-FILE
                       MOVE WS-MERCH-STATUS TO ERR-STATUS
                       PERFORM 9810-IO-ERROR
               END-EVALUATE
           END-IF
           IF RECORD-ACCEPTED AND MER-TERMINATED
               MOVE 'E006' TO WS-REJECT-CODE
           END-IF.

       2300-BUILD-ENRICHED-RECORD.
           MOVE SPACES TO ENR-RECORD
           MOVE TRN-CORE TO ENR-CORE
           MOVE XRF-ACCT-NUM TO ENR-ACCT-NUM
           MOVE MER-MCC TO ENR-MCC
           MOVE MER-NAME TO ENR-MERCH-NAME
           MOVE MER-COUNTRY TO ENR-MERCH-COUNTRY
           PERFORM 2310-DERIVE-MCC-CLASS
           IF TRN-CARD-PRESENT
               SET ENR-PRESENT TO TRUE
           ELSE
               SET ENR-NOT-PRESENT TO TRUE
           END-IF
           IF TRN-DEBIT-TYPE
               SET ENR-DEBIT TO TRUE
           ELSE
               SET ENR-CREDIT TO TRUE
           END-IF.

       2310-DERIVE-MCC-CLASS.
           MOVE MER-MCC TO WS-MCC
           EVALUATE TRUE
               WHEN TRN-CASH-ADVANCE
                   MOVE 'CA' TO ENR-MCC-CLASS
               WHEN MCC-SUPERMARKET
                   MOVE 'SM' TO ENR-MCC-CLASS
               WHEN MCC-FUEL
                   MOVE 'FU' TO ENR-MCC-CLASS
               WHEN MCC-TRAVEL
                   MOVE 'TR' TO ENR-MCC-CLASS
               WHEN MCC-RESTAURANT
                   MOVE 'RS' TO ENR-MCC-CLASS
               WHEN MCC-UTILITY
                   MOVE 'UT' TO ENR-MCC-CLASS
               WHEN OTHER
                   MOVE 'GN' TO ENR-MCC-CLASS
           END-EVALUATE.

       2400-WRITE-ENRICHED.
           WRITE ENRICHED-REC FROM ENR-RECORD
           IF NOT ENRICHED-OK
               MOVE '2400-WRITE-ENRICHED' TO ERR-PARAGRAPH
               MOVE 'ENROUT' TO ERR-FILE
               MOVE WS-ENRICHED-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-OUT-COUNT
           ADD ENR-AMOUNT TO WS-OUT-AMOUNT.

       2500-WRITE-REJECT.
           MOVE 'UNDEFINED REASON CODE' TO WS-REJECT-TEXT
           SET WS-RSN-IDX TO 1
           SEARCH WS-REASON-ENTRY
               WHEN WS-REASON-CODE(WS-RSN-IDX) = WS-REJECT-CODE
                   MOVE WS-REASON-TEXT(WS-RSN-IDX) TO WS-REJECT-TEXT
                   SET WS-RSN-SUB TO WS-RSN-IDX
                   ADD 1 TO WS-REASON-COUNT(WS-RSN-SUB)
           END-SEARCH
           MOVE SPACES TO RJ-RECORD
           MOVE 'CPENRICH' TO RJ-STEP
           MOVE WS-BUS-DATE TO RJ-BUS-DATE
           MOVE WS-REJECT-CODE TO RJ-REASON-CODE
           MOVE WS-REJECT-TEXT TO RJ-REASON-TEXT
           MOVE TRN-RECORD TO RJ-DATA
           WRITE REJECT-REC FROM RJ-RECORD
           IF NOT REJECT-OK
               MOVE '2500-WRITE-REJECT' TO ERR-PARAGRAPH
               MOVE 'REJECTS' TO ERR-FILE
               MOVE WS-REJECT-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-REJ-COUNT
           ADD TRN-AMOUNT TO WS-REJ-AMOUNT.

       2900-READ-VALID.
           READ VALID-FILE INTO TRN-RECORD
           EVALUATE TRUE
               WHEN VALID-OK
                   CONTINUE
               WHEN VALID-EOF
                   SET END-OF-VALID TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-VALID' TO ERR-PARAGRAPH
                   MOVE 'VALIDIN' TO ERR-FILE
                   MOVE WS-VALID-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           PERFORM 3100-WRITE-CONTROL-TOTALS
           CLOSE VALID-FILE
                 CARDXREF-FILE
                 MERCHMST-FILE
                 ENRICHED-FILE
                 REJECT-FILE
                 CTL-FILE
           PERFORM 3200-DISPLAY-STATISTICS
           IF WS-REJ-COUNT > ZERO
               MOVE 4 TO RETURN-CODE
           ELSE
               MOVE ZERO TO RETURN-CODE
           END-IF.

       3100-WRITE-CONTROL-TOTALS.
           MOVE SPACES TO CTL-RECORD
           MOVE 'CPENRICH' TO CTL-STEP
           MOVE WS-BUS-DATE TO CTL-BUS-DATE
           MOVE WS-IN-COUNT TO CTL-IN-COUNT
           MOVE WS-IN-AMOUNT TO CTL-IN-AMOUNT
           MOVE WS-OUT-COUNT TO CTL-OUT-COUNT
           MOVE WS-OUT-AMOUNT TO CTL-OUT-AMOUNT
           MOVE WS-REJ-COUNT TO CTL-REJ-COUNT
           MOVE WS-REJ-AMOUNT TO CTL-REJ-AMOUNT
           MOVE WS-CURR-DATE TO CTL-RUN-DATE
           MOVE WS-CURR-TIME TO CTL-RUN-TIME
           WRITE CTL-REC FROM CTL-RECORD
           IF NOT CTL-OK
               MOVE '3100-WRITE-CONTROL-TOTALS' TO ERR-PARAGRAPH
               MOVE 'CTLOUT' TO ERR-FILE
               MOVE WS-CTL-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF.

       3200-DISPLAY-STATISTICS.
           DISPLAY 'CPENRICH TRANSACTION ENRICHMENT SUMMARY'
           MOVE WS-IN-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-IN-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS READ         ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-OUT-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-OUT-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS ENRICHED     ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-REJ-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-REJ-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS REJECTED     ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           PERFORM VARYING WS-RSN-SUB FROM 1 BY 1
                   UNTIL WS-RSN-SUB > 6
               IF WS-REASON-COUNT(WS-RSN-SUB) > ZERO
                   MOVE WS-REASON-COUNT(WS-RSN-SUB)
                     TO WS-DISPLAY-COUNT
                   DISPLAY '    ' WS-REASON-CODE(WS-RSN-SUB) ' '
                           WS-REASON-TEXT(WS-RSN-SUB)
                           WS-DISPLAY-COUNT
               END-IF
           END-PERFORM
           MOVE WS-XREF-READS TO WS-DISPLAY-COUNT
           DISPLAY '  CARD XREF READS      ' WS-DISPLAY-COUNT
           MOVE WS-MERCH-READS TO WS-DISPLAY-COUNT
           DISPLAY '  MERCHANT READS       ' WS-DISPLAY-COUNT
           MOVE WS-MERCH-CACHE-HITS TO WS-DISPLAY-COUNT
           DISPLAY '  MERCHANT CACHE HITS  ' WS-DISPLAY-COUNT.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
