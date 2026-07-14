# Phase 12a Summary — (0,1) point-channel merge variant + R9 genericity probe

- **Task**: 350
- **Phase**: 12a (plan v3, `plans/03_negfix-refactor-exterior-carriers.md`)
- **Status**: [COMPLETED]
- **Session**: sess_1784009176_e5245f
- **Date**: 2026-07-13

## What Was Built

New leaf module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregatePointMergeK1.lean`
(388 lines) + one aggregator import line in `NfMultiAnchorBridge.lean`. The per-qnf k=1 carrier
for the `w = x` channel of the population existential `∃ w, nf_eval_nf M 1 3 [w,x,t] qnf`
(Rabinovich Lemma 3.2(2) coincident-witness collapse, chunk_0009), as the position-(0,1)
rename-merge variant of the delivered gated anchor-collapse.

## R9 Genericity Probe (first task) — PASSED

`aggPm01Probe_clause_iff` encodes the (0,1) merge end-to-end for one concrete qnf (all-false
row + all-false quant layer) and proves its clause iff through the full engine chain:
`renameNF_eval_diag0` at row and lifted-sub level, and `agg_rename_fixpoint_of_eval` in the
backward non-fixpoint branch, all at the NEW rename pair `aggPmExpand01` (0↦0, 1↦2) /
`aggPmMerge01` (0,1↦0, 2↦1) with duplicated-head env `[x,x,t]`. All three delivered engines
are rename-generic at position (0,1); risk R9 is retired with no engine modification.

## Theorems Proved (all sorry-free)

| Name | Statement shape |
|---|---|
| `aggPmMerge01_expand01`, `aggPm_liftMerge_liftExpand01` | retraction + lifted retraction |
| `agg_pm01_collapse_k1` | gated collapse: `nf_eval M 1 3 [x,x,t] qnf ↔ nf_eval M 1 2 [x,t] (collapse qnf)` under the (0,1) gate |
| `aggPm01_renameNF_false`, `aggPm01Probe_row_fix`, `aggPm01Probe_quant_off` | probe gate discharge |
| `aggPm01Probe_clause_iff` | R9 probe clause iff (end-to-end, concrete qnf) |
| `aggPm01_gate_of_eval` | any realizer at `[x,x,t]` forces the gate (fixpoint engine) |
| `aggPm01_clause_iff` | eval `[x,x,t]` ↔ `aggPm01GateK1 qnf` ∧ collapsed eval `[x,t]` |
| `aggPm01ClauseK1_iff` | dite carrier correct (off-gate `⊥`, the `aggPosDiagK1` shape) |
| `aggPm01_fold_iff`, `aggPm01_clause_fold_iff` | collapsed side via `nf_eval_depth1_fold_iff` at n=2 (agg2-kit-ready) |

## Verification Results

- Scoped build: 1033 jobs green; aggregator: 1044 jobs green; full `lake build`: 1747 jobs green.
- `lean_verify` on `aggPm01Probe_clause_iff`, `aggPm01ClauseK1_iff`, `aggPm01_clause_fold_iff`:
  axioms exactly `[propext, Classical.choice, Quot.sound]`, no warnings, no suspicious patterns.
- Sorry count in module: 0. Vacuous-definition count: 0. New axioms: 0.
- Territory: zero hunks in the seven frozen provider files, `KampPrior.lean`, or task-358 files.
- Guards honored: consumed (never rebuilt) `agg_rename_fixpoint_of_eval`, `renameNF`,
  `renameNF_eval_diag0`, `nf_eval_depth1_fold_iff`, `aggPosDiagK1` pattern; `nf_char3_deeper_split`
  not referenced; G5 manual bridges throughout the Lemma 3.2(2) chain.

## Plan Deviations

- None of substance. One noted nuance: the probe and its supporting general collapse lemma
  landed in a single green commit (the probe was the first proved item; the general lemma is
  the merge encoding the probe instantiates). Nothing was generalized to (0,2).

## Commits

- `0ae5ff87c` — task 350 phase 12a: (0,1) point-merge carrier + R9 genericity probe green
- `7167eb83e` — task 350 phase 12a: thread AggregatePointMergeK1 into the aggregator

## Next Phase

12b: the (0,2) mirror (`w = t` channel), same file, same technique — see
`handoffs/phase-12a-handoff-20260713.md` for the (0,2) rename-pair orientation note.
