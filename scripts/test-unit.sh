#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failed=0

for test in TCLUHN TCDATEU TCINTCH; do
  echo
  if ! "$ROOT/build/bin/$test"; then
    failed=1
  fi
done

if (( failed )); then
  echo "unit tests FAILED" >&2
  exit 1
fi
echo
echo "all unit tests passed"
