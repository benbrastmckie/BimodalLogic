# Implementation Plan: CI parity, root collapse and publication gate

- **Task**: 637 - CI parity, root collapse and publication gate
- **Status**: [NOT STARTED]
- **Effort**: 12.5 hours
- **Dependencies**: 636 (complete)
- **Research Inputs**: specs/637_ci_parity_root_collapse_publication_gate/reports/01_ci-parity-root-collapse.md
- **Artifacts**: plans/01_ci-parity-root-collapse.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Phase 8 of the publication-refactor programme: collapse the two-level `FormalSystem` root into a
single `lake exe mk_all`-generated `FormalSystem.lean`, empty the C6 unreachable-module manifest,
wire `mk_all --check` and `lint-style-action` into CI, add a tag-triggered release workflow, adopt
the module-size and namespace-exception policy text, and close the publication gate with a
maintainer handoff. The collapse is cheap on its own but switches Mathlib's `linter.style.header`
from 1 module to 503 under CI's existing `--wfail`, so the measured 22-finding header debt must be
cleared in the same change or immediately before it. Definition of done: `lake exe mk_all --lib
FormalSystem --check` green, `scripts/module-invariants-manifest.txt` empty, the release workflow's
automatable dry-run (YAML parse plus action-pin resolution) passing, and the full
`check-module-invariants.sh` gate set green.

### Research Integration

Every phase below is grounded in `reports/01_ci-parity-root-collapse.md`, whose measurements were
taken at HEAD `657c41892`. Load-bearing findings carried into this plan:

- `mk_all` must be invoked as `--lib FormalSystem`. A bare `lake exe mk_all` errors: `BimodalTest`
  and `BimodalToolsTest` declare `srcDir = "Tests"` while `GetAllModules.getAllFiles` resolves a
  library name as a CWD-relative *directory*, and a generated `BimodalTools.lean` would import 12
  `*Main` modules whose `main` declarations cannot coexist. The other three aggregators stay
  hand-maintained under C8.
- `mk_all` emits imports only — no copyright header, no docstring. The `set_option
  linter.style.longLine false` tail is appended for `Mathlib` alone. `check-copyright-headers.sh`
  walks the `FormalSystem/` *directory*, so the repo-root file is outside its scan and the missing
  header is not a gate failure. `linter.style.longFile = 1500` is not approached (504 lines).
- `linter.style.header` gates on `isInLibraryRoot` — whether `./FormalSystem.lean` *directly*
  imports the module. Today that is one module; after the collapse it is all 503, under the
  lean-action step's existing `build-args: "--wfail"`. Measured latent debt: 22 findings (16
  docstring-not-first, 6 broad `import Lean`).
- Import lines are exempt from `linter.style.longLine` (`Style.lean:471`), so the two 101-character
  generated import lines need no module renames. Risk checked and cleared.
- The C6 manifest holds **14** live entries, not the 12 the task description implies. Nine clear
  automatically once the generated root imports everything; two clear as a side effect; one is a
  vestigial import line; one needs a module split; one needs the `#eval` decision.
- `lint-style` costs 362 findings post-collapse across 87 files: 258 unicode-allowlist findings on
  this library's own notation and 103 trailing-whitespace findings. The whitespace half is free via
  `--fix`; the unicode half is settled by the recorded decision below.
- The publication-gate untracking item is **already done** in commit `6ac3b3844`; `.gitattributes`
  has never existed and `CITATION.cff` already reads `version: "1.0.0"`. What remains is the
  maintainer's `v1.0.0` tag alone.
- C16 re-measured at HEAD: 170 findings across 13 of 17 roots, superseding the script's recorded
  `179`/14-root table. C28's warning budget is 0 warnings across 0 files with every tooling root's
  trace warm, so the recorded reason for withholding `--wfail` from the two tooling CI steps no
  longer holds — and that block names exactly this condition as its revision trigger.
- All eight `unrelated` namespace-audit files already carry a written reason and are sound; renaming
  any of them would touch declaration moves, importers, external FQN citations and the pinned
  `#print axioms` baselines that appear twice each in `check-module-invariants.sh`.

### Prior Plan Reference

No prior plan. This is artifact round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context and no `ROADMAP.md` was consulted. The
programme record this task advances is `docs/development/PUBLICATION_REFACTOR.md` (Phase 8,
follow-up H), read through the research report rather than as a roadmap artifact.

### Recorded Decisions Carried In

| Decision | Source | Disposition |
|---|---|---|
| Unicode text linter | `.decisions.json`, cycle 1, non-blocking | Disable `linter.unicodeLinter` in `lakefile.toml` `[leanOptions]` with a recorded reason; adopt every other lint-style text linter. **Settled — do not re-ask.** |
| `mk_all` scope | Research, structural | `--lib FormalSystem` only. Not a preference. |
| `mk_all` harness check shape | Research | A build-free Python scanner inside `check-module-invariants.sh`, so CI's `--no-build` pass actually runs it; `lake exe mk_all --check` remains the full-mode authoritative cross-check. |
| `check-copyright-headers.sh` | Research, measured | **Kept, not retired.** It is the only header gate for the 12 `BimodalTools/*Main.lean` roots and the 65 files under `Tests/`, which `linter.style.header` structurally cannot reach. Its stale `WHY THIS EXISTS` premise is corrected instead. |
| Namespace exceptions | Research, measured | All eight kept, none renamed; the three lacking the standard heading get it, and an eight-row index lands in `ORGANISATION.md`. |
| `ENFORCE_C16_ROOTS` | Research | Stays `0`. Only the stale recorded measurement is corrected. |
| `specs/` disposition | User, recorded in the task description | Stays tracked and published permanently as the development record. Do not untrack, gitignore, or move it. |

## Goals & Non-Goals

**Goals**:
- A single repo-root `FormalSystem.lean` generated byte-for-byte by `lake exe mk_all --lib
  FormalSystem`, with `FormalSystem/FormalSystem.lean` absorbed and deleted.
- Zero `linter.style.header` findings under `lake build --wfail` with the generated root in place.
- `scripts/module-invariants-manifest.txt` empty, with every previously-manifested module wired into
  a build closure.
- A new enforced invariant (next free ID: **C31**) asserting the generated root is byte-current,
  plus its CI step and its `CI_CD_PROCESS.md` runtime-budget row.
- `lint-style-action` wired and green: trailing whitespace fixed, `linter.unicodeLinter` disabled
  with a recorded reason.
- `.github/workflows/release.yml` with `push: tags: ['v*']` and an explicit `workflow_dispatch`.
- `--wfail` adopted on the two tooling build steps, with C28's decision block rewritten to record
  that its stated revision trigger fired.
- `ORGANISATION.md` carrying the module-size policy, the eight-row namespace-exception index, and a
  corrected `specs/` row.
- The publication gate recorded as satisfied, with the residue handed to the maintainer.

**Non-Goals**:
- The `v1.0.0` tag itself and the `workflow_dispatch` release run on the maintainer's account.
  Agents must not push tags or create releases (`rules/pr-prohibition.md`).
- The C16 burndown (170 findings, 67 of them in `BimodalTest` alone). Not this task's scope.
- The size splits of `GapDetection.lean` (5,094 lines) and `SplitPoint.lean` (4,906) — Phase 9 of
  the programme. This task adopts the *policy text* only.
- The Lean module system migration (programme Phase 9).
- Renaming any of the eight namespace-exception modules.
- Enabling `linter.checkInitImports` (duplicates C24) or `linter.allScriptsDocumented` (would gate
  `scripts/README.md`, which is task 644's declared territory this cycle). Both stay off by default;
  the plan records the choice rather than enabling by accident.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The collapse turns CI red via `linter.style.header` (22 measured findings, `--wfail` already live) | H | H | Phase 1 clears all 22 *before* Phase 2 lands the collapse, measured against the real linter with a temporarily generated root rather than a mirror scanner |
| Nine newly-reachable modules (80 declarations) enter `runLinter FormalSystem`'s enforced C16 half, which is at 0 today | H | M | Run `lake exe runLinter FormalSystem` inside Phase 2, before committing; any new finding is fixed, not nolisted |
| Same nine modules enter `--wfail` and C24's `checkInitImports` closure for the first time | H | M | Phase 2 verification is a full guarded `lake build --wfail` plus `lake exe checkInitImports` |
| **Territory collision on `scripts/check-module-invariants.sh` and `docs/development/MODULE_INVARIANTS.md`** — task 643 declares both this same cycle | H | H | Phases 5 and 6 re-read each file immediately before editing, stage only this task's own hunks (never a directory or glob `git add`), and rebase onto 643's landed changes rather than reverting them. On a foreign commit or foreign uncommitted modification, STOP and report per `context/contracts/territory.md` |
| **Territory collision on `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md`** — task 614 declares both this cycle, and both carry `FormalSystem/FormalSystem.lean` prose the collapse invalidates | H | H | Same protocol inside Phase 2's atomic batch; the four free README/doc references can be written first. C5/C12/C13 fail on any missed reference, so the sweep is gated, not optional |
| `lint-style-action` lands permanently red | M | L | Phase 7 fixes the whitespace half and applies the recorded unicode decision *before* wiring the action; the action is never wired on an un-green tree |
| The release workflow cannot be self-certified locally (`actionlint`, `act`, `yamllint` all absent) | M | H | The automatable half is a YAML parse plus action-pin resolution; the `workflow_dispatch` green run is an explicit maintainer handoff item, not a self-certification |
| Wiring `DerivationBenchmark` in makes `lake test` print the whole benchmark table | M | M | Delete the five top-level `#eval` lines (the benchmark `def`s stay callable); C27's allow-list is unaffected, its 54 entries all being in `MainResults.lean` |
| `def version` silently disappears with the absorbed file | L | H | Relocate to a new `FormalSystem/Version.lean` reachable from the generated root, bumped to `"1.0.0"` to agree with `CITATION.cff`; reconcile `VERSIONING.md`'s "version in lakefile.toml" instruction, which names a field that does not exist |
| `--wfail` on the two tooling steps is adopted on a trace-scan alone and the runner disagrees | M | L | Phase 6 verifies with an actual `--wfail` build of both tooling roots locally, not with `warning-budget.py` output alone |
| A generated root that drifts silently between generation and commit | M | L | C31 (Phase 5) is the durable gate; its deliberate negative test is required by `MODULE_INVARIANTS.md`'s "Adding a Check" procedure |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 8, 9 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 |
| 4 | 4, 6 | 3; 5 |
| 5 | 7 | 6 |
| 6 | 10 | 4, 6, 7, 8, 9 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Clear the latent header-linter debt [NOT STARTED]

**Goal**: Reach zero `linter.style.header` findings across `FormalSystem/` so that the collapse in
Phase 2 can land under CI's existing `--wfail` without turning the build red.

**Tasks**:
- [ ] Copy the current `FormalSystem.lean` to a scratch file outside the repo (the session scratchpad),
      and record its `sha256sum`.
- [ ] Run `lake exe mk_all --lib FormalSystem` to put a temporary generated root in place. This is a
      measurement scaffold, not the Phase 2 deliverable.
- [ ] Run `lake build --wfail` and collect every `linter.style.header` diagnostic from the real
      compiler. Do not re-implement the research agent's mirror scanner; the linter itself is
      authoritative.
- [ ] Fix each docstring-position finding by moving the module docstring above the offending command
      (`assert_not_exists`, `namespace`, or `set_option autoImplicit false`). Expected shapes: 6 files
      under `Semantics/` and `MinusLanguage/` with `assert_not_exists` first; 9 files, mostly under
      `Metalogic/Expressiveness/Kamp/EANegationFix/`, with `namespace` first; and
      `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` with `set_option autoImplicit false`
      first.
- [ ] Fix each broad-import finding by **narrowing** `import Lean` to the specific `Lean.*` modules the
      file actually uses. Narrowing is preferred to suppression: it is what the linter asks for and it
      costs no `set_option`. If narrowing proves infeasible for a given module, fall back to a
      declaration-scoped suppression carrying a reason at the site (C29 requires the reason; C30
      forbids the blanket form) and record why in the phase notes.
- [ ] Re-run `lake build --wfail` with the temporary root still in place and confirm zero
      `linter.style.header` findings.
- [ ] Restore the original root by copying the scratch file back (`cp`), and verify with
      `sha256sum -c` against the recorded hash. Do **not** use `git checkout --`/`git restore` —
      `rules/git-workflow.md` forbids discarding working-tree changes on a dirty tree.
- [ ] Confirm `git status --short` shows only the header-fix files changed, then run `lake build` once
      more under the restored two-level root to confirm the fixes are harmless there too.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 22 findings across 23 files (16 docstring-position, 6 broad `import Lean`),
measured at HEAD `657c41892`. Confirm by the `lake build --wfail` diagnostic count with the temporary
generated root in place, before any edit; if the count differs from 22, record the actual figure and
proceed against it rather than the hypothesis.

**Files to modify**:
- `FormalSystem/Tactic/Attr.lean`, `FormalSystem/Tactic/Meta.lean`,
  `FormalSystem/Automation/Tactics/{Deduction,Search,UserTactics}.lean`,
  `FormalSystem/Metalogic/Expressiveness/EFGameTactics.lean` - narrow `import Lean`
- `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` - move docstring above `set_option`
- The remaining 15 docstring-position files, enumerated from the linter output at phase start
- `FormalSystem.lean` - temporarily generated and then restored byte-for-byte; **not** a deliverable
  of this phase

**Verification**:
- `lake build --wfail` emits zero `linter.style.header` findings with the temporary generated root
- `sha256sum -c` confirms `FormalSystem.lean` restored byte-for-byte
- `git status --short` lists only the header-fix files
- `lake build` green under the restored two-level root

---

### Phase 2: Collapse the root and sweep every reference [NOT STARTED]

**Goal**: Replace the two-level root with one `mk_all`-generated `FormalSystem.lean`, rehouse
`def version`, and update every prose reference the collapse invalidates — as one atomic change, since
the intermediate states are red by construction.

**Tasks**:
- [ ] Re-read `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` immediately before
      touching them: **task 614 declares both in its `file_scope` this same `/orchestrate` cycle.** If
      614 has already landed changes, rebase this phase's edits onto them. On a foreign commit or
      foreign uncommitted modification, check `git log` to confirm the work is not your own, then STOP
      and report rather than proceeding.
- [ ] Create `FormalSystem/Version.lean`: an Apache-headered, module-docstringed module in
      `namespace FormalSystem` carrying `def version : String := "1.0.0"`, bumped from `"0.1.0"` to
      agree with `CITATION.cff`. The docstring records that this is the single definition site and
      that `VERSIONING.md`'s release checklist points here.
- [ ] Delete `FormalSystem/FormalSystem.lean`. This is a precondition, not a nicety: `mk_all`'s
      `allModules.erase ml.lean` step erases the path `FormalSystem.lean`, which the walk of
      `FormalSystem/` never produces, so the file would otherwise be emitted as
      `import FormalSystem.FormalSystem`.
- [ ] Run `lake exe mk_all --lib FormalSystem` to generate the new root. Do not hand-edit the result,
      and do not add a copyright header or docstring to it — `mk_all --check` compares byte-for-byte
      and any addition would make the new C31 gate permanently red.
- [ ] Rewrite the four free prose references that explain the self-named indirection as
      "load-bearing": `FormalSystem/{Plus,Minus,Star}Language/README.md` and
      `docs/development/DIRECTORY_README_STANDARD.md`. These are substantive rewrites, not path swaps.
- [ ] Rewrite the three coordinated references in `FormalSystem/README.md` (×1) and
      `FormalSystem/Metalogic/README.md` (×2), under the protocol above.
- [ ] Leave `docs/development/PUBLICATION_REFACTOR.md`'s three occurrences as-is: they are programme
      prose describing this very work.
- [ ] Run `lake build --wfail`, `lake exe runLinter FormalSystem`, and `lake exe checkInitImports`
      before committing. The nine newly-reachable modules enter all three closures for the first time;
      any new C16 finding is **fixed**, never added to `scripts/nolints.json`.
- [ ] Stage only this task's own hunks — an explicit multi-file `git add -- <files>` list, never a
      directory or glob pathspec.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 14 occurrences of `FormalSystem/FormalSystem.lean` or `FormalSystem.FormalSystem`
outside `specs/`, of which 3 are in `scripts/check-module-invariants.sh` (deferred to Phase 6), 3 are
programme prose left as-is, and 8 are rewritten here. The generated root is expected at ~504 lines,
`FormalSystem.Automation` … `FormalSystem.Theorems.TemporalDerived`. Confirm both by
`grep -rn 'FormalSystem/FormalSystem\.lean\|FormalSystem\.FormalSystem' --exclude-dir=specs
--exclude-dir=.lake .` and `wc -l FormalSystem.lean` at phase start and phase end.

**Files to modify**:
- `FormalSystem.lean` - regenerated, import-only
- `FormalSystem/FormalSystem.lean` - deleted
- `FormalSystem/Version.lean` - new; `def version : String := "1.0.0"`
- `FormalSystem/{Plus,Minus,Star}Language/README.md` - rewrite the indirection prose
- `docs/development/DIRECTORY_README_STANDARD.md` - rewrite the indirection prose
- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` - **task 614's territory**; rewrite
  under the coordination protocol

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `lake build --wfail` green, including the nine newly-reachable modules
- `lake exe runLinter FormalSystem` still reports zero un-nolisted findings
- `lake exe checkInitImports` green
- `bash scripts/check-module-invariants.sh --no-build` passes C5, C12 and C13 (no dangling reference
  to the absorbed module)
- `grep` for the absorbed path returns only the three `PUBLICATION_REFACTOR.md` occurrences and the
  three `check-module-invariants.sh` occurrences

---

### Phase 3: Empty the auto-clearing half of the C6 manifest [NOT STARTED]

**Goal**: Remove the eleven manifest entries that the generated root either clears outright or clears
as a side effect, and wire the two `BimodalTest` modules whose sole reason for exclusion has gone.

**Tasks**:
- [ ] Re-measure the manifest before editing: run `bash scripts/check-module-invariants.sh --no-build`
      and read C6's own count. The task description implies 12 entries and the research measured 14 at
      HEAD; task 632 already deleted one line. Work against the measured figure.
- [ ] Delete manifest entries 1–9 — `FormalSystem.Metalogic.{Core,Bundle,SoundnessLemmas}`,
      `FormalSystem.Metalogic.SoundnessLemmas.CoValidity`,
      `…Kamp.NfMultiAnchorBridge.OuterGateFaithful`, and
      `…Decidability.BiLasso.{Extend,Successor,Orbit,Agreement}`. All nine are now reachable from the
      generated root; C6 fails on an entry naming a reachable module, so these are forced deletions,
      not optional tidying.
- [ ] Confirm no cycle was introduced: the three importer-less sibling aggregators are kept so that no
      *content* module imports an aggregator its own contents reach. Nothing imports the root, so the
      root importing them is safe. Verify by `lake build` rather than by inspection.
- [ ] Add `import BimodalTest.Metalogic.PeriodicExtensionAxiomTest` and
      `import BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest` to `Tests/BimodalTest.lean`,
      then delete manifest entries 10 and 11. Their only recorded reason for exclusion was that
      importing them would make `BiLasso.Orbit` / `BiLasso.Successor` reachable — which they now are
      regardless.
- [ ] Drop the now-unnecessary recorded fix for entry 5 (the one import line in
      `NfMultiAnchorBridge.lean`) from the manifest's comment block if it names one.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 11 of the 14 measured manifest entries clear in this phase, leaving 3 for
Phase 4. Confirm by C6's reported count before and after, and by `grep -cvE '^\s*#|^\s*$'
scripts/module-invariants-manifest.txt`.

**Files to modify**:
- `scripts/module-invariants-manifest.txt` - delete 11 entries
- `Tests/BimodalTest.lean` - add 2 imports

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` passes C6 with 3 remaining entries
- `lake build --wfail` and `lake test` green
- `lake test` output carries no new benchmark noise (the `DerivationBenchmark` `#eval`s are Phase 4)

---

### Phase 4: Empty the remaining three C6 manifest entries [NOT STARTED]

**Goal**: Clear the last three manifest entries — one vestigial import, one module split, and the
`DerivationBenchmark` `#eval` decision — leaving the manifest empty.

**Tasks**:
- [ ] `BimodalToolsTest.ProofFirstTests`: delete the vestigial
      `import BimodalTools.ProofFirstGeneratorMain` from
      `Tests/BimodalToolsTest/ProofFirstTests.lean`. Confirm first that nothing in the file references
      `exportToJsonl`, `writeJsonl`, `parseAtoms`, `parseForwardConfig` or `parseOutputPath`. Then wire
      the module into `Tests/BimodalToolsTest.lean` and delete its manifest entry.
- [ ] `BimodalToolsTest.FormulaMutatorTest`: extract `ContrastivePair` and the mutator logic from
      `BimodalTools/ContrastiveGeneratorMain.lean` into a new `BimodalTools/ContrastiveGenerator.lean`,
      leaving `ContrastiveGeneratorMain.lean` as a thin `main` that imports it. This mirrors the
      existing `DatasetGeneratorMain` / `DatasetGenerator` pair, which is the precedent shape. Add the
      new module to the hand-maintained repo-root `BimodalTools.lean` aggregator (it carries no `main`,
      so the double-`main` constraint is not engaged), re-point
      `Tests/BimodalToolsTest/FormulaMutatorTest.lean` at it, wire the test into
      `Tests/BimodalToolsTest.lean`, and delete the manifest entry.
- [ ] `BimodalTest.ProofSystem.DerivationBenchmark`: delete the five top-level `#eval` lines from
      `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`, leaving the benchmark `def`s callable.
      This keeps the compile coverage and removes the `lake test` noise that was the recorded reason
      for exclusion, and needs no archive. Wire the module into `Tests/BimodalTest.lean` and delete the
      manifest entry. Record in the module docstring that the `#eval`s were removed deliberately and
      how to invoke the benchmark by hand.
- [ ] Confirm `scripts/module-invariants-manifest.txt` now holds zero live entries.
- [ ] Verify B3 stays green: `FormalSystem` must still never import `BimodalTools`. The new
      `ContrastiveGenerator.lean` lives on the tooling side only.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 3 manifest entries remain at phase start and 0 at phase end; the
`ContrastiveGeneratorMain` split moves exactly the `ContrastivePair` type and the mutator
declarations. Confirm the manifest count with `grep -cvE '^\s*#|^\s*$'` and the split's scope by
building both `BimodalTools` and `BimodalToolsTest` plus `lake exe contrastive_generator --help` (or
the executable's own no-side-effect invocation).

**Files to modify**:
- `Tests/BimodalToolsTest/ProofFirstTests.lean` - delete the vestigial import
- `BimodalTools/ContrastiveGenerator.lean` - new; extracted logic
- `BimodalTools/ContrastiveGeneratorMain.lean` - reduced to a thin `main`
- `BimodalTools.lean` - add the new module
- `Tests/BimodalToolsTest/FormulaMutatorTest.lean` - re-point imports
- `Tests/BimodalToolsTest.lean` - wire 2 modules
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` - delete 5 top-level `#eval`s
- `Tests/BimodalTest.lean` - wire 1 module
- `scripts/module-invariants-manifest.txt` - delete the last 3 entries

**Verification**:
- `scripts/module-invariants-manifest.txt` holds zero live entries; C6 reports an empty manifest
- `bash scripts/check-module-invariants.sh` (full mode) passes C6 and B3
- `lake build BimodalTools`, `lake build BimodalToolsTest`, `lake test` all green
- `lake test` prints no benchmark table
- `python3 scripts/lake_targets.py exe-roots` still resolves, and `lake build
  BimodalTools.ContrastiveGeneratorMain` succeeds

---

### Phase 5: Add the C31 generated-root invariant and its CI step [NOT STARTED]

**Goal**: Make the byte-currency of the generated root a durable, enforced, build-free invariant that
CI's `--no-build` pass actually runs.

**Tasks**:
- [ ] Re-read `scripts/check-module-invariants.sh` and `docs/development/MODULE_INVARIANTS.md`
      immediately before editing: **task 643 declares both in its `file_scope` this same cycle.** Apply
      the territory protocol — rebase onto 643's landed changes, stage only this task's hunks, STOP and
      report on any foreign commit or foreign uncommitted modification.
- [ ] Confirm C30 is still the highest check ID in the script before claiming C31.
- [ ] Add check **C31** to `scripts/check-module-invariants.sh` as a build-free Python scanner: walk
      every `.lean` file under `FormalSystem/`, sort, prefix each with `import ` and the dotted module
      path, join with newlines plus a trailing newline, and compare byte-for-byte against
      `FormalSystem.lean`. This is the same reasoning that made C28 a trace-scan rather than a `lake`
      call — a check that shells out to `lake` would join the documented "Known Not-in-CI Gaps" list
      alongside C2/C6/C24.
- [ ] Ship C31 **enforced with no soft window**, on the C24/C25/C26 precedent: it is green the day it
      lands. Give it an `ENFORCE_C31` variable defaulting to `1` for consistency with its neighbours.
- [ ] Write the check's header block in the file's established style: what it asserts, why the scanner
      form was chosen over `lake exe mk_all --check`, and that `lake exe mk_all --lib FormalSystem
      --check` is the full-mode authoritative cross-check.
- [ ] Run the deliberate negative test `MODULE_INVARIANTS.md`'s "Adding a Check" procedure requires:
      add a stray `.lean` file under `FormalSystem/`, observe `FAIL` **and** a non-zero script exit,
      remove it, observe `PASS`. Record both observations.
- [ ] Add the C31 row to `docs/development/MODULE_INVARIANTS.md` (643's territory — same protocol).
- [ ] Add the CI step to `.github/workflows/ci.yml` following `CI_CD_PROCESS.md`'s "Wiring a New Check
      Script" convention: step `name:` carrying the exact invocation, `set -euo pipefail`,
      `::group::`/`::endgroup::` wrapping, appended directly before "Report results". The scanner is
      pure `python3`, so it carries no cache-warm placement constraint of its own.
- [ ] Add the step's row to `CI_CD_PROCESS.md`'s runtime budget table and **re-sum both columns** — the
      table's own instruction requires it.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: C31 is the next free check ID (C30 is the current maximum). Confirm with
`grep -nE '^# --- C[0-9]+' scripts/check-module-invariants.sh | tail -1` and
`grep -n 'ENFORCE_C[0-9]*=' scripts/check-module-invariants.sh` before writing.

**Files to modify**:
- `scripts/check-module-invariants.sh` - **task 643's territory**; add C31 and its `ENFORCE_C31` flag
- `docs/development/MODULE_INVARIANTS.md` - **task 643's territory**; add the C31 row
- `.github/workflows/ci.yml` - add the C31 CI step before "Report results"
- `docs/development/CI_CD_PROCESS.md` - add the runtime-budget row and re-sum

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` runs C31 and reports `PASS`
- Negative test: a stray `FormalSystem/_Scratch.lean` produces `FAIL` and a non-zero exit; removing it
  restores `PASS`
- `lake exe mk_all --lib FormalSystem --check` agrees with C31's verdict
- The extracted `run:` body of the new CI step executes green locally
- `CI_CD_PROCESS.md`'s budget sums equal the sum of their own rows

---

### Phase 6: Correct the stale invariant records and adopt `--wfail` on the tooling steps [NOT STARTED]

**Goal**: Bring `check-module-invariants.sh`'s recorded measurements and decision blocks into agreement
with the tree, and act on C28's own stated revision trigger.

**Tasks**:
- [ ] Re-read `scripts/check-module-invariants.sh` immediately before editing (**task 643's
      territory**; same protocol as Phase 5, and Phase 5's own edits must already be in the tree).
- [ ] Remove the dead `C8_ALLOW_SELFNAMED` entry `"FormalSystem/FormalSystem.lean"` and rewrite the
      preceding comment paragraph that justifies it. The `Semantics/Extension/Extension.lean` entry
      stays.
- [ ] Reduce B3's two-root loop (`for f in FormalSystem.lean FormalSystem/FormalSystem.lean`) to the
      single surviving root. The `[ -f "$f" ] || continue` guard means the current form degrades safely
      rather than failing, so this is correctness of the record, not a fix for a live break.
- [ ] Replace C16's recorded `179`-findings/14-root table with the re-measured **170 findings across 13
      of 17 roots**, and correct the `BimodalTest` row from `85` to `67`. The stale table predates the
      `BimodalTools`/`BimodalToolsTest` split; a recorded number disagreeing with the tree is precisely
      the defect class C14 exists to catch. Re-measure at the phase's own HEAD rather than transcribing
      the research figures, and use the measured values.
- [ ] Leave `ENFORCE_C16_ROOTS` at `0` and record the decision in its comment block: 170 findings, 67
      of them in `BimodalTest` alone, is not a burndown this task owns.
- [ ] Verify the `--wfail` claim directly: run `lake build BimodalTools --wfail` and
      `lake build BimodalToolsTest --wfail` locally and confirm both are green. Do not rely on
      `warning-budget.py`'s trace scan alone.
- [ ] Add `--wfail` to the two tooling CI build steps in `.github/workflows/ci.yml` (`lake build
      BimodalTools`, `lake build BimodalToolsTest`) and rewrite their inline comments, which currently
      state the tooling tree carries warnings the library does not.
- [ ] Rewrite C28's decision block to record that its stated revision trigger has fired, with the
      measured evidence and the date. Correct the `ENFORCE_C28` header's stale "The floor is 7, not 0"
      note — `scripts/warning-budget.txt` reads `Baseline total: 0 warning(s) across 0 file(s)`.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: C16 stands at 170 findings across 13 of 17 roots, and the tooling tree at 0
compiler warnings. Both are research-time measurements at HEAD `657c41892` and both must be
**re-measured in this phase** — Phases 2–4 added nine modules to `FormalSystem`'s closure and split
`ContrastiveGeneratorMain`, either of which can move these numbers. Confirm with
`lake exe runLinter <each lakefile root>` and `python3 scripts/warning-budget.py`, and record the
figures actually observed.

**Files to modify**:
- `scripts/check-module-invariants.sh` - **task 643's territory**; C8 allow-list, B3 loop, C16 table,
  C28 decision block, `ENFORCE_C28` header note
- `.github/workflows/ci.yml` - add `--wfail` to the two tooling build steps; rewrite their comments

**Verification**:
- `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` both green
- `bash scripts/check-module-invariants.sh` (full mode) green, with C16 and C28 reporting numbers that
  match their own recorded tables
- `grep` finds no remaining reference to `FormalSystem/FormalSystem.lean` in
  `scripts/check-module-invariants.sh`
- The extracted `run:` bodies of both modified CI steps execute green locally

---

### Phase 7: Adopt `lint-style-action` [NOT STARTED]

**Goal**: Land `lake exe lint-style` as a green CI gate, with the trailing-whitespace debt cleared and
the unicode linter disabled per the recorded decision.

**Tasks**:
- [ ] Re-measure with `lake exe lint-style` against the collapsed root and record the finding count and
      breakdown before changing anything.
- [ ] Run `lake exe lint-style --fix` to clear the trailing-whitespace findings. Review the resulting
      diff before staging — `--fix` touches whatever it finds, so the diff must be confirmed to be
      whitespace-only.
- [ ] Apply the recorded decision: add `weak.linter.unicodeLinter = false` to `lakefile.toml`'s
      `[leanOptions]` block with a comment recording *why* — this library's own notation (`⟐` the
      limit-closure diamond ×115, `⃗` vector arrows ×75, `⟺` ×28, `Ĝ` ×23) is documented and
      load-bearing, and Mathlib's allowlist is Mathlib-specific. Cross-reference the lint-suppression
      policy in `docs/development/LEAN_STYLE_GUIDE.md`, whose permanent-opt-out list this joins.
- [ ] Add the opt-out to `LEAN_STYLE_GUIDE.md`'s permanent opt-out list, matching the existing entries'
      shape (the `linter.hashCommand` test-library opt-out is the model).
- [ ] Confirm `lake exe lint-style` now exits 0. Do **not** wire the CI step until it does — a wired
      action on an un-green tree lands a permanently-red gate.
- [ ] Wire `leanprover-community/lint-style-action` into `.github/workflows/ci.yml`, appended directly
      before "Report results", with a pinned action version. Record in the step's comment that
      `scripts/nolints-style.txt` is the per-project exception file and that it deliberately does not
      exist (the tool warns and proceeds with an empty exception set).
- [ ] Record, in the same step comment, that `linter.checkInitImports` (duplicates C24 /
      `lake exe checkInitImports`) and `linter.allScriptsDocumented` (would gate `scripts/README.md`,
      task 644's declared territory this cycle) stay at their default `false`, so that a future reader
      sees the choice rather than an accident.
- [ ] Add the step's row to `CI_CD_PROCESS.md`'s runtime budget table and re-sum.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 362 findings across 87 files at research time — 258 unicode, 103 trailing
whitespace, 1 other. Re-measure with `lake exe lint-style` at phase start: Phase 1's docstring moves
and Phase 2's regenerated root both change the scanned text. Work against the observed figures.

**Files to modify**:
- `lakefile.toml` - `weak.linter.unicodeLinter = false` with a recorded reason
- `docs/development/LEAN_STYLE_GUIDE.md` - add the permanent opt-out entry
- `.github/workflows/ci.yml` - wire `lint-style-action` before "Report results"
- `docs/development/CI_CD_PROCESS.md` - budget row and re-sum
- Whatever files `lint-style --fix` touches for trailing whitespace (diff reviewed before staging)

**Verification**:
- `lake exe lint-style` exits 0
- The `--fix` diff contains only trailing-whitespace removals
- `lake build --wfail` still green after the `lakefile.toml` change (the option is `weak.`-prefixed, so
  an unrecognised name is a no-op rather than an error — confirm the name is in fact recognised by
  observing the finding count drop)
- `bash scripts/check-module-invariants.sh` green, including C29/C30 (the opt-out is a lakefile option,
  not an in-source `set_option`, so neither should engage — confirm rather than assume)

---

### Phase 8: Add the tag-triggered release workflow [NOT STARTED]

**Goal**: A `.github/workflows/release.yml` the maintainer can exercise without creating a throwaway
tag, with the automatable half of its dry-run passing locally.

**Tasks**:
- [ ] Model the new workflow on `.github/workflows/docs.yml`, the in-repo precedent for a non-CI
      workflow, including its prerequisite-checking header style.
- [ ] Trigger on `push: tags: ['v*']` **plus** an explicit `workflow_dispatch`, so the maintainer can
      run it without a throwaway tag. The `workflow_dispatch` path must be a real, complete path, not a
      stub.
- [ ] Build and test the library at the tagged commit, then produce the release artifacts. Keep the job
      minimal and honest: what it publishes must be what the repository can actually produce.
- [ ] Pin every referenced action to a specific version, matching `ci.yml`'s and `docs.yml`'s
      convention.
- [ ] Write a header comment recording that `actionlint`, `act` and `yamllint` are unavailable in this
      environment, what the local dry-run therefore does and does not certify, and that the first green
      `workflow_dispatch` run is a maintainer step.
- [ ] Run the automatable dry-run: `python3 -c "import yaml,sys;
      yaml.safe_load(open('.github/workflows/release.yml'))"` for the parse, and resolve every action
      pin (via `gh`, which is available locally) to confirm each reference exists at the pinned
      version.
- [ ] **Do not** push a tag, create a release, or trigger the workflow. `rules/pr-prohibition.md`
      forbids all three; they belong to Phase 10's maintainer handoff.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: `actionlint`, `act` and `yamllint` are all absent locally while `gh` is present.
Confirm with `command -v actionlint act yamllint gh` at phase start; if any linter turns out to be
available, use it and widen the dry-run accordingly.

**Files to modify**:
- `.github/workflows/release.yml` - new

**Verification**:
- `yaml.safe_load` parses the file without error
- Every action pin resolves to an existing published version
- `git log` and `git tag` confirm no tag was created and nothing was pushed
- The workflow's `on:` block carries both `push: tags: ['v*']` and `workflow_dispatch`

**Note on the acceptance criterion**: the task's "release workflow dry-run passes" is satisfied here
only in its automatable half. The green `workflow_dispatch` run on the maintainer's account is
recorded as a handoff item in Phase 10, not self-certified.

---

### Phase 9: Adopt the policy text and consolidate the namespace exceptions [NOT STARTED]

**Goal**: Land the module-size policy, the namespace-exception index, and the documentation
corrections the research measured as factually wrong.

**Tasks**:
- [ ] Add a module-size subsection to `ORGANISATION.md` adopting cslib's rule: split along dependency
      seams, never to satisfy a line count. Name the two files currently over 4,500 lines —
      `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` (5,094) and
      `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` (4,906) — re-measuring both
      counts rather than transcribing them, and point at the existing `linter.style.longFile = 1500`
      in-source baselines as the mechanical half.
- [ ] Fix `ORGANISATION.md`'s "Everything else" table row reading
      `| `specs/` | Task-management artefacts; not part of the deliverable |`. It contradicts the
      recorded user decision that `specs/` stays tracked and is published permanently as the project
      development record.
- [ ] Add the eight-row namespace-exception index to `ORGANISATION.md` as the single consolidated
      record: `ForMathlib/Order/PFilter` (`Order.PFilter`), `BXCanonical/Chronicle/
      ChronicleRealExtension` (`…Metalogic.Bundle`), `Decidability/BiLasso/Periodic`
      (`…Decidability.Periodic`), `WeakCanonical/DenseModelSurgery/ChronicleInstance` and
      `WeakCanonical/RealModel/ChronicleRealFlow` (both `…BXCanonical.Chronicle`),
      `Semantics/FrameClassValidity` (`FormalSystem.ProofSystem`), `Tactic/Meta`
      (`FormalSystem.Automation`), `Theorems/DeductionTheorem` (`FormalSystem.Metalogic.Core`). Re-run
      `python3 scripts/measure-refactor-partitions.py namespace-audit` to confirm the set is still
      exactly eight before writing the table.
- [ ] Add the standard `## Recorded namespace exception` heading to the three module docstrings that
      carry a reason in prose but lack the heading:
      `FormalSystem/ForMathlib/Order/PFilter.lean`, `FormalSystem/Tactic/Meta.lean`,
      `FormalSystem/Theorems/DeductionTheorem.lean`. Rename nothing.
- [ ] Rewrite `scripts/check-copyright-headers.sh`'s `WHY THIS EXISTS` block. Its stated premise —
      "This project's lakefile sets `srcDir := "FormalSystem"`, so `./FormalSystem.lean` does not
      exist" — is factually wrong and becomes more so after the collapse. Replace it with the measured
      surviving coverage gap: post-collapse `linter.style.header` subsumes this script for all 503
      `FormalSystem` modules and is strictly stronger there, but structurally cannot reach the 12
      `BimodalTools/*Main.lean` roots (not imported by `BimodalTools.lean`, and cannot be) or anything
      under `Tests/` (`./BimodalTest.lean` does not exist and will not, since `srcDir = "Tests"`). The
      script remains the only header gate for those 77 files. Keep the CI step unchanged.
- [ ] Reconcile `docs/development/VERSIONING.md`: its release checklist says "Update version in
      `lakefile.toml`", naming a field `lakefile.toml` does not have. Point it at
      `FormalSystem/Version.lean` instead, and at `CITATION.cff`.
- [ ] Create a minimal `CHANGELOG.md` seeded with the `1.0.0` entry, or — if the maintainer's
      preference is unknown — correct `VERSIONING.md`'s five references to a file that does not exist.
      Prefer creating the file: `VERSIONING.md`'s release process, `CITATION.cff`'s `1.0.0`, and the
      publication gate all assume one. Record the choice made.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 8 `unrelated` namespace-audit files, 3 of them lacking the standard heading; 2
files over 4,500 lines; 5 `CHANGELOG.md` references in `VERSIONING.md`. Confirm each with
`measure-refactor-partitions.py namespace-audit`, `wc -l` over `FormalSystem/`, and
`grep -c CHANGELOG docs/development/VERSIONING.md` respectively, before writing any count into prose.

**Files to modify**:
- `ORGANISATION.md` - module-size policy, corrected `specs/` row, namespace-exception index
- `FormalSystem/ForMathlib/Order/PFilter.lean`, `FormalSystem/Tactic/Meta.lean`,
  `FormalSystem/Theorems/DeductionTheorem.lean` - add the `## Recorded namespace exception` heading
- `scripts/check-copyright-headers.sh` - rewrite the `WHY THIS EXISTS` block
- `docs/development/VERSIONING.md` - point the release checklist at `FormalSystem/Version.lean`
- `CHANGELOG.md` - new (or `VERSIONING.md`'s references corrected instead)

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` green, including C14's status-claim tripwires
  and C9's task-number scan over `ORGANISATION.md` and `docs/`
- `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` still green (the header
  rewrite is comment-only; confirm no behavioural change)
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` green
- `measure-refactor-partitions.py namespace-audit` reports the same eight files the table names
- `lake build` green (the three docstring heading additions touch module docstrings only)

---

### Phase 10: Close the publication gate and hand off [NOT STARTED]

**Goal**: Verify every acceptance criterion against the tree, record the already-satisfied gate items
as satisfied rather than re-performing them, and hand the maintainer-only residue over explicitly.

**Tasks**:
- [ ] Verify the untracking item is already satisfied rather than re-performing it: `git ls-files`
      finds none of `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`; `.gitignore` carries the
      three that exist; `.gitattributes` has never existed; commit `6ac3b3844` is the record. If any of
      this no longer holds at this phase's HEAD, perform the missing part in one commit.
- [ ] Confirm `specs/` is still tracked and is **not** in `.gitignore`. It stays published as the
      project development record, per the recorded user decision.
- [ ] Confirm `CITATION.cff` already reads `version: "1.0.0"` / `date-released: "2026-09-07"`, and that
      `FormalSystem/Version.lean` agrees.
- [ ] Run the complete gate set: `bash scripts/check-module-invariants.sh` (full mode),
      `lake build --wfail`, `lake test`, `lake lint`, `lake build BimodalTools --wfail`,
      `lake build BimodalToolsTest --wfail`, `lake exe mk_all --lib FormalSystem --check`,
      `lake exe lint-style`, `bash scripts/check-copyright-headers.sh --strict FormalSystem
      BimodalTools`, `bash scripts/readme-lint.sh FormalSystem BimodalTools`,
      `bash scripts/check-evidence-probes.sh`, `bash scripts/check-metalogic-cycles.sh`,
      `bash scripts/typst-sync-check.sh`. Every one green.
- [ ] Confirm all three stated acceptance criteria against observed output: `mk_all --check` green; C6
      manifest empty; release-workflow dry-run (YAML parse + pin resolution) passing.
- [ ] Update `docs/development/PUBLICATION_REFACTOR.md`'s Phase 8 / follow-up H entries to record what
      landed, what was decided, and what remains with the maintainer.
- [ ] Write the maintainer handoff explicitly into the implementation summary and into
      `PUBLICATION_REFACTOR.md`: (a) create and push the `v1.0.0` tag; (b) run the release workflow
      once via `workflow_dispatch` and confirm it is green; (c) confirm the `CITATION.cff` fields at
      tag time. **Do none of these.** `rules/pr-prohibition.md` forbids agents from pushing, tagging,
      or creating releases, and the first green remote run is the only thing that can certify the
      workflow.
- [ ] Record the research report's context-extension recommendation as a follow-up: a note in
      `context/project/lean4/tools/` covering `isInLibraryRoot`'s activation gate, the
      `srcDir`-vs-directory-name asymmetry in `mk_all`/`GetAllModules`, and the import-line exemption
      in `linter.style.longLine`. Note it in the summary; do not author it here (it is outside this
      task's scope and lands in the deploy-artifact tree, whose source store is
      `agent-system/extensions/**`).

**Timing**: 1 hour

**Depends on**: 4, 6, 7, 8, 9

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: three of the four publication-gate untracking targets are already untracked and
the fourth has never existed. Confirm with `git ls-files -- CLAUDE.md .claude-extensions.json
.syncprotect .gitattributes` and `git log --oneline -1 6ac3b3844` before recording the item as
satisfied.

**Files to modify**:
- `docs/development/PUBLICATION_REFACTOR.md` - record Phase 8 outcomes and the maintainer handoff
- `specs/637_ci_parity_root_collapse_publication_gate/summaries/01_*-summary.md` - implementation
  summary carrying the handoff list

**Verification**:
- Every command in the gate set above exits 0
- `scripts/module-invariants-manifest.txt` holds zero live entries
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `git ls-files` confirms the untracking state and that `specs/` is still tracked
- No tag exists and nothing was pushed (`git tag`, `git log origin/main..HEAD`)

---

## Lean Challenge Statements

This plan commits to **no new Lean theorem statements**. It is repository infrastructure — aggregator
generation, linter configuration, CI wiring, manifest bookkeeping and policy text — and its `Goals`
bullets name no Lean identifiers, so the challenge identifier set is empty by construction and matches.
The one new Lean declaration this plan introduces, `FormalSystem.version : String` in
`FormalSystem/Version.lean` (Phase 2), is a relocated constant with no proof obligation and is
therefore not a challenge statement.

## Testing & Validation

- [ ] `lake build --wfail` green, including the nine modules newly reachable from the generated root
- [ ] `lake test` green, and printing no benchmark table
- [ ] `lake lint` (`runLinter FormalSystem` against `scripts/nolints.json`) still at zero un-nolisted
      findings — the enforced C16 half must not regress
- [ ] `lake build BimodalTools --wfail` and `lake build BimodalToolsTest --wfail` green
- [ ] `lake exe checkInitImports` green (C24's closure grew by nine modules)
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `lake exe lint-style` exits 0
- [ ] `bash scripts/check-module-invariants.sh` (full mode) green — C6 empty, C8 without the dead
      allow-list entry, C16 and C28 agreeing with their own recorded tables, C31 passing
- [ ] C31's deliberate negative test: a stray `.lean` file produces `FAIL` and a non-zero exit;
      removing it restores `PASS`
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools` green
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` green
- [ ] `bash scripts/check-evidence-probes.sh`, `check-metalogic-cycles.sh`, `typst-sync-check.sh` green
- [ ] `.github/workflows/release.yml` parses under `yaml.safe_load` and every action pin resolves
- [ ] Every modified CI step's `run:` body, extracted from the committed YAML rather than retyped,
      executes green locally
- [ ] `CI_CD_PROCESS.md`'s runtime-budget sums equal the sum of their own rows after both new rows land

## Artifacts & Outputs

- `FormalSystem.lean` - regenerated, import-only, byte-for-byte reproducible by `mk_all`
- `FormalSystem/Version.lean` - new
- `FormalSystem/FormalSystem.lean` - deleted
- `BimodalTools/ContrastiveGenerator.lean` - new
- `.github/workflows/release.yml` - new
- `CHANGELOG.md` - new (or `VERSIONING.md` corrected instead; the choice is recorded in Phase 9)
- `scripts/module-invariants-manifest.txt` - emptied
- `scripts/check-module-invariants.sh` - C31 added; C8, B3, C16, C28 records corrected
- `scripts/check-copyright-headers.sh` - `WHY THIS EXISTS` block corrected
- `.github/workflows/ci.yml` - C31 step, `lint-style-action` step, `--wfail` on the two tooling steps
- `lakefile.toml` - `weak.linter.unicodeLinter = false` with a recorded reason
- `ORGANISATION.md` - module-size policy, namespace-exception index, corrected `specs/` row
- `docs/development/{CI_CD_PROCESS,MODULE_INVARIANTS,LEAN_STYLE_GUIDE,VERSIONING,PUBLICATION_REFACTOR,DIRECTORY_README_STANDARD}.md`
- `specs/637_ci_parity_root_collapse_publication_gate/summaries/01_ci-parity-root-collapse-summary.md`

## Rollback/Contingency

- **Per-phase**: every phase except Phase 2 uses `per-substep` commits, so a failed step is recovered
  by fixing forward from the last green commit. `rules/error-handling.md` forbids discarding
  uncommitted changes to reach a passing build.
- **Phase 1's temporary root**: restored by `cp` from a scratch copy taken before generation, verified
  with `sha256sum -c`. Never restored with `git checkout --` or `git restore`, which the
  `guard-destructive-git.sh` hook blocks on a dirty tree.
- **Phase 2 (`atomic-batch`)**: the only phase whose intermediate states are expected red. If it
  cannot be brought green, revert the single batch commit with `git revert` rather than a
  working-tree-discarding command. The pre-collapse root is recoverable from git history at any point.
- **A genuine whole-tree rollback**, if one is ever needed, follows `context/contracts/recovery.md`'s
  rollback rung: `bash .claude/scripts/git-snapshot.sh 637 --allow-out-of-scope` first (the override is
  required because a whole-tree rollback necessarily spans paths outside this task's `file_scope`),
  then the destructive command. Do not emit a bare `git-snapshot.sh 637` as a routine start-of-phase
  checkpoint; a defensive checkpoint before risky work uses `--no-revert`.
- **Territory conflicts**: if task 643 or 614 has landed changes to a shared file, rebase this task's
  edits onto theirs. Never revert a sibling's work to make room. On a foreign commit, foreign
  uncommitted modification, or a running build this task did not start, check `git log` to confirm the
  work is not this task's own, then STOP and report.
- **The C6 manifest** is the safety net for the reachability work: if a module cannot be wired, it can
  be re-manifested with a recorded reason rather than left dangling — but the task's acceptance
  criterion is an *empty* manifest, so any such re-manifesting is a `[PARTIAL]` outcome that must be
  reported, not absorbed silently.
