# Implementation Summary: Task #912

**Completed**: 2026-02-20
**Duration**: ~3 hours
**Status**: Partial (Phases 1, 2, 5 completed; Phases 3, 4 blocked)

## Overview

Task 912 reviewed the completeness proof and metalogic state after task 910, with two
main objectives: (1) archive superseded experimental code to reduce active sorry count,
and (2) investigate and attempt to discharge the two sorry placeholders in
Representation.lean caused by the Omega-mismatch between `canonicalOmega B` and `Set.univ`.

## Changes Made

### Phase 1: Codebase Archival (COMPLETED)

Archived 29 sorries from the active codebase to Boneyard:

1. **RecursiveSeed/** (5 files, ~25 sorries) -> `Boneyard/Bundle/RecursiveSeed/`
   - Core.lean, Builder.lean, Worklist.lean, Consistency.lean, Closure.lean
   - Updated internal imports to `Bimodal.Boneyard.Bundle.RecursiveSeed.*`

2. **SeedCompletion.lean** (~5 sorries) -> `Boneyard/Bundle/SeedCompletion.lean`
   - Updated import from RecursiveSeed to Boneyard path

3. **SeedBMCS.lean** (~6 sorries) -> `Boneyard/Bundle/SeedBMCS.lean`
   - Updated import from SeedCompletion to Boneyard path

4. **RecursiveSeed.lean** (barrel file) -> `Boneyard/Bundle/RecursiveSeed.lean`
   - Updated all re-export imports

5. **TruthLemma.lean EvalBMCS section** (4 sorries) - Removed
   - `eval_bmcs_truth_lemma` and `eval_bmcs_eval_truth` deleted (unused)

6. **Construction.lean cleanup** - Removed dead code
   - `construct_bmcs`, `construct_bmcs_from_set` and helpers deleted
   - `singleFamilyBMCS` retained (still used by TemporalCoherentConstruction.lean)

7. **Documentation fixes**
   - FMP/FiniteWorldState.lean: Fixed stale comment (strict -> reflexive semantics)
   - Metalogic.lean: Updated sorry table to accurate 9 active sorries
   - Completeness.lean: Updated cross-references

### Phase 2: Omega-Mismatch Investigation (COMPLETED)

Performed thorough mathematical investigation of three approaches to resolve the
Omega-mismatch between `canonicalOmega B` and `Set.univ`:

**Finding 1: Coverage lemma unprovable**
- `is_modally_saturated` provides diamond witnesses, not MCS coverage
- The canonical frame's WorldState = `{ S // SetMaximalConsistent S }` includes ALL MCSes
- BMCS families only contain specific MCSes from the construction
- No mechanism to ensure every MCS appears in some family

**Finding 2: Truth lemma with Set.univ unprovable**
- Box case requires IH at canonical histories (sigma in canonicalOmega)
- Extending to Set.univ requires IH at arbitrary histories
- Induction structure only provides IH at canonical histories

**Finding 3: Omega-parametric validity breaks soundness**
- MF axiom (Box phi -> G phi) uses `Set.univ_shift_closed` in soundness proof
- `canonicalOmega B` is NOT shift-closed (documented in Representation.lean)
- Making `valid` quantify over arbitrary Omega breaks MF/TF soundness

**Conclusion**: The Omega-mismatch is a genuine mathematical gap requiring either:
- (A) Add `ShiftClosed Omega` condition to `valid`/`semantic_consequence`
- (B) Prove truth equivalence via stronger saturation (coverage + state-determination)
- (C) Leave sorry and document as known gap

### Phases 3-4: BLOCKED

Blocked by the Omega-mismatch finding. The two sorry placeholders in Representation.lean
(lines ~417, ~449) cannot be discharged without a resolution path for the mismatch.

### Phase 5: Final Verification (COMPLETED)

- `lake build` succeeds (1000 jobs, 0 errors)
- Active Metalogic/ sorry count: 9 (down from 38)
- Active axiom count: 2 (`fully_saturated_bmcs_exists` [deprecated], `saturated_extension_exists`)
- No new sorries or axioms introduced
- All documentation updated

## Files Modified

### Active Files
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Removed dead code, updated docs
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Removed EvalBMCS section (4 sorries)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Updated cross-references
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Updated sorry table
- `Theories/Bimodal/Metalogic/Representation.lean` - Added Omega-mismatch analysis
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Fixed stale documentation

### Archived Files (moved to Boneyard/)
- `Theories/Bimodal/Boneyard/Bundle/RecursiveSeed/` (5 files, new)
- `Theories/Bimodal/Boneyard/Bundle/RecursiveSeed.lean` (barrel file, new)
- `Theories/Bimodal/Boneyard/Bundle/SeedCompletion.lean` (new)
- `Theories/Bimodal/Boneyard/Bundle/SeedBMCS.lean` (new)

### Deleted Files (from active codebase)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/` (5 files)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

## Sorry Inventory (Active Metalogic/)

| File | Line | Description | Dependency |
|------|------|-------------|------------|
| Representation.lean | ~417 | Omega-mismatch (weak completeness) | Genuine gap |
| Representation.lean | ~449 | Omega-mismatch (strong completeness) | Genuine gap |
| Construction.lean | 197 | modal_backward (single-family) | Inherited by TemporalCoherentConstruction |
| TemporalCoherentConstruction.lean | 636 | temporal_coherent_family_exists | DovetailingChain sorries |
| TemporalCoherentConstruction.lean | 842 | fully_saturated_bmcs_exists_int | Combines temporal + modal |
| DovetailingChain.lean | 606 | cross-sign forward propagation | Core construction |
| DovetailingChain.lean | 617 | cross-sign backward propagation | Core construction |
| DovetailingChain.lean | 633 | F-witness existence | Core construction |
| DovetailingChain.lean | 640 | P-witness existence | Core construction |

## Verification

- `lake build` succeeds with 0 errors
- No new sorry or axiom declarations introduced
- 29 sorries eliminated by archival (38 -> 9 in active Metalogic/)
- Main completeness theorems (bmcs_weak_completeness, bmcs_strong_completeness) remain SORRY-FREE

## Recommendations for Follow-up

1. **Omega-mismatch resolution** (new task): Redesign `valid` and `semantic_consequence`
   in Validity.lean to add `ShiftClosed Omega` parameter. This would enable the sorry
   discharge in Representation.lean without breaking soundness.

2. **DovetailingChain sorries** (existing debt): 4 sorries for cross-sign temporal
   propagation and F/P witness existence. These block `fully_saturated_bmcs_exists_int`.

3. **Construction.lean modal_backward**: 1 sorry inherited from the single-family approach.
   Will be eliminated when `construct_temporal_bmcs` is replaced by a multi-family construction.
