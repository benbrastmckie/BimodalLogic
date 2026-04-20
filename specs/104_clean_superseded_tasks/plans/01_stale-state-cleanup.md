# Implementation Plan: Clean Superseded Tasks

- **Task**: 104 - clean_superseded_tasks
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/104_clean_superseded_tasks/reports/01_stale-state-cleanup.md
- **Artifacts**: plans/01_stale-state-cleanup.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Clean up stale task state remaining after the post-task-93 review. Three items need fixing: (1) task 60's dependency on archived task 59 must be removed and its description reassessed since `discrete_Icc_finite_axiom` was already eliminated, (2) sorry count metrics in state.json need correction from 140 to 129 non-Boneyard and from 1 to 11 publication-path sorries, (3) TODO.md frontmatter metrics must be updated to match. Done when all three files are internally consistent and reflect the audited 2026-04-20 values.

### Research Integration

Research report confirmed: 129 non-Boneyard sorries (not 140), 11 active-path sorries in CanonicalModel.lean (6) and RootScopedChain.lean (5), zero custom axiom declarations, and task 59 is archived with no state.json entry. Task 60 dependency on 59 is stale. All 6 abandoned tasks (89, 87, 74, 75, 76, 82) are properly recorded and need no changes.

### Roadmap Alignment

ROADMAP.md references 5 active-path sorries in RootScopedChain.lean. The research report identifies 11 sorries across CanonicalModel + RootScopedChain. Note: the ROADMAP counts only RootScopedChain sorries as "blocking bx_completeness" while CanonicalModel sorries (4 genuinely false/unprovable) are upstream dependencies. This plan updates TODO.md and state.json metrics but does not modify ROADMAP.md.

## Goals & Non-Goals

**Goals**:
- Remove task 60's stale dependency on task 59
- Update task 60 description to reflect that discrete_Icc_finite_axiom is already eliminated
- Correct sorry_count from 140 to 129 in both state.json and TODO.md
- Correct publication_path_sorries from 1 to 11 in TODO.md
- Update sorry_count_note to reference the 11 CanonicalModel+RootScopedChain sorries
- Reconcile task_counts in TODO.md frontmatter if needed

**Non-Goals**:
- Re-auditing Boneyard sorry counts (171, accepted as-is)
- Modifying ROADMAP.md
- Deciding whether to abandon task 60 (update description, leave for user decision)
- Fixing any Lean source code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sorry counts shift before implementation | L | M | Use audited 2026-04-20 values, note timestamp |
| Task count reconciliation finds deeper issues | M | L | Log discrepancies, fix only clear mismatches |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Task 60 in state.json and TODO.md [COMPLETED]

**Goal**: Remove stale dependency on task 59 and update task 60 description.

**Tasks**:
- [ ] Edit state.json: remove `59` from task 60's dependencies array
- [ ] Edit state.json: update task 60 description to note discrete_Icc_finite_axiom was eliminated; task now covers stale docstring cleanup in FrameClass.lean and SuccExistence.lean
- [ ] Edit TODO.md: remove "Dependencies: Task 59" from task 60 entry
- [ ] Edit TODO.md: update task 60 description to match state.json changes

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` - task 60 entry (dependencies, description)
- `specs/TODO.md` - task 60 entry (dependencies, description)

**Verification**:
- Task 60 has no dependencies in state.json
- Task 60 description references docstring cleanup, not axiom elimination
- No reference to task 59 remains in task 60's entries

---

### Phase 2: Update Sorry Count Metrics [COMPLETED]

**Goal**: Correct sorry_count and publication_path_sorries in both state.json and TODO.md.

**Tasks**:
- [ ] Edit state.json: change `repository_health.sorry_counts.non_boneyard` from 140 to 129
- [ ] Edit state.json: change `repository_health.sorry_counts.total` from 311 to 300
- [ ] Edit state.json: update any sorry-related notes to reference 11 active-path sorries
- [ ] Edit TODO.md frontmatter: change `sorry_count: 140` to `sorry_count: 129`
- [ ] Edit TODO.md frontmatter: change `publication_path_sorries: 1` to `publication_path_sorries: 11`
- [ ] Edit TODO.md frontmatter: update `sorry_count_note` to reference 11 active-path sorries in CanonicalModel+RootScopedChain (6+5), noting 4 are genuinely false/unprovable

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` - repository_health.sorry_counts section
- `specs/TODO.md` - frontmatter technical_debt section

**Verification**:
- state.json shows non_boneyard: 129, total: 300
- TODO.md shows sorry_count: 129, publication_path_sorries: 11
- sorry_count_note references CanonicalModel+RootScopedChain, not Completeness.lean:154

---

### Phase 3: Reconcile Task Counts and Final Verification [NOT STARTED]

**Goal**: Verify task_counts in TODO.md frontmatter match actual state, perform cross-file consistency check.

**Tasks**:
- [ ] Count active/not_started/abandoned tasks in state.json and compare to TODO.md frontmatter task_counts
- [ ] Fix any task_count discrepancies in TODO.md frontmatter
- [ ] Cross-check: confirm state.json and TODO.md agree on task 60 status, dependencies, and description
- [ ] Cross-check: confirm sorry metrics match between state.json and TODO.md

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- `specs/TODO.md` - frontmatter task_counts (if discrepancies found)

**Verification**:
- task_counts match actual state.json counts
- All sorry metrics consistent between files
- Task 60 consistent between files

## Testing & Validation

- [ ] `jq '.active_projects[] | select(.project_number == 60) | .dependencies' specs/state.json` returns empty or no task 59
- [ ] `jq '.repository_health.sorry_counts.non_boneyard' specs/state.json` returns 129
- [ ] `jq '.repository_health.sorry_counts.total' specs/state.json` returns 300
- [ ] TODO.md frontmatter sorry_count is 129
- [ ] TODO.md frontmatter publication_path_sorries is 11
- [ ] No remaining references to "Completeness.lean:154" as active-path sorry in metrics

## Artifacts & Outputs

- `specs/104_clean_superseded_tasks/plans/01_stale-state-cleanup.md` (this plan)
- `specs/104_clean_superseded_tasks/summaries/01_stale-state-cleanup-summary.md` (after implementation)
- Updated `specs/state.json`
- Updated `specs/TODO.md`

## Rollback/Contingency

All changes are to tracked files (state.json, TODO.md). Revert with `git checkout specs/state.json specs/TODO.md` if needed. No Lean source changes are made.
