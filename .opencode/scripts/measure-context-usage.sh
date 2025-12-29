#!/usr/bin/env bash
# measure-context-usage.sh - Measure context window usage at different checkpoints
#
# Usage: ./measure-context-usage.sh [--verbose]
#
# Checkpoints:
#   1. Orchestrator routing (Stages 1-3)
#   2. Command routing (Stages 1-3)
#   3. Agent execution (Stage 4+)

set -euo pipefail

VERBOSE=false
CONTEXT_DIR=".opencode/context"
COMMAND_DIR=".opencode/command"
AGENT_DIR=".opencode/agent"

# Parse arguments
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE=true
fi

# Token estimation: ~4 characters per token (conservative)
CHARS_PER_TOKEN=4

# Context budget (200K tokens)
TOTAL_BUDGET=200000

echo "=== Context Window Usage Measurement ==="
echo ""
echo "Total context budget: ${TOTAL_BUDGET} tokens"
echo ""

# Function to measure file size in tokens
measure_file() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo 0
    return
  fi
  
  local chars=$(wc -c < "$file")
  local tokens=$((chars / CHARS_PER_TOKEN))
  echo "$tokens"
}

# Function to measure directory size in tokens
measure_dir() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo 0
    return
  fi
  
  local total_chars=0
  while IFS= read -r file; do
    if [ -f "$file" ]; then
      local chars=$(wc -c < "$file")
      total_chars=$((total_chars + chars))
    fi
  done < <(find "$dir" -type f -name "*.md")
  
  local tokens=$((total_chars / CHARS_PER_TOKEN))
  echo "$tokens"
}

# Checkpoint 1: Orchestrator Routing (Stages 1-3)
echo "## Checkpoint 1: Orchestrator Routing (Stages 1-3)"
echo ""

orchestrator_tokens=$(measure_file "$AGENT_DIR/orchestrator.md")
routing_guide_tokens=$(measure_file "$CONTEXT_DIR/system/routing-guide.md")

checkpoint1_total=$((orchestrator_tokens + routing_guide_tokens))
checkpoint1_pct=$((checkpoint1_total * 100 / TOTAL_BUDGET))

echo "Files loaded:"
echo "  - orchestrator.md: ${orchestrator_tokens} tokens"
echo "  - routing-guide.md: ${routing_guide_tokens} tokens"
echo ""
echo "Total: ${checkpoint1_total} tokens (${checkpoint1_pct}% of budget)"
echo ""

if [ $checkpoint1_pct -lt 15 ]; then
  echo "[PASS] Routing uses ${checkpoint1_pct}% of context (target: <15%)"
else
  echo "[FAIL] Routing uses ${checkpoint1_pct}% of context (exceeds 15% target)"
fi
echo ""

# Checkpoint 2: Command Routing (research.md Stages 1-3)
echo "## Checkpoint 2: Command Routing (research.md Stages 1-3)"
echo ""

research_tokens=$(measure_file "$COMMAND_DIR/research.md")

checkpoint2_total=$((checkpoint1_total + research_tokens))
checkpoint2_pct=$((checkpoint2_total * 100 / TOTAL_BUDGET))

echo "Files loaded (cumulative):"
echo "  - orchestrator.md: ${orchestrator_tokens} tokens"
echo "  - routing-guide.md: ${routing_guide_tokens} tokens"
echo "  - research.md: ${research_tokens} tokens"
echo ""
echo "Total: ${checkpoint2_total} tokens (${checkpoint2_pct}% of budget)"
echo ""

if [ $checkpoint2_pct -lt 20 ]; then
  echo "[PASS] Command routing uses ${checkpoint2_pct}% of context (target: <20%)"
else
  echo "[WARN] Command routing uses ${checkpoint2_pct}% of context (target: <20%)"
fi
echo ""

# Checkpoint 3: Agent Execution (researcher.md Stage 4+)
echo "## Checkpoint 3: Agent Execution (researcher.md Stage 4+)"
echo ""

researcher_tokens=$(measure_file "$AGENT_DIR/subagents/researcher.md")
index_tokens=$(measure_file "$CONTEXT_DIR/index.md")
status_markers_tokens=$(measure_file "$CONTEXT_DIR/common/system/status-markers.md")
artifact_mgmt_tokens=$(measure_file "$CONTEXT_DIR/common/system/artifact-management.md")
return_format_tokens=$(measure_file "$CONTEXT_DIR/common/standards/subagent-return-format.md")

# Task extraction (estimated ~2KB = ~500 tokens)
task_extraction_tokens=500

checkpoint3_total=$((researcher_tokens + index_tokens + status_markers_tokens + artifact_mgmt_tokens + return_format_tokens + task_extraction_tokens))
checkpoint3_pct=$((checkpoint3_total * 100 / TOTAL_BUDGET))

echo "Files loaded (execution only, not cumulative):"
echo "  - researcher.md: ${researcher_tokens} tokens"
echo "  - index.md: ${index_tokens} tokens"
echo "  - status-markers.md: ${status_markers_tokens} tokens"
echo "  - artifact-management.md: ${artifact_mgmt_tokens} tokens"
echo "  - subagent-return-format.md: ${return_format_tokens} tokens"
echo "  - task extraction (grep): ${task_extraction_tokens} tokens (estimated)"
echo ""
echo "Total: ${checkpoint3_total} tokens (${checkpoint3_pct}% of budget)"
echo ""

if [ $checkpoint3_pct -lt 50 ]; then
  echo "[PASS] Agent execution uses ${checkpoint3_pct}% of context (target: <50%)"
else
  echo "[WARN] Agent execution uses ${checkpoint3_pct}% of context (target: <50%)"
fi
echo ""

# Summary
echo "## Summary"
echo ""
echo "| Checkpoint | Tokens | % of Budget | Status |"
echo "|------------|--------|-------------|--------|"

if [ $checkpoint1_pct -lt 15 ]; then
  status1="[PASS]"
else
  status1="[FAIL]"
fi

if [ $checkpoint2_pct -lt 20 ]; then
  status2="[PASS]"
else
  status2="[WARN]"
fi

if [ $checkpoint3_pct -lt 50 ]; then
  status3="[PASS]"
else
  status3="[WARN]"
fi

echo "| Orchestrator Routing | ${checkpoint1_total} | ${checkpoint1_pct}% | ${status1} |"
echo "| Command Routing | ${checkpoint2_total} | ${checkpoint2_pct}% | ${status2} |"
echo "| Agent Execution | ${checkpoint3_total} | ${checkpoint3_pct}% | ${status3} |"
echo ""

# Overall assessment
echo "## Overall Assessment"
echo ""

if [ $checkpoint1_pct -lt 15 ] && [ $checkpoint2_pct -lt 20 ] && [ $checkpoint3_pct -lt 50 ]; then
  echo "[PASS] All checkpoints within target ranges"
  echo ""
  echo "Context window optimization successful:"
  echo "  - Routing: ${checkpoint1_pct}% (target: <15%)"
  echo "  - Command: ${checkpoint2_pct}% (target: <20%)"
  echo "  - Execution: ${checkpoint3_pct}% (target: <50%)"
  exit 0
else
  echo "[WARN] Some checkpoints exceed targets"
  echo ""
  echo "Recommendations:"
  
  if [ $checkpoint1_pct -ge 15 ]; then
    echo "  - Reduce orchestrator.md or routing-guide.md size"
  fi
  
  if [ $checkpoint2_pct -ge 20 ]; then
    echo "  - Further reduce research.md size"
  fi
  
  if [ $checkpoint3_pct -ge 50 ]; then
    echo "  - Optimize execution context files"
  fi
  
  exit 1
fi
