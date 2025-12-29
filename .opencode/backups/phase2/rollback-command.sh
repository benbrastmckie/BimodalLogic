#!/bin/bash
# Rollback script for individual command migration
# Task 245: Phase 2 Core Architecture
# Created: 2025-12-29

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 COMMAND_NAME"
  echo "Example: $0 plan"
  echo "Available commands: plan, implement, revise"
  exit 1
fi

COMMAND=$1
BACKUP_DIR=".opencode/backups/phase2"

echo "=== Rolling back ${COMMAND} command ==="
echo ""

# Validate command
case $COMMAND in
  plan|implement|revise)
    ;;
  *)
    echo "ERROR: Invalid command '${COMMAND}'"
    echo "Available commands: plan, implement, revise"
    exit 1
    ;;
esac

# Determine agent name
case $COMMAND in
  plan) AGENT="planner" ;;
  implement) AGENT="implementer" ;;
  revise) AGENT="task-executor" ;;
esac

# Check backups exist
if [ ! -f "${BACKUP_DIR}/${COMMAND}.md.backup" ]; then
  echo "ERROR: Backup file not found: ${BACKUP_DIR}/${COMMAND}.md.backup"
  exit 1
fi

if [ ! -f "${BACKUP_DIR}/${AGENT}.md.backup" ]; then
  echo "ERROR: Backup file not found: ${BACKUP_DIR}/${AGENT}.md.backup"
  exit 1
fi

# Restore command file
echo "Restoring command file..."
cp "${BACKUP_DIR}/${COMMAND}.md.backup" ".opencode/command/${COMMAND}.md"
echo "  ✓ ${COMMAND}.md restored"

# Restore agent file
echo "Restoring agent file..."
cp "${BACKUP_DIR}/${AGENT}.md.backup" ".opencode/agent/subagents/${AGENT}.md"
echo "  ✓ ${AGENT}.md restored"

# Verify restoration
echo ""
echo "Verifying restoration..."
if [ -f ".opencode/command/${COMMAND}.md" ]; then
  CMD_SIZE=$(wc -l < ".opencode/command/${COMMAND}.md")
  echo "  ✓ ${COMMAND}.md exists (${CMD_SIZE} lines)"
else
  echo "  ✗ ${COMMAND}.md not found"
  exit 1
fi

if [ -f ".opencode/agent/subagents/${AGENT}.md" ]; then
  AGENT_SIZE=$(wc -l < ".opencode/agent/subagents/${AGENT}.md")
  echo "  ✓ ${AGENT}.md exists (${AGENT_SIZE} lines)"
else
  echo "  ✗ ${AGENT}.md not found"
  exit 1
fi

echo ""
echo "=== Rollback Complete ==="
echo "Command '${COMMAND}' and agent '${AGENT}' restored from backup"
echo ""
echo "Next steps:"
echo "  1. Test command: /${COMMAND} <task_number>"
echo "  2. Validate Stage 7: bash .opencode/backups/phase2/validate-stage7.sh <task_number> ${COMMAND}"
