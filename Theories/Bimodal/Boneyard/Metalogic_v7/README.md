# Metalogic v7 Boneyard

Archived: 2026-02-25 (Task 932)

## Contents

| File | Lines | Original Location | Why Archived |
|------|-------|-------------------|--------------|
| WitnessGraph.lean | 3,403 | Bundle/WitnessGraph.lean | Dead code, witness graph approach incompatible with linear time ordering |
| ChainBundleBFMCS.lean | 338 | Bundle/ChainBundleBFMCS.lean | Dead code, CanonicalBC domain superseded by Int-indexed chain |
| ConstantWitnessFamily_ModalSaturation.lean | ~40 | Bundle/ModalSaturation.lean | Flawed constant witness family pattern |
| SingleFamilyBFMCS.lean | ~28 | Bundle/Construction.lean | Deprecated, sorry-backed modal_backward |
| TemporalSaturationBundle.lean | ~150 | Bundle/TemporalCoherentConstruction.lean | Multiple abandoned approaches and deprecated axiom |

Additionally deleted (not archived):
- RecursiveSeed.lean.backup-v004 (~4,300 lines) - backup file only, not original work

## Total Lines Affected

- Archived to Boneyard: ~3,960 lines of original code
- Deleted (backup file): ~4,300 lines
- Removed from active files: ~320 lines (replaced with warning comments)
- Total: ~8,580 lines removed from active codebase

## Banned Patterns

1. **Constant Witness Families**: Mapping all time points to the same MCS
   - Cannot satisfy forward_F/backward_P because temporal saturation is impossible
   - Counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi

2. **MCS-Membership Box Semantics**: Using `phi in fam'.mcs t` instead of recursive truth
   - bmcs_truth_at_mcs pattern is non-standard and semantically incorrect

3. **Temporal Saturation of Single MCS**: Requiring F(psi)->psi within one MCS
   - Provably impossible for consistent sets containing F-obligations

4. **Single-Family Modal Backward**: Claiming phi -> Box phi for arbitrary phi
   - FALSE in general modal logic, even in S5

5. **Polymorphic D Axioms**: Using axiom for generic type parameter D
   - Only D = Int is ever instantiated downstream; use theorem with sorry instead

## What Was Removed From Active Files

### ModalSaturation.lean
- extendToMCS, extendToMCS_contains, extendToMCS_is_mcs
- constantWitnessFamily, constantWitnessFamily_mcs_eq
- constructWitnessFamily, constructWitnessFamily_contains

### Construction.lean
- singleFamilyBFMCS (sorry in modal_backward)
- singleFamilyBFMCS_eval_family_eq

### TemporalCoherentConstruction.lean
- TemporalForwardSaturated, TemporalBackwardSaturated, TemporallySaturated
- TemporalEvalSaturatedBundle and all methods
- temporal_coherent_family_exists (generic D, sorry)
- construct_temporal_bfmcs and all related theorems
- fully_saturated_bfmcs_exists (deprecated polymorphic AXIOM)
- construct_saturated_bfmcs and all related theorems

## What Was Kept

- fully_saturated_bfmcs_exists_int (active sorry location for future work)
- construct_saturated_bfmcs_int and wrappers (used by Completeness.lean)
- temporal_coherent_family_exists_Int (active, delegates to DovetailingChain)
- TemporalCoherentFamily structure and backward G/H theorems (used by TruthLemma)
- All temporal duality infrastructure (G_dne_theorem, H_dne_theorem, etc.)
- constantBFMCS (general utility, not specifically a "constant witness family")
- lindenbaumMCS / lindenbaumMCS_set (general Lindenbaum helpers)

## References

- specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-007.md - Fundamental tension analysis
- specs/932_remove_constant_witness_family_metalogic/reports/research-001 through research-004 - Full documentation
