/-!
# BONEYARD - ARCHIVED

**WARNING**: This file has been archived to the Boneyard. Do not use in new code.

**Reason**: Infrastructure for the superseded CanonicalReachable/CanonicalQuotient approach.
Provides derived properties (F_implies_G_P_F, canonical_reachable_linear, etc.) that supported
the quotient construction, which is blocked because backward_P past witnesses are not
future-reachable.

**Archived from**: Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean
**Date**: 2026-02-26
**Task**: 933

**Alternative**: Use `canonicalMCSBFMCS` from `Bimodal.Metalogic.Bundle.CanonicalFMCS` instead.
-/

-- Original imports (may not compile from Boneyard location)
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms

/-!
# Canonical Embedding: Derived Properties for FMCS Construction

This module provides derived lemmas from the canonical frame (CanonicalFrame.lean)
that support the construction of FMCS Int for bimodal completeness.

## Key Results

1. **`F_implies_G_P_F`**: If F(psi) in MCS M, then G(P(F(psi))) in M.
   This means P(F(psi)) propagates through GContent seeds to all future MCSes.

2. **`P_implies_H_F_P`**: Symmetric past version.

These lemmas establish that while F-formulas themselves do NOT persist through
GContent seeds (the fundamental blocker for chain approaches), a WEAKER property
P(F(psi)) DOES persist. This weaker property witnesses that F(psi) held at some
past time, which is valuable for linearity-based arguments.

## Connection to Canonical Quotient Approach

The canonical frame (CanonicalFrame.lean) proves forward_F and backward_P
trivially for the abstract canonical model. The challenge is embedding this
into a `FMCS Int` (indexed by integers, not abstract MCS worlds).

The temp_linearity axiom (Phase 1) ensures the canonical frame's reachable
fragment is linearly ordered. Combined with the derived properties in this
module, a future implementation can:

1. Build a linearly ordered reachable fragment from any root MCS
2. Embed it into Int (using `Order.embedding_from_countable_to_dense` for Q,
   then transferring to Int via the discreteness of the fragment)
3. Construct FMCS Int with sorry-free forward_F/backward_P

## Technical Analysis: Why Forward_F is Hard for Int Chains

The fundamental challenge (analyzed extensively in research-001.md):

- **F-persistence failure**: F(psi) in M_n does NOT imply F(psi) in M_{n+1}
  when M_{n+1} = Lindenbaum(GContent(M_n)). Lindenbaum can introduce G(neg(psi)).
- **Linearity doesn't fix persistence**: The temp_linearity axiom constrains
  models semantically but does not prevent Lindenbaum from making choices that
  kill F-obligations.
- **GContent propagation**: G(P(F(psi))) DOES propagate (proven below), meaning
  P(F(psi)) persists. But P(F(psi)) only says "F(psi) held in the past", which
  is insufficient for forward_F at the current position.

The correct resolution is the full canonical quotient: build the canonical model
(where forward_F is trivial), prove linearity, and embed into Int. This avoids
the F-persistence problem entirely by not using a chain construction.

## References

- CanonicalFrame.lean: canonical_forward_F, canonical_backward_P (proven)
- Task 922 research-001.md: Canonical Quotient approach
- Goldblatt 1992, *Logics of Time and Computation*
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Temp_a Derived Properties for GContent Propagation

The temp_a axiom (phi -> G(P(phi))) provides key derived properties
that help propagate information through the canonical chain.

While F-formulas don't persist through GContent seeds, their "memory"
P(F(psi)) DOES persist, via temp_a.
-/

/--
If F(psi) ∈ M (MCS), then G(P(F(psi))) ∈ M.

This follows from temp_a: `phi -> G(P(phi))`, instantiated with `F(psi)`.
Since `F(psi) ∈ M` and temp_a gives `⊢ F(psi) -> G(P(F(psi)))`, by MCS closure
`G(P(F(psi))) ∈ M`.

**Significance**: `P(F(psi)) ∈ GContent(M)`, so `P(F(psi))` propagates through
GContent seeds to ALL future MCSes in ANY chain extending M. This means the
"memory" that F(psi) once held persists indefinitely through GContent propagation.
-/
lemma F_implies_G_P_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    Formula.all_future (Formula.some_past (Formula.some_future psi)) ∈ M := by
  -- temp_a instantiated with F(psi): ⊢ F(psi) → G(P(F(psi)))
  -- Note: some_past = sometime_past in the axiom definition
  have h_ta : [] ⊢ (Formula.some_future psi).imp
      (Formula.all_future ((Formula.some_future psi).some_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.some_future psi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_F

/--
Corollary: P(F(psi)) ∈ GContent(M) whenever F(psi) ∈ M.

This is a restatement of F_implies_G_P_F in GContent terms.
-/
lemma F_implies_P_F_in_GContent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    (Formula.some_future psi).some_past ∈ GContent M := by
  exact F_implies_G_P_F M h_mcs psi h_F

/--
If P(psi) ∈ M (MCS), then G(P(P(psi))) ∈ M.

This follows from temp_a instantiated with P(psi).
Significance: P(P(psi)) propagates through GContent seeds.
-/
lemma P_implies_G_P_P (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    Formula.all_future ((Formula.some_past psi).some_past) ∈ M := by
  have h_ta : [] ⊢ (Formula.some_past psi).imp
      (Formula.all_future ((Formula.some_past psi).some_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.some_past psi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_P

/-!
## Linearity and CanonicalR Properties

The temp_linearity axiom (`F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)`)
provides key structural properties of the canonical frame.

These lemmas connect the axiom to CanonicalR comparability.
-/

/--
Linearity in MCS: If `F(phi) ∈ M` and `F(psi) ∈ M`, then one of three
disjuncts holds in M:
1. `F(phi ∧ psi) ∈ M` (witnesses coincide)
2. `F(phi ∧ F(psi)) ∈ M` (phi comes first, F(psi) still holds there)
3. `F(F(phi) ∧ psi) ∈ M` (psi comes first, F(phi) still holds there)
-/
lemma mcs_F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Fphi : Formula.some_future phi ∈ M)
    (h_Fpsi : Formula.some_future psi ∈ M) :
    Formula.some_future (Formula.and phi psi) ∈ M ∨
    Formula.some_future (Formula.and phi (Formula.some_future psi)) ∈ M ∨
    Formula.some_future (Formula.and (Formula.some_future phi) psi) ∈ M := by
  -- From temp_linearity: ⊢ F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)
  have h_lin : [] ⊢ (Formula.and (Formula.some_future phi) (Formula.some_future psi)).imp
      (Formula.or (Formula.some_future (Formula.and phi psi))
        (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
          (Formula.some_future (Formula.and (Formula.some_future phi) psi)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_linearity phi psi)
  -- F(phi) ∧ F(psi) ∈ M
  have h_conj : Formula.and (Formula.some_future phi) (Formula.some_future psi) ∈ M :=
    Bimodal.Metalogic.set_mcs_conjunction_intro h_mcs h_Fphi h_Fpsi
  -- Apply linearity axiom via MCS closure
  have h_disj : Formula.or (Formula.some_future (Formula.and phi psi))
      (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
        (Formula.some_future (Formula.and (Formula.some_future phi) psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_lin) h_conj
  -- Decompose the outer disjunction
  rcases Bimodal.Metalogic.set_mcs_disjunction_elim h_mcs h_disj with h1 | h23
  · exact Or.inl h1
  · -- Decompose the inner disjunction
    rcases Bimodal.Metalogic.set_mcs_disjunction_elim h_mcs h23 with h2 | h3
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr h3)

/-!
## Canonical Existence Lemma (Reverse Direction)

If phi is in an R-successor of M, then F(phi) must be in M.
This is the canonical model analog of the modal existence lemma.
-/

/--
Canonical existence lemma: if CanonicalR M M' and phi in M', then F(phi) in M.

**Proof by contraposition**: if F(phi) not in M, then G(neg phi) in M (by MCS
completeness and the fact that neg(F(phi)) = G(neg phi) up to double negation).
Then neg phi in M' (by CanonicalR propagation). But phi in M' -- contradiction.
-/
lemma canonical_F_of_mem_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_future phi ∈ M := by
  -- By contradiction: suppose F(phi) ∉ M
  by_contra h_not_F
  -- Then neg(F(phi)) ∈ M by MCS completeness
  have h_neg_F : Formula.neg (Formula.some_future phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.some_future phi) with h | h
    · exact absurd h h_not_F
    · exact h
  have h_neg_F_eq : Formula.neg (Formula.some_future phi) =
    Formula.neg (Formula.neg (Formula.all_future (Formula.neg phi))) := rfl
  rw [h_neg_F_eq] at h_neg_F
  have h_G_neg : Formula.all_future (Formula.neg phi) ∈ M :=
    Bimodal.Metalogic.Bundle.mcs_double_neg_elim h_mcs _ h_neg_F
  have h_neg_phi : Formula.neg phi ∈ M' := h_R h_G_neg
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi

/--
Canonical existence lemma (past version): if CanonicalR_past M M' and phi in M',
then P(phi) in M.
-/
lemma canonical_P_of_mem_past_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR_past M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_past phi ∈ M := by
  by_contra h_not_P
  have h_neg_P : Formula.neg (Formula.some_past phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.some_past phi) with h | h
    · exact absurd h h_not_P
    · exact h
  have h_neg_P_eq : Formula.neg (Formula.some_past phi) =
    Formula.neg (Formula.neg (Formula.all_past (Formula.neg phi))) := rfl
  rw [h_neg_P_eq] at h_neg_P
  have h_H_neg : Formula.all_past (Formula.neg phi) ∈ M :=
    Bimodal.Metalogic.Bundle.mcs_double_neg_elim h_mcs _ h_neg_P
  have h_neg_phi : Formula.neg phi ∈ M' := h_R h_H_neg
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi

/-!
## Linearity of the Canonical Frame

The temp_linearity axiom ensures that the canonical frame's reachable fragment
is linearly ordered. This is the key structural property needed for embedding
into Int.
-/

/--
Linearity of CanonicalR on R-successors of a common root.

If M sees both M1 and M2 (CanonicalR M M1 and CanonicalR M M2), then
M1 and M2 are comparable: either CanonicalR M1 M2 or CanonicalR M2 M1 or M1 = M2.

**Proof Strategy**: Compound-formula linearity with cross-propagation.

Assume NOT(CanonicalR M1 M2) and NOT(CanonicalR M2 M1). Extract witnesses:
- alpha: G(alpha) in M1, neg(alpha) in M2 (from NOT CanonicalR M1 M2)
- beta: G(beta) in M2, neg(beta) in M1 (from NOT CanonicalR M2 M1)

Construct compound formulas:
- phi_c = G(alpha) AND neg(beta) (in M1, hence F(phi_c) in M)
- psi_c = G(beta) AND neg(alpha) (in M2, hence F(psi_c) in M)

Apply `mcs_F_linearity` with phi_c and psi_c. All three cases yield contradiction:

**Case 1**: F(phi_c AND psi_c) -- world has G(alpha) and neg(alpha), so alpha (by T)
and neg(alpha) at same world. Contradiction.

**Case 2**: F(phi_c AND F(psi_c)) -- outer world has G(alpha), inner world has neg(alpha).
G(alpha) propagates via CanonicalR to inner world, giving alpha AND neg(alpha). Contradiction.

**Case 3**: F(F(phi_c) AND psi_c) -- outer world has G(beta), inner world has neg(beta).
G(beta) propagates via CanonicalR to inner world, giving beta AND neg(beta). Contradiction.

The key insight is using BOTH non-comparability witnesses simultaneously in compound
formulas, ensuring that in Cases 2 and 3, the G-formula from one component propagates
through CanonicalR to contradict the neg-formula from the other component.

**References**:
- Goldblatt 1992, Logics of Time and Computation (canonical frame linearity)
- Task 922 research-001.md, Task 923 research-001.md
-/
theorem canonical_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  -- By classical case analysis: either CanonicalR M1 M2 holds, or it doesn't.
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · -- NOT(CanonicalR M1 M2): there exists alpha with G(alpha) in M1 and alpha not in M2.
    -- We show CanonicalR M2 M1 by contradiction.
    right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    -- NOT(CanonicalR M1 M2): GContent M1 ⊄ M2
    -- Unfold: exists alpha, G(alpha) in M1 and alpha not in M2
    have h_not_sub_12 : ¬(GContent M1 ⊆ M2) := h_12
    rw [Set.not_subset] at h_not_sub_12
    obtain ⟨alpha, h_alpha_G1, h_alpha_not2⟩ := h_not_sub_12
    -- alpha in GContent(M1) means G(alpha) in M1
    have h_G_alpha_M1 : Formula.all_future alpha ∈ M1 := h_alpha_G1
    -- alpha not in M2, so neg(alpha) in M2 (MCS negation completeness)
    have h_neg_alpha_M2 : Formula.neg alpha ∈ M2 := by
      rcases set_mcs_negation_complete h_mcs2 alpha with h | h
      · exact absurd h h_alpha_not2
      · exact h
    -- NOT(CanonicalR M2 M1): GContent M2 ⊄ M1
    have h_not_sub_21 : ¬(GContent M2 ⊆ M1) := h_not_21
    rw [Set.not_subset] at h_not_sub_21
    obtain ⟨beta, h_beta_G2, h_beta_not1⟩ := h_not_sub_21
    -- G(beta) in M2
    have h_G_beta_M2 : Formula.all_future beta ∈ M2 := h_beta_G2
    -- neg(beta) in M1
    have h_neg_beta_M1 : Formula.neg beta ∈ M1 := by
      rcases set_mcs_negation_complete h_mcs1 beta with h | h
      · exact absurd h h_beta_not1
      · exact h
    -- Construct compound formulas for linearity application:
    -- phi_compound = G(alpha) AND neg(beta) (both in M1)
    -- psi_compound = G(beta) AND neg(alpha) (both in M2)
    have h_conj_M1 : Formula.and (Formula.all_future alpha) (Formula.neg beta) ∈ M1 :=
      Bimodal.Metalogic.set_mcs_conjunction_intro h_mcs1 h_G_alpha_M1 h_neg_beta_M1
    have h_conj_M2 : Formula.and (Formula.all_future beta) (Formula.neg alpha) ∈ M2 :=
      Bimodal.Metalogic.set_mcs_conjunction_intro h_mcs2 h_G_beta_M2 h_neg_alpha_M2
    -- F(phi_compound) in M and F(psi_compound) in M (by canonical_F_of_mem_successor)
    have h_F_conj1 : Formula.some_future (Formula.and (Formula.all_future alpha) (Formula.neg beta)) ∈ M :=
      canonical_F_of_mem_successor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_F_conj2 : Formula.some_future (Formula.and (Formula.all_future beta) (Formula.neg alpha)) ∈ M :=
      canonical_F_of_mem_successor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    -- Apply linearity with these compound formulas
    have h_lin := mcs_F_linearity M h_mcs
      (Formula.and (Formula.all_future alpha) (Formula.neg beta))
      (Formula.and (Formula.all_future beta) (Formula.neg alpha))
      h_F_conj1 h_F_conj2
    -- All three cases yield contradiction
    rcases h_lin with h_case1 | h_case2 | h_case3
    · -- Case 1: F(phi_compound AND psi_compound)
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case1
      have h_big_conj := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_left := h_big_conj.1
      have h_right := h_big_conj.2
      have h_left_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_left
      have h_right_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_right
      have h_alpha_W : alpha ∈ W := by
        have h_T : [] ⊢ (Formula.all_future alpha).imp alpha :=
          Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future alpha)
        exact set_mcs_implication_property h_W_mcs (theorem_in_mcs h_W_mcs h_T) h_left_parts.1
      have h_neg_alpha_W := h_right_parts.2
      exact set_consistent_not_both h_W_mcs.1 alpha h_alpha_W h_neg_alpha_W
    · -- Case 2: F(phi_compound AND F(psi_compound))
      obtain ⟨W, h_W_mcs, h_R_MW, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case2
      have h_outer := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_phi_in_W := h_outer.1
      have h_F_psi_W := h_outer.2
      have h_phi_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_phi_in_W
      have h_G_alpha_W := h_phi_parts.1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_psi_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_psi_W
      have h_psi_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W'_mcs h_psi_W'
      have h_neg_alpha_W' := h_psi_parts.2
      have h_alpha_W' : alpha ∈ W' := canonical_forward_G W W' h_R_WW' alpha h_G_alpha_W
      exact set_consistent_not_both h_W'_mcs.1 alpha h_alpha_W' h_neg_alpha_W'
    · -- Case 3: F(F(phi_compound) AND psi_compound)
      obtain ⟨W, h_W_mcs, h_R_MW, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case3
      have h_outer := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_F_phi_W := h_outer.1
      have h_psi_in_W := h_outer.2
      have h_psi_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_psi_in_W
      have h_G_beta_W := h_psi_parts.1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_phi_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_phi_W
      have h_phi_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W'_mcs h_phi_W'
      have h_neg_beta_W' := h_phi_parts.2
      have h_beta_W' : beta ∈ W' := canonical_forward_G W W' h_R_WW' beta h_G_beta_W
      exact set_consistent_not_both h_W'_mcs.1 beta h_beta_W' h_neg_beta_W'

end Bimodal.Metalogic.Bundle
