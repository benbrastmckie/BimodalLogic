# Implementation Plan: Task #804

- **Task**: 804 - Narrow the termination subtree's fan-in from the syntax layer
- **Status**: [IMPLEMENTING]
- **Effort**: 3.75 hours
- **Dependencies**: 803 (landed)
- **Research Inputs**: `specs/804_narrow_termination_syntax_layer_fanin/reports/01_termination-syntax-fanin.md`
- **Artifacts**: plans/01_termination-syntax-fanin.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The termination subtree under `FormalSystem/Metalogic/Decidability/Verified/Termination/` sits
downstream of 146 `FormalSystem` modules, most of them through import lines whose targets it never
uses. This plan applies the research report's import-only narrowings R1-R4 to seven files, with no
declaration, statement or proof text touched, so that an edit to any `Semantics/` module or to the
`Syntax.lean` aggregator stops rebuilding `Fuel` and `MintBound`. The dependence on
`ProofSystem/Axioms.lean` is essential and stays. Done means: the narrowed tree builds green on all
four library roots, `check-module-invariants.sh` prints `ALL CHECKS PASSED`, the sorry count is 0,
and a before/after rebuild-scope record exists for an edit to `Axioms.lean` and to the Semantics and
Syntax aggregators.

### Research Integration

- **Edge classification is taken from the report as the acceptance deliverable.** Its 20-row table
  classifies every import edge from the subtree to the syntax, proof-system and semantics layers
  with declaration-level use counts. The final evidence file restates it against the landed tree.
- **R1** (drop `import FormalSystem.Semantics` from `Automation/ProofSearch/Core.lean`, add
  `Mathlib.Tactic.Ring` to `Fuel.lean` and `Mathlib.Data.Finset.Max` to
  `MintBound/ClosureResidual.lean`), **R3** (narrow three aggregator imports) and **R4** (drop the
  unused `SubformulaClosure.Closure` import from `SubformulaProperty.lean`) are applied as the
  report states them.
- **R2 is applied in a line-neutral variant**, not in the report's form. See Decisions.
- **R5 (relocate `FrameClass`) is not taken.** The report leaves it optional with default defer.
- **R6 (leave the `Closure` -> `Core` -> `Axioms` path alone)** is adopted: no interface is
  introduced.
- **Carried figures.** The report's counts (146 -> 52 closure, 520 -> 519 for an `Axioms.lean` edit,
  251 -> 204 for `Semantics.lean`, 107 -> 29 for `Syntax.lean`, 91 of 91 shadow compiles) are
  CARRIED-UNVERIFIED from `reports/01_termination-syntax-fanin.md`; Phase 1 and Phase 3 re-derive
  the rebuild-set figures on the real tree. The task description's timings (1103s, 476s, 360s,
  238s; 414 of 2848 jobs; 6354s; 5649s across 306 modules) are CARRIED-UNVERIFIED from the task
  description; the report records that the build log they came from has been overwritten.
- **Premise re-validation (checked at HEAD `75dbaedcc`, 2026-11-13).** The description's one
  checkable structural claim, that `SubformulaProperty.lean` imports
  `FormalSystem.Metalogic.Decidability.Tableau` and `FormalSystem.Syntax.SubformulaClosure.Closure`,
  holds (lines 7-8 of the file). All import lines the report's recommendations name are present as
  the report describes them: `Core.lean` lines 9-10, `SuccessPatterns.lean` line 8,
  `SignedFormula.lean` lines 8 and 42, `TraceCertificate.lean` lines 7-8. `Fuel.lean` and
  `ClosureResidual.lean` carry no Mathlib import today. The description's timing figures are not
  re-checkable (log overwritten) and no step of this plan depends on them.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch.

## Goals & Non-Goals

- **Goals**:
  - Remove the termination subtree from the rebuild set of every Semantics module and of the Syntax
    aggregator by import-line edits only.
  - Record measured before/after rebuild sets for an edit to the Axioms module, the Semantics
    aggregator and the Syntax aggregator.
  - Deliver the written essential/reducible classification of every import edge, checked against
    the landed tree.

- **Non-Goals**:
  - Any change to a proved statement, a definition or a proof body.
  - Any new `sorry` or new axiom dependency.
  - Relocating `FrameClass` out of `Axioms.lean` (R5).
  - Abstracting `findClosure` or the expansion engine behind an interface (R6).
  - Narrowing imports of any module outside the seven named in Phase 2.

## Decisions

- **No theorem deliverable.** The task changes import lines only. The Lean Challenge Statements
  section therefore carries the zero-goal marker and the Goals block names no identifiers.
- **R2 variant.** The report's R2 removes two lines from `SignedFormula.lean` and adds one to
  `Tableau.lean`. That shifts every later line in both files, and 23 `file.lean:NNN` citations
  outside `specs/` point into them (`SignedFormula.lean` 5, `Tableau.lean` 18; grep at HEAD
  `75dbaedcc`). `check-module-invariants.sh` C20 gates those citations, and the sibling task's
  `Tableau.lean` edit already tripped it once. The variant used here replaces
  `import FormalSystem.ProofSystem` in `SignedFormula.lean` with
  `import FormalSystem.ProofSystem.Axioms`, keeps the `open` line, and leaves `Tableau.lean`
  untouched. Both files keep their line counts. The cost: `SignedFormula` stays in the rebuild set
  of `Axioms.lean`, so the expected figure for an `Axioms.lean` edit is 520 -> 520 instead of the
  report's 520 -> 519. Every other row of the report's table is expected to be unchanged, because
  `SignedFormula` and `Tableau` still lose `Derivation`, `Derivable`, `DerivedAxioms`,
  `LinearityDerivedFacts` and `Syntax.Context`. The variant's environment is a superset of the
  shadow-compiled one and a subset of today's.
- **R5 deferred.** It moves the acceptance metric by 4 modules (CARRIED-UNVERIFIED, from the
  report) at the cost of shifting 33 `Axioms.lean:NNN` citations and adding a module. The task asks
  for the smallest change that breaks the invalidation path; the path R5 addresses is the essential
  one.
- **One atomic edit phase.** The report compiled the combined edit set; R2 alone was compiled only
  for four modules. Landing the edits as one batch keeps every commit at a state that was verified.
- **Rebuild scope is measured on the import graph**, as the reverse import closure read from the
  built environment (`env.header.moduleData`), before and after. Lake rebuilds a module exactly when
  something in its import closure changes, so this is the rebuild set; it is not a timed build, and
  the evidence file says so.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A module outside the 91 shadow-compiled ones relied on a name reaching it through a removed import | M | L | Phase 2 builds all four library roots, including `BimodalToolsTest`, which the research did not cover; fix forward by adding the explicit import to the failing module and recording it |
| Line shifts in `TraceCertificate`, `SubformulaProperty`, `Fuel`, `ClosureResidual` invalidate a `file.lean:NNN` citation | M | L | Zero such citations outside `specs/` at authoring time; Phase 2 re-runs the grep and runs the build-free invariants pass before committing; `scripts/reanchor-lean-citations.py` is the repair |
| Net Lean line-count change blocks the commit through `.githooks/pre-commit` | M | H | Phase 2 runs `scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in the same commit |
| Module-inventory blocks go stale | L | H | Phase 2 runs `check-module-invariants.sh --emit-inventory` and stages the rewritten READMEs |
| A smaller simp/instance environment changes a proof term's axiom set | H | L | Statements are untouched; C2 and C14 axiom baselines run in Phase 3; a diff there is a hard failure |
| A new linter warning under `--wfail` (for example from a now-different elaboration route) | M | L | Phase 2 reads the build's warning lines, not only its exit status; C28 warning budget runs in Phase 3 |
| Concurrent sessions building the same package | M | M | Every `lake` call goes through `.claude/scripts/lake-build-guard.sh` |
| The deployed `.claude/` tree is stale for core, lean and sapience | L | H | Use only the repository's own `scripts/` gates plus the build guard; a red `verify-deploy.sh` gate naming none of this task's files is recorded as standing baseline |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Pre-Change Baseline [COMPLETED]

**Goal**: Record, on the unedited tree, the rebuild sets and gate states that Phase 3 compares
against.

**Tasks**:
- [x] Confirm the tree is built: `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`,
  verdict read from the guard's `result`. Record the job count and exit status.
- [x] Re-run the report's whole-repo probe
  (`specs/804_narrow_termination_syntax_layer_fanin/probes/WholeRepoUsesProbe.lean`, invoked as the
  report's appendix states, through the build guard where its allowlist admits the subcommand) and
  compute the reverse import closure of `FormalSystem.ProofSystem.Axioms`, `FormalSystem.Semantics`,
  `FormalSystem.Syntax`, `FormalSystem.ProofSystem.Derivation` and `FormalSystem.Syntax.Context`.
  Record the module count of each set and how many of the 25 termination modules it contains.
- [x] Record the pre-change state of the build-free gates, each with exit status:
  `bash scripts/check-module-invariants.sh --no-build`, `bash scripts/check-metalogic-cycles.sh`,
  `bash scripts/typst-sync-check.sh --counts-only`,
  `bash scripts/check-module-invariants.sh --emit-inventory --check`. Any pre-existing finding is
  listed by name so Phase 3 can state its result as a delta.
- [x] Record the `file.lean:NNN` citation counts outside `specs/` for the seven files Phase 2 edits
  and for `Tableau.lean`.
- [x] Record the leading `import` and `open` lines of the seven files as they stand.
- [x] Write all of the above to the evidence file, with the commit hash and the method for each
  figure.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The report gives 520 modules for an `Axioms.lean` edit, 251 for
`Semantics.lean`, 107 for `Syntax.lean`, 361 for `Derivation.lean`, 544 for `Syntax/Context.lean`,
out of 852 project modules, with 25, 23, 23, 25 and 25 termination modules respectively
(CARRIED-UNVERIFIED, from `reports/01_termination-syntax-fanin.md`). Confirm by the probe re-run
above; record the measured figure where it differs and continue, since commits have landed since
the report. The count of 25 termination modules is confirmed by listing the `.lean` files under
`Termination/` plus `MintBound.lean`.

**Tier Justification**: Every path this phase writes lies under `specs/**` and is not a report, plan or summary, so the covering check is the diff read-through of the evidence file (`suite_selection_select` returns `__FULL_SWEEP__` for it).

**Files to modify**:
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md` - new; pre-change
  rebuild sets, gate states, citation counts, import lines

**Verification**:
- The evidence file exists and carries a figure, a method and a commit hash for each of the five
  rebuild sets.
- Each of the four build-free gates has a recorded exit status and, where non-zero, its findings by
  name.
- `git status --short` shows no change outside `specs/`.

---

### Phase 2: Apply the Import Narrowings [COMPLETED]

**Goal**: Land R1-R4 as one verified batch and bring the two generated surfaces the line-count
change moves back into sync.

**Tasks**:
- [x] `FormalSystem/Automation/ProofSearch/Core.lean`: replace `import FormalSystem.ProofSystem`
  with `import FormalSystem.ProofSystem.Derivation`, and replace `import FormalSystem.Semantics`
  with `import FormalSystem.ProofSystem.DerivedAxioms`. Two lines replaced in place.
- [x] `FormalSystem/Automation/SuccessPatterns.lean`: replace `import FormalSystem.Syntax` with
  `import FormalSystem.Syntax.Formula`.
- [x] `FormalSystem/Metalogic/Decidability/SignedFormula.lean`: replace
  `import FormalSystem.ProofSystem` with `import FormalSystem.ProofSystem.Axioms`. Leave
  `open FormalSystem.ProofSystem` as it is. Do not edit `Tableau.lean`.
- [x] `FormalSystem/Metalogic/Decidability/TraceCertificate.lean`: delete
  `import FormalSystem.Syntax` and `import FormalSystem.ProofSystem`.
- [x] `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`: delete
  `import FormalSystem.Syntax.SubformulaClosure.Closure`.
- [x] `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`: add
  `import Mathlib.Tactic.Ring` beside the existing imports.
- [x] `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean`: add
  `import Mathlib.Data.Finset.Max` beside the existing import.
- [x] Confirm with `git diff` that every changed hunk is an `import` line and nothing else.
- [x] Build all four library roots through the guard:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build FormalSystem BimodalTest BimodalTools BimodalToolsTest`.
  Read the verdict from the guard's `result`, and read the captured output for warning lines; CI
  builds with `--wfail`, so a warning is a failure. If the guard refuses a four-target vector, run
  the four roots as four guarded builds. *(deviation: altered — three roots green (3072 jobs, 0 warnings); `BimodalToolsTest` exits 1 on one module, `CertificateImportTest`, an ambiguous `closureList` that predates this change (commit `22e2afa46`) and lies outside the task file scope; see evidence 2.2)*
- [ ] If a module fails with an unknown tactic or unknown constant, add the explicit import that
  supplies it to that module, rebuild, and record the module and the import in the evidence file.
  This is the same repair the report applied to `Fuel` and `ClosureResidual`. Do not restore a
  removed import to fix it. *(deviation: skipped — no module failed for a missing import)*
- [ ] If `SignedFormula.lean` or a dependent fails because of the R2 variant, fall back to the
  report's R2 form (drop the import and the `open` line from `SignedFormula.lean`, add
  `import FormalSystem.ProofSystem.Axioms` to `Tableau.lean`), then repair the shifted citations
  with `python3 scripts/reanchor-lean-citations.py` using an explicit `--files` list and its
  `--exact` mode, run exactly once. Record the deviation; the citing files then join this phase's
  commit. *(deviation: skipped — the R2 variant built; fallback not needed)*
- [x] Regenerate the commit-blocking count surface: `bash scripts/typst-sync-check.sh --fix`, then
  `bash scripts/typst-sync-check.sh --counts-only` must exit 0.
- [x] Run the bare `bash scripts/typst-sync-check.sh`. If it reports
  `typst/generated/automation-module-map.typ` or another generated typst file as drifted, run the
  generator command it prints for that file and stage the result.
- [x] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
  then `--emit-inventory --check` must exit 0.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/check-metalogic-cycles.sh`.
  Compare against Phase 1: no new finding. A C20 finding here is repaired with the re-anchor tool
  as above before committing.
- [x] Commit the batch as one commit with an explicit file list.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Seven `.lean` files are edited and `Tableau.lean` is not. Expected line
deltas: `Core` 0, `SuccessPatterns` 0, `SignedFormula` 0, `TraceCertificate` -2,
`SubformulaProperty` -1, `Fuel` +1, `ClosureResidual` +1, net -1; confirm with
`git diff --numstat`. Citations into the four files whose lines shift number zero outside `specs/`
(grep at HEAD `75dbaedcc`); confirm by re-running the Phase 1 grep and by C20 in the `--no-build`
pass. The inventory regeneration is expected to rewrite at most the six README files listed
below, and `typst/generated/automation-module-map.typ` is expected to be unchanged because neither
Automation file changes its line count; take the actual set from `git diff --name-only` after the `--emit-inventory` run and stage
exactly that set. No further explicit Mathlib import is expected to be needed beyond the two named
(CARRIED-UNVERIFIED, from the report's 91 shadow compiles, which did not cover `BimodalToolsTest`);
the four-root build confirms it.

**Tier Justification**: The covering check is the guarded `lake build FormalSystem BimodalTest BimodalTools BimodalToolsTest`, which elaborates every importer of the seven edited modules (`suite_selection_select` returns `__FULL_SWEEP__` for all seven `.lean` paths, so no shell suite covers them), with the two generated surfaces covered by `scripts/typst-sync-check.sh` and `scripts/check-module-invariants.sh --emit-inventory --check`.

**Files to modify**:
- `FormalSystem/Automation/ProofSearch/Core.lean` - two import lines replaced
- `FormalSystem/Automation/SuccessPatterns.lean` - one import line replaced
- `FormalSystem/Metalogic/Decidability/SignedFormula.lean` - one import line replaced
- `FormalSystem/Metalogic/Decidability/TraceCertificate.lean` - two import lines removed
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - one import
  line removed
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - one import line added
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean` - one
  import line added
- `typst/generated/status.typ` - regenerated line counts
- `README.md` - regenerated inventory block, if the run changes it
- `FormalSystem/Metalogic/README.md` - regenerated inventory block, if the run changes it
- `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` - regenerated inventory
  block, if the run changes it
- `FormalSystem/README.md` - regenerated inventory block, if the run changes it
- `FormalSystem/Automation/README.md` - regenerated inventory block, if the run changes it
- `FormalSystem/Automation/ProofSearch/README.md` - regenerated inventory block, if the run changes
  it
- `typst/generated/automation-module-map.typ` - regenerated module map, if the bare typst sync
  check reports it drifted
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md` - build result,
  any added import, any deviation

**Verification**:
- The guarded four-root build is green by the guard's `result`, with zero `error:` lines and zero
  warning lines in the captured output.
- `git diff` against the Phase 1 commit shows only `import` lines changed in the seven `.lean`
  files, and no change to `Tableau.lean` (unless the recorded R2 fallback was taken).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/check-metalogic-cycles.sh`
  show no finding absent from the Phase 1 record.

---

### Phase 3: Post-Change Measurement and Final Gate [COMPLETED]

**Goal**: Measure the rebuild sets on the landed tree, run the complete gate set, and finish the
evidence record the acceptance criteria ask for.

**Tasks**:
- [x] Re-run the Phase 1 probe on the rebuilt tree and compute the same five reverse import
  closures. Record each beside its Phase 1 figure, with the termination-module count.
- [x] State the `Axioms.lean` result plainly, whatever it is. The expected outcome is no change in
  that row; the expected gains are in the `Semantics.lean`, `Syntax.lean`, `Derivation.lean` and
  `Syntax/Context.lean` rows.
- [x] Run the full unscoped guarded build:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`, verdict from the
  guard's `result`.
- [x] Run `bash scripts/check-module-invariants.sh` in full mode and require `ALL CHECKS PASSED`
  with exit status 0. This covers `lake build` (C1), the axiom baselines (C2, C14), zero structural
  `sorry` by content (C3), import resolution (C4), `file.lean:NNN` citations (C20), the exe roots
  (C25) and the warning budget (C28).
- [x] Run `bash scripts/check-metalogic-cycles.sh` and `bash scripts/typst-sync-check.sh`; each
  exits 0, or shows no finding absent from the Phase 1 record.
- [x] Confirm the sorry count is 0 by content over the seven edited files, and that `git diff`
  from the Phase 1 commit to HEAD touches no line of them other than `import` lines.
- [x] Run `bash .claude/scripts/check-task-references.sh` on each edited non-`specs/` file; each
  exits 0.
- [x] Run `bash .claude/scripts/verify-deploy.sh`. This task touches no `.claude/**` and no
  source-store path, and the deployed tree is known stale, so a red gate is judged by whether its
  findings name a file this task touched; findings that do not are listed as standing baseline.
  If the dispatch carries a batch gate deferral, record the deferral instead. *(deviation: altered — batch gate deferral recorded instead of an independent run, as the dispatch directs)*
- [x] Finish the evidence file: the before/after rebuild-set table; the edge classification table
  restated against the landed imports (each reducible edge marked removed, narrowed or kept, each
  essential edge with its declaration-level evidence); the recommendation taken and the two not
  taken (R5, R6) with reasons; the gate results.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Expected post-change figures are 520 for `Axioms.lean` (unchanged, per the
Decisions note on the R2 variant), 204 for `Semantics.lean`, 29 for `Syntax.lean`, 356 for
`Derivation.lean`, 538 for `Syntax/Context.lean`, with the termination-module counts 25, 0, 0, 23
and 23 (CARRIED-UNVERIFIED, from the report's simulation of its own R2 form; the variant here may
differ by one module in rows where `SignedFormula` is the difference). These are predictions to
test, not targets: record what the probe measures. If the `Semantics.lean` set still contains any
termination module, an import path from the subtree to Semantics survives; find it with the probe's
module graph before closing the phase.

**Files to modify**:
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md` - post-change
  rebuild sets, final edge classification, gate results

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` green by the guard's
  `result`.
- `bash scripts/check-module-invariants.sh` prints `ALL CHECKS PASSED` and exits 0.
- `bash scripts/check-metalogic-cycles.sh` and `bash scripts/typst-sync-check.sh` exit 0, or carry
  only findings recorded in Phase 1.
- Sorry count 0 by content in the seven edited files.
- `bash .claude/scripts/check-task-references.sh` exits 0 on each edited non-`specs/` file.
- `bash .claude/scripts/verify-deploy.sh` run and its result recorded, with findings split into
  those naming this task's files (none permitted) and standing baseline; or the batch deferral
  recorded.
- The evidence file holds a measured before and after figure for an `Axioms.lean` edit, the full
  edge classification, and the recommendation with reasons.
- The reverse import closure of `FormalSystem.Semantics` contains no termination module.

## Lean Challenge Statements

This plan changes import lines only. It adds no declaration and alters no statement, so there is
nothing to pin; the rationale is recorded under Decisions.

<!-- lean-challenge-statements:none -->

## Testing & Validation

- [ ] Guarded build of `FormalSystem`, `BimodalTest`, `BimodalTools` and `BimodalToolsTest` green
  with no warning lines (Phase 2).
- [x] `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the Phase 2 commit.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 (Phase 2).
- [x] Full unscoped guarded build green (Phase 3).
- [x] `bash scripts/check-module-invariants.sh` prints `ALL CHECKS PASSED`, exit 0 (Phase 3).
- [x] `bash scripts/check-metalogic-cycles.sh` shows no new finding (Phases 2 and 3).
- [x] Sorry count 0 by content in the edited files (Phase 3).
- [x] Only `import` lines differ in the seven `.lean` files (Phases 2 and 3).
- [x] Reverse import closure of `FormalSystem.Semantics` contains no termination module (Phase 3).
- [x] Before/after rebuild set for an `Axioms.lean` edit recorded with its method (Phase 3).

## Artifacts & Outputs

- `specs/804_narrow_termination_syntax_layer_fanin/plans/01_termination-syntax-fanin.md` (this file)
- `specs/804_narrow_termination_syntax_layer_fanin/evidence/01_rebuild-scope.md` (baseline,
  post-change rebuild sets, edge classification, gate results)
- `specs/804_narrow_termination_syntax_layer_fanin/summaries/01_termination-syntax-fanin-summary.md`
  (at completion)
- Modified: seven `.lean` files, import lines only (listed in Phase 2)
- Regenerated: `typst/generated/status.typ` and the module-inventory README blocks

## Rollback/Contingency

The Lean change is one commit of import-line edits plus regenerated surfaces, so the ordinary
recovery is `git revert` of that commit followed by a guarded rebuild. Nothing downstream depends
on the narrowed imports.

- **A module outside the tested set fails to build**: fix forward with an explicit import in that
  module. Do not restore a removed import.
- **One narrowing cannot be made to build**: restore that one file's original import line, keep the
  others, close Phase 2 `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record, and
  report the measured rebuild sets for what landed. R1 is the high-value edit; the others are
  independent of it.
- **An axiom baseline (C2 or C14) differs in Phase 3**: hard failure. Revert the Phase 2 commit,
  then re-apply the edits one file at a time to find which import removal changed an elaboration
  route.
- **The Semantics closure still reaches the subtree after Phase 2**: not a rollback case. Locate the
  surviving path with the probe's module graph, record it in the evidence file, and report it; a
  further narrowing outside the seven files is new scope for the user to decide.
- **Before any rollback that would discard uncommitted work**: follow
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
  including its out-of-scope override flag. Never discard uncommitted changes to reach a passing
  build; fix forward instead.
