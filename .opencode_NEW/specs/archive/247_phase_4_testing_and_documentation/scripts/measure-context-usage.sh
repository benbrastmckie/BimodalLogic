#!/usr/bin/env bash
# measure-context-usage.sh
# Measures context window usage during command routing
# Validates <10% usage target for OpenAgents migration

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$SPEC_DIR/logs"
METRICS_DIR="$SPEC_DIR/metrics"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/measure-context-usage-$TIMESTAMP.log"
RESULTS_FILE="$METRICS_DIR/context-usage-$TIMESTAMP.json"

# Context window configuration
TOTAL_CONTEXT_WINDOW=100000  # 100k tokens
TARGET_ROUTING_PERCENTAGE=10  # <10% target
TARGET_ROUTING_TOKENS=$((TOTAL_CONTEXT_WINDOW * TARGET_ROUTING_PERCENTAGE / 100))

# Create directories
mkdir -p "$LOG_DIR" "$METRICS_DIR"

# Logging functions
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

log_status() {
  local status=$1
  shift
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$status] $*" | tee -a "$LOG_FILE" >&2
}

# Token estimation function (rough approximation: 1 token ≈ 4 characters)
estimate_tokens() {
  local file=$1
  if [[ ! -f "$file" ]]; then
    echo "0"
    return
  fi
  
  local char_count=$(wc -c < "$file")
  local token_estimate=$((char_count / 4))
  echo "$token_estimate"
}

# Measure orchestrator routing context (Checkpoint 1)
measure_orchestrator_routing() {
  log "Measuring orchestrator routing context (Checkpoint 1)"
  
  local orchestrator_file=".opencode/command/orchestrator.md"
  local context_index=".opencode/context/index.md"
  
  # Measure orchestrator file
  local orchestrator_tokens=$(estimate_tokens "$orchestrator_file")
  log "  Orchestrator file: $orchestrator_tokens tokens"
  
  # Measure context index (lazy-loaded)
  local index_tokens=$(estimate_tokens "$context_index")
  log "  Context index: $index_tokens tokens"
  
  # Total checkpoint 1
  local checkpoint1_tokens=$((orchestrator_tokens + index_tokens))
  log "  Checkpoint 1 total: $checkpoint1_tokens tokens"
  
  echo "$checkpoint1_tokens"
}

# Measure command routing context (Checkpoint 2)
measure_command_routing() {
  local command=$1
  log "Measuring command routing context for /$command (Checkpoint 2)"
  
  local command_file=".opencode/command/${command}.md"
  
  # Measure command file
  local command_tokens=$(estimate_tokens "$command_file")
  log "  Command file: $command_tokens tokens"
  
  # Command only loads frontmatter + agent delegation
  # No additional context loaded at routing stage
  local checkpoint2_tokens=$command_tokens
  log "  Checkpoint 2 total: $checkpoint2_tokens tokens"
  
  echo "$checkpoint2_tokens"
}

# Main measurement
main() {
  log "Starting context window usage measurement"
  log "Configuration:"
  log "  Total context window: $TOTAL_CONTEXT_WINDOW tokens"
  log "  Target routing usage: <$TARGET_ROUTING_PERCENTAGE% (<$TARGET_ROUTING_TOKENS tokens)"
  log ""
  
  # Measure orchestrator routing
  local checkpoint1_tokens=$(measure_orchestrator_routing)
  log ""
  
  # Measure command routing for each command
  declare -A command_tokens
  local commands=("research" "plan" "implement" "revise")
  
  for command in "${commands[@]}"; do
    local checkpoint2_tokens=$(measure_command_routing "$command")
    command_tokens[$command]=$checkpoint2_tokens
    log ""
  done
  
  # Calculate overall routing context (worst case: orchestrator + largest command)
  local max_command_tokens=0
  local max_command=""
  for command in "${commands[@]}"; do
    if [[ ${command_tokens[$command]} -gt $max_command_tokens ]]; then
      max_command_tokens=${command_tokens[$command]}
      max_command=$command
    fi
  done
  
  local total_routing_tokens=$((checkpoint1_tokens + max_command_tokens))
  local routing_percentage=$((total_routing_tokens * 100 / TOTAL_CONTEXT_WINDOW))
  
  # Generate results summary
  log "========================================="
  log "Context Window Usage Results"
  log "========================================="
  log ""
  log "Checkpoint 1 (Orchestrator Routing):"
  log "  Tokens: $checkpoint1_tokens"
  log "  Percentage: $((checkpoint1_tokens * 100 / TOTAL_CONTEXT_WINDOW))%"
  log ""
  log "Checkpoint 2 (Command Routing):"
  for command in "${commands[@]}"; do
    local cmd_tokens=${command_tokens[$command]}
    local cmd_percentage=$((cmd_tokens * 100 / TOTAL_CONTEXT_WINDOW))
    log "  /$command: $cmd_tokens tokens ($cmd_percentage%)"
  done
  log ""
  log "Overall Routing Context (Worst Case):"
  log "  Orchestrator + /$max_command: $total_routing_tokens tokens"
  log "  Percentage: $routing_percentage%"
  log "  Target: <$TARGET_ROUTING_PERCENTAGE%"
  log ""
  
  # Determine status
  if [[ $routing_percentage -lt $TARGET_ROUTING_PERCENTAGE ]]; then
    log_status "PASS" "Context window usage: $routing_percentage% (below $TARGET_ROUTING_PERCENTAGE% target)"
    local status="PASS"
  elif [[ $routing_percentage -eq $TARGET_ROUTING_PERCENTAGE ]]; then
    log_status "WARN" "Context window usage: $routing_percentage% (at $TARGET_ROUTING_PERCENTAGE% target)"
    local status="WARN"
  else
    log_status "FAIL" "Context window usage: $routing_percentage% (exceeds $TARGET_ROUTING_PERCENTAGE% target)"
    local status="FAIL"
  fi
  
  # Save results to JSON
  cat > "$RESULTS_FILE" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "total_context_window": $TOTAL_CONTEXT_WINDOW,
  "target_percentage": $TARGET_ROUTING_PERCENTAGE,
  "target_tokens": $TARGET_ROUTING_TOKENS,
  "checkpoint1": {
    "tokens": $checkpoint1_tokens,
    "percentage": $((checkpoint1_tokens * 100 / TOTAL_CONTEXT_WINDOW))
  },
  "checkpoint2": {
    "research": ${command_tokens[research]},
    "plan": ${command_tokens[plan]},
    "implement": ${command_tokens[implement]},
    "revise": ${command_tokens[revise]}
  },
  "overall": {
    "tokens": $total_routing_tokens,
    "percentage": $routing_percentage,
    "worst_case_command": "$max_command"
  },
  "status": "$status"
}
EOF
  
  log ""
  log "Results saved to: $RESULTS_FILE"
  log "Log saved to: $LOG_FILE"
  
  # Exit with appropriate code
  if [[ "$status" == "PASS" ]]; then
    exit 0
  else
    exit 1
  fi
}

# Run main function
main
