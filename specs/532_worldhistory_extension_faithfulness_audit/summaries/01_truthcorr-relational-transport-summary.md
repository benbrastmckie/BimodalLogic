# Implementation Summary: Task #532 — TruthCorr relational transport

- **Task**: 532 — Audit and resolve the partial-vs-total WorldHistory faithfulness gap
- **Status**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Plan**: `plans/01_truthcorr-relational-transport.md` (6 phases, all `[COMPLETED]`)
- **Session**: sess_1788388902_211d42 (dispatch 3)
- **Type**: lean4

## What landed

The paper's relational proof shape is now the single generic truth transport:

| Declaration | File | Role |
|---|---|---|
| `TruthCorr` | `FormalSystem/Semantics/Truth.lean` (before the `TimeShift` namespace) | `dur` (order iso), `Rel` (relation on arbitrary histories), `atom`, `total_fwd`, `total_bwd` — `def:time-shift-histories` + `app:auto_existence` + the `□` case of `lem:history-time-shift-preservation` |
| `Truth.truthAt_of_truthCorr` | same | the one six-case `induction φ`; axioms `[propext, Quot.sound]` |
| `TruthIso.toCorr` | same | `TruthIso` as the total-only bijective special case |
| `Truth.truthAt_of_truthIso` | same | **statement byte-identical**; now a term-mode one-liner |
| `TimeShift.ShiftRel`, `shiftRel_timeShift`, `shiftRel_timeShift_neg`, `shiftCorr` | same | time shift as a `TruthCorr M M`; `dur := OrderIso.addRight Δ` |
| `TimeShift.timeShift_preserves_truth` | same | **statement byte-identical** (arbitrary `σ`); 230-line induction deleted; 5-line derivation |
| `TimeShift.timeShift_preserves_truth_total` | same | new `F.HF` corollary — the paper-faithful `lem:history-time-shift-preservation`; no consumer uses it |
| `alignedCorr` | `FormalSystem/Semantics/IntTransfer.lean` | `Aligned e` as the `Rel` of a `TruthCorr M (M.map e)` |
| `truthAt_map` | same | **statement byte-identical**; induction deleted; one-line term |

No `WorldHistory ≃`, no `HEq`, no `sorry`, no new axiom anywhere in the diff.
Net: `Truth.lean` 1217 → 1164 lines despite ~130 new lines of structure/docstrings; `IntTransfer.lean` −28 lines.

Hygiene: `specs/paper-definitions-of-record.md` re-pinned (10 anchors re-quoted/re-hashed,
sentinels at sha256 `7303bc9e…`/4867 lines/HEAD `fa0dbf7c…` dirty, narrative
"Drift correction (2026-09-02): ten-anchor re-pin"); raw line-number paper citations removed
from `Truth.lean`/`WorldHistory.lean`; the `Truth.lean` atom bullet corrected against
`def:BL-semantics` (no domain conjunct in the paper; Decision A encoding stated as Lean-side);
convex docstring says equivalent-not-identical; four `def:world-history` `H_F` quotes at the
live wording ("possible worlds"); `FwdRecPeriodicity` names `TruthCorr`; `Semantics/README.md`
`Truth.lean` row extended; resolution notes appended to the 523 plan's Phase 10 blocker and
Phase 12 exclusions.

## `induction φ` ledger (measured, `FormalSystem/Semantics` + `Metalogic/Independence`)

| Site | Class |
|---|---|
| `Truth.truthAt_of_truthCorr` (`Truth.lean:638`) | truth transport — generic |
| `Truth.truthAt_of_truthAntiIso` (`Truth.lean:1126`) | truth transport — generic, time-reversal twin |
| `FwdRecPeriodicity.truthAt_add_hist_period` (`:401`) | truth transport — per-history exception |
| `Truth.truthAt_atomFree_history_indep` (`Truth.lean:893`) | non-transport |
| `ShiftSet.forward_repr` (`:263`) | non-transport |
| `ShiftSet.reverse_repr` (`:366`) | non-transport |

Truth-transport inductions: 5 → **3**. `IntTransfer.lean`: 0.

## Axiom report

| Declaration | Axioms |
|---|---|
| `Truth.truthAt_of_truthCorr` | `propext, Quot.sound` |
| `TimeShift.timeShift_preserves_truth` (and `_total`, `shiftCorr`) | `propext, Quot.sound` (unchanged) |
| `Truth.truthAt_of_truthIso` (and `TruthIso.toCorr`) | `propext, Quot.sound` (unchanged) |
| `truthAt_map` (and `alignedCorr`, `validDiscrete_iff_validInt`) | `propext, Classical.choice, Quot.sound` (unchanged — `Classical.choice` was already present before) |
| `Truth.truthAt_of_truthAntiIso` | `propext, Quot.sound` |

No `sorryAx`. `^axiom ` declarations in `FormalSystem/`: 8 before, 8 after.

## Gate set (final)

- `lake build`: 2520 jobs, exit 0, zero `declaration uses 'sorry'` warnings (run after every Lean phase).
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED (C15: 48 anchor citations resolve).
- `scripts/check-paper-definitions.sh`: exit 0, quiet case-(a) pass (was FAIL on 10 anchors).
- `.claude/scripts/check-task-references.sh`: PASS, 0 occurrences.
- `scripts/readme-lint.sh`: pre-existing FAIL unrelated to this task (2 directories with no README: `Semantics/Frames/`, `Semantics/Ultraproduct/`; 0 broken references, including the edited `Truth.lean` row).
- Sorry census on `FormalSystem/`: 3 hits, all in `Boneyard/StrictSemanticsLegacy/…` — pre-existing (18 `sorry` mentions in that file at the baseline commit) and not part of the build.
- Vacuous-pattern grep: 1 hit, `Examples/TemporalStructures.lean:496` `int_domain_universal … := trivial` — a legitimate proof of a `True`-valued domain fact, pre-existing, not in this diff.
- Consumer sites of `timeShift_preserves_truth` outside `Truth.lean`: 23 lines before and after; `LoopingDuration.lean` and `validDiscrete_iff_validInt` compile unchanged.

## Plan Deviations

- Phase 1, "Leave `TruthAntiIso` and `truthAt_of_truthAntiIso` untouched": altered — code untouched, but one docstring sentence in `truthAt_of_truthAntiIso` now names `truthAt_of_truthCorr` as its twin (the induction it referred to no longer exists).
- Phase 4: the paper repo's `git HEAD` had moved since planning (`fa0dbf7c…`, not `14f1bee5…`); the file checksum/line count were unchanged; measured values pinned. The `def:frame` sub-anchor table's stale `#Spherical` row was re-keyed to `#Saturation` (recorded in the narrative).
- Phase 5: the plan's grep `total world histories over \$` is shell-escaped into an end-of-line anchor and matches nothing; the sweep was run as the plain phrase (4 hits before, 0 after).
- Phase 2: `truth_history_eq` kept (public lemma, zero external references, harmless).

## Recorded traps (honoured)

1. `shiftCorr.dur` must be `OrderIso.addRight Δ`, not a hand-built `OrderIso`.
2. `shiftRel_timeShift_neg` closes the state equation with `WorldHistory.states_eq_of_time_eq … (add_neg_cancel_right z Δ).symm`.
3. `timeShift_preserves_truth`'s derivation ends with `change … at h; rw [add_sub_cancel] at h` — `simpa` does not normalise `(OrderIso.addRight Δ) x`.
4. `alignedCorr.total_bwd` uses the bare term `fun s => hσ' (e s)`; `simpa` fails.
5. New this dispatch: a concurrent `lake env lean` axiom check during a full `lake build` produced a spurious `.olean` "no such file" build failure; re-running the build fixed it. Serialize the two.
