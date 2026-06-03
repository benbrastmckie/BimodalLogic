# Teammate C: Critic Findings — Task 267

**Role**: Critic — Gaps, Blind Spots, Assumptions Challenged

---

## Key Findings

### Finding 1: Exhaustive C9 Generation Has Questionable Marginal Value

The task assumes exhaustive enumeration of ~1.3M c9 formulas is needed. The data does not support this assumption.

**Structural diversity plateaus at c8**: C7 had 9 unique axiom combinations in valid proofs. C8 added exactly 1 new combination (`modal_4 + prop_s`). The marginal structural information gain from c9 is projected to be 0-2 new combinations. The proof height range also expanded by only 1 level (c7: 0-6, c8: 0-7).

**Label distribution is stable**: The valid formula fraction stabilizes at 8-9% from c6 onward:

| Level | Valid% | Invalid% | Timeout% |
|-------|--------|----------|----------|
| c5    | 6.5%   | 90.9%    | 2.6%     |
| c6    | 8.6%   | 88.4%    | 3.0%     |
| c7    | 8.4%   | 86.7%    | 4.8%     |
| c8    | 8.9%   | 83.3%    | 7.8%     |
| c9 sample | 8.7% | 86.5% | 4.8%   |

**Implication**: If the use case is ML training data, exhaustive c9 adds ~113K valid formulas (8.7% of 1.3M) while adding ~1.13M invalid formulas, worsening the existing class imbalance. C8 already provides 22,400 valid formulas. A stratified sample of c9 targeting the under-represented proof structures (high-height proofs, diverse axiom combinations) would likely be more useful than exhaustive enumeration.

**The task should state its use case explicitly**. If the goal is to maximize formula count for scaling experiments, exhaustive enumeration is justified. If the goal is training data quality, it is not.

---

### Finding 2: Atom-Permutation Reduction Factor Is 4.58x, Not 6x

**Theoretical claim**: S3 has 6 elements, so deduplication reduces the dataset by up to 6x.

**Measured reality**: Computed canonical forms under S3 for all c7 and a 50K sample of c8:
- C7 (49,865 total): 10,878 canonical forms = **4.58x reduction**
- C8 sample (50,000): 10,890 canonical forms = **4.59x reduction**

**Why it falls short of 6x**: Approximately 5% of formulas are symmetric (invariant under all permutations), forming equivalence classes of size 1. About 12% form size-3 classes (partially symmetric). Only ~56% achieve the maximum 6x reduction. The remaining ~27% form size-3 classes (not size-6) because the formula uses only 2 distinct atoms, limiting the effective permutation group.

**Practical consequence**: The reduction factor is stable and well-characterized: apply deduplication to expect ~4.6x reduction (not 6x). For c9 with ~1.3M formulas: deduplicated dataset would have approximately 283K canonical representatives, not the 217K implied by 6x reduction.

**The 4.58x figure is stable across c7 and c8**, suggesting it will hold for c9.

---

### Finding 3: The 487 Wallclock Timeouts Are a Single Homogeneous Category

Task 266 found 487 wallclock timeouts at c8. The task asks whether this pattern is resolved or whether new categories exist.

**All 487 wallclock timeouts share the same structural pattern**:
- Complexity: exactly 8 (all of them)
- Pattern key: `(modalDepth=1, temporalDepth=1, topOperator=Implication)`
- Left side: either `Until(atom, ...)` or `Since(atom, ...)` (240 Until, 247 Since)
- Right side: either `Until(...)`, `Since(...)`, or `Implication(..., ...)` (very rare)
- Label: all `timeout` (no countermodels; validity unknown)
- No countermodels found for any of them

**Example formulas**:
```
U(p, ⊥) → U(p, □⊥)
U(p, ⊥) → U(□p, q)
S(p, q) → S(□p, ⊥)
```

This is a single temporal-modal interaction pattern involving implications between Until/Since formulas where one side mixes modal operators (□) with temporal operators. The decision procedure runs full 5s before timing out — these are not fast adaptive timeouts.

**Open question not addressed by the task plan**: Are these 487 formulas genuinely independent theorems whose validity is unknown, or are they all invalid with countermodels the procedure cannot find? The task labels them "timeout" and moves on. For a logic dataset this is a problem: "timeout" is not a ground-truth label. A downstream ML model trained on these records learns nothing true about their validity.

**Recommendation**: Investigate whether the structural pre-filter (task 265) can be extended to handle this specific pattern. The pattern `U(atom, X) → U(Y, Z)` may have a decidable special case. If not, these 487 (and a proportionally larger count at c9) should be excluded from training data rather than labeled "timeout".

---

### Finding 4: Parallel Labeling Has an Unaddressed File-Write Concurrency Problem

The proposed optimization parallelizes `labelFormula` across N formulas simultaneously. The current implementation in `DatasetExport.lean` (main function, lines 908-946) does this:

```lean
let handle ← IO.FS.Handle.mk outputPath fileMode
for φ in formulasToLabel do
    let labeled ← labelFormula φ fc cliArgs.wallclockTimeoutMs
    writeRecordJSONL handle record
    handle.flush
```

**Thread safety**: `IO.monoMsNow` (monotonic clock read) is thread-safe at the POSIX level. `Task.spawn` with `.dedicated` creates an OS thread safely. The pure `decideAutoAdaptive` has no shared mutable state.

**Critical gap**: `writeRecordJSONL` + `handle.flush` writes to a single file handle. In a parallel implementation where N formulas are being labeled concurrently, their write operations will interleave on the handle. Lean 4's `IO.FS.Handle` does NOT provide thread-safe, atomic-line writes. Concurrent writes to the same handle will produce interleaved or garbled JSONL records.

**The proposed design must include a write serializer** (a sequential write queue or mutex-protected writer) before the file handle. Without this, parallel labeling will corrupt the output file. This is not mentioned in the optimization proposal.

**Secondary concern**: Memory pressure under high parallelism. The tableau construction for complex formulas allocates intermediate data structures. With c9's harder formulas and N concurrent threads each building a tableau, peak memory usage could be N times the single-formula peak. At complexity 9, some tableaux may be deep. This should be benchmarked before committing to a parallelism degree.

---

### Finding 5: Resumable Generation Has Silent Corruption Risks

The checkpoint mechanism has evidence of a real integrity failure from the c8 run:

- C8 checkpoint file (`.checkpoint.partial`): **252,893 lines**
- C8 final JSONL: **252,900 records**
- Gap: **7 records**

The checkpoint was written during an aborted earlier run. The successful final run apparently regenerated from scratch (not from checkpoint), producing a different formula count. This means:

1. Enumeration is **not perfectly deterministic** across runs, OR
2. The checkpoint was overwritten at a different point during the run

**Resume mechanism risk (from source code analysis)**:
- The user must manually specify `--resume-from N`
- There is NO automated verification that N matches the actual record count in the existing JSONL file
- If N is too small (duplicate formulas already labeled): duplicate JSONL records are silently appended
- If N is too large (some formulas skipped): a gap in coverage that produces no error

**Recommendation**: The resume mechanism should automatically count existing JSONL lines and cross-check against `--resume-from N` before proceeding. A mismatch should abort with an error, not silently proceed.

**JSONL corruption on crash**: The code flushes after every record (`handle.flush`), which prevents partial-record corruption within a single write. However, if the process is killed between two `handle.putStrLn` calls in a parallel implementation (where multiple records are queued), some records may be half-written. The current sequential implementation is relatively safe; the parallel implementation requires more careful crash safety design.

---

## Gaps Identified

1. **No stated use case for exhaustive c9 enumeration**. The task states "exhaustive c9 generation" as a goal without explaining what downstream use case requires 1.3M formulas rather than a stratified sample. The optimizations are motivated by performance rather than data necessity.

2. **Timeout records are included in training data without a principled justification**. At c8, 7.8% of records are labeled "timeout" with no ground-truth validity determination. At c9 this may reach 10-12%. An ML model trained on timeout records learns that certain formula structures produce "timeout", which is a property of the decision procedure, not of the logic.

3. **No deduplication of equivalent-under-negation formulas**. The permutation deduplication targets atom relabeling. But `φ → ψ` and `¬ψ → ¬φ` (contrapositive) are logically equivalent. Such reductions are not discussed and could provide additional redundancy elimination in the valid/invalid split.

4. **Parallelism degree is unspecified**. The optimization proposes "parallel labeling" but does not specify N (number of concurrent workers), whether N is auto-tuned to CPU count, or whether memory budgets are enforced.

5. **Extended pre-filter scope is underspecified**. Task 265 extended the pre-filter to handle `U(⊥, X)` patterns. Task 267 proposes further extension. But the 487 wallclock timeouts all involve `U(atom, X) → U(Y, Z)` or `S(atom, X) → S(Y, Z)` — neither is a simple bot-antecedent pattern. Whether these are provable by structural inspection alone is not analyzed in the task description.

---

## Assumptions Challenged

**Assumption: "We need all ~1.2M c9 formulas"**
- CHALLENGED: The data shows diminishing structural returns at each complexity level. A stratified sample of c9 targeting the ~8.7% valid formulas plus a representative invalid sample would likely provide equivalent or better training signal. The c9 sample already shows the distribution is identical to c8. Exhaustive enumeration appears motivated by completeness for its own sake.

**Assumption: "Atom-permutation deduplication achieves ~6x reduction"**
- CHALLENGED: Measured at 4.58-4.59x, not 6x. The 6x figure assumes no symmetric formulas, but ~5% are fully symmetric (single-element orbits) and ~12% have partial symmetry. Post-deduplication c9 will have ~283K canonical representatives, not ~217K.

**Assumption: "Parallelism is safe because decideAutoAdaptive is pure"**
- CHALLENGED: Purity of the decision procedure does not make the I/O layer safe. The file write is not thread-safe in the proposed concurrent design. A write serializer is required.

**Assumption: "Wallclock timeouts are a resolved edge case"**
- CHALLENGED: The 487 wallclock timeouts at c8 are all unresolved — they are labeled "timeout" and included in the dataset, but their true validity is unknown. At c9, the same pattern will produce proportionally more such records. These are not a fixed-count residual; they will grow with complexity.

**Assumption: "Resumable generation solves the crash problem"**
- PARTIALLY CHALLENGED: The mechanism works, but the c8 evidence shows checkpoint-JSONL count mismatch occurred in practice. The manual `--resume-from N` parameter has no safety check, creating silent duplicate/gap risk.

---

## Confidence Levels

| Finding | Confidence | Evidence Basis |
|---------|------------|----------------|
| Atom-permutation 4.58x actual (not 6x) | HIGH | Measured on all 49,865 c7 formulas and 50K c8 sample |
| Wallclock timeouts are a single category | HIGH | 487/487 share identical pattern key |
| File-write concurrency unsafety | HIGH | Source code analysis of DatasetExport.lean |
| Checkpoint-JSONL mismatch (7 record gap) | HIGH | Direct file measurement |
| Exhaustive c9 has low marginal structural value | MEDIUM | Inferred from c7->c8 axiom combination trend |
| Timeout records are problematic for training | MEDIUM | Logical argument; depends on use case |
| Extended pre-filter cannot cover the 487 pattern | LOW | No formal decidability analysis; further research needed |

---

## Quantitative Reference

| Metric | C7 | C8 | C9 (estimated) |
|--------|----|----|----------------|
| Total formulas | 49,865 | 252,900 | ~1,283,000 |
| Valid count | 4,198 (8.4%) | 22,400 (8.9%) | ~112K (8.7%) |
| Timeout count | 2,410 (4.8%) | 19,721 (7.8%) | ~100-150K |
| Wallclock timeouts | N/A | 487 (0.19%) | ~2,500-6,400 |
| Unique axiom combinations in valid | 9 | 10 | ~10-11 |
| Dedup reduction factor | 4.58x | 4.59x | ~4.59x |
| Single-thread generation time | ~63 min | ~64 min | ~10h |
| 8-core parallel time | ~8 min | ~8 min | ~1.2h |
