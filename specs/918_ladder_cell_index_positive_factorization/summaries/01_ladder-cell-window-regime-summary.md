# Implementation Summary: Task #918

- **Task**: 918 - Ladder cell index positive factorization (re-scoped: the ordinary window regime)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-11T00:00:00Z
- **Completed**: 2026-11-11T14:05:00Z
- **Effort**: ~5h across five dispatches (phases 1-4)
- **Dependencies**: None
- **Artifacts**: plans/01_ladder-cell-window-regime.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-4 of the window-regime plan are closed. Phase 1 landed the new leaf module
`LadderWindow.lean` with the four compiled arithmetic statements; Phase 2's decision gate PASSED
by compiled measurement; Phase 3 landed the window regime's RAISING primitive in full — a ladder
path through `(objAt g z, cntAt g z + m·(P+1), nxtAt g z)` at `z` itself, carrying the realized
stab-free type at `z`, under the window hypotheses, the collision's room and one named idle-run
condition. Phase 3's second deliverable, the LOWERING primitive, is EXCLUDED on a compiled
measurement: its anchor clause reverses direction under deletion and needs a sixth hypothesis that
the decision gate's own criterion forbids adding. Phase 4 lifted the raising primitive to the CELL
level as `cellAt_subset_of_window_raise`, the window regime's upward cell inclusion, carrying the
region-start-plus-idle-run package through a new existential-over-paths condition
`WindowIdleRunWitnessed`; its downward counterpart is excluded for want of the lowering primitive,
as the cycle-1 recorded decision settled.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — 406 → 1571 lines. New in
  this dispatch: `window_natAbs_sub_comm`, `window_iter_anchor_raise`, `window_iter_anchor_shift`,
  `window_iter_slack_raise`, `window_iter_budget_raise`, `window_iter_no_low_shift`,
  `window_iter_pin_trichotomy`, `window_iter_pins`, `exists_window_iterSpliced_ladderPath`,
  `window_idle_pin_dichotomy`, `window_idle_anchor_clause`, `window_idle_slack`,
  `window_idle_budget`, `exists_iterIdleSpliced_ladderPath_idx`, `exists_window_raise_displaced`,
  `exists_window_raise_ladderPath`, `window_lower_anchor_not_implied`,
  `window_lower_anchor_fails_at_tight_bound`, `window_lower_anchor_of_required`;
  `exists_idleBlock_of_hasIdleRunBelow` strengthened with the run's own lower end; the module's
  `longFile` baseline set to 1700.
- `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` — the
  three-assertion probe measuring the lowering direction's deficit.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — 1571 → 1683 lines in the
  phase-4 dispatch. New: `WindowIdleRunWitnessed` (the window regime's path data lifted from one
  path to a whole cell, existential over paths, in the landed `ForwardSlackWitnessed` shape) and
  `cellAt_subset_of_window_raise` (the upward cell inclusion). The `longFile` baseline stays at
  1700; 1683 is inside the linter's own `1500 ≤ lines < 1700` window.
- `typst/generated/status.typ` — regenerated line/count fields.

## Decisions

- **The iterate is stated about the spliced path alone, not relative to the original.** The
  relative form landed in the first phase-3 dispatch is not preserved by a second splice. The
  self-contained restatement is strictly shorter: the pending stretch `(a, u+l]` forces a region
  start at or above `a` to BE `a`, so the class-1 clause needs no agreement hypothesis and the
  idle-run condition drops out of the trichotomy entirely, re-entering only as a numeric budget.
- **Both budget invariants carry the spend added on the RIGHT, not subtracted from the budget.**
  No truncated natural subtraction appears, and each step's reproduction is one `omega` away.
- **A new index-form idle iterate was needed.** The landed `exists_iterIdleSpliced_ladderPath`
  exposes the realized type only strictly BELOW its block, while this construction's comparison
  position sits above it, and no shift argument substitutes — a stab-free realized type is not
  determined locally. What makes the global form available is that the idle splice is a rigid index
  pullback in BOTH coordinates, so `tpOf_eq_spliceIdx_of_tpOf_eq` applies unchanged.
- **The re-anchoring is a genuine translation.** `isLadderPath_shift` moves the path back by the
  insertion length, and the realized type crosses it through `tpOf_timeShift` composed with
  `tpOf_stabFree_eq_of_objAt_eq` at the shifted history — the same conjugation
  `tpOf_periodic_of_objAt_periodic` uses. No new model-level machinery was added.
- **The lowering direction's sixth hypothesis was NOT added.** The decision gate's criterion is
  the contract; the missing hypothesis's exact shape is recorded as a theorem instead.
- **The cell inclusion's regime data is CARRIED, not derived, and this is forced.** The plan's
  phase-4 task said to derive the idle-past fact from the window hypothesis. It is not derivable:
  `cntAt_le_nxtAt_succ_of_idle_past` runs from an idle past to the window and its converse is
  false (a pending-forever path at `c = 0` satisfies `c ≤ n + 1` outright), so no state-level
  variant of the regime's path data exists. `WindowIdleRunWitnessed` carries it in the weakest
  available form — EXISTENTIAL over the paths through the state, the same shape the landed
  `ForwardSlackWitnessed` takes for the pending-forever regime's own downward inclusion — rather
  than universally over all paths.
- **The window hypothesis is not carried separately on the inclusion.** The collision's own room
  `c + m·(P+1) ≤ n` already implies `c ≤ n`, hence `¬ (n + 2 ≤ c)`, so the statement lies inside
  the window branch by construction. No regime hypothesis was added to make it so.

## Plan Deviations

- **Phase 3, lowering primitive** skipped: excluded on a compiled measurement; see the plan's
  `#### Reasoned Exclusions` record.
- **Phase 3, type half** altered: carried for the raising direction only, and the idle stage needed
  a new index-form iterate rather than the landed one.
- **Phase 3, final task** altered: the `[COMPLETED WITH EXCLUSIONS]` branch was written for a gate
  FAIL; the gate PASSED, so the marker and the exclusions record serve a direction-specific
  exclusion instead.
- **Phase 1** (earlier dispatch): the aggregator's `## Modules` docstring list gained a matching
  bullet alongside the bare import line.
- **Phase 4, downward inclusion** skipped: EXCLUDED — it is a lift of a primitive Phase 3
  excluded on a compiled measurement, and the cycle-1 recorded decision re-scoped Phases 4-5 to
  the upward inclusion only. See the plan's phase-4 `#### Reasoned Exclusions` record.
- **Phase 4, upward inclusion** altered: the idle-past fact is carried rather than derived (see
  Decisions); every other element of the task — `mem_cellAt_ladder_iff`, the three read-offs,
  `exists_window_raise_ladderPath`, `exists_hist_of_isLadderPath` — is as the plan wrote it.
- **Phase 4, docstring task** altered: recorded in the upward inclusion's docstring and in
  `WindowIdleRunWitnessed`'s, there being no second inclusion.
- **Phase 4, final task** altered: written for a gate FAIL, which did not occur; the marker and
  the exclusions record serve the direction-specific exclusion instead, as in Phase 3.

## Verification

- Build: Success — phase-end FULL guarded `lake build`, 2974 jobs, guard exit 0, `error:` count 0,
  `warning:` count 0, `.olean` newer than source for `LadderWindow`.
- Sorry count: 0 (`lean-sorry-census.sh --cross-check`: stripper 0, compiler 0, `cross_check:
  MATCH`).
- Sorry inventory: None.
- Vacuous count: 1, pre-existing and untouched — `FormalSystem/Examples/TemporalStructures.lean`'s
  `int_domain_universal`, whose goal is definitionally `True` for integer time. Zero introduced by
  this task.
- Axiom count: 14, unchanged from baseline; `LadderWindow.lean` declares none.
- `lean_verify` on `exists_window_raise_ladderPath` and on `cellAt_subset_of_window_raise`:
  `propext`, `Classical.choice`, `Quot.sound`; `trust: standard`; no `sorryAx`, no non-standard
  axioms.
- Scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` green on
  the FIRST attempt in the phase-4 dispatch: guard exit 0, 2018 jobs, 0 errors, 0 warnings.
- Exact-name sweep: 0 declaration sites for `cellLE_zero_const_of_kappa_eq` under `FormalSystem/`;
  neither new name is a prefix of it.
- Batch-gate deferral: the complete gate set was DEFERRED to this invocation's batch stage, per
  this dispatch's Batch Gate Deferral directive; the scoped narrowing invocation covering the
  touched files was run at every sub-step. The plan's final phase keeps `**Verification Tier**:
  full` unedited.

## Impacts

- The window regime now has a path-level raising primitive at an exact multiple of `P + 1` with the
  object state, the register and the realized type all held at `z`, AND its cell-level lift
  `cellAt_subset_of_window_raise`. Phase 5's schema can consume the inclusion directly.
- The downward cell inclusion and the window schema's two-directional form (Phase 5) are blocked by
  the lowering exclusion. Phase 5's schema is therefore reachable as a cell INCLUSION only, not as
  the cell EQUALITY its task list specifies: `Set.Subset.antisymm` needs both directions and only
  one exists. That is a scope question for Phase 5, flagged here rather than pre-decided.
- `exists_iterIdleSpliced_ladderPath_idx` is a general-purpose addition: an iterated idle
  lengthening with the realized type exposed at every position, usable wherever the landed idle
  pump's below-the-block exposure is too narrow.

## Follow-ups

- Decide whether the lowering direction's missing hypothesis — a bound on the register from above,
  relative to the in-region depth, recorded as `window_lower_anchor_of_required` — is admissible.
  If it is not, Phases 4 and 5 are one-directional and the window schema is correspondingly
  one-directional.
- Phase 5's task list writes cell EQUALITY via `Set.Subset.antisymm`. With the downward direction
  excluded, that is unreachable; the honest terminus is the one-directional schema plus the
  compiled dichotomy. Phase 5 should state which it lands rather than weakening the equality
  silently.
- `exists_window_raise_ladderPath` and `cellAt_subset_of_window_raise` carry the idle-run condition
  as a hypothesis. It RESTRICTS the
  obligation rather than discharging it, so the reserved `cellLE_zero_const_of_kappa_eq` is still
  claimed by nothing and the positive factorization lemma in its unconditional form is unproved.

## References

- `specs/918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md`
- `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean`
- `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`
- `specs/918_ladder_cell_index_positive_factorization/handoffs/phase-3-handoff-20261111T005756Z.md`
- `specs/918_ladder_cell_index_positive_factorization/handoffs/phase-3-handoff-20261111T131951Z.md`
