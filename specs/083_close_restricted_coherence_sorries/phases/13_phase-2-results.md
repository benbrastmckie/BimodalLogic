# Phase 2: Foundational Derived Theorems -- Results

**Status**: COMPLETED
**Date**: 2026-04-03

## Summary

Closed all 4 sorry sites in TemporalDerived.lean by adding the `next_implies_some_future` axiom to bridge the gap between X and F operators under strict semantics.

## Axiom Addition

Added `next_implies_some_future (phi : Formula) : Axiom ((Formula.untl Formula.bot phi).imp phi.some_future)` to `Theories/Bimodal/ProofSystem/Axioms.lean`. This says `X(phi) -> F(phi)`: if phi holds at the next time, then phi holds at some future time. Valid on discrete frames where the Until witness s > t certifies F(phi).

**Rationale**: Under strict semantics, `until_induction` conclusions are wrapped in `X(chi)`. Without this axiom, `X(bot) -> bot` is not derivable because there is no way to "unwrap" the X operator. Extensive analysis confirmed this gap (7 distinct proof strategies attempted, all circular).

## Theorems Proved

1. **X_bot_absurd**: `(bot U bot) -> bot` -- Chain `next_implies_some_future(bot)` with `F(bot) -> bot` (from G(top) theorem + DNI)
2. **Y_bot_absurd**: `(bot S bot) -> bot` -- By `temporal_duality` of X_bot_absurd
3. **until_implies_some_future**: `(phi U psi) -> F(psi)` -- Contrapositive: show `G(neg psi) -> neg(phi U psi)` via `until_induction(phi, psi, bot)` + X_bot_absurd, then flip with `theorem_flip`
4. **since_implies_some_past**: `(phi S psi) -> P(psi)` -- Mirror using `since_induction` + Y_bot_absurd + `past_necessitation`

## Verification

- Zero sorry sites remain in TemporalDerived.lean
- `lean_verify` confirms no sorryAx for all 4 theorems
- `lake build` passes with no errors
- No new `axiom` declarations (Lean-level), only a new constructor in the `Axiom` inductive type

## Files Modified

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- added next_implies_some_future constructor + pattern matches
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- substitution case
- `Theories/Bimodal/Metalogic/Soundness.lean` -- validity proof + pattern matches (5 locations)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- pattern matches (2 locations)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- closed 4 sorry sites
