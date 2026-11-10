       01  TRN-RECORD.
           05  TRN-REC-TYPE                PIC X.
               88  TRN-HEADER              VALUE 'H'.
               88  TRN-DETAIL              VALUE 'D'.
               88  TRN-TRAILER             VALUE 'T'.
           05  TRN-DETAIL-DATA.
               10  TRN-CORE.
           COPY CPTRNCOR REPLACING ==:PFX:== BY ==TRN==.
               10  FILLER                  PIC X(60).
           05  TRN-HEADER-DATA REDEFINES TRN-DETAIL-DATA.
               10  TRN-HDR-FILE-ID         PIC X(8).
               10  TRN-HDR-BUS-DATE        PIC 9(8).
               10  TRN-HDR-SOURCE          PIC X(8).
               10  FILLER                  PIC X(125).
           05  TRN-TRAILER-DATA REDEFINES TRN-DETAIL-DATA.
               10  TRN-TRL-REC-COUNT       PIC 9(9).
               10  TRN-TRL-HASH-AMOUNT     PIC 9(13)V99.
               10  FILLER                  PIC X(125).
