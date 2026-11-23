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
# 1 when --check finds a difference, or the shared build lock is not acquired in time;
# 2 on a usage error; 3 when the index command wrote
# nothing; 4 when the build fails; otherwise the status of the failing Lean run.

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

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# SHARED .lake LOCK. Both calls below read or write `.lake`, so this script takes the advisory
# lock on `.lake/build-guard.lock` that the other lake-calling scripts here take, in the shape
# scripts/README.md's "Shared `.lake` build lock" section fixes: `flock -n`, then a bounded
# announced wait, held to exit, and an audible unserialized run when `flock` is absent.
# `LIBRARY_INDEX_LOCK_WAIT_S` overrides the bound so the timeout branch can be exercised.
LIBRARY_INDEX_LOCK_WAIT_S="${LIBRARY_INDEX_LOCK_WAIT_S:-600}"
LOCK_FILE="$ROOT/.lake/build-guard.lock"
mkdir -p "$ROOT/.lake"
if command -v flock >/dev/null 2>&1; then
  exec {LIBRARY_INDEX_LOCK_FD}<>"$LOCK_FILE"
  if ! flock -n "$LIBRARY_INDEX_LOCK_FD"; then
    echo "library-index.sh: waiting on the shared build lock ($LOCK_FILE, up to ${LIBRARY_INDEX_LOCK_WAIT_S}s)" >&2
    if ! flock -w "$LIBRARY_INDEX_LOCK_WAIT_S" "$LIBRARY_INDEX_LOCK_FD"; then
      echo "library-index.sh: environment failure: timed out after ${LIBRARY_INDEX_LOCK_WAIT_S}s waiting for the shared build lock; nothing was read or written" >&2
      exit 1
    fi
  fi
else
  echo "library-index.sh: flock not found on PATH; building and rendering unserialized" >&2
fi

# The build replays every `info:` line of the whole import closure; show it only on failure.
if [ "$build" -eq 1 ]; then
  if ! lake build BimodalLib > "$work/build.log" 2>&1; then
    cat "$work/build.log" >&2
    echo "library-index.sh: lake build BimodalLib failed" >&2
    exit 4
  fi
fi

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
