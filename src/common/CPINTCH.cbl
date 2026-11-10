       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPINTCH.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-SEARCH-KEY.
           05  WS-SK-NETWORK               PIC X(4).
           05  WS-SK-PRODUCT               PIC X(4).
           05  WS-SK-MCC-CLASS             PIC X(2).
           05  WS-SK-PRESENCE              PIC X.
       01  WS-FOUND-SW                     PIC X.
           88  WS-FOUND                    VALUE 'Y'.
           88  WS-NOT-FOUND                VALUE 'N'.
       01  WS-PASS                         PIC S9(4) COMP.
       01  WS-STEP                         PIC S9(4) COMP.
       01  WS-LEVEL                        PIC 9.
       01  WS-FEE                          PIC S9(7)V99 COMP-3.
       LINKAGE SECTION.
           COPY CPFEETBL.
           COPY CPINTPRM.
       PROCEDURE DIVISION USING FEE-TABLE INT-PARMS.
       0000-MAINLINE.
           MOVE ZERO TO INT-FEE INT-RATE INT-PER-ITEM WS-LEVEL
           MOVE SPACES TO INT-MATCHED-KEY
           SET INT-NOT-FOUND TO TRUE
           SET WS-NOT-FOUND TO TRUE
           MOVE INT-NETWORK TO WS-SK-NETWORK
           PERFORM VARYING WS-PASS FROM 1 BY 1
                   UNTIL WS-PASS > 2 OR WS-FOUND
               IF WS-PASS = 1
                   MOVE INT-PRODUCT TO WS-SK-PRODUCT
               ELSE
                   MOVE '****' TO WS-SK-PRODUCT
               END-IF
               PERFORM VARYING WS-STEP FROM 1 BY 1
                       UNTIL WS-STEP > 3 OR WS-FOUND
                   PERFORM 1000-BUILD-SEARCH-KEY
                   ADD 1 TO WS-LEVEL
                   PERFORM 2000-SEARCH-TABLE
               END-PERFORM
           END-PERFORM
           IF WS-FOUND
               MOVE WS-LEVEL TO INT-MATCH-LEVEL
               PERFORM 3000-CALCULATE-FEE
           END-IF
           GOBACK.

       1000-BUILD-SEARCH-KEY.
           EVALUATE WS-STEP
               WHEN 1
                   MOVE INT-MCC-CLASS TO WS-SK-MCC-CLASS
                   MOVE INT-PRESENCE TO WS-SK-PRESENCE
               WHEN 2
                   MOVE INT-MCC-CLASS TO WS-SK-MCC-CLASS
                   MOVE '*' TO WS-SK-PRESENCE
               WHEN OTHER
                   MOVE '**' TO WS-SK-MCC-CLASS
                   MOVE '*' TO WS-SK-PRESENCE
           END-EVALUATE.

       2000-SEARCH-TABLE.
           IF FT-ENTRY-COUNT > ZERO
               SEARCH ALL FT-ENTRY
                   AT END
                       SET WS-NOT-FOUND TO TRUE
                   WHEN FT-KEY(FT-IDX) = WS-SEARCH-KEY
                       SET WS-FOUND TO TRUE
               END-SEARCH
           END-IF.

       3000-CALCULATE-FEE.
           MOVE WS-SEARCH-KEY TO INT-MATCHED-KEY
           MOVE FT-RATE(FT-IDX) TO INT-RATE
           MOVE FT-PER-ITEM(FT-IDX) TO INT-PER-ITEM
           COMPUTE WS-FEE ROUNDED =
               INT-AMOUNT * FT-RATE(FT-IDX) + FT-PER-ITEM(FT-IDX)
           IF FT-MAX-FEE(FT-IDX) > ZERO
              AND WS-FEE > FT-MAX-FEE(FT-IDX)
               MOVE FT-MAX-FEE(FT-IDX) TO WS-FEE
           END-IF
           IF INT-CREDIT
               COMPUTE INT-FEE = ZERO - WS-FEE
           ELSE
               MOVE WS-FEE TO INT-FEE
           END-IF.
