# Plan Summary: Add Property-Based Testing Framework and Metalogic Tests

**Version**: 001  
**Complexity**: Moderate  
**Estimated Effort**: 18-23 hours  
**Language**: lean

---

## Overview

Integrate Plausible property-based testing framework and implement comprehensive property tests for metalogic, derivation, semantic, and formula transformation properties. This enhances the existing test infrastructure with automated test case generation to find edge cases across a wide range of inputs.

---

## Key Steps

### Phase 1: Infrastructure Validation (1-2 hours)
- Verify Plausible integration and existing generators
- Create CI/CD workflow for property tests
- Document baseline test coverage

### Phase 2: TaskModel Generator (4-6 hours) [WARN] **MAIN CHALLENGE**
- Implement SampleableExt instance for TaskModel with dependent types
- Use proxy pattern to handle valuation dependency on WorldState
- Add helper generators for specific patterns
- Test generator produces valid models

### Phase 3: Metalogic Property Tests (2-3 hours)
- Enhance axiom validity tests (all 14 axiom schemas)
- Add soundness tests (where decidable)
- Add consistency tests
- Configure for 100+ test cases per property

### Phase 4: Derivation Property Tests (2-3 hours)
- Enhance structural property tests (reflexivity, weakening, height)
- Add axiom derivability tests
- Add context subset properties
- Optimize for performance (<5 seconds per test)

### Phase 5: Semantic Property Tests (2-3 hours)
- Enhance frame property tests (nullity, compositionality)
- Add truth condition tests using TaskModel generator
- Add validity property tests
- Configure for moderate test counts (200 cases)

### Phase 6: Formula Transformation Tests (2-3 hours)
- Enhance complexity and transformation tests
- Add derived operator properties (diamond-box duality)
- Add idempotence tests (NNF, CNF if applicable)
- Add operator injectivity tests

### Phase 7: Documentation and CI (2-3 hours)
- Create PROPERTY_TESTING_GUIDE.md
- Update README.md with TaskModel examples
- Integrate property tests into CI workflow
- Update IMPLEMENTATION_STATUS.md

---

## Dependencies

**Completed Infrastructure:**
- [PASS] Plausible framework integrated in lakefile.lean
- [PASS] Basic generators for Formula, Context, TaskFrame
- [PASS] Property test directory structure
- [PASS] README.md with testing patterns

**To Implement:**
- TaskModel generator (Phase 2)
- Enhanced property tests (Phases 3-6)
- Documentation and CI (Phase 7)

**External:**
- Plausible framework (already in lakefile.lean)
- Mathlib4 v4.14.0 (already in lakefile.lean)

---

## Success Criteria

### Functional
- [ ] TaskModel generator implemented and tested
- [ ] Property tests for soundness (axiom validity)
- [ ] Property tests for derivation (reflexivity, weakening)
- [ ] Property tests for semantics (frame constraints, truth)
- [ ] Property tests for formulas (transformations, derived ops)
- [ ] All tests passing with 100+ cases per property

### Quality
- [ ] Test coverage ≥ 100 cases per property
- [ ] Tests run in <5 seconds each
- [ ] No false positives/negatives
- [ ] Shrinking produces minimal counterexamples

### Documentation
- [ ] PROPERTY_TESTING_GUIDE.md created
- [ ] README.md updated with examples
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] CI workflow integrated

---

## Key Challenges

### 1. TaskModel Generator (HIGH RISK)
**Challenge**: Dependent types (valuation depends on WorldState)  
**Mitigation**: Use SampleableExt with proxy pattern  
**Effort**: 4-6 hours

### 2. Decidability Requirements (MEDIUM RISK)
**Challenge**: Cannot test general derivability (not decidable)  
**Mitigation**: Test specific axiom instances  
**Effort**: 2-3 hours

### 3. Generator Performance (MEDIUM RISK)
**Challenge**: Recursive generation can be slow  
**Mitigation**: Size control and parameter tuning  
**Effort**: 1-2 hours

---

## Research Foundation

This plan is based on comprehensive research completed 2025-12-24:

- **Main Report**: `.opencode/specs/174_property_based_testing/reports/research-001.md` (374 lines)
- **Summary**: `.opencode/specs/174_property_based_testing/summaries/research-summary.md`
- **Detailed Findings**: `docs/research/property-based-testing-lean4.md` (986 lines)

**Key Finding**: Plausible is the only mature property-based testing framework for Lean 4, with excellent integration, automatic derivation, and no external dependencies.

---

## Full Plan

See: `.opencode/specs/174_property_based_testing/plans/implementation-001.md`

---

**Status**: [IN PROGRESS]  
**Started**: 2025-12-24  
**Estimated Completion**: 2025-12-26
