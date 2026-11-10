       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPVALID.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTLCARD-FILE ASSIGN TO CTLCARD
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CTLCARD-STATUS.
           SELECT TRANIN-FILE ASSIGN TO TRANIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-TRANIN-STATUS.
           SELECT VALID-FILE ASSIGN TO VALIDOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-VALID-STATUS.
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
       FD  TRANIN-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 150 CHARACTERS.
       01  TRANIN-REC                      PIC X(150).
       FD  VALID-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 150 CHARACTERS.
       01  VALID-REC                       PIC X(150).
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
           05  WS-TRANIN-STATUS            PIC X(2).
               88  TRANIN-OK               VALUE '00'.
               88  TRANIN-EOF              VALUE '10'.
           05  WS-VALID-STATUS             PIC X(2).
               88  VALID-OK                VALUE '00'.
           05  WS-REJECT-STATUS            PIC X(2).
               88  REJECT-OK               VALUE '00'.
           05  WS-CTL-STATUS               PIC X(2).
               88  CTL-OK                  VALUE '00'.

       01  WS-SWITCHES.
           05  WS-TRANIN-EOF-SW            PIC X VALUE 'N'.
               88  END-OF-TRANIN           VALUE 'Y'.
           05  WS-TRAILER-SW               PIC X VALUE 'N'.
               88  TRAILER-FOUND           VALUE 'Y'.

       01  WS-CONTROL-CARD.
           05  WS-CC-KEYWORD               PIC X(10).
           05  WS-CC-VALUE                 PIC X(40).

       01  WS-RUN-OPTIONS.
           05  WS-BUS-DATE                 PIC 9(8) VALUE ZERO.
           05  WS-OLDEST-DATE              PIC 9(8) VALUE ZERO.
           05  WS-STALE-DAYS               PIC S9(7) COMP-3 VALUE 30.
           05  WS-MAX-ITEM-AMOUNT          PIC 9(9)V99 VALUE 50000.00.

       01  WS-COUNTERS.
           05  WS-RECORD-NUMBER            PIC S9(9) COMP-3 VALUE 0.
           05  WS-IN-COUNT                 PIC S9(9) COMP-3 VALUE 0.
           05  WS-IN-AMOUNT                PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-OUT-COUNT                PIC S9(9) COMP-3 VALUE 0.
           05  WS-OUT-AMOUNT               PIC S9(13)V99 COMP-3
                                           VALUE 0.
           05  WS-REJ-COUNT                PIC S9(9) COMP-3 VALUE 0.
           05  WS-REJ-AMOUNT               PIC S9(13)V99 COMP-3
                                           VALUE 0.

       01  WS-HASH-AMOUNT                  PIC 9(9)V99.
       01  WS-REJECT-CODE                  PIC X(4) VALUE SPACES.
           88  RECORD-ACCEPTED             VALUE SPACES.
       01  WS-REJECT-TEXT                  PIC X(40).
       01  WS-RSN-SUB                      PIC S9(4) COMP.

       01  WS-REASON-VALUES.
           05  FILLER  PIC X(4)  VALUE 'V001'.
           05  FILLER  PIC X(40) VALUE 'TRANSACTION ID IS BLANK'.
           05  FILLER  PIC X(4)  VALUE 'V002'.
           05  FILLER  PIC X(40) VALUE 'CARD NUMBER IS NOT NUMERIC'.
           05  FILLER  PIC X(4)  VALUE 'V003'.
           05  FILLER  PIC X(40) VALUE 'CARD NUMBER FAILS CHECK DIGIT'.
           05  FILLER  PIC X(4)  VALUE 'V004'.
           05  FILLER  PIC X(40) VALUE 'MERCHANT ID IS BLANK'.
           05  FILLER  PIC X(4)  VALUE 'V005'.
           05  FILLER  PIC X(40) VALUE 'AMOUNT IS NOT NUMERIC'.
           05  FILLER  PIC X(4)  VALUE 'V006'.
           05  FILLER  PIC X(40) VALUE 'AMOUNT IS ZERO'.
           05  FILLER  PIC X(4)  VALUE 'V007'.
           05  FILLER  PIC X(40) VALUE
               'AMOUNT EXCEEDS SINGLE ITEM LIMIT'.
           05  FILLER  PIC X(4)  VALUE 'V008'.
           05  FILLER  PIC X(40) VALUE 'CURRENCY IS NOT SUPPORTED'.
           05  FILLER  PIC X(4)  VALUE 'V009'.
           05  FILLER  PIC X(40) VALUE 'TRANSACTION DATE IS INVALID'.
           05  FILLER  PIC X(4)  VALUE 'V010'.
           05  FILLER  PIC X(40) VALUE
               'TRANSACTION DATE AFTER BUSINESS DATE'.
           05  FILLER  PIC X(4)  VALUE 'V011'.
           05  FILLER  PIC X(40) VALUE
               'TRANSACTION OUTSIDE PRESENTMENT WINDOW'.
           05  FILLER  PIC X(4)  VALUE 'V012'.
           05  FILLER  PIC X(40) VALUE 'TRANSACTION TIME IS INVALID'.
           05  FILLER  PIC X(4)  VALUE 'V013'.
           05  FILLER  PIC X(40) VALUE 'TRANSACTION TYPE IS INVALID'.
           05  FILLER  PIC X(4)  VALUE 'V014'.
           05  FILLER  PIC X(40) VALUE 'POS ENTRY MODE IS INVALID'.
           05  FILLER  PIC X(4)  VALUE 'V015'.
           05  FILLER  PIC X(40) VALUE 'CARD NETWORK IS INVALID'.
           05  FILLER  PIC X(4)  VALUE 'V016'.
           05  FILLER  PIC X(40) VALUE
               'AUTHORIZATION CODE IS MISSING'.
       01  WS-REASON-TABLE REDEFINES WS-REASON-VALUES.
           05  WS-REASON-ENTRY             OCCURS 16 TIMES
                                           INDEXED BY WS-RSN-IDX.
               10  WS-REASON-CODE          PIC X(4).
               10  WS-REASON-TEXT          PIC X(40).
       01  WS-REASON-COUNTS.
           05  WS-REASON-COUNT             PIC S9(9) COMP-3
                                           OCCURS 16 TIMES.

       01  WS-CURRENT-DATE-TIME.
           05  WS-CURR-DATE                PIC 9(8).
           05  WS-CURR-TIME                PIC 9(6).
           05  FILLER                      PIC X(7).

       01  WS-DISPLAY-FIELDS.
           05  WS-DISPLAY-COUNT            PIC ZZZ,ZZZ,ZZ9.
           05  WS-DISPLAY-AMOUNT           PIC Z,ZZZ,ZZZ,ZZZ,ZZ9.99.
           05  WS-DISPLAY-RECNO            PIC Z(8)9.

           COPY CPTRNREC.
           COPY CPRJTREC.
           COPY CPCTLREC.
           COPY CPDTPARM.
           COPY CPLNPARM.
           COPY CPERRWS.

       PROCEDURE DIVISION.
       0000-MAINLINE.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-RECORD
               UNTIL END-OF-TRANIN
           PERFORM 3000-FINALIZE
           GOBACK.

       1000-INITIALIZE.
           INITIALIZE ERR-AREA
           INITIALIZE WS-REASON-COUNTS
           MOVE 'CPVALID' TO ERR-PROGRAM
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE-TIME
           PERFORM 1100-OPEN-FILES
           PERFORM 1200-READ-CONTROL-CARDS
           PERFORM 1300-PROCESS-HEADER
           PERFORM 1400-SET-PRESENTMENT-WINDOW
           PERFORM 2900-READ-TRANIN.

       1100-OPEN-FILES.
           MOVE '1100-OPEN-FILES' TO ERR-PARAGRAPH
           OPEN INPUT CTLCARD-FILE
           IF NOT CTLCARD-OK
               MOVE 'CTLCARD' TO ERR-FILE
               MOVE WS-CTLCARD-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN INPUT TRANIN-FILE
           IF NOT TRANIN-OK
               MOVE 'TRANIN' TO ERR-FILE
               MOVE WS-TRANIN-STATUS TO ERR-STATUS
               PERFORM 9800-OPEN-ERROR
           END-IF
           OPEN OUTPUT VALID-FILE
           IF NOT VALID-OK
               MOVE 'VALIDOUT' TO ERR-FILE
               MOVE WS-VALID-STATUS TO ERR-STATUS
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
           IF WS-BUS-DATE = ZERO
               MOVE 'BUSDATE CONTROL CARD NOT SUPPLIED'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           SET DT-VALIDATE TO TRUE
           MOVE WS-BUS-DATE TO DT-DATE-1
           CALL 'CPDATEU' USING DT-PARMS
           IF NOT DT-OK
               MOVE 'BUSDATE IS NOT A VALID CALENDAR DATE'
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

       1300-PROCESS-HEADER.
           MOVE '1300-PROCESS-HEADER' TO ERR-PARAGRAPH
           PERFORM 2900-READ-TRANIN
           EVALUATE TRUE
               WHEN END-OF-TRANIN
                   MOVE 'TRANSACTION FILE IS EMPTY' TO ERR-MESSAGE
                   PERFORM 9900-ABEND
               WHEN NOT TRN-HEADER
                   MOVE 'FIRST RECORD IS NOT A HEADER RECORD'
                     TO ERR-MESSAGE
                   PERFORM 9900-ABEND
               WHEN TRN-HDR-FILE-ID NOT = 'CPTRAN'
                   MOVE 'HEADER FILE IDENTIFIER IS NOT CPTRAN'
                     TO ERR-MESSAGE
                   PERFORM 9900-ABEND
               WHEN TRN-HDR-BUS-DATE IS NOT NUMERIC
               WHEN TRN-HDR-BUS-DATE NOT = WS-BUS-DATE
                   MOVE SPACES TO ERR-MESSAGE
                   STRING 'HEADER DATE ' TRN-HDR-BUS-DATE
                          ' DOES NOT MATCH BUSDATE ' WS-BUS-DATE
                          DELIMITED BY SIZE
                     INTO ERR-MESSAGE
                   END-STRING
                   PERFORM 9900-ABEND
           END-EVALUATE
           DISPLAY 'CPVALID  INPUT SOURCE  : ' TRN-HDR-SOURCE
           DISPLAY 'CPVALID  BUSINESS DATE : ' TRN-HDR-BUS-DATE.

       1400-SET-PRESENTMENT-WINDOW.
           MOVE '1400-SET-PRESENTMENT-WINDOW' TO ERR-PARAGRAPH
           SET DT-ADD TO TRUE
           MOVE WS-BUS-DATE TO DT-DATE-1
           COMPUTE DT-DAYS = ZERO - WS-STALE-DAYS
           CALL 'CPDATEU' USING DT-PARMS
           IF NOT DT-OK
               MOVE 'UNABLE TO DERIVE PRESENTMENT WINDOW'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           MOVE DT-RESULT-DATE TO WS-OLDEST-DATE.

       2000-PROCESS-RECORD.
           MOVE '2000-PROCESS-RECORD' TO ERR-PARAGRAPH
           IF TRAILER-FOUND
               MOVE 'RECORDS FOUND AFTER TRAILER RECORD'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           EVALUATE TRUE
               WHEN TRN-DETAIL
                   PERFORM 2100-PROCESS-DETAIL
               WHEN TRN-TRAILER
                   PERFORM 2500-PROCESS-TRAILER
               WHEN TRN-HEADER
                   MOVE 'DUPLICATE HEADER RECORD ENCOUNTERED'
                     TO ERR-MESSAGE
                   PERFORM 9900-ABEND
               WHEN OTHER
                   MOVE WS-RECORD-NUMBER TO WS-DISPLAY-RECNO
                   MOVE SPACES TO ERR-MESSAGE
                   STRING 'INVALID RECORD TYPE AT RECORD '
                          WS-DISPLAY-RECNO DELIMITED BY SIZE
                     INTO ERR-MESSAGE
                   END-STRING
                   PERFORM 9900-ABEND
           END-EVALUATE
           PERFORM 2900-READ-TRANIN.

       2100-PROCESS-DETAIL.
           ADD 1 TO WS-IN-COUNT
           IF TRN-AMOUNT IS NUMERIC
               MOVE TRN-AMOUNT TO WS-HASH-AMOUNT
           ELSE
               MOVE ZERO TO WS-HASH-AMOUNT
           END-IF
           ADD WS-HASH-AMOUNT TO WS-IN-AMOUNT
           MOVE SPACES TO WS-REJECT-CODE
           PERFORM 2200-EDIT-IDENTIFIERS
           IF RECORD-ACCEPTED
               PERFORM 2210-EDIT-AMOUNT
           END-IF
           IF RECORD-ACCEPTED
               PERFORM 2220-EDIT-DATE-TIME
           END-IF
           IF RECORD-ACCEPTED
               PERFORM 2230-EDIT-ATTRIBUTES
           END-IF
           IF RECORD-ACCEPTED
               PERFORM 2400-WRITE-VALID
           ELSE
               PERFORM 2300-WRITE-REJECT
           END-IF.

       2200-EDIT-IDENTIFIERS.
           EVALUATE TRUE
               WHEN TRN-TRAN-ID = SPACES
                   MOVE 'V001' TO WS-REJECT-CODE
               WHEN TRN-CARD-NUM IS NOT NUMERIC
                   MOVE 'V002' TO WS-REJECT-CODE
               WHEN TRN-MERCH-ID = SPACES
                   MOVE 'V004' TO WS-REJECT-CODE
               WHEN OTHER
                   MOVE TRN-CARD-NUM TO LN-CARD-NUM
                   CALL 'CPLUHN' USING LN-PARMS
                   IF LN-INVALID
                       MOVE 'V003' TO WS-REJECT-CODE
                   END-IF
           END-EVALUATE.

       2210-EDIT-AMOUNT.
           EVALUATE TRUE
               WHEN TRN-AMOUNT IS NOT NUMERIC
                   MOVE 'V005' TO WS-REJECT-CODE
               WHEN TRN-AMOUNT = ZERO
                   MOVE 'V006' TO WS-REJECT-CODE
               WHEN TRN-AMOUNT > WS-MAX-ITEM-AMOUNT
                   MOVE 'V007' TO WS-REJECT-CODE
               WHEN TRN-CURRENCY NOT = 'USD'
                   MOVE 'V008' TO WS-REJECT-CODE
           END-EVALUATE.

       2220-EDIT-DATE-TIME.
           IF TRN-TRAN-DATE IS NOT NUMERIC
               MOVE 'V009' TO WS-REJECT-CODE
           ELSE
               SET DT-VALIDATE TO TRUE
               MOVE TRN-TRAN-DATE TO DT-DATE-1
               CALL 'CPDATEU' USING DT-PARMS
               EVALUATE TRUE
                   WHEN NOT DT-OK
                       MOVE 'V009' TO WS-REJECT-CODE
                   WHEN TRN-TRAN-DATE > WS-BUS-DATE
                       MOVE 'V010' TO WS-REJECT-CODE
                   WHEN TRN-TRAN-DATE < WS-OLDEST-DATE
                       MOVE 'V011' TO WS-REJECT-CODE
                   WHEN TRN-TRAN-TIME IS NOT NUMERIC
                       MOVE 'V012' TO WS-REJECT-CODE
                   WHEN TRN-TRAN-HH > 23
                   WHEN TRN-TRAN-MM > 59
                   WHEN TRN-TRAN-SS > 59
                       MOVE 'V012' TO WS-REJECT-CODE
               END-EVALUATE
           END-IF.

       2230-EDIT-ATTRIBUTES.
           EVALUATE TRUE
               WHEN NOT TRN-VALID-TYPE
                   MOVE 'V013' TO WS-REJECT-CODE
               WHEN NOT TRN-VALID-ENTRY
                   MOVE 'V014' TO WS-REJECT-CODE
               WHEN NOT TRN-VALID-NETWORK
                   MOVE 'V015' TO WS-REJECT-CODE
               WHEN TRN-DEBIT-TYPE AND TRN-AUTH-CODE = SPACES
                   MOVE 'V016' TO WS-REJECT-CODE
           END-EVALUATE.

       2300-WRITE-REJECT.
           MOVE 'UNDEFINED REASON CODE' TO WS-REJECT-TEXT
           SET WS-RSN-IDX TO 1
           SEARCH WS-REASON-ENTRY
               WHEN WS-REASON-CODE(WS-RSN-IDX) = WS-REJECT-CODE
                   MOVE WS-REASON-TEXT(WS-RSN-IDX) TO WS-REJECT-TEXT
                   SET WS-RSN-SUB TO WS-RSN-IDX
                   ADD 1 TO WS-REASON-COUNT(WS-RSN-SUB)
           END-SEARCH
           MOVE SPACES TO RJ-RECORD
           MOVE 'CPVALID' TO RJ-STEP
           MOVE WS-BUS-DATE TO RJ-BUS-DATE
           MOVE WS-REJECT-CODE TO RJ-REASON-CODE
           MOVE WS-REJECT-TEXT TO RJ-REASON-TEXT
           MOVE TRN-RECORD TO RJ-DATA
           WRITE REJECT-REC FROM RJ-RECORD
           IF NOT REJECT-OK
               MOVE '2300-WRITE-REJECT' TO ERR-PARAGRAPH
               MOVE 'REJECTS' TO ERR-FILE
               MOVE WS-REJECT-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-REJ-COUNT
           ADD WS-HASH-AMOUNT TO WS-REJ-AMOUNT.

       2400-WRITE-VALID.
           WRITE VALID-REC FROM TRN-RECORD
           IF NOT VALID-OK
               MOVE '2400-WRITE-VALID' TO ERR-PARAGRAPH
               MOVE 'VALIDOUT' TO ERR-FILE
               MOVE WS-VALID-STATUS TO ERR-STATUS
               PERFORM 9810-IO-ERROR
           END-IF
           ADD 1 TO WS-OUT-COUNT
           ADD TRN-AMOUNT TO WS-OUT-AMOUNT.

       2500-PROCESS-TRAILER.
           MOVE '2500-PROCESS-TRAILER' TO ERR-PARAGRAPH
           SET TRAILER-FOUND TO TRUE
           IF TRN-TRL-REC-COUNT IS NOT NUMERIC
              OR TRN-TRL-HASH-AMOUNT IS NOT NUMERIC
               MOVE 'TRAILER CONTROL TOTALS ARE NOT NUMERIC'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           IF TRN-TRL-REC-COUNT NOT = WS-IN-COUNT
               MOVE TRN-TRL-REC-COUNT TO WS-DISPLAY-COUNT
               DISPLAY 'CPVALID  TRAILER RECORD COUNT : '
                       WS-DISPLAY-COUNT
               MOVE WS-IN-COUNT TO WS-DISPLAY-COUNT
               DISPLAY 'CPVALID  DETAIL RECORDS READ  : '
                       WS-DISPLAY-COUNT
               MOVE 'TRAILER RECORD COUNT IS OUT OF BALANCE'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           IF TRN-TRL-HASH-AMOUNT NOT = WS-IN-AMOUNT
               MOVE TRN-TRL-HASH-AMOUNT TO WS-DISPLAY-AMOUNT
               DISPLAY 'CPVALID  TRAILER HASH AMOUNT  : '
                       WS-DISPLAY-AMOUNT
               MOVE WS-IN-AMOUNT TO WS-DISPLAY-AMOUNT
               DISPLAY 'CPVALID  DETAIL AMOUNT READ   : '
                       WS-DISPLAY-AMOUNT
               MOVE 'TRAILER HASH TOTAL IS OUT OF BALANCE'
                 TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF.

       2900-READ-TRANIN.
           READ TRANIN-FILE INTO TRN-RECORD
           EVALUATE TRUE
               WHEN TRANIN-OK
                   ADD 1 TO WS-RECORD-NUMBER
               WHEN TRANIN-EOF
                   SET END-OF-TRANIN TO TRUE
               WHEN OTHER
                   MOVE '2900-READ-TRANIN' TO ERR-PARAGRAPH
                   MOVE 'TRANIN' TO ERR-FILE
                   MOVE WS-TRANIN-STATUS TO ERR-STATUS
                   PERFORM 9810-IO-ERROR
           END-EVALUATE.

       3000-FINALIZE.
           MOVE '3000-FINALIZE' TO ERR-PARAGRAPH
           IF NOT TRAILER-FOUND
               MOVE 'TRAILER RECORD NOT FOUND' TO ERR-MESSAGE
               PERFORM 9900-ABEND
           END-IF
           PERFORM 3100-WRITE-CONTROL-TOTALS
           CLOSE TRANIN-FILE
                 VALID-FILE
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
           MOVE 'CPVALID' TO CTL-STEP
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
           DISPLAY 'CPVALID  TRANSACTION VALIDATION SUMMARY'
           MOVE WS-IN-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-IN-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  DETAIL RECORDS READ  ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-OUT-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-OUT-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS ACCEPTED     ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           MOVE WS-REJ-COUNT TO WS-DISPLAY-COUNT
           MOVE WS-REJ-AMOUNT TO WS-DISPLAY-AMOUNT
           DISPLAY '  RECORDS REJECTED     ' WS-DISPLAY-COUNT
                   '  ' WS-DISPLAY-AMOUNT
           PERFORM VARYING WS-RSN-SUB FROM 1 BY 1
                   UNTIL WS-RSN-SUB > 16
               IF WS-REASON-COUNT(WS-RSN-SUB) > ZERO
                   MOVE WS-REASON-COUNT(WS-RSN-SUB)
                     TO WS-DISPLAY-COUNT
                   DISPLAY '    ' WS-REASON-CODE(WS-RSN-SUB) ' '
                           WS-REASON-TEXT(WS-RSN-SUB)
                           WS-DISPLAY-COUNT
               END-IF
           END-PERFORM.

       9800-OPEN-ERROR.
           MOVE 'UNABLE TO OPEN FILE' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9810-IO-ERROR.
           MOVE 'UNEXPECTED FILE STATUS' TO ERR-MESSAGE
           PERFORM 9900-ABEND.

       9900-ABEND.
           MOVE 16 TO ERR-RETURN-CODE
           CALL 'CPABEND' USING ERR-AREA.
