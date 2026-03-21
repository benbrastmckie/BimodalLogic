# Implementation Summary: Remove DN-Based Seriality Proofs Tech Debt

**Task**: 980 - remove_dn_based_seriality_proofs_tech_debt
**Date**: 2026-03-16
**Session**: sess_1773695456_456a55
**Status**: COMPLETED

## Overview

Removed technical debt where the discrete timeline construction incorrectly used the density
axiom DN (`F(phi) -> F(F(phi))`) to prove NoMaxOrder/NoMinOrder. The discrete logic explicitly
excludes DN because density and discreteness are incompatible frame conditions.

## Solution: MCS Richness Approach

Instead of the originally planned "Direct NoMaxOrder" approach, we implemented MCS Richness,
which provides a cleaner DN-free proof.

### Key Insight

For any atom i, either `G(bot ∧ neg(atom(i))) ∈ M` or `F(neg bot ∨ atom(i)) ∈ M` by MCS
negation completeness. The former would imply `G(bot) ∈ M`, contradicting seriality
`F(neg bot) ∈ M`. Therefore `F(neg bot ∨ atom(i)) ∈ M` for ALL atoms i.

Since atoms are infinite and formula encodings are injective, the formulas `(neg bot ∨ atom(i))`
have unbounded encodings. This gives MCS Richness: for any N, exists phi with encoding >= N
such that `F(phi) ∈ M`, WITHOUT using the density axiom.

## Changes Made

### CantorPrereqs.lean

**New Lemmas (Future direction):**
- `G_bot_not_in`: G(bot) is not in any serial MCS
- `G_bot_and_of_G_bot_and_X`: G(bot ∧ X) implies G(bot) via K-distribution
- `orAtomFormula`: Formula (neg bot ∨ atom(natToAtom n)) for index n
- `orAtomFormula_injective`: Different indices give different formulas
- `F_or_atom_in`: For any atom i, F(neg bot ∨ atom(i)) ∈ M
- `mcs_has_large_F_formula`: For any N, ∃ phi with encoding >= N and F(phi) ∈ M

**New Lemmas (Past direction):**
- `derive_past_necessitation`: Derive ⊢ H(phi) from ⊢ phi via temporal duality
- `derive_past_k_dist`: Derive past K-distribution via temporal duality
- `H_bot_not_in`: H(bot) is not in any serial MCS
- `H_bot_and_of_H_bot_and_X`: H(bot ∧ X) implies H(bot)
- `P_or_atom_in`: For any atom i, P(neg bot ∨ atom(i)) ∈ M
- `mcs_has_large_P_formula`: For any N, ∃ phi with encoding >= N and P(phi) ∈ M

**Refactored Theorems:**
- `discrete_staged_has_future`: Now uses `mcs_has_large_F_formula` (DN-free)
- `discrete_staged_has_past`: Now uses `mcs_has_large_P_formula` (DN-free)

### LogicVariants.lean

Updated the technical debt documentation section (lines 60-75) to mark the DN dependency
as RESOLVED with a description of the MCS Richness solution.

## Verification

- `lake build` passes (975 jobs)
- Zero sorries in CantorPrereqs.lean
- Zero new axioms introduced
- `discrete_staged_has_future` no longer calls `iterated_future_in_mcs`
- `discrete_staged_has_past` no longer calls `iterated_past_in_mcs`
- Dense timeline construction correctly RETAINS DN usage (as intended)

## Files Modified

1. `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
   - Added ~120 lines of MCS Richness infrastructure
   - Refactored discrete_staged_has_future (reduced from ~150 to ~15 lines)
   - Refactored discrete_staged_has_past (reduced from ~20 to ~15 lines)

2. `Theories/Bimodal/LogicVariants.lean`
   - Updated technical debt section to mark issue as resolved

## Impact

The discrete timeline construction is now mathematically correct:
- It no longer depends on the density axiom DN
- It uses only axioms appropriate for discrete frames (DF, SF, SP)
- The proof structure is cleaner and more maintainable

## Related Tasks

- Task 978 (typeclass-based frame modularity) - This task resolves one aspect
- Task 979 (discrete_Icc_finite_axiom) - Separate discrete construction issue
