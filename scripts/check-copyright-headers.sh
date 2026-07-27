#!/usr/bin/env bash
# Copyright-header checker for this project's Lean sources.
#
# WHY THIS EXISTS: Mathlib's `linter.style.header` cannot see this project.
# Its gate, `isInLibraryRoot` (Mathlib/Tactic/Linter/Header.lean:259-264), looks for
# `<root>.lean` relative to the CWD and asks whether that file *directly* imports the
# module being linted. This project's lakefile sets `srcDir := "FormalSystem"`, so the root
# lives at `FormalSystem.lean` and `./FormalSystem.lean` does not exist -- the linter
# silently no-ops on every file. Even with the root path fixed, `FormalSystem.lean`
# directly imports only `FormalSystem.Bimodal`, so the linter would still cover exactly one
# module. Hence a text-based checker.
#
# The predicate below mirrors Mathlib's `copyrightHeaderChecks`
# (Mathlib/Tactic/Linter/Header.lean:182-249), which is the check cslib CI enforces.
#
# Usage:
#   check-copyright-headers.sh [ROOT ...]        # report counts + write bucket lists
#   check-copyright-headers.sh --strict [ROOT..] # additionally exit 1 if anything is wrong
#   check-copyright-headers.sh --exclude GLOB    # skip paths matching GLOB (repeatable)
#
# --exclude exists because the 151 archived files under the two Boneyard trees
# (FormalSystem/Boneyard/ and FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/)
# are intentionally unheadered, so `--strict FormalSystem` could otherwise never exit 0.
# The live-set gate is:
#   check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem
#
# Bucket lists are written to $OUTDIR (default: a mktemp dir, path echoed at the end).
set -uo pipefail

LICENSE_LINE='Released under Apache 2.0 license as described in the file LICENSE.'
STRICT=0
ROOTS=()
EXCLUDES=()
want_exclude=0
for a in "$@"; do
  if [ "$want_exclude" = 1 ]; then EXCLUDES+=("$a"); want_exclude=0; continue; fi
  case "$a" in
    --strict) STRICT=1 ;;
    --exclude) want_exclude=1 ;;
    --exclude=*) EXCLUDES+=("${a#--exclude=}") ;;
    *) ROOTS+=("$a") ;;
  esac
done
if [ "$want_exclude" = 1 ]; then
  echo "error: --exclude requires a PATTERN argument" >&2
  exit 2
fi
[ "${#ROOTS[@]}" -eq 0 ] && ROOTS=("FormalSystem")

# Build the find predicate: `! -path GLOB` per exclusion.
FIND_ARGS=()
for pat in ${EXCLUDES+"${EXCLUDES[@]}"}; do
  FIND_ARGS+=(! -path "$pat")
done

OUTDIR="${OUTDIR:-$(mktemp -d)}"
mkdir -p "$OUTDIR"
: >"$OUTDIR/conforming.txt"
: >"$OUTDIR/nonconforming.txt"
: >"$OUTDIR/missing.txt"
: >"$OUTDIR/duplicate.txt"

conforming=0; nonconforming=0; missing=0; duplicate=0

while IFS= read -r f; do
  # A stale/second copyright block anywhere in the file is a duplicate. Checked FIRST,
  # because validating only the leading block would silently pass a double-headered file.
  n_cop=$(grep -ci '^Copyright (c) ' "$f")
  n_lic=$(grep -cF "$LICENSE_LINE" "$f")
  if [ "$n_cop" -gt 1 ] || [ "$n_lic" -gt 1 ]; then
    duplicate=$((duplicate+1)); echo "$f" >>"$OUTDIR/duplicate.txt"; continue
  fi

  if ! head -10 "$f" | grep -qi 'copyright'; then
    missing=$((missing+1)); echo "$f" >>"$OUTDIR/missing.txt"; continue
  fi

  ok=1
  [ "$(sed -n 1p "$f")" = "/-" ] || ok=0
  sed -n 2p "$f" | grep -Eq '^Copyright \(c\) 20[0-9]{2} .+\. All rights reserved\.$' || ok=0
  [ "$(sed -n 3p "$f")" = "$LICENSE_LINE" ] || ok=0
  # Authors block: line 4 must be `Authors: <names>` not ending in a period;
  # continuation lines must end in a comma; block terminates with `-/` by line 12.
  sed -n 4p "$f" | grep -Eq '^Authors: [^ ].*[^.]$' || ok=0
  closed=0
  for n in 4 5 6 7 8 9 10 11 12; do
    ln=$(sed -n "${n}p" "$f")
    if [ "$ln" = "-/" ]; then closed=1; break; fi
    if [ "$n" -gt 4 ]; then
      case "$ln" in Authors:*|*,) ;; *) ok=0 ;; esac
    fi
  done
  [ "$closed" = 1 ] || ok=0

  if [ "$ok" = 1 ]; then
    conforming=$((conforming+1)); echo "$f" >>"$OUTDIR/conforming.txt"
  else
    nonconforming=$((nonconforming+1)); echo "$f" >>"$OUTDIR/nonconforming.txt"
  fi
done < <(find "${ROOTS[@]}" ${FIND_ARGS+"${FIND_ARGS[@]}"} -name '*.lean' -type f | sort)

total=$((conforming+nonconforming+missing+duplicate))
printf 'roots        : %s\n' "${ROOTS[*]}"
printf 'excludes     : %s\n' "${EXCLUDES[*]:-(none)}"
printf 'conforming   : %d\n' "$conforming"
printf 'nonconforming: %d\n' "$nonconforming"
printf 'duplicate    : %d\n' "$duplicate"
printf 'missing      : %d\n' "$missing"
printf 'total        : %d\n' "$total"
printf 'lists        : %s\n' "$OUTDIR"

if [ "$STRICT" = 1 ] && [ $((nonconforming+missing+duplicate)) -gt 0 ]; then
  exit 1
fi
exit 0
