import Bimodal.Metalogic.StagedConstruction.SeparationLemma
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Completeness
import Bimodal.ProofSystem.LinearityDerivedFacts
import Mathlib.Data.Finset.Union

/-!
# Staged Construction Execution

This module implements the step-by-step (staged) construction that builds a countable
dense linear order of MCSs from a root MCS M₀. The construction alternates between:

- **Even stages (0, 2, 4, ...)**: Process F/P formula obligations for all current points
- **Odd stages (1, 3, 5, ...)**: Insert intermediate points for density

## Key Definitions

- `canonical_forward_reachable_linear`: Forward linearity from temp_linearity axiom
- `canonical_backward_reachable_linear`: Backward linearity from temp_linearity (past)
- `comparability_step_forward` / `comparability_step_backward`: Inductive comparability steps
- `staged_comparability`: Any two points in the staged construction are comparable

## Linearity

The linearity of the staged timeline follows from the `temp_linearity` axiom:
any two MCSs that are both CanonicalR-reachable from a common predecessor (or
both CanonicalR-predecessors of a common successor) are CanonicalR-comparable.
Since all points in the staged construction are bidirectionally reachable from
the root M₀, they are all pairwise comparable.

## References

- Task 956 plan v014: Phase 4
- research-034: Staged construction justification
- BidirectionalReachable.lean (Boneyard): Original linearity proofs
- Burgess 1984, Venema 2001, Goldblatt 1992
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

-- Classical decidability for set membership
attribute [local instance] Classical.propDecidable

/-!
## Formula Enumeration

Since Formula derives Countable, we obtain an Encodable instance
for formula enumeration. This provides the ordering for processing
F/P obligations at even stages.
-/

/-- Encodable instance for Formula, from Countable. -/
noncomputable instance formulaEncodableStaged : Encodable Formula :=
  Encodable.ofCountable Formula

/-- Decode a natural number to a formula for obligation processing. -/
noncomputable def decodeFormulaStaged (k : Nat) : Option Formula :=
  @Encodable.decode Formula formulaEncodableStaged k

/-!
## Linearity Lemmas

These are the key structural lemmas from the temp_linearity axiom.
They establish that CanonicalR-accessible MCSs are comparable.

Replicated from BidirectionalReachable.lean (Boneyard) to avoid importing
that module's heavy dependencies (Completeness.lean).
-/

/--
F-linearity in an MCS: if F(phi) and F(psi) are both in M, then one of:
1. F(phi ∧ psi) ∈ M
2. F(phi ∧ F(psi)) ∈ M
3. F(F(phi) ∧ psi) ∈ M
-/
lemma SetMaximalConsistent.F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Fphi : Formula.some_future phi ∈ M)
    (h_Fpsi : Formula.some_future psi ∈ M) :
    Formula.some_future (Formula.and phi psi) ∈ M ∨
    Formula.some_future (Formula.and phi (Formula.some_future psi)) ∈ M ∨
    Formula.some_future (Formula.and (Formula.some_future phi) psi) ∈ M := by
  have h_lin := theorem_in_mcs h_mcs (temp_linearity_derivation phi psi)
  have h_conj := SetMaximalConsistent.conjunction_intro h_mcs h_Fphi h_Fpsi
  have h_disj := SetMaximalConsistent.implication_property h_mcs h_lin h_conj
  rcases SetMaximalConsistent.disjunction_elim h_mcs h_disj with h | h
  · exact Or.inl h
  · rcases SetMaximalConsistent.disjunction_elim h_mcs h with h | h
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr h)

/--
If phi ∈ M' and CanonicalR M M', then F(phi) ∈ M.
-/
lemma canonical_F_of_mem_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_future phi ∈ M := by
  by_contra h_not_F
  have h_neg_F : Formula.neg (Formula.some_future phi) ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future phi) with h | h
    · exact absurd h h_not_F
    · exact h
  have h_neg_F_eq : Formula.neg (Formula.some_future phi) =
      Formula.neg (Formula.neg (Formula.all_future (Formula.neg phi))) := rfl
  rw [h_neg_F_eq] at h_neg_F
  have h_G_neg : Formula.all_future (Formula.neg phi) ∈ M :=
    SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_F
  have h_neg_phi_M' : Formula.neg phi ∈ M' := h_R h_G_neg
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi_M'

/--
If phi ∈ M' and CanonicalR M' M, then P(phi) ∈ M.
-/
lemma canonical_P_of_mem_predecessor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M' M) (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_past phi ∈ M := by
  have h_R_past : CanonicalR_past M M' :=
    g_content_subset_implies_h_content_reverse M' M h_mcs' h_mcs h_R
  by_contra h_not_P
  have h_neg_P : Formula.neg (Formula.some_past phi) ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past phi) with h | h
    · exact absurd h h_not_P
    · exact h
  have h_neg_P_eq : Formula.neg (Formula.some_past phi) =
      Formula.neg (Formula.neg (Formula.all_past (Formula.neg phi))) := rfl
  rw [h_neg_P_eq] at h_neg_P
  have h_H_neg : Formula.all_past (Formula.neg phi) ∈ M :=
    SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_P
  have h_neg_phi_M' : Formula.neg phi ∈ M' := h_R_past h_H_neg
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi_M'

/--
Past linearity in MCS: if P(phi) and P(psi) are both in M, then one of:
1. P(phi ∧ psi) ∈ M
2. P(phi ∧ P(psi)) ∈ M
3. P(P(phi) ∧ psi) ∈ M

Derived from temp_linearity via the temporal duality rule.
-/
lemma SetMaximalConsistent.P_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Pphi : Formula.some_past phi ∈ M)
    (h_Ppsi : Formula.some_past psi ∈ M) :
    Formula.some_past (Formula.and phi psi) ∈ M ∨
    Formula.some_past (Formula.and phi (Formula.some_past psi)) ∈ M ∨
    Formula.some_past (Formula.and (Formula.some_past phi) psi) ∈ M := by
  have h_lin_future := DerivationTree.axiom []
    (Formula.and (Formula.some_future phi.swap_temporal) (Formula.some_future psi.swap_temporal) |>.imp
      (Formula.or (Formula.some_future (Formula.and phi.swap_temporal psi.swap_temporal))
        (Formula.or (Formula.some_future (Formula.and phi.swap_temporal (Formula.some_future psi.swap_temporal)))
          (Formula.some_future (Formula.and (Formula.some_future phi.swap_temporal) psi.swap_temporal)))))
    (Axiom.temp_linearity phi.swap_temporal psi.swap_temporal)
  have h_dual := DerivationTree.temporal_duality _ h_lin_future
  simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg,
    Formula.some_future, Formula.swap_temporal_involution] at h_dual
  have h_conj : Formula.and (Formula.some_past phi) (Formula.some_past psi) ∈ M :=
    SetMaximalConsistent.conjunction_intro h_mcs h_Pphi h_Ppsi
  have h_disj := SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_dual) h_conj
  rcases SetMaximalConsistent.disjunction_elim h_mcs h_disj with h1 | h23
  · exact Or.inl h1
  · rcases SetMaximalConsistent.disjunction_elim h_mcs h23 with h2 | h3
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr h3)

/--
Linearity of forward-reachable elements: If CanonicalR M M1 and CanonicalR M M2,
then M1 and M2 are CanonicalR-comparable (or equal).

Key structural property from the temp_linearity axiom. Uses the gamma enrichment
trick: when M1 ≠ M2, include a distinguishing formula gamma in the compound
formulas so that Case 1 of the linearity trichotomy is self-contradictory.
-/
theorem canonical_forward_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    -- NOT(CanonicalR M1 M2): exists alpha with G(alpha) ∈ M1 and alpha ∉ M2
    rw [CanonicalR, Set.not_subset] at h_12
    obtain ⟨alpha, h_alpha_G1, h_alpha_not2⟩ := h_12
    have h_G_alpha_M1 : Formula.all_future alpha ∈ M1 := h_alpha_G1
    have h_neg_alpha_M2 : Formula.neg alpha ∈ M2 := by
      rcases SetMaximalConsistent.negation_complete h_mcs2 alpha with h | h
      · exact absurd h h_alpha_not2
      · exact h
    -- NOT(CanonicalR M2 M1): exists beta with G(beta) ∈ M2 and beta ∉ M1
    have h_not_sub_21 : ¬(g_content M2 ⊆ M1) := h_not_21
    rw [Set.not_subset] at h_not_sub_21
    obtain ⟨beta, h_beta_G2, h_beta_not1⟩ := h_not_sub_21
    have h_G_beta_M2 : Formula.all_future beta ∈ M2 := h_beta_G2
    have h_neg_beta_M1 : Formula.neg beta ∈ M1 := by
      rcases SetMaximalConsistent.negation_complete h_mcs1 beta with h | h
      · exact absurd h h_beta_not1
      · exact h
    -- KEY: Find gamma ∈ M1 \ M2 (exists since M1 ≠ M2)
    have h_sep : ∃ gamma, gamma ∈ M1 ∧ gamma ∉ M2 := by
      by_contra h_all
      push_neg at h_all
      apply h_neq
      apply Set.Subset.antisymm h_all
      intro phi h_phi_M2
      rcases SetMaximalConsistent.negation_complete h_mcs1 phi with h | h
      · exact h
      · exact absurd (h_all _ h) (fun h_neg_M2 =>
          set_consistent_not_both h_mcs2.1 phi h_phi_M2 h_neg_M2)
    obtain ⟨gamma, h_gamma_M1, h_gamma_not_M2⟩ := h_sep
    have h_neg_gamma_M2 : Formula.neg gamma ∈ M2 := by
      rcases SetMaximalConsistent.negation_complete h_mcs2 gamma with h | h
      · exact absurd h h_gamma_not_M2
      · exact h
    -- Enriched compound formulas with gamma/¬gamma for Case 1 elimination
    -- conj1 = (G(alpha) ∧ gamma) ∧ ¬beta, in M1
    -- conj2 = (G(beta) ∧ ¬gamma) ∧ ¬alpha, in M2
    have h_inner1_M1 : Formula.and (Formula.all_future alpha) gamma ∈ M1 :=
      SetMaximalConsistent.conjunction_intro h_mcs1 h_G_alpha_M1 h_gamma_M1
    have h_conj_M1 : Formula.and (Formula.and (Formula.all_future alpha) gamma) (Formula.neg beta) ∈ M1 :=
      SetMaximalConsistent.conjunction_intro h_mcs1 h_inner1_M1 h_neg_beta_M1
    have h_inner2_M2 : Formula.and (Formula.all_future beta) (Formula.neg gamma) ∈ M2 :=
      SetMaximalConsistent.conjunction_intro h_mcs2 h_G_beta_M2 h_neg_gamma_M2
    have h_conj_M2 : Formula.and (Formula.and (Formula.all_future beta) (Formula.neg gamma)) (Formula.neg alpha) ∈ M2 :=
      SetMaximalConsistent.conjunction_intro h_mcs2 h_inner2_M2 h_neg_alpha_M2
    -- F(conj) ∈ M via canonical_F_of_mem_successor
    have h_F_conj1 := canonical_F_of_mem_successor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_F_conj2 := canonical_F_of_mem_successor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    -- Apply linearity
    rcases SetMaximalConsistent.F_linearity M h_mcs
      (Formula.and (Formula.and (Formula.all_future alpha) gamma) (Formula.neg beta))
      (Formula.and (Formula.and (Formula.all_future beta) (Formula.neg gamma)) (Formula.neg alpha))
      h_F_conj1 h_F_conj2 with h_case1 | h_case2 | h_case3
    · -- Case 1: F(conj1 ∧ conj2) - IMPOSSIBLE (gamma ∧ ¬gamma in witness)
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case1
      have h_big := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_conj1_W := h_big.1
      have h_conj2_W := h_big.2
      have h_inner1_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj1_W).1
      have h_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_W).2
      have h_inner2_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj2_W).1
      have h_neg_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_W).2
      exact set_consistent_not_both h_W_mcs.1 gamma h_gamma_W h_neg_gamma_W
    · -- Case 2: F(conj1 ∧ F(conj2)) - G(alpha) propagates from W to W'
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case2
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_conj1_in_W := h_outer.1
      have h_F_conj2_W := h_outer.2
      have h_inner1_in_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj1_in_W).1
      have h_G_alpha_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_in_W).1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj2_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_conj2_W
      have h_neg_alpha_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj2_W').2
      have h_alpha_W' : alpha ∈ W' := canonical_forward_G W W' h_R_WW' alpha h_G_alpha_W
      exact set_consistent_not_both h_W'_mcs.1 alpha h_alpha_W' h_neg_alpha_W'
    · -- Case 3: F(F(conj1) ∧ conj2) - G(beta) propagates from W to W'
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case3
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_F_conj1_W := h_outer.1
      have h_conj2_in_W := h_outer.2
      have h_inner2_in_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj2_in_W).1
      have h_G_beta_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_in_W).1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj1_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_conj1_W
      have h_neg_beta_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj1_W').2
      have h_beta_W' : beta ∈ W' := canonical_forward_G W W' h_R_WW' beta h_G_beta_W
      exact set_consistent_not_both h_W'_mcs.1 beta h_beta_W' h_neg_beta_W'

/--
Linearity of backward-reachable elements: If CanonicalR M1 M and CanonicalR M2 M,
then M1 and M2 are CanonicalR-comparable (or equal).

This is the backward (past) analog of `canonical_forward_reachable_linear`.
-/
theorem canonical_backward_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M1 M) (h_R2 : CanonicalR M2 M) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    -- Use duality: ¬(CanonicalR M1 M2) → ¬(h_content(M2) ⊆ M1)
    have h_not_H21 : ¬(h_content M2 ⊆ M1) := by
      intro h_HC
      exact h_12 (h_content_subset_implies_g_content_reverse M2 M1 h_mcs2 h_mcs1 h_HC)
    rw [Set.not_subset] at h_not_H21
    obtain ⟨alpha, h_H_alpha_M2, h_alpha_not1⟩ := h_not_H21
    have h_Halpha_M2 : Formula.all_past alpha ∈ M2 := h_H_alpha_M2
    have h_neg_alpha_M1 : Formula.neg alpha ∈ M1 := by
      rcases SetMaximalConsistent.negation_complete h_mcs1 alpha with h | h
      · exact absurd h h_alpha_not1
      · exact h
    -- NOT(CanonicalR M2 M1): exists beta with H(beta) ∈ M1 and beta ∉ M2
    have h_not_H12 : ¬(h_content M1 ⊆ M2) := by
      intro h_HC
      exact h_not_21 (h_content_subset_implies_g_content_reverse M1 M2 h_mcs1 h_mcs2 h_HC)
    rw [Set.not_subset] at h_not_H12
    obtain ⟨beta, h_H_beta_M1, h_beta_not2⟩ := h_not_H12
    have h_Hbeta_M1 : Formula.all_past beta ∈ M1 := h_H_beta_M1
    have h_neg_beta_M2 : Formula.neg beta ∈ M2 := by
      rcases SetMaximalConsistent.negation_complete h_mcs2 beta with h | h
      · exact absurd h h_beta_not2
      · exact h
    -- KEY: Find gamma ∈ M1 \ M2
    have h_sep : ∃ gamma, gamma ∈ M1 ∧ gamma ∉ M2 := by
      by_contra h_all
      push_neg at h_all
      apply h_neq
      apply Set.Subset.antisymm h_all
      intro phi h_phi_M2
      rcases SetMaximalConsistent.negation_complete h_mcs1 phi with h | h
      · exact h
      · exact absurd (h_all _ h) (fun h_neg_M2 =>
          set_consistent_not_both h_mcs2.1 phi h_phi_M2 h_neg_M2)
    obtain ⟨gamma, h_gamma_M1, h_gamma_not_M2⟩ := h_sep
    have h_neg_gamma_M2 : Formula.neg gamma ∈ M2 := by
      rcases SetMaximalConsistent.negation_complete h_mcs2 gamma with h | h
      · exact absurd h h_gamma_not_M2
      · exact h
    -- Enriched compound formulas with gamma/¬gamma for Case 1 elimination
    have h_inner1_M1 : Formula.and (Formula.all_past beta) gamma ∈ M1 :=
      SetMaximalConsistent.conjunction_intro h_mcs1 h_Hbeta_M1 h_gamma_M1
    have h_conj_M1 : Formula.and (Formula.and (Formula.all_past beta) gamma) (Formula.neg alpha) ∈ M1 :=
      SetMaximalConsistent.conjunction_intro h_mcs1 h_inner1_M1 h_neg_alpha_M1
    have h_inner2_M2 : Formula.and (Formula.all_past alpha) (Formula.neg gamma) ∈ M2 :=
      SetMaximalConsistent.conjunction_intro h_mcs2 h_Halpha_M2 h_neg_gamma_M2
    have h_conj_M2 : Formula.and (Formula.and (Formula.all_past alpha) (Formula.neg gamma)) (Formula.neg beta) ∈ M2 :=
      SetMaximalConsistent.conjunction_intro h_mcs2 h_inner2_M2 h_neg_beta_M2
    -- P-pullback to M
    have h_P_conj1 := canonical_P_of_mem_predecessor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_P_conj2 := canonical_P_of_mem_predecessor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    -- Apply past linearity
    rcases SetMaximalConsistent.P_linearity M h_mcs
      (Formula.and (Formula.and (Formula.all_past beta) gamma) (Formula.neg alpha))
      (Formula.and (Formula.and (Formula.all_past alpha) (Formula.neg gamma)) (Formula.neg beta))
      h_P_conj1 h_P_conj2 with h_case1 | h_case2 | h_case3
    · -- Case 1: P(conj1 ∧ conj2) - IMPOSSIBLE (gamma ∧ ¬gamma)
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case1
      have h_big := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_conj1_W := h_big.1
      have h_conj2_W := h_big.2
      have h_inner1_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj1_W).1
      have h_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_W).2
      have h_inner2_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj2_W).1
      have h_neg_gamma_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_W).2
      exact set_consistent_not_both h_W_mcs.1 gamma h_gamma_W h_neg_gamma_W
    · -- Case 2: P(conj1 ∧ P(conj2)) - H(beta) propagates from W to W'
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case2
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_conj1_in_W := h_outer.1
      have h_P_conj2_W := h_outer.2
      have h_inner1_in_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj1_in_W).1
      have h_H_beta_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner1_in_W).1
      obtain ⟨W', h_W'_mcs, h_R_past_WW', h_conj2_W'⟩ := canonical_backward_P W h_W_mcs _ h_P_conj2_W
      have h_neg_beta_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj2_W').2
      have h_beta_W' : beta ∈ W' := canonical_backward_H W W' h_R_past_WW' beta h_H_beta_W
      exact set_consistent_not_both h_W'_mcs.1 beta h_beta_W' h_neg_beta_W'
    · -- Case 3: P(P(conj1) ∧ conj2) - H(alpha) propagates from W to W'
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_backward_P M h_mcs _ h_case3
      have h_outer := SetMaximalConsistent.conjunction_elim h_W_mcs h_W_mem
      have h_P_conj1_W := h_outer.1
      have h_conj2_in_W := h_outer.2
      have h_inner2_in_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_conj2_in_W).1
      have h_H_alpha_W := (SetMaximalConsistent.conjunction_elim h_W_mcs h_inner2_in_W).1
      obtain ⟨W', h_W'_mcs, h_R_past_WW', h_conj1_W'⟩ := canonical_backward_P W h_W_mcs _ h_P_conj1_W
      have h_neg_alpha_W' := (SetMaximalConsistent.conjunction_elim h_W'_mcs h_conj1_W').2
      have h_alpha_W' : alpha ∈ W' := canonical_backward_H W W' h_R_past_WW' alpha h_H_alpha_W
      exact set_consistent_not_both h_W'_mcs.1 alpha h_alpha_W' h_neg_alpha_W'

/-!
## Comparability Step Lemmas

These lemmas allow us to extend comparability across one CanonicalR step,
enabling inductive proofs of comparability for the full staged construction.
-/

/--
If W1 is comparable with W2, and CanonicalR W2 W3 (forward step), then W1 is comparable with W3.
-/
theorem comparability_step_forward
    (W1 W2 W3 : Set Formula)
    (h_mcs1 : SetMaximalConsistent W1)
    (h_mcs2 : SetMaximalConsistent W2)
    (h_mcs3 : SetMaximalConsistent W3)
    (h_comp : CanonicalR W1 W2 ∨ CanonicalR W2 W1 ∨ W1 = W2)
    (h_R23 : CanonicalR W2 W3) :
    CanonicalR W1 W3 ∨ CanonicalR W3 W1 ∨ W1 = W3 := by
  rcases h_comp with h_12 | h_21 | h_eq
  · exact Or.inl (canonicalR_transitive W1 W2 W3 h_mcs1 h_12 h_R23)
  · exact canonical_forward_reachable_linear W2 W1 W3 h_mcs2 h_mcs1 h_mcs3 h_21 h_R23
  · subst h_eq; exact Or.inl h_R23

/--
If W1 is comparable with W2, and CanonicalR W3 W2 (backward step), then W1 is comparable with W3.
-/
theorem comparability_step_backward
    (W1 W2 W3 : Set Formula)
    (h_mcs1 : SetMaximalConsistent W1)
    (h_mcs2 : SetMaximalConsistent W2)
    (h_mcs3 : SetMaximalConsistent W3)
    (h_comp : CanonicalR W1 W2 ∨ CanonicalR W2 W1 ∨ W1 = W2)
    (h_R32 : CanonicalR W3 W2) :
    CanonicalR W1 W3 ∨ CanonicalR W3 W1 ∨ W1 = W3 := by
  rcases h_comp with h_12 | h_21 | h_eq
  · exact canonical_backward_reachable_linear W2 W1 W3 h_mcs2 h_mcs1 h_mcs3 h_12 h_R32
  · exact Or.inr (Or.inl (canonicalR_transitive W3 W2 W1 h_mcs3 h_R32 h_21))
  · subst h_eq; exact Or.inr (Or.inl h_R32)

/-!
## StagedPoint Comparability from MCS Comparability

Bridge between MCS-level comparability and StagedPoint-level ordering.
-/

/--
If two MCSs are CanonicalR-comparable (or equal), then their StagedPoints are le-comparable.
-/
theorem stagedPoint_le_of_mcs_comparable (a b : StagedPoint)
    (h_comp : CanonicalR a.mcs b.mcs ∨ CanonicalR b.mcs a.mcs ∨ a.mcs = b.mcs) :
    StagedPoint.le a b ∨ StagedPoint.le b a := by
  rcases h_comp with h_ab | h_ba | h_eq
  · exact Or.inl (Or.inr h_ab)
  · exact Or.inr (Or.inr h_ba)
  · exact Or.inl (Or.inl h_eq)

/-!
## Staged Construction: Core Definitions

The staged construction builds a growing sequence of Finsets of StagedPoints.
It starts from a root MCS and alternates between processing F/P obligations
(even stages) and inserting density intermediates (odd stages).

The construction is parameterized by:
- `root_mcs`: The starting MCS (from Lindenbaum({¬phi₀}))
- `root_mcs_proof`: Proof that root_mcs is MCS
-/

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-- The root point at stage 0. -/
noncomputable def rootPoint : StagedPoint where
  mcs := root_mcs
  is_mcs := root_mcs_proof
  introduced_at := 0

/-- Initial stage contains just the root point. -/
noncomputable def stage0 : Finset StagedPoint :=
  {rootPoint root_mcs root_mcs_proof}

/--
Process a single forward obligation: given a point p with F(phi) in p.mcs,
add a forward witness point at the given stage.
-/
noncomputable def processForwardObligation
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) (stage : Stage) : StagedPoint :=
  forwardWitnessPoint p.mcs p.is_mcs phi h_F stage

/--
Process a single backward obligation: given a point p with P(phi) in p.mcs,
add a backward witness point at the given stage.
-/
noncomputable def processBackwardObligation
    (p : StagedPoint) (phi : Formula)
    (h_P : Formula.some_past phi ∈ p.mcs) (stage : Stage) : StagedPoint :=
  backwardWitnessPoint p.mcs p.is_mcs phi h_P stage

/--
The forward witness is comparable with all existing points that are
comparable with the source point.

If W1.mcs is comparable with p.mcs, and W2 = forwardWitness(p, phi),
then W1 is comparable with W2. This is because CanonicalR p.mcs W2.mcs,
and we can apply comparability_step_forward.
-/
theorem forwardWitness_comparable_with
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) (stage : Stage)
    (other : StagedPoint)
    (h_comp : CanonicalR other.mcs p.mcs ∨ CanonicalR p.mcs other.mcs ∨ other.mcs = p.mcs) :
    StagedPoint.le other (processForwardObligation p phi h_F stage) ∨
    StagedPoint.le (processForwardObligation p phi h_F stage) other := by
  have h_R : CanonicalR p.mcs (processForwardObligation p phi h_F stage).mcs :=
    forwardWitnessPoint_canonicalR
  have h_mcs_w := (processForwardObligation p phi h_F stage).is_mcs
  have h_comp' := comparability_step_forward other.mcs p.mcs
    (processForwardObligation p phi h_F stage).mcs
    other.is_mcs p.is_mcs h_mcs_w h_comp h_R
  exact stagedPoint_le_of_mcs_comparable other (processForwardObligation p phi h_F stage) h_comp'

/--
The backward witness is comparable with all existing points that are
comparable with the source point.
-/
theorem backwardWitness_comparable_with
    (p : StagedPoint) (phi : Formula)
    (h_P : Formula.some_past phi ∈ p.mcs) (stage : Stage)
    (other : StagedPoint)
    (h_comp : CanonicalR other.mcs p.mcs ∨ CanonicalR p.mcs other.mcs ∨ other.mcs = p.mcs) :
    StagedPoint.le other (processBackwardObligation p phi h_P stage) ∨
    StagedPoint.le (processBackwardObligation p phi h_P stage) other := by
  have h_R : CanonicalR (processBackwardObligation p phi h_P stage).mcs p.mcs :=
    backwardWitnessPoint_canonicalR
  have h_mcs_w := (processBackwardObligation p phi h_P stage).is_mcs
  have h_comp' := comparability_step_backward other.mcs p.mcs
    (processBackwardObligation p phi h_P stage).mcs
    other.is_mcs p.is_mcs h_mcs_w h_comp h_R
  exact stagedPoint_le_of_mcs_comparable other (processBackwardObligation p phi h_P stage) h_comp'

/-!
## Forward Witness Properties for Staged Construction

These bridge the gap between MCS-level properties and StagedPoint-level properties
needed for the staged construction invariants.
-/

/-- Forward witness has CanonicalR from source to witness. -/
theorem processForwardObligation_canonicalR
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) (stage : Stage) :
    CanonicalR p.mcs (processForwardObligation p phi h_F stage).mcs :=
  forwardWitnessPoint_canonicalR

/-- Forward witness contains the target formula phi. -/
theorem processForwardObligation_contains_phi
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) (stage : Stage) :
    phi ∈ (processForwardObligation p phi h_F stage).mcs :=
  forwardWitnessPoint_contains_phi

/-- Backward witness has CanonicalR from witness to source. -/
theorem processBackwardObligation_canonicalR
    (p : StagedPoint) (phi : Formula)
    (h_P : Formula.some_past phi ∈ p.mcs) (stage : Stage) :
    CanonicalR (processBackwardObligation p phi h_P stage).mcs p.mcs :=
  backwardWitnessPoint_canonicalR

/-- Backward witness contains the target formula phi. -/
theorem processBackwardObligation_contains_phi
    (p : StagedPoint) (phi : Formula)
    (h_P : Formula.some_past phi ∈ p.mcs) (stage : Stage) :
    phi ∈ (processBackwardObligation p phi h_P stage).mcs :=
  backwardWitnessPoint_contains_phi

/-!
## Density Witness Properties

The density axiom F(phi) -> F(F(phi)) provides intermediate witnesses
for the odd-stage density insertion.
-/

/-- Density intermediate: from F(phi) at M, get witness W with F(phi) still alive. -/
theorem density_intermediate_exists
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR p.mcs W ∧
      Formula.some_future phi ∈ W :=
  density_witness_exists p.mcs p.is_mcs phi h_F

/-!
## Key Invariant: Root Comparability

All points added to the staged construction are CanonicalR-comparable with the root.
This is established by induction: the root is comparable with itself, and each
new witness (forward or backward from a comparable point) is also comparable.
-/

/--
The root is comparable with itself.
-/
theorem root_comparable_self :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs
      (rootPoint root_mcs root_mcs_proof).mcs ∨
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs
      (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs = (rootPoint root_mcs root_mcs_proof).mcs :=
  Or.inr (Or.inr rfl)

/--
Any point that is comparable with the root can generate a forward witness that
is also comparable with the root.
-/
theorem forward_witness_comparable_with_root
    (p : StagedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (stage : Stage)
    (h_p_comp_root : CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
                     CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
                     (rootPoint root_mcs root_mcs_proof).mcs = p.mcs) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs
      (processForwardObligation p phi h_F stage).mcs ∨
    CanonicalR (processForwardObligation p phi h_F stage).mcs
      (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs =
      (processForwardObligation p phi h_F stage).mcs :=
  comparability_step_forward
    (rootPoint root_mcs root_mcs_proof).mcs p.mcs
    (processForwardObligation p phi h_F stage).mcs
    root_mcs_proof p.is_mcs (processForwardObligation p phi h_F stage).is_mcs
    h_p_comp_root (processForwardObligation_canonicalR p phi h_F stage)

/--
Any point that is comparable with the root can generate a backward witness that
is also comparable with the root.
-/
theorem backward_witness_comparable_with_root
    (p : StagedPoint) (phi : Formula)
    (h_P : Formula.some_past phi ∈ p.mcs)
    (stage : Stage)
    (h_p_comp_root : CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
                     CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
                     (rootPoint root_mcs root_mcs_proof).mcs = p.mcs) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs
      (processBackwardObligation p phi h_P stage).mcs ∨
    CanonicalR (processBackwardObligation p phi h_P stage).mcs
      (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs =
      (processBackwardObligation p phi h_P stage).mcs :=
  comparability_step_backward
    (rootPoint root_mcs root_mcs_proof).mcs p.mcs
    (processBackwardObligation p phi h_P stage).mcs
    root_mcs_proof p.is_mcs (processBackwardObligation p phi h_P stage).is_mcs
    h_p_comp_root (processBackwardObligation_canonicalR p phi h_P stage)

/-!
## Even Stage: Process Formula Obligations

The even stage processes a single formula phi (identified by the formula enumeration
index) across all current points. For each point p:
- If F(phi) ∈ p.mcs, add a forward witness
- If P(phi) ∈ p.mcs, add a backward witness

This is implemented as a fold over the current Finset.
-/

/--
Collect the forward/backward witnesses for a single point p and formula phi.
Returns a (possibly empty) Finset of new StagedPoints.
-/
noncomputable def witnessesForPoint
    (p : StagedPoint) (phi : Formula) (stage : Stage) : Finset StagedPoint :=
  let fwd : Finset StagedPoint :=
    if h : Formula.some_future phi ∈ p.mcs then
      {processForwardObligation p phi h stage}
    else ∅
  let bwd : Finset StagedPoint :=
    if h : Formula.some_past phi ∈ p.mcs then
      {processBackwardObligation p phi h stage}
    else ∅
  fwd ∪ bwd

/--
Process a single formula across all points in the current Finset.
Returns the union of the current set with all new witnesses.
-/
noncomputable def processFormula
    (current : Finset StagedPoint) (phi : Formula) (stage : Stage) : Finset StagedPoint :=
  current ∪ current.biUnion (fun p => witnessesForPoint p phi stage)

/--
The even stage for index k: process the k-th formula (if it exists).
If decodeFormulaStaged k = none, the stage is a no-op.
-/
noncomputable def evenStage
    (current : Finset StagedPoint) (k : Nat) (stage : Stage) : Finset StagedPoint :=
  match decodeFormulaStaged k with
  | none => current
  | some phi => processFormula current phi stage

/-!
## Odd Stage: Density Insertion

The odd stage inserts density intermediates. For each point p in the current set
with F(phi) ∈ p.mcs (for the k-th formula), we add a density witness W with
CanonicalR(p, W) and F(phi) ∈ W. This ensures that between p and any eventual
phi-witness, there will be an intermediate.

Rather than finding "successive pairs" (which requires sorting), we use the density
axiom to add intermediate points. For the k-th formula phi, for each point p with
F(phi) ∈ p.mcs, we use density_intermediate to get a witness W between p and the
phi-witness.
-/

/--
Extract the density witness MCS for a point with F(phi) obligation.
-/
noncomputable def densityWitnessMCS
    (p : StagedPoint) (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs) : Set Formula :=
  Classical.choose (density_intermediate_exists p phi h_F)

theorem densityWitnessMCS_spec
    (p : StagedPoint) (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs) :
    SetMaximalConsistent (densityWitnessMCS p phi h_F) ∧
    CanonicalR p.mcs (densityWitnessMCS p phi h_F) ∧
    Formula.some_future phi ∈ (densityWitnessMCS p phi h_F) :=
  Classical.choose_spec (density_intermediate_exists p phi h_F)

/--
Create a density witness StagedPoint.
-/
noncomputable def densityWitnessPoint
    (p : StagedPoint) (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (stage : Stage) : StagedPoint where
  mcs := densityWitnessMCS p phi h_F
  is_mcs := (densityWitnessMCS_spec p phi h_F).1
  introduced_at := stage

theorem densityWitnessPoint_canonicalR
    (p : StagedPoint) (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (stage : Stage) :
    CanonicalR p.mcs (densityWitnessPoint p phi h_F stage).mcs :=
  (densityWitnessMCS_spec p phi h_F).2.1

/--
Density witnesses for a single point and formula: if F(phi) ∈ p.mcs,
create a density intermediate witness.
-/
noncomputable def densityWitnessForPoint
    (p : StagedPoint) (phi : Formula) (stage : Stage) : Finset StagedPoint :=
  if h : Formula.some_future phi ∈ p.mcs then
    {densityWitnessPoint p phi h stage}
  else ∅

/--
Process density for a formula across all current points.
-/
noncomputable def processDensity
    (current : Finset StagedPoint) (phi : Formula) (stage : Stage) : Finset StagedPoint :=
  current ∪ current.biUnion (fun p => densityWitnessForPoint p phi stage)

/--
The odd stage for index k: add density intermediates for the k-th formula.
-/
noncomputable def oddStage
    (current : Finset StagedPoint) (k : Nat) (stage : Stage) : Finset StagedPoint :=
  match decodeFormulaStaged k with
  | none => current
  | some phi => processDensity current phi stage

/-!
## Recursive Staged Build

The staged build alternates even and odd stages:
- Stage 0: Initial root point
- Stage 2k+1: Even stage (process formula k)
- Stage 2k+2: Odd stage (density for formula k)

This ensures every formula is eventually processed and density intermediates
are eventually inserted for every obligation.
-/

/--
The recursive staged build. Produces the accumulated Finset at each stage.
- Stage 0: Just the root
- Stage 2k+1 (odd): Process formula k (add F/P witnesses)
- Stage 2k+2 (even in Nat, but "odd stage" in construction): Add density intermediates for formula k
-/
noncomputable def stagedBuild : Nat → Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := stagedBuild n
    if n % 2 = 0 then
      -- n is even, so n+1 is odd: process formula obligations for formula (n/2)
      evenStage prev (n / 2) (n + 1)
    else
      -- n is odd, so n+1 is even: density insertion for formula ((n-1)/2)
      oddStage prev (n / 2) (n + 1)

/-!
## Monotonicity of Staged Build

Each stage is a superset of the previous stage.
-/

theorem evenStage_monotone (current : Finset StagedPoint) (k : Nat) (stage : Stage) :
    current ⊆ evenStage current k stage := by
  unfold evenStage
  match decodeFormulaStaged k with
  | none => exact Finset.Subset.refl _
  | some _ => exact Finset.subset_union_left

theorem oddStage_monotone (current : Finset StagedPoint) (k : Nat) (stage : Stage) :
    current ⊆ oddStage current k stage := by
  unfold oddStage
  match decodeFormulaStaged k with
  | none => exact Finset.Subset.refl _
  | some _ => exact Finset.subset_union_left

theorem stagedBuild_monotone (n : Nat) :
    stagedBuild root_mcs root_mcs_proof n ⊆
    stagedBuild root_mcs root_mcs_proof (n + 1) := by
  show stagedBuild root_mcs root_mcs_proof n ⊆
    (if n % 2 = 0 then
      evenStage (stagedBuild root_mcs root_mcs_proof n) (n / 2) (n + 1)
    else
      oddStage (stagedBuild root_mcs root_mcs_proof n) (n / 2) (n + 1))
  split
  · exact evenStage_monotone _ _ _
  · exact oddStage_monotone _ _ _

/-!
## Linearity of Staged Build

Every stage of the staged build is linearly ordered. The key insight is that
every new witness added is comparable with all existing points (because it's
CanonicalR-reachable from an existing point, and all existing points are
mutually comparable by induction).

We prove this by induction on the stage, using the comparability lemmas from
the linearity infrastructure above.
-/

/-- All points in the staged build are MCS-comparable with the root. -/
theorem stagedBuild_all_comparable_with_root (n : Nat)
    (p : StagedPoint) (hp : p ∈ stagedBuild root_mcs root_mcs_proof n) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
    CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs = p.mcs := by
  induction n generalizing p with
  | zero =>
    simp only [stagedBuild, stage0, Finset.mem_singleton] at hp
    rw [hp]
    exact root_comparable_self root_mcs root_mcs_proof
  | succ n ih =>
    by_cases h_prev : p ∈ stagedBuild root_mcs root_mcs_proof n
    · exact ih p h_prev
    · -- p was added at stage n+1
      simp only [stagedBuild] at hp
      split at hp
      · -- evenStage
        rename_i h_even
        unfold evenStage at hp
        split at hp
        · -- decodeFormulaStaged returns none, so no new points
          exact ih p hp
        · -- decodeFormulaStaged returns some phi
          rename_i phi _h_decode
          unfold processFormula at hp
          rw [Finset.mem_union] at hp
          rcases hp with h_old | h_new
          · exact ih p h_old
          · rw [Finset.mem_biUnion] at h_new
            obtain ⟨q, hq_mem, hp_wit⟩ := h_new
            have h_q_comp := ih q hq_mem
            unfold witnessesForPoint at hp_wit
            rw [Finset.mem_union] at hp_wit
            rcases hp_wit with h_fwd | h_bwd
            · -- forward witness
              split at h_fwd
              · rename_i h_F
                rw [Finset.mem_singleton] at h_fwd
                rw [h_fwd]
                exact forward_witness_comparable_with_root root_mcs root_mcs_proof q phi h_F (n + 1) h_q_comp
              · exact absurd h_fwd (Finset.notMem_empty _)
            · -- backward witness
              split at h_bwd
              · rename_i h_P
                rw [Finset.mem_singleton] at h_bwd
                rw [h_bwd]
                exact backward_witness_comparable_with_root root_mcs root_mcs_proof q phi h_P (n + 1) h_q_comp
              · exact absurd h_bwd (Finset.notMem_empty _)
      · -- oddStage
        rename_i h_odd
        unfold oddStage at hp
        split at hp
        · exact ih p hp
        · rename_i phi _h_decode
          unfold processDensity at hp
          rw [Finset.mem_union] at hp
          rcases hp with h_old | h_new
          · exact ih p h_old
          · rw [Finset.mem_biUnion] at h_new
            obtain ⟨q, hq_mem, hp_density⟩ := h_new
            have h_q_comp := ih q hq_mem
            unfold densityWitnessForPoint at hp_density
            split at hp_density
            · rename_i h_F
              rw [Finset.mem_singleton] at hp_density
              rw [hp_density]
              -- Now goal is about densityWitnessPoint q phi h_F (n+1)
              -- It has CanonicalR q.mcs (densityWitnessPoint ...).mcs
              have h_R := densityWitnessPoint_canonicalR q phi h_F (n + 1)
              exact comparability_step_forward
                (rootPoint root_mcs root_mcs_proof).mcs q.mcs
                (densityWitnessPoint q phi h_F (n + 1)).mcs
                root_mcs_proof q.is_mcs (densityWitnessPoint q phi h_F (n + 1)).is_mcs
                h_q_comp h_R
            · exact absurd hp_density (Finset.notMem_empty _)

/-- The staged build is linearly ordered at every stage. -/
theorem stagedBuild_linear (n : Nat) :
    IsLinearlyOrdered (stagedBuild root_mcs root_mcs_proof n) := by
  intro a ha b hb
  have h_a_comp := stagedBuild_all_comparable_with_root root_mcs root_mcs_proof n a ha
  have h_b_comp := stagedBuild_all_comparable_with_root root_mcs root_mcs_proof n b hb
  -- Both a and b are comparable with root, so they are comparable with each other
  -- via the linearity of forward/backward reachability
  rcases h_a_comp with h_aR | h_Ra | h_aeq
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · -- Both are forward from root: use canonical_forward_reachable_linear
      have := canonical_forward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_aR h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · -- a forward from root, b backward from root
      have := comparability_step_backward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inr (Or.inl h_aR)) h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · -- h_beq : root.mcs = b.mcs, h_aR : CanonicalR root.mcs a.mcs
      -- After rewriting: CanonicalR b.mcs a.mcs, so b ≤ a
      exact Or.inr (Or.inr (h_beq ▸ h_aR))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · -- a backward from root, b forward from root
      have := comparability_step_forward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inl h_Ra) h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · -- Both backward from root: use canonical_backward_reachable_linear
      have := canonical_backward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_Ra h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · -- h_beq : root.mcs = b.mcs, h_Ra : CanonicalR a.mcs root.mcs
      -- After rewriting: CanonicalR a.mcs b.mcs, so a ≤ b
      exact Or.inl (Or.inr (h_beq ▸ h_Ra))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · -- h_aeq : root.mcs = a.mcs, h_bR : CanonicalR root.mcs b.mcs
      -- Need: a.le b ∨ b.le a, i.e., (a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs) ∨ ...
      exact Or.inl (Or.inr (h_aeq ▸ h_bR))
    · -- h_aeq : root.mcs = a.mcs, h_Rb : CanonicalR b.mcs root.mcs
      exact Or.inr (Or.inr (h_aeq ▸ h_Rb))
    · -- h_aeq : root.mcs = a.mcs, h_beq : root.mcs = b.mcs
      exact Or.inl (Or.inl (h_aeq.symm.trans h_beq))

/-- The root is in stage 0 of the build. -/
theorem rootPoint_in_stagedBuild_0 :
    rootPoint root_mcs root_mcs_proof ∈ stagedBuild root_mcs root_mcs_proof 0 := by
  simp [stagedBuild, stage0]

/-!
## Wrapping as StagedTimeline

Combine the staged build with its monotonicity and linearity proofs to
construct a StagedTimeline.
-/

/--
The full staged timeline, constructed from a root MCS by alternating
even/odd stages. This is the main output of the staged construction.
-/
noncomputable def buildStagedTimeline : StagedTimeline where
  root := rootPoint root_mcs root_mcs_proof
  root_stage := rfl
  at_stage := stagedBuild root_mcs root_mcs_proof
  root_in_stage_0 := rootPoint_in_stagedBuild_0 root_mcs root_mcs_proof
  monotone := stagedBuild_monotone root_mcs root_mcs_proof
  linear_at_stage := stagedBuild_linear root_mcs root_mcs_proof

/-!
## Discrete Staged Construction

The discrete staged construction is a variant of the staged build that SKIPS
odd stages (density insertion). This is used for discrete timelines where
the DN (density) axiom is not available.

Without odd stages, only F/P witnesses are added (no density intermediates).
This produces a discrete (non-dense) timeline where every element has an
immediate successor and predecessor.

### Key Difference from `stagedBuild`

- `stagedBuild`: Alternates evenStage (F/P witnesses) and oddStage (density)
- `discreteStagedBuild`: Only applies evenStage, skips oddStage entirely

### Mathematical Consequence

The discrete construction has finitely many points between any two comparable
points, enabling LocallyFiniteOrder and hence SuccOrder/PredOrder instances.
-/

/--
The discrete staged build. Like `stagedBuild` but skips odd stages (no density insertion).
- Stage 0: Just the root
- Stage n+1: Process formula n for F/P obligations (evenStage only)

This construction does NOT use the density axiom DN.
-/
noncomputable def discreteStagedBuild : Nat → Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuild n
    -- Always apply evenStage for formula n (no density insertion)
    evenStage prev n (n + 1)

/-!
## Discrete Build: Monotonicity
-/

theorem discreteStagedBuild_monotone (n : Nat) :
    discreteStagedBuild root_mcs root_mcs_proof n ⊆
    discreteStagedBuild root_mcs root_mcs_proof (n + 1) := by
  show discreteStagedBuild root_mcs root_mcs_proof n ⊆
    evenStage (discreteStagedBuild root_mcs root_mcs_proof n) n (n + 1)
  exact evenStage_monotone _ _ _

theorem discreteStagedBuild_monotone_le (m n : Nat) (h : m ≤ n) :
    discreteStagedBuild root_mcs root_mcs_proof m ⊆
    discreteStagedBuild root_mcs root_mcs_proof n := by
  induction n with
  | zero =>
    have : m = 0 := Nat.le_zero.mp h
    rw [this]
  | succ n ih =>
    cases Nat.eq_or_lt_of_le h with
    | inl h_eq => rw [h_eq]
    | inr h_lt =>
      have h_le : m ≤ n := Nat.lt_succ_iff.mp h_lt
      exact Finset.Subset.trans (ih h_le) (discreteStagedBuild_monotone root_mcs root_mcs_proof n)

/-!
## Discrete Build: Root Comparability
-/

/-- All points in the discrete staged build are MCS-comparable with the root. -/
theorem discreteStagedBuild_all_comparable_with_root (n : Nat)
    (p : StagedPoint) (hp : p ∈ discreteStagedBuild root_mcs root_mcs_proof n) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
    CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs = p.mcs := by
  induction n generalizing p with
  | zero =>
    simp only [discreteStagedBuild, stage0, Finset.mem_singleton] at hp
    rw [hp]
    exact root_comparable_self root_mcs root_mcs_proof
  | succ n ih =>
    by_cases h_prev : p ∈ discreteStagedBuild root_mcs root_mcs_proof n
    · exact ih p h_prev
    · -- p was added at stage n+1
      simp only [discreteStagedBuild] at hp
      unfold evenStage at hp
      split at hp
      · -- decodeFormulaStaged returns none, so no new points
        exact ih p hp
      · -- decodeFormulaStaged returns some phi
        rename_i phi _h_decode
        unfold processFormula at hp
        rw [Finset.mem_union] at hp
        rcases hp with h_old | h_new
        · exact ih p h_old
        · rw [Finset.mem_biUnion] at h_new
          obtain ⟨q, hq_mem, hp_wit⟩ := h_new
          have h_q_comp := ih q hq_mem
          unfold witnessesForPoint at hp_wit
          rw [Finset.mem_union] at hp_wit
          rcases hp_wit with h_fwd | h_bwd
          · -- forward witness
            split at h_fwd
            · rename_i h_F
              rw [Finset.mem_singleton] at h_fwd
              rw [h_fwd]
              exact forward_witness_comparable_with_root root_mcs root_mcs_proof q phi h_F (n + 1) h_q_comp
            · exact absurd h_fwd (Finset.notMem_empty _)
          · -- backward witness
            split at h_bwd
            · rename_i h_P
              rw [Finset.mem_singleton] at h_bwd
              rw [h_bwd]
              exact backward_witness_comparable_with_root root_mcs root_mcs_proof q phi h_P (n + 1) h_q_comp
            · exact absurd h_bwd (Finset.notMem_empty _)

/-!
## Discrete Build: Linearity
-/

/-- The discrete staged build is linearly ordered at every stage. -/
theorem discreteStagedBuild_linear (n : Nat) :
    IsLinearlyOrdered (discreteStagedBuild root_mcs root_mcs_proof n) := by
  intro a ha b hb
  have h_a_comp := discreteStagedBuild_all_comparable_with_root root_mcs root_mcs_proof n a ha
  have h_b_comp := discreteStagedBuild_all_comparable_with_root root_mcs root_mcs_proof n b hb
  -- Both a and b are comparable with root, so they are comparable with each other
  rcases h_a_comp with h_aR | h_Ra | h_aeq
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · have := canonical_forward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_aR h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · have := comparability_step_backward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inr (Or.inl h_aR)) h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · exact Or.inr (Or.inr (h_beq ▸ h_aR))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · have := comparability_step_forward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inl h_Ra) h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · have := canonical_backward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_Ra h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · exact Or.inl (Or.inr (h_beq ▸ h_Ra))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · exact Or.inl (Or.inr (h_aeq ▸ h_bR))
    · exact Or.inr (Or.inr (h_aeq ▸ h_Rb))
    · exact Or.inl (Or.inl (h_aeq.symm.trans h_beq))

/-- The root is in stage 0 of the discrete build. -/
theorem rootPoint_in_discreteStagedBuild_0 :
    rootPoint root_mcs root_mcs_proof ∈ discreteStagedBuild root_mcs root_mcs_proof 0 := by
  simp [discreteStagedBuild, stage0]

/-!
## Discrete Staged Timeline
-/

/--
The discrete staged timeline, constructed without density insertion.
This is used for discrete (non-dense) timelines where DN is not available.
-/
noncomputable def buildDiscreteStagedTimeline : StagedTimeline where
  root := rootPoint root_mcs root_mcs_proof
  root_stage := rfl
  at_stage := discreteStagedBuild root_mcs root_mcs_proof
  root_in_stage_0 := rootPoint_in_discreteStagedBuild_0 root_mcs root_mcs_proof
  monotone := discreteStagedBuild_monotone root_mcs root_mcs_proof
  linear_at_stage := discreteStagedBuild_linear root_mcs root_mcs_proof

end Bimodal.Metalogic.StagedConstruction
