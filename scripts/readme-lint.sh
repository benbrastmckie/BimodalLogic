#!/usr/bin/env bash
# readme-lint.sh -- Check README health across Theories/Bimodal/
#
# Checks performed:
#   1. Every directory containing .lean files has a README.md
#   2. Every .lean file in a directory appears in its README.md
#   3. No broken relative file references in any README.md
#   4. Every README.md has a "Last verified" date
#
# Usage: ./scripts/readme-lint.sh [<root-directory>]
#
# Default root: Theories/Bimodal
# Exit code: 0 = all clean, 1 = errors found

set -euo pipefail

ROOT="${1:-Theories/Bimodal}"

if [ ! -d "$ROOT" ]; then
  echo "Error: Root directory '$ROOT' does not exist." >&2
  exit 1
fi

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
find "$ROOT" -name "README.md" | sort | while read -r readme; do
  dir=$(dirname "$readme")
  # Skip Boneyard
  case "$dir" in
    *Boneyard*) continue ;;
  esac
  # Find all Markdown links: [text](path) and extract paths
  grep -oP '\[.*?\]\(\K[^)]+' "$readme" 2>/dev/null | while read -r link; do
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
find "$ROOT" -name "README.md" | sort | while read -r readme; do
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

# Missing READMEs
MISSING=$(find "$ROOT" -type d | grep -v Boneyard | grep -v "\.git" | while read -r dir; do
  lean_count=$(find "$dir" -maxdepth 1 -name "*.lean" 2>/dev/null | wc -l)
  if [ "$lean_count" -gt 0 ] && [ ! -f "$dir/README.md" ]; then echo "$dir"; fi
done | wc -l)
echo "Missing READMEs:          $MISSING"

# Total README count
README_COUNT=$(find "$ROOT" -name "README.md" | grep -v Boneyard | wc -l)
echo "Total READMEs found:      $README_COUNT"

# Broken links count
BROKEN=$(find "$ROOT" -name "README.md" | grep -v Boneyard | while read -r readme; do
  dir=$(dirname "$readme")
  grep -oP '\[.*?\]\(\K[^)]+' "$readme" 2>/dev/null | while read -r link; do
    case "$link" in http://*|https://*) continue ;; esac
    path="${link%%#*}"
    if [ -z "$path" ]; then continue; fi
    full_path="$dir/$path"
    if [ ! -e "$full_path" ]; then echo "$full_path"; fi
  done
done | wc -l)
echo "Broken file references:   $BROKEN"

if [ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ]; then
  echo ""
  echo "RESULT: FAIL ($MISSING missing READMEs, $BROKEN broken references)"
  exit 1
else
  echo ""
  echo "RESULT: PASS"
  exit 0
fi
