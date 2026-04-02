# Implementation Summary: Close Restricted Coherence Sorries (v3)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: PARTIAL
- **Session**: sess_1775165541_b32b52
- **Date**: 2026-04-02
- **Phases Completed**: Phase 1 partial (foundation for DRM chain approach)

## Summary

Phase 1 of the v3 plan was partially implemented. Extensive mathematical analysis revealed that the plan's primary approach (joint consistency of filtered F-formulas) is **unprovable** -- a concrete counterexample was constructed. An alternative approach using DRM chains with bounded witness was identified and the foundation implemented sorry-free.

## Key Findings

### Joint Consistency is Unprovable (NEW)

The plan's Phase 2 proposes proving: if each F(chi_i) is individually compatible with the target seed, then they are jointly compatible. A concrete counterexample disproves this:

- Let M contain `G(p -> G(neg(A)) v G(neg(B)))`, `F(p)`, `F(A)`, `F(B)`
- `{p} ∪ g_content(M) ∪ {F(A)}` is consistent (A compatible with target p)
- `{p} ∪ g_content(M) ∪ {F(B)}` is consistent (B compatible with target p)
- `{p} ∪ g_content(M) ∪ {F(A), F(B)}` is INCONSISTENT

Proof: From `G(p -> G(neg A) v G(neg B))`, T-axiom gives `p -> G(neg A) v G(neg B)` in g_content. With p: `G(neg A) v G(neg B)`. With F(A): `neg(G(neg A))`, forcing `G(neg B)`. With F(B): `neg(G(neg B))`, contradiction.

### DRM Chain Alternative (NEW)

An alternative approach using DeferralRestrictedMCS chains avoids the joint consistency issue entirely:

1. In a DRM restricted to deferralClosure, F-nesting is bounded (by `closure_F_bound`)
2. The `simplified_restricted_seed` (g_content + deferralDisjunctions + p_step_blocking) is trivially consistent (subset of DRM)
3. This seed provides f_step and Succ properties
4. The existing `bounded_witness` theorem gives forward_F from bounded nesting + f_step
5. DRM-to-MCS extension preserves properties for deferralClosure formulas

### Why Full MCS Chains Fail

In a full MCS, `F(A) -> F(F(A))` is provable via T-axiom contrapositive, making F-nesting unbounded. The `bounded_witness` theorem cannot apply. The `SuccChainFMCS` uses full MCS chains, hence forward_F is unprovable for it (perpetual deferral is consistent in TM).

## Implementation

### New File Created
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean` (sorry-free, builds successfully)
  - `simplified_restricted_successor`: DRM successor from simplified seed
  - `simplified_restricted_successor_is_drm`: DRM property preserved
  - `simplified_restricted_successor_extends`: Seed extension
  - `simplified_restricted_successor_g_persistence`: G-content propagation
  - `simplified_restricted_successor_f_step`: F-step (resolve-or-defer)
  - `simplified_restricted_successor_succ`: Full Succ relation

### What Remains
See handoff document: `specs/083_close_restricted_coherence_sorries/handoffs/03_drm-chain-approach.md`

Estimated remaining effort: 6-10 hours across 5 sub-phases:
1. Build DRM forward/backward chains
2. Prove forward_F via bounded_witness
3. Build Int-indexed FMCS
4. DRM-to-MCS extension
5. Build BFMCS and rewire completeness

## Files Modified
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean` -- new file (sorry-free)

## Files NOT Modified (sorries remain)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` still have sorry
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- `completeness_over_Int` still has sorry dependency
