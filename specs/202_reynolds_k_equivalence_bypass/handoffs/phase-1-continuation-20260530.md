# Phase 1 Continuation Handoff: h_accessible closed, proof restructured

**Date**: 2026-05-30
**Session**: sess_1780118957_3a63e0
**Phase**: 1 (Reynolds Model Surgery)
**Status**: PARTIAL (Phase 1 ongoing, infrastructure improved)

## What Was Done This Cycle

### 1. h_accessible sorry CLOSED (Transfer.lean)

The sorry at Transfer.lean:1074 (now gone) proved that every predicate in
`mkSigFrom phi` is temporally accessible via `chronicle_temporal_truth`.

**Key additions**:
- `predFormulas_trans`: predFormulas is transitively closed (if `f in phi.predFormulas`
  and `g in f.predFormulas`, then `g in phi.predFormulas`)
- h_accessible proof: case split on `f = bot` vs `f in phi.predFormulas`.
  For bot: both sides False. For predFormulas: use `chronicle_temporal_truth` with
  section property derived from `predFormulas_trans`.

### 2. no_gaps_discrete_model_surgery RESTRUCTURED (GoodStructuresModelSurgery.lean)

Consolidated the two sorry sites (a < b and b < a cases) into a single
`prior_implies_archimedean_of_accessible` helper. The main theorem
`no_gaps_discrete_model_surgery` is now sorry-free:

```
prior_implies_archimedean_of_accessible  [SORRY - Reynolds Theorem 14 core]
  -> IsSuccArchimedean
  -> one_class_archimedean
  -> contemp_equiv a b
  -> contradiction with h_diff_class
```

### 3. GoodStructures.lean sorry updated

Updated the `no_gaps_discrete` sorry comment to document the proof path through
`prior_implies_archimedean_of_accessible`. The sorry itself remains (cannot import
GoodStructuresModelSurgery due to circular import).

## Remaining Sorry Sites (3 independent)

| # | File | Line | Theorem | Nature |
|---|------|------|---------|--------|
| 1 | GoodStructuresModelSurgery.lean | 314 | `prior_implies_archimedean_of_accessible` | Reynolds Theorem 14: Prior-UZ/SZ + h_accessible -> IsSuccArchimedean. Requires full model surgery (Lemmas 6-13). 500+ lines. |
| 2 | GoodStructures.lean | 845 | `no_gaps_discrete` | Same underlying blocker as #1 (identical logic, cannot wire due to circular import) |
| 3 | Transfer.lean | 1181 | `countermodel_discrete_reynolds` | Z-interval -> TaskFrame packaging. Fundamental tension: position-dependent atoms vs Unit WorldState. |

Note: Transfer.lean:1215 (`countermodel_discrete`) is BX pipeline, not our concern.

## Mathematical Analysis of Remaining Blockers

### Blocker 1: prior_implies_archimedean_of_accessible (Reynolds Theorem 14)

**Claim**: Prior-UZ + Prior-SZ + h_accessible -> IsSuccArchimedean.

**Why it's hard**: The proof requires showing that a gap (Dedekind cut) is
incompatible with the Prior axioms + predicate accessibility. The gap's cut C
is closed under successor (proved from Gap axioms + SuccOrder), but the
contradiction requires constructing a temporal formula that detects "being in C."

**Key obstacle**: `US_expressively_complete_over_prior` requires `h_surj`
(every predicate is image of an atom), but `mkSigFrom phi` has box-predicates
that are NOT atom images. So the standard expressive completeness theorem
cannot be directly applied.

**Potential approaches**:
1. Extend `US_expressively_complete_over_prior` to use h_accessible instead of h_surj
2. Construct a modified signature where all predicates map to atoms
3. Prove the gap contradiction directly without going through expressive completeness
4. Use a different characterization of "being in C" that doesn't need expressive completeness

### Blocker 3: Z-interval packaging

**Claim**: Given a Z-interval with temporal_truth of phi.neg at some point,
construct a TaskFrame + TaskModel countermodel.

**Why it's hard**: `truth_at` for atoms is `TM.valuation (tau.states t ht) p`,
which for the trivial frame (WorldState = Unit) reduces to `TM.valuation () p`
(position-independent). But `temporal_truth` depends on position via `Z.interp`.

**Potential approaches**:
1. Use a non-trivial TaskFrame where WorldState encodes position (Int-indexed states)
2. Use the existing `dd_countermodel_chronicle_discrete` path (but it has its own sorry)
3. Prove a more general `z_interval_countermodel` that handles position-dependent valuations

## Immediate Next Action

The most productive next step is to investigate whether `US_expressively_complete_over_prior`
can be generalized to use h_accessible instead of h_surj. If so, the gap contradiction
follows from the Prior-SZ argument documented in ChronicleNoGaps.lean lines 33-39.

Alternatively, research whether there exists a simpler proof of Reynolds Theorem 14
that avoids the full model surgery.

## Files Modified This Cycle

- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
  - Added `predFormulas_trans` lemma
  - Closed h_accessible sorry with `chronicle_temporal_truth` + section property
  - Fixed deprecation warning (Finset.not_mem_empty -> notMem_empty)
  - Cleaned unused simp args
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - Added `prior_implies_archimedean_of_accessible` (sorry)
  - Restructured `no_gaps_discrete_model_surgery` to be sorry-free (delegates to helper)
  - Removed old a < b / b < a case split
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`
  - Updated no_gaps_discrete sorry comment with proof path documentation
- `specs/202_reynolds_k_equivalence_bypass/plans/13_reynolds-pipeline-pivot.md`
  - Updated Phase 1 task statuses
  - Marked Phase 2 as PARTIAL (h_accessible done)

## Build Status

Full `lake build` passes with 0 errors and 1680 jobs.
