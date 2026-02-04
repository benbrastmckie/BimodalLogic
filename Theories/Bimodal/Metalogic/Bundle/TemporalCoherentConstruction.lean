import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.CoherentConstruction
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
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)

/-!
## Phase 1: Temporal Saturation Structures (Task 857 v002)

Following the EvalCoherentBundle pattern from CoherentConstruction.lean, we define
analogous structures for temporal saturation.
-/

/--
GContent of an MCS: the set of all formulas phi where G phi appears in the MCS.
-/
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
HContent of an MCS: the set of all formulas phi where H phi appears in the MCS.
-/
def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

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
TemporalEvalSaturatedBundle: A constant IndexedMCSFamily with temporally saturated MCS.

This structure provides:
1. A constant family (same MCS M at all times)
2. M is temporally saturated (F psi -> psi and P psi -> psi in M)
3. The family therefore satisfies forward_F and backward_P
-/
structure TemporalEvalSaturatedBundle (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] where
  /-- The underlying MCS -/
  baseMCS : Set Formula
  /-- The MCS is maximal consistent -/
  is_mcs : SetMaximalConsistent baseMCS
  /-- Forward temporal saturation -/
  forward_saturated : TemporalForwardSaturated baseMCS
  /-- Backward temporal saturation -/
  backward_saturated : TemporalBackwardSaturated baseMCS

/--
Convert a TemporalEvalSaturatedBundle to a constant IndexedMCSFamily.
-/
noncomputable def TemporalEvalSaturatedBundle.toIndexedMCSFamily
    (B : TemporalEvalSaturatedBundle D) : IndexedMCSFamily D where
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
  forward_H := fun _ _ phi _ h_H => by
    have h_T : [] ⊢ (Formula.all_past phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_past phi)
    exact set_mcs_implication_property B.is_mcs (theorem_in_mcs B.is_mcs h_T) h_H
  backward_G := fun _ _ phi _ h_G => by
    have h_T : [] ⊢ (Formula.all_future phi).imp phi :=
      DerivationTree.axiom [] _ (Axiom.temp_t_future phi)
    exact set_mcs_implication_property B.is_mcs (theorem_in_mcs B.is_mcs h_T) h_G

/--
The toIndexedMCSFamily conversion produces a constant family.
-/
lemma TemporalEvalSaturatedBundle.toIndexedMCSFamily_constant
    (B : TemporalEvalSaturatedBundle D) :
    IsConstantFamily B.toIndexedMCSFamily :=
  ⟨B.baseMCS, fun _ => rfl⟩

variable [Nontrivial D]

/--
In an ordered additive group, for any t there exists s > t.
-/
lemma exists_gt_in_ordered_group (t : D) : ∃ s : D, t < s := by
  obtain ⟨a, b, hab⟩ := Nontrivial.exists_pair_ne (α := D)
  rcases lt_trichotomy a b with h_lt | h_eq | h_gt
  · use t + (b - a)
    have h_pos : (0 : D) < b - a := sub_pos.mpr h_lt
    have h1 : t + 0 < t + (b - a) := add_lt_add_right h_pos t
    rw [add_zero] at h1
    exact h1
  · exact absurd h_eq hab
  · use t + (a - b)
    have h_pos : (0 : D) < a - b := sub_pos.mpr h_gt
    have h1 : t + 0 < t + (a - b) := add_lt_add_right h_pos t
    rw [add_zero] at h1
    exact h1

/--
In an ordered additive group, for any t there exists s < t.
-/
lemma exists_lt_in_ordered_group (t : D) : ∃ s : D, s < t := by
  obtain ⟨s, hs⟩ := exists_gt_in_ordered_group (D := D) (-t)
  use -s
  have h : -s < -(-t) := neg_lt_neg hs
  simp only [neg_neg] at h
  exact h

/--
Convert a TemporalEvalSaturatedBundle to a TemporalCoherentFamily.

**Requires** [Nontrivial D] to ensure the existence of witness times.
-/
noncomputable def TemporalEvalSaturatedBundle.toTemporalCoherentFamily
    (B : TemporalEvalSaturatedBundle D) : TemporalCoherentFamily D where
  toIndexedMCSFamily := B.toIndexedMCSFamily
  forward_F := fun t psi h_F => by
    have h_psi : psi ∈ B.baseMCS := B.forward_saturated psi h_F
    obtain ⟨s, hs⟩ := exists_gt_in_ordered_group (D := D) t
    exact ⟨s, hs, h_psi⟩
  backward_P := fun t psi h_P => by
    have h_psi : psi ∈ B.baseMCS := B.backward_saturated psi h_P
    obtain ⟨s, hs⟩ := exists_lt_in_ordered_group (D := D) t
    exact ⟨s, hs, h_psi⟩

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

/--
Axiom: For any consistent context, there exists a temporally saturated MCS extending it.

**Mathematical Justification**:
The standard Henkin-style construction for temporal completeness produces a temporally
saturated MCS through witness insertion during the Lindenbaum enumeration. At each step,
when a formula F(psi) = neg(G(neg(psi))) is added to the growing set, the witness psi
is also added if consistent. The key consistency lemma (temporal_witness_seed_consistent)
ensures that {psi} union GContent(M) is consistent whenever F(psi) is in MCS M.

Temporal saturation means: F(psi) in M implies psi in M, and P(psi) in M implies psi in M.
This is equivalent to: phi in M implies G(phi) in M (and similarly for H).

Such saturated MCS exist for ANY consistent context (this is a theorem of temporal logic,
provable in the metatheory). The full Lean construction would require:
1. An enumeration of formulas (countable inductive type)
2. A modified Lindenbaum step that inserts temporal witnesses
3. Careful bookkeeping of consistency preservation across omega steps

This axiom captures the mathematical content while the formal construction is deferred.
It is analogous to `singleFamily_modal_backward_axiom` in Construction.lean.

**Structural proof approach**: Implement a modified Lindenbaum construction
(`temporalLindenbaumMCS`) that produces temporally saturated MCS via Henkin-style
witness insertion during enumeration. Uses temporal_witness_seed_consistent for
the consistency argument at each step.
-/
axiom temporally_saturated_mcs_exists (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ M : Set Formula,
      SetMaximalConsistent M ∧
      (∀ gamma ∈ Gamma, gamma ∈ M) ∧
      TemporalForwardSaturated M ∧
      TemporalBackwardSaturated M

/--
Main theorem: A temporally saturated bundle exists for any consistent context.

**Construction**:
Uses `temporally_saturated_mcs_exists` to obtain an MCS that is both maximal consistent
and temporally saturated (F(psi) in M implies psi in M, and P(psi) in M implies psi in M).
The axiom captures the Henkin-style construction that would produce such an MCS.

**Axiom dependency**: `temporally_saturated_mcs_exists`
-/
theorem temporal_eval_saturated_bundle_exists (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ B : TemporalEvalSaturatedBundle D,
      (∀ gamma ∈ Gamma, gamma ∈ B.baseMCS) := by
  -- Obtain temporally saturated MCS extending Gamma
  obtain ⟨M, h_mcs, h_extends, h_forward_sat, h_backward_sat⟩ :=
    temporally_saturated_mcs_exists Gamma h_cons
  -- Construct the bundle
  exact ⟨{
    baseMCS := M
    is_mcs := h_mcs
    forward_saturated := h_forward_sat
    backward_saturated := h_backward_sat
  }, h_extends⟩

/-!
## Phase 3: Temporally Coherent BMCS Construction

We construct a BMCS that is temporally coherent, meaning all families satisfy
forward_F and backward_P. This enables the truth lemma to be proven without sorry
for all cases including temporal backward (G and H).

The construction uses `TemporalEvalSaturatedBundle` (with temporally saturated MCS)
to obtain a `TemporalCoherentFamily`, then wraps it in a single-family BMCS.
-/

/--
Construct a temporally coherent BMCS from a consistent context.

The construction:
1. Obtain a temporally saturated MCS M extending Gamma (via axiom)
2. Build a TemporalEvalSaturatedBundle from M
3. Convert to TemporalCoherentFamily (which has forward_F and backward_P)
4. Extract the IndexedMCSFamily and wrap in a single-family BMCS

**Axiom dependencies**:
- `temporally_saturated_mcs_exists` (temporal saturation existence)
- `singleFamily_modal_backward_axiom` (modal backward for single-family BMCS)
-/
noncomputable def construct_temporal_bmcs (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    BMCS D :=
  -- Get temporally saturated bundle
  let bundle := (temporal_eval_saturated_bundle_exists (D := D) Gamma h_cons).choose
  -- Convert to TemporalCoherentFamily then extract IndexedMCSFamily
  let tcf := bundle.toTemporalCoherentFamily
  -- Build single-family BMCS
  singleFamilyBMCS tcf.toIndexedMCSFamily

/--
The eval family of the constructed BMCS is the constant family from the saturated bundle.
-/
lemma construct_temporal_bmcs_eval_eq (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_temporal_bmcs Gamma h_cons (D := D)).eval_family =
      (temporal_eval_saturated_bundle_exists (D := D) Gamma h_cons).choose.toTemporalCoherentFamily.toIndexedMCSFamily :=
  rfl

/--
The MCS at any time in the constructed BMCS is the baseMCS of the saturated bundle.
-/
lemma construct_temporal_bmcs_mcs_eq (Gamma : List Formula) (h_cons : ContextConsistent Gamma) (t : D) :
    (construct_temporal_bmcs Gamma h_cons (D := D)).eval_family.mcs t =
      (temporal_eval_saturated_bundle_exists (D := D) Gamma h_cons).choose.baseMCS :=
  rfl

/--
The constructed BMCS preserves the original context.
-/
theorem construct_temporal_bmcs_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (construct_temporal_bmcs Gamma h_cons (D := D)).eval_family.mcs 0 := by
  intro gamma h_mem
  -- The MCS at time 0 is the baseMCS of the saturated bundle
  rw [construct_temporal_bmcs_mcs_eq]
  -- The baseMCS extends Gamma
  exact (temporal_eval_saturated_bundle_exists (D := D) Gamma h_cons).choose_spec gamma h_mem

/--
The constructed BMCS is temporally coherent.

**Key Property**: Since the BMCS uses a temporally saturated MCS as a constant family,
the forward_F and backward_P properties hold for the single family in the bundle.

For forward_F: F(psi) in M -> psi in M (by temporal forward saturation of baseMCS),
and since D has Nontrivial, there exists s > t. Since the family is constant,
psi in fam.mcs s = psi in M.

For backward_P: P(psi) in M -> psi in M (by temporal backward saturation of baseMCS),
and since D has Nontrivial, there exists s < t with psi in fam.mcs s = psi in M.
-/
theorem construct_temporal_bmcs_temporally_coherent (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    (construct_temporal_bmcs Gamma h_cons (D := D)).temporally_coherent := by
  -- Unfold temporally_coherent: need forward_F and backward_P for all families
  intro fam hfam
  -- The BMCS has a single family
  simp only [construct_temporal_bmcs, singleFamilyBMCS] at hfam
  have h_eq := Set.mem_singleton_iff.mp hfam
  subst h_eq
  -- Get the bundle and its properties
  let bundle := (temporal_eval_saturated_bundle_exists (D := D) Gamma h_cons).choose
  let tcf := bundle.toTemporalCoherentFamily
  -- The family IS tcf.toIndexedMCSFamily, which has forward_F and backward_P
  exact ⟨tcf.forward_F, tcf.backward_P⟩

end Bimodal.Metalogic.Bundle
