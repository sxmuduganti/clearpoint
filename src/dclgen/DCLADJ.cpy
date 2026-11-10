           EXEC SQL DECLARE CP_ADJUSTMENT TABLE
           ( ADJ_ID                         INTEGER NOT NULL,
             ACCT_NUM                       CHAR(12) NOT NULL,
             ADJ_TYPE                       CHAR(1) NOT NULL,
             AMOUNT                         DECIMAL(11, 2) NOT NULL,
             REASON_CODE                    CHAR(4) NOT NULL,
             STATUS                         CHAR(1) NOT NULL,
             MAKER_ID                       CHAR(8) NOT NULL,
             MAKER_TS                       TIMESTAMP NOT NULL,
             CHECKER_ID                     CHAR(8),
             CHECKER_TS                     TIMESTAMP
           ) END-EXEC.
       01  DCLCP-ADJUSTMENT.
           10  HV-ADJ-ID                   PIC S9(9) USAGE COMP.
           10  HV-ADJ-ACCT-NUM             PIC X(12).
           10  HV-ADJ-TYPE                 PIC X(1).
           10  HV-ADJ-AMOUNT               PIC S9(9)V9(2) USAGE COMP-3.
           10  HV-ADJ-REASON-CODE          PIC X(4).
           10  HV-ADJ-STATUS               PIC X(1).
           10  HV-ADJ-MAKER-ID             PIC X(8).
           10  HV-ADJ-MAKER-TS             PIC X(26).
           10  HV-ADJ-CHECKER-ID           PIC X(8).
           10  HV-ADJ-CHECKER-TS           PIC X(26).
       01  DCLCP-ADJUSTMENT-IND.
           10  HI-ADJ-CHECKER-ID           PIC S9(4) USAGE COMP.
           10  HI-ADJ-CHECKER-TS           PIC S9(4) USAGE COMP.
