       IDENTIFICATION DIVISION.
       PROGRAM-ID. TCDATEU.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-TEST-CASES.
           05  FILLER PIC X      VALUE 'V'.
           05  FILLER PIC 9(8)   VALUE 20240229.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE ZERO.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE 'LEAP DAY'.
           05  FILLER PIC X      VALUE 'V'.
           05  FILLER PIC 9(8)   VALUE 20230229.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE ZERO.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '01'.
           05  FILLER PIC X(8)   VALUE 'NOT LEAP'.
           05  FILLER PIC X      VALUE 'V'.
           05  FILLER PIC 9(8)   VALUE 20261301.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE ZERO.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '01'.
           05  FILLER PIC X(8)   VALUE 'MONTH 13'.
           05  FILLER PIC X      VALUE 'V'.
           05  FILLER PIC 9(8)   VALUE 20261131.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE ZERO.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '01'.
           05  FILLER PIC X(8)   VALUE 'NOV 31'.
           05  FILLER PIC X      VALUE 'D'.
           05  FILLER PIC 9(8)   VALUE 20260101.
           05  FILLER PIC 9(8)   VALUE 20261231.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE 364.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE 'YEAR LEN'.
           05  FILLER PIC X      VALUE 'D'.
           05  FILLER PIC 9(8)   VALUE 20261108.
           05  FILLER PIC 9(8)   VALUE 20261009.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE -30.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE 'BACKWARD'.
           05  FILLER PIC X      VALUE 'A'.
           05  FILLER PIC 9(8)   VALUE 20261108.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE -30.
           05  FILLER PIC 9(8)   VALUE 20261009.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE '30 BACK'.
           05  FILLER PIC X      VALUE 'A'.
           05  FILLER PIC 9(8)   VALUE 20240228.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE 1.
           05  FILLER PIC 9(8)   VALUE 20240229.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE 'LEAP ADD'.
           05  FILLER PIC X      VALUE 'A'.
           05  FILLER PIC 9(8)   VALUE 20231231.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE 1.
           05  FILLER PIC 9(8)   VALUE 20240101.
           05  FILLER PIC X(2)   VALUE '00'.
           05  FILLER PIC X(8)   VALUE 'YEAR END'.
           05  FILLER PIC X      VALUE 'X'.
           05  FILLER PIC 9(8)   VALUE 20261108.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC S9(7)  SIGN LEADING SEPARATE VALUE ZERO.
           05  FILLER PIC 9(8)   VALUE ZERO.
           05  FILLER PIC X(2)   VALUE '99'.
           05  FILLER PIC X(8)   VALUE 'BAD FUNC'.
       01  WS-TEST-TABLE REDEFINES WS-TEST-CASES.
           05  WS-TEST-CASE                OCCURS 10 TIMES.
               10  WS-TC-FUNCTION          PIC X.
               10  WS-TC-DATE-1            PIC 9(8).
               10  WS-TC-DATE-2            PIC 9(8).
               10  WS-TC-DAYS              PIC S9(7)
                                           SIGN LEADING SEPARATE.
               10  WS-TC-EXP-RESULT        PIC 9(8).
               10  WS-TC-EXP-RC            PIC X(2).
               10  WS-TC-NAME              PIC X(8).
       01  WS-SUB                          PIC S9(4) COMP.
       01  WS-PASSED                       PIC 9(4) VALUE 0.
       01  WS-FAILED                       PIC 9(4) VALUE 0.
       01  WS-CASE-OK-SW                   PIC X.
           88  CASE-OK                     VALUE 'Y'.
       01  WS-DISPLAY-DAYS                 PIC -(7)9.
           COPY CPDTPARM.
       PROCEDURE DIVISION.
       0000-MAINLINE.
           DISPLAY 'TCDATEU  DATE SERVICE TESTS'
           PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 10
               PERFORM 1000-RUN-CASE
           END-PERFORM
           DISPLAY 'TCDATEU  PASSED ' WS-PASSED ' FAILED ' WS-FAILED
           IF WS-FAILED > ZERO
               MOVE 8 TO RETURN-CODE
           ELSE
               MOVE ZERO TO RETURN-CODE
           END-IF
           GOBACK.

       1000-RUN-CASE.
           INITIALIZE DT-PARMS
           MOVE WS-TC-FUNCTION(WS-SUB) TO DT-FUNCTION
           MOVE WS-TC-DATE-1(WS-SUB) TO DT-DATE-1
           MOVE WS-TC-DATE-2(WS-SUB) TO DT-DATE-2
           IF WS-TC-FUNCTION(WS-SUB) = 'A'
               MOVE WS-TC-DAYS(WS-SUB) TO DT-DAYS
           END-IF
           CALL 'CPDATEU' USING DT-PARMS
           MOVE 'Y' TO WS-CASE-OK-SW
           IF DT-RC NOT = WS-TC-EXP-RC(WS-SUB)
               MOVE 'N' TO WS-CASE-OK-SW
           END-IF
           IF DT-OK AND DT-DIFF
              AND DT-DAYS NOT = WS-TC-DAYS(WS-SUB)
               MOVE 'N' TO WS-CASE-OK-SW
           END-IF
           IF DT-OK AND DT-ADD
              AND DT-RESULT-DATE NOT = WS-TC-EXP-RESULT(WS-SUB)
               MOVE 'N' TO WS-CASE-OK-SW
           END-IF
           MOVE DT-DAYS TO WS-DISPLAY-DAYS
           IF CASE-OK
               ADD 1 TO WS-PASSED
               DISPLAY '  PASS  ' WS-TC-NAME(WS-SUB)
                       ' RC ' DT-RC ' RESULT ' DT-RESULT-DATE
                       ' DAYS ' WS-DISPLAY-DAYS
           ELSE
               ADD 1 TO WS-FAILED
               DISPLAY '  FAIL  ' WS-TC-NAME(WS-SUB)
                       ' RC ' DT-RC ' RESULT ' DT-RESULT-DATE
                       ' DAYS ' WS-DISPLAY-DAYS
           END-IF.
