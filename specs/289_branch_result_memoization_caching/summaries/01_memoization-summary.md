# Implementation Summary: Task #289 — Branch-Result Memoization/Caching

## Overview

Implemented a Mutex-protected bounded HashMap cache at the `labelBatch` and `DatasetExport` levels to eliminate redundant `labelFormulaImpl` calls for duplicate formulas within a batch. The cache stores complete `LabeledFormula` results keyed by `(Formula, FrameClass)`, is shared across parallel threads via `Std.Mutex`, and evicts by clearing the oldest half when exceeding 10K entries.

## Changes

### Files Modified (4)

1. **Theories/Bimodal/ProofSystem/Axioms.lean**
   - Added `BEq, Hashable` to `FrameClass` deriving clause

2. **Theories/Bimodal/Automation/DatasetGenerator.lean**
   - Added `import Std.Data.HashMap`
   - Added `DecideCacheKey` structure (Formula + FrameClass, deriving BEq/Hashable)
   - Added `DecideCache` structure with bounded HashMap, FIFO accessOrder, hit/miss/eviction counters
   - Added `DecideCache.empty`, `hitRate`, `lookup`, `insert`, `evict`, `display` methods
   - Added `labelFormulaWithCache` wrapper using `Std.Mutex` with short critical sections
   - Modified `labelBatch` to create shared cache and use `labelFormulaWithCache` in both sequential and parallel paths
   - Added `cacheMaxSize` parameter to `labelBatch` (default 10000)

3. **Theories/Bimodal/Automation/DatasetExport.lean**
   - Created shared `exportCache` via `Std.Mutex.new (DecideCache.empty 10000)`
   - Replaced `labelFormula` calls with `labelFormulaWithCache exportCache` in both parallel and sequential paths
   - Added cache statistics printing after labeling completion

4. **Theories/Bimodal/Automation/EnumBenchmark.lean**
   - Added `BenchmarkArgs` structure with `cacheSize` field
   - Added `--cache-size N` CLI flag parsing
   - Threaded `cacheSize` through `benchmarkValidFraction` and `benchmarkFullPipeline` to `labelBatch`

## Architecture

```
labelBatch / DatasetExport main
  │
  ├── Std.Mutex.new (DecideCache.empty cacheMaxSize)
  │
  └── for φ in formulas:
        │
        ├── cache.atomically { lookup key }  ← O(1) lock
        │     ├── HIT  → return cached result (method="cached", time=0ms)
        │     └── MISS → fall through
        │
        ├── labelFormula φ fc ...             ← NO lock held during computation
        │
        └── cache.atomically { insert key }  ← O(1) lock, triggers evict if > maxSize
```

**Thread safety**: The mutex is only held during O(1) HashMap operations. The expensive `labelFormula` call runs entirely outside the critical section.

**Eviction**: When `accessOrder.size > maxSize`, the oldest half of entries are removed from both the HashMap and the accessOrder array. This is a single bulk operation, not per-entry LRU.

## Plan Deviations

- Phase 1: Used `deriving BEq, Hashable` inline instead of standalone `Hashable` instance (simpler)
- Phase 1: Imported `Std.Data.HashMap` instead of `Std.Sync.Mutex` (Mutex available via transitive imports)
- Phase 2: `labelFormulaWithCache` calls `labelFormula` (not `labelFormulaImpl`) to support all generation modes (exhaustive, proofFirst, hybrid)
- Phase 2: Added `mode` and `proofFirstPool` parameters to `labelFormulaWithCache` for full mode forwarding
- Phase 3: Skipped `labelFormula` overload with optional cache parameter; `labelFormulaWithCache` is called directly
- Phase 4: Skipped separate `CacheStats` structure; `DecideCache.display` provides human-readable output from `labelBatch`
- Phase 4: Runtime benchmark execution deferred (requires compiled binary)

## Build Verification

- `lake build Bimodal.Automation.DatasetGenerator` -- passes (736 jobs)
- `lake build Bimodal.Automation.DatasetExport` -- passes (737 jobs)
- `lake build Bimodal.Automation.EnumBenchmark` -- passes (737 jobs)
- `lake build` (full project) -- pre-existing CanonicalTaskRelation heartbeat timeout; all task 289 modules pass
- Zero sorries in modified files
- Zero vacuous definitions
- Zero new axioms
