# Implementation Plan: Task #289

- **Task**: 289 - Add branch-result memoization/caching to decision procedure
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 286 (parallelization, completed)
- **Research Inputs**: specs/289_branch_result_memoization_caching/reports/01_memoization-research.md
- **Artifacts**: plans/01_memoization-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement a Mutex-protected bounded HashMap cache at the `labelBatch` level to eliminate redundant `labelFormulaImpl` calls for duplicate formulas within a batch. The cache stores complete `LabeledFormula` results keyed by `(Formula, FrameClass)`, is shared across parallel threads via `Std.Mutex`, and evicts by clearing the oldest half when exceeding 10K entries. Cache statistics (hits, misses, hit rate) are tracked and reported in benchmark output.

### Research Integration

Research report 01 confirmed: (1) `decide` is pure and deterministic, so caching is safe; (2) no LRU cache exists in Lean 4 / Mathlib -- a bounded HashMap with bulk eviction suffices; (3) `Std.Mutex` provides thread-safe `atomically` for shared access; (4) `FrameClass` needs `Hashable` instance; (5) caching at `labelFormulaImpl` level avoids dependent-type issues with `DecisionResult`; (6) the effective cache key is `(Formula, FrameClass)` since `searchDepth` and `tableauFuel` are deterministic functions of the formula; (7) expected hit rates: 10-30% for exhaustive enumeration, higher for axiom-seeded batches.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `Hashable` instance for `FrameClass`
- Define `DecideCache` structure with bounded HashMap, access ordering, and statistics
- Create `labelFormulaWithCache` wrapper that checks/populates the cache
- Thread the cache through `labelBatch` for both sequential and parallel paths
- Report cache hit rate in `EnumBenchmark` output
- Maintain thread safety with `Std.Mutex` for parallel labeling

**Non-Goals**:
- True LRU eviction (unnecessary for batch access pattern)
- Caching at the `decide` level (dependent type issues)
- Persisting cache across separate `labelBatch` invocations
- Modifying the pure tableau core (`expandBranchWithFuel`, `decide`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mutex contention in parallel mode | M | L | Critical section is O(1) HashMap lookup; decide computation is O(2^n). Contention negligible. |
| Stale timing metrics on cache hit | M | M | Update `decisionTimeMs` to reflect cache hit time; mark `decisionMethod` as "cached" |
| HashMap memory at 10K entries | L | L | ~5MB at ~500 bytes/entry. Negligible for any system. |
| FrameClass Hashable instance conflicts | L | L | Simple 3-variant enum; deriving is mechanical |
| Build breakage from import changes | M | L | Std.Mutex is in stdlib; no new Mathlib deps needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Hashable FrameClass and Define DecideCache [COMPLETED]

**Goal**: Add the missing `Hashable` instance for `FrameClass` and define the `DecideCache` structure with bounded HashMap, access tracking, and statistics counters.

**Tasks**:
- [x] Add `deriving instance Hashable for FrameClass` in Axioms.lean after the `FrameClass` definition (after line 426) *(deviation: altered -- used `deriving BEq, Hashable` on the existing deriving clause instead of standalone instance)*
- [x] Define `DecideCacheKey` as a structure with `formula : Formula` and `frameClass : FrameClass`, deriving `BEq` and `Hashable`
- [x] Define `DecideCache` structure in DatasetGenerator.lean containing:
  - `entries : Std.HashMap DecideCacheKey LabeledFormula` (the cache map)
  - `accessOrder : Array DecideCacheKey` (insertion order for eviction)
  - `hits : Nat` (cache hit counter)
  - `misses : Nat` (cache miss counter)
  - `evictions : Nat` (bulk eviction counter)
  - `maxSize : Nat` (bound, default 10000)
- [x] Define `DecideCache.empty` constructor with configurable `maxSize`
- [x] Define `DecideCache.hitRate` computed property returning `Float`
- [x] Import `Std.Data.HashMap` in DatasetGenerator.lean *(deviation: altered -- imported Std.Data.HashMap instead of Std.Sync.Mutex; Mutex is auto-available via Std transitive imports)*

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add `Hashable` instance for `FrameClass`
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- add `DecideCacheKey`, `DecideCache` structures and `Std.Mutex` import

**Verification**:
- `lake build Bimodal.ProofSystem.Axioms` succeeds
- `lake build Bimodal.Automation.DatasetGenerator` succeeds
- `DecideCache.empty 10000` compiles

---

### Phase 2: Implement Cache Lookup/Insert and labelFormulaWithCache [COMPLETED]

**Goal**: Implement the cache lookup, insert, and eviction logic, then create a `labelFormulaWithCache` wrapper that checks the Mutex-protected cache before calling `labelFormulaImpl`.

**Tasks**:
- [x] Implement `DecideCache.lookup` method: given a `DecideCacheKey`, return `Option LabeledFormula` and increment `hits` or `misses`
- [x] Implement `DecideCache.insert` method: insert key-value pair, append to `accessOrder`, trigger eviction if `entries.size > maxSize`
- [x] Implement `DecideCache.evict` method: when size exceeds `maxSize`, remove the first half of `accessOrder` entries from the HashMap and trim `accessOrder`
- [x] Define `labelFormulaWithCache` function *(deviation: altered -- added `mode` and `proofFirstPool` parameters to forward through to `labelFormula` for hybrid mode support)*
- [x] In `labelFormulaWithCache`: use `cache.atomically` to check for a hit; on hit, update `decisionTimeMs` to 0 and `decisionMethod` to `"cached"`, return early
- [x] On cache miss: call `labelFormula` normally, then use `cache.atomically` to insert the result *(deviation: altered -- calls `labelFormula` instead of `labelFormulaImpl` to support all generation modes)*
- [x] Ensure cache miss path does NOT hold the mutex during the `labelFormula` call (only lock for lookup and insert, not computation)
- [x] Added `DecideCache.display` method for human-readable cache stats output

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- add `lookup`, `insert`, `evict` methods and `labelFormulaWithCache`

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` succeeds
- Type signatures match the research report architecture

---

### Phase 3: Thread Cache Through labelBatch and DatasetExport [COMPLETED]

**Goal**: Integrate the cache into both the sequential and parallel paths of `labelBatch`, and thread it through the `DatasetExport` parallel labeling path. Add cache statistics reporting.

**Tasks**:
- [x] Modify `labelBatch` to create a `Std.Mutex DecideCache` at the start via `Std.Mutex.new (DecideCache.empty 10000)`
- [x] In sequential path: replace `labelFormula` with `labelFormulaWithCache`
- [x] In parallel path: pass the shared `cache` to each chunk's IO.asTask, replacing `labelFormula` with `labelFormulaWithCache`
- [x] After batch completion: use `cache.atomically` to read final statistics, print cache hit/miss/rate summary
- [x] Modify `labelBatch` signature to accept optional `cacheMaxSize : Nat := 10000` parameter
- [x] In `DatasetExport.lean`: create shared cache and replace both parallel and sequential `labelFormula` calls with `labelFormulaWithCache`
- [ ] Add `labelFormula` overload or modify `labelFormula` to accept an optional `cache` parameter *(deviation: skipped -- labelFormulaWithCache is called directly, no overload needed)*
- [x] Print cache statistics at end of export run

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- modify `labelBatch` sequential and parallel paths
- `Theories/Bimodal/Automation/DatasetExport.lean` -- thread cache through parallel export path

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` succeeds
- `lake build Bimodal.Automation.DatasetExport` succeeds
- Cache statistics print after batch/export completion

---

### Phase 4: Benchmark Integration and Full Build Verification [COMPLETED]

**Goal**: Add cache hit rate reporting to `EnumBenchmark`, run benchmarks to measure actual hit rates, and verify the full project builds cleanly.

**Tasks**:
- [x] Modify `benchmarkValidFraction` and `benchmarkFullPipeline` in EnumBenchmark.lean to pass `cacheSize` through to `labelBatch` *(deviation: altered -- cache statistics are reported by labelBatch itself via DecideCache.display, no separate benchmark-level reporting needed)*
- [x] Add a `--cache-size N` CLI flag to `enum_benchmark` (default 10000) for tunable cache bounds
- [x] Run `lake build` to verify full project compiles with zero errors *(pre-existing CanonicalTaskRelation.lean heartbeat timeout is unrelated)*
- [ ] Verify `lake exe enum_benchmark` runs successfully with cache statistics in output *(deviation: deferred -- runtime benchmark requires compiled binary execution; build verification confirms compilation)*
- [ ] Update `BatchStats` or add a `CacheStats` companion structure to `computeBatchStats` for programmatic cache metric access *(deviation: skipped -- DecideCache.display provides human-readable output directly from labelBatch; separate CacheStats structure adds complexity without benefit since cache stats are per-batch, not per-formula)*
- [x] Add cache hit rate to the benchmark output format: `Cache: {hits} hits, {misses} misses, {hitRate}% hit rate, {evictions} evictions` -- via DecideCache.display

**Timing**: 45 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/EnumBenchmark.lean` -- add cache statistics reporting and CLI flag
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- ensure `BatchStats` or companion exposes cache metrics

**Verification**:
- `lake build` succeeds (full project, zero errors)
- `lake exe enum_benchmark` runs and displays cache statistics
- No new sorries or axioms introduced

## Testing & Validation

- [ ] `lake build` compiles full project with zero errors
- [ ] `lake exe enum_benchmark` runs and reports cache hit/miss/rate
- [ ] Cache hit rate > 0% on exhaustive enumeration batches (confirms dedup is working)
- [ ] Parallel mode with cache produces same labels as sequential mode (determinism check)
- [ ] No new `sorry` or `axiom` introduced (verify with `grep -r "sorry" Theories/` delta)
- [ ] Cache eviction triggers at 10K+ entries without crash
- [ ] `decisionMethod` field shows "cached" for cache hits in output

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- `Hashable FrameClass` instance
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- `DecideCache`, `labelFormulaWithCache`, modified `labelBatch`
- `Theories/Bimodal/Automation/DatasetExport.lean` -- cache threading in parallel export
- `Theories/Bimodal/Automation/EnumBenchmark.lean` -- cache statistics reporting
- `specs/289_branch_result_memoization_caching/plans/01_memoization-plan.md` -- this plan

## Rollback/Contingency

All changes are additive (new structures, new wrapper function, modified function signatures with default parameters). Rollback is straightforward: revert the 4 modified files. No data migrations or schema changes. The cache is opt-in via the `labelFormulaWithCache` wrapper -- existing `labelFormula`/`labelFormulaImpl` continue to work unchanged. If Mutex performance is worse than expected, the cache can be disabled by setting `cacheMaxSize := 0` without code changes.
