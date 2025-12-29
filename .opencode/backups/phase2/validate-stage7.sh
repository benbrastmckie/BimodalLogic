#!/bin/bash
# Stage 7 validation script for Phase 2
# Task 245: Phase 2 Core Architecture
# Created: 2025-12-29

set -e

# Function to validate Stage 7 execution for a task
validate_stage7() {
  local task_number=$1
  local command=$2
  local errors=0
  
  echo "Validating Stage 7 for task ${task_number} (${command} command)..."
  
  # Determine expected status marker
  local expected_status
  case $command in
    research) expected_status="RESEARCHED" ;;
    plan) expected_status="PLANNED" ;;
    implement) expected_status="IMPLEMENTED" ;;
    revise) expected_status="COMPLETED" ;;
    *) 
      echo "  ✗ ERROR: Unknown command '${command}'"
      return 1
      ;;
  esac
  
  # Check 1: TODO.md updated with correct status
  if grep -q "### ${task_number}\." .opencode/specs/TODO.md 2>/dev/null; then
    if grep -A 5 "### ${task_number}\." .opencode/specs/TODO.md | grep -q "\[${expected_status}\]"; then
      echo "  ✓ TODO.md status updated to [${expected_status}]"
    else
      echo "  ✗ TODO.md status NOT updated to [${expected_status}]"
      ((errors++))
    fi
  else
    echo "  ✗ Task ${task_number} not found in TODO.md"
    ((errors++))
  fi
  
  # Check 2: Artifacts section exists
  if grep -A 20 "### ${task_number}\." .opencode/specs/TODO.md 2>/dev/null | grep -q -i "artifact"; then
    echo "  ✓ Artifacts section found in TODO.md"
  else
    echo "  ⚠ Artifacts section not found (may be acceptable)"
  fi
  
  # Check 3: Git commit created (check last 5 commits)
  if git log -5 --oneline 2>/dev/null | grep -q "${task_number}"; then
    echo "  ✓ Git commit created for task ${task_number}"
  else
    echo "  ⚠ Git commit not found in last 5 commits (may be acceptable)"
  fi
  
  # Check 4: Timestamp updated
  if grep -A 20 "### ${task_number}\." .opencode/specs/TODO.md 2>/dev/null | grep -q -E "(Completed|Updated):"; then
    echo "  ✓ Timestamp found in TODO.md"
  else
    echo "  ⚠ Timestamp not found (may be acceptable)"
  fi
  
  # Return result
  if [ $errors -eq 0 ]; then
    echo "  ✓ PASS: Stage 7 validation successful"
    return 0
  else
    echo "  ✗ FAIL: Stage 7 validation failed (${errors} errors)"
    return 1
  fi
}

# Main execution
if [ $# -eq 2 ]; then
  # Validate specific task
  validate_stage7 "$1" "$2"
else
  echo "Usage: $0 TASK_NUMBER COMMAND"
  echo "Example: $0 245 implement"
  exit 1
fi
