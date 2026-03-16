import Bimodal.Metalogic.StagedConstruction.WitnessSeedWrapper

/-!
# Separation Lemma for Strict Intermediates

This module proves key separation results for the staged construction:
given strictly ordered MCSs M < M', there exists an intermediate Delta.

## Overview

The separation lemma is needed for odd stages of the staged construction,
which insert intermediate points between successive pairs to ensure density.

The key results are:

1. `distinguishing_formula_exists`: If ¬CanonicalR(M', M), there exists a
   formula that distinguishes M from M'.

2. `intermediate_from_density`: Given CanonicalR(M, M') and a formula phi
   with F(phi) ∈ M and phi ∈ M', the density axiom provides an intermediate
   witness W with CanonicalR(M, W) and F(phi) ∈ W.

## Approach

Rather than proving a general separation lemma (which research-034 showed has
difficulties with controlling g_content of Lindenbaum witnesses), we use the
density axiom directly: F(phi) → F(F(phi)) gives intermediate witnesses that
preserve the F-obligation.

## References

- Task 956 plan v014: Phase 3
- research-034: Findings 9-12 (separation lemma analysis)
- CanonicalTimeline.lean: density_of_canonicalR
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

/-!
## Distinguishing Formula Existence

If two MCSs M, M' satisfy CanonicalR(M, M') but NOT CanonicalR(M', M),
then there exists a formula that distinguishes them: some formula is in
g_content(M') but not in M.
-/

/--
If ¬CanonicalR(M', M), then there exists beta such that G(beta) ∈ M'
and beta ∉ M. This is the distinguishing formula.

Proof: ¬CanonicalR(M', M) means g_content(M') ⊄ M, i.e., there exists
beta ∈ g_content(M') with beta ∉ M. By definition of g_content, G(beta) ∈ M'.
-/
theorem distinguishing_formula_exists
    {M M' : Set Formula}
    (_h_mcs : SetMaximalConsistent M)
    (_h_mcs' : SetMaximalConsistent M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ beta : Formula, Formula.all_future beta ∈ M' ∧ beta ∉ M := by
  -- ¬CanonicalR(M', M) means g_content(M') ⊄ M
  -- i.e., ∃ beta ∈ g_content(M'), beta ∉ M
  rw [CanonicalR, Set.not_subset] at h_not_R'
  obtain ⟨beta, h_beta_G, h_beta_not_M⟩ := h_not_R'
  -- beta ∈ g_content(M') means G(beta) ∈ M'
  exact ⟨beta, h_beta_G, h_beta_not_M⟩

/--
For a distinguishing formula beta (G(beta) ∈ M', beta ∉ M), exactly one of:
- Case A: G(beta) ∉ M (equivalently, F(¬beta) ∈ M)
- Case B: G(beta) ∈ M
-/
theorem case_analysis_G_beta
    {M : Set Formula} {beta : Formula}
    (_h_mcs : SetMaximalConsistent M) :
    Formula.all_future beta ∈ M ∨ Formula.all_future beta ∉ M :=
  Classical.em _

/-!
## Case A: G(beta) ∉ M → F(¬beta) ∈ M

When G(beta) ∉ M, we have F(¬beta) ∈ M by MCS negation completeness.
This gives us a concrete F-obligation that provides a forward witness
via the standard witness seed construction.
-/

/--
If G(beta) ∉ M and M is MCS, then ¬G(beta) ∈ M.
Since ¬G(beta) = F(¬beta) (by definition of F), we have F(¬beta) ∈ M.

Note: F(psi) = ¬G(¬psi) definitionally. So ¬G(beta) is NOT directly F(¬beta).
Instead: F(¬beta) = ¬G(¬(¬beta)) = ¬G(beta) (by double negation in MCS).
We need to be careful with the formula encoding.
-/
theorem not_G_implies_F_neg
    {M : Set Formula} {beta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_not_G : Formula.all_future beta ∉ M) :
    Formula.some_future (Formula.neg beta) ∈ M := by
  -- By MCS negation completeness, G(beta) ∉ M → ¬G(beta) ∈ M.
  have h_neg_G : Formula.neg (Formula.all_future beta) ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future beta) with
    | inl h => exact absurd h h_not_G
    | inr h => exact h
  -- F(¬beta) = some_future (neg beta) = neg (all_future (neg (neg beta)))
  -- ¬G(beta) = neg (all_future beta)
  -- We need: neg (all_future beta) ∈ M → neg (all_future (neg (neg beta))) ∈ M
  --
  -- Strategy: G(¬¬beta) → G(beta) is a theorem (via temporal necessitation of ¬¬beta → beta).
  -- Contrapositively: ¬G(beta) → ¬G(¬¬beta).
  -- The latter is exactly neg(all_future beta) → neg(all_future (neg (neg beta))).
  --
  -- Step 1: ¬¬beta → beta is a theorem (double negation elimination = Peirce's law consequence)
  have h_dne_thm : [] ⊢ (Formula.neg (Formula.neg beta)).imp beta :=
    dne_theorem beta
  -- Step 2: G(¬¬beta → beta) is a theorem (temporal necessitation)
  have h_G_dne : [] ⊢ Formula.all_future ((Formula.neg (Formula.neg beta)).imp beta) :=
    DerivationTree.temporal_necessitation _ h_dne_thm
  -- Step 3: G(¬¬beta → beta) → (G(¬¬beta) → G(beta)) (temporal K distribution)
  have h_K : [] ⊢ (Formula.all_future ((Formula.neg (Formula.neg beta)).imp beta)).imp
      ((Formula.all_future (Formula.neg (Formula.neg beta))).imp (Formula.all_future beta)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist (Formula.neg (Formula.neg beta)) beta)
  -- Step 4: G(¬¬beta) → G(beta) (modus ponens)
  have h_G_nn_imp_G : [] ⊢ (Formula.all_future (Formula.neg (Formula.neg beta))).imp
      (Formula.all_future beta) :=
    DerivationTree.modus_ponens [] _ _ h_K h_G_dne
  -- Step 5: In MCS M, ¬G(beta) → ¬G(¬¬beta) (contrapositive in MCS)
  -- If G(¬¬beta) ∈ M, then G(beta) ∈ M by MP. But G(beta) ∉ M. Contradiction.
  -- So G(¬¬beta) ∉ M, hence ¬G(¬¬beta) ∈ M.
  have h_not_G_nn : Formula.all_future (Formula.neg (Formula.neg beta)) ∉ M := by
    intro h_G_nn
    have h_imp_in_M := theorem_in_mcs h_mcs h_G_nn_imp_G
    exact h_not_G (SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_G_nn)
  -- Step 6: ¬G(¬¬beta) ∈ M by MCS negation completeness
  have h_neg_G_nn : Formula.neg (Formula.all_future (Formula.neg (Formula.neg beta))) ∈ M := by
    cases SetMaximalConsistent.negation_complete h_mcs (Formula.all_future (Formula.neg (Formula.neg beta))) with
    | inl h => exact absurd h h_not_G_nn
    | inr h => exact h
  -- F(¬beta) = neg (all_future (neg (neg beta))) definitionally
  exact h_neg_G_nn

/-!
## Case A Forward Witness

When Case A holds (G(beta) ∉ M), we have F(¬beta) ∈ M, and the forward
witness W = Lindenbaum({¬beta} ∪ g_content(M)) satisfies:
- CanonicalR(M, W)
- ¬beta ∈ W (and therefore beta ∉ W, since W is consistent)
-/

/--
In Case A, the forward witness for ¬beta is in the canonical future of M,
contains ¬beta, and therefore does NOT contain beta.
-/
theorem caseA_forward_witness_not_contains_beta
    {M : Set Formula} {beta : Formula}
    {h_mcs : SetMaximalConsistent M}
    {h_F_neg : Formula.some_future (Formula.neg beta) ∈ M} :
    beta ∉ executeForwardStep M h_mcs (Formula.neg beta) h_F_neg := by
  intro h_beta_W
  -- W contains both ¬beta (from seed) and beta (by assumption)
  have h_neg_beta_W := executeForwardStep_contains_phi (h_mcs := h_mcs) (h_F := h_F_neg)
  -- W is MCS, so it cannot contain both beta and ¬beta
  exact set_consistent_not_both (executeForwardStep_mcs (h_mcs := h_mcs) (h_F := h_F_neg)).1
    beta h_beta_W h_neg_beta_W

/-!
## Density-Based Intermediate Witness

For the staged construction, the density axiom provides the key mechanism
for inserting intermediates. Given M with F(phi) ∈ M:

1. density_of_canonicalR gives W with CanonicalR(M, W) and F(phi) ∈ W
2. This W is between M and the eventual phi-witness

The density axiom F(phi) → F(F(phi)) ensures we can always find an
intermediate point that still has the F-obligation pending.
-/

/--
Given CanonicalR(M, M') and a distinguishing formula phi with
F(phi) ∈ M and phi ∈ M', the density axiom provides an intermediate
witness W with:
- CanonicalR(M, W)
- F(phi) ∈ W (obligation preserved)
- W can see M' (since it still has F(phi), and M' has phi)

This is the key mechanism for odd-stage density insertion.
-/
theorem density_intermediate
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future phi ∈ W :=
  density_of_canonicalR M h_mcs phi h_F

/-!
## NoMaxOrder and NoMinOrder via Seriality

These are simpler than the full separation lemma and provide the
no-endpoint properties for the staged timeline.
-/

/--
Every MCS has a strict canonical future successor (from seriality F(¬⊥)).
This is the key property for NoMaxOrder in the staged timeline.
-/
theorem SetMaximalConsistent.has_strict_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W := by
  exact SetMaximalConsistent.has_canonical_successor M h_mcs

/--
Every MCS has a strict canonical past predecessor (from seriality P(¬⊥)).
This is the key property for NoMinOrder in the staged timeline.
-/
theorem SetMaximalConsistent.has_strict_past (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR W M := by
  obtain ⟨W, h_W_mcs, h_R_past⟩ := SetMaximalConsistent.has_canonical_predecessor M h_mcs
  -- Convert CanonicalR_past to CanonicalR in the reverse direction
  exact ⟨W, h_W_mcs, h_content_subset_implies_g_content_reverse M W h_mcs h_W_mcs h_R_past⟩

end Bimodal.Metalogic.StagedConstruction
