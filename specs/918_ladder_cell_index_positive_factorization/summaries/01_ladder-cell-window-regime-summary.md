# Implementation Summary: Task #918

- **Task**: 918 - Ladder cell index positive factorization (re-scoped: the ordinary window regime)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-11T00:00:00Z
- **Completed**: 2026-11-11T16:05:00Z
- **Effort**: ~6.5h across seven dispatches (phases 1-6)
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
as the cycle-1 recorded decision settled. Phase 5 stated the regime's depth-`0` cell obligation as
a schema, proved it, and compiled the regimes' exhaustiveness — the schema concluding direction-
indexed cell INCLUSION rather than the equality its task list specified, because
`Set.Subset.antisymm` has only one inclusion to consume and equality is therefore not proved. Phase 6
is CONDITIONAL on a Phase 2 gate FAIL, which did not occur, so it closed on its own PASS branch:
no window-regime obstruction was compiled, because none exists to compile. The one edit it made
is a guard entry for the obstruction this task DID compile -- the lowering-direction anchor
deficit -- which three landed exclusion records cite as their Evidence and which no gate reached.

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
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — 1683 → 1866 lines in the
  phase-5 dispatch. New: `CellSubsetOfKappaEqWindowRaise` (the window regime's depth-`0` cell
  obligation as a schema, with direction-indexed cell inclusion as the conclusion),
  `cellSubset_of_kappa_eq_window_raise` (its theorem), and
  `kappa_collision_window_or_pendPast_exhaustive` (the regimes' exhaustiveness at a fixed
  register, derived from `clipIdx_regime_of_eq` and `pend_past_of_nxtAt_lt`). The `longFile`
  baseline was raised from 1700 to 1900 on the crossing.
- `typst/generated/status.typ` — regenerated line/count fields.

- `scripts/check-evidence-probes.sh` — one new `WIRED_REPO` entry plus its documentation block
  (+53 lines), wiring `specs/918_ladder_cell_index_positive_factorization/evidence/`
  `lowering-anchor-deficit.lean` into the probe rot guard. That probe is this task's actually
  compiled obstruction and was previously reached by no gate. Entered under `WIRED_REPO` rather
  than `WIRED` with a named deferred-move blocker: three landed `#### Reasoned Exclusions` records
  cite its task-directory path verbatim, so the file cannot move until those citations move with
  it. Phase 6 touched no `.lean` file at all.

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
- **The schema concludes INCLUSION and is named for it.** `CellSubsetOfKappaEqWindowRaise`, not
  `CellLEZeroConstOfKappaEqWindow`: a reader comparing it against the five landed
  `CellLEZeroConstOfKappaEq...` schemas can tell the two conclusion strengths apart without
  opening either statement. Weakening the conclusion under the equality-suggesting name would
  have hidden the asymmetry the lowering exclusion creates.
- **The conclusion is stated symmetrically, as two direction-indexed implications**, rather than
  as the single inclusion the room pays for. The reverse half is discharged as vacuous
  (`0 < j * (P + 1)` contradicts the opposite ordering) and the docstring says so; stating only
  one direction would have left which pair the room pays for implicit in the quantifier order.
- **The exhaustiveness record consumes both named lemmas, as the plan specified.**
  `clipIdx_regime_of_eq` supplies the same-side arithmetic — a fixed-register collision cannot
  straddle the window boundary at `2 ≤ B` — and `pend_past_of_nxtAt_lt` supplies the gap branch's
  path-level half, that every ladder path through either state is pending at every earlier
  position. Neither branch is asserted inhabited at any particular parameters.
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
- **Phase 5, schema and theorem** altered: landed as `CellSubsetOfKappaEqWindowRaise` /
  `cellSubset_of_kappa_eq_window_raise` with direction-indexed cell INCLUSION as the conclusion,
  not `CellLEZeroConstOfKappaEqWindow` with cell EQUALITY. `Set.Subset.antisymm` is unavailable —
  there is one landed inclusion — and the cycle-1 recorded decision had already re-scoped Phases
  4-5 to the upward direction. Everything else in both tasks is as written. See the plan's
  phase-5 `#### Reasoned Exclusions` record.
- **Phase 5, docstring task** altered: all three required scope-boundary parts are present, with
  a fifth separator added for the weaker conclusion (the plan's list named four, all of which are
  hypothesis-side).
- **Phase 5, final task** altered: written for a gate FAIL, which did not occur; the marker and
  the exclusions record serve the conclusion-strength exclusion instead, as in Phases 3 and 4.
  The schema, its theorem and the dichotomy are all landed, so "land nothing" does not apply.
- **Phase 5, Scope Hypothesis** — the per-phase delta held (+183 against an estimated +180); the
  hypothesis's absolute "near 720 lines" figure was stale from Phase 3's overshoot onward, and
  the module crossed the 1700 `longFile` baseline rather than the 1500 ceiling.

- **Phase 6, probe task** skipped: FAIL-branch-only, and Phase 2's gate measured PASS. No
  window-regime obstruction exists, so a probe asserting one would be false rather than merely
  unnecessary.
- **Phase 6, module-docstring verdict task** skipped: its text ("the window regime is refuted...
  the ladder route is closed in both regimes") is counterfactual on the branch taken. The window
  regime is closed positively and one-directionally; the ladder route is closed in neither regime
  by this task.
- **Phase 6, durable-record task** skipped: same counterfactual consequence. No false durable
  claim was written.
- **Phase 6, `WIRED`-entry task** altered: discharged against the obstruction actually measured,
  as this phase's own `**Files to modify**` note directs, rather than against a non-existent
  window-regime probe.
- **Phase 6, Scope Hypothesis** — predicted content only on the FAIL branch; branch confirmed PASS
  from Phase 2's recorded measurement before starting, so the predicted 80-140-line probe is
  correctly absent. Actual: 0 new `.lean` lines.

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
  axioms. Phase 5's two theorems likewise: `cellSubset_of_kappa_eq_window_raise` → `propext`,
  `Classical.choice`, `Quot.sound`; `kappa_collision_window_or_pendPast_exhaustive` → `propext`,
  `Quot.sound`; both `trust: standard`, no `sorryAx`.
- Scoped guarded build of the same module in the phase-5 dispatch: green on the FIRST attempt,
  guard exit 0, 2018 jobs, 0 errors; one `unusedFintypeInType` warning on the dichotomy was fixed
  by dropping the unused binder and the rebuild is 0 warnings. Phase-end FULL guarded `lake
  build`: guard exit 0, 2974 jobs, 0 errors, 0 warnings, `.olean` newer than source.
- Scoped guarded build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` green on
  the FIRST attempt in the phase-4 dispatch: guard exit 0, 2018 jobs, 0 errors, 0 warnings.
- Exact-name sweep: 0 declaration sites for `cellLE_zero_const_of_kappa_eq` under `FormalSystem/`;
  none of the five new names across phases 4-5 is a prefix of it.
- Batch-gate deferral: the complete gate set was DEFERRED to this invocation's batch stage, per
  this dispatch's Batch Gate Deferral directive; the scoped narrowing invocation covering the
  touched files was run at every sub-step. The plan's final phase keeps `**Verification Tier**:
  full` unedited.

- Phase 6 gate (`local` tier): `bash scripts/check-evidence-probes.sh` exit 0,
  `PASS  all 54 wired probe(s) compile`. Delta against the pre-phase run: 53 -> 54 wired, the new
  entry `PASS`, zero PASS-to-FAIL transitions, the one deliberate `SKIP` unchanged.
- The newly wired probe itself: `timeout 540 lake env lean` on it exits 0 with zero output;
  `sorry`/`axiom` sweep returns no occurrence; all three theorems (`lowering_anchor_not_implied`,
  `lowering_anchor_of_required`, `lowering_anchor_fails_at_tight_bound`) close by `omega` alone.
- Phase 6 phase-end FULL guarded `lake build`: guard exit 0, `Build completed successfully
  (2974 jobs)`, `error:` count 0, `warning:` count 0, `.olean` newer than source for
  `LadderWindow`. Run although Phase 6 touched no `.lean` file, so the Lean build graph was
  unchanged from Phase 5's close.
- Phase 6 sorry census: `lean-sorry-census.sh` over the resolved source roots reports
  `sorry_count: 0`, empty inventory. The compiler-side half of the cross-check is the same
  dispatch's full build, which reports 0 `uses 'sorry'` warnings; `--cross-check`'s own `lake
  build` was not re-run as a separate invocation, which is stated here rather than implied.
- Phase 6 `bash scripts/typst-sync-check.sh --fix`: PASS, `MA_COUNT_MISMATCHES=0`; `status.typ`
  came back unchanged, correctly, since no `.lean` line count moved. Nothing to stage.
- Phase 6 vacuous count 1 and axiom count 14, both byte-identical to the figures above: the
  phase's commit touched 0 `.lean` files (`git show --name-only` on `68e260294`), so neither
  figure could have moved.

## Impacts

- The window regime now has a path-level raising primitive at an exact multiple of `P + 1` with the
  object state, the register and the realized type all held at `z`, AND its cell-level lift
  `cellAt_subset_of_window_raise`. Phase 5's schema can consume the inclusion directly.
- The window regime's depth-`0` cell obligation now has a stated schema and a theorem, as a cell
  INCLUSION. The cell EQUALITY the plan's phase-5 task list specified is NOT proved and is not
  claimed anywhere: `Set.Subset.antisymm` needs both directions and only one exists.
- The regimes' exhaustiveness is compiled, so this schema and the five landed
  `CellLEZeroConstOfKappaEq...` schemas are visibly the two halves of a partition of the
  fixed-register collisions rather than two unrelated special cases. What the partition does NOT
  give is a proof of the reserved statement: the window half's conclusion is an inclusion, so the
  two halves do not compose into an equality even where both apply.
- `exists_iterIdleSpliced_ladderPath_idx` is a general-purpose addition: an iterated idle
  lengthening with the realized type exposed at every position, usable wherever the landed idle
  pump's below-the-block exposure is too narrow.

## Follow-ups

- Decide whether the lowering direction's missing hypothesis — a bound on the register from above,
  relative to the in-region depth, recorded as `window_lower_anchor_of_required` — is admissible.
  Until it is, the window schema stays one-directional and cell equality in this regime is
  unproved. This is now the single gate between the landed inclusion schema and an equality one.
- Phase 7 remains, and is the only phase left. Phase 6 closed on its PASS branch
  `[COMPLETED WITH EXCLUSIONS]` with a three-row record; it compiled no obstruction, because the
  decision gate it is conditional on passed. Phase 7 owns the generated surfaces and the stale
  `RaySummary/README.md` module-inventory row for `LadderWindow.lean` (still recording 682 lines
  and no cell-level consequence; both figures and the description are now wrong at 1866 lines with
  a schema, a theorem and a dichotomy).
- PROMOTION OWED BEFORE ARCHIVAL, now Phase 7's to discharge: move
  `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` to
  `specs/evidence/seam-gluing-ray-product/`, where every other ladder probe in this family lives,
  and update the three `#### Reasoned Exclusions` Evidence citations (Phases 3, 4, 5) that name
  its task-directory path verbatim, then re-point its guard entry from `WIRED_REPO` to `WIRED`.
  This is not cosmetic: `.gitignore` excludes `specs/archive/`, so an archival `mv` of the task
  directory would take the probe out of version control in that one commit, after which the guard
  reports `FAIL (untracked: ...)` on every clean checkout while staying green for whoever already
  has the file.
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
- `specs/918_ladder_cell_index_positive_factorization/handoffs/phase-4-handoff-20261111T134005Z.md`
