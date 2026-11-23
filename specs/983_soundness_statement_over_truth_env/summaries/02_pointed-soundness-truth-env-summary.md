# Implementation Summary: Task #983

- **Task**: 983 - State pointed soundness once over TruthEnv (milestone D4)
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T20:28:10Z
- **Completed**: 2026-11-23T20:52:00Z
- **Effort**: about 1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_pointed-soundness-truth-env.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

TM⋆ now has a context form of soundness, `star_soundness_in`, beside `star_soundness_validIn`. Pointed soundness is stated once over `TruthEnv` in a new layer-3 module: the `Prop`-valued mixin class `PointedSound L D`, instances at TM, TM⁺ and TM⋆, and the generic theorem `truth_of_derivation`. Tests instantiate the generic theorem at all three languages. All four D4 done-when checks hold.

## What Changed

- `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` — new theorem `star_soundness_in` (signature as in the plan's Lean Challenge Statements; proof by `induction d generalizing τ t`, seven arms, one fixed register environment `v`); "Main Results" bullet. Axioms: `[propext, Classical.choice, Quot.sound]`.
- `FormalSystem/Metalogic/PointedSoundness.lean` — created: `assert_not_exists` guard on the four `completeness_*` theorems, class `PointedSound`, three instances (each a one-line application of `soundness_in`, `plus_soundness_in`, `star_soundness_in`), `truth_of_derivation` with the environment explicit. Imports exactly the three soundness modules. `truth_of_derivation` axioms: `[propext]`.
- `Tests/BimodalTest/Metalogic/PointedSoundnessTest.lean` — created: five examples (one per language from an abstract tree; a TM⋆ register axiom at a point; a TM⋆ two-premise modus ponens).
- `FormalSystem.lean`, `FormalSystem/Metalogic.lean`, `Tests/BimodalTest.lean` — imports; a docstring section in the `Metalogic` aggregator.
- `FormalSystem/Metalogic/Conservativity/Star/README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md`, `typst/generated/status.typ` — regenerated inventories and counts; one hand-written results bullet and one module description.

## Decisions

- No `docs/theorem-index.md` rows were added. Every row on that page must be axiom-pinned in the C14 baseline pair inside `scripts/check-module-invariants.sh`, which is outside the plan's file list and the task's file_scope; the neighbouring context forms `soundness_in` and `plus_soundness_in` carry no row. The plan's fallback ("follow the file") was applied. Consequently no allowlist entry was needed either.
- The two-element-context premise in the tests uses `List.mem_pair` instead of `simp at`, which trips the flexible-tactic linter.
- A full guarded `lake build` was run at each phase end as well as the plan's scoped builds; it costs about four minutes after a `StarSoundness` edit and seconds otherwise.

## Plan Deviations

- **Phase 1, theorem-index row** skipped: a row requires a C14 pin in a script outside scope; file convention followed.
- **Phase 1, regeneration** altered: `--emit-inventory` also rewrote `FormalSystem/Metalogic/Conservativity/Star/README.md` (in file_scope); a `star_soundness_in` bullet was added to its results list.
- **Phase 2, theorem-index rows and allowlist entry** skipped: same cause; the plan's own conditional (no row, no dotted name in markdown, no allowlist entry) applies.
- **Phase 2, regeneration** altered: `--emit-inventory` also rewrote `FormalSystem/README.md`; the generated `PointedSoundness.lean` inventory row received a description in place of its TODO placeholder.
- **Phase 4, aggregator build** altered: built `FormalSystem BimodalTest` plus the default full build, a superset of the planned targets.
- **Artifact number**: this summary is `02_` per the dispatch's artifact round, not the `01_` the plan's Artifacts section names.

## Verification

- Build: Success (full guarded `lake build`, exit 0, zero errors, zero warnings; `lake build FormalSystem BimodalTest` also green; `.olean` newer than source for all three touched modules)
- Sorry count: 0
- Vacuous count: 0 in touched files (the grep reports 2 hits tree-wide, both in files this task did not touch: `FormalSystem/Semantics/PointTransport.lean:163`, `FormalSystem/Examples/TemporalStructures.lean:495`)
- Axiom count: 14 `^axiom` lines, unchanged from the pre-task commit
- Tests: Passed (`BimodalTest.Metalogic.PointedSoundnessTest` builds; at least one example per language)
- Files verified: Yes
- Repository gates: `check-module-invariants.sh --no-build` ALL CHECKS PASSED; `check-metalogic-cycles.sh` exit 0; `--emit-inventory --check` PASS; `mk_all --lib FormalSystem --check` exit 0; `typst-sync-check.sh --counts-only` exit 0; `check-copyright-headers.sh` missing 0 of 792.
- Plan compliance spot-check: passed.
- Deferred: the complete gate set is deferred to the orchestration batch stage and was not run here. `verify-touched.sh` selected a 119-suite agent-system fallback for uncommitted specs plan files, did not finish inside a 400 s bound and was stopped; it produced no verdict.
- D4 done-when: (a) `star_soundness_in` sits directly after `star_soundness_validIn`; (b) `PointedSound` has instances at all three languages; (c) the language theorems are named in `PointedSoundness.lean` only in the three instance bodies and in docstrings; (d) no import under `FormalSystem/Automation/ProofMode/`, and the guard elaborates.

## Impacts

- C4 (the semantic mode's adapter) can consume `truth_of_derivation` with `[PointedSound L D]`; no per-language wrapper is needed.
- `proof_mode_abstract_frontend_interface` can require `[PointedSound L D]` of its own derivation relation; the class owns no data.

## Follow-ups

- If `star_soundness_in` and `truth_of_derivation` should appear in `docs/theorem-index.md`, add them together with their C14 pins in `scripts/check-module-invariants.sh` (and a C5 allowlist entry if the class is given a row). `PointedSound` itself reports `[propext]`, so it is pinnable.

## References

- `specs/983_soundness_statement_over_truth_env/plans/01_pointed-soundness-truth-env.md`
- `specs/983_soundness_statement_over_truth_env/reports/01_pointed-soundness-truth-env.md`
- `records/milestones.md` (D4, join 7), `records/proof-mode-architecture.md`
