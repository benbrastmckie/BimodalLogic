# Implementation Plan: Automation Tactics

**Task**: 259 - Automation Tactics  
**Status**: [PLANNED]  
**Created**: 2026-01-04  
**Estimated Effort**: 17-23 hours  
**Complexity**: Medium  
**Language**: lean  
**Plan Version**: 001  

## Metadata

- **Task Number**: 259
- **Task Title**: Automation Tactics
- **Priority**: Medium
- **Dependencies**: None
- **Blocking**: None
- **Research Integrated**: Yes (research-001.md)
- **Plan Type**: Implementation

## Overview

### Problem Statement

The ProofChecker project needs to complete the remaining automation tactics for TM logic to support easier proof construction. Research found that 10/12 tactics are fully implemented (83% complete), with 2 tactics (modal_search, temporal_search) having infrastructure ready but currently delegating to tm_auto. Additionally, the Aesop integration is functional but has 2 noncomputable errors that need resolution.

### Scope

**In Scope**:
- Fix 2 noncomputable errors in AesopRules.lean
- Implement full modal_search and temporal_search tactics using ProofSearch.lean infrastructure
- Add comprehensive test suite for all tactics
- Update TACTIC_REGISTRY.md with final implementation status
- Document usage patterns and examples

**Out of Scope**:
- Implementing new tactics beyond the 12 planned
- Major refactoring of existing tactics (optional factory pattern refactoring deferred)
- Performance optimization beyond basic heuristics
- Integration with external proof assistants

### Constraints

- Must maintain backward compatibility with existing tactic usage
- Must follow Lean 4 style guide and metaprogramming best practices
- Must not introduce new build errors or warnings
- Must preserve existing test coverage (no regressions)
- ProofSearch.lean infrastructure must remain reusable for future tactics

### Definition of Done

- [ ] All 12 tactics implemented and functional
- [ ] Zero noncomputable errors in AesopRules.lean
- [ ] modal_search and temporal_search use ProofSearch.lean (not tm_auto delegation)
- [ ] Comprehensive test suite added with 90%+ coverage
- [ ] TACTIC_REGISTRY.md updated with final status
- [ ] Documentation updated with usage examples
- [ ] All tests pass (no regressions)
- [ ] Build succeeds with zero errors and warnings

## Goals and Non-Goals

### Goals

1. **Fix Aesop Integration**: Resolve 2 noncomputable errors to enable full Aesop functionality
2. **Complete Search Tactics**: Implement modal_search and temporal_search using existing ProofSearch.lean infrastructure
3. **Ensure Quality**: Add comprehensive test suite to prevent regressions
4. **Document Usage**: Update documentation with clear examples and usage patterns

### Non-Goals

1. **Refactoring Existing Tactics**: Factory pattern for axiom tactics is optional (deferred)
2. **Advanced Heuristics**: Beyond basic heuristics in ProofSearch.lean (future work)
3. **Performance Benchmarking**: Basic performance testing only (detailed benchmarking deferred)
4. **New Tactics**: Only complete the 12 planned tactics (no new tactics)

## Risks and Mitigations

### Risk 1: Noncomputable Errors Persist After Adding Keyword

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**: If adding `noncomputable` doesn't resolve errors, investigate whether axioms themselves need to be marked noncomputable. Review Lean 4 documentation on computability requirements. Consult Lean community if needed.

### Risk 2: Proof Term Construction is Complex

**Likelihood**: Medium  
**Impact**: High  
**Mitigation**: Start with simple proof construction for axioms and assumptions. Incrementally add support for modus ponens, modal K, and temporal K. Use existing DerivationTree constructors as templates. Test each step before proceeding.

### Risk 3: Performance Degradation with Full Search

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**: Use visit limits and depth limits to prevent runaway search. Profile performance and optimize heuristics if needed. Consider caching strategies. Document performance characteristics.

### Risk 4: Test Suite is Time-Consuming

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: Prioritize tests for critical tactics (modal_k, temporal_k, modal_search, temporal_search). Add remaining tests incrementally. Use property-based testing where appropriate.

## Implementation Phases

### Phase 1: Fix Aesop Integration [NOT STARTED]

**Estimated Effort**: 2-3 hours

**Objective**: Resolve 2 noncomputable errors in AesopRules.lean to enable full Aesop functionality.

**Tasks**:
1. Identify exact location of noncomputable errors in AesopRules.lean
2. Add `noncomputable` keyword to forward chaining rules (lines 110-196)
3. Add `noncomputable` keyword to apply rules if needed (lines 209-232)
4. Verify tm_auto tactic still works after changes
5. Run existing tests to ensure no regressions
6. Document noncomputable requirements in code comments

**Files Modified**:
- `Logos/Core/Automation/AesopRules.lean`

**Acceptance Criteria**:
- [ ] Zero noncomputable errors in AesopRules.lean
- [ ] All 14 Aesop rules compile successfully
- [ ] tm_auto tactic works correctly
- [ ] No regressions in existing tests

**Validation**:
```bash
# Build AesopRules.lean
lake build Logos.Core.Automation.AesopRules

# Verify no errors
echo $?  # Should be 0

# Test tm_auto tactic
lake build LogosTest.Core.Automation.TacticsTest
```

---

### Phase 2: Modify ProofSearch.lean to Return Proof Terms [NOT STARTED]

**Estimated Effort**: 6-8 hours

**Objective**: Modify ProofSearch.lean infrastructure to construct and return proof terms instead of just Boolean results.

**Tasks**:
1. Change `SearchResult` type from `Bool` to `Option DerivationTree`
2. Modify `bounded_search` to construct proof terms during search
3. Update axiom matching to return `DerivationTree.axiom` when matched
4. Update assumption checking to return `DerivationTree.assumption` when found
5. Update modus ponens to construct `DerivationTree.modus_ponens`
6. Update modal K to construct `DerivationTree.generalized_modal_k`
7. Update temporal K to construct `DerivationTree.generalized_temporal_k`
8. Update cache to store `Option DerivationTree` instead of `Bool`
9. Test proof construction with simple examples
10. Document proof construction strategy in code comments

**Files Modified**:
- `Logos/Core/Automation/ProofSearch.lean`

**Acceptance Criteria**:
- [ ] `SearchResult` type is `Option DerivationTree`
- [ ] `bounded_search` returns `Some proof` on success, `None` on failure
- [ ] Proof terms are valid `DerivationTree` instances
- [ ] Cache stores proof terms correctly
- [ ] Simple test cases pass (axioms, assumptions, modus ponens)

**Validation**:
```lean
-- Test axiom proof construction
#check bounded_search [] (Formula.box p |>.imp p) 1
-- Should return: Some (DerivationTree.axiom [] (Formula.box p |>.imp p) (Axiom.modal_t p))

-- Test assumption proof construction
#check bounded_search [p] p 1
-- Should return: Some (DerivationTree.assumption [p] p)
```

---

### Phase 3: Implement modal_search Tactic [NOT STARTED]

**Estimated Effort**: 4-5 hours

**Objective**: Implement modal_search tactic using ProofSearch.lean infrastructure.

**Tasks**:
1. Replace tm_auto delegation with bounded_search call
2. Extract depth parameter from tactic syntax
3. Extract context and formula from goal type
4. Call bounded_search with extracted parameters
5. Handle success case: construct proof term and close goal
6. Handle failure case: throw informative error with search statistics
7. Add error handling for invalid goal types
8. Add logging for search statistics (hits, misses, visited)
9. Test with simple modal formulas
10. Test with complex modal formulas
11. Document usage in docstring with examples

**Files Modified**:
- `Logos/Core/Automation/Tactics.lean` (lines 601-604)

**Acceptance Criteria**:
- [ ] modal_search no longer delegates to tm_auto
- [ ] modal_search uses bounded_search from ProofSearch.lean
- [ ] Depth parameter is correctly parsed and used
- [ ] Success case closes goal with valid proof
- [ ] Failure case provides informative error message
- [ ] Search statistics are logged
- [ ] Docstring includes usage examples

**Validation**:
```lean
-- Test simple modal formula
example (p : Formula) : DerivationTree [] ((p.box).imp p) := by
  modal_search 3  -- Should succeed with modal_t axiom

-- Test complex modal formula
example (p q : Formula) : DerivationTree [p.box, (p.imp q).box] (q.box) := by
  modal_search 5  -- Should succeed with modal_k and modus_ponens
```

---

### Phase 4: Implement temporal_search Tactic [NOT STARTED]

**Estimated Effort**: 4-5 hours

**Objective**: Implement temporal_search tactic using ProofSearch.lean infrastructure.

**Tasks**:
1. Replace tm_auto delegation with bounded_search call
2. Extract depth parameter from tactic syntax
3. Extract context and formula from goal type
4. Call bounded_search with extracted parameters
5. Handle success case: construct proof term and close goal
6. Handle failure case: throw informative error with search statistics
7. Add error handling for invalid goal types
8. Add logging for search statistics (hits, misses, visited)
9. Test with simple temporal formulas
10. Test with complex temporal formulas
11. Document usage in docstring with examples

**Files Modified**:
- `Logos/Core/Automation/Tactics.lean` (lines 619-623)

**Acceptance Criteria**:
- [ ] temporal_search no longer delegates to tm_auto
- [ ] temporal_search uses bounded_search from ProofSearch.lean
- [ ] Depth parameter is correctly parsed and used
- [ ] Success case closes goal with valid proof
- [ ] Failure case provides informative error message
- [ ] Search statistics are logged
- [ ] Docstring includes usage examples

**Validation**:
```lean
-- Test simple temporal formula
example (p : Formula) : DerivationTree [] ((p.all_future).imp (p.all_future.all_future)) := by
  temporal_search 3  -- Should succeed with temp_4 axiom

-- Test complex temporal formula
example (p q : Formula) : DerivationTree [p.all_future, (p.imp q).all_future] (q.all_future) := by
  temporal_search 5  -- Should succeed with temporal_k and modus_ponens
```

---

### Phase 5: Add Comprehensive Test Suite [NOT STARTED]

**Estimated Effort**: 4-6 hours

**Objective**: Add comprehensive test suite for all 12 tactics to ensure quality and prevent regressions.

**Tasks**:
1. Create `LogosTest/Core/Automation/TacticsTest.lean`
2. Add unit tests for each of the 10 existing tactics
3. Add unit tests for modal_search and temporal_search
4. Add integration tests for tactic combinations
5. Add edge case tests (invalid goals, depth limits, etc.)
6. Add performance tests for proof search (basic timing)
7. Add Aesop integration tests (tm_auto with various formulas)
8. Document test organization and coverage
9. Run all tests and verify they pass
10. Update test documentation

**Files Created**:
- `LogosTest/Core/Automation/TacticsTest.lean`

**Acceptance Criteria**:
- [ ] Test file created with comprehensive coverage
- [ ] All 12 tactics have unit tests
- [ ] Integration tests cover tactic combinations
- [ ] Edge cases are tested
- [ ] Performance tests provide baseline timing
- [ ] Aesop integration tests verify tm_auto works
- [ ] All tests pass
- [ ] Test coverage is 90%+ for automation tactics

**Validation**:
```bash
# Run all automation tests
lake build LogosTest.Core.Automation.TacticsTest

# Verify all tests pass
echo $?  # Should be 0

# Check test coverage (manual inspection)
grep -c "example\|theorem" LogosTest/Core/Automation/TacticsTest.lean
```

---

### Phase 6: Update Documentation [NOT STARTED]

**Estimated Effort**: 2-3 hours

**Objective**: Update documentation to reflect final implementation status and provide clear usage examples.

**Tasks**:
1. Update TACTIC_REGISTRY.md with final status (12/12 complete)
2. Update Automation README.md with usage examples
3. Add troubleshooting guide for common issues
4. Document performance characteristics (depth limits, visit limits)
5. Add examples for modal_search and temporal_search
6. Update FEATURE_REGISTRY.md if needed
7. Verify all documentation is accurate and complete

**Files Modified**:
- `docs/project-info/TACTIC_REGISTRY.md`
- `Logos/Core/Automation/README.md`
- `docs/project-info/FEATURE_REGISTRY.md` (if needed)

**Acceptance Criteria**:
- [ ] TACTIC_REGISTRY.md shows 12/12 tactics complete
- [ ] README.md includes usage examples for all tactics
- [ ] Troubleshooting guide covers common issues
- [ ] Performance characteristics documented
- [ ] Examples are clear and tested
- [ ] Documentation is accurate and complete

**Validation**:
```bash
# Verify TACTIC_REGISTRY.md updated
grep "12/12" docs/project-info/TACTIC_REGISTRY.md

# Verify README.md has examples
grep -c "example" Logos/Core/Automation/README.md
```

---

## Testing and Validation

### Unit Testing

**Scope**: Each of the 12 tactics individually

**Approach**:
- Test each tactic with simple formulas (axioms, assumptions)
- Test each tactic with complex formulas (nested operators)
- Test error cases (invalid goals, wrong formula structure)
- Verify error messages are informative

**Tools**: Lean 4 test framework, manual verification

**Success Criteria**: All unit tests pass, 100% tactic coverage

### Integration Testing

**Scope**: Combinations of tactics, Aesop integration

**Approach**:
- Test tactic combinations (modal_k + modus_ponens, etc.)
- Test tm_auto with various formulas
- Test modal_search and temporal_search with complex proofs
- Verify tactics work together correctly

**Tools**: Lean 4 test framework, manual verification

**Success Criteria**: All integration tests pass, no conflicts between tactics

### Performance Testing

**Scope**: Proof search performance, depth limits, visit limits

**Approach**:
- Measure search time for simple formulas (baseline)
- Measure search time for complex formulas (stress test)
- Verify depth limits prevent infinite loops
- Verify visit limits prevent excessive computation
- Document performance characteristics

**Tools**: Lean 4 profiling, manual timing

**Success Criteria**: Search completes within reasonable time (<5 seconds for depth 10)

### Regression Testing

**Scope**: Existing tests, existing tactic usage

**Approach**:
- Run all existing tests after each phase
- Verify no regressions in existing functionality
- Check for new build errors or warnings
- Verify backward compatibility

**Tools**: Lean 4 build system, existing test suite

**Success Criteria**: All existing tests pass, zero new errors/warnings

## Artifacts and Outputs

### Code Artifacts

1. **AesopRules.lean** (modified)
   - Location: `Logos/Core/Automation/AesopRules.lean`
   - Changes: Add `noncomputable` keywords to fix build errors
   - Status: [NOT STARTED]

2. **ProofSearch.lean** (modified)
   - Location: `Logos/Core/Automation/ProofSearch.lean`
   - Changes: Modify `SearchResult` to return proof terms
   - Status: [NOT STARTED]

3. **Tactics.lean** (modified)
   - Location: `Logos/Core/Automation/Tactics.lean`
   - Changes: Implement modal_search and temporal_search
   - Status: [NOT STARTED]

4. **TacticsTest.lean** (new)
   - Location: `LogosTest/Core/Automation/TacticsTest.lean`
   - Purpose: Comprehensive test suite for all tactics
   - Status: [NOT STARTED]

### Documentation Artifacts

1. **TACTIC_REGISTRY.md** (updated)
   - Location: `docs/project-info/TACTIC_REGISTRY.md`
   - Changes: Update status to 12/12 complete
   - Status: [NOT STARTED]

2. **Automation README.md** (updated)
   - Location: `Logos/Core/Automation/README.md`
   - Changes: Add usage examples and troubleshooting
   - Status: [NOT STARTED]

3. **Implementation Summary** (new)
   - Location: `.opencode/specs/259_automation_tactics/summaries/implementation-summary-20260104.md`
   - Purpose: Summary of implementation work
   - Status: [NOT STARTED]

## Rollback/Contingency

### Rollback Strategy

If implementation fails or introduces critical bugs:

1. **Phase 1 Rollback**: Revert AesopRules.lean changes
   - Command: `git checkout HEAD -- Logos/Core/Automation/AesopRules.lean`
   - Impact: Aesop integration remains broken (current state)

2. **Phase 2 Rollback**: Revert ProofSearch.lean changes
   - Command: `git checkout HEAD -- Logos/Core/Automation/ProofSearch.lean`
   - Impact: Proof term construction unavailable

3. **Phase 3-4 Rollback**: Revert Tactics.lean changes
   - Command: `git checkout HEAD -- Logos/Core/Automation/Tactics.lean`
   - Impact: modal_search and temporal_search remain delegated to tm_auto

4. **Full Rollback**: Revert all changes
   - Command: `git reset --hard HEAD`
   - Impact: Return to current state (10/12 tactics, Aesop broken)

### Contingency Plans

**If Noncomputable Errors Persist**:
- Investigate axiom definitions in `Logos/Core/ProofSystem/Axioms.lean`
- Consult Lean 4 documentation on computability
- Ask Lean community for guidance
- Consider alternative Aesop rule formulations

**If Proof Term Construction Fails**:
- Start with simpler proof construction (axioms only)
- Incrementally add complexity (assumptions, modus ponens)
- Use existing DerivationTree constructors as templates
- Consult Lean 4 metaprogramming documentation

**If Performance is Unacceptable**:
- Reduce default depth limits
- Optimize heuristics (increase weights for expensive operations)
- Add more aggressive pruning
- Consider caching strategies

**If Tests Fail**:
- Debug failing tests individually
- Verify test expectations are correct
- Check for environment-specific issues
- Simplify tests if needed

## Success Metrics

### Quantitative Metrics

1. **Tactic Completion**: 12/12 tactics implemented (100%)
2. **Build Errors**: 0 noncomputable errors (down from 2)
3. **Test Coverage**: 90%+ coverage for automation tactics
4. **Test Pass Rate**: 100% of tests pass
5. **Performance**: Search completes in <5 seconds for depth 10

### Qualitative Metrics

1. **Code Quality**: Clear, well-documented, follows Lean 4 style guide
2. **Usability**: Tactics are easy to use with informative error messages
3. **Maintainability**: Code is modular and reusable
4. **Documentation**: Clear examples and troubleshooting guide

### Acceptance Criteria

- [ ] All 12 tactics implemented and functional
- [ ] Zero noncomputable errors in AesopRules.lean
- [ ] modal_search and temporal_search use ProofSearch.lean
- [ ] Comprehensive test suite with 90%+ coverage
- [ ] TACTIC_REGISTRY.md updated to 12/12 complete
- [ ] Documentation includes usage examples
- [ ] All tests pass (no regressions)
- [ ] Build succeeds with zero errors and warnings

## Dependencies and Blockers

### Dependencies

- **Research Report**: research-001.md (completed)
- **ProofSearch.lean**: Existing infrastructure (ready)
- **DerivationTree**: Proof system types (ready)
- **Lean 4**: Metaprogramming framework (ready)

### Blockers

- None identified

### External Dependencies

- Lean 4 toolchain (version specified in lean-toolchain)
- Lake build system
- Aesop library (already integrated)

## Timeline and Milestones

### Estimated Timeline

- **Phase 1**: 2-3 hours (Fix Aesop Integration)
- **Phase 2**: 6-8 hours (Modify ProofSearch.lean)
- **Phase 3**: 4-5 hours (Implement modal_search)
- **Phase 4**: 4-5 hours (Implement temporal_search)
- **Phase 5**: 4-6 hours (Add Test Suite)
- **Phase 6**: 2-3 hours (Update Documentation)

**Total**: 17-23 hours (revised from 40-60 hours based on research)

### Milestones

1. **Milestone 1**: Aesop integration fixed (Phase 1 complete)
2. **Milestone 2**: Proof term construction working (Phase 2 complete)
3. **Milestone 3**: modal_search implemented (Phase 3 complete)
4. **Milestone 4**: temporal_search implemented (Phase 4 complete)
5. **Milestone 5**: Test suite complete (Phase 5 complete)
6. **Milestone 6**: Documentation updated (Phase 6 complete)

### Critical Path

Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

Phases 3 and 4 can be parallelized after Phase 2 completes.

## Notes

### Research Findings Integration

This plan integrates key findings from research-001.md:

1. **10/12 tactics already implemented**: Focus on completing remaining 2 tactics
2. **ProofSearch.lean infrastructure ready**: Reuse existing code instead of reimplementing
3. **Aesop integration functional but broken**: Simple fix with `noncomputable` keyword
4. **Effort estimate revised**: 17-23 hours (down from 40-60 hours in TODO.md)

### Key Insights

1. **Factory Pattern**: Existing factory pattern for K-rule tactics reduces code duplication
2. **Proof Construction**: Main challenge is modifying ProofSearch.lean to return proof terms
3. **Test Coverage**: Currently incomplete (docstring examples only), needs comprehensive suite
4. **Performance**: Bounded search with heuristics should provide acceptable performance

### Future Work (Out of Scope)

1. **Factory Pattern for Axiom Tactics**: Optional refactoring to reduce code duplication
2. **Advanced Heuristics**: Domain-specific optimizations for modal/temporal reasoning
3. **Performance Benchmarking**: Detailed performance analysis and optimization
4. **New Tactics**: Additional tactics beyond the 12 planned

### References

- Research Report: `.opencode/specs/259_automation_tactics/reports/research-001.md`
- TACTIC_REGISTRY.md: `docs/project-info/TACTIC_REGISTRY.md`
- ProofSearch.lean: `Logos/Core/Automation/ProofSearch.lean`
- Tactics.lean: `Logos/Core/Automation/Tactics.lean`
- AesopRules.lean: `Logos/Core/Automation/AesopRules.lean`
