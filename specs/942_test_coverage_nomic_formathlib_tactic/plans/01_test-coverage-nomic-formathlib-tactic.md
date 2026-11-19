# Implementation Plan: Task #942

- **Task**: 942 - Add regression test coverage for three FormalSystem module groups that currently have none
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None (territory overlap with open task 177 on `TacticsTest.lean` is avoided outright -- see Decisions)
- **Research Inputs**: specs/942_test_coverage_nomic_formathlib_tactic/reports/01_test-coverage-nomic-formathlib-tactic.md
- **Artifacts**: plans/01_test-coverage-nomic-formathlib-tactic.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/standards/tasks.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Three `FormalSystem` module groups have zero referencing tests anywhere under `Tests/`:
`NomicLanguage/` (Medium), `ForMathlib/` (Low) and `Tactic/` (Low). This plan closes each gap
with the smallest artifact the existing test tree admits -- one new module per gap for the first
two, two small folds into existing `Automation/` tests for the third -- and changes nothing under
`FormalSystem/`. Done means: `lake build` and the `BimodalTest` test target both green at the
repository's zero warning budget, and a grep confirming each of `NomicLanguage`, `ForMathlib` and
`Tactic` is referenced from at least one file under `Tests/`.

### Research Integration

Every artifact this plan schedules was compiled against the current tree by the research dispatch
before being written down, so the phase bodies below carry measured inputs rather than guesses:

- **Both suggested extension points for group (A) are structurally unavailable.**
  `ValidityLayerTest.lean` pins a defeq between a language's validity `def` and the generic
  `PointTruth`/`TaskFrame` layer; `NomicTruth.lean`'s own "Why the clause layer is duplicated
  rather than instantiated" section records that `TruthEnv.T`'s `WorldHistory F` binder cannot be
  met for a non-uniform nomic frame, so that defeq does not exist to be pinned.
  `LanguageDerivationTest.lean` builds `DerivationTree` terms, and `NomicLanguage` has no proof
  system. A new module is the only route.
- **The seven axiom profiles group (A) pins were read off `#print axioms`**, not predicted:
  `[propext]` for `NomicLanguage.ofFormula_injective`, `NomicLanguage.nomic_iff_box_of_uniform`
  and `Semantics.nomicValidOn_nomic_iff_box_of_uniform`;
  `[propext, Classical.choice, Quot.sound]` for `Semantics.nomic_serial`,
  `Semantics.four_validOn_iff_uniform`, `Semantics.not_four_nomicValid` and
  `NomicLanguage.tenseFree_satSet_iff`.
- **Group (C) is narrower than the review states.** `NormalizationTest.lean` already exercises
  `formula_unfold`/`formula_fold` and `LemmaDBTest.lean` already reads `` Lean.labelled `tmLemma ``,
  so only `truth_norm`, `reflect_time_norm` and `Tactic/Meta.lean`'s five helpers are genuinely
  uncovered. Re-covering the other three would be the "raising coverage of modules that already
  have tests" the task excludes.
- **`buildContextExpr` throws on every call** (`mkAppM `` `List.nil `` with an explicit argument
  for an implicit parameter), hard-failing `modal_search` on any box-headed goal. Repairing it
  edits a `FormalSystem` declaration, which this task places out of scope; group (C) therefore
  probes it with `#check` only (see Decisions and Risks).
- **Three repository gates will bite a careless implementation**: C6 (a test module absent from
  `Tests/BimodalTest.lean` is an unreachable-module failure), C16's `docBlame` ceiling (a new
  module has no row in `scripts/c16-roots-baseline.txt`, so its ceiling is 0), and the zero
  warning budget under CI's `--wfail`.
- **A fourth gate, measured during plan authoring rather than taken from the research report:
  the generated count surface IS in play for a `Tests/`-only change.**
  `scripts/typst-status-counts.sh` derives `tests-file-count` and `tests-line-count` in
  `typst/generated/status.typ` by counting `.lean` files and lines under `Tests/` recursively, and
  `.githooks/pre-commit` BLOCKS any commit staging a `.lean` path while that file has drifted.
  Every phase here adds Lean lines under `Tests/`, so every phase regenerates and stages
  `typst/generated/status.typ` with its own commit. This corrects an initial reading that looked
  only at `scripts/typst-sync-check.sh`'s `LEAN_SRC_ROOTS` (which governs declaration scanning,
  `FormalSystem/` + `BimodalTools/`, and is a different mechanism from the count fields).

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap flag is set, so no roadmap
consultation was performed and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:

- Close the NomicLanguage coverage gap with a dedicated test module placed where the tree's
  existing per-language tests live, exercising formula syntax, the truth clauses, a concrete
  witness frame, and the component's axiom profiles.
- Give ForMathlib an isolated-import smoke check that reaches every one of its five files
  directly, so each upstream-PR candidate is verifiable without pulling in the project tree.
- Cover the two genuinely untested simp sets in the lower-level attribute module and the five
  metaprogramming helpers in the lower-level meta module, by folding into existing Automation
  tests rather than adding a file.
- Keep every edit inside the test tree: no FormalSystem declaration, signature, import or proof
  is touched, and no coverage is raised on a module that already has tests.
- Leave the tree green at its pre-task baselines: build, test target, module invariants, and the
  zero warning budget.

**Non-Goals**:

- Repairing the `buildContextExpr` defect, or any other change to a `FormalSystem` declaration,
  signature, import or proof, however small or however clearly correct.
- Raising coverage of modules that already have referencing tests.
- Touching the 360 `sorry` occurrences under `FormalSystem/` (expected for an in-progress
  formalization, with no unexplained clustering).
- Editing `Tests/BimodalTest/Automation/TacticsTest.lean` at all, in any form.
- Creating a `Tests/BimodalTest/NomicLanguage/` directory, or any other new per-language test
  directory shape the tree does not already use.
- Proving any new theorem: this plan's deliverables are `example`, `#check`, `#guard`,
  `#guard_msgs` and `#eval` probes only (see `## Lean Challenge Statements`).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C6 failure from forgetting the `Tests/BimodalTest.lean` import for a new module | H | M | The import-list edit is a task in the SAME phase as each file creation, never deferred; `bash scripts/check-module-invariants.sh --no-build` (whose C6 half is structural) runs before the phase-closing commit |
| C16 `docBlame` rise: a new module has no baseline row, so its ceiling is 0 | H | M | Docstring or `private` every new public declaration; confirm with `lake exe runLinter BimodalTest` and check that no row named `BimodalTest.Semantics.NomicLanguageTest` or `BimodalTest.ForMathlib.SmokeTest` appears and no existing row rises |
| Zero warning budget turns a style slip into a CI failure (CI builds with `--wfail`) | H | M | Keep code lines at 100 characters or fewer; the `/-- info: ... -/` expected-output exemption measured at 104-133 characters does NOT extend to code lines. Build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` rather than bare `lake` |
| `BimodalTest` has `autoImplicit = false`; an implicit binder left undeclared fails to elaborate | M | M | Bind every universe/type variable explicitly, as the existing `Semantics/*AxiomTest.lean` modules do |
| `F3.IsRegular` does not synthesize (`F3` is a plain `def`, so the instance head is not syntactically `ofStepFamily ...`) | M | H | Bind it with `haveI : F3.IsRegular := NomicFrame.ofStepFamily_isRegular R3 R3.fwd R3.bwd`, exactly as `NomicLanguage/NomicFour.lean` does |
| A pinned axiom profile drifts and a `#guard_msgs` block goes red | L | L | This is the intended behaviour. `OpenLanguageAxiomTest.lean`'s "When one of these guards fires" policy applies: update the expected block in the same commit as the change that moved it, never re-baseline alone to turn a red build green. Carry that paragraph into the new module's docstring |
| A test that invokes `buildContextExpr` cannot pass; one written to expect the throw would launder the bug | M | M | `#check @buildContextExpr` only, with an in-file comment naming the defect (the `mkAppM` call shape), never an assertion over its result |
| `.githooks/pre-commit` blocks every phase commit here: it fires on any staged `.lean` path and refuses while `typst/generated/status.typ` has drifted, and this task moves that file's `tests-file-count` and `tests-line-count` | H | H | Not deferrable -- surface (b) of `plan-authoring-gate-collisions.md` Condition 1 blocks the commit of the very phase that causes it. Every phase regenerates it as named phase work: guarded `lake build`, then `bash scripts/typst-sync-check.sh --fix`, then stage `typst/generated/status.typ` with that phase's own commit. Baseline measured clean (`--counts-only` reports `MISMATCH_COUNT=0`) before any edit, so any field OTHER than the two `tests-*` counts moving in the `--fix` diff means another writer's uncommitted `FormalSystem/` edit -- stop and diagnose, never hand-patch the generated file |
| `--fix` run against a stale build absorbs an unrelated field's drift into this task's commit | M | L | Run the guarded `lake build` immediately before `--fix`, then review `git diff typst/generated/status.typ` and confirm only `tests-file-count` and `tests-line-count` moved before staging |
| A gate goes red on a pre-existing finding unrelated to this task | M | M | Capture every gate's pre-task verdict in Phase 1 before editing. Per `plan-authoring-gate-collisions.md` Condition 4, a gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS, with the findings enumerated -- not grounds to edit an out-of-scope file |

## Decisions

- **Zero Lean goals is a deliberate declaration, not an omission.** Every deliverable here is a
  regression probe -- `example`, `#check`, `#guard`, `#guard_msgs` and `#eval` -- and not one is
  a named theorem with a statement to pin. The `## Lean Challenge Statements` section therefore
  carries the verbatim `<!-- lean-challenge-statements:none -->` marker and no fenced blocks, and
  `- **Goals**:` names zero identifiers, per `plan-format.md`'s "Zero Lean Goals" subsection. A
  plan that invented a theorem to satisfy the section would be adding scope the task excludes.
- **Group (A) is placed under `Tests/BimodalTest/Semantics/`, not in a new
  `Tests/BimodalTest/NomicLanguage/` directory.** The review suggested the latter; the tree has no
  per-language test directory at all, and the task asks to follow the existing pattern. The
  nearest precedent for a semantic-only language component is
  `Semantics/OpenLanguageAxiomTest.lean`, so the new module sits beside it.
- **Group (C) hosts in `NormalizationTest.lean` + `LemmaDBTest.lean`, never in
  `TacticsTest.lean`.** The dispatch's territory note permits disjoint edits in
  `TacticsTest.lean` alongside open task 177's prose-only work there, but avoiding the file
  entirely removes the collision risk at no cost. `LemmaDBTest.lean`'s own header records that
  metaprogramming probes were moved out of `TacticsTest.lean` deliberately, and it already runs a
  `#eval show CoreM Unit from do` probe -- so it is the right host on its own merits, not merely
  the convenient one.
- **The `buildContextExpr` repair stays out of scope.** This discharges the recorded prior
  decision (route (b): keep scope, file the repair separately), verified against this plan: no
  phase's `Files to modify` block names any path under `FormalSystem/`, and Phase 3's group (C)
  task list probes `buildContextExpr` with `#check` only. The route leaves no second obstruction
  -- the two pre-validated repairs are recorded in Phase 3's follow-up step so the separate task
  can be filed with the fix already measured.
- **Documentation reconciliation is scheduled in the final phase, not alongside each file
  creation.** The affected READMEs under `Tests/BimodalTest/` are hand-maintained Contents tables;
  `scripts/readme-lint.sh` runs against `FormalSystem BimodalTools` only (confirmed in both
  `scripts/verify-all.sh` and `.github/workflows/ci.yml`), and its "every `.lean` file appears in
  its README" check is reported-not-gated even in scope. Nothing is commit-blocking, so grouping
  the doc edits into the final `full` phase is legitimate and keeps the two work phases' narrowed
  verification from dragging in the whole markdown suite set.
- **Of Condition 1's two coupled generated surfaces, exactly one is in play -- measured, and the
  split is not the one a first reading suggests.** `plan-authoring-gate-collisions.md`
  Condition 1 makes a Lean line-count change trip two generated surfaces, and both were checked
  against this task's `Tests/`-only edit set:
  - **Surface (b), `typst/generated/status.typ`: IN PLAY, and commit-blocking.**
    `scripts/typst-status-counts.sh` emits `tests-file-count` and `tests-line-count` from a
    recursive count of `.lean` files and lines under `Tests/`, so every phase here moves it, and
    `.githooks/pre-commit` refuses a commit staging a `.lean` path while it has drifted. It is
    therefore declared in EVERY phase's `Files to modify` block with its regeneration scheduled in
    that same phase, exactly as Condition 1 requires for a surface that cannot wait.
    `scripts/typst-sync-check.sh`'s `LEAN_SRC_ROOTS` (`FormalSystem/` + `BimodalTools/`) governs
    the script's DECLARATION scan, not these count fields -- reading it as the scope of the whole
    file is the trap this bullet exists to record.
  - **Surface (a), the generated inventory blocks: NOT in play.** `README.md`'s block is
    `dir=FormalSystem`, and no README under `Tests/BimodalTest/` carries a machine-owned block at
    all (only `Tests/BimodalToolsTest/README.md` does, for a different library). Confirmed
    independently by `bash .claude/scripts/plan-file-scope-harvest.sh` over this plan, whose
    ancestor-chain generated-README scan appends nothing for these paths. So no inventory block is
    declared and no `--emit-inventory` step is scheduled.
- **`Tests/BimodalTest.lean` is edited by hand, correctly.** Unlike `FormalSystem.lean`, which C33
  holds byte-current against `lake exe mk_all`, the test aggregator is hand-maintained -- its own
  docstring states the invariant C6 enforces over it. No `mk_all` step is scheduled.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. Every wave here holds exactly one phase:
Phases 1 and 2 are independent in content but both edit `Tests/BimodalTest.lean`, so they are
serialized on that shared file rather than declared parallel, and Phase 3 is the final
reconciliation-and-verification phase.

---

### Phase 1: NomicLanguage regression module [COMPLETED]

**Goal**: Close the Medium-severity gap: `FormalSystem/NomicLanguage/` is referenced from a test
module for the first time, exercising `NomicFormula`, `NomicTruth` and `NomicValidity`.

**Tasks**:

- [x] Capture the pre-edit gate baseline, before touching any file, and record each verdict in
      the phase notes: `bash scripts/check-module-invariants.sh --no-build`,
      `bash scripts/typst-sync-check.sh --counts-only`, `lake exe runLinter BimodalTest`
      (for the current `BimodalTest` `docBlame`/`defsWithUnderscore`/`synTaut` rows), and the
      current `scripts/warning-budget.txt` statement. This is what makes a later red gate
      attributable or not.
- [x] Create `Tests/BimodalTest/Semantics/NomicLanguageTest.lean` with the four-line Apache
      copyright header every file under `Tests/` carries, the two imports
      `FormalSystem.NomicLanguage` and `FormalSystem.Semantics.Nomic`, and a module docstring
      that (a) states what the module covers and (b) carries
      `OpenLanguageAxiomTest.lean`'s guard-fired policy paragraph verbatim in substance: when a
      `#guard_msgs` block goes red, update the expected block in the same commit as the change
      that moved the profile, never re-baseline it alone to turn a red build green.
- [x] Section 1, syntax: `#guard`s over `NomicFormula`'s `DecidableEq`, pins on `ofFormula`, and a
      use of `ofFormula_injective`.
- [x] Section 2, truth clauses: apply `NomicTruth.nomic_iff`, `box_iff`, `always_iff` and
      `diamond_iff` at an arbitrary `NomicFrame D`. These lemmas are `Iff.rfl`-shaped, so direct
      terms suffice (e.g. `NomicTruth.nomic_iff M τ x φ`); no tactic is needed.
- [x] Section 3, concrete frame: build a `NomicModel` over
      `FormalSystem.Semantics.NomicHierarchy.F3`, evaluate truth at it, instantiate
      `Semantics.nomic_serial` at `F3` under
      `haveI : F3.IsRegular := NomicFrame.ofStepFamily_isRegular R3 R3.fwd R3.bwd`, and witness
      axiom 4's failure at `F3` via `Semantics.four_validOn_iff_uniform` together with
      `NomicHierarchy.F3.not_uniform`. Also pin a `TenseFree` negative:
      `¬ TenseFree (NomicFormula.someFuture (.atom p))` closes by `intro h; cases h`.
- [x] Section 4, axiom-profile pins: `#guard_msgs`-gated `#print axioms` blocks for the seven
      declarations in the measured table under "Research Integration" above. Re-read each profile
      from the compiler rather than copying the table on faith -- a mismatched expected string is
      a compile error, which is the point of the pin.
- [x] Docstring (or make `private`) every new public declaration in the module -- the
      `NomicModel F3` valuation and any atom abbreviation above all. This module has no row in
      `scripts/c16-roots-baseline.txt`, so its `docBlame` ceiling is 0. Avoid a non-trailing
      underscore in any `def`/`abbrev` name (C26/`defsWithUnderscore`) and avoid a tautological
      statement (`synTaut`).
- [x] Add `import BimodalTest.Semantics.NomicLanguageTest` to `Tests/BimodalTest.lean`, beside the
      other `BimodalTest.Semantics.*` entries. This is part of this phase, not a later one:
      omitting it is a C6 unreachable-module failure.
- [x] Verify no task-number citation appears anywhere in the new `.lean` file: it is a deliverable
      outside `specs/**`, so `.claude/rules/no-task-references-in-deliverables.md` applies. Name
      durable anchors (a file path, a declaration name) in every comment.
- [x] Build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      BimodalTest.Semantics.NomicLanguageTest`, then
      `bash scripts/check-module-invariants.sh --no-build` for C6.
- [x] Regenerate the commit-blocking count surface, in THIS phase: `bash
      scripts/typst-sync-check.sh --fix`, then review `git diff typst/generated/status.typ` and
      confirm only `tests-file-count` and `tests-line-count` moved. Any other field moving means a
      concurrent writer's `FormalSystem/` edit -- stop and diagnose rather than staging it.
- [x] Commit once, with an explicit three-path staging list: the new module,
      `Tests/BimodalTest.lean`, and `typst/generated/status.typ`. Omitting the third path is
      refused by `.githooks/pre-commit`, not merely untidy.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is hypothesized to be one new ~115-line module plus a one-line
aggregator import plus the regenerated count surface, pinning exactly seven axiom profiles across
four sections, with no other `Tests/` file touched. The implementer confirms it by: (a)
`git status --short` showing exactly three paths changed at phase close, and (b) a count of
`#guard_msgs` blocks in the new file equal to
the number of profile rows actually pinned, which may legitimately grow to nine if
`nomic_iff_box_validOn_iff_uniform` and `exists_refutation_of_not_uniform` are pinned too (both
measure `[propext, Classical.choice, Quot.sound]`). A count that moves is a reportable deviation,
not a silent one; a count that moves BELOW seven means a profile could not be reproduced and is a
finding to record, not to drop.

**Tier Justification**: `bash .claude/scripts/verify-touched.sh` over this phase's touched paths
covers the whole blast radius -- a new leaf test module nothing imports, a one-line aggregator
import, and the regenerated count surface -- and the single selector run over that path set
returns `test-lean-src-roots.sh`, `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, alongside the per-module `lake build` the `local` row prescribes.

**Files to modify**:

- `Tests/BimodalTest/Semantics/NomicLanguageTest.lean` - NEW. The four-section NomicLanguage
  regression module: syntax, truth clauses, concrete-frame witnesses, axiom-profile pins.
- `Tests/BimodalTest.lean` - add `import BimodalTest.Semantics.NomicLanguageTest` beside the other
  `BimodalTest.Semantics.*` entries. Import line only; the docstring and `version` def are
  untouched.
- `typst/generated/status.typ` - regenerate via `scripts/typst-sync-check.sh --fix`; the new
  module moves `tests-file-count` and `tests-line-count`, and the pre-commit hook blocks on the
  drift.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  BimodalTest.Semantics.NomicLanguageTest` exits 0 with no warning. The three
  `linter.hashCommand` warnings a `#guard` would raise are suppressed for this library by
  `weak.linter.hashCommand = false` in `lakefile.toml`; any OTHER warning is a failure, since CI
  builds with `--wfail`.
- `bash scripts/check-module-invariants.sh --no-build` reports C6 PASS, and every other check's
  verdict equals the Phase 1 baseline captured in the first task.
- `lake exe runLinter BimodalTest` introduces no row for
  `BimodalTest.Semantics.NomicLanguageTest` and raises no existing `BimodalTest` row above its
  `scripts/c16-roots-baseline.txt` ceiling.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 with `MISMATCH_COUNT=0` AFTER the
  `--fix` run, and `git diff --staged typst/generated/status.typ` shows only the two `tests-*`
  count fields changed.
- `grep -rn "NomicLanguage" Tests/ | grep -v "^Tests/.*README"` returns at least one hit in a
  `.lean` file -- the gap the review recorded is closed for group (A).

---

### Phase 2: ForMathlib isolated-import smoke module [NOT STARTED]

**Goal**: Close the first Low-severity gap: every file under `FormalSystem/ForMathlib/` is reached
by a check that imports only `FormalSystem.ForMathlib`, making each upstream-PR candidate
verifiable in isolation rather than only transitively through its seven in-tree consumers.

**Tasks**:

- [ ] Create `Tests/BimodalTest/ForMathlib/SmokeTest.lean` with the four-line Apache copyright
      header, importing ONLY `FormalSystem.ForMathlib`. The isolated import is the whole point of
      the artifact; adding a second `FormalSystem.*` import defeats it.
- [ ] A `#check` per public declaration, plus one minimal instantiating `example` per file, using
      the forms the research dispatch compiled: `Order.IsNest ({Set.univ} : Set (Set ℕ))` via
      `⟨⟨Set.univ, rfl⟩, by simp [IsChain, Set.Pairwise]⟩` and `IsNest.exists_subset_inter`
      (BallSpace); `Order.PFilter.isProper_iff_bot_notMem` and `Order.PrimeFilter.mem_iff`
      (PFilter); `(⊥ : SimpleGraph ℕ).IsAcyclic` via `isAcyclic_of_rank_parent` with `rk = 0`,
      `par = id`, closing the vacuous adjacency branch with `absurd h (by simp)`
      (SimpleGraphAcyclic); `Nat.exists_strictMono_const_pair_colour` at `C := Bool`
      (InfiniteRamseyPairs); `Sierpinski.isOpen_locallyConstantLocus` and
      `const_of_countable_range` on a constant `ℝ → Bool` (Sierpinski).
- [ ] For the Sierpinski level-set closedness obligation, use `simp [Sierpinski.levelSet]` on the
      `a = c` branch and `simp [Sierpinski.levelSet, Ne.symm hac]` on the `a ≠ c` branch. A
      `simpa` form and an explicit `isClosed_empty` were both measured to FAIL here
      (`unnecessarySimpa`, and "No goals to be solved"), and under the zero warning budget an
      `unnecessarySimpa` warning is a gate failure.
- [ ] Keep this to ONE module, not one per file. A module per `ForMathlib` file is the over-built
      shape the review explicitly warns against; a single ~70-line module is the lightweight
      reading of "a `#check`/`example` smoke test per file".
- [ ] Docstring (or make `private`) every new public declaration -- this module also has no
      `scripts/c16-roots-baseline.txt` row, so its ceiling is 0. Same `defsWithUnderscore` and
      `synTaut` cautions as Phase 1.
- [ ] Add `import BimodalTest.ForMathlib.SmokeTest` to `Tests/BimodalTest.lean` as a new group, in
      this same phase -- C6 again.
- [ ] Verify no task-number citation appears in the new `.lean` file.
- [ ] Build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      BimodalTest.ForMathlib.SmokeTest`, then `bash scripts/check-module-invariants.sh
      --no-build`.
- [ ] Regenerate the commit-blocking count surface, in THIS phase, with the same
      build-then-`--fix`-then-review-diff sequence Phase 1 used, and stage
      `typst/generated/status.typ` with this phase's commit.
- [ ] Commit once, with an explicit three-path staging list: the new module,
      `Tests/BimodalTest.lean`, and `typst/generated/status.typ`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is hypothesized to be one new ~70-line module reaching all five
`ForMathlib` files (`Order/BallSpace.lean`, `Order/PFilter.lean`,
`Combinatorics/SimpleGraphAcyclic.lean`, `Combinatorics/InfiniteRamseyPairs.lean`,
`Topology/Sierpinski.lean`) plus a one-line aggregator import plus the regenerated count surface,
and DELIBERATELY EXCLUDES a second
`FormalSystem.*` import and a per-file module split. The implementer confirms it by: (a) the new
file carrying exactly one `import` line, and (b) `grep -c` over the file finding at least one
reference to each of the five files' headline declarations. No task in this phase requires a
second import or a second module, so the exclusion and the task list are consistent.

**Tier Justification**: `bash .claude/scripts/verify-touched.sh` over this phase's touched paths
covers the whole blast radius -- one new leaf test module with a single import, a one-line
aggregator edit, and the regenerated count surface -- and the single selector run over that path
set returns `test-lean-src-roots.sh`, `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, alongside the per-module `lake build` the `local` row prescribes.

**Files to modify**:

- `Tests/BimodalTest/ForMathlib/SmokeTest.lean` - NEW (also creates the directory). One `#check`
  per public `ForMathlib` declaration plus one instantiating `example` per file, importing only
  `FormalSystem.ForMathlib`.
- `Tests/BimodalTest.lean` - add `import BimodalTest.ForMathlib.SmokeTest` as a new group. Import
  line only.
- `typst/generated/status.typ` - regenerate via `scripts/typst-sync-check.sh --fix`; this phase's
  new module moves `tests-file-count` and `tests-line-count` again.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  BimodalTest.ForMathlib.SmokeTest` exits 0 with no warning other than the library's suppressed
  `linter.hashCommand` class.
- `grep -c "^import" Tests/BimodalTest/ForMathlib/SmokeTest.lean` returns 1, and that one line is
  `import FormalSystem.ForMathlib` -- the isolation property the artifact exists for.
- `bash scripts/check-module-invariants.sh --no-build` reports C6 PASS and every other verdict
  equal to the Phase 1 baseline.
- `lake exe runLinter BimodalTest` introduces no row for `BimodalTest.ForMathlib.SmokeTest` and
  raises no existing row above its ceiling.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 with `MISMATCH_COUNT=0` after the
  `--fix` run, with only the two `tests-*` count fields changed in the staged diff.
- `grep -rn "ForMathlib" Tests/ --include="*.lean"` returns at least one hit -- group (B)'s gap is
  closed.

---

### Phase 3: Tactic folds, documentation reconciliation, and whole-tree verification [NOT STARTED]

**Goal**: Close the second Low-severity gap by folding minimal usage checks for
`FormalSystem/Tactic/Attr.lean` and `FormalSystem/Tactic/Meta.lean` into existing `Automation/`
tests, bring the hand-maintained test READMEs back in step with the two new modules, and leave
the whole tree green.

**Tasks**:

- [ ] Fold the two missing `Tactic/Attr.lean` simp-set checks into
      `Tests/BimodalTest/Automation/NormalizationTest.lean` (545 lines), which already hosts the
      `formula_unfold`/`formula_fold` checks and already names `FormalSystem/Tactic/Attr.lean` in
      its prose. Two `example`s suffice:
      `TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ` closed by `simp only [truth_norm]`, and
      `(φ.neg).reflectTime = (φ.reflectTime).neg` closed by `simp only [reflect_time_norm]`.
      **No new import is required** -- both were compiled under this file's existing two-import
      closure.
- [ ] Fold the `Tactic/Meta.lean` usage probe into
      `Tests/BimodalTest/Automation/LemmaDBTest.lean` (223 lines): `#check` all five helpers, then
      one `TermElabM` block that elaborates
      `DerivationTree FrameClass.Base ([] : Context) (p.imp p)` and asserts that
      `extractDerivationGoal` recognises it, `isNilContext` accepts its context, `formulaHead`
      reads `Formula.imp`, and `lemmaConclusionHead` reads `Formula.imp` off the
      `@[tmLemma]`-tagged `FormalSystem.Theorems.ModalS5.tBoxToDiamond`; plus a negative `MetaM`
      block asserting that `extractDerivationGoal` and `isNilContext` both reject
      `mkConst ``Nat`. **No new import is required.** Watch for the `Context` ambiguity that
      arises under `open Lean Meta Elab Term` -- qualify the name rather than widening the
      `open`.
- [ ] Assert NOTHING about `buildContextExpr` beyond `#check @buildContextExpr`. A test that
      invokes it cannot pass, and one written to expect the throw would launder the bug. Add an
      in-file comment naming the defect by durable anchor -- `FormalSystem/Tactic/Meta.lean`'s
      `buildContextExpr`, whose `mkAppM `` `List.nil `` ` call passes an explicit argument for an
      implicit parameter -- with no task number anywhere in the comment.
- [ ] Do not open `Tests/BimodalTest/Automation/TacticsTest.lean`. It is named in open task 177's
      file scope for a prose-only concern; this phase's hosts were chosen precisely to keep the
      two disjoint.
- [ ] Record the follow-up the recorded prior decision owes: the `buildContextExpr` repair is a
      separate task, and two repairs were already compiled and both round-trip --
      `mkAppOptM `` `List.nil `` #[some formulaType]`, or
      `Lean.mkApp (Lean.mkConst `` `List.nil `` [Level.zero]) formulaType`. State both, with the
      two `Search.lean` call sites (`tryModalK`, `tryTemporalK`, both outside their `observing?`
      block) in the implementation summary's follow-up section and in `.return-meta.json`, so the
      separate task can be filed with the fix pre-validated. Do NOT create the task from this
      dispatch and do NOT apply the repair.
- [ ] Add a `NomicLanguageTest.lean` row to `Tests/BimodalTest/Semantics/README.md`'s Contents
      table and refresh its Last Updated stamp.
- [ ] Create `Tests/BimodalTest/ForMathlib/README.md` following the shape every other
      `Tests/BimodalTest/` subdirectory README uses (title, Contents table, Coverage, Related,
      Last Updated), so the new directory is not the one test directory without one.
- [ ] Note the two new `Automation/` folds in `Tests/BimodalTest/Automation/README.md` if its
      Contents table or Coverage section describes per-file content at that granularity; leave it
      untouched if it does not. Do not invent a row shape the file does not already use.
- [ ] Regenerate the commit-blocking count surface one last time, in THIS phase: the two folds add
      Lean lines under `Tests/`, so `tests-line-count` moves again. Same
      build-then-`--fix`-then-review-diff sequence, and stage `typst/generated/status.typ` with
      this phase's commit.
- [ ] Record any issue, deviation or win as it arises via `issue-record.sh`, per this dispatch's
      Issue Log contract -- not reconstructed at the end.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is hypothesized to be two small folds (two `example`s in
`NormalizationTest.lean`, five `#check`s plus two elaboration blocks in `LemmaDBTest.lean`), no
new import in either host, at most three README edits, and one regenerated count surface -- and it
DELIBERATELY EXCLUDES any edit
to `TacticsTest.lean`, any invocation of `buildContextExpr`, and any file under `FormalSystem/`.
The implementer confirms it by: (a) `git status --short` at phase close naming no path under
`FormalSystem/` and not `TacticsTest.lean`, (b) `grep -c "^import"` on each host file returning
its pre-edit value, and (c) `grep -n "buildContextExpr" Tests/` showing only a `#check` and a
comment, never an application. No task in this phase requires any excluded item.

**Files to modify**:

- `Tests/BimodalTest/Automation/NormalizationTest.lean` - add two `example`s exercising the
  `truth_norm` and `reflect_time_norm` simp sets. No import change.
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` - add the five-helper `#check` block, the
  positive `TermElabM` probe, and the negative `MetaM` probe for `Tactic/Meta.lean`. No import
  change.
- `Tests/BimodalTest/Semantics/README.md` - add the `NomicLanguageTest.lean` Contents row; refresh
  the Last Updated stamp.
- `Tests/BimodalTest/ForMathlib/README.md` - NEW. Directory README matching the shape the other
  `Tests/BimodalTest/` subdirectory READMEs use.
- `Tests/BimodalTest/Automation/README.md` - note the two folds only if the file already describes
  content at that granularity; otherwise leave untouched.
- `typst/generated/status.typ` - regenerate via `scripts/typst-sync-check.sh --fix`; the two folds
  move `tests-line-count`.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` exits 0
  with no warning other than the library's suppressed `linter.hashCommand` class, and `lake test`
  (`testDriver = "BimodalTest"`) exits 0.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (the default
  `FormalSystem` target) exits 0 -- confirming nothing under `FormalSystem/` moved.
- `bash scripts/check-module-invariants.sh` (full mode, which is where the C16-roots half runs)
  reports no finding absent from the Phase 1 baseline. Per
  `plan-authoring-gate-collisions.md` Condition 4, this criterion is a DELTA against that
  baseline, never an absolute zero: a gate whose only failures are pre-existing and outside this
  task's file scope is a recorded PASS, with each pre-existing finding enumerated.
- `bash scripts/verify-all.sh` exits 0, or -- if it exits non-zero -- every FAIL it reports is one
  already present in the Phase 1 baseline, enumerated by name. Its exit status is read, not only
  its printed verdicts.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 with `MISMATCH_COUNT=0` after this
  phase's `--fix` run, and `bash scripts/check-module-invariants.sh --emit-inventory --check`
  exits 0 -- confirming the measured split: the count surface moved and was regenerated, the
  inventory blocks did not move at all.
- Group-closure grep, the task's own stated acceptance bar: each of `NomicLanguage`, `ForMathlib`
  and `Tactic` is referenced from at least one `.lean` file under `Tests/` --
  `grep -rln "NomicLanguage\|ForMathlib\|FormalSystem.Tactic" Tests/ --include="*.lean"` names at
  least one file per group.
- This phase declares `full`, and under `/orchestrate` its own in-dispatch obligation is the
  scoped touched-path check -- `bash .claude/scripts/verify-touched.sh` over this phase's touched
  paths -- plus an explicit deferral of the complete gate set to the orchestration close. It does
  NOT run an independent full battery as its own criterion. Outside `/orchestrate` (a standalone
  run with no orchestration close to defer to), run the complete set directly instead.

---

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This plan has no theorem deliverable. Every artifact it schedules is a regression probe --
`example`, `#check`, `#guard`, `#guard_msgs` and `#eval` -- over declarations that already exist
under `FormalSystem/`; not one phase introduces a named theorem whose statement could be pinned
here. Adding one would be scope the task description explicitly excludes. The rationale is
recorded in full under `## Decisions` above, and `- **Goals**:` correspondingly names zero
identifiers.

## Testing & Validation

- [ ] `lake build` (default `FormalSystem` target) exits 0 -- nothing under `FormalSystem/` moved.
- [ ] `lake build BimodalTest` exits 0 with no warning beyond the library's suppressed
      `linter.hashCommand` class. CI builds with `--wfail`, so warning and error are the same
      thing here.
- [ ] `lake test` exits 0.
- [ ] `lake exe runLinter BimodalTest` adds no new per-module row and raises no existing row above
      its `scripts/c16-roots-baseline.txt` ceiling.
- [ ] `bash scripts/check-module-invariants.sh` reports C6 PASS for both new modules and no
      finding absent from the pre-task baseline captured in Phase 1.
- [ ] `bash scripts/verify-all.sh` exits 0, or every FAIL it reports is enumerated in the Phase 1
      pre-task baseline. Exit status checked, not only stdout.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0 with `MISMATCH_COUNT=0` and
      `typst/generated/status.typ` is committed with each phase that moved it; the staged diff for
      that file never names a field other than `tests-file-count` and `tests-line-count`.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 -- the generated
      inventory blocks were not moved by this task and must not have been edited.
- [ ] `bash scripts/check-copyright-headers.sh --strict Tests` exits 0 (the checker was clean in
      this scope before the task, so both new files must carry the four-line header).
- [ ] Every code line in both new modules is 100 characters or fewer; only `/-- info: ... -/`
      expected-output lines exceed it, which is the measured, pre-existing exemption.
- [ ] No `.lean` file touched by this task cites a task number
      (`.claude/rules/no-task-references-in-deliverables.md`).
- [ ] `git status --short` at task close names no path under `FormalSystem/` and does not name
      `Tests/BimodalTest/Automation/TacticsTest.lean`. The one path outside `Tests/` that this
      task legitimately touches is `typst/generated/status.typ`.
- [ ] Group-closure grep: `NomicLanguage`, `ForMathlib` and `FormalSystem.Tactic` each referenced
      from at least one `.lean` file under `Tests/`.

## Artifacts & Outputs

- `Tests/BimodalTest/Semantics/NomicLanguageTest.lean` (new) - NomicLanguage regression module.
- `Tests/BimodalTest/ForMathlib/SmokeTest.lean` (new) - isolated-import ForMathlib smoke module.
- `Tests/BimodalTest/ForMathlib/README.md` (new) - directory README for the new test directory.
- `Tests/BimodalTest.lean` (modified) - two added import lines.
- `Tests/BimodalTest/Automation/NormalizationTest.lean` (modified) - two `Tactic/Attr.lean`
  simp-set `example`s.
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` (modified) - `Tactic/Meta.lean` helper probe.
- `Tests/BimodalTest/Semantics/README.md` (modified) - Contents row for the new module.
- `Tests/BimodalTest/Automation/README.md` (possibly modified) - only if it already describes
  content at the granularity the folds would add.
- `typst/generated/status.typ` (modified, once per phase) - regenerated `tests-file-count` and
  `tests-line-count`; the only path this task touches outside `Tests/`.
- `specs/942_test_coverage_nomic_formathlib_tactic/summaries/01_test-coverage-nomic-formathlib-tactic-summary.md`
  - implementation summary, carrying the `buildContextExpr` follow-up with both pre-validated
  repairs.

## Rollback/Contingency

Every edit is additive and confined to `Tests/`: no `FormalSystem` declaration, signature, import
or proof changes, so nothing downstream depends on any of it. Reverting is correspondingly cheap
and is done per phase, not per task:

- **A phase whose work is committed**: `git revert` that phase's single scoped commit. Each phase
  commits exactly the files its own `Files to modify` block names, so a revert is surgical --
  including its `typst/generated/status.typ` hunk, which reverts in step with the Lean lines that
  moved it rather than needing a separate regeneration.
- **A phase whose work is uncommitted and must be discarded**: this is a genuine rollback, so take
  a snapshot FIRST and then roll back -- see `context/contracts/recovery.md`'s rollback rung for
  the exact invocation shape, including its out-of-scope override flag for the deliberate
  whole-tree case. Never discard uncommitted work to reach a passing build.
- **A phase that is merely stuck, not wrong**: prefer fixing forward. Dropping a single probe
  (one `example`, one `#check`) from a module while keeping the rest is a legitimate partial
  landing -- record it as a `[COMPLETED WITH EXCLUSIONS]` phase with the dropped probe named,
  rather than reverting the whole module.
- **If a new module cannot be made to satisfy C16's zero `docBlame` ceiling**: make the offending
  declaration `private` rather than regenerating `scripts/c16-roots-baseline.txt`. Regenerating
  that file to absorb a new finding is the failure mode its own header warns against.
