# Research Report: Status Synchronization Audit for /plan, /research, /revise, and /task Commands

**Project**: #168
**Date**: 2025-12-24
**Research Type**: Implementation Audit

## Executive Summary

This audit examined status synchronization behavior across four critical commands (/plan, /research, /revise, /task) to verify compliance with status-markers.md and state-schema.md standards. The analysis reveals **significant gaps in atomicity guarantees** and **incomplete status synchronization** across TODO.md, state.json, and plan files.

**Key Findings**:
1. **Preflight status updates are documented but atomicity is not enforced** - Commands specify setting [IN PROGRESS] in TODO.md and state.json, but lack explicit atomic update mechanisms
2. **Postflight status updates vary by command** - /research and /plan use command-specific markers ([RESEARCHED], [PLANNED]) correctly, but /revise lacks clear postflight status updates
3. **Plan file status synchronization is inconsistent** - Only /task explicitly mentions updating plan headers and phases; /plan and /research do not specify plan status updates
4. **batch-status-manager only handles TODO.md** - Does not update state.json or plan files, creating potential for divergence
5. **Lazy directory creation is well-specified** - All commands correctly defer directory creation until artifact write time

## Research Question

Audit the four commands to verify they correctly update TODO.md and state.json status markers atomically according to status-markers.md and state-schema.md standards.

## Sources Consulted

- Command specifications: plan.md, research.md, revise.md, task.md
- Agent specifications: planner.md, researcher.md, task-executor.md, batch-task-orchestrator.md
- Specialist specification: batch-status-manager.md
- Standards: status-markers.md, state-schema.md

## Detailed Findings

### 1. Preflight Status Updates

#### /plan Command (plan.md)

**Documented Behavior**:
- Stage 1 (Preflight): "Otherwise set TODO status to [IN PROGRESS] with **Started** date; set state status to `in_progress` before routing."
- Line 55: "4. Otherwise set TODO status to [IN PROGRESS] with **Started** date; set state status to `in_progress` before routing."

**Atomicity Analysis**:
- **Gap**: No explicit mechanism for atomic updates across TODO.md and state.json
- **Gap**: Does not mention updating linked plan file status if plan already exists
- **Compliance**: Correctly specifies [IN PROGRESS] marker and **Started** timestamp per status-markers.md
- **Risk**: TODO.md and state.json could diverge if one update fails

#### /research Command (research.md)

**Documented Behavior**:
- Stage 1 (Preflight): "4. Otherwise set TODO to [IN PROGRESS] with **Started** date and state to `in_progress` before routing."
- Line 53: "4. Otherwise set TODO to [IN PROGRESS] with **Started** date and state to `in_progress` before routing."

**Atomicity Analysis**:
- **Gap**: No explicit mechanism for atomic updates
- **Gap**: Does not mention plan file updates
- **Compliance**: Correctly specifies [IN PROGRESS] marker and **Started** timestamp
- **Risk**: TODO.md and state.json could diverge

#### /revise Command (revise.md)

**Documented Behavior**:
- Stage 1 (Preflight): "5. Otherwise set TODO status to [IN PROGRESS] with **Started** date; state to `in_progress` if task-bound."
- Line 53: "5. Otherwise set TODO status to [IN PROGRESS] with **Started** date; state to `in_progress` if task-bound."

**Atomicity Analysis**:
- **Gap**: Conditional state update ("if task-bound") creates inconsistency risk
- **Gap**: No explicit atomic update mechanism
- **Compliance**: Correctly specifies [IN PROGRESS] marker and **Started** timestamp
- **Risk**: TODO.md and state.json could diverge; conditional logic adds complexity

#### /task Command (task.md)

**Documented Behavior**:
- Stage 2 (ResolveTasks): "3. Pre-flight: atomically set TODO status to [IN PROGRESS] with **Started** date and, when a plan link exists, set the plan header + first active phase to [IN PROGRESS] with (Started: ISO8601); set state to `in_progress` with started_at in the same batch. No dirs created."
- Line 67: "atomically set TODO status to [IN PROGRESS]"

**Atomicity Analysis**:
- **Strength**: Explicitly specifies "atomically" for status updates
- **Strength**: Includes plan file updates when plan link exists
- **Strength**: Specifies "same batch" for TODO/plan/state updates
- **Compliance**: Correctly specifies [IN PROGRESS] marker, **Started** timestamp, and ISO8601 format for plans
- **Implementation Gap**: Relies on delegated agents (task-executor, batch-task-orchestrator) to implement atomicity

**task-executor.md Analysis**:
- Stage 1 (MarkTaskInProgress): "5. Update task status atomically with linked plan/state when present"
- Line 63-68: Specifies atomic updates across TODO/plan/state
- **Gap**: Implementation details not specified - how is atomicity achieved?
- **Gap**: Lines 985-990 specify "single batch per transition" but mechanism unclear

**batch-task-orchestrator.md Analysis**:
- Uses batch-status-manager for TODO.md updates
- Line 542: "must>Always update TODO.md atomically via batch-status-manager and keep plan/state parity per task"
- **Gap**: batch-status-manager only handles TODO.md (see specialist analysis below)

### 2. Postflight Status Updates

#### /plan Command (plan.md)

**Documented Behavior**:
- Stage 4 (Postflight): "1. When not `--dry-run`, mark TODO and state to `[PLANNED]` with **Completed** date; add plan link and brief summary; keep metadata intact."
- Line 79: "mark TODO and state to `[PLANNED]` with **Completed** date"

**Atomicity Analysis**:
- **Compliance**: Correctly uses [PLANNED] marker per status-markers.md lines 163-183
- **Compliance**: Includes **Completed** timestamp
- **Gap**: No explicit atomic update mechanism
- **Gap**: Does not mention updating plan file status (plan header should be marked [PLANNED])
- **Risk**: TODO.md, state.json, and plan file could diverge

#### /research Command (research.md)

**Documented Behavior**:
- Stage 3 (Postflight): "1. When not `--dry-run`, mark TODO and state to `[RESEARCHED]` with **Completed** date; add research link and brief summary; preserve metadata."
- Line 69: "mark TODO and state to `[RESEARCHED]` with **Completed** date"

**Atomicity Analysis**:
- **Compliance**: Correctly uses [RESEARCHED] marker per status-markers.md lines 163-183
- **Compliance**: Includes **Completed** timestamp
- **Gap**: No explicit atomic update mechanism
- **Gap**: Does not mention updating research report status
- **Risk**: TODO.md and state.json could diverge

#### /revise Command (revise.md)

**Documented Behavior**:
- Stage 3 (Postflight): "2. Update TODO task to point to the new plan version; keep metadata intact."
- Line 69: "Update TODO task to point to the new plan version"

**Atomicity Analysis**:
- **Critical Gap**: Does not specify status marker update
- **Critical Gap**: Does not specify state.json update
- **Critical Gap**: Does not specify whether task status should change (remain [PLANNED]? move to [IN PROGRESS]?)
- **Ambiguity**: Unclear if revision resets status or preserves it
- **Risk**: Status markers could become stale or incorrect after revision

#### /task Command (task.md)

**Documented Behavior**:
- Stage 4 (Postflight): "1. Update plan phases/status markers when used, keeping TODO/plan/state status fields in lockstep"
- Line 81: "keeping TODO/plan/state status fields in lockstep"
- Line 82: "2. Update TODO with status markers (`[IN PROGRESS]` → `[COMPLETED]`), timestamps, and artifact links in the same atomic write batch as plan/state"

**Atomicity Analysis**:
- **Strength**: Explicitly specifies "lockstep" synchronization
- **Strength**: Specifies "same atomic write batch"
- **Strength**: Includes plan phase updates
- **Compliance**: Correctly uses [COMPLETED] marker and **Completed** timestamp
- **Implementation Gap**: Relies on delegated agents to implement atomicity

**task-executor.md Analysis**:
- Stage 9 (MarkTaskComplete): "3. Update task status using status-markers.md, atomically with plan/state"
- Lines 510-515: Specifies atomic updates across TODO/plan/state
- **Gap**: Implementation mechanism not specified

### 3. State Schema Compliance

#### TODO.md Status Values

**status-markers.md Specification** (lines 236-248):
```markdown
### 63. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [NOT STARTED]
**Priority**: Medium
```

**Lifecycle** (lines 244-248):
1. Created: `[NOT STARTED]`
2. Work begins: `[IN PROGRESS]` + `**Started**: YYYY-MM-DD`
3. Work completes: `[COMPLETED]` + `**Completed**: YYYY-MM-DD` + [PASS] to title
4. Or blocked: `[BLOCKED]` + `**Blocked**: YYYY-MM-DD` + `**Blocking Reason**: {reason}`
5. Or abandoned: `[ABANDONED]` + `**Abandoned**: YYYY-MM-DD` + `**Abandonment Reason**: {reason}`

**Command Compliance**:
- **/plan**: [PASS] Uses [IN PROGRESS] → [PLANNED] with timestamps
- **/research**: [PASS] Uses [IN PROGRESS] → [RESEARCHED] with timestamps
- **/revise**: [FAIL] Does not specify status updates
- **/task**: [PASS] Uses [IN PROGRESS] → [COMPLETED] with timestamps

#### state.json Status Values

**status-markers.md Specification** (lines 287-317):
```json
{
  "tasks": {
    "63": {
      "status": "completed",
      "started": "2025-12-19",
      "completed": "2025-12-20"
    },
    "64": {
      "status": "in_progress",
      "started": "2025-12-20"
    }
  }
}
```

**Status Values** (lines 309-317):
- `not_started`
- `in_progress`
- `researched`
- `planned`
- `blocked`
- `abandoned`
- `completed`

**Command Compliance**:
- **/plan**: [PASS] Uses `in_progress` → `planned` (lines 55, 79 in plan.md)
- **/research**: [PASS] Uses `in_progress` → `researched` (lines 53, 69 in research.md)
- **/revise**: [FAIL] Does not specify state.json updates
- **/task**: [PASS] Uses `in_progress` → `completed` (lines 67, 82 in task.md)

#### Timestamp Fields

**state-schema.md Specification** (lines 283-291):
```
All timestamps use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`
```

**status-markers.md Specification**:
- TODO.md: `YYYY-MM-DD` (lines 323-330)
- Implementation Plans: `YYYY-MM-DDTHH:MM:SSZ` (lines 333-340)
- State Files: `YYYY-MM-DD` (lines 343-350)

**Command Compliance**:
- **/plan**: [PASS] Specifies YYYY-MM-DD for TODO.md (line 55)
- **/research**: [PASS] Specifies YYYY-MM-DD for TODO.md (line 53)
- **/revise**: [FAIL] Does not specify timestamp updates
- **/task**: [PASS] Specifies YYYY-MM-DD for TODO.md, ISO8601 for plans (line 67)

**Missing Timestamp Fields**:
- **state.json**: Commands do not explicitly specify `started_at` and `completed_at` fields
- **Gap**: state-schema.md uses `started`/`completed` (lines 293-294) but task.md line 67 mentions `started_at`
- **Inconsistency**: Field naming mismatch between specification and implementation

### 4. Atomicity Analysis

#### Current Atomic Update Mechanisms

**batch-status-manager.md** (specialist):
- **Scope**: TODO.md only (lines 1-552)
- **Method**: Read entire file, modify in memory, write entire file (lines 179-203)
- **Operations**: mark_in_progress, mark_complete, mark_abandoned, mark_blocked (line 33)
- **Atomicity**: Single atomic write per file (line 181)
- **Limitation**: Does not handle state.json or plan files

**task-executor.md**:
- Lines 63-68: "Update task status atomically with linked plan/state when present"
- Lines 985-990: "Atomic writes: Read entire TODO.md (and linked plan/state when present) into memory, make all modifications in memory as a single batch per transition, write each touched file back in a single operation"
- **Strength**: Specifies atomic updates across multiple files
- **Gap**: Implementation mechanism not specified - how are multiple files updated atomically?

**batch-task-orchestrator.md**:
- Line 542: "Always update TODO.md atomically via batch-status-manager and keep plan/state parity per task"
- **Gap**: Delegates to batch-status-manager which only handles TODO.md
- **Gap**: "keep plan/state parity" is aspirational but not implemented

#### Atomicity Gaps

1. **No Multi-File Atomic Update Mechanism**:
   - batch-status-manager only handles TODO.md
   - No specialist for atomic state.json updates
   - No specialist for atomic plan file updates
   - **Risk**: Files can diverge if one update succeeds and another fails

2. **No Transaction Semantics**:
   - No rollback mechanism if partial update fails
   - No two-phase commit or similar protocol
   - **Risk**: Inconsistent state if process crashes mid-update

3. **No Explicit Ordering**:
   - Commands do not specify update order (TODO.md first? state.json first?)
   - **Risk**: Race conditions if multiple processes update simultaneously

4. **No Locking Mechanism**:
   - batch-status-manager mentions "optional, filesystem-dependent" locking (line 202)
   - No explicit file locking strategy
   - **Risk**: Concurrent updates could corrupt files

#### Recommended Atomic Update Strategy

**Option 1: Extend batch-status-manager**
- Add state.json update capability
- Add plan file update capability
- Implement multi-file atomic updates with rollback
- Use file locking to prevent concurrent updates

**Option 2: Create status-sync-manager Specialist**
- New specialist for atomic TODO/state/plan synchronization
- Implements two-phase commit protocol
- Handles rollback on partial failure
- Provides transaction semantics

**Option 3: Event-Driven Updates**
- Commands emit status change events
- Central status manager consumes events and updates files
- Ensures consistent ordering and atomicity
- More complex but more robust

### 5. Lazy Directory Creation Compliance

All commands correctly specify lazy directory creation:

#### /plan Command (plan.md)
- Line 62: "derive slug and plan project root; if `--dry-run`, preview slug only; otherwise create root + reports/ only when writing artifacts (lazy creation)"
- Line 94: "Create project root and plans/ only when emitting the plan"
- **Compliance**: [PASS] Correct

#### /research Command (research.md)
- Line 60: "Derive slug and plan project root; if `--dry-run`, preview slug only; otherwise create root + reports/ only when writing artifacts (lazy creation)"
- Line 84: "Create project root/reports/ only when writing research artifacts"
- **Compliance**: [PASS] Correct

#### /revise Command (revise.md)
- Line 15: `creates_root_on: never (reuses existing plans/)`
- Line 84: "No new project roots; only create the new plan file in existing plans/ subdir"
- **Compliance**: [PASS] Correct

#### /task Command (task.md)
- Line 22: `creates_root_on: "Only when delegated agent writes first artifact"`
- Line 96: "Derive slug `specs/NNN_slug/`; create project root/subdir only when writing an artifact"
- **Compliance**: [PASS] Correct

**task-executor.md**:
- Lines 229-251: Stage 4 (CreateProjectDirectory) with lazy creation
- Line 235: "Lazily create directory: specs/NNN_task_name/ **only immediately before writing the first artifact**"
- Line 249: "If execution only updates TODO/status markers with no artifacts, **skip directory creation entirely**"
- **Compliance**: [PASS] Correct

**batch-task-orchestrator.md**:
- Line 543: "Preserve lazy directory creation: never create project roots/subdirs unless a delegated execution writes an artifact"
- **Compliance**: [PASS] Correct

### 6. Current Implementation Analysis

#### Command Flow Analysis

**Flow 1: /plan {task_number}**
```
1. Preflight (plan.md stage 1):
   - Set TODO.md: [NOT STARTED] → [IN PROGRESS] + **Started**
   - Set state.json: status = "in_progress", started = "YYYY-MM-DD"
   - Mechanism: Not specified (gap)

2. CreatePlan (plan.md stage 3):
   - Delegate to @subagents/planner
   - planner.md creates plan file with [NOT STARTED] phases
   - Plan header status: Not specified (gap)

3. Postflight (plan.md stage 4):
   - Set TODO.md: [IN PROGRESS] → [PLANNED] + **Completed**
   - Set state.json: status = "planned", completed = "YYYY-MM-DD"
   - Update plan file: Not specified (gap)
   - Mechanism: Not specified (gap)
```

**Flow 2: /research {task_number}**
```
1. Preflight (research.md stage 1):
   - Set TODO.md: [NOT STARTED] → [IN PROGRESS] + **Started**
   - Set state.json: status = "in_progress", started = "YYYY-MM-DD"
   - Mechanism: Not specified (gap)

2. Research (research.md stage 2):
   - Delegate to @subagents/researcher
   - researcher.md creates research report
   - Report status: Not applicable

3. Postflight (research.md stage 3):
   - Set TODO.md: [IN PROGRESS] → [RESEARCHED] + **Completed**
   - Set state.json: status = "researched", completed = "YYYY-MM-DD"
   - Mechanism: Not specified (gap)
```

**Flow 3: /revise {task_number} {prompt}**
```
1. Preflight (revise.md stage 1):
   - Set TODO.md: [PLANNED] → [IN PROGRESS] + **Started**
   - Set state.json: status = "in_progress", started = "YYYY-MM-DD"
   - Mechanism: Not specified (gap)

2. CreateRevision (revise.md stage 2):
   - Create new plan version (implementation-{N+1}.md)
   - New plan phases: [NOT STARTED]
   - Old plan status: Unchanged

3. Postflight (revise.md stage 3):
   - Update TODO.md: Point to new plan version
   - Status update: Not specified (critical gap)
   - State.json update: Not specified (critical gap)
   - Mechanism: Not specified (gap)
```

**Flow 4: /task {task_number}**
```
1. Preflight (task.md stage 2):
   - Set TODO.md: [NOT STARTED] → [IN PROGRESS] + **Started**
   - Set plan header: [NOT STARTED] → [IN PROGRESS] + (Started: ISO8601)
   - Set plan first phase: [NOT STARTED] → [IN PROGRESS] + (Started: ISO8601)
   - Set state.json: status = "in_progress", started_at = "YYYY-MM-DD"
   - Mechanism: "atomically" via task-executor (lines 67-68)

2. Execute (task.md stage 3):
   - Delegate to appropriate agent (implementer, documenter, etc.)
   - Agent produces artifacts
   - Lazy directory creation enforced

3. Postflight (task.md stage 4):
   - Set TODO.md: [IN PROGRESS] → [COMPLETED] + **Completed**
   - Set plan header: [IN PROGRESS] → [COMPLETED] + (Completed: ISO8601)
   - Set plan phases: [IN PROGRESS] → [COMPLETED] + (Completed: ISO8601)
   - Set state.json: status = "completed", completed_at = "YYYY-MM-DD"
   - Mechanism: "lockstep" via task-executor (lines 81-82)
```

#### Agent Implementation Analysis

**planner.md**:
- Stage 6 (UpdateState): "Update project state with new plan version"
- Line 267: "Update project state with new plan version"
- **Gap**: Does not specify updating TODO.md or global state.json
- **Gap**: Does not specify updating plan file status markers
- **Delegation**: Relies on orchestrator (plan.md) for status updates

**researcher.md**:
- Stage 5 (UpdateState): "Update project and global state"
- Lines 199-205: Updates project state.json and global state.json
- **Gap**: Does not specify updating TODO.md
- **Gap**: Does not specify status markers
- **Delegation**: Relies on orchestrator (research.md) for status updates

**task-executor.md**:
- Stage 1 (MarkTaskInProgress): Specifies atomic TODO/plan/state updates
- Stage 9 (MarkTaskComplete): Specifies atomic TODO/plan/state updates
- **Strength**: Explicitly mentions atomicity and plan file updates
- **Gap**: Implementation mechanism not specified
- **Gap**: Lines 985-990 describe atomic writes but no code/specialist reference

**batch-task-orchestrator.md**:
- Uses batch-status-manager for TODO.md updates
- Line 542: "keep plan/state parity per task"
- **Gap**: batch-status-manager only handles TODO.md
- **Gap**: No mechanism for plan/state updates

**batch-status-manager.md**:
- Scope: TODO.md only
- Operations: mark_in_progress, mark_complete, mark_abandoned, mark_blocked
- Atomicity: Single file atomic write
- **Limitation**: Does not handle state.json or plan files
- **Gap**: Cannot provide multi-file atomicity

### 7. Gap Analysis Summary

#### Critical Gaps

1. **No Multi-File Atomic Update Mechanism**
   - Commands specify atomic updates but no implementation exists
   - batch-status-manager only handles TODO.md
   - Risk: Files can diverge

2. **/revise Command Missing Postflight Status Updates**
   - Does not specify TODO.md status update
   - Does not specify state.json update
   - Ambiguous whether status should change
   - Risk: Stale status markers after revision

3. **Plan File Status Updates Inconsistent**
   - /task specifies plan header/phase updates
   - /plan does not specify plan file status updates
   - /research does not apply (no plan file)
   - /revise does not specify plan file status updates
   - Risk: Plan files out of sync with TODO.md

4. **state.json Field Naming Inconsistency**
   - state-schema.md uses `started`/`completed`
   - task.md line 67 uses `started_at`/`completed_at`
   - Risk: Implementation may use wrong field names

#### Moderate Gaps

5. **No Explicit Atomic Update Implementation**
   - task-executor.md describes atomic writes (lines 985-990)
   - No specialist or code reference provided
   - Risk: Implementation may not be atomic

6. **No Rollback Mechanism**
   - No transaction semantics
   - No two-phase commit
   - Risk: Partial updates leave inconsistent state

7. **No File Locking Strategy**
   - batch-status-manager mentions optional locking
   - No explicit locking protocol
   - Risk: Concurrent updates could corrupt files

8. **Conditional State Updates**
   - /revise: "state to `in_progress` if task-bound"
   - Adds complexity and inconsistency risk
   - Risk: State updates may be skipped incorrectly

#### Minor Gaps

9. **Timestamp Format Inconsistency**
   - TODO.md: YYYY-MM-DD
   - Plans: YYYY-MM-DDTHH:MM:SSZ
   - state.json: YYYY-MM-DD (per state-schema.md) but ISO 8601 mentioned
   - Risk: Timestamp parsing errors

10. **Missing Timestamp Fields in Commands**
    - Commands do not explicitly specify all timestamp fields
    - state.json should have `started`/`completed` but not always mentioned
    - Risk: Missing timestamps in state.json

### 8. Recommendations

#### Immediate Actions (High Priority)

1. **Create Multi-File Status Sync Specialist**
   - New specialist: `status-sync-manager.md`
   - Capabilities:
     - Atomic updates across TODO.md, state.json, and plan files
     - Transaction semantics with rollback
     - File locking to prevent concurrent updates
     - Validation of status transitions
   - Replace batch-status-manager usage with status-sync-manager

2. **Fix /revise Command Postflight**
   - Add explicit status update specification
   - Clarify whether status should change or remain [PLANNED]
   - Add state.json update specification
   - Add plan file status update specification

3. **Standardize Plan File Status Updates**
   - /plan should update plan header to [PLANNED] on completion
   - /revise should update new plan header to [NOT STARTED]
   - All commands should use status-sync-manager for plan updates

4. **Fix state.json Field Naming**
   - Standardize on `started`/`completed` (per state-schema.md)
   - Update task.md line 67 to use correct field names
   - Update all command specifications

#### Short-Term Actions (Medium Priority)

5. **Implement Atomic Update Protocol**
   - Document multi-file atomic update algorithm
   - Implement in status-sync-manager specialist
   - Add rollback mechanism for partial failures
   - Add file locking strategy

6. **Add Validation Checks**
   - Pre-update: Validate status transitions
   - Post-update: Verify all files updated successfully
   - Detect and report divergence

7. **Standardize Timestamp Handling**
   - Document timestamp format per file type
   - Ensure all commands specify all required timestamps
   - Add timestamp validation

8. **Remove Conditional State Updates**
   - /revise: Always update state.json (remove "if task-bound")
   - Simplify logic and reduce inconsistency risk

#### Long-Term Actions (Low Priority)

9. **Add Integration Tests**
   - Test atomic updates across TODO.md, state.json, plan files
   - Test rollback on partial failure
   - Test concurrent update handling

10. **Add Monitoring and Alerting**
    - Detect file divergence
    - Alert on failed status updates
    - Track status update success rate

11. **Consider Event-Driven Architecture**
    - Commands emit status change events
    - Central status manager consumes events
    - Ensures consistent ordering and atomicity

## Lazy Creation Compliance Check

All commands correctly implement lazy directory creation:

- **/plan**: [PASS] Creates project root + plans/ only when writing plan artifact
- **/research**: [PASS] Creates project root + reports/ only when writing research artifact
- **/revise**: [PASS] Never creates project root (reuses existing plans/)
- **/task**: [PASS] Creates project root + subdirs only when delegated agent writes artifact

**Compliance**: 100% - All commands correctly defer directory creation until artifact write time.

## Conclusion

The audit reveals **significant gaps in status synchronization atomicity** across the four commands. While all commands correctly specify the status markers and timestamps per status-markers.md, **none have a robust implementation for atomic multi-file updates**. The batch-status-manager specialist only handles TODO.md, leaving state.json and plan files vulnerable to divergence.

**Most Critical Issues**:
1. No multi-file atomic update mechanism
2. /revise command missing postflight status updates
3. Plan file status updates inconsistent across commands
4. state.json field naming inconsistency

**Recommended Priority**:
1. Create status-sync-manager specialist for multi-file atomic updates
2. Fix /revise command postflight specification
3. Standardize plan file status updates across all commands
4. Fix state.json field naming inconsistency

Implementing these recommendations will ensure robust, atomic status synchronization across TODO.md, state.json, and plan files, preventing divergence and maintaining consistency per status-markers.md and state-schema.md standards.
