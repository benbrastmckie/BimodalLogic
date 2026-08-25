#!/usr/bin/env bash
# readme-lint.sh -- Check README health across FormalSystem/
#
# Checks performed:
#   1. Every directory containing .lean files has a README.md
#   2. Every .lean file in a directory appears in its README.md   [REPORTED, not gated]
#   3. No broken relative file references in any markdown file in scope
#   4. Every README.md has a "Last verified" date                 [REPORTED, not gated]
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
# Only Checks 1 and 3 affect the exit code. Check 2 (`NOT LISTED`) is REPORTED and
# deliberately not gated: the tree carries ~110 such warnings, all cosmetic, and
# gating them would convert a documentation nicety into a build failure. Check 4
# (missing `Last verified`) is likewise reported. The summary block below states
# both counts explicitly so that "not gated" never reads as "not measured".
#
# Exit code: 0 = all clean, 1 = errors found

set -euo pipefail

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
# Check 4: Last verified date present
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
  if ! grep -qi "last verified\|last updated" "$readme"; then
    echo "  MISSING DATE: $readme"
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

# Check 2 and Check 4 are REPORTED, not gated. Counting them here is the point:
# "not gated" must never be mistaken for "not measured".
NOT_LISTED=$(for r in "${ROOTS[@]}"; do
  if is_lean_root "$r"; then find "$r" -name "README.md"; fi
done | sort -u | { grep -v Boneyard || true; } | while read -r readme; do
  d=$(dirname "$readme")
  find "$d" -maxdepth 1 -name "*.lean" 2>/dev/null | while read -r lf; do
    grep -qF "$(basename "$lf")" "$readme" || echo "$lf"
  done
done | wc -l)
echo "Files not listed (info):  $NOT_LISTED"

NO_DATE=$(for r in "${ROOTS[@]}"; do scope_md "$r"; done | sort -u \
  | { grep -vE 'Boneyard|(^|/)(docs|latex|typst)/' || true; } | while read -r md; do
  grep -qi "last verified\|last updated" "$md" || echo "$md"
done | wc -l)
echo "Missing dates (info):     $NO_DATE"

if [ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ]; then
  echo ""
  echo "RESULT: FAIL ($MISSING missing READMEs, $BROKEN broken references)"
  exit 1
else
  echo ""
  echo "RESULT: PASS"
  exit 0
fi
