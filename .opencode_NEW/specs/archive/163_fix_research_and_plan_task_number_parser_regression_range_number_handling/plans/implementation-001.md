# Implementation Plan: Fix /research and /plan task-number parser regression (range/number handling)

**Project**: #163  
**Status**: [IN PROGRESS]  
**Started**: 2025-12-24T12:30:00Z  
**Language**: markdown  
**Lean**: false

## Context

The `/research` and `/plan` commands currently fail to accept numeric task IDs provided as arguments (e.g., `/research 161` or `/plan 163`), instead prompting the user to enter a task number interactively. This regression breaks the expected workflow where users can directly invoke research or planning on a specific TODO task by number.

The root cause is a parsing logic flaw where numeric arguments are discarded before validation, causing the command to fall through to an interactive prompt path even when a valid numeric ID was provided. This affects both single numeric IDs and range inputs.

## Research Inputs

- **Research Report**: [reports/research-001.md](specs/163_fix_research_and_plan_task_number_parser_regression_range_number_handling/reports/research-001.md)
  - Identified parsing regression: numeric tokens discarded when preflight expects list object
  - Range parsing lacks numeric-only guard before prompting
  - Subagent wrappers depend on task-executor for TODO/state preflight
  - Recommended centralized numeric/range parser with structured output
  - Preflight gating requirements: validate TODO presence, set IN PROGRESS status
  - Lazy creation enforcement: no directories until artifact write

## Objectives

1. Fix the numeric task ID parser in `/research` and `/plan` commands to accept single numeric IDs without prompting
2. Implement proper preflight validation and status updates before delegation
3. Preserve lazy directory creation guarantees
4. Update documentation to reflect corrected behavior
5. Ensure consistency between `/research` and `/plan` parsing logic

## Implementation Phases

### Phase 1: Parser Fix and Validation [NOT STARTED]

**Objective**: Implement robust numeric/range parser that accepts provided arguments without re-prompting

**Tasks**:
1. Update `/research` command parsing logic:
   - Accept `$ARGUMENTS` as single numeric task ID
   - Validate numeric format before any prompting
   - Reject ranges/lists/non-numeric inputs with clear error message
   - Only prompt if `$ARGUMENTS` is empty/missing
   
2. Update `/plan` command parsing logic:
   - Mirror `/research` parsing approach for consistency
   - Accept single numeric task ID from `$ARGUMENTS`
   - Validate and fail fast on invalid inputs
   - Preserve optional prompt text after task number

3. Add validation checks:
   - Confirm task exists in TODO.md before proceeding
   - Confirm task exists in state.json `pending_tasks`
   - Return clear error if task not found (no prompting)

**Acceptance Criteria**:
- `/research 163` and `/plan 163` accept the numeric ID without prompting
- Invalid inputs (ranges, non-numeric, missing) produce clear error messages
- Missing task numbers fail fast with informative error
- No interactive prompts when valid numeric ID is provided

**Files Modified**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`

### Phase 2: Preflight Status Updates [NOT STARTED]

**Objective**: Ensure proper status marker updates before delegation to subagents

**Tasks**:
1. Implement preflight status updates in `/research`:
   - Set TODO status to `[IN PROGRESS]` with `Started` date if not already set
   - Update `state.json` `pending_tasks` entry: `status: "in_progress"`, `started_at` timestamp
   - Ensure idempotent updates (preserve existing timestamps if already started)
   - Perform updates before delegating to researcher subagent

2. Implement preflight status updates in `/plan`:
   - Mirror `/research` preflight logic
   - Set TODO to `[IN PROGRESS]` with `Started` date
   - Update state `pending_tasks` to `in_progress` status
   - Execute before delegating to planner subagent

3. Ensure atomic updates:
   - TODO.md and state.json updates must be synchronized
   - No partial updates if validation fails
   - Preserve all existing task metadata

**Acceptance Criteria**:
- TODO status set to `[IN PROGRESS]` before research/planning work begins
- State `pending_tasks` status synchronized with TODO
- Timestamps added only if not already present
- Updates are atomic (both TODO and state updated together)
- Existing metadata preserved during status updates

**Files Modified**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`

### Phase 3: Completion Flow Updates [NOT STARTED]

**Objective**: Ensure proper status transitions when research/planning completes

**Tasks**:
1. Update `/research` completion flow:
   - Mark TODO status to `[RESEARCHED]` with ISO8601 `Completed` timestamp
   - Update state `pending_tasks`: `status: "research_completed"`, `research_completed_at` timestamp
   - Update/create `active_projects` entry: `phase: "research"`, `status: "completed"`
   - Add report path to `reports` array
   - Append to `recent_activities`

2. Update `/plan` completion flow:
   - Mark TODO status to `[PLANNED]` with ISO8601 `Completed` timestamp
   - Update state `pending_tasks`: `status: "planned"`, `planned_at` timestamp
   - Update `active_projects` entry: `phase: "planning"`, `status: "planned"`
   - Add plan path to `plans` array
   - Append to `recent_activities`

3. Ensure state consistency:
   - All timestamps use ISO8601 format
   - State transitions follow status-markers.md standard
   - Artifact paths properly linked in TODO and state

**Acceptance Criteria**:
- Research completion sets `[RESEARCHED]` status with timestamp
- Planning completion sets `[PLANNED]` status with timestamp
- State `pending_tasks` and `active_projects` synchronized
- Artifact paths correctly linked in TODO and state
- All timestamps in ISO8601 format

**Files Modified**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`

### Phase 4: Lazy Creation Enforcement [NOT STARTED]

**Objective**: Ensure no directories are created during parsing/validation, only during artifact writes

**Tasks**:
1. Review and enforce lazy creation in `/research`:
   - No project root creation during parsing/validation
   - Create `specs/{id}_{slug}/` only when writing first artifact
   - Create `reports/` subdirectory only when writing research report
   - Ensure preflight failures leave no filesystem artifacts

2. Review and enforce lazy creation in `/plan`:
   - No project root creation during parsing/validation
   - Create project root only when writing plan artifact
   - Create `plans/` subdirectory only when writing plan
   - Validation failures must not create directories

3. Add guardrails:
   - Wrap all directory creation in artifact write guards
   - Document lazy creation contract in command files
   - Add regression test coverage (if applicable)

**Acceptance Criteria**:
- Parsing failures create no directories
- Validation failures create no directories
- Project root created only when writing first artifact
- Subdirectories created only when writing specific artifact types
- Lazy creation contract documented in command files

**Files Modified**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`

### Phase 5: Documentation and Standards Updates [NOT STARTED]

**Objective**: Update documentation to reflect corrected behavior and prevent regression

**Tasks**:
1. Update command documentation:
   - Document numeric task ID acceptance in `/research` and `/plan`
   - Clarify error messages for invalid inputs
   - Document preflight status update behavior
   - Document lazy directory creation guarantees
   - Add usage examples with numeric IDs

2. Update subagent documentation:
   - Update `researcher.md` to reflect preflight expectations
   - Update `planner.md` to reflect preflight expectations
   - Document delegation contract (status already set by orchestrator)

3. Update standards:
   - Update `commands.md` with numeric ID parsing requirements
   - Update `status-markers.md` if needed for preflight transitions
   - Update `artifact-management.md` to reinforce lazy creation

4. Add regression prevention notes:
   - Document the root cause of this regression
   - Add notes on proper argument parsing patterns
   - Include validation checklist for command updates

**Acceptance Criteria**:
- Command docs clearly describe numeric ID acceptance
- Subagent docs reflect preflight contract
- Standards updated with parsing requirements
- Regression cause documented for future reference
- Usage examples include numeric ID invocations

**Files Modified**:
- `.opencode/command/research.md`
- `.opencode/command/plan.md`
- `.opencode/agent/subagents/researcher.md`
- `.opencode/agent/subagents/planner.md`
- `.opencode/context/core/standards/commands.md`
- `.opencode/context/core/standards/tasks.md`
- `.opencode/context/core/standards/status-markers.md`

## Dependencies

- Research report already completed: `reports/research-001.md`
- No blocking dependencies on other tasks
- No external library dependencies

## Risk Assessment

**Low Risk**:
- Changes are localized to command parsing logic
- Existing subagent delegation remains unchanged
- Status marker updates follow established patterns
- Lazy creation is already the documented standard

**Mitigation**:
- Preserve all existing metadata during updates
- Ensure atomic TODO/state synchronization
- Test with various input formats (numeric, invalid, missing)
- Verify no regression in existing workflows

## Success Criteria

1. `/research 163` and `/plan 163` accept numeric IDs without prompting
2. Invalid inputs produce clear, actionable error messages
3. TODO and state status markers updated correctly during preflight
4. Completion flows set appropriate final statuses with timestamps
5. No directories created during parsing/validation failures
6. Documentation accurately reflects corrected behavior
7. No regression in existing command functionality

## Testing Strategy

**Manual Testing**:
1. Test `/research {number}` with valid task ID
2. Test `/plan {number}` with valid task ID
3. Test with invalid inputs (non-numeric, missing, ranges)
4. Test with missing task numbers
5. Verify status transitions in TODO.md and state.json
6. Verify no directories created on validation failures
7. Verify artifact creation triggers directory creation

**Validation**:
- Check TODO.md status markers before and after
- Check state.json `pending_tasks` and `active_projects` entries
- Verify filesystem state (no spurious directories)
- Confirm artifact paths correctly linked

## Rollback Plan

If issues arise:
1. Revert command file changes
2. Restore previous parsing logic
3. Document specific failure mode
4. Re-plan with additional research if needed

Changes are isolated to command files and can be reverted independently without affecting subagents or state schema.

## Notes

- This fix addresses a regression introduced during recent command standardization work
- The parsing logic should be simple and fail-fast to avoid user confusion
- Consistency between `/research` and `/plan` is critical for user experience
- Lazy directory creation is a core system guarantee and must be preserved
- Status marker updates must be atomic to maintain TODO/state consistency

## Next Steps After Completion

1. Monitor for similar parsing issues in other commands
2. Consider extracting common parsing utilities if pattern repeats
3. Update command template to include parsing validation checklist
4. Archive this project once implementation is verified
