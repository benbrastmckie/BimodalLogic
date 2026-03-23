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
  | .imp (.all_future (.imp inner .bot)) .bot => some inner
  | _ => none

/--
Extract the inner formula chi from P(chi) = some_past chi.

P(chi) = chi.neg.all_past.neg
       = (chi.imp bot).all_past.imp bot
       = Formula.imp (Formula.all_past (Formula.imp chi Formula.bot)) Formula.bot
-/
def extractPastInner : Formula → Option Formula
  | .imp (.all_past (.imp inner .bot)) .bot => some inner
  | _ => none

/-- extractFutureInner correctly extracts from some_future. -/
theorem extractFutureInner_some_future (chi : Formula) :
    extractFutureInner (Formula.some_future chi) = some chi := by
  simp only [Formula.some_future, Formula.neg, extractFutureInner]

/-- extractPastInner correctly extracts from some_past. -/
theorem extractPastInner_some_past (chi : Formula) :
    extractPastInner (Formula.some_past chi) = some chi := by
  simp only [Formula.some_past, Formula.neg, extractPastInner]

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

/-!
## Deferral Closure

The deferral closure extends closureWithNeg with the deferral disjunctions
needed for the successor seed construction.

deferralClosure(phi) = closureWithNeg(phi)
                     ∪ {chi ∨ F(chi) | F(chi) ∈ closureWithNeg(phi)}
                     ∪ {chi ∨ P(chi) | P(chi) ∈ closureWithNeg(phi)}
-/

/--
Convert an F-formula F(chi) to its deferral disjunction chi ∨ F(chi).
For non-F-formulas, returns bot (which will be filtered out).
-/
def toFutureDeferral (f : Formula) : Formula :=
  match extractFutureInner f with
  | some chi => Formula.or chi (Formula.some_future chi)
  | none => Formula.bot  -- Placeholder, will be filtered

/--
Convert a P-formula P(chi) to its deferral disjunction chi ∨ P(chi).
For non-P-formulas, returns bot (which will be filtered out).
-/
def toPastDeferral (f : Formula) : Formula :=
  match extractPastInner f with
  | some chi => Formula.or chi (Formula.some_past chi)
  | none => Formula.bot  -- Placeholder, will be filtered

/--
The set of F-deferral disjunctions for phi.

For each F(chi) in closureWithNeg(phi), we add chi ∨ F(chi).
These are the formulas that enable the F-step condition to be satisfied.

Implementation: filter for F-formulas, then map to deferral disjunctions.
-/
def deferralDisjunctionSet (phi : Formula) : Finset Formula :=
  ((closureWithNeg phi).filter IsFutureFormula).image toFutureDeferral

/--
The set of P-deferral disjunctions for phi (backward direction).

For each P(chi) in closureWithNeg(phi), we add chi ∨ P(chi).
These are the formulas that enable the P-step condition to be satisfied.
-/
def backwardDeferralSet (phi : Formula) : Finset Formula :=
  ((closureWithNeg phi).filter IsPastFormula).image toPastDeferral

/--
The deferral closure extends closureWithNeg with deferral disjunctions.

This closure is used for the restricted MCS construction in the completeness proof.
It ensures that:
1. The successor deferral seed lies within the closure
2. The F/P-nesting depth is bounded (deferral disjunctions have depth 0)
3. The closure is still finite
-/
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi

/-- closureWithNeg is a subset of deferralClosure. -/
theorem closureWithNeg_subset_deferralClosure (phi : Formula) :
    closureWithNeg phi ⊆ deferralClosure phi := by
  intro psi h
  unfold deferralClosure
  exact Finset.mem_union_left _ (Finset.mem_union_left _ h)

/-- The formula itself is in deferralClosure. -/
theorem self_mem_deferralClosure (phi : Formula) : phi ∈ deferralClosure phi :=
  closureWithNeg_subset_deferralClosure phi (self_mem_closureWithNeg phi)

/-- The negation of the formula is in deferralClosure. -/
theorem neg_self_mem_deferralClosure (phi : Formula) : phi.neg ∈ deferralClosure phi :=
  closureWithNeg_subset_deferralClosure phi (neg_self_mem_closureWithNeg phi)

/-- toFutureDeferral correctly converts F(chi) to chi ∨ F(chi). -/
theorem toFutureDeferral_some_future (chi : Formula) :
    toFutureDeferral (Formula.some_future chi) = Formula.or chi (Formula.some_future chi) := by
  simp only [toFutureDeferral, extractFutureInner_some_future]

/-- toPastDeferral correctly converts P(chi) to chi ∨ P(chi). -/
theorem toPastDeferral_some_past (chi : Formula) :
    toPastDeferral (Formula.some_past chi) = Formula.or chi (Formula.some_past chi) := by
  simp only [toPastDeferral, extractPastInner_some_past]

/-- If F(chi) is in closureWithNeg, then chi ∨ F(chi) is in deferralClosure. -/
theorem deferral_of_F_in_closure (phi chi : Formula)
    (h : Formula.some_future chi ∈ closureWithNeg phi) :
    Formula.or chi (Formula.some_future chi) ∈ deferralClosure phi := by
  unfold deferralClosure deferralDisjunctionSet
  apply Finset.mem_union_left
  apply Finset.mem_union_right
  rw [← toFutureDeferral_some_future chi]
  apply Finset.mem_image_of_mem
  apply Finset.mem_filter.mpr
  constructor
  · exact h
  · simp only [IsFutureFormula, extractFutureInner_some_future, Option.isSome_some]

/-- If P(chi) is in closureWithNeg, then chi ∨ P(chi) is in deferralClosure. -/
theorem deferral_of_P_in_closure (phi chi : Formula)
    (h : Formula.some_past chi ∈ closureWithNeg phi) :
    Formula.or chi (Formula.some_past chi) ∈ deferralClosure phi := by
  unfold deferralClosure backwardDeferralSet
  apply Finset.mem_union_right
  rw [← toPastDeferral_some_past chi]
  apply Finset.mem_image_of_mem
  apply Finset.mem_filter.mpr
  constructor
  · exact h
  · simp only [IsPastFormula, extractPastInner_some_past, Option.isSome_some]

/-!
## F/P-Depth Bounding for Deferral Closure

The key insight: deferral disjunctions chi ∨ F(chi) have f_nesting_depth 0
because they are imp formulas (Formula.or = neg.imp), NOT F-formulas.
Therefore, adding deferral disjunctions to the closure doesn't increase
the maximum F/P-depth bound.
-/

/--
F-nesting depth of a disjunction is 0.

A disjunction phi ∨ psi is encoded as phi.neg.imp psi = (phi.imp bot).imp psi.
This is an imp formula, not an F-formula, so f_nesting_depth is 0.
-/
theorem f_nesting_depth_or (chi psi : Formula) :
    f_nesting_depth (Formula.or chi psi) = 0 := by
  simp only [Formula.or, Formula.neg, f_nesting_depth]

/--
P-nesting depth of a disjunction is 0.

Symmetric to f_nesting_depth_or.
-/
theorem p_nesting_depth_or (chi psi : Formula) :
    p_nesting_depth (Formula.or chi psi) = 0 := by
  simp only [Formula.or, Formula.neg, p_nesting_depth]

/--
F-nesting depth of the F-deferral disjunction chi ∨ F(chi) is 0.
-/
theorem f_nesting_depth_F_deferral (chi : Formula) :
    f_nesting_depth (Formula.or chi (Formula.some_future chi)) = 0 :=
  f_nesting_depth_or chi (Formula.some_future chi)

/--
P-nesting depth of the P-deferral disjunction chi ∨ P(chi) is 0.
-/
theorem p_nesting_depth_P_deferral (chi : Formula) :
    p_nesting_depth (Formula.or chi (Formula.some_past chi)) = 0 :=
  p_nesting_depth_or chi (Formula.some_past chi)

/--
Maximum F-nesting depth in deferralClosure equals max in closureWithNeg.

The deferral disjunctions all have f_nesting_depth 0, so they don't
increase the maximum depth bound.
-/
theorem max_F_depth_deferralClosure_eq (phi : Formula) :
    (deferralClosure phi).sup f_nesting_depth = max_F_depth_in_closure phi := by
  -- Show max over deferralClosure = max over closureWithNeg
  apply le_antisymm
  · -- ≤ direction: every element of deferralClosure has depth ≤ max of closureWithNeg
    apply Finset.sup_le
    intro f hf
    unfold deferralClosure at hf
    simp only [Finset.mem_union] at hf
    rcases hf with (hf_orig | hf_defer_F) | hf_defer_P
    · -- f ∈ closureWithNeg phi
      exact f_depth_le_max hf_orig
    · -- f ∈ deferralDisjunctionSet phi
      unfold deferralDisjunctionSet at hf_defer_F
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_F
      obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := hf_defer_F
      -- g is an F-formula, f = toFutureDeferral g
      simp only [IsFutureFormula] at hg_F
      cases h_ext : extractFutureInner g <;> simp [h_ext] at hg_F
      -- g = F(chi) for some chi, f = chi ∨ F(chi)
      simp only [toFutureDeferral, h_ext] at hf_eq
      subst hf_eq
      -- f_nesting_depth (chi ∨ F(chi)) = 0 ≤ max
      simp only [f_nesting_depth_F_deferral, Nat.zero_le]
    · -- f ∈ backwardDeferralSet phi
      unfold backwardDeferralSet at hf_defer_P
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_P
      obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := hf_defer_P
      -- g is a P-formula, f = toPastDeferral g
      simp only [IsPastFormula] at hg_P
      cases h_ext : extractPastInner g <;> simp [h_ext] at hg_P
      -- g = P(chi) for some chi, f = chi ∨ P(chi)
      simp only [toPastDeferral, h_ext] at hf_eq
      subst hf_eq
      -- f_nesting_depth (chi ∨ P(chi)) = 0 ≤ max
      simp only [f_nesting_depth_or, Nat.zero_le]
  · -- ≥ direction: closureWithNeg ⊆ deferralClosure, so sup is at least as large
    apply Finset.sup_mono
    exact closureWithNeg_subset_deferralClosure phi

/--
Maximum P-nesting depth in deferralClosure equals max in closureWithNeg.

Symmetric to max_F_depth_deferralClosure_eq.
-/
theorem max_P_depth_deferralClosure_eq (phi : Formula) :
    (deferralClosure phi).sup p_nesting_depth = max_P_depth_in_closure phi := by
  apply le_antisymm
  · apply Finset.sup_le
    intro f hf
    unfold deferralClosure at hf
    simp only [Finset.mem_union] at hf
    rcases hf with (hf_orig | hf_defer_F) | hf_defer_P
    · exact p_depth_le_max hf_orig
    · unfold deferralDisjunctionSet at hf_defer_F
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_F
      obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := hf_defer_F
      simp only [IsFutureFormula] at hg_F
      cases h_ext : extractFutureInner g <;> simp [h_ext] at hg_F
      simp only [toFutureDeferral, h_ext] at hf_eq
      subst hf_eq
      simp only [p_nesting_depth_or, Nat.zero_le]
    · unfold backwardDeferralSet at hf_defer_P
      simp only [Finset.mem_image, Finset.mem_filter] at hf_defer_P
      obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := hf_defer_P
      simp only [IsPastFormula] at hg_P
      cases h_ext : extractPastInner g <;> simp [h_ext] at hg_P
      simp only [toPastDeferral, h_ext] at hf_eq
      subst hf_eq
      simp only [p_nesting_depth_P_deferral, Nat.zero_le]
  · apply Finset.sup_mono
    exact closureWithNeg_subset_deferralClosure phi

/-!
## Structural Lemmas for DeferralClosure

Key insight: the deferral disjunction additions are all `Formula.or` (= `Formula.imp`)
formulas. Therefore, any non-imp formula in deferralClosure must be in closureWithNeg.
In particular, G-formulas (all_future), H-formulas (all_past), box, atom, and bot
formulas in deferralClosure are all in closureWithNeg.
-/

/--
Helper: deferralDisjunctionSet and backwardDeferralSet only contain imp formulas.
Any formula in deferralClosure that is not an imp formula must be in closureWithNeg.

We prove this by showing deferralDisjunctionSet and backwardDeferralSet produce
imp formulas (via Formula.or = neg.imp = imp (imp _ bot) _).
-/
private theorem non_imp_in_deferralClosure_is_in_closureWithNeg (phi : Formula)
    (f : Formula) (h : f ∈ deferralClosure phi)
    (h_not_imp : ∀ a b : Formula, f ≠ Formula.imp a b) :
    f ∈ closureWithNeg phi := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with (h_orig | h_defer_F) | h_defer_P
  · exact h_orig
  · unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next chi =>
      simp only [toFutureDeferral, h_ext] at hf_eq
      -- hf_eq : chi.or chi.some_future = f
      exfalso; exact h_not_imp _ _ hf_eq.symm
  · unfold backwardDeferralSet at h_defer_P
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_P
    obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := h_defer_P
    simp only [IsPastFormula] at hg_P
    cases h_ext : extractPastInner g
    · simp [h_ext] at hg_P
    · next chi =>
      simp only [toPastDeferral, h_ext] at hf_eq
      exfalso; exact h_not_imp _ _ hf_eq.symm

/--
Any all_future formula in deferralClosure is in closureWithNeg.
-/
theorem all_future_in_deferralClosure_is_in_closureWithNeg (phi psi : Formula)
    (h : Formula.all_future psi ∈ deferralClosure phi) :
    Formula.all_future psi ∈ closureWithNeg phi :=
  non_imp_in_deferralClosure_is_in_closureWithNeg phi _ h (by intro a b; exact Formula.noConfusion)

/--
Any all_past formula in deferralClosure is in closureWithNeg.
-/
theorem all_past_in_deferralClosure_is_in_closureWithNeg (phi psi : Formula)
    (h : Formula.all_past psi ∈ deferralClosure phi) :
    Formula.all_past psi ∈ closureWithNeg phi :=
  non_imp_in_deferralClosure_is_in_closureWithNeg phi _ h (by intro a b; exact Formula.noConfusion)

/--
If G(psi) is in deferralClosure, then psi is in deferralClosure.
-/
theorem deferralClosure_all_future (phi psi : Formula)
    (h : Formula.all_future psi ∈ deferralClosure phi) :
    psi ∈ deferralClosure phi := by
  have h_cwn := all_future_in_deferralClosure_is_in_closureWithNeg phi psi h
  unfold closureWithNeg at h_cwn
  simp only [Finset.mem_union, Finset.mem_image] at h_cwn
  rcases h_cwn with h_sub | ⟨g, h_g_sub, h_g_eq⟩
  · exact closureWithNeg_subset_deferralClosure phi
      (subformulaClosure_subset_closureWithNeg phi (closure_all_future phi psi h_sub))
  · cases h_g_eq

/--
If H(psi) is in deferralClosure, then psi is in deferralClosure.
-/
theorem deferralClosure_all_past (phi psi : Formula)
    (h : Formula.all_past psi ∈ deferralClosure phi) :
    psi ∈ deferralClosure phi := by
  have h_cwn := all_past_in_deferralClosure_is_in_closureWithNeg phi psi h
  unfold closureWithNeg at h_cwn
  simp only [Finset.mem_union, Finset.mem_image] at h_cwn
  rcases h_cwn with h_sub | ⟨g, h_g_sub, h_g_eq⟩
  · exact closureWithNeg_subset_deferralClosure phi
      (subformulaClosure_subset_closureWithNeg phi (closure_all_past phi psi h_sub))
  · cases h_g_eq

/--
Any F-formula (some_future) in deferralClosure is in closureWithNeg.

F(chi) has f_nesting_depth >= 1, but deferral disjunctions have f_nesting_depth = 0,
so F(chi) cannot be a deferral disjunction.
-/
theorem some_future_in_deferralClosure_is_in_closureWithNeg (phi chi : Formula)
    (h : Formula.some_future chi ∈ deferralClosure phi) :
    Formula.some_future chi ∈ closureWithNeg phi := by
  -- F(chi) = imp (all_future (imp chi bot)) bot, which IS an imp formula
  -- So we can't use the non_imp lemma directly.
  -- Instead, use depth argument.
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with (h_orig | h_defer_F) | h_defer_P
  · exact h_orig
  · unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next inner =>
      simp only [toFutureDeferral, h_ext] at hf_eq
      have h1 : f_nesting_depth (Formula.some_future chi) ≥ 1 := by
        rw [f_nesting_depth_some_future]; omega
      rw [← hf_eq] at h1
      simp only [f_nesting_depth_or] at h1; omega
  · unfold backwardDeferralSet at h_defer_P
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_P
    obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := h_defer_P
    simp only [IsPastFormula] at hg_P
    cases h_ext : extractPastInner g
    · simp [h_ext] at hg_P
    · next inner =>
      simp only [toPastDeferral, h_ext] at hf_eq
      have h1 : f_nesting_depth (Formula.some_future chi) ≥ 1 := by
        rw [f_nesting_depth_some_future]; omega
      rw [← hf_eq] at h1
      simp only [f_nesting_depth_or] at h1; omega

/--
Any P-formula (some_past) in deferralClosure is in closureWithNeg.
Symmetric to some_future_in_deferralClosure_is_in_closureWithNeg.
-/
theorem some_past_in_deferralClosure_is_in_closureWithNeg (phi chi : Formula)
    (h : Formula.some_past chi ∈ deferralClosure phi) :
    Formula.some_past chi ∈ closureWithNeg phi := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with (h_orig | h_defer_F) | h_defer_P
  · exact h_orig
  · unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next inner =>
      simp only [toFutureDeferral, h_ext] at hf_eq
      have h1 : p_nesting_depth (Formula.some_past chi) ≥ 1 := by
        rw [p_nesting_depth_some_past]; omega
      rw [← hf_eq] at h1
      simp only [p_nesting_depth_or] at h1; omega
  · unfold backwardDeferralSet at h_defer_P
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_P
    obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := h_defer_P
    simp only [IsPastFormula] at hg_P
    cases h_ext : extractPastInner g
    · simp [h_ext] at hg_P
    · next inner =>
      simp only [toPastDeferral, h_ext] at hf_eq
      have h1 : p_nesting_depth (Formula.some_past chi) ≥ 1 := by
        rw [p_nesting_depth_some_past]; omega
      rw [← hf_eq] at h1
      simp only [p_nesting_depth_P_deferral] at h1; omega

end Bimodal.Syntax
