       IDENTIFICATION DIVISION.
       PROGRAM-ID. TCLUHN.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-TEST-CASES.
           05  FILLER PIC X(17) VALUE '4111111111111111Y'.
           05  FILLER PIC X(17) VALUE '4111111111111112N'.
           05  FILLER PIC X(17) VALUE '5500000000000004Y'.
           05  FILLER PIC X(17) VALUE '4012888888881881Y'.
           05  FILLER PIC X(17) VALUE '6011000990139424Y'.
           05  FILLER PIC X(17) VALUE '0000000000000000N'.
           05  FILLER PIC X(17) VALUE '41111111111A1111N'.
           05  FILLER PIC X(17) VALUE '                N'.
           05  FILLER PIC X(17) VALUE '3714496353984310N'.
           05  FILLER PIC X(17) VALUE '3714496353984314Y'.
       01  WS-TEST-TABLE REDEFINES WS-TEST-CASES.
           05  WS-TEST-CASE                OCCURS 10 TIMES.
               10  WS-TC-CARD              PIC X(16).
               10  WS-TC-EXPECTED          PIC X.
       01  WS-SUB                          PIC S9(4) COMP.
       01  WS-PASSED                       PIC 9(4) VALUE 0.
       01  WS-FAILED                       PIC 9(4) VALUE 0.
           COPY CPLNPARM.
       PROCEDURE DIVISION.
       0000-MAINLINE.
           DISPLAY 'TCLUHN   CARD NUMBER CHECK DIGIT TESTS'
           PERFORM VARYING WS-SUB FROM 1 BY 1 UNTIL WS-SUB > 10
               MOVE WS-TC-CARD(WS-SUB) TO LN-CARD-NUM
               MOVE SPACE TO LN-RESULT
               CALL 'CPLUHN' USING LN-PARMS
               IF LN-RESULT = WS-TC-EXPECTED(WS-SUB)
                   ADD 1 TO WS-PASSED
                   DISPLAY '  PASS  ' WS-TC-CARD(WS-SUB)
                           ' EXPECTED ' WS-TC-EXPECTED(WS-SUB)
               ELSE
                   ADD 1 TO WS-FAILED
                   DISPLAY '  FAIL  ' WS-TC-CARD(WS-SUB)
                           ' EXPECTED ' WS-TC-EXPECTED(WS-SUB)
                           ' ACTUAL ' LN-RESULT
               END-IF
           END-PERFORM
           DISPLAY 'TCLUHN   PASSED ' WS-PASSED ' FAILED ' WS-FAILED
           IF WS-FAILED > ZERO
               MOVE 8 TO RETURN-CODE
           ELSE
               MOVE ZERO TO RETURN-CODE
           END-IF
           GOBACK.
