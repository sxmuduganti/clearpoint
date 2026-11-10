#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-$ROOT/build/restart}"
BUSDATE="${BUSDATE:-20261108}"
ABEND_AT="${ABEND_AT:-2750}"
source "$ROOT/scripts/lib.sh"

rm -rf "$WORK"
mkdir -p "$WORK"

python3 "$TOOLS/gendata.py" --out "$WORK" \
  --business-date "$BUSDATE" --transactions 5000 --seed 4242

cards "$WORK/DATECARD" "BUSDATE=$BUSDATE"
cards "$WORK/POSTNORM" "BUSDATE=$BUSDATE" "MODE=NORMAL" "CHKPINT=200"
cards "$WORK/POSTFAIL" "BUSDATE=$BUSDATE" "MODE=NORMAL" "CHKPINT=200" \
                       "ABENDAT=$ABEND_AT"
cards "$WORK/POSTRSTR" "BUSDATE=$BUSDATE" "MODE=RESTART" "CHKPINT=200"

load_masters
step CPVALID  CTLCARD=DATECARD TRANIN=TRANIN.dat VALIDOUT=VALID \
              REJECTS=REJECTS.VALID CTLOUT=CTL.VALID
step CPENRICH CTLCARD=DATECARD VALIDIN=VALID CARDXREF=CARDXREF \
              MERCHMST=MERCHMST ENROUT=ENRICHED \
              REJECTS=REJECTS.ENRICH CTLOUT=CTL.ENRICH
sort_enriched ENRICHED ENRSORT

echo
echo "=== baseline: uninterrupted posting run"
load_masters
step CPPOST CTLCARD=POSTNORM ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
            RSTCTL=RSTCTL POSTOUT=POSTED.BASE SUSPENSE=SUSPENSE.BASE \
            CTLOUT=CTL.BASE
step CPACCUNL ACCTMAST=ACCTMAST ACCTEXT=ACCOUNTS.BASE

echo
echo "=== failure: posting run halted at record $ABEND_AT"
load_masters
MAX_RC=16 step CPPOST CTLCARD=POSTFAIL ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
            RSTCTL=RSTCTL POSTOUT=POSTED.FAIL SUSPENSE=SUSPENSE.FAIL \
            CTLOUT=CTL.FAIL
expect_rc 16

echo
echo "=== guard: a normal resubmission must be refused"
MAX_RC=16 step CPPOST CTLCARD=POSTNORM ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
            RSTCTL=RSTCTL POSTOUT=POSTED.RERUN SUSPENSE=SUSPENSE.RERUN \
            CTLOUT=CTL.RERUN
expect_rc 16

echo
echo "=== restart from last checkpoint"
step CPPOST CTLCARD=POSTRSTR ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
            RSTCTL=RSTCTL POSTOUT=POSTED.RSTR SUSPENSE=SUSPENSE.RSTR \
            CTLOUT=CTL.RSTR
step CPACCUNL ACCTMAST=ACCTMAST ACCTEXT=ACCOUNTS.RSTR

echo
echo "=== guard: a completed business date must not post twice"
MAX_RC=16 step CPPOST CTLCARD=POSTNORM ENRSORT=ENRSORT ACCTMAST=ACCTMAST \
            RSTCTL=RSTCTL POSTOUT=POSTED.TWICE SUSPENSE=SUSPENSE.TWICE \
            CTLOUT=CTL.TWICE
expect_rc 16

echo
echo "=== verification"
cmp "$WORK/ACCOUNTS.BASE" "$WORK/ACCOUNTS.RSTR"
echo "account master after restart is identical to the baseline"
cmp "$WORK/SUSPENSE.BASE" "$WORK/SUSPENSE.RSTR"
echo "suspense file after restart is identical to the baseline"
cmp <(head -c 88 "$WORK/CTL.BASE") <(head -c 88 "$WORK/CTL.RSTR")
echo "posting control totals after restart match the baseline"
echo
echo "checkpoint/restart test passed"
