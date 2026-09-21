# Implementation Summary: Task #568

- **Task**: 568 - C3/C4 consequence relations as library definitions
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T21:16:02Z
- **Completed**: 2026-09-21T22:07:22Z
- **Effort**: under one hour of agent wall-clock time against an 18.5-hour estimate
- **Dependencies**: None
- **Artifacts**: plans/01_c3-c4-library-definitions.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

C3 and C4 — the paper's footnoted convex-index alternative to `def:logical-consequence`, and its
restriction to interval indices — are now definitions the library has: a truth recursion
`TruthAtConvex` written beside `TruthAt`, the validity and consequence notions over it, the germ
theorems, shift invariance, the C1/C3/C4 separations, and the axiom-survival table as one theorem
per row and once over all 29 `Axiom` constructors. All ten plan phases closed; all 50 pinned
challenge statements are proved sorry-free. C1 (`Truth.lean`, `Validity.lean`) has an empty diff.

## What Changed

- `FormalSystem/Semantics/ConvexTruth.lean` — new. `TruthAtConvex`, `ValidC3`, `IsInterval`,
  `ValidC4`, `ValidC3In`, `ValidC4In`, `ConsequenceC3`, `ConsequenceC4`; clause lemmas under
  `TruthAtConvex.*`; `IsInterval.isConvex`, `PartialHistory.point_isConvex`;
  `validC3_imp_validC4`, `truthC3_box_indep`, `germ_untl_false`, `germ_snce_false`,
  `c3_box_untl_unsat`, `c3_box_snce_unsat`, `c3_nec`, `c3_valid_imp_germ_valid`,
  `truthC3_timeShift`, `c3_box_time_uniform`. Docstring quotes the footnote, retires C2 by the
  index type, and records the box-range working default.
- `FormalSystem/Semantics/ConvexTruthCut.lean` — new. `TruthAtConvexCut`, the named alternative.
- `FormalSystem/Metalogic/ConvexConsequence.lean` — new aggregator, plus directory `README.md`.
- `.../ConvexConsequence/Separations.lean` — new. Fixtures `NF`, `bdd`, `bdd01`, `totalNF`;
  `valid_C1_someFuture_top`, `refute_C3_someFuture_top`, `refute_C3_somePast_top`,
  `refute_C4_someFuture_top`, `lastPoint`, `validC4_lastPoint`, `refute_C3_lastPoint`.
- `.../ConvexConsequence/AxiomSurvival.lean` — new. 21 survival rows and the six refutations.
- `.../ConvexConsequence/FrameClassSurvival.lean` — new. `c3_prior_UZ`, `c3_z1`, `c3_density`,
  `c3_dense_indicator`, `c3_prior_U_gap`, `c3_sep`, six `ValidC3In` corollaries.
- `.../ConvexConsequence/Mirrors.lean` — new. Ten base mirrors; `c3_prior_SZ`, `c3_prior_S_gap`,
  `c3_sep_mirror`.
- `.../ConvexConsequence/SurvivalTable.lean` — new. `Axiom.failsC3`, `c3_survival_table`,
  `c3_failure_table` (29 named cases each, no wildcard).
- `.../ConvexConsequence/CutContrast.lean` — new. `truthCut_box_someFuture_top`.
- `Tests/BimodalTest/Semantics/ConvexTruthTest.lean` — new. Ten measured axiom-profile pins.
- Edited: `FormalSystem.lean` (regenerated), `FormalSystem/Semantics.lean`,
  `FormalSystem/Metalogic.lean`, `Tests/BimodalTest.lean`,
  `FormalSystem/Semantics/PartialHistory.lean` (two docstrings only), five existing READMEs,
  `docs/reference/paper-definitions-of-record.md`.

### The four gaps, and the fifth

Every verdict the source table left open is SURVIVES: `discrete_propagate_bwd` (every frame),
`z1` (ℤ-time), `prior_U_gap` (complete frames, no density), `sep` (ℝ-time), and `prior_S_gap`
(complete frames, no density) — the last never checked anywhere before this task. No argued-only
row turned out false; the escalate-if-false rule was never triggered.

## Decisions

- Box range: the footnote's own reading is primary; the cut-back variant is a named definition
  with one contrast theorem and no second table. This is the task's working default, recorded in
  both module docstrings as revisable by the author before any completeness sequel.
- No docstring identifies the C3 validities with a known axiomatic system.
- `gapFwd` / `gapBwd` are `abbrev`s in `AxiomSurvival.lean`; `c3_dense_indicator` spells the
  formula out because its file does not import that module.
- `c3_failure_table` was added beside the planned survival half so `Axiom.failsC3` is a verdict
  in both directions.

## Plan Deviations

- **Phase 3 (README rows)** altered: the README rows Phase 10 lists were brought forward and
  maintained phase by phase, because the module-invariant gate failed `INV` on the missing
  `ConvexTruth.lean` row as soon as Phase 1 landed. No `.lean` content affected.
- **Phase 4 (scope count)**: the plan's "15 survival theorems" was a miscount; 14 land there.
- **Phase 9 (contrast theorem placement)**: placed in its own cluster file `CutContrast.lean`,
  which the plan permitted but did not list under Files to modify.

## Verification

- Build: Success. Full `lake build` through the guard, detached: 2683 jobs, exit 0, zero
  warnings. Test library `lake build BimodalTest`: 2740 jobs, exit 0.
- Sorry count: 0 (`FormalSystem/` and `Tests/`)
- Vacuous count: 1, unchanged from the pre-task baseline (the one hit is
  `Examples/TemporalStructures.lean`, untouched). A second hit this task briefly introduced
  (`totalNF_mem := trivial`) was caught by the gate and re-proved from totality.
- Axiom count: 12, unchanged from the pre-task baseline
- Tests: the new axiom-profile module compiles, so its ten pins hold. The test build also prints
  `FAIL:` lines from `Automation/ProofSearchTest.lean`: that module's informational proof-search
  coverage report, not a build failure; nothing it depends on changed here beyond a docstring.
- Gates: `scripts/check-module-invariants.sh` (full, with build) ALL CHECKS PASSED;
  `readme-lint.sh` PASS; `check-copyright-headers.sh` clean; `check-paper-definitions.sh` pass.
- Pinned statements: 50 of 50 present; 48 verbatim; `validC4_lastPoint` differs by an explicit
  `{F : TaskFrame}` binder; `c3_dense_indicator` spells `gapFwd` out.
- Mirror fidelity: all twelve surviving mirrors unify with their `DerivedAxioms` / `Combinators`
  derivations' formulas under `with_reducible`; the Sep mirror is the `reflectTime` of `sep`.
- `lean_verify` on `c3_sep`, `c3_z1`, `c3_prior_U_gap`: `propext`, `Classical.choice`,
  `Quot.sound`; `c3_prior_S_gap` and `truthC3_timeShift` the same by `#print axioms`.
- C1 untouched: `git diff` over `Truth.lean` and `Validity.lean` is empty.
- Plan compliance: passed. Files verified: Yes.

## Impacts

- A completeness sequel for C3 now has its semantic side fixed: 25 surviving constructors, 4
  failing, with the box-range default on the record.
- `PartialHistory.IsConvex` now has a consumer; the two docstrings that said otherwise are
  corrected.
- `Axiom` gains a second exhaustive `cases` consumer: a new constructor breaks
  `SurvivalTable.lean` until its C3 verdict is supplied.

## Follow-ups

- The author may override the box-range default; doing so before the sequel starts is what the
  task description asks for.
- The Lean challenge snapshot was not taken in this dispatch. The plan records that the tool
  exits 71 in the ambient locale and must be run under `LC_ALL=C`.
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` reports 12 of 42 proof-search cases
  unmatched (the derived `temp_*` rows). Pre-existing and out of scope, but visible in every
  test build.

## References

- `specs/568_c3_c4_consequence_relations_as_library_definitions/plans/01_c3-c4-library-definitions.md`
- `specs/568_c3_c4_consequence_relations_as_library_definitions/reports/01_c3-c4-library-definitions.md`
- `specs/568_c3_c4_consequence_relations_as_library_definitions/probes/01_gap-closures.lean`
- `specs/archive/553_decide_convex_history_layer_collapse/probes/02_alternative-consequence.lean`
- `specs/archive/553_decide_convex_history_layer_collapse/probes/03_axiom-survival.lean`
