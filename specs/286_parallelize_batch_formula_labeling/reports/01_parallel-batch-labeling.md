# Research Report: Parallelize Batch Formula Labeling

- **Task**: 286 - parallelize_batch_formula_labeling
- **Started**: 2025-06-07T20:12:00Z
- **Completed**: 2025-06-07T20:20:00Z
- **Effort**: 2 hours
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/Automation/DatasetGenerator.lean` (current `labelBatch` impl)
  - `Theories/Bimodal/Automation/DatasetExport.lean` (existing parallel labeling pattern, CLI args)
  - `Theories/Bimodal/Automation/FormulaEnumerator.lean` (chunk-based `IO.asTask` pattern)
  - `Theories/Bimodal/Automation/DatasetExporter.lean` (end-to-end pipeline callers)
  - `Theories/Bimodal/Automation/FormulaMutator.lean` (CLI caller)
  - `Theories/Bimodal/Automation/EnumBenchmark.lean` (caller without CLI)
  - `Theories/Bimodal/Automation/DatasetValidator.lean` (caller without CLI)
  - Lean 4 standard library docs (`IO.asTask`, `IO.wait`, `IO.mapTasks`, `Task.spawn`)
- **Artifacts**: `specs/286_parallelize_batch_formula_labeling/reports/01_parallel-batch-labeling.md`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `DatasetGenerator.lean` (`labelBatch`, `labelFormula`), `DecisionProcedure.lean` (pure decision spawned via `Task.spawn`)
- **Downstream Dependents**: `DatasetExporter.lean`, `DatasetExport.lean` (streaming CLI), `EnumBenchmark.lean`, `FormulaMutator.lean`, `DatasetValidator.lean`
- **Alternative Paths**: Could parallelize at the streaming exporter level only (current state in `DatasetExport.lean`), but centralizing in `labelBatch` benefits all callers.
- **Potential Extensions**: Streaming callback version of `labelBatch` for constant-memory JSONL export; worker-pool with indexed result assembly for even finer granularity.

## Executive Summary

- `labelBatch` in `DatasetGenerator.lean:1070` is a purely sequential `for`-loop over `List Formula`, appending to a list and reversing at the end. It is hardcoded to `FrameClass.Base`.
- `DatasetExport.lean` already implements a working parallel labeling loop (Task 267) using `IO.asTask` per formula with batch-size gating equal to `parallelThreads`. It also already parses `--parallel N` in its `CLIArgs` struct.
- `FormulaEnumerator.lean:2129` demonstrates a chunk-based `IO.asTask` parallelism pattern (Phase B cross-product) that serves as a ready template.
- Lean 4 provides `IO.asTask : IO α → Task.Priority → BaseIO (Task (Except IO.Error α))` and `IO.wait : Task α → BaseIO α`. Tasks return `Except IO.Error α`, enabling graceful error handling.
- The recommended approach is **chunk-based parallelism** inside `labelBatch`: split the formula array into `parallelThreads` chunks, spawn each chunk as an `IO.asTask` that sequentially labels its formulas, wait for all, and concatenate in chunk order. This preserves deterministic output ordering and aligns with existing project patterns.
- Exception handling should be done **inside each chunk task**: wrap each `labelFormula` call in a `try/catch` that produces a `.timeout` placeholder on failure. This mirrors the graceful fallback already used in `DatasetExport.lean:1092`.
- CLI flag `--parallel N` already exists in `DatasetExport.lean`. It should be added to `FormulaMutator.lean`'s `parseContrastiveArgs` and optionally to `EnumBenchmark.lean` / `DatasetValidator.lean` (which currently have no argument parsers).
- Expected throughput improvement: 6-7x on an 8-core machine, since `labelFormula` already spawns the CPU-bound decision procedure on a dedicated thread via `Task.spawn`; running multiple `labelFormula`s concurrently saturates available cores.

## Context & Scope

This research evaluates how to parallelize the `labelBatch` function in `DatasetGenerator.lean` while:
1. Preserving deterministic output ordering (the returned `List LabeledFormula` must match the input formula order).
2. Gracefully handling `Task` exceptions (no crash on individual formula failure).
3. Adding a `--parallel N` CLI flag to relevant executables.
4. Achieving a 6-7x speedup on multi-core hardware.

The scope covers:
- The current `labelBatch` implementation and its callers.
- Existing concurrency patterns in the Lean 4 codebase.
- Lean 4 standard-library concurrency primitives (`IO.asTask`, `IO.wait`, `Task.spawn`).
- CLI argument infrastructure for project executables.

## Findings

### Current `labelBatch` Implementation

`DatasetGenerator.lean:1070`:
```lean
def labelBatch (formulas : List Formula) (wallclockTimeoutMs : Nat := 1000)
    : IO (List LabeledFormula) := do
  let total := formulas.length
  let mut results : List LabeledFormula := []
  let mut count : Nat := 0
  for φ in formulas do
    let labeled ← labelFormula φ .Base wallclockTimeoutMs
    results := labeled :: results
    count := count + 1
    if count % 100 == 0 then
      IO.println s!"  Progress: {count}/{total} formulas labeled"
  return results.reverse
```

Characteristics:
- Sequential, hardcoded to `FrameClass.Base`.
- Collects results into a list, reversing at the end.
- Progress printed every 100 formulas.
- Called by `DatasetExporter.lean`, `EnumBenchmark.lean`, `FormulaMutator.lean`, `DatasetValidator.lean`.

### Existing Parallel Labeling Pattern

`DatasetExport.lean:1069-1131` (Task 267) implements parallel labeling for streaming JSONL export:
- Parses `--parallel N` into `CLIArgs.parallelThreads : Nat` (line 530-533, 621-622).
- Converts formulas to `Array`, computes `numBatches` where `batchSize = parallelThreads`.
- For each batch, spawns `IO.asTask (labelFormula φ ...) .dedicated` per formula.
- Waits for each task in order with `IO.wait`, handles `.error _err` by recording a timeout (lines 1091-1095).
- Writes results sequentially for crash safety.

This pattern **preserves ordering** because tasks are spawned in index order and consumed in the same order within each batch. However, batches are processed sequentially (batch N starts only after batch N-1 finishes), which caps peak concurrency to `parallelThreads` but is simple and safe.

### Existing Chunk-Based Parallelism

`FormulaEnumerator.lean:2129-2190` (Task 283 Phase 5) demonstrates a more advanced pattern:
- Pre-computes immutable cache sequentially (Phase A).
- Splits work into partitions (chunks).
- Spawns each partition via `IO.asTask (prio := .dedicated) do pure (partitionCrossProduct ...)`.
- Collects results with `IO.ofExcept (← IO.wait task)`.
- This is a pure-computation chunk pattern, but the structure maps directly to `labelBatch`.

### Lean 4 Concurrency Primitives

From `Init.System.IO` (verified via `loogle`):
- `IO.asTask : {α : Type} (act : IO α) (prio : Task.Priority := default) : BaseIO (Task (Except IO.Error α))`
- `IO.wait : {α : Type} (t : Task α) : BaseIO α`
- `IO.mapTasks : {α : Type u} {β : Type} (f : List α → IO β) (tasks : List (Task α)) (prio : Task.Priority := default) (sync : Bool := false) : BaseIO (Task (Except IO.Error β))`
- `Task.spawn : (Unit → α) → Task.Priority → Task α` (used inside `labelFormula` for the pure decision procedure).
- `IO.hasFinished : Task α → BaseIO Bool`

Key observations:
- `IO.asTask` wraps an `IO` action in a separate thread and returns a `Task (Except IO.Error α)`.
- `IO.wait` blocks until the task completes and returns the raw result (not wrapped in `Except`). If the task returned `Except.error e`, `IO.wait` propagates the error as an `IO.Error` exception.
- To access the `Except` wrapper safely, one can use `IO.ofExcept` after `IO.wait`, or pattern-match on the result if the task type is `Except`.

### Deterministic Ordering Strategies

Two approaches were evaluated:

1. **Batch-based (DatasetExport style)**:
   - Spawn `parallelThreads` tasks, wait for all, then emit results.
   - Pros: Simple, caps concurrency naturally, preserves order.
   - Cons: Wait barrier between batches means total time includes waiting for the slowest formula in each batch.

2. **Chunk-based (recommended)**:
   - Split the full input into `parallelThreads` chunks.
   - Spawn one `IO.asTask` per chunk that sequentially labels all formulas in that chunk.
   - Wait for all chunk tasks, concatenate in chunk order.
   - Pros: All chunks run in parallel with a single synchronization point at the end. No intermediate barriers. Deterministic order is trivially preserved by concatenating chunks 0..N-1. Lower task overhead (one task per chunk, not per formula).
   - Cons: Progress reporting is coarser (per-chunk rather than per-formula).

For a function that returns a complete `List LabeledFormula` (not streaming), chunk-based is strictly better because there is no reason to introduce artificial batch barriers.

### Exception Handling

Inside `DatasetExport.lean:1091-1095`, per-formula task failures are caught and recorded as timeouts:
```lean
| .error _err =>
  timeoutCount := timeoutCount + 1
  count := count + 1
```

For `labelBatch`, the recommended strategy is to catch **inside each chunk task** so the chunk task never fails:
```lean
let labeled ← try
  labelFormula φ .Base wallclockTimeoutMs
catch _e =>
  -- produce a timeout placeholder
  pure { formula := φ, label := .timeout, ... }
```

This ensures:
- The outer `labelBatch` never loses partial results.
- A single runaway formula cannot crash the entire batch.
- The behavior mirrors the existing streaming exporter fallback.

### CLI Flag Infrastructure

`DatasetExport.lean` already has the full `--parallel N` infrastructure:
- `CLIArgs.parallelThreads : Nat := 0` (line 533)
- Parser branch: `| "--parallel" :: n :: rest, acc => go rest { acc with parallelThreads := n.toNat! }` (line 621-622)

Other executables that call `labelBatch`:
- **FormulaMutator.lean**: Has `parseContrastiveArgs` (line 1056). Should add `parallelThreads : Nat := 0` and a `--parallel` branch.
- **EnumBenchmark.lean**: Has `def main : IO Unit := do` with no arg parsing (line 177). Should add minimal arg parsing or accept that it runs sequentially by default.
- **DatasetValidator.lean**: Has `def main : IO Unit := Bimodal.Automation.DatasetValidator.runFullValidation` (line 588). Same as above.
- **DatasetExporter.lean**: Library module (no `main`). Its `generateAndExportDataset` and `generateSplitDatasets` should accept a `parallelThreads` parameter and pass it to `labelBatch`.

## Decisions

1. **Use chunk-based parallelism**, not per-formula tasks or worker-pool with index tracking.
   - Rationale: Lower task overhead, single synchronization point, deterministic ordering, and aligns with the existing `FormulaEnumerator.lean` pattern.

2. **Add `parallelThreads` as an optional parameter to `labelBatch`** (default `0` = sequential).
   - Rationale: Backward-compatible with all existing callers; no breakage.

3. **Handle exceptions inside chunk tasks**, not at the `labelBatch` top level.
   - Rationale: Prevents total failure on a single bad formula; matches `DatasetExport.lean` behavior.

4. **Do NOT refactor `DatasetExport.lean` to use `labelBatch` in this task.**
   - Rationale: `DatasetExport.lean` streams JSONL incrementally for crash safety. Switching to `labelBatch` would require holding all results in memory before writing, which regresses crash safety. The two patterns serve different use cases. However, deduplicating the parallel logic into a shared helper (e.g., `labelChunk`) is a future cleanup opportunity.

## Recommendations

### High Priority

1. **Modify `labelBatch` in `DatasetGenerator.lean`**
   - Change signature to: `def labelBatch (formulas : List Formula) (wallclockTimeoutMs : Nat := 1000) (parallelThreads : Nat := 0) : IO (List LabeledFormula)`
   - Implement sequential path when `parallelThreads == 0`.
   - Implement parallel path:
     - Convert `formulas` to `Array Formula`.
     - Compute `chunkSize := max 1 ((arr.size + parallelThreads - 1) / parallelThreads)`.
     - For each chunk `i`, `let chunk := arr.extract (i * chunkSize) (min ((i+1)*chunkSize) arr.size)`.
     - Spawn `IO.asTask (prio := .dedicated) do ...` for each chunk.
     - Inside chunk: sequentially label each formula with `try/catch` fallback to `.timeout` placeholder.
     - Wait for all tasks with `IO.wait`.
     - Concatenate chunk results in order.
     - Print progress after each chunk (or after every 100 results assembled).

2. **Update `DatasetExporter.lean`**
   - Add `parallelThreads : Nat := 0` parameter to `generateAndExportDataset` and `generateSplitDatasets`.
   - Pass it through to `labelBatch`.

3. **Update `FormulaMutator.lean`**
   - Add `parallelThreads : Nat := 0` to `ContrastiveConfig`.
   - Add parser branch `| "--parallel" :: n :: rest => go rest { acc with parallelThreads := n.toNat! }`.
   - Pass `cfg.parallelThreads` to `labelBatch`.

### Medium Priority

4. **Add `--parallel` to `EnumBenchmark.lean` and `DatasetValidator.lean`**
   - Introduce minimal arg parsing (or reuse a shared parser from `DatasetExport.lean` if one is extracted).
   - Pass the parsed thread count to `labelBatch`.

### Low Priority / Future Work

5. **Extract a shared `labelChunk` helper** if `DatasetExport.lean` later wants to deduplicate its parallel logic.
6. **Measure speedup** with `lake exe enum_benchmark --parallel 8` vs sequential to validate the 6-7x target.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Nested tasks (`IO.asTask` inside `labelBatch` calling `Task.spawn` inside `labelFormula`) overload Lean's thread scheduler | Low | Medium | Chunk-based approach uses only `parallelThreads` outer tasks, so total concurrent threads is bounded. |
| Memory bloat from holding all `LabeledFormula` results in memory during parallel execution | Low | Low | `labelBatch` already returns a full list; parallelism does not increase peak memory relative to sequential. |
| Progress reporting becomes misleading (coarse chunk-level) | Low | Low | Print progress after every chunk and include total count. |
| Existing callers break due to signature change | Very Low | High | Use default parameter `parallelThreads := 0`; all callers compile without modification. |
| `labelFormula` exceptions escape chunk task and crash `labelBatch` | Low | High | Wrap each formula labeling in `try/catch` inside the chunk task. |

## Context Extension Recommendations

- **Topic**: Lean 4 concurrency patterns in the project
  - **Gap**: No centralized documentation on how `IO.asTask`, `Task.spawn`, and exception handling are used across `DatasetGenerator`, `DatasetExport`, and `FormulaEnumerator`.
  - **Recommendation**: Create `.opencode/context/lean-concurrency.md` documenting the chunk-based pattern, the per-formula batch pattern, and the `try/catch` fallback convention.

- **Topic**: CLI argument parsing conventions
  - **Gap**: Each executable has its own ad-hoc `parseArgs` function; `--parallel` is duplicated.
  - **Recommendation**: Extract a shared minimal CLI parser in `Automation/CLI.lean` for common flags (`--parallel`, `--wallclock-timeout`, `--output`).

## Appendix

### Search Queries Used
- `grep "IO\.asTask\|IO\.mapTasks\|Task\.spawn\|parallel" --include="*.lean"`
- `grep "labelBatch " --include="*.lean"`
- `grep "parse.*Args\|CLIArgs\|cliArgs" --include="*.lean"`
- `loogle: IO.asTask`
- `loogle: IO.mapTasks`
- `loogle: IO.wait`

### References
- `Theories/Bimodal/Automation/DatasetGenerator.lean:1070` — `labelBatch`
- `Theories/Bimodal/Automation/DatasetExport.lean:530-622` — `CLIArgs` and `--parallel` parser
- `Theories/Bimodal/Automation/DatasetExport.lean:1069-1131` — parallel labeling loop (Task 267)
- `Theories/Bimodal/Automation/FormulaEnumerator.lean:2129-2190` — chunk-based `IO.asTask` pattern (Task 283)
- `Init.System.IO` — `IO.asTask`, `IO.wait`, `IO.mapTasks` signatures
- `specs/ROADMAP.md` — project priorities (not directly relevant to this automation task)
