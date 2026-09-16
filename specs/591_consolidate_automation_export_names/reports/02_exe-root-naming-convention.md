# Research Report: Task #591

**Task**: 591 - Consolidate the confusable `Automation/` export module names
**Started**: 2026-09-16T16:40:19Z
**Completed**: 2026-09-16T16:47:00Z
**Effort**: Medium (2-4 hours). This is a mechanical rename: 13 files renamed, 1 library renamed, about 40 files edited, and no proof work.
**Dependencies**: None blocking. Coordinate with 586, which rewrites `typst/chapters/p4-*`, and with 589, which is ordered last because renames shift cited lines.
**Sources/Inputs**: - Codebase (`lakefile.lean`, `FormalSystem/Automation/*.lean`, `Tests/BimodalTest.lean`, `scripts/check-module-invariants.sh`, `scripts/typst-sync-check.sh`, `scripts/typst-machine-appendix.sh`, `.github/workflows/ci.yml`, docs/typst/README surfaces), prior sweep report `01_confusable-export-module-names.md`. No Mathlib search was needed, because nothing in this task is a lemma question.
**Artifacts**: - specs/591_consolidate_automation_export_names/reports/02_exe-root-naming-convention.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The names give no signal today, and it is worse than five modules.** Across the 12 `Automation/`
  exe roots, the name suffixes are `Export` (3), `Exporter` (2), `Validator`, `Benchmark`,
  `Anchors`, `Oracle`, `Mutator`, `Bridge` and `Pipeline`. Every one of those suffixes also
  appears on a library module, or has a close library twin: `DataExport`,
  `Metalogic/Decidability/TraceExport`, `DatasetExporter`, `DatasetGenerator`,
  `ProofFirstBenchmark`, `ProofStepExtractor`. There are **four** confusable lib/exe pairs, not two:
  `DataExport`/`DatasetExport`, `DatasetExporter`/`DatasetExport`,
  `TraceExport`/`TraceExporter`, and `DatasetGenerator` (a library) versus `lake exe dataset_generator`
  (whose root is `DatasetExport`).
- **Recommended convention (one rule for all 13 roots):** *the root module of `lake exe foo_bar`
  is named `FooBarMain`, meaning the exe target in PascalCase plus `Main`. No module that is not an exe root ends
  in `Main`.* This is a bijection with the target names, so the target names stay stable and
  the external docs and the Hugging Face card (which name only `lake exe` targets) are
  untouched. It uses the Lean/Lake idiom that a `Main` module holds `main`. It can be checked
  by machine from the same `lakefile.lean` scrape that C25 already does.
- **The five modules in scope:** `DatasetExport` becomes `DatasetGeneratorMain`, and `ProofStepExport` becomes
  `ProofExtractorMain`. `DatasetExporter` becomes `DatasetAssembly`, because it assembles and splits and is a library.
  `DataExport` and `ProofStepExtractor` **keep their names**. Once no exe root uses `Export`,
  `DataExport` and `Metalogic/Decidability/TraceExport` share a consistent meaning:
  "`XExport` = the JSON serialization layer for X". `ProofStepExtractor` really does extract.
- **The other 10 roots are renamed under the same rule** so the convention covers the whole
  tree (see the table in Findings). No collisions with existing modules. The only module name
  containing `Main` today is `FormalSystem/MainResults.lean`, which does not *end* in `Main`.
- **Blast radius is small and fully enumerated.** Qualified namespace references to the renamed
  roots from outside their own file total 6. Three hard-coded paths in scripts need editing
  (`check-module-invariants.sh` C22_B, and two lines in `typst-machine-appendix.sh`). Two
  emitted `"generator"` provenance strings **must not** change.

## Context & Scope

The task asks for ONE naming convention that tells `lean_exe` roots apart from library modules in
`FormalSystem/Automation/`. It must be checked against all thirteen `lean_exe` declarations in
`lakefile.lean`, applied to the five confusable modules, keep `lake exe` target names stable,
and respect C4/C5/C8/C12/C24/C25, CI's exe-root step, and the docs/typst surfaces. This is a
rename, not a restructure. This report does not pick or measure a proof strategy, because there are no proofs
involved.

## Findings

### Codebase Patterns

**The thirteen `lean_exe` declarations (lakefile.lean lines 29-118).** Every root defines a
root-namespace `main`. Every `srcDir` is `"."` except `checkInitImports`, which uses `"scripts"`.

| # | `lake exe` target (kept) | Current root | Lines | Imported by (outside itself) | Current namespace | Proposed root |
|---|---|---|---|---|---|---|
| 1 | `dataset_generator` | `Automation.DatasetExport` | 1,354 | none | `...Automation.DatasetExport` | `Automation.DatasetGeneratorMain` |
| 2 | `dataset_validator` | `Automation.DatasetValidator` | 604 | `Tests/.../C5SmokeTest.lean` | `...Automation.DatasetValidator` | `Automation.DatasetValidatorMain` |
| 3 | `proof_extractor` | `Automation.ProofStepExport` | 1,692 | none | `...Automation.ProofStepExport` | `Automation.ProofExtractorMain` |
| 4 | `enum_benchmark` | `Automation.EnumBenchmark` | 227 | none | (none) | `Automation.EnumBenchmarkMain` |
| 5 | `benchmark_anchors` | `Automation.BenchmarkAnchors` | 593 | none | `...Automation.BenchmarkAnchors` | `Automation.BenchmarkAnchorsMain` |
| 6 | `benchmark_oracle` | `Automation.BenchmarkOracle` | 370 | none | `...Automation.BenchmarkOracle` | `Automation.BenchmarkOracleMain` |
| 7 | `contrastive_generator` | `Automation.FormulaMutator` | 1,191 | `Tests/.../FormulaMutatorTest.lean` | `...Automation.FormulaMutator` | `Automation.ContrastiveGeneratorMain` |
| 8 | `tableau_bridge` | `Automation.TableauBridge` | 648 | none | `...Automation.TableauBridge` | `Automation.TableauBridgeMain` |
| 9 | `tableau_proof_steps` | `Automation.TableauProofStepPipeline` | 696 | none | `...Automation.TableauProofStepPipeline` | `Automation.TableauProofStepsMain` |
| 10 | `trace_exporter` | `Automation.TraceExporter` | 265 | none | `...Automation.TraceExporter` | `Automation.TraceExporterMain` |
| 11 | `proof_first_generator` | `Automation.ProofFirstExporter` | 148 | `Tests/.../ProofFirstTests.lean` | `FormalSystem.Automation` (shared) | `Automation.ProofFirstGeneratorMain` |
| 12 | `machine_appendix` | `Automation.MachineAppendixExport` | 498 | none | `...Automation.MachineAppendixExport` | `Automation.MachineAppendixMain` |
| 13 | `checkInitImports` | `CheckInitImports` (srcDir `scripts`) | small | none | (none) | `CheckInitImportsMain` |

**Library modules whose names clash with this vocabulary** (not exe roots, but they share a suffix or a stem with one):
`DataExport` (395 lines, 19 importers + 2 tests, 22 `open` lines), `DatasetExporter` (348, imported only by
`Automation.lean`), `DatasetGenerator` (2,296, 14 importers), `ProofStepExtractor` (361, 4
importers), `ProofFirstBenchmark` (188), `Metalogic/Decidability/TraceExport` (a JSON serialization
library that "mirrors the style of `DataExport`").

**Why a suffix beats a subdirectory (`Automation/Cli/`, `Automation/Exe/`).**
- The C8 aggregator walk covers only `FormalSystem/`, `FormalSystem/Metalogic/` and
  `FormalSystem/Syntax/` (`check-module-invariants.sh` ~line 953). It does **not** cover
  `Automation/`, which already has `ProofSearch/` and `Tactics/` without sibling aggregators. So a
  subdirectory would not trip C8 today. It would still break the aggregator idiom the repo follows everywhere
  else, and any aggregator for it **could not import its children**: each child defines a
  root-namespace `main`, and importing two of them fails with "environment already contains 'main'"
  (documented in `Tests/BimodalTest.lean` lines 81-88). An aggregator that cannot aggregate is worse
  than no directory.
- A subdirectory lengthens every module path (`FormalSystem.Automation.Cli.X`), which adds churn to
  every doc path, and it does not encode *which* exe a root belongs to.
- The suffix rule matches the known structural issue exactly. `Tests/BimodalTest.lean` already says
  "Fixing this means restructuring where `main` lives in the executable roots". A `*Main`
  name is the natural target for that later split, where `ContrastiveGeneratorMain` becomes a thin `main`
  and `FormulaMutator` keeps the library code. The rename here does not do the split, but it points the tree in the same direction.

**Why target-derived rather than a free `*Main` suffix.** Deriving the name from the target
(`dataset_generator` becomes `DatasetGeneratorMain`) makes the mapping one-to-one and checkable by machine, and it
removes the current cross-wiring where `lake exe dataset_generator`'s root is *not*
`DatasetGenerator`. The cost shows up in one place: `FormulaMutator` becomes `ContrastiveGeneratorMain`, which
hides the "mutator" concept. That concept survives in the module docstring, and it would come back as a
library name if the split described above is done later.

### External Resources

- No Mathlib or Lean search was needed. The convention follows the ordinary Lake idiom that an
  executable's root module holds `main` (`Main.lean` in `lake new` templates).
- `data/dataset-card.md` names only `lake exe` targets (lines 44-54, 78, 101, 167, 176) and one
  unrelated `Normalization.lean`. No module names appear in `data/*.json`. Keeping the targets
  therefore leaves the Hugging Face surface unchanged.

### Recommendations

**R1 — Adopt the convention and record it where it will be read.** Add a short "Module naming"
subsection to `FormalSystem/Automation/README.md`, outside the generated inventory block. It should say:
roots are `PascalCase(target) ++ "Main"`; a library is named for what it produces
(`XExport` = JSON serialization of X, `XAssembly`, `XExtractor`, `XGenerator`); `Main` is reserved.

**R2 — Rename set (13 root renames + 1 library rename).** `git mv` each file. Update the `root :=`
line (keep `srcDir` unchanged, since C25 and CI scrape `root\s*:=\s*\`...`). Rename the namespace to match
the new module path for every root that has its own per-module namespace (1-3, 5-10, 12). Also rename
`DatasetExporter` to `DatasetAssembly` along with its namespace. Leave `ProofFirstExporter`'s shared
`FormalSystem.Automation` namespace, and the namespace-less `EnumBenchmark` and `CheckInitImports`, as
they are.

**R3 — Keep these byte-for-byte (data contracts, not module paths):**
- `"generator": "BimodalLogic/DatasetExporter"` (`DatasetExporter.lean` lines 37, 111), which is emitted into
  dataset metadata and documented in `docs/training/PIPELINE.md` lines 259 and 555.
- `"generator": "BimodalLogic/MachineAppendixExport"` (`MachineAppendixExport.lean` lines 45, 422),
  which is baked into the committed `typst/generated/machine-appendix.jsonl` line 1. Changing it
  forces the appendix to be regenerated and fails `typst-sync-check.sh` Check 3 until that happens.
  Add a one-line comment at each site saying the string is a stable provenance ID, not a module path.

**R4 — The enumerated edit surface** (from a whole-repo `grep -w` excluding `.lake/ specs/ .git/
.claude/ agent-system/ data/`; the counts are matching lines):
- Build/CI/scripts: `lakefile.lean` (13 roots). `scripts/check-module-invariants.sh` (17): the
  **functional** edit is `C22_B="FormalSystem/Automation/ProofStepExport.lean"` (line 2818) plus the
  note text at line 2842. The rest are comments, including the C16 measurement table at lines 2053-2059,
  which is best relabelled with the new names. `scripts/typst-machine-appendix.sh` has lines 15, 192 and 196, and
  **192/196 are functional** (`lake build FormalSystem.Automation.MachineAppendixExport` and
  `lake env lean --run FormalSystem/Automation/MachineAppendixExport.lean`).
  `.github/workflows/ci.yml` line 46 is a comment only. `scripts/generate_dataset.py` line 9 and
  `scripts/curate_benchmark.py` line 397 are docstrings. `scripts/module-invariants-manifest.txt`
  line 110 is a comment.
- Lean imports and docstrings: `FormalSystem/Automation.lean` (the `DatasetExporter` import plus the
  comment at lines 23-24 naming the exe roots). `Tests/BimodalTest/Automation/{C5SmokeTest,
  FormulaMutatorTest,ProofFirstTests}.lean` (imports and qualified names). `Tests/BimodalTest.lean`
  lines 84-86. Cross-references in `TableauBridge`, `TraceExporter`, `TableauProofStepPipeline`,
  `BenchmarkAnchors`, `BenchmarkOracle`, `AxiomNames`, `DatasetGenerator`, `Normalization`,
  `FormalSystem/Init.lean` line 19, and `FormalSystem/Theorems/TemporalDerived.lean` lines 65 and 438.
- Docs (C5/C12 will flag stale slash or module paths): `docs/training/PIPELINE.md` (23 lines, including
  the `root :=` excerpt at line 397 and the "Despite the similar name" note at line 303, which can then be deleted),
  `docs/training/SYNC_PROTOCOL.md` line 121, `docs/ARCHITECTURE.md` line 66,
  `docs/development/MODULE_INVARIANTS.md` lines 36 and 219, `docs/development/NAMING_CONVENTION_DEVIATION.md`
  (4 lines: historical narrative, so rewrite as "`ProofExtractorMain.lean` (then `ProofStepExport.lean`)"
  or similar, keeping the history accurate while the path resolves),
  `FormalSystem/Metalogic/Decidability/README.md`, `FormalSystem/Automation/README.md`
  (regenerate the inventory block with `scripts/readme-inventory.sh`, then fix the hand-written rows).
- Typst: `typst/chapters/p4-dataset-pipeline.typ` (6 spans, lines 34, 35, 39, 40, 64) and
  `typst/sync-check-whitelist.txt` line 112 (comment). **Important:** that whitelist comment says
  `dataset_generator` resolves "via a live doc-comment reference in DatasetExport.lean". Keep a
  backticked `lake exe dataset_generator` mention in the renamed file's docstring, or
  `typst-sync-check.sh` Check 1 starts failing on that span.
- Note that `FormalSystem/README.md` has **no** occurrence of these names (verified), despite the task
  description listing it.

**R5 — Add a mechanical guard (recommended, cheap).** Extend C25, which already scrapes the roots
in one place (the `LAKE_EXE_ROOTS` block, ~line 1972), with a pure-text assertion. It should parse
`lean_exe (\S+) where\s+root := \`([A-Za-z0-9_.]+)`, require the last component to equal
`PascalCase(target) + "Main"` (with `checkInitImports` becoming `CheckInitImportsMain`), and require that no
live `.lean` file outside that root list has a basename ending in `Main`. Without this, the next new
executable brings the drift back. Document the rule in the C25 row of `docs/development/MODULE_INVARIANTS.md`.

**R6 — Commit order.** Use one commit per coherent family so that a regression can be bisected: (a) the dataset family
(`DatasetGeneratorMain`, `DatasetValidatorMain`, `DatasetAssembly`); (b) the proof-step family
(`ProofExtractorMain`, `TableauProofStepsMain`, `ProofFirstGeneratorMain`); (c) benchmark/tableau/
trace/appendix/contrastive roots plus `CheckInitImportsMain`, including the
`typst-machine-appendix.sh` edits; (d) the convention doc and the R5 guard. Each commit must leave
`lake build` plus a `--no-build` invariants pass green.

**Sorry-free path:** trivially yes, since no proof content changes.

## Decisions

- Chose a target-derived `*Main` suffix over a `Cli/` subdirectory, because such an aggregator cannot import `main`-defining children and C8 does not walk `Automation/` anyway. Chose it over a free suffix, because a mechanical bijection can be checked.
- Keep `DataExport` and `ProofStepExtractor`. Rename `DatasetExporter` to `DatasetAssembly`.
- `lake exe` target names do not change, and neither do emitted `"generator"` strings.
- Rename namespaces along with modules wherever a module owns a per-module namespace. External
  qualified references are few (DatasetExport 1, DatasetValidator 1, TableauBridge 1, TraceExporter 2,
  MachineAppendixExport 1).
- Out of scope, recorded as a follow-up: splitting `main` out of the three roots that tests import
  (`DatasetValidator`, `FormulaMutator`, `ProofFirstExporter`) into thin `*Main` modules.

## Risks & Mitigations

- **Stale `.lake` oleans of old module names.** These are harmless to `lake build`, but a manual `lake env lean --run`
  on an old path would still appear to work. Mitigation: the `typst-machine-appendix.sh` edit is functional, so
  verify it by actually running the script (or at least its `lake build` line).
- **Concurrent edits by 586 in `typst/chapters/p4-*`.** 586 targets `p4-proof-automation.typ`,
  while this task touches `p4-dataset-pipeline.typ`, so the file overlap is low. Re-grep before committing.
- **589 line-citation shifts.** Renames change `file.lean:NNN` basenames, and none of the renamed
  basenames currently appears in `file.lean:NNN` form (the grep count is 0), so there is no C20 impact. 589 is already ordered last.
- **Losing the "FormulaMutator" concept name.** Mitigation: keep the module docstring heading
  ("Formula mutator ...") and mention the historical name once in the Automation README.
- **Build cost.** C25 links nothing, but full verification means re-elaborating 13 roots. Run the
  build detached, through the build guard.

## Tactic Survey Results

- Not applicable (no tactic survey performed): the task is a module rename with no proof goals.

## Context Extension Recommendations

- **Topic**: Lean project module naming for executable roots vs libraries
- **Gap**: `.claude/context/project/lean4/` has no guidance on `lean_exe` root naming or the "one `main` per environment" import hazard
- **Recommendation**: add a short note to the lean4 extension's patterns (source store `agent-system/extensions/lean/...`), not to `.claude/` directly

## Appendix

- Commands used: `grep -nE 'lean_exe|root :=|srcDir' lakefile.lean`; per-module scans for
  `def main`, importers (`^import FormalSystem.Automation.<M>$`), namespaces, external qualified
  references and `open` lines; whole-repo `grep -rlw`/`grep -rnw` over the 13 root names plus
  `DatasetExporter`, `DataExport` and `TraceExport`; string-literal scan for emitted module names; `data/`
  scan (no hits); reading the C8 walk, the `LAKE_EXE_ROOTS` scrape, C22, and CI lines 43-62.
- References: `specs/reviews/review-2026-09-16.md` Finding M5; `Tests/BimodalTest.lean` lines 78-90
  (duplicate-`main` hazard); `docs/development/MODULE_INVARIANTS.md` (C25 row).
