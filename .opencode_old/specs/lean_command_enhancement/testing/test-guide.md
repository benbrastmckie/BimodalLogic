# /lean Command Testing Guide

**Version**: 1.0
**Created**: 2025-12-20
**Purpose**: Comprehensive testing guide for enhanced /lean command

## Overview

This guide provides detailed test scenarios, procedures, and expected behaviors for testing the enhanced `/lean` command across all complexity levels and flag combinations.

## Test Projects

### 001_lean_test_simple
- **Complexity**: Simple
- **Theorems**: 1
- **Estimated Time**: 30 minutes
- **Purpose**: Verify basic command functionality

### 002_lean_test_moderate
- **Complexity**: Moderate
- **Theorems**: 3 (interdependent)
- **Estimated Time**: 1-2 hours
- **Purpose**: Verify multi-theorem handling and dependencies

### 003_lean_test_complex
- **Complexity**: Complex
- **Theorems**: 5 (multi-file, complex dependencies)
- **Estimated Time**: 3-4 hours
- **Purpose**: Verify complex proof handling and multi-file implementation

## Test Scenarios

### Scenario 1: Basic Execution (Simple Project)

**Test ID**: TEST-001
**Project**: 001_lean_test_simple
**Command**: `/lean 001_lean_test_simple`
**Flags**: None (default behavior)

**Expected Behavior**:
1. Load project state from `.opencode/specs/001_lean_test_simple/state.json`
2. Execute all phases in sequence:
   - Research (should be quick for simple project)
   - Planning (already completed, should skip or verify)
   - Implementation (main work)
   - Verification (compile and test)
   - Documentation (add docstrings)
3. Generate summary report
4. Update state.json with completion status

**Success Criteria**:
- All phases complete without errors
- Theorem compiles without `sorry`
- Tests pass
- Documentation generated
- Total time < 45 minutes

**Validation**:
- Check `Logos/Core/Theorems/ModalBasic.lean` exists and contains theorem
- Run `lake build Logos.Core.Theorems.ModalBasic`
- Verify no compilation errors
- Check state.json updated with completion timestamps

---

### Scenario 2: Skip Research Flag (Simple Project)

**Test ID**: TEST-002
**Project**: 001_lean_test_simple
**Command**: `/lean 001_lean_test_simple --skip-research`
**Flags**: `--skip-research`

**Expected Behavior**:
1. Load project state
2. Skip research phase entirely
3. Execute remaining phases:
   - Planning (verify existing plan)
   - Implementation
   - Verification
   - Documentation
4. Generate summary

**Success Criteria**:
- Research phase skipped (should see log message)
- All other phases complete
- Total time < 35 minutes (faster than TEST-001)
- Same quality output as TEST-001

**Validation**:
- Check logs for "Skipping research phase" message
- Verify no research artifacts created
- Compare output quality with TEST-001

---

### Scenario 3: Skip Planning Flag (Moderate Project)

**Test ID**: TEST-003
**Project**: 002_lean_test_moderate
**Command**: `/lean 002_lean_test_moderate --skip-planning`
**Flags**: `--skip-planning`

**Expected Behavior**:
1. Load project state
2. Execute research phase
3. Skip planning phase (use existing plan)
4. Execute implementation, verification, documentation

**Success Criteria**:
- Planning phase skipped
- Uses existing `plans/implementation-001.md`
- All 3 theorems implemented correctly
- Dependencies handled properly
- Total time < 2 hours

**Validation**:
- Check logs for "Using existing plan" message
- Verify no new plan files created
- Check all 3 theorems in `Logos/Core/Theorems/ModalS4.lean`
- Run tests in `LogosTest/Core/Theorems/ModalS4Test.lean`

---

### Scenario 4: Parallel Execution (Moderate Project)

**Test ID**: TEST-004
**Project**: 002_lean_test_moderate
**Command**: `/lean 002_lean_test_moderate --parallel`
**Flags**: `--parallel`

**Expected Behavior**:
1. Load project state
2. Execute phases sequentially (research, planning)
3. In implementation phase, execute independent specialists in parallel:
   - Syntax specialist
   - Semantics specialist
   - Proof specialist
   - Tactic specialist
4. Merge results
5. Continue with verification and documentation

**Success Criteria**:
- Parallel execution logged
- Faster than sequential execution (benchmark against TEST-003)
- No race conditions or conflicts
- All theorems implemented correctly
- Time improvement: 15-25% faster

**Validation**:
- Check logs for parallel execution messages
- Verify all specialists executed
- Compare timing with sequential run
- Check for any merge conflicts in output

---

### Scenario 5: Quick Mode (Simple Project)

**Test ID**: TEST-005
**Project**: 001_lean_test_simple
**Command**: `/lean 001_lean_test_simple --quick`
**Flags**: `--quick`

**Expected Behavior**:
1. Load project state
2. Skip research and planning (use existing)
3. Fast implementation (minimal exploration)
4. Basic verification only
5. Minimal documentation

**Success Criteria**:
- Significantly faster than TEST-001 (< 15 minutes)
- Theorem implemented and compiles
- Basic tests pass
- Documentation may be minimal but present

**Validation**:
- Check total execution time
- Verify theorem compiles
- Check documentation completeness (may be basic)

---

### Scenario 6: Combined Flags (Moderate Project)

**Test ID**: TEST-006
**Project**: 002_lean_test_moderate
**Command**: `/lean 002_lean_test_moderate --skip-research --parallel`
**Flags**: `--skip-research`, `--parallel`

**Expected Behavior**:
1. Skip research phase
2. Execute planning
3. Parallel implementation
4. Verification and documentation

**Success Criteria**:
- Both flags honored
- Faster than TEST-004 (no research overhead)
- All theorems implemented correctly
- Time: < 1.5 hours

**Validation**:
- Check logs for both flag behaviors
- Verify research skipped AND parallel execution
- Compare timing with single-flag tests

---

### Scenario 7: Complex Multi-File Implementation

**Test ID**: TEST-007
**Project**: 003_lean_test_complex
**Command**: `/lean 003_lean_test_complex`
**Flags**: None

**Expected Behavior**:
1. Execute all phases
2. Research phase: extensive (canonical models, completeness theory)
3. Planning phase: detailed multi-file plan
4. Implementation phase:
   - Create `Logos/Core/Semantics/CanonicalModel.lean`
   - Implement theorems in `Logos/Core/Metalogic/Completeness.lean`
   - Handle complex dependencies
5. Verification: comprehensive testing
6. Documentation: detailed with examples

**Success Criteria**:
- All 5 theorems implemented
- Both files created and properly structured
- Complex dependencies resolved
- All tests pass
- Compilation time per theorem < 10s
- Total time: 3-4 hours

**Validation**:
- Check both target files exist
- Verify all 5 theorems present
- Run `lake build Logos.Core.Metalogic.Completeness`
- Run tests in `LogosTest/Core/Metalogic/CompletenessTest.lean`
- Check dependency graph correctness

---

### Scenario 8: Error Handling - Invalid Project

**Test ID**: TEST-008
**Project**: 999_nonexistent_project
**Command**: `/lean 999_nonexistent_project`
**Flags**: None

**Expected Behavior**:
1. Attempt to load project state
2. Fail to find project directory
3. Return clear error message
4. Suggest available projects
5. Exit gracefully

**Success Criteria**:
- Clear error message: "Project not found: 999_nonexistent_project"
- List of available projects shown
- No partial execution
- No corrupted state

**Validation**:
- Check error message clarity
- Verify no files created
- Check logs for proper error handling

---

### Scenario 9: Error Handling - Compilation Failure

**Test ID**: TEST-009
**Project**: 001_lean_test_simple (modified to fail)
**Setup**: Modify plan to include invalid syntax
**Command**: `/lean 001_lean_test_simple`
**Flags**: None

**Expected Behavior**:
1. Execute through implementation phase
2. Verification phase detects compilation error
3. Error reported with details
4. Offer recovery options:
   - Retry with fixes
   - Skip verification
   - Abort
5. State saved with error status

**Success Criteria**:
- Compilation error caught
- Clear error message with line numbers
- Recovery options presented
- State.json updated with error status
- No data loss

**Validation**:
- Check error message includes compilation details
- Verify state.json shows error status
- Check recovery options work

---

### Scenario 10: Phase Skipping Logic

**Test ID**: TEST-010
**Project**: 002_lean_test_moderate
**Setup**: Set state.json phases.research.status = "completed"
**Command**: `/lean 002_lean_test_moderate`
**Flags**: None

**Expected Behavior**:
1. Load project state
2. Detect research already completed
3. Skip research phase automatically
4. Continue with next incomplete phase
5. Log skipped phase

**Success Criteria**:
- Research phase skipped automatically
- No duplicate work
- Correct phase resumption
- State consistency maintained

**Validation**:
- Check logs for "Phase already completed" message
- Verify no new research artifacts
- Check state.json timestamps unchanged for completed phases

---

### Scenario 11: Parallel Specialist Execution (Complex)

**Test ID**: TEST-011
**Project**: 003_lean_test_complex
**Command**: `/lean 003_lean_test_complex --parallel`
**Flags**: `--parallel`

**Expected Behavior**:
1. Execute research and planning sequentially
2. In implementation phase:
   - Syntax specialist: Define structures (CanonicalModel, etc.)
   - Semantics specialist: Implement truth lemma
   - Proof specialist: Implement completeness theorems
   - Tactic specialist: Develop custom tactics (if needed)
   - All execute in parallel where possible
3. Merge results with dependency resolution
4. Verification and documentation

**Success Criteria**:
- Parallel execution successful
- No merge conflicts
- Dependencies resolved correctly
- Time improvement: 20-30% vs sequential
- All 5 theorems correct

**Validation**:
- Check logs for parallel specialist execution
- Verify dependency order maintained
- Compare timing with sequential run
- Check for race conditions or conflicts

---

### Scenario 12: All Flags Combined (Complex)

**Test ID**: TEST-012
**Project**: 003_lean_test_complex
**Command**: `/lean 003_lean_test_complex --skip-research --skip-planning --parallel --quick`
**Flags**: All flags

**Expected Behavior**:
1. Skip research and planning
2. Use existing plan
3. Quick parallel implementation
4. Basic verification
5. Minimal documentation

**Success Criteria**:
- All flags honored
- Significantly faster (< 2 hours vs 3-4 hours)
- Theorems implemented (may be basic)
- Compiles and passes basic tests
- Trade-off: speed vs thoroughness

**Validation**:
- Check all flags in logs
- Verify time savings
- Check output quality (acceptable trade-offs)

---

## Performance Benchmarking

### Methodology

1. **Baseline Measurement**:
   - If old `/lean` command exists, run on test projects
   - Record total time and phase breakdown
   - Record resource usage (CPU, memory)

2. **Enhanced Command Measurement**:
   - Run each test scenario 3 times
   - Record average, min, max times
   - Record phase breakdown
   - Record resource usage

3. **Comparison Metrics**:
   - Total execution time
   - Time per phase
   - Time per theorem
   - Parallel speedup factor
   - Resource efficiency

### Performance Targets

| Complexity | Sequential Time | Parallel Time | Speedup Target |
|------------|----------------|---------------|----------------|
| Simple     | < 45 min       | < 35 min      | 20%            |
| Moderate   | < 2 hours      | < 1.5 hours   | 25%            |
| Complex    | < 4 hours      | < 3 hours     | 25-30%         |

### Resource Limits

- **Memory**: < 4GB per specialist
- **CPU**: Utilize available cores efficiently
- **Disk I/O**: Minimize redundant file operations

---

## Test Execution Order

### Phase 1: Basic Functionality
1. TEST-001 (Basic execution, simple)
2. TEST-008 (Error handling - invalid project)
3. TEST-010 (Phase skipping logic)

### Phase 2: Flag Testing
4. TEST-002 (Skip research)
5. TEST-003 (Skip planning)
6. TEST-005 (Quick mode)
7. TEST-006 (Combined flags)

### Phase 3: Parallel Execution
8. TEST-004 (Parallel, moderate)
9. TEST-011 (Parallel, complex)

### Phase 4: Complex Scenarios
10. TEST-007 (Complex multi-file)
11. TEST-009 (Error handling - compilation)
12. TEST-012 (All flags, complex)

---

## Test Result Recording

For each test, record in `test-results.md`:
- Test ID
- Timestamp
- Command executed
- Expected result
- Actual result
- Pass/Fail status
- Execution time
- Resource usage
- Issues encountered
- Notes

---

## Regression Testing

After any changes to `/lean` command:
1. Re-run all 12 test scenarios
2. Compare results with baseline
3. Verify no regressions
4. Update test results
5. Update performance benchmarks

---

## Continuous Testing

### Automated Tests
- Run TEST-001, TEST-002, TEST-005 on every commit
- Run full test suite weekly
- Performance benchmarks monthly

### Manual Tests
- Complex scenarios (TEST-007, TEST-011, TEST-012) before releases
- Error handling tests after error handling changes
- Flag combination tests after flag logic changes

---

## Test Environment

### Requirements
- LEAN 4 installed
- ProofChecker project set up
- All dependencies available
- Sufficient disk space (> 10GB)
- Sufficient memory (> 8GB recommended)

### Setup
```bash
# Ensure clean state
cd /home/benjamin/Projects/ProofChecker
lake clean
lake build

# Verify test projects exist
ls -la .opencode/specs/001_lean_test_simple
ls -la .opencode/specs/002_lean_test_moderate
ls -la .opencode/specs/003_lean_test_complex
```

### Cleanup
```bash
# After testing, optionally clean up generated files
# (Keep test projects for future testing)
rm -rf .opencode/specs/*/reports/*
rm -rf .opencode/specs/*/summaries/*
# Reset state.json files to pending status
```

---

## Troubleshooting

### Common Issues

**Issue**: Test hangs during execution
- **Cause**: Infinite loop in specialist or phase
- **Solution**: Check logs, add timeout, kill process

**Issue**: Compilation errors in generated code
- **Cause**: Incorrect syntax generation
- **Solution**: Review implementation specialist output, check templates

**Issue**: Parallel execution conflicts
- **Cause**: Race conditions in file writes
- **Solution**: Review merge logic, add file locking

**Issue**: State.json corruption
- **Cause**: Interrupted execution
- **Solution**: Restore from backup, implement atomic writes

---

## Success Criteria Summary

### Overall Success Criteria
- ✅ All 12 test scenarios pass
- ✅ Performance targets met
- ✅ No critical bugs
- ✅ Error handling robust
- ✅ Documentation complete
- ✅ Code quality high

### Quality Gates
- **Phase 1**: All basic tests pass before proceeding
- **Phase 2**: All flag tests pass before proceeding
- **Phase 3**: Parallel execution stable before proceeding
- **Phase 4**: Complex scenarios pass before release

---

## Next Steps

After completing all tests:
1. Review test results
2. Address any failures
3. Update documentation based on findings
4. Create final performance report
5. Mark Phase 2 complete in implementation plan
6. Proceed to Phase 3 (Documentation) if all tests pass
