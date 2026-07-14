# Phase 12a Handoff — (0,1) point-channel merge + R9 genericity probe (task 350)

## Immediate Next Action

Phase 12b: the (0,2) mirror (w = t channel) in the SAME file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean`.
Same technique at position (0,2): rename pair expand `0 ↦ 0, 1 ↦ 1` (slot 0 = the merged pair
`w = t`? NO — see orientation note below), merge sending positions 0, 2 together.

**Orientation note for 12b:** at `w = t` the duplicated positions of the env `[w, x, t] = [t, x, t]`
are (0, 2). A retraction pair is: expand `Fin 2 → Fin 3` with `0 ↦ 1, 1 ↦ 2` (slot 0 = the anchor
`x`, slot 1 = the merged point `w = t`) and merge `Fin 3 → Fin 2` with `0 ↦ 1, 1 ↦ 0, 2 ↦ 1` — the
collapsed env is `[x, t]` (same fixed anchors as 12a, KEEPING the anchor order), and the
`hcomp`/`hcomp2` compatibilities hold by `rfl` at literal indices exactly as in 12a. Verify the
retraction `merge ∘ expand = id` by `decide` before anything else.

## Current State

- Phase 12a [COMPLETED]. 13/18 phases complete (per plan v3 phase list).
- New leaf module `AggregatePointMergeK1.lean` (388 lines), imported by the aggregator
  `NfMultiAnchorBridge.lean` directly after `AggregateHookDischarge`.
- **R9 RETIRED**: `renameNF`, `renameNF_eval_diag0`, and `agg_rename_fixpoint_of_eval` are
  machine-confirmed rename-generic at position (0,1) — the probe `aggPm01Probe_clause_iff`
  compiles end-to-end for the concrete all-false qnf. No engine modification was needed.
- Full `lake build` green: 1747 jobs. Sorry count in module: 0. `lean_verify` on
  `aggPm01Probe_clause_iff`, `aggPm01ClauseK1_iff`, `aggPm01_clause_fold_iff` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- Commits: 0ae5ff87c (module + probe), 7167eb83e (aggregator import).
- Territory clean: no edits to the seven frozen provider files, KampPrior.lean, or the
  task-358 files (`git diff --stat` per commit shows only the new leaf + aggregator + plan).

## Delivered Names (BINDING for 12b/16 — consume, do not rebuild)

| Asset | Purpose |
|---|---|
| `aggPmExpand01` (0↦0, 1↦2) / `aggPmMerge01` (0,1↦0, 2↦1) | the (0,1) rename pair |
| `aggPmMerge01_expand01`, `aggPm_liftMerge_liftExpand01` | retraction + lifted retraction |
| `aggPm01CollapseRow/DupRow/CollapseSub/DupSub/CollapseK1` | concrete-typed rename wrappers |
| `agg_pm01_collapse_k1` | gated depth-1 (0,1) collapse: `[x,x,t]` eval ↔ `[x,t]` eval of collapse |
| `aggPm01GateK1` / `aggPm01_gate_of_eval` | syntactic gate + gate forcing (fixpoint engine) |
| `aggPm01_clause_iff` | clause iff: eval ↔ gate ∧ collapsed eval |
| `aggPm01ClauseK1(_iff)` | dite carrier, off-gate `⊥` (the `aggPosDiagK1` shape) |
| `aggPm01_fold_iff` / `aggPm01_clause_fold_iff` | n=2 fold characterization (agg2-kit-ready) |
| `aggPm01_renameNF_false` | any depth-0 rename of the all-false row is all-false (probe helper) |
| `aggPm01ProbeQnf` + `aggPm01Probe_{row_fix,quant_off,clause_iff}` | the R9 probe record |

## Key Decisions

- Probe-first honored at the proved-item level: the probe and its supporting general collapse
  lemma landed in ONE green commit; nothing was generalized to (0,2). The general lemma is the
  encoding of the merge; the probe instantiates it end-to-end at a concrete qnf.
- Concrete probe qnf = all-false row + all-false quant layer: its clause iff is NOT vacuous for
  arbitrary `M` (falsity of both sides is not decidable generically), so the proof genuinely
  traverses both rename bridges and the backward fixpoint branch.
- `renameNF` k-inference pitfall (one build iteration): bare lambdas do not unify with
  `NormalForm ?k ?a` because `NormalForm` is a recursion on `k` — pin `(k := 0)` explicitly
  (see `aggPm01_renameNF_false`). 12b will hit the same if it states row lemmas on lambdas.
- The carrier is Prop-level (`aggPm01ClauseK1 : … → Prop`), not a closed `Formula`: the (0,1)
  channel is FIXED-ANCHOR (no ∃w and two free anchors x, t), so the `aggPosDiagK1` dite-to-bot
  pattern is mirrored at Prop level; formula/VVecEA2-level assembly is Phase 16's job via
  `aggPm01_clause_fold_iff` + the delivered agg2 kit.

## Sorry Inventory

(empty)
