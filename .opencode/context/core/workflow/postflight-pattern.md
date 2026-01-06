# Postflight Pattern: Status Updates and Artifact Linking

## Overview

**Purpose**: This document defines the required pattern for workflow command postflight operations to ensure TODO.md and state.json remain synchronized with artifact links.

**Problem**: Workflow commands that bypass status-sync-manager and use direct jq commands create state inconsistencies where artifacts are created successfully but not linked in TODO.md, leaving tasks in stale status states.

**Solution**: All workflow commands MUST delegate to status-sync-manager in both preflight and postflight steps with validated_artifacts array to atomically update status and link artifacts.

**Enforcement**: This pattern is REQUIRED for all workflow commands (/research, /plan, /revise, /implement) and their subagents (researcher.md, planner.md, task-reviser.md, implementer.md).

---

## Required Pattern

### Preflight: Update Status to [IN_PROGRESS]

**When**: Before beginning work (step_0_preflight)

**Status Values**:
- Research: "researching"
- Planning: "planning"
- Revision: "revising"
- Implementation: "implementing"

**Pattern**:

```
STEP 0: PREFLIGHT

CRITICAL EXECUTION NOTE: This specification MUST be followed during execution.
DO NOT use direct jq commands. ALWAYS delegate to status-sync-manager.

1. Extract task inputs from delegation context

2. INVOKE status-sync-manager (REQUIRED - DO NOT SKIP):
   
   PREPARE delegation context:
   {
     "operation": "update_status",
     "task_number": {task_number},
     "new_status": "{in_progress_status}",  // e.g., "researching", "planning"
     "timestamp": "$(date -I)",
     "session_id": "{session_id}",
     "delegation_depth": {depth + 1},
     "delegation_path": [...delegation_path, "status-sync-manager"]
   }
   
   INVOKE status-sync-manager:
     - Execute delegation with timeout: 60s
     - LOG: "Invoking status-sync-manager for task {task_number}"
   
   WAIT for status-sync-manager return (maximum 60s):
     - IF timeout: ABORT with error "status-sync-manager timeout after 60s"
   
   VERIFY return:
     - status == "completed" (if "failed", abort with error)
     - files_updated includes [".opencode/specs/TODO.md", "state.json"]
   
   IF status != "completed":
     - Log error: "Preflight status update failed: {error_message}"
     - Return status: "failed"
     - DO NOT proceed to work execution

3. Verify status was actually updated (defense in depth):
   
   Read state.json to verify status:
     actual_status=$(jq -r --arg num "$task_number" \
       '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
       .opencode/specs/state.json)
   
   IF actual_status != "{in_progress_status}":
     - Log error: "Preflight verification failed - status not updated"
     - Log: "Expected: {in_progress_status}, Actual: $actual_status"
     - Return status: "failed"
     - DO NOT proceed to work execution

4. Verify preflight execution completed:
   - Checkpoint: status-sync-manager was actually invoked (not bypassed)
   - Checkpoint: TODO.md and state.json were verified on disk

5. Proceed to work execution
```

---

### Postflight: Update Status to [COMPLETED] and Link Artifacts

**When**: After work completion (step_N_postflight, where N varies by subagent)

**Status Values**:
- Research: "researched"
- Planning: "planned" or "revised"
- Implementation: "completed", "blocked", or "partial"

**Pattern**:

```
STEP N: POSTFLIGHT

CRITICAL EXECUTION NOTE: This specification MUST be followed during execution.
DO NOT use direct jq commands. ALWAYS delegate to status-sync-manager.

1. Generate completion timestamp: $(date -I)

2. INVOKE status-sync-manager (REQUIRED - DO NOT SKIP):
   
   PREPARE delegation context:
   {
     "operation": "update_status",
     "task_number": {task_number},
     "new_status": "{completed_status}",  // e.g., "researched", "planned"
     "timestamp": "$(date -I)",
     "session_id": "{session_id}",
     "delegation_depth": {depth + 1},
     "delegation_path": [...delegation_path, "status-sync-manager"],
     "validated_artifacts": [
       {
         "type": "{artifact_type}",  // e.g., "research_report", "plan"
         "path": "{artifact_path}",
         "summary": "{artifact_summary}",
         "validated": true
       }
     ],
     // Optional: Additional metadata (e.g., plan_metadata for planner)
   }
   
   INVOKE status-sync-manager:
     - Execute delegation with timeout: 60s
     - LOG: "Invoking status-sync-manager for task {task_number}"
   
   WAIT for status-sync-manager return (maximum 60s):
     - IF timeout: ABORT with error "status-sync-manager timeout after 60s"
   
   VERIFY return:
     - VERIFY return format matches subagent-return-format.md
     - VERIFY status field == "completed" (not "failed" or "partial")
     - VERIFY files_updated includes [".opencode/specs/TODO.md", "state.json"]
     - VERIFY rollback_performed == false
     - IF validation fails: ABORT with error details
   
   LOG: "status-sync-manager completed: {files_updated}"

3. Verify status and artifact link were actually updated (defense in depth):
   
   Read state.json to verify status:
     actual_status=$(jq -r --arg num "$task_number" \
       '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
       .opencode/specs/state.json)
   
   IF actual_status != "{completed_status}":
     - Log error: "Postflight verification failed - status not updated"
     - Log: "Expected: {completed_status}, Actual: $actual_status"
     - Return status: "failed"
     - DO NOT proceed to git commit
   
   Read TODO.md to verify artifact link:
     grep -q "{artifact_path}" .opencode/specs/TODO.md
   
   IF artifact link not found:
     - Log error: "Postflight verification failed - artifact not linked"
     - Return status: "failed"
     - DO NOT proceed to git commit

4. INVOKE git-workflow-manager (if status update succeeded):
   
   PREPARE delegation context:
   {
     "scope_files": [
       "{artifact_path}",
       ".opencode/specs/TODO.md",
       ".opencode/specs/state.json"
     ],
     "message_template": "task {task_number}: {work_description}",
     "task_context": {
       "task_number": {task_number},
       "description": "{work_description}"
     },
     "session_id": "{session_id}",
     "delegation_depth": {depth + 1},
     "delegation_path": [...delegation_path, "git-workflow-manager"]
   }
   
   INVOKE git-workflow-manager:
     - Execute delegation with timeout: 120s
     - LOG: "Invoking git-workflow-manager for task {task_number}"
   
   WAIT for git-workflow-manager return (maximum 120s):
     - IF timeout: LOG error (non-critical), continue
   
   VALIDATE return:
     - IF status == "completed":
       * EXTRACT commit_hash from commit_info
       * LOG: "Git commit created: {commit_hash}"
     
     - IF status == "failed":
       * LOG error to errors.json (non-critical)
       * INCLUDE warning in return
       * CONTINUE (git failure doesn't fail command)

5. Verify postflight execution completed:
   - Checkpoint: status-sync-manager was actually invoked (not bypassed)
   - Checkpoint: TODO.md and state.json were verified on disk
   - Checkpoint: git-workflow-manager was invoked (if status update succeeded)

6. Log postflight completion
```

---

## Working Examples

### Example 1: researcher.md (Research Workflow)

**Preflight** (step_0_preflight, lines 140-203):
- Status: "researching"
- No artifacts (research hasn't started)
- Delegates to status-sync-manager
- Verifies TODO.md and state.json updated

**Postflight** (step_4_postflight, lines 329-439):
- Status: "researched"
- Artifacts: research report
- Delegates to status-sync-manager with validated_artifacts
- Verifies TODO.md and state.json updated
- Delegates to git-workflow-manager

**File**: `.opencode/agent/subagents/researcher.md`

---

### Example 2: planner.md (Planning Workflow)

**Preflight** (step_0_preflight):
- Status: "planning" or "revising"
- No artifacts (planning hasn't started)
- Delegates to status-sync-manager
- Verifies TODO.md and state.json updated

**Postflight** (step_7, lines 410-550):
- Status: "planned" or "revised"
- Artifacts: implementation plan
- Delegates to status-sync-manager with validated_artifacts and plan_metadata
- Verifies TODO.md and state.json updated
- Delegates to git-workflow-manager

**File**: `.opencode/agent/subagents/planner.md`

---

### Example 3: implementer.md (Implementation Workflow)

**Preflight** (step_0_preflight):
- Status: "implementing"
- No artifacts (implementation hasn't started)
- Delegates to status-sync-manager
- Verifies TODO.md and state.json updated

**Postflight** (step_7):
- Status: "completed", "blocked", or "partial"
- Artifacts: implementation files and summary
- Delegates to status-sync-manager with validated_artifacts
- Verifies TODO.md and state.json updated
- Delegates to git-workflow-manager

**File**: `.opencode/agent/subagents/implementer.md`

---

## Validation Checklist

Use this checklist to verify correct implementation:

### Preflight Validation

- [ ] Delegation context prepared with correct parameters
- [ ] status-sync-manager invoked (not bypassed)
- [ ] Timeout set to 60s
- [ ] Return validated (status == "completed")
- [ ] files_updated includes TODO.md and state.json
- [ ] Defense-in-depth verification performed (read state.json)
- [ ] TODO.md status marker verified on disk
- [ ] Execution checkpoints added
- [ ] Explicit execution note added

### Postflight Validation

- [ ] Delegation context prepared with correct parameters
- [ ] validated_artifacts array included
- [ ] status-sync-manager invoked (not bypassed)
- [ ] Timeout set to 60s
- [ ] Return validated (status == "completed")
- [ ] files_updated includes TODO.md and state.json
- [ ] Defense-in-depth verification performed (read state.json and TODO.md)
- [ ] Artifact link verified in TODO.md
- [ ] git-workflow-manager invoked (if status update succeeded)
- [ ] Execution checkpoints added
- [ ] Explicit execution note added

---

## Common Mistakes

### ❌ WRONG: Direct jq Commands

```bash
# DO NOT DO THIS
jq --arg num "$task_number" \
  --arg status "researched" \
  '.active_projects[] |= if .project_number == ($num | tonumber) then .status = $status else . end' \
  .opencode/specs/state.json > /tmp/state.json.tmp
mv /tmp/state.json.tmp .opencode/specs/state.json
```

**Problem**: This updates state.json but NOT TODO.md, causing state inconsistency.

---

### ❌ WRONG: Skipping Defense-in-Depth Verification

```
# DO NOT DO THIS
INVOKE status-sync-manager
# Assume it worked, proceed to git commit
```

**Problem**: If status-sync-manager fails silently, TODO.md and state.json remain out of sync.

---

### ❌ WRONG: Missing validated_artifacts Array

```json
{
  "operation": "update_status",
  "task_number": 320,
  "new_status": "researched"
  // Missing: "validated_artifacts" array
}
```

**Problem**: status-sync-manager won't link artifacts in TODO.md without validated_artifacts.

---

### ✅ CORRECT: Full Delegation Pattern

```
INVOKE status-sync-manager:
  - Prepare delegation context with validated_artifacts
  - Execute with timeout
  - Validate return
  - Verify TODO.md and state.json on disk
  - Proceed to git commit only if verification succeeds
```

**Result**: TODO.md and state.json remain synchronized with artifact links.

---

## Enforcement Guidelines

### When to Load This Context

Load this context file when:

1. **Creating new workflow commands**: Ensure new commands follow the pattern
2. **Modifying existing workflow subagents**: Verify changes maintain the pattern
3. **Debugging postflight failures**: Check if pattern is being followed
4. **Code review**: Validate workflow command implementations

### How to Load This Context

**Selective Loading** (recommended):
```markdown
context_loading:
  strategy: lazy
  required:
    - "core/workflow/postflight-pattern.md"  # Only when creating/modifying workflow commands
```

**Full Loading** (for comprehensive validation):
```markdown
context_loading:
  strategy: eager
  required:
    - "core/workflow/postflight-pattern.md"
```

### Enforcement Mechanisms

1. **Code Review**: Check for status-sync-manager delegation in all workflow subagents
2. **Testing**: Verify TODO.md and state.json synchronization after workflow commands
3. **Documentation**: Reference this pattern in all workflow command documentation
4. **Validation Scripts**: Create automated checks for pattern compliance

---

## References

### Specifications

- **subagent-return-format.md**: Return format for status-sync-manager
- **artifact-management.md**: Artifact handling standards
- **status-markers.md**: Status marker conventions
- **tasks.md**: Task entry format standards

### Working Implementations

- **researcher.md**: Lines 140-203 (preflight), 329-439 (postflight)
- **planner.md**: Lines 410-550 (postflight with plan_metadata)
- **implementer.md**: Lines 275-380 (postflight with implementation artifacts)

### Related Tasks

- **Task 320**: Fix workflow command postflight failures
- **Task 324**: Root cause investigation
- **Task 323**: Test case proving problem exists

---

## Summary

**Key Principle**: ALWAYS delegate to status-sync-manager. NEVER use direct jq commands.

**Preflight**: Update status to [IN_PROGRESS] before work begins
**Postflight**: Update status to [COMPLETED] and link artifacts after work completes

**Defense in Depth**: Always verify TODO.md and state.json on disk after delegation

**Validation**: Use checklist to verify correct implementation

**Enforcement**: Load this context when creating/modifying workflow commands

---

**Created**: 2026-01-06  
**Version**: 1.0  
**Status**: Active  
**Enforcement**: Required for all workflow commands
