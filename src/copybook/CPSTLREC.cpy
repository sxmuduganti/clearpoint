       01  STL-RECORD.
           05  STL-REC-TYPE                PIC X.
               88  STL-CATEGORY            VALUE 'C'.
               88  STL-NETWORK-TOTAL       VALUE 'N'.
               88  STL-GRAND-TOTAL         VALUE 'G'.
           05  STL-BUS-DATE                PIC 9(8).
           05  STL-NETWORK                 PIC X(4).
           05  STL-MCC-CLASS               PIC X(2).
           05  STL-DR-COUNT                PIC 9(9).
           05  STL-DR-AMOUNT               PIC 9(13)V99.
           05  STL-CR-COUNT                PIC 9(9).
           05  STL-CR-AMOUNT               PIC 9(13)V99.
           05  STL-INTERCHANGE             PIC S9(11)V99
                                           SIGN LEADING SEPARATE.
           05  STL-NET-SETTLEMENT          PIC S9(13)V99
                                           SIGN LEADING SEPARATE.
           05  FILLER                      PIC X(57).
