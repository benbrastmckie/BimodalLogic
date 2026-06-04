# Implementation Plan: Enumeration Explosion Mitigation

- **Task**: 283 - Mitigate cross-product explosion in exhaustive formula enumeration at complexity >= 8
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None
- **Research Inputs**: reports/02_team-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The exhaustive formula enumerator in `FormulaEnumerator.lean` hits a combinatorial wall at complexity 8 due to `List.flatMap` cross-product materialization combined with O(n) `List.append` on cached (RC >= 2) lists. Team research (5 teammates) established that (1) Array conversion yields 4-8x enumeration speedup, (2) the `passesFilter` streaming optimization is a no-op at c8, and (3) prover labeling (~30h) dominates enumeration (~30min with Array), making formula count reduction via inline canonicalization the highest wall-clock ROI. This plan covers three implementation waves: foundational Array conversion with crash resilience (Wave 1), formula count reduction via canonicalization integration and structural pruning (Wave 2), and parallelism with pipeline overlap (Wave 3). Definition of done: c8 exhaustive enumeration completes in under 15 minutes on 8 cores with incremental JSONL output and checkpoint resume.

### Research Integration

- **02_team-research.md** (5-teammate synthesis, 2026-06-04): Corrected Array speedup to 4-8x (not 5-20x), identified `passesFilter` as no-op at c8, established prover labeling as binding constraint, validated two-phase parallelism design, identified `deduplicateCanonical` O(n^2) append bug.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "Tier 2: Optimized Exhaustive (c8)" milestone from the research synthesis. It is not directly referenced in the current ROADMAP.md (which focuses on completeness and publication), but it supports the dataset generation infrastructure needed for neural theorem prover training data at higher complexity levels.

## Goals & Non-Goals

**Goals**:
- Convert `EnumCache` and all enumeration internals from `List Formula` to `Array Formula`
- Add incremental JSONL output with per-level checkpointing and crash resume
- Fix `deduplicateCanonical` O(n^2) append anti-pattern
- Integrate atom-canonicalization deduplication into the enumeration loop to achieve ~4.58x formula count reduction
- Add structural pruning (identity implication, ex falso, S5 idempotence) during cross-product construction
- Implement two-phase parallel cross-products for level-N enumeration
- Add pipeline overlap so labeling can begin while enumeration continues

**Non-Goals**:
- Backward generation from BX axioms (Phase 4 in research -- separate future task for c9+)
- GPU offloading (not practical for tree-structured AST construction)
- Streaming `passesFilter` during cross-product (no-op at c8 -- zero formulas rejected)
- Changes to the prover/labeling infrastructure in `DatasetGenerator.lean` (beyond pipeline overlap entry point)
- Optimizations for complexity levels below 8 (already fast enough)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Array conversion breaks downstream consumers expecting `List Formula` | H | M | Phase 1 maintains `List` API wrappers; convert internal representation only, expose `.toList` at boundaries |
| Inline canonicalization changes enumeration semantics (different formula set) | H | L | Verify dedup count matches post-hoc `deduplicateCanonical` on the same input; regression test at c5-c7 |
| Parallel task spawning introduces non-determinism in output order | M | H | Sort final results by canonical hash before JSONL output; deterministic merge |
| Two-phase cache design underestimates memory for read-only sub-level cache at c8 | M | M | Monitor memory usage; fall back to sequential if >16GB RSS; c7 cache is ~200MB extrapolated |
| `lake build` time increases due to new Array-heavy code | L | M | Incremental builds; keep changes within existing module boundaries |
| Checkpoint/resume logic adds complexity that delays core optimization | M | L | Keep checkpoint format simple (completed levels + cache serialization); defer cache serialization to Phase 1 extension if needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Array-Based Accumulation [NOT STARTED]

**Goal**: Convert the entire enumeration pipeline from `List Formula` to `Array Formula`, eliminating O(n) append overhead on RC >= 2 cached lists.

**Tasks**:
- [ ] Change `EnumCache` type alias from `Std.HashMap (Nat x Nat x Nat) (List Formula)` to `Std.HashMap (Nat x Nat x Nat) (Array Formula)` in `FormulaEnumerator.lean:112`
- [ ] Rewrite `enumExactHelper` (lines 127-208) to use `Array.push` accumulation with `Array.reserve` pre-allocation for cross-product sizes
- [ ] Convert base case (line 137) from `Formula.bot :: atoms.map Formula.atom` to `#[Formula.bot] ++ atoms.map Formula.atom |>.toArray`
- [ ] Replace all `lefts.flatMap fun l => rights.map fun r =>` patterns (lines 194, 199-200) with nested `for l in lefts do / for r in rights do / acc := acc.push` loops
- [ ] Replace `accList ++ imps ++ temporalBinaries` (line 203) with `Array.append` or direct push into shared accumulator
- [ ] Convert unary operator mappings (lines 145, 157, 160, 170, 178) from `children.map Formula.box` to `children.map Formula.box` (Array.map is already O(n) with unique RC)
- [ ] Update `enumExactBudget` (line 643+) to use Array internally
- [ ] Update `enumHelper` (line 221) to use Array accumulation instead of `formulas ++ exact`
- [ ] Update `enumerateUpToDepth` (line 242) return type or add `.toList` conversion at boundary
- [ ] Update `enumerateWithProgress` (line 1363) to accumulate into Array and convert at output
- [ ] Update `enumerateStratifiedWithProgress` (line 1407) similarly
- [ ] Add `.toList` conversion at the API boundaries consumed by `DatasetExport.lean` and `DatasetGenerator.lean` to preserve backward compatibility
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify compilation
- [ ] Run existing c5 and c7 enumeration to verify formula counts match pre-change values

**Timing**: 3-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- Core enumeration functions (EnumCache type, enumExactHelper, enumExactBudget, enumHelper, enumerateUpToDepth, enumerateWithProgress, enumerateStratifiedWithProgress)

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors
- c5 enumeration produces identical formula count to pre-change baseline
- c7 enumeration produces identical formula count to pre-change baseline

---

### Phase 2: Incremental Output and Checkpoint Resume [NOT STARTED]

**Goal**: Add per-level JSONL flushing and checkpoint resume so that a crash at c8 level 7 does not lose hours of work.

**Tasks**:
- [ ] Define a `CheckpointState` structure: `{ completedLevels : Nat, formulaCount : Nat, outputPath : System.FilePath }`
- [ ] Add a `--checkpoint-dir` option to `EnumParams` (or extend existing config) for storing checkpoint metadata
- [ ] Modify `enumerateWithProgress` to write each level's formulas to a JSONL file (one formula per line, JSON-encoded) immediately after computation, flushing `IO.FS.Handle` after each level
- [ ] Write a checkpoint marker file after each level completes (level number + cumulative formula count + elapsed time)
- [ ] Add resume logic: on startup, check for existing checkpoint; if found, skip completed levels by re-reading their JSONL output and reconstructing the cache from the checkpoint
- [ ] Add progress metrics: formulas/sec, partition timing per level, ETA estimation based on extrapolation from completed levels
- [ ] Add a `--resume` flag (or automatic detection) to `enumerateWithProgress`
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator` to verify compilation

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- `EnumParams`, `enumerateWithProgress`, new checkpoint IO functions

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors
- Enumeration at c5 produces a JSONL file with correct formula count
- Interrupting and resuming enumeration at c5 produces the same final output as uninterrupted run

---

### Phase 3: Inline Canonicalization and Dedup Fix [NOT STARTED]

**Goal**: Move atom-canonicalization deduplication into the enumeration loop to achieve ~4.58x formula count reduction before formulas leave the enumerator, and fix the O(n^2) append bug in `deduplicateCanonical`.

**Tasks**:
- [ ] Fix `deduplicateCanonical` in `AtomCanonicalization.lean:132-139`: replace `deduped ++ [canonical]` with Array-based accumulation (`acc.push canonical`) to eliminate O(n^2) append
- [ ] Add a `canonicalDedup : Bool` flag to `EnumConfig` (default `false` for backward compatibility, `true` for c8+ runs)
- [ ] In `enumExactHelper`, after computing each batch of cross-product formulas (imps, untls, snces), canonicalize each formula and check membership in a `Std.HashSet Formula` before pushing to the accumulator
- [ ] Thread a `Std.HashSet Formula` (the "seen canonical set") through the enumeration alongside the `EnumCache`, or maintain it as a per-level local set that is merged after each level
- [ ] Ensure the canonical form is what gets stored in the cache and output (so downstream dedup in `DatasetExport.lean` becomes a no-op)
- [ ] Update `enumerateWithProgress` to report both raw and deduplicated counts per level for monitoring
- [ ] Verify that inline dedup at c7 produces the same canonical formula set as the existing post-hoc `deduplicateCanonical` path (77K formulas from 306K raw, per research)
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator` and `lake build Bimodal.Automation.AtomCanonicalization`

**Timing**: 4-5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/AtomCanonicalization.lean` -- Fix O(n^2) `deduplicateCanonical`, potentially add `canonicalizeAndDedup` helper
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- Integrate canonicalization into `enumExactHelper` and `enumerateWithProgress`, add `canonicalDedup` config flag

**Verification**:
- `lake build` for both modules compiles without errors
- c7 inline-dedup formula count matches post-hoc dedup count (77K +/- 1%)
- c5 inline-dedup formula count matches post-hoc dedup count exactly
- `deduplicateCanonical` standalone performance improved (no O(n^2) on large inputs)

---

### Phase 4: Structural Pruning in Cross-Product [NOT STARTED]

**Goal**: Add lightweight structural checks during cross-product construction to prune trivially redundant formulas, achieving ~10-20% additional reduction beyond canonicalization.

**Tasks**:
- [ ] Define a `structurallyTrivial` predicate that rejects:
  - Identity implication: `p -> p` (any formula implying itself)
  - Ex falso patterns: `bot -> phi` (already covered by the `ex_falso` axiom)
  - Double negation redundancy: `(phi -> bot) -> bot` when `phi` is already in the enumeration
  - S5 box idempotence: `box (box phi)` equivalent to `box phi` under S5
- [ ] Integrate `structurallyTrivial` check into the cross-product loop in `enumExactHelper`, skipping formulas that match before pushing to accumulator
- [ ] For temporal operators: reject `untl bot phi` when `phi` already enumerated as `next phi` (semantic equivalence under discrete frames)
- [ ] Measure the pruning rate at c5 and c7 to calibrate expected c8 reduction
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator`

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- Add `structurallyTrivial` predicate, integrate into cross-product loops

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors
- All pruned formulas are verified to be semantically equivalent to retained formulas (spot-check at c5)
- Pruning rate measured and logged at c5 and c7

---

### Phase 5: Two-Phase Parallel Enumeration and Pipeline Overlap [NOT STARTED]

**Goal**: Parallelize level-N cross-product computation across multiple cores and enable labeling to begin while enumeration of later levels continues.

**Tasks**:
- [ ] Implement the two-phase design from Teammate E's research:
  - Phase A (sequential, <1s): Pre-compute all sub-levels 1..(N-1) into a read-only `EnumCache`
  - Phase B (parallel): For each of the ~21 binary partitions of level N (leftSize + rightSize = N-1, leftSize >= 1, rightSize >= 1), spawn an independent `IO.asTask` that reads the immutable cache and produces an `Array Formula` of cross-products for that partition
- [ ] Define a `ParallelEnumConfig` structure with `numWorkers : Nat` (default 8), `parallelThreshold : Nat` (minimum level to parallelize, default 7)
- [ ] Implement partition-level task spawning: for level N, create `Task (Array Formula)` for each `(leftSize, rightSize)` pair, using `IO.asTask (prio := .dedicated)` for CPU-bound work
- [ ] Collect results from all tasks via `Task.get` and merge into a single sorted Array
- [ ] Apply canonicalization dedup to the merged result (since parallel tasks produce independent segments, dedup must happen after merge)
- [ ] Add pipeline overlap entry point: expose a channel or callback that emits completed levels for downstream labeling consumption
  - Define a `LevelComplete` structure: `{ level : Nat, formulas : Array Formula, elapsed : Nat }`
  - After each level is enumerated and deduped, invoke the callback before proceeding to the next level
  - This allows `DatasetGenerator` to begin labeling level-K formulas while level-(K+1) enumeration runs
- [ ] Handle partition size imbalance: the (1, N-2) partition produces far fewer formulas than the (N/2, N/2-1) partition; log per-partition timing for profiling
- [ ] Add deterministic output ordering: sort merged results by a canonical hash to ensure reproducibility regardless of task scheduling order
- [ ] Run `lake build Bimodal.Automation.FormulaEnumerator`
- [ ] Benchmark: run c7 parallel vs sequential, measure speedup factor

**Timing**: 5 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- New parallel enumeration functions, `ParallelEnumConfig`, pipeline overlap callback interface, partition task spawning

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors
- Parallel c7 enumeration produces identical formula set to sequential c7 (after sorting)
- Parallel c7 shows measurable speedup (target: 3-5x on 8 cores)
- Pipeline overlap callback fires correctly for each completed level
- No data races: parallel tasks read immutable cache only

---

## Testing & Validation

- [ ] **Regression**: c5 exhaustive enumeration formula count matches pre-change value exactly
- [ ] **Regression**: c7 exhaustive enumeration formula count matches pre-change value (before inline dedup) or matches post-dedup value (after inline dedup phase)
- [ ] **Correctness**: Inline canonicalization produces same canonical set as post-hoc `deduplicateCanonical`
- [ ] **Checkpoint**: Interrupt c5 enumeration mid-run, resume, verify final output matches uninterrupted run
- [ ] **Parallelism**: Parallel and sequential c7 produce identical sorted output
- [ ] **Performance**: c7 Array-based enumeration < 5 seconds (from ~1s baseline, verifying no regression)
- [ ] **Performance**: c8 full pipeline (Array + dedup + parallel) target < 15 minutes on 8 cores
- [ ] **Build**: `lake build` succeeds with zero errors across all modified modules
- [ ] **Structural pruning**: No valid theorem is pruned (spot-check the pruning predicate against known valid c5 formulas)

## Artifacts & Outputs

- `specs/283_enumeration_explosion_mitigation/plans/01_implementation-plan.md` (this file)
- `specs/283_enumeration_explosion_mitigation/summaries/01_execution-summary.md` (post-implementation)
- Modified: `Theories/Bimodal/Automation/FormulaEnumerator.lean`
- Modified: `Theories/Bimodal/Automation/AtomCanonicalization.lean`

## Rollback/Contingency

All changes are confined to two files (`FormulaEnumerator.lean` and `AtomCanonicalization.lean`). Git history provides clean rollback via `git checkout HEAD~N -- Theories/Bimodal/Automation/FormulaEnumerator.lean Theories/Bimodal/Automation/AtomCanonicalization.lean`. Each phase produces a separate commit, so partial rollback (e.g., reverting parallelism but keeping Array conversion) is straightforward. The `canonicalDedup` flag defaults to `false`, so existing workflows are unaffected until explicitly opted in. The JSONL checkpoint files are written to a configurable directory and do not affect the source tree.

## Future Work (Out of Scope)

- **Backward generation from BX axioms** (research Phase 4, 8-16h): Paradigm shift for c9+ that eliminates exhaustive enumeration entirely. Should be a separate task.
- **Label balancing**: The 89% invalid rate at c7 suggests intentional balancing is needed for training data quality. Orthogonal to enumeration speed.
- **hashDedup collision risk**: UInt64 hash-only dedup has statistically significant collision probability at 1.7M formulas. Should confirm structural equality or upgrade to collision-resistant hash.
