#!/usr/bin/env bash
# Coverage Analysis Script
# Maps Bimodal definitions to their test coverage in BimodalTest
#
# This script extracts definition names from Bimodal/ source files and checks
# whether each definition appears in BimodalTest/ to calculate coverage metrics.
#
# Usage: ./scripts/coverage-analysis.sh [--json] [--verbose]
#
# Options:
#   --json     Output results in JSON format
#   --verbose  Show all definitions, not just summary

set -e

# Parse arguments
JSON_OUTPUT=false
VERBOSE=false
for arg in "$@"; do
  case $arg in
    --json) JSON_OUTPUT=true ;;
    --verbose) VERBOSE=true ;;
  esac
done

# Colors for output (disabled for JSON)
if [ "$JSON_OUTPUT" = false ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

# Change to project root
cd "$(dirname "$0")/.."

echo "=== Bimodal Definition Coverage Analysis ==="
echo "Generated: $(date -Iseconds)"
echo ""

# Collect all Bimodal source files (exclude Examples/ for core coverage)
BIMODAL_FILES=$(find Bimodal -name "*.lean" -type f ! -path "*/Examples/*" | sort)

# Initialize counters
declare -A MODULE_TOTAL
declare -A MODULE_COVERED
declare -a UNCOVERED_DEFS
TOTAL_DEFS=0
TOTAL_COVERED=0

# Process each module
for file in $BIMODAL_FILES; do
  # Get module name from file path (e.g., Bimodal/Syntax.lean -> Syntax)
  module=$(echo "$file" | sed 's|Bimodal/||' | sed 's|\.lean$||' | tr '/' '.')

  # Extract definition names from this file
  # Match: def, theorem, lemma, inductive, structure, class, instance at line start
  # Use -o with Perl regex to extract just the name
  defs=$(grep -oP "^(def|theorem|lemma|inductive|structure|class|instance|abbrev)\s+\K\w+" "$file" 2>/dev/null || true)

  if [ -n "$defs" ]; then
    module_total=0
    module_covered=0

    for def in $defs; do
      module_total=$((module_total + 1))
      TOTAL_DEFS=$((TOTAL_DEFS + 1))

      # Check if this definition appears in BimodalTest
      # Use word boundaries to avoid false matches
      if grep -rqw "$def" BimodalTest/ --include="*.lean" 2>/dev/null; then
        module_covered=$((module_covered + 1))
        TOTAL_COVERED=$((TOTAL_COVERED + 1))
      else
        UNCOVERED_DEFS+=("$module.$def")
      fi
    done

    MODULE_TOTAL["$module"]=$module_total
    MODULE_COVERED["$module"]=$module_covered
  fi
done

# Calculate overall percentage
if [ $TOTAL_DEFS -gt 0 ]; then
  OVERALL_PCT=$((100 * TOTAL_COVERED / TOTAL_DEFS))
else
  OVERALL_PCT=0
fi

# Output results
if [ "$JSON_OUTPUT" = true ]; then
  # JSON output
  echo "{"
  echo "  \"generated\": \"$(date -Iseconds)\","
  echo "  \"summary\": {"
  echo "    \"total_definitions\": $TOTAL_DEFS,"
  echo "    \"covered_definitions\": $TOTAL_COVERED,"
  echo "    \"coverage_percentage\": $OVERALL_PCT"
  echo "  },"
  echo "  \"modules\": {"

  first=true
  for module in "${!MODULE_TOTAL[@]}"; do
    total=${MODULE_TOTAL[$module]}
    covered=${MODULE_COVERED[$module]}
    if [ $total -gt 0 ]; then
      pct=$((100 * covered / total))
    else
      pct=0
    fi

    if [ "$first" = true ]; then
      first=false
    else
      echo ","
    fi
    echo -n "    \"$module\": {\"total\": $total, \"covered\": $covered, \"percentage\": $pct}"
  done

  echo ""
  echo "  },"
  echo "  \"uncovered\": ["

  first=true
  for def in "${UNCOVERED_DEFS[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      echo ","
    fi
    echo -n "    \"$def\""
  done

  echo ""
  echo "  ]"
  echo "}"
else
  # Human-readable output
  echo "=== Summary ==="
  echo "Total definitions: $TOTAL_DEFS"
  echo "Covered definitions: $TOTAL_COVERED"
  if [ $OVERALL_PCT -ge 85 ]; then
    echo -e "Coverage: ${GREEN}$OVERALL_PCT%${NC}"
  elif [ $OVERALL_PCT -ge 60 ]; then
    echo -e "Coverage: ${YELLOW}$OVERALL_PCT%${NC}"
  else
    echo -e "Coverage: ${RED}$OVERALL_PCT%${NC}"
  fi
  echo ""

  echo "=== Module Breakdown ==="
  # Sort modules by name
  for module in $(echo "${!MODULE_TOTAL[@]}" | tr ' ' '\n' | sort); do
    total=${MODULE_TOTAL[$module]}
    covered=${MODULE_COVERED[$module]}
    if [ $total -gt 0 ]; then
      pct=$((100 * covered / total))
    else
      pct=0
    fi

    if [ $pct -ge 85 ]; then
      color=$GREEN
    elif [ $pct -ge 60 ]; then
      color=$YELLOW
    else
      color=$RED
    fi

    printf "  %-40s %3d/%3d (%s%3d%%${NC})\n" "$module:" $covered $total "$color" $pct
  done

  if [ "$VERBOSE" = true ]; then
    echo ""
    echo "=== Uncovered Definitions ==="
    for def in "${UNCOVERED_DEFS[@]}"; do
      echo "  - $def"
    done
  else
    echo ""
    echo "=== Uncovered Definitions (first 20) ==="
    count=0
    for def in "${UNCOVERED_DEFS[@]}"; do
      if [ $count -lt 20 ]; then
        echo "  - $def"
        count=$((count + 1))
      else
        remaining=$((${#UNCOVERED_DEFS[@]} - 20))
        echo "  ... and $remaining more (use --verbose to see all)"
        break
      fi
    done
  fi

  # Sorry audit section
  echo ""
  echo "=== Sorry Audit ==="
  echo "Scanning for actual 'sorry' placeholders (excluding comments)..."
  echo ""

  # Count actual sorry placeholders (not in comments)
  # Look for lines where sorry is not preceded by -- or inside /- -/
  echo "Files with sorry placeholders:"
  for testfile in $(find BimodalTest -name "*.lean" -type f); do
    # Count lines with 'sorry' that don't start with -- (simple heuristic)
    count=$(grep -P "^\s*sorry\s*$" "$testfile" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
      relpath=$(echo "$testfile" | sed 's|BimodalTest/||')
      echo "  - $relpath: $count sorry placeholder(s)"
    fi
  done

  echo ""
  echo "Sorry categorization:"
  echo "  Blocked by infrastructure:"
  completeness_sorries=$(grep -P "^\s*sorry\s*$" BimodalTest/Metalogic/CompletenessTest.lean 2>/dev/null | wc -l)
  echo "    - CompletenessTest.lean: $completeness_sorries (pending completeness proof)"
  echo "  Could be completed:"
  perpetuity_sorries=$(grep -P "^\s*sorry\s*$" BimodalTest/Theorems/PerpetuityTest.lean 2>/dev/null | wc -l)
  propositional_sorries=$(grep -P "^\s*sorry\s*$" BimodalTest/Theorems/PropositionalTest.lean 2>/dev/null | wc -l)
  echo "    - PerpetuityTest.lean: $perpetuity_sorries (box_conj_intro proof)"
  echo "    - PropositionalTest.lean: $propositional_sorries (deduction theorem)"
  echo ""
  total_sorries=$((completeness_sorries + perpetuity_sorries + propositional_sorries))
  echo "Total sorry placeholders: $total_sorries"
fi
