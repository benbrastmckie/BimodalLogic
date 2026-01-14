#!/usr/bin/env bash
# track-stage7-rate.sh
# Tracks Stage 7 execution rate from test logs
# Generates success rate visualization and validation

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$SPEC_DIR/logs"
METRICS_DIR="$SPEC_DIR/metrics"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$METRICS_DIR/stage7-rate-$TIMESTAMP.txt"

# Create directories
mkdir -p "$LOG_DIR" "$METRICS_DIR"

# Logging functions
log() {
  echo "$*" | tee -a "$OUTPUT_FILE"
}

# Parse test logs for Stage 7 execution
parse_test_logs() {
  local log_pattern="$LOG_DIR/test-stage7-reliability-*.log"
  
  # Find most recent log file
  local latest_log=$(ls -t $log_pattern 2>/dev/null | head -1)
  
  if [[ -z "$latest_log" ]]; then
    echo "ERROR: No test logs found in $LOG_DIR"
    exit 1
  fi
  
  echo "$latest_log"
}

# Calculate success rates
calculate_rates() {
  local log_file=$1
  
  # Extract pass/fail counts per command
  declare -A passed
  declare -A failed
  declare -A total
  
  local commands=("research" "plan" "implement" "revise")
  
  for command in "${commands[@]}"; do
    passed[$command]=$(grep -c "\[PASS\].*/$command" "$log_file" 2>/dev/null || echo "0")
    failed[$command]=$(grep -c "\[FAIL\].*/$command" "$log_file" 2>/dev/null || echo "0")
    total[$command]=$((${passed[$command]} + ${failed[$command]}))
  done
  
  # Calculate overall totals
  local total_passed=0
  local total_failed=0
  for command in "${commands[@]}"; do
    total_passed=$((total_passed + ${passed[$command]}))
    total_failed=$((total_failed + ${failed[$command]}))
  done
  local total_tests=$((total_passed + total_failed))
  
  # Return results as JSON-like string
  echo "research_passed=${passed[research]}"
  echo "research_failed=${failed[research]}"
  echo "research_total=${total[research]}"
  echo "plan_passed=${passed[plan]}"
  echo "plan_failed=${failed[plan]}"
  echo "plan_total=${total[plan]}"
  echo "implement_passed=${passed[implement]}"
  echo "implement_failed=${failed[implement]}"
  echo "implement_total=${total[implement]}"
  echo "revise_passed=${passed[revise]}"
  echo "revise_failed=${failed[revise]}"
  echo "revise_total=${total[revise]}"
  echo "total_passed=$total_passed"
  echo "total_failed=$total_failed"
  echo "total_tests=$total_tests"
}

# Generate visualization
generate_visualization() {
  local research_passed=$1
  local research_total=$2
  local plan_passed=$3
  local plan_total=$4
  local implement_passed=$5
  local implement_total=$6
  local revise_passed=$7
  local revise_total=$8
  local total_passed=$9
  local total_tests=${10}
  
  # Calculate percentages
  local research_rate=$((research_total > 0 ? research_passed * 100 / research_total : 0))
  local plan_rate=$((plan_total > 0 ? plan_passed * 100 / plan_total : 0))
  local implement_rate=$((implement_total > 0 ? implement_passed * 100 / implement_total : 0))
  local revise_rate=$((revise_total > 0 ? revise_passed * 100 / revise_total : 0))
  local overall_rate=$((total_tests > 0 ? total_passed * 100 / total_tests : 0))
  
  # Generate ASCII visualization
  log ""
  log "========================================="
  log "Stage 7 Execution Rate Tracking"
  log "========================================="
  log ""
  log "Per-Command Success Rates:"
  log ""
  log "  /research:   $research_passed/$research_total ($research_rate%) $(generate_bar $research_rate)"
  log "  /plan:       $plan_passed/$plan_total ($plan_rate%) $(generate_bar $plan_rate)"
  log "  /implement:  $implement_passed/$implement_total ($implement_rate%) $(generate_bar $implement_rate)"
  log "  /revise:     $revise_passed/$revise_total ($revise_rate%) $(generate_bar $revise_rate)"
  log ""
  log "Overall Success Rate:"
  log ""
  log "  Total:       $total_passed/$total_tests ($overall_rate%) $(generate_bar $overall_rate)"
  log ""
  log "Target: 100% (80/80 successful runs)"
  log ""
  
  # Determine status
  if [[ $overall_rate -eq 100 ]]; then
    log "[PASS] Stage 7 execution rate: 100% (target achieved)"
  elif [[ $overall_rate -ge 95 ]]; then
    log "[WARN] Stage 7 execution rate: $overall_rate% (below 100% target)"
  else
    log "[FAIL] Stage 7 execution rate: $overall_rate% (significantly below 100% target)"
  fi
  
  log ""
  log "Results saved to: $OUTPUT_FILE"
  
  # Return status
  if [[ $overall_rate -eq 100 ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Generate ASCII progress bar
generate_bar() {
  local percentage=$1
  local bar_length=20
  local filled=$((percentage * bar_length / 100))
  local empty=$((bar_length - filled))
  
  local bar="["
  for ((i=0; i<filled; i++)); do
    bar+="="
  done
  for ((i=0; i<empty; i++)); do
    bar+=" "
  done
  bar+="]"
  
  echo "$bar"
}

# Main execution
main() {
  log "Starting Stage 7 execution rate tracking"
  log "Timestamp: $(date -Iseconds)"
  log ""
  
  # Parse test logs
  local log_file=$(parse_test_logs)
  log "Analyzing log file: $log_file"
  
  # Calculate rates
  local rates=$(calculate_rates "$log_file")
  
  # Extract values
  eval "$rates"
  
  # Generate visualization
  local status=$(generate_visualization \
    "$research_passed" "$research_total" \
    "$plan_passed" "$plan_total" \
    "$implement_passed" "$implement_total" \
    "$revise_passed" "$revise_total" \
    "$total_passed" "$total_tests")
  
  # Exit with appropriate code
  if [[ "$status" == "PASS" ]]; then
    exit 0
  else
    exit 1
  fi
}

# Run main function
main
