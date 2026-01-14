#!/usr/bin/env bash
# cleanup-sessions.sh - Remove session directories older than 24 hours
#
# Usage: ./cleanup-sessions.sh [--dry-run]
#
# Options:
#   --dry-run    Show what would be deleted without actually deleting

set -euo pipefail

SESSIONS_DIR=".tmp/sessions"
MAX_AGE_HOURS=24
DRY_RUN=false

# Parse arguments
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  echo "[INFO] Dry run mode - no files will be deleted"
fi

# Check if sessions directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
  echo "[INFO] Sessions directory does not exist: $SESSIONS_DIR"
  exit 0
fi

# Find sessions older than MAX_AGE_HOURS
echo "[INFO] Searching for sessions older than ${MAX_AGE_HOURS} hours in $SESSIONS_DIR"

# Count sessions
total_sessions=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
echo "[INFO] Total sessions found: $total_sessions"

if [ "$total_sessions" -eq 0 ]; then
  echo "[INFO] No sessions to clean up"
  exit 0
fi

# Find and process old sessions
old_sessions=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +0 2>/dev/null || true)

if [ -z "$old_sessions" ]; then
  echo "[INFO] No sessions older than ${MAX_AGE_HOURS} hours found"
  exit 0
fi

# Count old sessions
old_count=$(echo "$old_sessions" | wc -l)
echo "[INFO] Found $old_count sessions older than ${MAX_AGE_HOURS} hours"

# Process each old session
deleted_count=0
while IFS= read -r session_dir; do
  if [ -z "$session_dir" ]; then
    continue
  fi
  
  session_name=$(basename "$session_dir")
  session_age=$(find "$session_dir" -maxdepth 0 -printf '%TY-%Tm-%Td %TH:%TM\n')
  
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would delete: $session_name (modified: $session_age)"
  else
    echo "[DELETE] Removing session: $session_name (modified: $session_age)"
    rm -rf "$session_dir"
    ((deleted_count++))
  fi
done <<< "$old_sessions"

if [ "$DRY_RUN" = true ]; then
  echo "[INFO] Dry run complete. Would delete $old_count sessions"
else
  echo "[INFO] Cleanup complete. Deleted $deleted_count sessions"
fi

# Show remaining sessions
remaining=$(find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
echo "[INFO] Remaining sessions: $remaining"

exit 0
