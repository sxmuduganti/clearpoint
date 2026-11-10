               15  :PFX:-TRAN-ID           PIC X(16).
               15  :PFX:-CARD-NUM          PIC X(16).
               15  :PFX:-MERCH-ID          PIC X(15).
               15  :PFX:-TRAN-TYPE         PIC X(2).
                   88  :PFX:-PURCHASE      VALUE 'PU'.
                   88  :PFX:-REFUND        VALUE 'RF'.
                   88  :PFX:-CASH-ADVANCE  VALUE 'CA'.
                   88  :PFX:-REVERSAL      VALUE 'RV'.
                   88  :PFX:-VALID-TYPE    VALUE 'PU' 'RF' 'CA' 'RV'.
                   88  :PFX:-DEBIT-TYPE    VALUE 'PU' 'CA'.
               15  :PFX:-AMOUNT            PIC 9(9)V99.
               15  :PFX:-CURRENCY          PIC X(3).
               15  :PFX:-TRAN-DATE         PIC 9(8).
               15  :PFX:-TRAN-TIME         PIC 9(6).
               15  :PFX:-TRAN-TIME-R REDEFINES :PFX:-TRAN-TIME.
                   20  :PFX:-TRAN-HH       PIC 9(2).
                   20  :PFX:-TRAN-MM       PIC 9(2).
                   20  :PFX:-TRAN-SS       PIC 9(2).
               15  :PFX:-AUTH-CODE         PIC X(6).
               15  :PFX:-ENTRY-MODE        PIC X(2).
                   88  :PFX:-KEYED         VALUE '01'.
                   88  :PFX:-CHIP          VALUE '05'.
                   88  :PFX:-CONTACTLESS   VALUE '07'.
                   88  :PFX:-ECOMMERCE     VALUE '81'.
                   88  :PFX:-VALID-ENTRY   VALUE '01' '05' '07' '81'.
                   88  :PFX:-CARD-PRESENT  VALUE '05' '07'.
               15  :PFX:-NETWORK           PIC X(4).
                   88  :PFX:-VALID-NETWORK VALUE 'VISA' 'MCRD'
                                                 'AMEX' 'DISC'.
