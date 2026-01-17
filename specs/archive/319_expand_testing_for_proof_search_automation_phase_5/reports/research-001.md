# Research Report: Task #319

**Task**: Expand testing for proof search automation (Phase 5)
**Date**: 2026-01-10
**Focus**: General research - existing infrastructure and testing gaps

## Summary

Task 319 is Phase 5 of the proof search automation project (task 260). The goal is to add comprehensive tests covering all phases: proof term construction (task 315), tactic integration (task 316), BFS/IDDFS variant (task 317), and advanced heuristics (task 318). The existing test infrastructure provides a solid foundation with 134 tactic tests and benchmark suites, but significant gaps exist in property-based testing, soundness verification, edge cases, and performance benchmarks with timing metrics.

## Findings

### 1. Existing Test Infrastructure

#### Test Files
| File | Tests | Coverage |
|------|-------|----------|
| `LogosTest/Core/Automation/TacticsTest.lean` | 134 | Tactic functionality |
| `LogosTest/Core/Automation/ProofSearchTest.lean` | ~50 | Search algorithms |
| `LogosTest/Core/Automation/ProofSearchBenchmark.lean` | 17 | Performance |
| `LogosTest/Core/Automation/TacticsTest_Simple.lean` | Minimal | Basic tests |

#### Testing Patterns Used
1. **rfl proofs**: `example : matches_axiom (...) = true := rfl`
2. **by decide**: `example : heuristic_score {} [] (...) = 0 := by decide`
3. **#eval tests**: Runtime verification with IO output
4. **Tactic tests**: `example : ⊢ φ := by modal_search`
5. **Benchmark suites**: Structured performance comparison

### 2. Core Components to Test

#### ProofSearch.lean (~740 lines)
- `matches_axiom`: Tests 14 TM axiom schemata (tested)
- `bounded_search`: Depth-limited DFS (partially tested)
- `iddfs_search`: Complete search (tested)
- `search`: Unified interface with strategies (tested)
- `heuristic_score`, `advanced_heuristic_score`: Scoring functions (tested)
- `orderSubgoalsByScore`, `orderSubgoalsByAdvancedScore`: Ordering (disabled due to decide timeout)
- `SearchStats`: Visit/hit/miss tracking (tested)
- `ProofCache`: Memoization (disabled tests due to decide timeout)

#### Tactics.lean (~1400 lines)
- `modal_search`: General bounded proof search (28 embedded tests, 24 in TacticsTest)
- `temporal_search`: Temporal-optimized search (tested)
- `propositional_search`: Propositional-optimized search (tested)
- `SearchConfig`: Configuration structure (tested)
- Helper functions: `tryAxiomMatch`, `tryAssumptionMatch`, `tryModusPonens`, `tryModalK`, `tryTemporalK` (indirectly tested)

### 3. Testing Gaps Identified

#### Gap 1: Property-Based Tests
**Current**: No property-based tests exist
**Needed**:
- Soundness: If `modal_search` succeeds, the derivation is valid
- Completeness: If an axiom schema matches, `matches_axiom` returns true
- Monotonicity: Adding to context doesn't break existing proofs
- Idempotency: Re-running search yields same result

#### Gap 2: Edge Cases
**Current**: Most tests use simple formulas (`p`, `q`, `p.imp q`)
**Needed**:
- Empty context: `[] ⊢ φ` for various φ
- Very deep nesting: `□□□□p`, `GGGGp`
- Complex formulas: Mix of modal/temporal/propositional operators
- Large context: 10+ formulas in context
- Unicode/special atom names

#### Gap 3: Performance Benchmarks with Timing
**Current**: Visit counts only, no wall-clock timing
**Needed**:
- Timing metrics for search operations
- Memory usage estimates
- Comparison of strategies at different depths
- Regression testing for performance

#### Gap 4: SearchConfig Weight Tests
**Current**: Weights are defined but marked "not yet used in search ordering"
**Needed**:
- If weights are implemented: Test different configurations affect ordering
- If not: Document as known limitation, test defaults work

#### Gap 5: Soundness Verification
**Current**: Tests verify tactics succeed, not that results are correct
**Needed**:
- Verify constructed `DerivationTree` matches expected structure
- Test that invalid goals correctly fail
- Test error messages are helpful

#### Gap 6: Negative Tests
**Current**: Limited negative test coverage
**Needed**:
- Non-derivable formulas correctly fail
- Invalid syntax handling
- Timeout behavior
- Visit limit enforcement (one test exists)

#### Gap 7: Integration Tests
**Current**: Tests are mostly unit-level
**Needed**:
- Multi-step proofs combining tactics
- Tactic interaction with manual proof steps
- Error recovery and state preservation

### 4. Related Task Insights

#### Task 315 (Prop vs Type Resolution)
- Implemented 3 tactics: `modal_search`, `temporal_search`, `propositional_search`
- 24 new tests added (Tests 111-134)
- Known limitation: SearchConfig weights not yet used

#### Task 317 (IDDFS)
- 8 test cases added
- 1 expected failure documented (modus ponens blocked by task 315)
- Benchmarks show 0% overhead for shallow proofs

#### Task 318 (Advanced Heuristics)
- Domain-specific heuristics: `modal_heuristic_bonus`, `temporal_heuristic_bonus`
- 17 benchmark proofs
- Context-based MP tests fail due to task 315 blocker

### 5. Testing Framework Constraints

#### Decide Timeout
Several tests disabled due to `decide` tactic timing out on complex computations:
- `orderSubgoalsByScore` tests (mergeSort not efficiently reducible)
- `bounded_search` tests
- `ProofCache` tests

**Workaround**: Use `#eval` for runtime verification instead of `by decide`

#### Noncomputable Theorems
Some theorems are `noncomputable` due to `Classical.choose`:
- `generalized_modal_k`
- `generalized_temporal_k`

**Impact**: Cannot use direct computation in tests, must use tactic mode

## Recommendations

### Priority 1: Property-Based Tests (High Value)
1. Implement `test_soundness`: For each tactic, verify derivation is valid
2. Implement `test_completeness_axioms`: All 14 axioms should be found
3. Create test generator for random formulas

### Priority 2: Edge Case Coverage (Medium Value)
1. Create systematic edge case test file
2. Test depth limits: 1, 5, 10, 20, 50
3. Test context sizes: 0, 1, 5, 10
4. Test formula complexity levels

### Priority 3: Performance Benchmarks (Medium Value)
1. Add timing to benchmark suite
2. Create performance regression tests
3. Document baseline metrics

### Priority 4: Negative Tests (Medium Value)
1. Test non-derivable formulas fail gracefully
2. Test error messages are informative
3. Test timeout/limit enforcement

### Priority 5: Integration Tests (Lower Value)
1. Multi-step proof tests
2. Tactic combination tests
3. State preservation tests

## References

- `Logos/Core/Automation/ProofSearch.lean`: Core search algorithms
- `Logos/Core/Automation/Tactics.lean`: Tactic implementations
- `LogosTest/Core/Automation/TacticsTest.lean`: Existing test suite
- `LogosTest/Core/Automation/ProofSearchBenchmark.lean`: Benchmark framework
- Task 315 summary: Tactic implementation details
- Task 317 summary: IDDFS implementation
- Task 318 summary: Heuristics implementation

## Next Steps

1. Create implementation plan with phased approach
2. Start with property-based soundness tests
3. Add systematic edge case coverage
4. Enhance benchmark suite with timing
5. Document test coverage metrics
