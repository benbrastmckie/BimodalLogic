# Implementation Summary: Task #1000

**Completed**: 2026-03-19
**Duration**: ~1.5 hours

## Changes Made

Implemented the mutual recursion needed for the temporal_duality soundness case using combined well-founded induction on DerivationTree.height.

### Key Theorems Added

1. **`derivable_valid_and_swap_valid`**: Combined theorem proving both local validity AND swap validity simultaneously for derivable formulas. Uses well-founded recursion on derivation height to handle the mutual dependency in the temporal_duality case.

2. **`derivable_locally_valid`**: Extracted theorem projecting validity from the combined result.

3. **`derivable_implies_swap_valid`**: Extracted theorem projecting swap validity from the combined result. This is the main theorem needed by `soundness_dense`.

### Helper Lemmas Added

- `mp_preserves_valid`: Modus ponens preserves local validity
- `necessitation_preserves_local_valid`: Modal necessitation preserves local validity
- `temporal_necessitation_preserves_local_valid`: Temporal necessitation preserves local validity

## Files Modified

- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
  - Added combined theorem `derivable_valid_and_swap_valid` with well-founded recursion
  - Added extracted theorems `derivable_locally_valid` and `derivable_implies_swap_valid`
  - Added helper lemmas for rule preservation of local validity

- `Theories/Bimodal/Metalogic/Soundness.lean`
  - Replaced sorry in temporal_duality case (line 690-694) with call to `derivable_implies_swap_valid`

## Technical Approach

The temporal_duality case creates a mutual dependency:
- To prove `phi.swap` is valid, need that derivable formulas have valid swaps
- But in temporal_duality subcase of that proof, need that `(phi.swap).swap = phi` is valid

Resolved using Approach A from research report:
- Single function `derivable_valid_and_swap_valid` returns `is_valid D phi AND is_valid D phi.swap`
- For temporal_duality: use `ih.2` for validity goal, `ih.1` with involution for swap goal
- `termination_by d.height` accepted by Lean's termination checker

## Verification

- `lake build` succeeds for full project (1023 jobs)
- SoundnessLemmas.lean: 1 sorry (IRR case, expected)
- Soundness.lean: 8 sorries total
  - 4 in frame-general `soundness` theorem (density, discreteness, seriality axioms - expected)
  - 2 in frame-general `soundness` theorem (temporal_duality, IRR - expected without frame constraints)
  - 1 in `soundness_dense` (IRR case - separate task)
  - 1 documentation reference
- No new axioms introduced

## Notes

- IRR case marked sorry in both `derivable_valid_and_swap_valid` and `soundness_dense` as per plan
- The weakening case required special handling with `subst` and explicit height equality proofs
- Used `Syntax.Context.not_mem_nil` for assumption case impossibility proof
