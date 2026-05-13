# Handoff: Task 115 - Phase 1 Complete, Phase 2 Requires Plan Revision

**Session**: sess_1778697140_6bec1c
**Date**: 2026-05-13
**Agent**: lean-implementation-agent
**Status**: Phase 1 complete, Phase 2 blocked on structural issues

## What Was Done

### Phase 1: Xu Lemma 2.3 (COMPLETED)

Added two theorems to `PointInsertion.lean` (lines ~698-830):

1. **`xu_lemma_2_3_since_top`**: If R(A, B, C) then `snce(alpha, top) in B` for all alpha in A
   - Proof: contradiction via `BurgessR3Maximal_extension_fails` + `dc_delta_B_burgessR3`
   - Key chain: BX4 (connect_future) -> BX12' (P_since_equiv) -> temporal K -> left_mono_until_G for guard strengthening
   - Since condition via `burgessR_implies_burgessRSince`

2. **`xu_lemma_2_3_until_top`**: If R(A, B, C) then `untl(gamma, top) in B` for all gamma in C
   - Dual proof using BX4' (connect_past) -> BX12 (F_until_equiv) -> past K -> left_mono_since_H
   - Until condition via `burgessRSince_implies_burgessR`

Both compile and `lake build` passes cleanly (1633 jobs, no new sorries).

## Why Phase 2 Is Blocked

### The B-subset Problem

The Xu Lemma 2.4 approach constructs MCS D from `{beta.neg} union B*` where B* is R-maximal. This gives:
- `beta.neg in D` and `B subset D` (since B subset B* subset D)
- `r(A, top, D)` and `r(D, top, C)` from Xu Lemma 2.3

But `lemma_2_6_splitting`'s output requires `B subset B'` where `R(A, B', D)`. This requires `r(A, B, D)`, i.e., for all beta in B and delta in D: `snce(delta, beta) in D`.

From R(A, B*, C): `snce(alpha, beta) in C` for beta in B* and alpha in A. But `C != D`, so `snce(alpha, beta)` might not be in D.

The Xu paper does NOT claim `B subset B'`. It only claims `B union {neg-beta} subset D` and existence of R(A, B', D) and R(D, B'', C). The existing code's output is STRONGER than what Xu provides because CounterexampleElimination.lean requires `B subset B'` for the chronicle C4 condition (g-values increasing along intervals).

### Four Possible Resolutions

1. **Add snce formulas to the seed**: Use `{beta.neg} union B* union {snce(alpha, beta) | alpha in A, beta in B}` as the seed for D. But showing this extended seed is consistent brings back the seed consistency problem that BX14 was originally solving.

2. **Derive r(A, B, D) from existing infrastructure**: Need snce(alpha, beta) in D for alpha in A, beta in B. If we can show this from R(A, B*, C) and D = MCS({beta.neg} union B*), this would solve the problem. But MCS extension is non-constructive (Lindenbaum/Zorn) and doesn't guarantee specific formulas are in D.

3. **Weaken lemma_2_6_splitting's output**: Remove `B subset B'` and `B subset B''` from the output type. This requires modifying all callers in CounterexampleElimination.lean (6+ call sites). The callers may be able to use alternative arguments for the chronicle C4 condition.

4. **Use the contrapositive argument for F(beta.neg)**: Replace the F(beta.neg) derivation at sites 2, 3, 4 with the left_mono_until_G contrapositive (G(beta0 -> beta0 AND beta).neg in A -> F(beta0 AND (beta0 AND beta).neg) -> F(beta.neg)). This avoids BX14 at those sites. But `burgess_zeta_consistent` (site 1) still uses BX14 internally for a DIFFERENT purpose (building the rich event for iterated enrichment), and no simple replacement exists.

### Recommendation

**Option 4** (contrapositive + restructure `burgess_zeta_consistent`) is the most promising path:

- Sites 2, 3, 4: Replace BX14 with contrapositive argument. This is straightforward.
- Site 1 (`burgess_zeta_consistent`): Restructure to use BX7 (linearity) combined with BX12 (F->U equivalence) to merge the Until chain with the F(beta.neg) witness. This requires handling a 3-way disjunction from BX7, where two disjuncts must be shown to still give consistent finite subsets.

A `/revise` on the plan would be appropriate to formalize this approach before proceeding.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (lines ~677-830): Added Xu Lemma 2.3 theorems (xu_lemma_2_3_since_top, xu_lemma_2_3_until_top)

## Current Proof State

- `lake build` passes cleanly
- No new sorries introduced
- No axiom constructors removed yet (all 4 usage sites still reference separation_until_mcs)
- Xu Lemma 2.3 infrastructure is in place and ready for use once Phase 2 is resolved
