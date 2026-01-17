#!/usr/bin/env bash
# validate-artifacts.sh
# Validates artifacts created by OpenAgents commands
# Checks existence, non-empty content, and required sections

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$SPEC_DIR/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/validate-artifacts-$TIMESTAMP.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Logging functions
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_status() {
  local status=$1
  shift
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$status] $*" | tee -a "$LOG_FILE"
}

# Validation functions for each command type
validate_research_artifact() {
  local task_num=$1
  local task_dir="specs/${task_num}_"*
  
  # Find research report
  local report_file=$(find "$task_dir" -name "research-001.md" 2>/dev/null | head -1)
  
  if [[ -z "$report_file" ]]; then
    echo "FAIL: Research report not found"
    return 1
  fi
  
  # Check non-empty
  if [[ ! -s "$report_file" ]]; then
    echo "FAIL: Research report is empty"
    return 1
  fi
  
  # Check required sections
  local required_sections=(
    "# Research Report"
    "## Executive Summary"
    "## Research Findings"
  )
  
  for section in "${required_sections[@]}"; do
    if ! grep -q "$section" "$report_file"; then
      echo "FAIL: Missing required section: $section"
      return 1
    fi
  done
  
  echo "PASS"
  return 0
}

validate_plan_artifact() {
  local task_num=$1
  local task_dir="specs/${task_num}_"*
  
  # Find implementation plan
  local plan_file=$(find "$task_dir" -name "implementation-001.md" 2>/dev/null | head -1)
  
  if [[ -z "$plan_file" ]]; then
    echo "FAIL: Implementation plan not found"
    return 1
  fi
  
  # Check non-empty
  if [[ ! -s "$plan_file" ]]; then
    echo "FAIL: Implementation plan is empty"
    return 1
  fi
  
  # Check required sections
  local required_sections=(
    "# Implementation Plan"
    "## Metadata"
    "## Overview"
    "## Implementation Phases"
  )
  
  for section in "${required_sections[@]}"; do
    if ! grep -q "$section" "$plan_file"; then
      echo "FAIL: Missing required section: $section"
      return 1
    fi
  done
  
  # Check for phases
  if ! grep -q "### Phase" "$plan_file"; then
    echo "FAIL: No phases found in plan"
    return 1
  fi
  
  echo "PASS"
  return 0
}

validate_implement_artifact() {
  local task_num=$1
  local task_dir="specs/${task_num}_"*
  
  # Find implementation summary
  local summary_file=$(find "$task_dir" -name "implementation-summary-*.md" 2>/dev/null | head -1)
  
  if [[ -z "$summary_file" ]]; then
    echo "FAIL: Implementation summary not found"
    return 1
  fi
  
  # Check non-empty
  if [[ ! -s "$summary_file" ]]; then
    echo "FAIL: Implementation summary is empty"
    return 1
  fi
  
  # Check required sections
  local required_sections=(
    "# Implementation Summary"
    "## Overview"
  )
  
  for section in "${required_sections[@]}"; do
    if ! grep -q "$section" "$summary_file"; then
      echo "FAIL: Missing required section: $section"
      return 1
    fi
  done
  
  echo "PASS"
  return 0
}

validate_revise_artifact() {
  local task_num=$1
  local task_dir="specs/${task_num}_"*
  
  # Find revision report
  local report_file=$(find "$task_dir" -name "revision-001.md" 2>/dev/null | head -1)
  
  if [[ -z "$report_file" ]]; then
    echo "FAIL: Revision report not found"
    return 1
  fi
  
  # Check non-empty
  if [[ ! -s "$report_file" ]]; then
    echo "FAIL: Revision report is empty"
    return 1
  fi
  
  # Check required sections
  local required_sections=(
    "# Revision Report"
    "## Changes Made"
  )
  
  for section in "${required_sections[@]}"; do
    if ! grep -q "$section" "$report_file"; then
      echo "FAIL: Missing required section: $section"
      return 1
    fi
  done
  
  echo "PASS"
  return 0
}

# Main validation function
validate_task_artifact() {
  local task_num=$1
  local command_type=$2
  
  log "Validating task $task_num ($command_type artifact)"
  
  # Check task directory exists
  local task_dir="specs/${task_num}_"*
  if [[ ! -d $task_dir ]]; then
    log_status "FAIL" "Task directory not found: $task_num"
    echo "FAIL"
    return 1
  fi
  
  # Validate based on command type
  local result=""
  case $command_type in
    research)
      result=$(validate_research_artifact "$task_num")
      ;;
    plan)
      result=$(validate_plan_artifact "$task_num")
      ;;
    implement)
      result=$(validate_implement_artifact "$task_num")
      ;;
    revise)
      result=$(validate_revise_artifact "$task_num")
      ;;
    *)
      log_status "FAIL" "Unknown command type: $command_type"
      echo "FAIL"
      return 1
      ;;
  esac
  
  if [[ "$result" == "PASS" ]]; then
    log_status "PASS" "Task $task_num ($command_type)"
    echo "PASS"
    return 0
  else
    log_status "FAIL" "Task $task_num ($command_type): $result"
    echo "FAIL"
    return 1
  fi
}

# Main execution
main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <task_number> [command_type]"
    echo "  task_number: Task number to validate"
    echo "  command_type: research|plan|implement|revise (auto-detected if not provided)"
    exit 1
  fi
  
  local task_num=$1
  local command_type=${2:-}
  
  # Auto-detect command type if not provided
  if [[ -z "$command_type" ]]; then
    local task_dir="specs/${task_num}_"*
    if [[ -d $task_dir ]]; then
      if [[ -f "$task_dir/reports/research-001.md" ]]; then
        command_type="research"
      elif [[ -f "$task_dir/plans/implementation-001.md" ]]; then
        command_type="plan"
      elif ls "$task_dir/summaries/implementation-summary-"*.md 1>/dev/null 2>&1; then
        command_type="implement"
      elif [[ -f "$task_dir/reports/revision-001.md" ]]; then
        command_type="revise"
      else
        log_status "FAIL" "Could not auto-detect command type for task $task_num"
        exit 1
      fi
    else
      log_status "FAIL" "Task directory not found: $task_num"
      exit 1
    fi
  fi
  
  log "Starting artifact validation"
  log "Task: $task_num"
  log "Command type: $command_type"
  log ""
  
  # Run validation
  local result=$(validate_task_artifact "$task_num" "$command_type")
  
  log ""
  log "Validation complete"
  log "Result: $result"
  log "Log saved to: $LOG_FILE"
  
  # Exit with appropriate code
  if [[ "$result" == "PASS" ]]; then
    exit 0
  else
    exit 1
  fi
}

# Run main function
main "$@"
