# Implementation Summary: Constrained Predecessor Seed

- **Task**: 34 - prove_succ_seed_consistency_axioms
- **Plan**: plans/02_constrained-seed-approach.md
- **Status**: Implemented
- **Date**: 2026-03-23

## What Was Done

Eliminated the `predecessor_f_step_axiom` from `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` by implementing the constrained predecessor seed approach discovered through team research.

### Changes Made

1. **Added `f_step_blocking_formulas` definition**: For each formula phi where both F(phi) is not in u and phi is not in u, the set contains G(not phi). This prevents the Lindenbaum extension from introducing F-formulas that violate the step condition.

2. **Modified `predecessor_deferral_seed`**: Extended from `h_content u ∪ pastDeferralDisjunctions u` to `h_content u ∪ pastDeferralDisjunctions u ∪ f_step_blocking_formulas u`.

3. **Updated membership and subset lemmas**: Fixed `h_content_subset_predecessor_deferral_seed`, `pastDeferralDisjunctions_subset_predecessor_deferral_seed`, and `mem_predecessor_deferral_seed_iff` for the 3-way union.

4. **Extended consistency proof**: Added proof that `f_step_blocking_formulas u ⊆ u` via MCS negation completeness and double negation elimination:
   - F(phi) not in u implies neg(G(neg phi)) not in u
   - By MCS negation completeness: neg(neg(G(neg phi))) in u
   - By double negation elimination: G(neg phi) in u

5. **Added import**: `Bimodal.Metalogic.Bundle.TemporalCoherence` for `double_neg_elim`.

6. **Verified `predecessor_f_step` theorem**: The theorem (which was already present from a previous incomplete attempt) now compiles successfully with the new definitions.

### Key Insight

The breakthrough is that `F(phi) = neg(G(neg phi))` by definition (`Formula.some_future`). When both F(phi) and phi are absent from u, we add G(neg phi) to the seed. This formula is already in u (proven via MCS completeness + double negation elimination), so the seed remains a subset of u and therefore consistent. In any MCS extending this seed, F(phi) = neg(G(neg phi)) cannot coexist with G(neg phi), preventing "bad" F-formulas.

## Verification Results

- **`lake build`**: Success (927 jobs, 0 errors)
- **sorry count**: 0 in SuccExistence.lean
- **axiom count**: 0 in SuccExistence.lean (no `axiom` declarations)
- **`lean_verify predecessor_f_step`**: Clean (no `sorryAx`)
- **`lean_verify predecessor_succ`**: Clean (no `sorryAx`)
- **`lean_verify predecessor_exists`**: Clean (no `sorryAx`)
- **Dependent modules**: All compile (SuccChainFMCS.lean, SuccChainTruth.lean, etc.)

## Axiom Status in SuccExistence.lean

| Axiom | Previous Status | Current Status |
|-------|----------------|----------------|
| `successor_deferral_seed_consistent_axiom` | Proven (v1) | Proven |
| `predecessor_deferral_seed_consistent_axiom` | Proven (v1) | Proven |
| `predecessor_f_step_axiom` | Axiom (blocked in v1) | **Eliminated** (proven as `predecessor_f_step`) |

**Note**: `successor_p_step_axiom` was removed in a previous change (not part of this task). There are zero `axiom` declarations remaining in SuccExistence.lean.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (main changes)
