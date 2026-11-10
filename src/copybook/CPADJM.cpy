       01  CPADJ1I.
           02  FILLER                      PIC X(12).
           02  CURDATEL                    PIC S9(4) COMP.
           02  CURDATEF                    PIC X.
           02  FILLER REDEFINES CURDATEF.
               03  CURDATEA                PIC X.
           02  CURDATEI                    PIC X(10).
           02  FUNCL                       PIC S9(4) COMP.
           02  FUNCF                       PIC X.
           02  FILLER REDEFINES FUNCF.
               03  FUNCA                   PIC X.
           02  FUNCI                       PIC X(1).
           02  ADJIDL                      PIC S9(4) COMP.
           02  ADJIDF                      PIC X.
           02  FILLER REDEFINES ADJIDF.
               03  ADJIDA                  PIC X.
           02  ADJIDI                      PIC X(7).
           02  ACCTNOL                     PIC S9(4) COMP.
           02  ACCTNOF                     PIC X.
           02  FILLER REDEFINES ACCTNOF.
               03  ACCTNOA                 PIC X.
           02  ACCTNOI                     PIC X(12).
           02  ADJTYPEL                    PIC S9(4) COMP.
           02  ADJTYPEF                    PIC X.
           02  FILLER REDEFINES ADJTYPEF.
               03  ADJTYPEA                PIC X.
           02  ADJTYPEI                    PIC X(1).
           02  AMOUNTL                     PIC S9(4) COMP.
           02  AMOUNTF                     PIC X.
           02  FILLER REDEFINES AMOUNTF.
               03  AMOUNTA                 PIC X.
           02  AMOUNTI                     PIC X(12).
           02  REASONL                     PIC S9(4) COMP.
           02  REASONF                     PIC X.
           02  FILLER REDEFINES REASONF.
               03  REASONA                 PIC X.
           02  REASONI                     PIC X(4).
           02  CURBALL                     PIC S9(4) COMP.
           02  CURBALF                     PIC X.
           02  FILLER REDEFINES CURBALF.
               03  CURBALA                 PIC X.
           02  CURBALI                     PIC X(15).
           02  ADJSTATL                    PIC S9(4) COMP.
           02  ADJSTATF                    PIC X.
           02  FILLER REDEFINES ADJSTATF.
               03  ADJSTATA                PIC X.
           02  ADJSTATI                    PIC X(10).
           02  MAKERL                      PIC S9(4) COMP.
           02  MAKERF                      PIC X.
           02  FILLER REDEFINES MAKERF.
               03  MAKERA                  PIC X.
           02  MAKERI                      PIC X(8).
           02  CHECKERL                    PIC S9(4) COMP.
           02  CHECKERF                    PIC X.
           02  FILLER REDEFINES CHECKERF.
               03  CHECKERA                PIC X.
           02  CHECKERI                    PIC X(8).
           02  MSGL                        PIC S9(4) COMP.
           02  MSGF                        PIC X.
           02  FILLER REDEFINES MSGF.
               03  MSGA                    PIC X.
           02  MSGI                        PIC X(78).
       01  CPADJ1O REDEFINES CPADJ1I.
           02  FILLER                      PIC X(12).
           02  FILLER                      PIC X(3).
           02  CURDATEO                    PIC X(10).
           02  FILLER                      PIC X(3).
           02  FUNCO                       PIC X(1).
           02  FILLER                      PIC X(3).
           02  ADJIDO                      PIC X(7).
           02  FILLER                      PIC X(3).
           02  ACCTNOO                     PIC X(12).
           02  FILLER                      PIC X(3).
           02  ADJTYPEO                    PIC X(1).
           02  FILLER                      PIC X(3).
           02  AMOUNTO                     PIC X(12).
           02  FILLER                      PIC X(3).
           02  REASONO                     PIC X(4).
           02  FILLER                      PIC X(3).
           02  CURBALO                     PIC X(15).
           02  FILLER                      PIC X(3).
           02  ADJSTATO                    PIC X(10).
           02  FILLER                      PIC X(3).
           02  MAKERO                      PIC X(8).
           02  FILLER                      PIC X(3).
           02  CHECKERO                    PIC X(8).
           02  FILLER                      PIC X(3).
           02  MSGO                        PIC X(78).
