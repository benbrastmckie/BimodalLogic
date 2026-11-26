/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve, Benjamin Brast-McKie
-/

import FormalSystem.Automation.ProofMode

/-! # One-step temporal rules and integer-time frame guards -/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeTemporalZTimeTest

variable {fc : FrameClass} (Γ : Context) (A B C : Formula)

-- Fold is Base-valid; forward unfolding retains the explicit integer-time gate and both joins.
example (g e : Formula) (hZ : FrameClass.ZTime ≤ fc) :
    [Formula.untl g e] ⊢[fc] Formula.untl g e := by
  lstart h
  luntil expand h as hEvent hContinue
  · luntil contract; lleft; lexact hEvent
  · luntil contract; lright; lexact hContinue

-- A false gate rejects atomically; a supplied fact remains usable after refusal.
example (provider : Γ ⊢[FrameClass.Dense] A.allFuture) :
    Γ ⊢[FrameClass.Dense] A.allFuture := by
  fail_if_success linduction future
  lexact provider

-- Invariance reuses the exact local frame certificate.
example (hZ : FrameClass.ZTime ≤ fc) :
    [A, A.imp A.next, (A.imp A.next).allFuture] ⊢[fc] A.allFuture := by
  lstart hInit hNow hFuture
  linvariant future
  · lexact hInit
  · lexact hNow
  · lexact hFuture

-- Integer-time expansion refuses a dense frame.
example : [Formula.untl A B] ⊢[FrameClass.Dense] Formula.untl A B := by
  lstart h
  fail_if_success luntil expand h as he hc
  lexact h

-- Use a local integer-time certificate and retain a strict H guarantee at the previous point.
example (hZ : FrameClass.ZTime ≤ fc) : [A.allPast] ⊢[fc] A.allPast.prev := by
  lstart hA
  lstep past using [] keeping [hA] as hA
  lexact hA

example : [(A.allFuture.imp A).allFuture, A.allFuture.someFuture] ⊢[FrameClass.ZTime]
    A.allFuture := by
  lstart hStep hBase
  linduction future
  · lexact hStep
  · lexact hBase

/-- error: integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense -/
#guard_msgs in
example : [Formula.untl A B] ⊢[FrameClass.Dense] Formula.untl A B := by
  lstart h
  luntil expand h as he hc

-- The gate's sibling guard: an integer-time rule invoked where the goal's frame class is still a
-- metavariable is refused before the gate parameter is ever created. The frame component of the
-- pair is deliberately left open -- assigning it is what would determine the frame class and
-- silence the guard -- so its own unsolved-goals report is pinned alongside.
/--
error: the frame class of the goal is undetermined
---
error: unsolved goals
case frame
fc : FrameClass
Γ : Context
A B C : Formula
⊢ FrameClass
-/
#guard_msgs in
example : (f : FrameClass) ×
    ([Formula.untl Formula.bot Formula.bot] ⊢[f] Formula.untl Formula.bot Formula.bot) := by
  refine ⟨?frame, ?proof⟩
  case proof =>
    lstart h
    luntil expand h as he hc

end BimodalTest.Automation.ProofModeTemporalZTimeTest
