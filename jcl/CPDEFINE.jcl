//CPDEFINE JOB (CP00,SETUP),'CLEARPOINT DEFINE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//DEFGDG   EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.TRANIN)    LIMIT(35) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.REJECTS)   LIMIT(35) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.SUSPENSE)  LIMIT(35) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.FEEDTL)    LIMIT(35) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.SETTLE)    LIMIT(90) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.SETLRPT)   LIMIT(90) NOEMPTY SCRATCH)
  DEFINE GENERATIONDATAGROUP -
         (NAME(CP.PROD.RECONRPT)  LIMIT(90) NOEMPTY SCRATCH)
/*
//DEFVSAM  EXEC PGM=IDCAMS,COND=(0,LT)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DEFINE CLUSTER (NAME(CP.PROD.ACCTMAST)        -
                  INDEXED                       -
                  KEYS(12 0)                    -
                  RECORDSIZE(200 200)           -
                  FREESPACE(20 10)              -
                  SHAREOPTIONS(2 3)             -
                  CYLINDERS(150 50))            -
         DATA    (NAME(CP.PROD.ACCTMAST.DATA)   -
                  CONTROLINTERVALSIZE(8192))    -
         INDEX   (NAME(CP.PROD.ACCTMAST.INDEX))

  DEFINE ALTERNATEINDEX                         -
                 (NAME(CP.PROD.ACCTMAST.CUSTAIX) -
                  RELATE(CP.PROD.ACCTMAST)      -
                  KEYS(10 12)                   -
                  NONUNIQUEKEY                  -
                  UPGRADE                       -
                  RECORDSIZE(39 4000)           -
                  CYLINDERS(20 10))             -
         DATA    (NAME(CP.PROD.ACCTMAST.CUSTAIX.DATA)) -
         INDEX   (NAME(CP.PROD.ACCTMAST.CUSTAIX.INDEX))

  DEFINE PATH    (NAME(CP.PROD.ACCTMAST.CUSTPATH) -
                  PATHENTRY(CP.PROD.ACCTMAST.CUSTAIX))

  DEFINE CLUSTER (NAME(CP.PROD.CARDXREF)        -
                  INDEXED                       -
                  KEYS(16 0)                    -
                  RECORDSIZE(50 50)             -
                  FREESPACE(15 10)              -
                  SHAREOPTIONS(2 3)             -
                  CYLINDERS(60 20))             -
         DATA    (NAME(CP.PROD.CARDXREF.DATA)   -
                  CONTROLINTERVALSIZE(4096))    -
         INDEX   (NAME(CP.PROD.CARDXREF.INDEX))

  DEFINE CLUSTER (NAME(CP.PROD.MERCHMST)        -
                  INDEXED                       -
                  KEYS(15 0)                    -
                  RECORDSIZE(100 100)           -
                  FREESPACE(15 10)              -
                  SHAREOPTIONS(2 3)             -
                  CYLINDERS(20 10))             -
         DATA    (NAME(CP.PROD.MERCHMST.DATA)   -
                  CONTROLINTERVALSIZE(4096))    -
         INDEX   (NAME(CP.PROD.MERCHMST.INDEX))

  DEFINE CLUSTER (NAME(CP.PROD.RSTCTL)          -
                  INDEXED                       -
                  KEYS(8 0)                     -
                  RECORDSIZE(100 100)           -
                  SHAREOPTIONS(2 3)             -
                  TRACKS(1 1))                  -
         DATA    (NAME(CP.PROD.RSTCTL.DATA))    -
         INDEX   (NAME(CP.PROD.RSTCTL.INDEX))
/*
