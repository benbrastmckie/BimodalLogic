# Implementation Plan: Optimize generateValidBatch O(n^2) MP Closure Bottleneck

- **Task**: 251 - Optimize generateValidBatch O(n^2) MP closure bottleneck
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (unblocks task 217 c9/c11 generation)
- **Research Inputs**: specs/251_optimize_generate_valid_batch_bottleneck/reports/01_bottleneck-optimization-research.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Refactor `generateValidBatch` in `Theories/Bimodal/Automation/FormulaEnumerator.lean` to eliminate three compounding O(n^2) operations: the all-pairs MP closure loop, repeated `List.eraseDups` calls, and implicit linear membership checks. The optimization replaces the `List Formula` pool with a `Std.HashSet Formula` (for O(1) membership and dedup) paired with an `Array Formula` (for ordered iteration), introduces an implication-index `Std.HashMap Formula (Array Formula)` for O(n) MP closure, and adds early complexity filtering to reduce pool growth. The combined effect reduces overall complexity from O(n^2 * rounds) to O(n * rounds), targeting 100-1000x speedup at 10K seeds.

### Research Integration

The research report (01_bottleneck-optimization-research.md) identified 8 optimization strategies. This plan implements the top 3 in a single refactoring pass:
- **Strategy 1** (Priority 1): Implication-index HashMap for O(n) MP closure
- **Strategy 3** (Priority 1): HashSet + Array pool data structure replacing List
- **Strategy 5** (Priority 2): Early complexity filtering during Nec and MP rounds
- Strategies 4 (incremental frontier), 6 (parallelism), 7 (caching), 8 (seed diversity) are deferred as unnecessary given the expected speedup from Strategies 1+3+5.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Reduce `generateValidBatch` time complexity from O(n^2 * rounds) to O(n * rounds)
- Enable 10K+ seed counts to run in minutes instead of hours
- Maintain identical output semantics (same valid formulas produced, modulo ordering)
- Pass `lake build` with zero errors and zero new sorries

**Non-Goals**:
- Parallelism via Lean 4 Tasks (deferred, diminishing returns after algorithmic fix)
- Cross-batch caching (not applicable to current single-invocation pipeline)
- Changing the seed generation strategy (out of scope)
- Modifying `generateFormulas` or `enumerateStratified` (separate functions)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Std.HashSet` import not available | M | L | Already have `Std.Data.HashMap` imported; construct HashSet from `HashMap Formula Unit` if needed |
| Hash collisions cause missed formulas | L | VL | `Std.HashMap`/`HashSet` use BEq fallback in bucket chains; collision probability negligible at 10K formulas |
| Early complexity filter misses derivable in-range formulas via out-of-range intermediates | L | L | Keep implication index over ALL formulas (including above maxComplexity) but only add Nec results within range |
| Pool iteration order change affects downstream (dataset determinism) | L | M | Results are filtered and sorted by complexity anyway; add explicit sort if needed |
| `Formula.hash` performance is slow | L | VL | Derived `Hashable` is structural; still orders of magnitude faster than structural equality in tight loops |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Replace List Pool with HashSet + Array and Eliminate eraseDups [COMPLETED]

**Goal**: Convert the pool data structure from `List Formula` to `Std.HashSet Formula` + `Array Formula`, eliminating all `eraseDups` calls.

**Tasks**:
- [x] Add `import Std.Data.HashSet` at top of file (or verify it is available via existing `Std.Data.HashMap` import)
- [x] Define a local helper function `addToPool` that inserts into both `poolSet : Std.HashSet Formula` and `poolArr : Array Formula` only if the formula is not already in `poolSet`
- [x] Refactor Phase 1 (Seed pool, lines 993-999): replace `mut pool : List Formula` with `mut poolSet : Std.HashSet Formula` and `mut poolArr : Array Formula`; use `addToPool` for each `axiomInst` and each `theoremSeedFormulas` entry; remove `pool.eraseDups` call
- [x] Refactor Phase 2 (Ex-falso cap, lines 1001-1019): use `poolArr` for iteration/filtering, `poolSet` for membership; rebuild both structures after filtering; remove second `pool.eraseDups` call
- [x] Refactor Phase 3 stub (lines 1021-1041): convert `pool.length` references to `poolArr.size`; convert `pool.map` to `poolArr` iteration; remove all `(pool ++ ...).eraseDups` calls -- new formulas go through `addToPool` check *(deviation: altered -- also implemented Phase 2 implication-index and Phase 3 complexity filtering in the same rewrite since the function is a single block)*
- [x] Refactor Phase 4 (Filter, lines 1043-1044): filter from `poolArr.toList` instead of `pool`
- [x] Verify `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Lines 989-1044: replace List pool with HashSet+Array, eliminate eraseDups

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- No new sorries introduced
- All `eraseDups` calls within `generateValidBatch` are removed

---

### Phase 2: Implication-Index HashMap for O(n) MP Closure [NOT STARTED]

**Goal**: Replace the O(n^2) nested MP closure loop with an O(n) implication-index lookup.

**Tasks**:
- [ ] At the start of each MP round (after Nec round), build an implication index: `mut impIndex : Std.HashMap Formula (Array Formula)` by iterating `poolArr` and, for each `.imp lhs rhs` formula, inserting `lhs -> [rhs]` (appending to existing array if key exists)
- [ ] Replace the nested `for phi in pool do for psi in pool do match generateValidFromMP phi psi` loop with a single pass: `for phi in poolArr do match impIndex[phi]? with | some rhsArr => for rhs in rhsArr do addToPool ...`
- [ ] Remove the `generateValidFromMP` call from the hot loop (the index lookup replaces it)
- [ ] Ensure the snapshot pattern is correct: build impIndex from a snapshot of `poolArr` taken before the MP round, then iterate a snapshot for lookups, adding new results to the live `poolSet`/`poolArr`
- [ ] Verify `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Phase 3 MP closure section: replace nested loop with implication-index lookup

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- No nested `for phi in pool do for psi in pool do` loop remains in generateValidBatch
- The implication index is rebuilt each round from the current pool snapshot

---

### Phase 3: Early Complexity Filtering [NOT STARTED]

**Goal**: Add complexity bounds checks at formula insertion points to prevent pool inflation from high-complexity formulas.

**Tasks**:
- [ ] In the Nec round: after computing `boxPhi := generateValidFromNec phi`, check `boxPhi.complexity <= maxComplexity` before calling `addToPool`; skip insertion if over the limit
- [ ] In the MP round: after looking up `rhs` from the implication index, check `rhs.complexity <= maxComplexity` before calling `addToPool`
- [ ] Keep the implication index built from ALL pool formulas (including those above maxComplexity that were added during seeding), so high-complexity implications still serve as derivation paths for in-range consequents
- [ ] Update the Nec snapshot iteration to also skip formulas whose `boxPhi` would exceed maxComplexity (minor optimization to avoid unnecessary hash computations)
- [ ] Verify `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors

**Timing**: 20 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Phase 3 Nec and MP sections: add complexity guards at insertion points

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` passes
- Complexity filter is applied at both Nec and MP insertion points
- Implication index still includes all pool formulas regardless of complexity

---

### Phase 4: Integration Testing and Build Verification [NOT STARTED]

**Goal**: Verify the optimized function produces correct output and the full project builds cleanly.

**Tasks**:
- [ ] Run `lake build` (full project) to verify no downstream compilation breakage
- [ ] Verify `#print axioms generateValidBatch` shows no `sorryAx` (if reachable from a non-partial def)
- [ ] Verify the `hashDedup` function (lines 1050-1058) is still used by `generateFormulas` (line 1140) and not accidentally broken
- [ ] Review the `generateFormulas` function (lines 1117-1141) to ensure it correctly calls the refactored `generateValidBatch` -- the return type `IO (List Formula)` must be preserved
- [ ] Optionally add a timing log (`IO.println`) to `generateValidBatch` showing pool size per round and total elapsed time, for future benchmarking (can be removed or gated behind a debug flag)

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Optional: add timing/logging for benchmarking
- No other files expected to change

**Verification**:
- `lake build` passes with zero errors across all project modules
- No new sorries introduced anywhere
- `generateFormulas` return type unchanged (`IO (List Formula)`)
- Output semantics preserved: all formulas that would have been generated before are still generated (modulo ordering)

---

## Testing & Validation

- [ ] `lake build Bimodal.Automation.FormulaEnumerator` passes after each phase
- [ ] `lake build` (full project) passes after Phase 4
- [ ] No new `sorry` or `sorryAx` introduced
- [ ] `generateValidBatch` return type remains `IO (List Formula)`
- [ ] `generateFormulas` function continues to call `generateValidBatch` correctly
- [ ] All `eraseDups` calls within `generateValidBatch` are eliminated
- [ ] The O(n^2) nested MP loop is replaced with O(n) index lookup
- [ ] Early complexity filtering is active at both Nec and MP insertion points

## Artifacts & Outputs

- `specs/251_optimize_generate_valid_batch_bottleneck/plans/02_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Automation/FormulaEnumerator.lean` (primary change, ~80-100 lines modified)

## Rollback/Contingency

- All changes are confined to a single function (`generateValidBatch`) in a single file (`FormulaEnumerator.lean`)
- The function signature and return type are unchanged, so no downstream callers are affected
- `git checkout -- Theories/Bimodal/Automation/FormulaEnumerator.lean` reverts all changes
- If `Std.HashSet` is unavailable, fall back to `Std.HashMap Formula Unit` as a HashSet substitute (same API, slightly more verbose)
- If early complexity filtering changes output semantics in an undesirable way, it can be disabled independently (remove the complexity guards from Phase 3) while keeping the HashSet pool and implication index
