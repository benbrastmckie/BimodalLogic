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

## Sorry Characterization

This module has 2 sorries at the Omega-mismatch boundary (lines ~417, ~449).
These are NOT inherited from upstream; they represent a genuine semantic gap between
the BMCS truth (using canonicalOmega) and the standard validity (using Set.univ).

Task 912 Phase 2 investigated three approaches and found all blocked:
1. Coverage lemma unprovable from is_modally_saturated
2. Truth lemma with Set.univ unprovable (IH only at canonical histories)
3. Omega-parametric validity breaks MF/TF soundness (needs ShiftClosed)

The most promising resolution is approach (A): add ShiftClosed to validity definition.

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
def CanonicalWorldState (B : BMCS Int) : Type :=
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
def mkCanonicalWorldState (B : BMCS Int) (fam : IndexedMCSFamily Int) (t : Int) :
    CanonicalWorldState B :=
  ⟨fam.mcs t, fam.is_mcs t⟩

/-- The canonical world history for a family, with time-varying states. -/
def canonicalHistory (B : BMCS Int) (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => mkCanonicalWorldState B fam t
  respects_task := fun _ _ _ _ _ => trivial

theorem canonicalHistory_states_val (B : BMCS Int) (fam : IndexedMCSFamily Int)
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
  { sigma | ∃ (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families), sigma = canonicalHistory B fam hfam }

/-- Every canonical history is in canonicalOmega. -/
theorem canonicalHistory_mem_canonicalOmega (B : BMCS Int) (fam : IndexedMCSFamily Int)
    (hfam : fam ∈ B.families) :
    canonicalHistory B fam hfam ∈ canonicalOmega B :=
  ⟨fam, hfam, rfl⟩

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
    (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families) (t : Int) :
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
    (fam : IndexedMCSFamily Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔ truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t φ :=
  canonical_truth_lemma_all B h_tc φ fam hfam t

/-!
## Standard Completeness Theorems

These theorems connect the BMCS completeness results to the standard semantic definitions
from `Semantics/Validity.lean`.

**Sorry dependency**: All theorems inherit the sorry from `fully_saturated_bmcs_exists_int`
via `construct_saturated_bmcs_int`.
-/

/--
**Standard Representation Theorem**: If `φ` is consistent (i.e., `[φ]` has no derivation
of ⊥), then `φ` is satisfiable in the standard semantics with temporal type `Int`.

This is the core existential statement: consistent formulas have standard models.

**Proof Strategy**:
1. Get a fully saturated BMCS B from `construct_saturated_bmcs_int`
2. φ ∈ B.eval_family.mcs 0 by construction
3. By truth lemma: truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B eval_family) 0 φ
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
  -- By truth lemma: truth_at at canonical model
  have h_truth := (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 φ).mp h_in_mcs
  -- Package as satisfiable
  exact ⟨canonicalFrame B, canonicalModel B, canonicalOmega B,
    canonicalHistory B B.eval_family B.eval_family_mem,
    canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem, 0,
    fun ψ h_mem => by
      simp at h_mem
      rw [h_mem]
      exact h_truth⟩

/--
**Standard Context Representation**: If a context Γ is consistent, then all formulas
in Γ are satisfiable simultaneously in the standard semantics.
-/
theorem standard_context_representation (Γ : List Formula) (h_cons : ContextConsistent Γ) :
    satisfiable Int Γ := by
  let B := construct_saturated_bmcs_int Γ h_cons
  have h_contains := construct_saturated_bmcs_int_contains_context Γ h_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent Γ h_cons
  exact ⟨canonicalFrame B, canonicalModel B, canonicalOmega B,
    canonicalHistory B B.eval_family B.eval_family_mem,
    canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem, 0,
    fun γ h_mem => by
      have h_in_mcs := h_contains γ h_mem
      exact (canonical_truth_lemma B h_tc B.eval_family B.eval_family_mem 0 γ).mp h_in_mcs⟩

/--
**Standard Weak Completeness**: If a formula is valid (true in all standard models),
then it is derivable from the empty context.

**Proof Strategy** (by contraposition):
1. If ⊬ φ, then [¬φ] is consistent
2. By standard_representation, ¬φ is satisfiable in some standard model
3. So φ is not valid in that model
4. Contradiction with valid φ

**Omega-mismatch analysis (Task 912)**:

`valid` uses `Set.univ` as Omega, while `satisfiable` provides `canonicalOmega B`.
The contradiction requires matching Omega values, which we cannot achieve because:

1. **Truth monotonicity fails**: truth_at is neither monotone nor anti-monotone in Omega
   because box quantifies over Omega (anti-monotone) while appearing under imp (contravariant).

2. **Coverage lemma unprovable**: is_modally_saturated (from fully_saturated_bmcs_exists_int)
   provides diamond witnesses, NOT coverage of all MCSes. The canonical frame's WorldState
   type `{ S : Set Formula // SetMaximalConsistent S }` includes ALL MCSes, but families
   only contain specific ones. So canonicalOmega B =/= Set.univ.

3. **Truth lemma with Set.univ unprovable**: The box case of canonical_truth_lemma_all
   requires IH at canonical histories (σ ∈ canonicalOmega). Extending to Set.univ would
   require IH at arbitrary histories, which the induction structure doesn't provide.

4. **Omega-parametric validity breaks soundness**: Making valid quantify over all Omega
   (not just Set.univ) would break soundness for MF (Box phi -> G phi) and TF axioms,
   which use Set.univ_shift_closed. Arbitrary Omega is not shift-closed.

**Resolution paths** (ranked by feasibility):
- (A) Add ShiftClosed Omega as condition to valid/semantic_consequence, prove soundness
      still works, prove canonicalOmega is shift-closed (or use Set.univ in representation)
- (B) Prove truth equivalence for canonical model: truth_at M Omega1 σ t φ ↔ truth_at M Omega2 σ t φ
      when both Omega contain all states reachable from σ (requires coverage + state-determination)
- (C) Leave sorry and document as known gap requiring Validity.lean redesign

See specs/910_phase4_canonical_model_reconstruction/reports/research-001.md for initial analysis.
See specs/912_review_completeness_proof_metalogic_state/plans/implementation-001.md Phase 2 for full investigation.
-/
theorem standard_weak_completeness (φ : Formula) (h_valid : valid φ) :
    Nonempty (DerivationTree [] φ) := by
  by_contra h_not_deriv
  -- [φ.neg] is consistent
  have h_neg_cons : ContextConsistent [φ.neg] :=
    Bimodal.Metalogic.Bundle.not_derivable_implies_neg_consistent φ h_not_deriv
  -- ¬φ is satisfiable: ∃ F M Omega τ t, τ ∈ Omega ∧ truth_at M Omega τ t φ.neg
  obtain ⟨F, M, Omega, τ, _h_mem, t, h_all_true⟩ := standard_representation φ.neg h_neg_cons
  have h_neg_true : truth_at M Omega τ t φ.neg := h_all_true φ.neg (by simp)
  -- truth_at φ.neg at Omega = (truth_at φ at Omega → False)
  -- So φ is false at (M, Omega, τ, t)
  have h_phi_false : ¬truth_at M Omega τ t φ := h_neg_true
  -- But valid φ says φ is true everywhere with Set.univ as Omega
  -- We need truth_at M Omega τ t φ, but valid gives truth_at M Set.univ τ t φ
  -- TODO: Omega-mismatch - valid uses Set.univ, satisfiable uses canonicalOmega
  -- For now, use sorry pending Validity.lean coordination
  sorry

/--
**Standard Strong Completeness**: If φ is a semantic consequence of Γ (in the standard
semantics), then φ is derivable from Γ.

**Proof Strategy** (by contraposition):
1. If Γ ⊬ φ, then Γ ++ [¬φ] is consistent
2. By standard_context_representation, Γ ++ [¬φ] is simultaneously satisfiable
3. So Γ is satisfied but φ is false in some standard model
4. Therefore φ is not a semantic consequence of Γ
5. Contradiction

See standard_weak_completeness for Omega-mismatch analysis (Task 912).
-/
theorem standard_strong_completeness (Γ : List Formula) (φ : Formula)
    (h_conseq : semantic_consequence Γ φ) :
    Bimodal.Metalogic.Bundle.ContextDerivable Γ φ := by
  by_contra h_not_deriv
  -- Γ ++ [φ.neg] is consistent
  have h_ext_cons : ContextConsistent (Γ ++ [φ.neg]) :=
    Bimodal.Metalogic.Bundle.context_not_derivable_implies_extended_consistent Γ φ h_not_deriv
  -- All of Γ ++ [¬φ] satisfiable simultaneously
  obtain ⟨F, M, Omega, τ, _h_mem, t, h_all_true⟩ := standard_context_representation (Γ ++ [φ.neg]) h_ext_cons
  -- ¬φ is true
  have h_neg_true : truth_at M Omega τ t φ.neg := h_all_true φ.neg (by simp)
  have h_phi_false : ¬truth_at M Omega τ t φ := h_neg_true
  -- All of Γ are true
  have h_gamma_true : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ := fun ψ h_mem =>
    h_all_true ψ (List.mem_append.mpr (Or.inl h_mem))
  -- By semantic consequence: φ is true (but with Set.univ as Omega)
  -- TODO: Omega-mismatch - semantic_consequence uses Set.univ, satisfiable uses canonicalOmega
  sorry

end Bimodal.Metalogic.Representation
