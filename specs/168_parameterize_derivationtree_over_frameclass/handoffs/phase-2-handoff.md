# Phase 2 Handoff: ProofSystem Layer and Derivable

**Task**: 168 - Parameterize DerivationTree over FrameClass
**Phase**: 2 of 7
**Status**: COMPLETED
**Session**: sess_1779757476_869869
**Date**: 2026-05-25

## Summary

Phase 2 is complete. All ProofSystem/ files compile cleanly. Zero sorries, zero vacuous definitions.

## Changes Made

### Theories/Bimodal/ProofSystem/Derivable.lean

1. **Parameterized `Derivable`**: `def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop`
2. **Added `Derivable.lift`**: Wraps `DerivationTree.lift` for Prop-valued derivability
3. **Updated all constructor-mirroring lemmas**: `ax` now requires `h_fc`, all others thread `fc` as implicit
4. **Added new notation**: `G |-![fc] p` and `|-![fc] p` for explicit frame class; `G |-! p` and `|-! p` default to `.Base`
5. **Updated all examples**: Explicit `.Base` where needed; added lift example
6. **Updated docstrings**: Reflect frame class parameterization

### Theories/Bimodal/ProofSystem/Substitution.lean

1. **Added `density` case** to `axiom_subst`: Handles the new density axiom constructor
2. **Added `axiom_subst_minFrameClass`**: Proves substitution preserves `minFrameClass`
3. **Threaded `fc`** through `derivation_subst`: Now `{fc : FrameClass}` implicit parameter
4. **Updated axiom case**: Uses `axiom_subst_minFrameClass` rewrite to transfer `h_fc` proof

### Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean

1. **Added `trivial`** for `h_fc` proof in `temp_linearity_derivation` (temp_linearity is a base axiom)

## Build Status

- `lake build Bimodal.ProofSystem`: PASSES (661 jobs)

## Next Action

Phase 3: Update Theorems/ layer (10 files). All use base axioms, so `h_fc` proofs will be `trivial` or `le_refl`. The `|- f` notation defaults to `.Base`, so many signatures should be unchanged.
