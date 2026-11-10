       01  CPINQ1I.
           02  FILLER                      PIC X(12).
           02  CURDATEL                    PIC S9(4) COMP.
           02  CURDATEF                    PIC X.
           02  FILLER REDEFINES CURDATEF.
               03  CURDATEA                PIC X.
           02  CURDATEI                    PIC X(10).
           02  ACCTNOL                     PIC S9(4) COMP.
           02  ACCTNOF                     PIC X.
           02  FILLER REDEFINES ACCTNOF.
               03  ACCTNOA                 PIC X.
           02  ACCTNOI                     PIC X(12).
           02  CUSTIDL                     PIC S9(4) COMP.
           02  CUSTIDF                     PIC X.
           02  FILLER REDEFINES CUSTIDF.
               03  CUSTIDA                 PIC X.
           02  CUSTIDI                     PIC X(10).
           02  PRODUCTL                    PIC S9(4) COMP.
           02  PRODUCTF                    PIC X.
           02  FILLER REDEFINES PRODUCTF.
               03  PRODUCTA                PIC X.
           02  PRODUCTI                    PIC X(4).
           02  ACSTATL                     PIC S9(4) COMP.
           02  ACSTATF                     PIC X.
           02  FILLER REDEFINES ACSTATF.
               03  ACSTATA                 PIC X.
           02  ACSTATI                     PIC X(15).
           02  OPENDTL                     PIC S9(4) COMP.
           02  OPENDTF                     PIC X.
           02  FILLER REDEFINES OPENDTF.
               03  OPENDTA                 PIC X.
           02  OPENDTI                     PIC X(10).
           02  CRLIMITL                    PIC S9(4) COMP.
           02  CRLIMITF                    PIC X.
           02  FILLER REDEFINES CRLIMITF.
               03  CRLIMITA                PIC X.
           02  CRLIMITI                    PIC X(15).
           02  CURBALL                     PIC S9(4) COMP.
           02  CURBALF                     PIC X.
           02  FILLER REDEFINES CURBALF.
               03  CURBALA                 PIC X.
           02  CURBALI                     PIC X(15).
           02  AVAILL                      PIC S9(4) COMP.
           02  AVAILF                      PIC X.
           02  FILLER REDEFINES AVAILF.
               03  AVAILA                  PIC X.
           02  AVAILI                      PIC X(15).
           02  CASHLIML                    PIC S9(4) COMP.
           02  CASHLIMF                    PIC X.
           02  FILLER REDEFINES CASHLIMF.
               03  CASHLIMA                PIC X.
           02  CASHLIMI                    PIC X(15).
           02  CASHBALL                    PIC S9(4) COMP.
           02  CASHBALF                    PIC X.
           02  FILLER REDEFINES CASHBALF.
               03  CASHBALA                PIC X.
           02  CASHBALI                    PIC X(15).
           02  CTDPURL                     PIC S9(4) COMP.
           02  CTDPURF                     PIC X.
           02  FILLER REDEFINES CTDPURF.
               03  CTDPURA                 PIC X.
           02  CTDPURI                     PIC X(15).
           02  CTDCRDL                     PIC S9(4) COMP.
           02  CTDCRDF                     PIC X.
           02  FILLER REDEFINES CTDCRDF.
               03  CTDCRDA                 PIC X.
           02  CTDCRDI                     PIC X(15).
           02  LSTPOSTL                    PIC S9(4) COMP.
           02  LSTPOSTF                    PIC X.
           02  FILLER REDEFINES LSTPOSTF.
               03  LSTPOSTA                PIC X.
           02  LSTPOSTI                    PIC X(10).
           02  MSGL                        PIC S9(4) COMP.
           02  MSGF                        PIC X.
           02  FILLER REDEFINES MSGF.
               03  MSGA                    PIC X.
           02  MSGI                        PIC X(78).
       01  CPINQ1O REDEFINES CPINQ1I.
           02  FILLER                      PIC X(12).
           02  FILLER                      PIC X(3).
           02  CURDATEO                    PIC X(10).
           02  FILLER                      PIC X(3).
           02  ACCTNOO                     PIC X(12).
           02  FILLER                      PIC X(3).
           02  CUSTIDO                     PIC X(10).
           02  FILLER                      PIC X(3).
           02  PRODUCTO                    PIC X(4).
           02  FILLER                      PIC X(3).
           02  ACSTATO                     PIC X(15).
           02  FILLER                      PIC X(3).
           02  OPENDTO                     PIC X(10).
           02  FILLER                      PIC X(3).
           02  CRLIMITO                    PIC X(15).
           02  FILLER                      PIC X(3).
           02  CURBALO                     PIC X(15).
           02  FILLER                      PIC X(3).
           02  AVAILO                      PIC X(15).
           02  FILLER                      PIC X(3).
           02  CASHLIMO                    PIC X(15).
           02  FILLER                      PIC X(3).
           02  CASHBALO                    PIC X(15).
           02  FILLER                      PIC X(3).
           02  CTDPURO                     PIC X(15).
           02  FILLER                      PIC X(3).
           02  CTDCRDO                     PIC X(15).
           02  FILLER                      PIC X(3).
           02  LSTPOSTO                    PIC X(10).
           02  FILLER                      PIC X(3).
           02  MSGO                        PIC X(78).
