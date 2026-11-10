       01  PST-RECORD.
           05  PST-ENRICHED                PIC X(200).
           05  PST-PRODUCT                 PIC X(4).
           05  PST-POST-DATE               PIC 9(8).
           05  PST-NEW-BALANCE             PIC S9(9)V99
                                           SIGN LEADING SEPARATE.
           05  PST-OVERLIMIT               PIC X.
               88  PST-IS-OVERLIMIT        VALUE 'Y'.
           05  PST-POST-STATUS             PIC X.
               88  PST-APPLIED             VALUE 'P'.
               88  PST-PREVIOUSLY-APPLIED  VALUE 'R'.
           05  FILLER                      PIC X(24).
