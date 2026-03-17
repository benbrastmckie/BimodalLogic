import Bimodal.Metalogic.Decidability.FMP.Filtration
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Fintype.Powerset
import Mathlib.Data.Set.Finite.Basic

/-!
# Finiteness Theorem for Filtered Models

This module proves that the filtered model has bounded cardinality.

## Overview

The key insight is that equivalence classes of closure MCS are determined
by their membership on the subformula closure. Since the closure is finite,
there are at most 2^|closure| distinct equivalence classes.

## Main Results

- `FilteredWorld.finite`: The filtered world type is finite
- `FiniteFilteredFrame`: The filtered task frame is finite

## Proof Strategy

1. Each equivalence class is determined by a subset of the closure
2. There are at most 2^|closure| subsets
3. We use the injection principle to prove finiteness

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3)
-/

namespace Bimodal.Metalogic.Decidability.FMP

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core

/-!
## Characteristic Sets

Each closure MCS is determined by which closure formulas it contains.
We represent this as a subset (Set) of the closure.
-/

/--
The characteristic set of a closure MCS: the set of closure formulas it contains.
-/
def characteristicSet (phi : Formula) (S : ClosureMCSBundle phi) :
    Set (subformulaClosure phi) :=
  {x | x.val ∈ S.carrier}

/--
Two closure MCS have the same characteristic set iff they are equivalent.
-/
theorem characteristicSet_eq_iff_equiv (phi : Formula)
    (S T : ClosureMCSBundle phi) :
    characteristicSet phi S = characteristicSet phi T ↔ ClosureMCSEquiv phi S T := by
  constructor
  · intro h_eq ψ hψ
    have h1 : (⟨ψ, hψ⟩ : subformulaClosure phi) ∈ characteristicSet phi S ↔
              (⟨ψ, hψ⟩ : subformulaClosure phi) ∈ characteristicSet phi T := by
      rw [h_eq]
    simp only [characteristicSet, Set.mem_setOf_eq] at h1
    exact h1
  · intro h_equiv
    ext ⟨ψ, hψ⟩
    simp only [characteristicSet, Set.mem_setOf_eq]
    exact h_equiv ψ hψ

/--
The characteristic set respects equivalence.
-/
theorem characteristicSet_respects_equiv (phi : Formula)
    {S T : ClosureMCSBundle phi} (h : ClosureMCSEquiv phi S T) :
    characteristicSet phi S = characteristicSet phi T :=
  (characteristicSet_eq_iff_equiv phi S T).mpr h

/--
Lift characteristic set to filtered worlds.
-/
def filteredCharacteristicSet (phi : Formula) (w : FilteredWorld phi) :
    Set (subformulaClosure phi) :=
  Quotient.lift (characteristicSet phi)
    (fun S T h => characteristicSet_respects_equiv phi h) w

/--
The filtered characteristic set map is injective.
-/
theorem filteredCharacteristicSet_injective (phi : Formula) :
    Function.Injective (filteredCharacteristicSet phi) := by
  intro w v h
  -- Get representatives
  obtain ⟨S, hS⟩ := Quotient.exists_rep w
  obtain ⟨T, hT⟩ := Quotient.exists_rep v
  -- Show they are equivalent
  have h_char : characteristicSet phi S = characteristicSet phi T := by
    simp only [← hS, ← hT, filteredCharacteristicSet] at h
    exact h
  have h_equiv : ClosureMCSEquiv phi S T :=
    (characteristicSet_eq_iff_equiv phi S T).mp h_char
  -- Use quotient exactness
  rw [← hS, ← hT]
  exact Quotient.sound h_equiv

/-!
## Main Finiteness Theorem

The filtered world type is finite.
-/

/--
The subformula closure is a Finset, which gives us a Fintype instance.
-/
instance subformulaClosure_fintype (phi : Formula) :
    Fintype (subformulaClosure phi) :=
  (subformulaClosure phi).fintypeCoeSort

/--
The subformula closure elements form a finite type, so its powerset is also finite.
This uses `Set.instFinite` from Mathlib.Data.Fintype.Powerset.
-/
noncomputable instance set_finite (phi : Formula) :
    Finite (Set (subformulaClosure phi)) := by
  haveI : Finite (subformulaClosure phi) := Finite.of_fintype (subformulaClosure phi)
  exact Set.instFinite

/--
FilteredWorld is finite because it injects into a finite type.
-/
noncomputable instance FilteredWorld.finite (phi : Formula) :
    Finite (FilteredWorld phi) := by
  -- FilteredWorld phi injects into Set (subformulaClosure phi)
  -- which is finite by set_finite
  haveI : Finite (Set (subformulaClosure phi)) := set_finite phi
  exact Finite.of_injective (filteredCharacteristicSet phi)
    (filteredCharacteristicSet_injective phi)

/-!
## Finite Filtered Task Frame

Bundle the filtered frame with its finiteness proof.
-/

variable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
The finite filtered task frame.

This bundles the refined filtered task frame with the proof
that its world states are finite.
-/
noncomputable def FiniteFilteredTaskFrame (phi : Formula) :
    FiniteTaskFrame D where
  toTaskFrame := RefinedFilteredTaskFrame D phi
  finite_world := FilteredWorld.finite phi

/--
The finite filtered frame has the same world state type as the refined frame.
-/
theorem FiniteFilteredTaskFrame.worldState_eq (phi : Formula) :
    (FiniteFilteredTaskFrame D phi).WorldState = FilteredWorld phi :=
  rfl

/-!
## Summary

This module proves:
1. FilteredWorld phi is finite
2. FiniteFilteredTaskFrame bundles the frame with finiteness

The key technique is showing that equivalence classes are determined
by characteristic sets, and these sets form a finite type
(the powerset of a finite set is finite).
-/

end Bimodal.Metalogic.Decidability.FMP
