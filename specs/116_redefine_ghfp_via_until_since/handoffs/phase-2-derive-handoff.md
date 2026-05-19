# Phase 2 Handoff: Derive temp_k_dist and temp_4

**Date**: 2026-05-19
**Session**: sess_1779159757_8a4784
**Phase**: 2 (Steps 2.1-2.4 only)
**Status**: Steps 2.1-2.4 COMPLETED; Steps 2.5-2.10 NOT YET STARTED

## What Was Done

Added two sorry-free derived theorems to `Theories/Bimodal/Theorems/TemporalDerived.lean`:

### temp_k_dist_derived

**Statement**: `G(phi -> psi) -> (G(phi) -> G(psi))`

**Derivation**: Uses BX3 (right_mono_until) and propositional contraposition in three steps:
1. From the propositional tautology `not(not psi -> not phi) -> not(phi -> psi)`, lift through G via temporal necessitation, then apply BX3 to get `F(not(not psi -> not phi)) -> F(not(phi -> psi))`.
2. Take the contrapositive to get `G(phi -> psi) -> G(not psi -> not phi)`.
3. Apply BX3 with `alpha := not psi, beta := not phi, gamma := top` to get `G(not psi -> not phi) -> (F(not psi) -> F(not phi))`, then take the propositional contrapositive to get `G(phi) -> G(psi)`.
4. Compose steps 2 and 3.

Helper lemmas (all private):
- `neg_contrapositive_imp_neg`: The tautology for step 1
- `F_neg_contra_imp_F_neg`: Step 1 (F-monotonicity via BX3)
- `G_imp_to_G_contra`: Step 2 (contrapositive of step 1)
- `G_contra_to_GK`: Step 3 (BX3 + propositional contrapositive)

### temp_4_derived

**Statement**: `G(phi) -> G(G(phi))`

**Derivation**: The contrapositive `F(not not F(not phi)) -> F(not phi)` is proved in three steps:
1. `F(not not F(not phi)) -> F(F(not phi))` via BX3 + double negation elimination.
2. `F(F(not phi)) -> F(top and F(not phi))` via BX3 + the tautology `X -> top and X`.
3. `F(top and F(not phi)) -> F(not phi)` via BX6 (absorb_until).
Composing and taking the contrapositive gives `G(phi) -> G(G(phi))`.

Helper lemmas (all private):
- `top_and_intro`: The tautology `X -> top and X`
- `dne_lift_F`: Step 1
- `FF_to_F_top_and`: Step 2
- `F_top_and_absorb`: Step 3 (direct BX6 instance)

## Build Status

- The derived theorems themselves type-check successfully (verified via lean_goal: no remaining goals).
- `lake build Bimodal.Theorems.TemporalDerived` fails due to pre-existing errors in `GeneralizedNecessitation.lean` (upstream dependency), which is being fixed by another agent working on downstream files.
- The errors in `GeneralizedNecessitation.lean` are caused by `all_future` changing from a constructor to a `def` in Phase 1, causing `swap_temporal` simplification to break in `past_k_dist` and `past_necessitation`.

## Immediate Next Action

**Steps 2.5-2.10** (replace invocations, remove axiom constructors) should be done AFTER the downstream file fixes are complete, as they require a passing build. Specifically:

1. Replace all ~45 invocations of `Axiom.temp_k_dist` and `Axiom.temp_4` with `temp_k_dist_derived` and `temp_4_derived`.
2. Remove the `| temp_k_dist` and `| temp_4` constructors from `Axiom` in `Axioms.lean`.
3. Fix match arms in Soundness.lean, DiscreteSoundness.lean, Substitution.lean.
4. Verify full build.

## Key Decisions

- **No past versions needed**: The H analogues (`H_distribution`, `H_transitivity`) are already derived via temporal duality from the G versions in `GeneralizedNecessitation.lean`. Once that file is fixed, the past versions will work automatically.
- **Derivation approach**: Used BX3 (right_mono_until) as the primary tool for F-monotonicity, combined with propositional contraposition. This avoids any circularity since BX3 is a primitive axiom.
- **BX6 for temp_4**: The absorption axiom `U(phi and U(psi, phi), phi) -> U(psi, phi)` is the key to proving `F(F(X)) -> F(X)`, which is the contrapositive form of `G(phi) -> G(G(phi))`.

## Files Modified

- `Theories/Bimodal/Theorems/TemporalDerived.lean` (added ~100 lines of derived theorems)
