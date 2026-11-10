       01  XRF-RECORD.
           05  XRF-CARD-NUM                PIC X(16).
           05  XRF-ACCT-NUM                PIC X(12).
           05  XRF-CARD-STATUS             PIC X.
               88  XRF-CARD-ACTIVE         VALUE 'A'.
               88  XRF-CARD-LOST           VALUE 'L'.
               88  XRF-CARD-CLOSED         VALUE 'C'.
           05  XRF-EXPIRY                  PIC 9(6).
           05  FILLER                      PIC X(15).
