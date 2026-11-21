# Implementation Summary: Task #942

- **Task**: 942 - Add regression test coverage for three FormalSystem module groups that currently have none
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T21:33:34Z
- **Completed**: 2026-11-19T22:10:00Z
- **Effort**: ~0.6 hours
- **Dependencies**: None
- **Artifacts**: plans/01_test-coverage-nomic-formathlib-tactic.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Three `FormalSystem` module groups had zero referencing tests anywhere under `Tests/`. All three
gaps are closed: `NomicLanguage/` by a new four-section regression module, `ForMathlib/` by a new
isolated-import smoke module, and `Tactic/` by two small folds into existing `Automation/` tests.
Nothing under `FormalSystem/` was touched, no new theorem was proved, and `lake build`,
`lake build BimodalTest` and `lake test` are all green at the repository's zero warning budget.

## What Changed

- `Tests/BimodalTest/Semantics/NomicLanguageTest.lean` — NEW (175 lines). Group (A), the Medium
  finding. Four sections: `NomicFormula` syntax with `DecidableEq` `#guard`s, three `ofFormula`
  constructor pins and an application of `ofFormula_injective`; the `Iff.rfl`-shaped clause lemmas
  `NomicTruth.nomic_iff`/`box_iff`/`always_iff`/`diamond_iff` applied at an arbitrary
  `NomicFrame D`; a concrete `NomicModel` over `NomicHierarchy.F3` with truth evaluated both ways,
  `Semantics.nomic_serial` instantiated under a `haveI` regularity instance, axiom 4's failure via
  `Semantics.four_validOn_iff_uniform` plus `F3.not_uniform`, and a `TenseFree` negative; and seven
  `#guard_msgs`-gated `#print axioms` profile pins. Placed beside `OpenLanguageAxiomTest.lean`
  rather than in a new per-language directory, because the tree has no per-language test directory.
- `Tests/BimodalTest/ForMathlib/SmokeTest.lean` — NEW (141 lines, exactly one `import`). Group (B).
  45 `#check`s covering every public declaration of all five `ForMathlib` files, plus seven
  instantiating `example`s: `Order.IsNest ({Set.univ} : Set (Set ℕ))` and
  `IsNest.exists_subset_inter`; `isProper_iff_bot_notMem` and `PrimeFilter.mem_iff`;
  `(⊥ : SimpleGraph ℕ).IsAcyclic` via `isAcyclic_of_rank_parent`;
  `Nat.exists_strictMono_const_pair_colour` at `C := Bool`; and both `Sierpinski` headline results
  on a constant `ℝ → Bool`.
- `Tests/BimodalTest/Automation/NormalizationTest.lean` — group (C.1): a new
  `AttrSimpSetTests` section with the two `example`s covering `Tactic/Attr.lean`'s remaining simp
  sets, `truth_norm` and `reflect_time_norm`, each closed by that set alone. No import change;
  `open FormalSystem.Semantics` is scoped to the new section.
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` — group (C.2): a new `MetaHelperProbes` section.
  `#check`s all five `Tactic/Meta.lean` helpers, then a positive `TermElabM` block that elaborates
  `DerivationTree FrameClass.Base ([] : Context) (p.imp p)` and asserts `extractDerivationGoal`,
  `isNilContext`, `formulaHead` and `lemmaConclusionHead` each read what they should, plus a
  negative `MetaM` block asserting both recognisers reject `mkConst ``Nat`. No import change.
- `Tests/BimodalTest.lean` — two added `import` lines.
- `Tests/BimodalTest/Semantics/README.md`, `Tests/BimodalTest/Automation/README.md`,
  `Tests/BimodalTest/ForMathlib/README.md` (NEW), `Tests/BimodalTest/README.md` — Contents rows,
  Coverage bullets and Last Updated stamps brought in step.
- `typst/generated/status.typ` — regenerated once per phase: `tests-file-count` 83 -> 85,
  `tests-line-count` 28615 -> 29020.

## Decisions

- **`buildContextExpr` is `#check`ed and never applied.** This discharges the recorded prior
  decision (route (b): keep scope, file the repair separately). A probe that invoked it could not
  pass, and one written to expect the throw would launder the defect as intended behaviour. The
  defect is named in `LemmaDBTest.lean` by durable anchor, with no task number.
- **`Tests/BimodalTest/Automation/TacticsTest.lean` was never opened**, keeping this task disjoint
  from the open task that names it for prose-only work.
- **The `MetaM` helpers are covered by executed `#eval` probes, not signature pins alone.** A
  `MetaM` helper's failure is a runtime failure of the elaborator, never a compile error, so these
  helpers can be broken while the whole project builds clean — which is exactly how
  `buildContextExpr` went undetected. That reasoning is recorded in the new section's docstring.
- **Group (C) was scoped to the genuinely uncovered declarations.** `formula_unfold`/`formula_fold`
  and the `tmLemma` label were already exercised; re-covering them would be the "raising coverage
  of modules that already have tests" the task excludes.

## Plan Deviations

- **Phase 3, "Note the two new `Automation/` folds ... if its Contents table ... describes per-file
  content at that granularity"** — altered. It does, so the `NormalizationTest.lean` row was
  updated and a `LemmaDBTest.lean` row added (that file had no row, and the `Tactic/Meta.lean` fold
  lives there). Additionally `Tests/BimodalTest/README.md` gained a `ForMathlib/` bullet, one README
  beyond the three the task list names: a brand-new top-level test directory absent from the parent
  organization list is the drift this phase's Goal names. Both edits reuse existing shapes.
- **Testing & Validation, `bash scripts/verify-all.sh`** — deferred. This dispatch carried a Batch
  Gate Deferral directive, so the complete gate set runs once for the whole batch at the
  orchestration close and is attributed back by this task's `modified_files`. Discharged in-dispatch
  by `bash .claude/scripts/verify-touched.sh` instead.
- **Both new modules overran their line-count hypotheses** (175 vs ~115; 141 vs ~70). The content is
  exactly what the task lists name; Phase 2's overrun is the literal "a `#check` per public
  declaration" instruction meeting `Order/PFilter.lean`'s 31 public declarations. Both phases'
  Scope-Hypothesis confirmation criteria held.

## Verification

- Build: Success — guarded `lake build` (default `FormalSystem` target) exit 0 / 2991 jobs;
  guarded `lake build BimodalTest` exit 0 / 3062 jobs; guarded `lake test` exit 0. Zero `error:`
  and zero `warning:` lines across all three, and the `.olean` for each of the four touched modules
  is newer than its source.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots, empty inventory)
- Vacuous count: 0
- Axiom count: 14 over the resolved roots, unchanged — the four touched test files declare zero
  `axiom`s.
- Tests: Passed (`lake test`, `testDriver = "BimodalTest"`)
- `scripts/check-module-invariants.sh` (full mode): exit 0, ALL CHECKS PASSED. C6 PASS for both new
  modules; no verdict drift against the Phase 1 pre-task baseline.
- `scripts/check-module-invariants.sh --emit-inventory --check`: exit 0 — the generated inventory
  blocks did not move, confirming the plan's measured surface split (count surface in play,
  inventory blocks not).
- `scripts/typst-sync-check.sh --counts-only`: exit 0, `MISMATCH_COUNT=0`.
- `scripts/check-copyright-headers.sh --strict Tests`: exit 0, 85 files, 0 nonconforming / 0 missing.
- `lake exe runLinter BimodalTest`: no row for `BimodalTest.Semantics.NomicLanguageTest` or
  `BimodalTest.ForMathlib.SmokeTest`; total finding count unchanged from the pre-task baseline
  (both modules' `docBlame` ceiling is 0, and every new public declaration carries a docstring).
- `bash .claude/scripts/verify-touched.sh`: exit 1 with 11 failing `.claude/scripts/tests` suites,
  recorded as a PASS under `plan-authoring-gate-collisions.md` Condition 4. Every one fails on a
  missing LOCAL source store (`agent-system/extensions does not exist`); this repository has no
  `agent-system/` directory, and `.claude-extensions.json` resolves every `source_dir` to
  `~/.config/nvim/agent-system/extensions/*`. They fail unconditionally here regardless of any
  task, and none of the 11 references `Tests/`, `typst/` or `FormalSystem/`. Full enumeration in
  Phase 3's Verification Notes.
- **Group-closure grep, the task's own acceptance bar**: `NomicLanguage`, `ForMathlib` and
  `FormalSystem.Tactic` are each referenced from at least one `.lean` file under `Tests/` — five
  files total. All three gaps are closed.
- Files verified: Yes. `git status --short` at task close names no path under `FormalSystem/` and
  does not name `Tests/BimodalTest/Automation/TacticsTest.lean`.

## Impacts

- A refactor of `FormalSystem/NomicLanguage/`'s formula type, truth clauses or validity definitions
  now breaks a test rather than passing silently, and seven of that component's choice-dependence
  claims — previously asserted only in module docstring prose — are now compiler-checked.
- Each `ForMathlib` upstream-PR candidate is now verifiable in isolation: a reviewer can see that
  all five files stand up under `import FormalSystem.ForMathlib` alone, with no project-tree
  dependency.
- `Tactic/Attr.lean`'s four simp sets and `Tactic/Meta.lean`'s four working helpers are covered,
  the latter by executed probes rather than signature pins.
- Nothing downstream can depend on any of this: every edit is additive and confined to `Tests/`
  plus the regenerated count surface.

## Follow-ups

- **`FormalSystem/Tactic/Meta.lean`'s `buildContextExpr` is broken and needs its own task** (the
  recorded prior decision's route (b); this task did NOT create it and did NOT apply the repair).
  The defect: `buildContextExpr` calls `mkAppM ``List.nil`` with an explicit argument for
  `List.nil`'s *implicit* type parameter, so it raises `too many explicit arguments provided to
  @List.nil` on every input, including the empty list. It hard-fails `modal_search` on any
  box-headed goal. **Two repairs were already compiled during research and both round-trip** (the
  non-empty case too):
  - `mkAppOptM ``List.nil`` #[some formulaType]`, or
  - `Lean.mkApp (Lean.mkConst ``List.nil`` [Level.zero]) formulaType`.

  Both produce `[] : List Formula` and are accepted by `isNilContext`. The two call sites are in
  `FormalSystem/Automation/Tactics/Search.lean`: `tryModalK` and `tryTemporalK`, **both outside
  their `observing?` block**, so the exception propagates rather than being swallowed — which is
  why the failure is user-visible rather than a silent fallback.
- **`verify-touched.sh`'s 11 source-store suites should SKIP, not FAIL, in a deploy-only
  repository.** As written they fail unconditionally wherever the resolved `source_dir` lies
  outside the repository, so every Lean-side dispatch here pays the same triage to establish
  non-attribution.
- **A plan sizing a `ForMathlib`-style smoke module should count the target files' public
  declarations, not their file count.** "One smoke check per file" and "a `#check` per public
  declaration" differ by a factor of nine on `Order/PFilter.lean` alone.

## References

- `specs/942_test_coverage_nomic_formathlib_tactic/plans/01_test-coverage-nomic-formathlib-tactic.md`
- `specs/942_test_coverage_nomic_formathlib_tactic/reports/01_test-coverage-nomic-formathlib-tactic.md`
- `specs/942_test_coverage_nomic_formathlib_tactic/handoffs/` — per-phase handoffs with the
  measured gate baselines
- `specs/942_test_coverage_nomic_formathlib_tactic/issues.jsonl` — issues and wins recorded as they arose
- `specs/reviews/review-2026-11-19.md` — source of record for the three findings
- `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` — the semantic-only-component test
  precedent the new NomicLanguage module follows
