           EXEC SQL DECLARE CP_AUDIT_LOG TABLE
           ( AUDIT_TS                       TIMESTAMP NOT NULL,
             USER_ID                        CHAR(8) NOT NULL,
             ACCT_NUM                       CHAR(12) NOT NULL,
             ACTION                         CHAR(8) NOT NULL,
             REF_ID                         INTEGER,
             BEFORE_BAL                     DECIMAL(11, 2),
             AFTER_BAL                      DECIMAL(11, 2)
           ) END-EXEC.
       01  DCLCP-AUDIT-LOG.
           10  HV-AUD-AUDIT-TS             PIC X(26).
           10  HV-AUD-USER-ID              PIC X(8).
           10  HV-AUD-ACCT-NUM             PIC X(12).
           10  HV-AUD-ACTION               PIC X(8).
           10  HV-AUD-REF-ID               PIC S9(9) USAGE COMP.
           10  HV-AUD-BEFORE-BAL           PIC S9(9)V9(2) USAGE COMP-3.
           10  HV-AUD-AFTER-BAL            PIC S9(9)V9(2) USAGE COMP-3.
