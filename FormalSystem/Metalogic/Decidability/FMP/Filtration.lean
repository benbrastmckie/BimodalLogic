/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.FMP.ClosureMCS
import FormalSystem.Metalogic.Soundness
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.Truth
import Mathlib.Data.Setoid.Basic
import Mathlib.Data.Fintype.Quotient

/-!
# Filtration Construction for FMP

This module defines the filtration equivalence and quotient model construction
for the Finite Model Property (FMP).

## Overview

Filtration is a technique to construct finite models from infinite ones:
1. Define equivalence: w ≡_φ v iff they agree on truth of all closure formulas
2. Take quotient of world states by this equivalence
3. Define filtered accessibility as lifting of original accessibility
4. Show the filtered model is finite (bounded by 2^|closure φ|)

## Main Definitions

- `MCSFiltrationEquiv`: Equivalence relation based on membership agreement on closure
- `ClosureMCSSetoid`: The setoid structure for quotient construction
- `FilteredWorld`: Quotient type of closure MCS under filtration equivalence
- `FilteredTaskFrame`: Task frame on filtered worlds

## Approach

For TM bimodal logic, we use an MCS-based filtration approach:
- "Worlds" are closure MCS (restricted to subformula closure)
- Equivalence is agreement on which closure formulas are in the MCS
- This directly relates to canonical model construction

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3 Filtrations)
- Hughes & Cresswell: A New Introduction to Modal Logic (Ch 6.2)
-/

namespace FormalSystem.Metalogic.Decidability.FMP

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Core
open FormalSystem.ProofSystem

/-!
## MCS-Based Filtration Equivalence

Two closure MCS are equivalent if they contain exactly the same
formulas from the subformula closure.
-/

/--
MCS-based filtration equivalence.

Two sets are equivalent if they agree on membership for all
formulas in the subformula closure.
-/
def MCSFiltrationEquiv (phi : Formula) (S T : Set Formula) : Prop :=
  ∀ ψ ∈ subformulaClosure phi, (ψ ∈ S ↔ ψ ∈ T)

/--
MCS filtration equivalence is reflexive.
-/
theorem mcs_filtration_equiv_refl (phi : Formula) (S : Set Formula) :
    MCSFiltrationEquiv phi S S := by
  intro ψ _
  rfl

/--
MCS filtration equivalence is symmetric.
-/
theorem mcs_filtration_equiv_symm (phi : Formula) {S T : Set Formula}
    (h : MCSFiltrationEquiv phi S T) :
    MCSFiltrationEquiv phi T S := by
  intro ψ hψ
  exact (h ψ hψ).symm

/--
MCS filtration equivalence is transitive.
-/
theorem mcs_filtration_equiv_trans (phi : Formula) {S T U : Set Formula}
    (h1 : MCSFiltrationEquiv phi S T) (h2 : MCSFiltrationEquiv phi T U) :
    MCSFiltrationEquiv phi S U := by
  intro ψ hψ
  exact (h1 ψ hψ).trans (h2 ψ hψ)

/--
MCS filtration equivalence is an equivalence relation.
-/
theorem mcs_filtration_equiv_equivalence (phi : Formula) :
    Equivalence (MCSFiltrationEquiv phi) :=
  ⟨mcs_filtration_equiv_refl phi,
   fun h => mcs_filtration_equiv_symm phi h,
   fun h1 h2 => mcs_filtration_equiv_trans phi h1 h2⟩

/--
The setoid for MCS filtration.
-/
def MCSFiltrationSetoid (phi : Formula) : Setoid (Set Formula) where
  r := MCSFiltrationEquiv phi
  iseqv := mcs_filtration_equiv_equivalence phi

/-!
## Closure MCS Bundle

A closure MCS bundled with its proof of maximality.
-/

/--
A closure MCS bundled with its proof.
-/
structure ClosureMCSBundle (phi : Formula) (fc : FrameClass := FrameClass.Base) where
  /-- The underlying set of formulas -/
  carrier : Set Formula
  /-- Proof that the carrier is a closure MCS at frame class `fc` -/
  is_mcs : ClosureMCS phi carrier fc

variable {fc : FrameClass}

/--
Filtration equivalence on bundled closure MCS.
-/
def ClosureMCSEquiv (phi : Formula) (S T : ClosureMCSBundle phi fc) : Prop :=
  MCSFiltrationEquiv phi S.carrier T.carrier

/--
ClosureMCS equivalence is an equivalence relation.
-/
theorem closure_mcs_equiv_equivalence (phi : Formula) :
    Equivalence (ClosureMCSEquiv (fc := fc) phi) :=
  ⟨fun S => mcs_filtration_equiv_refl phi S.carrier,
   fun h => mcs_filtration_equiv_symm phi h,
   fun h1 h2 => mcs_filtration_equiv_trans phi h1 h2⟩

/--
Setoid for closure MCS.
-/
def ClosureMCSSetoid (phi : Formula)
    (fc : FrameClass := FrameClass.Base) : Setoid (ClosureMCSBundle phi fc) where
  r := ClosureMCSEquiv phi
  iseqv := closure_mcs_equiv_equivalence phi

/-!
## Filtered World Type
-/

/--
Filtered world type: quotient of closure MCS bundles by equivalence.

Each equivalence class represents a "world" in the filtered model.
The number of equivalence classes is bounded by 2^|subformulaClosure phi|.
-/
def FilteredWorld (phi : Formula) (fc : FrameClass := FrameClass.Base) : Type :=
  Quotient (ClosureMCSSetoid phi fc)

/--
Quotient map: lift a closure MCS bundle to its equivalence class.
-/
def toFilteredWorld (phi : Formula) (S : ClosureMCSBundle phi fc) : FilteredWorld phi fc :=
  Quotient.mk (ClosureMCSSetoid phi fc) S

/-!
### Nonemptiness of the filtered world type

`FilteredWorld phi` is inhabited for **every** `phi`, with no consistency side condition on
`phi` itself: the witness comes from Lindenbaum-extending the *empty* set within the closure,
which needs only that the logic itself is consistent. `Finite (FilteredWorld phi)`
(`FiniteModel.lean`) is a genuinely different fact and does not imply this one.
-/

/--
The empty set of formulas is consistent at any frame class whose system is consistent.

The only list all of whose members lie in `∅` is `[]`, so the obligation collapses to
`¬ Derivable fc [] ⊥` — the consistency of the system at `fc`, which is exactly the hypothesis.

Consistency of the system is genuinely a per-frame-class fact and cannot be discharged
uniformly in `fc`: it is read off a soundness theorem for `fc`, and the tree currently proves
one for `FrameClass.Base` (`not_derivable_nil_bot`) and for `FrameClass.Discrete`
(`not_derivable_nil_bot_discrete`). Hence the hypothesis rather than a `{fc}`-uniform statement.
-/
theorem setConsistent_empty_of {fc : FrameClass}
    (h : ¬ Derivable fc ([] : Context) Formula.bot) :
    SetConsistent (fc := fc) (∅ : Set Formula) := by
  intro L hL
  have hnil : L = [] := by
    cases L with
    | nil => rfl
    | cons a _ => exact absurd (hL a (by simp)) (by simp)
  subst hnil
  exact h

/--
The empty set of formulas is consistent at `FrameClass.Base`.

**Why `Base` is essential here**: this is the `fc := FrameClass.Base` instance of
`setConsistent_empty_of`, and the consistency witness it consumes
(`Metalogic/Soundness.lean`'s `not_derivable_nil_bot`) is a theorem about the base system
specifically. The `{fc}`-uniform statement is `setConsistent_empty_of`.
-/
theorem setConsistent_empty :
    SetConsistent (fc := ProofSystem.FrameClass.Base) (∅ : Set Formula) :=
  setConsistent_empty_of FormalSystem.Metalogic.not_derivable_nil_bot

/--
Every formula has at least one closure MCS: Lindenbaum-extend `∅` within `closureWithNeg phi`.

The extension lemma is `closure_mcs_extension` (`ClosureMCS.lean`), whose two hypotheses are
`ClosureRestricted phi ∅` (immediate) and `SetConsistent ∅` (`setConsistent_empty` above).
-/
theorem closureMCSBundle_nonempty_of {fc : FrameClass}
    (h : ¬ Derivable fc ([] : Context) Formula.bot) (phi : Formula) :
    Nonempty (ClosureMCSBundle phi fc) := by
  obtain ⟨M, _, hM⟩ :=
    closure_mcs_extension phi ∅ (Set.empty_subset _) (setConsistent_empty_of h)
  exact ⟨⟨M, hM⟩⟩

/--
Every formula has at least one `FrameClass.Base` closure MCS.

**Why `Base` is essential here**: this is the `fc := FrameClass.Base` instance of
`closureMCSBundle_nonempty_of`; it inherits the base-system consistency witness from
`setConsistent_empty`. The `{fc}`-uniform statement is `closureMCSBundle_nonempty_of`, which
also applies at `FrameClass.Discrete` via `not_derivable_nil_bot_discrete`.
-/
theorem closureMCSBundle_nonempty (phi : Formula) : Nonempty (ClosureMCSBundle phi) :=
  closureMCSBundle_nonempty_of FormalSystem.Metalogic.not_derivable_nil_bot phi

/--
The filtered world type is nonempty: push `closureMCSBundle_nonempty` through the quotient map.

This is what lets the filtration frames satisfy a world-state nonemptiness requirement without
assuming anything about `phi`.

**Why `Base` is essential here**: an `instance` cannot carry the per-frame-class consistency
hypothesis that `closureMCSBundle_nonempty_of` needs, so the instance is registered at the one
frame class whose consistency is available unconditionally at this point in the import graph.
At another `fc`, apply `(closureMCSBundle_nonempty_of h phi).map (toFilteredWorld phi)` directly.
-/
instance filteredWorld_nonempty (phi : Formula) : Nonempty (FilteredWorld phi) :=
  (closureMCSBundle_nonempty phi).map (toFilteredWorld phi)

/-!
## Filtered Task Frame

We construct a task frame on the filtered worlds.

For the FMP construction, we use the "largest filtration" where
the task relation is universal. This ensures:
1. The frame axioms hold trivially
2. Truth preservation for box/diamond follows from MCS properties
3. The model is finite (as required)

A more refined "smallest filtration" could be used for preserving
additional frame properties (reflexivity, transitivity, etc.).
-/

variable (D : TemporalOrder)

/--
Refined filtered task relation.

At duration 0: relate only identical equivalence classes
At non-zero duration: universal relation
-/
def refinedFilteredTaskRel (phi : Formula)
    (w : FilteredWorld phi) (d : D) (u : FilteredWorld phi) : Prop :=
  if d = 0 then w = u else True

/--
The refined filtered task frame with proper nullity_identity.

**Discrete duration types only.** `[SuccOrder ↑D] [NoMaxOrder ↑D]` is a genuine restriction, not
bookkeeping: the relation is universal above duration zero, so over a *dense* `D` every filtered
world sits in every cone of every other one (for any radius `x > 0` pick `y ≠ 0` with `|y| < x`)
and the paper's *Limit* axiom (`def:frame#Limit`, verbatim:
"$\bigcap\limits_{x > 0} (w)_x = \set{w}$") collapses outright. Over a discrete `D` the axiom is
restored, because `|y| < Order.succ 0` forces `y = 0` — this is exactly what
`ParamTaskFrame.limit_of_succOrder` proves. `ParamTaskFrame.exists_uniform_radius_of_finite` records the
same fact from the other side: a *finite* frame satisfying *Limit* over a dense duration type is
temporally rigid, so the filtration and FMP frames cannot both be finite and dense-polymorphic.
The restriction is therefore forced by the axiom rather than adopted for convenience.

Every consumer of this frame — `FiniteFilteredTaskFrame`, `FiniteFilteredTaskFrame.worldState_eq`,
and `filteredFiniteFrame` — is itself polymorphic in `D` and carries the same two instances; none
elaborates at a dense duration type, and nothing outside `FMP/` refers to any of them.
-/
noncomputable def RefinedFilteredTaskFrame [SuccOrder ↑D] [NoMaxOrder ↑D]
    (phi : Formula) : FrameOver D where
  WorldState := FilteredWorld phi
  worldNonempty := filteredWorld_nonempty phi
  TaskRel := refinedFilteredTaskRel D phi
  nullity_identity := by
    intro w u
    simp only [refinedFilteredTaskRel]
    constructor
    · intro h
      simp only [↓reduceIte] at h
      exact h
    · intro h
      simp [h]
  comp := TaskFrame.comp_of
    (ParamTaskFrame.interpolates_of_permissive fun w d u => by
      by_cases hd : d = 0 <;> simp [refinedFilteredTaskRel, hd])
    (by
      intro w u v x y hx hy h_wu h_uv
      simp only [refinedFilteredTaskRel] at *
      by_cases hxy : x + y = 0
      · -- x + y = 0 with x ≥ 0 and y ≥ 0 implies x = 0 and y = 0
        simp only [hxy, ↓reduceIte]
        -- In an ordered additive group, if x ≥ 0 and y ≥ 0 and x + y = 0, then x = y = 0
        have hx0 : x = 0 := by
          have h_sum := add_nonneg hx hy
          rw [hxy] at h_sum
          -- 0 ≤ x, x + y = 0, 0 ≤ y means x = 0
          have h1 : y = -x := (neg_eq_of_add_eq_zero_right hxy).symm
          rw [h1] at hy
          have h2 : 0 ≤ -x := hy
          have h3 : x ≤ 0 := neg_nonneg.mp h2
          exact le_antisymm h3 hx
        have hy0 : y = 0 := by
          have h1 : y = -x := (neg_eq_of_add_eq_zero_right hxy).symm
          rw [hx0] at h1
          simp only [neg_zero] at h1
          exact h1
        simp [hx0] at h_wu
        simp only [hy0, ↓reduceIte] at h_uv
        exact h_wu.trans h_uv
      · simp [hxy])
  serial := ParamTaskFrame.serial_of_permissive fun w d u => by
    by_cases hd : d = 0 <;> simp [refinedFilteredTaskRel, hd]
  limit := ParamTaskFrame.limit_of_permissive fun w d u => by
    by_cases hd : d = 0 <;> simp [refinedFilteredTaskRel, hd]
  spherical := ParamTaskFrame.spherical_of_permissive fun w d u => by
    by_cases hd : d = 0 <;> simp [refinedFilteredTaskRel, hd]
  converse := by
    intro w d u
    simp only [refinedFilteredTaskRel]
    constructor
    · intro h
      by_cases hd : d = 0
      · simp only [hd, ↓reduceIte, neg_zero] at h ⊢
        exact h.symm
      · have hnd : -d ≠ 0 := by simp [hd]
        simp only [↓reduceIte, hnd]
    · intro h
      by_cases hd : d = 0
      · simp only [hd, neg_zero, ↓reduceIte] at h ⊢
        exact h.symm
      · have hnd : -d ≠ 0 := by simp [hd]
        simp only [hd, ↓reduceIte, hnd] at h ⊢

/-! ### `RefinedFilteredTaskFrame` discharges `def:frame`'s four axioms

`refinedFilteredTaskRel` — `if d = 0 then w = u else True` — is the *permissive* relation class
of `TaskFrame.lean`'s Helper B, spelled with an `if` rather than a disjunction. Once that is
recorded (`RefinedFilteredTaskFrame_rel_iff`), all four axioms follow from the reusable helpers:
*Seriality*, interpolation, and *Spherical* unconditionally, and *Limit* from this frame's
`[SuccOrder ↑D] [NoMaxOrder ↑D]` restriction. -/

/-- The refined filtered relation is the permissive class: the `if`-form
`if d = 0 then w = u else True` and the disjunctive form `d ≠ 0 ∨ w = u` are the same
proposition. -/
theorem RefinedFilteredTaskFrame_rel_iff [SuccOrder ↑D] [NoMaxOrder ↑D] (phi : Formula) :
    ∀ w d u, (RefinedFilteredTaskFrame D phi).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := by
  intro w d u
  by_cases hd : d = 0 <;> simp [RefinedFilteredTaskFrame, refinedFilteredTaskRel, hd]

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for the refined filtered frame, via the `w = u` disjunct. -/
theorem RefinedFilteredTaskFrame_serial [SuccOrder ↑D] [NoMaxOrder ↑D] (phi : Formula) :
    TaskFrame.Serial (RefinedFilteredTaskFrame D phi).TaskRel :=
  ParamTaskFrame.serial_of_permissive (RefinedFilteredTaskFrame_rel_iff D phi)

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for the refined filtered frame. -/
theorem RefinedFilteredTaskFrame_interpolates [SuccOrder ↑D] [NoMaxOrder ↑D] (phi : Formula) :
    TaskFrame.Interpolates (RefinedFilteredTaskFrame D phi).TaskRel :=
  ParamTaskFrame.interpolates_of_permissive (RefinedFilteredTaskFrame_rel_iff D phi)

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for the
refined filtered frame, in the literal transcribed shape. This is the axiom the frame's
`[SuccOrder ↑D] [NoMaxOrder ↑D]` restriction exists to make provable; see the frame's docstring
for why the restriction is not removable. -/
theorem RefinedFilteredTaskFrame_limit [SuccOrder ↑D] [NoMaxOrder ↑D] (phi : Formula) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (RefinedFilteredTaskFrame D phi).TaskRel w y u) → u = w :=
  ParamTaskFrame.limit_of_permissive (RefinedFilteredTaskFrame_rel_iff D phi)

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for the refined
filtered frame: every nonempty fiber and segment is the whole carrier (above duration zero) or a
singleton (at zero), and a directed family cannot contain two distinct singletons. Unlike
*Limit*, this needs no restriction on `D`. -/
theorem RefinedFilteredTaskFrame_spherical [SuccOrder ↑D] [NoMaxOrder ↑D] (phi : Formula) :
    TaskFrame.Spherical (RefinedFilteredTaskFrame D phi).TaskRel :=
  ParamTaskFrame.spherical_of_permissive (RefinedFilteredTaskFrame_rel_iff D phi)

/-!
## Equivalence Class Representatives

For working with filtered worlds, we often need to extract representatives.
-/

/--
Every filtered world has a representative closure MCS.
-/
theorem filtered_world_has_rep (phi : Formula) (w : FilteredWorld phi fc) :
    ∃ S : ClosureMCSBundle phi fc, toFilteredWorld phi S = w := by
  exact Quotient.exists_rep w

/--
Lift a property from representatives to the quotient (if it respects equivalence).
-/
theorem filtered_world_lift_prop (phi : Formula)
    (P : ClosureMCSBundle phi fc → Prop)
    (h_resp : ∀ S T : ClosureMCSBundle phi fc, ClosureMCSEquiv phi S T → (P S ↔ P T))
    (w : FilteredWorld phi fc) :
    (∀ S : ClosureMCSBundle phi fc, toFilteredWorld phi S = w → P S) ↔
    (∃ S : ClosureMCSBundle phi fc, toFilteredWorld phi S = w ∧ P S) := by
  constructor
  · intro h_all
    obtain ⟨S, hS⟩ := filtered_world_has_rep phi w
    exact ⟨S, hS, h_all S hS⟩
  · intro ⟨S, hS, hPS⟩ T hT
    have h_eq : toFilteredWorld phi S = toFilteredWorld phi T := hS.trans hT.symm
    have h_equiv : ClosureMCSEquiv phi S T := Quotient.exact h_eq
    exact (h_resp S T h_equiv).mp hPS

/-!
## Formula Membership in Filtered Worlds

A key property: membership of closure formulas is well-defined on equivalence classes.
-/

/--
Formula membership in a closure MCS respects filtration equivalence
(for formulas in the closure).
-/
theorem formula_mem_respects_equiv (phi ψ : Formula) (hψ : ψ ∈ subformulaClosure phi)
    {S T : ClosureMCSBundle phi fc} (h : ClosureMCSEquiv phi S T) :
    ψ ∈ S.carrier ↔ ψ ∈ T.carrier :=
  h ψ hψ

/--
Lift formula membership to filtered worlds (for closure formulas).
-/
def filteredWorldMem (phi ψ : Formula) (hψ : ψ ∈ subformulaClosure phi)
    (w : FilteredWorld phi fc) : Prop :=
  Quotient.lift (fun S => ψ ∈ S.carrier)
    (fun _S _T h => propext (formula_mem_respects_equiv phi ψ hψ h)) w

/--
Filtered world membership agrees with representative membership.
-/
theorem filteredWorldMem_iff (phi ψ : Formula) (hψ : ψ ∈ subformulaClosure phi)
    (S : ClosureMCSBundle phi fc) :
    filteredWorldMem phi ψ hψ (toFilteredWorld phi S) ↔ ψ ∈ S.carrier := by
  simp only [filteredWorldMem, toFilteredWorld]
  rfl

/-!
## Summary

This module provides:
1. MCS-based filtration equivalence
2. Closure MCS bundle type with setoid structure
3. Filtered world type as quotient
4. Refined filtered task frame with proper nullity_identity
5. Formula membership lifted to filtered worlds

Next phases will prove:
- Phase 3: Finiteness of FilteredWorld
- Phase 4: Truth preservation (Filtration Lemma)
-/

end FormalSystem.Metalogic.Decidability.FMP
