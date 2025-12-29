#!/bin/bash
# Context usage measurement script for Phase 2
# Task 245: Phase 2 Core Architecture
# Created: 2025-12-29

set -e

echo "=== Context Window Usage Measurement ==="
echo ""

# Token budget (200K tokens)
TOKEN_BUDGET=200000

# Function to estimate tokens (rough: 1 token ≈ 4 characters)
estimate_tokens() {
  local file=$1
  if [ -f "$file" ]; then
    local chars=$(wc -c < "$file")
    local tokens=$((chars / 4))
    echo "$tokens"
  else
    echo "0"
  fi
}

# Function to calculate percentage
calc_percentage() {
  local tokens=$1
  local percentage=$((tokens * 100 / TOKEN_BUDGET))
  echo "$percentage"
}

# Measure orchestrator
echo "1. Orchestrator Context:"
ORCH_TOKENS=$(estimate_tokens ".opencode/agent/orchestrator.md")
ORCH_PCT=$(calc_percentage $ORCH_TOKENS)
echo "   orchestrator.md: ${ORCH_TOKENS} tokens (${ORCH_PCT}%)"

# Measure routing guide
echo ""
echo "2. Routing Context:"
ROUTING_TOKENS=$(estimate_tokens ".opencode/context/system/routing-guide.md")
ROUTING_PCT=$(calc_percentage $ROUTING_TOKENS)
echo "   routing-guide.md: ${ROUTING_TOKENS} tokens (${ROUTING_PCT}%)"

# Measure command files
echo ""
echo "3. Command Files:"
for cmd in research plan implement revise; do
  CMD_FILE=".opencode/command/${cmd}.md"
  if [ -f "$CMD_FILE" ]; then
    CMD_TOKENS=$(estimate_tokens "$CMD_FILE")
    CMD_PCT=$(calc_percentage $CMD_TOKENS)
    echo "   ${cmd}.md: ${CMD_TOKENS} tokens (${CMD_PCT}%)"
  fi
done

# Calculate total routing context
echo ""
echo "4. Total Routing Context (Orchestrator + Routing + Command):"
TOTAL_ROUTING=$((ORCH_TOKENS + ROUTING_TOKENS))
# Add average command size (use plan.md as example)
PLAN_TOKENS=$(estimate_tokens ".opencode/command/plan.md")
TOTAL_ROUTING=$((TOTAL_ROUTING + PLAN_TOKENS))
TOTAL_ROUTING_PCT=$(calc_percentage $TOTAL_ROUTING)
echo "   Total: ${TOTAL_ROUTING} tokens (${TOTAL_ROUTING_PCT}%)"

# Target check
echo ""
echo "5. Target Validation:"
if [ $TOTAL_ROUTING_PCT -lt 10 ]; then
  echo "   ✓ PASS: Routing context under 10% target (${TOTAL_ROUTING_PCT}%)"
else
  echo "   ✗ FAIL: Routing context exceeds 10% target (${TOTAL_ROUTING_PCT}%)"
fi

# Measure agent files
echo ""
echo "6. Agent Files:"
for agent in researcher planner implementer task-executor lean-research-agent lean-implementation-agent; do
  AGENT_FILE=".opencode/agent/subagents/${agent}.md"
  if [ -f "$AGENT_FILE" ]; then
    AGENT_TOKENS=$(estimate_tokens "$AGENT_FILE")
    AGENT_PCT=$(calc_percentage $AGENT_TOKENS)
    echo "   ${agent}.md: ${AGENT_TOKENS} tokens (${AGENT_PCT}%)"
  fi
done

echo ""
echo "=== Measurement Complete ==="
