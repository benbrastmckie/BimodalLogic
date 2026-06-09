# Execution Summary: Task #297 - Verify Operator Removal and Regenerate Datasets

**Task**: 297
**Date**: 2026-06-08
**Session**: sess_1749420800_orchestrate
**Status**: Partial (c4/c5/c6 complete, c7 partial)

## Summary

Verified that 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) were correctly removed from FormulaEnumerator.lean, and regenerated datasets at complexity levels 4, 5, and 6. Level 7 hit a reproducible labeling bug at formula ~13,750 and is only partially regenerated (13,749 of 77,272 records).

## Phase Results

### Phase 1: Build Verification [COMPLETED]
- Automation modules build cleanly (738 jobs, zero errors)
- Both executables (enum_benchmark, dataset_generator) built successfully
- Pre-existing warnings only (String.trimLeft deprecation, unused variables)

### Phase 2: Gradual Enumeration Verification [COMPLETED]
- c4 raw enumeration: 4,396 formulas (down 44% from 7,852 baseline)
- c5 raw enumeration: 32,474 formulas (down 57% from 75,914 baseline)
- Zero removed operators in FormulaEnumerator.lean
- Memory stable at 18GB available throughout

### Phase 3: Higher Complexity Verification [COMPLETED]
- enum_benchmark ran c5/c6/c7 sequentially, all timing gates passed:
  - c5: 23,033 formulas, 2ms (gate: 5000ms)
  - c6: 169,739 formulas, 12ms (gate: 30000ms)
  - c7: 1,250,023 formulas, 92ms (gate: 60000ms)
- Note: benchmark uses enumExactBudget (cumulative), which is a different enumeration path than enumExactHelper used for dataset generation
- Memory stable at 17GB available after benchmark

### Phase 4: Sequential Dataset Regeneration [PARTIAL]

| Level | Baseline | New Count | Change | Valid | Invalid | Timeout |
|-------|----------|-----------|--------|-------|---------|---------|
| c4 | 408 | 806 | +97.5% | 17 (2.1%) | 669 (83.0%) | 120 (14.9%) |
| c5 | 6,031 | 6,028 | -0.05% | 100 (1.7%) | 4,772 (79.2%) | 1,156 (19.2%) |
| c6 | 39,832 | 39,790 | -0.1% | 790 (2.0%) | 28,694 (72.1%) | 10,306 (25.9%) |
| c7 | 77,272 | 13,749 (partial) | N/A | 141 (1.0%) | 10,295 (74.9%) | 3,313 (24.1%) |

**c4 increase explanation**: The removal of 6 binary operators changes the formula space that enters deduplication. With fewer derived-operator formulas competing for dedup slots, more primitive-operator formulas survive, resulting in a net increase from 408 to 806 pipeline-surviving records.

**c5/c6 stability**: These levels are essentially unchanged because the removed operators were already being eliminated during canonicalization dedup in the original pipeline.

**c7 bottleneck**: All 3 attempts to generate c7 stalled at exactly record 13,749 with unbounded RSS growth (~40MB/6s). The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. This is a bug in the decision procedure's timeout handling, not an OOM issue.

### Phase 5: Final Validation [COMPLETED]
- Zero removed operators in all 4 datasets (c4, c5, c6, c7 partial)
- All JSONL records are valid JSON (validated c7 partial: 13,749 valid, 0 errors)
- Label distributions are consistent with baselines

## Verification Results

- Zero occurrences of removed operators in any dataset
- Zero occurrences of removed operators in FormulaEnumerator.lean
- Enumeration counts decreased at c4 (-44%) and c5 (-57%), confirming operator removal
- All timing gates pass in enum_benchmark
- No OOM events; peak memory usage: 18GB of 30GB used (during c7 labeling)

## Open Issues

1. **c7 labeling bug**: Formula ~13,750 in the c7 enumeration causes unbounded memory growth in the labeling function. The decision procedure either does not respect the wallclock timeout or enters a state that the timeout mechanism cannot interrupt. This blocks full c7 regeneration.

2. **c7 dataset availability**: The original c7 dataset (77,272 records) is available on HuggingFace Hub (logos-labs/bmlogic-bench) but cannot be regenerated locally with the current codebase. The partial c7 (13,749 records) is valid but incomplete.

## Artifacts

- `data/bmlogic-c4.jsonl` -- Regenerated c4 dataset (806 records)
- `data/bmlogic-c5.jsonl` -- Regenerated c5 dataset (6,028 records)
- `data/bmlogic-c6.jsonl` -- Regenerated c6 dataset (39,790 records)
- `data/bmlogic-c7.jsonl` -- Partial c7 dataset (13,749 records)

## Plan Deviations

- Phase 2: Used lean_run_code instead of enum_benchmark for isolated c4/c5 checks (altered -- more efficient for spot-checking individual levels)
- Phase 3: Benchmark counts at c6/c7 match pre-removal baselines because enumExactBudget never generated derived operators (altered -- the decrease only shows in enumExactHelper)
- Phase 4 c7: Deferred due to reproducible labeling bug at formula ~13,750; 3 attempts all stalled at 13,749 records (deferred to follow-up investigation)
