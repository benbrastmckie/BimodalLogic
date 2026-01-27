#!/bin/bash
# Measure current state of Phase 2 migration

echo "=== Current State Measurement ==="
echo "Date: $(date +%Y-%m-%d)"
echo ""

echo "=== Orchestrator ===" 
wc -l .opencode/agent/orchestrator.md

echo ""
echo "=== Command Files ==="
wc -l .opencode/command/plan.md
wc -l .opencode/command/implement.md
wc -l .opencode/command/revise.md
wc -l .opencode/command/research.md
echo "Total:"
wc -l .opencode/command/plan.md .opencode/command/implement.md .opencode/command/revise.md .opencode/command/research.md | tail -1

echo ""
echo "=== Subagent Files ==="
find .opencode/agent/subagents -name "*.md" -exec wc -l {} + | tail -1

echo ""
echo "=== Context System ==="
find .opencode/context -name "*.md" -exec wc -l {} + | tail -1

echo ""
echo "=== Total System Size ==="
find .opencode -name "*.md" -exec wc -l {} + | tail -1
