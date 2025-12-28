# Analysis Report: Status Update Failure in /implement Command

**Project Number**: 207  
**Project Name**: fix_implement_status_updates  
**Type**: bugfix  
**Priority**: Critical  
**Language**: markdown  
**Created**: 2025-12-28  
**Author**: Orchestrator Agent  

---

## Executive Summary

Critical bug discovered during Task 193 implementation: The `/implement` command fails to update status markers in TODO.md, state.json, and plan files. This breaks task tracking consistency across the entire .opencode system. Root cause: The orchestrator treats command specification files as documentation rather than executable workflows, never invoking the status-sync-manager specialist responsible for atomic status updates.

**Impact**: All `/implement`, `/research`, `/plan`, and `/revise` commands leave files in stale states, breaking workflow state machines defined in status-markers.md.

**Severity**: CRITICAL - Affects core task management functionality.

---

## Problem Statement

### Observed Behavior

After running `/implement 193` which resulted in partial implementation:

1. **TODO.md** (line 47): Status remains `[PLANNED]`, expected `[IMPLEMENTING]` → `[PARTIAL]`
2. **state.json** (line 295): Status remains `"planned"`, expected `"implementing"` → `"partial"`
3. **Plan file** (line 34): Phase 1 status remains `[NOT STARTED]`, expected `[IN PROGRESS]` → `[PARTIAL]`
4. **No timestamps**: No `Started` or `Completed` timestamps added to any file

### Expected Behavior

According to `.opencode/command/implement.md` specification:

**Preflight Stage (Line 138-156)**:
```markdown
Mark task(s) [IMPLEMENTING] with Started timestamp
Update state.json: status = "implementing", started = "{YYYY-MM-DD}"

Atomic update via status-sync-manager:
  - TODO.md: [IMPLEMENTING], **Started**: {date}
  - state.json: status = "implementing", started = "{date}"
  - Plan file (if exists): Mark resuming phase [IN PROGRESS]
```

**Postflight Stage (Line 297-363)**:
```markdown
If status == "partial":
  a. Update TODO.md status to [PARTIAL]
  b. Add partial artifact links
  c. Update state.json: status = "partial"
  d. Update plan file (if exists):
     - Mark completed phases [COMPLETED]
     - Keep incomplete phases [NOT STARTED] or [IN PROGRESS]

Use status-sync-manager to atomically:
  - Update TODO.md: Add artifact links
  - Update TODO.md: Change status to [COMPLETED]
  - Update TODO.md: Add Completed timestamp
  - Update state.json: status = "completed"
  - Update state.json: completed timestamp
  - Update state.json: artifacts array
  - Update plan file: phase statuses
```

**Actual Behavior**: None of these updates occurred.

---

## Root Cause Analysis

### Investigation Process

1. **Examined Task 193 Files**:
   - TODO.md (lines 45-69): Status unchanged after /implement execution
   - state.json (lines 293-308): Status field unchanged
   - Plan file: Phase statuses unchanged
   - Implementation file (Truth.lean): Successfully modified with partial work

2. **Examined Command Specification**:
   - `.opencode/command/implement.md`: Fully specifies Preflight and Postflight stages
   - References `status-sync-manager` at lines 34, 152, 344, 438, 450
   - Documents atomic update requirements

3. **Examined Status Sync Manager**:
   - `.opencode/agent/subagents/status-sync-manager.md`: Fully implemented specialist
   - Provides two-phase commit protocol for atomic updates
   - Handles rollback on failure
   - Returns standardized format per subagent-return-format.md

4. **Examined Orchestrator**:
   - `.opencode/agent/orchestrator.md`: Routes commands to subagents
   - Tracks delegation with session IDs and depth tracking
   - Handles timeouts and errors
   - **DOES NOT execute command workflow stages**
   - **DOES NOT invoke status-sync-manager**

### Root Cause

**The orchestrator treats command specification files as documentation, not executable workflows.**

#### Architecture Gap

```
Current Architecture (BROKEN):

User: /implement 193
  ↓
Orchestrator:
  1. Load .opencode/command/implement.md
  2. Read specification (documentation only)
  3. Route directly to lean-implementation-agent
  4. Wait for implementation results
  5. Return results (no status updates)
  ↓
lean-implementation-agent:
  1. Implement the proof
  2. Return implementation artifacts
  3. NEVER updates status
  4. NEVER calls status-sync-manager
```

**Expected Architecture (CORRECT):**

```
User: /implement 193
  ↓
Orchestrator (or Command Executor):
  1. Load .opencode/command/implement.md
  2. EXECUTE Stage 1 Preflight:
     a. Invoke status-sync-manager
     b. Mark [IMPLEMENTING] atomically
  3. EXECUTE Stage 4 InvokeImplementer:
     a. Route to lean-implementation-agent
     b. Wait for results
  4. EXECUTE Stage 7 Postflight:
     a. Invoke status-sync-manager
     b. Mark final status atomically
     c. Add artifact links
  5. Return final results
  ↓
lean-implementation-agent:
  1. Implement the proof
  2. Return implementation artifacts
  3. Trust orchestrator for status updates
```

### Why This Happened

1. **Separation of Concerns**: Implementation agents (lean-implementation-agent, task-executor, implementer) focus solely on implementation logic, correctly delegating status management

2. **Missing Coordination Layer**: No agent/layer executes the multi-stage workflows defined in command specification files

3. **Specification vs Execution Gap**: Command files document workflows but don't trigger execution

4. **Orchestrator Design**: Orchestrator is designed for routing and delegation tracking, not workflow execution

### Evidence

**From `.opencode/agent/orchestrator.md` (lines 173-179)**:
```markdown
**For /implement command**:
- If has plan file:
  - If Language == "lean" → lean-implementation-agent
  - Else → task-executor (multi-phase)
- Else (no plan):
  - If Language == "lean" → lean-implementation-agent (simple mode)
  - Else → implementer (direct)
```

**Analysis**: Orchestrator only routes to implementation agents. No mention of:
- Calling status-sync-manager
- Executing Preflight/Postflight stages
- Reading workflow stages from command specs

**From lean-implementation-agent return** (Task 193):
- Implementation: Partial (helper lemma complete, main theorem blocked)
- Artifacts: Truth.lean modified (lines 625-688)
- Status updates: NONE (correctly not in agent's responsibility)

---

## Impact Analysis

### Affected Commands

All commands using status-sync-manager specification:

1. **`/implement`**: 
   - No [IMPLEMENTING] marker at start
   - No [COMPLETED]/[PARTIAL]/[BLOCKED] marker at end
   - No Started/Completed timestamps
   - No artifact links added to TODO.md

2. **`/research`**:
   - No [RESEARCHING] marker at start
   - No [RESEARCHED] marker at end
   - No research artifact links in TODO.md

3. **`/plan`**:
   - No [PLANNING] marker at start
   - No [PLANNED] marker at end
   - No plan artifact links in TODO.md

4. **`/revise`**:
   - No [REVISING] marker at start
   - No [REVISED] marker at end
   - No updated plan links in TODO.md

### Affected Files

1. **TODO.md**: Stale status markers, missing timestamps, missing artifact links
2. **state.json**: Stale status fields, missing timestamp fields
3. **Plan files**: Stale phase statuses, no execution tracking
4. **Project state.json**: Inconsistent with global state

### Workflow Impact

**Status Marker State Machine (from status-markers.md) is BROKEN:**

```
Specified Workflow:
[NOT STARTED] → [IMPLEMENTING] → [COMPLETED]
                       ↓
                  [PARTIAL] (timeout/incomplete)

Actual Workflow:
[NOT STARTED] → [NOT STARTED] (no change!)
```

### User Impact

1. **No Progress Tracking**: Users cannot see task progress in TODO.md
2. **Stale Information**: TODO.md shows old statuses despite work completion
3. **Manual Fixes Required**: Users must manually update TODO.md, state.json, plan files
4. **Broken Resume**: `/implement` resume logic depends on accurate plan phase statuses
5. **Inconsistent State**: Different files show different task statuses
6. **Lost Audit Trail**: No timestamps tracking when work started/completed

### System Impact

1. **State Inconsistency**: TODO.md ≠ state.json ≠ plan files
2. **Broken Dependencies**: Tasks depending on completion markers never trigger
3. **Broken Cleanup**: `/todo` command cannot identify completed tasks for cleanup
4. **Broken Metrics**: No way to track task duration, completion rates
5. **Broken Recovery**: Cannot identify partial work for resume operations

---

## Technical Details

### File Locations

**Command Specifications**:
- `/implement`: `.opencode/command/implement.md` (531 lines)
- `/research`: `.opencode/command/research.md`
- `/plan`: `.opencode/command/plan.md`
- `/revise`: `.opencode/command/revise.md`

**Orchestrator**:
- `.opencode/agent/orchestrator.md` (v2.0, Task 191 updates)

**Status Sync Manager**:
- `.opencode/agent/subagents/status-sync-manager.md` (341 lines, fully implemented)

**Status Markers Specification**:
- `.opencode/context/common/system/status-markers.md` (889 lines)

**Implementation Agents**:
- `.opencode/agent/subagents/lean-implementation-agent.md`
- `.opencode/agent/subagents/task-executor.md`
- `.opencode/agent/subagents/implementer.md`

### Code References

**implement.md Preflight Stage** (lines 122-163):
```markdown
<stage id="1" name="Preflight">
  <action>Validate task(s) and determine execution mode</action>
  <status_update>
    Atomic update via status-sync-manager:
      - TODO.md: [IMPLEMENTING], **Started**: {date}
      - state.json: status = "implementing", started = "{date}"
      - Plan file (if exists): Mark resuming phase [IN PROGRESS]
  </status_update>
</stage>
```

**implement.md Postflight Stage** (lines 297-364):
```markdown
<stage id="7" name="Postflight">
  <action>Update status, link artifacts, and commit</action>
  <atomic_update>
    Use status-sync-manager to atomically:
      - Update TODO.md: Add artifact links
      - Update TODO.md: Change status to [COMPLETED]
      - Update TODO.md: Add Completed timestamp
      - Update state.json: status = "completed"
      - Update state.json: completed timestamp
      - Update state.json: artifacts array
      - Update plan file: phase statuses
  </atomic_update>
</stage>
```

**status-sync-manager.md Interface** (lines 23-54):
```markdown
<inputs_required>
  <parameter name="task_number" type="integer">Task number to update</parameter>
  <parameter name="new_status" type="string">
    New status marker: not_started, in_progress, researched, planned, 
    blocked, abandoned, completed
  </parameter>
  <parameter name="timestamp" type="string">ISO 8601 date (YYYY-MM-DD)</parameter>
  <parameter name="session_id" type="string">Unique session identifier</parameter>
  <parameter name="delegation_depth" type="integer">Current delegation depth</parameter>
  <parameter name="delegation_path" type="array">Array of agent names</parameter>
  <parameter name="plan_path" type="string" optional="true">Path to plan file</parameter>
  <parameter name="artifact_links" type="array" optional="true">
    Artifact links to add to TODO.md
  </parameter>
</inputs_required>
```

**orchestrator.md Routing Logic** (lines 173-179):
```markdown
**For /implement command**:
- If has plan file:
  - If Language == "lean" → lean-implementation-agent
  - Else → task-executor (multi-phase)
- Else (no plan):
  - If Language == "lean" → lean-implementation-agent (simple mode)
  - Else → implementer (direct)
```

**Analysis**: No mention of status-sync-manager invocation.

### Status Sync Manager Capabilities

**Two-Phase Commit Protocol** (lines 63-133):

**Phase 1 (Prepare)**:
1. Read all target files into memory
2. Validate current status allows requested transition
3. Prepare all updates in memory
4. Validate all updates are well-formed
5. If any validation fails, abort (no files written)

**Phase 2 (Commit)**:
1. Write files in dependency order: TODO.md → state.json → project state → plan
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
4. All files updated or none updated (atomic guarantee)

**Rollback Mechanism** (lines 124-131):
```markdown
If any write fails:
1. Immediately stop further writes
2. Restore all previously written files from backups
3. Log error with details
4. Return failed status with rollback info
```

**This specialist is fully implemented and ready to use - it's just never invoked.**

---

## Proposed Solutions

### Solution A: Orchestrator Executes Command Workflows ✅ RECOMMENDED

**Description**: Extend orchestrator to execute workflow stages from command specifications.

**Implementation**:

1. **Add new orchestrator stage: ExecuteCommandPreflight** (after Stage 2, before Stage 3)
   - Load command specification workflow stages
   - Execute Preflight stage if defined
   - For `/implement`: Call status-sync-manager with `new_status="implementing"`
   - For `/research`: Call status-sync-manager with `new_status="researching"`
   - For `/plan`: Call status-sync-manager with `new_status="planning"`
   - For `/revise`: Call status-sync-manager with `new_status="revising"`

2. **Add new orchestrator stage: ExecuteCommandPostflight** (after Stage 9, before Stage 10)
   - Execute Postflight stage from command specification
   - Extract final status from implementation agent return
   - Call status-sync-manager with final status and artifact links
   - For `/implement`: `new_status="completed"|"partial"|"blocked"`
   - For `/research`: `new_status="researched"`
   - For `/plan`: `new_status="planned"`
   - For `/revise`: `new_status="revised"`

3. **Update orchestrator workflow**:
   ```
   Stage 1: AnalyzeRequest
   Stage 2: DetermineComplexity
   ★ Stage 2.5: ExecuteCommandPreflight (NEW)
   Stage 3: CheckLanguage
   Stage 4: PrepareRouting
   Stage 5: CheckCycleAndDepth
   Stage 6: RegisterDelegation
   Stage 7: RouteToAgent
   Stage 8: MonitorDelegation
   Stage 9: ReceiveResults
   ★ Stage 9.5: ExecuteCommandPostflight (NEW)
   Stage 10: ValidateReturn
   Stage 11: ProcessResults
   Stage 12: CleanupDelegation
   Stage 13: ReturnToUser
   ```

**Pros**:
- Single coordination point
- No new agents needed
- Minimal architectural changes
- Leverages existing status-sync-manager
- Command specs remain declarative

**Cons**:
- Orchestrator becomes more complex
- Orchestrator needs to parse command workflow stages

**Effort**: 4-6 hours
- 2 hours: Implement ExecuteCommandPreflight stage
- 2 hours: Implement ExecuteCommandPostflight stage
- 1 hour: Testing with all commands
- 1 hour: Documentation updates

---

### Solution B: Create Command Executor Subagents

**Description**: Create dedicated command executor subagents (implement-executor, research-executor, etc.) that orchestrate workflow stages.

**Implementation**:

1. **Create implement-executor.md subagent**:
   - Executes implement.md workflow stages
   - Calls status-sync-manager for Preflight
   - Delegates to implementation agents (lean-implementation-agent, task-executor, implementer)
   - Calls status-sync-manager for Postflight
   - Returns consolidated results

2. **Create similar executors**:
   - research-executor.md
   - plan-executor.md
   - revise-executor.md

3. **Update orchestrator routing**:
   ```markdown
   For /implement command:
   → implement-executor
   
   For /research command:
   → research-executor
   
   For /plan command:
   → plan-executor
   ```

4. **Each executor follows pattern**:
   ```
   1. Preflight: Call status-sync-manager (mark in-progress)
   2. Execute: Delegate to specialist (implementation, research, planning)
   3. Postflight: Call status-sync-manager (mark completed/partial/blocked)
   4. Return: Consolidated results
   ```

**Pros**:
- Clean separation of concerns
- Orchestrator remains simple (routing only)
- Command executors can be tested independently
- Follows existing delegation patterns

**Cons**:
- Additional delegation layer (depth increases)
- More agents to maintain
- Slightly more complex architecture

**Effort**: 8-10 hours
- 3 hours: Implement implement-executor
- 2 hours: Implement research-executor
- 2 hours: Implement plan-executor, revise-executor
- 2 hours: Update orchestrator routing
- 1 hour: Testing

---

### Solution C: Implementation Agents Handle Status ❌ NOT RECOMMENDED

**Description**: Modify implementation agents to call status-sync-manager directly.

**Implementation**:

1. Update lean-implementation-agent.md:
   - Add Preflight: Call status-sync-manager
   - Add Postflight: Call status-sync-manager

2. Update task-executor.md: Same pattern

3. Update implementer.md: Same pattern

4. Repeat for researcher, planner, etc.

**Pros**:
- Direct status updates
- No orchestrator changes

**Cons**:
- **Violates separation of concerns**: Implementation ≠ status tracking
- **Code duplication**: Every agent duplicates status logic
- **Inconsistent behavior**: Each agent may implement differently
- **Harder to maintain**: Changes require updating all agents
- **Tight coupling**: Implementation agents now depend on status system

**Effort**: 12-15 hours (high due to duplication)

**Recommendation**: **DO NOT PURSUE** - Architectural anti-pattern

---

## Recommended Solution

### Solution A: Orchestrator Executes Command Workflows

**Rationale**:
1. **Minimal Changes**: Extends existing orchestrator without new agents
2. **Single Coordination Point**: Orchestrator already manages delegation
3. **Leverages Existing Infrastructure**: status-sync-manager already implemented
4. **Declarative Command Specs**: Command files remain declarative
5. **Lower Effort**: 4-6 hours vs 8-10 hours (Solution B)
6. **Faster Deployment**: Fewer moving parts to test

**Implementation Priority**:
1. **Phase 1**: Implement ExecuteCommandPreflight and ExecuteCommandPostflight stages in orchestrator
2. **Phase 2**: Test with `/implement` command on Task 193
3. **Phase 3**: Extend to `/research`, `/plan`, `/revise` commands
4. **Phase 4**: Update documentation and examples

---

## Detailed Implementation Plan (Solution A)

### Phase 1: Orchestrator Updates (3 hours)

#### Task 1.1: Add ExecuteCommandPreflight Stage (1.5 hours)

**Location**: `.opencode/agent/orchestrator.md` (after Stage 2, before Stage 3)

**Add new stage**:
```markdown
### Stage 2.5: ExecuteCommandPreflight

**Action**: Execute command Preflight stage if defined

**Process**:
1. Check if command specification has Preflight stage
2. If not present: Skip to next stage
3. If present:
   a. Extract status update requirements
   b. Determine new_status based on command:
      - /implement → "implementing"
      - /research → "researching"
      - /plan → "planning"
      - /revise → "revising"
   c. Generate timestamp (YYYY-MM-DD)
   d. Invoke status-sync-manager via task_tool:
      - subagent_type: "status-sync-manager"
      - task_number: {task_number}
      - new_status: {new_status}
      - timestamp: {timestamp}
      - session_id: {current_session_id}
      - delegation_depth: {depth + 1}
      - delegation_path: {path + ["status-sync-manager"]}
      - plan_path: {plan_path if exists}
   e. Wait for status-sync-manager return
   f. Validate return format
   g. If failed: Log error, continue (degraded mode)

**Error Handling**:
- If status-sync-manager fails: Log warning, continue with implementation
- If status-sync-manager times out: Log warning, continue
- Status update failure is non-critical (implementation can proceed)

**Output**: Status update attempted, result logged
```

**Validation**:
- Test with `/implement 194` (next available task)
- Verify TODO.md gets [IMPLEMENTING] marker
- Verify state.json gets status="implementing"
- Verify Started timestamp added

#### Task 1.2: Add ExecuteCommandPostflight Stage (1.5 hours)

**Location**: `.opencode/agent/orchestrator.md` (after Stage 9, before Stage 10)

**Add new stage**:
```markdown
### Stage 9.5: ExecuteCommandPostflight

**Action**: Execute command Postflight stage if defined

**Process**:
1. Check if command specification has Postflight stage
2. If not present: Skip to next stage
3. If present:
   a. Extract implementation agent return
   b. Determine final status from return:
      - return.status == "completed" → new_status = "completed"
      - return.status == "partial" → new_status = "partial"
      - return.status == "failed" → new_status = "implementing" (keep in progress)
      - return.status == "blocked" → new_status = "blocked"
   c. Extract artifact links from return.artifacts
   d. Generate completion timestamp (YYYY-MM-DD)
   e. Invoke status-sync-manager via task_tool:
      - subagent_type: "status-sync-manager"
      - task_number: {task_number}
      - new_status: {final_status}
      - timestamp: {timestamp}
      - session_id: {current_session_id}
      - delegation_depth: {depth + 1}
      - delegation_path: {path + ["status-sync-manager"]}
      - plan_path: {plan_path if exists}
      - artifact_links: {artifact_links}
   f. Wait for status-sync-manager return
   g. Validate return format
   h. If failed: Log error, return with warning

**Command-Specific Status Mapping**:
- /implement: completed | partial | blocked | implementing
- /research: researched
- /plan: planned
- /revise: revised

**Error Handling**:
- If status-sync-manager fails: Return with warning about stale status
- If status-sync-manager times out: Return with warning
- Postflight failure should not fail overall command

**Output**: Final status update attempted, result included in return
```

**Validation**:
- Test with `/implement 194` completion
- Verify TODO.md gets [COMPLETED]/[PARTIAL] marker
- Verify state.json gets final status
- Verify Completed timestamp added
- Verify artifact links added to TODO.md

---

### Phase 2: Testing (2 hours)

#### Test 2.1: /implement Command (1 hour)

**Test Case 1: Simple Implementation (Success)**
- Create test task 195
- Run `/implement 195`
- Verify Preflight: [IMPLEMENTING] marker, Started timestamp
- Verify implementation completes
- Verify Postflight: [COMPLETED] marker, Completed timestamp, artifact links

**Test Case 2: Phased Implementation (Partial)**
- Create test task 196 with multi-phase plan
- Run `/implement 196`
- Simulate timeout after phase 1
- Verify Postflight: [PARTIAL] marker, phase 1 marked [COMPLETED]

**Test Case 3: Implementation Failure (Blocked)**
- Create test task 197 with blocking issue
- Run `/implement 197`
- Verify implementation encounters blocker
- Verify Postflight: [BLOCKED] marker, blocking reason added

#### Test 2.2: Other Commands (1 hour)

**Test /research**:
- Run `/research 198`
- Verify [RESEARCHING] → [RESEARCHED] transition
- Verify research artifacts linked

**Test /plan**:
- Run `/plan 198`
- Verify [PLANNING] → [PLANNED] transition
- Verify plan artifacts linked

**Test /revise**:
- Run `/revise 198`
- Verify [REVISING] → [REVISED] transition
- Verify updated plan linked

---

### Phase 3: Manual Fix for Task 193 (0.5 hours)

**Update TODO.md** (line 47):
```markdown
### 193. Prove is_valid_swap_involution theorem in Truth.lean (currently sorry)
- **Effort**: 2 hours
- **Status**: [PARTIAL]
- **Started**: 2025-12-28
- **Priority**: High
- **Language**: lean
```

**Update state.json** (line 295):
```json
{
  "project_number": 193,
  "title": "Prove is_valid_swap_involution theorem in Truth.lean (currently sorry)",
  "status": "partial",
  "started": "2025-12-28",
  "priority": "high",
  "language": "lean"
}
```

**Update plan file** (line 34):
```markdown
## Phase 1: Implement Helper Lemma and Update Main Theorem [PARTIAL]
(Started: 2025-12-28T16:00:00Z)

**Partial Completion Notes**:
- Helper lemma `truth_at_swap_swap` completed (lines 632-670)
- All 6 cases proven correctly
- Main theorem blocked by complex type theory interaction
- Files modified: Truth.lean (64 lines added)
```

---

### Phase 4: Documentation (0.5 hours)

**Update orchestrator.md**:
- Document new ExecuteCommandPreflight stage
- Document new ExecuteCommandPostflight stage
- Add examples of status-sync-manager invocation

**Update implement.md**:
- Add note that Preflight/Postflight executed by orchestrator
- Clarify status-sync-manager invocation pattern

**Update status-markers.md**:
- Confirm orchestrator handles all command status transitions
- Update workflow diagrams

---

## Success Criteria

### Functional Requirements

1. **Preflight Status Updates**:
   - [ ] `/implement` marks [IMPLEMENTING] at start
   - [ ] `/research` marks [RESEARCHING] at start
   - [ ] `/plan` marks [PLANNING] at start
   - [ ] `/revise` marks [REVISING] at start
   - [ ] Started timestamps added to TODO.md and state.json

2. **Postflight Status Updates**:
   - [ ] `/implement` marks final status ([COMPLETED]/[PARTIAL]/[BLOCKED])
   - [ ] `/research` marks [RESEARCHED] at completion
   - [ ] `/plan` marks [PLANNED] at completion
   - [ ] `/revise` marks [REVISED] at completion
   - [ ] Completed timestamps added to TODO.md and state.json

3. **Artifact Links**:
   - [ ] Implementation artifacts linked in TODO.md
   - [ ] Research artifacts linked in TODO.md
   - [ ] Plan artifacts linked in TODO.md
   - [ ] Revised plan artifacts linked in TODO.md

4. **Atomic Updates**:
   - [ ] All files update together (TODO.md + state.json + plan)
   - [ ] No inconsistent states
   - [ ] Rollback works on failure

5. **Error Handling**:
   - [ ] Status update failures don't block implementation
   - [ ] Warnings returned to user on status update failure
   - [ ] Graceful degradation (implementation proceeds even if status fails)

### Non-Functional Requirements

1. **Performance**:
   - [ ] Status updates add <2 seconds to command execution
   - [ ] No noticeable delay for users

2. **Reliability**:
   - [ ] Status updates succeed 99% of time
   - [ ] Rollback mechanism prevents inconsistent states
   - [ ] Error logging for debugging

3. **Maintainability**:
   - [ ] Clear separation: orchestrator handles status, agents handle work
   - [ ] Single invocation point for status-sync-manager
   - [ ] Easy to extend to new commands

---

## Risk Assessment

### High Risks

1. **Risk**: Orchestrator becomes too complex with workflow execution
   - **Likelihood**: Medium
   - **Impact**: Medium
   - **Mitigation**: Keep stage logic simple, delegate to status-sync-manager
   - **Contingency**: Fall back to Solution B (command executors)

2. **Risk**: Status update failures block implementation
   - **Likelihood**: Low
   - **Impact**: High
   - **Mitigation**: Make status updates non-critical, log warnings on failure
   - **Contingency**: Users can manually update status

### Medium Risks

3. **Risk**: Delegation depth increases (orchestrator → status-sync-manager)
   - **Likelihood**: High
   - **Impact**: Low
   - **Mitigation**: Already accounted for in max depth (3)
   - **Contingency**: None needed

4. **Risk**: Timeout handling becomes complex
   - **Likelihood**: Medium
   - **Impact**: Medium
   - **Mitigation**: Use short timeout for status-sync-manager (30s)
   - **Contingency**: Fail gracefully, continue with implementation

### Low Risks

5. **Risk**: Breaking existing workflows
   - **Likelihood**: Low
   - **Impact**: High
   - **Mitigation**: Thorough testing before deployment
   - **Contingency**: Git rollback

6. **Risk**: Documentation drift
   - **Likelihood**: Medium
   - **Impact**: Low
   - **Mitigation**: Update docs in same PR as code changes
   - **Contingency**: Documentation update sprint

---

## Dependencies

### Required Files

1. `.opencode/agent/orchestrator.md` (exists, needs updates)
2. `.opencode/agent/subagents/status-sync-manager.md` (exists, ready to use)
3. `.opencode/command/implement.md` (exists, specification complete)
4. `.opencode/command/research.md` (exists, specification complete)
5. `.opencode/command/plan.md` (exists, specification complete)
6. `.opencode/command/revise.md` (exists, specification complete)
7. `.opencode/context/common/system/status-markers.md` (exists, defines state machine)

### Required Tools

1. `task_tool` (exists, for invoking subagents)
2. `status-sync-manager` specialist (exists, fully implemented)
3. `edit` tool (exists, for updating orchestrator.md)
4. `read` tool (exists, for reading files)

### External Dependencies

None - all required components exist in codebase.

---

## Timeline Estimate

**Total Effort**: 6-7 hours

| Phase | Description | Effort | Dependencies |
|-------|-------------|--------|--------------|
| Phase 1.1 | Implement ExecuteCommandPreflight | 1.5 hours | None |
| Phase 1.2 | Implement ExecuteCommandPostflight | 1.5 hours | Phase 1.1 |
| Phase 2.1 | Test /implement command | 1 hour | Phase 1.2 |
| Phase 2.2 | Test other commands | 1 hour | Phase 2.1 |
| Phase 3 | Manual fix Task 193 | 0.5 hours | None (parallel) |
| Phase 4 | Documentation updates | 0.5 hours | Phase 2.2 |
| **Total** | **All phases** | **6 hours** | Sequential + 0.5h parallel |

**Critical Path**: Phase 1.1 → 1.2 → 2.1 → 2.2 → 4 (5.5 hours)  
**Parallel Work**: Phase 3 can run anytime (0.5 hours)

**Calendar Time**: 1 day (with breaks and testing)

---

## Rollback Plan

If implementation fails or causes issues:

### Immediate Rollback

1. **Revert orchestrator.md changes**:
   ```bash
   git checkout HEAD~1 .opencode/agent/orchestrator.md
   ```

2. **Manual status updates for affected tasks**:
   - Identify tasks with stale status
   - Update TODO.md, state.json, plan files manually
   - Document in rollback report

3. **Notify users**:
   - Status updates temporarily unavailable
   - Manual updates required
   - ETA for fix

### Graceful Degradation

If status-sync-manager fails:
- Log warning
- Continue with implementation
- Return results with warning about stale status
- User can manually update status

### Recovery

1. Investigate failure cause
2. Fix root issue (orchestrator or status-sync-manager)
3. Retest with isolated test cases
4. Redeploy with monitoring

---

## Testing Strategy

### Unit Tests (Conceptual)

1. **Test ExecuteCommandPreflight**:
   - Mock task_tool invocation
   - Verify status-sync-manager called with correct params
   - Verify error handling on failure
   - Verify graceful degradation

2. **Test ExecuteCommandPostflight**:
   - Mock implementation agent return
   - Verify final status determination
   - Verify artifact link extraction
   - Verify status-sync-manager called with correct params

### Integration Tests

1. **Test /implement flow**:
   - End-to-end test with real task
   - Verify Preflight → Implementation → Postflight
   - Verify file updates
   - Verify atomic updates

2. **Test all commands**:
   - /research, /plan, /revise, /implement
   - Verify status transitions
   - Verify artifact links
   - Verify timestamps

### Regression Tests

1. **Test existing functionality**:
   - Verify routing still works
   - Verify delegation tracking still works
   - Verify timeout handling still works
   - Verify error handling still works

### User Acceptance Tests

1. **Manual testing**:
   - Run `/implement` on real task
   - Verify user sees status changes in TODO.md
   - Verify timestamps are accurate
   - Verify artifact links work

---

## Monitoring and Validation

### Metrics to Track

1. **Status Update Success Rate**:
   - Target: 99% of status updates succeed
   - Monitor: Log status-sync-manager invocations and results
   - Alert: If success rate drops below 95%

2. **Status Update Latency**:
   - Target: <2 seconds for status updates
   - Monitor: Track status-sync-manager execution time
   - Alert: If latency exceeds 5 seconds

3. **File Consistency**:
   - Target: 100% consistency between TODO.md and state.json
   - Monitor: Periodic validation script
   - Alert: If inconsistencies detected

### Validation Checks

1. **Post-Deployment Validation**:
   - Run `/implement` on 5 test tasks
   - Verify all status updates work
   - Verify no regressions

2. **Weekly Validation**:
   - Audit TODO.md vs state.json consistency
   - Check for stale statuses
   - Review error logs

---

## Related Issues

### Upstream Issues

- **Task 191**: Subagent delegation hang (fixed with delegation registry, cycle detection, timeout enforcement)
  - Related: This bug shares similar coordination issues
  - Fixed: Delegation tracking, session IDs, timeouts
  - Remaining: Command workflow execution (this bug)

### Downstream Issues

- **Task 193**: Partial implementation (manually fix status after bug fix deployed)
- **All active tasks**: May have stale statuses (audit and fix after deployment)

### Similar Bugs

Search for other commands that may have same issue:
- `/review`: Does it update status?
- `/errors`: Does it update status?
- `/todo`: Does it update status correctly?

---

## Appendices

### Appendix A: File Diff Examples

**TODO.md (Expected Update)**:
```diff
### 193. Prove is_valid_swap_involution theorem in Truth.lean (currently sorry)
- **Effort**: 2 hours
- **Status**: [PLANNED]
+ **Status**: [PARTIAL]
- **Started**: 2025-12-28
- **Completed**: 2025-12-28
  **Priority**: High
```

**state.json (Expected Update)**:
```diff
{
  "project_number": 193,
  "title": "Prove is_valid_swap_involution theorem in Truth.lean (currently sorry)",
- "status": "planned",
+ "status": "partial",
  "started": "2025-12-28",
+ "completed": "2025-12-28",
  "priority": "high",
  "language": "lean"
}
```

**Plan file (Expected Update)**:
```diff
- ## Phase 1: Implement Helper Lemma and Update Main Theorem [NOT STARTED]
+ ## Phase 1: Implement Helper Lemma and Update Main Theorem [PARTIAL]
+ (Started: 2025-12-28T16:00:00Z)
+ 
+ **Partial Completion Notes**:
+ - Helper lemma `truth_at_swap_swap` completed (lines 632-670)
+ - All 6 cases proven correctly
+ - Main theorem blocked by complex type theory interaction
```

### Appendix B: Orchestrator Workflow (Current vs Proposed)

**Current Workflow**:
```
Stage 1: AnalyzeRequest
Stage 2: DetermineComplexity
Stage 3: CheckLanguage
Stage 4: PrepareRouting
Stage 5: CheckCycleAndDepth
Stage 6: RegisterDelegation
Stage 7: RouteToAgent          ← Implementation only
Stage 8: MonitorDelegation
Stage 9: ReceiveResults
Stage 10: ValidateReturn
Stage 11: ProcessResults
Stage 12: CleanupDelegation
Stage 13: ReturnToUser
```

**Proposed Workflow**:
```
Stage 1: AnalyzeRequest
Stage 2: DetermineComplexity
★ Stage 2.5: ExecuteCommandPreflight  ← NEW: Status update
Stage 3: CheckLanguage
Stage 4: PrepareRouting
Stage 5: CheckCycleAndDepth
Stage 6: RegisterDelegation
Stage 7: RouteToAgent
Stage 8: MonitorDelegation
Stage 9: ReceiveResults
★ Stage 9.5: ExecuteCommandPostflight ← NEW: Status update
Stage 10: ValidateReturn
Stage 11: ProcessResults
Stage 12: CleanupDelegation
Stage 13: ReturnToUser
```

### Appendix C: status-sync-manager Invocation Example

**Preflight Invocation**:
```javascript
task_tool({
  subagent_type: "status-sync-manager",
  prompt: `Update task 193 status to implementing.
  
Task Number: 193
New Status: implementing
Timestamp: 2025-12-28
Session ID: sess_1703779200_a1b2c3
Plan Path: .opencode/specs/193_prove_is_valid_swap_involution/plans/implementation-001.md
  `,
  session_id: "sess_1703779200_a1b2c3",
  delegation_depth: 1,
  delegation_path: ["orchestrator", "implement", "status-sync-manager"]
})
```

**Postflight Invocation**:
```javascript
task_tool({
  subagent_type: "status-sync-manager",
  prompt: `Update task 193 status to partial with artifact links.
  
Task Number: 193
New Status: partial
Timestamp: 2025-12-28
Session ID: sess_1703779200_a1b2c3
Plan Path: .opencode/specs/193_prove_is_valid_swap_involution/plans/implementation-001.md
Artifact Links:
  - Implementation: Logos/Core/Semantics/Truth.lean (lines 625-688)
  - Summary: .opencode/specs/193_prove_is_valid_swap_involution/summaries/implementation-summary.md
  `,
  session_id: "sess_1703779200_a1b2c3",
  delegation_depth: 1,
  delegation_path: ["orchestrator", "implement", "status-sync-manager"]
})
```

---

## Conclusion

This critical bug affects all command workflows in the .opencode system. The root cause is clear: the orchestrator treats command specifications as documentation rather than executable workflows. The recommended solution (Solution A) extends the orchestrator with two new stages to execute Preflight and Postflight operations, leveraging the existing status-sync-manager specialist.

Implementation is straightforward (6-7 hours), low-risk (graceful degradation on failure), and provides immediate value by restoring status tracking consistency across the entire system.

**Recommended Next Steps**:
1. Create Task 207 in TODO.md to track this bug fix
2. Implement Solution A following the detailed plan
3. Test with Task 193 and new test tasks
4. Deploy and monitor for issues
5. Audit and fix stale statuses in existing tasks

---

**Report Status**: COMPLETE  
**Created**: 2025-12-28  
**Last Updated**: 2025-12-28  
**Author**: Orchestrator Agent  
**Reviewers**: (Pending user review)
