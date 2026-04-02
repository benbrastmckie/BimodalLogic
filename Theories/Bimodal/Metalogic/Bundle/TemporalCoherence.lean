import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Syntax.SubformulaClosure
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Temporal Coherence Core

This module contains the core temporal coherence definitions and backward lemmas
needed for the truth lemma. Extracted from TemporalCoherentConstruction.lean
as part of publication cleanup.

## Main Definitions

- `TemporalCoherentFamily`: FMCS with forward_F and backward_P coherence
- `BFMCS.temporally_coherent`: Predicate for BFMCS with coherent families
- `temporal_backward_G`: If phi in all s > t, then G(phi) in fam.mcs t
- `temporal_backward_H`: If phi in all s < t, then H(phi) in fam.mcs t

## Key Insight

The backward lemmas are proven by contraposition:
1. Assume G(phi) not in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By temporal duality: F(neg phi) in fam.mcs t
4. By forward_F: exists s > t with neg(phi) in fam.mcs s
5. But by hypothesis: phi in fam.mcs s -- contradiction

## References

- Extracted from deprecated TemporalCoherentConstruction.lean
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [Preorder D] [Zero D]

/-!
## Temporal Duality Infrastructure

These lemmas establish the transformation from neg(G phi) to F(neg phi) in MCS context,
enabling the contraposition argument for temporal backward proofs.
-/

/--
G distributes over double negation elimination: G(neg(neg phi)) -> G(phi)

**Proof Strategy**:
1. dne_theorem: neg(neg phi) -> phi
2. temporal_necessitation: G(neg(neg phi) -> phi)
3. temp_k_dist: G(A -> B) -> (G(A) -> G(B))
4. modus_ponens
-/
noncomputable def G_dne_theorem (phi : Formula) :
    [] ⊢ (Formula.all_future (Formula.neg (Formula.neg phi))).imp (Formula.all_future phi) := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  have h_G_dne : [] ⊢ Formula.all_future ((Formula.neg (Formula.neg phi)).imp phi) :=
    DerivationTree.temporal_necessitation _ h_dne
  have h_K : [] ⊢ (Formula.all_future ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.all_future (Formula.neg (Formula.neg phi))).imp (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist _ _)
  exact DerivationTree.modus_ponens [] _ _ h_K h_G_dne

/--
H distributes over double negation elimination: H(neg(neg phi)) -> H(phi)

Past analog of G_dne_theorem.
-/
noncomputable def H_dne_theorem (phi : Formula) :
    [] ⊢ (Formula.all_past (Formula.neg (Formula.neg phi))).imp (Formula.all_past phi) := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  have h_H_dne : [] ⊢ Formula.all_past ((Formula.neg (Formula.neg phi)).imp phi) :=
    Bimodal.Theorems.past_necessitation _ h_dne
  have h_K : [] ⊢ (Formula.all_past ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.all_past (Formula.neg (Formula.neg phi))).imp (Formula.all_past phi)) :=
    Bimodal.Theorems.past_k_dist _ _
  exact DerivationTree.modus_ponens [] _ _ h_K h_H_dne

/--
Transform neg(G phi) membership to F(neg phi) membership in an MCS.

Since F(neg phi) = neg(G(neg(neg phi))), we use G_dne_theorem contrapositively:
  neg(G phi) in MCS -> neg(G(neg neg phi)) in MCS = F(neg phi) in MCS
-/
lemma neg_all_future_to_some_future_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_G : Formula.neg (Formula.all_future phi) ∈ M) :
    Formula.some_future (Formula.neg phi) ∈ M := by
  have h_G_dne := G_dne_theorem phi
  have h_neg_G_dne : Formula.neg (Formula.all_future (Formula.neg (Formula.neg phi))) ∈ M :=
    SetMaximalConsistent.contrapositive h_mcs h_G_dne h_neg_G
  have h_eq : Formula.some_future (Formula.neg phi) =
              Formula.neg (Formula.all_future (Formula.neg (Formula.neg phi))) := rfl
  rw [h_eq]
  exact h_neg_G_dne

/--
Transform neg(H phi) membership to P(neg phi) membership in an MCS.

Since P(neg phi) = neg(H(neg(neg phi))), we use H_dne_theorem contrapositively.
Past analog of neg_all_future_to_some_future_neg.
-/
lemma neg_all_past_to_some_past_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_H : Formula.neg (Formula.all_past phi) ∈ M) :
    Formula.some_past (Formula.neg phi) ∈ M := by
  have h_H_dne := H_dne_theorem phi
  have h_neg_H_dne : Formula.neg (Formula.all_past (Formula.neg (Formula.neg phi))) ∈ M :=
    SetMaximalConsistent.contrapositive h_mcs h_H_dne h_neg_H
  have h_eq : Formula.some_past (Formula.neg phi) =
              Formula.neg (Formula.all_past (Formula.neg (Formula.neg phi))) := rfl
  rw [h_eq]
  exact h_neg_H_dne

/--
Double negation elimination in MCS: if neg(neg phi) in MCS, then phi in MCS.

Uses dne_theorem and MCS closure under derivation.
-/
lemma SetMaximalConsistent.double_neg_elim {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_neg : Formula.neg (Formula.neg phi) ∈ M) : phi ∈ M := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dne_theorem phi
  have h_thm_in_M : (Formula.neg (Formula.neg phi)).imp phi ∈ M := theorem_in_mcs h_mcs h_dne
  exact SetMaximalConsistent.implication_property h_mcs h_thm_in_M h_neg_neg

/-!
## TemporalCoherentFamily and Backward Lemmas

The backward lemmas are proven directly using contraposition and MCS properties.
-/

/--
TemporalCoherentFamily: An FMCS with temporal forward coherence properties.

The key properties are:
- `forward_F`: If F(phi) in fam.mcs t, then exists s ≥ t with phi in fam.mcs s
- `backward_P`: If P(phi) in fam.mcs t, then exists s ≤ t with phi in fam.mcs s

These are the existential duals of forward_G and backward_H.
Uses weak inequality (s ≥ t, s ≤ t) for reflexive semantics (aligned with Truth.lean).
-/
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  /-- Forward F coherence: F(phi) at t implies witness at some s ≥ t (weak) -/
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t ≤ s ∧ φ ∈ mcs s
  /-- Backward P coherence: P(phi) at t implies witness at some s ≤ t (weak) -/
  backward_P : ∀ t : D, ∀ φ : Formula,
    Formula.some_past φ ∈ mcs t → ∃ s : D, s ≤ t ∧ φ ∈ mcs s

/--
Temporal backward G lemma: If phi in fam.mcs s for all s ≥ t, then G(phi) in fam.mcs t.

**Proof by Contraposition**:
1. Assume G(phi) not in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By neg_all_future_to_some_future_neg: F(neg phi) in fam.mcs t
4. By forward_F: exists s ≥ t with neg(phi) in fam.mcs s
5. By hypothesis h_all: phi in fam.mcs s (since s ≥ t)
6. Contradiction: fam.mcs s contains both phi and neg(phi)
-/
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (φ : Formula)
    (h_all : ∀ s : D, t ≤ s → φ ∈ fam.mcs s) :
    Formula.all_future φ ∈ fam.mcs t := by
  by_contra h_not_G
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.all_future φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future φ) with h_G | h_neg
    · exact absurd h_G h_not_G
    · exact h_neg
  have h_F_neg : Formula.some_future (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs φ h_neg_G
  obtain ⟨s, h_le, h_neg_phi_s⟩ := fam.forward_F t (Formula.neg φ) h_F_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Temporal backward H lemma: If phi in fam.mcs s for all s ≤ t, then H(phi) in fam.mcs t.

**Proof by Contraposition** (symmetric to temporal_backward_G):
1. Assume H(phi) not in fam.mcs t
2. By MCS maximality: neg(H(phi)) in fam.mcs t
3. By neg_all_past_to_some_past_neg: P(neg phi) in fam.mcs t
4. By backward_P: exists s ≤ t with neg(phi) in fam.mcs s
5. By hypothesis h_all: phi in fam.mcs s (since s ≤ t)
6. Contradiction: fam.mcs s contains both phi and neg(phi)
-/
theorem temporal_backward_H (fam : TemporalCoherentFamily D) (t : D) (φ : Formula)
    (h_all : ∀ s : D, s ≤ t → φ ∈ fam.mcs s) :
    Formula.all_past φ ∈ fam.mcs t := by
  by_contra h_not_H
  have h_mcs := fam.is_mcs t
  have h_neg_H : Formula.neg (Formula.all_past φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_past φ) with h_H | h_neg
    · exact absurd h_H h_not_H
    · exact h_neg
  have h_P_neg : Formula.some_past (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_past_to_some_past_neg (fam.mcs t) h_mcs φ h_neg_H
  obtain ⟨s, h_le, h_neg_phi_s⟩ := fam.backward_P t (Formula.neg φ) h_P_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Temporal coherence for a BFMCS: all families have forward_F and backward_P properties.

This condition ensures that for each family in the BFMCS:
- `forward_F`: If F(phi) is in the MCS at time t, then exists s ≥ t with phi in the MCS at s
- `backward_P`: If P(phi) is in the MCS at time t, then exists s ≤ t with phi in the MCS at s

These properties are used in the truth lemma backward direction for temporal operators G and H
via the contraposition argument (temporal_backward_G and temporal_backward_H).

Note: Uses weak inequality (s ≥ t, s ≤ t) to align with reflexive G/H semantics (Truth.lean).
-/
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)

/-!
## Restricted Temporal Coherence

Restricted temporal coherence only requires forward_F and backward_P for formulas
within `deferralClosure(root)`. This weaker condition suffices for the truth lemma
when evaluating formulas in `subformulaClosure(root)`, because the G/H backward
cases only invoke forward_F/backward_P on `neg(psi)` where `psi` is a subformula
of root, and `neg(psi) ∈ closureWithNeg(root) ⊆ deferralClosure(root)`.

### Key Insight

The existing `TemporalCoherentFamily` quantifies forward_F/backward_P over ALL formulas.
This is impossible to prove for the SuccChainFMCS because F-nesting is unbounded in
full MCS chains. The restricted variant only quantifies over `deferralClosure(root)`,
where F-nesting IS bounded (by `max_F_depth_in_closure`), making the coherence proof
achievable via the restricted chain construction.
-/

/--
Restricted temporal coherence for a BFMCS: all families have forward_F and backward_P
properties for formulas within `deferralClosure(root)` only.

This is the key weakening that makes canonical completeness provable. The truth lemma
for evaluating `root` only needs temporal coherence for formulas in `deferralClosure(root)`.
-/
def BFMCS.restricted_temporally_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)

/--
Full temporal coherence implies restricted temporal coherence for any root.
-/
theorem BFMCS.temporally_coherent_implies_restricted (B : BFMCS D) (root : Formula)
    (h_tc : B.temporally_coherent) : B.restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨h_F, h_P⟩ := h_tc fam hfam
  exact ⟨fun t φ _ h_F_in => h_F t φ h_F_in, fun t φ _ h_P_in => h_P t φ h_P_in⟩

/--
Restricted temporal backward G: If phi in fam.mcs s for all s ≥ t, then G(phi) in fam.mcs t.

This is the restricted analog of `temporal_backward_G`. It only requires forward_F for
`neg(phi)`, which must be in `deferralClosure(root)` (supplied as a hypothesis).

The proof structure is identical to `temporal_backward_G`:
1. Assume G(phi) not in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By temporal duality: F(neg phi) in fam.mcs t
4. By restricted forward_F (using h_neg_phi_dc): exists s ≥ t with neg(phi) in fam.mcs s
5. Contradiction with phi in fam.mcs s
-/
theorem restricted_temporal_backward_G
    (fam : FMCS D) (root : Formula)
    (h_forward_F : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, t ≤ s → φ ∈ fam.mcs s) :
    Formula.all_future φ ∈ fam.mcs t := by
  by_contra h_not_G
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.all_future φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future φ) with h_G | h_neg
    · exact absurd h_G h_not_G
    · exact h_neg
  have h_F_neg : Formula.some_future (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs φ h_neg_G
  obtain ⟨s, h_le, h_neg_phi_s⟩ := h_forward_F t (Formula.neg φ) h_neg_phi_dc h_F_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/--
Restricted temporal backward H: If phi in fam.mcs s for all s ≤ t, then H(phi) in fam.mcs t.

Symmetric to `restricted_temporal_backward_G`, using restricted backward_P.
-/
theorem restricted_temporal_backward_H
    (fam : FMCS D) (root : Formula)
    (h_backward_P : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, s ≤ t → φ ∈ fam.mcs s) :
    Formula.all_past φ ∈ fam.mcs t := by
  by_contra h_not_H
  have h_mcs := fam.is_mcs t
  have h_neg_H : Formula.neg (Formula.all_past φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.all_past φ) with h_H | h_neg
    · exact absurd h_H h_not_H
    · exact h_neg
  have h_P_neg : Formula.some_past (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_past_to_some_past_neg (fam.mcs t) h_mcs φ h_neg_H
  obtain ⟨s, h_le, h_neg_phi_s⟩ := h_backward_P t (Formula.neg φ) h_neg_phi_dc h_P_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

end Bimodal.Metalogic.Bundle
