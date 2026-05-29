# BFMCS Direct Construction from Z-interval: Feasibility Analysis

**Task**: 202 (reynolds_k_equivalence_bypass)
**Date**: 2026-05-29
**Focus**: Can a BFMCS be built from Z-interval/chronicle data without `succ_cofinal`?

## Summary

A BFMCS can already be built without `succ_cofinal` — the existing `cantor_bfmcs_discrete` is sorry-free. The sorry enters only through `succ_embed_surjective`, which the three restricted coherence conditions need. There is no viable way to satisfy these coherence conditions while bypassing `succ_cofinal` within the parametric canonical model pipeline. The Reynolds pipeline (`countermodel_discrete_reynolds` at Transfer.lean:792) is the correct bypass path.

## 1. BFMCS Structure Requirements

A `BFMCS D` requires:
- `families : Set (FMCS D)` — set of time-indexed MCS families
- `nonempty` — non-empty bundle
- `modal_forward` — Box phi in any family => phi in ALL families at same time
- `modal_backward` — phi in ALL families => Box phi in each family
- `eval_family` / `eval_family_mem` — distinguished evaluation family

The downstream completeness theorem additionally requires three restricted coherence conditions: temporal coherence (F/P resolution), backward U/S coherence, and forward U/S coherence.

## 2. Sorry Dependency Chain

```
countermodel_discrete
  -> dd_countermodel_chronicle_discrete
    -> cantor_bfmcs_discrete          (SORRY-FREE)
    -> restricted_tc                   (needs succ_embed_surjective)
    -> restricted_buc                  (needs succ_embed_squeeze_strict)
    -> restricted_fuc                  (needs succ_embed_surjective)
      -> succ_embed_surjective         (needs IsSuccArchimedean)
        -> limitDomSubtype_isSuccArchimedean  (needs succ_cofinal: SORRY)
```

The BFMCS construction itself is sorry-free. Box stability (`box_stable_in_rooted_succ_discrete_fmcs`) and the modal witness lemma suffice.

## 3. Why Surjectivity Cannot Be Avoided in This Pipeline

The coherence conditions prove: "F(phi) in fam.mcs(t) => exists s > t with phi in fam.mcs(s)." The proof:
1. `limit_F_resolution` finds witness y in `limit_dom`
2. `succ_embed_surjective` maps y to integer m
3. Return m - offset as the integer witness

Without surjectivity, limit_dom witnesses cannot be mapped to integers. The no-gap property (`succ_embed_no_gap`) handles witnesses between known embedded bounds, but cannot handle witnesses outside all bounds — which is exactly what `succ_cofinal` resolves.

## 4. Reynolds Pipeline Status

`countermodel_discrete_reynolds` (Transfer.lean:792) avoids this entirely:
- Steps 1-7 complete (chronicle extraction, monadic structure, EF-game, truth transfer)
- Step 8 sorry (line 866): packaging Z-interval as TaskFrame

Remaining work for step 8:
- (a) Prove Z-interval is unbounded (lo = none, hi = none)
- (b) Construct TaskModel with position-dependent atom valuation
- (c) Prove truth_at <-> temporal_truth correspondence

## 5. Recommendation

**Path A (Reynolds completion)** is preferred over **Path B (prove succ_cofinal)**. The Reynolds pipeline requires straightforward Lean engineering (TaskModel construction, truth correspondence), not novel mathematics. The `succ_cofinal` gap involves a deep mathematical difficulty with constant-MCS scenarios under strict semantics.
