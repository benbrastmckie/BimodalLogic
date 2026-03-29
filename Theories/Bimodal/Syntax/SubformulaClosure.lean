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

/--
If P(chi) is in closureWithNeg phi, then chi is in subformulaClosure phi.

P(chi) = neg(H(neg chi)) = (H(neg chi)).imp bot.
If P(chi) is in subformulaClosure, we extract chi via closure_imp_left and closure_all_past.
If P(chi) = psi.neg for psi in subformulaClosure, then psi = H(neg chi), so we extract chi similarly.
-/
theorem some_past_in_closureWithNeg_inner_in_subformulaClosure (phi chi : Formula)
    (h : Formula.some_past chi ∈ closureWithNeg phi) :
    chi ∈ subformulaClosure phi := by
  unfold closureWithNeg at h
  simp only [Finset.mem_union, Finset.mem_image] at h
  rcases h with h_sub | ⟨psi, h_psi_sub, h_psi_neg_eq⟩
  · -- Case: P(chi) in subformulaClosure phi
    -- P(chi) = neg(H(neg chi)) = (H(neg chi)).imp bot
    -- Immediate subformula: H(neg chi)
    have h_H_neg : Formula.all_past (Formula.neg chi) ∈ subformulaClosure phi :=
      closure_imp_left phi _ _ h_sub
    -- Inner of H: neg chi
    have h_neg_chi : Formula.neg chi ∈ subformulaClosure phi :=
      closure_all_past phi _ h_H_neg
    -- neg chi = chi.imp bot, so chi is a subformula
    exact closure_imp_left phi _ _ h_neg_chi
  · -- Case: P(chi) = psi.neg for some psi in subformulaClosure phi
    -- P(chi) = neg(H(neg chi)), so psi.neg = neg(H(neg chi))
    -- This means psi = H(neg chi) (syntactically, since neg is injective)
    -- Note: psi.neg = Formula.imp psi Formula.bot
    -- neg(H(neg chi)) = Formula.imp (H(neg chi)) Formula.bot
    -- So psi = H(neg chi)
    unfold Formula.some_past Formula.neg at h_psi_neg_eq
    -- h_psi_neg_eq : psi.imp bot = (chi.imp bot).all_past.imp bot
    -- Extract psi = (chi.imp bot).all_past = chi.neg.all_past
    have h_eq : psi = Formula.all_past (Formula.neg chi) := by
      cases h_psi_neg_eq; rfl
    rw [h_eq] at h_psi_sub
    -- Now psi = H(neg chi) in subformulaClosure phi
    have h_neg_chi : Formula.neg chi ∈ subformulaClosure phi :=
      closure_all_past phi _ h_psi_sub
    exact closure_imp_left phi _ _ h_neg_chi

/--
If F(chi) is in closureWithNeg phi, then chi is in subformulaClosure phi.

Symmetric to some_past_in_closureWithNeg_inner_in_subformulaClosure.
F(chi) = neg(G(neg chi)) = (G(neg chi)).imp bot.
-/
theorem some_future_in_closureWithNeg_inner_in_subformulaClosure (phi chi : Formula)
    (h : Formula.some_future chi ∈ closureWithNeg phi) :
    chi ∈ subformulaClosure phi := by
  unfold closureWithNeg at h
  simp only [Finset.mem_union, Finset.mem_image] at h
  rcases h with h_sub | ⟨psi, h_psi_sub, h_psi_neg_eq⟩
  · -- Case: F(chi) in subformulaClosure phi
    -- F(chi) = neg(G(neg chi)) = (G(neg chi)).imp bot
    have h_G_neg : Formula.all_future (Formula.neg chi) ∈ subformulaClosure phi :=
      closure_imp_left phi _ _ h_sub
    have h_neg_chi : Formula.neg chi ∈ subformulaClosure phi :=
      closure_all_future phi _ h_G_neg
    exact closure_imp_left phi _ _ h_neg_chi
  · -- Case: F(chi) = psi.neg for some psi in subformulaClosure phi
    unfold Formula.some_future Formula.neg at h_psi_neg_eq
    have h_eq : psi = Formula.all_future (Formula.neg chi) := by
      cases h_psi_neg_eq; rfl
    rw [h_eq] at h_psi_sub
    have h_neg_chi : Formula.neg chi ∈ subformulaClosure phi :=
      closure_all_future phi _ h_psi_sub
    exact closure_imp_left phi _ _ h_neg_chi

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

/-!
## Seriality Formulas

The seriality formulas F(neg bot), P(neg bot), and neg bot are always included
in deferralClosure, regardless of the target formula phi. This is needed for
completeness: any maximal consistent set must contain F_top and P_top (the
seriality axioms), so these formulas must be available in the closure used
for restricted MCS construction.
-/

/-- F_top = F(neg bot) is the seriality axiom for forward time. -/
abbrev F_top : Formula := Formula.some_future (Formula.neg Formula.bot)

/-- P_top = P(neg bot) is the seriality axiom for backward time. -/
abbrev P_top : Formula := Formula.some_past (Formula.neg Formula.bot)

/-- neg neg bot = neg (neg bot) = (neg bot).neg -/
abbrev neg_neg_bot : Formula := Formula.neg (Formula.neg Formula.bot)

/-- G(neg neg bot) = G(neg (neg bot)) is needed for F_top's blocking formula in chains. -/
abbrev G_neg_neg_bot : Formula := Formula.all_future neg_neg_bot

/-- H(neg neg bot) = H(neg (neg bot)) is needed for P_top's blocking formula in chains. -/
abbrev H_neg_neg_bot : Formula := Formula.all_past neg_neg_bot

/-- The deferral disjunction for F_top: neg bot ∨ F_top. -/
abbrev F_top_deferral : Formula := Formula.or (Formula.neg Formula.bot) F_top

/-- The deferral disjunction for P_top: neg bot ∨ P_top. -/
abbrev P_top_deferral : Formula := Formula.or (Formula.neg Formula.bot) P_top

/-- The set of seriality formulas that must be in any deferralClosure.

This includes:
- F_top, P_top: the seriality axioms
- neg bot: the inner formula of F_top and P_top (needed for chi ∈ deferralClosure when F/P(chi) is)
- neg neg bot: the inner of the blocking formulas
- G(neg neg bot), H(neg neg bot): the blocking formulas for F_top and P_top
- F_top_deferral, P_top_deferral: deferral disjunctions for the seriality axioms
-/
def serialityFormulas : Finset Formula :=
  {F_top, P_top, Formula.neg Formula.bot, neg_neg_bot, G_neg_neg_bot, H_neg_neg_bot,
   F_top_deferral, P_top_deferral}

/--
The deferral closure extends closureWithNeg with deferral disjunctions and
seriality formulas.

This closure is used for the restricted MCS construction in the completeness proof.
It ensures that:
1. The successor deferral seed lies within the closure
2. The F/P-nesting depth is bounded (deferral disjunctions have depth 0)
3. The closure is still finite
4. F_top and P_top are always available (for seriality/chain construction)
-/
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas

/-- closureWithNeg is a subset of deferralClosure. -/
theorem closureWithNeg_subset_deferralClosure (phi : Formula) :
    closureWithNeg phi ⊆ deferralClosure phi := by
  intro psi h
  unfold deferralClosure
  exact Finset.mem_union_left _ (Finset.mem_union_left _ (Finset.mem_union_left _ h))

/-- The formula itself is in deferralClosure. -/
theorem self_mem_deferralClosure (phi : Formula) : phi ∈ deferralClosure phi :=
  closureWithNeg_subset_deferralClosure phi (self_mem_closureWithNeg phi)

/-- The negation of the formula is in deferralClosure. -/
theorem neg_self_mem_deferralClosure (phi : Formula) : phi.neg ∈ deferralClosure phi :=
  closureWithNeg_subset_deferralClosure phi (neg_self_mem_closureWithNeg phi)

/-- F_top is in serialityFormulas. -/
theorem F_top_mem_serialityFormulas : F_top ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  left; trivial

/-- P_top is in serialityFormulas. -/
theorem P_top_mem_serialityFormulas : P_top ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; left; trivial

/-- neg bot is in serialityFormulas. -/
theorem neg_bot_mem_serialityFormulas : Formula.neg Formula.bot ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; left; trivial

/-- neg neg bot is in serialityFormulas. -/
theorem neg_neg_bot_mem_serialityFormulas : neg_neg_bot ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; right; left; trivial

/-- G(neg neg bot) is in serialityFormulas. -/
theorem G_neg_neg_bot_mem_serialityFormulas : G_neg_neg_bot ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; right; right; left; trivial

/-- H(neg neg bot) is in serialityFormulas. -/
theorem H_neg_neg_bot_mem_serialityFormulas : H_neg_neg_bot ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; right; right; right; trivial

/-- F_top is in deferralClosure for any phi. -/
theorem F_top_mem_deferralClosure (phi : Formula) : F_top ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact F_top_mem_serialityFormulas

/-- P_top is in deferralClosure for any phi. -/
theorem P_top_mem_deferralClosure (phi : Formula) : P_top ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact P_top_mem_serialityFormulas

/-- neg bot is in deferralClosure for any phi. -/
theorem neg_bot_mem_deferralClosure (phi : Formula) :
    Formula.neg Formula.bot ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact neg_bot_mem_serialityFormulas

/-- neg neg bot is in deferralClosure for any phi. -/
theorem neg_neg_bot_mem_deferralClosure (phi : Formula) :
    neg_neg_bot ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact neg_neg_bot_mem_serialityFormulas

/-- G(neg neg bot) is in deferralClosure for any phi. -/
theorem G_neg_neg_bot_mem_deferralClosure (phi : Formula) :
    G_neg_neg_bot ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact G_neg_neg_bot_mem_serialityFormulas

/-- H(neg neg bot) is in deferralClosure for any phi. -/
theorem H_neg_neg_bot_mem_deferralClosure (phi : Formula) :
    H_neg_neg_bot ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact H_neg_neg_bot_mem_serialityFormulas

/-- F_top_deferral is in serialityFormulas. -/
theorem F_top_deferral_mem_serialityFormulas : F_top_deferral ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; right; right; right; right; left; trivial

/-- P_top_deferral is in serialityFormulas. -/
theorem P_top_deferral_mem_serialityFormulas : P_top_deferral ∈ serialityFormulas := by
  simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton]
  right; right; right; right; right; right; right; trivial

/-- F_top_deferral is in deferralClosure for any phi. -/
theorem F_top_deferral_mem_deferralClosure (phi : Formula) :
    F_top_deferral ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact F_top_deferral_mem_serialityFormulas

/-- P_top_deferral is in deferralClosure for any phi. -/
theorem P_top_deferral_mem_deferralClosure (phi : Formula) :
    P_top_deferral ∈ deferralClosure phi := by
  unfold deferralClosure
  apply Finset.mem_union_right
  exact P_top_deferral_mem_serialityFormulas

/-- F_top deferral is the correct deferral formula for F_top. -/
theorem F_top_deferral_eq : F_top_deferral = Formula.or (Formula.neg Formula.bot) F_top := rfl

/-- P_top deferral is the correct deferral formula for P_top. -/
theorem P_top_deferral_eq : P_top_deferral = Formula.or (Formula.neg Formula.bot) P_top := rfl

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
  apply Finset.mem_union_left
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
Maximum F-nesting depth in deferralClosure equals max in closureWithNeg (or 1 for F_top).

The deferral disjunctions have f_nesting_depth 0. F_top has f_nesting_depth 1.
For any phi with F-formulas, the max is unchanged. For phi with no F-formulas,
the max is max(0, 1) = 1 from F_top.
-/
theorem max_F_depth_deferralClosure_eq (phi : Formula) :
    (deferralClosure phi).sup f_nesting_depth = max (max_F_depth_in_closure phi) 1 := by
  -- Show max over deferralClosure = max(max over closureWithNeg, 1)
  apply le_antisymm
  · -- ≤ direction: every element of deferralClosure has depth ≤ max
    apply Finset.sup_le
    intro f hf
    unfold deferralClosure at hf
    simp only [Finset.mem_union] at hf
    rcases hf with ((hf_orig | hf_defer_F) | hf_defer_P) | hf_serial
    · -- f ∈ closureWithNeg phi
      exact le_max_of_le_left (f_depth_le_max hf_orig)
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
    · -- f ∈ serialityFormulas
      simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at hf_serial
      rcases hf_serial with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- f = F_top: f_nesting_depth = 1
        simp only [F_top, f_nesting_depth_some_future]
        exact le_max_of_le_right (by native_decide)
      · -- f = P_top: f_nesting_depth = 0
        simp only [P_top, Formula.some_past, Formula.neg, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = neg bot: f_nesting_depth = 0
        simp only [Formula.neg, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = neg neg bot: f_nesting_depth = 0
        simp only [neg_neg_bot, Formula.neg, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = G(neg neg bot): f_nesting_depth = 0 (it's an all_future, not some_future)
        simp only [G_neg_neg_bot, Formula.all_future, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = H(neg neg bot): f_nesting_depth = 0
        simp only [H_neg_neg_bot, Formula.all_past, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = F_top_deferral: f_nesting_depth = 0 (it's an or/imp)
        simp only [F_top_deferral, Formula.or, Formula.neg, f_nesting_depth]
        exact Nat.zero_le _
      · -- f = P_top_deferral: f_nesting_depth = 0 (it's an or/imp)
        simp only [P_top_deferral, Formula.or, Formula.neg, f_nesting_depth]
        exact Nat.zero_le _
  · -- ≥ direction: max from closureWithNeg and from F_top
    apply max_le
    · apply Finset.sup_mono; exact closureWithNeg_subset_deferralClosure phi
    · calc 1 = f_nesting_depth F_top := by native_decide
        _ ≤ (deferralClosure phi).sup f_nesting_depth :=
            Finset.le_sup (F_top_mem_deferralClosure phi)

/--
Maximum P-nesting depth in deferralClosure equals max in closureWithNeg (or 1 for P_top).

Symmetric to max_F_depth_deferralClosure_eq.
-/
theorem max_P_depth_deferralClosure_eq (phi : Formula) :
    (deferralClosure phi).sup p_nesting_depth = max (max_P_depth_in_closure phi) 1 := by
  apply le_antisymm
  · apply Finset.sup_le
    intro f hf
    unfold deferralClosure at hf
    simp only [Finset.mem_union] at hf
    rcases hf with ((hf_orig | hf_defer_F) | hf_defer_P) | hf_serial
    · exact le_max_of_le_left (p_depth_le_max hf_orig)
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
    · -- f ∈ serialityFormulas
      simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at hf_serial
      rcases hf_serial with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- f = F_top: p_nesting_depth = 0
        simp only [F_top, Formula.some_future, Formula.neg, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = P_top: p_nesting_depth = 1
        simp only [P_top, p_nesting_depth_some_past]
        exact le_max_of_le_right (by native_decide)
      · -- f = neg bot: p_nesting_depth = 0
        simp only [Formula.neg, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = neg neg bot: p_nesting_depth = 0
        simp only [neg_neg_bot, Formula.neg, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = G(neg neg bot): p_nesting_depth = 0
        simp only [G_neg_neg_bot, Formula.all_future, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = H(neg neg bot): p_nesting_depth = 0 (it's an all_past, not some_past)
        simp only [H_neg_neg_bot, Formula.all_past, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = F_top_deferral: p_nesting_depth = 0 (it's an or/imp)
        simp only [F_top_deferral, Formula.or, Formula.neg, p_nesting_depth]
        exact Nat.zero_le _
      · -- f = P_top_deferral: p_nesting_depth = 0 (it's an or/imp)
        simp only [P_top_deferral, Formula.or, Formula.neg, p_nesting_depth]
        exact Nat.zero_le _
  · -- ≥ direction: max from closureWithNeg and from P_top
    apply max_le
    · apply Finset.sup_mono; exact closureWithNeg_subset_deferralClosure phi
    · calc 1 = p_nesting_depth P_top := by native_decide
        _ ≤ (deferralClosure phi).sup p_nesting_depth :=
            Finset.le_sup (P_top_mem_deferralClosure phi)

/-!
## Structural Lemmas for DeferralClosure

Key insight: the deferral disjunction additions are all `Formula.or` (= `Formula.imp`)
formulas. Therefore, any non-imp formula in deferralClosure must be in closureWithNeg.
In particular, G-formulas (all_future), H-formulas (all_past), box, atom, and bot
formulas in deferralClosure are all in closureWithNeg.
-/

/--
Helper: deferralDisjunctionSet, backwardDeferralSet, and most serialityFormulas contain imp formulas.
Any formula in deferralClosure that is not an imp formula and not G/H_neg_neg_bot must be in closureWithNeg.

Note: G_neg_neg_bot and H_neg_neg_bot are non-imp formulas in serialityFormulas but not in closureWithNeg.
Callers that need to handle all_future/all_past formulas should use `all_future_in_deferralClosure_cases`
or `all_past_in_deferralClosure_cases` instead.
-/
private theorem non_imp_in_deferralClosure_is_in_closureWithNeg (phi : Formula)
    (f : Formula) (h : f ∈ deferralClosure phi)
    (h_not_imp : ∀ a b : Formula, f ≠ Formula.imp a b)
    (h_not_G : f ≠ G_neg_neg_bot)
    (h_not_H : f ≠ H_neg_neg_bot) :
    f ∈ closureWithNeg phi := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with ((h_orig | h_defer_F) | h_defer_P) | h_serial
  · exact h_orig
  · unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next chi =>
      simp only [toFutureDeferral, h_ext] at hf_eq
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
  · -- serialityFormulas
    simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at h_serial
    rcases h_serial with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exfalso; exact h_not_imp _ _ rfl  -- F_top is imp
    · exfalso; exact h_not_imp _ _ rfl  -- P_top is imp
    · exfalso; exact h_not_imp _ _ rfl  -- neg bot is imp
    · exfalso; exact h_not_imp _ _ rfl  -- neg neg bot is imp
    · exfalso; exact h_not_G rfl        -- G_neg_neg_bot excluded by hypothesis
    · exfalso; exact h_not_H rfl        -- H_neg_neg_bot excluded by hypothesis
    · exfalso; exact h_not_imp _ _ rfl  -- F_top_deferral is imp (or = neg.imp)
    · exfalso; exact h_not_imp _ _ rfl  -- P_top_deferral is imp (or = neg.imp)

/--
Any all_future formula in deferralClosure is either in closureWithNeg or is G_neg_neg_bot.
-/
theorem all_future_in_deferralClosure_cases (phi psi : Formula)
    (h : Formula.all_future psi ∈ deferralClosure phi) :
    Formula.all_future psi ∈ closureWithNeg phi ∨ Formula.all_future psi = G_neg_neg_bot := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with ((h_orig | h_defer_F) | h_defer_P) | h_serial
  · exact Or.inl h_orig
  · -- deferralDisjunctionSet: all_future is not an or formula
    unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next chi =>
      simp only [toFutureDeferral, h_ext] at hf_eq
      exact (Formula.noConfusion hf_eq.symm : False).elim
  · -- backwardDeferralSet: all_future is not an or formula
    unfold backwardDeferralSet at h_defer_P
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_P
    obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := h_defer_P
    simp only [IsPastFormula] at hg_P
    cases h_ext : extractPastInner g
    · simp [h_ext] at hg_P
    · next chi =>
      simp only [toPastDeferral, h_ext] at hf_eq
      exact (Formula.noConfusion hf_eq.symm : False).elim
  · -- serialityFormulas
    simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at h_serial
    rcases h_serial with h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq
    · exact (Formula.noConfusion h_eq : False).elim  -- F_top is some_future, not all_future
    · exact (Formula.noConfusion h_eq : False).elim  -- P_top is some_past
    · exact (Formula.noConfusion h_eq : False).elim  -- neg bot is imp
    · exact (Formula.noConfusion h_eq : False).elim  -- neg neg bot is imp
    · exact Or.inr h_eq  -- G_neg_neg_bot
    · exact (Formula.noConfusion h_eq : False).elim  -- H_neg_neg_bot is all_past
    · exact (Formula.noConfusion h_eq : False).elim  -- F_top_deferral is or
    · exact (Formula.noConfusion h_eq : False).elim  -- P_top_deferral is or

/--
For backward compatibility: all_future in deferralClosure excluding G_neg_neg_bot.
-/
theorem all_future_in_deferralClosure_is_in_closureWithNeg (phi psi : Formula)
    (h : Formula.all_future psi ∈ deferralClosure phi)
    (h_not_G : Formula.all_future psi ≠ G_neg_neg_bot) :
    Formula.all_future psi ∈ closureWithNeg phi := by
  rcases all_future_in_deferralClosure_cases phi psi h with h_cwn | h_eq
  · exact h_cwn
  · exact absurd h_eq h_not_G

/--
Any all_past formula in deferralClosure is either in closureWithNeg or is H_neg_neg_bot.
-/
theorem all_past_in_deferralClosure_cases (phi psi : Formula)
    (h : Formula.all_past psi ∈ deferralClosure phi) :
    Formula.all_past psi ∈ closureWithNeg phi ∨ Formula.all_past psi = H_neg_neg_bot := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with ((h_orig | h_defer_F) | h_defer_P) | h_serial
  · exact Or.inl h_orig
  · -- deferralDisjunctionSet
    unfold deferralDisjunctionSet at h_defer_F
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_F
    obtain ⟨g, ⟨_, hg_F⟩, hf_eq⟩ := h_defer_F
    simp only [IsFutureFormula] at hg_F
    cases h_ext : extractFutureInner g
    · simp [h_ext] at hg_F
    · next chi =>
      simp only [toFutureDeferral, h_ext] at hf_eq
      exact (Formula.noConfusion hf_eq.symm : False).elim
  · -- backwardDeferralSet
    unfold backwardDeferralSet at h_defer_P
    simp only [Finset.mem_image, Finset.mem_filter] at h_defer_P
    obtain ⟨g, ⟨_, hg_P⟩, hf_eq⟩ := h_defer_P
    simp only [IsPastFormula] at hg_P
    cases h_ext : extractPastInner g
    · simp [h_ext] at hg_P
    · next chi =>
      simp only [toPastDeferral, h_ext] at hf_eq
      exact (Formula.noConfusion hf_eq.symm : False).elim
  · -- serialityFormulas
    simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at h_serial
    rcases h_serial with h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq
    · exact (Formula.noConfusion h_eq : False).elim  -- F_top
    · exact (Formula.noConfusion h_eq : False).elim  -- P_top
    · exact (Formula.noConfusion h_eq : False).elim  -- neg bot
    · exact (Formula.noConfusion h_eq : False).elim  -- neg neg bot
    · exact (Formula.noConfusion h_eq : False).elim  -- G_neg_neg_bot is all_future
    · exact Or.inr h_eq  -- H_neg_neg_bot
    · exact (Formula.noConfusion h_eq : False).elim  -- F_top_deferral is or
    · exact (Formula.noConfusion h_eq : False).elim  -- P_top_deferral is or

/--
For backward compatibility: all_past in deferralClosure excluding H_neg_neg_bot.
-/
theorem all_past_in_deferralClosure_is_in_closureWithNeg (phi psi : Formula)
    (h : Formula.all_past psi ∈ deferralClosure phi)
    (h_not_H : Formula.all_past psi ≠ H_neg_neg_bot) :
    Formula.all_past psi ∈ closureWithNeg phi := by
  rcases all_past_in_deferralClosure_cases phi psi h with h_cwn | h_eq
  · exact h_cwn
  · exact absurd h_eq h_not_H

/--
If G(psi) is in deferralClosure, then psi is in deferralClosure.
-/
theorem deferralClosure_all_future (phi psi : Formula)
    (h : Formula.all_future psi ∈ deferralClosure phi) :
    psi ∈ deferralClosure phi := by
  rcases all_future_in_deferralClosure_cases phi psi h with h_cwn | h_eq_G
  · -- G(psi) ∈ closureWithNeg phi
    unfold closureWithNeg at h_cwn
    simp only [Finset.mem_union, Finset.mem_image] at h_cwn
    rcases h_cwn with h_sub | ⟨g, h_g_sub, h_g_eq⟩
    · exact closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi (closure_all_future phi psi h_sub))
    · cases h_g_eq
  · -- G(psi) = G_neg_neg_bot, so psi = neg_neg_bot
    have h_psi_eq : psi = neg_neg_bot := by
      simp only [G_neg_neg_bot, Formula.all_future] at h_eq_G
      injection h_eq_G
    rw [h_psi_eq]
    exact neg_neg_bot_mem_deferralClosure phi

/--
If H(psi) is in deferralClosure, then psi is in deferralClosure.
-/
theorem deferralClosure_all_past (phi psi : Formula)
    (h : Formula.all_past psi ∈ deferralClosure phi) :
    psi ∈ deferralClosure phi := by
  rcases all_past_in_deferralClosure_cases phi psi h with h_cwn | h_eq_H
  · -- H(psi) ∈ closureWithNeg phi
    unfold closureWithNeg at h_cwn
    simp only [Finset.mem_union, Finset.mem_image] at h_cwn
    rcases h_cwn with h_sub | ⟨g, h_g_sub, h_g_eq⟩
    · exact closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi (closure_all_past phi psi h_sub))
    · cases h_g_eq
  · -- H(psi) = H_neg_neg_bot, so psi = neg_neg_bot
    have h_psi_eq : psi = neg_neg_bot := by
      simp only [H_neg_neg_bot, Formula.all_past] at h_eq_H
      injection h_eq_H
    rw [h_psi_eq]
    exact neg_neg_bot_mem_deferralClosure phi

/--
Any F-formula (some_future) in deferralClosure is either:
1. In closureWithNeg phi, or
2. Equal to F_top (seriality formula)

The original theorem is no longer true because F_top is now in deferralClosure.
-/
theorem some_future_in_deferralClosure_cases (phi chi : Formula)
    (h : Formula.some_future chi ∈ deferralClosure phi) :
    Formula.some_future chi ∈ closureWithNeg phi ∨ Formula.some_future chi = F_top := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with ((h_orig | h_defer_F) | h_defer_P) | h_serial
  · exact Or.inl h_orig
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
  · -- serialityFormulas case
    simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at h_serial
    rcases h_serial with h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq
    · exact Or.inr h_eq  -- F_top
    · -- P_top is not an F-formula (some_future has all_future, P_top has all_past)
      exfalso
      simp only [P_top, Formula.some_past, Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; injection h1
    · -- neg bot is not an F-formula (some_future is imp (all_future _) _, neg bot is imp bot _)
      exfalso
      simp only [Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- neg neg bot is not an F-formula
      exfalso
      simp only [neg_neg_bot, Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- G_neg_neg_bot is all_future, not some_future (imp _ _ vs all_future _)
      exfalso
      simp only [G_neg_neg_bot, Formula.some_future, Formula.neg] at h_eq
      exact Formula.noConfusion h_eq
    · -- H_neg_neg_bot is all_past, not some_future (imp _ _ vs all_past _)
      exfalso
      simp only [H_neg_neg_bot, Formula.some_future, Formula.neg] at h_eq
      exact Formula.noConfusion h_eq
    · -- F_top_deferral is a disjunction, not an F-formula
      exfalso
      simp only [F_top_deferral, Formula.or, Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- P_top_deferral is a disjunction, not an F-formula
      exfalso
      simp only [P_top_deferral, Formula.or, Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1

/--
Any P-formula (some_past) in deferralClosure is either:
1. In closureWithNeg phi, or
2. Equal to P_top (seriality formula)

Symmetric to some_future_in_deferralClosure_cases.
-/
theorem some_past_in_deferralClosure_cases (phi chi : Formula)
    (h : Formula.some_past chi ∈ deferralClosure phi) :
    Formula.some_past chi ∈ closureWithNeg phi ∨ Formula.some_past chi = P_top := by
  unfold deferralClosure at h
  simp only [Finset.mem_union] at h
  rcases h with ((h_orig | h_defer_F) | h_defer_P) | h_serial
  · exact Or.inl h_orig
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
  · -- serialityFormulas case
    simp only [serialityFormulas, Finset.mem_insert, Finset.mem_singleton] at h_serial
    rcases h_serial with h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq | h_eq
    · -- F_top is not a P-formula (some_past has all_past, F_top has all_future)
      exfalso
      simp only [F_top, Formula.some_past, Formula.some_future, Formula.neg] at h_eq
      injection h_eq with h1 _; injection h1
    · exact Or.inr h_eq  -- P_top
    · -- neg bot is not a P-formula (some_past is imp (all_past _) _, neg bot is imp bot _)
      exfalso
      simp only [Formula.some_past, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- neg neg bot is not a P-formula
      exfalso
      simp only [neg_neg_bot, Formula.some_past, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- G_neg_neg_bot is all_future, not some_past (imp _ _ vs all_future _)
      exfalso
      simp only [G_neg_neg_bot, Formula.some_past, Formula.neg] at h_eq
      exact Formula.noConfusion h_eq
    · -- H_neg_neg_bot is all_past, not some_past (imp _ _ vs all_past _)
      exfalso
      simp only [H_neg_neg_bot, Formula.some_past, Formula.neg] at h_eq
      exact Formula.noConfusion h_eq
    · -- F_top_deferral is a disjunction, not a P-formula
      exfalso
      simp only [F_top_deferral, Formula.or, Formula.some_past, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1
    · -- P_top_deferral is a disjunction, not a P-formula
      exfalso
      simp only [P_top_deferral, Formula.or, Formula.some_past, Formula.neg] at h_eq
      injection h_eq with h1 _; exact Formula.noConfusion h1

/--
If F(chi) is in deferralClosure, then chi is in deferralClosure.

This handles both cases:
1. F(chi) ∈ closureWithNeg → chi ∈ subformulaClosure ⊆ deferralClosure
2. F(chi) = F_top → chi = neg bot ∈ serialityFormulas ⊆ deferralClosure
-/
theorem F_inner_in_deferralClosure (phi chi : Formula)
    (h : Formula.some_future chi ∈ deferralClosure phi) :
    chi ∈ deferralClosure phi := by
  rcases some_future_in_deferralClosure_cases phi chi h with h_cwn | h_eq_F_top
  · -- F(chi) ∈ closureWithNeg phi
    have h_chi_sub := some_future_in_closureWithNeg_inner_in_subformulaClosure phi chi h_cwn
    exact closureWithNeg_subset_deferralClosure phi
      (subformulaClosure_subset_closureWithNeg phi h_chi_sub)
  · -- F(chi) = F_top = F(neg bot), so chi = neg bot
    have h_chi_eq : chi = Formula.neg Formula.bot := by
      simp only [F_top, Formula.some_future, Formula.neg] at h_eq_F_top
      -- h_eq_F_top : (chi.imp bot).all_future.imp bot = ((bot.imp bot).imp bot).all_future.imp bot
      injection h_eq_F_top with h_inner _
      injection h_inner with h_all
      injection h_all
    rw [h_chi_eq]
    exact neg_bot_mem_deferralClosure phi

/--
If P(chi) is in deferralClosure, then chi is in deferralClosure.

Symmetric to F_inner_in_deferralClosure.
-/
theorem P_inner_in_deferralClosure (phi chi : Formula)
    (h : Formula.some_past chi ∈ deferralClosure phi) :
    chi ∈ deferralClosure phi := by
  rcases some_past_in_deferralClosure_cases phi chi h with h_cwn | h_eq_P_top
  · -- P(chi) ∈ closureWithNeg phi
    have h_chi_sub := some_past_in_closureWithNeg_inner_in_subformulaClosure phi chi h_cwn
    exact closureWithNeg_subset_deferralClosure phi
      (subformulaClosure_subset_closureWithNeg phi h_chi_sub)
  · -- P(chi) = P_top = P(neg bot), so chi = neg bot
    have h_chi_eq : chi = Formula.neg Formula.bot := by
      simp only [P_top, Formula.some_past, Formula.neg] at h_eq_P_top
      -- h_eq_P_top : (chi.imp bot).all_past.imp bot = ((bot.imp bot).imp bot).all_past.imp bot
      injection h_eq_P_top with h_inner _
      injection h_inner with h_all
      injection h_all
    rw [h_chi_eq]
    exact neg_bot_mem_deferralClosure phi

/--
If F(chi) is in deferralClosure, then chi ∨ F(chi) is in deferralClosure.

This handles both cases:
1. F(chi) ∈ closureWithNeg → deferral ∈ deferralDisjunctionSet ⊆ deferralClosure
2. F(chi) = F_top → deferral = F_top_deferral ∈ serialityFormulas ⊆ deferralClosure
-/
theorem deferral_of_F_in_deferralClosure (phi chi : Formula)
    (h : Formula.some_future chi ∈ deferralClosure phi) :
    Formula.or chi (Formula.some_future chi) ∈ deferralClosure phi := by
  rcases some_future_in_deferralClosure_cases phi chi h with h_cwn | h_eq_F_top
  · -- F(chi) ∈ closureWithNeg phi
    exact deferral_of_F_in_closure phi chi h_cwn
  · -- F(chi) = F_top = F(neg bot), so chi = neg bot
    have h_chi_eq : chi = Formula.neg Formula.bot := by
      simp only [F_top, Formula.some_future, Formula.neg] at h_eq_F_top
      injection h_eq_F_top with h_inner _
      injection h_inner with h_all
      injection h_all
    rw [h_chi_eq]
    -- Formula.or (neg bot) F_top = F_top_deferral
    exact F_top_deferral_mem_deferralClosure phi

/--
If P(chi) is in deferralClosure, then chi ∨ P(chi) is in deferralClosure.

Symmetric to deferral_of_F_in_deferralClosure.
-/
theorem deferral_of_P_in_deferralClosure (phi chi : Formula)
    (h : Formula.some_past chi ∈ deferralClosure phi) :
    Formula.or chi (Formula.some_past chi) ∈ deferralClosure phi := by
  rcases some_past_in_deferralClosure_cases phi chi h with h_cwn | h_eq_P_top
  · -- P(chi) ∈ closureWithNeg phi
    exact deferral_of_P_in_closure phi chi h_cwn
  · -- P(chi) = P_top = P(neg bot), so chi = neg bot
    have h_chi_eq : chi = Formula.neg Formula.bot := by
      simp only [P_top, Formula.some_past, Formula.neg] at h_eq_P_top
      injection h_eq_P_top with h_inner _
      injection h_inner with h_all
      injection h_all
    rw [h_chi_eq]
    -- Formula.or (neg bot) P_top = P_top_deferral
    exact P_top_deferral_mem_deferralClosure phi

/--
Any box formula in deferralClosure is in closureWithNeg.

Box formulas are not imp formulas, so they cannot be deferral disjunctions.
-/
theorem box_in_deferralClosure_is_in_closureWithNeg (phi psi : Formula)
    (h : Formula.box psi ∈ deferralClosure phi) :
    Formula.box psi ∈ closureWithNeg phi :=
  non_imp_in_deferralClosure_is_in_closureWithNeg phi _ h
    (by intro a b; exact Formula.noConfusion)
    (by simp only [G_neg_neg_bot, Formula.all_future]; exact Formula.noConfusion)
    (by simp only [H_neg_neg_bot, Formula.all_past]; exact Formula.noConfusion)

/--
If Box(psi) is in closureWithNeg(phi), then psi is in subformulaClosure(phi).

This is the key closure property for box formulas: the inner formula of any
Box formula in the closure is itself in the (raw) subformula closure.
-/
theorem box_inner_in_subformulaClosure_of_closureWithNeg (phi psi : Formula)
    (h : Formula.box psi ∈ closureWithNeg phi) :
    psi ∈ subformulaClosure phi := by
  unfold closureWithNeg at h
  simp only [Finset.mem_union, Finset.mem_image] at h
  rcases h with h_sub | ⟨g, h_g_sub, h_g_eq⟩
  · -- Box(psi) in subformulaClosure phi
    exact closure_box phi psi h_sub
  · -- Box(psi) = g.neg for some g in subformulaClosure
    -- But g.neg = Formula.imp g Formula.bot, and this cannot equal Formula.box psi
    cases h_g_eq

/--
If Box(psi) is in deferralClosure(phi), then psi is in subformulaClosure(phi).

This combines box_in_deferralClosure_is_in_closureWithNeg and
box_inner_in_subformulaClosure_of_closureWithNeg.
-/
theorem box_inner_in_subformulaClosure_of_deferralClosure (phi psi : Formula)
    (h : Formula.box psi ∈ deferralClosure phi) :
    psi ∈ subformulaClosure phi :=
  box_inner_in_subformulaClosure_of_closureWithNeg phi psi
    (box_in_deferralClosure_is_in_closureWithNeg phi psi h)

/--
If Box(psi) is in deferralClosure(phi), then psi is in closureWithNeg(phi).
-/
theorem box_inner_in_closureWithNeg_of_deferralClosure (phi psi : Formula)
    (h : Formula.box psi ∈ deferralClosure phi) :
    psi ∈ closureWithNeg phi :=
  subformulaClosure_subset_closureWithNeg phi
    (box_inner_in_subformulaClosure_of_deferralClosure phi psi h)

/--
If Box(psi) is in deferralClosure(phi), then psi is in deferralClosure(phi).
-/
theorem box_inner_in_deferralClosure (phi psi : Formula)
    (h : Formula.box psi ∈ deferralClosure phi) :
    psi ∈ deferralClosure phi :=
  closureWithNeg_subset_deferralClosure phi
    (box_inner_in_closureWithNeg_of_deferralClosure phi psi h)

end Bimodal.Syntax
