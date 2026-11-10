       01  FS-RECORD.
           05  FS-KEY.
               10  FS-NETWORK              PIC X(4).
               10  FS-PRODUCT              PIC X(4).
               10  FS-MCC-CLASS            PIC X(2).
               10  FS-PRESENCE             PIC X.
           05  FS-RATE                     PIC 9V9(4).
           05  FS-PER-ITEM                 PIC 9(3)V99.
           05  FS-MAX-FEE                  PIC 9(5)V99.
           05  FS-EFF-DATE                 PIC 9(8).
           05  FILLER                      PIC X(44).
