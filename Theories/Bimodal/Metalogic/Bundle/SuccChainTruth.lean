import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.SuccChainTaskFrame
import Bimodal.Metalogic.Bundle.SuccChainWorldHistory
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Theorems.Propositional

/-!
# Succ-Chain Truth Lemma

This module proves the truth lemma for the Succ-chain canonical model.

## Main Results

- `succ_chain_model`: TaskModel for CanonicalTaskTaskFrame with valuation = MCS membership
- `succ_chain_omega`: Singleton set containing only the succ_chain_history
- `succ_chain_truth_lemma`: phi in MCS <-> truth_at ... phi (biconditional)
- `succ_chain_truth_forward`: Forward direction (MCS -> truth)

## Design

The Succ-chain approach uses a SINGLE history (not a bundle of FMCS families).
This simplifies the box case: since Omega is a singleton, Box phi is true iff
phi is true at the unique history.

The truth lemma states:
  phi in succ_chain_fam M0 t <-> truth_at succ_chain_model succ_chain_omega (succ_chain_history M0) t phi

We prove the full biconditional because the imp case of the forward direction
requires the backward direction (psi true -> psi in MCS).

**Note on Box Backward**: The backward direction for Box in a singleton-Omega model
requires that psi in MCS implies Box psi in MCS. This is NOT generally true for
arbitrary MCS content without modal saturation.

**Sorry Status**: Both `succ_chain_truth_lemma` and `succ_chain_truth_forward` depend on
`sorryAx` because the forward Imp case structurally requires the backward direction.
For sorry-free completeness, use `semantic_weak_completeness` or the algebraic path.

**BFMCS Solution**: The `boxClassFamilies_modal_backward` theorem (UltrafilterChain.lean)
proves modal backward for the bundled construction. The singleton-Omega approach here
is intentionally left with a sorry to document WHY bundling is mathematically necessary.

## References

- ParametricTruthLemma.lean: Pattern for truth lemma proof
- SuccChainFMCS.lean: succ_chain_fam and temporal coherence
- SuccChainWorldHistory.lean: succ_chain_history
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Semantics

/-!
## Succ-Chain Canonical Model
-/

/--
The Succ-chain canonical task model: valuation is MCS membership.

An atom p is true at world-state M (a Set Formula) iff `Formula.atom p ∈ M`.
Note: WorldState for CanonicalTaskTaskFrame is `Set Formula`.
-/
def succ_chain_model : TaskModel CanonicalTaskTaskFrame where
  valuation := fun (M : Set Formula) p => Formula.atom p ∈ M

/--
The Succ-chain Omega: singleton set containing only our history.

For the Succ-chain construction, we have a single history built from the
serial MCS M0. The box quantification is over this singleton set.
-/
def succ_chain_omega (M0 : SerialMCS) : Set (WorldHistory CanonicalTaskTaskFrame) :=
  {succ_chain_history M0}

/-!
## Helper Lemmas
-/

/-- Domain of succ_chain_history is full (all times are in domain). -/
theorem succ_chain_history_domain_full (M0 : SerialMCS) (t : Int) :
    (succ_chain_history M0).domain t := True.intro

/-- States of succ_chain_history at time t equals succ_chain_fam M0 t. -/
theorem succ_chain_history_states (M0 : SerialMCS) (t : Int) :
    (succ_chain_history M0).states t (succ_chain_history_domain_full M0 t) = succ_chain_fam M0 t := rfl

/-!
## Classical Tautologies for Imp Case
-/

/-- Classical tautology: neg(psi -> chi) -> psi -/
private noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : Bimodal.ProofSystem.DerivationTree [] (ψ.neg.imp (ψ.imp χ)) :=
    Bimodal.Theorems.Propositional.efq_neg ψ χ
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    Bimodal.Theorems.Propositional.double_negation ψ
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_b h_dne
  exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_step1 h_deduct

/-- Classical tautology: neg(psi -> chi) -> neg(chi) -/
private noncomputable def neg_imp_implies_neg_consequent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ)
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] χ Formula.bot h_bot
  exact Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg χ.neg h_neg_chi

/-!
## Truth Lemma (Biconditional)

For the Succ-chain model with singleton Omega, we prove:
  phi in succ_chain_fam M0 t <-> truth_at ... phi

The forward direction is needed for completeness (neg(phi) in MCS -> neg(phi) true).
The backward direction is needed for the imp case of forward direction.
-/

/--
The Succ-chain truth lemma: MCS membership iff semantic truth.

For the singleton-Omega model, we have:
  phi in succ_chain_fam M0 t <-> truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi

The proof proceeds by induction on phi:
- Atom: valuation is MCS membership by definition
- Bot: both sides are False (consistency of MCS)
- Imp: by MCS negation completeness and IH
- Box: Omega is singleton, so box quantifies over just our history; use T-axiom
- G: by forward_G/backward_G of SuccChainFMCS
- H: by backward_H/forward_H of SuccChainFMCS

**Note**: The backward direction for Box requires additional infrastructure.
For completeness, we only need the forward direction.
-/
theorem succ_chain_truth_lemma (M0 : SerialMCS) (phi : Formula) (t : Int) :
    phi ∈ succ_chain_fam M0 t ↔
    truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi := by
  induction phi generalizing t with
  | atom p =>
    -- Atom: valuation = MCS membership
    simp only [truth_at, succ_chain_model]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- Bot: bot in MCS <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      have h_cons := (succ_chain_fam_mcs M0 t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- Imp: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := succ_chain_fam_mcs M0 t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi ∈ succ_chain_fam M0 t := (ih_psi t).mpr h_psi_true
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi ∈ succ_chain_fam M0 t :=
        SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ succ_chain_fam M0 t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ succ_chain_fam M0 t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: psi is true
        have h_psi_true : truth_at succ_chain_model (succ_chain_omega M0)
            (succ_chain_history M0) t psi := (ih_psi t).mp h_psi_mcs
        -- By hypothesis: chi is true
        have h_chi_true : truth_at succ_chain_model (succ_chain_omega M0)
            (succ_chain_history M0) t chi := h_truth_imp h_psi_true
        -- By IH: chi in MCS
        have h_chi_mcs : chi ∈ succ_chain_fam M0 t := (ih_chi t).mpr h_chi_true
        -- Contradiction: chi and neg(chi) in consistent MCS
        exact set_consistent_not_both h_mcs.1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    -- Box: Omega is singleton, so Box psi <-> psi (via T-axiom for forward)
    simp only [truth_at]
    constructor
    · -- Forward: Box psi in MCS -> forall sigma in Omega, truth sigma t psi
      intro h_box sigma h_sigma_mem
      simp only [succ_chain_omega, Set.mem_singleton_iff] at h_sigma_mem
      subst h_sigma_mem
      -- Box psi in MCS -> psi in MCS by T-axiom
      have h_T_axiom : [] ⊢ (Formula.box psi).imp psi :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t psi)
      have h_psi_mcs : psi ∈ succ_chain_fam M0 t :=
        SetMaximalConsistent.implication_property (succ_chain_fam_mcs M0 t)
          (theorem_in_mcs (succ_chain_fam_mcs M0 t) h_T_axiom) h_box
      exact (ih t).mp h_psi_mcs
    · -- Backward: forall sigma in Omega, truth sigma t psi -> Box psi in MCS
      intro h_all
      -- For singleton Omega, psi true at unique history -> psi in MCS by IH
      have h_in_omega : succ_chain_history M0 ∈ succ_chain_omega M0 := by
        simp only [succ_chain_omega, Set.mem_singleton_iff]
      have h_psi_true := h_all (succ_chain_history M0) h_in_omega
      have h_psi_mcs : psi ∈ succ_chain_fam M0 t := (ih t).mpr h_psi_true
      /-
      MATHEMATICALLY UNPROVABLE IN SINGLETON-OMEGA

      The goal is: psi in MCS -> Box psi in MCS
      This does NOT hold for arbitrary MCS content without modal saturation.

      WHY THIS IS UNPROVABLE:
      ----------------------
      In S5, Box phi means "phi holds at ALL accessible worlds". For a singleton Omega,
      "all accessible" means just the one world/history. But MCS membership for Box
      requires the S5 necessitation property: if psi is valid in the model, then Box psi
      is derivable. This is NOT the same as "psi being in one MCS".

      Consider: MCS M could contain psi but not Box psi. The T-axiom (Box phi -> phi)
      doesn't give us (phi -> Box phi). The 5-axiom (Diamond phi -> Box Diamond phi)
      combined with K and T gives S5, but these don't yield (psi -> Box psi) for
      arbitrary psi in a single MCS.

      THE BFMCS SOLUTION (Algebraic/UltrafilterChain.lean):
      -----------------------------------------------------
      The BFMCS approach bundles ALL families agreeing on box-content with M0.
      Modal backward works by contraposition:
      1. If Box phi is not in MCS, then Diamond(neg phi) is in M0
      2. box_theory_witness_exists provides W' with neg phi in W' and same box-class
      3. The shifted chain from W' is IN the bundle
      4. If phi were in ALL families, it would be in W', contradicting neg phi in W'

      The key is: the BFMCS bundle contains witness families that falsify phi when
      Box phi fails. Singleton Omega has NO such witnesses.

      PROVEN THEOREM REFERENCE:
      -------------------------
      `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678) proves modal backward
      for the `boxClassFamilies` construction. This theorem is sorry-free and is used by
      `construct_bfmcs` to build a BFMCS with working modal coherence.

      The parametric truth lemma (`parametric_canonical_truth_lemma` in
      ParametricTruthLemma.lean:170) uses `B.modal_backward` which is populated by
      `boxClassFamilies_modal_backward` when the BFMCS is constructed via `construct_bfmcs`.

      STATUS: Modal completeness (Box forward/backward) is SOLVED in the BFMCS path.
      This singleton-Omega sorry remains as documentation of why bundling is necessary.

      IMPACT ON COMPLETENESS:
      -----------------------
      This sorry propagates to succ_chain_truth_forward because the forward Imp case
      uses (ih_psi t).mpr - the backward direction on sub-formulas.

      For sorry-free completeness, use:
      - semantic_weak_completeness (FMP/SemanticCanonicalModel.lean)
      - The algebraic path (Algebraic/ParametricRepresentation.lean)
      -/
      sorry
  | all_future psi ih =>
    -- G: forward_G for forward direction, backward via temporal_backward_G
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s >= t, truth tau s psi
      intro h_G s h_ts
      have h_psi_mcs : psi ∈ succ_chain_fam M0 s := succ_chain_forward_G_le M0 t s psi h_ts h_G
      exact (ih s).mp h_psi_mcs
    · -- Backward: forall s >= t, truth tau s psi -> G psi in MCS
      intro h_all
      -- Use temporal_backward_G from TemporalCoherence.lean
      let tcf : TemporalCoherentFamily Int := SuccChainTemporalCoherent M0
      have h_all_mcs : ∀ s : Int, t < s → psi ∈ succ_chain_fam M0 s := by
        intro s h_ts
        exact (ih s).mpr (h_all s (le_of_lt h_ts))
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H: backward_H for forward direction, backward via temporal_backward_H
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s <= t, truth tau s psi
      intro h_H s h_st
      have h_psi_mcs : psi ∈ succ_chain_fam M0 s := succ_chain_backward_H_le M0 t s psi h_st h_H
      exact (ih s).mp h_psi_mcs
    · -- Backward: forall s <= t, truth tau s psi -> H psi in MCS
      intro h_all
      -- Use temporal_backward_H from TemporalCoherence.lean
      let tcf : TemporalCoherentFamily Int := SuccChainTemporalCoherent M0
      have h_all_mcs : ∀ s : Int, s < t → psi ∈ succ_chain_fam M0 s := by
        intro s h_st
        exact (ih s).mpr (h_all s (le_of_lt h_st))
      exact temporal_backward_H tcf t psi h_all_mcs

/--
Forward truth lemma: MCS membership implies semantic truth.

This is the key direction needed for completeness.

**Axiom Status** (verified 2026-03-24):
- This theorem depends on `sorryAx` via the Box backward case in `succ_chain_truth_lemma`
- The forward direction requires the backward direction structurally: the Imp case uses
  `(ih_psi t).mpr` to convert truth to MCS membership for sub-formulas

**Why Sorry is Required**:
- The Imp forward case needs backward IH: "if psi is true, then psi is in MCS"
- Backward for Box (line 254) is unprovable in singleton-Omega: `psi in MCS` does NOT
  imply `Box psi in MCS` without modal saturation
- For sorry-free completeness, use `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean)
  or the algebraic path (Algebraic/ParametricRepresentation.lean)

**Note**: The BFMCS approach (UltrafilterChain.lean) CAN prove Box backward via modal saturation,
but the SuccChain singleton-Omega construction fundamentally cannot.
-/
theorem succ_chain_truth_forward (M0 : SerialMCS) (phi : Formula) (t : Int) :
    phi ∈ succ_chain_fam M0 t →
    truth_at succ_chain_model (succ_chain_omega M0) (succ_chain_history M0) t phi :=
  (succ_chain_truth_lemma M0 phi t).mp

end Bimodal.Metalogic.Bundle
