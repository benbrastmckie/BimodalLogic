# Implementation Summary: K-Relational Pipeline (Phase 5 BLOCKED - axiom gap)

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09 (session 3)
**Session**: sess_1741536300_i956impl
**Plan**: implementation-005.md (K-Relational strategy)
**Status**: Partial (3 phases complete, 1 blocked, Phase 4+5 blocked, 6 not started)

## Phase 5 Blocker Analysis

### Problem Statement

Phase 5 requires proving `NoMaxOrder` and `NoMinOrder` on `RestrictedQuotient`. This requires showing that every MCS in the fragment has a **strict** CanonicalR-successor (and predecessor).

### Root Cause: Missing Temporal T-Axiom

The plan assumed `G(phi) -> phi` (temporal T-axiom / reflexivity) is available, which would give `G(bot) in M -> bot in M` (contradiction with consistency), hence `F(neg bot) in M` for all MCS M.

**However**: The temporal T-axioms (`temp_t_future: G(phi) -> phi` and `temp_t_past: H(phi) -> phi`) were:
1. **Added** in commit 29307540 (task 658, phase 1)
2. **Removed** in commit 12cb4f65 (task 782: restore to pre-archival state)

The current axiom system has 15 base constructors + density/discreteness. None of them give `G(phi) -> phi`.

### Mathematical Analysis

The semantics is **strictly irreflexive**: `G(phi)` at time `t` means `forall s > t, phi(s)` (strict inequality). With this semantics:
- `G(phi) -> phi` is NOT sound (countermodel: single-point timeline where G is vacuously true)
- `F(neg bot)` is NOT a theorem (consistent with `G(bot) in M` when M has no strict future)
- A timeline with endpoints is consistent with TM + DN axioms

### Consequences

1. The canonical model of TM + DN can have MCSes that are "temporal endpoints" (no strict future/past)
2. For propositional input formulas, the root MCS `M0` may be an isolated point with `G(bot)` and `H(bot)`
3. The restricted fragment would be `{M0}` alone -- trivially DenselyOrdered but NOT `NoMaxOrder` or `NoMinOrder`
4. Cantor's theorem `Order.iso_of_countable_dense` requires `NoMaxOrder` and `NoMinOrder` as hypotheses

### Impact on Pipeline

```
Phases 1-3: COMPLETE (countability, linear order) -- NOT affected
Phase 4: NOT STARTED (density) -- separate blocker
Phase 5: BLOCKED (no-endpoints requires axiom gap resolution)
Phases 6-10: BLOCKED by Phase 5 (Cantor iso requires no-endpoints)
```

### Possible Resolutions

1. **Re-add temporal T-axioms**: Add `G(phi) -> phi` and `H(phi) -> phi` back to the axiom system. But these are NOT sound for strict future semantics, so this would require changing the semantics to reflexive (>= instead of >).

2. **Change semantics to reflexive**: Redefine `truth_at` so G/H use >= and <=. This is a large refactoring that affects soundness proofs, the canonical model construction, and possibly the density/discreteness axioms.

3. **Restrict to temporal formulas**: Only prove completeness for formulas that "use" temporal operators, ensuring the root MCS has temporal content. But this limits the theorem's applicability.

4. **Add no-endpoint axioms**: Add `F(neg bot)` and `P(neg bot)` as explicit axioms (or derive them from added axioms). Sound for dense linear orders without endpoints but not for general strict orders.

5. **Work with bounded orders**: Use a different characterization that doesn't require no-endpoints. For example, prove isomorphism with `[0,1] ∩ Q` (countable dense linear order WITH endpoints).

6. **Hybrid approach**: Prove completeness conditionally -- assume the canonical model has no endpoints as a hypothesis, prove the Cantor isomorphism under that hypothesis.

## Completed Work (unchanged from session 2)

### Phase 1: Verify Existing Infrastructure [COMPLETED]
- sorry-free infrastructure confirmed

### Phase 2: Define Restricted Countable Fragment [COMPLETED]
- `RestrictedFragment.lean` (~430 lines)
- `Countable RestrictedFragment` via path encoding surjection

### Phase 3: Prove Totality on Restricted Fragment [COMPLETED]
- `LinearOrder RestrictedQuotient` via antisymmetrization
- `Countable RestrictedQuotient` and `Nonempty RestrictedQuotient`

## New Files
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (~430 lines)

## Sorry Audit
- RestrictedFragment.lean:423 - NoMaxOrder sorry (BLOCKED by axiom gap)
- RestrictedFragment.lean:434 - NoMinOrder sorry (BLOCKED by axiom gap)

## Key Finding
The research reports (research-023 lines 125-127) incorrectly identify `temp_a` as the temporal T-axiom. `temp_a` is actually `phi -> G(P_exists(phi))` (connectedness), not `G(phi) -> phi` (reflexivity). This confusion propagated into the plan's Phase 5 strategy.
