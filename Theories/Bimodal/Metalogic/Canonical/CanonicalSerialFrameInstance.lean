/-
Copyright (c) 2025-2026 Benjamin Bumpus. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Bumpus, Claude
-/
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
import Bimodal.Metalogic.Canonical.ConstructiveFragment

/-!
# Serial Frame Instances for ConstructiveQuotient

This file provides `NoMaxOrder` and `NoMinOrder` instances for `ConstructiveQuotient`,
establishing that the quotient has no maximum or minimum elements.

## Main Results

- `NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀)`: Every element has a strictly greater element
- `NoMinOrder (ConstructiveQuotient M₀ h_mcs₀)`: Every element has a strictly lesser element

## Design Note

These instances are defined in a separate file to avoid an elaboration-order conflict
that occurs when `ConstructiveFragment.lean` imports `CanonicalIrreflexivityAxiom`.
The separation also foreshadows task 978's `SerialFrame` typeclass architecture.
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## NoMaxOrder Instance

Every element of the constructive quotient has a strictly greater element.
The proof uses forward seriality (`F(¬⊥) ∈ M` for every MCS M) to construct
a successor, then shows strictness via `canonicalR_strict`.
-/

instance : NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_gt a := by
    induction a using Quotient.ind with | _ w =>
    -- Get seriality witness: F(¬⊥) ∈ w.val
    have h_F := SetMaximalConsistent.contains_seriality_future w.val w.is_mcs
    -- Execute forward step to get successor MCS
    let N := executeForwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_F
    have h_N_mcs := executeForwardStep_mcs (h_mcs := w.is_mcs) (h_F := h_F)
    have h_R := executeForwardStep_canonicalR (h_mcs := w.is_mcs) (h_F := h_F)
    -- Strictness: CanonicalR w.val N but ¬CanonicalR N w.val
    have h_strict : ¬CanonicalR N w.val :=
      canonicalR_strict w.val N w.is_mcs h_N_mcs h_R
    -- Build reachability for N (N is forward-reachable from w)
    obtain ⟨h_reach⟩ := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M₀ h_mcs₀ N) :=
      ⟨ConstructiveReachable.forward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_F⟩
    -- Construct the successor element in the fragment
    let w' : ConstructiveFragment M₀ h_mcs₀ := ⟨N, h_N_reach⟩
    use toAntisymmetrization (· ≤ ·) w'
    -- Show w < w' in the quotient
    -- The goal is ⟦w⟧ < toAntisymmetrization w', which by definition of < on quotients
    -- is equivalent to w ≤ w' ∧ ¬(w' ≤ w)
    constructor
    · -- w ≤ w': by CanonicalR w.val N
      exact Or.inr h_R
    · -- w' ≰ w: neither w'.val = w.val nor CanonicalR N w.val
      intro h_le_back
      cases h_le_back with
      | inl h_eq =>
        -- h_eq : w'.val = w.val, and since w'.val = N definitionally
        -- and h_R : CanonicalR w.val N, we get CanonicalR w.val w.val
        have h_R' : CanonicalR w.val w.val := by
          convert h_R using 2
          exact h_eq.symm
        exact canonicalR_irreflexive w.val w.is_mcs h_R'
      | inr h_R_back => exact h_strict h_R_back

/-!
## NoMinOrder Instance

Every element of the constructive quotient has a strictly lesser element.
The proof uses backward seriality (`P(¬⊥) ∈ M` for every MCS M) to construct
a predecessor, then shows strictness via `canonicalR_strict`.
-/

instance : NoMinOrder (ConstructiveQuotient M₀ h_mcs₀) where
  exists_lt a := by
    induction a using Quotient.ind with | _ w =>
    -- Get seriality witness: P(¬⊥) ∈ w.val
    have h_P := SetMaximalConsistent.contains_seriality_past w.val w.is_mcs
    -- Execute backward step to get predecessor MCS
    let N := executeBackwardStep w.val w.is_mcs (Formula.neg Formula.bot) h_P
    have h_N_mcs := executeBackwardStep_mcs (h_mcs := w.is_mcs) (h_P := h_P)
    have h_R := executeBackwardStep_canonicalR (h_mcs := w.is_mcs) (h_P := h_P)
    -- h_R : CanonicalR N w.val (N is predecessor of w)
    -- Strictness: CanonicalR N w.val but ¬CanonicalR w.val N
    have h_strict : ¬CanonicalR w.val N :=
      canonicalR_strict N w.val h_N_mcs w.is_mcs h_R
    -- Build reachability for N (N is backward-reachable from w)
    obtain ⟨h_reach⟩ := w.property
    have h_N_reach : Nonempty (ConstructiveReachable M₀ h_mcs₀ N) :=
      ⟨ConstructiveReachable.backward_witness w.val (Formula.neg Formula.bot) h_reach w.is_mcs h_P⟩
    -- Construct the predecessor element in the fragment
    let w' : ConstructiveFragment M₀ h_mcs₀ := ⟨N, h_N_reach⟩
    use toAntisymmetrization (· ≤ ·) w'
    -- Show w' < w in the quotient
    -- The goal is toAntisymmetrization w' < ⟦w⟧, which by definition of < on quotients
    -- is equivalent to w' ≤ w ∧ ¬(w ≤ w')
    constructor
    · -- w' ≤ w: by CanonicalR N w.val (i.e., CanonicalR w'.val w.val)
      exact Or.inr h_R
    · -- w ≰ w': neither w.val = w'.val nor CanonicalR w.val N
      intro h_le_back
      cases h_le_back with
      | inl h_eq =>
        -- h_eq : w.val = w'.val (i.e., w.val = N), and h_R : CanonicalR N w.val
        -- Substituting gives CanonicalR N N, contradicting irreflexivity
        have h_R' : CanonicalR N N := by
          convert h_R using 1
          exact h_eq.symm
        exact canonicalR_irreflexive N h_N_mcs h_R'
      | inr h_R_back => exact h_strict h_R_back

end Bimodal.Metalogic.Canonical
