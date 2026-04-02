# Implementation Summary: Close Restricted Coherence Sorries (v2)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: BLOCKED
- **Session**: sess_1775161305_aafe43
- **Date**: 2026-04-02

## Summary

Phase 1 of the v2 plan is BLOCKED on a fundamental mathematical issue: the enriched deferral seed proposed in the plan is NOT always consistent. The plan proposed adding deferral disjunctions `chi v F(chi)` to the targeted forward seed to achieve F-persistence, but a concrete counterexample shows this can produce an inconsistent seed.

No code changes were made. This summary documents the mathematical analysis and identifies the precise blocker.

## The Enriched Seed Inconsistency

### Plan's Proposed Seed

The plan proposed: `enriched_seed(M, psi, DC) = {psi} U g_content(M) U {chi v F(chi) | F(chi) in M, chi in DC}`

### Counterexample

Let root = G(neg(p)) AND F(p). Then:
- deferralClosure(root) contains both G(neg(p)) and p
- M (the MCS for completeness) can have F(G(neg(p))) in M and F(p) in M
- The enriched seed for target psi = G(neg(p)) includes the deferral disjunction p v F(p) (from F(p) in M, p in DC)

The seed {G(neg(p)), p v F(p)} U g_content(M) is INCONSISTENT:
1. G(neg(p)) implies neg(p) by T-axiom
2. G(neg(p)) implies neg(F(p)) by definition (G(neg(p)) = neg(F(p)))
3. neg(p) and neg(F(p)) together negate the disjunction p v F(p)
4. So {G(neg(p)), p v F(p)} derives bot

### Root Cause

The inconsistency arises when the target psi implies G(neg(chi)) for some chi in DC with F(chi) in M. Since G(neg(chi)) = neg(F(chi)), the target contradicts F(chi), and the deferral disjunction chi v F(chi) becomes false under the target.

This occurs specifically when:
- The target is a G-formula: psi = G(alpha)
- G(alpha) logically implies G(neg(chi)) for some chi
- F(chi) is in M (generating the deferral disjunction)

## Alternative Approaches Analyzed

### 1. F-Formula Seed (Adding F(chi) Instead of chi v F(chi))

Seed: `{psi} U g_content(M) U {F(chi) | F(chi) in M, chi in DC}`

Same problem: {G(neg(p)), F(p)} derives bot directly (G(neg(p)) = neg(F(p))).

### 2. Filtered Deferral Disjunctions

Only include deferral disjunctions compatible with the target. Conceptually sound but:
- Defining "compatible" requires checking a derivability condition
- The filtered seed would need a separate consistency proof
- Formalization is complex and non-standard

### 3. Backward_G Argument (psi Never Appears -> G(neg(psi)) -> Contradiction)

Attempted proof: If F(psi) in chain(n) and psi never appears at any m >= n, then neg(psi) at all m >= n, which should give G(neg(psi)) at n, contradicting F(psi) in chain(n).

BLOCKED: backward_G (if phi at all future times then G(phi) now) is EQUIVALENT to forward_F (by contrapositive). So this proof is circular.

### 4. Temporal Linearity Axiom

TM includes `F(phi) AND F(psi) -> F(phi AND psi) v F(phi AND F(psi)) v F(F(phi) AND psi)`.

Attempted to use this to prove the enriched seed consistent by showing incompatible disjuncts lead to F(bot). The analysis shows:
- First two disjuncts of linearity lead to F(bot) (impossible in M)
- Third disjunct is consistent but doesn't eliminate the incompatibility

### 5. Constrained Successor with Forced Target

Add target to `constrained_successor_seed(M)`. Same inconsistency as #1 (the constrained seed includes deferral disjunctions from M).

### 6. temp_a Axiom (phi -> G(P(phi)))

F(psi) in chain(n) gives G(P(F(psi))) in chain(n), which propagates P(F(psi)) forward. But P(F(psi)) in chain(m) is a formula membership, not an extractable witness. Cannot derive "psi in chain(s) for some s" without the truth lemma (which requires forward_F -- circular).

### 7. Existing Succ Chain F-Step Property

The SuccChainFMCS has f_step: F(chi) in chain(n) implies chi in chain(n+1) or F(chi) in chain(n+1). This gives persistence but NOT eventual resolution. Perpetual deferral is consistent in TM (confirmed by research report).

## Precise Blocker Statement

The task requires proving: for each family f in boxClassFamilies and each psi in deferralClosure(root) with F(psi) in f.mcs(t), there exists s >= t with psi in f.mcs(s).

This requires a chain construction where F-obligations are EVENTUALLY resolved (not just deferred). All known approaches either:
1. Lose F-obligations at target resolution steps (targeted chain without enriched seed)
2. Have inconsistent seeds when targets are G-formulas (enriched seed approaches)
3. Are circular (backward_G requires forward_F)

## Recommendations for Next Steps

### Option A: Topological Resolution Order (Research Report's Recommendation)

The blocking relation (chi blocks psi iff {chi} U g_content(M) |- G(neg(psi))) is acyclic on deferralClosure. Resolve obligations in topological order. Blocked obligations are resolved first, so their targets don't conflict with later resolutions.

Estimated effort: 8-12 hours additional research + implementation.

### Option B: Custom Lindenbaum with Deferral Preference

Build a custom Lindenbaum extension that, at each enumeration step, preferentially includes chi over neg(chi) when F(chi) is pending. This requires modifying the Lindenbaum machinery itself.

Estimated effort: 6-10 hours.

### Option C: Accept Sorry in Specific Cases

Prove the enriched seed consistent for non-G-formula targets (which covers the majority of cases in deferralClosure) and leave a targeted sorry for G-formula targets. Then prove that G-formula targets can be handled by a separate argument.

Estimated effort: 4-6 hours for the non-G case, unknown for the G case.

### Option D: Alternative Completeness Architecture

Restructure the completeness proof to avoid family-level forward_F entirely. This would require a fundamentally different truth lemma or a different model construction (e.g., using filtrations or step-indexed models).

Estimated effort: 15-25 hours (major architectural change).

## Files Modified

None. No code changes were made.

## Artifacts

- `specs/083_close_restricted_coherence_sorries/summaries/02_restricted-coherence-summary.md` (this file)
