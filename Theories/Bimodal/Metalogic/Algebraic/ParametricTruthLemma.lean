import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Semantics.TaskModel
import Bimodal.Theorems.Propositional

/-!
# D-Parametric Truth Lemma

This module proves the truth lemma for the D-parametric canonical model construction.
The truth lemma states:

  phi in fam.mcs t <-> truth_at ParametricCanonicalTaskModel (ParametricCanonicalOmega B) (parametric_to_history fam) t phi

This is the key lemma connecting MCS membership to semantic truth evaluation.

## Bidirectionality Requirement

**The truth lemma is inherently bidirectional.** Both directions are required — the
forward direction CANNOT be proved in isolation because the `imp` forward case uses
the backward induction hypothesis:

    Forward imp: (ψ → χ) ∈ MCS, truth(ψ) ⊢ truth(χ)
      Step 1: truth(ψ) → ψ ∈ MCS        [BACKWARD IH for ψ]
      Step 2: (ψ → χ) ∈ MCS, ψ ∈ MCS → χ ∈ MCS  [MCS modus ponens]
      Step 3: χ ∈ MCS → truth(χ)          [FORWARD IH for χ]

This propagates: since `neg(φ) = φ.imp ⊥`, proving the forward direction for `neg(φ)`
requires the backward direction for `φ`. If `φ` contains `G` or `H` subformulas, the
backward direction for those cases requires `forward_F`/`backward_P` (family-level
temporal coherence), which is the `h_tc : B.temporally_coherent` hypothesis.

**There is no known reformulation that avoids this requirement.**

## Temporal Coherence Dependency

The `h_tc` parameter is used ONLY in the backward direction of the `G` and `H` cases
(lines 280 and 300), where `temporal_backward_G` / `temporal_backward_H` are invoked.
These use a contrapositive argument:

    Backward G: ∀ s ≥ t, truth(ψ) at s → G(ψ) ∈ fam.mcs t
      Contrapositive: assume G(ψ) ∉ fam.mcs t
      1. neg(G(ψ)) ∈ fam.mcs t           [MCS negation completeness]
      2. F(neg(ψ)) ∈ fam.mcs t           [temporal duality]
      3. ∃ s > t, neg(ψ) ∈ fam.mcs s    [forward_F — REQUIRES h_tc]
      4. ψ ∈ fam.mcs s                   [backward IH + hypothesis]
      5. Contradiction                     [ψ and neg(ψ) in consistent MCS]

Step 3 is the critical use of `forward_F`. The witness must be in the SAME family
`fam`, because the semantic hypothesis (truth at all s ≥ t) is evaluated along the
history `to_history(fam)`. A witness in a DIFFERENT family would be evaluated along
a different history and would not produce the needed contradiction.

## Main Results

- `ParametricCanonicalTaskModel D`: D-parametric task model with valuation = MCS membership
- `parametric_canonical_truth_lemma`: The main truth lemma for D-parametric canonical model
- `parametric_shifted_truth_lemma`: Truth lemma for shift-closed Omega
- `parametric_box_persistent`: Box phi persists to all times (TF axiom)

## Design

The proof follows the same structure as Bundle/FMCS.lean and Bundle/CanonicalFrame.lean,
but generalized to arbitrary D. The key cases are:
- atom: valuation = MCS membership (by definition)
- bot: both sides are False
- imp: by induction and MCS closure under derivation (BOTH directions use BOTH IH directions)
- box: by modal coherence of BFMCS (forward and backward)
- untl: forward by forward_until_since_coherent; backward by backward_until_since_coherent
- snce: forward by forward_until_since_coherent; backward by backward_until_since_coherent

Note: G/H formulas are now `def` abbreviations (structurally `imp` terms), so the
truth lemma for G/H is handled by the `imp` arm combined with `@[simp]` characterization
theorems `Truth.future_iff` and `Truth.past_iff`.

## References

- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean
-/

namespace Bimodal.Metalogic.Algebraic.ParametricTruthLemma

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Parametric Canonical Task Model
-/

/--
The D-parametric canonical task model: valuation is MCS membership.

An atom p is true at world-state M iff `atom p in M.val`.
-/
def ParametricCanonicalTaskModel (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskModel (ParametricCanonicalTaskFrame D) where
  valuation := fun M p => Formula.atom p ∈ M.val

/-!
## Helper Tautologies for Imp Case
-/

/-- Classical tautology: neg(psi -> chi) -> psi -/
private noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree FrameClass.Base [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : Bimodal.ProofSystem.DerivationTree FrameClass.Base [] (ψ.neg.imp (ψ.imp χ)) :=
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
    Bimodal.ProofSystem.DerivationTree FrameClass.Base [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ) trivial
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
## Box Persistence
-/

/-- Past analog of TF axiom: Box phi -> H(Box phi), derived via temporal duality. -/
private def past_tf_deriv (φ : Formula) :
    Bimodal.ProofSystem.DerivationTree FrameClass.Base [] ((Formula.box φ).imp (Formula.box φ).all_past) := by
  have h_tf_swap : Bimodal.ProofSystem.DerivationTree FrameClass.Base [] _ := Bimodal.Theorems.Combinators.temp_future_derived (Formula.swap_temporal φ)
  have h_dual := Bimodal.ProofSystem.DerivationTree.temporal_duality _ h_tf_swap
  have h_eq : Formula.swap_temporal ((Formula.box (Formula.swap_temporal φ)).imp
      (Formula.box (Formula.swap_temporal φ)).all_future) =
    (Formula.box φ).imp (Formula.box φ).all_past := by
    simp [Formula.swap_temporal, Formula.swap_temporal_involution]
  rw [h_eq] at h_dual
  exact h_dual

/-- Box phi at time t implies Box phi at all times s, for any family in an FMCS.

The proof uses:
1. TF axiom: Box phi -> G(Box phi) -- so Box phi persists to all future times
2. Temporal dual of TF: Box phi -> H(Box phi) -- so Box phi persists to all past times
3. forward_G and backward_H to extract Box phi at specific times
-/
theorem parametric_box_persistent
    (fam : FMCS D)
    (φ : Formula) (t s : D)
    (h_box : Formula.box φ ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs s := by
  -- Step 1: G(Box phi) in fam.mcs t via TF axiom
  have h_tf : (Formula.box φ).imp (Formula.box φ).all_future ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (Bimodal.Theorems.Combinators.temp_future_derived φ)
  have h_G_box : (Formula.box φ).all_future ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_tf h_box
  -- Step 2: H(Box phi) in fam.mcs t via past-TF
  have h_past_tf : (Formula.box φ).imp (Formula.box φ).all_past ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (past_tf_deriv φ)
  have h_H_box : (Formula.box φ).all_past ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_past_tf h_box
  -- Step 3: Case split on s vs t
  rcases lt_trichotomy t s with h_lt | h_eq | h_gt
  · -- t < s: use forward_G
    exact fam.forward_G t s (Formula.box φ) h_lt h_G_box
  · -- t = s: box φ ∈ fam.mcs t = fam.mcs s
    exact h_eq ▸ h_box
  · -- s < t: use backward_H
    exact fam.backward_H t s (Formula.box φ) h_gt h_H_box

/-!
## The Parametric Canonical Truth Lemma
-/

/--
The parametric canonical truth lemma: MCS membership iff truth at canonical model.

For any D-parametric BFMCS with temporal coherence and Until/Since coherence,
family in the BFMCS, time t, and formula phi:
  phi in fam.mcs t <-> truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B) (parametric_to_history fam) t phi

The `h_uc` parameter provides Until/Since coherence: the semantic content of
Until and Since operators is reflected at the MCS level. This is needed because
the Until/Since truth conditions involve existential witnesses with guard
conditions on intermediate times, which cannot be derived from temporal
coherence (forward_F/backward_P) alone over generic D.

For D = Int with deterministic chains, `h_uc` is provable from the chain
structure via `until_persists_chain` and `since_persists_chain`.
-/
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (h_buc : B.backward_until_since_coherent)
    (h_fuc : B.forward_until_since_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
        (parametric_to_history fam) t phi := by
  induction phi generalizing fam t with
  | atom p =>
    -- atom case: phi in fam.mcs t <-> exists ht, M.valuation (tau.states t ht) p
    -- Since domain = True, ht = True.intro
    -- valuation (fam.mcs t, is_mcs t) p = (atom p in fam.mcs t)
    simp only [truth_at, ParametricCanonicalTaskModel, parametric_to_history]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- bot case: bot in fam.mcs t <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      -- bot in MCS contradicts consistency
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree FrameClass.Base [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- imp case: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
      have h_chi_mcs : chi ∈ fam.mcs t := SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_psi_true : truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
            (parametric_to_history fam) t psi :=
          (ih_psi fam hfam t).mp h_psi_mcs
        have h_chi_true : truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
            (parametric_to_history fam) t chi :=
          h_truth_imp h_psi_true
        have h_chi_mcs : chi ∈ fam.mcs t := (ih_chi fam hfam t).mpr h_chi_true
        exact set_consistent_not_both (fam.is_mcs t).1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    simp only [truth_at]
    constructor
    · intro h_box sigma h_sigma_mem
      obtain ⟨fam', hfam', h_eq⟩ := h_sigma_mem
      subst h_eq
      have h_psi_mcs : psi ∈ fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
      exact (ih fam' hfam' t).mp h_psi_mcs
    · intro h_all
      have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_in_omega : parametric_to_history fam' ∈ ParametricCanonicalOmega B := ⟨fam', hfam', rfl⟩
        have h_truth := h_all (parametric_to_history fam') h_in_omega
        exact (ih fam' hfam' t).mpr h_truth
      exact B.modal_backward fam hfam psi t h_psi_all_mcs
  | untl phi psi ih_phi ih_psi =>
    -- Until truth lemma (Burgess: untl(event=phi, guard=psi)):
    -- untl(phi,psi) ∈ mcs(t) ↔ ∃ s > t, truth(phi,s) ∧ ∀ r ∈ (t,s), truth(psi,r)
    simp only [truth_at]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · -- Forward: untl(phi,psi) ∈ mcs(t) → semantic Until witness
      intro h_U
      obtain ⟨s, h_ts, h_event_s, h_guard⟩ := h_fwd_U t phi psi h_U
      exact ⟨s, h_ts,
        (ih_phi fam hfam s).mp h_event_s,
        fun r h_tr h_rs => (ih_psi fam hfam r).mp (h_guard r h_tr h_rs)⟩
    · -- Backward: semantic Until witness → untl(phi,psi) ∈ mcs(t)
      intro ⟨s, h_ts, h_truth_event_s, h_truth_guard⟩
      exact h_bwd_U t phi psi ⟨s, h_ts,
        (ih_phi fam hfam s).mpr h_truth_event_s,
        fun r h_tr h_rs => (ih_psi fam hfam r).mpr (h_truth_guard r h_tr h_rs)⟩
  | snce phi psi ih_phi ih_psi =>
    -- Since truth lemma (Burgess: snce(event=phi, guard=psi)):
    -- snce(phi,psi) ∈ mcs(t) ↔ ∃ s < t, truth(phi,s) ∧ ∀ r ∈ (s,t), truth(psi,r)
    simp only [truth_at]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · -- Forward: snce(phi,psi) ∈ mcs(t) → semantic Since witness
      intro h_S
      obtain ⟨s, h_st, h_event_s, h_guard⟩ := h_fwd_S t phi psi h_S
      exact ⟨s, h_st,
        (ih_phi fam hfam s).mp h_event_s,
        fun r h_sr h_rt => (ih_psi fam hfam r).mp (h_guard r h_sr h_rt)⟩
    · -- Backward: semantic Since witness → snce(phi,psi) ∈ mcs(t)
      intro ⟨s, h_st, h_truth_event_s, h_truth_guard⟩
      exact h_bwd_S t phi psi ⟨s, h_st,
        (ih_phi fam hfam s).mpr h_truth_event_s,
        fun r h_sr h_rt => (ih_psi fam hfam r).mpr (h_truth_guard r h_sr h_rt)⟩

/-!
## Shifted Truth Lemma

The truth lemma extended to ShiftClosedParametricCanonicalOmega. This is the key result
enabling the completeness proof: it relates MCS membership to truth in the canonical
model with a shift-closed set of histories.
-/

/--
Shifted truth lemma: MCS membership iff truth at the parametric canonical model with
shift-closed parametric canonical Omega. The box forward case uses `parametric_box_persistent`
to show that Box phi persists to all times, enabling truth at shifted histories
via `time_shift_preserves_truth`.
-/
theorem parametric_shifted_truth_lemma (B : BFMCS D)
    (h_tc : B.temporally_coherent)
    (h_buc : B.backward_until_since_coherent)
    (h_fuc : B.forward_until_since_coherent) (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ := by
  induction φ generalizing fam t with
  | atom p =>
    simp only [truth_at, ParametricCanonicalTaskModel, parametric_to_history]
    constructor
    · intro h_mem
      exact ⟨True.intro, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree FrameClass.Base [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true
      exact (ih_χ fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_ψ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t ψ :=
          (ih_ψ fam hfam t).mp h_ψ_mcs
        have h_χ_true : truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
            (parametric_to_history fam) t χ :=
          h_truth_imp h_ψ_true
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ fam hfam t).mpr h_χ_true
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    constructor
    · intro h_box σ h_σ_mem
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        parametric_box_persistent fam ψ t (t + delta) h_box
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      have h_truth_canon := (ih fam' hfam' (t + delta)).mp h_ψ_fam'
      have h_preserve := TimeShift.time_shift_preserves_truth
        (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
        (shiftClosedParametricCanonicalOmega_is_shift_closed B) (parametric_to_history fam')
        t (t + delta) ψ
      have h_delta : (t + delta) - t = delta := add_sub_cancel_left t delta
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (parametric_to_history fam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · intro h_all_σ
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := parametricCanonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
        exact (ih fam' hfam' t).mpr (h_all_σ (parametric_to_history fam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | untl phi psi ih_phi ih_psi =>
    simp only [truth_at]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · intro h_U
      obtain ⟨s, h_ts, h_event_s, h_guard⟩ := h_fwd_U t phi psi h_U
      exact ⟨s, h_ts,
        (ih_phi fam hfam s).mp h_event_s,
        fun r h_tr h_rs => (ih_psi fam hfam r).mp (h_guard r h_tr h_rs)⟩
    · intro ⟨s, h_ts, h_truth_event_s, h_truth_guard⟩
      exact h_bwd_U t phi psi ⟨s, h_ts,
        (ih_phi fam hfam s).mpr h_truth_event_s,
        fun r h_tr h_rs => (ih_psi fam hfam r).mpr (h_truth_guard r h_tr h_rs)⟩
  | snce phi psi ih_phi ih_psi =>
    simp only [truth_at]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · intro h_S
      obtain ⟨s, h_st, h_event_s, h_guard⟩ := h_fwd_S t phi psi h_S
      exact ⟨s, h_st,
        (ih_phi fam hfam s).mp h_event_s,
        fun r h_sr h_rt => (ih_psi fam hfam r).mp (h_guard r h_sr h_rt)⟩
    · intro ⟨s, h_st, h_truth_event_s, h_truth_guard⟩
      exact h_bwd_S t phi psi ⟨s, h_st,
        (ih_phi fam hfam s).mpr h_truth_event_s,
        fun r h_sr h_rt => (ih_psi fam hfam r).mpr (h_truth_guard r h_sr h_rt)⟩

end Bimodal.Metalogic.Algebraic.ParametricTruthLemma
