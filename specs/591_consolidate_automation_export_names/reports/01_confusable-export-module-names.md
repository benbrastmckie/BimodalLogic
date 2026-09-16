# Sweep Evidence Report: Task #591

**Task**: 591 — Consolidate the confusable `Automation/` export module names
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Small–Medium. A rename touching `lakefile.lean`, import lines, and documentation that names these modules.
**Dependencies**: None. Feeds **586** (whose Module Map table enumerates these modules), **588** and **589**.
**Sources/Inputs**:
- `FormalSystem/Automation/{DataExport,DatasetExport,DatasetExporter,ProofStepExport,ProofStepExtractor}.lean`
- `lakefile.lean` (`lean_exe` declarations), `scripts/check-module-invariants.sh` C25
- `specs/reviews/review-2026-09-16.md`, Finding M5

## Executive Summary

- Five modules sit in two near-identical naming families. In each family one member is a
  `lean_exe` root and the others are library code — **and nothing in the names says which**.
- Each module is individually well-documented and does a coherent job. This is purely a naming
  problem, so the fix is a rename, not a restructure — but it is a rename that touches
  `lakefile.lean`, which makes it worth doing carefully and worth doing before the tasks that
  cite these paths.

## The two families

| Module | Lines | Role (from its own docstring) | `lean_exe` root? |
|---|---|---|---|
| `DataExport.lean` | 395 | JSON serialization (`toJson`) and pretty-printing for core types | No |
| `DatasetExport.lean` | 1,354 | JSONL streaming, CLI, and the Lake executable's `main` | **Yes** — `dataset_generator` |
| `DatasetExporter.lean` | 348 | Assembles labeled formulas into a structured JSON dataset file with metadata and a train/eval split | No |
| `ProofStepExport.lean` | 1,692 | Executable entry point; registers computable theorems and exports proof steps | **Yes** — `proof_extractor` |
| `ProofStepExtractor.lean` | 361 | Walks `DerivationTree` values and emits ordered `ProofStep` records | No |

Three observations that should shape the rename:

1. **`Export` means "is the executable" in one family and "is a library" in neither consistently.**
   `DatasetExport` is the exe; `ProofStepExport` is the exe; but `DataExport` is a serialization
   library and `DatasetExporter` — the one whose name most suggests "the thing that exports" — is
   also a library. The agent-facing consequence is real: a dispatch asked to "fix the dataset
   exporter" has three plausible files and will pick by name.
2. **`DataExport` vs `DatasetExport` differ by three characters** and are unrelated in function
   (serialization primitives vs a CLI pipeline).
3. **`lakefile.lean`'s comments already carry the disambiguating information** that the names lack
   — each `lean_exe` block has a docstring saying what it runs and how. That is the content that
   should be in the module names.

## Suggested direction (not prescriptive)

A convention where the executable roots are visibly executables, e.g. a `Cli/` or `Main/`
subdirectory, or a uniform `*Main.lean` suffix — and where the library modules are named for what
they produce rather than for the verb "export". Something like:

- `DataExport.lean` → `Json.lean` or `Serialization.lean` (it is the `toJson`/`prettyPrint` layer)
- `DatasetExporter.lean` → `DatasetAssembly.lean` (it assembles and splits)
- `ProofStepExtractor.lean` → keep (it genuinely extracts)
- `DatasetExport.lean`, `ProofStepExport.lean` → mark as executable roots by location or suffix

Research should propose the convention and check it against the other eleven `lean_exe` roots in
`lakefile.lean`, several of which have the same shape (`BenchmarkOracle`, `TraceExporter`,
`MachineAppendixExport`, `TableauProofStepPipeline`, …). A convention that fixes five modules and
leaves eleven inconsistent is worth less than one applied across all thirteen roots.

## Constraints the rename must respect

- **C25** compile-checks every `lean_exe` root scraped from `lakefile.lean` at run time, so a
  renamed root is covered automatically — but the `root :=` line and the `srcDir` must stay
  consistent or the scrape silently covers the wrong module.
- **CI's "Compile `lean_exe` roots" step** greps `root\s*:=\s*\`([A-Za-z0-9_.]+)` from
  `lakefile.lean`. A rename is safe for it; a change in how roots are declared is not.
- **C8** requires exactly one sibling aggregator per directory (`X.lean` beside `X/`, never
  `X/X.lean`). Introducing a subdirectory means introducing its aggregator.
- **C4** (import resolution), **C24** (Init closure) and **C5/C12** (module-shaped paths in
  markdown) all move with a rename. `docs/training/PIPELINE.md`, `typst/chapters/p4-dataset-pipeline.typ`,
  `FormalSystem/Automation.lean`'s docstring and `FormalSystem/README.md` all name these modules.
- **`scripts/export-training-data.sh`** and `scripts/run_dataset_generation.sh` invoke the
  executables by their `lake exe` names. Renaming the *module* need not rename the *executable*;
  decide deliberately whether both change, and prefer keeping `lake exe` names stable since they
  appear in external documentation and the Hugging Face dataset card.

## Recommended approach

1. Propose one convention covering all thirteen `lean_exe` roots and their library siblings.
2. Apply it to the five modules in scope, leaving `lake exe` target names unchanged unless there
   is a reason to move them.
3. Update `lakefile.lean`, every import line, the aggregator, and every doc that names a renamed
   module in one commit per family so a regression bisects cleanly.

## Verification

- `lake build` exits 0; `lake exe dataset_generator --help` and `lake exe proof_extractor --help`
  (or their equivalent no-op invocations) still run.
- `bash scripts/check-module-invariants.sh` passes in full — C4, C5, C8, C12, C24, C25 in
  particular.
- `bash scripts/typst-sync-check.sh` still resolves every backticked module name (coordinate with
  task 586, which rewrites the chapter that names several of them).
- `scripts/export-training-data.sh` and `scripts/run_dataset_generation.sh` still work.
