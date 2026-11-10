           EXEC SQL DECLARE CP_FEE_SCHEDULE TABLE
           ( NETWORK                        CHAR(4) NOT NULL,
             PRODUCT                        CHAR(4) NOT NULL,
             MCC_CLASS                      CHAR(2) NOT NULL,
             PRESENCE                       CHAR(1) NOT NULL,
             RATE                           DECIMAL(5, 4) NOT NULL,
             PER_ITEM                       DECIMAL(5, 2) NOT NULL,
             MAX_FEE                        DECIMAL(7, 2) NOT NULL,
             EFF_DATE                       DATE NOT NULL,
             END_DATE                       DATE,
             UPDATED_BY                     CHAR(8) NOT NULL,
             UPDATED_TS                     TIMESTAMP NOT NULL
           ) END-EXEC.
       01  DCLCP-FEE-SCHEDULE.
           10  HV-FEE-NETWORK              PIC X(4).
           10  HV-FEE-PRODUCT              PIC X(4).
           10  HV-FEE-MCC-CLASS            PIC X(2).
           10  HV-FEE-PRESENCE             PIC X(1).
           10  HV-FEE-RATE                 PIC S9(1)V9(4) USAGE COMP-3.
           10  HV-FEE-PER-ITEM             PIC S9(3)V9(2) USAGE COMP-3.
           10  HV-FEE-MAX-FEE              PIC S9(5)V9(2) USAGE COMP-3.
           10  HV-FEE-EFF-DATE             PIC X(10).
           10  HV-FEE-END-DATE             PIC X(10).
           10  HV-FEE-UPDATED-BY           PIC X(8).
           10  HV-FEE-UPDATED-TS           PIC X(26).
