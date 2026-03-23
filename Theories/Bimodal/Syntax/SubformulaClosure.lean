import Bimodal.Syntax.Formula
import Bimodal.Syntax.Subformulas
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.List.Basic

/-!
# Subformula Closure for Multi-Family BFMCS Construction

This module provides the subformula closure infrastructure needed for the
multi-family BFMCS construction that eliminates the modal_backward sorry.

## Overview

The key insight is that for completeness, we only need to saturate Diamond
formulas that are subformulas of the target formula. This finite bound
enables termination of the iterative saturation process.

## Main Definitions

- `subformulaClosure`: Subformula closure as a Finset (delegates to existing)
- `closureWithNeg`: Closure extended with negations of all members
- `diamondSubformulas`: Filter for Diamond formulas in closure
- `isDiamondFormula`: Predicate for Diamond form (neg (Box (neg _)))
- `extractDiamondInner`: Extract inner formula from Diamond

## Main Results

- `diamondSubformulas_subset`: Diamond subformulas are in closure
- `diamond_in_diamondSubformulas`: If a Diamond formula is in closure, it's in diamondSubformulas

## Design Notes

This module bridges the existing `Bimodal.Syntax.Subformulas` (List-based)
with the specific needs of the multi-family BFMCS construction.

## References

- Research report: specs/827_complete_multi_family_bmcs_construction/reports/research-002.md
- Implementation plan: specs/827_complete_multi_family_bmcs_construction/plans/implementation-002.md
-/

namespace Bimodal.Syntax

open Bimodal.Syntax.Formula

/-!
## Subformula Closure as Finset

Convert the List-based subformulas to a Finset for finite set operations.
-/

/--
Subformula closure of a formula as a Finset.

This converts the List-based `Formula.subformulas` to a Finset,
enabling finite set operations and cardinality reasoning.
-/
def subformulaClosure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

/--
The formula itself is in its subformula closure.
-/
theorem self_mem_subformulaClosure (phi : Formula) : phi ∈ subformulaClosure phi := by
  unfold subformulaClosure
  simp only [List.mem_toFinset]
  exact Formula.self_mem_subformulas phi

/--
Membership in subformula closure is decidable.
-/
instance (phi : Formula) : DecidablePred (· ∈ subformulaClosure phi) :=
  fun psi => Finset.decidableMem psi (subformulaClosure phi)

/--
Size of the subformula closure (useful for termination measures).
-/
def subformulaClosureCard (phi : Formula) : Nat := (subformulaClosure phi).card

/-!
## Closure with Negations

For negation completeness in MCS, we extend closure with negations.
-/

/--
Closure extended with negations of all members.

For each formula psi in the subformula closure, we include both psi
and its negation. This ensures closure-restricted MCS can have
negation completeness.
-/
def closureWithNeg (phi : Formula) : Finset Formula :=
  (subformulaClosure phi) ∪ (subformulaClosure phi).image Formula.neg

/--
Subformula closure is a subset of closureWithNeg.
-/
theorem subformulaClosure_subset_closureWithNeg (phi : Formula) :
    subformulaClosure phi ⊆ closureWithNeg phi := by
  intro psi h
  unfold closureWithNeg
  exact Finset.mem_union_left _ h

/--
Negation of a closure member is in closureWithNeg.
-/
theorem neg_mem_closureWithNeg (phi psi : Formula) (h : psi ∈ subformulaClosure phi) :
    psi.neg ∈ closureWithNeg phi := by
  unfold closureWithNeg
  apply Finset.mem_union_right
  exact Finset.mem_image_of_mem Formula.neg h

/--
The formula itself is in closureWithNeg.
-/
theorem self_mem_closureWithNeg (phi : Formula) : phi ∈ closureWithNeg phi :=
  subformulaClosure_subset_closureWithNeg phi (self_mem_subformulaClosure phi)

/--
The negation of the formula is in closureWithNeg.
-/
theorem neg_self_mem_closureWithNeg (phi : Formula) : phi.neg ∈ closureWithNeg phi :=
  neg_mem_closureWithNeg phi phi (self_mem_subformulaClosure phi)

/--
Membership in closureWithNeg is decidable.
-/
instance (phi : Formula) : DecidablePred (· ∈ closureWithNeg phi) :=
  fun psi => Finset.decidableMem psi (closureWithNeg phi)

/--
Size of the closure with negations (useful for termination measures).
-/
def closureWithNegCard (phi : Formula) : Nat := (closureWithNeg phi).card

/-!
## Diamond Formula Detection

A Diamond formula has the form: neg (Box (neg psi)) = (neg psi).box.neg
In our syntax: psi.neg.box.neg = (psi.imp bot).box.imp bot
                                = ((psi.imp bot).box).imp bot
-/

/--
Check if a formula is of the form Diamond psi (= neg (Box (neg psi))).

Diamond psi = psi.diamond = psi.neg.box.neg
            = (psi.imp bot).box.imp bot
            = Formula.imp (Formula.box (Formula.imp psi Formula.bot)) Formula.bot

Returns the inner formula psi if it matches, or none otherwise.
-/
def extractDiamondInner : Formula → Option Formula
  | .imp (.box (.imp inner .bot)) .bot => some inner
  | _ => none

/--
Predicate (Prop) for Diamond formulas. Used in Finset.filter.
-/
def IsDiamondFormula (psi : Formula) : Prop :=
  (extractDiamondInner psi).isSome = true

/--
IsDiamondFormula is decidable.
-/
instance : DecidablePred IsDiamondFormula :=
  fun psi => decidable_of_iff ((extractDiamondInner psi).isSome = true)
    (by simp only [IsDiamondFormula])

/--
Boolean version: check if formula is Diamond.
-/
def isDiamondFormulaBool (psi : Formula) : Bool :=
  (extractDiamondInner psi).isSome

/--
The Diamond constructor matches the extract function.
-/
theorem extractDiamondInner_diamond (psi : Formula) :
    extractDiamondInner psi.diamond = some psi := by
  simp only [Formula.diamond, Formula.neg, extractDiamondInner]

/--
If extract succeeds, the formula is a Diamond formula.
-/
theorem isDiamondFormula_of_extract {psi inner : Formula}
    (h : extractDiamondInner psi = some inner) : IsDiamondFormula psi := by
  simp only [IsDiamondFormula, h, Option.isSome_some]

/--
A Diamond formula satisfies IsDiamondFormula.
-/
theorem diamond_isDiamondFormula (psi : Formula) : IsDiamondFormula psi.diamond := by
  simp only [IsDiamondFormula, extractDiamondInner_diamond, Option.isSome_some]

/--
Diamond formula unfolds correctly.
-/
theorem diamond_unfold (psi : Formula) :
    psi.diamond = Formula.imp (Formula.box (Formula.imp psi Formula.bot)) Formula.bot := by
  simp only [Formula.diamond, Formula.neg]

/-!
## Diamond Subformulas

Filter the closure for Diamond formulas that need witnesses in saturation.
-/

/--
Filter subformula closure for Diamond formulas.

These are the formulas that need witnesses during BFMCS saturation.
Since the closure is finite, this set is also finite, enabling
termination of the saturation process.
-/
def diamondSubformulas (phi : Formula) : Finset Formula :=
  (subformulaClosure phi).filter IsDiamondFormula

/--
Diamond subformulas are a subset of the subformula closure.
-/
theorem diamondSubformulas_subset (phi : Formula) :
    diamondSubformulas phi ⊆ subformulaClosure phi := by
  intro psi h
  unfold diamondSubformulas at h
  exact Finset.mem_of_mem_filter psi h

/--
If a Diamond formula is in the subformula closure, it's in diamondSubformulas.
-/
theorem diamond_in_diamondSubformulas (phi psi : Formula)
    (h_sub : psi.diamond ∈ subformulaClosure phi) :
    psi.diamond ∈ diamondSubformulas phi := by
  unfold diamondSubformulas
  apply Finset.mem_filter.mpr
  constructor
  · exact h_sub
  · exact diamond_isDiamondFormula psi

/--
Any element in diamondSubformulas is a Diamond formula.
-/
theorem mem_diamondSubformulas_isDiamond {phi psi : Formula}
    (h : psi ∈ diamondSubformulas phi) : IsDiamondFormula psi := by
  unfold diamondSubformulas at h
  exact (Finset.mem_filter.mp h).2

/--
Count of Diamond formulas in closure (bounds saturation iterations).
-/
def diamondCount (phi : Formula) : Nat := (diamondSubformulas phi).card

/-!
## Subformula Membership Lemmas

These lemmas enable reasoning about when subformulas are in the closure.
-/

/--
Left component of implication is in closure.
-/
theorem closure_imp_left (phi psi chi : Formula)
    (h : Formula.imp psi chi ∈ subformulaClosure phi) :
    psi ∈ subformulaClosure phi := by
  unfold subformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_imp_left h

/--
Right component of implication is in closure.
-/
theorem closure_imp_right (phi psi chi : Formula)
    (h : Formula.imp psi chi ∈ subformulaClosure phi) :
    chi ∈ subformulaClosure phi := by
  unfold subformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_imp_right h

/--
Inner formula of Box is in closure.
-/
theorem closure_box (phi psi : Formula)
    (h : Formula.box psi ∈ subformulaClosure phi) :
    psi ∈ subformulaClosure phi := by
  unfold subformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_box h

/--
Inner formula of all_past is in closure.
-/
theorem closure_all_past (phi psi : Formula)
    (h : Formula.all_past psi ∈ subformulaClosure phi) :
    psi ∈ subformulaClosure phi := by
  unfold subformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_all_past h

/--
Inner formula of all_future is in closure.
-/
theorem closure_all_future (phi psi : Formula)
    (h : Formula.all_future psi ∈ subformulaClosure phi) :
    psi ∈ subformulaClosure phi := by
  unfold subformulaClosure at h ⊢
  simp only [List.mem_toFinset] at h ⊢
  exact Formula.mem_subformulas_of_all_future h

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
def f_nesting_depth : Formula → Nat
  | .imp (.all_future (.imp inner .bot)) .bot => 1 + f_nesting_depth inner
  | _ => 0

/-- f_nesting_depth is always non-negative (trivially true for Nat). -/
theorem f_nesting_depth_nonneg (phi : Formula) : f_nesting_depth phi ≥ 0 := Nat.zero_le _

/-- The some_future (F) operator matches our pattern. -/
theorem some_future_unfold (psi : Formula) :
    Formula.some_future psi = Formula.imp (Formula.all_future (Formula.imp psi Formula.bot)) Formula.bot := by
  simp only [Formula.some_future, Formula.neg]

/-- F-nesting depth of F(psi) is 1 + depth of psi. -/
theorem f_nesting_depth_some_future (psi : Formula) :
    f_nesting_depth (Formula.some_future psi) = 1 + f_nesting_depth psi := by
  simp only [Formula.some_future, Formula.neg, f_nesting_depth]

/-- Atoms have F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_atom (a : Bimodal.Syntax.Atom) : f_nesting_depth (.atom a) = 0 := rfl

/-- Bot has F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_bot : f_nesting_depth .bot = 0 := rfl

/-- Box formulas have F-nesting depth 0 (F is not Box). -/
@[simp]
theorem f_nesting_depth_box (psi : Formula) : f_nesting_depth (.box psi) = 0 := rfl

/-- all_past formulas have F-nesting depth 0. -/
@[simp]
theorem f_nesting_depth_all_past (psi : Formula) : f_nesting_depth (.all_past psi) = 0 := rfl

/-- all_future formulas have F-nesting depth 0 (F = neg ∘ all_future ∘ neg, not raw all_future). -/
@[simp]
theorem f_nesting_depth_all_future (psi : Formula) : f_nesting_depth (.all_future psi) = 0 := rfl

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
def max_F_depth_in_closure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup f_nesting_depth

/--
Every element of closureWithNeg has F-depth at most max_F_depth_in_closure.
-/
theorem f_depth_le_max {phi psi : Formula} (h : psi ∈ closureWithNeg phi) :
    f_nesting_depth psi ≤ max_F_depth_in_closure phi := by
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
def p_nesting_depth : Formula → Nat
  | .imp (.all_past (.imp inner .bot)) .bot => 1 + p_nesting_depth inner
  | _ => 0

/-- p_nesting_depth is always non-negative (trivially true for Nat). -/
theorem p_nesting_depth_nonneg (phi : Formula) : p_nesting_depth phi ≥ 0 := Nat.zero_le _

/-- The some_past (P) operator matches our pattern. -/
theorem some_past_unfold (psi : Formula) :
    Formula.some_past psi = Formula.imp (Formula.all_past (Formula.imp psi Formula.bot)) Formula.bot := by
  simp only [Formula.some_past, Formula.neg]

/-- P-nesting depth of P(psi) is 1 + depth of psi. -/
theorem p_nesting_depth_some_past (psi : Formula) :
    p_nesting_depth (Formula.some_past psi) = 1 + p_nesting_depth psi := by
  simp only [Formula.some_past, Formula.neg, p_nesting_depth]

/-- Atoms have P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_atom (a : Bimodal.Syntax.Atom) : p_nesting_depth (.atom a) = 0 := rfl

/-- Bot has P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_bot : p_nesting_depth .bot = 0 := rfl

/-- Box formulas have P-nesting depth 0 (P is not Box). -/
@[simp]
theorem p_nesting_depth_box (psi : Formula) : p_nesting_depth (.box psi) = 0 := rfl

/-- all_future formulas have P-nesting depth 0. -/
@[simp]
theorem p_nesting_depth_all_future (psi : Formula) : p_nesting_depth (.all_future psi) = 0 := rfl

/-- all_past formulas have P-nesting depth 0 (P = neg ∘ all_past ∘ neg, not raw all_past). -/
@[simp]
theorem p_nesting_depth_all_past (psi : Formula) : p_nesting_depth (.all_past psi) = 0 := rfl

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
def max_P_depth_in_closure (phi : Formula) : Nat :=
  (closureWithNeg phi).sup p_nesting_depth

/--
Every element of closureWithNeg has P-depth at most max_P_depth_in_closure.
-/
theorem p_depth_le_max {phi psi : Formula} (h : psi ∈ closureWithNeg phi) :
    p_nesting_depth psi ≤ max_P_depth_in_closure phi := by
  exact Finset.le_sup h

end Bimodal.Syntax
