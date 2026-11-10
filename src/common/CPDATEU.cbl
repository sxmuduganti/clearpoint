       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPDATEU.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-INTEGER-DATE                 PIC S9(9) COMP.
       01  WS-MAX-INTEGER-DATE             PIC S9(9) COMP VALUE 3067671.
       LINKAGE SECTION.
           COPY CPDTPARM.
       PROCEDURE DIVISION USING DT-PARMS.
       0000-MAINLINE.
           SET DT-OK TO TRUE
           EVALUATE TRUE
               WHEN DT-VALIDATE
                   PERFORM 1000-CHECK-DATE-1
               WHEN DT-DIFF
                   PERFORM 2000-DAYS-BETWEEN
               WHEN DT-ADD
                   PERFORM 3000-ADD-DAYS
               WHEN OTHER
                   SET DT-BAD-FUNCTION TO TRUE
           END-EVALUATE
           GOBACK.

       1000-CHECK-DATE-1.
           IF DT-DATE-1 IS NOT NUMERIC
               SET DT-INVALID-DATE-1 TO TRUE
           ELSE
               IF FUNCTION TEST-DATE-YYYYMMDD(DT-DATE-1) NOT = ZERO
                   SET DT-INVALID-DATE-1 TO TRUE
               END-IF
           END-IF.

       1100-CHECK-DATE-2.
           IF DT-DATE-2 IS NOT NUMERIC
               SET DT-INVALID-DATE-2 TO TRUE
           ELSE
               IF FUNCTION TEST-DATE-YYYYMMDD(DT-DATE-2) NOT = ZERO
                   SET DT-INVALID-DATE-2 TO TRUE
               END-IF
           END-IF.

       2000-DAYS-BETWEEN.
           PERFORM 1000-CHECK-DATE-1
           IF DT-OK
               PERFORM 1100-CHECK-DATE-2
           END-IF
           IF DT-OK
               COMPUTE DT-DAYS =
                   FUNCTION INTEGER-OF-DATE(DT-DATE-2)
                 - FUNCTION INTEGER-OF-DATE(DT-DATE-1)
           END-IF.

       3000-ADD-DAYS.
           PERFORM 1000-CHECK-DATE-1
           IF DT-OK
               COMPUTE WS-INTEGER-DATE =
                   FUNCTION INTEGER-OF-DATE(DT-DATE-1) + DT-DAYS
               IF WS-INTEGER-DATE < 1
                  OR WS-INTEGER-DATE > WS-MAX-INTEGER-DATE
                   SET DT-OUT-OF-RANGE TO TRUE
               ELSE
                   COMPUTE DT-RESULT-DATE =
                       FUNCTION DATE-OF-INTEGER(WS-INTEGER-DATE)
               END-IF
           END-IF.
