# WorldHistory Universal Helper and Tactic Test Suite Research

## Metadata
- **Date**: 2025-12-03
- **Agent**: lean-research-specialist
- **Topic**: Task 8 (WorldHistory Universal Helper) and Task 12 (Tactic Test Suite) implementation research
- **Report Type**: Lean formalization analysis
- **Workflow Type**: lean-plan

## Executive Summary

This research analyzes two medium-priority tasks from Logos's TODO.md:

1. **Task 8 - WorldHistory Universal Helper**: A 1 sorry placeholder at WorldHistory.lean:119 requiring proof of `respects_task` property for the universal history constructor
2. **Task 12 - Tactic Test Suite Expansion**: 31/50+ tests currently implemented, needing 19 additional tests for comprehensive coverage

Key findings:
- Task 8 requires frame reflexivity (`∀ w d, task_rel w d w`) which only holds for `trivialFrame` and `natFrame`
- Solution: Either (a) conditional proof with frame constraint, or (b) generalize to frame-specific constructors
- Task 12 expansion follows established test patterns in TacticsTest.lean with 6 test categories

## Findings

### Task 8: WorldHistory Universal Helper Analysis

#### Current Implementation (WorldHistory.lean:110-119)

```lean
def universal (F : TaskFrame) (w : F.WorldState) : WorldHistory F where
  domain := fun _ => True
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht hst
    -- This requires F to be reflexive: ∀ w d, task_rel w d w
    -- For trivialFrame and natFrame, this holds trivially.
    -- For identityFrame, this only holds when s = t.
    -- For MVP, we document the requirement and use sorry.
    sorry
```

#### Problem Analysis

The universal history assigns the same world state `w` to all times. For this to respect the task relation, we need:

```
∀ s t : Int, s ≤ t → F.task_rel w (t - s) w
```

This is equivalent to **frame reflexivity**: `∀ w d, F.task_rel w d w`

#### Frame Classification

| Frame | Reflexive? | Universal History Valid? |
|-------|-----------|-------------------------|
| `trivialFrame` | Yes (task_rel always True) | Yes |
| `natFrame` | Yes (task_rel always True) | Yes |
| `identityFrame` | No (only at d=0) | No |

#### Proof Strategies

**Strategy A: Frame-Specific Proofs** (Recommended)
- Remove generic `universal` constructor (it doesn't work for all frames)
- Keep `trivial : WorldHistory trivialFrame` (already proven)
- Add `universal_trivialFrame` and `universal_natFrame` as separate proven constructors

**Strategy B: Conditional Proof with Typeclass**
```lean
class ReflexiveTaskFrame (F : TaskFrame) where
  reflexive : ∀ w d, F.task_rel w d w

def universal (F : TaskFrame) [ReflexiveTaskFrame F] (w : F.WorldState) : WorldHistory F where
  domain := fun _ => True
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht hst
    exact ReflexiveTaskFrame.reflexive w (t - s)
```

**Strategy C: Documented Limitation** (Current MVP)
- Keep sorry with clear documentation
- Mark as known limitation in KNOWN_LIMITATIONS.md
- Accept as minor gap for MVP completion

#### Mathlib/Lean 4 Patterns

- `omega` tactic handles Int arithmetic proofs
- `exact` for direct term application
- `trivial` for True goals
- Typeclasses (`class`/`instance`) for conditional proofs

### Task 12: Tactic Test Suite Analysis

#### Current Test Coverage (TacticsTest.lean)

| Category | Tests | Coverage |
|----------|-------|----------|
| Direct Axiom Application | 10 | All 10 TM axioms |
| apply_axiom/modal_t | 2 | Basic functionality |
| tm_auto | 6 | 6/10 axioms |
| assumption_search | 5 | Basic matching |
| Helper Functions | 8 | All 4 helpers |
| **Total** | **31** | **62%** |

#### Gap Analysis

**Missing Tests (19 needed for 50+ target)**:

1. **Negative Tests (8 tests)**
   - `apply_axiom` on non-derivable goal → failure
   - `modal_t` on non-modal goal → failure
   - `tm_auto` depth limit exceeded → failure
   - `assumption_search` no match → failure message validation
   - `is_box_formula` edge cases
   - `is_future_formula` edge cases
   - `extract_from_box` nested formulas
   - `extract_from_future` nested formulas

2. **tm_auto Coverage Expansion (4 tests)**
   - `prop_k` axiom
   - `prop_s` axiom
   - `modal_b` axiom
   - `temp_l` axiom

3. **Context Tests (4 tests)**
   - `assumption_search` with empty context
   - `assumption_search` with multiple matching hypotheses
   - `assumption_search` with dependent types
   - `assumption_search` with formula hypotheses

4. **Edge Case Tests (3 tests)**
   - Deeply nested formulas
   - Very long formula chains
   - Unicode atom names

#### Test Pattern Templates

**Positive Test Template**:
```lean
/-- Test N: description -/
example : ExpectedType := by
  tactic_name
```

**Negative Test Template**:
```lean
/-- Test N: tactic should fail on invalid goal -/
-- This test verifies the tactic fails appropriately
-- Cannot use `example` as it would fail to compile
-- Document expected behavior in comment
#check fun (h : InvalidInput) => ...
```

**Helper Function Test**:
```lean
/-- Test N: helper function behavior -/
example : helper_fn input = expected_output := rfl
```

## Recommendations

### Recommendation 1: Implement Task 8 with Strategy A (Frame-Specific)

**Action**: Remove the generic `universal` constructor; add frame-specific proven versions.

**Implementation Steps**:
1. Remove or deprecate `WorldHistory.universal` (generic, unproven)
2. Keep `WorldHistory.trivial` (already proven for trivialFrame)
3. Add `WorldHistory.universal_trivialFrame : (w : Unit) → WorldHistory trivialFrame`
4. Add `WorldHistory.universal_natFrame : (n : Nat) → WorldHistory natFrame`
5. Document that universal history requires reflexive frames

**Rationale**: This preserves API completeness while avoiding the unprovable generic case.

**Estimated Effort**: 1-1.5 hours

### Recommendation 2: Expand Task 12 with 19 Systematic Tests

**Action**: Add 19 tests following the gap analysis categories.

**Implementation Priority**:
1. tm_auto coverage (4 tests) - fills obvious gaps
2. Negative tests (8 tests) - validates error handling
3. Context tests (4 tests) - validates assumption_search robustness
4. Edge cases (3 tests) - validates formula handling

**Test File Structure**:
```
/-!
## Existing Tests (1-31)
...

## Phase 7: tm_auto Coverage Expansion
Tests 32-35

## Phase 8: Negative Tests
Tests 36-43

## Phase 9: Context Tests
Tests 44-47

## Phase 10: Edge Case Tests
Tests 48-50+
-/
```

**Estimated Effort**: 3-4 hours

### Recommendation 3: Create WorldHistoryTest.lean

**Action**: Create dedicated test file for WorldHistory semantics.

**Tests to Include**:
1. `test_trivial_history_domain` - trivial history covers all times
2. `test_trivial_history_states` - trivial history returns unit
3. `test_time_shift_domain` - time shift preserves domain structure
4. `test_time_shift_states` - time shift maps states correctly
5. `test_time_shift_inverse` - double shift cancels

**File Location**: `LogosTest/Semantics/WorldHistoryTest.lean`

**Estimated Effort**: 1 hour

## Proof Techniques Reference

### For Task 8 Proofs

| Goal Pattern | Tactic |
|--------------|--------|
| `True` | `trivial` or `True.intro` |
| `F.task_rel _ _ _` where F is trivialFrame | `exact True.intro` |
| Arithmetic equality | `omega` |
| Direct term construction | `exact` |

### For Task 12 Test Assertions

| Assertion Type | Pattern |
|---------------|---------|
| Definitional equality | `example : expr = expected := rfl` |
| Tactic success | `example : Goal := by tactic` |
| Type check | `#check expression` |

## Dependencies

### Task 8 Dependencies
- `Logos/Semantics/TaskFrame.lean` - TaskFrame structure
- `Logos/Semantics/WorldHistory.lean` - WorldHistory definition

### Task 12 Dependencies
- `Logos/Automation/Tactics.lean` - Tactic definitions
- `Logos/ProofSystem.lean` - Derivability and axioms

## References

### Primary Sources
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/WorldHistory.lean` (lines 110-119)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Automation/TacticsTest.lean` (174 lines, 31 tests)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/TODO.md` (lines 87-139)

### Mathlib References
- Reflexivity patterns: Mathlib.Order.Basic
- Proof by computation: Mathlib.Tactic.Ring/Omega

### Project Standards
- Testing Standards: `.claude/docs/reference/standards/testing-protocols.md`
- LEAN Style Guide: `Documentation/Development/LEAN_STYLE_GUIDE.md`
