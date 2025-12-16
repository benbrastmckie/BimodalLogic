# Implementation Plan: WorldHistory Universal Helper and Tactic Test Suite

## Metadata
- **Plan ID**: 033-001
- **Status**: [IN PROGRESS]
- **Created**: 2025-12-03
- **Estimated Hours**: 5-7 hours total
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/WorldHistory.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/Logos
- **Based On**: Tasks 8 and 12 from TODO.md

## Overview

This plan implements two medium-priority tasks from the Logos TODO.md:

1. **Task 8**: Fix WorldHistory Universal Helper - Prove or refactor the `respects_task` sorry at WorldHistory.lean:119
2. **Task 12**: Expand Tactic Test Suite - Add 19 tests to reach 50+ comprehensive coverage

## Success Criteria

- [ ] Zero sorry placeholders in WorldHistory.lean (currently 1)
- [ ] TacticsTest.lean has 50+ tests (currently 31)
- [ ] All tests pass with `lake build` and `lake test`
- [ ] IMPLEMENTATION_STATUS.md updated to reflect changes
- [ ] TODO.md status updated for Tasks 8 and 12

---

## Phase 1: WorldHistory Universal Helper Refactoring [IN PROGRESS]

**Objective**: Remove the sorry at WorldHistory.lean:119 by implementing frame-specific universal history constructors.

**Rationale**: The generic `universal` constructor requires frame reflexivity (`∀ w d, task_rel w d w`), which only holds for `trivialFrame` and `natFrame`, not for general frames like `identityFrame`.

### Theorem Specifications

#### `theorem_01_universal_trivialFrame`
- [ ] `theorem universal_trivialFrame : WorldHistory trivialFrame`
  - Goal: `WorldHistory TaskFrame.trivialFrame`
  - Strategy: Construct history with `domain := fun _ => True`, `states := fun _ _ => ()`, prove `respects_task` using `True.intro`
  - Complexity: Simple
  - Dependencies: []

#### `theorem_02_universal_natFrame`
- [ ] `def universal_natFrame (n : Nat) : WorldHistory natFrame`
  - Goal: `(n : Nat) → WorldHistory TaskFrame.natFrame`
  - Strategy: Construct history with constant state `n`, prove `respects_task` using `trivial` (natFrame.task_rel is always True)
  - Complexity: Simple
  - Dependencies: []

#### `theorem_03_refactor_universal`
- [ ] Refactor `universal` to require reflexivity proof
  - Goal: Either remove generic `universal` or add a parameter `(h_refl : ∀ d, F.task_rel w d w)`
  - Strategy: Modify function signature to accept reflexivity proof, then use `exact h_refl _` in respects_task
  - Complexity: Medium (API change)
  - Dependencies: [theorem_01, theorem_02]

### Phase 1 Tasks [IN PROGRESS]

1. **Add `universal_trivialFrame`** (15 min)
   - Location: WorldHistory.lean after `trivial` definition (~line 132)
   - Pattern: Same as `trivial` but parameterized

2. **Add `universal_natFrame`** (15 min)
   - Location: WorldHistory.lean after `universal_trivialFrame`
   - Pattern: Construct with Nat parameter

3. **Refactor `universal` to conditional** (30 min)
   - Add reflexivity parameter to function signature
   - Update respects_task proof to use the parameter
   - Remove sorry

4. **Add unit tests** (15 min)
   - Create WorldHistoryTest.lean if not exists
   - Test universal_trivialFrame construction
   - Test universal_natFrame construction

5. **Update documentation** (15 min)
   - Update IMPLEMENTATION_STATUS.md Semantics sorry count
   - Update WorldHistory.lean docstrings

### Phase 1 Expected Outcome [IN PROGRESS]
- WorldHistory.lean: 0 sorry (down from 1)
- New constructors: `universal_trivialFrame`, `universal_natFrame`
- Refactored: `universal` with explicit reflexivity requirement

---

## Phase 2: Tactic Test Suite - tm_auto Coverage [NOT STARTED]

**Objective**: Add 4 tests to cover remaining tm_auto axiom cases.

**Rationale**: Current tm_auto tests cover 6/10 axioms; need coverage for prop_k, prop_s, modal_b, temp_l.

### Theorem Specifications

#### `theorem_04_tm_auto_prop_k`
- [ ] `example : Derivable [] (prop_k formula) := by tm_auto`
  - Goal: `Derivable [] (Formula.imp (Formula.imp p (Formula.imp q r)) (Formula.imp (Formula.imp p q) (Formula.imp p r)))`
  - Strategy: tm_auto should find prop_k axiom
  - Complexity: Simple
  - Dependencies: []

#### `theorem_05_tm_auto_prop_s`
- [ ] `example : Derivable [] (prop_s formula) := by tm_auto`
  - Goal: `Derivable [] (Formula.imp p (Formula.imp q p))`
  - Strategy: tm_auto should find prop_s axiom
  - Complexity: Simple
  - Dependencies: []

#### `theorem_06_tm_auto_modal_b`
- [ ] `example : Derivable [] (modal_b formula) := by tm_auto`
  - Goal: `Derivable [] (Formula.imp p (Formula.box (Formula.diamond p)))`
  - Strategy: tm_auto should find modal_b axiom
  - Complexity: Simple
  - Dependencies: []

#### `theorem_07_tm_auto_temp_l`
- [ ] `example : Derivable [] (temp_l formula) := by tm_auto`
  - Goal: `Derivable [] (Formula.imp (Formula.sometime_past p) (Formula.future p))`
  - Strategy: tm_auto should find temp_l axiom
  - Complexity: Simple
  - Dependencies: []

### Phase 2 Tasks

1. **Add tm_auto coverage tests** (20 min)
   - Location: TacticsTest.lean Phase 7 section
   - Tests 32-35: prop_k, prop_s, modal_b, temp_l

### Phase 2 Expected Outcome
- TacticsTest.lean: 35 tests (up from 31)
- tm_auto covers all 10 TM axioms

---

## Phase 3: Tactic Test Suite - Negative Tests [NOT STARTED]

**Objective**: Add 8 negative tests to validate error handling.

**Rationale**: Negative tests ensure tactics fail gracefully with appropriate error messages.

### Theorem Specifications

#### `theorem_08_apply_axiom_fail`
- [ ] Document: `apply_axiom` fails on non-axiom goal
  - Goal: Verify tactic reports failure for non-derivable goals
  - Strategy: Comment-documented expected behavior (can't use `example` for failing tests)
  - Complexity: Simple
  - Dependencies: []

#### `theorem_09_assumption_search_fail`
- [ ] Document: `assumption_search` fails with error message when no match
  - Goal: Error message contains "no assumption matches goal"
  - Strategy: Comment-documented expected behavior
  - Complexity: Simple
  - Dependencies: []

#### `theorem_10_is_box_nested`
- [ ] `example : is_box_formula (Formula.box (Formula.box p)) = true := rfl`
  - Goal: Nested box detection works
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_11_is_future_nested`
- [ ] `example : is_future_formula (Formula.future (Formula.future p)) = true := rfl`
  - Goal: Nested future detection works
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_12_extract_box_nested`
- [ ] `example : extract_from_box (Formula.box (Formula.box p)) = some (Formula.box p) := rfl`
  - Goal: Extract returns outer box content
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_13_extract_future_nested`
- [ ] `example : extract_from_future (Formula.future (Formula.future p)) = some (Formula.future p) := rfl`
  - Goal: Extract returns outer future content
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_14_is_box_imp`
- [ ] `example : is_box_formula (Formula.imp p q) = false := rfl`
  - Goal: Implication is not box
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_15_is_future_past`
- [ ] `example : is_future_formula (Formula.past p) = false := rfl`
  - Goal: Past is not future
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

### Phase 3 Tasks

1. **Add negative tests** (30 min)
   - Location: TacticsTest.lean Phase 8 section
   - Tests 36-43: Error handling and edge cases

### Phase 3 Expected Outcome
- TacticsTest.lean: 43 tests (up from 35)
- Error handling validated

---

## Phase 4: Tactic Test Suite - Context Tests [NOT STARTED]

**Objective**: Add 4 context-related tests for assumption_search robustness.

### Theorem Specifications

#### `theorem_16_assumption_multiple`
- [ ] `example (h1 : Nat) (h2 : Nat) : Nat := by assumption_search`
  - Goal: Multiple matching assumptions - picks one
  - Strategy: assumption_search with multiple candidates
  - Complexity: Simple
  - Dependencies: []

#### `theorem_17_assumption_formula_type`
- [ ] `example (h : Derivable [] (Formula.atom "p")) : Derivable [] (Formula.atom "p") := by assumption_search`
  - Goal: Works with Derivable type
  - Strategy: assumption_search with Derivable hypothesis
  - Complexity: Simple
  - Dependencies: []

#### `theorem_18_assumption_nested_type`
- [ ] `example (h : List (Option Nat)) : List (Option Nat) := by assumption_search`
  - Goal: Works with nested parameterized types
  - Strategy: assumption_search with complex type
  - Complexity: Simple
  - Dependencies: []

#### `theorem_19_assumption_function_type`
- [ ] `example (f : Nat → Bool) : Nat → Bool := by assumption_search`
  - Goal: Works with function types
  - Strategy: assumption_search with function hypothesis
  - Complexity: Simple
  - Dependencies: []

### Phase 4 Tasks

1. **Add context tests** (20 min)
   - Location: TacticsTest.lean Phase 9 section
   - Tests 44-47: Context handling variations

### Phase 4 Expected Outcome
- TacticsTest.lean: 47 tests (up from 43)

---

## Phase 5: Tactic Test Suite - Edge Cases [NOT STARTED]

**Objective**: Add 3+ edge case tests to reach 50+ total.

### Theorem Specifications

#### `theorem_20_deep_nesting`
- [ ] `example : is_box_formula (Formula.box (Formula.box (Formula.box p))) = true := rfl`
  - Goal: Deep nesting works
  - Strategy: Definitional equality
  - Complexity: Simple
  - Dependencies: []

#### `theorem_21_complex_formula`
- [ ] `example : Derivable [] (Formula.imp (Formula.box (Formula.future p)) (Formula.future (Formula.box p))) := by apply_axiom`
  - Goal: Complex bimodal formula
  - Strategy: Uses modal_future or temp_future axiom
  - Complexity: Simple
  - Dependencies: []

#### `theorem_22_long_context`
- [ ] `example (a b c d e : Nat) : Nat := by assumption_search`
  - Goal: Many hypotheses in context
  - Strategy: assumption_search finds one of many
  - Complexity: Simple
  - Dependencies: []

### Phase 5 Tasks

1. **Add edge case tests** (15 min)
   - Location: TacticsTest.lean Phase 10 section
   - Tests 48-50+: Edge cases

### Phase 5 Expected Outcome
- TacticsTest.lean: 50+ tests (target achieved)

---

## Phase 6: Documentation and Verification [NOT STARTED]

**Objective**: Update documentation and verify all changes.

### Tasks

1. **Run full test suite** (5 min)
   ```bash
   lake build
   lake test
   ```

2. **Update IMPLEMENTATION_STATUS.md** (10 min)
   - Semantics sorry count: 2 → 1 (or 0 if universal_trivialFrame/natFrame added)
   - Automation test count: 31 → 50+

3. **Update TODO.md** (10 min)
   - Task 8 status: DOCUMENTED AS LIMITATION → COMPLETE
   - Task 12 status: PARTIAL COMPLETE (31/50+) → COMPLETE (50+/50+)

4. **Verify no regressions** (5 min)
   - Check existing tests still pass
   - Check lake lint (if applicable)

### Phase 6 Expected Outcome
- All tests pass
- Documentation reflects current state
- TODO.md shows Task 8 and 12 as COMPLETE

---

## Dependency Graph

```
Phase 1 (WorldHistory)
├── theorem_01 (universal_trivialFrame)
├── theorem_02 (universal_natFrame)
└── theorem_03 (refactor universal) ← depends on 01, 02

Phase 2 (tm_auto)
├── theorem_04 (prop_k)
├── theorem_05 (prop_s)
├── theorem_06 (modal_b)
└── theorem_07 (temp_l)

Phase 3 (Negative)
├── theorem_08-09 (failure docs)
└── theorem_10-15 (helper edge cases)

Phase 4 (Context)
└── theorem_16-19 (assumption variations)

Phase 5 (Edge Cases)
└── theorem_20-22 (complex formulas)

Phase 6 (Documentation)
└── depends on all previous phases
```

## Parallel Execution Opportunities

- **Phases 2-5 can run in parallel** (independent test additions)
- **Phase 1 can run in parallel with Phases 2-5** (different files)
- **Phase 6 must run last** (verification)

## Estimated Time Breakdown

| Phase | Effort | Description |
|-------|--------|-------------|
| Phase 1 | 1.5 hours | WorldHistory refactoring |
| Phase 2 | 0.5 hours | tm_auto coverage |
| Phase 3 | 0.5 hours | Negative tests |
| Phase 4 | 0.5 hours | Context tests |
| Phase 5 | 0.5 hours | Edge cases |
| Phase 6 | 0.5 hours | Documentation |
| **Total** | **4-5 hours** | (Parallel: ~3 hours) |

## Risk Mitigation

1. **Risk**: Frame-specific constructors break existing code
   - **Mitigation**: Search for uses of `universal` before refactoring

2. **Risk**: Test failures due to tactic behavior changes
   - **Mitigation**: Run incremental builds after each test addition

3. **Risk**: Documentation out of sync
   - **Mitigation**: Update docs immediately after code changes

## Next Steps

1. Execute Phase 1 first (highest value - removes sorry)
2. Execute Phases 2-5 in parallel or sequentially
3. Execute Phase 6 last (verification)
4. Mark Tasks 8 and 12 as COMPLETE in TODO.md
