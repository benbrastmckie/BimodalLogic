# Workflow Command Refactoring Plan

## Executive Summary

**Problem**: The `/research 317` command demonstrates a critical architectural flaw where the orchestrator correctly identifies the need for preflight/postflight stages but then delegates the entire workflow (including status management) to the subagent. This causes:

1. **Preflight not executing**: Status doesn't update to `[RESEARCHING]` before work begins
2. **Postflight not executing**: Artifacts aren't linked and status doesn't update to `[RESEARCHED]` after completion
3. **Responsibility confusion**: Commands describe preflight/postflight but delegate execution to subagents

**Root Cause**: Architectural mismatch between command specifications (which define preflight/postflight stages) and actual execution (which delegates everything to subagents who may or may not implement these stages correctly).

**Impact**: All four workflow commands (`/research`, `/plan`, `/revise`, `/implement`) suffer from this issue, causing:
- Manual fixes required (as seen with Task 326)
- State synchronization failures between TODO.md and state.json
- Inconsistent status tracking
- Missing artifact links

## Problem Analysis

### Current Architecture (Broken)

```
/research 317
    ↓
orchestrator.md (Stage 1: ParseAndValidate)
    ↓
research.md command (Stages 1-4 defined but not executed)
    Stage 1: ParseAndValidate ✓ (executes)
    Stage 1.5: Preflight ✗ (documented but NOT executed)
    Stage 2: Delegate → lean-research-agent
    Stage 3: ValidateReturn ✗ (not executed)
    Stage 3.5: Postflight ✗ (documented but NOT executed)
    Stage 4: RelayResult ✗ (not executed)
    ↓
lean-research-agent.md (receives full delegation)
    step_0_preflight: Attempts status update (may fail)
    step_1-5: Does research work
    step_6: Attempts postflight (may fail)
    Returns to command
    ↓
Command relays result to user WITHOUT executing Stages 3-4
```

### What Should Happen

```
/research 317
    ↓
orchestrator.md (Stage 1: ParseAndValidate)
    ↓
research.md command (ALL stages execute)
    Stage 1: ParseAndValidate ✓
    Stage 1.5: Preflight ✓ (COMMAND executes via status-sync-manager)
    Stage 2: Delegate → lean-research-agent (WORK ONLY, no status management)
    Stage 3: ValidateReturn ✓ (COMMAND validates)
    Stage 3.5: Postflight ✓ (COMMAND executes via status-sync-manager)
    Stage 4: RelayResult ✓ (COMMAND relays)
    ↓
lean-research-agent.md (receives work-only delegation)
    step_1: Determine research strategy
    step_2: Analyze research topic
    step_3: Conduct research
    step_4: Synthesize findings
    step_5: Create research report
    Returns artifacts to command
    ↓
Command executes postflight and relays result
```

## Detailed Problem Breakdown

### Issue 1: Preflight Responsibility Confusion

**Current State**:
- `research.md` Stage 1.5 documents preflight requirements
- `research.md` Stage 2 delegates to `lean-research-agent`
- `lean-research-agent.md` step_0_preflight attempts to update status
- **Result**: Preflight may or may not execute depending on subagent implementation

**Evidence from `/research 317`**:
```
Perfect! Task 317 is a Lean task with status "not_started". 
According to the research command workflow, I need to:

1. Stage 1 (ParseAndValidate): ✓ Task validated
2. Stage 1.5 (Preflight): Update status to RESEARCHING via status-sync-manager
3. Stage 2 (Delegate): Delegate to lean-research-agent
```

The orchestrator **knows** it should execute preflight, but then it delegates everything to the subagent instead.

### Issue 2: Postflight Responsibility Confusion

**Current State**:
- `research.md` Stage 3.5 documents postflight requirements
- `lean-research-agent.md` step_6 attempts postflight
- **Result**: Postflight may or may not execute, artifacts may not link

**Evidence from `/research 317`**:
```
Research Completed for Task 317
Status: ✓ Completed
Research Report: .opencode/specs/317_bfs_variant_phase3/reports/research-001.md
```

But checking TODO.md and state.json shows:
- Status still shows `[NOT STARTED]` (should be `[RESEARCHED]`)
- No artifact link in TODO.md
- state.json may or may not be updated

### Issue 3: Validation Stage Not Executing

**Current State**:
- `research.md` Stage 3 documents validation requirements
- Commands delegate and then immediately relay results
- **Result**: No validation of subagent returns

**What's Missing**:
- JSON structure validation
- Required fields validation
- Status field validation
- Session ID validation
- Artifact existence validation (CRITICAL - prevents phantom research)

### Issue 4: Inconsistent Subagent Implementations

**Current State**:
- `lean-research-agent.md` has step_0_preflight and step_6_postflight
- `researcher.md` may have different implementation
- `planner.md` may have different implementation
- **Result**: Inconsistent behavior across workflow commands

## Systematic Solution

### Principle 1: Commands Own Workflow Orchestration

**Commands are responsible for**:
- Preflight (status updates before work)
- Delegation (passing work to subagents)
- Validation (verifying subagent returns)
- Postflight (status updates and artifact linking after work)
- Result relay (presenting results to user)

**Subagents are responsible for**:
- Domain-specific work ONLY
- Creating artifacts
- Returning standardized JSON with artifact paths
- NO status management
- NO file system updates outside their artifact directory

### Principle 2: Separation of Concerns

**Status Management**: Commands delegate to `status-sync-manager`
- Preflight: Update status to `[RESEARCHING]`, `[PLANNING]`, `[IMPLEMENTING]`, `[REVISING]`
- Postflight: Update status to `[RESEARCHED]`, `[PLANNED]`, `[COMPLETED]`, `[REVISED]`
- Atomic updates to both TODO.md and state.json
- Two-phase commit protocol

**Work Execution**: Commands delegate to domain specialists
- Research: `lean-research-agent`, `researcher`
- Planning: `lean-planner`, `planner`
- Implementation: `lean-implementation-agent`, `implementer`
- Revision: `task-reviser`, `lean-planner`, `planner`

**Validation**: Commands execute validation logic
- JSON structure validation
- Required fields validation
- Artifact existence validation
- Session ID validation

### Principle 3: Standardized Return Format

All subagents MUST return:
```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief summary of work completed",
  "artifacts": [
    {
      "type": "research|plan|implementation|revision",
      "path": "relative/path/to/artifact.md",
      "created": "2026-01-07T12:00:00Z",
      "summary": "Brief description"
    }
  ],
  "metadata": {
    "session_id": "sess_1234567890_abc123",
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "next_steps": "Optional next steps or recommendations",
  "errors": [
    {
      "type": "error_type",
      "message": "Error description",
      "recommendation": "How to fix"
    }
  ]
}
```

## Implementation Plan

### Phase 1: Refactor `/research` Command (2-3 hours)

**Goal**: Make `/research` command execute all stages, delegate only work to subagents

**Files to Modify**:
1. `.opencode/command/research.md`
2. `.opencode/agent/subagents/lean-research-agent.md`
3. `.opencode/agent/subagents/researcher.md`

**Changes to `research.md`**:

1. **Stage 1.5 (Preflight)**: Make it ACTUALLY execute
   ```markdown
   <stage id="1.5" name="Preflight">
     <action>Update status to [RESEARCHING] before delegating to researcher</action>
     <process>
       CRITICAL: This stage MUST complete BEFORE Stage 2 (Delegate) begins.
       
       1. Generate session_id for tracking
       2. INVOKE status-sync-manager via task tool (NOT via subagent)
       3. Validate status-sync-manager return
       4. Verify status was actually updated (defense in depth)
       5. Log preflight success
       6. ONLY THEN proceed to Stage 2
     </process>
   </stage>
   ```

2. **Stage 2 (Delegate)**: Pass work-only context
   ```markdown
   <stage id="2" name="Delegate">
     <action>Delegate WORK ONLY to researcher (no status management)</action>
     <process>
       1. Prepare work context (task description, research focus)
       2. Invoke target agent via task tool
       3. Pass session_id for tracking
       4. DO NOT pass status management responsibilities
       5. Wait for researcher to complete and capture return
     </process>
   </stage>
   ```

3. **Stage 3 (ValidateReturn)**: Make it ACTUALLY execute
   ```markdown
   <stage id="3" name="ValidateReturn">
     <action>Validate subagent return format and artifacts</action>
     <process>
       1. Validate JSON structure
       2. Validate required fields
       3. Validate status field
       4. Validate session ID
       5. Validate artifacts (CRITICAL - prevents phantom research)
          a. Check artifacts array is non-empty (if status=completed)
          b. Verify each artifact exists on disk
          c. Verify each artifact is non-empty
       6. Log validation success
     </process>
   </stage>
   ```

4. **Stage 3.5 (Postflight)**: Make it ACTUALLY execute
   ```markdown
   <stage id="3.5" name="Postflight">
     <action>Update status to [RESEARCHED], link artifacts, create git commit</action>
     <process>
       CRITICAL: This stage ensures artifacts are linked and status is updated.
       
       1. Extract artifacts from subagent return
       2. Validate artifacts exist on disk (CRITICAL)
       3. INVOKE status-sync-manager to update status and link artifacts
       4. Validate status-sync-manager return
       5. Verify status and artifact links were actually updated
       6. INVOKE git-workflow-manager to create commit
       7. Log postflight success
     </process>
   </stage>
   ```

**Changes to `lean-research-agent.md`**:

1. **Remove step_0_preflight**: Command handles this
2. **Remove step_6_postflight**: Command handles this
3. **Simplify to work-only steps**:
   - step_1: Determine research strategy
   - step_2: Analyze research topic
   - step_3: Conduct research
   - step_4: Synthesize findings
   - step_5: Create research report
   - Return standardized JSON

**Changes to `researcher.md`**:
- Same as `lean-research-agent.md`
- Remove preflight/postflight
- Focus on research work only

**Testing**:
1. Run `/research 317` and verify:
   - Status updates to `[RESEARCHING]` immediately
   - Research work completes
   - Status updates to `[RESEARCHED]` after completion
   - Artifact link appears in TODO.md
   - state.json is updated correctly
   - Git commit is created

### Phase 2: Refactor `/plan` Command (2-3 hours)

**Goal**: Make `/plan` command execute all stages, delegate only work to subagents

**Files to Modify**:
1. `.opencode/command/plan.md`
2. `.opencode/agent/subagents/lean-planner.md`
3. `.opencode/agent/subagents/planner.md`

**Changes**: Same pattern as Phase 1
- Stage 1.5: Preflight (update to `[PLANNING]`)
- Stage 2: Delegate work only
- Stage 3: Validate return
- Stage 3.5: Postflight (update to `[PLANNED]`, link plan)
- Stage 4: Relay result

**Subagent Changes**:
- Remove preflight/postflight from `lean-planner.md` and `planner.md`
- Focus on planning work only
- Return standardized JSON with plan artifact

**Testing**:
1. Run `/plan <task>` and verify all stages execute correctly

### Phase 3: Refactor `/revise` Command (2-3 hours)

**Goal**: Make `/revise` command execute all stages, delegate only work to subagents

**Files to Modify**:
1. `.opencode/command/revise.md`
2. `.opencode/agent/subagents/task-reviser.md`
3. `.opencode/agent/subagents/lean-planner.md` (revision mode)
4. `.opencode/agent/subagents/planner.md` (revision mode)

**Changes**: Same pattern as Phase 1
- Stage 1.5: Preflight (update to `[REVISING]`)
- Stage 2: Delegate work only (to task-reviser or planner based on plan presence)
- Stage 3: Validate return
- Stage 3.5: Postflight (update to `[REVISED]`, link revised plan)
- Stage 4: Relay result

**Subagent Changes**:
- Remove preflight/postflight from all revision subagents
- Focus on revision work only
- Return standardized JSON with revised artifact

**Testing**:
1. Run `/revise <task>` (no plan) and verify task-only revision
2. Run `/revise <task>` (plan exists) and verify plan revision

### Phase 4: Refactor `/implement` Command (2-3 hours)

**Goal**: Make `/implement` command execute all stages, delegate only work to subagents

**Files to Modify**:
1. `.opencode/command/implement.md`
2. `.opencode/agent/subagents/lean-implementation-agent.md`
3. `.opencode/agent/subagents/implementer.md`

**Changes**: Same pattern as Phase 1
- Stage 1.5: Preflight (update to `[IMPLEMENTING]`)
- Stage 2: Delegate work only
- Stage 3: Validate return
- Stage 3.5: Postflight (update to `[COMPLETED]`, link implementation)
- Stage 4: Relay result

**Subagent Changes**:
- Remove preflight/postflight from implementation subagents
- Focus on implementation work only
- Return standardized JSON with implementation artifacts

**Testing**:
1. Run `/implement <task>` and verify all stages execute correctly

### Phase 5: Create Shared Validation Module (1-2 hours)

**Goal**: Eliminate duplication by creating shared validation logic

**Files to Create**:
1. `.opencode/context/core/orchestration/subagent-validation.md`

**Content**:
```markdown
# Subagent Return Validation

## Standard Validation Process

All workflow commands MUST validate subagent returns using this process:

### Step 1: Validate JSON Structure
- Parse return as JSON using jq
- If parsing fails: Return error "Cannot parse return as JSON"

### Step 2: Validate Required Fields
- Check required fields exist: status, summary, artifacts, metadata
- Check metadata subfields: session_id, agent_type, delegation_depth, delegation_path
- If any field missing: Return error "Missing required field: {field}"

### Step 3: Validate Status Field
- Extract status from return
- Check status is valid enum: completed, partial, failed, blocked
- If status invalid: Return error "Invalid status: {status}"

### Step 4: Validate Session ID
- Extract returned session_id
- Compare with expected session_id
- If mismatch: Return error "Session ID mismatch"

### Step 5: Validate Artifacts (CRITICAL)
- If status == "completed":
  a. Check artifacts array is non-empty
  b. Verify each artifact exists on disk
  c. Verify each artifact is non-empty
- If any check fails: Return error with specific failure

### Step 6: Log Validation Success
- Log: "[PASS] Return validation succeeded"
- Log: "Status: {status}"
- Log: "Artifacts: {artifact_count} validated"
```

**Files to Modify**:
1. `.opencode/command/research.md` - Reference shared validation
2. `.opencode/command/plan.md` - Reference shared validation
3. `.opencode/command/revise.md` - Reference shared validation
4. `.opencode/command/implement.md` - Reference shared validation

### Phase 6: Create Shared Preflight/Postflight Modules (1-2 hours)

**Goal**: Eliminate duplication by creating shared preflight/postflight logic

**Files to Create**:
1. `.opencode/context/core/orchestration/preflight-pattern.md`
2. `.opencode/context/core/orchestration/postflight-pattern.md`

**Content for `preflight-pattern.md`**:
```markdown
# Preflight Pattern

## Standard Preflight Process

All workflow commands MUST execute preflight using this process:

1. Generate session_id for tracking
2. Delegate to status-sync-manager to update status
3. Validate status-sync-manager return
4. Verify status was actually updated (defense in depth)
5. Log preflight success
6. Proceed to delegation stage

## Implementation Template

[Detailed template with all steps]
```

**Content for `postflight-pattern.md`**:
```markdown
# Postflight Pattern

## Standard Postflight Process

All workflow commands MUST execute postflight using this process:

1. Extract artifacts from subagent return
2. Validate artifacts exist on disk (CRITICAL)
3. Delegate to status-sync-manager to update status and link artifacts
4. Validate status-sync-manager return
5. Verify status and artifact links were actually updated
6. Delegate to git-workflow-manager to create commit
7. Log postflight success

## Implementation Template

[Detailed template with all steps]
```

**Files to Modify**:
1. `.opencode/command/research.md` - Reference shared preflight/postflight
2. `.opencode/command/plan.md` - Reference shared preflight/postflight
3. `.opencode/command/revise.md` - Reference shared preflight/postflight
4. `.opencode/command/implement.md` - Reference shared preflight/postflight

### Phase 7: Update Documentation (1 hour)

**Files to Update**:
1. `.opencode/context/core/orchestration/delegation.md` - Update delegation patterns
2. `.opencode/context/core/orchestration/state-management.md` - Clarify responsibilities
3. `.opencode/context/core/standards/subagent-return-format.md` - Standardize return format
4. `.opencode/AGENTS.md` - Update agent responsibilities

**Key Documentation Updates**:
- Commands own workflow orchestration
- Subagents own domain-specific work
- Status management delegated to status-sync-manager
- Validation is mandatory
- Preflight/postflight are mandatory

### Phase 8: Comprehensive Testing (2-3 hours)

**Test Suite**:

1. **Test `/research` command**:
   - Run on Lean task
   - Run on general task
   - Verify preflight executes
   - Verify postflight executes
   - Verify artifact linking
   - Verify status updates

2. **Test `/plan` command**:
   - Run on researched task
   - Verify preflight executes
   - Verify postflight executes
   - Verify plan linking
   - Verify status updates

3. **Test `/revise` command**:
   - Run on task without plan (task-only revision)
   - Run on task with plan (plan revision)
   - Verify preflight executes
   - Verify postflight executes
   - Verify artifact linking
   - Verify status updates

4. **Test `/implement` command**:
   - Run on planned task
   - Verify preflight executes
   - Verify postflight executes
   - Verify implementation linking
   - Verify status updates to COMPLETED

5. **Test error handling**:
   - Test with invalid task numbers
   - Test with missing artifacts
   - Test with invalid status
   - Verify graceful error handling

6. **Test state synchronization**:
   - Verify TODO.md and state.json stay in sync
   - Verify no manual fixes needed
   - Verify atomic updates

## Success Criteria

### Functional Requirements

1. **Preflight Executes**: Status updates to `[RESEARCHING]`, `[PLANNING]`, `[IMPLEMENTING]`, `[REVISING]` BEFORE work begins
2. **Work Executes**: Subagents complete domain-specific work and return artifacts
3. **Validation Executes**: Commands validate subagent returns before postflight
4. **Postflight Executes**: Status updates to final state and artifacts are linked AFTER work completes
5. **State Synchronization**: TODO.md and state.json stay in sync automatically
6. **No Manual Fixes**: No manual intervention required (unlike Task 326)

### Non-Functional Requirements

1. **Consistency**: All four workflow commands follow the same pattern
2. **Maintainability**: Shared validation/preflight/postflight modules reduce duplication
3. **Clarity**: Clear separation of concerns between commands and subagents
4. **Robustness**: Defense-in-depth validation prevents phantom work
5. **Traceability**: Session IDs enable tracking across delegation chain

## Risks and Mitigations

### Risk 1: Breaking Existing Workflows

**Mitigation**:
- Implement changes incrementally (one command at a time)
- Test thoroughly after each phase
- Keep backups of original files
- Document rollback procedure

### Risk 2: Subagent Compatibility

**Mitigation**:
- Update subagents in same phase as commands
- Ensure return format is standardized
- Test with both Lean and general tasks

### Risk 3: Status-Sync-Manager Failures

**Mitigation**:
- Add defense-in-depth verification
- Log all status-sync-manager invocations
- Provide clear error messages
- Document recovery procedures

## Rollback Plan

If issues arise during implementation:

1. **Immediate Rollback**: Restore original command files from backup
2. **Partial Rollback**: Keep completed phases, rollback problematic phase
3. **Investigation**: Analyze logs to identify root cause
4. **Fix Forward**: Address issues and continue implementation

## Timeline

- **Phase 1**: 2-3 hours (refactor `/research`)
- **Phase 2**: 2-3 hours (refactor `/plan`)
- **Phase 3**: 2-3 hours (refactor `/revise`)
- **Phase 4**: 2-3 hours (refactor `/implement`)
- **Phase 5**: 1-2 hours (shared validation module)
- **Phase 6**: 1-2 hours (shared preflight/postflight modules)
- **Phase 7**: 1 hour (documentation)
- **Phase 8**: 2-3 hours (comprehensive testing)

**Total**: 14-20 hours

## Conclusion

This refactoring plan addresses the root cause of preflight/postflight failures by:

1. **Clarifying Responsibilities**: Commands own workflow orchestration, subagents own work
2. **Enforcing Execution**: Commands MUST execute all stages, not just document them
3. **Standardizing Returns**: All subagents return the same JSON format
4. **Validating Rigorously**: Commands validate before postflight to prevent phantom work
5. **Eliminating Duplication**: Shared modules reduce complexity and improve maintainability

The result will be a robust, consistent workflow system where:
- Status updates happen reliably
- Artifacts are linked automatically
- State stays synchronized
- No manual fixes are needed
- All four workflow commands behave consistently

This systematic approach avoids needless complexity while addressing the core architectural issues that caused the problems observed with `/research 317` and Task 326.
