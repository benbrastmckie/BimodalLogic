# Phase 5 Blocker Analysis

## Summary

Phase 5 of task 98 plan v4 ("Realize Full Chain with stricter seed (C.4)")
is BLOCKED due to TWO independent mathematical obstacles in the chain
realization approach. The obstacles are structural, not implementation bugs.

## Obstacle 1: Strict Seed Inconsistency

**The plan's strict seed**: `h_{i+1}.formulas U g_content(v_i.formulas) U {neg f | f in Sigma \ h_{i+1}.formulas}`

**Required for consistency**: `bx_le v_i w_{i+1}` (where `w_{i+1}` is the
ChainWitnessed BXPoint backing `h_{i+1}`). This means
`g_content(v_i) subset w_{i+1}.formulas`.

**Why it fails**: For `G(chi) in v_i.formulas` with `G(chi) not in Sigma`:
- `hintikka_step` only propagates G-formulas *within* Sigma
- So `chi in h_{i+1}` is NOT guaranteed when `G(chi) not in Sigma`
- If additionally `chi in Sigma` and `chi not in h_{i+1}`:
  - The strict seed forces `neg chi in v_{i+1}` (from the negation component)
  - But `bx_le v_i v_{i+1}` forces `chi in v_{i+1}` (from g_content propagation)
  - These are contradictory: the seed is INCONSISTENT

**Concrete scenario**: `v_i` is a full MCS containing `G(chi)` where `G(chi)`
is NOT in the enriched Sigma-closure. By BX1, `chi in v_i`, and `chi` may
be in Sigma. The sigma_signature `h_i` only captures `Sigma cap v_i`, so
`G(chi)` is invisible at the Hintikka level. The next Hintikka point `h_{i+1}`
may have `chi not in h_{i+1}`, creating the inconsistency.

## Obstacle 2: G-formulas Do Not Persist Through Hintikka Chains

**The plan assumes**: G-content propagates transitively through the chain,
so `G(chi) in h_0` implies `chi in h_k` (the last point).

**Why it fails**: For `G(chi) in h_i` (with `G(chi) in Sigma`):
- `hintikka_step` gives `chi in h_{i+1}` (G-propagation, first clause)
- But `G(chi) in h_{i+1}` is NOT guaranteed
- `h_{i+1}` is locally_maximal, so `G(chi) in h_{i+1} or neg G(chi) in h_{i+1}`
- The case `neg G(chi) in h_{i+1}` is consistent: the backing witness
  `w_{i+1}` has `chi in w_{i+1}` (from G-propagation) but may have
  `neg G(chi) in w_{i+1}` (chi holds now but not always in the future)
- Without G-persistence, chi may not reach the last point for chains > length 2

## Impact on Phases 6-8

- **Phase 6** (locus control): Depends on Phase 5. BLOCKED.
- **Phase 7** (Realization.lean sorries): Depends on Phases 5 + 6. BLOCKED.
- **Phase 8** (Frame.lean sorries): Depends on Phase 7. BLOCKED.

## What Was Delivered

- Proven helper lemmas: `g_content_sigma`, `g_content_sigma_sub_g_content`,
  `hintikka_step_g_prop` (all sorry-free, zero new axioms)
- Detailed mathematical documentation in Realization.lean comments
- This handoff analysis

## Possible Resolutions (Future Research)

1. **Redefine `bx_le`** to use Until-witness ordering instead of g_content
   inclusion. This would make `bx_le` linear (from BX7) but requires
   reworking the entire Frame.lean infrastructure.

2. **Sigma-restricted chain realization**: Only propagate Sigma-portion of
   g_content through the chain, accepting that `bx_le` between realized
   points is only guaranteed for the Sigma-restricted portion.

3. **Quotient/filtration model**: Work in a finite quotient model where the
   ordering IS total by construction (the "quasimodel filtration" approach
   mentioned in the Realization.lean header).

4. **Derive Until-induction**: `(psi or (phi and G(theta)) -> theta) -> (phi U psi -> theta)`.
   If derivable from BX1-BX12, this would bypass the chain approach entirely.
   Currently believed to be non-derivable.

5. **Strengthen hintikka_step**: Add a G-persistence clause to hintikka_step
   requiring `G(chi) in h_1 -> G(chi) in h_2` (for `G(chi) in Sigma`).
   This would require re-proving `hintikka_chain_exists` with a stronger oracle.

## Sorry Count

Before: 11 (4 Frame.lean + 6 Realization.lean + 1 Completeness.lean)
After: 11 (unchanged)
Net new sorries: 0
Net new axioms: 0
