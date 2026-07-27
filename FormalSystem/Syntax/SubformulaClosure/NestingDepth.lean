/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.SubformulaClosure.Closure

/-!
# F/P-Nesting Depth Computation and Maximum Depth Within Closure Sets

F/P-nesting depth, max nesting depth in closure, and F/P inner formula extraction.
-/

namespace FormalSystem.Syntax

open FormalSystem.Syntax.Formula

/-!
## F-Nesting Depth

The F-nesting depth counts how many F (some_future) operators wrap a formula.
This is the key measure for proving that iter_F eventually leaves closureWithNeg.
-/

/--
Count the F-nesting depth at the outermost level of a formula.

`f_nesting_depth (F(F(F(phi)))) = 3`
`f_nesting_depth (phi) = 0` when phi is not an F-formula

Note: This counts the outermost consecutive F-operators only.
F(phi.and F(psi)) has f_nesting_depth 1, not 2.

The F operator is `some_future φ = φ.neg.all_future.neg`
  = `(φ.imp bot).all_future.imp bot`
  = `Formula.imp (Formula.all_future (Formula.imp φ Formula.bot)) Formula.bot`
-/
def fNestingDepth : Formula → Nat
  | .untl inner (.imp .bot .bot) => 1 + fNestingDepth inner
  | _ => 0

/-- f_nesting_depth is always non-negative (trivially true for Nat). -/
theorem f_nesting_depth_nonneg (phi : Formula) : fNestingDepth phi ≥ 0 := Nat.zero_le _

/-- The some_future (F) operator unfolds to untl. -/
theorem some_future_unfold (psi : Formula) :
    Formula.someFuture psi = Formula.untl psi Formula.top := by
  rfl

/-- F-nesting depth of F(psi) is 1 + depth of psi. -/
theorem f_nesting_depth_some_future (psi : Formula) :
    fNestingDepth (Formula.someFuture psi) = 1 + fNestingDepth psi := by
  simp only [Formula.someFuture, Formula.top, fNestingDepth]

/-- Atoms have F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_atom (a : FormalSystem.Syntax.Atom) : fNestingDepth (.atom a) = 0 := rfl

/-- Bot has F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_bot : fNestingDepth .bot = 0 := rfl

/-- Box formulas have F-nesting depth 0 (F is not Box). -/
@[simp]
theorem f_nesting_depth_box (psi : Formula) : fNestingDepth (.box psi) = 0 := rfl

/-- all_past formulas have F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_all_past (psi : Formula) : fNestingDepth (Formula.allPast psi) = 0 := by
  simp only [Formula.allPast, Formula.somePast, Formula.neg, Formula.top, fNestingDepth]

/-- all_future formulas have F-nesting depth 0 (F = neg ∘ all_future ∘ neg, not raw all_future). -/
@[simp]
theorem f_nesting_depth_all_future (psi : Formula) :
    fNestingDepth (Formula.allFuture psi) = 0 := by
  simp only [Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top, fNestingDepth]

/-!
## Maximum F-Depth in Closure

The maximum F-nesting depth over all formulas in closureWithNeg(phi).
This provides the bound for when iter_F leaves the closure.
-/

/--
Maximum F-nesting depth of any formula in closureWithNeg(phi).

Since closureWithNeg is a Finset, this is well-defined via Finset.sup.
We use Nat.zero as the default for empty sets (though closureWithNeg is never empty).
-/
def maxFDepthInClosure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup fNestingDepth

/--
Every element of closureWithNeg has F-depth at most max_F_depth_in_closure.
-/
theorem f_depth_le_max {phi psi : Formula} (h : psi ∈ closureWithNeg phi) :
    fNestingDepth psi ≤ maxFDepthInClosure phi := by
  exact Finset.le_sup h

/-!
## P-Nesting Depth

The P-nesting depth counts how many P (some_past) operators wrap a formula.
This is the key measure for proving that iter_P eventually leaves closureWithNeg.
Symmetric to F-nesting depth.
-/

/--
Count the P-nesting depth at the outermost level of a formula.

`p_nesting_depth (P(P(P(phi)))) = 3`
`p_nesting_depth (phi) = 0` when phi is not a P-formula

Note: This counts the outermost consecutive P-operators only.
P(phi.and P(psi)) has p_nesting_depth 1, not 2.

The P operator is `some_past φ = φ.neg.all_past.neg`
  = `(φ.imp bot).all_past.imp bot`
  = `Formula.imp (Formula.all_past (Formula.imp φ Formula.bot)) Formula.bot`
-/
def pNestingDepth : Formula → Nat
  | .snce inner (.imp .bot .bot) => 1 + pNestingDepth inner
  | _ => 0

/-- p_nesting_depth is always non-negative (trivially true for Nat). -/
theorem p_nesting_depth_nonneg (phi : Formula) : pNestingDepth phi ≥ 0 := Nat.zero_le _

/-- The some_past (P) operator unfolds to snce. -/
theorem some_past_unfold (psi : Formula) :
    Formula.somePast psi = Formula.snce psi Formula.top := by
  rfl

/-- P-nesting depth of P(psi) is 1 + depth of psi. -/
theorem p_nesting_depth_some_past (psi : Formula) :
    pNestingDepth (Formula.somePast psi) = 1 + pNestingDepth psi := by
  simp only [Formula.somePast, Formula.top, pNestingDepth]

/-- Atoms have P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_atom (a : FormalSystem.Syntax.Atom) : pNestingDepth (.atom a) = 0 := rfl

/-- Bot has P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_bot : pNestingDepth .bot = 0 := rfl

/-- Box formulas have P-nesting depth 0 (P is not Box). -/
@[simp]
theorem p_nesting_depth_box (psi : Formula) : pNestingDepth (.box psi) = 0 := rfl

/-- all_future formulas have P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_all_future (psi : Formula) :
    pNestingDepth (Formula.allFuture psi) = 0 := by
  simp only [Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top, pNestingDepth]

/-- all_past formulas have P-nesting depth 0 (P = neg ∘ all_past ∘ neg, not raw all_past). -/
@[simp]
theorem p_nesting_depth_all_past (psi : Formula) : pNestingDepth (Formula.allPast psi) = 0 := by
  simp only [Formula.allPast, Formula.somePast, Formula.neg, Formula.top, pNestingDepth]

/-!
## Maximum P-Depth in Closure

The maximum P-nesting depth over all formulas in closureWithNeg(phi).
This provides the bound for when iter_P leaves the closure.
-/

/--
Maximum P-nesting depth of any formula in closureWithNeg(phi).

Since closureWithNeg is a Finset, this is well-defined via Finset.sup.
We use Nat.zero as the default for empty sets (though closureWithNeg is never empty).
-/
def maxPDepthInClosure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup pNestingDepth

/--
Every element of closureWithNeg has P-depth at most max_P_depth_in_closure.
-/
theorem p_depth_le_max {phi psi : Formula} (h : psi ∈ closureWithNeg phi) :
    pNestingDepth psi ≤ maxPDepthInClosure phi := by
  exact Finset.le_sup h

/-!
## F/P Inner Formula Extraction

Extract the inner formula from F(chi) or P(chi) patterns.
These are used to construct the deferral closure.
-/

/--
Extract the inner formula chi from F(chi) = some_future chi.

F(chi) = chi.neg.all_future.neg
       = (chi.imp bot).all_future.imp bot
       = Formula.imp (Formula.all_future (Formula.imp chi Formula.bot)) Formula.bot
-/
def extractFutureInner : Formula → Option Formula
  | .untl inner (.imp .bot .bot) => some inner
  | _ => none

/--
Extract the inner formula chi from P(chi) = some_past chi.

P(chi) = Formula.snce chi Formula.top = Formula.snce chi (Formula.bot.imp Formula.bot)
-/
def extractPastInner : Formula → Option Formula
  | .snce inner (.imp .bot .bot) => some inner
  | _ => none

/-- extractFutureInner correctly extracts from some_future. -/
theorem extractFutureInner_some_future (chi : Formula) :
    extractFutureInner (Formula.someFuture chi) = some chi := by
  simp only [Formula.someFuture, Formula.top, extractFutureInner]

/-- extractPastInner correctly extracts from some_past. -/
theorem extractPastInner_some_past (chi : Formula) :
    extractPastInner (Formula.somePast chi) = some chi := by
  simp only [Formula.somePast, Formula.top, extractPastInner]

/-- Check if a formula is an F-formula (some_future pattern). -/
def IsFutureFormula (f : Formula) : Prop := (extractFutureInner f).isSome = true

/-- IsFutureFormula is decidable. -/
instance : DecidablePred IsFutureFormula :=
  fun f => decidable_of_iff ((extractFutureInner f).isSome = true)
    (by simp only [IsFutureFormula])

/-- Check if a formula is a P-formula (some_past pattern). -/
def IsPastFormula (f : Formula) : Prop := (extractPastInner f).isSome = true

/-- IsPastFormula is decidable. -/
instance : DecidablePred IsPastFormula :=
  fun f => decidable_of_iff ((extractPastInner f).isSome = true)
    (by simp only [IsPastFormula])


end FormalSystem.Syntax
