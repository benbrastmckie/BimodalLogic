#!/usr/bin/env bash
# test-postflight.sh - Test suite for atomic postflight operations
#
# Usage: ./test-postflight.sh [--verbose]

set -euo pipefail

VERBOSE=false
if [ "${1:-}" = "--verbose" ]; then
    VERBOSE=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log() {
    if [ "$VERBOSE" = true ]; then
        echo "$@"
    fi
}

pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo "  Reason: $2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
    echo "  Reason: $2"
}

run_test() {
    local test_name="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "=== Test $TESTS_RUN: $test_name ==="
}

# Change to project root
cd "$(dirname "$0")/../.."

# Load validation library
source .claude/scripts/lib/validation.sh

echo "Atomic Postflight Test Suite"
echo "============================"
echo ""

# Test 1: Validation library - state.json validation
run_test "validate_state_json function"

# Create test state.json
cat > /tmp/test-state.json <<'EOF'
{
  "active_projects": [
    {
      "project_number": 999,
      "status": "researched",
      "artifacts": [
        {
          "type": "report",
          "path": "specs/999_test/reports/research-001.md",
          "summary": "Test report"
        }
      ]
    }
  ]
}
EOF

if validate_state_json /tmp/test-state.json 999 "researched" "report"; then
    pass "validate_state_json detects valid state"
else
    fail "validate_state_json should pass on valid state" "Function returned error"
fi

# Test 2: Validation library - TODO.md validation
run_test "validate_todo_md function"

# Create test TODO.md
cat > /tmp/test-TODO.md <<'EOF'
### 999. Test task
- **Status**: [RESEARCHED]
- **Research**: [research-001.md](specs/999_test/reports/research-001.md)

**Description**: Test task description

---
EOF

if validate_todo_md /tmp/test-TODO.md 999 "RESEARCHED" "Research"; then
    pass "validate_todo_md detects valid TODO entry"
else
    fail "validate_todo_md should pass on valid entry" "Function returned error"
fi

# Test 3: Duplicate status detection
run_test "Duplicate status marker detection"

# Create TODO with duplicate status
cat > /tmp/test-TODO-dup.md <<'EOF'
### 999. Test task
- **Status**: [RESEARCHED]
- **Status**: [RESEARCHED]
- **Research**: [research-001.md](specs/999_test/reports/research-001.md)

**Description**: Test task description

---
EOF

if ! validate_todo_md /tmp/test-TODO-dup.md 999 "RESEARCHED" "Research" 2>/dev/null; then
    pass "validate_todo_md detects duplicate status markers"
else
    fail "validate_todo_md should fail on duplicate status" "Function passed but should have failed"
fi

# Test 4: Missing research link detection
run_test "Missing research link detection"

cat > /tmp/test-TODO-nolink.md <<'EOF'
### 999. Test task
- **Status**: [RESEARCHED]

**Description**: Test task description

---
EOF

if ! validate_todo_md /tmp/test-TODO-nolink.md 999 "RESEARCHED" "Research" 2>/dev/null; then
    pass "validate_todo_md detects missing research link"
else
    fail "validate_todo_md should fail on missing link" "Function passed but should have failed"
fi

# Test 5: Python TODO updater
run_test "Python TODO.md updater"

cat > /tmp/test-TODO-orig.md <<'EOF'
### 999. Test task
- **Status**: [RESEARCHED]
- **Effort**: 2 hours
- **Priority**: High

**Description**: Test task description

---
EOF

if python3 .claude/scripts/update-todo-artifact.py \
    --input /tmp/test-TODO-orig.md \
    --output /tmp/test-TODO-updated.md \
    --task 999 \
    --type research \
    --path "specs/999_test/reports/research-001.md" 2>&1 | grep -q "Successfully updated"; then

    # Check if link was added
    if grep -q "^\- \*\*Research\*\*:" /tmp/test-TODO-updated.md; then
        pass "Python updater adds research link"
    else
        fail "Python updater should add link" "Link not found in output"
    fi
else
    fail "Python updater execution" "Script failed to run"
fi

# Test 6: Existing task validation (task 690)
run_test "Task 690 validation (previously broken, now fixed)"

if validate_state_json specs/state.json 690 "researched" "report" 2>&1 | grep -q "Error"; then
    fail "Task 690 state.json should be valid" "Validation reported error"
else
    if validate_todo_md specs/TODO.md 690 "RESEARCHED" "Research" 2>&1 | grep -q "Error"; then
        fail "Task 690 TODO.md should be valid" "Validation reported error"
    else
        pass "Task 690 now validates successfully (fix verified)"
    fi
fi

# Test 7: Invalid JSON detection
run_test "Invalid JSON detection"

echo "{ invalid json" > /tmp/test-invalid.json

if ! validate_state_json /tmp/test-invalid.json 999 "researched" "report" 2>/dev/null; then
    pass "validate_state_json detects invalid JSON"
else
    fail "validate_state_json should fail on invalid JSON" "Function passed but should have failed"
fi

# Test 8: Task not found detection
run_test "Task not found detection"

if ! validate_state_json /tmp/test-state.json 12345 "researched" "report" 2>/dev/null; then
    pass "validate_state_json detects missing task"
else
    fail "validate_state_json should fail on missing task" "Function passed but should have failed"
fi

# Cleanup
rm -f /tmp/test-*.json /tmp/test-*.md

# Summary
echo ""
echo "============================"
echo "Test Summary"
echo "============================"
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
else
    echo "Tests failed: $TESTS_FAILED"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
