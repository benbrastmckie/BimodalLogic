import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
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

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

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

The key insight is that for IndexedMCSFamily, the forward_F property (exists s > t
with psi in fam.mcs s when F psi in fam.mcs t) can be proven via MCS maximality
and existing forward_G/backward_H properties.
-/

/--
TemporalCoherentFamily: An IndexedMCSFamily with temporal forward coherence properties.

The key properties are:
- `forward_F`: If F φ ∈ fam.mcs t, then exists s > t with φ ∈ fam.mcs s
- `backward_P`: If P φ ∈ fam.mcs t, then exists s < t with φ ∈ fam.mcs s

These are the existential duals of forward_G and backward_H.
-/
structure TemporalCoherentFamily (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] extends IndexedMCSFamily D where
  /-- Forward F coherence: F φ at t implies witness at some s > t -/
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
  /-- Backward P coherence: P φ at t implies witness at some s < t -/
  backward_P : ∀ t : D, ∀ φ : Formula,
    Formula.some_past φ ∈ mcs t → ∃ s : D, s < t ∧ φ ∈ mcs s

/--
Temporal backward G lemma: If φ ∈ fam.mcs s for all s ≥ t, then G φ ∈ fam.mcs t.

**Proof by Contraposition**:
1. Assume G φ ∉ fam.mcs t
2. By MCS maximality: neg(G φ) ∈ fam.mcs t
3. By neg_all_future_to_some_future_neg: F(neg φ) ∈ fam.mcs t
4. By forward_F: exists s > t with neg φ ∈ fam.mcs s
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

  -- By forward_F: exists s > t with neg φ ∈ fam.mcs s
  obtain ⟨s, h_lt, h_neg_phi_s⟩ := fam.forward_F t (Formula.neg φ) h_F_neg

  -- By h_all: φ ∈ fam.mcs s (since s ≥ t, and s > t implies s ≥ t)
  have h_phi_s : φ ∈ fam.mcs s := h_all s (le_of_lt h_lt)

  -- Contradiction: fam.mcs s contains both φ and neg φ
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Temporal backward H lemma: If φ ∈ fam.mcs s for all s ≤ t, then H φ ∈ fam.mcs t.

**Proof by Contraposition** (symmetric to temporal_backward_G):
1. Assume H φ ∉ fam.mcs t
2. By MCS maximality: neg(H φ) ∈ fam.mcs t
3. By neg_all_past_to_some_past_neg: P(neg φ) ∈ fam.mcs t
4. By backward_P: exists s < t with neg φ ∈ fam.mcs s
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

  -- By backward_P: exists s < t with neg φ ∈ fam.mcs s
  obtain ⟨s, h_lt, h_neg_phi_s⟩ := fam.backward_P t (Formula.neg φ) h_P_neg

  -- By h_all: φ ∈ fam.mcs s (since s ≤ t, and s < t implies s ≤ t)
  have h_phi_s : φ ∈ fam.mcs s := h_all s (le_of_lt h_lt)

  -- Contradiction: fam.mcs s contains both φ and neg φ
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

end Bimodal.Metalogic.Bundle
