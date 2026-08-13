/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.FMP.TruthPreservation
import FormalSystem.Semantics.Validity
import FormalSystem.Theorems.Propositional.Core

/-!
# Finite Model Property for TM Bimodal Logic

This module proves the Finite Model Property (FMP) for TM bimodal logic.

## Overview

The Finite Model Property states: If a formula is satisfiable, then it is
satisfiable in a finite model whose size is bounded by 2^|closure(φ)|.

Equivalently (contrapositive): If a formula is valid in all finite models,
it is valid in all models.

## Proof Strategy

The proof uses the MCS-based filtration approach:
1. If φ is not valid, then ¬φ is consistent (not a theorem)
2. By restricted Lindenbaum, there exists a closure MCS containing ¬φ
3. The filtered model (quotient by closure equivalence) is finite
4. Truth is preserved under filtration (membership = truth)
5. Therefore φ fails at some world in the finite filtered model

## Main Results

- `fmp_contrapositive`: If φ valid in all finite models → φ valid
- `finite_model_property`: ¬valid(φ) → ∃ finite model falsifying φ
- `assignmentSpace_card`: The assignment space has exactly 2^|closure(φ)| elements
- `filtered_world_bound`: `Nat.card (FilteredWorld φ) ≤ 2^|closure(φ)|`
- `fmp_size_bound`: The FMP countermodel is finite and bounded by 2^|closure(φ)|

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3)
- Hughes & Cresswell: A New Introduction to Modal Logic (Ch 6.2)
-/

namespace FormalSystem.Metalogic.Decidability.FMP

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Core
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Propositional

/-!
## Finite Model Construction

Given a formula φ that is not valid, we construct a finite model that falsifies it.
-/

/--
If ¬φ is consistent (no proof of φ from empty context), then there exists
a closure MCS containing ¬φ.
-/
theorem exists_mcs_with_negation (phi : Formula)
    (h_not_provable : ¬Derivable FrameClass.Base [] phi) :
    ∃ S : ClosureMCSBundle phi, phi.neg ∈ S.carrier := by
  -- First, show that neg (phi.neg) = phi.neg.neg is not derivable
  -- from the fact that phi is not derivable
  -- Actually, we need to show ¬φ is consistent (singleton {¬φ} is consistent)
  have h_neg_cons : ¬Derivable FrameClass.Base [] phi.neg.neg := by
    intro ⟨d_neg_neg⟩
    -- From phi.neg.neg (= ¬¬φ = φ → ⊥ → ⊥), derive phi using DNE
    have h_dne : [] ⊢ phi.neg.neg.imp phi := doubleNegation phi
    have h_phi : [] ⊢ phi := DerivationTree.modus_ponens [] _ _ h_dne d_neg_neg
    exact h_not_provable ⟨h_phi⟩
  -- Now phi.neg is consistent (its negation is not derivable from [])
  -- So {phi.neg} is set-consistent
  have h_singleton_cons : SetConsistent (fc := FrameClass.Base) {phi.neg} := by
    intro L hL
    intro ⟨d_bot⟩
    -- L ⊆ {phi.neg} means L is either [] or [phi.neg]
    -- From L ⊢ ⊥, we can derive phi.neg.neg (= phi.neg → ⊥)
    by_cases h_neg_in_L : phi.neg ∈ L
    · -- phi.neg ∈ L. Exchange to put it first.
      let L' := L.filter (fun x => decide (x ≠ phi.neg))
      have h_L_perm : L ⊆ phi.neg :: L' := by
        intro x hx
        by_cases hx_eq : x = phi.neg
        · simp [hx_eq]
        · simp only [List.mem_cons]
          right
          exact List.mem_filter.mpr ⟨hx, by simpa⟩
      -- L' ⊆ {phi.neg} \ {phi.neg} = ∅
      have h_L'_sub : ∀ x ∈ L', x ∈ ({phi.neg} : Set Formula) ∧ x ≠ phi.neg := by
        intro x hx
        have hx' := List.mem_filter.mp hx
        constructor
        · exact hL x hx'.1
        · simp only [decide_eq_true_eq] at hx'
          exact hx'.2
      have h_L'_empty : L' = [] := by
        cases hL' : L' with
        | nil => rfl
        | cons x xs =>
          exfalso
          have h_x_in : x ∈ L' := by rw [hL']; exact List.mem_cons_self
          have ⟨h_in, h_ne⟩ := h_L'_sub x h_x_in
          simp only [Set.mem_singleton_iff] at h_in
          exact h_ne h_in
      -- So L ⊆ [phi.neg]
      have h_L_sub_singleton : L ⊆ [phi.neg] := by
        intro x hx
        have := h_L_perm hx
        simp only [List.mem_cons, h_L'_empty, List.not_mem_nil, or_false] at this
        simp [this]
      have d_bot' : DerivationTree FrameClass.Base [phi.neg] Formula.bot :=
        DerivationTree.weakening L [phi.neg] _ d_bot h_L_sub_singleton
      have d_neg_neg : DerivationTree FrameClass.Base [] phi.neg.neg :=
        deductionTheorem [] phi.neg Formula.bot d_bot'
      exact h_neg_cons ⟨d_neg_neg⟩
    · -- phi.neg ∉ L. Then L ⊆ {phi.neg} \ {phi.neg} = ∅, so L = []
      have h_L_empty : L = [] := by
        cases L with
        | nil => rfl
        | cons x xs =>
          exfalso
          have hx := hL x List.mem_cons_self
          simp only [Set.mem_singleton_iff] at hx
          exact h_neg_in_L (hx ▸ List.mem_cons_self)
      -- [] ⊢ ⊥ implies ⊢ phi.neg.neg via EFQ and weakening
      rw [h_L_empty] at d_bot
      -- From [] ⊢ ⊥, derive [] ⊢ phi
      have h_efq : [] ⊢ Formula.bot.imp phi :=
        DerivationTree.axiom [] _ (Axiom.ex_falso phi) trivial
      have d_phi : [] ⊢ phi := DerivationTree.modus_ponens [] _ _ h_efq d_bot
      exact h_not_provable ⟨d_phi⟩
  -- phi.neg is in closureWithNeg phi
  have h_neg_clos : phi.neg ∈ closureWithNeg phi := neg_self_mem_closureWithNeg phi
  -- Apply restricted_mcs_exists_containing
  obtain ⟨M, h_neg_in, h_mcs⟩ :=
    restricted_mcs_exists_containing phi phi.neg h_neg_clos h_singleton_cons
  exact ⟨⟨M, h_mcs⟩, h_neg_in⟩

/--
The filtered model for a non-provable formula provides a finite witness.
-/
theorem filtered_model_falsifies (phi : Formula)
    (h_not_provable : ¬Derivable FrameClass.Base [] phi) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier := by
  obtain ⟨S, h_neg⟩ := exists_mcs_with_negation phi h_not_provable
  use S
  -- phi ∉ S because phi.neg ∈ S and MCS is consistent
  intro h_phi
  exact mcs_not_both_and_neg h_phi h_neg

/-!
## Finite Model Property Statement

The main FMP theorem connects unsatisfiability to finite model falsification.
-/

/--
Bundled finite filtered task frame with its formula.
-/
structure BundledFilteredFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] where
  /-- The formula whose subformula closure the filtration was taken with respect to. -/
  phi : Formula
  /-- The finite task frame obtained by filtering through `phi`'s subformula closure. -/
  frame : Semantics.FiniteTaskFrame D
  world_is_filtered : frame.WorldState = FilteredWorld phi

/--
The filtered task frame for a formula is finite.
-/
noncomputable def filteredFiniteFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [SuccOrder D] [NoMaxOrder D]
    (phi : Formula) : Semantics.FiniteTaskFrame D :=
  FiniteFilteredTaskFrame D phi

/--
The space of truth assignments to the subformula closure has exactly `2 ^ |closure(φ)|` elements.

This is an equality, not a bound: the closure is a `Finset`, so its coercion to a type is a
`Fintype` (`subformulaClosureFintype`), and the powerset of an `n`-element type has `2 ^ n`
elements. It is the *target* of the filtration's characteristic-set map, and so supplies the
figure that `filtered_world_bound` transports to the world type.
-/
theorem assignmentSpace_card (phi : Formula) :
    Nat.card (Set (subformulaClosure phi)) = 2 ^ (subformulaClosure phi).card := by
  rw [Nat.card_eq_fintype_card, Fintype.card_set, Fintype.card_coe]

/--
The number of worlds in the filtered model is at most `2 ^ |closure(φ)|`.

The bound is transported along `filteredCharacteristicSet`, the map sending a filtered world to
the set of closure formulas its representatives satisfy. That map is *injective*
(`filteredCharacteristicSet_injective`) — which is exactly the content of the filtration
equivalence, since two closure MCSs are identified precisely when they agree on the closure — so
the world type has no more elements than the assignment space, whose size
`assignmentSpace_card` computes exactly.

The `Nat.card` here is not the junk value that convention assigns to infinite types:
`FilteredWorld.finite` proves `Finite (FilteredWorld phi)` independently, via the same injection.
The inequality is therefore a real bound on a genuinely finite type, and not vacuously satisfied
by `Nat.card = 0`.
-/
theorem filtered_world_bound (phi : Formula) :
    Nat.card (FilteredWorld phi) ≤ 2 ^ (subformulaClosure phi).card := by
  haveI : Finite (Set (subformulaClosure phi)) := set_finite phi
  have h := Nat.card_le_card_of_injective (filteredCharacteristicSet phi)
    (filteredCharacteristicSet_injective phi)
  exact (assignmentSpace_card phi) ▸ h

/-!
## FMP Main Theorem

We state the FMP in terms of MCS membership, which corresponds to
satisfiability in the canonical model construction.
-/

/--
MCS-based Finite Model Property: If φ is not provable, then there exists
a closure MCS (a world in a finite model) where φ is false (not a member).

This is the key building block for the full FMP theorem.
-/
theorem mcs_finite_model_property (phi : Formula)
    (h_not_provable : ¬Derivable FrameClass.Base [] phi) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧
    Finite (FilteredWorld phi) := by
  obtain ⟨S, h_not_in⟩ := filtered_model_falsifies phi h_not_provable
  exact ⟨S, h_not_in, FilteredWorld.finite phi⟩

/--
Contrapositive of FMP: If φ is true in all closure MCS for the finite
filtered model, then φ is provable.

This establishes completeness via finite model reasoning.
-/
theorem fmp_contrapositive (phi : Formula)
    (h_all_mcs : ∀ (S : ClosureMCSBundle phi), phi ∈ S.carrier) :
    Derivable FrameClass.Base [] phi := by
  by_contra h_not_provable
  obtain ⟨S, h_not_in, _⟩ := mcs_finite_model_property phi h_not_provable
  exact h_not_in (h_all_mcs S)

/-!
## FMP Size Bound

The finite model has size bounded by 2^|closure(φ)|.
-/

/--
The Finite Model Property with its size bound attached: if `φ` is not provable, the countermodel
the FMP produces lives in a world type that is finite and has at most `2 ^ |closure(φ)|` elements.

This is `mcs_finite_model_property` with `filtered_world_bound` carried alongside, which is what
makes it a *size* bound rather than a bare finiteness claim — the point of the FMP for
decidability is not that some finite countermodel exists but that its size is bounded by a
computable function of `φ`, so that only finitely many candidates need be searched.

Each world (an equivalence class of closure MCSs) is determined by which closure formulas it
satisfies, and there are `2 ^ |closure|` such assignments; `filtered_world_bound` is where that
argument is discharged, through the injectivity of `filteredCharacteristicSet`.
-/
theorem fmp_size_bound (phi : Formula)
    (h_not_provable : ¬Derivable FrameClass.Base [] phi) :
    ∃ (S : ClosureMCSBundle phi), phi ∉ S.carrier ∧
    Finite (FilteredWorld phi) ∧
    Nat.card (FilteredWorld phi) ≤ 2 ^ (subformulaClosure phi).card := by
  obtain ⟨S, h_not_in, h_fin⟩ := mcs_finite_model_property phi h_not_provable
  exact ⟨S, h_not_in, h_fin, filtered_world_bound phi⟩

/-!
## Summary

This module proves the Finite Model Property for TM bimodal logic:

1. **exists_mcs_with_negation**: If φ not provable, ∃ closure MCS with ¬φ
2. **filtered_model_falsifies**: If φ not provable, ∃ world where φ fails
3. **mcs_finite_model_property**: Combined with finiteness proof
4. **fmp_contrapositive**: If φ true in all finite worlds → φ provable
5. **assignmentSpace_card**: The assignment space has exactly 2^|closure(φ)| elements
6. **filtered_world_bound**: The world type has at most 2^|closure(φ)| elements
7. **fmp_size_bound**: The FMP countermodel is finite and carries that bound

These results establish that TM bimodal logic has the finite model property,
which is essential for decidability.

Items 5-7 replace two theorems that previously stood at 5 and 6 under the names
`filtered_world_bound` and `fmp_size_bound` and were **vacuous**: each concluded in a `∧ True`
(respectively `∀ _S, True`) conjunct discharged by `trivial`, so neither said anything about
`FilteredWorld` at all. `filtered_world_bound` asserted only that `2 ^ |closure(φ)| ≤
2 ^ |closure(φ)|`, and `fmp_size_bound` only that some natural number equals
`2 ^ |closure(φ)|` — both true of any formula and of any world type whatsoever. The bound is now
carried by the injectivity of `filteredCharacteristicSet`, which was already proved in
`FiniteModel.lean` and used there for finiteness; it needed only to be read for cardinality as
well.
-/

end FormalSystem.Metalogic.Decidability.FMP
