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
def testFrame : TaskFrame Int := TaskFrame.trivial_frame

-- Helper: simple model where "p" is true, "q" is false
def testModel : TaskModel testFrame where
  valuation := fun _ p => p.base = "p"

-- Helper: trivial world history (universal domain)
def testHistory : WorldHistory testFrame := WorldHistory.trivial

-- Test: Bot is false (using trivial history's domain proof)
example : ¬(truth_at testModel Set.univ testHistory (0 : Int) Formula.bot) := by
  exact Truth.bot_false Set.univ

-- Test: Atom truth depends on valuation (p is true)
example : (truth_at testModel Set.univ testHistory (0 : Int) (Formula.atom_s "p")) := by
  simp [truth_at, testModel, testHistory, WorldHistory.trivial, Formula.atom_s, Atom.mk_base]

-- Test: Atom truth depends on valuation (q is false)
example : ¬(truth_at testModel Set.univ testHistory (0 : Int) (Formula.atom_s "q")) := by
  simp [truth_at, testModel, testHistory, WorldHistory.trivial, Formula.atom_s, Atom.mk_base]

-- Test: Implication basic behavior
-- p → p is true
example : (truth_at testModel Set.univ testHistory (0 : Int) ((Formula.atom_s "p").imp (Formula.atom_s "p"))) := by
  intro h
  exact h

-- Test: Truth of negation (¬⊥ = ⊤)
example : (truth_at testModel Set.univ testHistory (0 : Int) Formula.bot.neg) := by
  unfold Formula.neg truth_at
  intro h
  exact h

/-! ## Polymorphism Tests -/

-- Test: truth_at works with explicit Int type
theorem truth_at_int_example :
    truth_at testModel Set.univ testHistory (0 : Int) (Formula.atom_s "p") := by
  simp [truth_at, testModel, testHistory, WorldHistory.trivial, Formula.atom_s, Atom.mk_base]

end BimodalTest.Semantics
