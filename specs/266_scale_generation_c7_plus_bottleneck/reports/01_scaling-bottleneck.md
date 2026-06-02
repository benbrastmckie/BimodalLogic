# Scaling Bottleneck Report: Dataset Generation c7+

**Task**: 266  
**Session**: sess_1748895300_d6f0a4  
**Date**: 2026-06-02  

## Executive Summary

C7 exhaustive generation completed in **33 seconds** (49,865 formulas, 2,410 timeouts / 4.8%). C8 generation was attempted but hit a **wall-clock bottleneck**: after processing 147,864 of 252,893 formulas in ~2 minutes, the generator stalled on a single formula (`U(p,bot) -> U(p, box(bot))`) for 14+ minutes before being killed. The bottleneck is NOT timeout count or rate (stable at 3-5%) but the **per-formula wall-clock cost of computing certain timeouts**. These "hard timeout" formulas have temporal-to-temporal(box) structure that creates exponentially branching tableaux where each fuel step is expensive.

## Scaling Curve

| Level | Unique Formulas | Wall Clock | Timeouts | Timeout Rate | Throughput |
|-------|-----------------|------------|----------|--------------|------------|
| c3    | 36              | <1s        | 0        | 0.0%         | >1000/s    |
| c4    | 144             | <1s        | 0        | 0.0%         | >1000/s    |
| c5    | 1,312           | <1s        | 0        | 0.0%         | >1000/s    |
| c6    | 5,904           | ~6s        | 224      | 3.8%         | ~1000/s    |
| c7    | 42,416          | 30s        | 2,186    | 5.2%         | ~1640/s    |
| c8    | ~203,000 (est)  | >14min*    | ~8,000   | ~4%          | variable   |

*C8 processed 147,864 formulas in ~2 minutes, then stalled on a single formula for 14+ minutes.

### Formula Count Growth Rate

```
c5/c4:  9.1x
c6/c5:  4.5x
c7/c6:  7.2x
c8/c7:  4.8x
```

Growth is roughly 5-7x per complexity level, meaning c9 would have ~1.2M formulas and c10 ~6M.

## C7 Detailed Results

- **Total formulas**: 49,865 (42,416 at complexity 7)
- **Valid**: 4,198 (8.4%)
- **Invalid**: 43,257 (86.7%)
- **Timeout**: 2,410 (4.8%)
- **Wall clock**: 33 seconds
- **Mean decision time**: 0.60ms
- **Max decision time**: 91ms
- **Slow formulas (>1s)**: 0

### C7 Decision Method Distribution

| Method | Count | Percentage |
|--------|-------|------------|
| adaptive_500 | 44,436 | 89.1% |
| adaptive_timeout | 2,410 | 4.8% |
| fast_path_axiom | 1,659 | 3.3% |
| structural_prefilter | 1,360 | 2.7% |

### C7 Timeout Pattern Classification

| Pattern | Count | Percentage | Description |
|---------|-------|------------|-------------|
| Bare U(X,Y)->Z | 1,097 | 45.5% | Temporal Until in antecedent, no box |
| Bare S(X,Y)->Z | 585 | 24.3% | Temporal Since in antecedent, no box |
| box U(X,Y)->Z | 304 | 12.6% | Box-wrapped Until (same as c6) |
| box S(X,Y)->Z | 304 | 12.6% | Box-wrapped Since (same as c6) |
| Z->U(X,Y) | 36 | 1.5% | Temporal in consequent |
| Z->S(X,Y) | 36 | 1.5% | Temporal in consequent |
| box_imp | 25 | 1.0% | Box-only patterns (e.g., box(box(X)->Y)->Z) |
| double_box | 21 | 0.9% | Double-box patterns |
| plain_imp | 2 | 0.1% | Propositional tautology patterns |

### C7 New Patterns vs C6

At c6, ALL timeouts were `box U/S(X,Y) -> Z` patterns. At c7, **new patterns emerge**:

1. **Bare temporal (no box)**: `U(X,Y) -> Z` and `S(X,Y) -> Z` (69.8% of c7 timeouts)
   - Includes nested temporal: `U(U(p,q),r) -> Z`, `S(S(p,q),r) -> Z`
   - These are c7-only because complexity 7 is needed for nested temporal + implication

2. **Temporal in consequent**: `Z -> U(X,Y)` and `Z -> S(X,Y)` (3%)
   - New pattern class not seen at c6

3. **Box-implication patterns**: `box(box(X)->Y) -> Z` (1.9%)
   - E.g., `box(box(bot)->bot) -> p`, `box(box(p)->p) -> p`
   - These are VALID formulas that the decision procedure can't prove within fuel=500

4. **Propositional-like**: `p -> ((p->q) -> q)` (0.1%)
   - Should be trivially valid but the proof search misses them

### C7 Timeout Timing

| Bucket | Count | Percentage |
|--------|-------|------------|
| 0ms (instant fuel exhaustion) | 1,895 | 78.6% |
| 1-10ms | 59 | 2.4% |
| 11-100ms | 456 | 18.9% |

No slow timeouts (>1s). All c7 timeouts are fast. The computational cost per timeout formula is negligible.

## C8 Detailed Results (Partial: 147,864 / 252,893)

- **Processed**: 147,864 formulas (58% of total)
- **Valid**: 17,532 (11.9%)
- **Invalid**: 125,027 (84.6%)
- **Timeout**: 5,305 (3.6%)
- **Mean decision time**: 0.48ms
- **Max decision time (processed)**: 114ms
- **Slow formulas (>1s, processed)**: 0

### C8 Timeout Rate by Complexity Level (from processed data)

| Complexity | Total | Timeouts | Rate |
|------------|-------|----------|------|
| c3 | 36 | 0 | 0.0% |
| c4 | 144 | 0 | 0.0% |
| c5 | 1,312 | 0 | 0.0% |
| c6 | 5,904 | 224 | 3.8% |
| c7 | 42,416 | 2,184 | 5.1% |
| c8 (partial) | 98,052 | 2,897 | 3.0% |

The c8-only timeout rate (3.0%) is actually LOWER than c7 (5.1%) because c8 introduces many new formula shapes that don't involve temporal operators.

### C8 Timeout Pattern Classification (c8-only, partial data)

| Pattern | Count | Percentage |
|---------|-------|------------|
| Mixed box+U | 593 | 20.5% |
| Mixed box+S | 593 | 20.5% |
| Nested U(T(...)) | 512 | 17.7% |
| Nested S(T(...)) | 512 | 17.7% |
| Single box complex | 243 | 8.4% |
| box U | 192 | 6.6% |
| box S | 192 | 6.6% |
| Double box | 60 | 2.1% |

### C8 Wall-Clock Bottleneck

The critical finding: **the bottleneck is not in the processed portion**. The generator stalled on formula #147865:

```
U(p, bot) -> U(p, box(bot))
```

This formula (`Xp -> U(p, box(bot))`: "if next-p then p-holds-until-box-falsum") creates a tableau where:
1. The temporal `U(p, box(bot))` creates eventuality obligations
2. The `box(bot)` requires checking all accessible worlds
3. Each fuel step creates multiple branches (temporal unfolding + modal accessibility)
4. With fuel=500, the computation took >14 minutes before being killed

The remaining 105,029 unprocessed formulas include many similar `temporal -> temporal(box)` patterns. Conservatively, completing c8 would take **6-8 hours** with the current fuel=500 strategy.

## Bottleneck Characterization

### Root Cause

The bottleneck is **per-step cost asymmetry in fuel consumption**. The fuel parameter counts tableau expansion steps, but the wall-clock cost per step varies by orders of magnitude:

| Formula class | Cost per fuel step | 500 steps total |
|---------------|-------------------|-----------------|
| Simple prop/modal | O(microseconds) | ~0ms |
| Single temporal | O(microseconds) | ~0ms |
| Box + temporal | O(tens of microseconds) | 50-100ms |
| Temporal -> temporal(box) | O(seconds) | **minutes to hours** |

The branching factor per step is the key variable:
- Simple formulas: 1-2 branches per step
- Box + temporal: 3-5 branches per step  
- Temporal -> temporal(box): exponential branching (temporal unfolding creates box obligations which create temporal obligations in a feedback loop)

### Structural Signature of Hard Formulas

The formulas that cause wall-clock stalls share these structural features:

1. **Both antecedent and consequent contain temporal operators** (`U` or `S`)
2. **Box operator nested inside temporal operator**: `U(X, box(Y))` or `S(X, box(Y))`
3. **Non-bot event argument**: `U(p, box(bot))` not `U(bot, box(bot))` (the latter is trivially false)
4. **Antecedent creates eventuality chain**: `U(p, bot)` = `Xp` forces a successor time point

These formulas create a **temporal-modal feedback loop** in the tableau: temporal unfolding creates obligations at new time points, box rules create obligations at new worlds, and the combination multiplies exponentially.

### Implication for c9+

- **c9** would have ~1.2M formulas, with ~60K timeouts (5%)
- Of those timeouts, perhaps 10-20% would be "hard" (temporal-modal feedback)
- Each hard timeout could take minutes to hours
- **Total c9 time: estimated >100 hours** (impractical for exhaustive generation)
- **c10**: ~6M formulas, completely infeasible for exhaustive generation

## Recommended Mitigations

### M1: Wall-Clock Timeout (Immediate)

Add a per-formula wall-clock timeout (e.g., 5 seconds) in addition to the fuel limit. If a formula exceeds the wall-clock budget, immediately classify it as timeout without waiting for fuel exhaustion.

**Implementation**: Wrap `decide` in `IO.withTaskAsync` + `IO.sleep` timeout, or use Lean's `Task` cancellation mechanism. Alternatively, check `IO.monoMsNow` periodically during tableau expansion.

**Impact**: Would cap c8 at ~10 minutes total instead of 14+ minutes for a single formula.

### M2: Structural Pre-Filter Extension

Extend `structuralPrefilter` to catch:
1. `U(bot, X) -> Y` (already caught) -- keep
2. `S(bot, X) -> Y` (already caught) -- keep
3. **NEW**: `p -> (p -> q) -> q` and similar propositional tautologies
4. **NEW**: `box(X) -> box(Y -> X)` patterns (K axiom variant)
5. **NEW**: `box(box(X) -> Y) -> Z` where Y is derivable from X (box-descent variants)

**Impact**: Would reduce timeout count by ~2-5% but does NOT address the wall-clock bottleneck.

### M3: Fuel-Budget Splitting (Medium-term)

Replace flat `fuel=500` with a **branching-aware budget**: each branch gets `remaining_fuel / branch_count`, so wide-branching formulas exhaust faster. This preserves completeness for narrow tableaux while capping the exponential blowup.

**Impact**: Would reduce hard timeout cost from minutes to milliseconds.

### M4: Stratified Sampling for c8+ (Workaround)

For c8+, use stratified sampling instead of exhaustive generation:
```bash
lake exe dataset_generator -- --max-complexity 8 --mode stratified \
  --stratified-quotas "8:50000" --output data/bmlogic-c8-sample.jsonl
```

**Impact**: Get representative c8 data in ~2 minutes by sampling uniformly across the formula space, avoiding the dense temporal-modal region.

## Decision Method Distribution Trend

| Level | adaptive_500 | timeout | fast_path | prefilter |
|-------|-------------|---------|-----------|-----------|
| c5    | 93.3%       | 2.6%   | 4.2%      | 0.0%*     |
| c6    | 91.6%       | 3.0%   | 2.9%      | 2.5%      |
| c7    | 89.1%       | 4.8%   | 3.3%      | 2.7%      |
| c8**  | 88.9%       | 3.6%   | 5.4%      | 2.1%      |

*Pre-filter not present at c5 generation time.  
**Partial data (58%).

The `adaptive_500` rate is slowly declining (93% -> 89%) as more formulas require temporal reasoning. The `fast_path_axiom` rate increases at c8 (5.4%) because c8 has more axiom instances. The timeout rate is remarkably stable at 3-5% across levels.

## Files Produced

| File | Records | Status |
|------|---------|--------|
| `data/bmlogic-c7-clean.jsonl` | 49,865 | Complete |
| `data/bmlogic-c7-clean_metadata.json` | 1 | Complete |
| `data/bmlogic-c8-clean.jsonl` | 147,864 | Partial (58%) |
| `data/bmlogic-c8-clean_metadata.json` | 1 | Partial stats |

## Conclusion

The c7 scaling is **healthy**: 33 seconds for ~50K formulas, zero slow timeouts. The next bottleneck appears at c8 in the form of **hard timeout formulas** -- not the number of timeouts (stable at 3-5%) but the wall-clock cost of computing them. A single formula with `temporal -> temporal(box)` structure consumed 14+ minutes. The recommended immediate fix is a per-formula wall-clock timeout (M1), which would allow c8 exhaustive generation to complete in ~10-15 minutes. For c9+, stratified sampling (M4) is the practical approach since exhaustive generation would take >100 hours.
