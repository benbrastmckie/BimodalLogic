# Teammate A Findings: Implementation Approaches and Performance Patterns

- **Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
- **Angle**: Primary — Concrete data structures, algorithms, and Lean 4-specific performance optimizations
- **Date**: 2026-06-04
- **Confidence**: High (findings backed by Lean 4 documentation, quantitative analysis, and source code review)

## 1. Lean 4 Array vs List: Definitive Performance Analysis

### Key Finding: Array.push is O(1) amortized; List.append is O(n)

**Confidence: High**

Lean 4's `Array α` is backed by a dynamic array (contiguous memory, doubling capacity). The official Lean reference documentation (2026) states:

> "Array.push takes amortized O(1) time because Array α is represented by a dynamic array."
> "Array.append takes time proportional to the length of the second array."
> "Arrays can be vastly more efficient than lists in compiled code."

Lean 4's `List α` is a singly-linked list where:
- `List.append (++)` is O(|first list|) — must traverse the entire first list to find the end
- `List.flatMap` internally uses append, creating intermediate lists per element
- Every cons cell is a heap-allocated object (~48 bytes: object header + tag + head pointer + tail pointer)

### Critical: Uniqueness and In-Place Mutation

Lean 4 uses reference counting with a uniqueness optimization: when an object has exactly one reference (refcount = 1), operations like `Array.push` mutate in-place rather than copying. The official documentation states:

> "Many array functions in the Lean runtime check whether they have exclusive access to their argument by consulting the reference count. Lean code that uses an array linearly avoids the performance overhead of persistent data structures."

**Gotcha**: If a value is referenced from multiple places (e.g., stored in a cache AND returned as a result), the refcount exceeds 1, forcing a copy. The `dbgTraceIfShared` debugging primitive can detect this at runtime — but **only in compiled code**, not `#eval`.

### Implication for EnumCache

The current `EnumCache = Std.HashMap (Nat × Nat × Nat) (List Formula)` stores formula lists. When `enumExactHelper` returns a cached list AND stores it, both the caller and cache hold references → refcount = 2. Any mutation of the returned list would trigger a copy.

**With Array**: `EnumCache := Std.HashMap (Nat × Nat × Nat) (Array Formula)` would have the same sharing issue (cache holds one reference, caller holds another). However, the key difference is that callers should **not mutate cached arrays**. Instead, they should iterate over cached arrays and push results into a fresh accumulator array. The cached arrays are read-only; only the accumulator array is mutated.

### Quantitative Analysis: Copy Cost Elimination

For level 8 enumeration, the binary formula loop does `accList ++ imps ++ temporalBinaries` at each partition:

| After partition | Accumulated | Copy cost (elements traversed) |
|-----------------|-------------|-------------------------------|
| (1,6) | 159,264 | 0 |
| (2,5) | 231,744 | 159,264 |
| (3,4) | 358,464 | 231,744 |
| (4,3) | 485,184 | 358,464 |
| (5,2) | 557,664 | 485,184 |
| (6,1) | 716,928 | 557,664 |
| **Total** | | **1,792,320** |

For imp alone, 1.8M element copies are wasted on list traversal. Including `untl` and `snce` (estimated ~2.4x factor with temporal budgets): **~4.3M element copies** are eliminated by switching to Array.push.

Memory savings: List cons cells cost ~48 bytes each. For 1.7M formulas at level 8, that's ~82 MB of list node allocations eliminated. Array storage is ~8 bytes per pointer = 13.6 MB contiguous.

**Estimated speedup from Array conversion alone: 5–15x** for the enumeration phase.

## 2. Streaming/Lazy Enumeration in Lean 4

### Key Finding: Lean 4 now has a proper Iterator system, but it's not the right tool here

**Confidence: Medium**

As of Lean 4.22+ (2025), the `Std.Data.Iterators` module provides fusion-capable iterators with `map`, `filter`, `fold`, `zip` combinators. The documentation states:

> "Intermediate stages of the computation do not allocate new data structures."

However, iterators are designed for **single-pass consumption** of existing data. The enumeration problem requires **generating** formulas via nested cross-products and accumulating them into a cache. The iterator pattern doesn't naturally fit because:

1. Cached results need random access (looked up by key multiple times)
2. Cross-products require materializing pairs, not streaming through a single sequence
3. The memoization cache fundamentally requires storing complete level results

### Recommended Approach: Not iterators, but Array-based accumulation with inline filtering

Instead of trying to make the cross-product lazy, the right approach is:
1. Keep the cached results as `Array Formula` (read-only after creation)
2. Build cross-products into a fresh accumulator `Array` using nested `for` loops with `Array.push`
3. Apply `passesFilter` or structural checks inline before pushing

This avoids all intermediate allocations while keeping the memoization architecture intact.

## 3. HashMap Performance with (Nat × Nat × Nat) Keys

### Key Finding: Current cache key type is fine; the bottleneck is the stored values, not the keys

**Confidence: High**

`Std.HashMap` in Lean 4 uses power-of-two bucket counts for fast modular indexing (bitwise AND instead of modulo). For `(Nat × Nat × Nat)` keys:
- `Hashable` instance uses `mixHash` to combine the three `Nat` hashes
- `BEq` instance compares three `Nat` values — O(1), trivially fast
- Lookup is O(1) expected time

The cache at level 8 has at most ~200 unique keys (product of small modal/temporal/size budget values). This is tiny. Cache lookup is not a bottleneck.

**The bottleneck is the stored values**: `List Formula` forces linear-time operations on cached data. Switching to `Array Formula` means cached lookups return a reference to a contiguous array, which can be iterated efficiently with cache-friendly memory access.

### Recommendation: Change `EnumCache` to store `Array Formula`

```lean
abbrev EnumCache := Std.HashMap (Nat × Nat × Nat) (Array Formula)
```

No structural changes to the cache architecture needed.

## 4. Incremental Output / Checkpointing in Lean 4

### Key Finding: IO-based enumeration with periodic flush is straightforward in Lean 4

**Confidence: High**

The existing `enumerateWithProgress` function (line 1363) already interleaves IO with per-level enumeration. The pattern for incremental output:

```lean
partial def enumerateWithCheckpoint (params : EnumParams) (outPath : String) : IO Unit := do
  let handle ← IO.FS.Handle.mk outPath .write
  let mut cache : EnumCache := {}
  for i in List.range params.maxComplexity do
    let level := i + 1
    let (exact, cache') := enumExactBudget params.atoms level ...
    cache := cache'
    -- Write each formula immediately rather than accumulating
    for φ in exact do
      if passesFilter φ then
        handle.putStrLn (toString φ)
    handle.flush
    IO.println s!"[checkpoint] Level {level} flushed to disk"
```

Key considerations:
- `IO.FS.Handle.flush` forces buffered writes to disk
- Crash recovery: completed levels are on disk, only current level is lost
- Memory: no need to accumulate all formulas in memory across levels
- **This is independent of the Array optimization** — apply both

### Streaming Architecture Recommendation

The ideal architecture separates enumeration from output:

1. **`enumExactHelper`** (pure, cached): Returns `Array Formula` per (size, modal, temporal) triple
2. **Per-level consumer** (IO): Iterates the array, applies filters, writes to disk or accumulates
3. **Progress reporter** (IO): Emits timing and count statistics

This keeps the pure computation cacheable while adding IO only at the outer level.

## 5. Cross-Product Optimization: Nested For-Loop Pattern

### Key Finding: Replace `List.flatMap` with nested `for` loops writing to a mutable Array

**Confidence: High**

The current pattern:
```lean
let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
```

This creates:
1. For each `l` in `lefts`: a temporary `List Formula` of size `|rights|` via `rights.map`
2. Then `flatMap` concatenates all these temporary lists via repeated `++`
3. Total intermediate allocations: `|lefts|` temporary lists + `|lefts| - 1` concatenation copies

**Optimized pattern** (Array-based):
```lean
let mut acc : Array Formula := #[]
-- Pre-size the array to avoid repeated doubling
acc := acc.reserve (lefts.size * rights.size)
for l in lefts do
  for r in rights do
    acc := acc.push (Formula.imp l r)
```

With `Array.reserve`, the array pre-allocates capacity for the known cross-product size, eliminating all intermediate resizing. Each `push` is O(1) with zero allocation (just pointer write + size increment).

### Tiled/Blocked Iteration (Not Needed)

For extremely large cross-products (>10M), cache-line-aware blocked iteration can improve locality. At our scale (~1M cross-products at c8), this is unnecessary — the contiguous Array already provides excellent cache locality.

### Early-Exit Filtering During Cross-Product

While `passesFilter` saves <5% for binary operators at level 8 (nearly all formulas have modal/temporal content at high complexity), **structural redundancy checks** can be applied per-pair:

```lean
for l in lefts do
  for r in rights do
    -- Skip identity implications (always valid, no training value)
    if l == r then continue
    -- Skip bot → φ (ex falso, trivially valid)
    if l == Formula.bot then continue
    acc := acc.push (Formula.imp l r)
```

These O(1) checks per pair eliminate a small but non-trivial fraction of formulas before allocation.

## 6. Concrete Performance Estimates

### Level 8 Enumeration Time Projections

| Configuration | Est. Time | Formulas | Notes |
|---------------|-----------|----------|-------|
| Current (List) | 10–15 hours | ~1.7M raw | Based on 3.7h observed, ~50% done |
| Array-only | 40–120 min | ~1.7M raw | 5–15x speedup from eliminating copies |
| Array + structural pruning | 30–90 min | ~1.5M raw | ~10–15% reduction from skip rules |
| Array + incremental IO | 40–120 min | ~1.7M raw | Same speed, crash-safe |
| Array + all optimizations | 20–60 min | ~1.3M raw | Best realistic case without alpha-canon |

### Level 9 Feasibility

With Array-based accumulation, level 9 cross-products (~15M formulas) would require:
- ~120 MB for Array storage (15M × 8 bytes)
- ~720 MB for Formula AST nodes (15M × 48 bytes)
- Estimated time: 4–12 hours (from the 6.5x growth factor)

Level 9 exhaustive becomes **marginally feasible** with Array optimization alone. Alpha-canonical enumeration (3–6x reduction) would make it solidly feasible at 1–3 hours.

## 7. Recommended Implementation Order

### Phase 1: Array Conversion (Highest ROI, 2–4 hours)

1. Change `EnumCache` from `List Formula` to `Array Formula`
2. Convert `enumExactHelper` to use `Array.push` accumulation
3. Replace `List.flatMap` cross-products with nested `for` loops
4. Use `Array.reserve` for pre-sizing at known partition sizes
5. Convert `enumHelper`, `enumerateExhaustive`, `enumerateWithProgress` to use Array throughout
6. Use `dbgTraceIfShared` to verify uniqueness of the accumulator array in compiled code

### Phase 2: Incremental IO (2 hours)

1. Add `IO.FS.Handle`-based streaming output to `enumerateWithProgress`
2. Flush after each complexity level
3. Add crash-recovery checkpoint metadata

### Phase 3: Structural Pruning (1–2 hours)

1. Add per-pair skip rules inside the cross-product loop:
   - `l == r` (identity implication)
   - `l == Formula.bot` (ex falso)
   - Duplicate modality: `box(box(φ))` under S5
2. Measure actual reduction percentages

### Phase 4: Cache Architecture Refinement (1 hour)

1. Split cache entries into modal vs. pure-propositional arrays
2. Pre-compute `hasModalOrTemporal` flags per cached array
3. Skip pure×pure cross-products for `imp`

## 8. Code-Level Transformation: Before and After

### Before (current code, lines 184–204):

```lean
let (binaryFormulas, cache2) := ((List.range childBudget).foldl
  (fun (acc : List Formula × EnumCache) i =>
    let leftSize := i + 1
    let rightSize := childBudget - leftSize
    if rightSize < 1 then acc
    else
      let (accList, accCache) := acc
      let (lefts, c1) := enumExactHelper atoms modalBudget temporalBudget leftSize accCache
      let (rights, c2) := enumExactHelper atoms modalBudget temporalBudget rightSize c1
      let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
      let (temporalBinaries, c3) := if temporalBudget > 0 then
        let (tLefts, c2a) := enumExactHelper atoms modalBudget (temporalBudget - 1) leftSize c2
        let (tRights, c2b) := enumExactHelper atoms modalBudget (temporalBudget - 1) rightSize c2a
        let untls := tLefts.flatMap fun l => tRights.map fun r => Formula.untl l r
        let snces := tLefts.flatMap fun l => tRights.map fun r => Formula.snce l r
        (untls ++ snces, c2b)
      else ([], c2)
      (accList ++ imps ++ temporalBinaries, c3)
  ) ([], cache1a))
```

### After (Array-based):

```lean
let (binaryFormulas, cache2) := Id.run do
  let mut acc : Array Formula := #[]
  let mut cache := cache1a
  for i in List.range childBudget do
    let leftSize := i + 1
    let rightSize := childBudget - leftSize
    if rightSize < 1 then continue
    let (lefts, c1) := enumExactHelper atoms modalBudget temporalBudget leftSize cache
    let (rights, c2) := enumExactHelper atoms modalBudget temporalBudget rightSize c1
    -- Pre-size for known cross-product
    acc := acc.reserve (acc.size + lefts.size * rights.size)
    for l in lefts do
      for r in rights do
        acc := acc.push (Formula.imp l r)
    cache := c2
    if temporalBudget > 0 then
      let (tLefts, c2a) := enumExactHelper atoms modalBudget (temporalBudget - 1) leftSize cache
      let (tRights, c2b) := enumExactHelper atoms modalBudget (temporalBudget - 1) rightSize c2a
      acc := acc.reserve (acc.size + tLefts.size * tRights.size * 2)
      for l in tLefts do
        for r in tRights do
          acc := acc.push (Formula.untl l r)
          acc := acc.push (Formula.snce l r)
      cache := c2b
  (acc, cache)
```

**Note**: `enumExactHelper` itself needs to return `Array Formula` (or the cache stores Arrays). The `for l in lefts` loop iterates over the cached Array without copying it. The `acc` Array is uniquely owned (never stored elsewhere during the loop), so all `push` operations are in-place.

## 9. Risk Assessment

| Change | Risk | Mitigation |
|--------|------|------------|
| Array conversion | Low | Array and List share the same semantics; all consumers use iteration |
| Cross-product loop rewrite | Low | Nested for-loop is semantically identical to flatMap |
| EnumCache type change | Medium | All cache consumers must be updated; use `dbgTraceIfShared` to verify |
| Incremental IO | Low | Additive change, doesn't affect pure enumeration |
| Structural pruning | Medium | Must verify skip rules don't exclude interesting formulas |

## References

- [Lean 4 Arrays Reference](https://lean-lang.org/doc/reference/latest/Basic-Types/Arrays/)
- [Lean 4 Reference Counting](https://lean-lang.org/doc/reference/latest/Run-Time-Code/Reference-Counting/)
- [Lean 4 Linked Lists Reference](https://lean-lang.org/doc/reference/latest/Basic-Types/Linked-Lists/)
- [Lean 4 Iterators](https://lean-lang.org/doc/reference/latest/Iterators/)
- [Lean 4 File I/O](https://lean-lang.org/doc/reference/latest/IO/Files___-File-Handles___-and-Streams/)
- [Lean 4 HashMap (Std)](https://leanprover-community.github.io/mathlib4_docs/Std/Data/HashMap/Basic.html)
- [Functional Programming in Lean: Insertion Sort and Array Mutation](https://lean-lang.org/functional_programming_in_lean/Programming___-Proving___-and-Performance/Insertion-Sort-and-Array-Mutation/)
- [Efficient Normalization of Linear Temporal Logic (Esparza et al., 2023)](https://arxiv.org/abs/2310.12613)
