# Phase 1 Handoff: Henkin Chain FMCS Construction on Z

## Status: BLOCKED

## Context

Task 202 aims to eliminate the `succ_cofinal` sorry in `completeness_discrete`.
Plan v2 (Option C) proposed building a Henkin chain FMCS directly on Z,
bypassing the chronicle's `succ_embed_surjective` which depends on `succ_cofinal`.

## What Was Done

1. **Deep analysis of the sorry chain**: Traced the exact dependency path:
   `completeness_discrete` -> `countermodel_discrete_enriched` ->
   `cantor_bfmcs_discrete_restricted_tc/fuc` -> `succ_embed_surjective` ->
   `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (sorry).
   The BUC proof is sorry-free (uses `succ_embed_squeeze` not surjectivity).

2. **Explored 6 approaches** (documented in HenkinDiscreteChain.lean):
   - Direct restricted_tc without surjectivity (fails: gap scenario)
   - Henkin chain with all F-witnesses (fails: f_content ∪ g_content not consistent)
   - Successor deferral seed (blocked: sorry in SuccExistence.lean under irreflexive semantics)
   - One-at-a-time dovetailing (fails: F-persistence through g_content not provable)
   - Direct succ_cofinal via pred induction (circular: needs IsPredArchimedean)
   - Stage-based induction (boundary case sorry unresolved)

3. **Proved two new sorry-free lemmas** (HenkinDiscreteChain.lean):
   - `g_content_consistent`: g_content(M) is consistent for any MCS M
   - `h_content_consistent`: h_content(M) is consistent for any MCS M
   These are building blocks for any future Henkin chain approach.

4. **Verified existing sorry-free infrastructure**:
   - `completeness_dense`: already sorry-free (verified: no sorryAx)
   - Dense case BUC, TC, FUC: all sorry-free
   - Discrete case BUC: sorry-free (uses squeeze lemma)
   - `succ_embed_no_gap`, `succ_embed_squeeze`, `succ_embed_squeeze_strict`: all sorry-free

## Key Mathematical Insight

The fundamental obstacle is the **gap scenario**: the succ-orbit from point a
in the chronicle's limit domain can converge (as real numbers) to a limit L
without reaching point b, when:
- All orbit points have identical or compatible MCS labels
- No temporal axiom forces the orbit to "jump" past the accumulation point
- The pred-chain from b also converges to L from above
- Under strict (irreflexive) temporal semantics, G(phi) -> phi is NOT valid,
  so the gap is consistent with all BX axioms

This gap scenario was analyzed extensively in task 153 and confirmed by 4
research agents (task 155 reports 48, 49a-d).

## Blocked On

The root cause is that no well-founded measure exists for the succ_cofinal
induction that avoids circularity with IsSuccArchimedean.

## Viable Paths Forward (Priority Order)

1. **Prove successor_deferral_seed consistency for general fc** (Medium effort):
   The seed `g_content(M) ∪ {phi ∨ F(phi) | F(phi) ∈ M}` might be provable
   consistent using generalized temporal K without assuming g_content ⊆ M.
   The single-disjunction case works (via forward_temporal_witness_seed_consistent).
   Need to extend to multiple disjunctions simultaneously.

2. **Construction-level gap elimination** (High effort):
   Prove that the omega-chain construction cannot produce gaps by analyzing
   the interaction between C5 witness insertion and the succ-orbit. When the
   orbit converges, the C5 counterexamples at orbit points generate witnesses
   that must be within the orbit's range (because they're added to resolve
   counterexamples involving orbit points).

3. **Task 129: Weak/reflexive completeness + conservative extension** (High effort):
   Under reflexive semantics, g_content(M) ⊆ M, making seed consistency trivial.
   Transfer via conservative extension to irreflexive semantics.

## Files Modified

- New: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean`
  (analysis documentation + g_content_consistent + h_content_consistent lemmas)
- Modified: `specs/202_reynolds_k_equivalence_bypass/plans/02_option-c-plan.md`
  (Phase 1 marked BLOCKED with blocker documentation)

## Immediate Next Action

Try approach #1: prove `successor_deferral_seed` consistency for general fc
by adapting the `forward_temporal_witness_seed_consistent` proof technique
to handle multiple deferral disjunctions. The key step: from
`(phi_1 ∨ F(phi_1)) :: ... :: (phi_k ∨ F(phi_k)) :: L_g ⊢ ⊥`,
derive `L_g ⊢ neg(phi_1) ∧ G(neg(phi_1)) ∧ ... ∧ neg(phi_k) ∧ G(neg(phi_k))`,
then use temporal K to get `G(neg(phi_i)) ∈ M` for each i, contradicting
`F(phi_i) ∈ M` via `some_future_all_future_neg_absurd`.
