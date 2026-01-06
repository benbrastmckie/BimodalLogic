# Research Report: Fix Systematic Postflight Failures in Workflow Commands

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 6-8 hours (estimated)  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**:
- `.opencode/command/research.md` (4 stages, no postflight)
- `.opencode/command/plan.md` (4 stages, no postflight)
- `.opencode/command/implement.md` (4 stages, no postflight)
- `.opencode/command/revise.md` (4 stages, no postflight)
- `.opencode/agent/subagents/researcher.md` (step_4_postflight with delegation)
- `.opencode/agent/subagents/planner.md` (step_7 with delegation)
- `.opencode/agent/subagents/lean-research-agent.md` (step_7 with delegation)
- `.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md`
- `.opencode/specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/` (evidence)
- Git log analysis (2026-01-05)

**Artifacts**:
- `.opencode/specs/320_fix_workflow_command_postflight_failures_causing_missing_artifact_links_and_status_updates/reports/research-001.md`

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md, delegation.md, subagent-return-format.md

---

## Executive Summary

Systematic investigation reveals that postflight failures in workflow commands (/research, /plan, /revise, /implement) are NOT caused by missing postflight steps in subagents. The root cause is architectural: **workflow commands delegate to subagents but do not verify that postflight work completed successfully**. Subagents (researcher.md, planner.md) DO have postflight steps that invoke status-sync-manager and git-workflow-manager, but if these delegations fail silently or return errors, the command has no mechanism to detect or handle the failure.

Evidence: Task 314 research created artifact at 08:34 on 2026-01-05, but no git commit exists in log, and TODO.md shows status [RESEARCHED] with artifact link (indicating partial success). This suggests postflight steps executed partially but failed at git commit stage.

**Key Finding**: The issue is not "postflight steps not executing" but rather "postflight failures not surfaced to command level for handling."

---

## Context & Scope

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) exhibit systematic failures where:

1. Artifacts are created successfully (research-001.md, implementation-001.md, etc.)
2. Status is NOT updated in TODO.md and state.json (remains [NOT STARTED])
3. Artifact links are NOT added to TODO.md
4. Git commits are NOT created

Example from task description:
- `/research 314` created research-001.md successfully
- Task status remained [NOT STARTED] (should be [RESEARCHED])
- No research link in TODO.md
- No git commit

### Hypothesis from Task Description

Task 320 description states: "Root cause: postflight steps (step_4_postflight in researcher, step_7 in planner) are not executing or failing silently."

### Scope

This research investigates:
1. Whether postflight steps exist in subagents
2. Whether postflight steps are being executed
3. Why postflight failures are not surfaced
4. How to ensure atomic postflight completion

---

## Key Findings

### Finding 1: Workflow Commands Have NO Postflight Stages

**Evidence**: All 4 workflow commands have identical 4-stage structure:

**File**: `.opencode/command/research.md`
```xml
<stage id="1" name="ParseAndValidate">
  Parse task number, validate, extract metadata from state.json
</stage>

<stage id="2" name="Delegate">
  Delegate to researcher subagent via task() tool
</stage>

<stage id="3" name="ValidateReturn">
  Validate subagent return format and artifacts
</stage>

<stage id="4" name="RelayResult">
  Relay validated result to user
</stage>
```

**Analysis**: Commands do NOT have postflight stages. They delegate to subagents and expect subagents to handle ALL postflight work (status updates, artifact linking, git commits). This is the "agent workflow ownership" pattern from OpenAgents migration (task 245).

**Implication**: If subagent postflight fails, command has no fallback mechanism.

### Finding 2: Subagents DO Have Postflight Steps with Delegation

**Evidence**: researcher.md has step_4_postflight that invokes status-sync-manager and git-workflow-manager:

**File**: `.opencode/agent/subagents/researcher.md` (lines 296-340)
```xml
<step_4_postflight>
  <action>Postflight: Update status to [RESEARCHED], link report, create git commit</action>
  <process>
    1. Generate completion timestamp: $(date -I)
    2. Invoke status-sync-manager to mark [RESEARCHED]:
       a. Prepare delegation context:
          - task_number: {number}
          - new_status: "researched"
          - timestamp: {date}
          - session_id: {session_id}
          - delegation_depth: {depth + 1}
          - delegation_path: [...delegation_path, "status-sync-manager"]
          - validated_artifacts: [{type, path, summary}]
       b. Invoke status-sync-manager with timeout (60s)
       c. Validate return status == "completed"
       d. Verify files_updated includes ["TODO.md", "state.json"]
       e. Verify artifact linked in TODO.md
       f. If status update fails: Log error but continue (artifact exists)
    3. Invoke git-workflow-manager to create commit:
       a. Prepare delegation context:
          - scope_files: ["{research_report_path}", ".opencode/specs/TODO.md", ...]
          - message_template: "task {number}: research completed"
       b. Invoke git-workflow-manager with timeout (120s)
       c. Validate return status (completed or failed)
       d. If status == "completed": Log commit hash
       e. If status == "failed": Log warning (non-critical, don't fail research)
    4. Log postflight completion
  </process>
</step_4_postflight>
```

**Analysis**: Postflight steps ARE defined and DO invoke status-sync-manager and git-workflow-manager. The specification is correct.

**Implication**: The hypothesis "postflight steps not executing" is INCORRECT. The steps exist and should execute.

### Finding 3: Planner Also Has Postflight Step with Delegation

**Evidence**: planner.md has step_7 that invokes status-sync-manager and git-workflow-manager:

**File**: `.opencode/agent/subagents/planner.md` (lines 374-493)
```xml
<step_7>
  <action>Execute Stage 7 (Postflight) - Update status and create git commit</action>
  <process>
    STEP 7.1: INVOKE status-sync-manager
      PREPARE delegation context with validated_artifacts
      INVOKE status-sync-manager with timeout (60s)
      VALIDATE return status == "completed"
      VERIFY files_updated includes [".opencode/specs/TODO.md", "state.json"]
    
    STEP 7.2: INVOKE git-workflow-manager (if status update succeeded)
      PREPARE delegation context with scope_files
      INVOKE git-workflow-manager with timeout (120s)
      VALIDATE return status
  </process>
</step_7>
```

**Analysis**: Planner also has proper postflight delegation. Pattern is consistent across subagents.

### Finding 4: Evidence of Partial Postflight Success

**Evidence**: Task 314 research investigation:

1. **Artifact Created**: `.opencode/specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md` exists
   - Created: 2026-01-05 08:34:21
   - Size: 34543 bytes (non-empty, valid)

2. **Status Updated**: TODO.md shows task 314 with:
   ```markdown
   ### 314. Conduct systematic review to complete context refactor plan aims
   - **Status**: [RESEARCHED]
   - **Researched**: 2026-01-05
   
   **Research Artifacts**:
     - Research Report: [.opencode/specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md]
   ```

3. **Git Commit Missing**: Git log shows NO commit for task 314 research:
   ```bash
   $ git log --all --oneline --since="2026-01-05 08:00" --until="2026-01-05 09:00"
   # No commit for task 314 research at 08:34
   ```

**Analysis**: This is CRITICAL evidence that:
- Artifact creation succeeded (step_2_artifact_creation)
- Status update succeeded (step_4_postflight → status-sync-manager)
- Artifact linking succeeded (TODO.md has link)
- Git commit FAILED (step_4_postflight → git-workflow-manager)

**Implication**: Postflight steps ARE executing, but git-workflow-manager delegation is failing silently.

### Finding 5: Git Failure Handling is Non-Critical

**Evidence**: researcher.md specifies git failures should not fail research:

**File**: `.opencode/agent/subagents/researcher.md` (lines 332-338)
```xml
<git_failure_handling>
  If git commit fails:
  - Log warning to errors array
  - Include manual recovery instructions
  - DO NOT fail research command (git failure is non-critical)
  - Continue to Step 5 (Return)
</git_failure_handling>
```

**Analysis**: Git commit failures are intentionally non-critical. If git-workflow-manager fails, the researcher logs a warning but returns status="completed" anyway.

**Implication**: This explains why task 314 shows [RESEARCHED] status with artifact link but no git commit. The postflight step executed, status-sync-manager succeeded, git-workflow-manager failed, but researcher returned "completed" status.

### Finding 6: Task 291 Identifies Different Issue

**Evidence**: Task 291 research report identifies that lean-research-agent.md directly manipulates files instead of delegating:

**File**: `.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md`
```markdown
Root cause confirmed: lean-research-agent.md step_6 (lines 651-662) directly manipulates 
TODO.md and state.json files instead of delegating to status-sync-manager and 
git-workflow-manager like researcher.md does.
```

**Analysis**: This is a SEPARATE issue affecting only lean-research-agent. The general researcher.md and planner.md DO delegate properly.

**Implication**: Task 291 fix is needed for Lean tasks, but does not address the systematic git commit failures affecting all workflow commands.

---

## Detailed Analysis

### Root Cause: Silent Git Commit Failures

The systematic postflight failures are caused by:

1. **Git-workflow-manager delegation failures**: When researcher/planner invoke git-workflow-manager, the delegation may fail due to:
   - Timeout (120s limit)
   - Git errors (merge conflicts, detached HEAD, etc.)
   - File permission issues
   - Missing git configuration

2. **Non-critical error handling**: Subagents treat git failures as non-critical:
   - Log warning to errors array
   - Return status="completed" anyway
   - User sees "Research completed" but no git commit

3. **Command-level validation gap**: Workflow commands validate subagent return format (stage 3) but do NOT validate that git commits were created:
   ```xml
   <stage id="3" name="ValidateReturn">
     2. VALIDATION STEP 1: Validate JSON Structure
     3. VALIDATION STEP 2: Validate Required Fields
     4. VALIDATION STEP 3: Validate Artifacts Exist
     <!-- NO VALIDATION: Check git commit created -->
   </stage>
   ```

4. **No error surfacing**: If git-workflow-manager returns status="failed", the subagent logs it to errors array but command does not check errors array in validation.

### Why Task 314 Shows Partial Success

Task 314 evidence shows:
- ✓ Artifact created (research-001.md)
- ✓ Status updated ([RESEARCHED])
- ✓ Artifact linked (TODO.md has link)
- ✗ Git commit missing

This pattern indicates:
1. researcher.md step_4_postflight executed
2. status-sync-manager delegation succeeded
3. git-workflow-manager delegation failed
4. researcher returned status="completed" with warning in errors array
5. /research command validated return, saw status="completed", relayed result
6. User saw "Research completed" but git commit never created

### Why This Appears as "Postflight Not Executing"

From user perspective:
- Artifact exists → "Postflight partially worked"
- No status update → "Postflight failed"
- No git commit → "Postflight failed"

But actual behavior:
- Postflight DID execute
- Status-sync-manager succeeded (TODO.md updated)
- Git-workflow-manager failed (no commit)
- Error not surfaced to user

This creates the illusion that "postflight steps are not executing" when in reality "postflight steps are executing but failing at git commit stage."

---

## Decisions

### Decision 1: Postflight Steps ARE Executing

**Conclusion**: The hypothesis "postflight steps not executing" is INCORRECT.

**Evidence**:
- researcher.md has step_4_postflight with proper delegation
- planner.md has step_7 with proper delegation
- Task 314 shows status updated and artifact linked (proof of execution)

**Implication**: No need to add postflight steps to subagents. They already exist.

### Decision 2: Git Commit Failures Are Root Cause

**Conclusion**: The systematic failures are caused by git-workflow-manager delegation failures that are treated as non-critical.

**Evidence**:
- Task 314 has no git commit despite successful research
- researcher.md specifies git failures are non-critical
- No validation in commands to check git commits created

**Implication**: Need to either:
- Make git commits critical (fail research if git fails)
- Surface git failures to user with manual recovery steps
- Add command-level validation to check git commits

### Decision 3: Lean-Research-Agent Has Separate Issue

**Conclusion**: Task 291 identifies a different issue specific to lean-research-agent.md.

**Evidence**: Task 291 research shows lean-research-agent directly manipulates files instead of delegating.

**Implication**: Task 291 fix is orthogonal to task 320. Both fixes needed.

---

## Recommendations

### Recommendation 1: Add Git Commit Validation to Commands (Preferred)

**Approach**: Enhance workflow command stage 3 (ValidateReturn) to check if git commits were created.

**Implementation**:
```xml
<stage id="3" name="ValidateReturn">
  4. VALIDATION STEP 4: Validate Git Commit Created
     - Extract metadata.git_commit from subagent return
     - If git_commit is null or empty:
       * Check errors array for git-related errors
       * If git error found:
         - Log warning: "Git commit failed: {error_message}"
         - Display manual recovery steps:
           1. Review changes: git status
           2. Create commit manually: git add . && git commit -m "task {number}: {description}"
           3. Verify commit: git log -1
       * If no git error but no commit:
         - Log error: "Postflight incomplete: git commit missing"
         - Return error to user
</stage>
```

**Benefits**:
- Surfaces git failures to user immediately
- Provides manual recovery steps
- Does not fail research (artifact still created)
- Maintains non-critical git failure handling

**Effort**: 2-3 hours per command (8-12 hours total for 4 commands)

### Recommendation 2: Make Git Commits Critical (Alternative)

**Approach**: Change subagent specifications to fail if git-workflow-manager fails.

**Implementation**:
```xml
<step_4_postflight>
  3. Invoke git-workflow-manager to create commit:
     e. If status == "failed": 
        - Log error
        - Return status="failed" with error details
        - DO NOT return "completed"
</step_4_postflight>
```

**Benefits**:
- Ensures atomic completion (all postflight steps succeed or all fail)
- Prevents partial success scenarios

**Drawbacks**:
- Fails research even if artifact created successfully
- User loses work if git fails
- Requires rollback mechanism

**Effort**: 1-2 hours per subagent (4-6 hours total)

**Recommendation**: DO NOT implement this approach. Git failures should remain non-critical to preserve user work.

### Recommendation 3: Add Errors Array Validation (Complementary)

**Approach**: Enhance command validation to check errors array in subagent return.

**Implementation**:
```xml
<stage id="3" name="ValidateReturn">
  5. VALIDATION STEP 5: Check Errors Array
     - Extract errors from subagent return
     - If errors array is non-empty:
       * For each error:
         - Log error type and message
         - If error.type == "git_commit_failed":
           * Display manual recovery steps
         - If error.recoverable == false:
           * Fail command with error details
</stage>
```

**Benefits**:
- Surfaces all subagent errors to user
- Provides context for partial failures
- Enables error-specific handling

**Effort**: 1-2 hours per command (4-8 hours total)

### Recommendation 4: Fix Lean-Research-Agent (Task 291)

**Approach**: Implement task 291 fix to replace direct file manipulation with delegation.

**Implementation**: See task 291 research report for detailed plan.

**Effort**: 2-3 hours (per task 291 estimate)

**Priority**: High (separate from task 320 but related)

---

## Risks & Mitigations

### Risk 1: Git-Workflow-Manager May Have Bugs

**Risk**: If git-workflow-manager is failing systematically, fixing command validation won't solve the underlying issue.

**Mitigation**:
1. Test git-workflow-manager in isolation
2. Check git-workflow-manager logs for errors
3. Verify git-workflow-manager return format
4. Fix git-workflow-manager bugs if found

**Likelihood**: Medium  
**Impact**: High

### Risk 2: Status-Sync-Manager May Also Fail Silently

**Risk**: Task 314 shows status updated, but other tasks may have status-sync-manager failures.

**Mitigation**:
1. Add validation for status-sync-manager return
2. Check TODO.md and state.json after research
3. Verify files_updated array in return

**Likelihood**: Low (task 314 evidence shows status-sync-manager succeeded)  
**Impact**: High

### Risk 3: Validation May Increase Context Window Usage

**Risk**: Adding validation steps to commands increases context window usage.

**Mitigation**:
1. Keep validation concise
2. Use brief error messages
3. Delegate detailed validation to subagents

**Likelihood**: Low  
**Impact**: Low

---

## Appendix: Sources and Citations

### Source 1: Workflow Command Files

- `.opencode/command/research.md` (4 stages, no postflight)
- `.opencode/command/plan.md` (4 stages, no postflight)
- `.opencode/command/implement.md` (4 stages, no postflight)
- `.opencode/command/revise.md` (4 stages, no postflight)

### Source 2: Subagent Files

- `.opencode/agent/subagents/researcher.md` (step_4_postflight, lines 296-340)
- `.opencode/agent/subagents/planner.md` (step_7, lines 374-493)
- `.opencode/agent/subagents/lean-research-agent.md` (step_7, lines 631-679)

### Source 3: Task 291 Research

- `.opencode/specs/291_fix_lean_research_agent_delegate_status_updates/reports/research-001.md`
- Identifies lean-research-agent direct file manipulation issue

### Source 4: Task 314 Evidence

- Artifact: `.opencode/specs/314_conduct_systematic_review_to_complete_context_refactor_plan_aims/reports/research-001.md`
- Created: 2026-01-05 08:34:21
- Size: 34543 bytes
- Status: [RESEARCHED] in TODO.md
- Git commit: MISSING

### Source 5: Git Log Analysis

```bash
$ git log --all --oneline --since="2026-01-05 08:00" --until="2026-01-05 09:00"
# No commit for task 314 research
```

### Source 6: Standards

- `.opencode/context/core/standards/status-markers.md`
- `.opencode/context/core/standards/artifact-management.md`
- `.opencode/context/core/standards/subagent-return-format.md`
- `.opencode/context/core/standards/delegation.md`

---

## Summary

Systematic postflight failures in workflow commands are caused by **silent git commit failures**, not missing postflight steps. Subagents (researcher.md, planner.md) DO have postflight steps that invoke status-sync-manager and git-workflow-manager, but git-workflow-manager failures are treated as non-critical and not surfaced to users.

**Evidence**: Task 314 research shows artifact created, status updated, artifact linked, but no git commit. This proves postflight executed but git-workflow-manager failed.

**Solution**: Add git commit validation to workflow commands (stage 3) to surface git failures and provide manual recovery steps. Estimated effort: 8-12 hours for all 4 commands.

**Related Work**: Task 291 fix needed for lean-research-agent (separate issue, 2-3 hours).
