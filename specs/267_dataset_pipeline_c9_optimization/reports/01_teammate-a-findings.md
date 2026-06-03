# Teammate A Findings: Primary Implementation Approaches for C9 Pipeline Optimization

**Task**: 267 - Optimize dataset pipeline for exhaustive c9 generation and beyond
**Role**: Teammate A (Primary Implementation Approaches)
**Date**: 2026-06-02

---

## Key Findings

### 1. Current Throughput Baseline

Based on completed dataset metadata:

| Level | Records | Effective Rate | Wall-Clock | Bottleneck |
|-------|---------|---------------|------------|------------|
| c6    | 7,412   | ~1,200 formulas/sec | ~6s | None |
| c7    | 49,865  | ~1,511 formulas/sec | ~33s | None |
| c8    | 252,900 | ~98 formulas/sec effective | ~43 min | 487 wall-clock timeouts @ 5s each |
| c9 (projected) | 1,593,620 | ~98 formulas/sec | ~4.5 hr | ~3,075 wall-clock timeouts |

The c8 effective throughput collapse (1,511 -> 98 formulas/sec) is entirely caused by the 487 wall-clock timeout formulas (0.19% of total), each consuming the full 5-second budget. The 252,413 normal formulas complete at ~0.6ms/formula (the same rate as c7).

From the c8 metadata: `{"adaptive_500": 218552, "fast_path_axiom": 8065, "structural_prefilter": 6562, "adaptive_timeout": 19234, "wallclock_timeout": 487}`. The wallclock timeouts represent formulas with temporal-modal feedback loops (documented in task 266 report).

### 2. Wall-Clock Timeout Reduction: Highest-Impact Single Change

The dominant bottleneck is the 5-second wall-clock limit per formula. The task 266 analysis established that hard-timeout formulas (temporal->temporal(box) structure) create exponential branching with no practical fuel ceiling. A 1-second limit captures the same information (they all timeout regardless) while saving 4 seconds per formula.

- c8: 487 formulas × 4s savings = 1,948s (32.5 min savings)
- c9: ~3,075 formulas × 4s savings = ~12,300s (205 min savings)
- Implementation: Change the `--wallclock-timeout` CLI parameter from 5000 to 1000ms
- Risk: Near-zero. From task 266 evidence, hard-timeout formulas require minutes of computation and do not recover in 1-5 seconds.

Projected c9 times:
- Status quo (5s wc-timeout, sequential): **4.5 hours**
- Reduce to 1s wc-timeout, sequential: **1.1 hours** (4.1x speedup)

### 3. Parallel Formula Labeling: Architecture Analysis

The `labelFormula` function in `DatasetGenerator.lean` is already partially parallelized via `Task.spawn` for wall-clock timeout enforcement (line 484). The current pattern:

```lean
let task := Task.spawn (fun _ => decideAutoAdaptive φ fc) .dedicated
-- ... poll with 1ms sleeps ...
let (result, fuelTier) ← IO.wait task
```

This spawns one dedicated thread per formula but only to implement the timeout mechanism, not for concurrent batch processing.

**Thread Safety Analysis for Batch Parallelism:**

Examining the code for shared mutable state:
- `decideAutoAdaptive`: Pure function (no IO.Ref, no shared state) - SAFE to run concurrently
- `extractCountermodelData`: Pure computation on formula - SAFE
- `computeMetrics`, `computeInterestingness`: Pure - SAFE
- `structuralPrefilter`, `isUnsatBotTemporal`: Pure - SAFE
- File I/O (`handle.putStrLn`, `handle.flush`): NOT thread-safe - requires serialization
- Running counters (`count`, `validCount`, etc.): NOT thread-safe - requires serialization or atomic ops

**Proposed Parallel Architecture:**

Process formulas in batches of N (where N = number of CPU cores, currently 24 on this machine):
```lean
-- For each batch of N formulas:
let tasks := batch.map fun φ => Task.spawn (fun _ => labelFormula φ fc timeout) .dedicated
let results ← tasks.mapM IO.wait
-- Write results serially (file I/O is not the bottleneck)
for result in results do
  writeRecordJSONL handle (labeledToRecord ...)
```

The key insight: IO writing is fast (~1ms per 2-5KB record) while computation is slow (0.6ms for normal, 1-5000ms for timeouts). Serializing writes does not create a bottleneck.

**Parallelism Effectiveness Analysis (24 cores):**

The wall-clock timeout formulas (0.19% of c9) fundamentally limit parallelism gains. In a batch of 24 formulas, the probability of at least one wall-clock timeout formula is approximately 4.5%. This means:
- 95.5% of batches complete in ~5ms (limited by slowest normal formula in batch)
- 4.5% of batches wait 1-5 seconds for the slow formula

| Strategy | c9 Total Time | Speedup |
|----------|-------------|---------|
| Status quo (sequential, 5s wc) | 4.5 hours | 1x |
| Reduce wc-timeout to 1s (sequential) | 1.1 hours | 4.1x |
| 24-core parallel + 1s wc-timeout | 55 min | 4.9x |
| Canonical dedup (4x) + 24-core + 1s | 14 min | 19.7x |

The parallel speedup alone (without wc-timeout reduction) is minimal (~1.1x) because wc-timeout batches dominate. Parallelism becomes effective only after wc-timeout reduction.

**Implementation Requirements for Batch Parallelism:**

The main loop in `DatasetExport.lean` (lines 908-946) currently processes formulas sequentially. To add batch parallelism:

1. Replace the `for φ in formulasToLabel do` sequential loop with batched processing
2. Spawn N tasks per batch, all pointing to pure computation (not IO)
3. Wait for all N tasks before writing
4. Serialize writes to the output file handle
5. Merge per-batch statistics after each batch

The `labelFormula` function itself already uses `Task.spawn` internally for timeout. The outer batch parallelism would nest inside this: each batch task spawns its own timeout task. This is safe in Lean 4's task system.

**Concern**: The existing per-formula `Task.spawn` for wall-clock timeout creates a `dedicated` thread. With 24 formulas in a batch, each spawning their own dedicated thread, we have 24-48 threads active simultaneously. This is manageable given 24 CPU cores but could hit OS thread limits at higher batch sizes.

### 4. Atom-Permutation Equivalence Classes

The enumerator generates all formulas using atoms `p`, `q`, `r` (from `defaultAtoms`). Many of these are structurally equivalent under atom renaming - a form of symmetry reduction that reduces the formula space by ~4x at c7.

**Measured Atom Distribution (from c7 dataset, 10,000 formula sample):**

| Distinct Atoms in Formula | Count | Fraction | Orbit Size | Equivalents |
|--------------------------|-------|---------|------------|-------------|
| 0 (bot only) | 190 | 1.9% | 1 | 1 |
| 1 atom (p, q, or r) | 3,448 | 34.5% | 3 | 3 |
| 2 atoms | 5,491 | 54.9% | ~4.5 (avg) | 3-6 |
| 3 atoms | 871 | 8.7% | 6 | 6 |

Weighted average orbit size: **4.05x**

This means ~75% of the 1,593,620 c9 formulas are redundant under atom permutation. The 1-atom formulas (box(p)->p, box(q)->q, box(r)->r) form groups of 3 where only one representative needs labeling. The 2-atom formulas form groups of up to 6.

**Canonicalization Approach:**

Assign atoms in order of first appearance in a left-to-right traversal. The canonical representative uses `p` for the first distinct atom encountered, `q` for the second, `r` for the third.

```lean
/-- Convert a formula to canonical atom naming.
    First distinct atom encountered -> p, second -> q, third -> r. -/
def canonicalizeAtoms (φ : Formula) : Formula :=
  let (canonical, _) := go φ {} 0
  canonical
where
  go : Formula → List (Atom × Atom) → Nat → Formula × List (Atom × Atom) × Nat
  | .bot, m, n => (.bot, m, n)
  | .atom a, m, n =>
    match m.find? (fun (k,_) => k == a) with
    | some (_, a') => (.atom a', m, n)
    | none =>
      let a' := Atom.mk_base (["p","q","r","s","t"].getD n "?")
      (.atom a', m ++ [(a, a')], n + 1)
  | .imp l r, m, n =>
    let (l', m', n') := go l m n
    let (r', m'', n'') := go r m' n'
    (.imp l' r', m'', n'')
  | .box a, m, n =>
    let (a', m', n') := go a m n
    (.box a', m', n')
  | .untl l r, m, n =>
    let (l', m', n') := go l m n
    let (r', m'', n'') := go r m' n'
    (.untl l' r', m'', n'')
  | .snce l r, m, n =>
    let (l', m', n') := go l m n
    let (r', m'', n'') := go r m' n'
    (.snce l' r', m'', n'')
```

**Integration into Pipeline:**

Two points of integration:
1. **At enumeration time**: Canonicalize each formula as it is generated, then deduplicate. This is the cleanest approach but requires modifying `enumExactHelper` or adding a canonicalization pass after enumeration.
2. **At labeling time**: Check if the canonical form has been labeled already, reuse the label if so.

The cleanest implementation adds a `canonicalizeAndDedup` step between `generateFormulas` and the labeling loop in `DatasetExport.lean:main`. This requires tracking which canonical forms have been processed.

**Impact by Level:**

| Level | Raw Formulas | After Canonical Dedup | Reduction |
|-------|-------------|----------------------|-----------|
| c6 | 7,412 | ~1,830 | 4.1x |
| c7 | 49,865 | ~12,321 | 4.0x |
| c8 | 252,900 | ~62,491 | 4.0x |
| c9 | 1,593,620 | ~393,782 | 4.0x |

**Data Fidelity Consideration**: Labeling only canonical representatives means the dataset must synthesize records for non-canonical formulas by applying the atom permutation to the canonical label. The label (valid/invalid/timeout) is preserved under atom permutation (semantic invariance). The proof trace and countermodel change structurally but can be derived by applying the permutation to the canonical result.

### 5. Incremental/Resumable Generation

The checkpoint system is already implemented. From `DatasetExport.lean` (lines 833-883):

- **Checkpoint file**: `{output}.checkpoint` contains one formula S-expression per line (the full ordered formula list)
- **Resume**: `--resume-from N --use-checkpoint` skips the first N formulas and appends to the existing output
- **Write-as-you-go**: Each record is written and flushed immediately after labeling (line 916-918)

The c8 dataset was completed via this mechanism: the first run processed 147,864 formulas, was interrupted, and the second run resumed from that point.

**Current Limitation**: The checkpoint stores the entire formula list upfront (written before labeling begins, line 879-883). For c9 with 1.6M formulas, this checkpoint file would be ~100MB (one S-expression per line, average ~65 bytes). This is manageable but could be optimized.

**Missing Feature: Periodic Save Points During Labeling**

The current system supports resume from a single fixed point (the start of a run). It does not support resume from an arbitrary mid-run position. Adding periodic save points every 10,000 formulas would:

1. Save the current formula index to a lightweight checkpoint
2. Allow precise resumption from any 10K boundary
3. Eliminate the need to reprocess formulas already labeled in a failed run

Implementation sketch:
```lean
-- Every 10,000 formulas, write a save-point file
if count % 10000 == 0 then do
  let savepointPath := outputPath.toString ++ s!".savepoint_{count}"
  IO.FS.writeFile ⟨savepointPath⟩ (toString count)
```

This is low-effort and would make the generation pipeline more robust for c9 runs that might take 1+ hours.

---

## Recommended Approach

For exhaustive c9 generation (prioritized by ROI):

**Phase 1: Quick wins (implement immediately)**

1. **Reduce wall-clock timeout from 5s to 1s**: Single CLI argument change. Saves 205+ minutes at c9 scale. No code changes needed, just update the default in `DatasetExport.lean:CLIArgs` or pass `--wallclock-timeout 1000`.

2. **Add periodic save-points**: ~20 lines of code. Makes c9 runs resilient to interruption without re-running from the beginning.

**Phase 2: Structural improvements (implement before c9 run)**

3. **Atom-permutation canonicalization**: Add a `canonicalizeAtoms` pass after enumeration and before labeling. This reduces the labeling work by 4x (from 1.6M to ~394K formulas). Records for non-canonical formulas are synthesized by applying the inverse permutation to the canonical result.

**Phase 3: Parallelism (implement if Phase 1+2 insufficient)**

4. **Batch parallel labeling**: Replace the sequential for-loop in `DatasetExport.lean:main` with a batch-parallel pattern. Effective speedup is ~4.9x combined with 1s wc-timeout reduction, yielding c9 generation in ~55 min with 24 cores.

**Combined projected c9 time** (all phases):
- With Phase 1+2+3 (reduce wc-timeout + canonical dedup + 24-core): ~14 min
- With Phase 1+2 only (reduce wc-timeout + canonical dedup): ~17 min
- With Phase 1 only (reduce wc-timeout): ~1.1 hours

---

## Evidence and Examples

### Evidence: Wall-Clock Timeout Distribution

From c8 dataset metadata:
```json
"decision_method_distribution": {
  "adaptive_500": 218552,
  "fast_path_axiom": 8065,
  "structural_prefilter": 6562,
  "adaptive_timeout": 19234,
  "wallclock_timeout": 487
}
```
The 487 wallclock_timeout formulas at 5s each = 40.6 minutes out of ~43 minutes total.

### Evidence: Atom Distribution Drives Canonicalization Factor

From sampling 10,000 c7 formulas:
- 34.5% use exactly 1 atom (orbit size 3: equivalent to 2 other atom choices)
- 54.9% use exactly 2 atoms (orbit size ~4.5: equivalent to ~3.5 other atom labelings)
- 8.7% use all 3 atoms (orbit size 6: equivalent to 5 other atom labelings)
- Weighted: 4.05x reduction factor

### Evidence: Task.spawn Already in Use

The wall-clock timeout mechanism in `DatasetGenerator.lean:484` demonstrates that Lean 4's Task system works correctly with the decision procedure. Extending this to batch parallelism is a natural continuation of the existing pattern.

### Evidence: Sequential Throughput Baseline

From c7 metadata: 49,865 formulas in 33 seconds = 1,511 formulas/sec. At this rate, c9 normal formulas would take 16 minutes. The wc-timeout overhead is the dominant bottleneck.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Wc-timeout reduction saves 4x time at c9 | **High** - Direct extrapolation from c8 data |
| Parallel batch labeling is thread-safe | **High** - Code analysis confirms no shared mutable state in compute paths |
| Atom canonicalization reduces by ~4x | **High** - Measured from c7 dataset atom distribution |
| Combined approach achieves ~14 min c9 | **Medium** - Projection assumes c9 wc-timeout rate similar to c8 (0.19%); actual rate may differ |
| Implementation complexity for batch parallel | **Medium** - Requires care around nested Task.spawn patterns |

---

## Implementation Notes

### Lean 4 Task System Constraints

- `Task.spawn (fun _ => pureComputation) .dedicated` is the correct pattern (already used in line 484)
- `IO.wait task` blocks the current thread until the task completes
- For batch of 24: spawn all 24 tasks first, then wait for all 24 in order
- The `.dedicated` option prevents task stealing and ensures predictable scheduling
- Nesting: each `labelFormula` call spawns its own timeout task; outer batch task spawns `labelFormula`; this creates 2-level task nesting which is supported

### Atom Canonicalization Integration Point

The best integration point is in `DatasetExport.lean:main` between the checkpoint write (line 883) and the labeling loop start (line 908):

```lean
-- After writing checkpoint, before labeling:
let formulas' := formulas'.map canonicalizeAtoms
let formulas' := formulas'.eraseDups  -- remove newly-identical canonical forms
```

This preserves the checkpoint format (non-canonical formulas are saved, then filtered) and requires no changes to `FormulaEnumerator.lean`.
