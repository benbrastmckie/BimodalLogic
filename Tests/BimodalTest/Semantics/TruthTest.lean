/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TaskFrame

/-!
# Truth Evaluation Tests

Tests for truth evaluation in task models.

## Temporal Type Note

After the temporal generalization, TaskFrame and WorldHistory now take a
type parameter `T` with `LinearOrderedAddCommGroup` constraint. Tests use
explicit `Int` annotations.
-/

namespace BimodalTest.Semantics

open FormalSystem.Syntax
open FormalSystem.Semantics

-- Helper: use trivial frame for testing (with explicit Int time)
def testFrame : TaskFrame Int := TaskFrame.trivialFrame

-- Helper: simple model where "p" is true, "q" is false
def testModel : TaskModel testFrame where
  valuation := fun _ p => p.base = "p"

-- Helper: trivial world history (universal domain)
def testHistory : WorldHistory testFrame := WorldHistory.trivial

-- Test: Bot is false (using trivial history's domain proof)
example : ¬(TruthAt testModel testHistory (0 : Int) Formula.bot) := by
  exact Truth.bot_false

-- Test: Atom truth depends on valuation (p is true)
example : (TruthAt testModel testHistory (0 : Int) (Formula.atomS "p")) := by
  simp [TruthAt, testModel, testHistory, WorldHistory.trivial, Formula.atomS, Atom.mkBase]

-- Test: Atom truth depends on valuation (q is false)
example : ¬(TruthAt testModel testHistory (0 : Int) (Formula.atomS "q")) := by
  simp [TruthAt, testModel, testHistory, WorldHistory.trivial, Formula.atomS, Atom.mkBase]

-- Test: Implication basic behavior
-- p → p is true
example : (TruthAt testModel testHistory (0 : Int)
    ((Formula.atomS "p").imp (Formula.atomS "p"))) := by
  intro h
  exact h

-- Test: Truth of negation (¬⊥ = ⊤)
example : (TruthAt testModel testHistory (0 : Int) Formula.bot.neg) := by
  unfold Formula.neg TruthAt
  intro h
  exact h

/-! ## Polymorphism Tests -/

-- Test: TruthAt works with explicit Int type
theorem truth_at_int_example :
    TruthAt testModel testHistory (0 : Int) (Formula.atomS "p") := by
  simp [TruthAt, testModel, testHistory, WorldHistory.trivial, Formula.atomS, Atom.mkBase]

end BimodalTest.Semantics
