# Implementation Summary: Task #591

- **Task**: 591 - Consolidate the confusable `Automation/` export module names
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T09:59:03-07:00
- **Completed**: 2026-09-16T11:38:31-07:00
- **Effort**: ~1.5 hours wall-clock (mostly queued guarded builds)
- **Dependencies**: None
- **Artifacts**: plans/02_exe-root-rename-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Adopted one naming rule for every `lean_exe` root: the root of `lake exe foo_bar` is `FooBarMain`, and `Main` is reserved for exe roots. The rule was applied to all 13 roots in `lakefile.lean`, plus one library rename (`DatasetExporter` -> `DatasetAssembly`). A new invariant check, C25N, enforces the rule. `lake exe` target names, `srcDir` values and emitted provenance strings did not change.

## What Changed

- Exe roots renamed (file, `root :=`, per-module namespace where one existed): `DatasetExport`->`DatasetGeneratorMain`, `DatasetValidator`->`DatasetValidatorMain`, `ProofStepExport`->`ProofExtractorMain`, `TableauProofStepPipeline`->`TableauProofStepsMain`, `ProofFirstExporter`->`ProofFirstGeneratorMain` (shared namespace kept), `EnumBenchmark`->`EnumBenchmarkMain` (no namespace), `BenchmarkAnchors`->`BenchmarkAnchorsMain`, `BenchmarkOracle`->`BenchmarkOracleMain`, `FormulaMutator`->`ContrastiveGeneratorMain`, `TableauBridge`->`TableauBridgeMain`, `TraceExporter`->`TraceExporterMain`, `MachineAppendixExport`->`MachineAppendixMain`, `scripts/CheckInitImports`->`scripts/CheckInitImportsMain`
- Library: `FormalSystem/Automation/DatasetExporter.lean` -> `DatasetAssembly.lean` (namespace too). `DataExport` and `ProofStepExtractor` keep their names
- Functional script edits: `scripts/check-module-invariants.sh` `C22_B` path; `scripts/typst-machine-appendix.sh` build and `lean --run` lines
- Imports and references: `FormalSystem/Automation.lean`, `Tests/BimodalTest/Automation/{C5SmokeTest,ProofFirstTests,FormulaMutatorTest}.lean`, `Tests/BimodalTest.lean`, and docstrings in `AxiomNames`, `DatasetGenerator`, `Normalization`, `Init`, `TemporalDerived` and the renamed modules
- Docs and typst: `docs/training/PIPELINE.md` (stale "Despite the similar name" note removed), `SYNC_PROTOCOL.md`, `docs/ARCHITECTURE.md`, `docs/development/{MODULE_INVARIANTS,NAMING_CONVENTION_DEVIATION}.md`, `docs/architecture/untl-snce-argument-order.md`, `FormalSystem/Metalogic/Decidability/README.md`, `typst/chapters/p4-dataset-pipeline.typ`, `typst/sync-check-whitelist.txt`, `.github/workflows/ci.yml` (comment), `scripts/{generate_dataset.py,curate_benchmark.py,module-invariants-manifest.txt}`
- Convention: a new "Module naming" section in `FormalSystem/Automation/README.md` (inventory regenerated); a new `C25N` check in `scripts/check-module-invariants.sh` with a matching row in `MODULE_INVARIANTS.md`
- Provenance IDs `"BimodalLogic/DatasetExporter"` and `"BimodalLogic/MachineAppendixExport"` are byte-identical at every emitting site, and each now has a comment saying it is a stable ID, not a module path

## Decisions

- Token-boundary rename (`(?<![A-Za-z0-9_])(?<!BimodalLogic/)Old(?![A-Za-z0-9_])`) over live surfaces, so `FormulaMutatorTest`, `TraceExporterE2ETest`, `TraceExport` and the provenance literals are untouched
- Historical narrative keeps the old name in parentheses ("`ProofExtractorMain.lean` (then `ProofStepExport.lean`)"). The CSLib upstream filename `scripts/CheckInitImports.lean` in the port note keeps its spelling
- C25N is its own labelled check. It is textual, so it runs under `--no-build` too
- The README's broken `lake run FormalSystem.Automation.DatasetExporter` and `BenchmarkOracle` examples were replaced with the real `lake exe dataset_generator` / `lake exe benchmark_oracle` invocations

## Plan Deviations

- **Phase 1** altered: the Automation README inventory was regenerated early because INV flagged the renamed rows. Rows for files another session was editing were left at their HEAD counts
- **Phase 2** altered: the planned cross-ref targets `TableauBridge.lean`, `ProofStepExtractor.lean`, `curate_benchmark.py` and the manifest held no phase-2 names. `TemporalDerived.lean`, `ARCHITECTURE.md` and the historical comments were updated instead
- **Phase 3** altered: `typst-machine-appendix.sh` was verified by running its functional `lean --run` line into a scratch file with the committed stamps. The result was byte-identical to the committed JSONL. The full script would re-stamp the committed artifact with today's HEAD and date. The aggregate `BimodalTest` target in the phase-3 targeted build failed only on a concurrent session's uncommitted test move. All 8 renamed modules, their exes and `FormulaMutatorTest` built, and the phase-5 full gate later showed `lake build BimodalTest` green
- **Phase 4** altered: the guard is `C25N` with its own row rather than a rewrite of C25. The bad-root negative test ran against a scratch mirror of `lakefile.lean` so concurrent builds never saw a broken lakefile. The optional lean4 context-extension note was skipped because it is out of deliverable scope
- **Phase 5** altered: see typst-sync-check under Verification

## Verification

- Build: Success. Full guarded `lake build` exit 0. Full `check-module-invariants.sh` (with build) exit 0: C1, C4, C5, C6, C8, C12, C16, C22, C24, C25, C25N and INV all PASS
- Sorry count: 0 structural sorries in the live tree (C3 PASS; census hits are Boneyard only)
- Vacuous count: 0
- Axiom count: not increased (9 live `^axiom` lines vs 11 at the pre-task commit; the decrease comes from other tasks)
- Tests: `lake build BimodalTest` PASS (in C1). Smoke runs: `dataset_generator` ran; `proof_extractor` emitted 12,077 steps; `run_dataset_generation.sh smoke` validation passed (321 lines); `export-training-data.sh --dry-run c5` ok; `checkInitImports` built from `CheckInitImportsMain`; C25N negative tests failed as expected (exit 1)
- typst-sync-check: every renamed module name resolves, and Checks 2 and 3 are clean. The script still exits FAIL on 4 Check-1 violations, all in `typst/chapters/p4-proof-automation.typ` (`AesopRules.lean`, `Tactics/Helpers.lean`, `tm_auto 5`). These predate this task and are unrelated to it
- Files verified: Yes. The residue grep for all 14 old names finds only the provenance literals, the historical "(then ...)" notes and the CSLib upstream filename. `data/` and `typst/generated/` are unchanged

## Impacts

- A new `lean_exe` must name its root `PascalCase(target)Main` or C25N fails
- Anything citing the old module paths (external notes, open plans for other tasks) must use the new names. `lake exe` targets and the Hugging Face card are unaffected
- Concurrent sessions' commits swept some of this task's hunks (`check-module-invariants.sh`, `typst/sync-check-whitelist.txt`, `Tests/BimodalTest.lean`) into their own commits. The content is correct in HEAD

## Follow-ups

- Split `main` out of the three test-imported roots (`DatasetValidatorMain`, `ContrastiveGeneratorMain`, `ProofFirstGeneratorMain`) into thin mains, so library code can live in a non-`Main` module (for example `FormulaMutator`)
- Fix the pre-existing `p4-proof-automation.typ` typst-sync violations (belongs to the p4 chapter rewrite)

## References

- specs/591_consolidate_automation_export_names/plans/02_exe-root-rename-plan.md
- specs/591_consolidate_automation_export_names/reports/02_exe-root-naming-convention.md
- specs/591_consolidate_automation_export_names/reports/01_confusable-export-module-names.md
