# Phase 12b Handoff — (0,2) point-channel merge (w = t channel) (task 350)

## Immediate Next Action

Phase 13: (E1) exterior fiber kit + single-fiber R3 probe, in NEW module
`Kamp/NfMultiAnchorBridge/ExteriorFiberKitK1.lean` (+ one aggregator import line).
FIRST task is the R3 ADJUDICATION PROBE: one concrete qnf with the w<x channel, one bit-true
and one bit-false inner fiber end-to-end through the intended device, clause iff proved.
On failure: [BLOCKED] + exact fiber + qnf pattern — do NOT generalize (E2 does not dispatch).
Then `extZoneFiber_k1` via `nf_eval_depth1_fold_iff` at n=3, env `[w,x,t]` (7 zones of w<x<t),
and `extZone_consistent_*` falsity lemmas (arity-3 instance of the `agg2_zone_consistent_*`
technique). Depends on Phase 11 (delivered).

## Current State

- Phase 12b [COMPLETED]. 14/18 phases complete (per plan v3 phase list). Next phase: 13.
- `AggregatePointMergeK1.lean` extended 387 → 668 lines with section `AggPointMerge02`
  (purely additive; the aggregator import from 12a already covers it — no import changes).
- Scoped build 1033 jobs + full `lake build` 1747 jobs green on the FIRST build — the 12a
  proof scripts transferred verbatim under the (0,2) renames; zero fix iterations.
- `lean_verify` on `aggPm02ClauseK1_iff` and `aggPm02_clause_fold_iff` = exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings. Sorry count in module: 0.
- Territory clean: only the leaf module + plan file modified (no frozen provider files, no
  KampPrior.lean, no task-358 files).

## Delivered Names (BINDING for 16 — consume, do not rebuild)

| Asset | Purpose |
|---|---|
| `aggPmExpand02` (0↦1, 1↦2) / `aggPmMerge02` (0↦1, 1↦0, 2↦1) | the (0,2) rename pair |
| `aggPmMerge02_expand02`, `aggPm_liftMerge_liftExpand02` | retraction + lifted retraction |
| `aggPm02CollapseRow/DupRow/CollapseSub/DupSub/CollapseK1` | concrete-typed rename wrappers |
| `agg_pm02_collapse_k1` | gated depth-1 (0,2) collapse: `[t,x,t]` eval ↔ `[x,t]` eval of collapse |
| `aggPm02GateK1` / `aggPm02_gate_of_eval` | syntactic gate + gate forcing (fixpoint engine) |
| `aggPm02_clause_iff` | clause iff: eval ↔ gate ∧ collapsed eval |
| `aggPm02ClauseK1(_iff)` | dite carrier, off-gate `⊥` (the `aggPosDiagK1` shape) |
| `aggPm02_fold_iff` / `aggPm02_clause_fold_iff` | n=2 fold characterization (agg2-kit-ready) |

## Key Decisions

- The 12a-handoff orientation note was followed exactly: expand `0↦1, 1↦2` (slot 0 = anchor
  `x`, slot 1 = merged point `w = t`), merge `0↦1, 1↦0, 2↦1`; collapsed env `[x, t]` keeps
  the SAME fixed anchors as 12a (Phase 16 consumes both channels against one agg2 kit shape).
- No new genericity probe: R9 was retired in 12a (engines machine-confirmed rename-generic);
  the (0,2) instantiation is direct.
- All env compatibilities (`hcomp`, `hcomp2`, `hE3`) closed by `rfl` at literal `Fin`
  indices, exactly as in 12a — the `if`-based rename pair defs reduce definitionally.
- Merge def uses `if i.val = 1 then 0 else 1` (position 1 is the sole non-merged slot),
  the minimal single-test mirror of 12a's `if i.val ≤ 1`.

## Sorry Inventory

(empty)
