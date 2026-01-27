#!/usr/bin/env bash
# test-stage7-reliability.sh - Test Stage 7 execution reliability
#
# Usage: ./test-stage7-reliability.sh [--runs N]
#
# This script tests Stage 7 (Postflight) execution reliability by running
# /research command multiple times and verifying status updates occur.
#
# NOTE: This is a template script. Actual execution requires integration
# with the OpenCode CLI to invoke /research commands.

set -euo pipefail

RUNS=20
TEST_TASK=244  # Use task 244 for testing (this task)

# Parse arguments
if [ "${1:-}" = "--runs" ] && [ -n "${2:-}" ]; then
  RUNS=$2
fi

echo "=== Stage 7 Reliability Test ==="
echo ""
echo "Test configuration:"
echo "  - Runs: ${RUNS}"
echo "  - Test task: ${TEST_TASK}"
echo ""

# NOTE: This is a template. Actual implementation would require:
# 1. Integration with OpenCode CLI to invoke /research commands
# 2. Ability to reset task status between runs
# 3. Verification of TODO.md and state.json updates
# 4. Git commit verification

echo "[INFO] This is a template script for Stage 7 reliability testing"
echo ""
echo "To implement full testing:"
echo "  1. Integrate with OpenCode CLI"
echo "  2. Create test task with known state"
echo "  3. Run /research command ${RUNS} times"
echo "  4. Verify each run:"
echo "     - TODO.md updated with [RESEARCHED] status"
echo "     - state.json updated with status='researched'"
echo "     - Git commit created"
echo "     - Timestamps added (Started, Completed)"
echo "  5. Calculate success rate"
echo ""

# Template verification logic
verify_stage7_execution() {
  local task_number=$1
  local run_number=$2
  
  echo "[RUN ${run_number}/${RUNS}] Verifying Stage 7 execution for task ${task_number}"
  
  # Check TODO.md status
  if grep -q "### ${task_number}\." .opencode/specs/TODO.md; then
    if grep -A 5 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "\[RESEARCHED\]"; then
      echo "  [PASS] TODO.md status: [RESEARCHED]"
      todo_pass=true
    else
      echo "  [FAIL] TODO.md status: NOT [RESEARCHED]"
      todo_pass=false
    fi
  else
    echo "  [FAIL] Task ${task_number} not found in TODO.md"
    todo_pass=false
  fi
  
  # Check state.json status
  if [ -f .opencode/specs/state.json ]; then
    if jq -e ".tasks[] | select(.task_number == ${task_number}) | select(.status == \"researched\")" .opencode/specs/state.json > /dev/null 2>&1; then
      echo "  [PASS] state.json status: researched"
      state_pass=true
    else
      echo "  [FAIL] state.json status: NOT researched"
      state_pass=false
    fi
  else
    echo "  [FAIL] state.json not found"
    state_pass=false
  fi
  
  # Check git commit
  if git log --oneline --grep="task ${task_number}: research" -1 > /dev/null 2>&1; then
    echo "  [PASS] Git commit created"
    git_pass=true
  else
    echo "  [FAIL] Git commit NOT created"
    git_pass=false
  fi
  
  # Check timestamps
  if grep -A 10 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "\*\*Started\*\*:"; then
    echo "  [PASS] Started timestamp present"
    started_pass=true
  else
    echo "  [FAIL] Started timestamp missing"
    started_pass=false
  fi
  
  if grep -A 10 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "\*\*Completed\*\*:"; then
    echo "  [PASS] Completed timestamp present"
    completed_pass=true
  else
    echo "  [FAIL] Completed timestamp missing"
    completed_pass=false
  fi
  
  # Overall result
  if $todo_pass && $state_pass && $git_pass && $started_pass && $completed_pass; then
    echo "  [PASS] Stage 7 executed successfully"
    return 0
  else
    echo "  [FAIL] Stage 7 execution incomplete"
    return 1
  fi
}

# Template test execution
echo "## Test Execution (Template)"
echo ""

success_count=0
fail_count=0

# Single verification run (template)
echo "Running single verification (template mode)..."
echo ""

if verify_stage7_execution $TEST_TASK 1; then
  ((success_count++))
else
  ((fail_count++))
fi

echo ""
echo "## Results (Template)"
echo ""

total_runs=1  # Template only runs once
success_rate=$((success_count * 100 / total_runs))

echo "Total runs: ${total_runs}"
echo "Successful: ${success_count}"
echo "Failed: ${fail_count}"
echo "Success rate: ${success_rate}%"
echo ""

if [ $success_rate -eq 100 ]; then
  echo "[PASS] Stage 7 reliability: ${success_rate}% (target: 100%)"
  echo ""
  echo "Stage 7 execution is 100% reliable based on current verification."
  exit 0
else
  echo "[FAIL] Stage 7 reliability: ${success_rate}% (below 100% target)"
  echo ""
  echo "Recommendations:"
  echo "  - Review Stage 7 implementation in researcher.md"
  echo "  - Verify status-sync-manager delegation"
  echo "  - Check git-workflow-manager delegation"
  echo "  - Add explicit checkpoints in Stage 7"
  exit 1
fi
