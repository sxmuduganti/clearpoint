#!/usr/bin/env bash

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BIN="$ROOT/build/bin"
TOOLS="$ROOT/tools"
LAST_RC=0

cards() {
  local file="$1"
  shift
  printf '%-80.80s' "$@" > "$file"
}

step() {
  local program="$1"
  shift
  local max_rc="${MAX_RC:-4}"
  local assignments=()
  local dd name path
  for dd in "$@"; do
    name="${dd%%=*}"
    path="${dd#*=}"
    [[ "$path" == /* ]] || path="$WORK/$path"
    assignments+=("DD_${name}=${path}")
  done
  echo
  echo ">>> $program"
  set +e
  env "${assignments[@]}" "$BIN/$program"
  LAST_RC=$?
  set -e
  echo "<<< $program RC=$LAST_RC"
  if (( LAST_RC > max_rc )); then
    echo "$program ended with RC=$LAST_RC (maximum allowed $max_rc)" >&2
    exit 1
  fi
}

expect_rc() {
  local expected="$1"
  if (( LAST_RC != expected )); then
    echo "expected RC=$expected but got RC=$LAST_RC" >&2
    exit 1
  fi
}

sort_enriched() {
  python3 "$TOOLS/fsort.py" --lrecl 200 \
    --key 90,12 --key 64,8 --key 72,6 --key 1,16 \
    "$WORK/$1" "$WORK/$2"
}

sort_fees() {
  python3 "$TOOLS/fsort.py" --lrecl 150 \
    --key 29,4 --key 37,2 --key 1,16 \
    "$WORK/$1" "$WORK/$2"
}

load_masters() {
  rm -f "$WORK"/ACCTMAST* "$WORK"/CARDXREF "$WORK"/CARDXREF.* \
        "$WORK"/MERCHMST* "$WORK"/RSTCTL*
  cards "$WORK/LOADACCT" "LOAD=ACCOUNTS"
  cards "$WORK/LOADCARD" "LOAD=CARDS"
  cards "$WORK/LOADMERC" "LOAD=MERCHANTS"
  step CPMSTLD CTLCARD=LOADACCT ACCTIN=ACCTEXT.dat ACCTMAST=ACCTMAST
  step CPMSTLD CTLCARD=LOADCARD CARDIN=CARDXREF.dat CARDXREF=CARDXREF
  step CPMSTLD CTLCARD=LOADMERC MERCHIN=MERCHANT.dat MERCHMST=MERCHMST
}

record_count() {
  local size
  size=$(stat -c %s "$WORK/$1")
  echo $(( size / $2 ))
}
