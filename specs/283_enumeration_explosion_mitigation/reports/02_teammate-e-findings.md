# Teammate E Findings: Parallelization and GPU Offloading

- **Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
- **Angle**: CPU parallelism and GPU offloading feasibility
- **Date**: 2026-06-04

## 1. Lean 4 Task Parallelism Primitives

### Key Findings

Lean 4 (v4.27.0-rc1) provides solid task-parallel primitives:

| Primitive | Purpose | Available |
|-----------|---------|-----------|
| `IO.asTask` | Spawn IO action on thread pool | Yes |
| `Task.spawn` | Spawn pure/IO computation (used in this codebase already) | Yes |
| `IO.mapTasks` | Collect results from multiple tasks | Yes |
| `IO.hasFinished` | Non-blocking task completion check | Yes |
| `IO.wait` | Blocking wait for task result | Yes |
| `IO.Mutex` | Thread-safe shared state | Yes |
| `IO.Ref` | Mutable reference (busy-wait, not suitable for contention) | Yes |

The Lean runtime maintains a **thread pool** sized by `LEAN_NUM_THREADS` (or logical processor count). This project already uses `Task.spawn .dedicated` for prover timeouts in `DatasetGenerator.lean:582`, confirming the runtime works correctly with parallel tasks.

**Critical caveat**: Within tasks, `IO.wait` does NOT register a dependency with the scheduler and can deadlock if the pool is saturated. Use `IO.mapTasks` or `IO.mapTask` instead for intra-task coordination.

**Confidence**: HIGH — primitives are well-documented and already used in this codebase.

### Evidence

From `DatasetGenerator.lean:582`:
```lean
let task := Task.spawn (fun _ => decideAutoAdaptive φ fc) .dedicated
```
This proves `Task.spawn` works in this project with the current Lean version.

---

## 2. Two-Phase Parallel Enumeration (CPU) — RECOMMENDED

### Approach

The current `enumExactHelper` threads a cache through a sequential `foldl` over partitions. But levels 1..(N-1) complete in <1s even at c8. The bottleneck is the 21 cross-products at level N. This enables a clean two-phase design:

**Phase 1 (Sequential, fast)**: Pre-compute all sub-levels 1..(N-1) into a read-only cache. This populates every `(sizeBudget, modalBudget, temporalBudget)` triple that any partition at level N will need. The cache becomes immutable after this phase.

**Phase 2 (Parallel)**: For each of the 21 cross-products (7 partitions × 3 binary operators), spawn a `Task` that:
1. Reads the immutable cache (no contention — Lean's RC sharing is thread-safe for reads)
2. Computes its cross-product independently
3. Returns its `Array Formula` result

Then merge all results.

### Sketch in Lean 4

```lean
-- Phase 1: Build read-only cache (sequential, <1s)
let cache := buildCacheUpTo atoms modalBudget temporalBudget (sizeBudget - 1)

-- Phase 2: Parallel cross-products
let partitions := (List.range childBudget).filterMap fun i =>
  let l := i + 1; let r := childBudget - l
  if r < 1 then none else some (l, r)

let tasks ← partitions.mapM fun (l, r) => IO.asTask do
  let lefts := cache.get (l, modalBudget, temporalBudget)
  let rights := cache.get (r, modalBudget, temporalBudget)
  let mut acc : Array Formula := #[]
  for lf in lefts do
    for rf in rights do
      acc := acc.push (Formula.imp lf rf)
  -- Similar for untl/snce with temporal cache entries
  return acc

-- Collect results
let results ← tasks.mapM IO.wait
let binaryFormulas := results.foldl (· ++ ·) #[]
```

### Speedup Estimate (Amdahl's Law)

At level 8:
- **Sequential phase** (levels 1-7): <1 second
- **Parallel phase** (21 cross-products at level 8): ~99.98% of total runtime

With the parallel fraction P ≈ 0.9998:
- 4 cores: `1 / (0.0002 + 0.9998/4)` ≈ **4.0x** speedup
- 8 cores: `1 / (0.0002 + 0.9998/8)` ≈ **7.9x** speedup
- 16 cores: `1 / (0.0002 + 0.9998/16)` ≈ **15.7x** speedup

The sequential fraction is negligible, so speedup scales nearly linearly with cores.

However, the 21 cross-products are **not equally sized**. The (1,6)/(6,1) partitions produce ~159K formulas each while (3,3) produces ~17K. With 21 tasks on 8 cores, load imbalance limits practical speedup to **5-6x on 8 cores** (the longest partition determines wall-clock).

**Confidence**: HIGH — the two-phase decomposition is clean, the primitives exist, and the project already uses `Task.spawn`.

---

## 3. Cache Sharing Problem — Solved by Pre-computation

### Analysis

The current sequential `foldl` threads a mutable `EnumCache` through each partition. This is the main obstacle to parallelization. However, the cache entries that each partition *reads* are all at levels < N, which are fully computed before level N begins. The cache entries that each partition *writes* are at level N — but these are the output formulas themselves, not input to other partitions at the same level.

**Key insight**: At level N, no partition's output is another partition's input. Each partition independently reads from levels 1..(N-1) and produces level-N formulas. The cache sharing is an artifact of the sequential algorithm, not a true data dependency.

**Solution**: Pre-compute the read-only cache in Phase 1. No `IO.Mutex` needed. No concurrent writes. Lean's reference-counted values are safe for concurrent reads (the RC increment/decrement is atomic).

**Confidence**: HIGH — verified by examining the data flow in `enumExactHelper` lines 184-204.

---

## 4. Process-Level Parallelism (Shell-Based)

### Approach

Instead of in-Lean parallelism, the dataset generation script could:
1. Run separate Lean processes for different complexity levels
2. Run separate processes for different partition ranges at the same level
3. Merge JSONL outputs after all complete

### Assessment

| Aspect | In-Lean `Task` | Shell-level processes |
|--------|-----------------|---------------------|
| Startup cost | ~0 (thread pool) | ~2-5s per Lean process |
| Memory sharing | Cache shared via RC | Each process rebuilds cache |
| Implementation | Moderate (refactor enumExactHelper) | Easy (script changes only) |
| Granularity | Per-partition | Per-complexity-level |
| Best for | Level 8 cross-products | Running c4-c7 in parallel with c8 |

**Shell parallelism is already practical** for running different complexity levels in parallel (c4, c5, c6, c7 all complete in <10 min total). But it doesn't help with the c8 single-level bottleneck since each process would need to rebuild the cache for levels 1-7.

For **per-partition parallelism at level 8**, you'd need to serialize the cache to disk after Phase 1 and load it in each child process — feasible but the serialization/deserialization overhead for ~300K Formula ASTs may negate the benefit.

**Confidence**: MEDIUM — shell-level parallelism for different complexity levels is trivial and should be done regardless. Per-partition process parallelism has overhead concerns.

---

## 5. GPU Offloading for Enumeration — NOT PRACTICAL

### Analysis

Formula enumeration is **tree-structured AST construction**, not matrix multiplication or data-parallel computation. Each formula is a recursive algebraic data type:

```lean
inductive Formula where
  | atom : Atom → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | untl : Formula → Formula → Formula
  | snce : Formula → Formula → Formula
```

GPU kernels require:
- Uniform data representation (fixed-size arrays/matrices)
- Minimal branching (SIMT execution model)
- High arithmetic intensity
- Large batch sizes of identical operations

Formula enumeration has:
- Recursive, variable-size tree structures
- Heavy branching (operator-dependent construction)
- Memory-bound operations (pointer chasing, allocation)
- No arithmetic to speak of

**No Lean 4 CUDA bindings exist** as of 2026. The FFI supports C ABI but not compound struct passing by value, and Formula's recursive structure would need a complete serialization layer. The engineering effort would be enormous (months) for negligible benefit.

**Confidence**: HIGH — fundamental mismatch between GPU execution model and the workload.

---

## 6. GPU for Semantic Deduplication — CONDITIONALLY VIABLE

### Analysis

The proposed semantic deduplication step (evaluating formulas on small Kripke models) IS potentially GPU-friendly:

- **Fixed evaluation structure**: Each formula is evaluated against a fixed set of truth assignments
- **No allocation**: Evaluation produces a boolean vector (the "fingerprint")
- **Embarrassingly parallel**: Each formula is independent
- **Batch-friendly**: ~500K formulas to evaluate at c8

For a small model with 2 worlds, 2 time points, 3 atoms = 2^(3×2×2) = 4096 assignments per formula. With ~500K formulas, that's 500K × 4096 = ~2 billion evaluations — solidly in GPU territory.

### Implementation Path

Rather than GPU from Lean directly, the practical path would be:
1. Export formulas as a serialized representation (S-expressions or integer-encoded ASTs)
2. Run a C++/CUDA program for batch evaluation
3. Import fingerprints back and dedup

This avoids the Lean FFI complexity entirely.

**Confidence**: MEDIUM — viable if semantic deduplication is adopted, but the external-process path adds pipeline complexity. May not be worth it if the formula count at c8 is already manageable after Array optimization (estimated ~100-300K final formulas).

---

## 7. Parallel SAT Solver Practices — Relevant Precedent

### Findings from SAT Competition 2024-2025

Modern parallel SAT solvers demonstrate relevant patterns:

- **Portfolio parallelism** (dominant approach): Run multiple independent solver configurations in parallel, share learned clauses. The winner of SAT Competition 2024 Parallel track was **PL-PRS-BVA-KISSAT** ("painless-2"), a portfolio.
- **MallobSat**: Scales to **3,072 cores** with consistent improvement, demonstrating that clause-sharing parallelism works at massive scale.
- **GaloisSAT** (2025): Hybrid GPU-CPU solver using differentiable SAT solving on GPU for initial search, then CDCL on CPU. This is the first competitive GPU-based approach.

**Relevance to enumeration**: SAT solvers parallelize the *search* (which has irregular workload distribution similar to our partitions). The key pattern is **work-stealing**: tasks that finish early pick up work from tasks that are still running. This addresses the load imbalance problem with unequally-sized partitions.

However, SAT solving is fundamentally different from enumeration — SAT solvers explore a search space with pruning, while enumeration must produce ALL elements. The parallelism patterns transfer, but the scaling characteristics differ.

**Confidence**: MEDIUM — useful design patterns but not directly applicable algorithms.

---

## 8. Cost-Benefit Analysis

### Comparison of Parallelism Approaches

| Approach | Speedup | Effort | Maintenance | Risk |
|----------|---------|--------|-------------|------|
| **Array optimization (baseline)** | 5-15x | 2-3h | Minimal | Low |
| **Two-phase + Task.spawn** | 4-8x additional | 4-6h | Moderate | Low |
| **Shell-level (cross-level)** | 2-4x for pipeline | 1h | Minimal | Very low |
| **Shell-level (per-partition)** | 3-5x at level N | 4-6h | Moderate | Medium |
| **GPU enumeration** | N/A | Months | High | Very high |
| **GPU semantic dedup** | 10-50x for dedup step | 1-2 weeks | High | Medium |

### Recommended Priority

1. **Array optimization first** (5-15x, 2-3h) — this alone may make c8 feasible in <30 min
2. **Shell-level cross-level parallelism** (trivial, 1h) — run c4-c7 concurrently while c8 runs
3. **Two-phase Task.spawn** (4-8x, 4-6h) — apply AFTER Array optimization if c8 still takes >10 min
4. **GPU for semantic dedup** — only if semantic dedup is adopted AND formula count exceeds 1M

### Combined Speedup Estimate

Array alone: c8 from ~10-15h → **40-120 min**
Array + Task.spawn (8 cores): **5-15 min**
Array + Task.spawn + structural pruning: **3-8 min**

**Confidence**: MEDIUM-HIGH for the estimates. The Array optimization is well-understood; the parallelism speedup depends on actual load distribution across partitions.

---

## 9. Key Risks and Gotchas

1. **Lean thread pool sizing**: Default is `num_logical_processors`. On a 16-core machine with hyperthreading, this spawns 32 threads. For compute-bound work (no IO waiting), set `LEAN_NUM_THREADS` to physical core count.

2. **Memory scaling**: With 8 parallel partitions each materializing ~100-200K formulas, peak memory could reach 8× the single-partition peak. At c8 with Array optimization, each partition's output is ~10-20 MB, so 8 partitions = ~160 MB peak — manageable.

3. **Lean's RC semantics under parallelism**: Lean's reference counting uses atomic increments/decrements, which is safe for concurrent reads. But if two tasks share a Formula value and both decrement its refcount, the deallocation happens correctly (last decrement frees). This is well-tested in Lean's runtime.

4. **Task priority and scheduling**: Use `Task.Priority.default` not `.dedicated` for cross-product tasks. `.dedicated` spawns a new thread per task, which would create 21 OS threads. The thread pool handles scheduling better.

5. **Result merging is sequential**: After all tasks complete, merging 21 arrays into one is O(total_formulas). This is fast (~ms) but must be accounted for.

## References

- [Lean 4 Tasks and Threads documentation](https://lean-lang.org/doc/reference/latest/IO/Tasks-and-Threads/)
- [Lean 4 IO.lean source](https://github.com/leanprover/lean4/blob/master/src/Init/System/IO.lean)
- [Lean 4 Mutable References](https://lean-lang.org/doc/reference/latest/IO/Mutable-References/)
- [Lean 4 structured concurrency (Zulip)](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/structured.20concurrency.html)
- [Additional concurrency primitives (Issue #1280)](https://github.com/leanprover/lean4/issues/1280)
- [CaDiCaL/Kissat SAT Competition 2025 solvers](https://cca.informatik.uni-freiburg.de/papers/BiereFallerFleuryFroleyksPollitt-SAT-Competition-2025-solvers.pdf)
- [GaloisSAT: GPU-CPU hybrid SAT solver](https://arxiv.org/pdf/2603.28796)
- [Lean 4 FFI documentation](https://lean-lang.org/doc/reference/latest/Run-Time-Code/Foreign-Function-Interface/)
