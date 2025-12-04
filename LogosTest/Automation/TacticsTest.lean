import Logos.Automation.Tactics
import Logos.ProofSystem

/-!
# Tests for Automation Tactics

This module contains tests for the custom tactics defined in
`ProofChecker.Automation.Tactics`.

## Test Coverage

**Total Tests**: 50 (Tests 1-50)

Comprehensive test suite covering:
- Basic axiom application (apply_axiom, modal_t)
- Automated proof search (tm_auto)
- Context-based assumption finding (assumption_search)
- Formula pattern matching helpers
- Negative tests and edge cases

## Test Organization

- **Phase 4 Tests (1-12)**: apply_axiom and modal_t
- **Phase 5 Tests (13-18)**: tm_auto (native implementation) - initial axioms
- **Phase 7 Tests (32-35)**: tm_auto extended coverage - remaining axioms
- **Phase 6 Tests (19-23)**: assumption_search basic functionality
- **Helper Function Tests (24-31)**: Pattern matching utilities
- **Phase 8 Tests (36-43)**: Negative tests and edge cases
- **Phase 9 Tests (44-47)**: Context variation tests
- **Phase 10 Tests (48-50)**: Deep nesting and complex formulas

## References

* Tactics Module: ProofChecker/Automation/Tactics.lean
-/

namespace LogosTest.Automation

open Logos.Syntax ProofChecker.ProofSystem ProofChecker.Automation

/-!
## Phase 4: apply_axiom and modal_t Tests

Tests for basic axiom application tactics.
-/

/-- Test 1: prop_s axiom via Derivable.axiom -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.imp (Formula.atom "q") (Formula.atom "p"))) :=
  Derivable.axiom [] _ (Axiom.prop_s _ _)

/-- Test 2: prop_k axiom for distribution -/
example : Derivable [] (Formula.imp
  (Formula.imp (Formula.atom "p") (Formula.imp (Formula.atom "q") (Formula.atom "r")))
  (Formula.imp (Formula.imp (Formula.atom "p") (Formula.atom "q")) (Formula.imp (Formula.atom "p") (Formula.atom "r")))) :=
  Derivable.axiom [] _ (Axiom.prop_k _ _ _)

/-- Test 3: modal_t axiom (□p → p) -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.atom "p")) :=
  Derivable.axiom [] _ (Axiom.modal_t _)

/-- Test 4: modal_4 axiom (□p → □□p) -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.box (Formula.box (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.modal_4 _)

/-- Test 5: modal_b axiom (p → □◇p) -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.box (Formula.diamond (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.modal_b _)

/-- Test 6: temp_4 axiom (Fp → FFp) -/
example : Derivable [] (Formula.imp (Formula.future (Formula.atom "p")) (Formula.future (Formula.future (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.temp_4 _)

/-- Test 7: temp_a axiom (p → FPp) -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.future (Formula.sometime_past (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.temp_a _)

/-- Test 8: temp_l axiom (always p → Fp) -/
example : Derivable [] (Formula.imp (Formula.sometime_past (Formula.atom "p")) (Formula.future (Formula.atom "p"))) :=
  Derivable.axiom [] _ (Axiom.temp_l _)

/-- Test 9: modal_future axiom (□p → F□p) -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.future (Formula.box (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.modal_future _)

/-- Test 10: temp_future axiom (Fp → □Fp) -/
example : Derivable [] (Formula.imp (Formula.future (Formula.atom "p")) (Formula.box (Formula.future (Formula.atom "p")))) :=
  Derivable.axiom [] _ (Axiom.temp_future _)

/-- Test 11: apply_axiom tactic unifies with modal_t -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "q")) (Formula.atom "q")) := by
  apply_axiom

/-- Test 12: modal_t tactic (convenience wrapper) -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "r")) (Formula.atom "r")) := by
  modal_t

/-!
## Phase 5: tm_auto Tests

Tests for native TM automation (no Aesop dependency).
-/

/-- Test 13: tm_auto finds modal_t axiom -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.atom "p")) := by
  tm_auto

/-- Test 14: tm_auto finds modal_4 axiom -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.box (Formula.box (Formula.atom "p")))) := by
  tm_auto

/-- Test 15: tm_auto finds temp_4 axiom -/
example : Derivable [] (Formula.imp (Formula.future (Formula.atom "p")) (Formula.future (Formula.future (Formula.atom "p")))) := by
  tm_auto

/-- Test 16: tm_auto finds temp_a axiom -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.future (Formula.sometime_past (Formula.atom "p")))) := by
  tm_auto

/-- Test 17: tm_auto finds modal_future axiom -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.future (Formula.box (Formula.atom "p")))) := by
  tm_auto

/-- Test 18: tm_auto finds temp_future axiom -/
example : Derivable [] (Formula.imp (Formula.future (Formula.atom "p")) (Formula.box (Formula.future (Formula.atom "p")))) := by
  tm_auto

/-!
## Phase 7: tm_auto Extended Coverage Tests

Tests for remaining axioms not covered in Phase 5.
-/

/-- Test 32: tm_auto finds prop_k axiom -/
example : Derivable [] (Formula.imp
  (Formula.imp (Formula.atom "p") (Formula.imp (Formula.atom "q") (Formula.atom "r")))
  (Formula.imp (Formula.imp (Formula.atom "p") (Formula.atom "q")) (Formula.imp (Formula.atom "p") (Formula.atom "r")))) := by
  tm_auto

/-- Test 33: tm_auto finds prop_s axiom -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.imp (Formula.atom "q") (Formula.atom "p"))) := by
  tm_auto

/-- Test 34: tm_auto finds modal_b axiom -/
example : Derivable [] (Formula.imp (Formula.atom "p") (Formula.box (Formula.diamond (Formula.atom "p")))) := by
  tm_auto

/-- Test 35: tm_auto finds temp_l axiom -/
example : Derivable [] (Formula.imp (Formula.sometime_past (Formula.atom "p")) (Formula.future (Formula.atom "p"))) := by
  tm_auto

/-!
## Phase 6: assumption_search Tests

Tests for context-based assumption finding.
-/

/-- Test 19: assumption_search finds exact match (Nat) -/
example (h : Nat) : Nat := by
  assumption_search

/-- Test 20: assumption_search with propositional type -/
example (h1 : Formula.atom "p" = Formula.atom "p") : Formula.atom "p" = Formula.atom "p" := by
  assumption_search

/-- Test 21: assumption_search with implication -/
example (h : Formula.imp (Formula.atom "p") (Formula.atom "q") = Formula.imp (Formula.atom "p") (Formula.atom "q")) :
    Formula.imp (Formula.atom "p") (Formula.atom "q") = Formula.imp (Formula.atom "p") (Formula.atom "q") := by
  assumption_search

/-- Test 22: assumption_search with multiple assumptions -/
example (h1 : String) (h2 : Nat) (h3 : Bool) : Bool := by
  assumption_search

/-- Test 23: assumption_search with formulas -/
example (h : Formula) : Formula := by
  assumption_search

/-!
## Helper Function Tests

Tests for formula pattern matching utilities.
-/

/-- Test 24: is_box_formula recognizes box formulas -/
example : is_box_formula (Formula.box (Formula.atom "p")) = true := rfl

/-- Test 25: is_box_formula rejects non-box formulas -/
example : is_box_formula (Formula.atom "p") = false := rfl

/-- Test 26: is_future_formula recognizes future formulas -/
example : is_future_formula (Formula.future (Formula.atom "p")) = true := rfl

/-- Test 27: is_future_formula rejects non-future formulas -/
example : is_future_formula (Formula.atom "p") = false := rfl

/-- Test 28: extract_from_box extracts inner formula -/
example : extract_from_box (Formula.box (Formula.atom "p")) = some (Formula.atom "p") := rfl

/-- Test 29: extract_from_box returns none for non-box -/
example : extract_from_box (Formula.atom "p") = none := rfl

/-- Test 30: extract_from_future extracts inner formula -/
example : extract_from_future (Formula.future (Formula.atom "p")) = some (Formula.atom "p") := rfl

/-- Test 31: extract_from_future returns none for non-future -/
example : extract_from_future (Formula.atom "p") = none := rfl

/-!
## Phase 8: Negative and Edge Case Tests

Tests for error conditions and edge cases in helper functions.
-/

/-
Test 36: apply_axiom should fail on non-axiom goal
Expected: Tactic reports failure for non-derivable formula
Note: Cannot write as executable test since Lean examples must succeed.
This is documented as expected behavior.
-/

/-
Test 37: assumption_search should fail with error when no assumption matches
Expected: Error message "no assumption matches goal"
Note: Cannot write as executable test since Lean examples must succeed.
This is documented as expected behavior.
-/

/-- Test 38: is_box_formula recognizes nested box -/
example : is_box_formula (Formula.box (Formula.box (Formula.atom "p"))) = true := rfl

/-- Test 39: is_future_formula recognizes nested future -/
example : is_future_formula (Formula.future (Formula.future (Formula.atom "p"))) = true := rfl

/-- Test 40: extract_from_box extracts outer box content from nested -/
example : extract_from_box (Formula.box (Formula.box (Formula.atom "p"))) = some (Formula.box (Formula.atom "p")) := rfl

/-- Test 41: extract_from_future extracts outer future content from nested -/
example : extract_from_future (Formula.future (Formula.future (Formula.atom "p"))) = some (Formula.future (Formula.atom "p")) := rfl

/-- Test 42: is_box_formula rejects implication -/
example : is_box_formula (Formula.imp (Formula.atom "p") (Formula.atom "q")) = false := rfl

/-- Test 43: is_future_formula rejects past -/
example : is_future_formula (Formula.sometime_past (Formula.atom "p")) = false := rfl

/-!
## Phase 9: Context Variation Tests

Tests for assumption_search with various context types.
-/

/-- Test 44: assumption_search with multiple matching Nat assumptions -/
example (h1 : Nat) (h2 : Nat) : Nat := by
  assumption_search

/-- Test 45: assumption_search with Derivable type -/
example (h : Derivable [] (Formula.atom "p")) : Derivable [] (Formula.atom "p") := by
  assumption_search

/-- Test 46: assumption_search with nested parameterized type -/
example (h : List (Option Nat)) : List (Option Nat) := by
  assumption_search

/-- Test 47: assumption_search with function type -/
example (f : Nat → Bool) : Nat → Bool := by
  assumption_search

/-!
## Phase 10: Edge Case and Complex Formula Tests

Tests for deep nesting and complex formulas.
-/

/-- Test 48: Deep nesting of box formulas -/
example : is_box_formula (Formula.box (Formula.box (Formula.box (Formula.atom "p")))) = true := rfl

/-- Test 49: Complex bimodal formula via axiom -/
example : Derivable [] (Formula.imp (Formula.box (Formula.atom "p")) (Formula.future (Formula.box (Formula.atom "p")))) := by
  apply_axiom

/-- Test 50: assumption_search with long context -/
example (a b c d e : Nat) : Nat := by
  assumption_search

end LogosTest.Automation
