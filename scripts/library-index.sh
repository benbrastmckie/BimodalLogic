#!/usr/bin/env bash
# library-index.sh -- generate BimodalLib/INDEX.md, the index of the results library.
#
# The index lists every registered theorem by fragment and frame class, every second proof
# paired with a registered statement, every conjecture, and, for each pair of dual operators,
# the laws stated for the universal operator with no declared dual. It is rendered by the Lean
# command `library_index` (BimodalLib/Index.lean) from the kernel-checked rows of the library;
# this script is the one named entry point that runs it.
#
# Usage:
#   scripts/library-index.sh            build BimodalLib and rewrite BimodalLib/INDEX.md
#   scripts/library-index.sh --check    build BimodalLib and fail if BimodalLib/INDEX.md is stale
#   scripts/library-index.sh --no-build as either form above, without building first
#
# Exit status: 0 on success (or, with --check, when the committed index is current);
# 1 when --check finds a difference; 2 on a usage error; otherwise the status of the failing
# build or of the Lean run.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$ROOT/BimodalLib/INDEX.md"

check=0
build=1
for arg in "$@"; do
  case "$arg" in
    --check) check=1 ;;
    --no-build) build=0 ;;
    -h|--help) sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "library-index.sh: unknown argument: $arg" >&2; exit 2 ;;
  esac
done

cd "$ROOT"

if [ "$build" -eq 1 ]; then
  lake build BimodalLib >&2
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# A one-line driver: the command reads the rows of every module `BimodalLib` imports.
printf 'import BimodalLib\nlibrary_index to "%s"\n' "$work/INDEX.md" > "$work/Driver.lean"
lake env lean "$work/Driver.lean" >&2

if [ ! -s "$work/INDEX.md" ]; then
  echo "library-index.sh: the index command wrote nothing" >&2
  exit 3
fi

if [ "$check" -eq 1 ]; then
  if ! diff -u "$INDEX" "$work/INDEX.md" >&2; then
    echo "library-index.sh: BimodalLib/INDEX.md is stale; run scripts/library-index.sh" >&2
    exit 1
  fi
  echo "library-index.sh: BimodalLib/INDEX.md is current"
else
  cp "$work/INDEX.md" "$INDEX"
  echo "library-index.sh: wrote BimodalLib/INDEX.md"
fi
