# Research Report: Task #283 — Enumeration Explosion Mitigation

**Task**: Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
**Date**: 2026-06-04
**Mode**: Team Research (5 teammates: Primary, Alternatives, Critic, Horizons, Parallelization)
**Session**: sess_1780601288_b06b55

## Summary

Five research agents investigated the enumeration explosion from complementary angles: Lean 4 performance patterns, prior art in formula generation, critical evaluation of existing claims, strategic alignment, and parallelization feasibility. The synthesis resolves three significant conflicts in the existing analysis and reorders implementation priorities based on a pipeline-level view of the problem.

**Key corrections to the original report (01_explosion-analysis.md)**:
1. The "5-20x speedup" from Array conversion is narrowed to **4-8x** — still the highest-ROI single change, but the GC pressure reasoning was partially incorrect
2. The "4x memory reduction" from streaming `passesFilter` is **a complete no-op at c8** — zero formulas are filtered (all c8 formulas contain modal/temporal operators)
3. **Prover labeling is the binding constraint** at c8 (~30h), not enumeration (~30min with Array) — formula count reduction has 8x higher ROI than enumeration speed improvement

**Strongest recommendations**:
- Phase 1 (2-4h): Array conversion + incremental output → makes c8 feasible in 40-120 min
- Phase 2 (4-6h): Move canonicalization into enumeration loop → 4.58x fewer formulas → ~24h labeling savings
- Phase 3 (4-6h): Two-phase parallel cross-products → c8 enumeration in 5-15 min on 8 cores
- Phase 4 (future): Backward generation from BX axioms for c9+ (paradigm shift)

## Key Findings

### 1. Array-Based Accumulation Remains the Highest-ROI Single Change

**Sources**: Teammate A (primary analysis), Teammate C (critical correction)

**Confirmed**: Converting `List Formula` to `Array Formula` throughout the enumeration pipeline eliminates O(n) list append overhead. Teammate A's quantitative analysis shows 4.3M wasted element copies at c8 from the `accList ++ imps ++ temporalBinaries` pattern.

**Correction**: Teammate C identifies that Lean 4's RC optimization makes uniquely-owned `List.append` O(n) with in-place pointer relinking (no allocation). However, the critical nuance is that **cached lists have RC ≥ 2** (one reference in the HashMap cache, one returned to the caller), which breaks the RC in-place optimization. This means operations on cached result lists are even worse than a naive analysis suggests — every `List.map` or `List.flatMap` on cached results must allocate fresh cons cells.

**Resolution**: The structural speedup from Array is **4-5x** (not 5-20x). The additional benefit from avoiding GC pressure on non-unique cached lists may add 1-3x, giving a realistic range of **4-8x**. This is still transformative — bringing c8 enumeration from ~10-15h to **40-120 minutes**.

**Concrete code transformation** (from Teammate A):
```lean
-- Before: O(n) append + O(n×m) flatMap on RC≥2 cached lists
let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
(accList ++ imps ++ temporalBinaries, c3)

-- After: O(1) amortized push into uniquely-owned accumulator
let mut acc : Array Formula := #[]
acc := acc.reserve (lefts.size * rights.size)
for l in lefts do
  for r in rights do
    acc := acc.push (Formula.imp l r)
```

**Confidence**: HIGH

### 2. Streaming passesFilter Is a No-Op at c8

**Source**: Teammate C (critical analysis, confirmed by Teammate A)

The original report's claim of "4x memory reduction" from applying `passesFilter` inside the cross-product loop is based on a misattribution. The 306K→77K "dedup" at c7 comes from **atom-canonicalization deduplication** (applied post-enumeration in `DatasetExport.lean`), not from `passesFilter`.

The `passesFilter` function (`complexity ≥ 3 && hasModalOrTemporal`) rejects **exactly 0%** of c8 formulas because:
- All c8 formulas have complexity ≥ 8 (complexity check is vacuous)
- Pure propositional formulas at c8 = 0 (at even complexity levels, all imp partitions require one odd and one even child, and pure prop at even levels is always zero)

**Impact**: "Streaming filter during cross-product" should be removed from the implementation priority list for c8. The concept is not wrong — it's just that the existing filter has nothing to filter at high complexity. A more useful inline filter would be structural pruning checks (identity implication, ex falso, S5 idempotence).

**Confidence**: HIGH

### 3. Prover Labeling Is the Binding Constraint, Not Enumeration

**Sources**: Teammate C (pipeline analysis), Teammate D (strategic assessment)

At c7, enumeration takes <1s but labeling takes ~4.6h (77K formulas × mixed 5ms/1s-timeout). At c8 (estimated 500K formulas after dedup), labeling would take ~30 hours regardless of enumeration speed. Even with Array-optimized enumeration at 30 minutes, labeling dominates by **60x**.

**Critical implication**: The original report's priority order (Array first, formula count reduction later) inverts the true ROI. Reducing formula COUNT saves labeling time linearly — the 4.58x canonicalization reduction (already measured by task 267) saves ~24 hours of labeling at c8. Array conversion saves ~3 hours of enumeration. Count reduction has **8x higher ROI** on wall-clock time.

However, Array conversion is a prerequisite for making enumeration fast enough to iterate on. The corrected priority makes Array a foundation, then adds count reduction.

**Confidence**: MEDIUM-HIGH (labeling estimates extrapolated from c7 statistics)

### 4. Alpha-Canonical Enumeration Already Partially Exists

**Source**: Teammate C (code discovery)

`AtomCanonicalization.lean` already implements DFS-order canonical renaming and deduplication. `DatasetExport.lean` applies it at line 1017 (`AtomCanonicalization.deduplicateCanonical`). Task 267 measured a **4.58x** deduplication ratio.

The real optimization is moving this INTO the enumeration loop rather than implementing it from scratch. This is more complex than the original report suggests — checking canonicality during bottom-up construction requires consistent atom ordering as the formula tree is built.

**Additionally**: `deduplicateCanonical` has an O(n²) accumulator append anti-pattern (`deduped ++ [canonical]` inside a foldl) — the same issue as enumeration itself. This should be fixed as a quick win.

**Confidence**: HIGH

### 5. Two-Phase Parallel Enumeration Is Practical

**Source**: Teammate E (parallelization research)

Lean 4's `IO.asTask` / `Task.spawn` primitives are well-documented and already used in this codebase (`DatasetGenerator.lean:582`). A clean two-phase design avoids all cache-sharing problems:

- **Phase 1 (sequential, <1s)**: Pre-compute all sub-levels 1..(N-1) into a read-only cache
- **Phase 2 (parallel)**: Spawn 21 independent tasks for level-N cross-products, each reading the immutable cache

Amdahl's law with 99.98% parallel fraction gives near-linear scaling. Practical speedup on 8 cores: **5-6x** (limited by partition size imbalance, not by sequential fraction).

Combined with Array: c8 enumeration in **5-15 minutes** on 8 cores.

**Confidence**: HIGH

### 6. GPU Offloading Is Not Practical for Enumeration

**Source**: Teammate E (GPU analysis)

Formula enumeration is tree-structured AST construction — recursive, variable-size, heavily branching, memory-bound. This is a fundamental mismatch with GPU architecture (uniform data, minimal branching, high arithmetic intensity). No Lean 4 CUDA bindings exist.

GPU is conditionally viable for semantic deduplication (evaluating formulas on small Kripke models — embarrassingly parallel, batch-friendly), but the engineering effort (external C++/CUDA process, serialization layer) is not justified at c8 scale (~500K formulas).

**Confidence**: HIGH

### 7. Prior Art Consensus: Exhaustive Enumeration Doesn't Scale

**Sources**: Teammate B (prior art survey), Teammate D (ML perspective)

The 2025-2026 research community has converged on alternatives to exhaustive enumeration:
- **Saturation-driven derivation** (TPTP ecosystem, 2025): Generate from axioms via inference rules — guarantees proof-theoretic relevance
- **Backward proof generation** (DeepSeek-Prover-V2, 2025): Start from theorems, decompose into subgoals — every formula comes with a proof certificate
- **Parameterized generation with verifiers** (SynLogic, NeurIPS 2025): Controlled difficulty, rule-based generators
- **Quality over quantity** (Theorem Prover as Judge, ACL 2025): 3,508 verified samples competitive with millions of unverified ones

For TM bimodal logic with 41 BX axioms, saturation-driven derivation is directly applicable: instantiate axiom schemas, apply modus ponens / necessitation / temporal induction, collect at each derivation depth.

**Confidence**: HIGH for the paradigm assessment; MEDIUM for bimodal-specific adaptation

### 8. Incremental Delivery Is the Biggest Operational Gap

**Sources**: Teammate D (strategic), Teammate A (IO patterns)

The current architecture is all-or-nothing — 3.7h of enumeration before any output, with total loss on crash. Required infrastructure:
1. **Per-level JSONL flushing**: Write formulas to disk after each complexity level
2. **Resumable checkpointing**: Serialize cache after each level; on restart, skip computed levels
3. **Progress metrics**: Level completion, formulas/sec, partition timing, ETA estimation
4. **Pipeline overlap**: Start labeling while enumeration continues (enumerate → label pipeline parallelism saves the most wall-clock time)

Lean 4's `IO.FS.Handle` with periodic flush is straightforward. The existing `enumerateWithProgress` already interleaves IO per level.

**Confidence**: HIGH

## Synthesis

### Conflicts Resolved

| # | Conflict | Resolution |
|---|----------|------------|
| 1 | Array speedup: 5-20x (A) vs 4-5x (C) | **4-8x** — structural improvement is 4-5x; cache RC effect adds 1-3x. GC pressure claim was wrong for unique lists but correct for cached (RC≥2) lists |
| 2 | Streaming filter: "4x reduction" (original report) vs "no-op" (C) | **No-op at c8** — passesFilter rejects 0% of c8 formulas. The 4x was atom-canonicalization dedup, not passesFilter |
| 3 | Priority: enumeration speed (original) vs formula count (C) | **Formula count has 8x higher ROI** — labeling at ~30h dominates enumeration at ~30min. But Array is still the first step as a prerequisite |
| 4 | Parallelism: "missing" (C) vs "practical" (E) | **Practical and recommended** — two-phase design with immutable cache avoids all sharing issues; 5-6x on 8 cores |

### Gaps Identified

1. **Pipeline overlap** (enumerate → label concurrently) — potentially the single largest wall-clock improvement, unmentioned in original report
2. **hashDedup collision risk** — UInt64 hash-only dedup has statistically significant collision probability at 1.7M formulas; should use structural equality confirmation
3. **deduplicateCanonical O(n²) append** — same accumulator anti-pattern as enumeration; quick fix
4. **Dataset versioning** — no enumerator version hash or generation parameter recording
5. **Label balance** — 89% invalid at c7 is suboptimal for training; intentional balancing needed

## Recommendations

### Corrected Implementation Priority

| Phase | Strategy | Time Est. | Impact | ROI Justification |
|-------|----------|-----------|--------|-------------------|
| **1a** | Array-based accumulation | 2-4h | c8 enum: 10-15h → 40-120min | Prerequisite for everything else |
| **1b** | Incremental JSONL + checkpoint | 2h | Crash resilience, monitoring | Eliminates total-loss risk |
| **1c** | Fix `deduplicateCanonical` O(n²) | 30min | Dedup step speedup | Quick bug fix |
| **2a** | Move canonicalization into enumeration loop | 4-6h | 4.58x fewer formulas | ~24h labeling saved at c8 |
| **2b** | Structural pruning in cross-product | 1-2h | ~10-20% additional reduction | Composes with 2a |
| **3a** | Two-phase parallel cross-products | 4-6h | c8 enum: 40-120min → 5-15min | Multiplicative with Phase 1 |
| **3b** | Pipeline overlap (enum → label) | 2-4h | ~30h → near-zero idle time | Biggest wall-clock savings |
| **4** | Backward generation from BX axioms | 8-16h | c9+ paradigm shift | Eliminates 90% waste rate |

### Phase 1 alone (4-6h investment) makes c8 feasible
### Phase 2 alone saves ~24h of labeling per c8 run
### Phases 1+2+3 together bring c8 total pipeline from days to hours

### Long-Term Architecture (from Teammates B, D)

```
Tier 1: Exhaustive (c4-c7)       — DONE, 93K records
Tier 2: Optimized Exhaustive (c8) — This task, Phases 1-3
Tier 3: Backward Generation (c9+)  — BX axiom instantiation + derivation
Tier 4: Targeted Invalid (c9+)    — Structural mutation of valid formulas
Tier 5: Active Learning (future)   — Model uncertainty-guided generation
```

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|-----------------|------------|
| A | Primary (performance) | completed | Array conversion quantitative analysis, code transformation template | high |
| B | Alternatives (prior art) | completed | SPOT/SynLogic/saturation-driven paradigm survey, alpha-canonical algorithms | high |
| C | Critic | completed | passesFilter no-op, cache RC insight, prover-is-bottleneck, hashDedup bug | high |
| D | Horizons (strategy) | completed | ML literature consensus, hybrid generation architecture, incremental delivery | high |
| E | Parallelization | completed | Two-phase Task.spawn design, GPU infeasibility, combined speedup estimates | high |

## References

### Lean 4 Performance
- Lean 4 Arrays Reference — https://lean-lang.org/doc/reference/latest/Basic-Types/Arrays/
- Lean 4 Reference Counting — https://lean-lang.org/doc/reference/latest/Run-Time-Code/Reference-Counting/
- Lean 4 Tasks and Threads — https://lean-lang.org/doc/reference/latest/IO/Tasks-and-Threads/
- Ullrich & de Moura, "Counting Immutable Beans" (IFL 2019) — https://arxiv.org/abs/1908.05647

### Formula Generation Prior Art
- SPOT randltl — https://spot.lre.epita.fr/randltl.html
- LTLBench (2024) — https://arxiv.org/abs/2407.05434
- SynLogic (NeurIPS 2025) — https://arxiv.org/html/2505.19641v1
- Esparza-Rubio-Sickert LTL Normalization (JACM 2023) — https://arxiv.org/abs/2310.12613
- Saturation-Driven Dataset Generation (2025) — https://arxiv.org/pdf/2509.06809

### Neural Theorem Prover Training
- DeepSeek-Prover-V2 (2025) — https://arxiv.org/html/2504.21801v1
- Goedel-Prover-V2 (2025) — https://arxiv.org/abs/2508.03613
- Theorem Prover as a Judge (ACL 2025) — https://arxiv.org/html/2502.13137
- LeanAgent (ICLR 2025) — https://proceedings.iclr.cc/paper_files/paper/2025/file/b67c77f8db8b991d73d6f2e16f491840-Paper-Conference.pdf

### Parallel SAT/SMT
- SAT Competition 2024-2025 Parallel Track — https://cca.informatik.uni-freiburg.de/papers/BiereFallerFleuryFroleyksPollitt-SAT-Competition-2025-solvers.pdf
- GaloisSAT GPU-CPU Hybrid (2025) — https://arxiv.org/pdf/2603.28796

### Canonical Enumeration
- McKay Isomorph-Free Generation — https://users.cecs.anu.edu.au/~bdm/papers/orderly.pdf
- Burnside's Lemma — https://cp-algorithms.com/combinatorics/burnside.html
