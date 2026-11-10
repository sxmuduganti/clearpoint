       01  RST-RECORD.
           05  RST-KEY                     PIC X(8).
           05  RST-STATUS                  PIC X.
               88  RST-RUNNING             VALUE 'R'.
               88  RST-COMPLETE            VALUE 'C'.
           05  RST-BUS-DATE                PIC 9(8).
           05  RST-START-DATE              PIC 9(8).
           05  RST-START-TIME              PIC 9(6).
           05  RST-CHKP-DATE               PIC 9(8).
           05  RST-CHKP-TIME               PIC 9(6).
           05  RST-RECS-READ               PIC 9(9).
           05  RST-LAST-KEY                PIC X(42).
           05  RST-RUN-COUNT               PIC 9(3).
           05  FILLER                      PIC X(1).
