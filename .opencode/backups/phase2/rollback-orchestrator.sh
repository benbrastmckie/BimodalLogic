#!/bin/bash
# Rollback script for orchestrator simplification
# Task 245: Phase 2 Core Architecture
# Created: 2025-12-29

set -e

BACKUP_DIR=".opencode/backups/phase2"

echo "=== Rolling back orchestrator ==="
echo ""

# Check backup exists
if [ ! -f "${BACKUP_DIR}/orchestrator.md.backup" ]; then
  echo "ERROR: Backup file not found: ${BACKUP_DIR}/orchestrator.md.backup"
  exit 1
fi

# Restore orchestrator
echo "Restoring orchestrator..."
cp "${BACKUP_DIR}/orchestrator.md.backup" ".opencode/agent/orchestrator.md"
echo "  ✓ orchestrator.md restored"

# Restore routing-guide if backup exists
if [ -f "${BACKUP_DIR}/routing-guide.md.backup" ]; then
  echo "Restoring routing-guide..."
  cp "${BACKUP_DIR}/routing-guide.md.backup" ".opencode/context/system/routing-guide.md"
  echo "  ✓ routing-guide.md restored"
fi

# Verify restoration
echo ""
echo "Verifying restoration..."
if [ -f ".opencode/agent/orchestrator.md" ]; then
  ORCH_SIZE=$(wc -l < ".opencode/agent/orchestrator.md")
  echo "  ✓ orchestrator.md exists (${ORCH_SIZE} lines)"
else
  echo "  ✗ orchestrator.md not found"
  exit 1
fi

echo ""
echo "=== Rollback Complete ==="
echo "Orchestrator restored from backup"
echo ""
echo "Next steps:"
echo "  1. Test all commands: /research, /plan, /implement, /revise"
echo "  2. Validate routing and delegation safety"
