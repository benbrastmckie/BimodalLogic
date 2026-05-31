# Implementation Summary: Anchor Coverage Expansion (14/42 to 42/42)

- **Task**: 220 - Anchor coverage expansion (14/42 -> 42/42 axiom constructors)
- **Status**: Implemented
- **Plan**: specs/220_anchor_coverage_expansion/plans/01_anchor-coverage-plan.md
- **Session**: sess_1748619600_orch220

## What Changed

### Phase 1: Extended matchAxiom to All 42 Constructors

**File**: `Theories/Bimodal/Automation/ProofSearch/Core.lean`

- Added 29 missing pattern-match branches to `matchAxiom`, covering all 42 BX axiom constructors (was 13/42)
- Fixed 5 broken existing patterns (`modal_b`, `modal_5_collapse`, `connect_future`, `prior_UZ`, `prior_SZ`) that used inconsistent half-expanded formula forms mixing derived operators (`.all_future`, `.all_past`) with raw `.imp ... .bot` negation patterns
- Root cause of broken patterns: Lean 4 unfolds `def` abbreviations in match patterns, but only the OUTERMOST unfolding is applied. Patterns like `.imp (.all_future (.imp phi .bot)) .bot` (intended to match `some_future phi`) fail because `some_future` is defined as `.untl phi top`, NOT as `neg (all_future (neg phi))`
- Refactored `matches_axiom` (Bool variant) to delegate to `matchAxiom` via `(matchAxiom phi).isSome`, eliminating duplicated pattern logic

### Phase 2: Axiom-Based Labeling with Top-3 Selection

**File**: `Theories/Bimodal/Automation/BenchmarkAnchors.lean`

- Added `labelViaAxiomMatch`: labels formulas via `matchAxiom` directly, bypassing the tableau decision procedure. Base axioms (37) get label `.valid`; non-Base axioms (5: prior_UZ, prior_SZ, z1, density, dense_indicator) get label `.invalid`
- Added `selectTopInstances`: groups instances by axiom name, sorts by formula complexity ascending, takes top-N per constructor
- Modified `main` to use axiom matching first (100% match rate), with fallback to `labelFormula`/`decideAuto` if needed
- Result: 110 records (8 ground * 1 + 34 parameterized * 3), 97 valid, 13 invalid, 0 timeout

### Phase 3: axiom_name Preservation in Finalize Pipeline

**File**: `scripts/finalize_benchmark.py`

- Added `axiom_name` to final record dict construction, resolving from top-level field or `augmentation.axiom_name`
- Added recount of axiom constructors from final records for accurate metadata reporting

### Phase 4: Full Pipeline Regeneration

- Regenerated: `data/axiom-instances.jsonl` (110 records, 42/42 coverage)
- Regenerated: `data/bmlogic-bench.jsonl` (777 records, up from 727)
- Regenerated: `data/bmlogic-bench_metadata.json` (39/42 constructors in final output)

## Key Metrics

| Metric | Before | After |
|--------|--------|-------|
| matchAxiom patterns | 13/42 (5 broken) | 42/42 (all working) |
| Axiom instances output | 724 (all, unlabeled) | 110 (top-3 per constructor, labeled) |
| Axiom match rate | ~8/42 constructors valid | 37/42 valid, 5/42 invalid (correct) |
| axiom_name in final benchmark | 0 records | 60 records |
| Benchmark size | 727 records | 777 records |
| Axiom constructors in final | 0/42 (stripped) | 39/42 (3 deduplicated) |

## Plan Deviations

1. **Phase 2, Task 2.4**: Instance count is 110 not 126 because 8 ground axioms have only 1 instance each (8*1 + 34*3 = 110). This is inherent to the axiom structure -- ground axioms have no parameters to vary.
2. **Phase 4, coverage**: 39/42 axiom constructors in final output (not 42/42) because `ex_falso`, `modal_4`, and `dense_indicator` have their simplest formulas deduplicated against the production pool. The axiom-instances.jsonl has 42/42.
3. **Phase 4, size**: 777 records (slightly below 800 target) due to stratified sampling constraints.
4. **Phase 4, regression**: 2 label changes (invalid -> valid) are corrections, not regressions. Both are axiom instances that were wrongly labeled invalid by the old broken `matchAxiom` patterns.
5. **Phase 1, bonus**: Fixed 5 broken existing patterns and refactored `matches_axiom` to delegate to `matchAxiom`.

## Files Modified

- `Theories/Bimodal/Automation/ProofSearch/Core.lean` -- Extended `matchAxiom` to 42/42, fixed 5 broken patterns, refactored `matches_axiom`
- `Theories/Bimodal/Automation/BenchmarkAnchors.lean` -- Added `labelViaAxiomMatch`, `selectTopInstances`, modified `main` pipeline
- `scripts/finalize_benchmark.py` -- Added `axiom_name` to final record dict
- `data/bmlogic-bench.jsonl` -- Regenerated (777 records)
- `data/bmlogic-bench_metadata.json` -- Regenerated (39/42 coverage)
