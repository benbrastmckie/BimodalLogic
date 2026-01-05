---
last_updated: 2026-01-04T17:47:49Z
next_project_number: 293
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2026-01-04T06:25:00Z
task_counts:
  active: 5
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 24
  total: 82
priority_distribution:
  high: 16
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO


---

## High Priority

### 289. Fix /task command to never implement solutions, only create task entries
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None

**Description**:
The `/task` command is currently implementing solutions instead of creating task entries. When a user runs `/task "Identify the root cause and fix X"`, the orchestrator interprets this as a general problem-solving instruction and implements the fix directly, rather than creating a task entry in TODO.md and state.json.

**Root Cause**:
The orchestrator is designed as a router/delegator but lacks logic to handle "self-execution" commands (commands with `agent: orchestrator` and no routing configuration). When `/task` is invoked, the orchestrator receives the entire command file content as context and interprets it as a general instruction rather than as a workflow to execute.

**Expected Behavior**:
- `/task "Fix the /implement command"` should create a new task entry in TODO.md
- It should increment next_project_number in state.json
- It should return the task number to the user
- It should NEVER implement the fix

**Current Behavior**:
- `/task "Fix the /implement command"` implements the fix directly
- It modifies multiple files (.opencode/agent/orchestrator.md, .opencode/command/*.md)
- It returns a summary of the implementation
- It does NOT create a task entry

**Fix Required**:
Add self-execution mode to orchestrator:
1. Stage 2: Detect commands with no routing configuration
2. Stage 2a: Execute command workflow directly (new stage)
3. Stage 3: Skip delegation for self-execution commands
4. Ensure `/task` follows its `<critical_constraints>` section exactly

**Files Involved**:
- `.opencode/agent/orchestrator.md` - Add self-execution detection and Stage 2a
- `.opencode/command/task.md` - Already has correct constraints, just needs orchestrator to respect them

### 283. Fix systematic status synchronization failure across all workflow commands
- **Effort**: 3-4 hours (revised from 6-8 hours)
- **Status**: [COMPLETED] (2026-01-04)
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](283_fix_systematic_status_synchronization_failure/reports/research-001.md)
- **Plan**: [Implementation Plan v1](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md) | [Implementation Plan v2](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md) (current)
- **Implementation**: [Implementation Summary](283_fix_systematic_status_synchronization_failure/summaries/implementation-summary-20260104.md)
- **Note**: Research and revision artifact links were NOT automatically added by /research and /revise commands - had to be added manually. /plan command DID work correctly. This is the EXACT bug this task is meant to fix.

**Description**:
Multiple tasks (269, 284) have exposed a **systematic status synchronization failure** affecting ALL workflow commands (/research, /plan, /implement, /revise). When commands complete successfully, status is NOT updated in TODO.md or state.json, and tasks are NOT added to state.json's active_projects or completed_projects arrays. This is a critical workflow bug that breaks task tracking.

**Evidence of Systematic Failure**:

1. **Task 269** (completed 2026-01-03):
   - state.json: status="completed", git_commit="a4fa33f"
   - TODO.md: status=`[NOT STARTED]` (WRONG)
   - Result: /research 269 failed with "cannot research completed task"

2. **Task 284** (completed 2026-01-04):
   - state.json: Task 284 NOT in active_projects or completed_projects (MISSING)
   - TODO.md: status=`[NOT STARTED]` (WRONG)
   - Result: Implementer claimed success but no status updates occurred

3. **Task 275** (Fix workflow status updates):
   - Marked as [COMPLETED] but the fix clearly didn't work
   - Status synchronization still broken after "fix"

**Root Cause Analysis**:

**Issue 1: Status-Sync-Manager Not Invoked**
- Subagents (researcher, planner, implementer) complete work successfully
- Subagents return JSON with status="completed"
- BUT status-sync-manager is NEVER invoked to update TODO.md and state.json
- Result: Status remains `[NOT STARTED]` despite completion

**Issue 2: Missing Preflight Status Updates**
- Commands should update status to `[RESEARCHING]`, `[PLANNING]`, `[IMPLEMENTING]` at START
- This never happens - status remains `[NOT STARTED]` during execution
- Task 275 claimed to fix this but it's still broken

**Issue 3: Missing Postflight Status Updates**
- Commands should update status to `[RESEARCHED]`, `[PLANNED]`, `[COMPLETED]` at END
- This never happens - status remains `[NOT STARTED]` after completion
- Task 275 claimed to fix this but it's still broken

**Issue 4: Missing state.json Project Entries**
- New tasks created with /task are NOT added to state.json active_projects
- Completed tasks are NOT moved to state.json completed_projects
- Result: state.json is incomplete and out of sync with TODO.md

**Expected Behavior**:

```bash
# PREFLIGHT (Command Start):
/implement 284
# 1. Orchestrator Stage 1: Validate task exists in state.json
# 2. Orchestrator Stage 1: Update status to [IMPLEMENTING] in TODO.md and state.json
# 3. Orchestrator Stage 2-3: Route to implementer and delegate

# POSTFLIGHT (Command End):
# 4. Implementer: Complete work, return JSON with status="completed"
# 5. Orchestrator Stage 4: Validate return format and artifacts
# 6. Orchestrator Stage 5: Update status to [COMPLETED] in TODO.md and state.json
# 7. Orchestrator Stage 5: Move task from active_projects to completed_projects in state.json
# 8. User sees: "Task 284 completed successfully"
```

**Fix Strategy**:

**Phase 1: Fix Orchestrator Preflight Status Updates** (2 hours)
1. Update orchestrator Stage 1 (PreflightValidation):
   - Extract task metadata from state.json
   - Validate task exists in active_projects or create entry if missing
   - Invoke status-sync-manager to update status to in-progress state:
     * /research → [RESEARCHING]
     * /plan → [PLANNING]
     * /implement → [IMPLEMENTING]
     * /revise → [REVISING]
2. Add validation to reject already-completed tasks:
   - If status == "completed": Error "Task {number} already completed ({date})"
   - If status == "blocked": Error "Task {number} is blocked by: {blockers}"
3. Test preflight updates with all workflow commands

**Phase 2: Fix Orchestrator Postflight Status Updates** (2 hours)
1. Update orchestrator Stage 5 (PostflightCleanup):
   - After validating subagent return (Stage 4)
   - Extract status from subagent return JSON
   - Invoke status-sync-manager to update status to completion state:
     * researcher → [RESEARCHED]
     * planner → [PLANNED]
     * implementer → [COMPLETED]
     * reviser → [REVISED]
   - If status="completed": Move task from active_projects to completed_projects
2. Add artifact links to TODO.md and state.json
3. Test postflight updates with all workflow commands

**Phase 3: Fix /task Command to Create state.json Entries** (1 hour)
1. Update /task command to add new tasks to state.json active_projects:
   ```json
   {
     "project_number": 284,
     "project_name": "todo_auto_commit",
     "type": "feature",
     "phase": "not_started",
     "status": "not_started",
     "priority": "medium",
     "language": "general",
     "created": "2026-01-04T06:00:00Z",
     "last_updated": "2026-01-04T06:00:00Z"
   }
   ```
2. Ensure /task creates both TODO.md entry AND state.json entry atomically
3. Test /task creates entries in both files

**Phase 4: Verify Task 275 "Fix" and Identify Why It Failed** (1 hour)
1. Review task 275 implementation to understand what was "fixed"
2. Identify why the fix didn't work (likely: documentation updated but code not changed)
3. Determine if task 275 needs to be re-implemented or if this task supersedes it
4. Document findings in task 283 implementation notes

**Phase 5: Manual Cleanup of Broken Tasks** (1 hour)
1. Fix task 269 status in TODO.md (currently [NOT STARTED], should be [COMPLETED])
2. Verify task 284 status is correct (manually fixed already)
3. Audit all tasks marked [COMPLETED] in TODO.md and verify they exist in state.json completed_projects
4. Audit all tasks in state.json completed_projects and verify they're marked [COMPLETED] in TODO.md
5. Create cleanup script for future use

**Files to Modify**:
- `.opencode/agent/orchestrator.md` - Add preflight (Stage 1) and postflight (Stage 5) status updates
- `.opencode/agent/subagents/status-sync-manager.md` - Verify it works correctly when invoked
- `.opencode/command/task.md` - Add state.json active_projects entry creation
- `.opencode/command/research.md` - Document preflight/postflight status updates
- `.opencode/command/plan.md` - Document preflight/postflight status updates
- `.opencode/command/implement.md` - Document preflight/postflight status updates
- `.opencode/command/revise.md` - Document preflight/postflight status updates
- `.opencode/context/core/system/state-management.md` - Document status update pattern
- `.opencode/context/core/workflows/command-lifecycle.md` - Document preflight/postflight pattern

**Acceptance Criteria**:
- [ ] /task creates entries in BOTH TODO.md and state.json active_projects
- [ ] /research updates status to [RESEARCHING] at start, [RESEARCHED] at end
- [ ] /plan updates status to [PLANNING] at start, [PLANNED] at end
- [ ] /implement updates status to [IMPLEMENTING] at start, [COMPLETED] at end
- [ ] /revise updates status to [REVISING] at start, [REVISED] at end
- [ ] Completed tasks moved from active_projects to completed_projects in state.json
- [ ] Orchestrator rejects already-completed tasks with clear error message
- [ ] Task 269 status synchronized: TODO.md shows `[COMPLETED]`
- [ ] Task 284 exists in state.json completed_projects (verify manual fix)
- [ ] All tasks in TODO.md with [COMPLETED] status exist in state.json completed_projects
- [ ] All tasks in state.json completed_projects have [COMPLETED] status in TODO.md
- [ ] No regression in existing workflow command behavior
- [ ] Task 275 findings documented (why did the "fix" fail?)

**Impact**: 
Fixes the systematic status synchronization failure affecting ALL workflow commands. Ensures TODO.md and state.json stay synchronized throughout the entire task lifecycle (creation → research → planning → implementation → completion). Prevents "phantom completions" where work is done but status never updates. Enables accurate task tracking and prevents wasted effort on already-completed tasks.

**Related Issues**:
- Task 269: Status mismatch (completed in state.json, [NOT STARTED] in TODO.md)
- Task 284: Status never updated despite successful implementation
- Task 275: "Fix workflow status updates" - marked COMPLETED but fix didn't work
- Task 279: Systematically fix metadata lookup to use state.json instead of TODO.md
- Task 280: Fix orchestrator Stage 4 validation (should catch missing status updates)

---

### 286. Research alternative to task 283 with subagent-owned pre-flight and post-flight work
- **Effort**: 6-8 hours
- **Status**: [ABANDONED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
Currently the orchestrator is in charge of running pre-flight and post-flight work, including synchronization of the task status and artifact links where lack of validation leads to failures. It might make more sense to move as much of the pre-flight and post-flight work including all synchronization to the subagents doing the work instead of leaving this to the orchestrator. That way the commands such as /research, /plan, /revise, and /implement would just be responsible for parsing and passing the appropriate arguments to the correct subagents and then all further work will then be handled by those subagents including status synchronization and git commits. Research an alternative to task 283 that works along these lines.

**Research Scope**:

1. **Current Architecture Analysis**:
   - Document current orchestrator responsibilities (Stage 1 preflight, Stage 5 postflight)
   - Document current subagent responsibilities (work execution only)
   - Identify validation failures caused by orchestrator-owned synchronization
   - Analyze task 283's proposed orchestrator-centric solution

2. **Alternative Architecture Design**:
   - Move preflight work to subagents (status updates, validation, state.json entry creation)
   - Move postflight work to subagents (status updates, artifact links, git commits)
   - Reduce orchestrator to argument parsing and routing only
   - Define subagent ownership of complete workflow lifecycle

3. **Comparison Analysis**:
   - Compare orchestrator-centric (task 283) vs. subagent-centric (this task) approaches
   - Analyze validation enforcement: orchestrator validation vs. subagent self-validation
   - Analyze failure modes: centralized vs. distributed responsibility
   - Analyze complexity: orchestrator complexity vs. subagent complexity

4. **Implementation Strategy**:
   - Define subagent preflight responsibilities (status updates, validation)
   - Define subagent postflight responsibilities (status updates, artifact links, git commits)
   - Define orchestrator responsibilities (argument parsing, routing, return validation)
   - Define migration path from current architecture to subagent-owned architecture

5. **Trade-offs and Recommendations**:
   - Identify benefits of subagent-owned approach (ownership, encapsulation, autonomy)
   - Identify drawbacks of subagent-owned approach (duplication, coordination complexity)
   - Compare with orchestrator-owned approach (task 283)
   - Recommend best approach with justification

**Files to Analyze**:
- `.opencode/agent/orchestrator.md` - Current orchestrator responsibilities
- `.opencode/agent/subagents/researcher.md` - Current researcher responsibilities
- `.opencode/agent/subagents/planner.md` - Current planner responsibilities
- `.opencode/agent/subagents/implementer.md` - Current implementer responsibilities
- `.opencode/agent/subagents/status-sync-manager.md` - Current synchronization mechanism
- `.opencode/specs/283_fix_systematic_status_synchronization_failure/reports/research-001.md` - Task 283 analysis
- `.opencode/specs/283_fix_systematic_status_synchronization_failure/plans/implementation-001.md` - Task 283 solution

**Acceptance Criteria**:
- [ ] Current architecture documented (orchestrator vs. subagent responsibilities)
- [ ] Alternative architecture designed (subagent-owned pre-flight and post-flight)
- [ ] Comparison analysis completed (orchestrator-centric vs. subagent-centric)
- [ ] Implementation strategy defined (migration path, responsibilities)
- [ ] Trade-offs identified (benefits and drawbacks of each approach)
- [ ] Recommendation provided (best approach with justification)
- [ ] Research report created with findings and recommendation

**Impact**: 
Provides alternative architectural approach to task 283 that moves responsibility for pre-flight and post-flight work from orchestrator to subagents. Enables comparison of centralized (orchestrator-owned) vs. distributed (subagent-owned) approaches to status synchronization and workflow management. Informs decision on best architecture for fixing systematic status synchronization failures.

**Related Tasks**:
- Task 283: Fix systematic status synchronization failure (orchestrator-centric approach)
- Task 285: Audit and fix status update behavior (related to status synchronization)
- Task 275: Fix workflow status updates (previous attempt at fixing status synchronization)

---

### 285. Audit and fix status update behavior in /research, /plan, /revise, and /implement commands
- **Effort**: 6-8 hours (revised from 8-12 hours)
- **Status**: [COMPLETED]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Planned**: 2026-01-04
- **Implementing**: 2026-01-04
- **Completed**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/285_audit_and_fix_status_update_behavior/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/285_audit_and_fix_status_update_behavior/plans/implementation-001.md)
- **Implementation**: [Implementation Summary](.opencode/specs/285_audit_and_fix_status_update_behavior/summaries/implementation-summary-20260104.md)
- **Artifacts**:
  - Task Description: [.opencode/specs/285_audit_and_fix_status_update_behavior/task-description.md]
- **Note**: Core work (Phases 1-3) was already completed by Task 289. This implementation verified the fix and updated documentation to reference Task 289.

**Description**:
When running `/research 259`, the lean-research-agent was correctly invoked, but the task status was NOT updated to `[RESEARCHING]` before work began. This violates the two-phase status update pattern defined in `.opencode/context/core/system/state-management.md`. All workflow commands (`/research`, `/plan`, `/revise`, `/implement`) must update status markers at BOTH the beginning (preflight) and end (postflight) of execution.

**Evidence**:
- `/research 259` invoked lean-research-agent successfully
- Task 259 status remained `[NOT STARTED]` during research execution
- Expected: Status should change to `[RESEARCHING]` at start, `[RESEARCHED]` at completion
- Actual: Status never updated during or after execution

**State Management Standard Requirements** (from state-management.md):

**Preflight Status Updates** (Command Start):
- `/research` → Update status to `[RESEARCHING]`
- `/plan` → Update status to `[PLANNING]`
- `/implement` → Update status to `[IMPLEMENTING]`
- `/revise` → Update status to `[REVISING]`

**Postflight Status Updates** (Command Completion):
- `/research` → Update status to `[RESEARCHED]`
- `/plan` → Update status to `[PLANNED]`
- `/implement` → Update status to `[COMPLETED]`
- `/revise` → Update status to `[REVISED]`

**Root Cause Analysis**:

The state-management.md standard (lines 390-402) defines the correct pattern:

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

However, the actual command implementations may not be following this pattern. Need to audit all four commands to verify:

1. **Preflight status updates**: Are commands updating status at START?
2. **Postflight status updates**: Are commands updating status at END?
3. **Status-sync-manager invocation**: Are commands using status-sync-manager correctly?
4. **Atomic updates**: Are updates atomic (all files or none)?

**Audit Scope**:

**Commands to Audit** (4 files):
- `.opencode/command/research.md` - Check preflight/postflight status updates
- `.opencode/command/plan.md` - Check preflight/postflight status updates
- `.opencode/command/implement.md` - Check preflight/postflight status updates
- `.opencode/command/revise.md` - Check preflight/postflight status updates

**Subagents to Audit** (4 files):
- `.opencode/agent/subagents/researcher.md` - Verify status update responsibility
- `.opencode/agent/subagents/planner.md` - Verify status update responsibility
- `.opencode/agent/subagents/implementer.md` - Verify status update responsibility
- `.opencode/agent/subagents/reviser.md` - Verify status update responsibility (if exists)

**Orchestrator to Audit** (1 file):
- `.opencode/agent/orchestrator.md` - Check if orchestrator handles status updates in Stage 1 (preflight) and Stage 5 (postflight)

**Status-Sync-Manager to Audit** (1 file):
- `.opencode/agent/subagents/status-sync-manager.md` - Verify it supports all required operations

**Implementation Strategy**:

**Phase 1: Comprehensive Audit** (3 hours)
1. Read all 4 command files and document current status update behavior
2. Read all 4 subagent files and document status update responsibility
3. Read orchestrator.md and document Stage 1/Stage 5 status handling
4. Read status-sync-manager.md and document available operations
5. Create audit report comparing actual vs. expected behavior
6. Identify gaps: Which commands/stages are missing status updates?

**Phase 2: Fix Orchestrator (if needed)** (2 hours)
1. If orchestrator Stage 1 (PreflightValidation) is missing status updates:
   - Add status-sync-manager invocation to update status to in-progress state
   - Map command to status marker: /research → [RESEARCHING], /plan → [PLANNING], etc.
2. If orchestrator Stage 5 (PostflightCleanup) is missing status updates:
   - Add status-sync-manager invocation to update status to completion state
   - Map subagent return to status marker: researcher → [RESEARCHED], planner → [PLANNED], etc.
3. Test orchestrator changes with all workflow commands

**Phase 3: Fix Commands (if needed)** (2 hours)
1. For each command missing preflight status updates:
   - Add status-sync-manager invocation at command start
   - Document the status update in command workflow
2. For each command missing postflight status updates:
   - Add status-sync-manager invocation at command end
   - Document the status update in command workflow
3. Test command changes with real tasks

**Phase 4: Fix Subagents (if needed)** (2 hours)
1. If subagents are responsible for status updates (not orchestrator):
   - Add preflight status update to subagent Stage 1
   - Add postflight status update to subagent final stage
2. If subagents should NOT handle status (orchestrator handles it):
   - Remove any status update logic from subagents
   - Document that orchestrator owns status updates
3. Test subagent changes

**Phase 5: Update Documentation** (1 hour)
1. Update state-management.md with actual implementation pattern
2. Update command-lifecycle.md with status update workflow
3. Create examples showing correct status update pattern
4. Document which component (orchestrator vs. command vs. subagent) owns status updates

**Phase 6: Validation Testing** (2 hours)
1. Test `/research` command:
   - Verify status changes to [RESEARCHING] at start
   - Verify status changes to [RESEARCHED] at completion
   - Verify both TODO.md and state.json updated atomically
2. Test `/plan` command:
   - Verify status changes to [PLANNING] at start
   - Verify status changes to [PLANNED] at completion
3. Test `/implement` command:
   - Verify status changes to [IMPLEMENTING] at start
   - Verify status changes to [COMPLETED] at completion
4. Test `/revise` command:
   - Verify status changes to [REVISING] at start
   - Verify status changes to [REVISED] at completion
5. Verify all updates are atomic (all files updated or none)
6. Verify no regression in existing functionality

**Files to Modify** (estimated 10-15 files):

**Commands** (4 files):
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/command/implement.md`
- `.opencode/command/revise.md`

**Subagents** (4-5 files):
- `.opencode/agent/subagents/researcher.md`
- `.opencode/agent/subagents/planner.md`
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/reviser.md` (if exists)
- `.opencode/agent/subagents/status-sync-manager.md` (if new operations needed)

**Orchestrator** (1 file):
- `.opencode/agent/orchestrator.md`

**Documentation** (2-3 files):
- `.opencode/context/core/system/state-management.md`
- `.opencode/context/core/workflows/command-lifecycle.md`
- `.opencode/context/core/standards/status-transitions.md` (if exists)

**Acceptance Criteria**:
- [ ] Audit report created documenting current vs. expected status update behavior
- [ ] All gaps identified (which commands/stages missing status updates)
- [ ] `/research` updates status to [RESEARCHING] at start, [RESEARCHED] at end
- [ ] `/plan` updates status to [PLANNING] at start, [PLANNED] at end
- [ ] `/implement` updates status to [IMPLEMENTING] at start, [COMPLETED] at end
- [ ] `/revise` updates status to [REVISING] at start, [REVISED] at end
- [ ] All status updates are atomic (TODO.md and state.json updated together)
- [ ] Status updates use status-sync-manager for atomic multi-file updates
- [ ] Documentation updated to reflect actual implementation pattern
- [ ] All workflow commands tested and verified
- [ ] No regression in existing functionality
- [ ] Clear ownership documented (orchestrator vs. command vs. subagent)

**Impact**: 
Ensures all workflow commands follow the two-phase status update pattern defined in state-management.md. Provides visibility into task progress (users can see when research/planning/implementation is actively underway). Enables accurate task tracking and prevents confusion about task state. Fixes the issue observed in `/research 259` where status was not updated during execution.

**Related Tasks**:
- Task 283: Fix systematic status synchronization failure (broader scope - includes state.json project entries)
- Task 275: Fix workflow status updates (claimed to fix this but didn't work - need to verify what was actually done)
- Task 280: Fix orchestrator Stage 4 validation (should validate status updates occurred)

---

### 257. Completeness Proofs
 **Effort**: 70-90 hours
 **Status**: [NOT STARTED]
 **Priority**: Low
 **Language**: lean
 **Blocking**: Decidability
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

**Acceptance Criteria**:
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.

---

### 258. Resolve Truth.lean Sorries
- **Effort**: 0.5 hours
- **Status**: [COMPLETED]
- **Started**: 2026-01-03
- **Completed**: 2026-01-04
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md]
  - Summary: [.opencode/specs/258_resolve_truth_lean_sorries/summaries/research-summary.md]
- **Plan Artifacts**:
  - Implementation Plan: [.opencode/specs/258_resolve_truth_lean_sorries/plans/implementation-001.md]
- **Implementation Artifacts**:
  - Summary: [.opencode/specs/258_resolve_truth_lean_sorries/summaries/implementation-summary-20260104.md]
  - Note: No code changes needed - task already resolved in Task 213 (commit 1cf688b)

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Research Findings**: The 3 sorries mentioned in the task description (lines 697, 776, 798) were already resolved in Task 213 (commit 1cf688b, 2025-12-28). Current Truth.lean has 580 lines with zero sorries. The unprovable `is_valid_swap_involution` theorem and `truth_swap_of_valid_at_triple` function were removed after semantic analysis proved them false. Task 258 is ALREADY RESOLVED.

**Action Items**:
1. ~~Resolve `truth_swap_of_valid_at_triple` (implication case)~~ - Already resolved in Task 213
2. ~~Resolve `truth_swap_of_valid_at_triple` (past case - domain extension)~~ - Already resolved in Task 213
3. ~~Resolve `truth_swap_of_valid_at_triple` (future case - domain extension)~~ - Already resolved in Task 213

**Files**:
- `Logos/Core/Semantics/Truth.lean` (current: 580 lines, 0 sorries)

**Acceptance Criteria**:
- [x] Implication case resolved (removed in Task 213)
- [x] Past case with domain extension resolved (removed in Task 213)
- [x] Future case with domain extension resolved (removed in Task 213)
- [x] All tests pass (Truth.lean builds successfully)
- [x] SORRY_REGISTRY.md updated (shows 0 sorries in Truth.lean)

**Impact**: Task objectives already achieved through Task 213. Truth.lean is clean, well-documented, and builds successfully.

**Recommendation**: Mark task as ALREADY RESOLVED or OBSOLETE. See Task 213 for resolution details.

---

### 259. Automation Tactics
- **Effort**: 17-23 hours (revised from 40-60 hours based on research findings)
- **Status**: [PLANNED] (2026-01-04)
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Planned**: 2026-01-04
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/259_automation_tactics/reports/research-001.md]
- **Plan Artifacts**:
  - Implementation Plan: [.opencode/specs/259_automation_tactics/plans/implementation-001.md]

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction. Research found 10/12 tactics fully implemented (83% complete), 2 tactics with infrastructure ready but delegating to tm_auto. Aesop integration functional with 2 noncomputable errors. ProofSearch.lean provides production-ready bounded search infrastructure (461 lines).

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

**Acceptance Criteria**:
- [ ] All 8 remaining tactics implemented
- [ ] Aesop integration fixed
- [ ] Tests added for new tactics
- [ ] TACTIC_REGISTRY.md updated
- [ ] Documentation updated

**Impact**: Significantly improves proof automation capabilities for TM logic, making proof construction easier and more efficient.

---

### 260. Proof Search
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

**Acceptance Criteria**:
- [ ] Breadth-first proof search implemented
- [ ] Heuristic-guided search implemented
- [ ] Tests added for proof search
- [ ] Performance benchmarks created
- [ ] Documentation updated

**Impact**: Enables automated proof discovery for TM logic, reducing manual proof construction effort.

---

### 261. Decidability
- **Effort**: 40-60 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

**Acceptance Criteria**:
- [ ] Tableau method implemented
- [ ] Satisfiability decision procedure implemented
- [ ] Tests added for decision procedures
- [ ] Documentation updated

**Impact**: Provides algorithmic decision procedures for TM logic validity and satisfiability.

---

### 262. ModalS5 Limitation
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

**Acceptance Criteria**:
- [ ] Documentation maintained or alternative formulation found
- [ ] SORRY_REGISTRY.md updated with justification

**Impact**: Resolves documented limitation in ModalS5 theorems.

---


### 263. Refactor Context.lean
- **Effort**: 2-4 hours
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: Task 264
- **Dependencies**: None

**Description**: Refactor the `Context.lean` file to improve clarity, performance, and alignment with the LEAN 4 style guide. This involves reviewing the existing implementation of proof contexts and applying best practices for data structures and function definitions in LEAN 4.

**Files Affected**:
- `Logos/Core/Syntax/Context.lean`
- `LogosTest/Core/Syntax/ContextTest.lean`

**Acceptance Criteria**:
- [ ] The `Context.lean` file is refactored for clarity and performance.
- [ ] All related tests in `ContextTest.lean` are updated and pass.
- [ ] The refactoring adheres to the LEAN 4 style guide.
- [ ] The public API of the `Context` module remains backward-compatible or changes are documented.

**Impact**: Improves the maintainability and readability of a core component of the syntax package.

---

### 264. Update Context References
- **Effort**: 1-2 hours
- **Status**: [RESEARCHING]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: Task 263

**Files Affected**:
- `Logos/Core/ProofSystem/Derivation.lean`
- `Logos/Core/Metalogic/DeductionTheorem.lean`
- Other files that import `Logos.Core.Syntax.Context`

**Description**: After refactoring `Context.lean`, update all references to the `Context` module throughout the codebase to ensure they are compatible with any changes made to the API. This task involves searching for all usages of `Context` and updating them as necessary.

**Acceptance Criteria**:
- [ ] All references to the `Context` module are updated.
- [ ] The project builds successfully after the updates.
- [ ] All tests pass after the updates.

**Impact**: Ensures that the entire codebase is compatible with the refactored `Context` module.

---

## High Priority




### 132. Prove Lindenbaum maximal consistency lemma in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Formalize and prove the Lindenbaum maximal consistency lemma to eliminate the first axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Lindenbaum lemma proven and axiom removed
  - [ ] Proof integrates with existing canonical model scaffolding
  - [ ] Related tests added or updated
- **Impact**: Unlocks subsequent completeness proofs by establishing maximal consistency.

---

### 133. Build canonical model constructors in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Implement canonical model construction helpers and remove associated axiom stubs.
- **Acceptance Criteria**:
  - [ ] Canonical model constructors implemented
  - [ ] Corresponding axiom placeholders removed
  - [ ] Construction type-checks with existing definitions
- **Impact**: Provides the core model for subsequent truth lemma proofs.

---

### 134. Prove truth lemma structure in Completeness.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 133
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Prove the truth lemma for the canonical model, removing the corresponding axiom placeholder.
- **Acceptance Criteria**:
  - [ ] Truth lemma proven and axiom removed
  - [ ] Proof integrates with canonical model components
  - [ ] Tests (or placeholders) updated to exercise lemma
- **Impact**: Establishes the key bridge between syntax and semantics for completeness.

---

### 135. Remove provable_iff_valid sorry in Completeness.lean
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 132, 133, 134
- **Files Affected**:
  - Logos/Core/Metalogic/Completeness.lean
- **Description**: Complete the `provable_iff_valid` theorem using the proven canonical model and truth lemma to eliminate the remaining sorry.
- **Acceptance Criteria**:
  - [ ] `provable_iff_valid` fully proven
  - [ ] No remaining axiom or sorry placeholders in Completeness.lean
  - [ ] Completeness tests added or updated
- **Impact**: Delivers full completeness, enabling derivability from validity.

### Decidability


---

### 136. Design Decidability.lean architecture and signatures
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Define the module structure, main theorems, and function signatures for decidability (tableau and satisfiability checks).
- **Acceptance Criteria**:
  - [ ] Module skeleton with signatures for tableau and decision procedures
  - [ ] Documentation comments outline intended algorithms
  - [ ] No build warnings from new declarations
- **Impact**: Establishes a foundation for future decidability proofs and implementations.

---

### 137. Implement tableau core rules in Decidability.lean
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
- **Description**: Implement the core tableau expansion rules and supporting helpers for validity checking.
- **Acceptance Criteria**:
  - [ ] Tableau expansion rules implemented and type-checking
  - [ ] Basic examples compile demonstrating rule application
  - [ ] No placeholder axioms for these rules remain
- **Impact**: Provides executable building blocks for the decision procedure.

---

### 138. Implement satisfiability and validity decision procedure tests
- **Effort**: 3 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: lean
- **Blocking**: None
- **Dependencies**: 136, 137
- **Files Affected**:
  - Logos/Core/Metalogic/Decidability.lean
  - LogosTest/Metalogic/DecidabilityTest.lean (new or updated)
- **Description**: Wire the tableau components into a decision procedure and add tests covering satisfiable and unsatisfiable cases.
- **Acceptance Criteria**:
  - [ ] Decision procedure implemented and compiles
  - [ ] Tests cover satisfiable and unsatisfiable scenarios
  - [ ] No remaining placeholder axioms in the decision procedure path
- **Impact**: Delivers an initial, test-backed decision procedure for TM logic.

### Layer Extensions (Future Planning)


---

### 139. Draft Layer 1 counterfactual operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 1 counterfactual operators, defining `box_c` and `diamond_m` semantics and integration points.
- **Acceptance Criteria**:
  - [ ] Draft plan describing operators, semantics, and required modules
  - [ ] Architecture updated with Layer 1 scope and assumptions
  - [ ] Clear follow-on tasks identified
- **Impact**: Provides roadmap for counterfactual extensions post Layer 0.

---

### 140. Draft Layer 2 epistemic operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 2 epistemic operators (`K`, `B`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 2 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Establishes roadmap for epistemic extensions.

---

### 141. Draft Layer 3 normative operator plan
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Low
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Documentation/UserGuide/ARCHITECTURE.md
  - Documentation/UserGuide/METHODOLOGY.md
- **Description**: Draft a plan for Layer 3 normative operators (`O`, `P`) including semantics and proof obligations.
- **Acceptance Criteria**:
  - [ ] Draft plan outlines semantics, target theorems, and module impacts
  - [ ] Architecture updated with Layer 3 scope and assumptions
  - [ ] Follow-on tasks identified
- **Impact**: Provides a roadmap for normative logic extensions.

---

### 175. Establish CI/CD pipeline with automated testing and linting
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .github/workflows/ci.yml (new)
  - .github/workflows/lint.yml (new)
  - .github/workflows/coverage.yml (new)
  - Documentation/Development/CI_CD_PROCESS.md (new)
- **Description**: Create GitHub Actions workflows for continuous integration and deployment. Currently all tests run manually. CI/CD pipeline should run tests, linting, style checks, coverage reporting, and documentation build checks automatically on every pull request and commit.
- **Acceptance Criteria**:
  - [ ] GitHub Actions workflow for tests created and passing
  - [ ] Linting and style checks integrated into CI
  - [ ] Coverage reporting integrated into CI
  - [ ] Documentation build checks integrated into CI
  - [ ] CI runs on all pull requests and commits to main
  - [ ] CI failure blocks merge
  - [ ] CI/CD process documented in CI_CD_PROCESS.md
- **Impact**: Ensures code quality automatically, prevents regressions, and enables confident merging of pull requests. Essential for maintaining production-ready code.

---

### 176. Enhance proof search with domain-specific heuristics and caching
- **Effort**: 18 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - Logos/Core/Automation/ProofSearch.lean
  - Logos/Core/Automation/ProofSearchHeuristics.lean (new)
  - Logos/Core/Automation/ProofCache.lean (new)
  - LogosTest/Core/Automation/ProofSearchHeuristicsTest.lean (new)
- **Description**: Enhance ProofSearch.lean with modal-specific and temporal-specific heuristics, proof caching with hash-consing, and success pattern learning. Current heuristics are basic (Task 127 complete). Domain-specific optimizations will significantly improve proof search effectiveness.
- **Acceptance Criteria**:
  - [ ] Modal-specific heuristics implemented (prefer S5 axioms for modal goals)
  - [ ] Temporal-specific heuristics implemented (prefer temporal axioms for temporal goals)
  - [ ] Proof caching with hash-consing implemented
  - [ ] Success pattern learning implemented
  - [ ] Heuristics tested and benchmarked
  - [ ] Documentation for heuristic tuning added
- **Impact**: Improves automation effectiveness by tailoring proof search to the structure of modal and temporal problems, reducing search time and increasing success rate.

---

### 178. Complete advanced tutorial sections with hands-on exercises
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 172
- **Files Affected**:
  - Documentation/UserGuide/TUTORIAL.md
  - Documentation/UserGuide/TUTORIAL_EXERCISES.md (new)
  - Documentation/UserGuide/TROUBLESHOOTING.md (new)
- **Description**: Enhance TUTORIAL.md with advanced sections on proof search automation, custom tactic development, and metalogic. Add hands-on exercises with solutions and a troubleshooting guide. Current tutorial is basic and lacks advanced topics.
- **Acceptance Criteria**:
  - [ ] Advanced tutorial section on proof search and automation added
  - [ ] Advanced tutorial section on custom tactic development added
  - [ ] Advanced tutorial section on metalogic and soundness added
  - [ ] Hands-on exercises with solutions added
  - [ ] Troubleshooting guide created
  - [ ] Tutorial tested with new users for clarity
- **Impact**: Improves onboarding by providing comprehensive learning path from basics to advanced topics with practical exercises.

---

### 179. Implement performance benchmarks for proof search and derivation
- **Effort**: 13 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - LogosBench/ (new directory)
  - LogosBench/ProofSearchBench.lean (new)
  - LogosBench/DerivationBench.lean (new)
  - LogosBench/SemanticEvaluationBench.lean (new)
  - Documentation/Development/PERFORMANCE_TARGETS.md (new)
- **Description**: Create performance benchmark suite for proof search, derivation, and semantic evaluation. Add performance regression testing to CI. Currently no benchmarks exist and performance could regress unnoticed. Document performance targets.
- **Acceptance Criteria**:
  - [ ] Benchmark suite for proof search created
  - [ ] Benchmark suite for derivation created
  - [ ] Benchmark suite for semantic evaluation created
  - [ ] Performance regression testing added to CI
  - [ ] Performance targets documented
  - [ ] Baseline performance measurements recorded
- **Impact**: Ensures performance doesn't regress and provides data for optimization efforts. Critical for maintaining usable proof search times.

---

### 180. Add test coverage metrics and reporting
- **Effort**: 9 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: 175
- **Files Affected**:
  - .github/workflows/coverage.yml
  - scripts/GenerateCoverage.lean (new)
  - Documentation/Development/TEST_COVERAGE.md (new)
- **Description**: Integrate test coverage measurement tool, generate coverage reports, add coverage reporting to CI, and create coverage improvement plan. TESTING_STANDARDS.md defines target of at least 85 percent but no measurement exists.
- **Acceptance Criteria**:
  - [ ] Coverage measurement tool integrated
  - [ ] Coverage reports generated automatically
  - [ ] Coverage reporting integrated into CI
  - [ ] Coverage improvement plan created
  - [ ] Coverage measurement process documented
  - [ ] Current coverage baseline established
- **Impact**: Enables data-driven test improvement by identifying untested code paths and tracking coverage over time.

---

### 189. Add --divide flag to /research command for topic subdivision
- **Effort**: 3 hours
- **Status**: [IN PROGRESS]
- **Started**: 2025-12-26
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Research Artifacts**:
  - Main Report: [.opencode/specs/189_research_divide_flag/reports/research-001.md]
  - Summary: [.opencode/specs/189_research_divide_flag/summaries/research-summary.md]
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/specialists/web-research-specialist.md
- **Description**: Add a --divide flag to the /research command that changes its behavior. Without --divide, /research should create individual research reports only (no research summary). With --divide, /research should invoke a subagent to divide the research topic into natural subtopics, pass each subtopic to further research subagents to research and create individual reports, then compile the references and brief summaries into a research summary report. The research summary should contain only references to the individual reports and their brief summaries, not duplicate the full content.
- **Acceptance Criteria**:
  - [ ] --divide flag added to /research command documentation and input parsing
  - [ ] Without --divide: /research creates only individual research reports (reports/research-NNN.md), no summary
  - [ ] With --divide: /research divides topic into subtopics using a subagent
  - [ ] With --divide: Each subtopic is researched by a separate subagent, creating individual reports
  - [ ] With --divide: Research summary report (summaries/research-summary.md) is created compiling references and brief summaries
  - [ ] Research summary contains only references and brief summaries, not full content
  - [ ] All behavior follows lazy directory creation (create summaries/ only when writing summary)
  - [ ] Status markers and state sync work correctly for both modes
  - [ ] Documentation updated to explain --divide flag behavior
- **Impact**: Provides more flexible research workflow - simple research creates focused reports without overhead of summary compilation, while complex research can be divided into manageable subtopics with a summary overview.

---

### 203. Add --complex flag to /research for subtopic subdivision with summary
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/agent/subagents/researcher.md
  - .opencode/agent/subagents/lean-research-agent.md
- **Description**: Enhance the /research command to support a --complex flag that changes its behavior for handling complex research topics. Without --complex flag: /research creates a single research report (reports/research-001.md) with no summary - this is the current default behavior. With --complex flag: /research should (1) Divide the topic into 1-5 appropriate subtopics using intelligent analysis, (2) Spawn research subagents to complete each subtopic in parallel, creating individual research reports (reports/research-001.md, reports/research-002.md, etc.), (3) Each subagent returns only its report path and brief summary (not full content) to the primary agent, (4) Primary agent compiles all report paths and brief summaries into a research summary report (summaries/research-summary.md), (5) Update TODO.md and state.json with all report references and mark task as [RESEARCHED]. The --complex flag enables comprehensive research on large topics while protecting context windows through summarization.
- **Acceptance Criteria**:
  - [ ] --complex flag added to /research command argument parsing
  - [ ] Without --complex: /research creates single report, no summary (current behavior preserved)
  - [ ] With --complex: Topic intelligently divided into 1-5 subtopics
  - [ ] With --complex: Separate research subagents spawned for each subtopic
  - [ ] With --complex: Each subtopic generates individual report (reports/research-NNN.md)
  - [ ] With --complex: Subagents return only report path + brief summary (not full content)
  - [ ] With --complex: Primary agent creates research summary (summaries/research-summary.md) compiling all references
  - [ ] Research summary contains only paths and brief summaries, not duplicated full content
  - [ ] Lazy directory creation followed (summaries/ created only when writing summary)
  - [ ] TODO.md updated with all report references and [RESEARCHED] status for both modes
  - [ ] state.json updated correctly for both modes
  - [ ] Documentation explains --complex flag behavior and use cases
- **Impact**: Enables comprehensive research on complex topics by dividing them into manageable subtopics while protecting the primary agent's context window through summarization. Provides flexibility - simple topics get focused single reports, complex topics get thorough multi-report coverage with summary overview.

---

### 205. Implement Lean tool usage verification and monitoring system
- **Effort**: 6-8 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None
- **Files Affected**:
  - .opencode/command/research.md
  - .opencode/command/implement.md
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - .opencode/context/core/standards/lean-tool-verification.md (new)
  - .opencode/specs/monitoring/ (new directory structure)
- **Description**: Design and implement a comprehensive monitoring and verification system to detect and validate that Lean-specific tools (lean-lsp-mcp, Loogle, LeanExplore, LeanSearch) are being correctly used by the appropriate commands and agents when processing Lean tasks. The system should provide visibility into tool usage patterns, detect routing errors, track tool availability issues, and identify opportunities for improvement. This includes creating verification methods, logging standards, monitoring dashboards, and automated health checks to ensure the system is working optimally.
- **Acceptance Criteria**:
  - [ ] Verification method identified for detecting lean-lsp-mcp usage in /implement command for Lean tasks
  - [ ] Verification method identified for detecting Loogle usage in /research command for Lean tasks
  - [ ] Automated tool availability checks implemented (binary existence, process health, API connectivity)
  - [ ] Tool usage logging standardized in lean-research-agent and lean-implementation-agent return formats
  - [ ] Monitoring dashboard or report created showing tool usage metrics per command execution
  - [ ] Health check command or script created to verify routing is working correctly
  - [ ] Documentation created explaining verification methods and monitoring approach
  - [ ] Error detection implemented for cases where tools should be used but aren't (routing failures)
  - [ ] Recommendations provided for system improvements based on monitoring data
  - [ ] All verification methods tested with real command executions on Lean tasks
- **Impact**: Provides visibility and confidence that the Lean tool integration is working correctly, enables early detection of routing or configuration issues, and identifies opportunities to improve the system's effectiveness with Lean-specific research and implementation workflows.

---

### 218. Fix lean-lsp-mcp integration and opencode module import errors
**Effort**: 0.75 hours
**Status**: [PLANNED]
**Started**: 2025-12-28
**Researched**: 2025-12-28
**Priority**: High
**Blocking**: None
**Dependencies**: 212 (completed)
**Language**: python
**Research Artifacts**:
  - Main Report: [.opencode/specs/218_fix_lean_lsp_mcp_integration/reports/research-002.md]
**Research Findings** (2025-12-28): CRITICAL DISCOVERY: OpenCode has native MCP support via opencode.json configuration, NOT .mcp.json. Task 212's custom Python MCP client approach is architecturally incompatible - OpenCode agents use natural language tool instructions, not Python imports. The ModuleNotFoundError is a symptom of wrong architectural approach, not missing __init__.py files. Solution requires complete pivot from Python-based integration to configuration-based integration: (1) Create opencode.json with lean-lsp-mcp server configuration, (2) Update lean-implementation-agent.md to use natural language MCP tool instructions instead of Python imports, (3) Remove custom MCP client from task 212 (architecturally incompatible). Proper approach enables 15+ lean-lsp-mcp tools (compile, check-proof, search, etc.) via native OpenCode MCP bridge. Previous plan obsolete - new configuration-based approach estimated 1-2 hours.

**Files Affected**:
- opencode.json (new, MCP server configuration)
- .opencode/agent/subagents/lean-implementation-agent.md (update to use MCP tool instructions)
- .opencode/agent/subagents/lean-research-agent.md (update to use MCP tool instructions)
- Documentation/UserGuide/MCP_INTEGRATION.md (new, user guide)
- .opencode/tool/mcp/client.py (mark deprecated, incompatible with OpenCode architecture)

**Description**:
Research revealed that OpenCode has native MCP (Model Context Protocol) support that makes task 212's custom Python MCP client unnecessary and architecturally incompatible. OpenCode agents interact with MCP servers through natural language tool instructions, not Python imports. The proper integration approach uses opencode.json configuration to register MCP servers, making their tools automatically available to agents. This enables lean-implementation-agent to use lean-lsp-mcp's 15+ tools for real-time compilation checking, proof state inspection, and theorem search during Lean proof implementation.

**Acceptance Criteria**:
- [ ] opencode.json created with lean-lsp-mcp server configuration
- [ ] lean-implementation-agent.md updated with MCP tool usage instructions
- [ ] lean-research-agent.md updated with MCP tool usage instructions  
- [ ] MCP integration guide created in user documentation
- [ ] Test Lean task implementation successfully uses lean-lsp-mcp tools
- [ ] No Python import errors (using configuration-based approach)
- [ ] Selective tool enablement reduces context window usage

**Impact**:
CRITICAL ARCHITECTURAL CORRECTION: Pivots from incompatible custom Python client to proper OpenCode-native MCP integration. Enables lean-lsp-mcp tools for real-time Lean compilation checking, proof verification, and theorem search. Reduces context window usage by 2000-5000 tokens through selective per-agent tool enablement. Establishes foundation for additional MCP servers (Context7, Grep) to enhance Lean development workflow.

---


### 279. Systematically fix metadata lookup to use state.json instead of TODO.md
- **Effort**: 12-16 hours
- **Status**: [RESEARCHING] (Started: 2026-01-03)
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**:
When running `/implement 276`, the command output showed "Extract task 276 details from TODO.md" which indicates that commands and subagents are extracting metadata from TODO.md instead of from the authoritative source (specs/state.json). TODO.md should be kept in sync as a user-facing version of state.json, but all metadata lookups should reference state.json as the single source of truth.

**Current Behavior**:
```bash
/implement 276
# Output shows: "Extract task 276 details from TODO.md"
# Problem: Using TODO.md for metadata lookup instead of state.json
```

**Expected Behavior**:
```bash
/implement 276
# Should: Extract task 276 metadata from state.json
# Should: Use state.json as single source of truth
# Should: Update TODO.md to reflect state.json changes (sync direction: state.json → TODO.md)
```

**Root Cause Analysis**:

Comprehensive codebase search reveals widespread use of TODO.md for metadata extraction:

1. **Orchestrator** (`.opencode/agent/orchestrator.md`):
   - Stage 2 (DetermineRouting): "Extract language from state.json or TODO.md"
   - Should be: Extract language from state.json ONLY

2. **Workflow Commands** (4 files):
   - `/research` - "Extract language from task entry (state.json or TODO.md)"
   - `/plan` - "Extract language from task entry (state.json or TODO.md)"
   - `/implement` - "Extract language from task entry (state.json or TODO.md)"
   - `/revise` - "Extract language from task entry (state.json or TODO.md)"
   - Should be: Extract from state.json ONLY

3. **Subagents** (7 files):
   - `researcher.md` - "Extract language from state.json (fallback to TODO.md)"
   - `planner.md` - "Read task from .opencode/specs/TODO.md"
   - `implementer.md` - "grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md"
   - `lean-research-agent.md` - "Extract language from state.json (fallback to TODO.md)"
   - `lean-implementation-agent.md` - "Read task from .opencode/specs/TODO.md"
   - `lean-planner.md` - "Read task from .opencode/specs/TODO.md"
   - `status-sync-manager.md` - "Extract current status from .opencode/specs/TODO.md"
   - Should be: Extract from state.json ONLY

4. **Context Files** (6 files):
   - `routing-guide.md` - "Extract language from task entry in TODO.md"
   - `routing-logic.md` - "task_entry=$(grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md)"
   - `research-workflow.md` - "Read task from TODO.md using grep"
   - `planning-workflow.md` - "Read task from TODO.md using grep"
   - `implementation-workflow.md` - "Read task from TODO.md using grep"
   - `subagent-structure.md` - "Read task from TODO.md"
   - Should be: Document state.json as source of truth

**Metadata Fields Affected**:

The following metadata fields are currently extracted from TODO.md but should come from state.json:

1. **Language** - Used for routing to Lean-specific agents
2. **Priority** - Used for task prioritization
3. **Status** - Used for workflow state tracking
4. **Effort** - Used for estimation
5. **Dependencies** - Used for task ordering
6. **Blocking** - Used for identifying blockers
7. **Description** - Used for task context
8. **Artifacts** - Used for linking research/plans/implementations

**Correct Architecture**:

```
state.json (authoritative source)
    ↓
    | (read metadata)
    ↓
Commands/Subagents
    ↓
    | (update metadata)
    ↓
status-sync-manager
    ↓
    | (atomic two-phase commit)
    ↓
state.json + TODO.md (synchronized)
```

**Sync Direction**: state.json → TODO.md (NOT bidirectional)

**Files to Modify** (25 files total):

**Orchestrator** (1 file):
- `.opencode/agent/orchestrator.md` - Update Stage 2 to extract language from state.json only

**Commands** (4 files):
- `.opencode/command/research.md` - Update Stage 1 to read from state.json
- `.opencode/command/plan.md` - Update Stage 1 to read from state.json
- `.opencode/command/implement.md` - Update Stage 1 to read from state.json
- `.opencode/command/revise.md` - Update Stage 1 to read from state.json

**Subagents** (7 files):
- `.opencode/agent/subagents/researcher.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/implementer.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-research-agent.md` - Remove TODO.md fallback, use state.json only
- `.opencode/agent/subagents/lean-implementation-agent.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/lean-planner.md` - Replace grep TODO.md with jq state.json
- `.opencode/agent/subagents/status-sync-manager.md` - Extract status from state.json, not TODO.md

**Context Files** (6 files):
- `.opencode/context/core/system/routing-guide.md` - Document state.json as source
- `.opencode/context/core/system/routing-logic.md` - Update examples to use state.json
- `.opencode/context/project/processes/research-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/planning-workflow.md` - Update to use state.json
- `.opencode/context/project/processes/implementation-workflow.md` - Update to use state.json
- `.opencode/context/core/standards/subagent-structure.md` - Document state.json pattern

**Standards** (2 files):
- `.opencode/context/core/system/state-management.md` - Clarify state.json as authoritative source
- `.opencode/context/core/system/artifact-management.md` - Document metadata lookup pattern

**Templates** (1 file):
- `.opencode/context/core/templates/command-template.md` - Update template to use state.json

**Documentation** (4 files):
- `.opencode/docs/guides/creating-commands.md` - Update examples to use state.json
- `.opencode/ARCHITECTURE.md` - Document state.json as source of truth
- `.opencode/REFACTOR.md` - Update refactoring notes
- `.opencode/REBUILD_SUMMARY.md` - Update rebuild notes

**Implementation Strategy**:

**Phase 1: Update Metadata Extraction Pattern** (4 hours)
1. Create helper function for state.json metadata extraction:
   ```bash
   # Extract task metadata from state.json
   task_metadata=$(jq -r --arg task_num "$task_number" \
     '.active_projects[] | select(.project_number == ($task_num | tonumber))' \
     .opencode/specs/state.json)
   
   # Extract specific fields
   language=$(echo "$task_metadata" | jq -r '.language // "general"')
   priority=$(echo "$task_metadata" | jq -r '.priority // "medium"')
   status=$(echo "$task_metadata" | jq -r '.status // "not_started"')
   ```

2. Document pattern in state-management.md
3. Create examples in routing-guide.md

**Phase 2: Update Orchestrator and Commands** (3 hours)
1. Update orchestrator.md Stage 2 (DetermineRouting)
2. Update research.md Stage 1 (PreflightValidation)
3. Update plan.md Stage 1 (PreflightValidation)
4. Update implement.md Stage 1 (PreflightValidation)
5. Update revise.md Stage 1 (PreflightValidation)

**Phase 3: Update Subagents** (4 hours)
1. Update researcher.md - Remove TODO.md fallback
2. Update planner.md - Replace grep with jq
3. Update implementer.md - Replace grep with jq
4. Update lean-research-agent.md - Remove TODO.md fallback
5. Update lean-implementation-agent.md - Replace grep with jq
6. Update lean-planner.md - Replace grep with jq
7. Update status-sync-manager.md - Extract status from state.json

**Phase 4: Update Context and Documentation** (3 hours)
1. Update 6 context files (routing, workflows, standards)
2. Update 2 standards files (state-management, artifact-management)
3. Update 1 template file (command-template)
4. Update 4 documentation files (guides, architecture, notes)

**Phase 5: Testing and Validation** (2 hours)
1. Test /research command with Lean task (language routing)
2. Test /plan command with markdown task
3. Test /implement command with general task
4. Test /revise command
5. Verify metadata extracted from state.json, not TODO.md
6. Verify TODO.md still synchronized correctly
7. Verify no grep TODO.md commands in output

**Acceptance Criteria**:
- [ ] All metadata extraction uses state.json as source of truth
- [ ] No commands or subagents extract metadata from TODO.md
- [ ] TODO.md remains synchronized via status-sync-manager (state.json → TODO.md)
- [ ] Language-based routing works correctly (Lean tasks → lean-research-agent)
- [ ] All workflow commands tested and verified
- [ ] Context files document state.json as authoritative source
- [ ] No "Extract task NNN details from TODO.md" messages in command output
- [ ] grep TODO.md only used for validation/testing, not metadata extraction

**Impact**: 
Establishes state.json as the single source of truth for task metadata, eliminating confusion about which file is authoritative. Ensures TODO.md is kept in sync as a user-facing view of state.json, but all programmatic access uses state.json. Fixes the issue observed in /implement 276 where TODO.md was being used for metadata lookup.

**Related Tasks**:
- Task 276: Investigate redundant project-level state.json files (related to state management)
- Task 272: Add YAML header to TODO.md (sync state.json → TODO.md)
- Task 275: Fix workflow status updates (uses status-sync-manager)

---

### 287. Fix /revise command to replace old plan link instead of appending new link
- **Effort**: 2-3 hours
- **Status**: [PLANNED] (2026-01-04)
- **Priority**: Medium
- **Language**: general
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](287_fix_revise_command_plan_link_replacement/reports/research-001.md)
- **Plan**: [Implementation Plan](287_fix_revise_command_plan_link_replacement/plans/implementation-001.md)

**Description**:
When running `/revise` for a task that already has a plan, the command appends the new plan link to the existing plan link instead of replacing it. This creates confusing entries like:

```
- **Plan**: [Implementation Plan v1](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md) | [Implementation Plan v2](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md) (current)
```

Instead, the `/revise` command should replace the old plan link with the new plan link to avoid confusion. The old plan file should remain in the project directory for reference if needed, but only the current plan should be linked in TODO.md.

**Expected Behavior**:
```
# Before /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md)

# After /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md)

# Old plan file still exists at:
# .opencode/specs/283_fix_systematic_status_synchronization_failure/plans/implementation-001.md
```

**Current Behavior**:
```
# Before /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md)

# After /revise:
- **Plan**: [Implementation Plan v1](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md) | [Implementation Plan v2](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md) (current)
```

**Files to Modify**:
- `.opencode/command/revise.md` - Update plan link replacement logic
- `.opencode/agent/subagents/planner.md` - Update plan link update behavior (if responsible)
- `.opencode/agent/subagents/status-sync-manager.md` - Update plan link synchronization (if responsible)

**Acceptance Criteria**:
- [ ] `/revise` replaces old plan link with new plan link in TODO.md
- [ ] Old plan file remains in project directory for reference
- [ ] Only current plan link shown in TODO.md (no "v1 | v2 (current)" format)
- [ ] state.json updated with new plan_path
- [ ] No regression in existing /revise functionality
- [ ] Tested with tasks that have existing plans

**Impact**: 
Simplifies TODO.md plan links by showing only the current plan, avoiding confusion from multiple plan versions. Old plans remain available in the project directory for reference but don't clutter the task entry.

**Related Tasks**:
- Task 283: Example task showing the current appending behavior
- Task 275: Fix workflow status updates (related to status-sync-manager)

---

### 289. Extend Task 283 fix to all remaining subagents with inconsistent step naming
- **Started**: 2026-01-04
- **Completed**: 2026-01-04
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Priority**: High
- **Implementation Artifacts**:
  - .opencode/agent/subagents/lean-research-agent.md
  - .opencode/agent/subagents/lean-planner.md
  - .opencode/agent/subagents/lean-implementation-agent.md
  - Summary: .opencode/specs/289_extend_task_283_fix/summaries/implementation-summary-20260104.md
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 283 (completed)

**Description**:
Task 283 successfully fixed general subagents (researcher, planner, implementer) by standardizing from `stage_1_preflight` to `step_0_preflight`. However, research on task 285 revealed that Lean subagents (lean-research-agent, lean-planner, lean-implementation-agent) still use inconsistent `<step_1>` naming instead of `<step_0_preflight>`. This causes the same status synchronization failure for Lean tasks.

**Evidence of Remaining Issues**:

1. **Task 285 /research failure**:
   - Research completed successfully but status NOT updated
   - Artifact links NOT added to TODO.md
   - state.json NOT updated
   - Same pattern as pre-Task 283 failures

2. **Research findings from task 285**:
   - General subagents use `<step_0_preflight>` consistently (Task 283 fix working)
   - Lean subagents use `<step_1>` instead of `<step_0_preflight>` (inconsistent)
   - Lean subagents update TODO.md directly instead of delegating to status-sync-manager
   - Task 259 failure explained by lean-research-agent using `<step_1>` naming

**Root Cause**:
Task 283 only fixed the general subagents but did not audit or fix the Lean-specific subagents. The Lean subagents have TWO issues:
1. **Naming inconsistency**: Use `<step_1>` instead of `<step_0_preflight>`
2. **Direct TODO.md updates**: Update TODO.md directly instead of delegating to status-sync-manager

**Affected Subagents**:
- `.opencode/agent/subagents/lean-research-agent.md`
- `.opencode/agent/subagents/lean-planner.md`
- `.opencode/agent/subagents/lean-implementation-agent.md`

**Fix Strategy**:

**Phase 1: Audit All Subagents** (30 minutes)
1. Search all subagent files for step naming patterns
2. Identify all subagents with inconsistent naming
3. Document findings in audit report

**Phase 2: Standardize Lean Subagent Naming** (1 hour)
1. Update lean-research-agent.md: Change `<step_1>` to `<step_0_preflight>`
2. Update lean-planner.md: Change `<step_1>` to `<step_0_preflight>`
3. Update lean-implementation-agent.md: Change `<step_1>` to `<step_0_preflight>`

**Phase 3: Fix Direct TODO.md Updates** (1 hour)
1. Review Lean subagents for direct TODO.md updates
2. Replace direct updates with status-sync-manager delegation
3. Ensure atomic updates across TODO.md and state.json

**Phase 4: Update Documentation** (30 minutes)
1. Update subagent-structure.md with Lean subagent examples
2. Document the `<step_0_preflight>` standard for ALL subagents
3. Add validation checklist for new subagents

**Files to Modify**:
- `.opencode/agent/subagents/lean-research-agent.md`
- `.opencode/agent/subagents/lean-planner.md`
- `.opencode/agent/subagents/lean-implementation-agent.md`
- `.opencode/context/core/standards/subagent-structure.md`

**Acceptance Criteria**:
- [ ] All subagents use `<step_0_preflight>` naming consistently
- [ ] No subagents use `<step_1>` or `stage_` naming
- [ ] Lean subagents delegate to status-sync-manager (no direct TODO.md updates)
- [ ] /research on Lean tasks updates status correctly
- [ ] /plan on Lean tasks updates status correctly
- [ ] /implement on Lean tasks updates status correctly
- [ ] Task 259 (Lean task) can be researched without status update failures
- [ ] Documentation updated with Lean subagent examples

**Impact**: 
Completes the systematic fix started in Task 283 by extending it to all remaining subagents. Ensures consistent status synchronization across ALL workflow commands for ALL task types (general, markdown, Lean). Fixes the root cause of task 285 and task 259 failures.

**Related Tasks**:
- Task 283: Fix systematic status synchronization failure (completed - fixed general subagents only)
- Task 285: Audit and fix status update behavior (research revealed Lean subagent issues)
- Task 259: Automation Tactics (Lean task that likely failed due to lean-research-agent naming issue)

---

### 288. Fix command confusion and status synchronization issues
- **Effort**: TBD
- **Status**: [ABANDONED]
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

**Description**: Systematically fix command confusion and status synchronization issues identified when running `/implement 259`. Root causes include: (1) Agents recommending incorrect commands (e.g., suggesting `/task 259` instead of `/implement 259`), (2) Status not being updated from `[PLANNED]` to `[IMPLEMENTING]` or `[COMPLETED]`, (3) No validation to prevent incorrect command recommendations, (4) Missing centralized command purpose documentation. Solution should include: creating command reference guide, adding validation to prevent incorrect recommendations, enforcing status updates with validation, and updating all affected command and agent files for uniformity and consistency.

---

### 290. Fix lean-research-agent preflight status updates and artifact linking to match standard workflow behavior
- **Effort**: 2.5 hours
- **Status**: [IMPLEMENTING]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Planned**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 289 (completed)
- **Research**: [Research Report](.opencode/specs/290_fix_lean_research_agent_preflight_status_updates_and_artifact_linking/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/290_fix_lean_research_agent_preflight_status_updates_and_artifact_linking/plans/implementation-001.md)

**Description**:
After fixing the step naming inconsistency in Task 289, `/research 260` (a Lean task) still exhibits two issues that differ from the standard workflow behavior seen in `/plan` and `/research` on non-Lean tasks:

1. **Missing preflight status update**: Status is NOT updated to `[RESEARCHING]` when research starts (only updated to `[RESEARCHED]` at the end)
2. **Unnecessary summary artifact**: Creates and links both a research report AND a summary (old behavior), when only the research report should be created and linked

**Research Findings**:
Research revealed that the actual root cause is NOT missing preflight status updates (Task 289 fix is working). The real issues are:
1. **Outdated documentation in lean-research-agent.md** requiring summary artifact creation
2. **Direct file manipulation** instead of delegating to status-sync-manager and git-workflow-manager

**Root Cause** (from research):
lean-research-agent.md step_6 (lines 641-750):
- Lines 651-657: Directly updates TODO.md status marker
- Lines 658-662: Directly updates state.json
- Does NOT delegate to status-sync-manager
- Does NOT delegate to git-workflow-manager
- Lines 647-649, 657, 664, 686-688: Requires summary artifact creation (outdated)

**Recommended Fix**:
1. Replace direct file updates with status-sync-manager delegation (matching researcher.md)
2. Remove summary artifact requirements
3. Add git-workflow-manager delegation for automatic commits

**Related Tasks**:
- Task 283: Fixed general subagents step naming (completed)
- Task 289: Fixed Lean subagents step naming (completed)
- Task 291: Implementation task for this fix

---

### 291. Fix lean-research-agent to delegate status updates to status-sync-manager instead of direct file manipulation
- **Effort**: 2-3 hours
- **Status**: [RESEARCHED]
- **Started**: 2026-01-04
- **Researched**: 2026-01-04
- **Priority**: High
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: Task 290 (researched)
- **Research**: [Research Report](.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md)

**Description**:
Root cause identified for `/research 290` status update failure: lean-research-agent.md directly manipulates TODO.md and state.json files (lines 651-662) instead of delegating to status-sync-manager and git-workflow-manager like researcher.md does. This bypasses atomic updates and causes status synchronization failures.

**Evidence**:
- `/research 290` created research report successfully
- Status remained `[NOT STARTED]` instead of updating to `[RESEARCHED]`
- No artifact link added to TODO.md
- No state.json update
- No git commit created

**Root Cause**:
lean-research-agent.md step_6 (lines 641-750):
- Line 651-657: Directly updates TODO.md status marker
- Line 658-662: Directly updates state.json
- Does NOT delegate to status-sync-manager
- Does NOT delegate to git-workflow-manager

Compare with researcher.md step_4_postflight (lines 331-379):
- Line 335: Invokes status-sync-manager to mark [RESEARCHED]
- Line 349: Invokes git-workflow-manager to create commit
- Proper delegation ensures atomic updates

**Fix Strategy**:

**Phase 1: Update lean-research-agent step_6 to match researcher step_4_postflight** (1.5 hours)
1. Replace direct TODO.md updates with status-sync-manager delegation:
   - Remove lines 651-657 (direct TODO.md manipulation)
   - Add status-sync-manager invocation matching researcher.md line 335-348
   - Pass validated_artifacts array to status-sync-manager
2. Replace direct state.json updates with status-sync-manager delegation:
   - Remove lines 658-662 (direct state.json manipulation)
   - status-sync-manager handles both TODO.md and state.json atomically
3. Add git-workflow-manager delegation:
   - Add git-workflow-manager invocation matching researcher.md line 349-368
   - Pass scope_files including research report, TODO.md, state.json
4. Update step_6 documentation to reflect delegation pattern

**Phase 2: Remove summary artifact requirement** (30 minutes)
1. Remove summary artifact validation (line 647-649):
   - Remove "Verify summary artifact created" check
   - Remove "Verify summary artifact is <100 tokens" check
2. Remove summary artifact linking (line 657, 664, 686-688):
   - Remove summary from artifact links in TODO.md
   - Remove summary from state.json artifacts array
3. Update return format to list only research report (line 664)
4. Match researcher.md behavior (single artifact only)

**Phase 3: Test with Lean task** (1 hour)
1. Test `/research` on a Lean task (e.g., task 260)
2. Verify status updates to `[RESEARCHING]` at start
3. Verify status updates to `[RESEARCHED]` at end
4. Verify artifact link added to TODO.md (research report only, no summary)
5. Verify state.json updated with artifact path
6. Verify git commit created
7. Verify no regression in research quality

**Files to Modify**:
- `.opencode/agent/subagents/lean-research-agent.md` - Update step_6 to delegate to status-sync-manager and git-workflow-manager

**Acceptance Criteria**:
- [ ] lean-research-agent step_6 delegates to status-sync-manager (not direct file updates)
- [ ] lean-research-agent step_6 delegates to git-workflow-manager (not manual git commands)
- [ ] Summary artifact requirement removed (only research report created)
- [ ] `/research` on Lean tasks updates status to `[RESEARCHING]` at start
- [ ] `/research` on Lean tasks updates status to `[RESEARCHED]` at end
- [ ] Artifact link added to TODO.md (research report only)
- [ ] state.json updated with artifact path
- [ ] Git commit created automatically
- [ ] Behavior matches researcher.md exactly
- [ ] No regression in Lean research functionality

**Impact**: 
Fixes the root cause of status synchronization failures for Lean tasks. Ensures lean-research-agent uses the same atomic update pattern as researcher.md via status-sync-manager and git-workflow-manager delegation. Eliminates direct file manipulation that bypasses validation and atomic updates.

**Related Tasks**:
- Task 283: Fixed general subagents step naming (completed)
- Task 289: Fixed Lean subagents step naming (completed)
- Task 290: Identified this root cause through research

---

### 292. Diagnose and fix /implement 259 command failure - orchestrator unable to extract $ARGUMENTS
- **Effort**: 2-3 hours
- **Status**: [PLANNED] (2026-01-04)
- **Priority**: High
- **Language**: general
- **Blocking**: None
- **Dependencies**: None
- **Research**: [Research Report](.opencode/specs/292_diagnose_and_fix_implement_259_command_failure/reports/research-001.md)
- **Plan**: [Implementation Plan](.opencode/specs/292_diagnose_and_fix_implement_259_command_failure/plans/implementation-001.md)

**Description**:
When running `/implement 259`, the orchestrator workflow fails at Stage 1 (PreflightValidation) while attempting to extract the `$ARGUMENTS` variable. The command output shows:

```
I'll execute the /implement command by following the orchestrator workflow stages.

Stage 1: PreflightValidation

→ Read .opencode/command/implement.md

┃
┃  # Extract $ARGUMENTS variable
┃
┃  $ echo "$ARGUMENTS"
```

The command appears to hang or fail at this point without completing the argument extraction or proceeding to subsequent stages.

**Expected Behavior**:
```bash
/implement 259
# Stage 1: Extract task number 259 from $ARGUMENTS
# Stage 2: Determine routing (language-based routing to lean-implementation-agent)
# Stage 3: Register session and invoke lean-implementation-agent
# Stage 4: Validate return format and artifacts
# Stage 5: Update status and return result to user
```

**Current Behavior**:
```bash
/implement 259
# Stage 1: Starts PreflightValidation
# Stage 1: Attempts to extract $ARGUMENTS
# Stage 1: FAILS or HANGS - no output after "$ echo "$ARGUMENTS""
# No subsequent stages executed
```

**Potential Root Causes**:

1. **$ARGUMENTS Variable Not Set**:
   - OpenCode may not be passing the `$ARGUMENTS` variable to the orchestrator
   - The variable may be empty or undefined
   - Task 281 fixed a similar issue in `/implement` command (missing `$` prefix)

2. **Orchestrator Stage 1 Logic Error**:
   - Stage 1 (PreflightValidation) may have incorrect argument parsing logic
   - The `echo "$ARGUMENTS"` command may be failing silently
   - Validation may be rejecting valid input

3. **Command File Configuration Error**:
   - `.opencode/command/implement.md` may have incorrect frontmatter
   - Routing configuration may be malformed
   - Agent field may be missing or incorrect

4. **Task Number Validation Failure**:
   - Task 259 may not exist in state.json or TODO.md
   - Task 259 may be in an invalid state (e.g., already completed)
   - Validation logic may be too strict

**Investigation Steps**:

1. **Verify $ARGUMENTS is being passed**:
   - Check if OpenCode is setting the `$ARGUMENTS` variable
   - Compare with working commands (`/research`, `/plan`, `/revise`)
   - Test with simple echo command to verify variable exists

2. **Verify task 259 exists and is valid**:
   - Check state.json for task 259 entry
   - Check TODO.md for task 259 entry
   - Verify task status is `[PLANNED]` (ready for implementation)

3. **Review orchestrator Stage 1 logic**:
   - Read `.opencode/agent/orchestrator.md` Stage 1 (PreflightValidation)
   - Check argument parsing logic
   - Check validation rules
   - Compare with working commands

4. **Review /implement command configuration**:
   - Read `.opencode/command/implement.md` frontmatter
   - Verify routing configuration
   - Verify agent field is correct
   - Compare with working commands

5. **Test with different task numbers**:
   - Try `/implement 260` (another Lean task)
   - Try `/implement 287` (a general task)
   - Determine if issue is specific to task 259 or affects all tasks

**Files to Investigate**:
- `.opencode/agent/orchestrator.md` - Stage 1 (PreflightValidation) logic
- `.opencode/command/implement.md` - Command configuration and frontmatter
- `.opencode/specs/state.json` - Verify task 259 exists
- `.opencode/specs/TODO.md` - Verify task 259 status
- `.opencode/context/core/standards/command-argument-handling.md` - Argument parsing standard

**Acceptance Criteria**:
- [ ] Root cause identified (which of the 4 potential causes is the actual issue)
- [ ] Fix implemented and tested
- [ ] `/implement 259` completes successfully
- [ ] Task 259 status updated to `[IMPLEMENTING]` then `[COMPLETED]`
- [ ] No regression in other `/implement` command usage
- [ ] Documentation updated if needed

**Impact**: 
Blocks implementation of task 259 (Automation Tactics) and potentially all other `/implement` command usage. Critical workflow command must be fixed to enable task completion.

**Related Tasks**:
- Task 259: Automation Tactics (blocked by this issue)
- Task 281: Fixed similar $ARGUMENTS issue in `/implement` command (completed)
- Task 285: Audit and fix status update behavior (may be related)

---

## Medium Priority

