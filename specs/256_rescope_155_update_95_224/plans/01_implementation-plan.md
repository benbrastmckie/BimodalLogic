# Implementation Plan: Task #256

- **Task**: 256 - Re-scope task 155 and update related task descriptions after task 202 completion
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/256_rescope_155_update_95_224/reports/01_rescope-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This is a metadata-only task that updates three task descriptions in state.json and TODO.md to reflect findings from the task 202 completion and task 256 research. Task 155 must be re-scoped from the obsolete GHR93 game-theoretic pipeline targeting `succ_cofinal` to the correct objective: closing the import-cycle sorry in `no_gaps_discrete` (GoodStructures.lean:855) by delegating to the sorry-free `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean:2133), then rewiring `completeness_discrete` to use the WeakCanonical path. Task 95 description must be updated to replace stale `succ_cofinal` references with the current `no_gaps_discrete` target. Task 224 must be abandoned as the IsSuccArchimedean alternative is no longer needed.

### Research Integration

The research report (01_rescope-research.md) established:
- Task 202 completed `chronicle_is_good_direct` but the full Reynolds Z-interval-to-TaskFrame pipeline is architecturally blocked (unsolvable sorry at `countermodel_discrete_reynolds`, Transfer.lean:1289).
- The correct path to sorry-free `completeness_discrete` is `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean), which is already sorry-free.
- The `no_gaps_discrete` sorry in GoodStructures.lean:855 exists solely due to an import cycle -- GoodStructuresModelSurgery.lean imports GoodStructures.lean, preventing the reverse delegation.
- `succ_cofinal` is on the BX chronicle path, which is being bypassed entirely.
- Task 224's IsSuccArchimedean approach addressed `succ_cofinal`, which is no longer the blocker.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- ROADMAP.md "Critical path" section references task 155 and the Reynolds bypass. The re-scope changes the definition of done for task 155 but does not alter the critical-path structure.
- The sorry chain documented in ROADMAP.md (`succ_cofinal -> limitDomSubtype_isSuccArchimedean -> ...`) will become stale once task 155 is re-scoped. However, updating ROADMAP.md is out of scope for this task (deferred to task 254).

## Goals & Non-Goals

**Goals**:
- Re-scope task 155 description in state.json and TODO.md to target `no_gaps_discrete` import-cycle fix + `completeness_discrete` WeakCanonical rewiring
- Update task 95 description to reflect that `no_gaps_discrete` (not `succ_cofinal`) is the primary target, with Reynolds model surgery as the resolution path
- Abandon task 224 with clear rationale
- Reset task 155 status and plan metadata to reflect the fundamental scope change

**Non-Goals**:
- Modifying any Lean source code
- Updating ROADMAP.md (deferred to task 254)
- Updating TODO.md sorry_count_note (deferred to task 254)
- Creating or modifying task dependencies beyond what research specifies

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale description fragments remain after editing | L | M | Carefully review full description text before and after editing |
| TODO.md and state.json get out of sync | M | L | Update state.json first, then TODO.md; verify both after each phase |
| Task 155 dependencies need updating | M | L | Research report identified dependencies; verify they remain correct for re-scoped objective |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Re-scope task 155 [COMPLETED]

**Goal**: Replace task 155's description, reset its plan metadata, and update its dependencies to reflect the new `no_gaps_discrete` import-cycle objective.

**Tasks**:
- [ ] Update task 155 `description` field in state.json to the re-scoped objective: close `no_gaps_discrete` import cycle in GoodStructures.lean by delegating to `no_gaps_discrete_model_surgery`, then rewire `completeness_discrete` to use WeakCanonical path. Definition of done: `#print axioms completeness_discrete` shows no `sorryAx`, `lake build` passes.
- [ ] Reset task 155 `status` from `implementing` to `not_started` in state.json (the existing 44 plan versions and GHR93 game-theoretic approach are obsolete for the re-scoped objective)
- [ ] Clear or reset `resume_phase` and `plan_metadata` fields to reflect clean start
- [ ] Update task 155 dependencies: remove dependency on task 256 (this task, which will be completed), keep dependency on task 199 if still relevant or remove if not
- [ ] Update TODO.md entry for task 155: change status marker to `[NOT STARTED]`, update description text to match new scope
- [ ] Verify state.json and TODO.md are consistent for task 155

**Timing**: 25 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` - Update task 155 entry (description, status, dependencies, plan_metadata)
- `specs/TODO.md` - Update task 155 entry (status marker, description text)

**Verification**:
- Task 155 description in state.json mentions `no_gaps_discrete`, `GoodStructuresModelSurgery`, and import-cycle fix
- Task 155 description does NOT mention `succ_cofinal` as the target or GHR93 game-theoretic pipeline as the approach
- Task 155 status is `not_started` in both state.json and TODO.md
- `plan_metadata` is cleared or reset

---

### Phase 2: Update task 95 description [COMPLETED]

**Goal**: Replace stale `succ_cofinal` references in task 95's description with the current `no_gaps_discrete` target and note Reynolds model surgery availability.

**Tasks**:
- [ ] Update task 95 `description` field in state.json: replace the sorry chain trace (`dd_countermodel_chronicle_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal`) with the current critical path through `no_gaps_discrete`. Note that the BX chronicle route's `succ_cofinal` is still the current sorry but the correct fix is the WeakCanonical route via `no_gaps_discrete_model_surgery` (task 155 re-scoped objective). Keep items (1), (3)-(6) largely intact, update item (2) to reflect both paths.
- [ ] Update TODO.md entry for task 95 to match the revised description
- [ ] Verify state.json and TODO.md are consistent for task 95

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `specs/state.json` - Update task 95 description field
- `specs/TODO.md` - Update task 95 description text

**Verification**:
- Task 95 description mentions `no_gaps_discrete` as the primary resolution target
- Task 95 description mentions Reynolds model surgery / `no_gaps_discrete_model_surgery` availability
- Task 95 description accurately distinguishes BX chronicle path (`succ_cofinal`) from WeakCanonical path (`no_gaps_discrete`)

---

### Phase 3: Abandon task 224 [COMPLETED]

**Goal**: Set task 224 to abandoned status with clear rationale documenting why the IsSuccArchimedean alternative is no longer needed.

**Tasks**:
- [ ] Update task 224 `status` to `abandoned` in state.json
- [ ] Add `abandonment_reason` field: "IsSuccArchimedean alternative is obsolete -- it addressed succ_cofinal on the BX chronicle path, which is being bypassed entirely. The correct path to sorry-free completeness_discrete is no_gaps_discrete_model_surgery (already sorry-free in GoodStructuresModelSurgery.lean). Task 202 confirmed the Reynolds Z-interval-to-TaskFrame pipeline is architecturally blocked, making this alternative moot regardless of approach."
- [ ] Update TODO.md entry for task 224: change status marker to `[ABANDONED]`, add abandonment note
- [ ] Verify state.json and TODO.md are consistent for task 224

**Timing**: 10 minutes

**Depends on**: 2

**Files to modify**:
- `specs/state.json` - Update task 224 status and add abandonment_reason
- `specs/TODO.md` - Update task 224 status marker and add note

**Verification**:
- Task 224 status is `abandoned` in state.json
- Task 224 status marker is `[ABANDONED]` in TODO.md
- Abandonment reason clearly explains why the task is no longer needed

## Testing & Validation

- [ ] `jq '.active_projects[] | select(.project_number == 155) | .status' specs/state.json` returns `"not_started"`
- [ ] `jq '.active_projects[] | select(.project_number == 155) | .description' specs/state.json` mentions `no_gaps_discrete`
- [ ] `jq '.active_projects[] | select(.project_number == 224) | .status' specs/state.json` returns `"abandoned"`
- [ ] `grep -c "\[NOT STARTED\]" specs/TODO.md` for task 155 entry shows correct marker
- [ ] `grep -c "\[ABANDONED\]" specs/TODO.md` for task 224 entry shows correct marker
- [ ] No JSON parse errors: `jq . specs/state.json > /dev/null`

## Artifacts & Outputs

- `specs/256_rescope_155_update_95_224/plans/01_implementation-plan.md` (this file)
- Updated `specs/state.json` (tasks 155, 95, 224 modified)
- Updated `specs/TODO.md` (tasks 155, 95, 224 entries updated)

## Rollback/Contingency

All changes are to `specs/state.json` and `specs/TODO.md`. If any change introduces inconsistency:
1. Use `git diff specs/state.json specs/TODO.md` to identify the problem
2. Use `git checkout -- specs/state.json specs/TODO.md` to revert to pre-implementation state
3. Re-apply changes incrementally with verification after each phase
