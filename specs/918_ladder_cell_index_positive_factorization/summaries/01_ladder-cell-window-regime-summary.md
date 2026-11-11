# Implementation Summary: Task #918

- **Task**: 918 - Ladder cell index positive factorization (re-scoped: the ordinary window regime)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-11T00:00:00Z
- **Completed**: 2026-11-11T08:10:00Z
- **Effort**: ~4h across four dispatches (phases 1-3)
- **Dependencies**: None
- **Artifacts**: plans/01_ladder-cell-window-regime.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-3 of the window-regime plan are closed. Phase 1 landed the new leaf module
`LadderWindow.lean` with the four compiled arithmetic statements; Phase 2's decision gate PASSED
by compiled measurement; Phase 3 landed the window regime's RAISING primitive in full — a ladder
path through `(objAt g z, cntAt g z + m·(P+1), nxtAt g z)` at `z` itself, carrying the realized
stab-free type at `z`, under the window hypotheses, the collision's room and one named idle-run
condition. Phase 3's second deliverable, the LOWERING primitive, is EXCLUDED on a compiled
measurement: its anchor clause reverses direction under deletion and needs a sixth hypothesis that
the decision gate's own criterion forbids adding.

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
- `lean_verify` on `exists_window_raise_ladderPath`: `propext`, `Classical.choice`, `Quot.sound`;
  no `sorryAx`.
- Batch-gate deferral: the complete gate set was DEFERRED to this invocation's batch stage, per
  this dispatch's Batch Gate Deferral directive; the scoped narrowing invocation covering the
  touched files was run at every sub-step. The plan's final phase keeps `**Verification Tier**:
  full` unedited.

## Impacts

- The window regime now has a path-level raising primitive at an exact multiple of `P + 1` with the
  object state, the register and the realized type all held at `z`. Phase 4's upward cell inclusion
  can consume it directly.
- The downward cell inclusion (Phase 4's second half) and the window schema's two-directional form
  (Phase 5) are blocked by the lowering exclusion. Phase 5's dichotomy is reachable in a
  one-directional form only.
- `exists_iterIdleSpliced_ladderPath_idx` is a general-purpose addition: an iterated idle
  lengthening with the realized type exposed at every position, usable wherever the landed idle
  pump's below-the-block exposure is too narrow.

## Follow-ups

- Decide whether the lowering direction's missing hypothesis — a bound on the register from above,
  relative to the in-region depth, recorded as `window_lower_anchor_of_required` — is admissible.
  If it is not, Phases 4 and 5 are one-directional and the window schema is correspondingly
  one-directional.
- `exists_window_raise_ladderPath` carries `HasIdleRunBelow` as a hypothesis. It RESTRICTS the
  obligation rather than discharging it, so the reserved `cellLE_zero_const_of_kappa_eq` is still
  claimed by nothing and the positive factorization lemma in its unconditional form is unproved.

## References

- `specs/918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md`
- `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean`
- `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`
- `specs/918_ladder_cell_index_positive_factorization/handoffs/phase-3-handoff-20261111T005756Z.md`
