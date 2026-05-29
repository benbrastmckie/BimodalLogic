# Phase 2 Handoff: Restricted TC Blocked (v5 Analysis)

**Task**: 202 - Reynolds k-equivalence bypass
**Phase**: 2 (Restricted TC on Z via Family Proliferation)
**Status**: BLOCKED
**Session**: sess_1780075095_dfdc3e
**Date**: 2026-05-29
**Plan**: v5 (05_option-c-direct-z-v5.md)

## Current State

Phase 1 (Henkin BFMCS on Int) was completed in a prior cycle. 426 lines of sorry-free code in CanonicalModel.lean including `henkin_bfmcs`, `shifted_bx_fmcs_fc`, box stability, and all BFMCS fields.

Phase 2 attempted to prove `henkin_bfmcs_restricted_tc` using the "enriched chain" approach from plan v5. This approach is fundamentally flawed -- the enriched seed is NOT necessarily consistent.

## Blocker Analysis (New in v5 Session)

### Root Cause: Enriched Seed Inconsistency
Plan v5 proposed building an "enriched chain" where the Lindenbaum extension seed includes F-formulas from the current MCS to ensure F-persistence. The specific seed: `{target} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M, χ ≠ target}`.

This seed can be INCONSISTENT. The analysis:

1. **f_content inconsistency** (documented in SuccExistence.lean:326-331 and HenkinDiscreteChain.lean:27-28): When both `F(A)` and `F(¬A)` are in a consistent MCS M, the set `{A} ∪ {F(¬A)}` contains formulas leading to inconsistency. More generally, the f_content approach (including formulas under F) is provably broken.

2. **Plan v5's F-formula variant**: Plan v5 includes `F(χ)` formulas (not `χ` itself) in the seed. This avoids the f_content inconsistency but introduces a different problem: the consistency proof requires deriving a contradiction in M from `{target} ∪ g_content(M) ⊢ G(¬χ₁) ∨ ... ∨ G(¬χₖ)` (via temporal K) combined with F(χᵢ) ∈ M. But G does not distribute over disjunction, so no contradiction is derivable. The enriched seed with F-formulas CAN be inconsistent when the F(χ) resolution witness temporally precedes the target resolution.

3. **g_content(M) ⊄ M**: Under strict temporal semantics (irreflexive G), `G(φ) → φ` is not an axiom. So g_content(M) = {φ | G(φ) ∈ M} is NOT a subset of M. This prevents the "subset of consistent set" argument.

4. **Deferral disjunction variant**: Using `ψ ∨ F(ψ)` (which IS in M) instead of F(ψ) doesn't help because g_content(M) is still not in M, so `g_content(M) ∪ {ψ ∨ F(ψ) | F(ψ) ∈ M}` is not provably consistent.

### Comprehensive Dead-End Summary
ALL approaches to F-persistence through the chain are dead:
- Plans v1-v3: F-persistence through g_content (impossible)
- Plan v4: enriched seed (blocked at Phase 2 by F-persistence)
- Plan v5: enriched seed with F-formulas (inconsistent seed)
- Family proliferation: restricted_tc requires same-family witness
- Deferral disjunctions: g_content ⊄ M under irreflexive semantics

### Both Alternative Paths Also Have Sorries
- Chronicle path: `succ_embed_surjective` → `succ_cofinal` (sorry)
- Reynolds path: `no_gaps_discrete` (sorry)

## Possible Next Steps (Research Needed)

1. **Restricted MCS with finite deferralClosure**: Lindenbaum constrained to deferralClosure(root). F-persistence via negation completeness within finite closure. Major infrastructure change.

2. **Reynolds Theorem 14 (no_gaps_discrete)**: Formalize the proof from Reynolds 1993. Unblocks Reynolds pipeline. May be more tractable than succ_cofinal.

3. **Task 129 (reflexive completeness)**: Under reflexive G(φ) → φ, g_content(M) ⊆ M holds. Transfer via conservative extension. ~18 existing sorries.

4. **Direct semantic truth lemma**: Bypass BFMCS infrastructure. Build countermodel on Z without restricted_tc.

## What Exists (Reusable)
- `henkin_bfmcs` (CanonicalModel.lean:744-793): sorry-free BFMCS on Int, fc-parametric
- All fc-parametric chain infrastructure (500+ lines): fwd_succ_fc, bwd_pred_fc, int_chain_fc, box_stable_in_int_chain_fc
- Phase 1 output is independently valuable for any future approach
