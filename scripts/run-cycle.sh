#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-$ROOT/build/cycle}"
BUSDATE="${BUSDATE:-20261108}"
TRANSACTIONS="${1:-20000}"
source "$ROOT/scripts/lib.sh"

rm -rf "$WORK"
mkdir -p "$WORK"

python3 "$TOOLS/gendata.py" --out "$WORK" \
  --business-date "$BUSDATE" --transactions "$TRANSACTIONS"

cards "$WORK/DATECARD" "BUSDATE=$BUSDATE"
cards "$WORK/POSTCARD" "BUSDATE=$BUSDATE" "MODE=NORMAL" "CHKPINT=500"

load_masters

step CPVALID  CTLCARD=DATECARD TRANIN=TRANIN.dat VALIDOUT=VALID \
              REJECTS=REJECTS.VALID CTLOUT=CTL.VALID

step CPENRICH CTLCARD=DATECARD VALIDIN=VALID CARDXREF=CARDXREF \
              MERCHMST=MERCHMST ENROUT=ENRICHED \
              REJECTS=REJECTS.ENRICH CTLOUT=CTL.ENRICH

sort_enriched ENRICHED ENRSORT

step CPPOST   CTLCARD=POSTCARD ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
              RSTCTL=RSTCTL POSTOUT=POSTED SUSPENSE=SUSPENSE \
              CTLOUT=CTL.POST

step CPFEECAL CTLCARD=DATECARD FEESCHED=FEESCHED.dat POSTIN=POSTED \
              FEEOUT=FEEDTL CTLOUT=CTL.FEECAL

sort_fees FEEDTL FEESORT

step CPSETTLE CTLCARD=DATECARD FEESORT=FEESORT SETLOUT=SETTLE \
              CTLOUT=CTL.SETTLE

cat "$WORK"/CTL.VALID "$WORK"/CTL.ENRICH "$WORK"/CTL.POST \
    "$WORK"/CTL.FEECAL "$WORK"/CTL.SETTLE > "$WORK/CTL.ALL"

MAX_RC=0 step CPRECON CTLCARD=DATECARD CTLIN=CTL.ALL RECONRPT=RECONRPT

step CPRPT    CTLCARD=DATECARD SETLIN=SETTLE RPTOUT=SETLRPT

step CPACCUNL ACCTMAST=ACCTMAST ACCTEXT=ACCOUNTS.OUT

python3 "$TOOLS/asa2txt.py" "$WORK/RECONRPT" > "$WORK/RECONRPT.txt"
python3 "$TOOLS/asa2txt.py" "$WORK/SETLRPT" > "$WORK/SETLRPT.txt"

echo
cat "$WORK/RECONRPT.txt"
echo
cat "$WORK/SETLRPT.txt"
echo
printf '%-16s %10s\n' "DATASET" "RECORDS"
printf '%-16s %10s\n' "TRANIN"         "$(record_count TRANIN.dat 150)"
printf '%-16s %10s\n' "VALID"          "$(record_count VALID 150)"
printf '%-16s %10s\n' "REJECTS.VALID"  "$(record_count REJECTS.VALID 210)"
printf '%-16s %10s\n' "REJECTS.ENRICH" "$(record_count REJECTS.ENRICH 210)"
printf '%-16s %10s\n' "POSTED"         "$(record_count POSTED 250)"
printf '%-16s %10s\n' "SUSPENSE"       "$(record_count SUSPENSE 250)"
printf '%-16s %10s\n' "FEEDTL"         "$(record_count FEEDTL 150)"
printf '%-16s %10s\n' "SETTLE"         "$(record_count SETTLE 150)"
echo
echo "nightly cycle completed for business date $BUSDATE"
