import Bimodal.Syntax.Formula
import Bimodal.Syntax.Subformulas
import Mathlib.Data.Finset.Basic
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
and `Bimodal.Metalogic.FMP.Closure` (Finset-based for FMP) with the specific
needs of the multi-family BFMCS construction.

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

end Bimodal.Syntax
