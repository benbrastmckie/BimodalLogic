# Stage 1: Implement apply_axiom and modal_t Tactics

## Metadata

- **Stage Number**: 1 of 3
- **Parent Phase**: Sub-Phase 3B - Implement Core Automation (Task 7)
- **Parent Plan**: `.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md`
- **Dependencies**: Phase 1 complete (propositional axioms)
- **Estimated Hours**: 10-13 hours (revised from 15-20 with METAPROGRAMMING_GUIDE.md)
- **Status**: [NOT STARTED]
- **Complexity**: Medium

## Objective

Implement `apply_axiom` (macro-based) and `modal_t` (pattern-matched) tactics as foundation for Logos automation. Replace 2 sorry placeholders in `Tactics.lean` with working implementations following TDD approach.

## Context

This stage implements Phase 1 of the three-phase automation roadmap:
- **Phase 1** (this stage): `apply_axiom` + `modal_t` → Basic axiom application
- **Phase 2**: `tm_auto` with Aesop integration → Comprehensive automation
- **Phase 3**: `assumption_search` + helpers → Context search and helper tactics

**Documentation Available**:
- `METAPROGRAMMING_GUIDE.md` (730 lines): Complete LEAN 4 tactic API reference
- `TACTIC_DEVELOPMENT.md` Section 2.5: Fully annotated `modal_t` implementation
- `CLAUDE.md` Section 10.1: Quick reference for rapid API lookup

**Time Savings**: Documentation eliminates 6-10 hours of external LEAN 4 API research.

## Success Criteria

- [ ] `apply_axiom` tactic works for all 8 TM axioms (MT, M4, MB, T4, TA, TL, MF, TF)
- [ ] `modal_t` tactic automatically applies modal T axiom when goal matches `□φ → φ` pattern
- [ ] Comprehensive test suite created in `TacticsTest.lean` with ≥12 tests
- [ ] All tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] 2 sorry removed from `Tactics.lean` (lines 112, 141)
- [ ] Zero #lint warnings in `Tactics.lean`
- [ ] Documentation updated with working examples

## Implementation Steps

### Step 1: Review Documentation (1-1.5 hours)

**Objective**: Build foundational knowledge of LEAN 4 tactic metaprogramming

**Resources to Review**:

1. **CLAUDE.md Section 10.1** (10 minutes):
   - Lines 307-336: Quick reference for API modules
   - Lines 338-365: Aesop integration pattern example
   - Lines 367-391: Priority tactics list with effort estimates

2. **METAPROGRAMMING_GUIDE.md** (30-45 minutes):
   - Section 1: Introduction and prerequisites
   - Section 2: Core modules and imports (REQUIRED)
   - Section 3: Goal management (`getMainGoal`, `goal.assign`)
   - Section 4: Expression pattern matching (formula destructuring)
   - Section 5: Proof term construction (`mkAppM`, `mkConst`)
   - Section 7: Three tactic development approaches (macro vs elab_rules)
   - Section 8: Complete working examples (apply_axiom, modal_t)

3. **TACTIC_DEVELOPMENT.md Section 2.5** (20-30 minutes):
   - Lines 104-200: Complete annotated `modal_t` implementation
   - Step-by-step explanation of pattern matching, proof construction, error handling

**Action Items**:
- [ ] Read CLAUDE.md Section 10.1 for quick orientation
- [ ] Skim METAPROGRAMMING_GUIDE.md Sections 1-2, 7-8
- [ ] Study TACTIC_DEVELOPMENT.md Section 2.5 in detail
- [ ] Bookmark METAPROGRAMMING_GUIDE.md Sections 3-6 for reference during implementation

**Output**: Solid understanding of `elab_rules`, `mkAppM`, goal pattern matching, and proof term construction.

---

### Step 2: Create Test File Structure (TDD) (1-2 hours)

**Objective**: Write failing tests BEFORE implementation (TDD enforcement)

**File**: `LogosTest/Automation/TacticsTest.lean`

**Test Categories**:

1. **apply_axiom Tests** (8 tests - one per axiom):
   - `test_apply_axiom_mt`: MT axiom (`□φ → φ`)
   - `test_apply_axiom_m4`: M4 axiom (`□φ → □□φ`)
   - `test_apply_axiom_mb`: MB axiom (`φ → □◇φ`)
   - `test_apply_axiom_t4`: T4 axiom (`Fφ → FFφ`)
   - `test_apply_axiom_ta`: TA axiom (`Fφ → φ`)
   - `test_apply_axiom_tl`: TL axiom (2 formula arguments)
   - `test_apply_axiom_mf`: MF axiom (modal-temporal interaction)
   - `test_apply_axiom_tf`: TF axiom (temporal-modal interaction)

2. **modal_t Tests** (4 tests):
   - `test_modal_t_success`: Successful application on `□P → P`
   - `test_modal_t_complex`: Application on nested formula `□(P ∧ Q) → (P ∧ Q)`
   - `test_modal_t_fail_mismatch`: Failure on `□P → Q` (φ ≠ ψ)
   - `test_modal_t_fail_not_implication`: Failure on `□P` (not implication)

**Implementation Template**:

```lean
-- File: LogosTest/Automation/TacticsTest.lean
import Logos.Automation.Tactics
import Logos.Syntax.Formula
import Logos.ProofSystem.Derivation

namespace LogosTest.Automation.TacticsTest

open Logos.Syntax (Formula)
open Logos.ProofSystem (Derivable Axiom)

/-! ## apply_axiom Tests -/

/-- Test: apply_axiom with MT axiom -/
theorem test_apply_axiom_mt (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  apply_axiom MT P
  -- Expected: Proof completes successfully

/-- Test: apply_axiom with M4 axiom -/
theorem test_apply_axiom_m4 (P : Formula) :
    Derivable [] ((Formula.box P).imp (Formula.box (Formula.box P))) := by
  apply Derivable.axiom
  apply_axiom M4 P
  -- Expected: Proof completes successfully

/-- Test: apply_axiom with TL axiom (2 arguments) -/
theorem test_apply_axiom_tl (P Q : Formula) :
    Derivable [] ((Formula.future (P.imp Q)).imp ((Formula.past P).imp (Formula.past Q))) := by
  apply Derivable.axiom
  apply_axiom TL P Q
  -- Expected: Proof completes with 2 formula arguments

/-- Test: apply_axiom error handling - wrong axiom name -/
-- This test should fail during compilation with clear error message
-- theorem test_apply_axiom_invalid (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
--   apply_axiom INVALID_AXIOM P
--   -- Expected: Error: "Unknown axiom: INVALID_AXIOM"

/-! ## modal_t Tests -/

/-- Test: modal_t applies successfully on □P → P -/
theorem test_modal_t_success (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  modal_t
  -- Expected: Tactic detects pattern and applies MT axiom

/-- Test: modal_t on complex nested formula -/
theorem test_modal_t_complex (P Q : Formula) :
    Derivable [] ((Formula.box (P.and Q)).imp (P.and Q)) := by
  apply Derivable.axiom
  modal_t
  -- Expected: Tactic extracts (P ∧ Q) and applies MT

/-- Test: modal_t fails gracefully on mismatched formulas -/
-- This test should fail during proof with informative error
-- theorem test_modal_t_fail_mismatch (P Q : Formula) :
--     Derivable [] ((Formula.box P).imp Q) := by
--   apply Derivable.axiom
--   modal_t
--   -- Expected: Error: "Goal has form □φ → ψ but φ ≠ ψ"

/-- Test: modal_t fails on non-implication goal -/
-- This test should fail during proof with informative error
-- theorem test_modal_t_fail_not_imp (P : Formula) :
--     Derivable [] (Formula.box P) := by
--   apply Derivable.axiom
--   modal_t
--   -- Expected: Error: "Goal does not match modal T pattern"

end LogosTest.Automation.TacticsTest
```

**Action Items**:
- [ ] Create `LogosTest/Automation/TacticsTest.lean`
- [ ] Write 8 apply_axiom tests (one per axiom)
- [ ] Write 4 modal_t tests (success + failure cases)
- [ ] Verify tests fail with expected errors: `lake test LogosTest.Automation.TacticsTest`
- [ ] Document expected error messages in comments

**Expected Output**: 12 failing tests with clear error messages indicating missing tactic implementations.

---

### Step 3: Implement apply_axiom Tactic (Macro-Based) (3-4 hours)

**Objective**: Implement `apply_axiom` using `elab_rules` approach for all 8 TM axioms

**File**: `Logos/Automation/Tactics.lean`

**Current State** (Lines 102-112):
```lean
/-- Apply a named axiom schema to the current goal. -/
syntax "apply_axiom" ident term* : tactic

macro_rules
  | `(tactic| apply_axiom $ax $args*) => `(tactic| sorry)
```

**Implementation Approach**: Use `elab_rules` for pattern-matched tactic with axiom name lookup

**Step 3.1**: Add Required Imports

```lean
-- At top of Logos/Automation/Tactics.lean
import Lean.Elab.Tactic
import Lean.Meta.Basic
import Lean.Expr
import Lean.MVarId

import Logos.Syntax.Formula
import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Derivation

namespace Logos.Automation

open Lean Elab Tactic Meta
open Logos.Syntax (Formula)
open Logos.ProofSystem (Axiom Derivable)
```

**Step 3.2**: Implement apply_axiom with elab_rules

```lean
/-- Apply a named axiom schema to the current goal.

Parses axiom name identifier and formula arguments, looks up the corresponding
axiom from `Logos.ProofSystem.Axioms`, instantiates it with provided
formulas, and applies to the current goal.

**Supported Axioms**:
- MT: Modal T (`□φ → φ`) - 1 argument
- M4: Modal 4 (`□φ → □□φ`) - 1 argument
- MB: Modal B (`φ → □◇φ`) - 1 argument
- T4: Temporal 4 (`Fφ → FFφ`) - 1 argument
- TA: Temporal A (`Fφ → φ`) - 1 argument
- TL: Temporal L (`F(φ → ψ) → (Pφ → Pψ)`) - 2 arguments
- MF: Modal-Future (`□Fφ ↔ F□φ`) - 1 argument
- TF: Temporal-Future (`FGφ ↔ GFφ`) - 1 argument

**Usage**:
```lean
theorem example_mt (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  apply_axiom MT P

theorem example_tl (P Q : Formula) :
    Derivable [] ((Formula.future (P.imp Q)).imp ((Formula.past P).imp (Formula.past Q))) := by
  apply Derivable.axiom
  apply_axiom TL P Q
```

**Error Handling**:
- Unknown axiom name → "Unknown axiom: {name}"
- Wrong argument count → "{axiom} requires exactly {N} formula arguments"
- Type mismatch → Standard LEAN type error
-/
syntax "apply_axiom" ident term* : tactic

elab_rules : tactic
  | `(tactic| apply_axiom $ax:ident $args*) => do
    let axiomName := ax.getId
    let goal ← getMainGoal

    -- Parse formula arguments
    let formulaArgs ← args.mapM fun arg => do
      elabTerm arg none

    -- Look up axiom by name and build axiom expression
    let axiomExpr ← match axiomName.toString with
      | "MT" =>
          if formulaArgs.size != 1 then
            throwError "MT axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.modal_t #[formulaArgs[0]!]

      | "M4" =>
          if formulaArgs.size != 1 then
            throwError "M4 axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.modal_4 #[formulaArgs[0]!]

      | "MB" =>
          if formulaArgs.size != 1 then
            throwError "MB axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.modal_b #[formulaArgs[0]!]

      | "T4" =>
          if formulaArgs.size != 1 then
            throwError "T4 axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.temporal_4 #[formulaArgs[0]!]

      | "TA" =>
          if formulaArgs.size != 1 then
            throwError "TA axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.temporal_a #[formulaArgs[0]!]

      | "TL" =>
          if formulaArgs.size != 2 then
            throwError "TL axiom requires exactly 2 formula arguments, got {formulaArgs.size}"
          mkAppM ``Axiom.temporal_l #[formulaArgs[0]!, formulaArgs[1]!]

      | "MF" =>
          if formulaArgs.size != 1 then
            throwError "MF axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.modal_future #[formulaArgs[0]!]

      | "TF" =>
          if formulaArgs.size != 1 then
            throwError "TF axiom requires exactly 1 formula argument, got {formulaArgs.size}"
          mkAppM ``Axiom.temporal_future #[formulaArgs[0]!]

      | _ =>
          throwError "Unknown axiom: {axiomName}. Supported axioms: MT, M4, MB, T4, TA, TL, MF, TF"

    -- Apply axiom expression to goal using built-in apply tactic
    evalTactic (← `(tactic| apply $axiomExpr))
```

**Reference**: METAPROGRAMMING_GUIDE.md Section 8, Example 1 (lines 610-626) for macro-based pattern

**Action Items**:
- [ ] Add required imports to `Tactics.lean`
- [ ] Replace lines 102-112 with full `apply_axiom` implementation
- [ ] Add comprehensive docstring with usage examples
- [ ] Test compilation: `lake build Logos.Automation.Tactics`
- [ ] Run tests: `lake test LogosTest.Automation.TacticsTest`
- [ ] Verify 8 apply_axiom tests pass

**Expected Output**: All 8 apply_axiom tests pass successfully.

---

### Step 4: Implement modal_t Tactic (Pattern-Matched) (3-4 hours)

**Objective**: Implement `modal_t` using `elab` approach with goal pattern matching

**File**: `Logos/Automation/Tactics.lean`

**Current State** (Lines 118-141):
```lean
/-- Apply modal T axiom (□φ → φ) to the current goal. -/
syntax "modal_t" : tactic

macro_rules
  | `(tactic| modal_t) => `(tactic| sorry)
```

**Implementation Approach**: Use `elab` with expression pattern matching on goal type

**Reference**:
- TACTIC_DEVELOPMENT.md Section 2.5 (lines 104-200): Complete annotated implementation
- METAPROGRAMMING_GUIDE.md Section 5 (lines 253-281): Pattern matching `□φ → φ`

**Step 4.1**: Implement modal_t with Expression Destructuring

```lean
/-- Apply modal T axiom (`□φ → φ`) to the current goal.

Automatically detects if the goal has the form `Derivable Γ (□φ → φ)` for some
context Γ and formula φ, then constructs and applies the modal T axiom proof.

**Pattern Matching**:
1. Goal must be `Derivable` relation
2. Formula must be implication (`→`)
3. Left side must be `box` operator (`□`)
4. Inner formula must match right side

**Usage**:
```lean
theorem modal_t_example (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  modal_t
  -- Automatically applies: Axiom.modal_t P

theorem modal_t_nested (P Q : Formula) :
    Derivable [] ((Formula.box (P.and Q)).imp (P.and Q)) := by
  apply Derivable.axiom
  modal_t
  -- Automatically applies: Axiom.modal_t (P.and Q)
```

**Error Messages**:
- Goal not `Derivable` → "modal_t: goal must be derivability relation `Γ ⊢ φ`, got {goalType}"
- Formula not implication → "modal_t: expected implication, got {formula}"
- Left side not box → "modal_t: expected `□_` on left side, got {lhs} → {rhs}"
- Formulas don't match → "modal_t: expected `□φ → φ`, got `□{innerFormula} → {rhs}`"
-/
syntax "modal_t" : tactic

elab_rules : tactic
  | `(tactic| modal_t) => do
    -- STEP 1: Get the main goal and its type
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- STEP 2: Pattern match on Derivable Γ φ
    -- goalType should have form: Derivable context formula
    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>

      -- STEP 3: Destructure formula to check for □φ → φ pattern
      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>

        -- STEP 4: Check lhs is Formula.box
        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>

          -- STEP 5: Verify innerFormula == rhs (definitional equality)
          if ← isDefEq innerFormula rhs then
            -- STEP 6: Construct proof term
            -- Build: Derivable.axiom (Axiom.modal_t innerFormula)
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]

            -- STEP 7: Assign proof to goal (closes goal)
            goal.assign proof
          else
            throwError "modal_t: expected `□φ → φ` pattern, but got `□{innerFormula} → {rhs}` where φ ≠ ψ"

        | _ =>
          throwError "modal_t: expected implication with `□_` on left, got `{lhs} → {rhs}`"

      | _ =>
        throwError "modal_t: expected implication, got `{formula}`"

    | _ =>
      throwError "modal_t: goal must be derivability relation `Γ ⊢ φ`, got `{goalType}`"
```

**Implementation Notes**:
1. **Expression Destructuring**: Uses `.app` pattern matching to destructure `Derivable Γ (Formula.box φ).imp φ`
2. **Definitional Equality**: `isDefEq` handles α-equivalence and β-reduction automatically
3. **Proof Construction**: `mkAppM` infers implicit universe levels
4. **Error Handling**: Each pattern match level has specific error message

**Action Items**:
- [ ] Replace lines 118-141 with full `modal_t` implementation
- [ ] Add comprehensive docstring with usage examples and error messages
- [ ] Test compilation: `lake build Logos.Automation.Tactics`
- [ ] Run tests: `lake test LogosTest.Automation.TacticsTest`
- [ ] Verify 4 modal_t tests pass (2 success, 2 expected failures)

**Expected Output**: All 4 modal_t tests behave as expected (2 pass, 2 fail gracefully with informative errors).

---

### Step 5: Verify Implementation and Run Full Test Suite (1-2 hours)

**Objective**: Confirm all implementations work correctly and tests pass

**Verification Commands**:

```bash
# 1. Verify tactics compile without errors
lake build Logos.Automation.Tactics
# Expected: Build succeeds, zero errors

# 2. Run full tactic test suite
lake test LogosTest.Automation.TacticsTest
# Expected: 10 tests pass (8 apply_axiom + 2 modal_t success cases)
# Expected: 2 tests fail gracefully (2 modal_t error cases documented in comments)

# 3. Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 10 (down from 12)
# 2 sorry removed: apply_axiom (line 112) and modal_t (line 141)

# 4. Run lint checks
lake exe lean --run Logos/Automation/Tactics.lean 2>&1 | grep -i "warning"
# Expected: Zero warnings

# 5. Check test coverage
lake test --coverage LogosTest.Automation.TacticsTest
# Expected: ≥80% coverage for Tactics.lean
```

**Action Items**:
- [ ] Run all verification commands
- [ ] Fix any compilation errors or test failures
- [ ] Ensure sorry count decreased by exactly 2
- [ ] Verify zero lint warnings
- [ ] Document any unexpected behaviors or edge cases discovered

**Expected Output**: All verification checks pass, 2 sorry removed, zero lint warnings.

---

### Step 6: Update Documentation with Working Examples (1-2 hours)

**Objective**: Document implemented tactics with real working examples

**Files to Update**:

1. **TACTIC_DEVELOPMENT.md** (Update Section 2.5):
   - Replace placeholder with actual working `modal_t` implementation
   - Add "Tested and Working" badge
   - Add reference to `TacticsTest.lean` for usage examples

2. **METAPROGRAMMING_GUIDE.md** (Update Section 8):
   - Verify Example 1 (apply_axiom) matches implementation
   - Verify Example 2 (modal_t) matches implementation
   - Add "Implementation Status: ✅ Complete" markers

3. **Tactics.lean Module Docstring**:
   - Update "Implementation Status" section
   - Mark `apply_axiom` and `modal_t` as "✅ Implemented"
   - Update overall module completion percentage

**Documentation Template for Tactics.lean**:

```lean
/-!
# Automation Tactics for Logos TM Logic

This module provides custom tactics for automated proof construction in the
TM (Tense and Modality) bimodal logic system.

## Implementation Status (Phase 1 Complete)

**Phase 1 Tactics** (✅ Implemented):
- `apply_axiom` - Apply named axiom schema (all 8 axioms supported)
- `modal_t` - Apply modal T axiom (`□φ → φ`) with pattern matching

**Phase 2 Tactics** (⏸️ Planned):
- `tm_auto` - Comprehensive TM automation with Aesop integration

**Phase 3 Tactics** (⏸️ Planned):
- `assumption_search` - Search context for matching assumptions
- `modal_k` - Apply modal K inference rule
- `temporal_k` - Apply temporal K inference rule

## Usage Examples

### apply_axiom

```lean
theorem example_mt (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  apply_axiom MT P

theorem example_tl (P Q : Formula) :
    Derivable [] ((Formula.future (P.imp Q)).imp ((Formula.past P).imp (Formula.past Q))) := by
  apply Derivable.axiom
  apply_axiom TL P Q
```

### modal_t

```lean
theorem modal_t_simple (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply Derivable.axiom
  modal_t

theorem modal_t_nested (P Q : Formula) :
    Derivable [] ((Formula.box (P.and Q)).imp (P.and Q)) := by
  apply Derivable.axiom
  modal_t
```

## Testing

See `LogosTest/Automation/TacticsTest.lean` for comprehensive test suite.

Run tests: `lake test LogosTest.Automation.TacticsTest`

## References

- [METAPROGRAMMING_GUIDE.md](../../Documentation/Development/METAPROGRAMMING_GUIDE.md)
- [TACTIC_DEVELOPMENT.md](../../Documentation/Development/TACTIC_DEVELOPMENT.md)
- [CLAUDE.md Section 10.1](../../CLAUDE.md#lean-4-metaprogramming-and-automation-quick-reference)
-/
```

**Action Items**:
- [ ] Update TACTIC_DEVELOPMENT.md Section 2.5 with "✅ Implemented" badge
- [ ] Update METAPROGRAMMING_GUIDE.md Section 8 with "✅ Complete" markers
- [ ] Replace Tactics.lean module docstring with updated version
- [ ] Add usage examples from TacticsTest.lean
- [ ] Commit documentation updates with implementation

**Expected Output**: All documentation accurately reflects implemented tactics with working examples.

---

## Error Handling Patterns

### Common Errors and Solutions

**Error 1: Unknown axiom name**
```
apply_axiom INVALID_AXIOM P
→ Error: "Unknown axiom: INVALID_AXIOM. Supported axioms: MT, M4, MB, T4, TA, TL, MF, TF"
```
**Solution**: Use correct axiom name from supported list.

**Error 2: Wrong argument count**
```
apply_axiom TL P  -- TL requires 2 arguments
→ Error: "TL axiom requires exactly 2 formula arguments, got 1"
```
**Solution**: Provide correct number of formula arguments.

**Error 3: Goal doesn't match modal_t pattern**
```
theorem test (P Q : Formula) : Derivable [] ((Formula.box P).imp Q) := by
  modal_t
→ Error: "modal_t: expected `□φ → φ`, got `□P → Q` where φ ≠ ψ"
```
**Solution**: Use `apply_axiom MT P` or manual proof for mismatched formulas.

**Error 4: Goal not a derivability relation**
```
theorem test (P : Formula) : (Formula.box P).imp P := by
  modal_t
→ Error: "modal_t: goal must be derivability relation `Γ ⊢ φ`, got {goalType}"
```
**Solution**: Wrap goal in `Derivable []` or apply `Derivable.axiom` first.

---

## Testing Strategy

### Test Coverage Requirements

**Unit Tests**: ≥12 tests covering:
- All 8 axioms with `apply_axiom` (MT, M4, MB, T4, TA, TL, MF, TF)
- `modal_t` success cases (simple and nested formulas)
- `modal_t` failure cases (mismatch, non-implication)
- Error message validation

**Integration Tests**: 2-3 tests combining tactics:
- `apply Derivable.axiom; apply_axiom MT P`
- `apply Derivable.axiom; modal_t`

**Performance Tests**: 1-2 benchmarks:
- `apply_axiom` on deeply nested formula (depth 10)
- `modal_t` on complex conjunction formula

### Test Execution

```bash
# Run all tests
lake test LogosTest.Automation.TacticsTest

# Run specific test
lake test LogosTest.Automation.TacticsTest::test_apply_axiom_mt

# Run with coverage
lake test --coverage LogosTest.Automation.TacticsTest

# Expected: ≥80% coverage per CLAUDE.md Automation module target
```

---

## Completion Checklist

Before marking this stage complete, verify ALL items:

### Implementation
- [ ] `apply_axiom` tactic implemented with all 8 axioms
- [ ] `modal_t` tactic implemented with pattern matching
- [ ] Both tactics compile without errors
- [ ] Required imports added to Tactics.lean
- [ ] Comprehensive docstrings added to both tactics

### Testing
- [ ] TacticsTest.lean created with ≥12 tests
- [ ] All apply_axiom tests pass (8 tests)
- [ ] modal_t success tests pass (2 tests)
- [ ] modal_t failure tests documented (2 tests)
- [ ] Test suite runs successfully: `lake test LogosTest.Automation.TacticsTest`
- [ ] Coverage ≥80% for implemented tactics

### Quality
- [ ] Zero lint warnings in Tactics.lean
- [ ] 2 sorry removed (lines 112, 141)
- [ ] Sorry count verification: `grep -c "sorry" Tactics.lean` returns 10
- [ ] Error messages are informative and actionable

### Documentation
- [ ] TACTIC_DEVELOPMENT.md Section 2.5 updated
- [ ] METAPROGRAMMING_GUIDE.md Section 8 verified
- [ ] Tactics.lean module docstring updated
- [ ] Working examples added to documentation
- [ ] References to test suite included

### Verification
- [ ] Build succeeds: `lake build Logos.Automation.Tactics`
- [ ] Tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] Lint clean: Zero warnings
- [ ] Coverage meets target: ≥80%

**Total Checklist Items**: 24
**Required for Completion**: 24/24 (100%)

---

## Next Steps

After completing Stage 1:

**Immediate**: Proceed to Stage 2 (tm_auto with Aesop integration)
**Alternative**: Pause and assess time constraints before committing to Phase 2

**Stage 2 Preview**: Implement `tm_auto` tactic using Aesop integration for comprehensive automation (12-15 hours estimated).

---

## Estimated Time Breakdown

| Task | Estimated Hours | Notes |
|------|----------------|-------|
| Documentation review | 1-1.5 | METAPROGRAMMING_GUIDE.md + TACTIC_DEVELOPMENT.md |
| Test file creation (TDD) | 1-2 | 12 tests with expected behaviors |
| apply_axiom implementation | 3-4 | 8 axioms with error handling |
| modal_t implementation | 3-4 | Pattern matching + proof construction |
| Verification and testing | 1-2 | Run all checks, fix issues |
| Documentation updates | 1-2 | Update 3 files with working examples |
| **Total** | **10-13 hours** | Revised from 15-20 with documentation |

**Confidence Level**: High (documentation eliminates trial-and-error)
**Risk Factors**: Low (clear patterns, working examples available)
**Blocker Potential**: None (independent of other Wave 2 tasks)
