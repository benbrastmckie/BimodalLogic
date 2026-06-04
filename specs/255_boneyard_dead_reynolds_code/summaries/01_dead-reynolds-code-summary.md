# Implementation Summary: Archive Dead Reynolds Code to Boneyard

- **Task**: 255
- **Status**: Implemented
- **Session**: sess_1749054756_a3b2c1
- **Date**: 2026-06-04

## What Was Done

Archived deprecated BX pipeline dead code left over after task 202 completed
the Reynolds model surgery approach.

### Phase 1: Clean ShiftAndGlue import and Transfer.lean countermodel_discrete

- Removed redundant `import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsNoGaps`
  from ShiftAndGlue.lean (gets it transitively via GoodStructuresModelSurgery)
- Replaced `countermodel_discrete` body in Transfer.lean with direct `sorry`,
  removing the dead BX pipeline dependency through `dd_countermodel_chronicle_discrete`.
  The theorem signature is unchanged; Completeness.lean still references it.

### Phase 2: Extract dead definitions from ReynoldsNoGaps.lean to Boneyard

- Verified zero external references for all 4 dead definitions
- Removed from ReynoldsNoGaps.lean:
  - `no_gaps_discrete_archimedean` (vacuously true, zero consumers)
  - `no_gaps_prior` (mathematically false as stated, contained sorry)
  - `prior_implies_succ_archimedean` (depended on no_gaps_prior)
  - `one_class_implies_succ_archimedean` (wrapper around prior_implies_succ_archimedean)
  - `orbit_le_succ_closed` (private helper, zero references)
- Also removed unused `PriorExpressiveness` import
- Created `Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` with archived
  definitions behind `#exit`
- Updated ReynoldsNoGaps.lean module doc comment to reflect remaining definitions

### Phase 3: Update Boneyard documentation

- Created `Boneyard/BXPipelineDeadCode/README.md` documenting both
  ReynoldsModelSurgery.lean (task 268) and ReynoldsNoGapsDeprecated.lean (task 255)
- Added BXPipelineDeadCode row to Boneyard README Directory Inventory
  (was missing -- task 268 had not created it)
- Added BXPipelineDeadCode subdirectory details section
- Added tasks 268 and 255 to Task Cross-References table

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` -- removed redundant import
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- simplified countermodel_discrete body
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsNoGaps.lean` -- removed 4 dead definitions + unused import

## Files Created

- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/ReynoldsNoGapsDeprecated.lean` -- archived dead definitions
- `Theories/Bimodal/Boneyard/BXPipelineDeadCode/README.md` -- subdirectory documentation

## Files Updated (Documentation Only)

- `Theories/Bimodal/Boneyard/README.md` -- added BXPipelineDeadCode inventory row, subdirectory details, and cross-references

## Verification

- `lake build` passes (1684 jobs, zero errors)
- Zero new sorries introduced (Transfer.lean sorry was pre-existing via dead BX chain)
- Zero new axioms introduced
- All live definitions (`very_good_of_archimedean`, `one_class_archimedean`,
  `gap_of_not_succ_archimedean`) confirmed still referenced by GoodStructuresModelSurgery.lean
- `countermodel_discrete` reference in BXCanonical/Completeness.lean confirmed intact

## Plan Deviations

- **Task 2.3** (orbit_le_succ_closed): altered -- the helper had zero references even
  before dead definition removal, not just after. Removed as straightforward dead code.
- **Task 3.2** (Boneyard README update): altered -- BXPipelineDeadCode had no existing
  row in the Directory Inventory (task 268 never created one). Added a new row rather
  than updating an existing one.

## Net Impact

- **Lines removed from active code**: ~220 (4 dead theorems + 1 private helper + section comments + unused import)
- **Lines added to Boneyard**: 161 (ReynoldsNoGapsDeprecated.lean)
- **Sorry change**: net -1 (removed no_gaps_prior sorry; Transfer.lean sorry was already present)
