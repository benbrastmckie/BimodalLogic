# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem (the READ-OFF / CONSTRUCTION pair)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-17T10:39:11Z
- **Completed**: 2026-11-17T11:20:00Z
- **Effort**: one dispatch (phase 24 re-entry; the phase is declared NOT COSTABLE and is excluded from the plan's costable total)
- **Dependencies**: Phase 23 (outcome (a), its entry gate); Phase 24's own first dispatch (the reduction it closes)
- **Artifacts**: plans/35_construction-over-certified-subset.md, records/round-35-construction-over-certified-subset.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 24 was re-entered at its one remaining step — produce a certified nonempty subset of an
arbitrary certified set on which every key carries one member — and that step is now **REFUTED by
compilation**, together with the phase's own Goal. The route was attacked before it was attempted,
per this task's standing attack-first discipline (decisions 21-23, 27, 29), and the attack
succeeded on the first fixture design.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — a new section
  (728 lines, appended; `longFile` baseline raised in place 3900 → 4600, file now 4,553 lines):
  - `not_keyFibreInj_of_noncollapsed` — **the general obstruction**, at an arbitrary certified set:
    a member carrying a `⊡` letter's ARGUMENT without the letter itself cannot sit in a
    key-injective certified set. No fixture, no `ParamsOk`, no finiteness instance consumed.
  - `NoElim` — a **certified** fixture whose every member has that shape: three object states in a
    star, two members over each key carrying the two `untl` letters `ρ = g₁ U e₁` and
    `σ = g₂ U e₂`, formula `⊡ρ → ⊡σ`. All six `certAdmK` conditions discharged by name
    (`elim_certLocK`, `elim_certBiInfK`, `elim_certFwdK`, `elim_certBwdK`, `elim_certStabK`,
    `elim_certBoxK`, assembled as `elim_certAdmK`), at a closure that **does** bear `⊡` letters
    (`stab_closure_E` is the non-vacuity guard). Every member is non-collapsed
    (`noncollapsed_mem`).
  - `NoElim.no_keyFibreInj_subset`, `NoElim.both_mem_subset`, `NoElim.not_serial_subset` — every
    certified nonempty subset of the fixture fails key-injectivity, must keep BOTH members over
    the state-`0` key, and carries no `conStepStrong` seriality.
  - `exists_certified_keyFibreInj_subset_refuted` — the reduction's remaining positive side is
    FALSE.
  - `exists_certified_serial_subset_refuted` — **Phase 24's own Goal, as recorded before any Lean
    was written (record §9.1), is FALSE.**
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — eight `#guard_msgs` axiom pins
  (`longFile` 4200 → 4300, file now 4,200 lines).
- `docs/theorem-index.md` — one new bullet for the refutation, and the preceding bullet's
  "what this does not establish" sentence re-pointed at it so the document states one current
  reading.
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 17-22: the posture, the verdict table, the six-condition check (answered with six
  declarations this time), statement fidelity, scope and branch, and the carried-figure check.
- `specs/761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md` — Phase 24
  closed `[COMPLETED WITH EXCLUSIONS]` with a re-entry `#### Recorded Outcome` and a
  `#### Reasoned Exclusions` record; two task items re-annotated.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `typst/generated/status.typ` —
  regenerated line counts through their sanctioned entry points.

## Decisions

- **Attack before attempt.** The remaining step was attacked rather than attempted, because every
  hypothesis adopted in this task without a prior attack turned out refuted while both rounds that
  attacked first produced survivors. The fixture was derived on paper from the conditions' own
  shapes before any Lean was written; all eight claimed `relK` edges, all eight claimed non-edges,
  `locCoh` at all six members and the `RK` self-loop compiled green on the first attempt.
- **Two `⊡` letters, not one.** With a single `⊡` letter the non-collapsed shape is unreachable:
  condition (5) forces the letter onto every member of a fibre all of whose members carry its
  argument. The two free letters are an `untl` pair because that is the only arm that may differ
  between two members over ONE key — atoms are pinned by condition (1), `⊡` letters per key by
  condition (5), `□` letters globally by condition (6).
- **No `user_decision`.** Decision 29 already names the sanctioned fallback (option (A), Phase 26's
  third step relation, attacked for seriality before adoption), which is not `conStepStrong` and is
  untouched by this refutation.

## Plan Deviations

- **Phase 24, "prove `certAdmK` of the fixpoint"**: excluded — there is no fixpoint and there
  cannot be one; the six conditions are discharged on the refuting fixture instead (record §19).
- **Phase 24, "prove nonemptiness of the fixpoint, or record the compiled counterexample"**:
  completed in the second branch the item itself provides for — the compiled counterexample.
- **Files**: `scripts/check-module-invariants.sh` not edited (no C14 entry owed, re-checked); three
  generated READMEs and `typst/generated/status.typ` written although not in the phase's file list,
  through their sanctioned regeneration entry points, because the repository's own gates require
  them to match a live regeneration.

## Verification

- Build: Success — `lake build` through `lake-build-guard.sh`, exit 0,
  `Build completed successfully (2976 jobs)`, zero `error:` over both captured streams, and the
  touched module's `.olean` (epoch 1794913005) newer than its source (1794912991).
  `lake build BimodalTest` exit 0, `Build completed successfully (3044 jobs)` — the eight axiom
  pins are inside it.
- Sorry count: 0
- Vacuous count: 1 — the pre-existing `FormalSystem/Examples/TemporalStructures.lean:495` baseline,
  unchanged by this dispatch
- Axiom count: 14, unchanged; zero `+axiom ` lines in this dispatch's diff; every landed
  declaration reports `[propext, Classical.choice, Quot.sound]`
- Tests: Passed — `check-module-invariants.sh` PASS with zero FAIL groups (`PASS C14`, `PASS C23`
  all three assertions); `readme-lint.sh` PASS; `check-evidence-probes.sh` reading recorded in the
  record's gate table
- Files verified: Yes

## Impacts

- Route (Q-2)'s elimination does not close, which is one of the two outcomes the `(Q-2)` sub-block
  named in advance. Phase 25 is not entered (its gate is "after Phase 24 lands"); Phase 26's
  fallback (A) carries the route.
- For that round: the obstruction is now known to be unremovable by SHRINKING at all, so a third
  step relation must find its seriality in the relation rather than in the set.
- `ladderConstruct` at its `(Q-2)` signature is **not** refuted and stays OPEN — it mentions
  neither key-injectivity nor `conStepStrong`. `ladderRealized` and `cellAt_const_of_kappa_eq`
  stay refuted under their pinned names and are declared nowhere.
- Guardrail (b) — infinite width — stays **UNMET** and is not addressed, narrowed or reported as
  met.

## Follow-ups

- Phase 26 (fallback (A)): the third step relation as the greatest fixpoint of the largest
  composing subrelation of `conStep`, attacked for seriality at `ConAttack.attR` before adoption.
- One **INFERRED, not compiled** consequence worth stating in Phase 25 or 26 if wanted: since every
  certified nonempty subset of the fixture keeps two members with distinct closure types over one
  key, any model satisfying the `(Q-2)` equation there has a cell with two types and so cannot be a
  two-sided deterministic frame of the sliced scheme (`fibre_subsingleton_of_det_cell_eq`,
  contrapositive).
- The task description's line "the construction half is UNWRITTEN in all four of its components"
  remains stale (carrier, frame and valuation landed in Phase 21; only the truth lemma is
  unwritten). `docs/theorem-index.md` carries the corrected reading.

## References

- `specs/761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md` — Phase 24
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 9-14 (the reduction) and 17-22 (this refutation)
- `specs/761_ladder_realization_theorem/summaries/35_elimination-reduced-to-key-injectivity-summary.md`
- `specs/761_ladder_realization_theorem/summaries/35_elimination-attacked-at-fixture-summary.md`
- `docs/theorem-index.md` — the two bullets on the elimination
