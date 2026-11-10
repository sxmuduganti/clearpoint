       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPABEND.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-TIMESTAMP.
           05  WS-TS-DATE                  PIC 9(8).
           05  WS-TS-TIME                  PIC 9(6).
           05  FILLER                      PIC X(7).
       01  WS-RC-DISPLAY                   PIC ZZZ9.
       01  WS-RULE                         PIC X(72) VALUE ALL '*'.
       LINKAGE SECTION.
           COPY CPERRWS.
       PROCEDURE DIVISION USING ERR-AREA.
       0000-MAINLINE.
           MOVE FUNCTION CURRENT-DATE TO WS-TIMESTAMP
           IF ERR-RETURN-CODE NOT > ZERO
               MOVE 16 TO ERR-RETURN-CODE
           END-IF
           MOVE ERR-RETURN-CODE TO WS-RC-DISPLAY
           DISPLAY WS-RULE
           DISPLAY 'CLEARPOINT PROCESSING TERMINATED'
           DISPLAY '  PROGRAM     : ' ERR-PROGRAM
           DISPLAY '  PARAGRAPH   : ' ERR-PARAGRAPH
           DISPLAY '  TIMESTAMP   : ' WS-TS-DATE ' ' WS-TS-TIME
           IF ERR-FILE NOT = SPACES
               DISPLAY '  FILE        : ' ERR-FILE
               DISPLAY '  FILE STATUS : ' ERR-STATUS
           END-IF
           DISPLAY '  REASON      : ' ERR-MESSAGE
           DISPLAY '  RETURN CODE : ' WS-RC-DISPLAY
           DISPLAY WS-RULE
           MOVE ERR-RETURN-CODE TO RETURN-CODE
           STOP RUN.
