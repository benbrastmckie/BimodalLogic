# Implementation Plan: Task #417

**Task**: Benchmark comparison of typeclass constraint approaches
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Task 420 (Mathlib upgrade) already implemented typeclass unbundling using `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]`. This plan creates a benchmarked comparison by temporarily reverting to the original `LinearOrderedAddCommGroup` constraint to measure performance differences.

The goal is to empirically verify that unbundling provides performance benefits (as theorized in research-001.md) and determine the optimal approach.

## Phases

### Phase 1: Create Benchmark Baseline

**Status**: [NOT STARTED]

**Objectives**:
1. Record current build times for Explanatory module with unbundled constraints
2. Establish reliable measurement methodology
3. Document system state for reproducibility

**Files to modify**:
- None (measurement only)

**Steps**:
1. Clean build cache: `lake clean`
2. Run 3 timed builds of Explanatory module: `time lake build Theories.Logos.SubTheories.Explanatory.Truth`
3. Record wall-clock time, user time, and system time for each run
4. Calculate mean and standard deviation
5. Document results in a benchmark log

**Verification**:
- Have 3 consistent timing measurements
- Documented in benchmark log with system info (Mathlib version, Lean version, hardware)

---

### Phase 2: Create Test Branch with LinearOrderedAddCommGroup

**Status**: [NOT STARTED]

**Objectives**:
1. Create a temporary branch for benchmark testing
2. Revert typeclass constraints to original bundled form
3. Verify the code still compiles

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Frame.lean` - revert variable/structure constraints
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - revert variable constraints
- `Theories/Logos/SubTheories/Explanatory/Syntax.lean` - if applicable

**Steps**:
1. Create test branch: `git checkout -b benchmark/typeclass-comparison`
2. In Frame.lean line 34, replace:
   ```lean
   variable {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
   ```
   with:
   ```lean
   variable {T : Type*} [LinearOrderedAddCommGroup T]
   ```
3. Update CoreFrame structure (line 42) similarly
4. Update CoreModel structure (if present)
5. In Truth.lean, make the same variable declaration change
6. Run `lake build` to verify compilation succeeds
7. If errors occur, document them and investigate fixes

**Verification**:
- `lake build` succeeds with bundled constraints
- All Explanatory files compile without errors

---

### Phase 3: Benchmark Bundled Approach

**Status**: [NOT STARTED]

**Objectives**:
1. Measure build times with bundled `LinearOrderedAddCommGroup`
2. Use same methodology as Phase 1 for valid comparison
3. Document results

**Files to modify**:
- None (measurement only)

**Steps**:
1. Clean build cache: `lake clean`
2. Run 3 timed builds: `time lake build Theories.Logos.SubTheories.Explanatory.Truth`
3. Record wall-clock time, user time, and system time for each run
4. Calculate mean and standard deviation
5. Compare with Phase 1 baseline

**Verification**:
- Have 3 consistent timing measurements
- Results compared with unbundled baseline

---

### Phase 4: Analyze Results and Document

**Status**: [NOT STARTED]

**Objectives**:
1. Compare benchmarks statistically
2. Document findings
3. Make recommendation based on data

**Files to modify**:
- Create `specs/417_split_typeclass_constraints_explanatory/reports/benchmark-results.md`

**Steps**:
1. Calculate performance difference (percentage improvement from unbundling)
2. Document:
   - Measurement methodology
   - Raw timing data
   - Statistical analysis (mean, std dev, confidence interval)
   - Conclusion and recommendation
3. If unbundled is faster: recommend keeping current approach
4. If bundled is faster or equivalent: document for future reference

**Verification**:
- Benchmark report created with statistical analysis
- Clear recommendation based on data

---

### Phase 5: Cleanup

**Status**: [NOT STARTED]

**Objectives**:
1. Return to main branch
2. Delete test branch
3. Close task appropriately

**Files to modify**:
- None (git operations only)

**Steps**:
1. Checkout main: `git checkout main`
2. Delete test branch: `git branch -d benchmark/typeclass-comparison`
3. Update task 417 status based on results:
   - If unbundled is significantly faster: mark as COMPLETED (validated by task 420)
   - If bundled is faster: create follow-up task to revert
   - If equivalent: mark as COMPLETED with note

**Verification**:
- On main branch
- Test branch deleted
- Task status updated

---

## Dependencies

- Task 420 (Mathlib upgrade) - COMPLETED
- Task 416 (quick performance fixes) - COMPLETED
- Current Mathlib version: v4.27.0-rc1

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bundled version doesn't compile | Medium | Low | Document errors, may need Mathlib-specific fixes |
| Benchmark variance too high | Medium | Medium | Use more runs, control for background processes |
| Performance difference negligible | Low | Medium | Document for reference, validate approach anyway |

## Success Criteria

- [ ] Baseline benchmarks recorded (3 runs minimum)
- [ ] Test branch with bundled constraints compiles
- [ ] Bundled benchmarks recorded (3 runs minimum)
- [ ] Statistical comparison documented
- [ ] Clear recommendation based on data
- [ ] Task status updated appropriately

## Rollback Plan

If the bundled version cannot compile or produces errors:
1. Document the specific errors
2. Note that unbundled approach is required for Mathlib v4.27.0-rc1 compatibility
3. Close task 417 as validated by task 420 (unbundling was necessary)
