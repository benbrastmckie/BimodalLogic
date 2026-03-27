# Path Forward Analysis: Completeness Proof Structure

**Task**: 58 - wire_completeness_to_frame_conditions
**Session**: sess_1774587086_06fcc5
**Date**: 2026-03-26

## Executive Summary

This analysis verifies the path forward for the completeness proof. The key finding is that the **core algebraic completeness infrastructure is sorry-free**, but there is a **model-theoretic glue gap** connecting the algebraic bundle model to the `valid_over` semantic definition.

## Research Question 1: RestrictedTemporallyCoherentFamily Analysis

### Structure (SuccChainFMCS.lean:4191-4202)

```lean
structure RestrictedTemporallyCoherentFamily (phi : Formula) where
  seed : DeferralRestrictedSerialMCS phi
  forward_F : ∀ n : Int, ∀ psi : Formula,
    Formula.some_future psi ∈ restricted_succ_chain_fam phi seed n →
    ∃ m : Int, m > n ∧ psi ∈ restricted_succ_chain_fam phi seed m
  backward_P : ∀ n : Int, ∀ psi : Formula,
    Formula.some_past psi ∈ restricted_succ_chain_fam phi seed n →
    ∃ m : Int, m < n ∧ psi ∈ restricted_succ_chain_fam phi seed m
```

### Properties Provided
- **forward_F**: F-witness existence for ANY formula in the chain (within deferralClosure)
- **backward_P**: P-witness existence for ANY formula in the chain (within deferralClosure)

### Properties NOT Provided
- **forward_G**: G(psi) at t implies psi at all t' >= t (FMCS requirement)
- **backward_H**: H(psi) at t implies psi at all t' <= t (FMCS requirement)

### Sorry Dependency Chain

```
build_restricted_tc_family
  └── restricted_forward_chain_forward_F (sorryAx via chain)
        └── restricted_forward_chain_iter_F_witness
              └── restricted_forward_chain (sorryAx)
                    └── constrained_successor_restricted (sorryAx)
                          └── constrained_successor_seed_restricted_consistent (SORRY at line 1543)
```

**Root Cause**: `constrained_successor_seed_restricted_consistent` has a sorry (line 1543). This is the consistency proof for the restricted seed which includes `boundary_resolution_set` elements.

## Research Question 2: RestrictedCanonical Section Analysis

### Location
`CanonicalConstruction.lean` lines 809-955

### What Was Added
1. `restricted_tc_family_to_fmcs`: Attempt to convert RestrictedTemporallyCoherentFamily to FMCS
2. `neg_in_mcs_implies_not_in_mcs`: If neg(phi) in MCS, then phi not in MCS
3. `not_in_mcs_implies_not_true`: Contrapositive for model connection

### Gap Identified (lines 873, 876)
```lean
forward_G := fun t t' ψ htt' h_G => by
  -- Independent Lindenbaum extensions don't preserve Succ relation!
  sorry
backward_H := fun t t' ψ htt' h_H => by
  sorry
```

**Problem**: Extending each DeferralRestrictedMCS to a full MCS via independent Lindenbaum extensions produces sets that don't preserve the chain structure required for forward_G/backward_H.

### Documented Gap Analysis (lines 917-951)
The code documents two approaches:
1. **Restricted Completeness**: Only for formulas with bounded F/P-nesting
2. **Single-Family Construction**: Build specialized BFMCS for specific formula evaluation

## Research Question 3: Completeness.lean Sorries

### Target Sorries

| Line | Theorem | Status | Gap |
|------|---------|--------|-----|
| 120 | `dense_completeness_fc` | OPEN | Model-theoretic glue |
| 163 | `discrete_completeness_fc` | OPEN | Model-theoretic glue |
| 214 | `bundle_validity_implies_provability` | OPEN | Model-theoretic glue |

### What Each Sorry Needs

All three sorries require the same infrastructure: connecting `valid_over Int phi` to MCS membership via a canonical model.

**Current state of proof (line 200-214)**:
```lean
by_contra h_not_prov
have h_cons := not_provable_implies_neg_consistent φ h_not_prov
have _h := bundle_completeness_contradiction φ h_cons
-- h : ¬(∀ M, SetMaximalConsistent M → φ ∈ M)
-- Need: From h_valid, derive φ ∈ M for the canonical model MCS
-- This requires canonical model theorem connecting to valid_over
sorry
```

### What's Actually Required
1. Build TaskModel from BFMCS_Bundle
2. Show ShiftClosedCanonicalOmega satisfies shift-closure
3. Apply valid_over hypothesis to get truth at eval_family position 0
4. Use shifted_truth_lemma (sorry-free) to conclude phi in MCS

## Research Question 4: Minimal Construction Analysis

### Current Architecture Comparison

| Structure | What it Provides | What it Lacks |
|-----------|------------------|---------------|
| `BFMCS` | forward_G, backward_H in FMCS + temporally_coherent | Requires family-level F/P coherence |
| `BFMCS_Bundle` | bundle_forward_F, bundle_backward_P | No FMCS with forward_G/backward_H |
| `RestrictedTemporallyCoherentFamily` | forward_F, backward_P over DRMs | No forward_G/backward_H, not full MCS |

### The Key Insight

The `shifted_truth_lemma` (sorry-free) requires:
1. `B : BFMCS D` with `B.temporally_coherent` (forward_F, backward_P at family level)
2. `fam : FMCS D` with implicit `forward_G`, `backward_H`

The `construct_bfmcs_bundle` (sorry-free) provides:
1. `BFMCS_Bundle` with bundle-level F/P coherence
2. Each family IS an FMCS (has forward_G, backward_H from SuccChainFMCS)

### Missing Connection

Convert `BFMCS_Bundle` to `BFMCS` by strengthening bundle-level to family-level temporal coherence.

**Key observation**: `SuccChainFMCS` (used in eval_family) provides forward_G/backward_H but NOT forward_F/backward_P. The boxClassFamilies provides bundle-level F/P coherence.

### Can We Use Restricted Chain Without Lindenbaum?

**Answer: No, not directly.**

The `shifted_truth_lemma` requires:
1. Full MCS at each position (for MCS closure properties in imp, neg cases)
2. Not just DeferralRestrictedMCS

However, the restricted_truth_lemma (lines 268-280) shows that for formulas in subformulaClosure(phi), membership in DRM equals membership in Lindenbaum extension. This could potentially be leveraged.

## Summary: Path Forward Options

### Option A: Fix constrained_successor_seed_restricted_consistent (Recommended)

**Location**: SuccChainFMCS.lean line 1507-1543

**What's needed**: Complete the consistency proof for the restricted seed. The proof outline is documented:
- Non-boundary part is subset of u (already proven)
- boundary_resolution_set elements don't introduce contradictions
- Key lemmas exist: `neg_not_in_g_content_when_F_in`, `neg_not_in_deferralDisjunctions`, `neg_not_in_p_step_blocking_restricted`

**Impact**: Would make build_restricted_tc_family sorry-free, which would then enable a sorry-free path through the restricted construction.

### Option B: Direct BFMCS_Bundle to TaskModel

**Approach**: Instead of trying to convert to BFMCS, directly construct a TaskModel from BFMCS_Bundle.

**Required**:
1. Define CanonicalTaskModel for BFMCS_Bundle (analogous to existing CanonicalTaskModel for BFMCS)
2. Define BundleCanonicalOmega
3. Prove forward truth lemma (MCS membership implies truth_at) - only need forward direction for completeness

**Advantage**: Avoids needing family-level temporal coherence entirely.

**Disadvantage**: Requires new infrastructure parallel to existing CanonicalConstruction.

### Option C: Weaken valid_over Definition

**Approach**: Modify valid_over to use bundle-level coherence directly.

**Status**: Not recommended - would require changing the semantic foundations.

## Recommendation

**Pursue Option A first**: The `constrained_successor_seed_restricted_consistent` proof is documented in detail (lines 1483-1506) and the key helper lemmas exist. This is the most direct path to a complete restricted construction.

**If Option A proves difficult**: Implement Option B, which avoids the Lindenbaum extension problem entirely by working directly with BFMCS_Bundle.

## Key Takeaways

1. **RestrictedTruthLemma.lean sorries at lines 106, 115, 135 are in UNUSED helper lemmas** - the main `restricted_truth_lemma` is structurally complete but depends on sorry through the chain construction.

2. **The real blocker is `constrained_successor_seed_restricted_consistent`** (SuccChainFMCS.lean line 1543) - not the helper lemmas in RestrictedTruthLemma.lean.

3. **The algebraic core (UltrafilterChain.lean) is already sorry-free**:
   - `bundle_completeness_contradiction`: Sorry-free
   - `construct_bfmcs_bundle`: Sorry-free
   - `boxClassFamilies_bundle_temporally_coherent`: Sorry-free

4. **The gap is model-theoretic**: Connecting BFMCS_Bundle to valid_over requires either:
   - Strengthening to BFMCS (family-level temporal coherence), OR
   - Building new TaskModel infrastructure for BFMCS_Bundle directly

## File References

| File | Key Lines | Status |
|------|-----------|--------|
| SuccChainFMCS.lean | 1507-1543 | constrained_successor_seed_restricted_consistent (SORRY) |
| SuccChainFMCS.lean | 4191-4270 | RestrictedTemporallyCoherentFamily (sorryAx dependency) |
| RestrictedTruthLemma.lean | 268-280 | restricted_truth_lemma (sorryAx dependency) |
| RestrictedTruthLemma.lean | 106, 115, 135 | Unused helper lemmas (can be deleted) |
| CanonicalConstruction.lean | 873, 876 | restricted_tc_family_to_fmcs (SORRY) |
| CanonicalConstruction.lean | 493-645 | shifted_truth_lemma (sorry-free) |
| UltrafilterChain.lean | 2853-2877 | construct_bfmcs_bundle (sorry-free) |
| Completeness.lean | 120, 163, 214 | Target sorries (model-theoretic glue) |
