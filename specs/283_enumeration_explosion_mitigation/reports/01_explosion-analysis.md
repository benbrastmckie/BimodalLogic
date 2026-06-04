# Research Report: Cross-Product Explosion in Exhaustive Formula Enumeration

- **Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
- **Date**: 2026-06-04
- **Status**: Detailed analysis with runtime observations from c8 attempt

## 1. Problem Statement

The exhaustive formula enumerator (`FormulaEnumerator.lean:enumExactHelper`) becomes infeasible at complexity 8 due to a combinatorial explosion in the cross-product of binary operator subformulas. At complexity 7, exhaustive enumeration completes in under 1 second and produces 77,272 labeled records in ~8 minutes total. At complexity 8, the enumeration phase alone has been running for 3h42m without completing. Complexity 9 exhaustive is completely infeasible.

## 2. Root Cause Analysis

### 2.1 The Enumeration Algorithm

`enumExactHelper` generates all formulas of *exactly* complexity `n` by:

1. **Unary operators** (box, F, P, G, H): wrap each formula of complexity `n-1`. Cost: O(|level(n-1)|) per operator.
2. **Binary operators** (imp, untl, snce): for each partition `(k, n-1-k)` where `1 ≤ k ≤ n-2`, compute the full cross-product of `level(k) × level(n-1-k)`. Cost: O(|level(k)| × |level(n-1-k)|) per operator per partition.

The critical code (lines 192-201):

```lean
let (lefts, c1) := enumExactHelper atoms modalBudget temporalBudget leftSize accCache
let (rights, c2) := enumExactHelper atoms modalBudget temporalBudget rightSize c1
let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
```

This materializes the entire cross-product as a Lean `List Formula` in memory.

### 2.2 Formula Counts Per Level (Observed)

| Level | Raw Enumerated | After Dedup | Growth Factor |
|-------|----------------|-------------|---------------|
| 3     | 132            | —           | —             |
| 4     | 960            | 408         | 7.3×          |
| 5     | 6,040          | 2,283       | 6.3×          |
| 6     | 39,816         | 13,064      | 6.6×          |
| 7     | 259,888        | 77,272      | 6.5×          |
| 8     | ~1.7M (est.)   | ~500K (est.)| ~6.5×         |
| 9     | ~11M (est.)    | ~3M (est.)  | ~6.5×         |

### 2.3 Cross-Product Sizes Per Partition at Level 8

For `imp` alone (complexity 8, child budget 7, partitions into left+right=7):

| Partition (L,R) | |Left| | |Right| | Cross-product |
|-----------------|--------|---------|---------------|
| (1, 6)          | 4      | 39,816  | 159,264       |
| (2, 5)          | 12     | 6,040   | 72,480        |
| (3, 4)          | 132    | 960     | 126,720       |
| (4, 3)          | 960    | 132     | 126,720       |
| (5, 2)          | 6,040  | 12      | 72,480        |
| (6, 1)          | 39,816 | 4       | 159,264       |
| **Total imp**   |        |         | **716,928**   |

With `untl` and `snce` adding similar counts (gated by temporal depth budget), plus unary operators, the total at level 8 is approximately:
- `imp`: ~717K
- `untl`: ~500K (smaller due to temporal depth constraint)
- `snce`: ~500K
- Unary (box, F, P, G, H): ~5 × 260K = ~1.3M
- **Total: ~3M+ formulas materialized before filtering**

### 2.4 Why Level 7 Was Fast and Level 8 Is Not

At level 7, the worst partition is (3,4) = 132 × 960 = 126,720 for `imp`. Total cross-products across all operators and partitions: ~300K. This completes in <1 second.

At level 8, the aggregate cross-product exceeds 3M formulas — a 10× increase. But the *time* increase is far more than 10×: c7 enumeration took <1s, while c8 has exceeded 3.5 hours (>12,000× slower). The superlinear slowdown has three causes:

1. **List.flatMap allocation pressure**: Each cross-product materializes millions of `Formula` AST nodes on the heap. Lean's reference-counted GC must trace and free each node, creating GC pressure proportional to the square of the list sizes.

2. **List append is O(n)**: `allFormulas ++ imps` copies the entire accumulated list on each partition. With millions of accumulated formulas, later appends become extremely expensive. At partition k of 21, the append copies all formulas from partitions 1..k-1.

3. **Cache thrashing**: The memoization cache (`EnumCache`) stores all formulas at every (size, modal, temporal) triple. At c8 the cache holds hundreds of thousands of entries. HashMap lookups on large Formula ASTs (which require deep structural equality checks) become expensive.

### 2.5 Level 9+ Projection

At level 9, the (1,7) partition produces 4 × 259,888 = 1M formulas for `imp` alone. The (4,4) partition produces 960 × 960 = 922K. The (3,5)/(5,3) partitions: 132 × 6,040 = 797K each. Total `imp` cross-products: ~5M. With `untl`/`snce`: ~15M+. This would require tens of GB of RAM and days of computation. Exhaustive c9 enumeration is completely infeasible with the current algorithm.

## 3. Runtime Observations from c8 Attempt

### 3.1 Timeline

The c8 exhaustive run was started at 08:31 and monitored every 5-10 minutes:

| Elapsed | RSS (MB) | Δ RSS | Phase |
|---------|----------|-------|-------|
| 5 min   | 302      | —     | Enumerating (levels 1-7 complete instantly, stuck on level 8) |
| 13 min  | 310      | +8    | Slow accumulation |
| 21 min  | 317      | +7    | Slow accumulation |
| 26 min  | 321      | +4    | Slowing |
| 34 min  | 327      | +6    | Steady |
| 45 min  | 334      | +7    | Steady |
| 56 min  | 372      | +38   | Acceleration — large partition starting |
| 67 min  | 378      | +6    | In-partition work |
| 78 min  | 383      | +5    | In-partition work |
| 88 min  | 388      | +5    | Plateau approaching |
| 102 min | 393      | +5    | Plateau |
| 113 min | 777      | +384  | **Phase change** — massive allocation spike |
| 124 min | 770      | -7    | GC reclaiming, partition completed |
| 135 min | 764      | -6    | Declining |
| 146 min | 760      | -4    | Plateau |
| 157 min | 756      | -4    | Plateau |
| 168 min | 756      | 0     | Flat — tight compute loop |
| 179 min | 740      | -16   | Partition completed, GC drop |
| 189 min | 740      | 0     | Flat |
| 200 min | 740      | 0     | Flat for 30 min |
| 211 min | 719      | -21   | Partition completed, GC drop |
| 222 min | 717      | -2    | Flat |

### 3.2 Interpretation

The RSS trace reveals a **partition-by-partition execution pattern**:

1. **Accumulation phase** (0-56 min): Levels 1-7 complete instantly. Level 8 begins processing binary operator partitions. RSS grows slowly (~1 MB/min) as smaller partitions (e.g., (2,5), (5,2)) are computed.

2. **Spike at 113 min** (393→777 MB, +384 MB): A large partition materialized its full cross-product. This is likely the (1,6) or (6,1) partition where one side has 39,816 formulas, producing ~159K `imp` formulas that must be appended to the growing list.

3. **Cyclic drops** (~30-40 min periods): After each partition completes, GC reclaims the intermediate cross-product lists. The drops at 124 min (777→770), 179 min (756→740), and 211 min (740→719) each represent one partition's cleanup.

4. **30-40 minute cycles**: Each major partition takes 30-40 minutes to compute. With ~21 cross-products (7 partitions × 3 binary operators), and accounting for temporal depth constraints reducing some, the total enumeration would take approximately **10-15 hours**.

### 3.3 Key Insight: The Time Is Not in Enumeration Logic

The memoized `enumExactHelper` calls are cached — looking up formulas at each complexity level is O(1) after first computation. The time is spent in:

1. **`List.flatMap`**: Materializing N×M formula pairs as a linked list
2. **`List.append` (++)**: Copying the accumulated formula list on each partition (O(accumulated_length))
3. **GC pressure**: Tracing and freeing millions of short-lived AST nodes

This means the fix is not about smarter enumeration logic — it's about **avoiding full materialization of cross-products**.

## 4. Limitations of Current Approach

1. **No structural deduplication**: `p → q` and `q → p` are both generated despite being trivially related by variable renaming. Under alpha-equivalence with 3 atoms (p, q, r), many formulas are equivalent up to atom permutation. With 3 atoms, up to 6× redundancy.

2. **No semantic deduplication**: `p → (q → p)` and `¬q → (p → ¬q)` are syntactically different but semantically equivalent tautologies. Both are generated and labeled separately.

3. **No simplification filtering during enumeration**: `p → p`, `¬¬p → p`, `□□p → □p` (under S5) are generated despite being trivially reducible. These consume enumeration budget without adding training value. The `passesFilter` check happens *after* full materialization.

4. **Full materialization**: The entire cross-product is built as a `List Formula` before any filtering. Even if 90% of the cross-product would be filtered, all entries are allocated first.

5. **List append is O(n)**: `allFormulas ++ imps` copies the left list. With millions of accumulated formulas, later appends dominate runtime. This is the single largest contributor to the superlinear slowdown.

6. **No streaming/incremental output**: The entire enumeration must complete before any formulas are written to disk. A crash or kill at 3.5 hours loses all work.

## 5. Candidate Mitigation Strategies

### 5.1 Array-Based Accumulation (High Impact, Easy — Do First)

Replace `List Formula` with `Array Formula` throughout the enumeration pipeline. This converts O(n) append to O(1) amortized push, and O(n×m) flatMap to direct indexed iteration with push. **Estimated speedup: 5-20× at c8** based on the observation that list copying dominates runtime.

This is the lowest-risk, highest-ROI change. It doesn't reduce formula count but eliminates the algorithmic inefficiency that causes the superlinear slowdown.

```lean
-- Before (O(n) append, O(n×m) flatMap):
let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
accList ++ imps

-- After (O(1) amortized push):
for l in lefts do
  for r in rights do
    accArray := accArray.push (Formula.imp l r)
```

### 5.2 Streaming Filter During Cross-Product (High Impact, Medium)

Apply `passesFilter` inside the cross-product loop rather than after materialization. Formulas that fail the filter are never allocated or stored. At c7, the dedup ratio is 306K enumerated → 77K after dedup (75% filtered). If similar ratios hold at c8, this would reduce memory by 4× and allocation count by 4×.

```lean
for l in lefts do
  for r in rights do
    let f := Formula.imp l r
    if passesFilter f then
      accArray := accArray.push f
```

### 5.3 Equivalence-Class Enumeration (High Impact, Hard)

Generate one canonical representative per equivalence class under atom permutation (alpha-equivalence). With 3 atoms, there are at most 3! = 6 permutations, reducing output by up to 6×. Implementation: define a canonical ordering where atoms appear in order of first occurrence in a left-to-right DFS traversal. During enumeration, only generate formulas where the first atom encountered is `p`, the second is `q`, the third is `r`.

**Estimated reduction**: 3-6× fewer formulas at every level, compounding across levels. A 4× reduction at each level means the c8 cross-product (4,3) drops from 960 × 132 to ~240 × 33 = 7,920 (16× smaller).

### 5.4 Structural Redundancy Pruning During Enumeration (Medium Impact, Medium)

Reject formulas during cross-product generation when the pair would create a trivially reducible expression:

- **S5 idempotence**: Skip `box(box(φ))` — equivalent to `box(φ)` under S5. Don't pair a `box` child with the `box` constructor.
- **Temporal idempotence**: Skip `G(G(φ))`, `F(F(φ))`, `H(H(φ))`, `P(P(φ))`.
- **Identity implication**: Skip `φ → φ` — always valid. When left == right in an `imp` partition, skip.
- **Bottom absorption**: Skip `⊥ → φ` — always valid. When left is `⊥`, skip `imp`.
- **Negation normal form**: Skip `¬¬φ` — equivalent to `φ`. (Encoded as `(φ → ⊥) → ⊥`.)
- **Vacuous temporal**: Skip `U(φ, ⊤)` — always true. Skip `U(⊥, φ)` — already caught by structural prefilter.

These checks are O(1) per pair and can be applied inside the cross-product loop. Estimated 10-20% reduction in materialized formulas.

### 5.5 Semantic Deduplication via Small-Model Hashing (Medium Impact, Post-Processing)

Evaluate each formula on all truth assignments over a small Kripke model (e.g., 2 worlds, 2 time points, 3 atoms = 2^(3×2×2) = 4096 assignments) to compute a semantic fingerprint. Formulas with identical fingerprints are candidates for semantic equivalence. Keep one representative per fingerprint bucket.

This is best applied as a post-processing pass after enumeration, not during it, because the Kripke evaluation requires the full formula AST. **Estimated reduction**: 30-50% at c7+ based on the high proportion of semantically equivalent formulas observed in practice.

### 5.6 Budget-Aware Cross-Product Sampling (Low Impact, Easy Fallback)

For any partition where |left| × |right| > threshold, sample N representative pairs using deterministic LCG rather than materializing all. This preserves the enumeration framework while bounding worst-case time. Coverage is no longer truly exhaustive but is statistically representative.

### 5.7 Incremental Output / Checkpointing (Resilience)

Write formulas to disk incrementally during enumeration rather than accumulating the entire list in memory. This prevents total loss on crash/kill and enables monitoring of progress. Each partition's results can be flushed to a temporary file and merged at the end.

## 6. Recommended Implementation Order

Based on impact, feasibility, and risk:

### Phase 1: Performance (make c8 feasible in minutes)

1. **Array-based accumulation (5.1)** — Convert all `List Formula` to `Array Formula` in enumExactHelper and enumerateWithProgress. Estimated 1-2 hours, 5-20× speedup. **Do this first.**
2. **Streaming filter (5.2)** — Apply passesFilter inside cross-product loop. Estimated 1 hour, 4× memory reduction. Compose with 5.1.

These two changes alone should make c8 exhaustive feasible in 10-30 minutes.

### Phase 2: Redundancy elimination (reduce formula count 5-10×)

3. **Structural pruning during enumeration (5.4)** — O(1) checks inside cross-product loop. Estimated 2-3 hours. 10-20% reduction.
4. **Alpha-canonical enumeration (5.3)** — Major refactor. Estimated 4-6 hours. 3-6× reduction. This is the single biggest reduction in formula count but requires careful design.

With Phase 2, c8 should produce ~50-100K formulas (vs. estimated ~500K without) and c9 exhaustive may become feasible.

### Phase 3: Semantic deduplication (maximize training quality)

5. **Small-model semantic hashing (5.5)** — Post-processing pass. Estimated 3-4 hours. 30-50% additional reduction.
6. **Incremental output (5.7)** — Resilience improvement. Estimated 2 hours.

### Phase 4: Scalability research

7. Consult prior art on canonical enumeration in modal logic
8. Evaluate whether backward proof generation (task 279) should replace exhaustive enumeration as the primary generation strategy for c9+

## 7. Prior Art to Consult

- **SPOT's `randltl`**: LTL formula generator with configurable operator distribution and redundancy avoidance. Uses DAG-based generation to avoid exponential blowup.
- **LTLBench (2024)**: LTL benchmark generation with difficulty calibration — uses template-based generation to avoid full enumeration.
- **Efficient Normalization of Linear Temporal Logic (2023, arxiv:2310.12613)**: Canonical forms for LTL formulas — directly applicable to alpha-canonicalization (5.3).
- **SAT competition formula generators**: Techniques for generating non-trivial, non-redundant instances.
- **Knuth's BDD-based enumeration**: Canonical enumeration of Boolean functions — the gold standard for avoiding redundancy in propositional enumeration.
- **SynLogic (NeurIPS 2025)**: Parameterized generation with verifiers — template-based approach that avoids full enumeration entirely.
- **Lean 4 Array vs List performance**: Lean 4's `Array` type is backed by a mutable array with O(1) amortized push (when uniquely owned). Converting from List to Array is the standard optimization for accumulation patterns in Lean.

## 8. Completed Datasets

Truly exhaustive datasets generated with unlimited enumeration (post-task-274 fixes):

| Tier | Records | Enumerated | Dedup Ratio | Valid% | Timeout% | Time |
|------|---------|------------|-------------|--------|----------|------|
| c4   | 408     | 1,092      | 2.7×        | 5%     | 12%      | <1s  |
| c5   | 2,283   | 7,132      | 3.1×        | 7%     | 14%      | 5s   |
| c6   | 13,064  | 46,948     | 3.6×        | 9%     | 17%      | 40s  |
| c7   | 77,272  | 306,836    | 4.0×        | 11%    | 21%      | ~8 min |
| c8   | —       | est. ~1.7M | est. ~3.4×  | —      | —        | >3.7h (not complete) |
| c9   | 27,797  | (stratified) | —         | 8%     | 14%      | 2 min (stratified) |

### Observations

1. **Dedup ratio increases with complexity**: 2.7× at c4 → 4.0× at c7. This suggests growing redundancy at higher levels — more formulas are syntactic variants of each other. Alpha-canonicalization (5.3) would directly address this.

2. **Valid% increases with complexity**: 5% at c4 → 11% at c7. Higher complexity formulas are more likely to be valid, probably because there are more ways to construct tautologies from larger subformulas.

3. **Timeout% increases with complexity**: 12% at c4 → 21% at c7. The prover struggles more with higher complexity, especially temporal formulas. This is a separate bottleneck addressed by tasks 277-278 (tableau instrumentation, prefilter expansion).

4. **Growth is ~6.5× per level**: Remarkably consistent from c3 to c7. This means each additional complexity level multiplies the enumeration time by ~40× (due to the quadratic cross-product cost scaling as 6.5²).

## 9. Recommendation

**Immediate**: Implement Phase 1 (Array accumulation + streaming filter) to make c8 exhaustive feasible. This is a straightforward Lean 4 refactor with high confidence of success.

**Short-term**: Implement alpha-canonical enumeration (Phase 2) to reduce formula count 3-6× at every level, which would make c9 exhaustive potentially feasible and dramatically improve c8 performance.

**Medium-term**: The backward proof generation approach (task 279) may ultimately be more valuable than exhaustive enumeration for c9+ — generating formulas with guaranteed interesting proofs rather than enumerating all formulas and hoping some are interesting. The 8% valid rate at c9 means 92% of prover calls are wasted on invalid or trivial formulas.
