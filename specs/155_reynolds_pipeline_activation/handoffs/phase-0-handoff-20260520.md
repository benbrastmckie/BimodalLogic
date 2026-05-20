# Phase 0 Handoff: Architectural Analysis

**Task**: 155 - reynolds_pipeline_activation
**Session**: sess_1779290650_45e3c8
**Date**: 2026-05-20
**Context spent on**: Deep analysis of Transfer.lean bridge and IntegerModel.lean helper sorries

## Current State

- **Phase 1**: BLOCKED - Transfer.lean bridge has fundamental box modality mismatch
- **Phase 2**: BLOCKED - `cofinal_decomposition_k_equiv` needs EF game framework
- **Phase 3**: NOT STARTED - depends on Phase 1 only for compilation (which works)
- **Phase 4**: NOT STARTED - chronicle truth lemma (independent)
- **Phase 5**: NOT STARTED - depends on Phases 2, 3, 4
- **Phase 6**: NOT STARTED - depends on Phase 5

## Key Findings

### Transfer.lean Box Modality Mismatch (Phase 1 Blocker)

The `z_interval_countermodel` theorem tries to bridge `temporal_truth` (on monadic FO structures) to `truth_at` (on task frames). This correspondence CANNOT be proved by structural induction on the formula because:

1. `temporal_truth` treats `box ψ` as an atomic PREDICATE LOOKUP: `M.interp (atomMap_fwd (.box ψ)) t`
2. `truth_at` interprets `box ψ` as UNIVERSAL QUANTIFICATION: `∀ σ ∈ Omega, truth_at TM Omega σ t ψ`

These are fundamentally different semantic operations. The mismatch cannot be resolved by:
- Using WorldState = Unit (valuation can't vary with time)
- Using WorldState = ℤ with Set.univ Omega (shifted histories give different atom values)
- Using singleton Omega (not shift-closed)

**Root cause**: The Reynolds pipeline works in the monadic FO framework where box is "absorbed" into predicates. The task frame semantics gives box its own structural interpretation.

**Recommended fix**: Restructure `countermodel_discrete` to NOT use `z_interval_countermodel`. Instead, route through the parametric canonical model by proving temporal coherence (`cantor_bfmcs_discrete_restricted_tc`) without `succ_embed_surjective`. The sorry chain is:
```
dd_countermodel_chronicle_discrete
  -> cantor_bfmcs_discrete_restricted_tc (SORRY HERE)
    -> succ_embed_surjective
      -> limitDomSubtype_isSuccArchimedean
        -> succ_cofinal (SORRY)
```

The Reynolds pipeline could provide an alternative proof of temporal coherence by using `chronicle_is_good` + k-equivalence to construct witnesses, but this requires careful design.

### cofinal_decomposition_k_equiv (Phase 2 Blocker)

The ordered sum `orderedSum ℤ (fun i => M.subinterval(a(i), a(i+1)))` has DUPLICATED boundary points: `a(i+1)` appears as both `(i, a(i+1))` (max of piece i) and `(i+1, a(i+1))` (min of piece i+1). These copies have different lexicographic positions, which breaks the naive order-preservation argument.

**Needed**: An Ehrenfeucht-Fraissé game framework, or alternatively, use half-open intervals to avoid boundary duplication.

### ordered_sum_of_good_bounded_is_good (Phase 2 Blocker)

At depth k >= 2, the shift-and-glue construction requires:
1. Transfer "has max/min" from ms(i) to Z_i via doets_lemma_1_1
2. Show each Z_i is bounded (lo = some _, hi = some _)  
3. Construct OrderIso from concatenation of bounded Z-intervals to Z
4. Apply k_equiv_of_iso

Steps 1-2 are set up but step 3-4 need ~100 lines of concrete construction.

## Immediate Next Action

The most tractable remaining work is:
1. **Phase 3 (no_gaps_discrete rewrite)**: Remove IsSuccArchimedean by implementing Reynolds Theorem 14. This is hard (6 pages) but uses existing infrastructure (table_correctness, separation_theorem_int).
2. **Phase 4 (chronicle_temporal_truth)**: Prove by structural induction on formula, using Prior-UZ/SZ for Until/Since cases.

Both of these are in IntegerModel.lean / Transfer.lean respectively and don't depend on the Phase 1/2 blockers.

## Files Modified

None (Transfer.lean was reverted after analysis).

## Sorry Sites (unchanged)

| File | Line | Name | Status |
|------|------|------|--------|
| Transfer.lean | 186 | chronicle_temporal_truth | Phase 4 target |
| Transfer.lean | 276 | z_interval_countermodel valuation | Phase 1 BLOCKED |
| Transfer.lean | 286 | z_interval_countermodel sorry | Phase 1 BLOCKED |
| Transfer.lean | 332 | Nonempty sig.preds | Phase 1 BLOCKED |
| Transfer.lean | 371 | countermodel_discrete inline sorry | Phase 4 target |
| IntegerModel.lean | 1079 | cofinal_decomposition_k_equiv | Phase 2 BLOCKED |
| IntegerModel.lean | 1138 | ordered_sum_of_good_bounded_is_good | Phase 2 BLOCKED |
