# Phase 7 Handoff: SDC-Maximality Blocker Analysis

## Session
- Session ID: sess_1778221275_3b41e2
- Agent: lean-implementation-agent
- Date: 2026-05-08

## Summary

Phase 7 was assigned as: "Revert BurgessR3Maximal to SDC-maximality and remove NoUnivBurgessR3 from the entire codebase." After extensive mathematical analysis (detailed below), this approach is **blocked** because it would require restructuring multiple non-trivial proofs that fundamentally depend on CUD-maximality through the NoUnivBurgessR3 hypothesis.

## What Was Attempted

1. Changed `BurgessR3Maximal` maximality clause from `ClosedUnderDerivation D` to `SetDeductivelyClosed D`
2. Removed `NoUnivBurgessR3` definition
3. Simplified the Zorn construction in `burgessR3Maximal_extension_exists` (removed `h_no_univ` parameter)
4. Added consistency precondition to `BurgessR3Maximal_extension_fails`
5. Changed `burgessR3Maximal_with_guard` to take `SetConsistent ({eta})` instead of `NoUnivBurgessR3`

Steps 1-3 compile successfully. Steps 4-5 create cascading failures.

## Why SDC-Maximality Breaks Downstream Proofs

### Problem 1: BurgessR3Maximal_extension_fails becomes conditional

With CUD-maximality: for ANY delta not in B, DC({delta} union B) is CUD and strictly extends B, so maximality gives not-burgessR3(A, DC({delta} union B), C). This is UNCONDITIONAL.

With SDC-maximality: DC({delta} union B) must be SDC (consistent). When {delta} union B is inconsistent (which happens when B is MCS and delta not in B), DC({delta} union B) = Set.univ, which is NOT SDC. So maximality does not apply.

### Problem 2: Neg-until witness extraction fails

PointInsertion.lean line 2068 (inside `by_cases h_mcs_B`) uses `BurgessR3Maximal_extension_fails` to get not-burgessR3(A, DC({beta} union B), C) when B is MCS and beta not in B. Since B is MCS and beta not in B, beta.neg in B (negation completeness), so {beta} union B is INCONSISTENT. With SDC-maximality, this call site cannot get the not-burgessR3 result.

The neg-until witness (beta0 in B, gamma0 in C, untl(beta0 and beta, gamma0) not in A) is essential for the pos sub-case contradiction in the d0 seed consistency proof.

### Problem 3: Guard consistency in burgessR3Maximal_with_guard

The function `burgessR3Maximal_with_guard` seeds the Zorn family with DC({eta}). For this to be SDC, {eta} must be consistent. The current proof derives this from NoUnivBurgessR3 via:
1. If {eta} inconsistent: derive burgessR3(A, Set.univ, C)
2. This contradicts NoUnivBurgessR3

Without NoUnivBurgessR3, consistency of {eta} cannot be derived from burgessR(A, eta, C) alone. The codebase already documents this (RRelation.lean lines 51-70): Burgess's Lemma 2.2 guard consistency is FALSE under open guard semantics (our axiom system uses irreflexive Until).

### Problem 4: Seed consistency in lemma_2_7

lemma_2_7 (Burgess Lemma 2.7, Until-formula splitting) proves DC({xi} union B) is consistent using NoUnivBurgessR3:
1. burgessR3(A, DC({xi} union B), D) holds (proved from seed structure)
2. If DC({xi} union B) were inconsistent, DC({xi} union B) = Set.univ
3. burgessR3(A, Set.univ, D) contradicts NoUnivBurgessR3

Without NoUnivBurgessR3, this consistency proof fails. The consistency of {xi} union B cannot be established by other means in the current codebase.

## Mathematical Root Cause

NoUnivBurgessR3 says: for all MCS A, C, not-burgessR3(A, Set.univ, C).

This is NOT provable in J0 (BX axiom system for all linear orders) because burgessR3(A, Set.univ, C) IS satisfiable on discrete orders: when A and C correspond to adjacent time points with empty open interval (t, t+1), the guard condition untl(phi, gamma) is vacuously true for any phi.

However, the completeness proof for ALL linear orders (including discrete ones) fundamentally uses this hypothesis through CUD-maximality. Burgess's original proof uses maximality over all DCS (including inconsistent ones like Set.univ), which implicitly rules out Set.univ when NoUnivBurgessR3 holds.

## Viable Alternative Approaches

### Approach A: Allow CUD interval sets (recommended)

Change C1 from `SetDeductivelyClosed (chi.g x y)` to `ClosedUnderDerivation (chi.g x y)`.

This matches Burgess 1982 exactly. The interval DCS g(x,y) CAN be inconsistent (= Set.univ). This removes the need for NoUnivBurgessR3 entirely:
- Zorn family consists of CUD sets (not just SDC)
- BurgessR3Maximal uses CUD-maximality naturally
- Guard consistency is not needed (inconsistent guards give g = Set.univ)

Impact: Moderate. Everywhere `h_B_dcs : SetDeductivelyClosed B` is used, change to `h_B_cud : ClosedUnderDerivation B`. Some proofs that use B's consistency would need restructuring.

### Approach B: Localize NoUnivBurgessR3

Keep NoUnivBurgessR3 as a hypothesis but prove it in the specific context where it's used (e.g., under a density assumption). This would make `bx_completeness` conditional on density, which is fine for dense linear orders.

### Approach C: Keep current state

Leave `bx_completeness` with the `h_nubr3 : NoUnivBurgessR3` parameter. Document that this is an open mathematical question for the general case. For specific classes of orders (dense, continuous), prove NoUnivBurgessR3 from density.

## Files Analyzed (no changes committed)

1. `ChronicleTypes.lean` - Definition change (reverted)
2. `RRelation.lean` - Zorn simplification (reverted)
3. `PointInsertion.lean` - Extension fails fix (reverted)
4. `CounterexampleElimination.lean` - h_nubr3 usage analysis
5. `Completeness.lean` - bx_completeness signature
6. Burgess 1982 paper (literature/Burgess_1982_*.md)

## Recommendation

Pursue **Approach A** (allow CUD interval sets) as a separate task. This is the mathematically correct fix that matches Burgess 1982 exactly. It requires:
1. Change C1 to use `ClosedUnderDerivation` instead of `SetDeductivelyClosed`
2. Update all proofs that use g-value consistency (propagate CUD vs SDC distinction)
3. Keep CUD-maximality in BurgessR3Maximal (current state)
4. Remove NoUnivBurgessR3 (now unnecessary)
5. Make bx_completeness unconditional

This is a significant refactoring (touching all 7 chronicle files + Completeness.lean) but is mathematically sound. Estimated effort: 1-2 days with multiple build-test cycles.
