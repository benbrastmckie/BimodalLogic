# Implementation Summary: Task 204 -- Production Dataset Generation

**Task**: 204 -- Run production dataset generation (medium and deep runs)
**Status**: Completed
**Session**: sess_1748563200_orch204
**Date**: 2026-05-29

## What Was Done

Executed the BMLogic dataset generator at production scale in two runs, producing labeled training data for downstream ML tasks. Created a reproducible shell script for future re-runs.

## Production Run Results

### Medium Run

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Records | ~5000 | 5,136 | PASS |
| Valid fraction | >= 15% | 25% (1,284) | PASS |
| Timeout rate | < 20% | 3% (166) | PASS |
| Category diversity | 3+ types | 4 types | PASS |
| File size | - | 4.2 MB | - |

**Parameters**: complexity 4, exhaustive mode, modal/temporal depth 2, include-duals
**Categories**: Implication (4,220), Until (432), Since (432), Box (52)
**Splits**: train 4,124 / val 483 / test 529

### Deep Run

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Records | ~50,000 | 53,979 | PASS |
| Valid fraction | >= 15% | 1.6% (888) | **FAIL** |
| Timeout rate | < 20% | 2.5% (1,361) | PASS |
| Category diversity | 3+ types | 4 types | PASS |
| File size | - | 49.1 MB | - |

**Parameters**: complexity 7, random mode, modal/temporal depth 2, include-duals
**Categories**: Implication (15,330), Until (14,110), Since (14,110), Box (10,429)
**Complexity distribution**: 3:36, 4:144, 5:1312, 6:5420, 7:20215, 8:13421, 9:10772, 10:2080, 11:571, 12:8
**Splits**: train 43,281 / val 5,364 / test 5,334

### Combined Dataset

| Metric | Value |
|--------|-------|
| Total records | 59,115 |
| Total valid | 2,172 (3.7%) |
| Total invalid | 55,416 |
| Total timeout | 1,527 |
| Combined size | 53.3 MB |

## Feasibility Gate Assessment

**Medium run**: All 3 gates PASSED (timeout 3% < 20%, valid 25% >= 15%, 4 categories >= 3).

**Deep run**: 2 of 3 gates PASSED. The valid fraction gate FAILED (1.6% < 15%). This is expected behavior for random sampling at high complexity -- most randomly generated bimodal logic formulas are not theorems. The research report predicted this outcome.

**Mitigation for task 205**: The medium run provides good valid/invalid balance for benchmark curation. The deep run provides volume and complexity diversity. Task 205 should use the medium run as the primary source for balanced sampling and the deep run for hard-formula selection.

## Plan Deviations

1. **Medium run complexity reduced from 5 to 4**: Exhaustive enumeration at complexity 5 with any modal/temporal depth does not terminate within reasonable time (>1.5 hours). The `enumerateAtBudget` function creates Cartesian products of all possible sub-formula trees without memoization, causing exponential blowup. Complexity 4 produces 5K+ formulas with good diversity.

2. **Medium run depth reduced from 3 to 2**: Even at complexity 4, depth 3 causes similar blowup. Depth 2 (the CLI default) works reliably.

3. **Deep run mode changed from hybrid to random**: Hybrid mode uses exhaustive enumeration up to min(5, maxComplexity), which triggers the same exponential blowup. Random mode avoids this entirely by generating formulas individually via IO.rand.

4. **Deep run depth reduced from 3 to 2**: Consistent with medium run adjustment.

## Issues Discovered

### Exhaustive Enumeration Bottleneck

The `enumerateAtBudget` function in `FormulaEnumerator.lean` generates all possible formula ASTs via Cartesian products of sub-formula lists without memoization. This is O(exponential) in complexity. At complexity 5 with 3 atoms and 4 constructors, the enumeration does not terminate within 1.5+ hours. This is a known limitation of the batch-oriented pipeline.

**Recommendation**: A future task should implement either (a) memoized enumeration, (b) incremental enumeration with early termination, or (c) streaming export to avoid holding all formulas in memory. For now, random mode is the practical workaround for complexity 5+.

### Low Valid Fraction at High Complexity

Random sampling at complexity 7 produces only 1.6% valid formulas. This is because:
- Most randomly generated bimodal logic formulas are not theorems
- Valid formulas require specific structural patterns (axiom instances, derived theorems)
- The validity rate drops rapidly with increasing complexity

**Recommendation for task 205**: Use enrichment strategies (seeding with known valid formulas, axiom instance generation, mutation of valid formulas) to boost the valid fraction in the benchmark.

## Output Files

| File | Records | Size | Description |
|------|---------|------|-------------|
| `data/bmlogic-medium.jsonl` | 5,136 | 4.2 MB | Complexity 4, exhaustive, 25% valid |
| `data/bmlogic-medium_metadata.json` | - | <1 KB | Medium run metadata |
| `data/bmlogic-deep.jsonl` | 53,979 | 49.1 MB | Complexity 7, random, 1.6% valid |
| `data/bmlogic-deep_metadata.json` | - | <1 KB | Deep run metadata |
| `scripts/run_dataset_generation.sh` | - | - | Reproducible run script |

All JSONL files are covered by `data/.gitignore` and excluded from version control.

## Guidance for Downstream Tasks

### Task 205 (Benchmark Curation)

- **Primary source**: `data/bmlogic-medium.jsonl` -- best valid/invalid balance (25% valid)
- **Hard formulas**: `data/bmlogic-deep.jsonl` -- complexity 7+ formulas for "hard" and "very hard" tiers
- **Known valid anchors**: Both files contain valid formulas with proof traces including axiom identifiers
- **Diversity**: 4 GoalCategory types across both files (Box, Implication, Until, Since)
- **Valid fraction enrichment needed**: The deep run's 1.6% valid fraction means ~888 valid formulas -- enough for a held-out benchmark but enrichment via axiom instance generation will help balance

### Task 206 (Contrastive Pairs)

- Use the valid formulas from both runs as seeds for mutation-based contrastive pair generation

### Task 207 (Multi-representation Export)

- Both JSONL files contain `formula_str`, `formula_ast`, and `pattern_key` fields that can be extended with additional representations
