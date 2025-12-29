#!/bin/bash
# Backup script for Phase 2 OpenAgents Migration
# Task 245: Phase 2 Core Architecture
# Created: 2025-12-29

set -e

BACKUP_DIR=".opencode/backups/phase2"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Phase 2 Backup Script ==="
echo "Backup directory: ${BACKUP_DIR}"
echo "Timestamp: ${TIMESTAMP}"
echo ""

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Backup command files
echo "Backing up command files..."
cp .opencode/command/plan.md "${BACKUP_DIR}/plan.md.backup"
cp .opencode/command/implement.md "${BACKUP_DIR}/implement.md.backup"
cp .opencode/command/revise.md "${BACKUP_DIR}/revise.md.backup"
echo "  ✓ plan.md, implement.md, revise.md backed up"

# Backup agent files
echo "Backing up agent files..."
cp .opencode/agent/subagents/planner.md "${BACKUP_DIR}/planner.md.backup"
cp .opencode/agent/subagents/implementer.md "${BACKUP_DIR}/implementer.md.backup"
cp .opencode/agent/subagents/task-executor.md "${BACKUP_DIR}/task-executor.md.backup"
cp .opencode/agent/subagents/researcher.md "${BACKUP_DIR}/researcher.md.backup"
cp .opencode/agent/subagents/lean-research-agent.md "${BACKUP_DIR}/lean-research-agent.md.backup"
cp .opencode/agent/subagents/lean-implementation-agent.md "${BACKUP_DIR}/lean-implementation-agent.md.backup"
echo "  ✓ All 6 subagent files backed up"

# Backup orchestrator
echo "Backing up orchestrator..."
cp .opencode/agent/orchestrator.md "${BACKUP_DIR}/orchestrator.md.backup"
echo "  ✓ orchestrator.md backed up"

# Backup context files
echo "Backing up context files..."
if [ -f .opencode/context/system/routing-guide.md ]; then
  cp .opencode/context/system/routing-guide.md "${BACKUP_DIR}/routing-guide.md.backup"
  echo "  ✓ routing-guide.md backed up"
else
  echo "  ⚠ routing-guide.md not found (may not exist yet)"
fi

# Verify backups
echo ""
echo "Verifying backups..."
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/*.backup 2>/dev/null | wc -l)
echo "  Total backup files created: ${BACKUP_COUNT}"

# List all backups
echo ""
echo "Backup files:"
ls -lh "${BACKUP_DIR}"/*.backup 2>/dev/null || echo "  No backup files found"

echo ""
echo "=== Backup Complete ==="
echo "All Phase 2 files backed up successfully to ${BACKUP_DIR}/"
