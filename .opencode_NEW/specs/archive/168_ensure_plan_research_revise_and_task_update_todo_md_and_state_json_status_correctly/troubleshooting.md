# Status Synchronization Troubleshooting Guide

**Project**: #168
**Date**: 2025-12-24
**Version**: 1.0

## Overview

This guide helps diagnose and resolve status synchronization issues across TODO.md, state.json, and plan files.

## Common Issues

### Issue 1: TODO.md and state.json Out of Sync

**Symptoms**:
- TODO.md shows `[PLANNED]` but state.json shows `"in_progress"`
- Timestamps don't match between files
- Status markers inconsistent

**Diagnosis**:
1. Check TODO.md status marker
2. Check state.json status field
3. Check project state.json status field (if exists)
4. Compare timestamps across all files

**Root Causes**:
- Partial update failure (one file updated, others failed)
- Manual edit to one file without updating others
- Command didn't use status-sync-manager
- Rollback failed to restore all files

**Resolution**:
1. Identify which file has correct status (usually TODO.md is authoritative)
2. Manually update other files to match
3. Verify timestamps are consistent
4. Run `/task {number}` to re-sync if needed

**Prevention**:
- Always use commands (/plan, /research, /task) for status updates
- Never manually edit TODO.md or state.json status fields
- Ensure status-sync-manager is used for all multi-file updates

---

### Issue 2: Plan File Status Doesn't Match TODO.md

**Symptoms**:
- TODO.md shows `[COMPLETED]` but plan file shows `[IN PROGRESS]`
- Plan file header status marker missing or incorrect
- Phase status markers don't reflect actual progress

**Diagnosis**:
1. Check TODO.md status
2. Check plan file header status
3. Check plan file phase status markers
4. Verify plan link in TODO.md matches actual plan file

**Root Causes**:
- Plan file not updated during status change
- Manual edit to plan file
- Command didn't include plan_path parameter
- Old plan file not superseded correctly

**Resolution**:
1. Open plan file
2. Update header status marker to match TODO.md
3. Update **Completed** timestamp if needed
4. Update phase status markers if needed
5. Save plan file

**Prevention**:
- Always provide plan_path to status-sync-manager
- Use /revise to create new plan versions
- Don't manually edit plan file status markers

---

### Issue 3: Invalid Status Transition Error

**Symptoms**:
- Command returns error: "Invalid status transition: [COMPLETED] → [IN PROGRESS]"
- Status update rejected
- No files modified

**Diagnosis**:
1. Check current status in TODO.md
2. Verify requested operation
3. Check status transition rules in status-markers.md

**Root Causes**:
- Attempting to change completed task
- Attempting invalid transition (e.g., [NOT STARTED] → [COMPLETED])
- Task already in target status

**Resolution**:
1. If task is [COMPLETED], don't try to change it
2. If transition is invalid, use intermediate status:
   - [NOT STARTED] → [IN PROGRESS] → [COMPLETED]
   - [COMPLETED] → [NOT STARTED] (restart from scratch)
3. If task already in target status, no action needed

**Prevention**:
- Follow status transition diagram in status-markers.md
- Don't skip intermediate statuses
- Don't modify completed tasks

---

### Issue 4: Partial Update Failure

**Symptoms**:
- TODO.md updated but state.json unchanged
- Error message: "Failed to write state.json"
- Rollback performed but some files not restored

**Diagnosis**:
1. Check error message for which file failed
2. Verify file permissions
3. Check disk space
4. Verify file is not locked by another process

**Root Causes**:
- Permission denied on state.json
- Disk full
- File locked by another process
- Filesystem error

**Resolution**:
1. Fix underlying issue (permissions, disk space, etc.)
2. Manually restore files from backup if rollback failed
3. Re-run command after fixing issue

**Prevention**:
- Ensure write permissions on all files
- Monitor disk space
- Don't run multiple commands concurrently on same task
- Use file locking to prevent concurrent updates

---

### Issue 5: Timestamp Format Incorrect

**Symptoms**:
- Timestamps in wrong format (e.g., "12/24/2025" instead of "2025-12-24")
- state.json has `started_at` instead of `started`
- Plan file has date-only timestamp instead of ISO8601

**Diagnosis**:
1. Check timestamp format in TODO.md (should be YYYY-MM-DD)
2. Check timestamp format in state.json (should be YYYY-MM-DD)
3. Check timestamp format in plan file (should be YYYY-MM-DD for header, ISO8601 for phases)
4. Check field names in state.json (should be `started`, not `started_at`)

**Root Causes**:
- Manual edit with wrong format
- Old command version using `_at` suffix
- Incorrect timestamp generation

**Resolution**:
1. Update timestamps to correct format:
   - TODO.md: YYYY-MM-DD
   - state.json: YYYY-MM-DD
   - Plan header: YYYY-MM-DD
   - Plan phases: ISO8601 (YYYY-MM-DDTHH:MM:SSZ)
2. Rename fields in state.json:
   - `started_at` → `started`
   - `completed_at` → `completed`
   - `researched_at` → `researched`
   - `planned_at` → `planned`

**Prevention**:
- Use status-sync-manager for all updates
- Don't manually edit timestamp fields
- Follow state-schema.md field naming conventions

---

### Issue 6: Lazy Directory Creation Violated

**Symptoms**:
- Project directory created during status update
- plans/ or reports/ subdirectory created without artifacts
- Empty directories in .opencode/specs/

**Diagnosis**:
1. Check if project directory exists
2. Check if subdirectories exist
3. Check if any artifacts exist in subdirectories
4. Verify command that created directories

**Root Causes**:
- Command created directories during status update
- Directory creation not deferred until artifact write
- Validation created directories

**Resolution**:
1. Remove empty directories
2. Update command to defer directory creation
3. Ensure status updates don't create directories

**Prevention**:
- Status updates must not create directories
- Only create directories when writing artifacts
- Follow lazy directory creation principle

---

### Issue 7: Concurrent Update Corruption

**Symptoms**:
- Files corrupted or truncated
- JSON syntax errors in state.json
- Status markers malformed in TODO.md
- Lost updates

**Diagnosis**:
1. Check file integrity (valid JSON, valid markdown)
2. Check for concurrent command execution
3. Check file modification timestamps
4. Restore from backup if corrupted

**Root Causes**:
- Two commands updating same task concurrently
- No file locking
- Race condition in write operations

**Resolution**:
1. Restore files from backup
2. Re-run commands sequentially (not concurrently)
3. Verify file integrity after restore

**Prevention**:
- Don't run multiple commands on same task concurrently
- Implement file locking in status-sync-manager
- Serialize status updates through orchestrator

---

## Diagnostic Commands

### Check Status Consistency

```bash
# Check TODO.md status for task 168
grep -A 5 "^### 168\." .opencode/specs/TODO.md | grep "Status:"

# Check state.json status for task 168
jq '.pending_tasks[] | select(.project_number == 168) | .status' .opencode/specs/state.json

# Check project state.json status
jq '.status' .opencode/specs/168_*/state.json

# Check plan file status
grep "^**Status**:" .opencode/specs/168_*/plans/implementation-*.md
```

### Check Timestamp Consistency

```bash
# Check TODO.md timestamps
grep -A 10 "^### 168\." .opencode/specs/TODO.md | grep -E "(Started|Completed|Researched|Planned):"

# Check state.json timestamps
jq '.pending_tasks[] | select(.project_number == 168) | {started, completed, researched, planned}' .opencode/specs/state.json

# Check project state.json timestamps
jq '{started, completed, last_updated}' .opencode/specs/168_*/state.json
```

### Check Field Naming

```bash
# Check for _at suffix in state.json (should not exist)
grep -E "(started_at|completed_at|researched_at|planned_at)" .opencode/specs/state.json

# Check for correct field names
jq '.pending_tasks[] | select(.project_number == 168) | keys' .opencode/specs/state.json
```

### Validate File Integrity

```bash
# Validate JSON syntax
jq empty .opencode/specs/state.json
jq empty .opencode/specs/168_*/state.json

# Check for empty directories
find .opencode/specs/168_* -type d -empty

# Check file permissions
ls -la .opencode/specs/TODO.md
ls -la .opencode/specs/state.json
```

## Recovery Procedures

### Procedure 1: Restore from Backup

If files are corrupted or inconsistent:

1. Stop all running commands
2. Restore files from backup:
   ```bash
   cp .opencode/specs/TODO.md.backup .opencode/specs/TODO.md
   cp .opencode/specs/state.json.backup .opencode/specs/state.json
   ```
3. Verify file integrity
4. Re-run commands to get back to desired state

### Procedure 2: Manual Sync

If backup not available, manually sync files:

1. Identify authoritative source (usually TODO.md)
2. Update state.json to match:
   ```bash
   # Edit state.json manually
   vim .opencode/specs/state.json
   ```
3. Update project state.json to match
4. Update plan file to match
5. Verify all files consistent

### Procedure 3: Reset Task Status

If task is in inconsistent state, reset to known good state:

1. Update TODO.md to [NOT STARTED]
2. Update state.json to "not_started"
3. Remove timestamps
4. Re-run workflow from beginning

## Prevention Best Practices

1. **Always use commands** for status updates, never manual edits
2. **Use status-sync-manager** for all multi-file updates
3. **Don't run concurrent commands** on same task
4. **Backup files** before major operations
5. **Validate file integrity** after updates
6. **Follow status transition rules** in status-markers.md
7. **Use correct timestamp formats** per state-schema.md
8. **Preserve lazy directory creation** - no dirs without artifacts
9. **Monitor error messages** and fix issues immediately
10. **Test in non-production** environment first

## Getting Help

If issues persist:

1. Check status-markers.md for status transition rules
2. Check state-schema.md for field naming conventions
3. Check status-sync-manager.md for atomic update details
4. Review command documentation for correct usage
5. Check test-plan.md for validation procedures
6. Report bugs with full error messages and file states

## Version History

- **1.0** (2025-12-24): Initial troubleshooting guide
