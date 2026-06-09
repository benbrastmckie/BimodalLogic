# Diagnostic Audit Summary: Dataset Generation Pipeline

**Task**: 295 - Diagnostic audit of the dataset generation pipeline
**Date**: 2026-06-08
**Status**: Complete
**Session**: sess_1780969832_cb1f59

## Executive Summary

The dataset generation pipeline is functionally correct and performs well through c6 complexity. All four recent enhancements (tasks 284, 285, 287, 289) are working as designed. Enumeration is extremely fast (c7 at 1.25M formulas in 101ms), and labeling is the clear bottleneck. The pipeline transitions from "fast and feasible" to "slow but feasible" between c5 and c6, with c7 being the practical upper bound for exhaustive labeling. The operator audit reveals that 8 of 13 derived operators contribute zero formulas to the pipeline output, suggesting significant formula-space inflation without corresponding dataset value.

## What Works Well

- **Enumeration speed**: All complexity levels c4-c7 enumerate in under 3 seconds total. c7 enumerates 1.25M formulas in 101ms. Enumeration is never the bottleneck.
- **Structural prefilter**: Correctly identifies known-valid patterns (15 catches at c4, 93 at c5, 743 at c6). All 60+ inline #eval tests pass.
- **Invalid prefilter**: Correctly identifies known-invalid patterns via `structuralInvalidPrefilter` (task 288). Cross-validation with full tableau agrees on all tested formulas. Note: no invalid prefilter catches appear in the c4 pipeline output because the patterns primarily target formulas with satisfiable antecedents and false consequents, which are already resolved by `adaptive_500`.
- **Cache behavior**: DecideCache with Mutex-based thread safety works correctly. Cache statistics are reported per batch.
- **Normalization**: `normalizeFormula` is provably the identity function (`normalizeFormula_id` by induction). `foldFormula`/`toPrimitive` round-trip passes on 21 representative formulas including all derived operators.
- **Hybrid/exhaustive agreement**: Zero label disagreements across all 806 c4 formulas when comparing exhaustive vs hybrid modes.
- **Fold/unfold correctness**: Enriched formula fields (formula_folded_json, formula_folded_str, formula_folded_sexpr) are correctly populated. E.g., `U(bot, top)` correctly folds to `F(bot)`.
- **Memory usage**: Peak RSS 248MB at c7 enumeration, ~100MB during labeling. No memory issues.

## What Needs Improvement

### 1. Labeling Speed at Scale

Labeling throughput degrades significantly at higher complexity:

| Level | Formulas | Labeling Time | Throughput | Timeout Rate |
|-------|----------|---------------|------------|--------------|
| c4    | 806      | 1s            | 786/sec    | 14%          |
| c5    | 6,029    | 11s           | 529/sec    | 19%          |
| c6    | 39,787   | ~15 min       | ~250/sec   | 25.9%        |
| c7    | ~300K est| ~20-30 min est| ~200/sec est| >30% est    |

The timeout rate climbs from 14% (c4) to 26% (c6), indicating the adaptive tableau struggles with higher-complexity formulas. At c6, 62 formulas hit the hard 1000ms wall-clock timeout, and 10,244 hit the adaptive timeout.

### 2. Operator Explosion Without Pipeline Impact

**Critical finding**: 8 of 13 derived temporal/modal operators contribute zero formulas to the final pipeline output at c4 and c5.

**Operators with zero pipeline presence (c4 and c5)**:
- `always` (triangle operator)
- `sometimes` (inverse triangle)
- `release` (dual of Until)
- `weak_until` (Until with possible infinite holding)
- `trigger` (dual of Since)
- `weak_since` (Since with possible infinite holding)
- `strong_release` (strong version of Release)
- `strong_trigger` (strong version of Trigger)

**Root cause analysis**:
- The enumerator DOES generate these operators. At c4 raw enumeration, 941 formulas contain `always` and 775 contain `sometimes`.
- They are eliminated during atom-permutation canonicalization dedup (7,852 raw -> 2,920 canonical -> 806 pipeline output).
- The `passesFilter` gate requires `complexity >= 3`, which eliminates `always(p)` (complexity 2). Higher-complexity `always` formulas exist (e.g., `always(p -> q)` at c4) but get deduplicated.
- Binary operators like `release(p, q)` have complexity 3 but their canonicalized forms collapse with primitives like `neg(untl(neg p, neg q))`.

**Impact**: These 8 operators inflate the raw enumeration space by an estimated 3-8x (each adds unary or binary combinations at every complexity level) without surviving to the final output. This is wasted computation in the enumeration phase and, more importantly, means the training dataset has zero representation of these operator families.

### 3. Low Valid Fraction

Valid fraction remains low: 2% at c4, 1.7% at c5, 2.0% at c6. The valid-seed generation adds only 16-58 valid formulas per run. The structural prefilter catches many valid formulas early (fast path), but the vast majority of formulas are invalid, reflecting the combinatorial nature of random formula generation.

### 4. Pre-existing Build Error

`CanonicalTaskRelation.lean` has a heartbeat timeout error unrelated to the pipeline. All pipeline modules (`DatasetGenerator`, `DatasetExport`, `FormulaEnumerator`, `Normalization`) build cleanly.

## Bottleneck Analysis

### Where Exhaustive Labeling Becomes Infeasible

| Level | Raw Enum | Post-Filter | Post-Dedup | Labeling Time | Feasible? |
|-------|----------|-------------|------------|---------------|-----------|
| c4    | 7,852    | 7,852       | 806        | 1s            | Yes       |
| c5    | 75,914   | 22,929      | 6,029      | 11s           | Yes       |
| c6    | 170K     | 169,629     | 39,787     | ~15 min       | Yes (borderline) |
| c7    | 1.25M    | ~1.25M      | ~300K est  | ~20-30 min est| Marginal  |
| c8    | ~10M est | ~10M est    | ~2M est    | ~3-5 hours est| No        |

**Bottleneck location**: c7 is the practical upper limit for exhaustive labeling on a single machine. c8 would require parallel labeling or timeout reduction to be feasible.

**Key factors**:
- Labeling throughput drops from 786/sec (c4) to ~250/sec (c6) due to increasing formula complexity
- Timeout rate climbs from 14% to 26%, wasting labeling budget on inconclusive results
- Formula count grows ~6-8x per complexity level after dedup

### Decision Method Distribution

| Method | c4 | c5 | c6 |
|--------|-----|-----|-----|
| structural_prefilter | 15 (1.9%) | 93 (1.5%) | 743 (1.9%) |
| fast_path_axiom | 0 (0%) | 4 (0.1%) | 32 (0.1%) |
| adaptive_500 | 671 (83.2%) | 4,776 (79.2%) | 28,706 (72.1%) |
| adaptive_timeout | 120 (14.9%) | 1,156 (19.2%) | 10,244 (25.7%) |
| wallclock_timeout | 0 (0%) | 0 (0%) | 62 (0.2%) |
| structural_invalid_prefilter | 0 (0%) | 0 (0%) | 0 (0%) |

**Observations**:
- `adaptive_500` handles the vast majority of formulas (72-83%)
- `adaptive_timeout` grows from 15% to 26% as complexity increases
- `structural_prefilter` remains constant at ~1.9% across all levels
- `wallclock_timeout` only appears at c6, hitting 62 formulas
- `structural_invalid_prefilter` catches zero formulas in the pipeline output (see root cause analysis above)

## Operator Curation Recommendations

### Tier 1: Keep (Natural, High-Value)

| Operator | c4 Count | c5 Count | Rationale |
|----------|----------|----------|-----------|
| some_future (F) | 248 (30.8%) | 1,629 (27.0%) | Core temporal: "eventually". Ubiquitous in LTL. |
| some_past (P) | 248 (30.8%) | 1,627 (27.0%) | Core temporal: "previously". Past-time dual of F. |
| all_future (G) | 183 (22.7%) | 1,468 (24.3%) | Core temporal: "always henceforth". Ubiquitous in LTL. |
| all_past (H) | 183 (22.7%) | 1,468 (24.3%) | Core temporal: "historically". Past-time dual of G. |
| next (X) | 66 (8.2%) | 564 (9.4%) | Core temporal: "at next time". Standard LTL operator. |
| prev (Y) | 66 (8.2%) | 564 (9.4%) | Core temporal: "at previous time". Past-time dual of X. |
| diamond (<>) | 4 (0.5%) | 52 (0.9%) | Core modal: possibility. Essential for S5 reasoning. |

### Tier 2: Consider Dropping (Zero Pipeline Presence)

| Operator | Min Complexity | Pipeline Count | Rationale |
|----------|---------------|----------------|-----------|
| always (triangle) | 2 | 0 | Compound: H AND present AND G. Eliminiated by dedup. |
| sometimes (inv-triangle) | 2 | 0 | Dual of always. Same dedup issue. |
| weak_future | 2 | 4 (c5) | Compound: present AND G. Very low contribution. |
| weak_past | 2 | 4 (c5) | Compound: present AND H. Very low contribution. |
| release (R) | 3 | 0 | Dual of Until. Canonical form collapses with neg(untl(neg,neg)). |
| trigger (T) | 3 | 0 | Dual of Since. Same canonicalization issue. |
| weak_until (WU) | 3 | 0 | Until-or-forever. Eliminated by dedup. |
| weak_since (WS) | 3 | 0 | Since-or-forever. Eliminated by dedup. |
| strong_release (M) | 4 | 0 | Strong version of Release. Higher complexity overhead. |
| strong_trigger (ST) | 4 | 0 | Strong version of Trigger. Higher complexity overhead. |

### Impact of Pruning

Removing the 8 zero-presence operators from the enumerator would:
- **Reduce raw enumeration count** by an estimated 40-60% at c5+ (since each operator generates cross-products with all subformulas)
- **Not change the pipeline output** (these operators produce zero surviving formulas after dedup)
- **Simplify the enumerator code** by removing 8 operator branches and their cross-product loops
- **Reduce memory usage** during enumeration by eliminating intermediate formula arrays

However, there is a more nuanced consideration: these operators may be valuable for **representation** in enriched formulas even if they don't appear as top-level pipeline entries. The fold function detects these operators in the enriched s-expression output. Removing them from enumeration would not affect fold detection.

**Recommendation**: Remove `strong_release`, `strong_trigger`, `weak_until`, `weak_since`, `release`, and `trigger` from the enumerator. These are technical duals that add formula-space inflation without contributing unique content. Keep `always` and `sometimes` in the enumerator but lower the `passesFilter` complexity gate from 3 to 2 for these specific operators (since they have complexity 2 for atomic arguments).

## Correctness Validation Results

| Test | Result | Details |
|------|--------|---------|
| Prefilter #eval tests (8 blocks, ~60 tests) | PASS | All structural patterns correctly identified |
| Normalization round-trip (normalizeFormula_id) | PASS | Proven by induction, verified on 21 formulas |
| Fold/unfold round-trip (foldFormulaFull) | PASS | 21 formulas, all pass |
| Hybrid vs exhaustive cross-validation | PASS | 806/806 labels match, zero mismatches |
| Invalid prefilter vs tableau agreement | PASS | All 10 cross-validation formulas agree |
| Valid formula regression (not mislabeled) | PASS | 10 known-valid formulas correctly not caught |
| Edge case tests (vacuous/boundary) | PASS | 4/4 edge cases correct |

## Enumeration Profiling Results (Phase 2)

| Level | Raw Formulas | Post-Filter | Enum Time | Peak RSS |
|-------|-------------|-------------|-----------|----------|
| c4    | 7,852       | 7,852       | <1ms      | -        |
| c5    | 75,914      | 22,929      | 2ms       | -        |
| c6    | ~170K       | 169,629     | 12ms      | -        |
| c7    | 1.25M       | ~1.25M      | 101ms     | 248MB    |
| Total | -           | -           | 2.85s     | 248MB    |

## Comparison Against Stale Dataset Baselines

| Metric | Stale c4 (pre-enhancements) | Fresh c4 (post-enhancements) | Change |
|--------|---------------------------|------------------------------|--------|
| Total records | 408 | 806 | +97% (atom canonicalization dedup change) |
| Valid count | 23 | 17 | -26% (fewer false positives from prefilter refinement) |
| Invalid count | 333 | 669 | +101% |
| Timeout count | 52 | 120 | +131% |
| Timeout rate | 12.7% | 14.9% | +2.2pp |
| Prefilter catches | 20 | 15 | -25% (prefilter patterns refined, fewer false matches) |
| Fast path axiom | 1 | 0 | Removed/absorbed into prefilter |
| Include duals | true | false | Different config |

## Prioritized Improvements (Updated from Research P1-P10)

| # | Improvement | Effort | Impact | Priority |
|---|-------------|--------|--------|----------|
| P1 | Remove 6 zero-presence binary temporal operators from enumerator | Low (2h) | Medium: ~40-60% enum reduction, no output change | High |
| P2 | Lower passesFilter gate to complexity >= 2 for always/sometimes | Low (1h) | Low-Medium: allows always/sometimes to survive | High |
| P3 | Parallel labeling via IO.asTask (already scaffolded in labelBatch) | Medium (4h) | High: ~4x throughput on multicore | High |
| P4 | Adaptive fuel scaling based on formula complexity | Medium (4h) | Medium: reduce timeout rate at c5+ | Medium |
| P5 | structural_invalid_prefilter integration: wire into pipeline position where it fires | Low (2h) | Low: catches known-invalid before tableau | Medium |
| P6 | Streaming JSONL write (avoid full-list materialization) | Low (2h) | Medium: reduce memory for c7+ | Medium |
| P7 | Stratified sampling for c7+ (instead of exhaustive) | Medium (4h) | High: makes c7-c8 feasible | Medium |
| P8 | Interestingness-weighted sampling to boost valid fraction | Medium (4h) | Medium: improve 2% valid rate | Low |
| P9 | Decision time profiling per operator family | Low (2h) | Low: inform timeout strategy | Low |
| P10| Memory-bounded enumeration for c8+ | High (8h) | High: enables c8-c10 | Low |

## Plan Deviations

- **Phase 3 Task 3.6 (operator audit)**: Altered -- used JSONL folded_sexpr analysis instead of direct enumeration-based grouping. Also discovered root cause of zero-presence operators via lean_run_code investigation of enumeration vs canonicalization.
- **Phase 4 Task 4.6 (operator pruning estimate)**: Altered -- provided qualitative estimate (40-60% enum reduction) rather than exact formula counts, because computing exact counts without the operators requires modifying the enumerator.
- **Phase 3 Task 3.3 (invalid prefilter catches)**: The plan expected nonzero invalid prefilter catches in c4 data. Actual: zero catches, because the invalid prefilter patterns target formula shapes that are already resolved by `adaptive_500` in the pipeline. This is not a bug -- the prefilter fires correctly on direct testing but the pipeline ordering means other methods handle these formulas first.
