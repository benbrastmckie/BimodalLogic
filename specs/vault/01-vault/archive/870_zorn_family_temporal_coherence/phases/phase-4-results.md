# Phase 4 Results: Seed Consistency via Collect-into-One-MCS

**Status**: [PARTIAL] - Analysis complete, fundamental gap identified, no code changes made
**Date**: 2026-02-12

## Summary

Deep analysis of the Phase 4 approach (collect-into-one-MCS) reveals a fundamental gap in the strategy for the pure past and pure future cases. The multi_witness_seed_consistent_future/past lemmas as currently stated are **mathematically false**. The plan needs revision before implementation can proceed.

## Findings

### 1. multi_witness_seed_consistent_future/past are FALSE

**Theorem as stated** (line 806):
```
theorem multi_witness_seed_consistent_future (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (h_F : forall psi in Psis, Formula.some_future psi in M) :
    SetConsistent ({phi | phi in Psis} union GContent M)
```

**Counterexample**: Let M be any MCS containing both F(p) and F(neg p) (this is consistent: F(p) = neg(G(neg p)) and F(neg p) = neg(G(p)), which says G(neg p) and G(p) are not in M, which is compatible). Then Psis = [p, neg p], and {p, neg p} union GContent(M) is inconsistent because {p, neg p} derives bottom directly.

**Why F(p) and F(neg p) can coexist in an MCS**: Semantically, F(p) means "p holds at some future time" and F(neg p) means "neg p holds at some future time." Both can be true simultaneously (p at time 5, neg p at time 10).

### 2. The Collect-into-One-MCS Strategy Has a Gap

The strategy from research-005 and the implementation plan:
> For the pure past case, take s_max = maximum source time. All GContent propagates forward to s_max. All F-obligation formulas are in mcs(s_max) by universal forward_F.

**The gap**: forward_F says `forall s t, s in domain -> t in domain -> s < t -> F phi in mcs(s) -> phi in mcs(t)`. For F-obligations with source time s < s_max, forward_F gives phi in mcs(s_max). But for F-obligations with source time s = s_max itself, there is no domain time t > s_max to apply forward_F to (in the pure past case, all domain times are < extension time t, and s_max is the largest source time).

So elements from F-obligations at s_max remain as {phi : F phi in mcs(s_max)}, which are NOT in mcs(s_max) in general (F phi in M does not imply phi in M; the T-axiom is G phi -> phi, not F phi -> phi).

### 3. What Works: Cross-Sign Case

For the cross-sign case (both past and future domain times exist), the strategy DOES work:
- Past elements collect into mcs(s_max) where s_max is the maximum past source time
- Future elements collect into mcs(s_min) where s_min is the minimum future source time
- Since s_max < t < s_min with both in domain:
  - GContent from s_max propagates to s_min via forward_G (+ 4-axiom)
  - F-obligations from s_max propagate to s_min via forward_F (s_max < s_min)
  - HContent from s_min is already at s_min
  - P-obligations from s_min propagate to s_min via backward_P (or T-axiom for s_min itself)
- All elements end up in mcs(s_min), which is consistent as an MCS

### 4. What Does NOT Work: Pure Past/Future Cases

For the pure past case: all domain times are < t, no future domain times exist. The F-obligations at the maximum source time s_max cannot be forwarded to any domain time above s_max. The problem reduces to showing {phi : F phi in mcs(s_max)} union GContent(mcs(s_max)) is consistent, which is exactly multi_witness_seed_consistent_future -- which is false.

Symmetric issue for the pure future case with P-obligations at s_min.

### 5. Deeper Problem: Construction Viability

The counterexample F(p), F(neg p) in mcs(s_max) raises a concern about the entire Zorn construction approach. If the base family at {0} has mcs(0) containing both F(p) and F(neg p), then the extension seed at time 1 includes both p and neg p (from FObligations), making the seed inconsistent. This means the family CANNOT be extended to time 1, so it remains maximal with domain = {0}, contradicting the desired "maximal implies total" theorem.

However, extension to time -1 would work (the seed at -1 contains HContent and PObligations, not FObligations). And from domain {-1, 0}, the seed at time 1 only has F-obligations from 0 (same as before) but ALSO from -1 (via forward_F). At domain time 0 > -1, all F-obligations from -1 are in mcs(0) by forward_F. The F-obligations from 0 are still problematic.

This suggests the construction may need a fundamentally different approach for handling F-obligations at the domain boundary.

## Recommended Next Steps

### Option A: Restructure the Extension Strategy (Recommended)

Instead of extending at arbitrary/boundary times with the current seed, use a **controlled Lindenbaum extension** that prevents the MCS from acquiring conflicting F/P obligations. This is Phase 3 of the plan (GH-Controlled Lindenbaum). With such control, the new-to-old propagation is guaranteed, and the seed consistency issue at s_max is avoided because the construction is more carefully controlled.

Key insight: the seed consistency problem at s_max is actually a symptom of the larger new-to-old propagation problem. Solving Phase 3 properly would make Phase 4 tractable.

### Option B: Weaken the Extension Seed

Remove F-obligations from the extension seed entirely. Instead of requiring phi in mcs(t) for every F phi in mcs(s) with s < t, only include single-witness F-obligations. This makes the seed consistent (single-witness is proven) but means forward_F for the extended family must be proved differently.

### Option C: Change the Domain Extension Strategy

Instead of adding one time at a time, add multiple times simultaneously (e.g., add t and t+1 together). Then F-obligations from s_max can propagate to t+1. This requires rethinking the entire Zorn structure.

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Main file with all 5 sorry sites
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - GContent/HContent definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - temporal_witness_seed_consistent (single-witness, proven)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - F/P definitions (F phi = neg(G(neg phi)))
- `/home/benjamin/Projects/ProofChecker/specs/870_zorn_family_temporal_coherence/reports/research-005.md` - Research report with collect-into-one-MCS claim
- `/home/benjamin/Projects/ProofChecker/specs/870_zorn_family_temporal_coherence/plans/implementation-004.md` - Implementation plan

## Sorry Sites Status (Unchanged)

| Line | Location | Status |
|------|----------|--------|
| 844 | multi_witness_seed_consistent_future | NOT RESOLVED - lemma is false |
| 874 | multi_witness_seed_consistent_past | NOT RESOLVED - lemma is false |
| 888 | extensionSeed_consistent cross-sign | SOLVABLE - collect into s_min works |
| 1120 | extensionSeed_consistent pure past | NOT RESOLVED - gap at s_max |
| 1260 | extensionSeed_consistent pure future | NOT RESOLVED - symmetric gap at s_min |
