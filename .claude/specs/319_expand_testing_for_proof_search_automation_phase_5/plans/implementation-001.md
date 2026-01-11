# Implementation Plan: Task #319

**Task**: Expand testing for proof search automation (Phase 5)
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

This plan creates a comprehensive test suite for the proof search automation system, covering all components implemented in tasks 315-318. The approach prioritizes high-value tests (completeness verification for all 14 axioms, edge cases) while avoiding known limitations (decide timeout, noncomputable theorems). Tests will use `#eval` for runtime verification where `by decide` times out.

## Phases

### Phase 1: Axiom Completeness Tests

**Estimated effort**: 2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Verify all 14 TM axiom schemata are correctly identified by `matches_axiom`
2. Verify all axioms are provable by `modal_search`, `temporal_search`, and `propositional_search` tactics
3. Create systematic coverage for axiom variants

**Files to modify**:
- `LogosTest/Core/Automation/ProofSearchTest.lean` - Add axiom completeness tests

**Steps**:
1. Create section "Axiom Completeness Tests"
2. Add positive tests for all 14 axioms:
   - prop_k, prop_s, prop_exfalso, prop_peirce
   - modal_t, modal_4, modal_b, modal_5, modal_k
   - temp_4, temp_a, temp_l, temp_k
   - modal_future, temp_future
3. Add tests with different atomic formulas (p, q, r, complex atoms)
4. Verify each axiom is found at depth 1 (immediate match)

**Verification**:
- `lake build LogosTest.Core.Automation.ProofSearchTest` succeeds
- All 14 axioms tested with at least 3 variants each

---

### Phase 2: Edge Case Test Suite

**Estimated effort**: 2.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create systematic edge case test file
2. Test formula complexity variations
3. Test context size variations
4. Test depth and limit variations

**Files to create**:
- `LogosTest/Core/Automation/EdgeCaseTest.lean` - New dedicated edge case tests

**Steps**:
1. Create new test file with structure:
   - Section: Empty Context Tests
   - Section: Deep Nesting Tests (depth 1-5 of modal/temporal operators)
   - Section: Large Context Tests (5, 10, 15 formulas)
   - Section: Complex Formula Tests (mixed operators)
   - Section: Depth Limit Tests (verify search respects limits)
   - Section: Visit Limit Tests (verify search respects visit limits)
2. Implement empty context tests for all axiom types
3. Implement deep nesting tests: `□□□p`, `□□□□p`, `GGGGp`
4. Implement large context tests with many formulas
5. Implement mixed modal/temporal formula tests

**Verification**:
- `lake build LogosTest.Core.Automation.EdgeCaseTest` succeeds
- At least 30 new edge case tests

---

### Phase 3: Negative Tests and Error Handling

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Verify non-derivable formulas are correctly rejected
2. Test search termination on impossible goals
3. Test limit enforcement behavior

**Files to modify**:
- `LogosTest/Core/Automation/ProofSearchTest.lean` - Add negative test section

**Steps**:
1. Create section "Negative Tests"
2. Add tests for non-axiom formulas that should NOT be found:
   - Random implications: `p → q` (not an axiom instance)
   - Partial axiom matches: `□p` alone (not an axiom)
   - Contradictions: formulas that don't match any schema
3. Add #eval tests verifying `search` returns `found = false` appropriately
4. Add visit limit enforcement tests (already one exists, add more)
5. Add depth limit enforcement tests

**Verification**:
- All tests pass
- At least 10 negative test cases

---

### Phase 4: Performance Benchmarks with Timing

**Estimated effort**: 2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Add wall-clock timing to benchmark suite
2. Create performance baseline document
3. Add strategy comparison with timing

**Files to modify**:
- `LogosTest/Core/Automation/ProofSearchBenchmark.lean` - Add timing
- `.claude/specs/319_expand_testing_for_proof_search_automation_phase_5/benchmarks/performance-baseline.md` - New

**Steps**:
1. Add timing wrapper using `IO.monoNanosNow`:
   ```lean
   def timed (action : IO α) : IO (α × Nat) := do
     let start ← IO.monoNanosNow
     let result ← action
     let end_ ← IO.monoNanosNow
     return (result, end_ - start)
   ```
2. Update `runBenchmark` to capture timing
3. Add timing to BenchmarkResult structure
4. Create comprehensive timing benchmark run
5. Document baseline performance metrics

**Verification**:
- Benchmark suite runs with timing output
- Baseline document created with metrics

---

### Phase 5: Integration Tests and Documentation

**Estimated effort**: 2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create integration tests combining multiple tactics
2. Test tactic interaction with manual proof steps
3. Update test documentation with coverage summary

**Files to modify**:
- `LogosTest/Core/Automation/TacticsTest.lean` - Add integration section
- `docs/ProjectInfo/TESTING.md` - Update coverage (if exists) or note in summary

**Steps**:
1. Add section "Integration Tests" to TacticsTest.lean
2. Create tests combining tactics with manual steps:
   - `modal_search` followed by manual `simp`
   - Manual `apply` followed by `propositional_search`
   - Chained tactic applications
3. Test state preservation after failed search
4. Create test coverage summary documenting:
   - Total test count
   - Coverage by component
   - Known limitations

**Verification**:
- All integration tests pass
- Documentation updated

---

## Dependencies

- Tasks 315, 316, 317, 318 completed (all done)
- Lean 4 and Mathlib available
- LogosTest build infrastructure working

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Decide timeout on complex tests | Med | High | Use #eval instead of `by decide` |
| Noncomputable theorem limitations | Low | Med | Test via tactic mode only |
| Build time increase from many tests | Low | Med | Organize tests efficiently |
| False negatives in negative tests | Med | Low | Carefully design non-derivable formulas |

## Success Criteria

- [ ] All 14 axioms have completeness tests
- [ ] At least 30 edge case tests added
- [ ] At least 10 negative tests added
- [ ] Performance benchmarks include timing
- [ ] Integration tests for tactic combinations
- [ ] All tests pass (`lake build LogosTest`)
- [ ] Test count documented in summary

## Rollback Plan

If implementation fails:
1. Revert new test files
2. Keep existing tests unchanged
3. Document what tests couldn't be implemented and why

## Estimated Total Effort

- Phase 1: 2 hours
- Phase 2: 2.5 hours
- Phase 3: 1.5 hours
- Phase 4: 2 hours
- Phase 5: 2 hours
- **Total**: 10 hours
