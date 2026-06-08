# Implementation Plan: Parallelize Batch Formula Labeling

- **Task**: 286 - parallelize_batch_formula_labeling
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/286_parallelize_batch_formula_labeling/reports/01_parallel-batch-labeling.md
- **Artifacts**: plans/01_parallel-batch-labeling.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the sequential `for` loop in `DatasetGenerator.lean`'s `labelBatch` with a chunk-based parallel approach using `IO.asTask`. Add an optional `parallelThreads` parameter (default `0` = sequential) for backward compatibility. Handle exceptions inside chunk tasks by producing `.timeout` placeholders. Update all downstream callers (`DatasetExporter.lean`, `FormulaMutator.lean`, and optionally `EnumBenchmark.lean` / `DatasetValidator.lean`) to accept and forward the parameter. Add `--parallel N` CLI flags where missing. The target is a 6-7x throughput improvement on multi-core machines while preserving deterministic output ordering.

### Research Integration

The research report (specs/286_parallelize_batch_formula_labeling/reports/01_parallel-batch-labeling.md) identified:

- `labelBatch` at `DatasetGenerator.lean:1070` is a purely sequential loop over `List Formula`, hardcoded to `FrameClass.Base`.
- `DatasetExport.lean` already implements per-formula `IO.asTask` parallelism (Task 267) and has a `--parallel N` CLI flag.
- `FormulaEnumerator.lean:2129-2190` demonstrates a chunk-based `IO.asTask` pattern that serves as a ready template.
- Recommended approach: **chunk-based parallelism** -- split input into `parallelThreads` chunks, spawn one task per chunk, wait for all, concatenate in chunk order. This preserves deterministic ordering and avoids intermediate batch barriers.
- Exception handling should be **inside each chunk task**, producing a `.timeout` placeholder on failure, mirroring `DatasetExport.lean:1092`.

### Prior Plan Reference

No prior plan exists for this task.

### Roadmap Alignment

This is an automation/infrastructure task (DatasetGenerator/Automation modules) and does not directly advance the BX completeness critical path in `specs/ROADMAP.md`. It improves dataset generation throughput for downstream ML and benchmarking workflows. No ROADMAP.md items are directly advanced by this task.

## Goals & Non-Goals

**Goals**:
- Parallelize `labelBatch` with chunk-based `IO.asTask` while preserving deterministic output ordering.
- Add `parallelThreads : Nat := 0` parameter to `labelBatch` for backward-compatible opt-in parallelism.
- Handle `labelFormula` exceptions gracefully inside chunk tasks (`.timeout` fallback).
- Add `--parallel N` CLI flag to `FormulaMutator.lean`.
- Plumb `parallelThreads` through `DatasetExporter.lean` (`generateAndExportDataset`, `generateSplitDatasets`).
- Verify build correctness and deterministic ordering.
- Benchmark throughput to validate the 6-7x improvement target.

**Non-Goals**:
- Do NOT refactor `DatasetExport.lean` to use `labelBatch` (streaming JSONL export needs crash-safe incremental writes; the research recommends keeping the two patterns separate).
- Do NOT extract a shared CLI parser (out of scope; noted as future work in research).
- Do NOT change `labelFormula` internals (the per-formula `Task.spawn` inside `labelFormula` remains unchanged).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Nested task overload (IO.asTask inside labelBatch calling Task.spawn inside labelFormula) | Medium | Low | Chunk-based approach caps outer tasks to `parallelThreads`; total concurrent threads is bounded. |
| Memory bloat during parallel execution | Low | Low | `labelBatch` already returns a full list; peak memory does not increase relative to sequential. |
| Existing callers break from signature change | High | Very Low | Use default parameter `parallelThreads := 0`; all callers compile without modification. |
| Exceptions escape chunk task and crash `labelBatch` | High | Low | Wrap each `labelFormula` call in `try/catch` inside the chunk task. |
| Progress reporting becomes coarse | Low | Low | Print progress after each chunk and include total count assembled so far. |
| Deterministic ordering violated by parallelism | High | Very Low | Chunk-based design concatenates results in chunk index order; no reordering occurs. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Core `labelBatch` Parallelization [COMPLETED]

**Goal**: Modify `DatasetGenerator.lean` to support chunk-based parallel labeling inside `labelBatch` with backward-compatible signature.

**Tasks**:
- [ ] Add `parallelThreads : Nat := 0` parameter to `labelBatch` signature.
- [ ] Implement sequential path: when `parallelThreads == 0`, use the existing `for`-loop logic.
- [ ] Implement parallel path:
  - Convert `formulas : List Formula` to `Array Formula`.
  - Compute `chunkSize := max 1 ((arr.size + parallelThreads - 1) / parallelThreads)`.
  - For each chunk index `i`, extract `arr.extract (i * chunkSize) (min ((i+1)*chunkSize) arr.size)`.
  - Spawn each chunk as `IO.asTask (prio := .dedicated) do ...`.
  - Inside each chunk task: sequentially label each formula with `try/catch` fallback that produces a `LabeledFormula` with `.timeout` label on exception.
  - Wait for all tasks with `IO.wait`, collecting results.
  - Concatenate chunk results in chunk index order to preserve deterministic ordering.
  - Print progress after each chunk completion (e.g., "Progress: X/Y formulas labeled").
- [ ] Verify the modified function still hardcodes `FrameClass.Base` (no change to frame class behavior).

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - `labelBatch` implementation and signature.

**Verification**:
- `lake build` succeeds with no errors.
- Calling `labelBatch formulas` (without `parallelThreads`) still compiles and behaves sequentially.

---

### Phase 2: `DatasetExporter.lean` Parameter Plumbing [COMPLETED]

**Goal**: Pass `parallelThreads` through the end-to-end pipeline functions in `DatasetExporter.lean`.

**Tasks**:
- [ ] Add `parallelThreads : Nat := 0` parameter to `generateAndExportDataset`.
- [ ] Forward the parameter to the `labelBatch` call inside `generateAndExportDataset`.
- [ ] Add `parallelThreads : Nat := 0` parameter to `generateSplitDatasets`.
- [ ] Forward the parameter to the `labelBatch` call inside `generateSplitDatasets`.

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExporter.lean` - `generateAndExportDataset` and `generateSplitDatasets` signatures and calls.

**Verification**:
- `lake build` succeeds.
- Existing calls to these functions without the new parameter still compile.

---

### Phase 3: `FormulaMutator.lean` CLI Flag [COMPLETED]

**Goal**: Add `--parallel N` CLI argument parsing to the contrastive pair generator.

**Tasks**:
- [ ] Add `parallelThreads : Nat := 0` field to `ContrastiveConfig`.
- [ ] Add parser branch: `| "--parallel" :: n :: rest, cfg => go rest { cfg with parallelThreads := n.toNat! }` inside `parseContrastiveArgs`.
- [ ] Update the `main` function to print the configured `parallelThreads` in the startup banner.
- [ ] Pass `cfg.parallelThreads` to the `labelBatch` call in `main`.

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` - `ContrastiveConfig`, `parseContrastiveArgs`, and `main`.

**Verification**:
- `lake build` succeeds.
- `lake exe formula_mutator --parallel 4` parses the flag and runs.

---

### Phase 4: Optional CLI Flags for Benchmark and Validator [COMPLETED]

**Goal**: Add minimal `--parallel N` argument parsing to `EnumBenchmark.lean` and `DatasetValidator.lean`.

**Tasks**:
- [ ] In `EnumBenchmark.lean`: add minimal arg parsing (e.g., scan `args` for `--parallel N`) and pass the parsed value to `labelBatch`.
- [ ] In `DatasetValidator.lean`: add minimal arg parsing (e.g., scan `args` for `--parallel N`) and pass the parsed value to `labelBatch`.
- [ ] If either file has no existing arg parser, implement a small inline scan (consistent with `parseContrastiveArgs` style).

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/EnumBenchmark.lean` - `main` and arg parsing.
- `Theories/Bimodal/Automation/DatasetValidator.lean` - `main` and arg parsing.

**Verification**:
- `lake build` succeeds.
- Both executables accept `--parallel N` and pass it through.

---

### Phase 5: Build Verification and Correctness Testing [COMPLETED]

**Goal**: Ensure all modified files compile and that parallel execution preserves deterministic ordering.

**Tasks**:
- [ ] Run `lake build` for the full project and fix any compile errors.
- [ ] Run `lake exe dataset_exporter` (or whichever executable tests the pipeline) without `--parallel` to confirm backward compatibility.
- [ ] Run the same executable with `--parallel 4` and verify it completes without crashes.
- [ ] Verify deterministic ordering: label a small batch with `--parallel 4` and compare output formula order against the input list order.
- [ ] Verify exception handling: if possible, inject a slow/formula that would timeout and confirm it produces a `.timeout` entry rather than crashing.
- [ ] Check for unused imports or variables introduced by changes.

**Timing**: 1 hour

**Depends on**: 2, 3, 4

**Files to modify**:
- None (testing phase).

**Verification**:
- `lake build` is clean (no errors, no warnings).
- Parallel run produces identical label order as sequential run for the same input.

---

### Phase 6: Benchmark Throughput Validation [COMPLETED]

**Goal**: Measure actual speedup and validate the 6-7x improvement target on multi-core hardware.

**Tasks**:
- [ ] Run a medium-sized formula set (e.g., complexity 6, modal depth 2, temporal depth 2) through `labelBatch` sequentially and record elapsed time.
- [ ] Run the same formula set with `--parallel 4` and `--parallel 8`, recording elapsed times.
- [ ] Compute speedup ratios (sequential time / parallel time) for each thread count.
- [ ] If speedup is significantly below target (< 4x at 8 threads), investigate bottlenecks (GIL-like contention, IO bottlenecks, Task.spawn overhead inside labelFormula).
- [ ] Document results in a brief summary note (can be inline in this plan or a short markdown file in `summaries/`).

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- None (benchmarking phase).

**Verification**:
- Benchmark results show measurable speedup; target is 6-7x at 8 threads.
- No regressions in output correctness or ordering.

## Testing & Validation

- [ ] `lake build` passes with zero errors.
- [ ] Backward compatibility: existing callers compile without modification.
- [ ] Deterministic ordering: output list order matches input list order for parallel runs.
- [ ] Graceful exception handling: a failing formula inside a chunk produces `.timeout` rather than crashing the batch.
- [ ] CLI flag parsing: `--parallel N` is accepted by `FormulaMutator.lean`, `EnumBenchmark.lean`, and `DatasetValidator.lean`.
- [ ] Throughput benchmark shows 6-7x speedup on an 8-core machine.

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DatasetGenerator.lean` - updated `labelBatch` with chunk-based parallelism.
- `Theories/Bimodal/Automation/DatasetExporter.lean` - updated `generateAndExportDataset` and `generateSplitDatasets` with `parallelThreads` plumbing.
- `Theories/Bimodal/Automation/FormulaMutator.lean` - updated `ContrastiveConfig`, parser, and `main` with `--parallel` flag.
- `Theories/Bimodal/Automation/EnumBenchmark.lean` - updated `main` with `--parallel` flag (optional).
- `Theories/Bimodal/Automation/DatasetValidator.lean` - updated `main` with `--parallel` flag (optional).
- `specs/286_parallelize_batch_formula_labeling/plans/01_parallel-batch-labeling.md` - this plan.
- Benchmark results summary (to be produced in Phase 6).

## Rollback/Contingency

If the parallel implementation introduces instability or build failures that cannot be quickly resolved:

1. Revert `DatasetGenerator.lean` to the original sequential `labelBatch` signature (remove `parallelThreads` parameter and restore the original `for`-loop body).
2. Revert downstream caller changes in `DatasetExporter.lean`, `FormulaMutator.lean`, `EnumBenchmark.lean`, and `DatasetValidator.lean`.
3. Fall back to the sequential implementation and revisit parallelism in a follow-up task with additional debugging.
4. Keep the research report findings as reference for the retry.
