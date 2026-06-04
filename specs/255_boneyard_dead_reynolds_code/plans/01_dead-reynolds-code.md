# Implementation Plan: Archive Dead Reynolds Code to Boneyard

- **Task**: 255 - Archive dead code to Boneyard/ after task 202 completed Reynolds model surgery
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/255_boneyard_dead_reynolds_code/reports/01_dead-reynolds-code.md
- **Artifacts**: plans/01_dead-reynolds-code.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive deprecated BX pipeline dead code left over after task 202 completed the Reynolds model surgery. Three targets: (1) extract 4 dead definitions from ReynoldsNoGaps.lean to Boneyard (leaving 3 live definitions in place), (2) replace the countermodel_discrete body in Transfer.lean with a direct sorry (making the existing implicit sorry explicit), and (3) remove a redundant import from ShiftAndGlue.lean. ReynoldsModelSurgery.lean is already in Boneyard and requires no action.

### Research Integration

The research report (01_dead-reynolds-code.md) identified:
- ReynoldsModelSurgery.lean already archived in Boneyard/BXPipelineDeadCode (no action)
- ReynoldsNoGaps.lean has 4 dead definitions (zero external references) and 3 live definitions (referenced by GoodStructuresModelSurgery.lean)
- Transfer.lean countermodel_discrete has a live reference from Completeness.lean:165 but its body is already sorry'd through dd_countermodel_chronicle_discrete; replacing with direct sorry removes dead BX dependency
- ShiftAndGlue.lean has a redundant ReynoldsNoGaps import (gets it transitively via GoodStructuresModelSurgery)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation required for this code-quality cleanup task.

## Goals & Non-Goals

**Goals**:
- Remove 4 dead definitions from ReynoldsNoGaps.lean, preserving 3 live definitions
- Archive dead definitions to Boneyard/BXPipelineDeadCode with documentation
- Replace countermodel_discrete body with explicit top-level sorry
- Remove redundant import from ShiftAndGlue.lean
- Update Boneyard README directory inventory

**Non-Goals**:
- Fixing any sorries (this is archival, not proof work)
- Moving ReynoldsModelSurgery.lean (already archived)
- Archiving live definitions used by GoodStructuresModelSurgery.lean
- Resolving the countermodel_discrete sorry (that is task 129 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing wrong definition from ReynoldsNoGaps.lean (live vs dead) | H | L | Verify zero external references via grep before removing; lake build after |
| ShiftAndGlue import removal breaks transitive dependency | M | L | Verify GoodStructuresModelSurgery already provides ReynoldsNoGaps transitively; lake build after |
| countermodel_discrete sorry replacement changes proof tree | L | L | Functionally equivalent (was already sorry'd); lake build confirms |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Clean ShiftAndGlue import and Transfer.lean countermodel_discrete [COMPLETED]

**Goal**: Remove redundant import and simplify countermodel_discrete body

**Tasks**:
- [x] Remove line 2 (`import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps`) from ShiftAndGlue.lean
- [x] In Transfer.lean, replace the `countermodel_discrete` body (lines 1291-1298) with a direct `sorry` -- the theorem signature stays identical, only the body changes from `Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete FrameClass.Base A h_mcs sorry phi h_neg_in h_box_discrete` to `by sorry`
- [x] Run `lake build` to verify no breakage

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` - Remove redundant import line 2
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Replace countermodel_discrete body with direct sorry

**Verification**:
- `lake build` passes with zero errors
- `grep -rn 'countermodel_discrete' Theories/` confirms the definition still exists and Completeness.lean still references it

---

### Phase 2: Extract dead definitions from ReynoldsNoGaps.lean to Boneyard [COMPLETED]

**Goal**: Remove 4 dead definitions from ReynoldsNoGaps.lean and archive them

**Tasks**:
- [x] Verify zero external references for each dead definition: `no_gaps_discrete_archimedean`, `no_gaps_prior`, `prior_implies_succ_archimedean`, `one_class_implies_succ_archimedean` (grep across Theories/ excluding Boneyard/)
- [x] Remove from ReynoldsNoGaps.lean:
  - `no_gaps_discrete_archimedean` (starting around line 111)
  - `no_gaps_prior` (starting around line 276)
  - `prior_implies_succ_archimedean` (starting around line 299)
  - `one_class_implies_succ_archimedean` (starting around line 321)
- [x] Also remove `orbit_le_succ_closed` (private helper for `gap_of_not_succ_archimedean`, starting around line 133) only if it has zero references after the dead definitions are removed -- check carefully as it may be used by the live `gap_of_not_succ_archimedean` *(deviation: altered -- orbit_le_succ_closed had zero references even before dead definition removal; removed as dead code)*
- [x] Create `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` containing:
  - Module header documenting the archival (task 255)
  - The 4 extracted definitions with `#exit` after imports (they reference deleted code)
  - Comments explaining why each was deprecated
- [x] Run `lake build` to verify no breakage

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` - Remove 4 dead definitions
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` - New file with archived definitions

**Verification**:
- `lake build` passes with zero errors
- ReynoldsNoGaps.lean retains `very_good_of_archimedean`, `one_class_archimedean`, `gap_of_not_succ_archimedean`
- GoodStructuresModelSurgery.lean still compiles (uses the live definitions)

---

### Phase 3: Update Boneyard documentation [NOT STARTED]

**Goal**: Update Boneyard README and add BXPipelineDeadCode README

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/BXPipelineDeadCode/README.md` documenting:
  - ReynoldsModelSurgery.lean (already archived, task 268)
  - ReynoldsNoGapsDeprecated.lean (new, task 255)
  - Why archived: BX pipeline dead code after Reynolds model surgery completion
- [ ] Update `Theories/Bimodal/Boneyard/README.md`:
  - Update BXPipelineDeadCode row in Directory Inventory: files 2 (was 1), update line count, add task 255 reference
  - Add task 255 to the Task Cross-References table
- [ ] Run `lake build` to verify documentation changes did not affect build

**Timing**: 20 minutes

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/README.md` - New file
- `Theories/Bimodal/Boneyard/README.md` - Update inventory and cross-references

**Verification**:
- `lake build` passes
- Boneyard README inventory table is consistent with actual directory contents

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] `grep -rn 'no_gaps_prior\|prior_implies_succ_archimedean\|one_class_implies_succ_archimedean\|no_gaps_discrete_archimedean' Theories/ --include='*.lean' | grep -v Boneyard` returns zero results
- [ ] `grep -rn 'gap_of_not_succ_archimedean\|one_class_archimedean\|very_good_of_archimedean' Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` confirms live references still work
- [ ] `grep -rn 'countermodel_discrete' Theories/Bimodal/Metalogic/WeakCanonical/Completeness.lean` confirms the reference is intact
- [ ] No new sorries introduced (net sorry change: -1 from removing `no_gaps_prior` sorry, +0 from Transfer.lean which was already sorry'd)

## Artifacts & Outputs

- `specs/255_boneyard_dead_reynolds_code/plans/01_dead-reynolds-code.md` (this plan)
- `specs/255_boneyard_dead_reynolds_code/summaries/01_dead-reynolds-code-summary.md` (post-implementation)
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` (archived definitions)
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/README.md` (subdirectory documentation)

## Rollback/Contingency

All changes are to well-isolated files with no downstream dependencies on the removed code. If any phase causes unexpected build failures:
1. `git stash` or `git checkout -- <file>` to revert the specific file
2. Re-run `lake build` to confirm revert is clean
3. Investigate the unexpected dependency before retrying
