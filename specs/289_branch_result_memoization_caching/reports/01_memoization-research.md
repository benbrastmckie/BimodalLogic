# Research Report: Branch-Result Memoization/Caching for Decision Procedure

**Task**: 289 — Add memoization/caching to tableau branch expansion
**Session**: sess_1780938205_d0e80f_289
**Date**: 2026-06-08

## Executive Summary

The decision procedure (`decide`) is a pure, deterministic function that runs as the inner kernel of the IO-based `labelFormulaImpl` in the batch labeling pipeline. The preferred caching approach is **Option C from the task description**: an IO-level LRU cache keyed by `(Formula, FrameClass)` at the `labelFormulaImpl` level, using a `Std.Mutex`-protected `Std.HashMap` for thread safety. This avoids modifying the pure tableau core while capturing cross-formula duplicate elimination in batch runs. No existing LRU cache exists in Lean 4 / Mathlib, so a simple bounded HashMap with eviction will be implemented.

---

## Research Question 1: Where is `expandBranchWithFuel` defined?

**File**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`, line 144.

**Signature**:
```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))
```

**Parameters**:
- `b : Branch` — the current list of signed formulas
- `fuel : Nat` — maximum expansion steps (termination bound)
- `timeOrd : TimeOrdering` — tracks temporal ordering constraints
- `fc : FrameClass` — which frame class axioms are available
- `tracker : EventualityTracker` — tracks Until/Since eventuality obligations
- `applied : AppliedSet` — prevents persistent rule re-application loops

**Return type**: `Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))`
- `none` — out of fuel
- `some (.inl closedBranch)` — branch closed (formula valid in this branch)
- `some (.inr (openBranch, timeOrd, appliedSet))` — branch saturated/open (formula invalid)

**Call chain**: `decide` -> `buildTableau` -> `expandBranchWithFuel`. The function is recursive with `termination_by fuel`, and handles splits by dividing fuel among sub-branches (`fuel / max 1 branches.length`).

---

## Research Question 2: What is the `decide` function signature?

**File**: `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`, line 121.

```lean
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : DecisionResult φ
```

**Cache key candidates**:
- `φ : Formula` — has `BEq`, `Hashable`, `DecidableEq` (derived)
- `fc : FrameClass` — has `BEq`, `DecidableEq` but **NOT** `Hashable` (needs to be added)
- `searchDepth : Nat` — always 5 + φ.complexity / 2 when called via `decideAutoAdaptive`
- `tableauFuel : Nat` — always 500 when called via `decideAutoAdaptive`

Since all callers in the batch pipeline go through `decideAutoAdaptive` which always uses `depth = 5 + φ.complexity / 2` and `fuel = 500`, the effective cache key reduces to just `(Formula, FrameClass)`. The `searchDepth` and `tableauFuel` are deterministic functions of the formula, so they are redundant in the key.

**Return type**: `DecisionResult φ` is dependent on `φ`:
```lean
inductive DecisionResult (φ : Formula) : Type where
  | valid (proof : ⊢ φ)
  | invalid (counter : SimpleCountermodel)
  | timeout
```

This dependent type is problematic for caching because you cannot store `DecisionResult φ₁` and retrieve it as `DecisionResult φ₂` even when `φ₁ = φ₂` without a cast. However, `decideAutoAdaptive` returns `DecisionResult φ × String`, so caching at that level requires erasure. The simplest approach is to cache at the `labelFormulaImpl` level and cache `LabeledFormula` (which is not dependent — it stores `FormulaLabel` and optional proof/countermodel data).

---

## Research Question 3: How does Lean 4 IO.Ref work?

**`IO.Ref`** is defined as `ST.Ref IO.RealWorld` — a mutable reference cell in the IO monad. API:
```lean
IO.mkRef : {α : Type} → α → BaseIO (IO.Ref α)
ST.Ref.get : IO.Ref α → IO α
ST.Ref.set : IO.Ref α → α → IO Unit
ST.Ref.modify : IO.Ref α → (α → α) → IO Unit
```

**`Std.Mutex`** (from `Std.Sync.Mutex`) provides thread-safe access:
```lean
Std.Mutex.new : α → BaseIO (Std.Mutex α)
Std.Mutex.atomically : Std.Mutex α → Std.AtomicT α m β → m β
```

`Std.AtomicT` is `StateRefT' IO.RealWorld` — within `atomically`, you use `get`/`set`/`modify` from the `MonadState` instance. The mutex guarantees exclusive access during the atomic block.

**Idiomatic pattern for passing a cache through the pipeline**:
```lean
-- Create cache at the batch level
let cache ← Std.Mutex.new (DecideCache.mk {} 0 0 0)

-- Pass to each labeling call
for φ in formulas do
  let result ← labelFormulaWithCache cache φ fc wallclockTimeoutMs
  ...
```

The cache is created once in the `labelBatch` function and threaded to each `labelFormula` call. In parallel mode, `Std.Mutex` ensures thread safety.

---

## Research Question 4: LRU cache implementations in Lean 4 / Mathlib

**No existing LRU cache implementation exists** in either Lean 4 stdlib or Mathlib. The `Std.HashMap` is the only hash-based container available.

**Implementation strategy**: A bounded HashMap with simple eviction:

1. **Simple approach**: Use `Std.HashMap` with a `size` counter. When `size > maxSize`, do bulk eviction (clear the oldest half). This avoids the complexity of maintaining a doubly-linked list for true LRU but gives adequate memory bounds.

2. **True LRU approach** (more complex): Maintain a `Std.HashMap` for O(1) lookup plus a `List` of keys in access order. On access, move key to front. On eviction, remove from back. This requires O(n) list manipulation per access.

3. **Recommended**: The simple bounded HashMap approach. For the batch labeling use case, the access pattern is "label many formulas, each formula accessed at most once per batch." The cache primarily catches duplicates across the batch (e.g., from atom canonicalization overlap or repeated formulas). True LRU ordering is unnecessary because there's no temporal locality — each formula is either a hit (already seen) or a miss (new). A simple bounded HashMap with periodic bulk eviction is sufficient.

---

## Research Question 5: Current performance profile

**Existing benchmarks and timing infrastructure**:

1. **`EnumBenchmark.lean`** (`lake exe enum_benchmark`):
   - Benchmarks complexity 5-7 enumeration and labeling
   - Reports total labeling time in milliseconds
   - Supports `--parallel N` flag for parallel labeling
   - **Recent benchmark (task 286)**: 1000 formulas at complexity 7 in 1267ms sequential, 161ms with 16 threads

2. **`DatasetExport.lean`** (`lake exe dataset_exporter`):
   - Full pipeline with JSONL export
   - Reports per-formula timing via `computeMetrics`
   - Wall-clock timeout support

3. **`BenchmarkOracle.lean`** (`lake exe benchmark_oracle`):
   - Axiom-based benchmark validation

4. **Timing primitives**: `IO.monoMsNow` is used throughout for wall-clock measurement.

**No dedicated micro-benchmarks** for the `decide` function itself exist. The `decisionTimeMs` field in `LabeledFormula.metrics` records per-formula decision time.

**Key performance observation from task 264**: The decision landscape is strictly bimodal — formulas either resolve at fuel=500 or not at all. No formulas resolve at higher fuel tiers. This means the cache hit rate depends entirely on formula deduplication, not on avoiding expensive recomputations of slow formulas.

---

## Research Question 6: Interaction with task 286 (parallelization)

**Task 286 status**: Fully implemented and complete. The `labelBatch` function supports chunk-based parallelism via `IO.asTask` with a `--parallel N` flag.

**Parallel architecture**:
- `labelBatch` with `parallelThreads > 0` divides formulas into chunks
- Each chunk runs in a separate `IO.asTask` with `.dedicated` priority
- Each task calls `labelFormula` independently
- Results are collected and concatenated in order

**Thread safety requirements**: If the cache is shared across parallel threads (which is necessary for cross-thread duplicate elimination), it **must** be thread-safe. Two approaches:

1. **`Std.Mutex`-protected HashMap** (recommended): The `Std.Mutex` type provides exclusive access via `atomically`. The cache lookup and insert become atomic operations. Contention is low because most of the time is spent in the pure `decide` computation, not in cache operations.

2. **Per-thread caches** (simpler but less effective): Each thread has its own HashMap. No synchronization needed, but duplicates across threads are not eliminated. This defeats the primary purpose of caching in the parallel context.

**Recommendation**: Use `Std.Mutex`-protected shared cache. The cache access is fast (HashMap lookup) and the critical section is short, so mutex contention will be negligible compared to the `decide` computation time.

---

## Research Question 7: What is FrameClass?

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 422.

```lean
inductive FrameClass where
  | Base
  | Dense
  | Discrete
  deriving Repr, DecidableEq, Inhabited
```

**Usage in decision procedure**: `FrameClass` determines which axioms are available during tableau expansion. `Base` allows all 37 base axioms. `Dense` adds 2 density axioms. `Discrete` adds 3 discreteness axioms. The `findClosure` function in the tableau uses `FrameClass` to determine which closure rules are applicable.

**Current usage**: All batch labeling calls use `FrameClass.Base`. The benchmark infrastructure does not exercise Dense or Discrete frame classes.

**Cache implication**: Since `FrameClass` is always `.Base` in current batch runs, it could be omitted from the cache key. However, including it in the key is cheap and future-proofs the cache for when other frame classes are used.

**Missing instance**: `FrameClass` does not derive `Hashable`. This must be added:
```lean
deriving instance Hashable for FrameClass
```

---

## Research Question 8: What would the cache entry look like?

**Option A: Cache at `decide` level** — Store `DecisionResult φ`
- Problem: `DecisionResult φ` is dependent on `φ`. You cannot store values of different `φ` in the same HashMap without type erasure.
- Workaround: Use `unsafeCast` or store an erased version. This is fragile.

**Option B: Cache at `decideAutoAdaptive` level** — Store `DecisionResult φ × String`
- Same dependent type problem.

**Option C (recommended): Cache at `labelFormulaImpl` level** — Store `LabeledFormula`
- `LabeledFormula` is NOT dependent on `φ`. It stores:
  ```lean
  structure LabeledFormula where
    formula : Formula
    label : FormulaLabel        -- valid | invalid | timeout
    proofTrace : Option ProofTrace
    countermodel : Option SimpleCountermodel
    metrics : FormulaMetrics
    patternKey : PatternKey
    ruleProfile : Option RuleProfile
    decisionMethod : String
    countermodelConsistent : Option Bool
    enrichedCountermodel : Option EnrichedCountermodel
    semanticCountermodelSummary : Option SemanticCountermodelSummary
    proofReconstructionMethod : Option String
    interestingnessScore : Option Float
    interestingnessTier : Option String
  ```
- This is the natural cache entry type. On cache hit, return the entire `LabeledFormula` directly (with updated `metrics.decisionTimeMs` to reflect the cache hit time).
- Cache key: `Formula` (since `FrameClass` is always `.Base` in current usage, but include it for correctness).

**Option D: Cache only the decision outcome** — Store `FormulaLabel` (valid/invalid/timeout)
- Lighter weight than full `LabeledFormula`, but requires re-running proof trace extraction on cache hit.
- Still eliminates the expensive `decide` call.
- Better for memory usage but loses the detailed proof/countermodel data.

**Recommendation**: Option C (cache `LabeledFormula`) for maximum benefit. The `LabeledFormula` contains all derived data (proof trace, countermodel, rule profile, interestingness) so a cache hit completely eliminates all redundant work.

---

## Architecture Recommendation

### Preferred Design: Mutex-Protected HashMap at `labelBatch` Level

```
labelBatch (formulas, parallelThreads)
  |
  +-- cache ← Std.Mutex.new (DecideCache.mk {} 0 0)
  |
  +-- for each φ in formulas (parallel or sequential):
        |
        +-- Check cache: cache.atomically (lookup φ)
        |     |
        |     +-- Hit: return cached LabeledFormula (update timing metrics)
        |     +-- Miss: continue to labeling
        |
        +-- labelFormulaImpl φ fc wallclockTimeoutMs
        |
        +-- Insert into cache: cache.atomically (insert φ result)
        |
        +-- If cache.size > maxSize: evict (atomic bulk eviction)
```

### Cache Structure

```lean
structure DecideCache where
  entries : Std.HashMap Formula LabeledFormula := {}
  accessOrder : Array Formula := #[]  -- For eviction ordering
  hits : Nat := 0
  misses : Nat := 0
  evictions : Nat := 0
  maxSize : Nat := 10000
```

### Key Design Decisions

1. **Cache key**: `Formula` alone (FrameClass is always `.Base` in batch runs; include FrameClass if future-proofing is desired, requiring a `Hashable FrameClass` instance).

2. **Cache value**: `LabeledFormula` (complete result, avoiding any recomputation on hit).

3. **Thread safety**: `Std.Mutex` (Lean 4 stdlib, verified above to compile).

4. **Eviction policy**: Simple bounded HashMap. When `size > maxSize`, clear oldest half of `accessOrder`. No true LRU needed for the batch access pattern.

5. **Cache location**: Created in `labelBatch`, passed to `labelFormulaImpl` (or a new `labelFormulaWithCache` wrapper).

6. **Metrics collection**: Track `hits`, `misses`, `evictions`, and `hitRate = hits / (hits + misses)`. Report at end of batch.

### Files to Modify

1. **`Theories/Bimodal/ProofSystem/Axioms.lean`**: Add `deriving instance Hashable for FrameClass` (if FrameClass is included in cache key).

2. **`Theories/Bimodal/Automation/DatasetGenerator.lean`**:
   - Define `DecideCache` structure
   - Add `labelFormulaWithCache` wrapper
   - Modify `labelBatch` to create and pass cache
   - Add cache statistics reporting

3. **`Theories/Bimodal/Automation/EnumBenchmark.lean`**: Add cache hit rate reporting.

4. **`Theories/Bimodal/Automation/DatasetExport.lean`**: Thread cache through parallel labeling path.

### Expected Impact

- **Exhaustive enumeration batches**: 10-30% hit rate from syntactic duplicates (especially after atom canonicalization which maps structurally isomorphic formulas to the same canonical form).
- **Axiom-seeded batches**: Higher hit rate (axiom instantiation with limited vocabulary produces many duplicates).
- **Diverse formula sets**: Marginal benefit (<5% hit rate).
- **Memory overhead**: ~10K entries * ~500 bytes/entry = ~5MB. Negligible.

### Risks and Mitigations

1. **Determinism**: `decide` is pure and fully deterministic (no IO, no randomness). Cache correctness is guaranteed.

2. **Timing metrics**: Cached results need `decisionTimeMs` updated to reflect cache hit time (near-zero) rather than original computation time. The implementation should distinguish "cached" results in the `decisionMethod` field.

3. **Mutex contention**: In parallel mode, the critical section (HashMap lookup/insert) is O(1) while the computation (decide) is O(2^n). Contention ratio is negligible.

4. **Pre-filter interaction**: The `structuralPrefilterWithAxiom` check in `labelFormulaImpl` runs before `decide`. The cache should be checked after the pre-filter (or the pre-filter results should also be cached). Since the pre-filter is fast, caching it separately is unnecessary.

---

## Atom Canonicalization Interaction

The existing `AtomCanonicalization.lean` module (task 267) already maps structurally isomorphic formulas to canonical representatives. This canonicalization happens **before** labeling in some pipelines (the `deduplicateCanonical` function). If canonicalization is applied before batch labeling, many potential cache hits are already eliminated by deduplication. The cache primarily catches:

1. Formulas that appear in multiple batches (if cache persists across batches)
2. Formulas not caught by canonical deduplication (e.g., identical formulas with different generation paths)
3. Formulas in the parallel pipeline where different chunks encounter the same formula

The interaction should be benchmarked to measure actual redundancy in the pipeline.
