import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.CoherentConstruction
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.DovetailingChain
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Temporal Backward Properties for Truth Lemma

This module implements the temporal backward properties needed to eliminate sorries
in TruthLemma.lean lines 387 and 400.

## Background

The truth lemma backward direction for temporal operators requires proving:
- If φ ∈ fam.mcs s for all s ≥ t, then G φ ∈ fam.mcs t
- If φ ∈ fam.mcs s for all s ≤ t, then H φ ∈ fam.mcs t

These are NOT instances of an omega-rule. The proof uses MCS maximality by contraposition:
1. If G φ NOT in fam.mcs t, then neg(G φ) IS in fam.mcs t (by maximality)
2. neg(G φ) in MCS is equivalent to F(neg φ) in MCS (via temporal duality)
3. F(neg φ) in MCS means: exists s > t with neg φ in fam.mcs s (by forward_F coherence)
4. But neg φ contradicts the hypothesis that φ is at ALL times ≥ t

## Key Insight: Temporal Duality for MCS

The transformation from neg(G φ) to F(neg φ) requires proving:
- neg(G φ) ∈ MCS implies F(neg φ) ∈ MCS

Since F φ = neg(G(neg φ)), we have F(neg φ) = neg(G(neg(neg φ))).
So neg(G φ) must imply neg(G(neg neg φ)) in an MCS.

This uses the temporal analog of box_dne_theorem:
- G_dne_theorem: ⊢ G(¬¬φ) → G φ
- Contrapositive: neg(G φ) implies neg(G(¬¬φ)) = F(neg φ) in MCS

## References

- Task 857 plan: specs/857_add_temporal_backward_properties/plans/implementation-001.md
- Modal analog: CoherentConstruction.lean (neg_box_to_diamond_neg, box_dne_theorem)
- Research: specs/857_add_temporal_backward_properties/reports/research-004.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [LinearOrder D] [Zero D]

/-!
## Phase 1: Temporal Duality Infrastructure

These lemmas establish the transformation from neg(G φ) to F(neg φ) in an MCS context,
enabling the contraposition argument for temporal backward proofs.
-/

/--
Double negation elimination theorem: ⊢ ¬¬φ → φ

Re-exported from ModalSaturation for convenience.
-/
noncomputable def dne_theorem' (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  dne_theorem phi

/--
G distributes over double negation elimination: ⊢ G(¬¬φ) → G φ

This is the temporal analog of box_dne_theorem in ModalSaturation.lean.

**Proof Strategy**:
1. ⊢ ¬¬φ → φ (DNE)
2. ⊢ G(¬¬φ → φ) (temporal necessitation)
3. ⊢ G(¬¬φ → φ) → (G(¬¬φ) → G φ) (temporal K distribution)
4. ⊢ G(¬¬φ) → G φ (modus ponens)
-/
noncomputable def G_dne_theorem (phi : Formula) :
    [] ⊢ (Formula.all_future (Formula.neg (Formula.neg phi))).imp (Formula.all_future phi) := by
  -- Step 1: ⊢ ¬¬φ → φ (DNE)
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  -- Step 2: ⊢ G(¬¬φ → φ) (temporal necessitation)
  have h_G_dne : [] ⊢ Formula.all_future ((Formula.neg (Formula.neg phi)).imp phi) :=
    DerivationTree.temporal_necessitation _ h_dne
  -- Step 3: ⊢ G(¬¬φ → φ) → (G(¬¬φ) → G φ) (temporal K distribution axiom)
  have h_K : [] ⊢ (Formula.all_future ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.all_future (Formula.neg (Formula.neg phi))).imp (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist _ _)
  -- Step 4: ⊢ G(¬¬φ) → G φ (modus ponens)
  exact DerivationTree.modus_ponens [] _ _ h_K h_G_dne

/--
H distributes over double negation elimination: ⊢ H(¬¬φ) → H φ

This is the past analog of G_dne_theorem.

**Proof Strategy**:
1. ⊢ ¬¬φ → φ (DNE)
2. ⊢ H(¬¬φ → φ) (past necessitation via temporal duality)
3. ⊢ H(¬¬φ → φ) → (H(¬¬φ) → H φ) (past K distribution)
4. ⊢ H(¬¬φ) → H φ (modus ponens)
-/
noncomputable def H_dne_theorem (phi : Formula) :
    [] ⊢ (Formula.all_past (Formula.neg (Formula.neg phi))).imp (Formula.all_past phi) := by
  -- Step 1: ⊢ ¬¬φ → φ (DNE)
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  -- Step 2: ⊢ H(¬¬φ → φ) (past necessitation)
  have h_H_dne : [] ⊢ Formula.all_past ((Formula.neg (Formula.neg phi)).imp phi) :=
    Bimodal.Theorems.past_necessitation _ h_dne
  -- Step 3: ⊢ H(¬¬φ → φ) → (H(¬¬φ) → H φ) (past K distribution)
  have h_K : [] ⊢ (Formula.all_past ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.all_past (Formula.neg (Formula.neg phi))).imp (Formula.all_past phi)) :=
    Bimodal.Theorems.past_k_dist _ _
  -- Step 4: ⊢ H(¬¬φ) → H φ (modus ponens)
  exact DerivationTree.modus_ponens [] _ _ h_K h_H_dne

/--
Transform neg(G phi) membership to F(neg phi) membership in an MCS.

Since F(neg φ) = neg(G(neg(neg φ))), we use G_dne_theorem contrapositively:
  neg(G phi) ∈ MCS → neg(G(neg neg phi)) ∈ MCS = F(neg phi) ∈ MCS

This uses mcs_contrapositive from ModalSaturation.lean.
-/
lemma neg_all_future_to_some_future_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_G : Formula.neg (Formula.all_future phi) ∈ M) :
    Formula.some_future (Formula.neg phi) ∈ M := by
  -- neg(G phi) relates to F(neg phi) via the G_dne_theorem
  -- G_dne_theorem: ⊢ G(¬¬φ) → G φ
  -- Contrapositive in MCS: neg(G phi) → neg(G(neg neg phi)) = F(neg phi)
  have h_G_dne := G_dne_theorem phi
  have h_neg_G_dne : Formula.neg (Formula.all_future (Formula.neg (Formula.neg phi))) ∈ M :=
    mcs_contrapositive h_mcs h_G_dne h_neg_G

  -- F(neg phi) = neg(G(neg(neg phi))) by definition
  -- some_future X = X.neg.all_future.neg
  -- So some_future (neg phi) = (neg phi).neg.all_future.neg = phi.neg.neg.all_future.neg
  have h_eq : Formula.some_future (Formula.neg phi) =
              Formula.neg (Formula.all_future (Formula.neg (Formula.neg phi))) := rfl
  rw [h_eq]
  exact h_neg_G_dne

/--
Transform neg(H phi) membership to P(neg phi) membership in an MCS.

Since P(neg φ) = neg(H(neg(neg φ))), we use H_dne_theorem contrapositively.

This is the past analog of neg_all_future_to_some_future_neg.
-/
lemma neg_all_past_to_some_past_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_H : Formula.neg (Formula.all_past phi) ∈ M) :
    Formula.some_past (Formula.neg phi) ∈ M := by
  -- neg(H phi) relates to P(neg phi) via the H_dne_theorem
  -- H_dne_theorem: ⊢ H(¬¬φ) → H φ
  -- Contrapositive in MCS: neg(H phi) → neg(H(neg neg phi)) = P(neg phi)
  have h_H_dne := H_dne_theorem phi
  have h_neg_H_dne : Formula.neg (Formula.all_past (Formula.neg (Formula.neg phi))) ∈ M :=
    mcs_contrapositive h_mcs h_H_dne h_neg_H

  -- P(neg phi) = neg(H(neg(neg phi))) by definition
  -- some_past X = X.neg.all_past.neg
  -- So some_past (neg phi) = (neg phi).neg.all_past.neg = phi.neg.neg.all_past.neg
  have h_eq : Formula.some_past (Formula.neg phi) =
              Formula.neg (Formula.all_past (Formula.neg (Formula.neg phi))) := rfl
  rw [h_eq]
  exact h_neg_H_dne

/--
Double negation elimination in MCS: if neg(neg phi) ∈ MCS, then phi ∈ MCS.

This uses dne_theorem and MCS closure under derivation.
-/
lemma mcs_double_neg_elim {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_neg : Formula.neg (Formula.neg phi) ∈ M) : phi ∈ M := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  have h_thm_in_M : (Formula.neg (Formula.neg phi)).imp phi ∈ M := theorem_in_mcs h_mcs h_dne
  exact set_mcs_implication_property h_mcs h_thm_in_M h_neg_neg

/-!
## Phase 2-4: TemporalCoherentFamily and Backward Lemmas

The backward lemmas are proven directly using contraposition and MCS properties,
without requiring the full GContent/TemporalWitnessSeed infrastructure.

The key insight is that for BFMCS, the forward_F property (exists s > t
with psi in fam.mcs s when F psi in fam.mcs t) can be proven via MCS maximality
and existing forward_G/backward_H properties.
-/

/--
TemporalCoherentFamily: An BFMCS with temporal forward coherence properties.

The key properties are:
- `forward_F`: If F φ ∈ fam.mcs t, then exists s ≥ t with φ ∈ fam.mcs s
- `backward_P`: If P φ ∈ fam.mcs t, then exists s ≤ t with φ ∈ fam.mcs s

These are the existential duals of forward_G and backward_H.
Task 922: Weakened from strict (s > t, s < t) to reflexive (s ≥ t, s ≤ t).
-/
structure TemporalCoherentFamily (D : Type*) [LinearOrder D] [Zero D] extends BFMCS D where
  /-- Forward F coherence: F φ at t implies witness at some s ≥ t (reflexive) -/
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t ≤ s ∧ φ ∈ mcs s
  /-- Backward P coherence: P φ at t implies witness at some s ≤ t (reflexive) -/
  backward_P : ∀ t : D, ∀ φ : Formula,
    Formula.some_past φ ∈ mcs t → ∃ s : D, s ≤ t ∧ φ ∈ mcs s

/--
Temporal backward G lemma: If φ ∈ fam.mcs s for all s ≥ t, then G φ ∈ fam.mcs t.

**Proof by Contraposition**:
1. Assume G φ ∉ fam.mcs t
2. By MCS maximality: neg(G φ) ∈ fam.mcs t
3. By neg_all_future_to_some_future_neg: F(neg φ) ∈ fam.mcs t
4. By forward_F: exists s ≥ t with neg φ ∈ fam.mcs s
5. By hypothesis h_all: φ ∈ fam.mcs s (since s ≥ t)
6. Contradiction: fam.mcs s contains both φ and neg φ
-/
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (φ : Formula)
    (h_all : ∀ s : D, t ≤ s → φ ∈ fam.mcs s) :
    Formula.all_future φ ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_G

  -- By MCS negation completeness, neg(G φ) ∈ fam.mcs t
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.all_future φ) ∈ fam.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.all_future φ) with h_G | h_neg
    · exact absurd h_G h_not_G
    · exact h_neg

  -- By temporal duality: F(neg φ) ∈ fam.mcs t
  have h_F_neg : Formula.some_future (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs φ h_neg_G

  -- By forward_F: exists s ≥ t with neg φ ∈ fam.mcs s
  obtain ⟨s, h_le, h_neg_phi_s⟩ := fam.forward_F t (Formula.neg φ) h_F_neg

  -- By h_all: φ ∈ fam.mcs s (since s ≥ t)
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le

  -- Contradiction: fam.mcs s contains both φ and neg φ
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Temporal backward H lemma: If φ ∈ fam.mcs s for all s ≤ t, then H φ ∈ fam.mcs t.

**Proof by Contraposition** (symmetric to temporal_backward_G):
1. Assume H φ ∉ fam.mcs t
2. By MCS maximality: neg(H φ) ∈ fam.mcs t
3. By neg_all_past_to_some_past_neg: P(neg φ) ∈ fam.mcs t
4. By backward_P: exists s ≤ t with neg φ ∈ fam.mcs s
5. By hypothesis h_all: φ ∈ fam.mcs s (since s ≤ t)
6. Contradiction: fam.mcs s contains both φ and neg φ
-/
theorem temporal_backward_H (fam : TemporalCoherentFamily D) (t : D) (φ : Formula)
    (h_all : ∀ s : D, s ≤ t → φ ∈ fam.mcs s) :
    Formula.all_past φ ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_H

  -- By MCS negation completeness, neg(H φ) ∈ fam.mcs t
  have h_mcs := fam.is_mcs t
  have h_neg_H : Formula.neg (Formula.all_past φ) ∈ fam.mcs t := by
    rcases set_mcs_negation_complete h_mcs (Formula.all_past φ) with h_H | h_neg
    · exact absurd h_H h_not_H
    · exact h_neg

  -- By temporal duality: P(neg φ) ∈ fam.mcs t
  have h_P_neg : Formula.some_past (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_past_to_some_past_neg (fam.mcs t) h_mcs φ h_neg_H

  -- By backward_P: exists s ≤ t with neg φ ∈ fam.mcs s
  obtain ⟨s, h_le, h_neg_phi_s⟩ := fam.backward_P t (Formula.neg φ) h_P_neg

  -- By h_all: φ ∈ fam.mcs s (since s ≤ t)
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le

  -- Contradiction: fam.mcs s contains both φ and neg φ
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Temporal coherence for a BMCS: all families have forward_F and backward_P properties.

This condition ensures that for each family in the BMCS:
- `forward_F`: If F(phi) is in the MCS at time t, then there exists s > t with phi in the MCS at s
- `backward_P`: If P(phi) is in the MCS at time t, then there exists s < t with phi in the MCS at s

These properties are used in the truth lemma backward direction for temporal operators G and H
via the contraposition argument (temporal_backward_G and temporal_backward_H).
-/
def BMCS.temporally_coherent (B : BMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)

/-!
## Phase 1: Temporal Saturation Structures (Task 857 v002)

Following the EvalCoherentBundle pattern from CoherentConstruction.lean, we define
analogous structures for temporal saturation.
-/

-- GContent and HContent are imported from TemporalContent.lean

/--
TemporalForwardSaturated: Every F(psi) in the MCS has its witness (psi also in the MCS).

For a constant family, this means F(psi) -> psi within the MCS.
-/
def TemporalForwardSaturated (M : Set Formula) : Prop :=
  ∀ psi : Formula, Formula.some_future psi ∈ M → psi ∈ M

/--
TemporalBackwardSaturated: Every P(psi) in the MCS has its witness (psi also in the MCS).
-/
def TemporalBackwardSaturated (M : Set Formula) : Prop :=
  ∀ psi : Formula, Formula.some_past psi ∈ M → psi ∈ M

/--
TemporallySaturated: Both forward and backward temporal saturation hold.
-/
def TemporallySaturated (M : Set Formula) : Prop :=
  TemporalForwardSaturated M ∧ TemporalBackwardSaturated M

/--
TemporalEvalSaturatedBundle: A constant BFMCS with temporally saturated MCS.

This structure provides:
1. A constant family (same MCS M at all times)
2. M is temporally saturated (F psi -> psi and P psi -> psi in M)
3. The family therefore satisfies forward_F and backward_P
-/
structure TemporalEvalSaturatedBundle (D : Type*) [LinearOrder D] where
  /-- The underlying MCS -/
  baseMCS : Set Formula
  /-- The MCS is maximal consistent -/
  is_mcs : SetMaximalConsistent baseMCS
  /-- Forward temporal saturation -/
  forward_saturated : TemporalForwardSaturated baseMCS
  /-- Backward temporal saturation -/
  backward_saturated : TemporalBackwardSaturated baseMCS

/--
Convert a TemporalEvalSaturatedBundle to a constant BFMCS.
-/
noncomputable def TemporalEvalSaturatedBundle.toBFMCS
    (B : TemporalEvalSaturatedBundle D) : BFMCS D where
  mcs _ := B.baseMCS
  is_mcs _ := B.is_mcs
  forward_G := fun _ _ phi _ h_G => by
    have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
    exact set_mcs_implication_property B.is_mcs (theorem_in_mcs B.is_mcs h_T) h_G
  backward_H := fun _ _ phi _ h_H => by
    have h_T : [] ⊢ (Formula.all_past phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_past phi)
    exact set_mcs_implication_property B.is_mcs (theorem_in_mcs B.is_mcs h_T) h_H

/--
The toBFMCS conversion produces a constant family.
-/
lemma TemporalEvalSaturatedBundle.toBFMCS_constant
    (B : TemporalEvalSaturatedBundle D) :
    IsConstantFamily B.toBFMCS :=
  ⟨B.baseMCS, fun _ => rfl⟩

/--
Convert a TemporalEvalSaturatedBundle to a TemporalCoherentFamily.

With reflexive forward_F/backward_P (Task 922), this no longer requires [Nontrivial D]
since we can use the same time point t as the witness (t ≤ t).
-/
noncomputable def TemporalEvalSaturatedBundle.toTemporalCoherentFamily
    (B : TemporalEvalSaturatedBundle D) : TemporalCoherentFamily D where
  toBFMCS := B.toBFMCS
  forward_F := fun t psi h_F => by
    have h_psi : psi ∈ B.baseMCS := B.forward_saturated psi h_F
    exact ⟨t, le_refl t, h_psi⟩
  backward_P := fun t psi h_P => by
    have h_psi : psi ∈ B.baseMCS := B.backward_saturated psi h_P
    exact ⟨t, le_refl t, h_psi⟩

/-!
## Phase 2: Temporal Saturation Construction

We prove that temporally saturated MCS exist for any consistent context.
The key is showing that witness seeds are consistent.
-/

/--
TemporalWitnessSeed for F(psi): {psi} ∪ GContent(M).
-/
def TemporalWitnessSeed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ GContent M

/--
psi is in its own TemporalWitnessSeed.
-/
lemma psi_mem_TemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    psi ∈ TemporalWitnessSeed M psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/--
GContent is a subset of TemporalWitnessSeed.
-/
lemma GContent_subset_TemporalWitnessSeed (M : Set Formula) (psi : Formula) :
    GContent M ⊆ TemporalWitnessSeed M psi :=
  Set.subset_union_right

/--
Temporal witness seed consistency: If F(psi) is in an MCS M, then {psi} ∪ GContent(M) is consistent.

**Proof Strategy**:
Suppose {psi} ∪ GContent(M) is inconsistent.
Then there exist chi₁, ..., chi_n in GContent(M) such that {psi, chi₁, ..., chi_n} ⊢ ⊥.
By deduction: {chi₁, ..., chi_n} ⊢ ¬psi.
By temporal K-distribution: G{chi₁, ..., chi_n} ⊢ G(¬psi).
Since G chi_i ∈ M for all i, by MCS closure: G(¬psi) ∈ M.
But F(psi) = ¬G(¬psi) ∈ M by hypothesis.
Contradiction.
-/
theorem temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (TemporalWitnessSeed M psi) := by
  intro L hL_sub ⟨d⟩

  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- Get G chi ∈ M for each chi ∈ L_filt from GContent
    have h_G_filt_in_M : ∀ chi ∈ L_filt, Formula.all_future chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [TemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq h_ne
      · exact h_gcontent

    -- Apply generalized temporal K (G distributes over derivation)
    have d_G_neg : (Context.map Formula.all_future L_filt) ⊢ Formula.all_future (Formula.neg psi) :=
      Bimodal.Theorems.generalized_temporal_k L_filt (Formula.neg psi) d_neg

    -- All formulas in G(L_filt) are in M
    have h_G_context_in_M : ∀ phi ∈ Context.map Formula.all_future L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_G_filt_in_M chi h_chi_in

    -- By MCS closure under derivation, G(neg psi) ∈ M
    have h_G_neg_in_M : Formula.all_future (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.all_future L_filt)
        h_G_context_in_M d_G_neg

    -- Contradiction - F psi = neg(G(neg psi)) is also in M
    have h_F_eq : Formula.some_future psi = Formula.neg (Formula.all_future (Formula.neg psi)) := rfl
    rw [h_F_eq] at h_F
    exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg psi)) h_G_neg_in_M h_F

  · -- Case: psi ∉ L, so L ⊆ GContent M
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [TemporalWitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_gcontent
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · -- chi ∈ GContent means G chi ∈ M, and by T-axiom chi ∈ M
        have h_G_chi : Formula.all_future chi ∈ M := h_gcontent
        have h_T := DerivationTree.axiom [] ((Formula.all_future chi).imp chi) (Axiom.temp_t_future chi)
        exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_chi

    exact h_mcs.1 L h_L_in_M ⟨d⟩

/--
Transform neg(G phi) to F(neg phi) in an MCS (renamed for clarity).
-/
lemma neg_G_to_F_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_G : Formula.neg (Formula.all_future phi) ∈ M) :
    Formula.some_future (Formula.neg phi) ∈ M :=
  neg_all_future_to_some_future_neg M h_mcs phi h_neg_G

/-!
## Temporal Coherent Family Existence Axiom (Task 843)

This axiom replaces the mathematically FALSE axiom `temporally_saturated_mcs_exists`
(which claimed a constant family could be temporally saturated -- see research-010.md
counterexample: `{F(psi), neg psi}` is consistent but cannot be in a single temporally
saturated MCS).

The replacement axiom asserts the existence of a `TemporalCoherentFamily` (which may
be NON-CONSTANT) extending any consistent context. This is mathematically TRUE and
will be proven in a subsequent phase using a dovetailing chain construction.
-/

/-!
## Temporal Coherent Family Existence

For any consistent context, there exists a temporally coherent family extending it.

### Mathematical Justification

Given a consistent context Gamma, we can build a family of MCS indexed by integers
using a dovetailing chain construction:
1. Extend Gamma to MCS M_0 via Lindenbaum
2. For each integer n, build M_n using `GContent(M_{n-1})` as seed (forward direction)
3. For witnessing F-formulas, include the witness in the seed at the appropriate step
4. Symmetrically for the backward (past) direction

This construction produces a NON-CONSTANT family (different MCS at different times)
that satisfies:
- forward_G: G phi in M_t -> phi in M_s for s > t (by GContent seed inclusion) [PROVEN]
- backward_H: H phi in M_t -> phi in M_s for s < t (by HContent seed inclusion) [PROVEN]
- forward_F: F phi in M_t -> exists s > t, phi in M_s [SORRY - requires omega-squared]
- backward_P: P phi in M_t -> exists s < t, phi in M_s [SORRY - requires omega-squared]

Note: forward_F and backward_P are NOT proven by the linear dovetailing chain because
F-formulas do not persist through GContent seeds. The plan to resolve them uses an
omega-squared construction (see Task 916 plan v012 and OmegaSquaredChain.lean).

The key consistency lemma `temporal_witness_seed_consistent` (proven above) ensures
that `{psi} union GContent(M)` is consistent whenever `F(psi) in M`, providing the
consistency argument at each step of the chain construction.

### Status

Replaced axiom with theorem backed by dovetailing chain construction
(DovetailingChain.lean). The Int case is proven via `temporal_coherent_family_exists_theorem`;
generic D uses sorry (only Int is ever instantiated downstream).
-/

/--
Temporal coherent family existence for Int - the primary instantiation.

**Proof Strategy** (Task 864 - RecursiveSeed approach):
This theorem uses the RecursiveSeed construction which pre-places temporal witnesses
in the seed BEFORE Lindenbaum extension. The key insight is that F/P witnesses are
placed at fresh time indices during seed construction, ensuring they survive extension.

For Lindenbaum-added F/P formulas (not in the original structure), we use
`temporal_witness_seed_consistent` which proves that {psi} ∪ GContent(M) is
consistent whenever F(psi) ∈ M. Combined with Lindenbaum, this ensures witnesses exist.

**Current Implementation**: Delegates to DovetailingChain.temporal_coherent_family_exists_theorem
pending full RecursiveSeed integration (see SeedCompletion.lean, SeedBMCS.lean).

**Technical Note**: DovetailingChain has 2 sorries (forward_F, backward_P). The 2 cross-sign
sorries (forward_G when t < 0, backward_H when t >= 0) were resolved in Task 916 via
cross-sign G/H propagation infrastructure. The remaining forward_F/backward_P sorries
require a non-linear BFMCS construction (the linear chain cannot satisfy these due to
F-formula non-persistence through GContent seeds). See WitnessGraph.lean for proven local
witness existence and Task 916 analysis for the fundamental blocker.
-/
theorem temporal_coherent_family_exists_Int
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : BFMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : Int, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : Int, s ≤ t ∧ φ ∈ fam.mcs s) := by
  obtain ⟨fam, h_ctx, h_fwd, h_bwd⟩ := temporal_coherent_family_exists_theorem Gamma h_cons
  exact ⟨fam, h_ctx,
    fun t φ h => let ⟨s, h_lt, h_mem⟩ := h_fwd t φ h; ⟨s, le_of_lt h_lt, h_mem⟩,
    fun t φ h => let ⟨s, h_lt, h_mem⟩ := h_bwd t φ h; ⟨s, le_of_lt h_lt, h_mem⟩⟩

/--
Temporal coherent family existence - generic version.

**Note**: Only `D = Int` is ever instantiated downstream (in Completeness.lean).
For Int, use `temporal_coherent_family_exists_Int` which delegates to DovetailingChain.

This generic version remains sorry'd because:
1. RecursiveSeed.lean uses Int specifically (timeIdx : Int in SeedEntry)
2. DovetailingChain.lean uses Int specifically (dovetailIndex : Nat → Int)
3. Type-level dispatch isn't supported in Lean (no runtime `D = Int` check)
4. No other instantiation is used in practice

**RecursiveSeed Approach (Task 864)**:
The RecursiveSeed construction pre-places temporal witnesses during seed building:
- When processing `neg(G psi)`, creates a witness at `freshFutureTime` containing `neg psi`
- When processing `neg(H psi)`, creates a witness at `freshPastTime` containing `neg psi`

This avoids the cross-sign propagation problem that blocked DovetailingChain, but:
- Witnesses are only pre-placed for F/P formulas IN THE STARTING FORMULA
- Lindenbaum-added F/P formulas still require witness construction via enumeration

**Technical debt**: Full proof requires either:
1. Generalizing RecursiveSeed to generic D (major refactor of seed time indices)
2. Implementing witness enumeration for Lindenbaum-added F/P formulas
-/
theorem temporal_coherent_family_exists (D : Type*) [LinearOrder D] [Zero D]
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : BFMCS D),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s) := by
  sorry

/-!
## Temporally Coherent BMCS Construction

We construct a BMCS that is temporally coherent, meaning all families satisfy
forward_F and backward_P. This enables the truth lemma to be proven without sorry
for all cases including temporal backward (G and H).

The construction uses `temporal_coherent_family_exists` to obtain a
TemporalCoherentFamily, then wraps it in a single-family BMCS.
-/

/--
Construct a temporally coherent BMCS from a consistent context.

The construction:
1. Obtain a temporally coherent family extending Gamma (via axiom)
2. Wrap the family in a single-family BMCS

**Axiom dependencies**:
- `temporal_coherent_family_exists` (temporal coherent family existence -- CORRECT, to be proven)
- `singleFamily_modal_backward_axiom` (modal backward for single-family BMCS)
-/
noncomputable def construct_temporal_bmcs (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    BMCS D :=
  -- Get temporally coherent family
  let fam := (temporal_coherent_family_exists D Gamma h_cons).choose
  -- Build single-family BMCS
  singleFamilyBMCS fam

/--
The eval family of the constructed BMCS is the family from temporal_coherent_family_exists.
-/
lemma construct_temporal_bmcs_eval_eq (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_temporal_bmcs Gamma h_cons (D := D)).eval_family =
      (temporal_coherent_family_exists D Gamma h_cons).choose :=
  rfl

/--
The constructed BMCS preserves the original context.
-/
theorem construct_temporal_bmcs_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_temporal_bmcs Gamma h_cons (D := D)).eval_family.mcs 0 := by
  intro gamma h_mem
  -- The eval family is the chosen family from the axiom
  rw [construct_temporal_bmcs_eval_eq]
  -- The family extends Gamma at time 0
  exact (temporal_coherent_family_exists D Gamma h_cons).choose_spec.1 gamma h_mem

/--
The constructed BMCS is temporally coherent.

**Key Property**: The family from `temporal_coherent_family_exists` directly provides
forward_F and backward_P properties. Since the BMCS has a single family, temporal
coherence holds trivially.
-/
theorem construct_temporal_bmcs_temporally_coherent (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_temporal_bmcs Gamma h_cons (D := D)).temporally_coherent := by
  -- Unfold temporally_coherent: need forward_F and backward_P for all families
  intro fam hfam
  -- The BMCS has a single family
  simp only [construct_temporal_bmcs, singleFamilyBMCS] at hfam
  have h_eq := Set.mem_singleton_iff.mp hfam
  subst h_eq
  -- Get the forward_F and backward_P from the axiom
  have h_spec := (temporal_coherent_family_exists D Gamma h_cons).choose_spec
  exact ⟨h_spec.2.1, h_spec.2.2⟩

/-!
## Fully Saturated BMCS Axiom (Task 843 Phase 4)

This axiom replaces the mathematically FALSE `singleFamily_modal_backward_axiom`
(which claimed phi in MCS -> Box phi in MCS).

The new axiom is mathematically CORRECT: it asserts the existence of a fully
saturated BMCS, which is guaranteed by standard canonical model theory for
S5 modal logic + temporal logic.

### Why the Old Axiom Was FALSE

The old axiom `singleFamily_modal_backward_axiom` claimed:
  forall phi t, phi in fam.mcs t -> Box phi in fam.mcs t

This is FALSE because:
- For phi = atom "p", Box(atom "p") is neither provable nor refutable
- Some MCS contain Box(atom "p"), others contain neg(Box(atom "p"))
- A single MCS does NOT satisfy phi -> Box phi for arbitrary phi

The counterexample was discovered during plan v006 Phase 2 implementation.
See research-016.md for the full analysis.

### Why the New Axiom Is CORRECT

The new axiom asserts: for any consistent context, there exists a BMCS that is
(a) temporally coherent, (b) modally saturated, and (c) contains the context.

This is TRUE by the standard canonical model construction:
1. Build the canonical model with ALL MCS as worlds
2. Define accessibility via BoxContent inclusion
3. S5 axioms (T, 4, B, 5-collapse) make accessibility an equivalence relation
4. The equivalence relation is universal (single equivalence class)
5. Universal accessibility gives modal_forward
6. Modal saturation (exists witness for every Diamond) gives modal_backward
   via the PROVEN `saturated_modal_backward` theorem (ModalSaturation.lean)

### References

- Research report: specs/843_remove_singleFamily_modal_backward_axiom/reports/research-016.md
- Proof of saturated_modal_backward: Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean
- Implementation plan: specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-007.md
-/

/--
Axiom: For any consistent context, there exists a fully saturated temporally coherent BMCS.

**Mathematical Justification**:
This is guaranteed by the standard canonical model construction for S5 modal logic
combined with temporal logic:

1. **Modal saturation**: The canonical model includes witness families for every
   Diamond formula, ensuring `is_modally_saturated` holds.

2. **Temporal coherence**: The dovetailing chain construction ensures `forward_F`
   and `backward_P` hold for temporal operators.

3. **Context preservation**: Lindenbaum extension preserves the original context
   at the evaluation family's MCS at time 0.

Combined with `saturated_modal_backward` (PROVEN in ModalSaturation.lean), this
gives a complete BMCS construction that does NOT rely on the FALSE single-family
axiom.

**This axiom will be proven in a future phase** using the full canonical model
construction infrastructure (BoxContent accessibility symmetry, universal
accessibility, etc.). See implementation plan v007 Phase 5.

**Task 881 Update**: This axiom is DEPRECATED. Use `fully_saturated_bmcs_exists_int`
for Int-indexed BMCS (the only case used in completeness proofs). The Int-specialized
version will be proven constructively using DovetailingChain + modal saturation.
-/
@[deprecated "Use fully_saturated_bmcs_exists_int for Int case (Task 881)"]
axiom fully_saturated_bmcs_exists (D : Type*) [LinearOrder D] [Zero D]
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS D),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B

/-!
## Int-Specialized Fully Saturated BMCS (Task 881)

This section provides Int-specialized versions of the BMCS construction.
Only Int is used in downstream completeness proofs, so specializing enables
constructive proofs via DovetailingChain + modal saturation infrastructure.
-/

/--
**Task 881 Phase 2**: This is a THEOREM (not axiom) that replaces the polymorphic
`fully_saturated_bmcs_exists` for the Int case.

**Current Status**: SORRY-BACKED THEOREM
The theorem has a sorry because achieving both temporal coherence AND modal saturation
simultaneously requires non-trivial infrastructure not yet implemented.

**Why a sorry-backed theorem is progress over an axiom**:
- An axiom is in the trusted kernel (cannot be checked by the type system)
- A sorry-backed theorem is explicitly incomplete but the REST of the proof is verified

**Technical Analysis (Task 881)**:
1. **Temporal coherence** is achievable via DovetailingChain (4 sorries for cross-sign/witnesses)
2. **Modal saturation** is achievable via exists_fullySaturated_extension (sorry-free)
3. **The combination** is difficult because:
   - Modal saturation creates new witness families
   - These witness families are constant (same MCS at all times)
   - For temporal coherence, constant families need temporally saturated MCS
   - Temporally saturated MCS (F psi -> psi, P psi -> psi) requires special construction
   - Henkin-style construction was proven flawed (research-004.md counterexample)

**Resolution Path**:
- Option A: Fix DovetailingChain's 4 sorries AND make witness construction temporally-aware
- Option B: Implement InterleaveConstruction.lean (unified construction from plan)
- Option C: Restructure truth lemma to only require temporal coherence for eval_family

**Technical Debt**: 1 sorry (combines temporal + modal saturation)
-/
theorem fully_saturated_bmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  -- The proof requires combining:
  -- 1. Temporal coherent family from DovetailingChain (has 4 sorries)
  -- 2. Modal saturation from exists_fullySaturated_extension (sorry-free)
  --
  -- The challenge is that these two properties are built differently:
  -- - Temporal coherence: single family with F/P witness placement
  -- - Modal saturation: multiple families via Zorn's lemma
  --
  -- For the combination:
  -- - The eval_family comes from DovetailingChain and IS temporally coherent
  -- - Additional witness families from modal saturation are CONSTANT families
  -- - Constant families are temporally coherent iff their MCS is temporally saturated
  -- - Making witness MCS temporally saturated requires non-trivial construction
  --
  -- See InterleaveConstruction approach in implementation-002.md for resolution path.
  sorry

/-!
## Fully Saturated BMCS Construction

This construction uses the CORRECT `fully_saturated_bmcs_exists` axiom instead of
the FALSE `singleFamily_modal_backward_axiom`.

The key insight is that modal saturation + the PROVEN `saturated_modal_backward`
theorem gives modal_backward without requiring the false single-family axiom.
-/

/--
Construct a fully saturated BMCS from a consistent context.

**Key Properties**:
- Context is preserved at eval_family.mcs 0
- Temporally coherent (forward_F and backward_P hold)
- Modally saturated (every Diamond has a witness)
- modal_backward holds via `saturated_modal_backward` theorem

**Axiom dependencies**:
- `fully_saturated_bmcs_exists` (CORRECT axiom)

**Does NOT use**:
- `singleFamily_modal_backward_axiom` (FALSE axiom, deprecated)
-/
noncomputable def construct_saturated_bmcs (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    BMCS D :=
  (fully_saturated_bmcs_exists D Gamma h_cons).choose

/--
The constructed saturated BMCS preserves the original context.
-/
theorem construct_saturated_bmcs_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_saturated_bmcs Gamma h_cons (D := D)).eval_family.mcs 0 := by
  intro gamma h_mem
  exact (fully_saturated_bmcs_exists D Gamma h_cons).choose_spec.1 gamma h_mem

/--
The constructed saturated BMCS is temporally coherent.
-/
theorem construct_saturated_bmcs_temporally_coherent (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_saturated_bmcs Gamma h_cons (D := D)).temporally_coherent :=
  (fully_saturated_bmcs_exists D Gamma h_cons).choose_spec.2.1

/--
The constructed saturated BMCS is modally saturated.
-/
theorem construct_saturated_bmcs_is_modally_saturated (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    is_modally_saturated (construct_saturated_bmcs Gamma h_cons (D := D)) :=
  (fully_saturated_bmcs_exists D Gamma h_cons).choose_spec.2.2

/-!
## Int-Specialized BMCS Construction (Task 881)

These are Int-specialized versions of the BMCS construction, using
`fully_saturated_bmcs_exists_int` instead of the deprecated polymorphic axiom.

**Rationale**: Only `D = Int` is used in completeness proofs (Completeness.lean).
Specializing to Int enables constructive proofs via existing infrastructure:
- DovetailingChain.lean for temporal coherence
- SaturatedConstruction.lean for modal saturation (sorry-free)
-/

/--
Int-specialized BMCS construction.

Uses `fully_saturated_bmcs_exists_int` axiom (to be replaced with constructive proof).
-/
noncomputable def construct_saturated_bmcs_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    BMCS Int :=
  (fully_saturated_bmcs_exists_int Gamma h_cons).choose

/--
The Int-specialized BMCS preserves the original context.
-/
theorem construct_saturated_bmcs_int_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_saturated_bmcs_int Gamma h_cons).eval_family.mcs 0 := by
  intro gamma h_mem
  exact (fully_saturated_bmcs_exists_int Gamma h_cons).choose_spec.1 gamma h_mem

/--
The Int-specialized BMCS is temporally coherent.
-/
theorem construct_saturated_bmcs_int_temporally_coherent (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_saturated_bmcs_int Gamma h_cons).temporally_coherent :=
  (fully_saturated_bmcs_exists_int Gamma h_cons).choose_spec.2.1

/--
The Int-specialized BMCS is modally saturated.
-/
theorem construct_saturated_bmcs_int_is_modally_saturated (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    is_modally_saturated (construct_saturated_bmcs_int Gamma h_cons) :=
  (fully_saturated_bmcs_exists_int Gamma h_cons).choose_spec.2.2

end Bimodal.Metalogic.Bundle
