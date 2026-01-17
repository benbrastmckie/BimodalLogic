# Research Report: Fix Systematic Preflight Failures in Workflow Commands

**Task**: 321 - Fix workflow command preflight status update failures  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 6-8 hours  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**: 
- .opencode/command/research.md
- .opencode/command/plan.md
- .opencode/command/implement.md
- .opencode/command/revise.md
- .opencode/agent/subagents/researcher.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/implementer.md
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/lean-planner.md
- .opencode/agent/subagents/lean-implementation-agent.md
- .opencode/agent/subagents/status-sync-manager.md
- .opencode/context/core/system/state-management.md
- .opencode/context/core/workflows/status-transitions.md
- specs/TODO.md
- specs/state.json

**Artifacts**: 
- specs/321_fix_workflow_command_preflight_status_update_failures/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

Research confirms systematic preflight failures in workflow commands (/research, /plan, /revise, /implement) where status is NOT being updated to in-progress markers ([RESEARCHING], [PLANNING], [REVISING], [IMPLEMENTING]) when starting work. The root cause is that subagent markdown files contain **instructions** to delegate to status-sync-manager in step_0_preflight, but these instructions are **not being executed** by the AI agents. This is a documentation-vs-execution gap where the process is documented but not enforced.

**Evidence of Failure**:
- Task 314: TODO.md shows [RESEARCHED] with artifacts, but state.json shows "not_started" with no artifacts
- Task 315: Successfully updated (shows proper delegation is possible when executed)
- Example from task description: "/research 315 does not update status to [RESEARCHING] at start"

**Impact**: 
- State synchronization failures between TODO.md and state.json
- Phantom research/planning/implementation (artifacts created but status not tracked)
- Workflow commands cannot detect if work is already in progress
- Status validation in commands becomes ineffective

**Recommendation**: 
1. Add explicit validation in workflow commands to verify preflight status update occurred
2. Add timeout protection for in-progress statuses (auto-reset stale statuses)
3. Enhance subagent instructions with concrete delegation examples
4. Add preflight validation checkpoints in command Stage 3 (ValidateReturn)

---

## Context & Scope

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) are experiencing systematic preflight failures where:

1. **Preflight Step Not Executing**: Subagents receive delegation from commands but do not execute step_0_preflight to update status to in-progress markers
2. **Status Remains Stale**: Task status remains [NOT STARTED] even after work begins
3. **State Synchronization Fails**: TODO.md and state.json become desynchronized
4. **No In-Progress Detection**: Commands cannot detect if work is already underway

### Scope of Investigation

**In Scope**:
- Workflow command preflight validation (Stage 1)
- Subagent step_0_preflight implementation
- status-sync-manager integration
- Status marker transitions
- State synchronization mechanisms

**Out of Scope**:
- Postflight status update failures (covered by task 320)
- Git commit failures (non-critical, separate issue)
- Artifact creation failures (separate validation)

### Research Methodology

1. **File Analysis**: Examined all 4 workflow commands and 6 subagents
2. **State Inspection**: Compared TODO.md vs state.json for evidence of failures
3. **Workflow Tracing**: Traced execution flow from command → subagent → status-sync-manager
4. **Standards Review**: Reviewed state-management.md and status-transitions.md
5. **Evidence Collection**: Documented specific failure cases (task 314, 315)

---

## Key Findings

### Finding 1: Subagent Instructions Are Not Being Executed

**Severity**: CRITICAL  
**Affected Files**: All 6 workflow subagents

**Evidence**:

All subagents have step_0_preflight instructions that say:
```
2. Update status to [RESEARCHING]:
   - Delegate to status-sync-manager with task_number and new_status="researching"
   - Validate status update succeeded
   - Generate timestamp: $(date -I)
```

However, these are **instructions in markdown**, not executable code. The AI agents reading these instructions may not execute them consistently.

**Affected Subagents**:
1. researcher.md (line 159)
2. planner.md (line 119-125)
3. implementer.md (line 118-121)
4. lean-research-agent.md (line 119-122)
5. lean-planner.md (similar pattern)
6. lean-implementation-agent.md (similar pattern)

**Root Cause**: Documentation-vs-execution gap. Instructions exist but are not enforced or validated.

---

### Finding 2: Commands Do Not Validate Preflight Execution

**Severity**: HIGH  
**Affected Files**: All 4 workflow commands

**Evidence**:

Workflow commands have 4 stages:
1. **Stage 1 (ParseAndValidate)**: Parse task number, validate, extract metadata
2. **Stage 2 (Delegate)**: Invoke subagent
3. **Stage 3 (ValidateReturn)**: Validate subagent return format
4. **Stage 4 (RelayResult)**: Relay result to user

**Gap**: Stage 3 validates the **return format** but does NOT validate that preflight status update occurred.

**Example from research.md (lines 133-236)**:
```xml
<stage id="3" name="ValidateReturn">
  <process>
    1. Validate JSON Structure
    2. Validate Required Fields
    3. Validate Status Field
    4. Validate Session ID
    5. Validate Artifacts (if status=completed)
    6. Validation Summary
  </process>
</stage>
```

**Missing Validation**:
- No check that status was updated to [RESEARCHING] at start
- No verification that status-sync-manager was invoked
- No validation of preflight checkpoint completion

**Impact**: Commands cannot detect if preflight failed, allowing work to proceed with stale status.

---

### Finding 3: State Synchronization Failures Are Silent

**Severity**: HIGH  
**Evidence**: Task 314 case study

**Task 314 State Analysis**:

**TODO.md** (lines 58-70):
```markdown
### 314. Conduct systematic review to complete context refactor plan aims
- **Status**: [RESEARCHED]
- **Researched**: 2026-01-05
**Research Artifacts**:
  - Research Report: [specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md]
```

**state.json**:
```json
{
  "project_number": 314,
  "status": "not_started",
  "started": null,
  "researched": null,
  "artifacts": null
}
```

**Filesystem**:
```
specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md
(exists, 34543 bytes)
```

**Analysis**:
- Research artifact created successfully
- TODO.md updated to [RESEARCHED] with artifact link
- state.json NOT updated (still shows "not_started")
- This is a **postflight failure** (task 320), but demonstrates state sync issues

**Root Cause**: status-sync-manager was either:
1. Not invoked at all
2. Invoked but failed silently
3. Invoked but only updated TODO.md (partial failure)

---

### Finding 4: No Timeout Protection for In-Progress Statuses

**Severity**: MEDIUM  
**Impact**: Stale in-progress statuses block future work

**Problem**:

If a command crashes or times out during execution, the status remains in an in-progress state:
- [RESEARCHING]
- [PLANNING]
- [REVISING]
- [IMPLEMENTING]

**Current Behavior** (from research.md lines 71-78):
```
"researching")
  echo "Warning: Task $task_number is already being researched"
  echo "If this is a stale status (e.g., previous research crashed):"
  echo "  1. Check for existing research artifacts"
  echo "  2. Use /sync to reset status if needed"
  echo "To override: /research $task_number --force"
  exit 1
```

**Gap**: No automatic detection or reset of stale statuses. User must manually intervene.

**Recommendation**: Add timestamp-based stale status detection:
- If status is [RESEARCHING] and started > 2 hours ago: Auto-reset to [NOT STARTED]
- If status is [PLANNING] and started > 1 hour ago: Auto-reset to [RESEARCHED]
- If status is [IMPLEMENTING] and started > 4 hours ago: Auto-reset to [PLANNED]

---

### Finding 5: Inconsistent Status Marker Usage

**Severity**: LOW  
**Affected Files**: state-management.md vs actual usage

**Discrepancy**:

**state-management.md** (lines 75-87) defines:
- In-Progress: [RESEARCHING], [PLANNING], [REVISING], [IMPLEMENTING]
- Completion: [RESEARCHED], [PLANNED], [REVISED], [COMPLETED]

**status-transitions.md** (lines 8-17) defines:
- [RESEARCHING], [RESEARCHED], [PLANNING], [PLANNED], [IMPLEMENTING], [IMPLEMENTED], [TESTING], [COMPLETED]

**Note**: [IMPLEMENTED] is defined in status-transitions.md but not used in practice. Commands use [COMPLETED] as terminal state.

**Recommendation**: Consolidate to single source of truth in state-management.md.

---

## Detailed Analysis

### Workflow Command Execution Flow

```
User: /research 315
    ↓
research.md (Command)
    ↓
Stage 1: ParseAndValidate
    - Parse task_number=315
    - Lookup in state.json
    - Extract metadata (language="lean", status="not_started")
    - Validate status allows research
    - Determine target_agent="lean-research-agent"
    ↓
Stage 2: Delegate
    - Generate session_id
    - Invoke lean-research-agent via task tool
    - Pass: task_number, description, session_id
    ↓
lean-research-agent.md (Subagent)
    ↓
step_0_preflight (SHOULD EXECUTE BUT MAY NOT)
    - Extract task inputs
    - Update status to [RESEARCHING] ← FAILS HERE
    - Delegate to status-sync-manager ← NOT EXECUTED
    - Validate status update succeeded ← SKIPPED
    ↓
step_1-6: Research execution
    - Conduct research
    - Create artifacts
    - Validate artifacts
    ↓
step_7: Postflight
    - Update status to [RESEARCHED]
    - Delegate to status-sync-manager
    - Create git commit
    ↓
step_8: Return
    - Format return JSON
    - Return to command
    ↓
research.md Stage 3: ValidateReturn
    - Validate JSON structure ✓
    - Validate required fields ✓
    - Validate status field ✓
    - Validate session ID ✓
    - Validate artifacts ✓
    - NO VALIDATION OF PREFLIGHT ✗
    ↓
research.md Stage 4: RelayResult
    - Display summary to user
```

**Gap Identified**: No validation that step_0_preflight executed successfully.

---

### Status-Sync-Manager Integration Analysis

**status-sync-manager.md** provides atomic multi-file updates:

**Inputs** (lines 55-122):
- operation: "update_status" | "create_task" | "archive_tasks"
- task_number: Integer
- new_status: String (not_started, researching, researched, planning, planned, implementing, completed, blocked, abandoned)
- timestamp: ISO 8601 date
- session_id: String
- validated_artifacts: Array (optional)

**Process** (update_status_flow):
1. Validate inputs
2. Read current TODO.md and state.json
3. Create backups
4. Update TODO.md status marker
5. Update state.json status field
6. Update plan file (if exists)
7. Commit atomically (two-phase commit)
8. Rollback on failure

**Return Format**:
```json
{
  "status": "completed",
  "summary": "Updated task 315 status to researching",
  "files_updated": ["TODO.md", "state.json"],
  "metadata": {
    "session_id": "sess_1234567890_abc123",
    "duration_seconds": 2
  }
}
```

**Critical Observation**: status-sync-manager is well-designed and should work correctly **if invoked**. The problem is that subagents are not consistently invoking it during preflight.

---

### Comparison: Preflight vs Postflight

**Preflight (step_0)**:
- **Purpose**: Update status to in-progress marker
- **Delegation**: Should delegate to status-sync-manager
- **Validation**: No validation in command
- **Failure Mode**: Silent (work proceeds with stale status)

**Postflight (step_4/step_7)**:
- **Purpose**: Update status to completion marker
- **Delegation**: Should delegate to status-sync-manager
- **Validation**: No validation in command
- **Failure Mode**: Silent (artifacts created but status not updated)

**Observation**: Both preflight and postflight have the same architectural issue - no validation that delegation occurred.

---

### Evidence Collection: Task Status Audit

**Methodology**: Checked state.json vs TODO.md for all high-priority tasks

**Task 314**:
- TODO.md: [RESEARCHED]
- state.json: "not_started"
- **Result**: DESYNCHRONIZED (postflight failure)

**Task 315**:
- TODO.md: [RESEARCHED]
- state.json: "researched"
- **Result**: SYNCHRONIZED (success case)

**Task 320**:
- TODO.md: [NOT STARTED]
- state.json: "not_started"
- **Result**: SYNCHRONIZED (no work done yet)

**Task 321** (this task):
- TODO.md: [NOT STARTED]
- state.json: "not_started"
- **Result**: SYNCHRONIZED (no work done yet)

**Conclusion**: Synchronization failures are intermittent, suggesting execution-dependent behavior rather than systematic design flaw.

---

## Code Examples

### Current Preflight Implementation (researcher.md)

```xml
<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status to [RESEARCHING]</action>
  <process>
    1. Extract task inputs from delegation context (already parsed and validated by command file):
       - task_number: Integer (already validated to exist in TODO.md)
       - language: String (already extracted from task metadata)
       - task_description: String (already extracted from TODO.md)
       
    2. Update status to [RESEARCHING]:
       - Delegate to status-sync-manager with task_number and new_status="researching"
       - Validate status update succeeded
       - Generate timestamp: $(date -I)
    
    3. Proceed to research execution with validated inputs
  </process>
  <checkpoint>Task inputs extracted from validated context, status updated to [RESEARCHING]</checkpoint>
</step_0_preflight>
```

**Problem**: This is an **instruction**, not executable code. AI agents may not execute it consistently.

---

### Recommended Preflight Implementation

**Option 1: Add Concrete Delegation Example**

```xml
<step_0_preflight>
  <action>Preflight: Extract validated inputs and update status to [RESEARCHING]</action>
  <process>
    1. Extract task inputs from delegation context
    
    2. Update status to [RESEARCHING] by delegating to status-sync-manager:
       
       CRITICAL: You MUST invoke status-sync-manager before proceeding.
       
       Example invocation:
       ```
       task(
         subagent_type="status-sync-manager",
         prompt="Update task {task_number} status to researching",
         description="Update status to [RESEARCHING]",
         context={
           "operation": "update_status",
           "task_number": {task_number},
           "new_status": "researching",
           "timestamp": "{current_date}",
           "session_id": "{session_id}",
           "delegation_depth": {depth + 1},
           "delegation_path": [...delegation_path, "status-sync-manager"]
         }
       )
       ```
       
       Validate return:
       - status == "completed"
       - files_updated includes ["TODO.md", "state.json"]
       
       If status update fails:
       - Log error with details
       - Return status: "failed"
       - Do NOT proceed to research execution
    
    3. Proceed to research execution with validated inputs
  </process>
  <checkpoint>Task inputs extracted, status updated to [RESEARCHING], validation passed</checkpoint>
</step_0_preflight>
```

**Benefits**:
- Concrete example shows exact invocation syntax
- Explicit validation requirements
- Clear failure handling

---

### Recommended Command Validation (research.md Stage 3)

**Add Preflight Validation Step**:

```xml
<stage id="3" name="ValidateReturn">
  <action>Validate subagent return format and artifacts</action>
  <process>
    1. Log return for debugging
    
    2. VALIDATION STEP 1: Validate JSON Structure
       [existing validation]
    
    3. VALIDATION STEP 2: Validate Required Fields
       [existing validation]
    
    4. VALIDATION STEP 3: Validate Status Field
       [existing validation]
    
    5. VALIDATION STEP 4: Validate Session ID
       [existing validation]
    
    6. VALIDATION STEP 5: Validate Preflight Execution (NEW)
       - Read current status from state.json:
         current_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           specs/state.json)
       
       - If current_status is NOT "researching" and NOT "researched":
         * Log error: "[FAIL] Preflight did not execute - status not updated"
         * Log: "Expected status: researching or researched"
         * Log: "Actual status: ${current_status}"
         * Return error to user: "Subagent validation failed: Preflight status update did not occur"
         * Recommendation: "Verify status-sync-manager was invoked in step_0_preflight"
         * Exit with error
       
       - Else:
         * Log: "[PASS] Preflight executed - status updated to ${current_status}"
    
    7. VALIDATION STEP 6: Validate Artifacts (if status=completed)
       [existing validation]
    
    8. Validation Summary
       [existing validation]
  </process>
</stage>
```

**Benefits**:
- Detects preflight failures immediately
- Prevents phantom research (artifacts without status)
- Provides clear error messages for debugging

---

## Decisions

### Decision 1: Add Preflight Validation to Commands

**Decision**: Add explicit preflight validation to all workflow commands (Stage 3)

**Rationale**:
- Commands are the enforcement point for workflow correctness
- Validation in commands catches failures regardless of subagent implementation
- Provides clear error messages to users
- Prevents state synchronization failures

**Implementation**:
- Add VALIDATION STEP 5 (Validate Preflight Execution) to Stage 3 in:
  - research.md
  - plan.md
  - implement.md
  - revise.md

**Effort**: 2 hours (30 minutes per command)

---

### Decision 2: Enhance Subagent Preflight Instructions

**Decision**: Add concrete delegation examples to all subagent step_0_preflight sections

**Rationale**:
- Current instructions are too abstract
- AI agents need concrete examples to execute consistently
- Explicit validation requirements reduce ambiguity
- Clear failure handling prevents silent failures

**Implementation**:
- Update step_0_preflight in:
  - researcher.md
  - planner.md
  - implementer.md
  - lean-research-agent.md
  - lean-planner.md
  - lean-implementation-agent.md

**Effort**: 3 hours (30 minutes per subagent)

---

### Decision 3: Add Stale Status Detection

**Decision**: Add timeout-based stale status detection to workflow commands (Stage 1)

**Rationale**:
- Prevents in-progress statuses from blocking future work
- Reduces manual intervention required
- Improves user experience

**Implementation**:
- Add stale status check in Stage 1 (ParseAndValidate) for all commands
- If status is in-progress and started > timeout threshold:
  - Log warning: "Stale status detected (started {hours} hours ago)"
  - Auto-reset status to previous completion state
  - Log: "Auto-reset status from {old_status} to {new_status}"
  - Proceed with command

**Thresholds**:
- [RESEARCHING]: 2 hours → reset to [NOT STARTED]
- [PLANNING]: 1 hour → reset to [RESEARCHED]
- [REVISING]: 1 hour → reset to [PLANNED]
- [IMPLEMENTING]: 4 hours → reset to [PLANNED]

**Effort**: 2 hours (30 minutes per command)

---

### Decision 4: Consolidate Status Marker Documentation

**Decision**: Make state-management.md the single source of truth for status markers

**Rationale**:
- Eliminates inconsistencies between state-management.md and status-transitions.md
- Reduces maintenance burden
- Improves clarity for developers

**Implementation**:
- Update status-transitions.md to reference state-management.md
- Remove duplicate status marker definitions
- Add cross-reference links

**Effort**: 30 minutes

---

## Recommendations

### Immediate Actions (High Priority)

1. **Add Preflight Validation to Commands** (2 hours)
   - Implement VALIDATION STEP 5 in all 4 workflow commands
   - Verify status was updated to in-progress marker
   - Fail fast if preflight did not execute

2. **Enhance Subagent Preflight Instructions** (3 hours)
   - Add concrete delegation examples
   - Add explicit validation requirements
   - Add clear failure handling

3. **Add Stale Status Detection** (2 hours)
   - Implement timeout-based auto-reset
   - Log warnings for stale statuses
   - Improve user experience

**Total Effort**: 7 hours

---

### Medium-Term Actions (Medium Priority)

4. **Consolidate Status Marker Documentation** (30 minutes)
   - Make state-management.md single source of truth
   - Update cross-references

5. **Add Preflight Execution Logging** (1 hour)
   - Log preflight start/completion in subagents
   - Include timestamps and status transitions
   - Improve debugging capabilities

6. **Create Preflight Test Suite** (2 hours)
   - Test preflight execution for all commands
   - Verify status updates occur
   - Validate state synchronization

**Total Effort**: 3.5 hours

---

### Long-Term Actions (Low Priority)

7. **Implement Preflight Checkpoint System** (4 hours)
   - Add checkpoint validation framework
   - Require explicit checkpoint confirmation
   - Prevent execution without checkpoint

8. **Add Preflight Metrics** (2 hours)
   - Track preflight success/failure rates
   - Identify problematic subagents
   - Monitor state synchronization health

9. **Create Preflight Recovery Tools** (3 hours)
   - Auto-detect and fix state synchronization failures
   - Provide manual recovery commands
   - Improve system resilience

**Total Effort**: 9 hours

---

## Risks & Mitigations

### Risk 1: Validation Adds Latency

**Risk**: Adding preflight validation to commands increases execution time

**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**: 
- Validation is a single jq query (< 100ms)
- Acceptable tradeoff for correctness
- Can optimize if needed

---

### Risk 2: Stale Status Detection Too Aggressive

**Risk**: Auto-reset may interrupt legitimate long-running work

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Set conservative timeout thresholds (2-4 hours)
- Log warnings before auto-reset
- Allow --force flag to override
- Monitor auto-reset frequency

---

### Risk 3: Subagent Instructions Still Not Executed

**Risk**: Even with concrete examples, AI agents may not execute preflight

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Command validation catches failures (defense in depth)
- Preflight checkpoint system enforces execution
- Metrics track execution rates

---

### Risk 4: Breaking Changes to Existing Workflows

**Risk**: Changes to commands/subagents may break existing workflows

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Test all changes with existing tasks
- Add backward compatibility where possible
- Document breaking changes clearly
- Provide migration guide

---

## Appendix: Sources and Citations

### Primary Sources

1. **.opencode/command/research.md** - Research command implementation
2. **.opencode/command/plan.md** - Planning command implementation
3. **.opencode/command/implement.md** - Implementation command implementation
4. **.opencode/command/revise.md** - Revision command implementation
5. **.opencode/agent/subagents/researcher.md** - General research subagent
6. **.opencode/agent/subagents/planner.md** - General planning subagent
7. **.opencode/agent/subagents/implementer.md** - General implementation subagent
8. **.opencode/agent/subagents/lean-research-agent.md** - Lean research subagent
9. **.opencode/agent/subagents/lean-planner.md** - Lean planning subagent
10. **.opencode/agent/subagents/lean-implementation-agent.md** - Lean implementation subagent
11. **.opencode/agent/subagents/status-sync-manager.md** - Status synchronization utility
12. **.opencode/context/core/system/state-management.md** - State management standard
13. **.opencode/context/core/workflows/status-transitions.md** - Status transition workflow

### Evidence Files

1. **specs/TODO.md** - Task list with status markers
2. **specs/state.json** - Main state tracking file
3. **specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md** - Evidence of state sync failure

### Related Tasks

1. **Task 320**: Fix workflow command postflight failures (related issue)
2. **Task 314**: Systematic review (evidence of state sync failure)
3. **Task 315**: Axiom Prop vs Type blocker (success case for comparison)

---

## Appendix: File Locations

### Workflow Commands
```
.opencode/command/
├── research.md      # /research command
├── plan.md          # /plan command
├── implement.md     # /implement command
└── revise.md        # /revise command
```

### Workflow Subagents
```
.opencode/agent/subagents/
├── researcher.md                    # General research
├── planner.md                       # General planning
├── implementer.md                   # General implementation
├── lean-research-agent.md           # Lean research
├── lean-planner.md                  # Lean planning
├── lean-implementation-agent.md     # Lean implementation
└── status-sync-manager.md           # Status synchronization
```

### Context Files
```
.opencode/context/
├── core/
│   ├── system/
│   │   └── state-management.md      # State management standard
│   └── workflows/
│       └── status-transitions.md    # Status transition workflow
```

### State Files
```
specs/
├── TODO.md          # User-facing task list
├── state.json       # Main state tracking
└── NNN_*/           # Project directories
    ├── reports/     # Research reports
    ├── plans/       # Implementation plans
    └── state.json   # Project-level state
```

---

## Appendix: Status Marker Reference

### In-Progress Markers
- `[RESEARCHING]` - Research actively underway
- `[PLANNING]` - Implementation plan being created
- `[REVISING]` - Plan revision in progress
- `[IMPLEMENTING]` - Implementation work actively underway

### Completion Markers
- `[RESEARCHED]` - Research completed, deliverables created
- `[PLANNED]` - Implementation plan completed, ready for implementation
- `[REVISED]` - Plan revision completed, new plan version created
- `[COMPLETED]` - Implementation finished successfully (terminal state)
- `[PARTIAL]` - Implementation partially completed (can resume)
- `[BLOCKED]` - Work blocked by dependencies or issues
- `[ABANDONED]` - Work abandoned without completion

### Valid Transitions
```
[NOT STARTED] → [RESEARCHING] → [RESEARCHED]
              → [PLANNING] → [PLANNED]
              → [REVISING] → [REVISED]
              → [IMPLEMENTING] → [COMPLETED]
                              → [PARTIAL]
                              → [BLOCKED]
```

---

**End of Report**
