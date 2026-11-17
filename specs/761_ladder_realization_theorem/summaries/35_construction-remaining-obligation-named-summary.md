# Implementation Summary: Task #761

- **Task**: 761 - The ladder realization theorem (READ-OFF / CONSTRUCTION pair)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-17T04:00:00Z
- **Completed**: 2026-11-17T05:10:00Z
- **Effort**: ~1.2h (one dispatch; Phase 25 is declared NOT COSTABLE in the plan)
- **Dependencies**: None carried as `dependencies[]` edges (decision 24 forbids re-adding the 836 edge)
- **Artifacts**: plans/35_construction-over-certified-subset.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 25 of plan v35 was dispatched although its own entry gate — "ENTERED ONLY after Phase 24
lands" — is unsatisfied: Phase 24 closed with its Goal **REFUTED**, and its own Recorded Outcome
says in so many words that Phase 25 is not entered and that Phase 26 carries the route. This
dispatch therefore executed exactly the part of Phase 25's task list that is independent of the
dead route — its two entry checks, which the phase's own `Timing` paragraph names as "its first
deliverables ... reportable on their own" — and then landed as much of the phase's Goal as a
refuted lifting route permits: the remaining obligation **named** as one library object, and the
truth lemma's two **base cases**, at an arbitrary certified set and for all `φ`. The phase returns
`[PARTIAL]`, which is the outcome its `Timing` paragraph provides for.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — +212 lines, APPEND ONLY,
  `longFile` baseline raised in place from `4600` to `4800` in the same commit (4,553 → 4,765
  lines); the module was not split. Landed:
  - `ConCellEq` — **the remaining obligation, named**: a `def` (not a theorem) saying the cell of
    every world state of the constructed frame is exactly the fibre of the certified set over that
    state's key. No declaration proves any instance of it.
  - `conStruct_frame_model_key_covers` — **the instantiation check, compiled**: at an arbitrary
    certified nonempty set it produces a frame, a model, a key map and the COVERAGE conjunct, with
    no new carrier and nothing specialised to the set a subset came from.
  - `ladderConstruct_of_conCellEq` — **the reduction**: from a certified nonempty subset plus
    `ConCellEq` on it, the re-stated `(Q-2)` conclusion in full. `ConCellEq` is an EXPLICIT
    hypothesis, so this discharges no part of the pin.
  - `conModel_atom_truth`, `locPred_atom_iff`, `tpOf_atom_iff_mem_of_over_key` — **the truth
    lemma's atom clause**, definitional in the constructed valuation and matched to certificate
    condition (1) at every member over a world state's key.
  - `bot_notMem_tpOf`, `bot_notMem_clType_of_mem` — **the `⊥` clause**, on both sides.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — seven new `#print axioms` pins, all
  `[propext, Classical.choice, Quot.sound]`.
- `docs/theorem-index.md` — one new bullet in the construction-half block.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — generated inventory blocks
  regenerated through the sanctioned entry point (`check-module-invariants.sh --emit-inventory`),
  their per-module line counts having gone stale the moment the module grew.
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 24–34: the entry-gate check, the two entry checks, the named obligation, why both
  routes to it are closed, the base cases, guardrail (b) re-recorded as UNMET, the GKWZ clause
  map, the statement-fidelity diff, the carried-figure check and the gate readings.
- `specs/761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md` — Phase 25
  marked `[PARTIAL]`, its seven task items annotated (two completed, three completed-with-change,
  two NOT DONE with the refuted route named).

## Decisions

- **The phase was entered and returned `[PARTIAL]` rather than closed by exclusion.** Its target
  (`ladderConstruct` at the `(Q-2)` pin) is not refuted and stays open; only its ROUTE is dead, so
  an exclusion record would have overstated the verdict. `[PARTIAL]` is also the outcome the
  phase's own `Timing` paragraph names for "the truth lemma has not landed by the end of the first
  dispatch".
- **The entry check was done by compilation rather than by reading**, which is what the task item
  asked for but weaker than what was available. The finding is negative in the useful direction:
  no object of the carrier/frame/valuation layer had to be rebuilt.
- **No new step relation was designed.** Phase 24's re-entry record established that the
  obstruction is unremovable by shrinking the SET, so seriality must be sought in the RELATION —
  which is Phase 26's content, and Rulings 27/31's attack-before-adopt discipline forbids
  designing a relation inside an implement round.
- **`ladderConstruct` was not landed under any ad hoc witness.** The phase's own WITNESS CHECK
  demands Phase 24's elimination by name; that elimination is refuted, so no witness exists, and
  the prohibition on an ad hoc `R'` binds.

## Plan Deviations

- **Entry check 2** altered: confirmed by COMPILATION rather than by reading, and at an arbitrary
  certified nonempty subset rather than at "the eliminated subset", there being no eliminated
  subset.
- **The truth lemma** NOT DONE: its named route (dependent-choice lifting along `conStepStrong`)
  is REFUTED, not merely unfinished — `conStepStrong_serial_refuted` denies the seriality and
  `exists_certified_serial_subset_refuted` proves it unrecoverable by shrinking. The obligation
  was named and its two base cases landed instead.
- **`ladderConstruct` at the `(Q-2)` pin** NOT DONE: no witness for the existential exists, Phase
  24's elimination being refuted and an ad hoc subset prohibited. The reduction
  `ladderConstruct_of_conCellEq` landed in its place and discharges none of the pin.
- **C14 heredoc entries** not added: none owed, for the reason Phases 23 and 24 both recorded and
  this phase re-checked. `check-module-invariants.sh` reports `PASS C14` unchanged.
- **Three files outside the phase's `Files to modify` list were written**: `README.md`,
  `FormalSystem/Metalogic/README.md` and
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, whose GENERATED inventory blocks
  carry per-module line counts. Regenerated through the sanctioned entry point; the phase's own
  Verification requires that script PASS, so the alternative was a failing gate. Cross-set
  collision with task 744 (README, invariants) is left to the admission gate, as the task's FILE
  SCOPE paragraph directs.

## Verification

- Build: **Success** — `lake-build-guard.sh build --timeout 1800 -- build` exit 0, zero `error:`
  over both streams, `Build completed successfully (2976 jobs)`, and `LadderRealize.olean` newer
  than its source. `-- build BimodalTest` exit 0, zero `error:`,
  `Build completed successfully (3044 jobs)` — all seven new axiom pins pass.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots, exit 0)
- Vacuous count: **1**, the pre-existing `FormalSystem/Examples/TemporalStructures.lean:495`
  baseline; no new hit
- Axiom count: **14**, unchanged from Phase 24's re-entry reading
- `#print axioms` on every landed declaration: `[propext, Classical.choice, Quot.sound]`
- `cellAt_const_of_kappa_eq` / `ladderRealized` / `ladderConstruct` declaration greps: no hits
- `dmax_certStabK` / `dmax_certBoxK` / `dmax_certAdmK` greps: no hits — nothing stated at `Dmax`
- THE ALL-`φ` CHECK: no landed declaration carries a `BoxStabFree` binder (the two `grep` hits in
  the appended block are docstring prose, at block lines 30 and 159)
- THE GUARDRAIL CHECK: record §30 states guardrail (b) **UNMET** at the re-stated signature, in
  those terms
- Gates: `check-module-invariants.sh` exit 0, ALL CHECKS PASSED (`PASS C14`); `readme-lint.sh`
  PASS; `check-evidence-probes.sh` PASS; `verify-deploy.sh` run
- Tests: Passed (the test library is the axiom-pin harness)
- Files verified: Yes

## Impacts

- The construction half's remaining work is now **one named object** rather than four unstated
  ones: any future round proves `ConCellEq` at some certified nonempty subset and
  `ladderConstruct_of_conCellEq` closes the rest.
- The truth lemma's two base cases are available to whichever round attempts the induction, at an
  arbitrary certified set and with no `BoxStabFree` premise.
- The instantiation check retires the plan's worry that the carrier/frame/valuation layer might be
  specialised to the set a subset came from: it is not.
- Guardrail (b) stays UNMET and is re-recorded as such, so no later reader can take the
  restatement to have addressed it.

## Follow-ups

- **ROUTING: Phase 26 is the live route, not Phase 25.** Phase 24's Goal is refuted and its own
  record directs the route to Phase 26 (decision 29's pre-sanctioned fallback (A): a third step
  relation as the greatest fixpoint of the largest composing subrelation of `conStep`, ATTACKED
  for seriality at `ConAttack.attR` BEFORE adoption). The next implement dispatch should be
  Phase 26. No `user_decision` is raised: the artifacts answer the question.
- Phase 26's attack must look for seriality in the RELATION, not in the SET — Phase 24's re-entry
  proved the obstruction unremovable by shrinking. A sub-relation of `conStep` only loses edges,
  so whether a composing sub-relation stays serial at `NoElim.elimR` is the live question and is
  claimed neither way here.
- The `→`, `□`, `⊡`, `▷` and `◁` clauses of the truth lemma remain unattempted. The `□` and `⊡`
  clauses match conditions (6) and (5) structurally (their `PlusTruthAt` clauses are a universal
  over all histories and over histories through the same world state) and need only the induction
  hypothesis; the `▷`/`◁` clauses need the refuted lifting.
- Phase 20's READ-OFF half still waits on the construction's output (decision 27, unrevoked).

## References

- `specs/761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md` — Phase 25
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 24–34 (this dispatch), 17–22 (Phase 24's refutation this dispatch's gate check reads)
- `specs/761_ladder_realization_theorem/summaries/35_elimination-lemma-refuted-summary.md`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — the landed objects
- `docs/theorem-index.md` — the new construction-half bullet
