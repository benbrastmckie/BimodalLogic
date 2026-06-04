# BXPipelineDeadCode -- Archived Dead Code from BX Pipeline

Dead code from the BX pipeline path that was superseded by the Reynolds pipeline
(task 202). All definitions in this directory are either mathematically false as
stated or had zero external references at time of removal.

## Files

| File | Lines | Task | Contents |
|------|------:|------|----------|
| ReynoldsModelSurgery.lean | 407 | 268 | `no_gaps_faithful`, `prior_model_is_succ_archimedean` -- deprecated Reynolds model surgery proof (mathematically false: Z+Z counterexample) |
| ReynoldsNoGapsDeprecated.lean | 161 | 255 | 4 dead definitions extracted from ReynoldsNoGaps.lean: `no_gaps_discrete_archimedean`, `no_gaps_prior`, `prior_implies_succ_archimedean`, `one_class_implies_succ_archimedean` |

## Why Archived

The BX pipeline path through `dd_countermodel_chronicle_discrete` carried a
sorry chain via `no_gaps_faithful`, which was proven mathematically false
(Z+Z counterexample: two disjoint copies of integers with constant predicates
satisfy all hypotheses but have a Dedekind gap).

Task 202 completed the Reynolds model surgery approach, which proves the no-gaps
result at the chronicle level where faithfulness holds by construction. This made
the BX pipeline code dead.

### ReynoldsModelSurgery.lean (task 268)

Contains the deprecated `no_gaps_faithful` proof and its corollary
`prior_model_is_succ_archimedean`. The `PriorModelData` formulation lacks
a faithfulness hypothesis, making the theorem false. The correct proof is
`chronicle_no_gaps` in ChronicleNoGaps.lean.

### ReynoldsNoGapsDeprecated.lean (task 255)

Four definitions with zero external references at time of extraction:

1. **`no_gaps_discrete_archimedean`**: Specialization of `no_gaps_discrete` for
   archimedean orders. Vacuously true (premise always false). Zero consumers.

2. **`no_gaps_prior`**: Mathematically false as stated -- missing faithfulness
   hypothesis. Contains a sorry. Superseded by `chronicle_no_gaps`.

3. **`prior_implies_succ_archimedean`**: Derives `IsSuccArchimedean` from
   Prior-UZ/SZ via `no_gaps_prior`. Dead because `no_gaps_prior` is deprecated.

4. **`one_class_implies_succ_archimedean`**: Thin wrapper around
   `prior_implies_succ_archimedean`. Dead for the same reason.

Also removed: `orbit_le_succ_closed` (private helper with zero references).

## Live Definitions (NOT archived)

Three definitions remain in `ReynoldsNoGaps.lean` and are referenced by
`GoodStructuresModelSurgery.lean`:

- `very_good_of_archimedean`
- `one_class_archimedean`
- `gap_of_not_succ_archimedean`

## Relationship to Active Code

The completeness pipeline uses:
- `chronicle_no_gaps` (ChronicleNoGaps.lean) for the no-gaps result
- `countermodel_discrete_reynolds` / `countermodel_discrete_reynolds_v2`
  (ReynoldsBridge.lean) for discrete countermodels
- `gap_of_not_succ_archimedean` (ReynoldsNoGaps.lean, still live) for gap
  existence in non-archimedean orders
