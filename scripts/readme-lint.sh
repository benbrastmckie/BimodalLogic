#!/usr/bin/env bash
# readme-lint.sh -- Check README health across FormalSystem/
#
# Checks performed:
#   1. Every directory containing .lean files has a README.md
#   2. Every .lean file in a directory appears in its README.md   [REPORTED, not gated]
#   3. No broken relative file references in any markdown file in scope
#   4. Every README.md has a "Last verified" date, and that date is not
#      older than the directory's last commit     [GATED against scripts/readme-date-baseline.txt]
#
# Usage: ./scripts/readme-lint.sh [<root-directory> ...]
#
# Default root: FormalSystem. Multiple roots may be given; a root that is not a
# Lean tree (e.g. `docs`) is handled by scope selection below rather than being
# silently inert.
#
# Scope selection, and why it matters
# -----------------------------------
# Checks 2-4 previously opened only files literally named `README.md`. Under a Lean
# tree that is the right scope. Under `docs/` it is not: `docs/` has 6 files named
# README.md out of ~70, so pointing this script at `docs/` used to check 9% of it
# and report success. Check 1 compounded the problem by firing only on directories
# containing `.lean` files, making it structurally inert outside a Lean tree.
#
# A root is now classified: a root containing `.lean` files is a LEAN root and
# keeps the README.md-only scope; any other root is a DOC root, and Checks 3-4 scan
# every `*.md` file under it. Check 1 still applies to Lean roots only, because
# "every directory needs a README" is a Lean-tree convention.
#
# What is gated vs. merely reported
# ---------------------------------
# Checks 1 and 3 always affect the exit code. Check 2 (`NOT LISTED`) is REPORTED
# and deliberately not gated: the tree carries ~110 such warnings, all cosmetic,
# and gating them would convert a documentation nicety into a build failure.
# Check 4 (a missing `Last verified` date, or a present one that predates the
# directory's last commit) is reported in full, but its DEBT IS PINNED: every
# finding present when `scripts/readme-date-baseline.txt` was generated is
# grandfathered by exact (class, path, stamp) match, and the exit code responds
# only to a NEW finding -- one absent from that baseline, or a previously
# grandfathered `stale` row whose stamp has since changed (refreshing a stamp
# permanently un-grandfathers that README). This is controlled by
# `ENFORCE_README_DATES` below, defaulting to enforced. The summary block states
# the info/new counts for both checks explicitly so that "gated" and "reported"
# are never conflated with "not measured".
#
# Exit code: 0 = all clean, 1 = errors (or, with ENFORCE_README_DATES=1, a new
# Check 4 finding) found

set -euo pipefail

# Set to 0 only for a one-off local run that must not fail on a new stale/missing
# README date (e.g. while deliberately refreshing many stamps at once). The
# committed default is 1 because scripts/readme-date-baseline.txt pins the
# existing debt in the same change that introduces this flag -- it must never be
# flipped to 0 in the committed script to quiet a new finding.
ENFORCE_README_DATES="${ENFORCE_README_DATES:-1}"

if [ "$#" -eq 0 ]; then
  ROOTS=("FormalSystem")
else
  ROOTS=("$@")
fi

for r in "${ROOTS[@]}"; do
  if [ ! -d "$r" ]; then
    echo "Error: Root directory '$r' does not exist." >&2
    exit 1
  fi
done

# Backwards compatibility: the single-root variable is still used by the messages
# and by the Check 1 / summary traversals below.
ROOT="${ROOTS[0]}"

# A root containing .lean files is a Lean tree. Checks 3-4 scan README.md only
# there, and every *.md elsewhere -- see the scope note in the header.
is_lean_root() {
  [ -n "$(find "$1" -name '*.lean' -not -path '*/Boneyard/*' -print -quit 2>/dev/null)" ]
}

# Files whose links are link-syntax illustrations rather than links to follow.
# Shared verbatim with check C13 of check-module-invariants.sh, so the two agree.
LINK_ALLOWLIST="scripts/markdown-link-allowlist.txt"
link_allowlisted() {
  [ -f "$LINK_ALLOWLIST" ] || return 1
  sed 's/#.*//' "$LINK_ALLOWLIST" | grep -qxF "$1"
}

# Emit every markdown file in scope for a given root.
scope_md() {
  local r="$1"
  if is_lean_root "$r"; then
    find "$r" -name "README.md"
  else
    find "$r" -name "*.md"
  fi
}

ERRORS=0
WARNINGS=0

# Helper: print error
err() {
  echo "ERROR: $*"
  ERRORS=$((ERRORS + 1))
}

# Helper: print warning
warn() {
  echo "WARN:  $*"
  WARNINGS=$((WARNINGS + 1))
}

echo "=== README Lint: $ROOT ==="
echo ""

# -----------------------------------------------------------------------
# Check 1: Every directory with .lean files has a README.md
# -----------------------------------------------------------------------
echo "--- Check 1: Missing READMEs ---"
MISSING_COUNT=0
find "$ROOT" -type d | sort | while read -r dir; do
  # Skip Boneyard (archived code)
  case "$dir" in
    *Boneyard*) continue ;;
    */.git*) continue ;;
  esac
  # Count .lean files directly in this directory
  lean_count=$(find "$dir" -maxdepth 1 -name "*.lean" | wc -l)
  if [ "$lean_count" -gt 0 ] && [ ! -f "$dir/README.md" ]; then
    echo "  MISSING: $dir/README.md ($lean_count .lean files)"
    ERRORS=$((ERRORS + 1))
  fi
done

# -----------------------------------------------------------------------
# Check 2: Files in directory appear in its README.md
# -----------------------------------------------------------------------
echo ""
echo "--- Check 2: Files missing from README inventory ---"
find "$ROOT" -name "README.md" | sort | while read -r readme; do
  dir=$(dirname "$readme")
  # Skip Boneyard
  case "$dir" in
    *Boneyard*) continue ;;
  esac
  # Check each .lean file in the same directory
  find "$dir" -maxdepth 1 -name "*.lean" | sort | while read -r lean_file; do
    basename=$(basename "$lean_file")
    if ! grep -qF "$basename" "$readme"; then
      echo "  NOT LISTED: $basename not found in $readme"
      ERRORS=$((ERRORS + 1))
    fi
  done
  # Check subdirectories with .lean files
  find "$dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r subdir; do
    subdirname=$(basename "$subdir")
    lean_count=$(find "$subdir" -name "*.lean" | wc -l)
    if [ "$lean_count" -gt 0 ]; then
      if ! grep -qF "$subdirname" "$readme"; then
        echo "  NOT LISTED: $subdirname/ not found in $readme"
        WARNINGS=$((WARNINGS + 1))
      fi
    fi
  done
done

# -----------------------------------------------------------------------
# Check 3: Broken relative file references in README.md
# -----------------------------------------------------------------------
echo ""
echo "--- Check 3: Broken file references ---"
for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u | while read -r readme; do
  dir=$(dirname "$readme")
  # Skip Boneyard
  case "$dir" in
    *Boneyard*) continue ;;
  esac
  link_allowlisted "$readme" && continue
  # Find all Markdown links: [text](path) and extract paths
  { grep -oP '\[.*?\]\(\K[^)]+' "$readme" 2>/dev/null || true; } | while read -r link; do
    # Skip external URLs
    case "$link" in
      http://*|https://*) continue ;;
      #*) continue ;;  # Skip anchor-only links
    esac
    # Strip anchor fragments
    path="${link%%#*}"
    # Skip empty paths (anchor-only)
    if [ -z "$path" ]; then continue; fi
    # Resolve relative path
    full_path="$dir/$path"
    if [ ! -e "$full_path" ]; then
      echo "  BROKEN: $readme -> $link (resolved: $full_path)"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

# -----------------------------------------------------------------------
# Check 4: Last verified date present, and not stale against the last commit
#
# The missing-stamp warning is unchanged. When a stamp IS present, its date is
# compared (as ISO8601 strings, which sort lexicographically) against
# `git log -1 --format=%cs -- "$dir"`, the directory's own last commit date.
# A stamp that predates that commit is REPORTED via a STALE DATE warning
# (WARNINGS, never ERRORS) -- this sub-check is reported, not gated, exactly
# like the missing-stamp warning above it. Two failure modes are handled by
# skipping silently rather than crashing under `set -euo pipefail`: no git
# available, or no commits touching this directory (empty `git log` output);
# and a stamp whose date does not parse as `YYYY-MM-DD` (the stamp format
# varies across READMEs -- `*Last verified: DATE*`, `**Last verified**: DATE`,
# with or without trailing prose -- so the date is extracted from wherever it
# appears on the matched line rather than assuming a fixed column).
# -----------------------------------------------------------------------
echo ""
echo "--- Check 4: Missing 'Last verified' dates ---"
for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u | while read -r readme; do
  dir=$(dirname "$readme")
  # Skip Boneyard and docs (non-Lean dirs)
  case "$dir" in
    *Boneyard*) continue ;;
    *docs*) continue ;;
    *latex*) continue ;;
    *typst*) continue ;;
  esac
  STAMP_LINE=$(grep -i "last verified\|last updated" "$readme" | head -1 || true)
  if [ -z "$STAMP_LINE" ]; then
    echo "  MISSING DATE: $readme"
    WARNINGS=$((WARNINGS + 1))
    continue
  fi
  STAMP_DATE=$(printf '%s' "$STAMP_LINE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
  [ -z "$STAMP_DATE" ] && continue
  COMMIT_DATE=$(git log -1 --format=%cs -- "$dir" 2>/dev/null || true)
  [ -z "$COMMIT_DATE" ] && continue
  if [[ "$STAMP_DATE" < "$COMMIT_DATE" ]]; then
    echo "  STALE DATE: $readme (stamped $STAMP_DATE, directory last changed $COMMIT_DATE)"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# -----------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------
echo ""
echo "=== Summary ==="
# Re-run counts properly (subshells above don't accumulate to parent)
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

# Missing READMEs (Lean roots only -- the convention is a Lean-tree convention)
MISSING=$(for r in "${ROOTS[@]}"; do
  if is_lean_root "$r"; then find "$r" -type d; fi
done | { grep -v Boneyard || true; } | { grep -v "\.git" || true; } | while read -r dir; do
  lean_count=$(find "$dir" -maxdepth 1 -name "*.lean" 2>/dev/null | wc -l)
  if [ "$lean_count" -gt 0 ] && [ ! -f "$dir/README.md" ]; then echo "$dir"; fi
done | wc -l)
echo "Missing READMEs:          $MISSING"

# Total README count
README_COUNT=$(for r in "${ROOTS[@]}"; do find "$r" -name "README.md"; done \
  | sort -u | { grep -v Boneyard || true; } | wc -l)
echo "Total READMEs found:      $README_COUNT"

# Files in scope for Checks 3-4 -- states the scope so it cannot be misread
SCOPE_COUNT=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u | { grep -v Boneyard || true; } | wc -l)
echo "Markdown files in scope:  $SCOPE_COUNT"

# Broken links count
BROKEN=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u | { grep -v Boneyard || true; } | while read -r readme; do
  link_allowlisted "$readme" && continue
  dir=$(dirname "$readme")
  { grep -oP '\[.*?\]\(\K[^)]+' "$readme" 2>/dev/null || true; } | while read -r link; do
    case "$link" in http://*|https://*) continue ;; esac
    path="${link%%#*}"
    if [ -z "$path" ]; then continue; fi
    full_path="$dir/$path"
    if [ ! -e "$full_path" ]; then echo "$full_path"; fi
  done
done | wc -l)
echo "Broken file references:   $BROKEN"

# Check 2 is REPORTED, not gated. Counting it here is the point: "not gated"
# must never be mistaken for "not measured".
NOT_LISTED=$(for r in "${ROOTS[@]}"; do
  if is_lean_root "$r"; then find "$r" -name "README.md"; fi
done | sort -u | { grep -v Boneyard || true; } | while read -r readme; do
  d=$(dirname "$readme")
  find "$d" -maxdepth 1 -name "*.lean" 2>/dev/null | while read -r lf; do
    grep -qF "$(basename "$lf")" "$readme" || echo "$lf"
  done
done | wc -l)
echo "Files not listed (info):  $NOT_LISTED"

# -----------------------------------------------------------------------
# Check 4 debt: recompute the live stale and missing-date sets here (the
# Check 4 loop above runs in a `while read` subshell; its counts don't reach
# this parent shell -- the same reason this recompute already existed for
# missing dates before Check 4 pinning). Diff each set against
# scripts/readme-date-baseline.txt to find NEW findings -- rows absent from
# the baseline entirely, or (for `stale`) present with a different stamp,
# since a refreshed stamp permanently un-grandfathers that README.
# -----------------------------------------------------------------------
BASELINE_FILE="scripts/readme-date-baseline.txt"

# Every markdown path in scope for the current ROOTS (Checks 3-4's own scope),
# used below to keep the pruning report honest when invoked on a root subset
# narrower than the baseline's union (e.g. the default FormalSystem-only run
# against a baseline generated from FormalSystem + BimodalTools).
SCOPE_SET=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u | { grep -v Boneyard || true; })

STALE_LIST=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u \
  | { grep -vE 'Boneyard|(^|/)(docs|latex|typst)/' || true; } | while read -r md; do
  dir=$(dirname "$md")
  STAMP_LINE=$(grep -i "last verified\|last updated" "$md" | head -1 || true)
  [ -z "$STAMP_LINE" ] && continue
  STAMP_DATE=$(printf '%s' "$STAMP_LINE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
  [ -z "$STAMP_DATE" ] && continue
  COMMIT_DATE=$(git log -1 --format=%cs -- "$dir" 2>/dev/null || true)
  [ -z "$COMMIT_DATE" ] && continue
  if [[ "$STAMP_DATE" < "$COMMIT_DATE" ]]; then
    echo "$md $STAMP_DATE"
  fi
done)
STALE_TOTAL=0
[ -n "$STALE_LIST" ] && STALE_TOTAL=$(printf '%s\n' "$STALE_LIST" | wc -l)
echo "Stale dates (info):       $STALE_TOTAL"

MISSING_LIST=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u \
  | { grep -vE 'Boneyard|(^|/)(docs|latex|typst)/' || true; } | while read -r md; do
  grep -qi "last verified\|last updated" "$md" || echo "$md"
done)
NO_DATE=0
[ -n "$MISSING_LIST" ] && NO_DATE=$(printf '%s\n' "$MISSING_LIST" | wc -l)
echo "Missing dates (info):     $NO_DATE"

STALE_NEW=0
if [ -n "$STALE_LIST" ]; then
  while read -r md stamp; do
    [ -z "$md" ] && continue
    if ! grep -qxF "stale $md $stamp" "$BASELINE_FILE" 2>/dev/null; then
      STALE_NEW=$((STALE_NEW + 1))
    fi
  done <<< "$STALE_LIST"
fi
echo "Stale dates (new):        $STALE_NEW"

NODATE_NEW=0
if [ -n "$MISSING_LIST" ]; then
  while read -r md; do
    [ -z "$md" ] && continue
    if ! grep -qxF "missing $md -" "$BASELINE_FILE" 2>/dev/null; then
      NODATE_NEW=$((NODATE_NEW + 1))
    fi
  done <<< "$MISSING_LIST"
fi
echo "Missing dates (new):      $NODATE_NEW"

# Baseline rows that no longer match a live finding -- reported, never failed,
# on the c20-declaration-baseline.txt stale-key precedent. Only rows whose path
# falls within the CURRENT invocation's scope are evaluated, so a narrower root
# subset never reports a wider baseline's out-of-scope rows as prunable.
echo ""
echo "--- Baseline rows no longer matching a live finding (candidates for pruning) ---"
PRUNE_COUNT=0
while IFS= read -r row; do
  case "$row" in '#'*|'') continue ;; esac
  b_class=$(printf '%s' "$row" | awk '{print $1}')
  b_path=$(printf '%s' "$row" | awk '{print $2}')
  b_stamp=$(printf '%s' "$row" | awk '{print $3}')
  printf '%s\n' "$SCOPE_SET" | grep -qxF "$b_path" || continue
  case "$b_class" in
    stale)
      if [ -z "$STALE_LIST" ] || ! printf '%s\n' "$STALE_LIST" | grep -qxF "$b_path $b_stamp"; then
        echo "  PRUNE: $row (no longer a live stale finding)"
        PRUNE_COUNT=$((PRUNE_COUNT + 1))
      fi
      ;;
    missing)
      if [ -z "$MISSING_LIST" ] || ! printf '%s\n' "$MISSING_LIST" | grep -qxF "$b_path"; then
        echo "  PRUNE: $row (no longer a live missing-date finding)"
        PRUNE_COUNT=$((PRUNE_COUNT + 1))
      fi
      ;;
  esac
done < "$BASELINE_FILE"
[ "$PRUNE_COUNT" -eq 0 ] && echo "  (none)"

if [ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ] \
   || { [ "$ENFORCE_README_DATES" -eq 1 ] && { [ "$STALE_NEW" -gt 0 ] || [ "$NODATE_NEW" -gt 0 ]; }; }; then
  echo ""
  if [ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ]; then
    echo "RESULT: FAIL ($MISSING missing READMEs, $BROKEN broken references, $STALE_NEW new stale dates, $NODATE_NEW new missing dates)"
  else
    echo "RESULT: FAIL ($STALE_NEW new stale dates, $NODATE_NEW new missing dates)"
  fi
  exit 1
else
  echo ""
  echo "RESULT: PASS"
  exit 0
fi
