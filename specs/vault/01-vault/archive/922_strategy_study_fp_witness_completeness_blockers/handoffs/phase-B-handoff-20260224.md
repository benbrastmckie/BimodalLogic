# Handoff: Task 922 Phase B - OrderIso Prerequisites

**Date**: 2026-02-24
**Session**: sess_1771971511_c8eb47
**Phase**: B (OrderIso Prerequisites)
**Status**: Blocked on mathematical feasibility

## Immediate Next Action

Research whether `NoMaxOrder` and `NoMinOrder` are provable for the canonical quotient,
OR identify an alternative approach that avoids the quotient-to-Int isomorphism.

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`
**Build**: Compiles successfully, zero sorries
**Phase A**: COMPLETED - LinearOrder on CanonicalQuotient verified

The canonical quotient `CanonicalQuotient M₀ h_mcs₀` is defined as:
```
Antisymmetrization (CanonicalReachable M₀ h_mcs₀) (· ≤ ·)
```
where `≤` is `CanonicalR` (GContent inclusion). It has `LinearOrder` and `Nonempty`.

## Key Decisions Made

1. **Used Mathlib's Antisymmetrization** instead of manual quotient construction
2. **Used `abbrev`** instead of `def` for CanonicalQuotient to ensure instance transparency
3. **Added explicit `IsPreorder` instance** to work around elaboration timing issue
4. **Used `CanonicalQuotient.mk`** wrapper instead of `⟦⟧` notation (which gave raw `Quotient` type without ordering)

## What NOT to Try

### NoMaxOrder via Tautological Witnesses
Tried: F(neg(bot)) is in every MCS (since G(bot) implies bot by T-axiom). But neg(bot) is a tautology, so the canonical_forward_F witness is in the same equivalence class.

### NoMaxOrder via Atomic Witnesses
Tried: For atom p, if F(neg(p)) in M, canonical_forward_F gives W with neg(p) in W. But W might be in the same equivalence class as M (MCSes in same class can disagree on atoms, they only agree on G-formulas).

### Temporally Saturated MCS Construction
This approach (F(phi) -> phi for all phi) was proven impossible in research-010.md counterexample: {F(psi), neg(psi)} is consistent but cannot be in a temporally saturated MCS.

## Analysis: Why Phase B is Hard

The plan requires `orderIsoIntOfLinearSuccPredArch` which needs:
- `Nonempty` (DONE)
- `LinearOrder` (DONE)
- `SuccOrder` (needs NoMaxOrder + Countable + LocallyFiniteOrder)
- `PredOrder` (needs NoMinOrder + Countable + LocallyFiniteOrder)
- `IsSuccArchimedean` (follows from above)
- `NoMaxOrder` (HARD - see below)
- `NoMinOrder` (HARD - symmetric to NoMaxOrder)

### NoMaxOrder Blocker

NoMaxOrder requires: for every equivalence class [M], there exists a STRICTLY greater class.

"Strictly greater" means: CanonicalR(M, W) but NOT CanonicalR(W, M), i.e., GContent(M) is a PROPER subset of W.

The problem: GContent(M) is "G-closed" (phi in GContent iff G(phi) in GContent, by temp_4). When we use canonical_forward_F to get a witness W with CanonicalR(M, W), the Lindenbaum process can choose to NOT add any new G-formulas, keeping GContent(W) = GContent(M). This makes W in the same equivalence class as M, giving no strict successor.

Whether the logic FORCES new G-formulas to appear depends on the specific axiom system. This needs more research.

## Alternative Approaches to Investigate

1. **Direct BFMCS construction without quotient-to-Int isomorphism**: Build an Int-indexed family using a clever enumeration that ensures forward_F/backward_P. The challenge is still the F-persistence problem through GContent seeds.

2. **Prove the quotient is always infinite**: Show that the temp_linearity axiom or other axioms force infinitely many equivalence classes. This would give NoMaxOrder/NoMinOrder.

3. **Use a different order-theoretic theorem**: Instead of `orderIsoIntOfLinearSuccPredArch`, find a Mathlib theorem that gives an ORDER EMBEDDING (not isomorphism) from a countable linear order to Int. Then construct additional "filler" positions.

4. **Modify the target**: Instead of proving `temporal_coherent_family_exists_Int` directly, prove it using the existing `fully_saturated_bmcs_exists_int` sorry but with a reduced sorry scope (e.g., only sorry the NoMaxOrder part).

5. **Prove forward_F/backward_P differently**: Instead of the quotient route, prove them for the DovetailingChain construction using the canonical frame witnesses. The challenge is showing that canonical frame witnesses are compatible with the chain positions.

## Critical Context

- `temporal_coherent_family_exists_Int` in TemporalCoherentConstruction.lean delegates to `temporal_coherent_family_exists_theorem` in DovetailingChain.lean
- DovetailingChain has 2 sorries: `forward_F` and `backward_P`
- The completeness theorem chain: Completeness.lean -> TemporalCoherentConstruction.lean -> DovetailingChain.lean
- The new CanonicalQuotient.lean is independent and does NOT yet connect to the completeness chain

## References

- Plan: specs/922_strategy_study_fp_witness_completeness_blockers/plans/implementation-003.md
- Research: specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-004.md
- New file: Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean
