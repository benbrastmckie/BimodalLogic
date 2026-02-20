import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.Completeness
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity
import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.Theorems.Propositional

/-!
# Standard Representation and Completeness via BMCS

This module bridges the gap between the BMCS (Bundle of Maximal Consistent Sets)
completeness results and the standard semantic definitions from `Semantics/`.

## Overview

The existing BMCS completeness chain proves completeness with respect to `bmcs_truth_at`,
a Henkin-style truth predicate that quantifies box over bundle families. This module
constructs a standard `TaskFrame`, `TaskModel`, and `WorldHistory` from a BMCS, then
proves a truth lemma connecting MCS membership to the standard `truth_at` predicate.

## Key Construction (Task 910 Reconstruction)

Given a consistent context and a fully saturated BMCS `B`:
- **canonicalFrame B**: A `TaskFrame Int` with `WorldState` restricted to bundle MCS
  at any time, `task_rel = fun _ _ _ => True` (trivial task relation)
- **canonicalModel B**: A `TaskModel` with `valuation w p = (Formula.atom p ∈ w.val)`
- **canonicalHistory B fam**: A `WorldHistory` for each family, with universal domain
  and time-varying states mapping time `t` to `fam.mcs t`
- **canonicalOmega B**: The set of all canonical histories (NOT shift-closed by design)

The WorldState type is `{ S : Set Formula // SetMaximalConsistent S }`, so every world
state in any world history is guaranteed to be an MCS. The time-varying states ensure
that the truth lemma relates `fam.mcs t` (not `fam.mcs 0`) to truth at time `t`.

## Truth Lemma Design

The truth lemma states: `phi in fam.mcs t <-> truth_at M (canonicalOmega B) tau t phi`

Key design choices:
- LHS is `fam.mcs t` (time-indexed), not `fam.mcs 0` (constant)
- Box quantifies over `canonicalOmega B` (canonical histories only)
- This fixes the Box forward case: sigma in canonicalOmega means sigma = canonicalHistory fam'
  for some fam', so IH applies directly
- No constant-family assumption needed

## Omega Parameterization (Task 912)

The previous Omega-mismatch sorries were resolved by parameterizing `valid` and
`semantic_consequence` over shift-closed Omega (Option B from research-003.md).
The key constructions:
- `shiftClosedCanonicalOmega B`: Shift-closed enlargement of `canonicalOmega B`
- `shifted_truth_lemma`: Truth lemma for the enlarged set (uses `box_persistent`)
- Completeness proofs instantiate `valid` at `shiftClosedCanonicalOmega B`

This module's remaining sorries are inherited from upstream (`construct_saturated_bmcs_int`).

## Main Results

- `canonical_truth_lemma`: MCS membership iff standard truth_at (for all families)
- `standard_representation`: `ContextConsistent [phi] -> satisfiable Int [phi]`
- `standard_weak_completeness`: `valid phi -> Nonempty (DerivationTree [] phi)`
- `standard_strong_completeness`: `semantic_consequence Gamma phi -> ContextDerivable Gamma phi`

## References

- Task 910: Phase 4 - Canonical Model Reconstruction
- Task 903: Restructure completeness proof for Bimodal task semantics
- Research: specs/910_phase4_canonical_model_reconstruction/reports/research-001.md
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics
open Bimodal.ProofSystem

/-!
## Canonical Definitions

The canonical frame, model, and histories are constructed from a BMCS.
WorldState is generalized to any MCS (not restricted to constant families).
-/

/-- Restricted world state type: any MCS. -/
def CanonicalWorldState (_B : BMCS Int) : Type :=
  { S : Set Formula // SetMaximalConsistent S }

/-- The canonical task frame with restricted WorldState. -/
def canonicalFrame (B : BMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/-- The canonical task model. -/
def canonicalModel (B : BMCS Int) : TaskModel (canonicalFrame B) where
  valuation := fun w p => Formula.atom p ∈ w.val

/-- Construct a CanonicalWorldState from a family at time t. -/
def mkCanonicalWorldState (B : BMCS Int) (fam : BFMCS Int) (t : Int) :
    CanonicalWorldState B :=
  ⟨fam.mcs t, fam.is_mcs t⟩

/-- The canonical world history for a family, with time-varying states. -/
def canonicalHistory (B : BMCS Int) (fam : BFMCS Int) (_hfam : fam ∈ B.families) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => mkCanonicalWorldState B fam t
  respects_task := fun _ _ _ _ _ => trivial

theorem canonicalHistory_states_val (B : BMCS Int) (fam : BFMCS Int)
    (hfam : fam ∈ B.families) (t : Int)
    (ht : (canonicalHistory B fam hfam).domain t) :
    ((canonicalHistory B fam hfam).states t ht).val = fam.mcs t := rfl

/-!
## Canonical Omega

The set of admissible histories for the box modality. This is the set of all
canonical histories constructed from bundle families.

NOTE: canonicalOmega is NOT shift-closed. Shift-closure is only needed for
soundness (time_shift_preserves_truth), not for completeness.
-/

/-- The set of canonical histories: one for each family in the BMCS. -/
def canonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | ∃ (fam : BFMCS Int) (hfam : fam ∈ B.families), sigma = canonicalHistory B fam hfam }

/-- Every canonical history is in canonicalOmega. -/
theorem canonicalHistory_mem_canonicalOmega (B : BMCS Int) (fam : BFMCS Int)
    (hfam : fam ∈ B.families) :
    canonicalHistory B fam hfam ∈ canonicalOmega B :=
  ⟨fam, hfam, rfl⟩

/-!
## Shift-Closed Canonical Omega

The shift-closed enlargement of canonicalOmega. This set contains all canonical
histories AND all their time-shifts, making it shift-closed by construction.
This is needed so that the completeness proof can provide an Omega satisfying
the ShiftClosed condition required by `valid`.
-/

/-- The shift-closed canonical Omega: all time-shifts of canonical histories. -/
def shiftClosedCanonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { σ | ∃ (fam : BFMCS Int) (hfam : fam ∈ B.families) (delta : Int),
    σ = WorldHistory.time_shift (canonicalHistory B fam hfam) delta }

/-- Time-shift of canonical histories composes: shifting by delta then delta' equals shifting by delta + delta'. -/
private theorem time_shift_canonicalHistory_compose (B : BMCS Int)
    (fam : BFMCS Int) (hfam : fam ∈ B.families)
    (delta delta' : Int) :
    WorldHistory.time_shift (WorldHistory.time_shift (canonicalHistory B fam hfam) delta) delta' =
    WorldHistory.time_shift (canonicalHistory B fam hfam) (delta + delta') := by
  simp only [WorldHistory.time_shift, canonicalHistory]
  congr 1; funext t ht; simp only [mkCanonicalWorldState]
  have h_eq : t + delta' + delta = t + (delta + delta') := by omega
  congr 1; exact congrArg fam.mcs h_eq

/-- A canonical history equals its time-shift by 0. -/
private theorem canonicalHistory_eq_time_shift_zero (B : BMCS Int)
    (fam : BFMCS Int) (hfam : fam ∈ B.families) :
    canonicalHistory B fam hfam = WorldHistory.time_shift (canonicalHistory B fam hfam) 0 := by
  simp only [WorldHistory.time_shift, canonicalHistory]
  congr 1; funext t ht; simp only [mkCanonicalWorldState]
  have h_eq : t = t + 0 := by omega
  congr 1; exact congrArg fam.mcs h_eq

/-- shiftClosedCanonicalOmega is shift-closed. -/
theorem shiftClosedCanonicalOmega_is_shift_closed (B : BMCS Int) :
    ShiftClosed (shiftClosedCanonicalOmega B) := by
  intro σ h_mem Δ'
  obtain ⟨fam, hfam, delta, h_eq⟩ := h_mem
  refine ⟨fam, hfam, delta + Δ', ?_⟩
  subst h_eq
  exact time_shift_canonicalHistory_compose B fam hfam delta Δ'

/-- Every canonical history is in the shift-closed canonical Omega (take delta = 0). -/
theorem canonicalOmega_subset_shiftClosed (B : BMCS Int) :
    canonicalOmega B ⊆ shiftClosedCanonicalOmega B := by
  intro σ h_mem
  obtain ⟨fam, hfam, h_eq⟩ := h_mem
  refine ⟨fam, hfam, 0, ?_⟩
  subst h_eq
  exact canonicalHistory_eq_time_shift_zero B fam hfam

/-!
## Box Persistence

The key lemma for the shifted truth lemma: Box phi at any time t implies
Box phi at ALL times, using the TF axiom and its temporal dual.
-/

/-- Past analog of TF axiom: Box phi -> H(Box phi), derived via temporal duality.
TF is `(Box phi).imp (Box phi).all_future`. Applying temporal duality to
TF for `swap_past_future phi` yields `(Box phi).imp (Box phi).all_past`. -/
private def past_tf_deriv (φ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((Formula.box φ).imp (Formula.box φ).all_past) := by
  have h_tf_swap := Bimodal.ProofSystem.DerivationTree.axiom [] _
    (Bimodal.ProofSystem.Axiom.temp_future (Formula.swap_past_future φ))
  have h_dual := Bimodal.ProofSystem.DerivationTree.temporal_duality _ h_tf_swap
  have h_eq : Formula.swap_past_future ((Formula.box (Formula.swap_past_future φ)).imp
      (Formula.box (Formula.swap_past_future φ)).all_future) =
    (Formula.box φ).imp (Formula.box φ).all_past := by
    simp [Formula.swap_past_future, Formula.swap_temporal]
  rw [h_eq] at h_dual
  exact h_dual

/-- Box phi at time t implies Box phi at all times s, for any family in a BMCS.

The proof uses:
1. TF axiom: Box phi -> G(Box phi) -- so Box phi persists to all future times
2. Temporal dual of TF: Box phi -> H(Box phi) -- so Box phi persists to all past times
3. forward_G and backward_H to extract Box phi at specific times
-/
theorem box_persistent
    (fam : BFMCS Int)
    (φ : Formula) (t s : Int)
    (h_box : Formula.box φ ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs s := by
  -- Step 1: G(Box phi) ∈ fam.mcs t via TF axiom
  have h_tf : (Formula.box φ).imp (Formula.box φ).all_future ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.temp_future φ))
  have h_G_box : (Formula.box φ).all_future ∈ fam.mcs t :=
    set_mcs_implication_property (fam.is_mcs t) h_tf h_box
  -- Step 2: H(Box phi) ∈ fam.mcs t via past-TF
  have h_past_tf : (Formula.box φ).imp (Formula.box φ).all_past ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (past_tf_deriv φ)
  have h_H_box : (Formula.box φ).all_past ∈ fam.mcs t :=
    set_mcs_implication_property (fam.is_mcs t) h_past_tf h_box
  -- Step 3: Case split on s vs t
  rcases le_or_gt t s with h_le | h_lt
  · -- s ≥ t: use T-axiom for s = t, forward_G for s > t
    rcases eq_or_lt_of_le h_le with h_eq | h_lt
    · rw [← h_eq]; exact h_box
    · exact fam.forward_G t s (Formula.box φ) h_lt h_G_box
  · -- s < t: use backward_H
    exact fam.backward_H t s (Formula.box φ) h_lt h_H_box

/-!
## Truth Lemma

The truth lemma is proven for ALL families simultaneously via structural induction
on the formula. This is necessary because the box case needs the IH for all families.

Key change from Task 903: The LHS is `fam.mcs t` (time-indexed) and the box case
quantifies over `canonicalOmega B` instead of all histories.
-/

/--
The canonical truth lemma: For all families in the BMCS, MCS membership at `fam.mcs t`
is equivalent to standard `truth_at` in the canonical model with `canonicalOmega`.

The statement quantifies over all families so that the box case IH is strong enough.
-/
theorem canonical_truth_lemma_all (B : BMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : BFMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔ truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t φ := by
  revert fam hfam t
  induction φ with
  | atom p =>
    intro fam hfam t
    constructor
    · intro h_mem
      show ∃ (ht : (canonicalHistory B fam hfam).domain t),
        (canonicalModel B).valuation ((canonicalHistory B fam hfam).states t ht) p
      exact ⟨trivial, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    intro fam hfam t
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      apply (fam.is_mcs t).1 [Formula.bot] (by intro x hx; simp at hx; rw [hx]; exact h_mem)
      exact ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    intro fam hfam t
    simp only [truth_at]
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true
      exact (ih_χ fam hfam t).mp (set_mcs_implication_property (fam.is_mcs t) h_imp h_ψ_mem)
    · intro h_truth_imp
      have h_mcs := fam.is_mcs t
      rcases set_mcs_negation_complete h_mcs ψ with h_ψ_in | h_neg_ψ_in
      · have h_χ_mem := (ih_χ fam hfam t).mpr (h_truth_imp ((ih_ψ fam hfam t).mp h_ψ_in))
        exact set_mcs_implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.prop_s χ ψ))) h_χ_mem
      · exact set_mcs_implication_property h_mcs
          (theorem_in_mcs h_mcs (Bimodal.Theorems.Propositional.efq_neg ψ χ)) h_neg_ψ_in
  | box ψ ih =>
    intro fam hfam t
    constructor
    · -- Forward: Box ψ ∈ fam.mcs t → ∀ σ ∈ canonicalOmega B, truth_at ... σ t ψ
      intro h_box σ h_σ_mem
      -- σ ∈ canonicalOmega B means σ = canonicalHistory B fam' hfam' for some fam'
      obtain ⟨fam', hfam', h_σ_eq⟩ := h_σ_mem
      -- By modal_forward: ψ ∈ fam'.mcs t for all fam' ∈ B.families
      have h_ψ_fam' : ψ ∈ fam'.mcs t :=
        B.modal_forward fam hfam ψ t h_box fam' hfam'
      -- By IH: ψ ∈ fam'.mcs t → truth_at ... (canonicalHistory B fam' hfam') t ψ
      have h_truth := (ih fam' hfam' t).mp h_ψ_fam'
      -- Substitute σ = canonicalHistory B fam' hfam'
      rw [h_σ_eq]
      exact h_truth
    · -- Backward: (∀ σ ∈ canonicalOmega B, truth_at ... σ t ψ) → Box ψ ∈ fam.mcs t
      intro h_all_σ
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := canonicalHistory_mem_canonicalOmega B fam' hfam'
        exact (ih fam' hfam' t).mpr (h_all_σ (canonicalHistory B fam' hfam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | all_future ψ ih =>
    intro fam hfam t
    -- truth_at for all_future: ∀ s ≥ t, truth_at M Omega τ s ψ
    -- With time-varying states, fam.mcs s at time s is directly available.
    constructor
    · -- Forward: G ψ ∈ fam.mcs t → ∀ s ≥ t, truth_at M Omega τ s ψ
      intro h_G s h_le
      -- Case split: s = t or s > t
      rcases eq_or_lt_of_le h_le with h_eq | h_lt
      · -- s = t: G ψ ∈ fam.mcs t, by T-axiom (G ψ → ψ): ψ ∈ fam.mcs t
        rw [← h_eq]
        have h_mcs := fam.is_mcs t
        have h_T : [] ⊢ (Formula.all_future ψ).imp ψ :=
          DerivationTree.axiom [] _ (Axiom.temp_t_future ψ)
        have h_ψ_mem : ψ ∈ fam.mcs t :=
          set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
        exact (ih fam hfam t).mp h_ψ_mem
      · -- s > t: G ψ ∈ fam.mcs t, by forward_G: ψ ∈ fam.mcs s
        have h_ψ_s : ψ ∈ fam.mcs s := fam.forward_G t s ψ h_lt h_G
        exact (ih fam hfam s).mp h_ψ_s
    · -- Backward: (∀ s ≥ t, truth_at M Omega τ s ψ) → G ψ ∈ fam.mcs t
      intro h_all_s
      -- By IH backward at each s: truth_at → ψ ∈ fam.mcs s
      -- Need G ψ ∈ fam.mcs t via contraposition
      have h_mcs := fam.is_mcs t
      by_contra h_not_G
      have h_neg_G : Formula.neg (Formula.all_future ψ) ∈ fam.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.all_future ψ) with h | h
        · exact absurd h h_not_G
        · exact h
      -- neg(G ψ) implies F(neg ψ) ∈ fam.mcs t (temporal duality)
      have h_F_neg : Formula.some_future (Formula.neg ψ) ∈ fam.mcs t :=
        neg_all_future_to_some_future_neg (fam.mcs t) h_mcs ψ h_neg_G
      -- By temporal coherence (forward_F): ∃ s > t with neg ψ ∈ fam.mcs s
      have h_tc_fam := h_tc fam hfam
      obtain ⟨s, h_lt, h_neg_ψ_s⟩ := h_tc_fam.1 t (Formula.neg ψ) h_F_neg
      -- By IH at s: truth_at → ψ ∈ fam.mcs s
      have h_ψ_s : ψ ∈ fam.mcs s := (ih fam hfam s).mpr (h_all_s s (le_of_lt h_lt))
      -- Contradiction: ψ and neg ψ both in fam.mcs s
      exact set_consistent_not_both (fam.is_mcs s).1 ψ h_ψ_s h_neg_ψ_s
  | all_past ψ ih =>
    intro fam hfam t
    -- Symmetric to all_future, using H and backward_P
    constructor
    · -- Forward: H ψ ∈ fam.mcs t → ∀ s ≤ t, truth_at M Omega τ s ψ
      intro h_H s h_le
      rcases eq_or_lt_of_le h_le with h_eq | h_lt
      · -- s = t: by T-axiom, using h_eq : s = t
        have h_mcs := fam.is_mcs t
        have h_T : [] ⊢ (Formula.all_past ψ).imp ψ :=
          DerivationTree.axiom [] _ (Axiom.temp_t_past ψ)
        have h_ψ_mem : ψ ∈ fam.mcs t :=
          set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H
        have h_ψ_s : ψ ∈ fam.mcs s := h_eq ▸ h_ψ_mem
        exact (ih fam hfam s).mp h_ψ_s
      · -- s < t: by backward_H
        have h_ψ_s : ψ ∈ fam.mcs s := fam.backward_H t s ψ h_lt h_H
        exact (ih fam hfam s).mp h_ψ_s
    · -- Backward: (∀ s ≤ t, truth_at M Omega τ s ψ) → H ψ ∈ fam.mcs t
      intro h_all_s
      have h_mcs := fam.is_mcs t
      by_contra h_not_H
      have h_neg_H : Formula.neg (Formula.all_past ψ) ∈ fam.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.all_past ψ) with h | h
        · exact absurd h h_not_H
        · exact h
      -- neg(H ψ) implies P(neg ψ) ∈ fam.mcs t
      have h_P_neg : Formula.some_past (Formula.neg ψ) ∈ fam.mcs t :=
        neg_all_past_to_some_past_neg (fam.mcs t) h_mcs ψ h_neg_H
      -- By temporal coherence (backward_P): ∃ s < t with neg ψ ∈ fam.mcs s
      have h_tc_fam := h_tc fam hfam
      obtain ⟨s, h_lt, h_neg_ψ_s⟩ := h_tc_fam.2 t (Formula.neg ψ) h_P_neg
      -- By IH at s: truth_at → ψ ∈ fam.mcs s
      have h_ψ_s : ψ ∈ fam.mcs s := (ih fam hfam s).mpr (h_all_s s (le_of_lt h_lt))
      -- Contradiction: ψ and neg ψ both in fam.mcs s
      exact set_consistent_not_both (fam.is_mcs s).1 ψ h_ψ_s h_neg_ψ_s

/-- Convenience wrapper: truth lemma for a specific family. -/
theorem canonical_truth_lemma (B : BMCS Int)
    (h_tc : B.temporally_coherent)
    (fam : BFMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔ truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t φ :=
  canonical_truth_lemma_all B h_tc φ fam hfam t

/-!
## Shifted Truth Lemma

The truth lemma extended to `shiftClosedCanonicalOmega`. This is the key result
enabling the completeness proof: it relates MCS membership to truth in the canonical
model with a shift-closed set of histories.

The proof follows the same structure as `canonical_truth_lemma_all` but handles
the box case differently, using `box_persistent` and `time_shift_preserves_truth`
to handle shifted canonical histories.
-/

/--
Shifted truth lemma: MCS membership iff truth at the canonical model with
shift-closed canonical Omega. The box forward case uses `box_persistent` to
show that Box phi persists to all times, enabling truth at shifted histories
via `time_shift_preserves_truth`.
-/
theorem shifted_truth_lemma (B : BMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : BFMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
    truth_at (canonicalModel B) (shiftClosedCanonicalOmega B) (canonicalHistory B fam hfam) t φ := by
  revert fam hfam t
  induction φ with
  | atom p =>
    intro fam hfam t
    -- Identical to canonical_truth_lemma_all (atom case is Omega-independent)
    constructor
    · intro h_mem
      exact ⟨trivial, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    intro fam hfam t
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      apply (fam.is_mcs t).1 [Formula.bot] (by intro x hx; simp at hx; rw [hx]; exact h_mem)
      exact ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    intro fam hfam t
    simp only [truth_at]
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true
      exact (ih_χ fam hfam t).mp (set_mcs_implication_property (fam.is_mcs t) h_imp h_ψ_mem)
    · intro h_truth_imp
      have h_mcs := fam.is_mcs t
      rcases set_mcs_negation_complete h_mcs ψ with h_ψ_in | h_neg_ψ_in
      · have h_χ_mem := (ih_χ fam hfam t).mpr (h_truth_imp ((ih_ψ fam hfam t).mp h_ψ_in))
        exact set_mcs_implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.prop_s χ ψ))) h_χ_mem
      · exact set_mcs_implication_property h_mcs
          (theorem_in_mcs h_mcs (Bimodal.Theorems.Propositional.efq_neg ψ χ)) h_neg_ψ_in
  | box ψ ih =>
    intro fam hfam t
    constructor
    · -- Forward: Box ψ ∈ fam.mcs t → ∀ σ ∈ shiftClosedCanonicalOmega B, truth_at ... σ t ψ
      intro h_box σ h_σ_mem
      -- σ ∈ shiftClosedCanonicalOmega B means σ = time_shift (canonicalHistory B fam' hfam') delta
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      -- By box_persistent: Box ψ ∈ fam.mcs (t + delta)
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        box_persistent fam ψ t (t + delta) h_box
      -- By modal_forward: ψ ∈ fam'.mcs (t + delta)
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      -- By IH at (fam', hfam', t + delta): truth_at ... (canonicalHistory B fam' hfam') (t + delta) ψ
      have h_truth_canon := (ih fam' hfam' (t + delta)).mp h_ψ_fam'
      -- By time_shift_preserves_truth with shift-closed Omega:
      -- truth_at ... (time_shift (canonicalHistory ...) delta) t ψ ↔ truth_at ... (canonicalHistory ...) (t + delta) ψ
      have h_preserve := TimeShift.time_shift_preserves_truth
        (canonicalModel B) (shiftClosedCanonicalOmega B)
        (shiftClosedCanonicalOmega_is_shift_closed B) (canonicalHistory B fam' hfam')
        t (t + delta) ψ
      -- time_shift_preserves_truth: truth_at ... (time_shift σ (y - x)) x φ ↔ truth_at ... σ y φ
      -- With x = t, y = t + delta: truth_at ... (time_shift σ ((t+delta) - t)) t ψ ↔ truth_at ... σ (t+delta) ψ
      -- (t+delta) - t = delta, so: truth_at ... (time_shift σ delta) t ψ ↔ truth_at ... σ (t+delta) ψ
      have h_delta : (t + delta) - t = delta := by omega
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (canonicalHistory B fam' hfam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · -- Backward: (∀ σ ∈ shiftClosedCanonicalOmega B, truth_at ... σ t ψ) → Box ψ ∈ fam.mcs t
      intro h_all_σ
      -- Only use canonical histories (delta = 0 case)
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := canonicalOmega_subset_shiftClosed B (canonicalHistory_mem_canonicalOmega B fam' hfam')
        exact (ih fam' hfam' t).mpr (h_all_σ (canonicalHistory B fam' hfam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | all_future ψ ih =>
    intro fam hfam t
    -- Identical to canonical_truth_lemma_all (temporal cases are Omega-independent)
    constructor
    · intro h_G s h_le
      rcases eq_or_lt_of_le h_le with h_eq | h_lt
      · rw [← h_eq]
        have h_mcs := fam.is_mcs t
        have h_T : [] ⊢ (Formula.all_future ψ).imp ψ :=
          DerivationTree.axiom [] _ (Axiom.temp_t_future ψ)
        have h_ψ_mem : ψ ∈ fam.mcs t :=
          set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
        exact (ih fam hfam t).mp h_ψ_mem
      · have h_ψ_s : ψ ∈ fam.mcs s := fam.forward_G t s ψ h_lt h_G
        exact (ih fam hfam s).mp h_ψ_s
    · intro h_all_s
      have h_mcs := fam.is_mcs t
      by_contra h_not_G
      have h_neg_G : Formula.neg (Formula.all_future ψ) ∈ fam.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.all_future ψ) with h | h
        · exact absurd h h_not_G
        · exact h
      have h_F_neg : Formula.some_future (Formula.neg ψ) ∈ fam.mcs t :=
        neg_all_future_to_some_future_neg (fam.mcs t) h_mcs ψ h_neg_G
      have h_tc_fam := h_tc fam hfam
      obtain ⟨s, h_lt, h_neg_ψ_s⟩ := h_tc_fam.1 t (Formula.neg ψ) h_F_neg
      have h_ψ_s : ψ ∈ fam.mcs s := (ih fam hfam s).mpr (h_all_s s (le_of_lt h_lt))
      exact set_consistent_not_both (fam.is_mcs s).1 ψ h_ψ_s h_neg_ψ_s
  | all_past ψ ih =>
    intro fam hfam t
    constructor
    · intro h_H s h_le
      rcases eq_or_lt_of_le h_le with h_eq | h_lt
      · have h_mcs := fam.is_mcs t
        have h_T : [] ⊢ (Formula.all_past ψ).imp ψ :=
          DerivationTree.axiom [] _ (Axiom.temp_t_past ψ)
        have h_ψ_mem : ψ ∈ fam.mcs t :=
          set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H
        have h_ψ_s : ψ ∈ fam.mcs s := h_eq ▸ h_ψ_mem
        exact (ih fam hfam s).mp h_ψ_s
      · have h_ψ_s : ψ ∈ fam.mcs s := fam.backward_H t s ψ h_lt h_H
        exact (ih fam hfam s).mp h_ψ_s
    · intro h_all_s
      have h_mcs := fam.is_mcs t
      by_contra h_not_H
      have h_neg_H : Formula.neg (Formula.all_past ψ) ∈ fam.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.all_past ψ) with h | h
        · exact absurd h h_not_H
        · exact h
      have h_P_neg : Formula.some_past (Formula.neg ψ) ∈ fam.mcs t :=
        neg_all_past_to_some_past_neg (fam.mcs t) h_mcs ψ h_neg_H
      have h_tc_fam := h_tc fam hfam
      obtain ⟨s, h_lt, h_neg_ψ_s⟩ := h_tc_fam.2 t (Formula.neg ψ) h_P_neg
      have h_ψ_s : ψ ∈ fam.mcs s := (ih fam hfam s).mpr (h_all_s s (le_of_lt h_lt))
      exact set_consistent_not_both (fam.is_mcs s).1 ψ h_ψ_s h_neg_ψ_s

/-!
## Standard Completeness Theorems

These theorems connect the BMCS completeness results to the standard semantic definitions
from `Semantics/Validity.lean`.

**Sorry dependency**: All theorems inherit the sorry from `fully_saturated_bmcs_exists_int`
via `construct_saturated_bmcs_int`.
-/

/--
**Standard Representation Theorem**: If `φ` is consistent (i.e., `[φ]` has no derivation
of ⊥), then `φ` is satisfiable in the standard semantics with temporal type `Int`,
using a shift-closed Omega.

This is the core existential statement: consistent formulas have standard models.

**Proof Strategy**:
1. Get a fully saturated BMCS B from `construct_saturated_bmcs_int`
2. φ ∈ B.eval_family.mcs 0 by construction
3. By shifted truth lemma: truth_at M (shiftClosedCanonicalOmega B) (canonicalHistory ...) 0 φ
4. Package as satisfiable: ∃ F M Omega τ t, τ ∈ Omega ∧ truth_at M Omega τ t φ
-/
theorem standard_representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    satisfiable Int [φ] := by
  -- Get fully saturated BMCS
  let B := construct_saturated_bmcs_int [φ] h_cons
  have h_contains := construct_saturated_bmcs_int_contains_context [φ] h_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent [φ] h_cons
  -- φ ∈ B.eval_family.mcs 0
  have h_in_mcs : φ ∈ B.eval_family.mcs 0 := h_contains φ (by simp)
  -- By shifted truth lemma: truth_at at canonical model with shift-closed Omega
  have h_truth := (shifted_truth_lemma B h_tc φ B.eval_family B.eval_family_mem 0).mp h_in_mcs
  -- canonical history is in shiftClosedCanonicalOmega (via canonicalOmega_subset_shiftClosed)
  have h_mem_sc := canonicalOmega_subset_shiftClosed B
    (canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem)
  -- Package as satisfiable
  exact ⟨canonicalFrame B, canonicalModel B, shiftClosedCanonicalOmega B,
    canonicalHistory B B.eval_family B.eval_family_mem,
    h_mem_sc, 0,
    fun ψ h_mem => by
      simp at h_mem
      rw [h_mem]
      exact h_truth⟩

/--
**Standard Context Representation**: If a context Γ is consistent, then all formulas
in Γ are satisfiable simultaneously in the standard semantics, with a shift-closed Omega.
-/
theorem standard_context_representation (Γ : List Formula) (h_cons : ContextConsistent Γ) :
    satisfiable Int Γ := by
  let B := construct_saturated_bmcs_int Γ h_cons
  have h_contains := construct_saturated_bmcs_int_contains_context Γ h_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent Γ h_cons
  have h_mem_sc := canonicalOmega_subset_shiftClosed B
    (canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem)
  exact ⟨canonicalFrame B, canonicalModel B, shiftClosedCanonicalOmega B,
    canonicalHistory B B.eval_family B.eval_family_mem,
    h_mem_sc, 0,
    fun γ h_mem => by
      have h_in_mcs := h_contains γ h_mem
      exact (shifted_truth_lemma B h_tc γ B.eval_family B.eval_family_mem 0).mp h_in_mcs⟩

/--
**Standard Weak Completeness**: If a formula is valid (true in all standard models),
then it is derivable from the empty context.

**Proof Strategy** (by contraposition):
1. If ⊬ φ, then [¬φ] is consistent
2. Construct a fully saturated BMCS B for [¬φ]
3. By shifted truth lemma: ¬φ is true at (canonicalModel B, shiftClosedCanonicalOmega B, ...)
4. By validity: φ is true at the SAME (model, Omega, history, time) since Omega is shift-closed
5. Contradiction: both φ and ¬φ true at the same point

**Resolution of Omega-mismatch (Task 912)**:
The previous sorry existed because `valid` used `Set.univ` while `satisfiable` provided
`canonicalOmega B`. With Omega-parameterized validity (quantifying over all shift-closed Omega),
we can instantiate `valid` at `shiftClosedCanonicalOmega B` which IS shift-closed, resolving
the mismatch.
-/
theorem standard_weak_completeness (φ : Formula) (h_valid : valid φ) :
    Nonempty (DerivationTree [] φ) := by
  by_contra h_not_deriv
  -- [φ.neg] is consistent
  have h_neg_cons : ContextConsistent [φ.neg] :=
    Bimodal.Metalogic.Bundle.not_derivable_implies_neg_consistent φ h_not_deriv
  -- Construct BMCS directly (avoid going through satisfiable, which loses ShiftClosed info)
  let B := construct_saturated_bmcs_int [φ.neg] h_neg_cons
  have h_contains := construct_saturated_bmcs_int_contains_context [φ.neg] h_neg_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent [φ.neg] h_neg_cons
  -- φ.neg ∈ B.eval_family.mcs 0
  have h_neg_in_mcs : φ.neg ∈ B.eval_family.mcs 0 := h_contains φ.neg (by simp)
  -- By shifted truth lemma: truth_at ... φ.neg at shift-closed canonical Omega
  have h_neg_truth := (shifted_truth_lemma B h_tc φ.neg B.eval_family B.eval_family_mem 0).mp h_neg_in_mcs
  -- φ.neg being true means φ is false
  have h_phi_false : ¬truth_at (canonicalModel B) (shiftClosedCanonicalOmega B)
      (canonicalHistory B B.eval_family B.eval_family_mem) 0 φ := h_neg_truth
  -- But valid φ says φ is true at ALL shift-closed Omega, including shiftClosedCanonicalOmega B
  have h_sc := shiftClosedCanonicalOmega_is_shift_closed B
  have h_mem := canonicalOmega_subset_shiftClosed B
    (canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem)
  have h_phi_true := h_valid Int (canonicalFrame B) (canonicalModel B)
    (shiftClosedCanonicalOmega B) h_sc
    (canonicalHistory B B.eval_family B.eval_family_mem) h_mem 0
  -- Contradiction
  exact h_phi_false h_phi_true

/--
**Standard Strong Completeness**: If φ is a semantic consequence of Γ (in the standard
semantics), then φ is derivable from Γ.

**Proof Strategy** (by contraposition):
1. If Γ ⊬ φ, then Γ ++ [¬φ] is consistent
2. Construct BMCS directly for Γ ++ [¬φ]
3. By shifted truth lemma: all of Γ are true and ¬φ is true at shift-closed Omega
4. By semantic consequence: φ must be true at the SAME (model, Omega, history, time)
5. Contradiction: both φ and ¬φ true

**Resolution of Omega-mismatch (Task 912)**:
With Omega-parameterized semantic_consequence, we can instantiate at
`shiftClosedCanonicalOmega B` directly.
-/
theorem standard_strong_completeness (Γ : List Formula) (φ : Formula)
    (h_conseq : semantic_consequence Γ φ) :
    Bimodal.Metalogic.Bundle.ContextDerivable Γ φ := by
  by_contra h_not_deriv
  -- Γ ++ [φ.neg] is consistent
  have h_ext_cons : ContextConsistent (Γ ++ [φ.neg]) :=
    Bimodal.Metalogic.Bundle.context_not_derivable_implies_extended_consistent Γ φ h_not_deriv
  -- Construct BMCS directly (avoid going through satisfiable, which loses ShiftClosed info)
  let B := construct_saturated_bmcs_int (Γ ++ [φ.neg]) h_ext_cons
  have h_contains := construct_saturated_bmcs_int_contains_context (Γ ++ [φ.neg]) h_ext_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent (Γ ++ [φ.neg]) h_ext_cons
  -- ¬φ ∈ B.eval_family.mcs 0
  have h_neg_in_mcs : φ.neg ∈ B.eval_family.mcs 0 := h_contains φ.neg (by simp)
  -- By shifted truth lemma: truth_at ... φ.neg
  have h_neg_truth := (shifted_truth_lemma B h_tc φ.neg B.eval_family B.eval_family_mem 0).mp h_neg_in_mcs
  have h_phi_false : ¬truth_at (canonicalModel B) (shiftClosedCanonicalOmega B)
      (canonicalHistory B B.eval_family B.eval_family_mem) 0 φ := h_neg_truth
  -- All of Γ are in B.eval_family.mcs 0
  have h_gamma_true : ∀ ψ ∈ Γ, truth_at (canonicalModel B) (shiftClosedCanonicalOmega B)
      (canonicalHistory B B.eval_family B.eval_family_mem) 0 ψ := by
    intro ψ h_mem
    have h_in_mcs := h_contains ψ (List.mem_append.mpr (Or.inl h_mem))
    exact (shifted_truth_lemma B h_tc ψ B.eval_family B.eval_family_mem 0).mp h_in_mcs
  -- By semantic consequence at shiftClosedCanonicalOmega: φ must be true
  have h_sc := shiftClosedCanonicalOmega_is_shift_closed B
  have h_mem := canonicalOmega_subset_shiftClosed B
    (canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem)
  have h_phi_true := h_conseq Int (canonicalFrame B) (canonicalModel B)
    (shiftClosedCanonicalOmega B) h_sc
    (canonicalHistory B B.eval_family B.eval_family_mem) h_mem 0
    h_gamma_true
  -- Contradiction
  exact h_phi_false h_phi_true

end Bimodal.Metalogic.Representation
