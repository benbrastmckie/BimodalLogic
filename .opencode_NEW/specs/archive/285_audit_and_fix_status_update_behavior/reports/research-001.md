# Research Report: Audit and Fix Status Update Behavior in Workflow Commands

**Task**: 285 - Audit and fix status update behavior in /research, /plan, /revise, and /implement commands  
**Started**: 2026-01-04  
**Completed**: 2026-01-04  
**Effort**: 1.5 hours  
**Priority**: High  
**Dependencies**: Task 283 (completed)  
**Sources/Inputs**: 
- .opencode/agent/subagents/researcher.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/implementer.md
- .opencode/agent/subagents/lean-research-agent.md
- .opencode/agent/subagents/lean-implementation-agent.md
- .opencode/agent/subagents/lean-planner.md
- .opencode/command/research.md
- .opencode/command/plan.md
- .opencode/command/implement.md
- .opencode/command/revise.md
- .opencode/context/core/system/state-management.md
- specs/283_fix_systematic_status_synchronization_failure/reports/research-001.md
- specs/283_fix_systematic_status_synchronization_failure/summaries/implementation-summary-20260104.md

**Artifacts**: 
- specs/285_audit_and_fix_status_update_behavior/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research audits the status update behavior across all workflow commands (/research, /plan, /revise, /implement) following the fix implemented in Task 283. The audit reveals that **Task 283 successfully fixed the naming inconsistency for general-purpose subagents** (researcher, planner, implementer) by standardizing them to use `<step_0_preflight>` naming. However, **Lean-specific subagents** (lean-research-agent, lean-implementation-agent, lean-planner) were NOT updated and still use inconsistent naming patterns.

**Key Findings**:
1. **General subagents (FIXED)**: researcher.md, planner.md, implementer.md all use `<step_0_preflight>` consistently
2. **Lean subagents (NOT FIXED)**: lean-research-agent.md, lean-implementation-agent.md, lean-planner.md use `<step_1>` instead of `<step_0_preflight>`
3. **Commands are correct**: All four commands (/research, /plan, /revise, /implement) properly delegate to subagents via orchestrator
4. **State-management.md is correct**: Defines proper two-phase status update pattern

**Recommendation**: Extend Task 283 fix to Lean-specific subagents by standardizing their naming to `<step_0_preflight>` pattern. This is a straightforward naming change that will ensure consistent status update behavior across ALL workflow commands, regardless of language.

## Context & Scope

### Problem Statement

Task 285 was created to audit and fix status update behavior in workflow commands after Task 259 (/research 259) failed to update status to [RESEARCHING] before work began. This violated the two-phase status update pattern defined in state-management.md.

**Evidence from Task Description**:
- `/research 259` invoked lean-research-agent successfully
- Task 259 status remained `[NOT STARTED]` during research execution
- Expected: Status should change to `[RESEARCHING]` at start, `[RESEARCHED]` at completion
- Actual: Status never updated during or after execution

### Task 283 Context

Task 283 (completed 2026-01-04) discovered and fixed a critical naming inconsistency:
- **Root Cause**: researcher.md used `<stage_1_preflight>` while planner.md and implementer.md used `<step_0_preflight>`
- **Fix**: Renamed researcher.md stages to use `<step_0_preflight>` naming (matching planner/implementer)
- **Rationale**: Explicit "step_0" numbering signals to Claude that preflight MUST execute BEFORE the main workflow
- **Result**: General-purpose workflow commands now have consistent status update behavior

### Scope of This Research

This research investigates:
1. Whether Task 283 fix was complete (did it cover all subagents?)
2. Current status update behavior in all four workflow commands
3. Naming consistency across all six primary subagents
4. Whether Lean-specific subagents need the same fix
5. Recommendations for completing the status update fix

## Key Findings

### Finding 1: General Subagents Are Fixed (Task 283)

**Evidence**: All three general-purpose subagents now use consistent `<step_0_preflight>` naming:

**researcher.md** (lines 140-205):
```xml
<step_0_preflight>
  <action>Preflight: Parse arguments, validate task, update status to [RESEARCHING]</action>
  <process>
    8. Invoke status-sync-manager to mark [RESEARCHING]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "researching"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
  </process>
</step_0_preflight>
```

**planner.md** (lines 95-153):
```xml
<step_0_preflight>
  <action>Preflight: Validate task and update status to [PLANNING]</action>
  <process>
    8. Invoke status-sync-manager to mark [PLANNING]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "planning"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
  </process>
</step_0_preflight>
```

**implementer.md** (lines 100-158):
```xml
<step_0_preflight>
  <action>Preflight: Validate task and update status to [IMPLEMENTING]</action>
  <process>
    8. Invoke status-sync-manager to mark [IMPLEMENTING]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "implementing"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. If status update fails: Abort with error and recommendation
  </process>
</step_0_preflight>
```

**Conclusion**: Task 283 successfully fixed general-purpose subagents. All three use `<step_0_preflight>` consistently.

### Finding 2: Lean Subagents Are NOT Fixed

**Evidence**: All three Lean-specific subagents use `<step_1>` instead of `<step_0_preflight>`:

**lean-research-agent.md** (lines 101-150):
```xml
<step_1>
  <action>Load Lean context, determine research strategy, and mark task as RESEARCHING</action>
  <process>
    1. Parse task_number from delegation context or prompt string:
       ...
    2. Update TODO.md status marker:
       a. Find task entry in specs/TODO.md
       b. Change status from [NOT STARTED] to [RESEARCHING]
       c. Add **Started**: YYYY-MM-DD timestamp
    3. Load context from .opencode/context/project/lean4/
    ...
  </process>
</step_1>
```

**Key Observations**:
1. **No `<step_0_preflight>` section**: Lean subagents start with `<step_1>` instead of `<step_0_preflight>`
2. **Status update in step_1**: Status update is embedded in step_1 (not a dedicated preflight step)
3. **No status-sync-manager invocation**: Lean subagents update TODO.md directly instead of delegating to status-sync-manager
4. **Inconsistent with general subagents**: Different workflow structure from researcher/planner/implementer

**Impact**: This explains why `/research 259` (a Lean task) failed to update status:
- Task 259 language is "lean" (from state.json)
- /research command routes Lean tasks to lean-research-agent (per routing table)
- lean-research-agent uses `<step_1>` naming (not `<step_0_preflight>`)
- Claude treats `<step_1>` as "part of main workflow" instead of "execute first"
- Preflight status update is skipped or deferred

### Finding 3: Commands Are Correct

**Evidence**: All four workflow commands properly delegate to subagents via orchestrator:

**research.md** (lines 36-49):
```markdown
**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Read task number from $ARGUMENTS variable, validate task exists in TODO.md
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent using routing table, validate routing
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
- **Stage 4 (ValidateReturn):** Validate return format, verify artifacts exist and are non-empty (prevents phantom research)
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Researcher subagent handles:**
- Update status to [RESEARCHING] at beginning (preflight)
- Research execution (web search, documentation, or Lean-specific tools)
- Topic subdivision (if --divide flag specified)
- Research report creation
- Update status to [RESEARCHED] at end (postflight)
- Git commits
```

**plan.md** (lines 33-47):
```markdown
**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number from $ARGUMENTS, validate task exists
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent (lean → lean-planner, general → planner)
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target planner
- **Stage 4 (ValidateReturn):** Validate return format, verify plan artifact exists
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Planner/Lean-planner subagent handles:**
- Update status to [PLANNING] at beginning (preflight)
- Research integration (automatic harvesting from TODO.md)
- Phase breakdown (1-2 hours per phase target)
- Effort estimation
- Plan template compliance
- Update status to [PLANNED] at end (postflight)
- Git commits
```

**implement.md** (lines 33-46):
```markdown
**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number or range from $ARGUMENTS, validate tasks exist
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent using routing table, validate routing
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
- **Stage 4 (ValidateReturn):** Validate return format, verify artifacts exist and are non-empty
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Implementer subagent handles:**
- Update status to [IMPLEMENTING] at beginning (preflight)
- Plan-based vs direct implementation
- Resume support (automatic detection of incomplete phases)
- Artifact creation (implementation files + summary)
- Update status to [COMPLETED] at end (postflight)
- Git commits (per-phase or single)
```

**revise.md** (lines 32-46):
```markdown
**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number from $ARGUMENTS, validate task exists and has existing plan
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent (lean → lean-planner, general → planner)
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target planner with revision context
- **Stage 4 (ValidateReturn):** Validate return format, verify plan artifact exists
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Planner/Lean-planner subagent handles:**
- Update status to [REVISING] at beginning (preflight)
- Plan revision (creates new version, preserves old)
- Version management (increments version number)
- Research integration (if new research available)
- Phase breakdown updates
- Update status to [REVISED] at end (postflight)
- Git commits
```

**Conclusion**: Commands are thin routers that delegate to orchestrator. Orchestrator handles routing to appropriate subagent based on language. Commands themselves do NOT need changes.

### Finding 4: State-Management.md Defines Correct Pattern

**Evidence**: state-management.md (lines 390-402) defines the two-phase status update pattern:

```markdown
### Usage in Commands

**`/research` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_researched(task_number, timestamp)`

**`/plan` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp)`
- Postflight: `status-sync-manager.mark_planned(task_number, timestamp, plan_path)`

**`/implement` command**:
- Preflight: `status-sync-manager.mark_in_progress(task_number, timestamp, plan_path)`
- Postflight: `status-sync-manager.mark_completed(task_number, timestamp, plan_path)`
```

**Two-Phase Commit Protocol** (lines 360-380):
```markdown
### status-sync-manager

The `status-sync-manager` specialist provides atomic multi-file updates using two-phase commit:

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
```

**Conclusion**: state-management.md correctly defines the two-phase pattern. Subagents should follow this pattern by invoking status-sync-manager in preflight and postflight.

### Finding 5: Lean Subagents Need Standardization

**Current State**:
- **General subagents**: Use `<step_0_preflight>` + status-sync-manager delegation
- **Lean subagents**: Use `<step_1>` + direct TODO.md updates

**Problems with Lean Subagents**:
1. **Naming inconsistency**: `<step_1>` instead of `<step_0_preflight>` causes Claude to skip or defer preflight
2. **No delegation**: Direct TODO.md updates instead of status-sync-manager delegation
3. **No atomicity**: Updates TODO.md only (not state.json or plan files)
4. **No validation**: No verification that status update succeeded
5. **No rollback**: No recovery mechanism if update fails

**Impact**:
- Lean tasks (language="lean") route to lean-research-agent, lean-planner, lean-implementation-agent
- These agents use inconsistent naming and update patterns
- Status updates are unreliable for Lean tasks
- Task 259 failure is explained by this inconsistency

## Detailed Analysis

### Subagent Naming Audit

| Subagent | Preflight Naming | Status Update Method | Atomic Updates | Consistent with Standard |
|----------|------------------|---------------------|----------------|-------------------------|
| researcher.md | `<step_0_preflight>` | status-sync-manager | Yes (TODO.md + state.json) | YES (Task 283) |
| planner.md | `<step_0_preflight>` | status-sync-manager | Yes (TODO.md + state.json) | YES |
| implementer.md | `<step_0_preflight>` | status-sync-manager | Yes (TODO.md + state.json) | YES |
| lean-research-agent.md | `<step_1>` | Direct TODO.md | No (TODO.md only) | NO |
| lean-planner.md | `<step_1>` | Direct TODO.md | No (TODO.md only) | NO |
| lean-implementation-agent.md | `<step_1>` | Direct TODO.md | No (TODO.md only) | NO |

### Routing Analysis

**Language-Based Routing** (from command specifications):

| Language | /research Routes To | /plan Routes To | /implement Routes To |
|----------|-------------------|----------------|---------------------|
| lean | lean-research-agent | lean-planner | lean-implementation-agent |
| markdown | researcher | planner | implementer |
| python | researcher | planner | implementer |
| general | researcher | planner | implementer |

**Implication**: Lean tasks use inconsistent subagents, general tasks use consistent subagents.

### Task 259 Root Cause Analysis

**Task 259 Details** (from state.json):
- project_number: 259
- project_name: "automation_tactics"
- language: "lean"
- status: "implementing"
- Started: 2026-01-04

**Routing Path**:
1. User runs `/research 259`
2. Orchestrator Stage 2 extracts language="lean" from state.json
3. Orchestrator Stage 3 routes to lean-research-agent (per routing table)
4. lean-research-agent uses `<step_1>` naming (not `<step_0_preflight>`)
5. Claude treats `<step_1>` as "part of main workflow" instead of "execute first"
6. Preflight status update is skipped or deferred
7. Task 259 status remains [NOT STARTED] during research execution

**Conclusion**: Task 259 failure is directly caused by lean-research-agent using `<step_1>` instead of `<step_0_preflight>`.

## Decisions

### Decision 1: Extend Task 283 Fix to Lean Subagents

**Rationale**: Task 283 proved that standardizing to `<step_0_preflight>` naming fixes status update issues. The same fix should be applied to Lean subagents for consistency.

**Approach**:
1. Rename `<step_1>` to `<step_0_preflight>` in lean-research-agent.md
2. Rename `<step_1>` to `<step_0_preflight>` in lean-planner.md
3. Rename `<step_1>` to `<step_0_preflight>` in lean-implementation-agent.md
4. Update status update logic to use status-sync-manager delegation (matching general subagents)
5. Renumber remaining steps (step_2 → step_1, step_3 → step_2, etc.)
6. Update subagent-structure.md to document that ALL subagents must use `<step_0_preflight>` naming

### Decision 2: Standardize Status Update Method

**Rationale**: Lean subagents currently update TODO.md directly, while general subagents delegate to status-sync-manager. This creates inconsistency and breaks atomicity.

**Approach**:
1. Replace direct TODO.md updates with status-sync-manager delegation
2. Match the pattern used in researcher.md, planner.md, implementer.md
3. Ensure atomic updates to both TODO.md and state.json
4. Add validation and error handling

### Decision 3: No Changes to Commands

**Rationale**: Commands are thin routers that properly delegate to orchestrator. Orchestrator handles routing to appropriate subagent based on language. No changes needed.

**Verification**: All four commands (/research, /plan, /revise, /implement) correctly document that subagents handle status updates in preflight and postflight.

## Recommendations

### Recommendation 1: Standardize Lean Subagent Naming (High Priority)

**Action**: Apply Task 283 fix to all three Lean subagents:
1. lean-research-agent.md: Rename `<step_1>` to `<step_0_preflight>`
2. lean-planner.md: Rename `<step_1>` to `<step_0_preflight>`
3. lean-implementation-agent.md: Rename `<step_1>` to `<step_0_preflight>`

**Effort**: 2-3 hours (straightforward naming change, following Task 283 pattern)

**Impact**: Fixes status update failures for ALL Lean tasks (like Task 259)

### Recommendation 2: Standardize Status Update Method (High Priority)

**Action**: Replace direct TODO.md updates with status-sync-manager delegation in all Lean subagents:
1. Add status-sync-manager invocation in `<step_0_preflight>` (preflight)
2. Add status-sync-manager invocation in postflight step
3. Remove direct TODO.md update logic
4. Match the pattern used in researcher.md, planner.md, implementer.md

**Effort**: 3-4 hours (requires careful refactoring of status update logic)

**Impact**: Ensures atomic updates to TODO.md and state.json for Lean tasks

### Recommendation 3: Update Subagent-Structure.md (Medium Priority)

**Action**: Document that ALL subagents (general and Lean) must use `<step_0_preflight>` naming:
1. Add requirement: "All subagents MUST use `<step_0_preflight>` for preflight step"
2. Add rationale: "Explicit step_0 numbering prevents Claude from skipping preflight"
3. Add examples from both general and Lean subagents
4. Reference Task 283 and Task 285 as history

**Effort**: 0.5 hours (documentation update)

**Impact**: Prevents future inconsistencies when creating new subagents

### Recommendation 4: Test Lean Workflow After Fix (High Priority)

**Action**: After implementing recommendations 1-2, test Lean workflow:
1. Create a test Lean task (e.g., Task 300)
2. Run `/research 300` and verify status updates to [RESEARCHING]
3. Verify TODO.md and state.json are updated atomically
4. Run `/plan 300` and verify status updates to [PLANNING] then [PLANNED]
5. Run `/implement 300` and verify status updates to [IMPLEMENTING] then [COMPLETED]

**Effort**: 1 hour (testing and validation)

**Impact**: Confirms fix works for Lean tasks

## Risks & Mitigations

### Risk 1: Lean Subagent Refactoring Breaks Existing Functionality

**Likelihood**: Low  
**Impact**: High  
**Mitigation**: 
- Follow Task 283 pattern exactly (proven to work)
- Only change naming and status update method (don't change core logic)
- Test thoroughly with Lean tasks before deploying
- Keep backup of original files

### Risk 2: Status-Sync-Manager Delegation Adds Latency

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: 
- status-sync-manager is fast (60s timeout, typically completes in <5s)
- Atomic updates are worth the small latency cost
- General subagents already use this pattern successfully

### Risk 3: Incomplete Fix (Missing Edge Cases)

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**: 
- Audit all six primary subagents (done in this research)
- Check for other subagents that might need fixing (e.g., meta, reviewer)
- Document standard in subagent-structure.md to prevent future inconsistencies

## Appendix: Sources and Citations

### Primary Sources

1. **Task 283 Research Report**: specs/283_fix_systematic_status_synchronization_failure/reports/research-001.md
   - Root cause analysis of naming inconsistency
   - Proof that `<step_0_preflight>` naming fixes status update issues

2. **Task 283 Implementation Summary**: specs/283_fix_systematic_status_synchronization_failure/summaries/implementation-summary-20260104.md
   - Details of fix applied to researcher.md
   - Standardization to `<step_0_preflight>` naming

3. **State-Management.md**: .opencode/context/core/system/state-management.md
   - Two-phase status update pattern definition
   - status-sync-manager usage documentation

### Subagent Specifications

1. **researcher.md**: .opencode/agent/subagents/researcher.md (lines 140-205)
   - `<step_0_preflight>` implementation (FIXED by Task 283)
   - status-sync-manager delegation pattern

2. **planner.md**: .opencode/agent/subagents/planner.md (lines 95-153)
   - `<step_0_preflight>` implementation (already correct)
   - status-sync-manager delegation pattern

3. **implementer.md**: .opencode/agent/subagents/implementer.md (lines 100-158)
   - `<step_0_preflight>` implementation (already correct)
   - status-sync-manager delegation pattern

4. **lean-research-agent.md**: .opencode/agent/subagents/lean-research-agent.md (lines 101-150)
   - `<step_1>` implementation (NOT FIXED)
   - Direct TODO.md updates (no status-sync-manager)

5. **lean-planner.md**: .opencode/agent/subagents/lean-planner.md
   - `<step_1>` implementation (NOT FIXED)
   - Direct TODO.md updates (no status-sync-manager)

6. **lean-implementation-agent.md**: .opencode/agent/subagents/lean-implementation-agent.md
   - `<step_1>` implementation (NOT FIXED)
   - Direct TODO.md updates (no status-sync-manager)

### Command Specifications

1. **research.md**: .opencode/command/research.md (lines 36-49)
   - Language-based routing to lean-research-agent or researcher
   - Subagent responsibilities documented

2. **plan.md**: .opencode/command/plan.md (lines 33-47)
   - Language-based routing to lean-planner or planner
   - Subagent responsibilities documented

3. **implement.md**: .opencode/command/implement.md (lines 33-46)
   - Language-based routing to lean-implementation-agent or implementer
   - Subagent responsibilities documented

4. **revise.md**: .opencode/command/revise.md (lines 32-46)
   - Language-based routing to lean-planner or planner
   - Subagent responsibilities documented

### State Files

1. **state.json**: specs/state.json (lines 526-551)
   - Task 259 details (language="lean", status="implementing")
   - Evidence of Lean task routing

2. **TODO.md**: specs/TODO.md
   - Task 285 description (evidence of status update failure)
   - Task 259 entry (Lean task example)

---

**Research Completed**: 2026-01-04  
**Next Steps**: Create implementation plan to standardize Lean subagent naming and status update methods
