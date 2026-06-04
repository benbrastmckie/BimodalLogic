# Teammate C (Critic) Findings: Task 283

**Task**: Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
**Date**: 2026-06-04
**Role**: Critical evaluation of existing analysis report (01_explosion-analysis.md)
**Confidence Framework**: high = verified by code/data, medium = supported by evidence, low = informed speculation

---

## Finding 1: The "5-20x Speedup" from Array Conversion Is Partially Overstated

### Claim Being Challenged
Report Section 5.1 claims: "Estimated speedup: 5-20× at c8" from converting List to Array.

### Analysis

The claim conflates two separate costs:

**1. Structural overhead (quantifiable: ~4.4x)**

I computed the exact operation counts for the `enumExactHelper` inner loop at c8. The accumulator pattern `accList ++ imps ++ temporalBinaries` inside the `foldl` traverses the accumulated list at each partition. With Lean 4's right-fold flatten semantics for `List.flatMap`, the total list operations (flatten traversals + allocations + accumulator appends) are ~3.2M vs ~717K Array pushes for `imp` alone. Extrapolating across all binary operators gives a **4.4x** structural speedup.

The accumulator append dominates later partitions: by partition (5,2), the accumulator holds 485K formulas, so even one `++` costs 485K pointer traversals just to relink.

**2. GC pressure (unquantifiable: claimed 2-5x additional)**

The report's claim of additional GC speedup from reduced allocation pressure is plausible but unverified. List.flatMap creates intermediate lists (132 lists of 960 elements for partition (3,4)), which become garbage after flatten. Array avoids these intermediates entirely. However, with Lean 4's RC optimization, uniquely-owned cons cells are recycled in-place during `List.map`, so the actual GC pressure may be lower than assumed.

**Key nuance the report misses**: Lean 4 implements "functional but in place" optimization. `List.append` with a uniquely-owned left argument reverses and relinks pointers without allocating new cons cells. `List.map` with a unique reference reuses cons cells destructively. The report assumes naive allocation behavior ("Lean's reference-counted GC must trace and free each node, creating GC pressure proportional to the square of the list sizes") — this is **incorrect** for uniquely-owned lists. The actual GC pressure is from non-unique references in the HashMap cache (which stores lists that are then shared).

### Verdict
**Partially confirmed.** The structural speedup is real but closer to **4-5x**, not 5-20x. The GC component is speculative. The report's reasoning about WHY Array helps (avoiding allocation) is partially wrong — the real benefit is avoiding O(n) traversal in append and eliminating intermediate list construction in flatMap.

### Confidence Level
**High** for the structural analysis, **medium** for the GC component.

---

## Finding 2: The Root Cause Analysis Is Incomplete — Cache Equality May Be a Hidden Bottleneck

### Claim Being Challenged
Report Section 3.3: "The time is not in enumeration logic — it's about avoiding full materialization of cross-products."

### Analysis

The RSS trace shows 30-40 minute cycles per partition at c8. But individual cross-products are small: partition (3,4) produces only 126K formulas, which should take seconds even with List overhead. So why does each partition take 30-40 minutes?

The report doesn't investigate the **HashMap cache** as a potential bottleneck. `EnumCache` is `Std.HashMap (Nat × Nat × Nat) (List Formula)`. The cache key is a simple tuple (fast hashing), but the cache VALUES are `List Formula`. When the cache returns `some result`, the returned list shares ownership with the cache — meaning subsequent operations on it are NOT uniquely owned. This breaks the RC in-place optimization for any operation on cached results.

Specifically: when `enumExactHelper` returns cached formulas at line 131 (`| some result => (result, cache)`), the `result` list has RC ≥ 2 (one in the cache, one returned). Any `List.map` or `List.flatMap` on these cached results **cannot** reuse cons cells in-place — they must allocate fresh copies.

This means the theoretical 4.4x speedup from Array may be a lower bound: the cache sharing effect makes List operations even more expensive than the unique-ownership analysis suggests.

### Verdict
**Partially confirmed, but incomplete.** The cross-product materialization IS a major cost, but the cache's effect on reference counting (breaking in-place optimization) is an undocumented and potentially significant additional bottleneck. The 30-40 minute partition cycles likely reflect the combined cost of non-unique List operations on cached sublists plus the cross-product materialization overhead.

### Confidence Level
**Medium.** The cache RC analysis is sound theoretically but untested empirically.

---

## Finding 3: The "4x Memory Reduction" from Streaming Filter Is Almost Entirely Wrong at c8

### Claim Being Challenged
Report Section 5.2 claims: "At c7, the dedup ratio is 306K enumerated → 77K after dedup (75% filtered). If similar ratios hold at c8, this would reduce memory by 4×."

### Analysis

This conflates two completely different operations:
1. **`passesFilter`**: filters `complexity ≥ 3 && hasModalOrTemporal` (applied during enumeration)
2. **Atom-permutation canonical deduplication**: `AtomCanonicalization.deduplicateCanonical` (applied AFTER enumeration in `DatasetExport.lean` line 1017)

The 306K→77K "dedup" at c7 is from **atom-canonicalization deduplication** (4.0x), not from `passesFilter`. The `passesFilter` function rejects only formulas that are pure propositional (no modal/temporal operators) AND have complexity < 3.

At complexity 8:
- **All** formulas have complexity ≥ 8, so the `complexity ≥ 3` check is vacuous
- Pure propositional formulas at c8 = **zero** (because pure prop formulas only exist at odd complexity levels — at even levels, all imp partitions require one odd and one even child, and pure prop at even levels is always 0)

Therefore `passesFilter` rejects **exactly 0%** of c8 formulas. "Streaming filter during cross-product" would save **no work whatsoever** at c8.

The actual 3-4x reduction comes from atom canonicalization, which is a POST-enumeration step and **cannot** be streamed into the cross-product loop because it requires seeing the complete formula before canonicalizing.

### Verdict
**Refuted.** The "4× memory reduction" claim is based on a misattribution. `passesFilter` rejects 0% of c8 formulas. The actual deduplication is from atom canonicalization, which is already implemented (`AtomCanonicalization.lean`) and applied in the pipeline (`DatasetExport.lean` line 1017).

### Confidence Level
**High.** Verified by code analysis and mathematical proof (pure propositional count at even complexity = 0).

---

## Finding 4: Alpha-Canonical Enumeration Is Already Partially Implemented

### Claim Being Challenged
Report Section 5.3 proposes alpha-canonical enumeration as a "Major refactor. Estimated 4-6 hours. 3-6× reduction."

### Analysis

The file `Theories/Bimodal/Automation/AtomCanonicalization.lean` already implements:
- `collectAtomsDFS`: Extract atoms in DFS order
- `canonicalAtomMap`: Build renaming to canonical ordering (first seen → p, second → q, etc.)
- `canonicalize`: Apply the canonical form
- `deduplicateCanonical`: Canonicalize and deduplicate a list

And `DatasetExport.lean` already applies it at line 1017:
```
let canonical := AtomCanonicalization.deduplicateCanonical formulas'
```

Task 267 measured a **4.58x** deduplication ratio. The existing report's "3-6× reduction" estimate is within range of the measured value.

However, the current implementation is a POST-enumeration step — it canonicalizes after the full cross-product is materialized. The report's proposed optimization (enumeration-time canonical filtering) would be a genuine improvement: skip non-canonical formulas DURING cross-product generation, reducing both memory and computation. But the report presents this as if no canonicalization exists at all, which is misleading.

The real task here is to move canonicalization INTO the enumeration loop (generate only canonical representatives) rather than implementing it from scratch. This is a different (and more complex) problem: checking canonicality during construction requires that the atom ordering be consistent across the formula tree as it's built bottom-up.

### Verdict
**Partially confirmed.** The deduplication value is real (4.58x measured), but the report fails to mention that post-enumeration canonicalization already exists. The actual optimization needed is moving canonicalization into the enumeration loop, not implementing it from scratch.

### Confidence Level
**High.** Verified by reading existing code.

---

## Finding 5: The Prover Is the Binding Constraint, Not Enumeration

### Claim Being Challenged
The report focuses exclusively on enumeration speed, implicitly assuming it's the bottleneck.

### Analysis

The dataset generation pipeline has three phases:
1. **Enumeration**: Generate formulas
2. **Deduplication**: Atom-canonicalization dedup
3. **Labeling**: Run decision procedure on each formula with 1-second wall-clock timeout

At c7:
- Enumeration: ~1 second (per report)
- Labeling: 77,272 formulas. At c7, 21% timeout (1 second each). Remaining 79% average ~5ms.
- Estimated labeling time: 0.79 × 77K × 5ms + 0.21 × 77K × 1s ≈ 305s + 16,227s ≈ **4.6 hours**
- Enumeration is <0.01% of total pipeline time at c7

At c8 (estimated 500K formulas after dedup):
- Enumeration with Array optimization: ~10-30 minutes (per report estimate)
- Labeling: 0.79 × 500K × 5ms + 0.21 × 500K × 1s ≈ 1,975s + 105,000s ≈ **29.7 hours**
- Even with the current 3.7h+ enumeration, labeling would dominate by 8x
- With Array-optimized enumeration (30 min), labeling dominates by **60x**

The report mentions timeout percentage increases with complexity (12% at c4 → 21% at c7), so c8 may have 25%+ timeouts, making labeling even more dominant.

### Verdict
**Confirmed gap.** The report correctly identifies enumeration as infeasible at c8, but doesn't frame the optimization in the context of the full pipeline. Reducing enumeration from 3.7h to 30min is valuable but doesn't change the end-to-end timeline much — labeling at ~30 hours is the binding constraint. This significantly affects the ROI analysis of the proposed strategies.

The report's Phase 2-3 strategies (reducing formula COUNT) have much higher ROI than Phase 1 (reducing enumeration TIME), because fewer formulas means fewer labeling calls. A 4.58x count reduction from canonicalization saves ~24 hours of labeling at c8, while Array conversion saves ~3 hours of enumeration.

### Confidence Level
**Medium.** Labeling time estimates are based on c7 statistics extrapolated to c8. Actual decision times at c8 may differ.

---

## Finding 6: Completeness Guarantees Are Under-Specified

### Claim Being Challenged
Task description: "without losing coverage of interesting formulas." Several strategies explicitly lose coverage.

### Analysis

The report proposes optimizations with different completeness properties:

| Strategy | Coverage Loss | Acceptable? |
|----------|--------------|-------------|
| Array-based accumulation | None | Yes |
| Streaming filter | None (passesFilter already exists) | N/A (no effect at c8) |
| Structural pruning | Loses redundant formulas | **Depends on definition** |
| Alpha-canonical | Loses atom-permutation variants | **Already accepted** (task 267) |
| Semantic dedup | Loses semantically equivalent variants | **Needs justification** |
| Budget-aware sampling | Loses deterministic coverage | **Explicitly breaks exhaustiveness** |

For training data generation, the key question is: do syntactically different but semantically equivalent formulas provide training signal? The report doesn't address this. If `p → (q → p)` and `q → (p → q)` have different proof trees (they do — different axiom instantiations), then semantic dedup loses valuable training diversity even though the formulas are "equivalent."

Similarly, structural pruning (e.g., skipping `□□φ` under S5) removes formulas that are valid in S5 but whose proofs exercise different rules than `□φ`. For proof-training data, these exercise paths through the proof system that simpler equivalents don't.

### Verdict
**Confirmed gap.** The report doesn't distinguish between "reduces formula count" and "reduces interesting formula count." The acceptable level of coverage loss depends on the downstream use case (training data diversity vs. enumeration efficiency), which is not discussed.

### Confidence Level
**Medium.**

---

## Finding 7: Missing Considerations

### 7a. Parallelism

The `enumExactHelper` inner loop uses `List.foldl` over partitions — purely sequential. Each partition's cross-product is independent and could be computed in parallel. Lean 4 supports `Task.spawn` for parallelism (already used in `labelFormula`). With 6 partitions at c8, parallel enumeration could provide up to 6x speedup with no algorithmic changes.

This is completely unmentioned in the report despite being potentially the highest-ROI optimization (zero algorithmic complexity, multiplicative with Array conversion).

### 7b. Incremental Delivery Is Under-Prioritized

The report lists incremental output as Phase 3 (5.7, "Resilience"). But incremental delivery also enables:
- **Early monitoring**: see formula distribution as enumeration proceeds
- **Pipeline overlap**: start labeling while enumeration continues (pipeline parallelism)
- **Debugging**: identify enumeration bugs from partial output without waiting for completion

Pipeline overlap is especially valuable given Finding 5: if labeling takes 30 hours and enumeration takes 30 minutes, starting labeling after the first complexity level completes means almost zero wasted wall-clock time. The current architecture forces sequential: enumerate ALL, THEN label ALL.

### 7c. The `hashDedup` Function Uses Hash-Only Dedup (Collision Risk)

Line 1300-1308 of FormulaEnumerator.lean:
```lean
private def hashDedup (formulas : List Formula) : List Formula :=
  let (_, result) := formulas.foldl
    (fun (acc : Std.HashMap UInt64 Unit × List Formula) φ =>
      let h := hash φ
      if seen.contains h then (seen, deduped)
      else (seen.insert h (), deduped ++ [φ]))
    ({}, [])
  result
```

This deduplicates by hash value alone (UInt64), not by structural equality. With millions of formulas, hash collisions are statistically significant (birthday problem: ~50% collision probability at ~4.3 billion entries, but even at 1.7M entries, the probability of at least one collision is non-trivial). Colliding formulas would be silently dropped. This isn't mentioned in the report.

### 7d. `deduplicateCanonical` Has O(n²) Append

Line 137:
```lean
else (seen.insert canonical, deduped ++ [canonical])
```

This uses `deduped ++ [canonical]` inside a foldl, which is O(|deduped|) per formula — the exact same accumulator antipattern identified for enumeration. At 500K+ formulas, this contributes significant overhead to the deduplication phase. Should be `canonical :: deduped` with a final reverse, or use Array accumulation.

---

## Summary: Prioritization Reordering

Based on this critical analysis, I recommend reordering the implementation priority:

| Priority | Strategy | ROI Justification |
|----------|----------|-------------------|
| 1 | **Pipeline parallelism** (enumerate → label overlap) | Zero algorithmic change, saves ~30h wall-clock at c8 |
| 2 | **Enumeration-time canonical filtering** (move existing canon into inner loop) | 4.58x fewer formulas = 4.58x less labeling = ~24h saved |
| 3 | **Array-based accumulation** | ~4-5x enumeration speedup = ~3h saved |
| 4 | **Partition-level parallelism** | Up to 6x enumeration speedup, composes with #3 |
| 5 | **Structural pruning** | 10-20% additional count reduction |
| 6 | **Fix `deduplicateCanonical` O(n²) append** | Quick fix, noticeable at scale |
| 7 | **Incremental output** | Resilience + monitoring |

The report's priority order (#1 = Array, #2 = streaming filter) should be revised. Streaming filter is a no-op at c8 (Finding 3), and Array conversion is less impactful than formula count reduction (Finding 5).

---

## References

- FormulaEnumerator.lean: lines 127-208 (enumExactHelper), 619-630 (passesFilter), 1300-1308 (hashDedup), 1363-1382 (enumerateWithProgress)
- AtomCanonicalization.lean: lines 115-141 (canonicalize, deduplicateCanonical)
- DatasetExport.lean: line 1017 (canon dedup in pipeline), line 525 (wallclock timeout)
- DatasetGenerator.lean: lines 572-615 (labelFormula with wall-clock timeout)
- Lean 4 Reference: [Linked Lists](https://lean-lang.org/doc/reference/latest/Basic-Types/Linked-Lists/), [Arrays](https://lean-lang.org/doc/reference/latest/Basic-Types/Arrays/), [Reference Counting](https://lean-lang.org/doc/reference/latest/Run-Time-Code/Reference-Counting/)
- Ullrich & de Moura, ["Counting Immutable Beans"](https://arxiv.org/abs/1908.05647) (IFL 2019)
- Geier & Rozier, ["Efficient Normalization of Linear Temporal Logic"](https://arxiv.org/pdf/2310.12613) (2023)
