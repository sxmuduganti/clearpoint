       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPLUHN.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CARD.
           05  WS-CARD-DIGIT               PIC 9 OCCURS 16 TIMES.
       01  WS-IDX                          PIC S9(4) COMP.
       01  WS-PRODUCT                      PIC 9(2).
       01  WS-SUM                          PIC 9(4).
       01  WS-DOUBLE-SW                    PIC X.
           88  WS-DOUBLE                   VALUE 'Y'.
           88  WS-NO-DOUBLE                VALUE 'N'.
       LINKAGE SECTION.
           COPY CPLNPARM.
       PROCEDURE DIVISION USING LN-PARMS.
       0000-MAINLINE.
           SET LN-INVALID TO TRUE
           IF LN-CARD-NUM IS NUMERIC
              AND LN-CARD-NUM NOT = ALL '0'
               PERFORM 1000-COMPUTE-CHECKSUM
               IF FUNCTION MOD(WS-SUM, 10) = ZERO
                   SET LN-VALID TO TRUE
               END-IF
           END-IF
           GOBACK.

       1000-COMPUTE-CHECKSUM.
           MOVE LN-CARD-NUM TO WS-CARD
           MOVE ZERO TO WS-SUM
           SET WS-NO-DOUBLE TO TRUE
           PERFORM VARYING WS-IDX FROM 16 BY -1 UNTIL WS-IDX < 1
               IF WS-DOUBLE
                   COMPUTE WS-PRODUCT = WS-CARD-DIGIT(WS-IDX) * 2
                   IF WS-PRODUCT > 9
                       SUBTRACT 9 FROM WS-PRODUCT
                   END-IF
                   ADD WS-PRODUCT TO WS-SUM
                   SET WS-NO-DOUBLE TO TRUE
               ELSE
                   ADD WS-CARD-DIGIT(WS-IDX) TO WS-SUM
                   SET WS-DOUBLE TO TRUE
               END-IF
           END-PERFORM.
