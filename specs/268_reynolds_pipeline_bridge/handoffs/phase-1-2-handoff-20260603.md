# Phase 1-2 Handoff: Reynolds Bridge Infrastructure

## What Was Done

Phases 1-2 of Strategy B are COMPLETE and sorry-free:

1. **Phase 1**: Built `LimitDomSubtype` as `OrderedMonadicStructure` (`limitdom_monadic_structure`), proved all required typeclass instances (Countable, NoMaxOrder, NoMinOrder, Nonempty, SuccOrder, PredOrder), proved `limitdom_temporal_truth_effective` (chronicle truth lemma), proved `limitdom_semantic_prior_UZ` and `limitdom_semantic_prior_SZ`.

2. **Phase 2**: Applied the Reynolds pipeline to get `limitdom_is_good`: the chronicle structure is `good` at any depth k, meaning it is k-equivalent to some Z-interval structure.

3. **Additional**: Proved `effectiveFormula_id_of_sub` (effectiveFormula is identity on subformulas), `effectiveFormula_id_self`, `effectiveFormula_id_neg`, and `limitdom_root_neg_truth` (neg phi is temporally true at the root).

## What Remains (Phase 3 -- BLOCKED)

The `countermodel_discrete_reynolds_v2` theorem has a sorry. The blocker is building a `TaskModel` countermodel on Z from the k-equivalent Z-interval.

### Root Cause

The bridge from `temporal_truth` on an `OrderedMonadicStructure` to `truth_at` on a `TaskModel` requires position-dependent atom truth. The existing `ParametricCanonicalTaskFrame` uses MCS-based world states, but the Z-interval only provides predicate interpretations (not full MCS sets). Reconstructing MCS sets from finite predicate information requires Lindenbaum extension or a custom TaskFrame construction.

### Possible Approaches for Phase 3

1. **Custom TaskFrame**: Define a TaskFrame where WorldState = predicate assignment from Z-interval, prove TaskFrame axioms, define truth correspondence. This is feasible but ~300-500 lines of new code.

2. **BFMCS from Z-interval via Lindenbaum**: For each integer z in the Z-interval, extend `{f | Z.interp (atomMapFwd f) z}` to a full MCS via Lindenbaum. Prove coherence (G/H/Until/Since) of the resulting FMCS. Very complex.

3. **Alternative Strategy**: Prove `chronicle_gap_contradiction` directly (the original sorry at ChronicleToCountermodel.lean:481). This would make the existing `countermodel_discrete_reynolds` sorry-free without needing the k-equivalence bridge. The existing proof attempt was ~250 lines but stuck at (a) using k=0 which is trivially true, and (b) symmetric case A sorry.

## Key Files

- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (NEW, 462 lines)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (modified, added import)

## Current Proof State

```
countermodel_discrete_reynolds_v2 : sorry (Phase 3 blocker)
limitdom_is_good : sorry-free
limitdom_semantic_prior_UZ : sorry-free
limitdom_semantic_prior_SZ : sorry-free
limitdom_temporal_truth_effective : sorry-free
limitdom_root_neg_truth : sorry-free
effectiveFormula_id_of_sub : sorry-free
```

## Next Action

Resolve Phase 3 by implementing one of the three approaches above. Approach 3 (proving chronicle_gap_contradiction) may be the most pragmatic path since it leverages the existing pipeline without new TaskFrame infrastructure.
