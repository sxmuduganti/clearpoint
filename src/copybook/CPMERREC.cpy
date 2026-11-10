       01  MER-RECORD.
           05  MER-MERCH-ID                PIC X(15).
           05  MER-NAME                    PIC X(25).
           05  MER-MCC                     PIC 9(4).
           05  MER-CITY                    PIC X(15).
           05  MER-STATE                   PIC X(2).
           05  MER-COUNTRY                 PIC X(3).
           05  MER-STATUS                  PIC X.
               88  MER-ACTIVE              VALUE 'A'.
               88  MER-TERMINATED          VALUE 'T'.
           05  FILLER                      PIC X(35).
