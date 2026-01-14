# Systematic Command Consistency Analysis

## Problem Statement

The `/research` and `/implement` commands are not working reliably compared to `/plan`. The user reports:
- `/plan` works well
- `/research` and `/implement` fail to update status and link artifacts consistently
- Need systematic approach across all commands: `/research`, `/plan`, `/revise`, `/implement`

## Root Cause Analysis

### Current Architecture (Post-Task 240 Migration)

The system uses a **frontmatter delegation pattern** where:
1. **Orchestrator** (`.opencode/agent/orchestrator.md`) handles Stages 1-5:
   - Stage 1: PreflightValidation (parse arguments, validate task)
   - Stage 2: DetermineRouting (extract language/type, map to agent)
   - Stage 3: RegisterAndDelegate (invoke subagent with formatted prompt)
   - Stage 4: ValidateReturn (verify JSON format, artifacts exist)
   - Stage 5: PostflightCleanup (update session registry, relay result)

2. **Subagents** (researcher, planner, implementer, etc.) own complete workflow:
   - Step 0: Preflight (update status to [RESEARCHING]/[PLANNING]/[IMPLEMENTING])
   - Steps 1-4: Core work (research/planning/implementation)
   - Step 5: Postflight (update status to [RESEARCHED]/[PLANNED]/[COMPLETED], git commit)

### Key Differences Between Commands

#### `/plan` Command (WORKING)
- **Command file**: `.opencode/command/plan.md`
- **Frontmatter**: Minimal, delegates to orchestrator
- **Subagent**: `planner.md` (`.opencode/agent/subagents/planner.md`)
- **Status flow**: [NOT STARTED] → [PLANNING] → [PLANNED]
- **Artifacts**: Plan file in `.opencode/specs/{number}_{slug}/plans/implementation-001.md`
- **Updates**: TODO.md (status, plan link), state.json (status, plan_path, plan_metadata)

#### `/research` Command (FAILING)
- **Command file**: `.opencode/command/research.md`
- **Frontmatter**: Minimal, delegates to orchestrator
- **Subagent**: `researcher.md` (`.opencode/agent/subagents/researcher.md`)
- **Status flow**: [NOT STARTED] → [RESEARCHING] → [RESEARCHED]
- **Artifacts**: Research report in `.opencode/specs/{number}_{slug}/reports/research-001.md`
- **Updates**: TODO.md (status, research link), state.json (status, research_path, research_metadata)

#### `/implement` Command (FAILING)
- **Command file**: `.opencode/command/implement.md`
- **Frontmatter**: Minimal, delegates to orchestrator
- **Subagent**: `implementer.md` (`.opencode/agent/subagents/implementer.md`)
- **Status flow**: [NOT STARTED] → [IMPLEMENTING] → [COMPLETED]
- **Artifacts**: Implementation files + summary in `.opencode/specs/{number}_{slug}/summaries/implementation-summary-YYYYMMDD.md`
- **Updates**: TODO.md (status, artifact links), state.json (status, artifact_paths)

### Identified Issues

#### Issue 1: Inconsistent Step Naming (FIXED in Task 283)
- **Problem**: Planner used `step_0_preflight`, researcher used `stage_1_preflight`
- **Impact**: Claude skipped preflight steps due to naming confusion
- **Status**: FIXED for general subagents (researcher, planner, implementer)
- **Remaining**: Lean subagents still use inconsistent naming (Task 285)

#### Issue 2: Argument Parsing Inconsistency
- **Problem**: `/implement` had typo "arguments" instead of "$ARGUMENTS" (line 34)
- **Impact**: Task number not extracted, routing failed
- **Status**: FIXED in Task 281

#### Issue 3: Missing Preflight Status Updates
- **Problem**: Some subagents didn't update status at beginning
- **Impact**: Status remained [NOT STARTED] even during execution
- **Status**: FIXED in Task 275 (added to planner.md, implementer.md)

#### Issue 4: Artifact Linking Failures
- **Problem**: Research reports created but not linked in TODO.md
- **Impact**: "Phantom research" - artifacts exist but not tracked
- **Status**: PARTIALLY ADDRESSED (Task 290 identified outdated documentation)

#### Issue 5: Status Synchronization Failures
- **Problem**: status-sync-manager not invoked or invoked incorrectly
- **Impact**: TODO.md and state.json out of sync
- **Status**: ONGOING (Task 283, 285, 290, 291)

## Systematic Solution

### Phase 1: Standardize Subagent Structure (CRITICAL)

All subagents must follow identical structure:

```markdown
<process_flow>
  <step_0_preflight>
    <action>Preflight: Parse arguments, validate task, update status to [STATUS]</action>
    <process>
      1. Parse task_number from delegation context or prompt string
      2. Validate task exists in TODO.md
      3. Extract task description and current status
      4. Verify task not [COMPLETED] or [ABANDONED]
      5. Generate timestamp: $(date -I)
      6. Invoke status-sync-manager to mark [STATUS]:
         a. Prepare delegation context
         b. Invoke with timeout (60s)
         c. Validate return status == "completed"
         d. Verify files_updated includes ["TODO.md", "state.json"]
      7. Log preflight completion
    </process>
  </step_0_preflight>
  
  <step_1_core_work>
    <!-- Command-specific work -->
  </step_1_core_work>
  
  <step_5_postflight>
    <action>Postflight: Update status to [FINAL_STATUS], create git commit</action>
    <process>
      1. Validate all artifacts created and non-empty
      2. Generate timestamp: $(date -I)
      3. Invoke status-sync-manager to mark [FINAL_STATUS]:
         a. Prepare delegation context with artifact_updates
         b. Invoke with timeout (60s)
         c. Validate return status == "completed"
         d. Verify files_updated includes ["TODO.md", "state.json"]
      4. Invoke git-workflow-manager to create commit:
         a. Prepare commit message
         b. Invoke with timeout (60s)
         c. Validate commit created
      5. Log postflight completion
    </process>
  </step_5_postflight>
</process_flow>
```

### Phase 2: Enforce Artifact Validation

Orchestrator Stage 4 must validate:
1. Return is valid JSON (not plain text)
2. Required fields present: status, summary, artifacts, metadata
3. If status="completed": artifacts array non-empty
4. All artifact paths exist on disk
5. All artifact files non-empty (size > 0 bytes)

### Phase 3: Standardize Artifact Management

All subagents must:
1. Create artifacts in `.opencode/specs/{number}_{slug}/{type}/`
2. Use consistent naming: `{type}-001.md`, `{type}-002.md`, etc.
3. Include artifacts in return JSON with full paths
4. Delegate artifact linking to status-sync-manager

### Phase 4: Enforce Status Synchronization

All subagents must:
1. Invoke status-sync-manager for ALL status updates (preflight and postflight)
2. Never update TODO.md or state.json directly
3. Validate status-sync-manager return before proceeding
4. Abort if status update fails

### Phase 5: Standardize Git Workflow

All subagents must:
1. Invoke git-workflow-manager for ALL commits
2. Never run git commands directly
3. Use standardized commit message format
4. Validate commit created before returning

## Implementation Plan

### Task 1: Audit All Subagents (2-3 hours)
- Read all 10 subagent files
- Document current step naming, status update patterns, artifact management
- Identify deviations from standard
- Create compliance matrix

### Task 2: Fix Lean Subagents (3-4 hours)
- Update lean-research-agent.md to use step_0_preflight
- Update lean-planner.md to use step_0_preflight
- Update lean-implementation-agent.md to use step_0_preflight
- Remove outdated summary artifact requirements (Task 290)
- Test with Lean tasks

### Task 3: Enhance Orchestrator Validation (2-3 hours)
- Strengthen Stage 4 validation (Task 280)
- Add artifact existence checks
- Add artifact non-empty checks
- Add JSON format enforcement
- Test with all commands

### Task 4: Create Subagent Structure Standard (1-2 hours)
- Document standard in `.opencode/context/core/standards/subagent-structure.md`
- Include step naming convention
- Include status update pattern
- Include artifact management pattern
- Include git workflow pattern

### Task 5: Comprehensive Testing (3-4 hours)
- Test /research with Lean and general tasks
- Test /plan with Lean and general tasks
- Test /implement with Lean and general tasks
- Test /revise with all task types
- Verify status updates in TODO.md and state.json
- Verify artifact linking
- Verify git commits

## Success Criteria

1. **Consistency**: All 4 commands follow identical workflow pattern
2. **Reliability**: 100% status update success rate
3. **Traceability**: All artifacts linked in TODO.md and state.json
4. **Atomicity**: TODO.md and state.json always in sync
5. **Auditability**: All changes tracked in git commits

## Related Tasks

- Task 275: Fix workflow status updates (COMPLETED)
- Task 280: Fix orchestrator Stage 4 validation (PLANNED)
- Task 283: Fix systematic status synchronization failure (COMPLETED)
- Task 285: Audit and fix status update behavior (PLANNED)
- Task 290: Fix lean-research-agent preflight status updates (PLANNED)
- Task 291: Fix lean-research-agent delegate status updates (NOT STARTED)

## Recommendations

1. **Prioritize Task 285**: Extend Task 283 fix to all remaining subagents
2. **Implement Task 280**: Strengthen orchestrator validation to catch failures early
3. **Create subagent-structure.md**: Document standard for future reference
4. **Comprehensive testing**: Test all commands with all task types
5. **Monitor metrics**: Track status update success rate, artifact linking rate, git commit rate
