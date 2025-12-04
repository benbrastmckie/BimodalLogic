import Mathlib.Algebra.Order.Group.Int
import Logos.Semantics.Truth
import Logos.Semantics.TaskFrame

/-!
# Truth Evaluation Tests

Tests for truth evaluation in task models.

## Temporal Type Note

After the temporal generalization, TaskFrame and WorldHistory now take a
type parameter `T` with `LinearOrderedAddCommGroup` constraint. Tests use
explicit `Int` annotations.
-/

namespace LogosTest.Semantics

open Logos.Syntax
open Logos.Semantics

-- Helper: use trivial frame for testing (with explicit Int time)
def testFrame : TaskFrame Int := TaskFrame.trivialFrame

-- Helper: simple model where "p" is true, "q" is false
def testModel : TaskModel testFrame where
  valuation := fun _ p => p = "p"

-- Helper: trivial world history (universal domain)
def testHistory : WorldHistory testFrame := WorldHistory.trivial

-- Test: Bot is false (using trivial history's domain proof)
example : ¬(truth_at testModel testHistory (0 : Int) trivial Formula.bot) := by
  exact Truth.bot_false

-- Test: Atom truth depends on valuation (p is true)
example : (truth_at testModel testHistory (0 : Int) trivial (Formula.atom "p")) := by
  unfold truth_at testModel testHistory WorldHistory.trivial
  simp

-- Test: Atom truth depends on valuation (q is false)
example : ¬(truth_at testModel testHistory (0 : Int) trivial (Formula.atom "q")) := by
  unfold truth_at testModel testHistory WorldHistory.trivial
  simp

-- Test: Implication basic behavior
-- p → p is true
example : (truth_at testModel testHistory (0 : Int) trivial ((Formula.atom "p").imp (Formula.atom "p"))) := by
  intro h
  exact h

-- Test: Truth of negation (¬⊥ = ⊤)
example : (truth_at testModel testHistory (0 : Int) trivial Formula.bot.neg) := by
  unfold Formula.neg truth_at
  intro h
  exact h

/-! ## Polymorphism Tests -/

-- Test: truth_at works with explicit Int type
theorem truth_at_int_example :
    truth_at testModel testHistory (0 : Int) trivial (Formula.atom "p") := by
  unfold truth_at testModel testHistory WorldHistory.trivial
  simp

end LogosTest.Semantics
