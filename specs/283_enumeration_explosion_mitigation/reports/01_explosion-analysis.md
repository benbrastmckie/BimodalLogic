# Research Report: Cross-Product Explosion in Exhaustive Formula Enumeration

- **Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
- **Date**: 2026-06-04
- **Status**: Initial analysis (pre-research)

## 1. Problem Statement

The exhaustive formula enumerator (`FormulaEnumerator.lean:enumExactHelper`) becomes infeasible at complexity 8 due to a combinatorial explosion in the cross-product of binary operator subformulas. At complexity 7, exhaustive enumeration completes in under 1 second. At complexity 8, it has been running for 45+ minutes without completing. Complexity 9 exhaustive is completely infeasible.

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

### 2.2 Formula Counts Per Level

| Level | Formulas | Growth Factor |
|-------|----------|---------------|
| 3     | 132      | —             |
| 4     | 960      | 7.3×          |
| 5     | 6,040    | 6.3×          |
| 6     | 39,816   | 6.6×          |
| 7     | 259,888  | 6.5×          |
| 8     | ~1.7M (est.) | ~6.5×     |
| 9     | ~11M (est.) | ~6.5×      |

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
- **Total: ~3M+ formulas materialized**

But the *time* cost is worse than the count suggests because `List.flatMap` on Lean lists is O(n×m) with allocation pressure. Each formula is a recursive AST, so GC overhead is substantial.

### 2.4 Why Level 7 Was Fast

At level 7, the worst partition is (3,4) = 132 × 960 = 126,720. The total cross-product across all partitions and operators is ~300K formulas. This fits comfortably in memory and completes in <1 second.

At level 8, the (1,6) and (6,1) partitions involve 39,816 formulas on one side, and the (4,3)/(3,4) partitions are 960 × 132 — individually manageable but there are 7 partitions × 3 binary operators = 21 cross-products to materialize. The aggregate is what kills it.

### 2.5 Level 9 Projection

At level 9, the (1,7) partition alone would be 4 × 259,888 = 1M formulas for `imp`. The (4,4) partition would be 960 × 960 = 922K. The (3,5)/(5,3) partitions: 132 × 6,040 = 797K each. Total `imp` cross-products: ~5M. With `untl`/`snce`: ~15M+. This would require hours and tens of GB of RAM. Exhaustive c9 enumeration is infeasible.

## 3. Current Workaround

For complexity 9+, the script uses **stratified sampling**: exhaustive at lower levels, random sampling at higher levels. The `--stratified-quotas` flag caps how many formulas are sampled per level. This produces usable datasets (c9: 27,797 records in 2 minutes) but is not truly exhaustive — it misses formulas.

## 4. Limitations of Current Approach

1. **No structural deduplication**: `p → q` and `q → p` are both generated despite being trivially related by variable renaming. Under alpha-equivalence with 3 atoms (p, q, r), many formulas are equivalent up to atom permutation.

2. **No semantic deduplication**: `p → (q → p)` and `¬q → (p → ¬q)` are syntactically different but semantically equivalent tautologies. Both are generated and labeled separately.

3. **No simplification filtering**: `p → p`, `¬¬p → p`, `□□p → □p` (under S5) are generated despite being trivially reducible. These consume enumeration budget without adding training value.

4. **Full materialization**: The entire cross-product is built as a `List Formula` before any filtering. Even if 90% of the cross-product is redundant, all entries are allocated, appended, and then discarded by `passesFilter`.

5. **List append is O(n)**: `allFormulas ++ imps` on Lean lists copies the left list. With millions of accumulated formulas, each append becomes expensive.

## 5. Candidate Mitigation Strategies

### 5.1 Equivalence-Class Enumeration (High Impact)

Generate one canonical representative per equivalence class under atom permutation (alpha-equivalence). With 3 atoms, there are at most 3! = 6 permutations, so this could reduce output by up to 6×. Implementation: define a canonical form (e.g., atoms appear in order of first occurrence), generate only formulas in canonical form.

### 5.2 Lazy/Streaming Enumeration (High Impact)

Replace `List.flatMap` with a streaming iterator that applies `passesFilter` during cross-product generation rather than after. Formulas that fail the filter are never allocated. This doesn't reduce the number of *iterations* but eliminates most *allocations*.

### 5.3 Symmetry Breaking for Commutative Operators (Medium Impact)

For `imp`, order doesn't matter for satisfiability/validity classification (φ → ψ and ψ → φ have different truth values, so both needed). But for `untl` and `snce`, the two arguments have asymmetric roles (event vs. condition), so there's no commutativity to exploit. However, `untl(φ, ψ)` and `snce(φ, ψ)` are temporal duals — the existing `--include-duals` flag already handles this, but both are still enumerated independently.

### 5.4 Structural Redundancy Pruning (Medium Impact)

Skip formulas containing reducible subexpressions:
- Double negation: `¬¬φ` (equivalent to `φ` in classical logic)
- Identity implications: `φ → φ` (always valid)
- Vacuous box: `□⊤` (always valid under any accessibility relation)
- S5 collapse: `□□φ` (equivalent to `□φ` under S5)
- Temporal collapse: `GGφ` (equivalent to `Gφ`)
- Bottom propagation: `□⊥ → anything` (antecedent unsatisfiable in S5)

This could be applied *during* enumeration (reject left/right children that would create reducible pairs) rather than after.

### 5.5 Semantic Deduplication via Small-Model Hashing (Medium Impact)

Evaluate each formula on all truth assignments over a small Kripke model (e.g., 2 worlds, 2 time points) to compute a semantic hash. Formulas with the same hash are *candidates* for equivalence (not proven equivalent, but highly likely). Keep only one per hash bucket. This is cheap (2^(atoms × worlds × times) evaluations per formula) and catches most redundancies.

### 5.6 Budget-Aware Cross-Product Sampling (Low Impact, Easy)

For any partition where |left| × |right| > threshold, sample N representative pairs instead of materializing all. This is the simplest fix but sacrifices coverage guarantees.

### 5.7 Array-Based Accumulation (Performance Only)

Replace `List Formula` accumulation with `Array Formula` to eliminate O(n) append costs. This doesn't reduce the formula count but would significantly speed up the enumeration at all levels.

## 6. Prior Art to Consult

- **SPOT's `randltl`**: LTL formula generator with configurable operator distribution and redundancy avoidance
- **LTLBench (2024)**: LTL benchmark generation with difficulty calibration
- **Efficient Normalization of Linear Temporal Logic (2023)**: Canonical forms for LTL formulas
- **SAT competition formula generators**: Techniques for generating non-trivial, non-redundant instances
- **Propositional formula enumeration**: Knuth's approaches to canonical BDD-based enumeration
- **SynLogic (NeurIPS 2025)**: Parameterized generation with verifiers — template-based approach that avoids full enumeration

## 7. Recommended Research Plan

1. **Quantify redundancy**: Run the existing c5/c6 datasets through alpha-equivalence normalization and semantic hashing to measure how many formulas are redundant. This determines the ceiling for deduplication gains.
2. **Benchmark candidate strategies**: Implement 5.1 (alpha-canonicalization) and 5.2 (streaming filter) as prototypes at c7, measure speedup and coverage loss.
3. **Consult prior art**: Web search for formula enumeration in modal/temporal logic generators, focusing on redundancy avoidance techniques.
4. **Design combined approach**: Most likely the solution is a combination of alpha-canonicalization (5.1) + streaming filter (5.2) + structural pruning (5.4) + Array accumulation (5.7), with semantic hashing (5.5) as a post-processing pass.
5. **Validate at c8/c9**: Verify that the combined approach makes c8 feasible in minutes and c9 feasible in under an hour.

## 8. Current c8 Status

As of this writing, the uncapped exhaustive c8 enumeration has been running for ~50 minutes at 99.4% CPU with 334 MB RSS. No output file has been produced (still in the `enumExactBudget` call for level 8). The process is not stuck — RSS is growing at ~1 MB/min — but completion time is uncertain. Estimated 2-3 hours total (enumeration + labeling).

Completed datasets (truly exhaustive, unlimited):

| Tier | Records | Enumerated | After Dedup | Time |
|------|---------|------------|-------------|------|
| c4   | 408     | 1,092      | 408         | <1s  |
| c5   | 2,283   | 7,132      | 2,283       | 5s   |
| c6   | 13,064  | 46,948     | 13,064      | 40s  |
| c7   | 77,272  | 306,836    | 77,272      | ~8 min |
| c8   | running | est. ~1.7M | est. ~500K  | est. 2-3h |
