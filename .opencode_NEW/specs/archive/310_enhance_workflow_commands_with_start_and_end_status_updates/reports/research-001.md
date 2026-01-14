# Research Report: Enhance Workflow Commands with Start and End Status Updates

**Task**: 310 - Enhance workflow commands with start and end status updates  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 4-6 hours (estimated for implementation)  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/command/implement.md`
- `.opencode/command/revise.md`
- `.opencode/agent/subagents/researcher.md`
- `.opencode/agent/subagents/planner.md`
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/status-sync-manager.md`
- `.opencode/context/core/system/state-management.md`
- `.opencode/context/core/workflows/status-transitions.md`

**Artifacts**:
- This research report

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md, state-management.md

---

## Executive Summary

Research reveals that workflow commands (`/research`, `/plan`, `/revise`, `/implement`) **already implement start and end status updates** through their subagents' preflight (step_0) and postflight (step_4/step_7) stages. The current implementation follows best practices:

- **Start status updates**: Delegated to `status-sync-manager` in subagent `step_0_preflight`
- **End status updates**: Delegated to `status-sync-manager` in subagent `step_4_postflight` or `step_7_postflight`
- **Fast lookups**: Commands use `state.json` for 8x faster task validation
- **Atomic synchronization**: `status-sync-manager` ensures TODO.md and state.json stay in sync
- **Already-in-progress detection**: Commands validate current status before starting

**Key Finding**: The task description requirements are **already implemented**. However, there are **gaps and inconsistencies** that need addressing:

1. `/revise` command does NOT update status (neither start nor end)
2. Status check for "already in progress" is incomplete
3. Documentation could be clearer about status lifecycle
4. Edge cases (concurrent execution, status conflicts) need handling

**Recommendation**: Rather than implementing from scratch, **enhance and standardize** the existing implementation to close gaps and improve consistency.

---

## Context & Scope

### Current Architecture

The ProofChecker workflow system uses a **delegation-based architecture**:

```
Command File (Stage 1-2)          Subagent (Step 0-8)
┌─────────────────────┐          ┌──────────────────────┐
│ Stage 1: Parse      │          │ Step 0: Preflight    │
│ - Parse task_number │          │ - Update to [*ING]   │
│ - Lookup state.json │          │ - Via status-sync    │
│ - Extract metadata  │          ├──────────────────────┤
│ - Validate status   │          │ Step 1-6: Work       │
├─────────────────────┤          │ - Research/Plan/Impl │
│ Stage 2: Delegate   │  ────>   │ - Create artifacts   │
│ - Invoke subagent   │          ├──────────────────────┤
│ - Relay result      │          │ Step 7: Postflight   │
└─────────────────────┘          │ - Update to [*ED]    │
                                 │ - Via status-sync    │
                                 │ - Create git commit  │
                                 └──────────────────────┘
```

**Key Components**:

1. **Command Files** (`.opencode/command/*.md`): Parse arguments, validate, delegate to subagents
2. **Subagents** (`.opencode/agent/subagents/*.md`): Own complete workflow including status updates
3. **status-sync-manager**: Provides atomic multi-file synchronization (TODO.md + state.json)
4. **state.json**: Fast task lookup (8x faster than TODO.md parsing)

### Status Lifecycle

Per `state-management.md`, the complete status lifecycle is:

```
[NOT STARTED] ──(/research)──> [RESEARCHING] ──> [RESEARCHED]
                                                        │
                                                        ▼
                                                  (/plan)
                                                        │
                                                        ▼
                                                  [PLANNING] ──> [PLANNED]
                                                                      │
                                                                      ├──(/revise)──> [REVISING] ──> [REVISED]
                                                                      │
                                                                      ▼
                                                                (/implement)
                                                                      │
                                                                      ▼
                                                              [IMPLEMENTING] ──> [COMPLETED]
                                                                      │
                                                                      ├──> [PARTIAL]
                                                                      └──> [BLOCKED]
```

**In-Progress Markers**:
- `[RESEARCHING]`: Research actively underway
- `[PLANNING]`: Plan creation in progress
- `[REVISING]`: Plan revision in progress
- `[IMPLEMENTING]`: Implementation actively underway

**Completion Markers**:
- `[RESEARCHED]`: Research completed
- `[PLANNED]`: Plan completed
- `[REVISED]`: Plan revision completed
- `[COMPLETED]`: Implementation finished successfully
- `[PARTIAL]`: Implementation partially complete (can resume)
- `[BLOCKED]`: Work blocked by dependencies

---

## Key Findings

### Finding 1: Start Status Updates Already Implemented

**Evidence**: All workflow subagents implement `step_0_preflight` that updates status to in-progress marker.

**researcher.md** (lines 140-166):
```xml
<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status to [RESEARCHING]</action>
  <process>
    1. Extract task inputs from delegation context
    2. Update status to [RESEARCHING]:
       - Delegate to status-sync-manager with task_number and new_status="researching"
       - Validate status update succeeded
       - Generate timestamp: $(date -I)
    3. Proceed to research execution with validated inputs
  </process>
  <checkpoint>Task inputs extracted, status updated to [RESEARCHING]</checkpoint>
</step_0_preflight>
```

**planner.md** (lines 95-121):
```xml
<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status to [PLANNING]</action>
  <process>
    2. Update status to [PLANNING]:
       - Delegate to status-sync-manager with task_number and new_status="planning"
       - Validate status update succeeded
       - Generate timestamp: $(date -I)
  </process>
  <checkpoint>Task inputs extracted, status updated to [PLANNING]</checkpoint>
</step_0_preflight>
```

**implementer.md** (lines 100-126):
```xml
<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status to [IMPLEMENTING]</action>
  <process>
    2. Update status to [IMPLEMENTING]:
       - Delegate to status-sync-manager with task_number and new_status="implementing"
       - Validate status update succeeded
       - Generate timestamp: $(date -I)
  </process>
  <checkpoint>Task inputs extracted, status updated to [IMPLEMENTING]</checkpoint>
</step_0_preflight>
```

**Status**: [PASS] - Start status updates fully implemented for /research, /plan, /implement

### Finding 2: End Status Updates Already Implemented

**Evidence**: All workflow subagents implement postflight steps that update status to completion marker.

**researcher.md** (lines 292-340):
```xml
<step_4_postflight>
  <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
  <process>
    2. Invoke status-sync-manager to mark [RESEARCHED]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "researched"
          - timestamp: {date}
          - validated_artifacts: [{type, path, summary}]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
  </process>
</step_4_postflight>
```

**planner.md** (lines 229-337):
```xml
<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    STEP 7.1: INVOKE status-sync-manager
      - new_status: "planned"
      - validated_artifacts: ["{plan_path}"]
      - plan_metadata: {phases, total_effort_hours, complexity}
  </process>
</step_7>
```

**implementer.md** (lines 237-338):
```xml
<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    STEP 7.1: INVOKE status-sync-manager
      - new_status: "completed"
      - validated_artifacts: ["{artifact_paths}"]
  </process>
</step_7>
```

**Status**: [PASS] - End status updates fully implemented for /research, /plan, /implement

### Finding 3: Fast Lookups Using state.json

**Evidence**: Commands use `state.json` for fast task validation and metadata extraction.

**research.md** (lines 26-64):
```xml
<stage id="1" name="ParseAndValidate">
  <process>
    3. Lookup task in state.json
       - Use jq to find task by project_number:
         task_data=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber))' \
           .opencode/specs/state.json)
       - If task_data is empty: Return error "Task $task_number not found"
    
    4. Extract all metadata at once
       - language=$(echo "$task_data" | jq -r '.language // "general"')
       - status=$(echo "$task_data" | jq -r '.status')
       - project_name=$(echo "$task_data" | jq -r '.project_name')
       - description=$(echo "$task_data" | jq -r '.description // ""')
       - priority=$(echo "$task_data" | jq -r '.priority')
  </process>
</stage>
```

**Performance**: Per `state-management.md` line 393:
- state.json lookup: ~12ms
- TODO.md parsing: ~100ms
- **8x faster** with state.json

**Status**: [PASS] - Fast lookups fully implemented

### Finding 4: Atomic Synchronization via status-sync-manager

**Evidence**: All status updates delegated to `status-sync-manager` for atomic multi-file updates.

**status-sync-manager.md** (lines 1-38):
```yaml
---
name: "status-sync-manager"
description: "Atomic multi-file status synchronization using two-phase commit"
---
```

**Two-Phase Commit Protocol** (state-management.md lines 458-470):

**Phase 1 (Prepare)**:
1. Read all target files into memory
2. Validate current status allows requested transition
3. Prepare all updates in memory
4. Validate all updates are well-formed
5. If any validation fails, abort (no files written)

**Phase 2 (Commit)**:
1. Write files in dependency order: TODO.md → state.json → plan
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
4. All files updated or none updated (atomic guarantee)

**Files Synchronized**:
- `.opencode/specs/TODO.md` (status marker, timestamps, artifact links)
- `.opencode/specs/state.json` (status field, timestamps, artifact_paths)
- `.opencode/specs/{task}_*/state.json` (project-specific state, lazy created)
- Plan files (phase status markers, if plan exists)

**Status**: [PASS] - Atomic synchronization fully implemented

### Finding 5: /revise Command Does NOT Update Status

**Evidence**: `/revise` command delegates to `planner` which updates status to `[PLANNED]`, not `[REVISED]`.

**revise.md** (lines 1-125):
```yaml
---
name: revise
description: "Create new plan versions with [REVISED] status"
routing:
  lean: lean-planner
  default: planner
---
```

**Problem**: The command description claims it sets `[REVISED]` status, but it delegates to `planner` which sets `[PLANNED]` status.

**planner.md** (line 239):
```json
{
  "new_status": "planned",  // Should be "revised" when called by /revise
}
```

**Impact**: 
- `/revise` command does NOT distinguish plan creation from plan revision in status
- Both `/plan` and `/revise` set status to `[PLANNED]`
- `[REVISED]` status marker exists in state-management.md but is never used
- `[REVISING]` in-progress marker exists but is never set

**Status**: [FAIL] - /revise command does not update status correctly

### Finding 6: Already-In-Progress Detection Incomplete

**Evidence**: Commands validate task status in Stage 1, but only check for "completed" or "abandoned", not for already-in-progress states.

**research.md** (lines 53-54):
```xml
5. Validate task status allows research
   - If status is "completed": Return error "Task $task_number already completed"
```

**plan.md** (lines 67-68):
```xml
5. Validate task status allows planning
   - If status is "completed": Return error "Task $task_number already completed"
```

**implement.md** (lines 53-55):
```xml
5. Validate task status allows implementation
   - If status is "completed": Return error "Task $task_number already completed"
   - If status is "abandoned": Return error "Task $task_number is abandoned"
```

**Missing Checks**:
- If task is `[RESEARCHING]`, `/research` should report "Task already being researched"
- If task is `[PLANNING]`, `/plan` should report "Task already being planned"
- If task is `[IMPLEMENTING]`, `/implement` should report "Task already being implemented"
- If task is `[REVISING]`, `/revise` should report "Task plan already being revised"

**Rationale**: Prevents concurrent execution of same command on same task, which could cause:
- Race conditions in status updates
- Duplicate artifacts
- Conflicting git commits
- Wasted computational resources

**Status**: [WARN] - Already-in-progress detection incomplete

### Finding 7: Edge Cases Not Handled

**Evidence**: No documentation or code for handling edge cases.

**Edge Cases Identified**:

1. **Concurrent Execution**: Two users run `/implement 259` simultaneously
   - Current: Both proceed, race condition in status updates
   - Expected: Second command detects `[IMPLEMENTING]` and reports "already in progress"

2. **Status Conflicts**: Task is `[BLOCKED]`, user runs `/implement`
   - Current: Command proceeds, changes status from `[BLOCKED]` to `[IMPLEMENTING]`
   - Expected: Command detects `[BLOCKED]` and reports "Task is blocked, resolve blocker first"

3. **Invalid Transitions**: Task is `[RESEARCHED]`, user runs `/research` again
   - Current: Command proceeds, changes status from `[RESEARCHED]` to `[RESEARCHING]`
   - Expected: Command detects `[RESEARCHED]` and reports "Task already researched. Use /plan to continue."

4. **Timeout Recovery**: `/implement` times out, status is `[IMPLEMENTING]`
   - Current: Status remains `[IMPLEMENTING]`, subsequent `/implement` blocked
   - Expected: Command detects stale `[IMPLEMENTING]` (e.g., >24 hours old) and allows resume

5. **Rollback Failures**: status-sync-manager rollback fails
   - Current: System in inconsistent state (TODO.md updated, state.json not)
   - Expected: Manual recovery instructions provided

**Status**: [WARN] - Edge cases not documented or handled

---

## Detailed Analysis

### Current Implementation Pattern

The current implementation follows a **consistent pattern** across all workflow commands:

**Command File Responsibilities** (Stage 1-2):
1. Parse task number from `$ARGUMENTS`
2. Validate `state.json` exists and is valid JSON
3. Lookup task in `state.json` using `jq`
4. Extract metadata (language, status, description, priority)
5. Validate task status allows operation (basic check)
6. Determine target agent based on language
7. Delegate to target agent via `task()` tool
8. Relay result to user

**Subagent Responsibilities** (Step 0-8):
1. **Step 0 (Preflight)**: Update status to in-progress marker via status-sync-manager
2. **Step 1-6 (Work)**: Execute research/planning/implementation
3. **Step 7 (Postflight)**: Update status to completion marker via status-sync-manager, create git commit
4. **Step 8 (Return)**: Format and return standardized result

**Delegation to status-sync-manager**:
```json
{
  "task_number": 259,
  "new_status": "implementing",
  "timestamp": "2026-01-05",
  "session_id": "sess_20260105_abc123",
  "delegation_depth": 2,
  "delegation_path": ["orchestrator", "implement", "implementer", "status-sync-manager"],
  "validated_artifacts": [
    ".opencode/specs/259_automation_tactics/summaries/implementation-summary-20260105.md"
  ]
}
```

**status-sync-manager Updates**:
1. TODO.md: Status marker, timestamps, artifact links
2. state.json: Status field, timestamps, artifact_paths
3. Project state.json: Lazy created if needed
4. Plan files: Phase status markers (if plan exists)

### Status Validation Best Practices

**Current Validation** (basic):
```bash
# research.md line 53-54
if [ "$status" == "completed" ]; then
  echo "Error: Task $task_number already completed"
  exit 1
fi
```

**Recommended Validation** (comprehensive):
```bash
# Validate status allows research
case "$status" in
  "completed")
    echo "Error: Task $task_number already completed"
    exit 1
    ;;
  "abandoned")
    echo "Error: Task $task_number is abandoned"
    exit 1
    ;;
  "researching")
    echo "Warning: Task $task_number is already being researched"
    echo "If this is a stale status, use /sync to fix"
    exit 1
    ;;
  "researched")
    echo "Info: Task $task_number already researched"
    echo "Research report: $(jq -r '.artifacts[0]' state.json)"
    echo "Use /plan to continue workflow"
    exit 0
    ;;
  *)
    # Status allows research, proceed
    ;;
esac
```

**Benefits**:
- Prevents concurrent execution
- Provides helpful guidance to user
- Detects invalid state transitions
- Suggests next steps in workflow

### state.json vs TODO.md for Reads

**Design Principle** (state-management.md line 363):
> Use state.json for reads, status-sync-manager for writes

**Why state.json for Reads?**:
- ✅ **Fast**: JSON parsing is 8x faster than markdown parsing (12ms vs 100ms)
- ✅ **Structured**: Direct field access with `jq` (no grep/sed needed)
- ✅ **Reliable**: Structured data more reliable than text parsing
- ✅ **Synchronized**: status-sync-manager keeps state.json and TODO.md in sync

**Why status-sync-manager for Writes?**:
- ✅ **Atomic**: Two-phase commit ensures all files updated or none
- ✅ **Consistent**: Single source of truth for update logic
- ✅ **Validated**: Validates status transitions before writing
- ✅ **Rollback**: Automatic rollback on failure

**Anti-Pattern** (DO NOT DO):
```bash
# WRONG: Direct TODO.md update
sed -i "s/\[NOT STARTED\]/\[RESEARCHING\]/" .opencode/specs/TODO.md

# WRONG: Direct state.json update
jq '.active_projects[0].status = "researching"' state.json > tmp && mv tmp state.json
```

**Correct Pattern**:
```bash
# RIGHT: Delegate to status-sync-manager
task(
  subagent_type="status-sync-manager",
  prompt="Update task 259 status to researching",
  context={
    "task_number": 259,
    "new_status": "researching",
    "timestamp": "2026-01-05"
  }
)
```

### /revise Command Analysis

**Current Behavior**:
1. `/revise 259` delegates to `planner`
2. `planner` updates status to `[PLANNING]` (step_0_preflight)
3. `planner` creates new plan version (implementation-002.md)
4. `planner` updates status to `[PLANNED]` (step_7_postflight)

**Problem**: No distinction between plan creation and plan revision in status.

**Expected Behavior**:
1. `/revise 259` delegates to `planner` with `revision_context`
2. `planner` detects `revision_context` parameter
3. `planner` updates status to `[REVISING]` (step_0_preflight)
4. `planner` creates new plan version (implementation-002.md)
5. `planner` updates status to `[REVISED]` (step_7_postflight)

**Implementation Options**:

**Option 1: Add revision_mode parameter to planner**
```xml
<!-- planner.md step_0_preflight -->
<process>
  1. Check if revision_context parameter provided
  2. If revision_context:
     - Update status to [REVISING]
     - Set revision_mode = true
  3. Else:
     - Update status to [PLANNING]
     - Set revision_mode = false
</process>

<!-- planner.md step_7_postflight -->
<process>
  1. If revision_mode:
     - Update status to [REVISED]
  2. Else:
     - Update status to [PLANNED]
</process>
```

**Option 2: Create separate plan-reviser subagent**
```yaml
# .opencode/agent/subagents/plan-reviser.md
---
name: "plan-reviser"
description: "Plan revision specialist"
---

<step_0_preflight>
  Update status to [REVISING]
</step_0_preflight>

<step_7_postflight>
  Update status to [REVISED]
</step_7_postflight>
```

**Recommendation**: Option 1 (add parameter) is simpler and avoids code duplication.

---

## Code Examples

### Example 1: Enhanced Status Validation in /research

```bash
# .opencode/command/research.md
# Stage 1: ParseAndValidate

# ... (task lookup code) ...

# 5. Validate task status allows research
status=$(echo "$task_data" | jq -r '.status')

case "$status" in
  "completed")
    echo "Error: Task $task_number already completed"
    echo "Recommendation: Task is done, no research needed"
    exit 1
    ;;
  "abandoned")
    echo "Error: Task $task_number is abandoned"
    echo "Recommendation: Un-abandon task before researching"
    exit 1
    ;;
  "researching")
    echo "Warning: Task $task_number is already being researched"
    echo "If this is a stale status (e.g., previous research crashed):"
    echo "  1. Check for existing research artifacts"
    echo "  2. Use /sync to reset status if needed"
    exit 1
    ;;
  "researched")
    # Get research artifact path
    research_path=$(echo "$task_data" | jq -r '.artifacts[0] // "unknown"')
    echo "Info: Task $task_number already researched"
    echo "Research report: $research_path"
    echo "Recommendation: Use /plan to continue workflow"
    exit 0
    ;;
  "not_started"|"planned"|"implementing"|"blocked")
    # Status allows research, proceed
    ;;
  *)
    echo "Warning: Unknown status '$status' for task $task_number"
    echo "Proceeding with research, but status may be invalid"
    ;;
esac
```

### Example 2: Enhanced Status Validation in /plan

```bash
# .opencode/command/plan.md
# Stage 1: ParseAndValidate

# ... (task lookup code) ...

# 5. Validate task status allows planning
status=$(echo "$task_data" | jq -r '.status')
plan_path=$(echo "$task_data" | jq -r '.plan_path // ""')

case "$status" in
  "completed")
    echo "Error: Task $task_number already completed"
    echo "Recommendation: Task is done, no planning needed"
    exit 1
    ;;
  "abandoned")
    echo "Error: Task $task_number is abandoned"
    echo "Recommendation: Un-abandon task before planning"
    exit 1
    ;;
  "planning")
    echo "Warning: Task $task_number is already being planned"
    echo "If this is a stale status (e.g., previous planning crashed):"
    echo "  1. Check for existing plan artifacts"
    echo "  2. Use /sync to reset status if needed"
    exit 1
    ;;
  "planned")
    echo "Info: Task $task_number already has a plan"
    echo "Plan: $plan_path"
    echo "Recommendation: Use /revise $task_number to update plan"
    exit 0
    ;;
  "not_started"|"researched"|"blocked")
    # Status allows planning, proceed
    ;;
  *)
    echo "Warning: Unknown status '$status' for task $task_number"
    echo "Proceeding with planning, but status may be invalid"
    ;;
esac
```

### Example 3: Enhanced Status Validation in /implement

```bash
# .opencode/command/implement.md
# Stage 1: ParseAndValidate

# ... (task lookup code) ...

# 5. Validate task status allows implementation
status=$(echo "$task_data" | jq -r '.status')

case "$status" in
  "completed")
    echo "Error: Task $task_number already completed"
    echo "Recommendation: Task is done, no implementation needed"
    exit 1
    ;;
  "abandoned")
    echo "Error: Task $task_number is abandoned"
    echo "Recommendation: Un-abandon task before implementing"
    exit 1
    ;;
  "implementing")
    echo "Warning: Task $task_number is already being implemented"
    echo "If this is a stale status (e.g., previous implementation crashed):"
    echo "  1. Check for existing implementation artifacts"
    echo "  2. Use /sync to reset status if needed"
    echo "  3. Or use /implement $task_number --resume to continue"
    exit 1
    ;;
  "blocked")
    blocking_reason=$(echo "$task_data" | jq -r '.blocking_reason // "unknown"')
    echo "Error: Task $task_number is blocked"
    echo "Blocking reason: $blocking_reason"
    echo "Recommendation: Resolve blocker before implementing"
    exit 1
    ;;
  "not_started"|"researched"|"planned"|"partial")
    # Status allows implementation, proceed
    ;;
  *)
    echo "Warning: Unknown status '$status' for task $task_number"
    echo "Proceeding with implementation, but status may be invalid"
    ;;
esac
```

### Example 4: /revise with Revision Mode

```xml
<!-- .opencode/agent/subagents/planner.md -->

<inputs_required>
  <parameter name="revision_context" type="string" optional="true">
    Context for plan revision (if called by /revise)
  </parameter>
  <parameter name="plan_version" type="integer" optional="true">
    Plan version number (default 1, incremented for revisions)
  </parameter>
</inputs_required>

<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status</action>
  <process>
    1. Extract task inputs from delegation context
    
    2. Determine if this is a revision:
       - If revision_context parameter provided: revision_mode = true
       - Else: revision_mode = false
    
    3. Update status based on mode:
       - If revision_mode:
         * Update status to [REVISING]
         * Delegate to status-sync-manager with new_status="revising"
       - Else:
         * Update status to [PLANNING]
         * Delegate to status-sync-manager with new_status="planning"
    
    4. Validate status update succeeded
    5. Generate timestamp: $(date -I)
    6. Proceed to planning with validated inputs
  </process>
  <checkpoint>Task inputs extracted, status updated to [PLANNING] or [REVISING]</checkpoint>
</step_0_preflight>

<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    STEP 7.1: INVOKE status-sync-manager
      PREPARE delegation context:
      ```json
      {
        "task_number": "{number}",
        "new_status": "{revision_mode ? 'revised' : 'planned'}",
        "timestamp": "{ISO8601 date}",
        "session_id": "{session_id}",
        "validated_artifacts": ["{plan_path}"],
        "plan_path": "{plan_path}",
        "plan_metadata": {
          "phases": {phase_count},
          "total_effort_hours": {estimated_hours},
          "complexity": "{complexity}",
          "research_integrated": {true/false},
          "plan_version": {plan_version}
        }
      }
      ```
  </process>
</step_7>
```

---

## Decisions

### Decision 1: Enhance Existing Implementation vs Rewrite

**Options**:
1. Enhance existing implementation (close gaps, add validation)
2. Rewrite from scratch (new architecture)

**Decision**: Enhance existing implementation

**Rationale**:
- Current implementation is well-designed and follows best practices
- Subagents already own complete workflow (preflight + postflight)
- status-sync-manager provides atomic synchronization
- state.json provides fast lookups
- Only gaps are: /revise status, already-in-progress detection, edge cases
- Rewrite would be high-risk, high-effort, low-value

### Decision 2: Where to Add Already-In-Progress Detection

**Options**:
1. In command files (Stage 1 validation)
2. In subagents (step_0_preflight)
3. In status-sync-manager (validation before update)

**Decision**: In command files (Stage 1 validation)

**Rationale**:
- Command files already validate status in Stage 1
- Fail-fast: Detect issue before delegating to subagent
- Better user experience: Immediate feedback, no wasted computation
- Consistent with current pattern (status validation in Stage 1)

### Decision 3: How to Handle /revise Status

**Options**:
1. Add revision_mode parameter to planner
2. Create separate plan-reviser subagent
3. Leave as-is (use [PLANNED] for both)

**Decision**: Add revision_mode parameter to planner

**Rationale**:
- Simpler than creating new subagent
- Avoids code duplication
- Planner already handles both plan creation and revision
- Only difference is status markers ([PLANNING]/[PLANNED] vs [REVISING]/[REVISED])

### Decision 4: Edge Case Handling Strategy

**Options**:
1. Implement full edge case handling now
2. Document edge cases, implement incrementally
3. Ignore edge cases

**Decision**: Document edge cases, implement incrementally

**Rationale**:
- Edge cases are rare in single-user environment
- Full implementation would add significant complexity
- Better to document and handle as issues arise
- Priority: Close known gaps first (already-in-progress, /revise status)

---

## Recommendations

### Recommendation 1: Enhance Status Validation in Command Files

**Priority**: High  
**Effort**: 2-3 hours  
**Impact**: Prevents concurrent execution, provides better user guidance

**Implementation**:
1. Update `/research` Stage 1 validation to check for `[RESEARCHING]` and `[RESEARCHED]`
2. Update `/plan` Stage 1 validation to check for `[PLANNING]` and `[PLANNED]`
3. Update `/implement` Stage 1 validation to check for `[IMPLEMENTING]` and `[BLOCKED]`
4. Update `/revise` Stage 1 validation to check for `[REVISING]`
5. Add helpful error messages with recommendations for next steps

**Files to Modify**:
- `.opencode/command/research.md` (Stage 1, lines 53-54)
- `.opencode/command/plan.md` (Stage 1, lines 67-71)
- `.opencode/command/implement.md` (Stage 1, lines 53-55)
- `.opencode/command/revise.md` (Stage 1, lines 54-56)

### Recommendation 2: Fix /revise Status Updates

**Priority**: High  
**Effort**: 1-2 hours  
**Impact**: Distinguishes plan creation from plan revision in status

**Implementation**:
1. Add `revision_context` parameter to planner inputs
2. Update planner `step_0_preflight` to check `revision_context` and set status to `[REVISING]` if present
3. Update planner `step_7_postflight` to set status to `[REVISED]` if `revision_context` present
4. Update `/revise` command to pass `revision_context` parameter to planner

**Files to Modify**:
- `.opencode/agent/subagents/planner.md` (inputs, step_0_preflight, step_7_postflight)
- `.opencode/command/revise.md` (Stage 2 delegation)

### Recommendation 3: Document Edge Cases and Recovery Procedures

**Priority**: Medium  
**Effort**: 1 hour  
**Impact**: Provides manual recovery instructions for rare edge cases

**Implementation**:
1. Create `.opencode/docs/troubleshooting/status-conflicts.md`
2. Document each edge case with:
   - Symptoms (how to detect)
   - Root cause
   - Manual recovery steps
   - Prevention tips
3. Link from command error messages

**Edge Cases to Document**:
1. Concurrent execution (two users run same command)
2. Stale in-progress status (command crashed, status stuck)
3. Invalid status transitions (e.g., `[RESEARCHED]` → `[RESEARCHING]`)
4. Rollback failures (status-sync-manager rollback fails)
5. Timeout recovery (command times out, how to resume)

### Recommendation 4: Add --force Flag for Override

**Priority**: Low  
**Effort**: 2 hours  
**Impact**: Allows advanced users to override status validation

**Implementation**:
1. Add `--force` flag parsing to command files
2. Skip status validation if `--force` flag present
3. Log warning when `--force` used
4. Document `--force` flag in command help text

**Use Cases**:
- Recovering from stale in-progress status
- Re-running research after previous research was incomplete
- Overriding status validation for testing

**Example**:
```bash
/research 259 --force  # Override status validation
```

### Recommendation 5: Create /sync Command for Status Repair

**Priority**: Medium  
**Effort**: 3-4 hours  
**Impact**: Provides automated status repair for common issues

**Implementation**:
1. Create `.opencode/command/sync.md`
2. Implement status repair logic:
   - Detect stale in-progress statuses (>24 hours old)
   - Detect TODO.md/state.json inconsistencies
   - Offer to reset status to last known good state
   - Validate artifact existence matches status
3. Delegate to status-sync-manager for atomic updates

**Use Cases**:
- Recovering from crashed commands
- Fixing TODO.md/state.json desync
- Resetting stale in-progress statuses

**Note**: Task 295 already exists for creating `/sync` command. This recommendation aligns with that task.

---

## Risks & Mitigations

### Risk 1: Breaking Existing Workflows

**Likelihood**: Medium  
**Impact**: High  
**Mitigation**:
- Test all changes thoroughly before deploying
- Add `--force` flag to override new validation
- Document changes in migration guide
- Provide rollback instructions

### Risk 2: False Positives in Already-In-Progress Detection

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Add timestamp checking (only flag if status >1 hour old)
- Provide clear error messages with recovery steps
- Add `--force` flag to override

### Risk 3: /revise Changes Break Existing Plans

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Revision mode only affects status markers, not plan content
- Existing plans continue to work
- No breaking changes to plan format

### Risk 4: Edge Cases Not Fully Handled

**Likelihood**: High  
**Impact**: Low  
**Mitigation**:
- Document edge cases thoroughly
- Provide manual recovery instructions
- Implement automated handling incrementally as issues arise

---

## Appendix: Sources and Citations

### Primary Sources

1. **Command Files**:
   - `.opencode/command/research.md` - Research command implementation
   - `.opencode/command/plan.md` - Planning command implementation
   - `.opencode/command/implement.md` - Implementation command implementation
   - `.opencode/command/revise.md` - Revision command implementation

2. **Subagent Files**:
   - `.opencode/agent/subagents/researcher.md` - Research subagent with preflight/postflight
   - `.opencode/agent/subagents/planner.md` - Planning subagent with preflight/postflight
   - `.opencode/agent/subagents/implementer.md` - Implementation subagent with preflight/postflight
   - `.opencode/agent/subagents/status-sync-manager.md` - Atomic status synchronization

3. **Standards and Documentation**:
   - `.opencode/context/core/system/state-management.md` - State management standard
   - `.opencode/context/core/workflows/status-transitions.md` - Status transition diagram
   - `.opencode/specs/TODO.md` - Task tracking file (YAML header, status markers)
   - `.opencode/specs/state.json` - Central state tracking (JSON schema)

### Key Findings Summary

| Finding | Status | Evidence |
|---------|--------|----------|
| Start status updates implemented | [PASS] | All subagents have step_0_preflight |
| End status updates implemented | [PASS] | All subagents have step_4/7_postflight |
| Fast lookups using state.json | [PASS] | Commands use jq for 8x faster lookup |
| Atomic sync via status-sync-manager | [PASS] | Two-phase commit protocol |
| /revise status updates | [FAIL] | Uses [PLANNED] instead of [REVISED] |
| Already-in-progress detection | [WARN] | Only checks completed/abandoned |
| Edge case handling | [WARN] | Not documented or handled |

### Implementation Effort Estimate

| Task | Priority | Effort | Impact |
|------|----------|--------|--------|
| Enhance status validation | High | 2-3 hours | High |
| Fix /revise status | High | 1-2 hours | High |
| Document edge cases | Medium | 1 hour | Medium |
| Add --force flag | Low | 2 hours | Low |
| Create /sync command | Medium | 3-4 hours | Medium |
| **Total** | | **9-12 hours** | |

---

## Conclusion

The workflow commands (`/research`, `/plan`, `/revise`, `/implement`) **already implement start and end status updates** through their subagents' preflight and postflight stages. The current implementation follows best practices:

- ✅ Subagents own complete workflow (preflight + work + postflight)
- ✅ status-sync-manager provides atomic multi-file synchronization
- ✅ state.json provides 8x faster task lookups
- ✅ Two-phase commit ensures TODO.md and state.json stay in sync

**However**, there are **gaps and inconsistencies** that need addressing:

1. ❌ `/revise` command does NOT update status to `[REVISING]`/`[REVISED]`
2. ⚠️ Already-in-progress detection is incomplete (only checks completed/abandoned)
3. ⚠️ Edge cases (concurrent execution, status conflicts) not handled

**Recommendation**: Rather than implementing from scratch, **enhance and standardize** the existing implementation:

1. **High Priority** (3-5 hours):
   - Enhance status validation in command files (check for already-in-progress)
   - Fix `/revise` status updates (add revision_mode parameter to planner)

2. **Medium Priority** (4-5 hours):
   - Document edge cases and recovery procedures
   - Create `/sync` command for status repair (aligns with task 295)

3. **Low Priority** (2 hours):
   - Add `--force` flag for override

**Total Effort**: 9-12 hours to close all gaps and achieve full compliance with task requirements.

The existing implementation is **well-designed and production-ready**. The recommended enhancements will make it **more robust and user-friendly** without requiring a rewrite.
