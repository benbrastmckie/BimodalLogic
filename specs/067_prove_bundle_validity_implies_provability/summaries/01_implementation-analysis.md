# Implementation Analysis: Task 67 - bundle_validity_implies_provability

**Date**: 2026-03-28
**Session**: sess_1774741595_814150
**Status**: BLOCKED - Requires architectural decision

## Executive Summary

After deep analysis of the completeness gap, I've identified the precise mathematical blocker and the implementation path required. The task cannot be completed with a simple proof fill-in; it requires implementing ~200-400 lines of new infrastructure to establish "restricted forward_F" for full MCS chains.

## Gap Analysis

### The Sorry Location

The sorry is at `Theories/Bimodal/FrameConditions/Completeness.lean:204` in `bundle_validity_implies_provability`.

### What the Proof Needs

1. **Contrapositive setup** (DONE, sorry-free):
   - `not_provable_implies_neg_consistent`: If phi not provable, neg(phi) is consistent
   - `set_lindenbaum`: Extend neg(phi) to MCS M
   - `construct_bfmcs_bundle`: Build BFMCS_Bundle from M

2. **Truth lemma** (BLOCKED):
   - Need: `neg(phi) in M(0) <-> truth(neg(phi)) at (history, 0)`
   - The `parametric_canonical_truth_lemma` exists but requires `B.temporally_coherent`

3. **Temporal coherence gap** (THE BLOCKER):
   - `B.temporally_coherent` requires same-family `forward_F` and `backward_P`
   - `construct_bfmcs_bundle` provides only bundle-level F/P (witness in ANY family)
   - The truth lemma's backward G case needs same-family witness

### Why Same-Family Matters

The backward G case proof structure:
```
Goal: truth(G(psi)) at (tau, t) -> G(psi) in fam.mcs(t)

Contrapositive:
1. G(psi) not in fam.mcs(t)
2. F(neg(psi)) in fam.mcs(t)           [MCS negation + temporal duality]
3. neg(psi) in fam.mcs(s) for s > t    [forward_F - MUST BE SAME FAMILY]
4. truth(psi) at s along tau           [semantic hypothesis]
5. psi in fam.mcs(s)                   [backward IH - SAME family]
6. Contradiction                        [psi and neg(psi) in consistent set]
```

Step 3 requires same-family witness because:
- tau = parametric_to_history(fam) is derived from fam
- truth at s along tau is evaluated using fam.mcs(s)
- A witness in a different family would give psi in fam'.mcs(s') for different fam'
- Cannot derive contradiction since fam.mcs(s) and fam'.mcs(s') are different sets

## The Restricted Coherence Solution

### Key Insight

The truth lemma is evaluated on a SPECIFIC formula phi. The formulas that appear in the proof are bounded by `subformulaClosure(phi)`, and the F-witnesses needed are bounded by `deferralClosure(phi)`.

For formulas in deferralClosure:
- F-nesting depth is bounded by `closure_F_bound(phi)`
- This bound is INDEPENDENT of whether we use full MCS or DRM chains
- Therefore, forward_F DOES hold for deferralClosure formulas in any chain

### Existing Infrastructure

| Component | Location | Status |
|-----------|----------|--------|
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean:2921 | SORRY-FREE (DRM chains) |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean:4262 | SORRY-FREE (DRM chains) |
| `iter_F_not_mem_deferralClosure` | RestrictedMCS.lean:1064 | SORRY-FREE |
| `deferral_restricted_mcs_F_bounded` | RestrictedMCS.lean:1090 | SORRY-FREE |
| `succ_chain_fam_succ` | SuccChainFMCS.lean:331 | SORRY-FREE |

### What's Missing

A theorem like:
```lean
theorem succ_chain_forward_F_restricted (phi : Formula) (M0 : SerialMCS)
    (n : Int) (psi : Formula)
    (h_clos : psi in deferralClosure phi)
    (h_F : F(psi) in succ_chain_fam M0 n) :
    exists m > n, psi in succ_chain_fam M0 m
```

This would state: for formulas in deferralClosure, forward_F holds even in full MCS chains.

## Implementation Path

### Option A: Restricted Truth Lemma (Recommended, ~300-400 lines)

1. **Define RestrictedTemporalCoherence predicate** (~50 lines)
   - A family satisfies RTC(phi) if forward_F/backward_P hold for deferralClosure(phi) formulas

2. **Prove SuccChainFMCS satisfies RTC** (~100-150 lines)
   - Adapt `restricted_forward_chain_forward_F` proof to full MCS chains
   - Key: use F-nesting boundedness from deferralClosure membership

3. **Prove restricted truth lemma** (~100-150 lines)
   - Identical to `parametric_canonical_truth_lemma` but takes RTC instead of full TC
   - Only difference: G/H backward cases use RTC's restricted forward_F/backward_P

4. **Wire to completeness** (~50 lines)
   - Show construct_bfmcs_bundle families satisfy RTC(phi)
   - Apply restricted truth lemma
   - Derive contradiction from validity

### Option B: Direct Proof via MCS Properties (~150-200 lines)

Alternative approach that avoids building new infrastructure by using MCS closure properties more directly. Not fully analyzed but potentially simpler.

## Current Sorry Counts

| File | Sorries | Notes |
|------|---------|-------|
| Completeness.lean | 18 | Includes bundle_validity_implies_provability + dense_completeness |
| RestrictedTruthLemma.lean | 3 | Helper lemmas (G_propagates, H_step) |
| SuccChainFMCS.lean | 19 | Termination sorries + deprecated code |

## Recommendation

This task should be BLOCKED pending:

1. **Architectural decision**: Should we use Option A (restricted truth lemma) or Option B (direct proof)?

2. **Implementation scope**: The implementation is ~300-400 lines of non-trivial Lean code that requires careful verification. This is better suited for a focused implementation session rather than attempting in the current context.

3. **Dependency on termination sorries**: Some termination sorries in SuccChainFMCS.lean may need to be filled first (Phase 4 of the plan).

## Files Analyzed

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/FrameConditions/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
