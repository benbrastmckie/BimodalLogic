# Phase 3 Handoff: Theorems Layer (Mechanical, Base-Only)

**Task**: 168 - Parameterize DerivationTree over FrameClass
**Phase**: 3 of 7
**Status**: COMPLETED
**Session**: sess_1779757476_869869
**Date**: 2026-05-25

## Summary

Phase 3 is complete. All Theorems/ files and the DeductionTheorem dependency compile cleanly.

## Changes Made

### Mechanical: Added `trivial` to all DerivationTree.axiom calls

All files in Theorems/ had `trivial` added as the 4th argument (h_fc) to every `DerivationTree.axiom` call. Since all axioms used in Theorems/ are base axioms, `Base ≤ Base` is `True`, so `trivial` works.

Files modified: Combinators.lean (30 calls), Propositional.lean (7), TemporalDerived.lean (12), GeneralizedNecessitation.lean (3), ModalS4.lean (9), ModalS5.lean (11), Bridge.lean (16), Helpers.lean (5), Principles.lean (20).

### Helpers.lean: Made helper functions fc-polymorphic

`axiom_in_context`, `apply_axiom_to`, `apply_axiom_in_context` now take `{fc : FrameClass}` and `h_fc` parameters, since they accept generic `Axiom φ` values.

### DeductionTheorem.lean: Made fully fc-polymorphic (deviation from plan)

The deduction theorem was pulled forward from Phase 5 because it's a transitive dependency of Propositional.lean. All functions (`deduction_theorem`, `deduction_with_mem`, `deduction_axiom`, `deduction_assumption_same`, `deduction_assumption_other`, `deduction_mp`, `weaken_under_imp`, `weaken_under_imp_ctx`, `exchange`) now have `{fc : FrameClass}` implicit parameter.

Key technique: `identity A` (from Combinators, at `.Base`) is lifted via `DerivationTree.lift (fc₁ := .Base) trivial` when needed at a generic `fc`.

## Build Status

- `lake build Bimodal.Theorems.Propositional`: PASSES
- `lake build Bimodal.Theorems.ModalS4 Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity`: PASSES
- `lake build Bimodal.Metalogic.Core.DeductionTheorem`: PASSES (with warnings)

## Next Action

Phase 4: Soundness Refactor. Rewrite soundness theorems to use parameterized DerivationTree. Remove h_dc parameters. Create unified axiom_valid dispatch.
