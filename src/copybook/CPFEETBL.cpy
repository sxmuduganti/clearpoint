       01  FEE-TABLE.
           05  FT-ENTRY-COUNT              PIC S9(4) COMP.
           05  FT-ENTRY                    OCCURS 1 TO 500 TIMES
                                           DEPENDING ON FT-ENTRY-COUNT
                                           ASCENDING KEY IS FT-KEY
                                           INDEXED BY FT-IDX.
               10  FT-KEY.
                   15  FT-NETWORK          PIC X(4).
                   15  FT-PRODUCT          PIC X(4).
                   15  FT-MCC-CLASS        PIC X(2).
                   15  FT-PRESENCE         PIC X.
               10  FT-RATE                 PIC 9V9(4) COMP-3.
               10  FT-PER-ITEM             PIC 9(3)V99 COMP-3.
               10  FT-MAX-FEE              PIC 9(5)V99 COMP-3.
