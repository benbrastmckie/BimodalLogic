# Diagnostic Audit: Dataset Generation Pipeline (c4-c7)

## Task 295 Research Report

**Date**: 2026-06-08
**Session**: sess_1749411600_orchestrate

---

## 1. Pipeline Architecture Overview

The dataset generation pipeline consists of five sequential stages:

```
Enumeration -> Prefiltering -> Labeling -> Normalization -> Export
     |               |             |            |             |
FormulaEnumerator  DatasetGen   DatasetGen  Normalization  DatasetExport
                   (prefilter)  (decide)    (fold/unfold)  (JSONL)
                                    |
                               DecideCache (task 289)
```

### Core Files

| File | Lines | Purpose |
|------|-------|---------|
| `FormulaEnumerator.lean` | 2,351 | Exhaustive/stratified/sampled formula generation |
| `DatasetGenerator.lean` | 2,137 | Labeling pipeline: prefilter + tableau + cache |
| `Normalization.lean` | 1,121 | Fold/unfold + `normalizeFormula` identity |
| `DatasetExport.lean` | ~1,300 | JSONL serialization + CLI `main` |
| `EnumBenchmark.lean` | 221 | Compiled benchmark binary |
| `AtomCanonicalization.lean` | ~130 | Atom-permutation dedup (~4.58x reduction) |
| `ForwardProofGenerator.lean` | ~500+ | Forward-chaining proof pool for hybrid mode |
| `PrefilterSoundness.lean` | 171 | Formal soundness proofs for invalid prefilter |
| `InterestingnessMetrics.lean` | ~500+ | Composite scoring for formula quality |

### Complexity Parameter Semantics

The "cN" designation refers to `maxComplexity = N`, which controls the maximum structural complexity (connective count + 1) of enumerated formulas. The parameters `maxModalDepth` and `maxTemporalDepth` are typically fixed at 2. The atom pool is typically `{p, q, r}` (3 atoms).

**Post-task-285 complexity**: Derived operators (diamond, always, sometimes, next, prev, weak_future, weak_past) now have pattern-aware complexity of 1 each (down from 3-23 in primitive expansion). This dramatically increases formula count at each complexity level.

---

## 2. Enhancement Inventory (Tasks 284, 285, 287, 289)

### Task 284: Structural Prefilter + Hybrid Labeling

**Status**: Fully implemented in `DatasetGenerator.lean` and `DatasetExport.lean`.

**Changes**:
1. **Identity prefilter**: `phi -> phi` short-circuits as valid for any formula (including temporal operators)
2. **Temporal implication patterns**: `U(X, Y) -> F(Y)` and `S(X, Y) -> P(Y)` recognized as structurally valid
3. **Hybrid generation mode**: `--generation-mode hybrid` checks proof pool first, falls back to tableau
4. **CLI integration**: `--generation-mode`, `--pool-depth`, `--pool-seeds` flags wired into DatasetExport

**Correctness Assessment**: 15 `#eval` tests pass inline. Mini-batch (8 formulas) shows zero label regressions between exhaustive and hybrid modes. The temporal implication patterns are semantically sound (Until guarantees eventual occurrence).

**Observation**: The `isTemporalImplicationPattern` function only matches exact `U(guard, event) -> F(event)` and `S(guard, event) -> P(event)` patterns. It does not match relaxed forms like `U(X, Y) -> F(X)` (which is indeed NOT valid in general). This conservative approach is correct.

### Task 285: Derived Operator Enumeration

**Status**: Fully implemented in `Formula.lean` and `FormulaEnumerator.lean`.

**Changes**:
1. **Pattern-aware complexity**: 7 derived operators reduced from multi-step primitive expansion to complexity 1
2. **Enumerator branches**: 8 new branches in `enumExactHelper` for diamond, always, sometimes, next, prev, weak_future, weak_past
3. **Binary derived temporal**: release, weak_until, trigger, weak_since, strong_release, strong_trigger added
4. **Parallel path updated**: `enumerateLevelParallel` mirrors the new branches
5. **`hasDerivedTemporal` extended**: All 7 unary + 8 binary derived patterns recognized

**Formula Count Impact**:
| Level | Pre-285 | Post-285 | Factor |
|-------|---------|----------|--------|
| c4 | ~960 | 7,852 | ~8.2x |
| c5 | ~9,100 | 75,914 | ~8.3x |

**Potential Issue**: The `sampleOne` and `sampleOneRandom` functions (random sampling paths) were NOT updated with new operators per the task summary. This means random/hybrid sampling modes will not generate derived operators -- only exhaustive enumeration does. This is a gap if random sampling is used at high complexity.

### Task 287: Formula Normalization Before Tableau

**Status**: Fully implemented in `Normalization.lean` and `DecisionProcedure.lean`.

**Changes**:
1. **`normalizeFormula`**: Pattern-matches on 6 primitive constructors, recursively normalizes
2. **Identity proof**: `@[simp] theorem normalizeFormula_id : normalizeFormula phi = phi` proved by structural induction (axiom-free except `propext`)
3. **Decision procedure integration**: `normalizeFormula` wired into `decide` as first step with `have h_norm` for proof transport
4. **Test coverage**: 27 static examples + 1 round-trip `#eval` + 5 decision procedure integration tests + c5 benchmark (50 formulas, 0 timeouts)

**Assessment**: Since `normalizeFormula` is provably the identity function (all derived operators are `def` abbreviations), this change has zero runtime effect -- it is purely a documentation/contract guard. No performance impact, positive or negative. The normalization pass exists as future-proofing in case any derived operator changes from `def` to `opaque`.

**Round-trip correctness**: The `foldFormula`/`toPrimitive` round-trip is verified by `#eval` tests for 21 formula types. The `foldFormulaFull` (with `recognizeComposites` post-processing) handles composite operators (always, sometimes, or_).

### Task 288: Invalid Structural Prefilter

**Status**: Fully implemented in `DatasetGenerator.lean` with formal soundness proofs in `PrefilterSoundness.lean`.

**Changes**:
1. **Three invalid pattern recognizers**:
   - `isTemporalContradiction`: `phi -> psi` where consequent always false and antecedent not always false
   - `isObviousSatisfiable`: `phi -> bot` where `phi` trivially satisfiable; `phi -> psi` where `phi` satisfiable and `psi` always false
   - `hasUnfulfillableEventuality`: `phi -> U(event, guard)` where `phi` contains `G(neg event)` (symmetric for Since/H)
2. **Combined in `structuralInvalidPrefilter`**: Wired as Phase 1.5 between valid prefilter and tableau
3. **Trivial countermodel construction**: `constructTrivialCountermodel` sets all atoms to true
4. **Formal soundness**: `PrefilterSoundness.lean` proves `isUnsatBotTemporal_not_truth` and unfulfillable eventuality lemmas

**Correctness Assessment**: 20+ `#eval` tests for individual recognizers and the combined prefilter. Cross-validation test (10 formulas) confirms agreement with full tableau. Regression test confirms no valid formulas are mislabeled. Edge case tests for vacuously valid formulas (bot -> bot) pass.

**Coverage estimates from task documentation**: ~30-50 of 96 remaining c6 timeouts could be caught. However, the existing c4-c7 datasets (generated before task 288) show 0 occurrences of `structural_invalid_prefilter`, confirming the datasets are stale relative to this enhancement.

### Task 289: Memoization Cache

**Status**: Fully implemented in `DatasetGenerator.lean`, `DatasetExport.lean`, and `EnumBenchmark.lean`.

**Changes**:
1. **`DecideCache`**: Bounded HashMap with FIFO eviction, hit/miss/eviction counters
2. **`labelFormulaWithCache`**: Mutex-protected wrapper with short critical sections
3. **Thread safety**: Mutex only held during O(1) HashMap operations; expensive computation runs unlocked
4. **Shared across parallel chunks**: All parallel labeling threads share one cache via `Std.Mutex`
5. **CLI flag**: `--cache-size N` (default 10000) in EnumBenchmark

**Expected Impact**: The cache is most effective when:
- Temporal dual augmentation produces duplicates
- Axiom-seeded formulas overlap with enumerated formulas
- Parallel chunks encounter overlapping formula subsets

**Observation**: The existing datasets show 0 "cached" entries, confirming they were generated before task 289. The actual cache hit rate depends on the formula distribution and whether temporal duals (`enrichWithDuals`) are enabled.

---

## 3. Existing Dataset Analysis (Pre-Enhancement Baseline)

The existing JSONL datasets in `data/` were generated with code predating tasks 284-289:

| Dataset | Records | Valid | Invalid | Timeout | Timeout % | Valid % | Date |
|---------|---------|-------|---------|---------|-----------|---------|------|
| c4 | 408 | 23 | 333 | 52 | 12.7% | 5.6% | Jun 4 |
| c5 | 6,031 | 103 | 4,772 | 1,156 | 19.2% | 1.7% | Jun 7 |
| c6 | 39,832 | 816 | 28,694 | 10,322 | 25.9% | 2.0% | Jun 7 |
| c7-clean | 49,865 | 4,198 | 43,257 | 2,410 | 4.8% | 8.4% | Jun 4 |

**Key observations**:
1. **Timeout rate escalation**: 12.7% at c4 -> 25.9% at c6, then drops to 4.8% at c7-clean (c7-clean likely used different parameters or code version)
2. **Prefilter coverage**: structural_prefilter hits = 20 (c4), 94 (c5), 772 (c6), 7,457 (c7) -- all valid-side only
3. **No invalid prefilter**: 0 `structural_invalid_prefilter` entries in any dataset
4. **No cache hits**: 0 "cached" entries in any dataset
5. **c7 anomaly**: c7.jsonl has 77,272 records but c7-clean metadata shows 49,865 -- suggests the raw c7 was post-processed

### Decision Method Distribution (from metadata)

| Method | c4 | c5 | c6 | c7-clean |
|--------|----|----|----|----|
| structural_prefilter | 20 | 94 | 772 | 1,360 |
| fast_path_axiom | 1 | 5 | 33 | 1,659 |
| adaptive_500 | 335 | 4,776 | 28,705 | 44,436 |
| adaptive_timeout | 52 | 1,156 | 9,986 | 2,410 |
| wallclock_timeout | 0 | 0 | 336 | 0 |

The `adaptive_timeout` vs `wallclock_timeout` distinction: adaptive_timeout means the tableau exceeded its fuel budget; wallclock_timeout means the wall-clock deadline was hit. The c6 dataset uniquely shows 336 wallclock timeouts.

---

## 4. Enumeration Stage Analysis

### Formula Counts (Post-Task-285)

With pattern-aware complexity for derived operators, the exhaustive enumeration space is significantly larger:

| Level | Pre-285 Estimate | Post-285 (measured) | Growth Factor |
|-------|-----------------|---------------------|---------------|
| c4 | ~960 | 7,852 | ~8.2x |
| c5 | ~9,100 | 75,914 | ~8.3x |
| c6 | ~40,000 | ~600K+ (estimated) | ~15x |
| c7 | ~50,000 | ~5M+ (estimated) | ~100x |

The massive growth at c6-c7 is due to combinatorial explosion of binary derived temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) crossing with the existing primitive operators.

### Memoization Cache in Enumeration

The enumeration cache (`EnumCache` = `Std.HashMap (Nat x Nat x Nat) (Array Formula)`) is separate from the labeling cache (`DecideCache`). The enumeration cache eliminates redundant computation across recursive calls in `enumExactHelper`. At budget 5, there are only 27 unique argument triples despite 1,027 recursive calls. This is the original memoization from task 210, not the new task 289 cache.

### Atom Canonicalization

The `canonicalDedup` flag in `EnumParams` enables atom-permutation canonicalization, yielding ~4.58x reduction at c7. This is controlled by the `--canonical-dedup` CLI flag. The c7-clean dataset likely used this feature.

### Potential Issues

1. **Memory pressure at c7+**: The formula counts grow superexponentially. At c7 with derived operators, exhaustive enumeration may exceed available memory. The existing pipeline has per-level progress reporting and checkpoint support (task 283), but no explicit memory bounds.

2. **`sampleOneRandom` not updated**: Random sampling paths (`sampleOne`, `sampleOneRandom`) were not updated with task 285 derived operators. This means `SamplingMode.random` and `SamplingMode.hybrid` will underrepresent derived operators.

3. **`structurallyTrivial` filter scope**: Only filters `box(box(phi))` (S5 idempotence), `phi -> phi` (identity), and `bot -> phi` (ex falso). Does not filter trivially false patterns like `phi -> bot` or `U(bot, phi) -> psi`. The invalid prefilter handles some of these downstream, but filtering at enumeration time would reduce labeling work.

---

## 5. Prefilter Stage Analysis

### Valid Prefilter (`structuralPrefilterWithAxiom`)

**Patterns recognized** (17 total):
- `structural_identity`: phi -> phi
- `structural_bot_temporal`: unsat antecedent (recursive: U(box(bot), X), etc.)
- `structural_tautology`: valid consequent (X -> (p -> p), X -> box(q -> q))
- `structural_polarity_drop_tautology`: deep unsat antecedent in consequent
- `structural_polarity_bot_neg`: bot among conjuncts
- `structural_prop_contradiction`: p and neg(p) among conjuncts
- `structural_s5_reflexive_conflict`: box(phi) and neg(phi) among conjuncts
- `structural_temporal_loop_until`: U(event, guard) and G(neg guard) among conjuncts
- `structural_temporal_loop_since`: S(event, guard) and H(neg event) among conjuncts
- `structural_subsumption_*`: 8 subsumption patterns (modal_t, modal_4, modal_d, gt, g4, gf, ht, h4, hp, ff, pp)
- `structural_until_implies_future`: U(X, Y) -> F(Y) (task 284)
- `structural_since_implies_past`: S(X, Y) -> P(Y) (task 284)
- `structural_double_box_bot`: box(box(bot)) -> anything
- `structural_modal_4`: box(box(phi)) -> phi
- `structural_modal_t_weakening`: box(phi) -> (psi -> phi)

### Invalid Prefilter (`structuralInvalidPrefilter`)

**Patterns recognized** (3 categories):
- `invalid_satisfiable_neg`: trivially satisfiable antecedent with false consequent
- `invalid_false_consequent`: always-false consequent with non-false antecedent
- `invalid_unfulfillable_eventuality`: G(neg event) makes U(event, guard) unfulfillable

### Coverage Analysis

From the existing c6 dataset: 772 formulas caught by valid prefilter out of 39,832 total (1.9%). The invalid prefilter was not yet integrated.

**Expected impact of full prefilter suite**: The invalid prefilter documentation estimates ~30-50 additional catches per ~96 remaining c6 timeouts. Combined with valid prefilter, the pipeline should resolve ~800-850 formulas without tableau invocation at c6, reducing timeout count from ~10,322 to perhaps ~10,000-10,200 (modest improvement since most timeouts are genuinely hard formulas).

### Potential Improvements

1. **Box-descent for invalid prefilter**: `structuralInvalidPrefilter` does not recurse into `box(...)`. A formula like `box(p -> U(bot, q))` might benefit from checking the inner implication.

2. **Conjunction-level invalid patterns**: The valid prefilter checks conjunct-level patterns (S5 reflexive conflict, temporal loop). The invalid prefilter could similarly check for contradictory conjuncts that make the formula satisfiable but not valid.

3. **Prefilter profiling**: Currently there is no per-pattern hit count in the metadata. Adding pattern-level statistics would help identify which patterns provide the most value.

---

## 6. Labeling Stage Analysis

### Decision Pipeline Flow

```
Phase 1:   structuralPrefilterWithAxiom -> valid? -> done
Phase 1.5: structuralInvalidPrefilter -> invalid? -> done  
Phase 2:   decideAutoAdaptive (spawned thread with wall-clock timeout)
           -> valid (proof tree) / invalid (countermodel) / timeout
```

### Cache Integration (Task 289)

The `labelFormulaWithCache` wrapper:
1. Acquires mutex, performs O(1) HashMap lookup
2. On hit: returns cached result with `decisionMethod = "cached"` and `decisionTimeMs = 0`
3. On miss: releases mutex, computes result, reacquires to insert

**Thread safety**: Correct. Mutex held only during O(1) operations. No risk of deadlock.

**Eviction policy**: When `accessOrder.size > maxSize`, oldest half is evicted. This is a simple FIFO bulk eviction. Not LRU.

**Potential improvement**: The eviction could be smarter -- evict only entries whose formulas have low complexity (fast to recompute) while keeping expensive timeout results cached longer.

### Timeout Analysis

The wallclock timeout (default 1000ms) is enforced via `IO.hasFinished` polling with 1ms sleep. This adds ~1ms overhead per formula but prevents pipeline stalls.

The `decideAutoAdaptive` function uses a single-tier fuel of 500. The "adaptive" in the name refers to the fuel allocation strategy, not an adaptive timeout.

### Potential Issues

1. **Timeout interaction with cache**: Timeout results are cached. If a formula times out once, it will be returned as timeout on subsequent encounters even if more time was available. This is correct behavior (deterministic) but means the cache does not help with "retry with more fuel" strategies.

2. **Countermodel extraction cost**: For invalid formulas, `extractCountermodelData` runs `buildTableau` again to extract enriched countermodels. This doubles the work for invalid formulas. The result could be cached at the tableau level.

3. **Interestingness computation**: `computeInterestingness` is called for every formula (valid, invalid, timeout). This is lightweight (syntactic analysis) but could be deferred to export time for timeouts.

---

## 7. Normalization Stage Analysis

### Unfold Direction (primitives)

15 `@[simp]` lemmas reduce derived operators to primitives. All are `rfl` proofs. The `modal_norm` macro applies all 15 simultaneously.

### Fold Direction (enriched)

`foldFormula` performs bottom-up greedy pattern matching to reconstitute derived operators. Key ambiguity: `imp(imp(A, bot), B)` matches both `or(A, B)` and `imp(neg(A), B)`. Resolution: `or_` is only recognized in `recognizeComposites` post-processing.

### `normalizeFormula` (Task 287)

Provably the identity function. Wired into `decide` for contract documentation. Zero runtime cost.

### Round-Trip Correctness

The `toPrimitive . foldFormulaFull` round-trip is verified by `#eval` tests. All 21 formula types round-trip correctly. The `or` fold lemma is deliberately omitted from `modal_fold` due to the ambiguity.

### Potential Issues

1. **Release/WeakUntil/Trigger/WeakSince fold**: These binary derived temporal operators may not be recognized by `foldFormula` since they require matching complex nested patterns. The `EnrichedFormula` type has `strong_release` and `strong_trigger` constructors but the fold algorithm may not match all binary derived temporal patterns from primitives.

2. **Export representation**: The `formula_folded_json` field in JSONL uses `foldFormulaFull`, but the fold may not be perfect for all formula types. Verify that the export correctly shows enriched tags for all newly enumerated derived operators.

---

## 8. Existing Benchmark Infrastructure

### Compiled Benchmark (`lake exe enum_benchmark`)

The `EnumBenchmark.lean` provides:
1. **Exact-complexity timing**: c5 (<5s), c6 (<30s), c7 (<60s) gates
2. **Valid fraction**: Axiom seeding at c5 and c7
3. **Full pipeline**: c7 generation + sampling + labeling + gate checks

**CLI**: `lake exe enum_benchmark -- --parallel N --cache-size M`

### Test Suite

| Test File | Coverage |
|-----------|----------|
| `C5SmokeTest.lean` | Decision procedure correctness at c5 |
| `NormalizationTest.lean` | normalizeFormula identity + decision integration |
| `ProofSearchTest.lean` | Proof search strategies |
| `InterestingnessTest.lean` | Interestingness scoring |
| `FormulaMutatorTest.lean` | Formula mutation for contrastive pairs |
| `ProofFirstTests.lean` | Forward proof generation pipeline |

### Inline `#eval` Tests

`DatasetGenerator.lean` contains ~60+ inline `#eval` tests covering:
- Prefilter pattern recognition (valid and invalid)
- Prefilter integration with `labelFormulaImpl`
- Cross-validation against full tableau
- Regression tests for valid formulas
- Edge cases for vacuously valid formulas
- Hybrid mode smoke tests
- Cache statistics display

---

## 9. Identified Issues and Gaps

### Critical (blocks accuracy)

1. **Stale datasets**: All existing c4-c7 datasets were generated BEFORE tasks 284-289. They lack:
   - Invalid prefilter results (task 288)
   - Cache hit data (task 289)
   - Task 285 derived operators (c5/c6 files from Jun 7 may have partial support)
   - Hybrid labeling mode data (task 284)

### High Priority (performance/quality)

2. **c6-c7 formula explosion**: Post-task-285, exhaustive enumeration at c6 produces ~600K+ formulas (vs ~40K pre-285). At c7, potentially millions. The existing benchmark gates (30s at c6, 60s at c7) may be inadequate.

3. **Random sampling gap**: `sampleOneRandom` and `sampleOne` not updated with task 285 derived operators. Random/hybrid sampling modes underrepresent derived operators.

4. **No profiling of cache hit rates**: The cache statistics are printed but not persisted to metadata. Cannot assess cache effectiveness without regeneration.

5. **Countermodel double-computation**: Invalid formulas run `buildTableau` twice -- once in `decideAutoAdaptive` and once in `extractCountermodelData`. This could be unified.

### Medium Priority (code quality)

6. **Dead code in `enumerateExhaustive`**: The pure (non-IO) `enumerateExhaustive` function is superseded by `enumerateWithProgress` (IO version). The pure version lacks checkpoint support, canonical dedup, and progress reporting.

7. **Duplicate serialization methods**: `ProofTrace.toJson` exists in both `DatasetGenerator.lean` (lines 1767-1775) and `DatasetExport.lean` (as `proofTraceToJson`). Similarly for `DifficultyMetrics.toJson`. These should be consolidated.

8. **`hashDedup` collision risk**: Uses `UInt64` hash as the key without equality check. Hash collisions would cause silent formula loss. Should use `Std.HashSet Formula` instead.

9. **`deterministicSampleFormulas` exists twice**: Once as a local `where` in `enumerateStratified` and once as a top-level private function. The top-level version was extracted for reuse but the local one was not removed.

### Low Priority (enhancements)

10. **Prefilter pattern-level statistics**: Metadata does not track per-pattern hit counts. Would enable optimization of pattern ordering.

11. **Eviction policy**: FIFO bulk eviction could be improved to retain expensive-to-compute entries.

12. **`strong_release`/`strong_trigger` fold**: The fold algorithm may not recognize all binary derived temporal patterns from their primitive expansions.

13. **Memory profiling infrastructure**: No built-in memory usage tracking. At c7+ with derived operators, memory could be the bottleneck rather than time.

---

## 10. Recommended Diagnostic Plan

### Phase 1: Regenerate Datasets with Current Code

Regenerate c4-c7 datasets using the compiled binary with all enhancements:
```bash
lake exe dataset_generator -- \
  --max-complexity N \
  --wallclock-timeout 1000 \
  --generation-mode exhaustive \
  --output data/bmlogic-cN-v2.jsonl
```

Collect: formula counts, timing, timeout rates, prefilter hit rates, cache statistics.

### Phase 2: Comparative Analysis

Compare v2 datasets against v1 (existing) datasets:
- Timeout rate reduction (quantify invalid prefilter impact)
- Formula count increase (quantify derived operator impact)
- Cache hit rates (quantify memoization benefit)
- Valid fraction change
- Decision method distribution shift

### Phase 3: Stress Test

Run enumeration-only benchmarks at c4-c7 to profile:
- Wall-clock time per complexity level
- Memory usage (via system tools)
- Formula count at each exact complexity level

### Phase 4: Code Cleanup

- Remove dead code (`enumerateExhaustive` pure version if unused)
- Consolidate duplicate serialization methods
- Fix `hashDedup` collision risk
- Update random sampling with derived operators

---

## 11. Prioritized Actionable Improvements

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 1 | Regenerate c4-c7 with current code | Medium | High -- enables all subsequent analysis |
| 2 | Profile c6-c7 enumeration memory | Low | High -- identifies feasibility ceiling |
| 3 | Update random sampling with derived operators | Medium | Medium -- affects hybrid/random modes |
| 4 | Consolidate duplicate serialization | Low | Low -- code quality |
| 5 | Fix `hashDedup` collision risk | Low | Medium -- correctness |
| 6 | Add per-pattern prefilter statistics to metadata | Low | Medium -- optimization data |
| 7 | Cache enrichment: persist to metadata | Low | Low -- observability |
| 8 | Unify countermodel extraction (avoid double tableau) | Medium | Medium -- ~2x speedup for invalid formulas |
| 9 | Remove dead code (pure `enumerateExhaustive`) | Low | Low -- code quality |
| 10 | Memory-bounded enumeration at c7+ | High | High -- enables larger datasets |

---

## 12. Summary of Findings

### What Works Well

- The prefilter architecture (valid + invalid) is well-designed with formal soundness proofs
- The cache design has correct thread safety (mutex only during O(1) operations)
- The normalization module provides both directions (fold/unfold) with round-trip verification
- The enumeration memoization (EnumCache) eliminates redundant computation effectively
- The checkpoint/resume infrastructure (task 283) enables crash recovery at c8+
- The atom canonicalization provides meaningful deduplication (~4.58x at c7)
- Zero sorries in all pipeline files

### What Needs Attention

- All existing datasets are stale (pre-tasks 284-289) and need regeneration
- Post-task-285 formula counts may exceed memory at c7
- Random sampling paths are missing derived operators
- Some code duplication and one hash-collision risk in deduplication
- No runtime profiling data exists for the new enhancements -- all benchmarks are deferred to compiled execution

### Blockers

None. All four tasks (284, 285, 287, 289) are fully implemented with zero sorries. The pipeline compiles and all inline tests pass. The main work for this diagnostic task is regeneration and profiling, which requires compiled binary execution.
