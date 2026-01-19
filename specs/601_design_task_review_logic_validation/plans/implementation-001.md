# Implementation Plan: Task #601

- **Task**: 601 - Design task review logic and validation rules
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/601_design_task_review_logic_validation/reports/research-001.md, research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement `/task --review N` as a READ-ONLY information gathering command that analyzes task completion status against its implementation plan. The command loads task artifacts (plan, summary, research), compares plan phases to actual completion, identifies missing work, and presents follow-up task suggestions to the user. User interactively selects which follow-up tasks to create.

**Key Design Decision**: `--review` is SEPARATE from `--sync`. The existing `--sync` command remains unchanged. `--review` focuses on analyzing a specific task's completion state, not reconciling TODO.md/state.json discrepancies.

### Research Integration

- Research-001.md provided comprehensive validation rule taxonomy (ERROR/WARN/INFO) and completion verification patterns
- Research-002.md analyzed `--sync` implementation (lines 197-223 of task.md) - user decided to keep `--sync` separate, not replace it
- User clarification: `--review` is for gathering information about task state and suggesting follow-ups, not for fixing inconsistencies

## Goals & Non-Goals

**Goals**:
- Analyze single task completion status vs its implementation plan
- Load and parse plan file to extract phase statuses
- Load implementation summary to verify completion claims
- Identify incomplete phases and missing work
- Generate follow-up task suggestions
- Present suggestions interactively to user
- Create selected follow-up tasks using existing `/task` machinery

**Non-Goals**:
- Replace or modify `--sync` functionality
- Auto-fix inconsistencies between TODO.md and state.json
- Batch review of multiple tasks (single task only in v1)
- Validate artifact naming conventions or file existence (that's `--sync` territory)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plan file parsing fragile | Medium | Medium | Use robust regex patterns, handle missing sections gracefully |
| User confusion with --sync | Low | Medium | Clear documentation distinguishing the two commands |
| Follow-up task creation fails | Medium | Low | Reuse proven /task creation logic, validate before creation |
| No plan file exists | Low | Medium | Gracefully report "no plan found" with recommendation to run /plan |

## Implementation Phases

### Phase 1: Add --review Flag Parsing [COMPLETED]

**Goal**: Extend task.md to recognize and route `--review N` flag

**Tasks**:
- [ ] Add `--review N` to mode detection section in task.md
- [ ] Parse task number from arguments
- [ ] Validate task exists in state.json
- [ ] Add "Review Mode (--review)" section header

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/task.md` - Add flag parsing and mode routing

**Verification**:
- `/task --review 597` parses correctly and routes to review mode
- Invalid task number returns clear error

---

### Phase 2: Implement Task Information Loading [COMPLETED]

**Goal**: Load all relevant artifacts for the target task

**Tasks**:
- [ ] Load task metadata from state.json via jq
- [ ] Find and load plan file (implementation-NNN.md)
- [ ] Find and load summary file (if exists)
- [ ] Find and load research reports (for context)
- [ ] Handle missing files gracefully with clear messages

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/task.md` - Add artifact loading logic

**Verification**:
- Review mode loads all existing artifacts
- Missing plan reports "No plan found, run /plan N"
- Missing summary reports "No summary found"

---

### Phase 3: Implement Plan Phase Analysis [COMPLETED]

**Goal**: Parse plan file and determine completion status of each phase

**Tasks**:
- [ ] Parse phase headings with status markers (### Phase N: Name [STATUS])
- [ ] Extract phase names and current statuses
- [ ] Identify phases that are NOT [COMPLETED]
- [ ] Extract phase goals and tasks for incomplete phases
- [ ] Build structured analysis result

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/task.md` - Add plan parsing logic

**Verification**:
- Correctly identifies [COMPLETED] vs [NOT STARTED] vs [IN PROGRESS] phases
- Extracts phase names and goals accurately
- Handles plans with various phase count

---

### Phase 4: Generate Follow-up Task Suggestions [COMPLETED]

**Goal**: Create actionable follow-up task suggestions for incomplete work

**Tasks**:
- [ ] For each incomplete phase, generate task suggestion
- [ ] Format: "Complete phase N of task {parent}: {phase_name}"
- [ ] Include phase goal and estimated effort
- [ ] Inherit language and priority from parent task
- [ ] Add reference to parent task in description

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/task.md` - Add suggestion generation logic

**Verification**:
- Suggestions are actionable and specific
- Suggestions reference parent task correctly
- No suggestions if all phases are complete

---

### Phase 5: Implement Interactive User Selection [COMPLETED]

**Goal**: Present suggestions and let user choose which tasks to create

**Tasks**:
- [ ] Display review summary to user (task status, phases analyzed, findings)
- [ ] List suggested follow-up tasks with numbers
- [ ] Prompt user to select tasks (e.g., "1,3" or "all" or "none")
- [ ] Parse user selection
- [ ] Create selected tasks using existing task creation jq patterns

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/task.md` - Add interactive selection and task creation

**Verification**:
- User can select individual tasks, all, or none
- Selected tasks are created with correct metadata
- Tasks link back to parent task in description

## Testing & Validation

- [ ] Test with completed task (597) - should report all phases complete
- [ ] Test with in-progress task (568) - should identify incomplete phases
- [ ] Test with task missing plan - should report gracefully
- [ ] Test follow-up task creation - verify tasks created correctly
- [ ] Test "none" selection - no tasks created

## Artifacts & Outputs

- `.claude/commands/task.md` - Extended with --review mode
- specs/601_design_task_review_logic_validation/plans/implementation-001.md - This plan

## Rollback/Contingency

If implementation fails:
1. Revert changes to task.md
2. The `--review` flag can be removed without affecting existing functionality
3. `--sync` remains completely unchanged regardless of outcome
