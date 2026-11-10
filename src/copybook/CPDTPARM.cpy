       01  DT-PARMS.
           05  DT-FUNCTION                 PIC X.
               88  DT-VALIDATE             VALUE 'V'.
               88  DT-DIFF                 VALUE 'D'.
               88  DT-ADD                  VALUE 'A'.
           05  DT-DATE-1                   PIC 9(8).
           05  DT-DATE-2                   PIC 9(8).
           05  DT-DAYS                     PIC S9(7) COMP-3.
           05  DT-RESULT-DATE              PIC 9(8).
           05  DT-RC                       PIC X(2).
               88  DT-OK                   VALUE '00'.
               88  DT-INVALID-DATE-1       VALUE '01'.
               88  DT-INVALID-DATE-2       VALUE '02'.
               88  DT-OUT-OF-RANGE         VALUE '03'.
               88  DT-BAD-FUNCTION         VALUE '99'.
