# scripts/

Build gates, drift ratchets, and one-off/utility tooling for this repository. Every script and
non-script data file that lives directly under `scripts/` (plus its `lib/` helper modules) is
named below; nothing in this directory is undocumented.

## Gates and ratchets

These are the scripts the module-invariant and README harnesses invoke; a red result here blocks
the deliverable-hygiene bar this task holds green.

| Script | Purpose |
|--------|---------|
| `check-module-invariants.sh` | Phase-gate harness for the Lean source tree: runs the full C1-C35 invariant suite that keeps the reorganization from silently drifting. |
| `readme-lint.sh` | Checks README health across `FormalSystem/`: missing per-directory READMEs, stale dates, and broken relative file references. |
| `check-copyright-headers.sh` | Copyright-header checker for this project's Lean sources (Mathlib's `linter.style.header` cannot see this project). |
| `check-evidence-probes.sh` | Compile-checks the bi-lasso decision layer's "evidence probes" — sorry-free Lean files that refute a design the decision layer once proposed. |
| `check-metalogic-cycles.sh` | Three assertions behind one exit code: `FormalSystem/Metalogic/` contains exactly one directory-level import cycle; the library-wide upward import set equals a recorded 7-line allowlist (fails on a shortfall as well as a surplus, on a module under `FormalSystem/` with no layer row, and on a stale per-file row); and inside the three language directories no syntax module imports a semantics module. |
| `check-paper-definitions.sh` | Detects drift between the JPL paper's semantic definitions and the pinned record at `docs/reference/paper-definitions-of-record.md`. |
| `CheckInitImportsMain.lean` | Lean entry point (near-verbatim port of CSLib's `CheckInitImports.lean`) that asserts every file imports its own directory's `Init`/root module before any sibling. |
| `warning-budget.py` | Build-free compiler-warning ratchet: measures the all-target warning surface from Lake's trace store and compares it against the committed baseline (closes the gap C16's declaration-only linting leaves open). |

## Dataset and benchmark utilities

Not gates — invoked on demand to (re)generate or validate the training/benchmark data pipeline.

| Script | Purpose |
|--------|---------|
| `export-training-data.sh` | Exports training data from BimodalLogic for sync to the external BimodalHarness project. |
| `run_dataset_generation.sh` | Runs production dataset generation for BMLogic training data at a given complexity tier. |
| `generate_dataset.py` | Converts a BimodalLogic JSON dataset to PyTorch tensors for ML training. |
| `validate_datasets.py` | Validates that all final datasets share a consistent field schema against the documented spec. |
| `validate_c5_dataset.py` | Validates a bmlogic JSONL dataset for well-formedness, field completeness, and an acceptable timeout rate. |
| `curate_benchmark.py` | BMLogic-Bench curation pipeline: loads production data and axiom instances, generates near-miss mutations, and stratified-samples the valid/invalid pools. |
| `curate_very_hard_plus.py` | Curates the very-hard-plus benchmark slice from the c9 dataset by difficulty heuristic. |
| `finalize_benchmark.py` | BMLogic-Bench finalization: stratified selection to target size/distribution, sequential ID assignment, and export. |
| `validate_benchmark.py` | BMLogic-Bench validation: oracle-result analysis, label-consistency checks against production data, and statistics. |
| `verify_benchmark.py` | BMLogic-Bench independent verification: parses every entry as valid JSON and re-checks the finished benchmark end to end. |

## Typst synchronization utilities

| Script | Purpose |
|--------|---------|
| `typst-status-counts.sh` | Single-source-of-truth generator for the volatile counts cited in `typst/` (sorry totals, axiom-constructor count, rule count). |
| `typst-module-map.sh` | Build-free generator for the Automation "Module Map" table cited in `typst/chapters/p4-proof-automation.typ`. |
| `typst-machine-appendix.sh` | Single-source-of-truth generator for the shipped machine-readable axiomatization, rendered into a typst data file. |
| `typst-sync-check.sh` | Mechanical drift detector for `typst/`: name resolution, count freshness, and declared-divergence bookkeeping. |

## Other utilities

| Script | Purpose |
|--------|---------|
| `lake_targets.py` | The single reader every script and CI step uses to enumerate the Lake targets declared in `lakefile.toml`, applying Lake's own defaults. |
| `measure-refactor-partitions.py` | Regenerates every structural-partition number cited in `docs/development/PUBLICATION_REFACTOR.md` and ADR-011 from the live tree. |
| `move-modules.py` | Relocates Lean modules from one auditable `old.module -> new.module` mapping, rewriting imports, dotted and slash citations, namespace/FQN occurrences, the axiom baselines and relative links in moved markdown, then performing the `git mv` and running the invariant harness. |
| `test-move-modules.py` | Fixture tests for `move-modules.py`: stdlib `unittest` only, each test building a disposable git repository in a temporary directory and running the tool's `run()` against it in process, plus one dry-run replay of a real past move against an export of its pre-move commit (skipped when that commit is absent; about a minute). Run as `python3 scripts/test-move-modules.py`. |
| `readme-inventory.sh` | Deprecated shim: module-inventory tables are now machine-owned via a `<!-- BEGIN GENERATED: inventory dir=... -->` block rather than pasted in by hand. |
| `export-lean-citations.py` | Generates `lean-citation-manifest.json`: resolves every fully qualified declaration name in `lean-citation-seeds.txt` to its current file, keyword line and span, reusing `lib/lean_citations.py`'s `decl_spans`/`candidates` so it cannot disagree with C20 about where a declaration lives. Exists so a consuming repository's adequacy argument can cite declaration **names** and include a generated line-numbered view, instead of hand-maintaining `file.lean:NNN` citations that nothing checks — four of which had drifted by exactly +38 lines. Deterministic by construction (no timestamp, no absolute path, seed-file entry order), which is what makes the C35 freshness assertion possible; `--check` compares without writing, and a name that resolves to zero or to several declarations is a named error entry and a non-zero exit, never a silently omitted row. |

## `lib/` helper modules

Python modules imported by the scripts above; not invoked directly.

| Module | Purpose |
|--------|---------|
| `import_graph.py` | The one place that turns a Lean file into its module name and a leading `import` block into edges; underlies `measure-refactor-partitions.py` and `check-metalogic-cycles.sh`. |
| `lean_debug_artifacts.py` | Comment-aware debug-artifact scanner for the module-invariant harness's C27, masking debug directives that appear only inside comments or docstrings. |
| `live_walk.py` | Shared Boneyard-excluding filesystem traversal used by every walk in `check-module-invariants.sh`, so the archive is filtered by directory name consistently everywhere. |
| `typst_axiom_report.py` | Renders `#print axioms` output as a typst `axiom-report-table` binding, using the display labels from `typst-axiom-report-modules.txt`. |

## Allowlists, manifests, and other data files

Not scripts — companion data consumed by the gates above.

| File | Purpose |
|------|---------|
| `boneyard-import-waivers.txt` | Archived import lines that C11 must not treat as repairable. |
| `debug-artifact-allowlist.txt` | Live debug directives that C27 must not treat as unreviewed debug output. |
| `markdown-link-allowlist.txt` | C13 companion: markdown files whose relative links are not resolution-checked. |
| `markdown-slash-path-allowlist.txt` | C12 companion: slash-shaped source paths permitted not to resolve. |
| `module-invariants-allowlist.txt` | Dotted names in markdown that C5 must not treat as module paths. |
| `lean-citation-seeds.txt` | `export-lean-citations.py`'s input: the reviewable list of fully qualified declaration names a consuming repository's transcription audit cites, grouped and commented. A field row writes `Parent.Name#field`, since a structure field opens no declaration span. |
| `lean-citation-manifest.json` | Generated by `export-lean-citations.py`; **do not hand-edit**. The line-numbered view of the seeded declarations, and the artifact C35 re-derives and compares on every run. |
| `module-invariants-manifest.txt` | Known-unreachable live modules, waived from the C6 rot guard. |
| `nolint-attribute-allowlist.txt` | In-source `nolint` attributes that C26 must not treat as an unreviewed suppression. |
| `nolints.json` | Machine-readable linter-suppression records consumed by the invariant harness. |
| `typst-axiom-report-modules.txt` | Display module label for each declaration in `typst-status-counts.sh`'s axiom-declaration list. |
| `warning-budget.txt` | Committed compiler-warning baseline for C28, generated by `warning-budget.py`. |
