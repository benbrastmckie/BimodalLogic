#!/usr/bin/env bash
#
# validate-context-index.sh - Validate .claude/context/index.json
#
# Validates the context index for:
# - JSON syntax correctness
# - All indexed paths exist on disk
# - No duplicate paths
# - Reports orphaned files not in index
# - Reports deprecated entries
#
# Usage: ./validate-context-index.sh [--fix]
#
# Options:
#   --fix   Regenerate index if validation fails
#

set -euo pipefail

# Change to project root (parent of .claude)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$PROJECT_ROOT"

CONTEXT_DIR=".claude/context"
INDEX_FILE="$CONTEXT_DIR/index.json"
FIX_MODE=false
EXIT_CODE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix)
            FIX_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

echo "Validating context index: $INDEX_FILE"
echo "========================================"

# 1. Check file exists
if [[ ! -f "$INDEX_FILE" ]]; then
    echo "ERROR: Index file not found: $INDEX_FILE"
    exit 1
fi

# 2. Validate JSON syntax
echo -n "1. JSON syntax: "
if jq '.' "$INDEX_FILE" > /dev/null 2>&1; then
    echo "OK"
else
    echo "FAILED"
    echo "   Error: Invalid JSON syntax"
    EXIT_CODE=1
fi

# 3. Check required fields
echo -n "2. Required fields: "
required_ok=true
for field in version generated_at file_count entries; do
    if ! jq -e ".$field" "$INDEX_FILE" > /dev/null 2>&1; then
        echo ""
        echo "   Missing field: $field"
        required_ok=false
        EXIT_CODE=1
    fi
done
$required_ok && echo "OK"

# 4. Verify all entry paths exist
echo -n "3. Path existence: "
missing_count=0
while IFS= read -r path; do
    full_path="$CONTEXT_DIR/$path"
    if [[ ! -f "$full_path" ]]; then
        if [[ $missing_count -eq 0 ]]; then
            echo ""
        fi
        echo "   Missing: $path"
        ((missing_count++))
    fi
done < <(jq -r '.entries[].path' "$INDEX_FILE")

if [[ $missing_count -eq 0 ]]; then
    echo "OK"
else
    echo "   $missing_count files missing"
    EXIT_CODE=1
fi

# 5. Check for duplicate paths
echo -n "4. Duplicate paths: "
duplicates=$(jq -r '.entries[].path' "$INDEX_FILE" | sort | uniq -d)
if [[ -z "$duplicates" ]]; then
    echo "OK"
else
    echo "FOUND"
    echo "$duplicates" | while read -r dup; do
        echo "   Duplicate: $dup"
    done
    EXIT_CODE=1
fi

# 6. Check for orphaned files (on disk but not in index)
echo -n "5. Orphaned files: "
orphan_count=0

# Get all files in context dir
while IFS= read -r file; do
    # Skip index.json itself
    [[ "$file" == "$INDEX_FILE" ]] && continue

    rel_path="${file#$CONTEXT_DIR/}"

    # Check if path is in index
    if ! jq -e --arg path "$rel_path" '.entries[] | select(.path == $path)' "$INDEX_FILE" > /dev/null 2>&1; then
        if [[ $orphan_count -eq 0 ]]; then
            echo ""
        fi
        echo "   Not indexed: $rel_path"
        ((orphan_count++))
    fi
done < <(find "$CONTEXT_DIR" -type f \( -name "*.md" -o -name "*.yaml" \))

if [[ $orphan_count -eq 0 ]]; then
    echo "OK"
else
    echo "   $orphan_count files not indexed"
    # Orphaned files are a warning, not an error
fi

# 7. Report deprecated entries
echo -n "6. Deprecated entries: "
deprecated=$(jq -r '.entries[] | select(.deprecated == true) | .path' "$INDEX_FILE")
if [[ -z "$deprecated" ]]; then
    echo "None"
else
    echo ""
    echo "$deprecated" | while read -r dep; do
        echo "   Deprecated: $dep"
    done
fi

# 8. Entry count verification
echo -n "7. Entry count match: "
indexed_count=$(jq '.entries | length' "$INDEX_FILE")
declared_count=$(jq '.file_count' "$INDEX_FILE")
if [[ "$indexed_count" == "$declared_count" ]]; then
    echo "OK ($indexed_count entries)"
else
    echo "MISMATCH"
    echo "   Declared: $declared_count, Actual: $indexed_count"
    EXIT_CODE=1
fi

# 9. Validate load_when fields have valid values
echo -n "8. load_when validation: "
load_when_errors=0

# Check for empty load_when objects
empty_load_when=$(jq -r '.entries[] | select(.load_when == {}) | .path' "$INDEX_FILE")
if [[ -n "$empty_load_when" ]]; then
    if [[ $load_when_errors -eq 0 ]]; then
        echo ""
    fi
    echo "$empty_load_when" | while read -r path; do
        echo "   Empty load_when: $path"
    done
    ((load_when_errors++))
fi

if [[ $load_when_errors -eq 0 ]]; then
    echo "OK"
fi

# Summary
echo ""
echo "========================================"
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "Validation PASSED"
else
    echo "Validation FAILED"
    if $FIX_MODE; then
        echo ""
        echo "Regenerating index..."
        "$SCRIPT_DIR/generate-context-index.sh"
        echo "Index regenerated. Please re-run validation."
    fi
fi

exit $EXIT_CODE
