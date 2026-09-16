# Implementation Plan: Task #591

- **Task**: 591 - Consolidate the confusable `Automation/` export module names
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None blocking (coordinate with 586 on `typst/chapters/p4-*`; 589 is ordered after this task)
- **Research Inputs**: specs/591_consolidate_automation_export_names/reports/02_exe-root-naming-convention.md (primary), specs/591_consolidate_automation_export_names/reports/01_confusable-export-module-names.md
- **Artifacts**: plans/02_exe-root-rename-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Adopt one naming rule for every `lean_exe` root: the root module of `lake exe foo_bar` is
`FooBarMain`, meaning the target name in PascalCase plus `Main`. No module that is not an exe root may
end in `Main`. Apply the rule to all 13 roots in `lakefile.lean`. Also rename the library
`DatasetExporter` to `DatasetAssembly`, and keep the names `DataExport` and `ProofStepExtractor`. `lake exe` target
names and the emitted `"generator"` provenance strings stay byte-for-byte identical. The work is split into
commit families (dataset, proof-step, remaining roots) so that a regression can be bisected. It closes with the
documented convention and a mechanical C25-adjacent guard that stops the drift from coming back.

### Research Integration

- Rename map (report 02, table in Findings):
  `DatasetExport` -> `DatasetGeneratorMain`, `DatasetValidator` -> `DatasetValidatorMain`,
  `ProofStepExport` -> `ProofExtractorMain`, `EnumBenchmark` -> `EnumBenchmarkMain`,
  `BenchmarkAnchors` -> `BenchmarkAnchorsMain`, `BenchmarkOracle` -> `BenchmarkOracleMain`,
  `FormulaMutator` -> `ContrastiveGeneratorMain`, `TableauBridge` -> `TableauBridgeMain`,
  `TableauProofStepPipeline` -> `TableauProofStepsMain`, `TraceExporter` -> `TraceExporterMain`,
  `ProofFirstExporter` -> `ProofFirstGeneratorMain`, `MachineAppendixExport` -> `MachineAppendixMain`,
  `scripts/CheckInitImports` -> `scripts/CheckInitImportsMain`. Library: `DatasetExporter` -> `DatasetAssembly`.
- Namespaces: rename the per-module namespace along with the module for roots 1-3, 5-10 and 12, and for
  `DatasetExporter`. Leave `ProofFirstExporter`'s shared `FormalSystem.Automation` namespace unchanged,
  and do the same for the namespace-less `EnumBenchmark` and `CheckInitImports`. `scripts/nolints.json` has no entries
  under any affected namespace (verified at planning time: 0 matches), so C16 is not affected.
- The subdirectory option (`Automation/Cli/`) was rejected. An aggregator cannot import several
  `main`-defining children, and the extra path depth adds churn without saying which exe a root belongs to.
- Functional (non-comment) script edits: `check-module-invariants.sh` `C22_B` (line ~2818) and
  its note (~2842), plus `typst-machine-appendix.sh` lines ~192 and ~196.
- Data contracts that must NOT change: `"generator": "BimodalLogic/DatasetExporter"` and
  `"generator": "BimodalLogic/MachineAppendixExport"`. Each gets a one-line comment marking it as a stable
  provenance ID.
- Typst sync hazard: `typst/sync-check-whitelist.txt` relies on a doc-comment mention of
  `dataset_generator` in the root file. That backticked mention must survive in `DatasetGeneratorMain.lean`.
- `FormalSystem/README.md` has no occurrence of these names (the research verified this). It is listed in the task description,
  but it needs no edit unless a re-grep finds one.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- One machine-checkable convention that tells all 13 exe roots apart from library modules.
- Remove the four confusable lib/exe pairs (`DataExport`/`DatasetExport`,
  `DatasetExporter`/`DatasetExport`, `TraceExport`/`TraceExporter`, `DatasetGenerator` versus the
  `dataset_generator` root).
- Keep every `lake exe` target name, emitted provenance string, and external doc surface
  (the Hugging Face card) stable.
- Record the convention in `FormalSystem/Automation/README.md` and in the C25 row of `MODULE_INVARIANTS.md`,
  enforced by a script check.

**Non-Goals**:
- Splitting `main` out of the test-imported roots (`DatasetValidator`, `FormulaMutator`,
  `ProofFirstExporter`) into thin mains. This is recorded as a follow-up, not done here.
- Renaming `DataExport`, `ProofStepExtractor`, `DatasetGenerator`, or
  `Metalogic/Decidability/TraceExport`.
- Changing `lake exe` target names, `srcDir` values, or any dataset or appendix output bytes.
- Regenerating `typst/generated/machine-appendix.jsonl`, which should not be needed because the generator string is unchanged.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale `.lake` oleans for old module names mask a missed reference (for example, a script still running an old path) | M | M | After each family, run `grep -rnw` for the old names over live surfaces, excluding `.lake/ specs/ .git/ .claude/ agent-system/ data/`, and require 0 unexpected hits. Actually execute `typst-machine-appendix.sh` (or at least its build line) rather than trusting the build |
| Accidentally changing an emitted `"generator"` string | H | L | Grep both literal strings before and after, and require identical match counts. Add comments marking them as stable IDs |
| `typst-sync-check.sh` Check 1 loses the `dataset_generator` resolution | M | M | Keep a backticked `lake exe dataset_generator` mention in the `DatasetGeneratorMain.lean` docstring, and run `typst-sync-check.sh` in phase 1 |
| Concurrent edits to `typst/chapters/p4-dataset-pipeline.typ` (from 586) | L | L | Re-grep and `git diff` that file right before editing, and edit only the named spans |
| Namespace rename misses an external qualified reference | M | L | The build fails loudly. The research counted 6 external qualified refs; grep `Automation\.<OldName>\.` before closing each phase |
| The new guard misparses `checkInitImports` (camelCase target, `scripts` srcDir) | L | M | PascalCase = capitalize the first letter of each `_`-separated segment and keep inner capitals, so `checkInitImports` -> `CheckInitImports`. Test the guard against a deliberately wrong temporary root |
| A full build is slow (13 roots re-elaborate) | L | H | Build per family with targeted `lake build <Module>` during the phase, and run a single full `lake build` at the final gate |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases run strictly in sequence. They share `lakefile.lean`, `check-module-invariants.sh`, and
`docs/training/PIPELINE.md`, so parallel runs would conflict.

### Phase 1: Dataset family rename [COMPLETED]

**Goal**: Rename `DatasetExport` -> `DatasetGeneratorMain`, `DatasetValidator` ->
`DatasetValidatorMain`, and `DatasetExporter` -> `DatasetAssembly`, with every reference updated and the
build green.

**Tasks**:
- [x] Record a baseline: `grep -rn '"generator": "BimodalLogic/DatasetExporter"'` count, and run
      `scripts/check-module-invariants.sh --no-build` (note any pre-existing failures so they are not attributed to this task)
- [x] `git mv` the three files under `FormalSystem/Automation/`
- [x] Update the `lakefile.lean` `root :=` lines for `dataset_generator` and `dataset_validator` (leave `srcDir` unchanged)
- [x] Rename the per-module namespaces (`...Automation.DatasetExport` -> `...DatasetGeneratorMain`, and so on) and fix
      the external qualified references (DatasetExport 1, DatasetValidator 1)
- [x] Update the importers: `FormalSystem/Automation.lean` (the `DatasetExporter` import and the exe-root comment at lines ~23-24),
      `Tests/BimodalTest/Automation/C5SmokeTest.lean`, and `Tests/BimodalTest.lean` lines ~84-86
- [x] Keep `"generator": "BimodalLogic/DatasetExporter"` byte-identical at both sites, and add a stable-provenance-ID comment
- [x] Keep a backticked `lake exe dataset_generator` mention in the `DatasetGeneratorMain.lean` docstring,
      and update the comment in `typst/sync-check-whitelist.txt` line ~112 to name the new file
- [x] *(deviation: altered — AxiomNames.lean, Normalization.lean, Init.lean, TemporalDerived.lean had no dataset-family names; their mentions belong to phase 2/3 names)* Update the docstring and doc cross-references: `DatasetGenerator.lean`, `Normalization.lean`, `AxiomNames.lean`,
      `FormalSystem/Init.lean`, `FormalSystem/Theorems/TemporalDerived.lean`, `scripts/generate_dataset.py`,
      `docs/training/PIPELINE.md` (including the `root :=` excerpt at ~397; delete the "Despite the similar name" note at ~303),
      `docs/training/SYNC_PROTOCOL.md`, `docs/ARCHITECTURE.md`, and `typst/chapters/p4-dataset-pipeline.typ` (lines ~34, 35, 39, 40, 64)
- [x] Update the C16 measurement table comment in `check-module-invariants.sh` (~2053-2059) for these names
- [x] Run `lake build FormalSystem.Automation.DatasetGeneratorMain FormalSystem.Automation.DatasetValidatorMain FormalSystem.Automation.DatasetAssembly BimodalTest`
- [x] Commit: `task 591: phase 1: dataset family rename`
- [x] Regenerated the Automation README inventory block early *(deviation: altered — done in phase 1 because INV flagged the renamed rows; rows for concurrently-edited FormulaEnumerator/Normalization kept at HEAD counts)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The research enumerated about 20 live files touched by this family (the grep excluded `.lake/ specs/ .git/ .claude/ agent-system/ data/`). Confirm with `grep -rnwE 'DatasetExport|DatasetValidator|DatasetExporter'` over the same exclusions before and after. The only survivors allowed after the edit are the two `"generator"` string literals and deliberate historical-narrative mentions.

**Files to modify**:
- `lakefile.lean` - two `root :=` lines
- `FormalSystem/Automation/{DatasetExport,DatasetValidator,DatasetExporter}.lean` - renamed, namespaces renamed
- `FormalSystem/Automation.lean`, `Tests/BimodalTest/Automation/C5SmokeTest.lean`, `Tests/BimodalTest.lean` - imports and comments
- Cross-referencing `.lean` docstrings, `docs/training/*.md`, `docs/ARCHITECTURE.md`, `typst/chapters/p4-dataset-pipeline.typ`, `typst/sync-check-whitelist.txt`, `scripts/generate_dataset.py`, `scripts/check-module-invariants.sh` (comments)

**Verification**:
- The targeted `lake build` exits 0
- `lake exe dataset_generator --help` (or a minimal smoke invocation) and `lake exe dataset_validator` still start
- `scripts/typst-sync-check.sh` passes
- The `"generator"` literal count is unchanged from the baseline

---

### Phase 2: Proof-step family rename [COMPLETED]

**Goal**: Rename `ProofStepExport` -> `ProofExtractorMain`, `TableauProofStepPipeline` ->
`TableauProofStepsMain`, and `ProofFirstExporter` -> `ProofFirstGeneratorMain`, including the functional C22 path.

**Tasks**:
- [x] `git mv` the three files and update their `lakefile.lean` `root :=` lines
- [x] Rename the namespaces for `ProofStepExport` and `TableauProofStepPipeline`. Leave `ProofFirstExporter`'s shared
      `FormalSystem.Automation` namespace unchanged
- [x] Update `Tests/BimodalTest/Automation/ProofFirstTests.lean` (import) and `Tests/BimodalTest.lean` comments
- [x] **Functional**: update `C22_B="FormalSystem/Automation/ProofStepExport.lean"` (~line 2818) and the
      note text (~2842) in `scripts/check-module-invariants.sh`. Also update the matching C16 table comment rows
- [x] *(deviation: altered — TableauBridge.lean, ProofStepExtractor.lean, curate_benchmark.py and module-invariants-manifest.txt held no phase-2 names; TemporalDerived.lean, docs/ARCHITECTURE.md and historical comments in check-module-invariants.sh were updated instead, with "(then ProofStepExport.lean)" kept where the text is historical)* Update the cross-references in `TableauBridge.lean`, `ProofStepExtractor.lean` (if present), `docs/training/PIPELINE.md`,
      `docs/development/MODULE_INVARIANTS.md` (~36, ~219), `docs/development/NAMING_CONVENTION_DEVIATION.md`
      (historical wording: "`ProofExtractorMain.lean` (then `ProofStepExport.lean`)"),
      `scripts/curate_benchmark.py`, `scripts/module-invariants-manifest.txt`, and `.github/workflows/ci.yml` line ~46 (comment)
- [x] Run `lake build FormalSystem.Automation.ProofExtractorMain FormalSystem.Automation.TableauProofStepsMain FormalSystem.Automation.ProofFirstGeneratorMain BimodalTest`
- [x] Commit: `task 591: phase 2: proof-step family rename`

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: This family touches about 12 live files, and the only functional script edit is C22_B. Confirm with `grep -rnwE 'ProofStepExport|TableauProofStepPipeline|ProofFirstExporter'` over the live surfaces, excluding `.lake/ specs/ .git/ .claude/ agent-system/ data/`. Also confirm that `grep -n 'C22_' scripts/check-module-invariants.sh` shows no other hard-coded old path.

**Files to modify**:
- `lakefile.lean` - three `root :=` lines
- `FormalSystem/Automation/{ProofStepExport,TableauProofStepPipeline,ProofFirstExporter}.lean` - renamed
- `scripts/check-module-invariants.sh` - C22_B path (functional), comments
- `Tests/BimodalTest/Automation/ProofFirstTests.lean`, `Tests/BimodalTest.lean`, docs listed above

**Verification**:
- The targeted `lake build` exits 0
- `lake exe proof_extractor` still starts. `scripts/export-training-data.sh` in dry-run mode, or a minimal run if it has no dry-run mode, reaches its `lake exe proof_extractor` step
- `scripts/check-module-invariants.sh --no-build` shows C22 green (no worse than the phase 1 baseline)

---

### Phase 3: Remaining roots rename [COMPLETED]

**Goal**: Rename `EnumBenchmark`, `BenchmarkAnchors`, `BenchmarkOracle`, `FormulaMutator`,
`TableauBridge`, `TraceExporter`, `MachineAppendixExport`, and `scripts/CheckInitImports` to their
`*Main` names, including the functional `typst-machine-appendix.sh` edits.

**Tasks**:
- [x] `git mv` the eight files (the `CheckInitImports` file stays under `scripts/`) and update the eight `root :=` lines
- [x] Rename the namespaces for `BenchmarkAnchors`, `BenchmarkOracle`, `FormulaMutator`, `TableauBridge`, `TraceExporter`,
      and `MachineAppendixExport`. Fix the external qualified references (TableauBridge 1, TraceExporter 2, MachineAppendixExport 1)
- [x] Update `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` (import and qualified names). Do not rename the test file itself
- [x] Keep the module docstring heading "Formula mutator ..." in `ContrastiveGeneratorMain.lean`
- [x] Keep `"generator": "BimodalLogic/MachineAppendixExport"` byte-identical at both sites (~45, ~422), and add a
      stable-provenance-ID comment
- [x] **Functional**: `scripts/typst-machine-appendix.sh` lines ~15 (comment), ~192 (`lake build ...MachineAppendixMain`),
      and ~196 (`lake env lean --run FormalSystem/Automation/MachineAppendixMain.lean`)
- [x] Update the doc cross-references: `FormalSystem/Metalogic/Decidability/README.md`, `docs/training/PIPELINE.md`,
      the `.lean` docstrings in the renamed siblings, and the C16 table comment rows
- [x] Check whether any script or CI step invokes `checkInitImports` by module path (`grep -rn CheckInitImports`) and update it
- [x] *(deviation: altered — all 8 modules, 8 exes and FormulaMutatorTest built green; the aggregate BimodalTest target failed only on a concurrent session's uncommitted test relocation (missing BiLassoTest.olean), unrelated to this rename)* Run `lake build` on the eight renamed modules plus `BimodalTest`
- [x] *(deviation: altered — ran the script's functional `lake env lean --run FormalSystem/Automation/MachineAppendixMain.lean` line into a scratch file with the committed stamps (79bd1794f / 2026-09-07); `cmp` against the committed JSONL was byte-identical. The full script re-stamps with HEAD/today, which would dirty the committed artifact)* Run `scripts/typst-machine-appendix.sh`, then `git diff --exit-code typst/generated/machine-appendix.jsonl`, to confirm the output is unchanged
- [x] Commit: `task 591: phase 3: rename remaining exe roots`

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: Eight file renames and about 15 referencing files. Confirm with `grep -rnwE 'EnumBenchmark|BenchmarkAnchors|BenchmarkOracle|FormulaMutator|TableauBridge|TraceExporter|MachineAppendixExport|CheckInitImports'` over the live surfaces. Expected survivors are the `MachineAppendixExport` provenance literal, the historical-name mentions, and the `FormulaMutatorTest.lean` filename.

**Files to modify**:
- `lakefile.lean` - eight `root :=` lines
- Eight root files (renamed), `scripts/typst-machine-appendix.sh` (functional), `Tests/BimodalTest/Automation/FormulaMutatorTest.lean`, docs and README cross-references

**Verification**:
- The targeted `lake build` exits 0
- `typst-machine-appendix.sh` runs and the committed JSONL does not change
- `lake exe checkInitImports` and `lake exe trace_exporter` still start

---

### Phase 4: Convention documentation and mechanical guard [NOT STARTED]

**Goal**: Record the convention and add a script check that fails when a root breaks it.

**Tasks**:
- [ ] Add a "Module naming" subsection to `FormalSystem/Automation/README.md`, outside the generated inventory
      block. It states: roots are `PascalCase(target) ++ "Main"`; a library is named for what it produces
      (`XExport` = JSON serialization of X, `XAssembly`, `XExtractor`, `XGenerator`); `Main` is reserved; and it mentions the historical
      `FormulaMutator` name once
- [ ] Regenerate the README inventory block with `scripts/readme-inventory.sh`, then fix the hand-written rows
- [ ] Extend `scripts/check-module-invariants.sh` next to the `LAKE_EXE_ROOTS` scrape (~line 1972), as part of C25 (or a
      clearly labelled C25 sub-check). Parse `lean_exe (\S+) where ... root := \`M`, require the last component of M to equal
      PascalCase(target) + `Main`, and require that no live `.lean` file outside the root list has a basename ending in `Main`
- [ ] Negative-test the guard. Temporarily change one `root :=` or add a stray `FooMain.lean`, confirm the failure,
      then revert. Do not commit the temporary change
- [ ] Update the C25 row of `docs/development/MODULE_INVARIANTS.md` to describe the naming assertion
- [ ] Add a lean4 context-extension note only if it is in scope for the source store (`agent-system/extensions/lean/...`). Otherwise skip it, because it is optional
- [ ] Commit: `task 591: phase 4: document exe-root naming convention and add guard`

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Automation/README.md` - convention subsection and regenerated inventory
- `scripts/check-module-invariants.sh` - naming assertion
- `docs/development/MODULE_INVARIANTS.md` - C25 row

**Verification**:
- `scripts/check-module-invariants.sh --no-build` passes with the new assertion green
- The negative test fails as expected and is reverted

---

### Phase 5: Full gate [NOT STARTED]

**Goal**: Run the task's full acceptance bar against the finished tree.

**Tasks**:
- [ ] Final residue grep over the live surfaces for all 14 old names, and account for every hit (provenance literals,
      historical narrative, test filename)
- [ ] Run a full `lake build` (detached, through the build guard) and require exit 0
- [ ] Run the full `scripts/check-module-invariants.sh` (with build), requiring C4/C5/C8/C12/C16/C22/C24/C25 green
- [ ] Run `scripts/typst-sync-check.sh`, which must pass
- [ ] Smoke-run both named executables: `lake exe dataset_generator` (minimal args) and `lake exe proof_extractor`
- [ ] Smoke-run `scripts/export-training-data.sh` and `scripts/run_dataset_generation.sh` (dry-run or smallest config)
- [ ] Confirm that both `"generator"` literals are unchanged, and that `git diff` on `data/` and `typst/generated/` is empty
- [ ] Commit any fixes: `task 591: phase 5: final verification fixes` (only if anything changed)

**Timing**: 0.5 hours (plus build wall-clock)

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- None expected. Fixes only if the gate finds residue

**Verification**:
- Every command above exits 0

## Testing & Validation

- [ ] `lake build` exits 0
- [ ] `lake exe dataset_generator` and `lake exe proof_extractor` run
- [ ] Full `scripts/check-module-invariants.sh` passes (C4/C5/C8/C12/C24/C25, plus the new naming assertion)
- [ ] `scripts/typst-sync-check.sh` resolves every backticked module name
- [ ] `scripts/export-training-data.sh` and `scripts/run_dataset_generation.sh` still work
- [ ] `"generator"` provenance strings, `lake exe` target names, `data/`, and `typst/generated/` are unchanged

## Artifacts & Outputs

- 13 renamed exe root modules plus `FormalSystem/Automation/DatasetAssembly.lean`
- Updated `lakefile.lean`, scripts, tests, docs, and typst chapter
- Naming convention section in `FormalSystem/Automation/README.md` and a guard in `check-module-invariants.sh`
- `specs/591_consolidate_automation_export_names/summaries/02_exe-root-rename-summary.md`

## Rollback/Contingency

Each phase is one commit containing only `git mv` renames and text edits, so `git revert <commit>` of the
failing family restores the prior names cleanly. If a phase cannot reach a green build within its
budget, revert that phase's working-tree changes, mark the phase [PARTIAL] with the unresolved
reference noted, and leave the earlier committed families in place, because each is independently consistent.
Delete stale `.lake/build` artifacts for old module names only if they cause confusion. They do not affect the build.
