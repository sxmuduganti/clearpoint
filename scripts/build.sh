#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"
COBFLAGS=(-std=ibm -fstatic-call -I "$ROOT/src/copybook")

rm -rf "$BUILD/obj" "$BUILD/bin"
mkdir -p "$BUILD/obj" "$BUILD/bin"

cobc --version | head -n 1

for src in "$ROOT"/src/common/*.cbl; do
  name="$(basename "$src" .cbl)"
  echo "compile  $name"
  cobc -c "${COBFLAGS[@]}" -o "$BUILD/obj/$name.o" "$src"
done

for src in "$ROOT"/src/batch/*.cbl "$ROOT"/tests/*.cbl; do
  name="$(basename "$src" .cbl)"
  echo "link     $name"
  cobc -x "${COBFLAGS[@]}" -o "$BUILD/bin/$name" "$src" "$BUILD"/obj/*.o
done

echo "build complete: $(ls "$BUILD/bin" | wc -l) executables"
