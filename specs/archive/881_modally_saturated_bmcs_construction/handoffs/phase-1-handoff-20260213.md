# Handoff: Task 881 Phase 1

**Date**: 2026-02-13
**Session**: sess_1771030645_147726
**Agent**: lean-implementation-agent

## Immediate Next Action

Prove `buildSeedAux_preserves_getFormulas` lemma in RecursiveSeed.lean:
```lean
theorem buildSeedAux_preserves_getFormulas (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (psi : Formula)
    (h_mem : psi ∈ seed.getFormulas famIdx timeIdx) :
    psi ∈ (buildSeedAux phi famIdx timeIdx seed).getFormulas famIdx timeIdx
```

This is required for `buildSeed_contains_formula` proof.

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Lines modified**: 4716-4922 (new multi-formula builder section)
**Build status**: Succeeds with 5 sorries

### Definitions Added (Complete)
- `buildSeedForList`: Build seed from list of formulas
- `buildSeedForList'`: Alternative definition
- `buildSeedForList_singleton`: Singleton case
- `buildSeedForList_nil`: Empty case

### Proofs Added (With Sorries)
- `foldl_buildSeedAux_preserves_seedConsistent` (1 sorry)
- `buildSeedForList_consistent` (1 sorry)
- `buildSeed_contains_formula` (6 sorry branches)
- `buildSeedForList_contains_input` (1 sorry branch)
- `buildSeedForList_propagates_box` (1 sorry)

## Key Decisions Made

1. **List-based approach**: Chose `buildSeedForList` operating on `List Formula` rather than set-based fold, avoiding termination issues
2. **Sequential processing**: Each formula processed at (0, 0) via `buildSeedAux phi 0 0 seed`
3. **Discovered existing infrastructure**: `SeedCompletion.lean` and `SeedBMCS.lean` already have Phase 2-4 framework (with sorries)

## What NOT to Try

- Don't try to prove consistency without `buildSeedAux_preserves_getFormulas` - it's the core dependency
- Don't create `SeedToFamily.lean` - use existing `SeedCompletion.lean` instead

## Critical Context

1. `addFormula_preserves_mem_getFormulas_same` exists (line 3369) - preserves membership at same position
2. `addFormula_formula_in_getFormulas` exists (line 3105) - formula is added to target position
3. `buildSeedAux` always calls `addFormula` at (famIdx, timeIdx) before recursing
4. The recursive cases (box, all_future, all_past, neg operators) need to show membership is preserved through the recursive call

## References

- Plan: `specs/881_modally_saturated_bmcs_construction/plans/implementation-004.md`
- Research: `specs/881_modally_saturated_bmcs_construction/reports/research-009.md`
- Existing infrastructure: `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`

