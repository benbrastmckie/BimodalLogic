# Phase 3A Handoff: sel_pn_ord sorry'd fact added

## Status: COMPLETED

## What Was Done

Added `sel_pn_ord` and `pn_sel_ord` as sorry'd local `have` statements in CaseAnalysis.lean at both Case A (line ~1418) and Case B (line ~1769) sorry sites. These provide the missing ordering between tau selections and p_n/e_n:

```lean
sel_pn_ord : forall (k : Fin n),
    (a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
    (a_init k = extendPoint p_n <-> resp_tau k = e_n)
```

`pn_sel_ord` is the reverse direction, derived from `sel_pn_ord` via linear order trichotomy (no additional sorry).

## Deviation from Plan

The plan called for adding `sel_pn_ord` as a field in `SplitPointProps` (SplitPoint.lean). This was altered: the field was added as local `have` statements in CaseAnalysis.lean instead.

**Reason**: `resp_tau` and `e_n` are local variables in the case analysis proof, NOT parameters of `SplitPointProps`. Adding them as SplitPointProps parameters would require invasive changes to the structure definition and `obtain_split_point_props` theorem. The local approach is simpler, achieves the same mathematical result, and the sorry is still concentrated in a single location per case.

## Build Status

`lake build` passes with zero errors. 1667 jobs.

## Sorry Count (CaseAnalysis.lean)

| Line | Type | Status |
|------|------|--------|
| 413 | Case I index mapping | Pre-existing |
| 1423 | sel_pn_ord (Case A) | **New** (Phase 3A) |
| 1622 | Grid fallback (Case A) | Pre-existing (same goals) |
| 1773 | sel_pn_ord (Case B) | **New** (Phase 3A) |
| 1914 | Grid fallback (Case B) | Pre-existing (same goals) |
| 1967 | Dead code block | Pre-existing |
| 2885 | Cases III-IV | Pre-existing (Phase 5) |

## Immediate Next Action

Phase 3B: Replace `same_order_type_grid <;> first | ... | sorry` pattern with structured focused proofs using named hypotheses. Use `sel_pn_ord` and `pn_sel_ord` for the sel-vs-p_n goals. The grid fallback sorries at lines 1622 and 1914 should be eliminated by Phase 3B.

## Key Decisions

1. Local `have` instead of SplitPointProps field -- pragmatic, avoids parameter explosion
2. `pn_sel_ord` derived from `sel_pn_ord` via trichotomy -- no additional sorry
3. Grid fallback sorries left unchanged -- Phase 3B responsibility

## Session

Session: sess_1779835463_ef22f5
