# Implementation Summary: Task #213

- **Task**: 213 - Production-scale dataset generation validation
- **Status**: Implemented
- **Plan**: specs/213_production_scale_dataset_validation/plans/01_production-validation-plan.md
- **Session**: sess_1780090111_5249cc

## Changes Made

### Phase 1: CLI Flag and Run Script Update
- Added `validSeedCount : Nat := 500` field to `CLIArgs` in `DatasetExport.lean`
- Added `--valid-seed-count` CLI parsing and banner display
- Wired `CLIArgs.validSeedCount` into `EnumParams` construction
- Updated run script: medium (complexity 4->5, 2K seeds), deep (random->exhaustive, 5K seeds)
- Added `production` run target (complexity 7, 60K formulas, 5K seeds)

### Phase 2: Temporal Axiom Seeds and Subformula Coverage
- Extended `randomSubFormula` from 4 to 6 branches: added `all_future`, `untl`, `snce`
- Added 6 temporal axiom schemata to `instantiateAxiom`: serial_future/past, connect_future/past, right_mono_until, F_until_equiv
- Rebalanced from 8 to 14 total schemata (ex_falso weight: 12.5% -> 7.1%)

### Phase 3: Streaming Write and OOM Prevention
- Refactored `main` to streaming label+write pipeline: label each formula, write JSONL line immediately, accumulate lightweight stats only
- Added progress reporting every 1000 formulas with valid%, elapsed time
- Replaced `List.eraseDups` (O(n^2)) with `hashDedup` using `Std.HashMap` (O(n))
- Metadata computed from running accumulators, not list scan

### Phase 4: Nec/MP Fixpoint Closure and Theorem Seed Integration
- Replaced fixed 2-round Nec/MP closure with fixpoint loop (stops when: growth <1%, pool >10K, or 10 rounds)
- Added 36 theorem seed formulas from task 212 registry (combinators, modal S4/S5, temporal derived, perpetuity principles)
- Implemented ex_falso cap: limit bot->phi patterns to 20% of seed pool, replace excess with non-ex_falso instances

### Phase 5: Full Pipeline Regression Run
- Complexity 5: 1,513 formulas, 4% valid, 3% timeout, 1.3s wall-clock
- Complexity 7: 49,904 formulas, 3% valid (1,687), 3% timeout (1,500), 17.3s wall-clock
- No OOM crashes, streaming write works correctly at 50K scale
- JSONL output passes Python JSON parse validation
- All 49,904 IDs unique, metadata consistent with JSONL record count
- 4 operator categories represented

### Phase 6: Benchmark Update
- Updated `EnumBenchmark.lean` with temporal seed testing, middle-of-pool sampling, ex_falso analysis
- Added `benchmarkFullPipeline` function for complexity 7 end-to-end validation
- Feasibility gate results:
  - Timeout rate: 5% [PASS, target <20%]
  - Category diversity: 4 categories [PASS, target >=3]
  - Valid fraction: 4% [BELOW TARGET, target >=15%]

## Feasibility Gate Summary

| Gate | Target | Result | Status |
|------|--------|--------|--------|
| Timeout rate | <20% | 3-5% | PASS |
| Category diversity | >=3 | 4 | PASS |
| Valid fraction | >=15% | 3-4% | GAP |
| Ex_falso dominance | <50% of valid | ~90% overall, ~25% in seed-only | PARTIAL |
| OOM prevention | No crash at 50K | No crash | PASS |
| Streaming write | Works | Works | PASS |
| JSONL integrity | Parseable | All records parse | PASS |

## Valid Fraction Gap Analysis

The valid fraction improved from the 1.6% baseline (task 204, random mode) to 3-4% (exhaustive + axiom seeds), but remains below the 15% target. Root causes:

1. **Exhaustive enumeration dominance**: The 51K exhaustive formulas vastly outnumber the ~2K axiom-seeded valid formulas. Most enumerated formulas are structurally invalid.
2. **Ex_falso regeneration**: The 20% cap on ex_falso seeds is effective in the seed pool, but Nec/MP closure regenerates ex_falso variants (boxing ex_falso, etc.).
3. **Decision procedure timeouts**: ~3% of formulas time out, particularly complex temporal axiom instances.

**Recommended next steps** for valid fraction improvement:
- Parallel labeling via `IO.asTask` (3-4x throughput improvement)
- Decision time filtering (exclude formulas that would timeout, skewing the valid/invalid ratio)
- Increased seed-to-exhaustive ratio (more axiom seeds relative to enumerated formulas)
- Contrastive filtering (use FormulaMutator to generate near-misses of valid formulas)

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI flag, streaming write, progress reporting |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Temporal seeds, fixpoint closure, HashMap dedup, theorem seeds |
| `Theories/Bimodal/Automation/EnumBenchmark.lean` | Updated benchmarks, full pipeline test, diversity checks |
| `scripts/run_dataset_generation.sh` | Updated parameters, added production target |

## Plan Deviations

- **Task 2.3** (rebalance to reduce ex_falso): *(deviation: altered -- implemented as 14 uniform-weighted schemata instead of explicit weight table; ex_falso is index 2 out of 0-13)*
- **Task 4.2** (theorem seed integration): *(deviation: altered -- created direct Formula values instead of importing ProofStepExtractor dependency; avoids circular import)*
- **Task 5.3** (compare to task 204 baselines): *(completed -- valid fraction 3% vs 1.6% baseline, but 15% target not met)*
- **Task 6.4** (document remaining bottlenecks): *(completed -- documented in gap analysis above and in benchmark notes)*
