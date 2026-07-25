#!/usr/bin/env bash
# Prepend the project's Apache-2.0 copyright header to live Lean sources.
#
# The emitted block, at line 1, above every `import` -- never inserted mid-file:
#
#   /-
#   Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
#   Released under Apache 2.0 license as described in the file LICENSE.
#   Authors: Benjamin Brast-McKie
#   -/
#
# YYYY is the file's git creation year (oldest `--diff-filter=A` commit), defaulting
# to 2026 when git has no add-record for the path.
#
# SKIP PREDICATES (a file is a target only if it passes BOTH):
#   1. Its path does not match `*/Boneyard/*`. There are TWO Boneyard trees --
#      Theories/Bimodal/Boneyard/ (89 files) and
#      Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/ (62 files) -- so a
#      predicate keyed on the top-level path alone would wrongly header 62 files.
#   2. It does not contain a line-initial `#exit`. All 151 archived files carry one and
#      no file outside the two Boneyard trees does, so this is an independent check on (1).
#
# SAFETY PREDICATE (both required before any write, else the file is reported and skipped):
#   - no `copyright` (case-insensitive) in the first 10 lines, AND
#   - no line-initial `Copyright (c) ` anywhere in the file.
# The second condition is what stops a naive prepend from double-heading the two files
# that already carry a stale header; those are repaired by hand, not by this script.
#
# Usage:
#   add-copyright-headers.sh [--dry-run] [ROOT ...]   # ROOT defaults to Theories
#
# Lists and the year manifest are written to $OUTDIR (default: a mktemp dir, echoed at the end).
set -uo pipefail

DRY_RUN=0
ROOTS=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    -*) echo "error: unknown flag $a" >&2; exit 2 ;;
    *) ROOTS+=("$a") ;;
  esac
done
[ "${#ROOTS[@]}" -eq 0 ] && ROOTS=("Theories")

DEFAULT_YEAR=2026
HOLDER='Benjamin Brast-McKie'
LICENSE_LINE='Released under Apache 2.0 license as described in the file LICENSE.'

OUTDIR="${OUTDIR:-$(mktemp -d)}"
mkdir -p "$OUTDIR"
: >"$OUTDIR/targets.txt"
: >"$OUTDIR/skipped-boneyard.txt"
: >"$OUTDIR/skipped-exit.txt"
: >"$OUTDIR/skipped-safety.txt"
: >"$OUTDIR/manifest.tsv"

n_target=0; n_boneyard=0; n_exit=0; n_safety=0

# ---- selection ---------------------------------------------------------------
while IFS= read -r f; do
  case "$f" in
    */Boneyard/*) n_boneyard=$((n_boneyard+1)); echo "$f" >>"$OUTDIR/skipped-boneyard.txt"; continue ;;
  esac
  if grep -q '^#exit' "$f"; then
    n_exit=$((n_exit+1)); echo "$f	(contains ^#exit, archived)" >>"$OUTDIR/skipped-exit.txt"; continue
  fi
  reason=''
  if head -10 "$f" | grep -qi 'copyright'; then
    reason='copyright in first 10 lines'
  elif grep -q '^Copyright (c) ' "$f"; then
    reason='^Copyright (c) elsewhere in file'
  fi
  if [ -n "$reason" ]; then
    n_safety=$((n_safety+1)); echo "$f	$reason" >>"$OUTDIR/skipped-safety.txt"; continue
  fi
  n_target=$((n_target+1)); echo "$f" >>"$OUTDIR/targets.txt"
done < <(find "${ROOTS[@]}" -name '*.lean' -type f | sort)

# ---- year manifest (built before anything is written) ------------------------
# Covers every in-scope live file, targets and safety-skips alike, so the manifest row
# count matches the live-set size rather than only the writable subset.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  y=$(git log --diff-filter=A --follow --format='%ad' --date=format:'%Y' -- "$f" 2>/dev/null | tail -1)
  case "$y" in
    20[0-9][0-9]) ;;
    *) y="$DEFAULT_YEAR" ;;
  esac
  printf '%s\t%s\n' "$f" "$y" >>"$OUTDIR/manifest.tsv"
done < <(cat "$OUTDIR/targets.txt"; cut -f1 "$OUTDIR/skipped-safety.txt")
sort -o "$OUTDIR/manifest.tsv" "$OUTDIR/manifest.tsv"

emit_header() {
  printf '/-\nCopyright (c) %s %s. All rights reserved.\n%s\nAuthors: %s\n-/\n\n' \
    "$1" "$HOLDER" "$LICENSE_LINE" "$HOLDER"
}

# ---- report ------------------------------------------------------------------
printf 'roots            : %s\n' "${ROOTS[*]}"
printf 'mode             : %s\n' "$([ "$DRY_RUN" = 1 ] && echo 'DRY RUN (writes nothing)' || echo 'APPLY')"
printf 'targets          : %d\n' "$n_target"
printf 'skipped boneyard : %d\n' "$n_boneyard"
printf 'skipped #exit    : %d\n' "$n_exit"
printf 'skipped safety   : %d\n' "$n_safety"
printf 'manifest rows    : %d\n' "$(wc -l <"$OUTDIR/manifest.tsv")"
printf 'year split       :\n'
cut -f2 "$OUTDIR/manifest.tsv" | sort | uniq -c | sed 's/^/                   /'
bad_years=$(cut -f2 "$OUTDIR/manifest.tsv" | grep -cvE '^20[0-9]{2}$')
printf 'malformed years  : %d\n' "$bad_years"
if [ "$n_safety" -gt 0 ]; then
  printf 'safety skips     :\n'
  sed 's/^/                   /' "$OUTDIR/skipped-safety.txt"
fi

if [ "$DRY_RUN" = 1 ]; then
  sample=$(head -1 "$OUTDIR/targets.txt")
  if [ -n "$sample" ]; then
    sample_year=$(awk -F'\t' -v f="$sample" '$1==f{print $2}' "$OUTDIR/manifest.tsv")
    printf '\nsample before/after for %s (year %s):\n' "$sample" "$sample_year"
    printf -- '--- before (first 6 lines) ---\n'
    head -6 "$sample" | sed 's/^/  /'
    printf -- '--- after (first 6 lines) ---\n'
    { emit_header "$sample_year"; cat "$sample"; } | head -6 | sed 's/^/  /'
  fi
  printf '\nlists            : %s\n' "$OUTDIR"
  exit 0
fi

# ---- apply -------------------------------------------------------------------
n_written=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  y=$(awk -F'\t' -v ff="$f" '$1==ff{print $2}' "$OUTDIR/manifest.tsv")
  case "$y" in 20[0-9][0-9]) ;; *) echo "error: no year for $f" >&2; exit 1 ;; esac
  tmp="$f.hdr.$$"
  { emit_header "$y"; cat "$f"; } >"$tmp" || { echo "error: write failed for $f" >&2; rm -f "$tmp"; exit 1; }
  mv "$tmp" "$f" || { echo "error: mv failed for $f" >&2; exit 1; }
  n_written=$((n_written+1))
done <"$OUTDIR/targets.txt"

printf 'written          : %d\n' "$n_written"
printf 'lists            : %s\n' "$OUTDIR"
exit 0
