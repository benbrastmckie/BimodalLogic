# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-02T20:58:53Z
- **Completed**: 2026-11-02T21:25:00Z
- **Effort**: one dispatch (seq 23), one phase
- **Dependencies**: 760, 775, 805, 806, 819, 820 (all DISCHARGED)
- **Artifacts**: plans/07_cell-level-agreement-route.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.4 of the cell-level agreement route landed: the ATOM-VALUATION CLOSURE AGREEMENT for the
ladder model. Two ladder paths whose object walks carry the same atom row at every position realize
the same closure type at every position, on the stab-free fragment. The hypothesis is pointwise
agreement of `lab` rather than of the object walk — which is what the ladder model's valuation
actually reads — so the result transports a realized type ACROSS a change of the object walk, which
the landed half (i) cannot do. The phase's one open question, whether the `□` letters have to be
excluded from the fragment, was answered AFFIRMATIVELY (they do not) and compiled.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — seven declarations:
  `StabBoxFree` (the narrow stab-free-and-box-free fragment predicate),
  `stabBoxFree_of_mem_closure` (its restriction to `plusSubformulaClosure φ`),
  `truthAt_iff_of_lab_eq_of_stabBoxFree` (the narrow transport, by induction, one case per clause),
  `tpOf_stabBoxFree_eq_of_lab_eq` (its reading on closure types),
  `truthAt_iff_of_lab_eq_of_stabPinned` (the WIDENED transport at the pinned-letter parameter),
  `tpOf_stabFree_eq_of_lab_eq` (the widened type-level corollary), and
  `tpOf_eq_of_altWalkPath_of_lab_eq` (the instance over Phase 11.3's alternative-history
  construction). Plus a new module-docstring section `## The atom-valuation closure agreement` and
  a `set_option linter.style.longFile 2100` raise (the module reached 1995 lines).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — a
  `## Requirement (W): the atom-valuation closure agreement` section with seven `#print axioms`
  pins, plus a `set_option linter.style.longFile 1700` raise (1539 lines).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` — generated inventory blocks rewritten by `check-module-invariants.sh
  --emit-inventory`.
- `typst/generated/status.typ` — line counts resynced by `typst-status-counts.sh`.
- `specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md` — Phase 11.4
  `[NOT STARTED]` -> `[COMPLETED]`, every checklist item annotated.

## Decisions

- **Fragment shape: the NEW-PREDICATE option.** `StabBoxFree` with no pinned-letter parameter,
  rather than `StabPinned` with its `box` arm tightened. Recorded reason: the narrow fragment asks
  nothing of the letter inside a `□` — it excludes the letter outright — so a parameter over `□`
  letters would carry no information, and tightening `StabPinned`'s arm would mean re-threading a
  parameter the narrow reading never consults.
- **THE `box` ARM WIDENS.** `box_mem_tpOf_transfer`'s only hypothesis beyond closure membership is
  that both points lie in the SAME model; the two compared histories here are both histories of
  `ladderModel step pend fwd bwd lab`, so no hypothesis of it fails and the `box` case of the
  widened induction is literally `Iff.rfl`. Consequence for the route: Phase 11.5's fragment is
  STAB-FREE with `□` INCLUDED, strictly wider than the route decision assumed.
- **The widened form is stated at the pinned-letter parameter**, not for the stab-free fragment
  alone, because the stab-free statement is the one shape an induction on `⊡`-nesting depth
  (Phase 11.6) cannot consume.

## Plan Deviations

- **Phase 11.4, task 3** altered: the `untl`/`snce` cases route through the TRUTH-level clause
  lemmas `PlusTruth.untl_iff`/`PlusTruth.snce_iff`, not the type-level
  `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff` the task names. The task's two directives are in tension:
  the theorem is a statement about `PlusTruthAt`, so a `tpOf`-level `iff` is not applicable inside
  its induction, and the task's own second directive — cite `truthAt_iff_of_objAt_eq_of_stabPinned`
  as the model for the induction's shape — points at a proof that uses exactly the two truth-level
  lemmas, which is what `untl_mem_tpOf_iff` is itself built from. No named declaration skipped, no
  signature weakened, half (i) untouched. Recorded in `issues.jsonl` as a `plan-fidelity` issue at
  severity `minor` so it is re-openable.
- Two file-scope additions the task list did not anticipate: the two `set_option
  linter.style.longFile` raises described above, both with explanatory comments and both following
  the in-repo pattern the module already used. `check-module-invariants.sh --emit-inventory`
  rewrote three generated README inventory blocks rather than the one the Files-to-modify list
  names — the same behaviour the prior phase recorded.

## Verification

- Build: Success. Guarded scoped build of `LadderAgree.lean` exit 0, 1966 jobs, 0 `error:`,
  0 `warning:` — on the FIRST attempt. Guarded scoped build of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` exit 0, 2361 jobs, 0 `error:`, 0 `warning:`.
  Guarded FULL-project build (detached as a shell-level background job, bounded single-call waiter
  with captured `pid`, `kill -0` liveness loop, outer `timeout`, un-piped `wait`) exit 0, 2892
  jobs, 0 `error:`, 0 `warning:`, with `.olean` newer than source for both touched modules — all
  three verdict tiers green.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots, empty inventory)
- Vacuous count: 0 module-scoped; 1 repository-wide, IDENTICAL to the dispatch's starting commit
  `86116550c`
- Axiom count: 14, IDENTICAL to the starting commit; `#print axioms` on all seven new
  declarations gives `StabBoxFree` on NO axioms and the other six on
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no custom axiom, no `native_decide`.
- Tests: Passed. `check-evidence-probes.sh` exit 0 (all 45 wired probes compile, refutation probes
  unmodified), `check-module-invariants.sh` exit 0, `readme-lint.sh` exit 0,
  `typst-sync-check.sh` PASS (4/4 checks), `check-task-references.sh` exit 0.
- Phase-specific checks: the transport hypothesis is pointwise `lab` agreement, and no new
  signature carries `objAt g v = objAt g' v`; half (i)'s three statements are untouched by
  `git diff`; the certificate-freedom grep over `LadderAgree.lean` returns ZERO occurrences; the
  import list is unchanged; `git diff --stat` on `CounterQuotient.lean` is EMPTY; no declaration
  named `tpOf_stabFree_eq_of_splice` or any `tpOf_*_of_splice` exists.
- Files verified: Yes

## Impacts

- Phase 11.5 (the stab-free cell agreement on `kappa`-classes) is unblocked and its fragment is
  now STAB-FREE with `□` included, so the box-free restriction can be dropped from every
  downstream statement of the route.
- Phase 11.6's `⊡`-nesting-depth induction has its step's hypothesis shape available at the
  pinned-letter parameter (`truthAt_iff_of_lab_eq_of_stabPinned`).
- The alternative-history construction and the truth-transport layer now meet in one statement
  (`tpOf_eq_of_altWalkPath_of_lab_eq`), and the prototype's own atom-level agreement becomes an
  instance of a hypothesis rather than a statement of its own.
- This layer transports NO type across a change of the realized valuation, mentions no `kappa`,
  counter class or cell constancy, and is not a repair of the refuted half (ii) — the refuted
  statement is about the SPLICE, which changes which positions exist, and no hypothesis here
  constrains such a surgery.

## Follow-ups

- Phase 11.5 is the route's mathematical heart and is NOT COSTABLE: no construction for it is
  recorded anywhere in the tree, and its first task is to STATE the obligation and IDENTIFY the
  construction, with `[BLOCKED]` plus a compiled separating object as a complete and reportable
  alternative outcome.
- Phase 11.2 (the pin cascade) remains `[NOT STARTED]` and independently enterable; its single
  consumer is Phase 15.
- The `plan-fidelity` tension in Phase 11.4's task 3 (type-level vs truth-level temporal clause
  lemmas) is recorded in `issues.jsonl` and is re-openable by `/revise`.

## References

- Plan: `specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md`
- Handoff: `specs/761_ladder_realization_theorem/handoffs/phase-11.4-handoff-20261102T211915Z.md`
- Prior phase handoff: `specs/761_ladder_realization_theorem/handoffs/phase-11.3-handoff-20261102T204919Z.md`
- Presentation decision: `specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
- Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C, H4
