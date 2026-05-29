# Implementation Summary: Task #210

- **Task**: 210 - enumerator_complexity_blowup
- **Status**: Implemented
- **Session**: sess_1780087242_1913db
- **Date**: 2026-05-29

## What Changed

### Phase 1: Exact-complexity enumeration with memoization
- Created `enumExactHelper` and `enumExactBudget`: memoized functions that generate formulas of EXACTLY a given complexity, eliminating the 651x bloat from "up to budget" semantics
- Rewrote `enumHelper`, `enumerateAtBudget`, `enumerateExhaustive`, and `enumerateUpToDepth` as backward-compatible wrappers over the new exact-complexity core
- Memoization cache (`Std.HashMap (Nat x Nat x Nat) (List Formula)`) shared across complexity levels via pure state threading
- Removed `eraseDups` from the main enumeration path (exact-complexity levels are disjoint by construction)

### Phase 2: Axiom-schema instantiation
- Added `instantiateAxiom`: generates random instances of 8 high-yield axiom schemata (prop_s, prop_k, ex_falso, peirce, modal_t, modal_4, modal_b, modal_k_dist)
- Added `generateValidFromMP` and `generateValidFromNec` for modus ponens and necessitation closure
- Added `generateValidBatch`: incremental pool strategy with seed, 2x necessitation rounds, and 2x MP rounds

### Phase 3: DatasetGenerator integration
- Added `validSeedCount` field to `EnumParams` (default: 500)
- Updated `generateFormulas` to combine exhaustive enumeration, random sampling, and axiom-seeded valid formulas with deduplication

### Phase 4: Validation
- Created `enum_benchmark` executable (`lake exe enum_benchmark`)
- Timing results (compiled): complexity 5 = 1ms, complexity 6 = 0ms, complexity 7 = 3ms (all gates PASS)
- Formula counts: complexity 5 = 1,644 (levels 1-5), complexity 7 = 51,244 (levels 1-7)
- Axiom-only pool: 60% confirmed valid by decision procedure, 40% timeout (all valid by construction)

### Phase 5: Cleanup
- Full project build passes (1678 jobs, zero errors)
- No sorry, no new axioms, no vacuous definitions

## Performance Improvement

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Complexity 5 raw formulas | 937,036 | 1,644 | 570x reduction |
| Complexity 5 time | >1.5 hours | 1 ms | >5,400,000x faster |
| Complexity 7 raw formulas | 650,043,020 | 51,244 | 12,688x reduction |
| Complexity 7 time | Infeasible | 3 ms | Now feasible |
| Valid fraction (axiom-only) | 0% (none generated) | 60% confirmed | New capability |

## Files Modified

- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- core rewrite (exact-complexity, memoization, axiom instantiation)
- `Theories/Bimodal/Automation/EnumBenchmark.lean` -- new benchmark executable
- `lakefile.lean` -- added `enum_benchmark` target

## Plan Deviations

- **Task 1.2**: Used pure state threading via foldl instead of `IO.Ref` for memoization (avoids IO dependency for pure enumeration)
- **Task 1.4**: Removed `eraseDups` entirely rather than adding debug assertion (exact-complexity levels are provably disjoint)
- **Task 1.7**: Wall-clock time cap (Strategy D) deferred -- enumeration completes in 0-3ms, making time caps unnecessary
- **Task 4.1**: Benchmark placed in `Theories/Bimodal/Automation/EnumBenchmark.lean` as a lake exe target instead of `Tests/BimodalTest/`
