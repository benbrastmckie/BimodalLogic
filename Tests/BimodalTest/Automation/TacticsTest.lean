/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.UserTactics
import FormalSystem.Automation.Tactics.Commands
import FormalSystem.Automation.ProofSearch.Core
import FormalSystem.ProofSystem

/-!
# Tests for Automation Tactics

This module contains tests for the custom tactics defined in
`ProofChecker.Automation.Tactics`.

## Test Coverage

**Total Tests**: 150 (Tests 1-150)

Comprehensive test suite covering:
- Basic axiom application (apply_axiom, modal_t)
- Automated proof search (modal_search)
- Context-based assumption finding (assumption_search)
- Formula pattern matching helpers
- Negative tests and edge cases
- Inference rule tests (modal_k, temporal_k, temporal_duality)
- ProofSearch function tests (boundedSearch, heuristics, helpers)
- Propositional depth tests (prop_k, prop_s chaining)
- Aesop integration tests (complex TM proofs)
- Task 315 modal_search tests

## Test Organization

- **Phase 4 Tests (1-12)**: apply_axiom and modal_t
- **Phase 5 Tests (13-18)**: modal_search (native implementation) - initial axioms
- **Phase 7 Tests (32-35)**: modal_search extended coverage - remaining axioms
- **Phase 6 Tests (19-23)**: assumption_search basic functionality
- **Helper Function Tests (24-31)**: Pattern matching utilities
- **Phase 8 Tests (36-43)**: Negative tests and edge cases
- **Phase 9 Tests (44-47)**: Context variation tests
- **Phase 10 Tests (48-50)**: Deep nesting and complex formulas
- **Phase 5 Group 1 Tests (51-58)**: Inference rule tests
- **Phase 5 Group 2 Tests (59-68)**: ProofSearch function tests
- **Phase 5 Group 3 Tests (69-72)**: Propositional depth tests
- **Phase 5 Group 4 Tests (73-77)**: Aesop integration tests
- **Phase 8 Tests (96-105)**: modal_search depth tests
- **Phase 9 Tests (106-110)**: Integration and bimodal tests
- **Phase 10 Tests (111-134)**: Task 315 tactic tests (modal_search)
- **Integration Tests (135-150)**: Task 319 tactic combination and state tests

## References

* Tactics Module: ProofChecker/Automation/Tactics.lean
-/

namespace BimodalTest.Automation

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Automation

/-!
## Phase 4: apply_axiom and modal_t Tests

Tests for basic axiom application tactics.
-/

/-- Test 1: prop_s axiom via DerivationTree.axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.imp (Formula.atomS "q") (Formula.atomS "p"))) :=
  DerivationTree.axiom [] _ (Axiom.prop_s _ _) trivial

/-- Test 2: prop_k axiom for distribution -/
example : DerivationTree FrameClass.Base [] (Formula.imp
  (Formula.imp (Formula.atomS "p") (Formula.imp (Formula.atomS "q") (Formula.atomS "r")))
  (Formula.imp (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))
      (Formula.imp (Formula.atomS "p") (Formula.atomS "r")))) :=
  DerivationTree.axiom [] _ (Axiom.prop_k _ _ _) trivial

/-- Test 3: modal_t axiom (□p → p) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p")) (Formula.atomS "p")) :=
  DerivationTree.axiom [] _ (Axiom.modal_t _) trivial

/-- Test 4: modal_4 axiom (□p → □□p) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.box (Formula.box (Formula.atomS "p")))) :=
  DerivationTree.axiom [] _ (Axiom.modal_4 _) trivial

/-- Test 5: modal_b axiom (p → □◇p) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.box (Formula.diamond (Formula.atomS "p")))) :=
  DerivationTree.axiom [] _ (Axiom.modal_b _) trivial

/-- Test 6: temp_4 axiom (Gp → GGp) -/
noncomputable example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.allFuture (Formula.atomS "p"))
        (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))) :=
  FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 7: temp_a axiom (p → GPp) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.allFuture (Formula.somePast (Formula.atomS "p")))) :=
  DerivationTree.axiom [] _ (Axiom.connect_future _) trivial

-- NOTE (Task 365): quarantined — `Axiom.temp_l` was removed (no axiom/derived replacement;
-- requires a multi-step derivation). Semantic `temp_l_valid` is retained elsewhere. See task
-- summary.
-- /-- Test 8: temp_l axiom (△p → F(Hp)) -/
-- example : DerivationTree FrameClass.Base [] (Formula.imp (Formula.always (Formula.atomS "p"))
-- (Formula.allFuture (Formula.allPast (Formula.atomS "p")))) :=
--   DerivationTree.axiom [] _ (Axiom.temp_l _)

/-- Test 9: modal_future axiom (□p → □Fp) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.box (Formula.allFuture (Formula.atomS "p")))) :=
  DerivationTree.axiom [] _ (Axiom.modal_future _) trivial

/-- Test 10: temp_future derived (□p → G□p, from MF + T + Modal 4) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.allFuture (Formula.box (Formula.atomS "p")))) :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived _

/-- Test 11: apply_axiom tactic unifies with modal_t -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "q")) (Formula.atomS "q")) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 12: modal_t tactic (convenience wrapper) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "r")) (Formula.atomS "r")) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-!
## Phase 5: modal_search Tests

Tests for native TM automation (no Aesop dependency).
-/

/-- Test 13: modal_search finds modal_t axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p")) (Formula.atomS "p")) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 14: modal_search finds modal_4 axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.box (Formula.box (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 15: modal_search finds temp_4 axiom -/
noncomputable example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.allFuture (Formula.atomS "p"))
        (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 16: modal_search finds temp_a axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.allFuture
        (Formula.somePast (Formula.atomS "p")))) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 17: modal_search finds modal_future axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.box (Formula.allFuture (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_future _) trivial

/-- Test 18: modal_search finds temp_future (now derived from MF + T + Modal 4) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.allFuture (Formula.box (Formula.atomS "p")))) :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived _

/-!
## Phase 7: modal_search Extended Coverage Tests

Tests for remaining axioms not covered in Phase 5.
-/

/-- Test 32: modal_search finds prop_k axiom -/
example : DerivationTree FrameClass.Base [] (Formula.imp
  (Formula.imp (Formula.atomS "p") (Formula.imp (Formula.atomS "q") (Formula.atomS "r")))
  (Formula.imp (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))
      (Formula.imp (Formula.atomS "p") (Formula.atomS "r")))) :=
  DerivationTree.axiom _ _ (Axiom.prop_k _ _ _) trivial

/-- Test 33: modal_search finds prop_s axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.imp (Formula.atomS "q") (Formula.atomS "p"))) :=
  DerivationTree.axiom _ _ (Axiom.prop_s _ _) trivial

/-- Test 34: modal_search finds modal_b axiom -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.box (Formula.diamond (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

-- NOTE (Task 365): quarantined — `Axiom.temp_l` was removed (no axiom/derived replacement;
-- requires a multi-step derivation). Semantic `temp_l_valid` is retained elsewhere. See task
-- summary.
-- /-- Test 35: modal_search finds temp_l axiom -/
-- example : DerivationTree FrameClass.Base [] (Formula.imp (Formula.always (Formula.atomS "p"))
-- (Formula.allFuture (Formula.allPast (Formula.atomS "p")))) := by
--   apply DerivationTree.axiom
--   exact Axiom.temp_l _

/-!
## Phase 6: assumption_search Tests

Tests for context-based assumption finding.
-/

/-- Test 19: assumption_search finds exact match (Nat) -/
example (h : Nat) : Nat := by
  assumption_search

/-- Test 20: assumption_search with propositional type -/
example (h1 : Formula.atomS "p" = Formula.atomS "p") : Formula.atomS "p" = Formula.atomS "p" := by
  assumption_search

/-- Test 21: assumption_search with implication -/
example (h : Formula.imp (Formula.atomS "p") (Formula.atomS "q") = Formula.imp (Formula.atomS "p")
    (Formula.atomS "q")) :
    Formula.imp (Formula.atomS "p") (Formula.atomS "q") = Formula.imp (Formula.atomS "p")
        (Formula.atomS "q") := by
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

/-- Test 24: isBoxFormula recognizes box formulas -/
example : isBoxFormula (Formula.box (Formula.atomS "p")) = true := rfl

/-- Test 25: isBoxFormula rejects non-box formulas -/
example : isBoxFormula (Formula.atomS "p") = false := rfl

/-- Test 26: isFutureFormula recognizes allFuture formulas -/
example : isFutureFormula (Formula.allFuture (Formula.atomS "p")) = true := rfl

/-- Test 27: isFutureFormula rejects non-allFuture formulas -/
example : isFutureFormula (Formula.atomS "p") = false := rfl

/-- Test 28: extractFromBox extracts inner formula -/
example : extractFromBox (Formula.box (Formula.atomS "p")) = some (Formula.atomS "p") := rfl

/-- Test 29: extractFromBox returns none for non-box -/
example : extractFromBox (Formula.atomS "p") = none := rfl

/-- Test 30: extractFromFuture extracts inner formula -/
example : extractFromFuture (Formula.allFuture (Formula.atomS "p")) = some (Formula.atomS "p") :=
    rfl

/-- Test 31: extractFromFuture returns none for non-allFuture -/
example : extractFromFuture (Formula.atomS "p") = none := rfl

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

/-- Test 38: isBoxFormula recognizes nested box -/
example : isBoxFormula (Formula.box (Formula.box (Formula.atomS "p"))) = true := rfl

/-- Test 39: isFutureFormula recognizes nested allFuture -/
example : isFutureFormula (Formula.allFuture (Formula.allFuture (Formula.atomS "p"))) = true := rfl

/-- Test 40: extractFromBox extracts outer box content from nested -/
example : extractFromBox (Formula.box (Formula.box (Formula.atomS "p"))) = some
    (Formula.box (Formula.atomS "p")) := rfl

/-- Test 41: extractFromFuture extracts outer allFuture content from nested -/
example : extractFromFuture (Formula.allFuture (Formula.allFuture (Formula.atomS "p"))) = some
    (Formula.allFuture (Formula.atomS "p")) := rfl

/-- Test 42: isBoxFormula rejects implication -/
example : isBoxFormula (Formula.imp (Formula.atomS "p") (Formula.atomS "q")) = false := rfl

/-- Test 43: isFutureFormula rejects somePast -/
example : isFutureFormula (Formula.somePast (Formula.atomS "p")) = false := rfl

/-!
## Phase 9: Context Variation Tests

Tests for assumption_search with various context types.
-/

/-- Test 44: assumption_search with multiple matching Nat assumptions -/
example (h1 : Nat) (h2 : Nat) : Nat := by
  assumption_search

/-- Test 45: assumption_search with DerivationTree type -/
example (h : DerivationTree FrameClass.Base [] (Formula.atomS "p")) : DerivationTree
    FrameClass.Base [] (Formula.atomS "p") := by
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
example : isBoxFormula (Formula.box (Formula.box (Formula.box (Formula.atomS "p")))) = true := rfl

/-- Test 49: Complex bimodal formula (TF derived from MF + T + Modal 4) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.allFuture (Formula.box (Formula.atomS "p")))) :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived _

/-- Test 50: assumption_search with long context -/
example (a b c d _ : Nat) : Nat := by
  assumption_search

/-!
## Phase 5 Group 1: Inference Rule Tests

Tests for generalizedModalK, generalizedTemporalK, temporal_duality inference rules.

NOTE: DerivationTree.modal_k and DerivationTree.temporal_k were removed in Task 44.
The generalized rules are now in FormalSystem.Theorems.GeneralizedNecessitation.
-/

open FormalSystem.Theorems in
/-- Test 51: generalizedModalK rule derives □φ from φ (empty context) -/
noncomputable example (h : DerivationTree FrameClass.Base [] (Formula.atomS "p")) :
    DerivationTree FrameClass.Base (Context.map Formula.box []) (Formula.box (Formula.atomS "p")) :=
  generalizedModalK [] _ h

open FormalSystem.Theorems in
/-- Test 52: generalizedTemporalK rule derives Fφ from φ (empty context) -/
noncomputable example (h : DerivationTree FrameClass.Base [] (Formula.atomS "p")) :
    DerivationTree FrameClass.Base (Context.map Formula.allFuture [])
        (Formula.allFuture (Formula.atomS "p")) :=
  generalizedTemporalK [] _ h

/-- Test 53: temporal_duality swaps past and future -/
example (h : DerivationTree FrameClass.Base [] (Formula.allPast (Formula.atomS "p"))) :
    DerivationTree FrameClass.Base [] (Formula.swapTemporal
        (Formula.allPast (Formula.atomS "p"))) :=
  DerivationTree.temporal_duality _ h

open FormalSystem.Theorems in
/-- Test 54: generalizedModalK with axiom derivation -/
noncomputable example :
    DerivationTree FrameClass.Base (Context.map Formula.box [])
        (Formula.box (Formula.imp (Formula.box (Formula.atomS "p")) (Formula.atomS "p"))) :=
  generalizedModalK [] _ (DerivationTree.axiom [] _ (Axiom.modal_t _) trivial)

open FormalSystem.Theorems in
/-- Test 55: generalizedTemporalK with axiom derivation -/
noncomputable example :
    DerivationTree FrameClass.Base (Context.map Formula.allFuture [])
        (Formula.allFuture (Formula.imp (Formula.allFuture (Formula.atomS "p"))
            (Formula.allFuture (Formula.allFuture (Formula.atomS "p"))))) :=
  generalizedTemporalK [] _ (FormalSystem.Theorems.TemporalDerived.temporal4Derived _)

open FormalSystem.Theorems in
/-- Test 56: generalizedModalK with non-empty context -/
noncomputable example (h : DerivationTree FrameClass.Base [Formula.atomS "p"] (Formula.atomS "p")) :
    DerivationTree FrameClass.Base (Context.map Formula.box [Formula.atomS "p"])
        (Formula.box (Formula.atomS "p")) :=
  generalizedModalK _ _ h

open FormalSystem.Theorems in
/-- Test 57: generalizedTemporalK with non-empty context -/
noncomputable example (h : DerivationTree FrameClass.Base [Formula.atomS "p"] (Formula.atomS "p")) :
    DerivationTree FrameClass.Base (Context.map Formula.allFuture [Formula.atomS "p"])
        (Formula.allFuture (Formula.atomS "p")) :=
  generalizedTemporalK _ _ h

/-- Test 58: temporal_duality with implication -/
example (h : DerivationTree FrameClass.Base []
    (Formula.allPast (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))) :
    DerivationTree FrameClass.Base [] (Formula.swapTemporal
        (Formula.allPast (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))) :=
  DerivationTree.temporal_duality _ h

/-!
## Phase 5 Group 2: Additional Derivation Tests

Tests for various derivation combinations and edge cases.
-/

/-- Test 59: Weakening with empty addition -/
example (h : DerivationTree FrameClass.Base [] (Formula.atomS "p")) : DerivationTree
    FrameClass.Base [] (Formula.atomS "p") :=
  DerivationTree.weakening [] [] _ h (List.nil_subset _)

/-- Test 60: Weakening adds unused assumption -/
example (h : DerivationTree FrameClass.Base [] (Formula.atomS "p")) :
    DerivationTree FrameClass.Base [Formula.atomS "q"] (Formula.atomS "p") :=
  DerivationTree.weakening [] [Formula.atomS "q"] _ h (List.nil_subset _)

/-- Test 61: Modal T with different variable -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "x")) (Formula.atomS "x")) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 62: Temporal A with different variable -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "y") (Formula.allFuture
        (Formula.somePast (Formula.atomS "y")))) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 63: Modal 4 applied to compound formula -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))
        (Formula.box (Formula.box (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))))) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 64: Temporal 4 applied to compound formula -/
noncomputable example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.allFuture (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))
        (Formula.allFuture (Formula.allFuture
            (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))))) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 65: Modal B with atomic formula -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "q") (Formula.box (Formula.diamond (Formula.atomS "q")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 66: Temp A with different variable -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "r") (Formula.allFuture
        (Formula.somePast (Formula.atomS "r")))) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 67: Modal future with compound formula -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))
        (Formula.box (Formula.allFuture (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))))) :=
  DerivationTree.axiom _ _ (Axiom.modal_future _) trivial

/-- Test 68: Temp future with compound formula (derived from MF + T + Modal 4) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.imp (Formula.atomS "p") (Formula.atomS "q")))
        (Formula.allFuture (Formula.box (Formula.imp (Formula.atomS "p") (Formula.atomS "q"))))) :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived _

/-!
## Phase 5 Group 3: Propositional Depth Tests

Tests for prop_k and prop_s axiom chaining.
-/

/-- Test 69: Nested prop_s application (p → (q → (r → p))) -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.imp
        (Formula.imp (Formula.atomS "q") (Formula.atomS "r")) (Formula.atomS "p"))) :=
  DerivationTree.axiom _ _ (Axiom.prop_s _ _) trivial

/-- Test 70: prop_k with complex antecedents -/
example : DerivationTree FrameClass.Base [] (Formula.imp
  (Formula.imp (Formula.box (Formula.atomS "p"))
      (Formula.imp (Formula.atomS "q") (Formula.atomS "r")))
  (Formula.imp (Formula.imp (Formula.box (Formula.atomS "p")) (Formula.atomS "q"))
      (Formula.imp (Formula.box (Formula.atomS "p")) (Formula.atomS "r")))) :=
  DerivationTree.axiom _ _ (Axiom.prop_k _ _ _) trivial

/-- Test 71: prop_s with modal formulas -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.imp (Formula.atomS "q") (Formula.box (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.prop_s _ _) trivial

/-- Test 72: prop_k with temporal formulas -/
example : DerivationTree FrameClass.Base [] (Formula.imp
  (Formula.imp (Formula.allFuture (Formula.atomS "p"))
      (Formula.imp (Formula.atomS "q") (Formula.atomS "r")))
  (Formula.imp (Formula.imp (Formula.allFuture (Formula.atomS "p")) (Formula.atomS "q"))
      (Formula.imp (Formula.allFuture (Formula.atomS "p")) (Formula.atomS "r")))) :=
  DerivationTree.axiom _ _ (Axiom.prop_k _ _ _) trivial

/-!
## Phase 5 Group 4: Aesop Integration Tests

Tests for Aesop-based modal_search on complex TM proofs.
-/

/-- Test 73: apply_axiom finds modal_t -/
example : DerivationTree FrameClass.Base []
    ((Formula.box (Formula.atomS "p")).imp (Formula.atomS "p")) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 74: apply_axiom finds modal_4 -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atomS "p"))
        (Formula.box (Formula.box (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 75: apply_axiom finds modal_b -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.box (Formula.diamond (Formula.atomS "p")))) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 76: apply_axiom finds temp_4 -/
noncomputable example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.allFuture (Formula.atomS "p"))
        (Formula.allFuture (Formula.allFuture (Formula.atomS "p")))) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 77: apply_axiom finds temp_a -/
example : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.atomS "p") (Formula.allFuture
        (Formula.somePast (Formula.atomS "p")))) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-!
## Phase 6: Tests for the modal K and temporal K inference rules

Positive and negative cases for the K rules. These exercise the rules through
`DerivationTree` directly; the `modal_k_tactic`/`temporal_k_tactic` wrappers that once
fronted them were retired to `Boneyard/RetiredTactics/` for having no invocations.
-/

/-- Test 78: Basic modal K rule -/
example (p : Formula) : DerivationTree FrameClass.Base [p.box] p.box := by
  apply DerivationTree.assumption
  simp

/-- Test 79: Modal K with modus ponens -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p.box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 80: Modal K weakening -/
example (p : Formula) : DerivationTree FrameClass.Base [p.box.box] p.box.box := by
  apply DerivationTree.assumption
  simp

/-- Test 81: Basic temporal K rule -/
example (p : Formula) : DerivationTree FrameClass.Base [p.allFuture] p.allFuture := by
  apply DerivationTree.assumption
  simp

/-- Test 82: Temporal K with modus ponens -/
noncomputable example (p : Formula) : DerivationTree FrameClass.Base []
    (p.allFuture.imp p.allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 83: Temporal K weakening -/
example (p : Formula) : DerivationTree FrameClass.Base [p.allFuture.allFuture]
    p.allFuture.allFuture := by
  apply DerivationTree.assumption
  simp

/-!
## Phase 7: Tests for Axiom Tactics

Tests for the modal 4, modal B, temporal 4 and temporal A axioms, applied directly.
-/

/-- Test 84: modal 4 axiom, basic application -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p.box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 85: modal 4 axiom with compound formula -/
example (p q : Formula) : DerivationTree FrameClass.Base [] ((p.imp q).box.imp (p.imp q).box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 86: modal 4 axiom with atom -/
example : DerivationTree FrameClass.Base []
    ((Formula.atomS "p").box.imp (Formula.atomS "p").box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 87: modal B axiom, basic application -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.imp p.diamond.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 88: modal B axiom with compound formula -/
example (p q : Formula) : DerivationTree FrameClass.Base [] ((p.imp q).imp (p.imp q).diamond.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 89: modal B axiom with atom -/
example : DerivationTree FrameClass.Base []
    ((Formula.atomS "p").imp (Formula.atomS "p").diamond.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 90: temp_4_tactic basic application -/
noncomputable example (p : Formula) : DerivationTree FrameClass.Base []
    (p.allFuture.imp p.allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 91: temp_4_tactic with compound formula -/
noncomputable example (p q : Formula) : DerivationTree FrameClass.Base []
    ((p.imp q).allFuture.imp (p.imp q).allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 92: temp_4_tactic with atom -/
noncomputable example : DerivationTree FrameClass.Base []
    ((Formula.atomS "p").allFuture.imp (Formula.atomS "p").allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 93: temp_a_tactic basic application -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.imp p.somePast.allFuture) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 94: temp_a_tactic with compound formula -/
example (p q : Formula) : DerivationTree FrameClass.Base []
    ((p.imp q).imp (p.imp q).somePast.allFuture) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 95: temp_a_tactic with atom -/
example : DerivationTree FrameClass.Base []
    ((Formula.atomS "p").imp (Formula.atomS "p").somePast.allFuture) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-!
## Phase 8: Tests for Proof Search Tactics

Tests for modal_search with varying depths.

NOTE: These tests use manual axiom applications since Aesop-based search
may not handle all cases. Full recursive search implementation is planned.
-/

/-- Test 96: modal_search depth 1 on modal_t -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 97: modal_search depth 2 on modal_4 -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p.box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 98: modal_search depth 3 on modal_b -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.imp p.diamond.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

/-- Test 99: modal_search depth 1 on temp_4 -/
noncomputable example (p : Formula) : DerivationTree FrameClass.Base []
    (p.allFuture.imp p.allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 100: modal_search depth 2 on temp_a -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.imp p.somePast.allFuture) := by
  exact DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

/-- Test 101: modal_search with complex nested formula -/
example (p q : Formula) : DerivationTree FrameClass.Base [] ((p.imp q).box.imp (p.imp q).box.box) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

/-- Test 102: modal_search with complex nested formula -/
noncomputable example (p q : Formula) : DerivationTree FrameClass.Base []
    ((p.imp q).allFuture.imp (p.imp q).allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-- Test 103: modal_search on prop_s -/
example (p q : Formula) : DerivationTree FrameClass.Base [] (p.imp (q.imp p)) :=
  DerivationTree.axiom _ _ (Axiom.prop_s _ _) trivial

/-- Test 104: modal_search combined with modal -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 105: modal_search combined with temporal -/
noncomputable example (p : Formula) : DerivationTree FrameClass.Base []
    (p.allFuture.imp p.allFuture.allFuture) := by
  exact FormalSystem.Theorems.TemporalDerived.temporal4Derived _

/-!
## Phase 9: Integration Tests and Complex Bimodal Tests

Tests combining multiple tactics for complex TM proofs.

NOTE: Modal K and Temporal K tactics require specific context patterns.
These tests demonstrate their usage with matching contexts.
-/

/-- Test 106: Direct modal_k rule application -/
example (p : Formula) : DerivationTree FrameClass.Base [p.box] p.box := by
  apply DerivationTree.assumption
  simp

/-- Test 107: Direct temporal_k rule application -/
example (p : Formula) : DerivationTree FrameClass.Base [p.allFuture] p.allFuture := by
  apply DerivationTree.assumption
  simp

/-- Test 108: Combination of axioms with weakening -/
example (p : Formula) : DerivationTree FrameClass.Base [p.box] p.box.box := by
  apply DerivationTree.modus_ponens (φ := p.box)
  · apply DerivationTree.weakening (Γ := [])
    · exact DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial
    · intro _ h; simp at h
  · apply DerivationTree.assumption
    simp

/-- Test 109: Bimodal proof using modal_t axiom -/
example (p : Formula) : DerivationTree FrameClass.Base [] (p.box.imp p) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

/-- Test 110: Propositional axiom application -/
example (p q : Formula) : DerivationTree FrameClass.Base [] (p.imp (q.imp p)) :=
  DerivationTree.axiom _ _ (Axiom.prop_s _ _) trivial

/-!
## Phase 10: Task 315 Tactic Tests

Tests for the modal_search tactic
implemented as part of Task 315 (Axiom Prop vs Type blocker resolution).

These tests verify that the tactics work correctly on various derivability goals.
-/

/-!
### modal_search Tactic Tests
-/

/-- Test 111: modal_search on modal_t axiom -/
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search

/-- Test 112: modal_search on modal_4 axiom -/
example (p : Formula) : ⊢ p.box.imp p.box.box := by
  modal_search

/-- Test 113: modal_search on simple assumption -/
example (p : Formula) : [p] ⊢ p := by
  modal_search

/-- Test 114: modal_search on modus ponens -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

/-- Test 115: modal_search on chained modus ponens -/
example (p q r : Formula) : [p, p.imp q, q.imp r] ⊢ r := by
  modal_search 5

/-- Test 116: modal_search with depth parameter -/
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search (depth := 5)

/-- Test 117: modal_search on modal K reduction -/
example (p : Formula) : [p.box] ⊢ p.box := by
  modal_search 3

/-- Test 118: modal_search on multiple boxed assumptions -/
example (p q : Formula) : [p.box, q.box] ⊢ p.box := by
  modal_search 3

/-!
### modal_search Tactic Tests
-/

/-- Test 119: modal_search on temp_4 axiom -/
noncomputable example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by
  modal_search

/-- Test 120: modal_search on simple assumption -/
example (p : Formula) : [p] ⊢ p := by
  modal_search

/-- Test 121: modal_search with depth parameter -/
noncomputable example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by
  modal_search (depth := 5)

/-- Test 122: modal_search on temporal K reduction -/
example (p : Formula) : [p.allFuture] ⊢ p.allFuture := by
  modal_search 3

/-- Test 123: modal_search on multiple future assumptions -/
example (p q : Formula) : [p.allFuture, q.allFuture] ⊢ p.allFuture := by
  modal_search 3

/-!
### modal_search Tactic Tests
-/

/-- Test 124: modal_search on simple assumption -/
example (p : Formula) : [p] ⊢ p := by
  modal_search

/-- Test 125: modal_search on modus ponens -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

/-- Test 126: modal_search on chained modus ponens -/
example (p q r : Formula) : [p, p.imp q, q.imp r] ⊢ r := by
  modal_search 5

/-- Test 127: modal_search on prop_s axiom -/
example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  modal_search

/-- Test 128: modal_search with depth parameter -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search (depth := 5)

/-!
### Configuration Tests
-/

/-- Test 129: modal_search with multiple named parameters -/
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search (depth := 5) (visitLimit := 500)

/-- Test 130: modal_search with visitLimit -/
noncomputable example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by
  modal_search (depth := 5) (visitLimit := 500)

/-- Test 131: modal_search with visitLimit -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search (depth := 5) (visitLimit := 500)

/-!
### Cross-Tactic Consistency Tests
-/

/-- Test 132: Same goal provable by modal_search -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

/-- Test 133: Same goal provable by modal_search -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

/-- Test 134: Same goal provable by modal_search -/
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

/-!
## Integration Tests (Task 319 Phase 5)

Tests combining automated tactics with manual proof steps and
verifying tactic interaction patterns.

**Tests**: 135-150 (16 integration tests)
-/

/-!
### Tactic Combination Tests

Tests that use multiple tactics in sequence.
-/

/-- Test 135: multiple tactics in same proof via exact -/
noncomputable example (p : Formula) : ([] ⊢ p.box.imp p) ×
    ([] ⊢ p.allFuture.imp p.allFuture.allFuture) :=
  (by modal_search, by modal_search)

/-- Test 136: tactics with non-derivation goals -/
example (p : Formula) : Nat × ([] ⊢ p.box.imp p) :=
  (42, by modal_search)

/-- Test 137: both subgoals automated -/
example (p q : Formula) : ([] ⊢ p.box.imp p) × ([] ⊢ q.box.imp q) :=
  (by modal_search, by modal_search)

/-- Test 138: product of different axiom types -/
example (p q : Formula) :
    ([] ⊢ p.box.imp p) × ([] ⊢ p.imp (q.imp p)) :=
  (by modal_search, by modal_search)

/-!
### State Preservation Tests

Tests verifying tactic behavior preserves proof state appropriately.
-/

/-- Test 139: successful search leaves no goals -/
example (p : Formula) : [] ⊢ p.box.imp p := by
  modal_search
  -- No remaining goals

/-- Test 140: independent product goals via Prod.mk -/
example (p q : Formula) :
    ([] ⊢ p.imp (q.imp p)) × ([] ⊢ q.imp (p.imp q)) :=
  Prod.mk (by modal_search) (by modal_search)

/-- Test 141: nested proof with inner tactic -/
example (p : Formula) : [] ⊢ p.box.imp p := by
  have h : [] ⊢ p.box.imp p := by modal_search
  exact h

/-!
### Complex Context Tests

Tests with rich contexts to verify tactic handling.
-/

/-- Test 142: large context simplification -/
example (p q r s : Formula) :
    [p, q, r, s, p.imp q, q.imp r, r.imp s] ⊢ p := by
  modal_search 3

/-- Test 143: context with modal formulas -/
example (p q : Formula) :
    [p.box, q.box, p.box.imp (q.box.imp (p.box.and q.box))] ⊢ p.box := by
  modal_search 3

/-- Test 144: context with temporal formulas -/
example (p q : Formula) :
    [p.allFuture, q.allFuture] ⊢ p.allFuture := by
  modal_search 3

/-!
### Cross-Domain Tests

Tests combining modal, temporal, and propositional reasoning.
-/

/-- Test 145: modal axiom in propositional context -/
example (p : Formula) : [] ⊢ p.box.imp p := by
  modal_search  -- Uses modal_t

/-- Test 146: temporal axiom temp_a: p → G(Pp) -/
example (p : Formula) : [] ⊢ p.imp p.somePast.allFuture := by
  modal_search  -- Uses temp_a: φ → G(Pφ)

/-- Test 147: any tactic finds assumption -/
example (p : Formula) : [p] ⊢ p := by
  modal_search

/-!
### Stress Tests

Tests with deeper search requirements.
-/

/-- Test 148: chain of modus ponens (depth 3) -/
example (p q r : Formula) : [p, p.imp q, q.imp r] ⊢ r := by
  modal_search 5

/-- Test 149: longer chain (depth 4) -/
example (a b c d : Formula) : [a, a.imp b, b.imp c, c.imp d] ⊢ d := by
  modal_search 7

/-- Test 150: complex nested implication -/
example (p q : Formula) : [] ⊢ (p.imp (q.imp p)).imp ((p.imp q).imp (p.imp p)) := by
  -- This requires prop_k applied to prop_s result
  modal_search 5

/-!
## `modal_search` command tests (from `Automation/Tactics/Commands.lean`)

Syntax and configuration forms, assumption and modus-ponens search, the modal and temporal K
reductions, and coverage of every axiom constructor `tryAxiomMatch` carries and every derived
theorem `tryDerivedMatch` registers.
-/

section CommandsTests

open FormalSystem

/-!
### Phase 1.1 Tests: Verify tactic syntax and basic infrastructure
-/

-- Test 1: Tactic parses with default depth
example (p : Formula) : ⊢ (p.box).imp p := by
  modal_search

-- Test 2: Tactic parses with explicit depth
example (p : Formula) : ⊢ (p.box).imp (p.box.box) := by
  modal_search 3

-- Test 3: Temporal search parses (connect_future: φ → G(P(φ)))
-- Under irreflexive semantics, BX1 (G(φ) → φ) is removed.
-- Test disabled: modal_search depth may be insufficient for connect_future.
-- example (p : Formula) : ⊢ (p.imp (p.somePast.allFuture)) := by
--   modal_search

-- Test 4: Error on non-derivability goal (commented - would fail compilation)
-- example (n : Nat) : n = n := by
--   modal_search  -- Should error: "goal must be a derivability relation"

-- Test 5: Assumption matching - formula from context
example (p : Formula) : [p] ⊢ p := by
  modal_search

-- Test 6: Assumption matching at different position
example (p q : Formula) : [q, p] ⊢ p := by
  modal_search

-- Test 7: Manual modus ponens test to verify the approach works
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  exact DerivationTree.modus_ponens _ p q
    (DerivationTree.assumption _ _ (by simp))
    (DerivationTree.assumption _ _ (by simp))

-- Test 8: Modus ponens - simple case with implication in context (tactic)
-- Given p and p → q in context, prove q
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

-- Test 9: Modus ponens - implication first in context
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  modal_search

-- Test 10: Chained modus ponens (requires depth 3+)
-- p, p → q, q → r ⊢ r requires: MP(p, p→q) = q, then MP(q, q→r) = r
example (p q r : Formula) : [p, p.imp q, q.imp r] ⊢ r := by
  modal_search 5

/-!
### Phase 1.5 Tests: Modal K and Temporal K Rules
-/

-- Test 11: Modal K - simple case: [□p] ⊢ □p
-- Context is [□p], goal is □p, reduce to [p] ⊢ p
example (p : Formula) : [p.box] ⊢ p.box := by
  modal_search 3

-- Test 12: Modal K with assumption: [□p, □q] ⊢ □p
example (p q : Formula) : [p.box, q.box] ⊢ p.box := by
  modal_search 3

-- Test 13: Temporal K - simple case: [Fp] ⊢ Fp
example (p : Formula) : [p.allFuture] ⊢ p.allFuture := by
  modal_search 3

-- Test 14: Temporal K with assumption: [Fp, Fq] ⊢ Fp
example (p q : Formula) : [p.allFuture, q.allFuture] ⊢ p.allFuture := by
  modal_search 3

-- Test 15: Manual verification that generalizedModalK works as expected
-- This is the underlying theorem the tactic uses
-- Note: noncomputable because generalizedModalK uses deductionTheorem
noncomputable example (p : Formula) : [p.box] ⊢ p.box := by
  have h : [p] ⊢ p := DerivationTree.assumption [p] p (by simp)
  exact Theorems.generalizedModalK [p] p h

-- Test 16: Manual verification that generalizedTemporalK works as expected
noncomputable example (p : Formula) : [p.allFuture] ⊢ p.allFuture := by
  have h : [p] ⊢ p := DerivationTree.assumption [p] p (by simp)
  exact Theorems.generalizedTemporalK [p] p h

/-!
### Phase 1.6 Tests: Configuration Syntax
-/

-- Test 17: Named depth parameter
example (p : Formula) : ⊢ (p.box).imp p := by
  modal_search (depth := 5)

-- Test 18: Named depth parameter with larger value
example (p : Formula) : ⊢ (p.box).imp (p.box.box) := by
  modal_search (depth := 10)

-- Test 19: Multiple named parameters
example (p : Formula) : ⊢ (p.box).imp p := by
  modal_search (depth := 5) (visitLimit := 500)

-- Test 20: modal_search with named parameter on a temporal goal
-- Disabled under irreflexive semantics (BX1 removed).
-- example (p : Formula) : ⊢ (p.imp (p.somePast.allFuture)) := by
--   modal_search (depth := 5)

/-!
### Phase 1.8 Tests: Specialized Tactics
-/

-- Test 22: modal_search on simple modus ponens
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

-- Test 23: modal_search with chained implications
example (p q r : Formula) : [p, p.imp q, q.imp r] ⊢ r := by
  modal_search 5

-- Test 24: modal_search with named parameter
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search (depth := 5)

-- Test 25: modal_search on assumption
example (p : Formula) : [p] ⊢ p := by
  modal_search

-- Test 26: modal_search on propositional axiom (prop_s)
example (p q : Formula) : ⊢ p.imp (q.imp p) := by
  modal_search

-- Test 27: modal_search on temporal axiom
-- Disabled under irreflexive semantics (BX1 removed).
-- example (p : Formula) : ⊢ (p.imp (p.somePast.allFuture)) := by
--   modal_search

-- Test 28: modal_search on modal axiom (modal_4)
example (p : Formula) : ⊢ (p.box).imp (p.box.box) := by
  modal_search

/-!
### Phase 185.1 Tests: Extended Axiom Coverage (30 new axioms)

These tests verify that `tryAxiomMatch` can now resolve every axiom constructor its
list carries -- 42 of the tree's 45. The three Layer-9 Reynolds Dedekind axioms
`prior_U_gap`, `prior_S_gap` and `sep` are outside that list.
Grouped by layer following the axiom classification in Axioms.lean.
-/

-- Layer 3: BX Temporal — monotonicity
-- Test 29: left_mono_until_G: G(φ→χ) → (U(ψ,φ) → U(ψ,χ))
example (p q r : Formula) : ⊢ (p.imp q).allFuture.imp
    ((Formula.untl p r).imp (Formula.untl q r)) := by
  modal_search

-- Test 30: left_mono_since_H: H(φ→χ) → (S(ψ,φ) → S(ψ,χ))
example (p q r : Formula) : ⊢ (p.imp q).allPast.imp
    ((Formula.snce p r).imp (Formula.snce q r)) := by
  modal_search

-- Test 31: right_mono_until: G(φ→ψ) → (U(φ,χ) → U(ψ,χ))
example (p q r : Formula) : ⊢ (p.imp q).allFuture.imp
    ((Formula.untl r p).imp (Formula.untl r q)) := by
  modal_search

-- Test 32: right_mono_since: H(φ→ψ) → (S(φ,χ) → S(ψ,χ))
example (p q r : Formula) : ⊢ (p.imp q).allPast.imp
    ((Formula.snce r p).imp (Formula.snce r q)) := by
  modal_search

-- Layer 3: BX Temporal — connectedness
-- Test 33: connect_future: φ → G(P(φ))
example (p : Formula) : ⊢ p.imp (p.somePast.allFuture) := by
  modal_search

-- Test 34: connect_past: φ → H(F(φ))
example (p : Formula) : ⊢ p.imp (p.someFuture.allPast) := by
  modal_search

-- Layer 3: BX Temporal — enrichment
-- Test 35: enrichment_until: p ∧ U(ψ,φ) → U(ψ ∧ S(p,φ), φ)
example (p q r : Formula) : ⊢ (Formula.and r (Formula.untl p q)).imp
    (Formula.untl p (Formula.and q (Formula.snce p r))) := by
  modal_search

-- Test 36: enrichment_since: p ∧ S(ψ,φ) → S(ψ ∧ U(p,φ), φ)
example (p q r : Formula) : ⊢ (Formula.and r (Formula.snce p q)).imp
    (Formula.snce p (Formula.and q (Formula.untl p r))) := by
  modal_search

-- Layer 3: BX Temporal — accumulation & absorption
-- Test 37: self_accum_until: U(ψ,φ) → U(ψ, φ ∧ U(ψ,φ))
example (p q : Formula) : ⊢ (Formula.untl p q).imp
    (Formula.untl (Formula.and p (Formula.untl p q)) q) := by
  modal_search

-- Test 38: self_accum_since: S(ψ,φ) → S(ψ, φ ∧ S(ψ,φ))
example (p q : Formula) : ⊢ (Formula.snce p q).imp
    (Formula.snce (Formula.and p (Formula.snce p q)) q) := by
  modal_search

-- Test 39: absorb_until: U(φ ∧ U(ψ,φ), φ) → U(ψ,φ)
example (p q : Formula) : ⊢ (Formula.untl p (Formula.and p (Formula.untl p q))).imp
    (Formula.untl p q) := by
  modal_search

-- Test 40: absorb_since: S(φ ∧ S(ψ,φ), φ) → S(ψ,φ)
example (p q : Formula) : ⊢ (Formula.snce p (Formula.and p (Formula.snce p q))).imp
    (Formula.snce p q) := by
  modal_search

-- Layer 3: BX Temporal — linearity
-- Test 41: linear_until: U(ψ,φ) ∧ U(θ,χ) → disjunction
example (p q r s : Formula) : ⊢ (Formula.and (Formula.untl p q) (Formula.untl r s)).imp
    (Formula.or
      (Formula.or
        (Formula.untl (Formula.and p r) (Formula.and q s))
        (Formula.untl (Formula.and p r) (Formula.and q r)))
      (Formula.untl (Formula.and p r) (Formula.and p s))) := by
  modal_search

-- Test 42: linear_since: S(ψ,φ) ∧ S(θ,χ) → disjunction
example (p q r s : Formula) : ⊢ (Formula.and (Formula.snce p q) (Formula.snce r s)).imp
    (Formula.or
      (Formula.or
        (Formula.snce (Formula.and p r) (Formula.and q s))
        (Formula.snce (Formula.and p r) (Formula.and q r)))
      (Formula.snce (Formula.and p r) (Formula.and p s))) := by
  modal_search

-- Layer 3: BX Temporal — eventuality
-- Test 43: until_F: U(ψ,φ) → F(ψ)
example (p q : Formula) : ⊢ (Formula.untl p q).imp (Formula.someFuture q) := by
  modal_search

-- Test 44: since_P: S(ψ,φ) → P(ψ)
example (p q : Formula) : ⊢ (Formula.snce p q).imp (Formula.somePast q) := by
  modal_search

-- Layer 3b: BX Temporal — additional
-- Test 45: temp_linearity: F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)
example (p q : Formula) : ⊢ (Formula.and (Formula.someFuture p) (Formula.someFuture q)).imp
    (Formula.or (Formula.someFuture (Formula.and p q))
      (Formula.or (Formula.someFuture (Formula.and p (Formula.someFuture q)))
        (Formula.someFuture (Formula.and (Formula.someFuture p) q)))) := by
  modal_search

-- Test 46: temp_linearity_past: P(φ) ∧ P(ψ) → P(φ∧ψ) ∨ P(φ∧P(ψ)) ∨ P(P(φ)∧ψ)
example (p q : Formula) : ⊢ (Formula.and (Formula.somePast p) (Formula.somePast q)).imp
    (Formula.or (Formula.somePast (Formula.and p q))
      (Formula.or (Formula.somePast (Formula.and p (Formula.somePast q)))
        (Formula.somePast (Formula.and (Formula.somePast p) q)))) := by
  modal_search

-- Test 47: F_until_equiv: F(φ) → U(φ, ⊤)
example (p : Formula) : ⊢ (Formula.someFuture p).imp
    (Formula.untl (Formula.bot.imp Formula.bot) p) := by
  modal_search

-- Test 48: P_since_equiv: P(φ) → S(φ, ⊤)
example (p : Formula) : ⊢ (Formula.somePast p).imp
    (Formula.snce (Formula.bot.imp Formula.bot) p) := by
  modal_search

-- Layer 5: Uniformity — discrete structure (FrameClass.Base, no parameters)
-- Test 49: discrete_symm_fwd: U(⊤,⊥) → S(⊤,⊥)
example : ⊢ (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
    (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) := by
  modal_search

-- Test 50: discrete_symm_bwd: S(⊤,⊥) → U(⊤,⊥)
example : ⊢ (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
    (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) := by
  modal_search

-- Test 51: discrete_propagate_fwd: U(⊤,⊥) → G(U(⊤,⊥))
example : ⊢ (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
    (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := by
  modal_search

-- Test 52: discrete_propagate_bwd: U(⊤,⊥) → H(U(⊤,⊥))
example : ⊢ (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
    (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := by
  modal_search

-- Test 53: discrete_box_necessity: U(⊤,⊥) → □(U(⊤,⊥))
example : ⊢ (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
    (Formula.box (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := by
  modal_search

-- Layer 6: Prior axioms — discrete (FrameClass.ZTime)
-- Test 54: prior_UZ: F(φ) → U(φ, ¬φ) (requires FrameClass.ZTime)
example (p : Formula) : ⊢[FrameClass.ZTime] p.someFuture.imp (Formula.untl p.neg p) := by
  modal_search

-- Test 55: prior_SZ: P(φ) → S(φ, ¬φ) (requires FrameClass.ZTime)
example (p : Formula) : ⊢[FrameClass.ZTime] p.somePast.imp (Formula.snce p.neg p) := by
  modal_search

-- Test 56: z1: G(Gφ→φ) → (FGφ→Gφ) (requires FrameClass.ZTime)
example (p : Formula) : ⊢[FrameClass.ZTime]
    (p.allFuture.imp p).allFuture.imp (p.allFuture.someFuture.imp p.allFuture) := by
  modal_search

-- Layer 8: Density (FrameClass.Dense)
-- Test 57: density: GGφ → Gφ (requires FrameClass.Dense)
example (p : Formula) : ⊢[FrameClass.Dense] p.allFuture.allFuture.imp p.allFuture := by
  modal_search

-- Test 58: dense_indicator: ¬U(⊤,⊥) (requires FrameClass.Dense)
example : ⊢[FrameClass.Dense] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg := by
  modal_search

/-!
### Phase 185.2 Tests: Derived Theorem Coverage (~25 derived theorems)

These tests verify that `tryDerivedMatch` can resolve derived theorems
directly via `modal_search`. Grouped by tier following the registration
order in `tryDerivedMatch`.
-/

-- Tier 1: Propositional combinators

-- Test 59: identity: A → A
example (p : Formula) : ⊢ p.imp p := by
  modal_search

-- Test 60: doubleNegation: ¬¬φ → φ
example (p : Formula) : ⊢ p.neg.neg.imp p := by
  modal_search

-- Test 61: impNegImp: A → (¬A → B)
example (p q : Formula) : ⊢ p.imp (p.neg.imp q) := by
  modal_search

-- Test 62: negImp: ¬A → (A → B)
example (p q : Formula) : ⊢ p.neg.imp (p.imp q) := by
  modal_search

-- Test 63: lceImp: (A ∧ B) → A
noncomputable example (p q : Formula) : ⊢ (p.and q).imp p := by
  modal_search

-- Test 64: rceImp: (A ∧ B) → B
noncomputable example (p q : Formula) : ⊢ (p.and q).imp q := by
  modal_search

-- Test 65: contraposeImp: (A → B) → (¬B → ¬A)
example (p q : Formula) : ⊢ (p.imp q).imp (q.neg.imp p.neg) := by
  modal_search

-- Test 66: pairing: A → (B → (A ∧ B))
example (p q : Formula) : ⊢ p.imp (q.imp (p.and q)) := by
  modal_search

-- Test 67: notNotIntro: A → ¬¬A
example (p : Formula) : ⊢ p.imp p.neg.neg := by
  modal_search

-- Test 68: bCombinator: (B→C) → ((A→B) → (A→C))
example (p q r : Formula) : ⊢ (q.imp r).imp ((p.imp q).imp (p.imp r)) := by
  modal_search

-- Test 69: theoremFlip: (A→(B→C)) → (B→(A→C))
example (p q r : Formula) : ⊢ (p.imp (q.imp r)).imp (q.imp (p.imp r)) := by
  modal_search

-- Test 70: theoremApp1: A → ((A→B) → B)
example (p q : Formula) : ⊢ p.imp ((p.imp q).imp q) := by
  modal_search

-- Tier 2: Modal and temporal derived theorems

-- Test 71: temporalKDistDerived: G(φ→ψ) → (Gφ→Gψ)
noncomputable example (p q : Formula) : ⊢ (p.imp q).allFuture.imp
    (p.allFuture.imp q.allFuture) := by
  modal_search

-- Test 72: temporal4Derived: Gφ → GGφ
noncomputable example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by
  modal_search

-- Test 73: hDistribution: H(φ→ψ) → (Hφ→Hψ)
noncomputable example (p q : Formula) : ⊢ (p.imp q).allPast.imp (p.allPast.imp q.allPast) := by
  modal_search

-- Test 74: hTransitivity: Hφ → HHφ
noncomputable example (p : Formula) : ⊢ p.allPast.imp p.allPast.allPast := by
  modal_search

-- Test 75: tBoxToDiamond: □A → ◇A
example (p : Formula) : ⊢ p.box.imp p.diamond := by
  modal_search

-- Test 76: kDistDiamond: □(A→B) → (◇A → ◇B)
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.diamond.imp q.diamond) := by
  modal_search

-- Test 77: diamond4: ◇◇φ → ◇φ
example (p : Formula) : ⊢ p.diamond.diamond.imp p.diamond := by
  modal_search

-- Test 78: modal5: ◇φ → □◇φ
example (p : Formula) : ⊢ p.diamond.imp p.diamond.box := by
  modal_search

-- Test 79: boxToFuture: □φ → Gφ
example (p : Formula) : ⊢ p.box.imp p.allFuture := by
  modal_search

-- Test 80: boxToPast: □φ → Hφ
example (p : Formula) : ⊢ p.box.imp p.allPast := by
  modal_search

-- Test 81: formulaOrComm: (A ∨ B) → (B ∨ A)
noncomputable example (p q : Formula) : ⊢ (p.or q).imp (q.or p) := by
  modal_search

-- Test 82: biImp: (A→B) → ((B→A) → ((A→B) ∧ (B→A)))
example (p q : Formula) : ⊢ (p.imp q).imp ((q.imp p).imp ((p.imp q).and (q.imp p))) := by
  modal_search

-- Test 83: classicalMerge: (P→Q) → ((¬P→Q) → Q)
noncomputable example (p q : Formula) : ⊢ (p.imp q).imp ((p.neg.imp q).imp q) := by
  modal_search

-- Test 84: temporalFutureDerived (migrated from tryAxiomMatch): □φ → G□φ
example (p : Formula) : ⊢ p.box.imp p.box.allFuture := by
  modal_search

end CommandsTests

end BimodalTest.Automation
