# Implementation Summary: Task #996 - Soundness Theorem Assembly

**Status**: PARTIAL
**Completed**: 2026-03-19
**Duration**: ~2 hours

## Summary

This task attempted to wire the 6 remaining sorries in Soundness.lean using proven component theorems. The implementation created a `soundness_dense` theorem with frame constraints but encountered blocking issues with the temporal_duality and IRR cases.

## Changes Made

### 1. Added DerivationTree Compatibility Predicates (Derivation.lean)

Added two new predicates to `DerivationTree`:
- `isDenseCompatible`: Returns `True` for derivations that only use axioms valid on dense frames (excludes `discreteness_forward`)
- `isDiscreteCompatible`: Returns `True` for derivations that only use axioms valid on discrete frames (excludes `density`)

These predicates enable type-safe filtering of derivations by frame class.

### 2. Created soundness_dense Theorem (Soundness.lean)

Created a new `soundness_dense` theorem with:
- Frame constraints: `[DenselyOrdered D]`, `[Nontrivial D]`
- Dense compatibility constraint: `h_dc : d.isDenseCompatible`
- Removed domain restriction (h_dom) from main theorem signature

**Fully wired cases** (no sorry):
- All 16 base axioms (prop_k, prop_s, modal_t, etc.)
- `density` axiom (using `density_valid`)
- `discreteness_forward` (eliminated as absurd by `h_dc`)
- `seriality_future` and `seriality_past` (using `NoMaxOrder`/`NoMinOrder` from dense frames)
- `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `weakening`

**Blocked cases** (sorry):
- `temporal_duality`: Requires `derivable_implies_swap_valid` theorem which needs mutual recursion with `derivable_locally_valid`. Attempted implementation hit Lean termination checking issues.
- `irr`: Requires `irr_sound_dense_at_domain` from IRRSoundness.lean, which has pre-existing build errors (String vs Atom type mismatch and omega failures on generic types).

## Files Modified

1. `Theories/Bimodal/ProofSystem/Derivation.lean`
   - Added `isDenseCompatible` predicate
   - Added `isDiscreteCompatible` predicate

2. `Theories/Bimodal/Metalogic/Soundness.lean`
   - Added `soundness_dense` theorem (~100 lines)
   - Wired all base axiom cases and non-temporal-duality rule cases

## Blocking Issues

### Issue 1: temporal_duality Case

The temporal_duality case requires proving that if `d' : ⊢ φ'` with dense-compatible derivation, then `φ'.swap` is valid. This requires two mutually recursive theorems:
- `derivable_locally_valid`: `⊢ φ` implies `φ` is valid
- `derivable_implies_swap_valid`: `⊢ φ` implies `φ.swap` is valid

The mutual recursion is needed because:
- `derivable_locally_valid` needs `derivable_implies_swap_valid` for the temporal_duality case (φ becomes φ'.swap)
- `derivable_implies_swap_valid` needs `derivable_locally_valid` for the temporal_duality case (swap of swap = original)

Lean's termination checker cannot infer structural recursion on `DerivationTree [] φ` because the formula index is not a variable.

### Issue 2: IRRSoundness.lean Pre-existing Errors

The IRRSoundness.lean file has pre-existing build errors:
1. Type mismatch between `String` and `Atom` in `prod_model`, `truth_prod_iff`, and `irr_sound_dense_at_domain`
2. `omega` tactic failures on generic ordered group types in `prod_frame` construction

These errors exist in the main branch before this task.

## Verification

- `lake build Bimodal.Metalogic.Soundness` succeeds with warnings about sorries
- `lake build Bimodal.ProofSystem.Derivation` succeeds
- 2 sorries remain in `soundness_dense` (temporal_duality, irr)
- Original `soundness` theorem unchanged (6 sorries as before)

## Recommendations for Completion

1. **temporal_duality**: Implement the mutual recursion using explicit termination proof with `DerivationTree.height` measure, or restructure as a single well-founded recursion.

2. **IRRSoundness**: Fix the pre-existing type errors by changing `p : String` to `p : Atom` throughout, and replace `omega` with algebraic tactics appropriate for generic ordered groups.

3. **Consider alternative**: The research report suggested creating frame-class-restricted soundness theorems. The current approach is viable but requires more work on the mutual recursion.

## Notes

- The build passes with no errors (only warnings about sorries)
- The predicates added to Derivation.lean provide a clean API for future frame-class work
- Phase 4 (soundness_discrete) and Phase 5 (documentation) were not attempted due to blocking issues in Phase 2/3
