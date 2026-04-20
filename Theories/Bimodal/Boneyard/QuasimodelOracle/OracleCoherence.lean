/-! # Oracle-Based FMCS Coherence (Archived)

Unfinished oracle replacement for dd_bfmcs, abandoned at backward coherence
obstruction. The backward step transfer `phi /\ F(phi U psi) -> phi U psi` is
semantically invalid, blocking qm_bfmcs_restricted_buc.

Built as Plan v40 Phases 3-4 deliverable (2026-04-18). The oracle chain
infrastructure in OracleStep.lean (qm_oracle_step, qm_oracle_step_bwd,
hintikka_step_for_sigma_sig) is preserved as reusable infrastructure.
-/

import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.BXCanonical.Quasimodel.OracleStep
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma

namespace Bimodal.Metalogic.BXCanonical

/-! ## Oracle-Based FMCS Construction (Phase 4)

This section builds a new Int-indexed FMCS using `qm_oracle_step` (forward) and
`qm_oracle_step_bwd` (backward), bypassing `fwd_chain_of_sigma` entirely.

The forward oracle chain has the property:
- `g_content(mcs(n)) ⊆ mcs(n+1)` (by qm_oracle_step_bx_le)
- `h_content(mcs(n+1)) ⊆ mcs(n)` (by qm_oracle_step_h_content)
- Until-defects propagate from mcs(n) to mcs(n+1) (by oracle seed construction)

The backward oracle chain is symmetric using h_content and Since defects.

This construction supports proofs of restricted_tc, restricted_buc, and restricted_fuc
because the oracle seed explicitly handles eventuality obligations.
-/

/-- Forward oracle chain: iterate qm_oracle_step. -/
private noncomputable def qm_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : (n : Nat) → BXPoint
  | 0 => ⟨M₀, h₀⟩
  | n + 1 => Quasimodel.qm_oracle_step (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- Backward oracle chain: iterate qm_oracle_step_bwd. -/
private noncomputable def qm_bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : (n : Nat) → BXPoint
  | 0 => ⟨M₀, h₀⟩
  | n + 1 => Quasimodel.qm_oracle_step_bwd (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- MCS property for forward oracle chain. -/
theorem qm_fwd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    SetMaximalConsistent (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
  (qm_fwd_chain M₀ h₀ Sigma n).is_mcs

/-- MCS property for backward oracle chain. -/
theorem qm_bwd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    SetMaximalConsistent (qm_bwd_chain M₀ h₀ Sigma n).formulas :=
  (qm_bwd_chain M₀ h₀ Sigma n).is_mcs

/-- g_content propagation step for forward oracle chain. -/
theorem qm_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    g_content (qm_fwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_bx_le (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- h_content backward step for forward oracle chain. -/
theorem qm_fwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    h_content (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
  Quasimodel.qm_oracle_step_h_content (qm_fwd_chain M₀ h₀ Sigma n) Sigma

/-- h_content propagation step for backward oracle chain. -/
theorem qm_bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    h_content (qm_bwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_bwd_h_content (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- g_content backward for backward oracle chain. -/
theorem qm_bwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) :
    g_content (qm_bwd_chain M₀ h₀ Sigma (n + 1)).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma n).formulas :=
  Quasimodel.qm_oracle_step_bwd_g_content (qm_bwd_chain M₀ h₀ Sigma n) Sigma

/-- Transitive g_content propagation for qm_fwd_chain. -/
theorem qm_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    g_content (qm_fwd_chain M₀ h₀ Sigma m).formulas ⊆
      (qm_fwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ
    exact SetMaximalConsistent.implication_property
      (qm_fwd_chain M₀ h₀ Sigma 0).is_mcs
      (theorem_in_mcs (qm_fwd_chain M₀ h₀ Sigma 0).is_mcs
        (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (qm_fwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
        (theorem_in_mcs (qm_fwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
          (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future
        (qm_fwd_chain M₀ h₀ Sigma m).is_mcs hφ
      exact qm_fwd_chain_g_content_step M₀ h₀ Sigma n
        (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

/-- Transitive h_content propagation for qm_bwd_chain. -/
theorem qm_bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    h_content (qm_bwd_chain M₀ h₀ Sigma m).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ
    exact SetMaximalConsistent.implication_property
      (qm_bwd_chain M₀ h₀ Sigma 0).is_mcs
      (theorem_in_mcs (qm_bwd_chain M₀ h₀ Sigma 0).is_mcs
        (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (qm_bwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
        (theorem_in_mcs (qm_bwd_chain M₀ h₀ Sigma (n + 1)).is_mcs
          (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past
        (qm_bwd_chain M₀ h₀ Sigma m).is_mcs hφ
      exact qm_bwd_chain_h_content_step M₀ h₀ Sigma n
        (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

/-- g_content reverse for qm_bwd_chain: g_content(bwd(n)) ⊆ bwd(m) for n ≥ m. -/
theorem qm_bwd_chain_g_content_reverse (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) :
    g_content (qm_bwd_chain M₀ h₀ Sigma n).formulas ⊆
      (qm_bwd_chain M₀ h₀ Sigma m).formulas :=
  h_content_subset_implies_g_content_reverse
    (qm_bwd_chain M₀ h₀ Sigma m).formulas
    (qm_bwd_chain M₀ h₀ Sigma n).formulas
    (qm_bwd_chain M₀ h₀ Sigma m).is_mcs
    (qm_bwd_chain M₀ h₀ Sigma n).is_mcs
    (qm_bwd_chain_h_content_trans M₀ h₀ Sigma h)

/-- Int-indexed oracle chain. -/
noncomputable def qm_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (t : Int) : Set Formula :=
  if t ≥ 0 then (qm_fwd_chain M₀ h₀ Sigma t.toNat).formulas
  else (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).formulas

theorem qm_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : qm_chain M₀ h₀ Sigma 0 = M₀ := by
  simp [qm_chain, qm_fwd_chain]

theorem qm_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (t : Int) :
    SetMaximalConsistent (qm_chain M₀ h₀ Sigma t) := by
  simp only [qm_chain]; split
  · exact (qm_fwd_chain M₀ h₀ Sigma t.toNat).is_mcs
  · exact (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).is_mcs

/-- g_content propagation across the full Int oracle chain. -/
theorem qm_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {t t' : Int} (h_le : t ≤ t') :
    g_content (qm_chain M₀ h₀ Sigma t) ⊆ qm_chain M₀ h₀ Sigma t' := by
  simp only [qm_chain]
  split_ifs with ht ht'
  · -- t ≥ 0, t' ≥ 0: forward chain
    exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Int.toNat_le_toNat h_le)
  · -- t ≥ 0, t' < 0: impossible
    omega
  · -- t < 0, t' ≥ 0: go through origin
    intro χ hχ
    have h_Gchi_in_bwd : Formula.all_future χ ∈ (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).formulas :=
      hχ
    have h_GGchi := SetMaximalConsistent.all_future_all_future
      (qm_bwd_chain M₀ h₀ Sigma ((-t).toNat)).is_mcs h_Gchi_in_bwd
    have h_Gchi_in_M0 : Formula.all_future χ ∈ M₀ :=
      qm_bwd_chain_g_content_reverse M₀ h₀ Sigma (Nat.zero_le _) h_GGchi
    exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_Gchi_in_M0
  · -- t < 0, t' < 0: backward chain
    exact qm_bwd_chain_g_content_reverse M₀ h₀ Sigma (by omega)

/-- Oracle FMCS from qm_chain. -/
noncomputable def qm_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : FMCS Int where
  mcs := qm_chain M₀ h₀ Sigma
  is_mcs := qm_chain_mcs M₀ h₀ Sigma
  forward_G t t' φ h_le h_G := qm_chain_g_content M₀ h₀ Sigma h_le h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (qm_chain M₀ h₀ Sigma t') (qm_chain M₀ h₀ Sigma t)
      (qm_chain_mcs M₀ h₀ Sigma t') (qm_chain_mcs M₀ h₀ Sigma t)
      (qm_chain_g_content M₀ h₀ Sigma h_le) h_H

theorem qm_fmcs_at_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) :
    (qm_fmcs M₀ h₀ Sigma).mcs 0 = M₀ := qm_chain_zero M₀ h₀ Sigma

/-- Shifted oracle FMCS: place M₀ at position s. -/
noncomputable def shifted_qm_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (s : Int) : FMCS Int where
  mcs t := qm_chain M₀ h₀ Sigma (t - s)
  is_mcs t := qm_chain_mcs M₀ h₀ Sigma (t - s)
  forward_G t t' φ h_le h_G :=
    qm_chain_g_content M₀ h₀ Sigma (by omega : t - s ≤ t' - s) h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (qm_chain M₀ h₀ Sigma (t' - s)) (qm_chain M₀ h₀ Sigma (t - s))
      (qm_chain_mcs M₀ h₀ Sigma (t' - s)) (qm_chain_mcs M₀ h₀ Sigma (t - s))
      (qm_chain_g_content M₀ h₀ Sigma (by omega : t' - s ≤ t - s)) h_H

theorem shifted_qm_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (s : Int) :
    (shifted_qm_fmcs M₀ h₀ Sigma s).mcs s = M₀ := by
  show qm_chain M₀ h₀ Sigma (s - s) = M₀
  simp [qm_chain, qm_fwd_chain]

/-- Box stability along the oracle chain: Box φ ∈ qm_chain(t) ↔ Box φ ∈ M₀. -/
theorem box_stable_qm_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (φ : Formula) (t : Int) :
    Formula.box φ ∈ qm_chain M₀ h₀ Sigma t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · intro h_box_t
    by_contra h_not_box_M0
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ qm_chain M₀ h₀ Sigma t := by
      rcases le_or_gt 0 t with h_pos | h_neg
      · have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        simp only [qm_chain, if_pos h_pos]
        exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_G
      · have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        simp only [qm_chain, if_neg (not_le.mpr h_neg)]
        exact qm_bwd_chain_h_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_H
    have h_neg_box_t : (Formula.box φ).neg ∈ qm_chain M₀ h₀ Sigma t :=
      SetMaximalConsistent.implication_property (qm_chain_mcs M₀ h₀ Sigma t)
        (theorem_in_mcs (qm_chain_mcs M₀ h₀ Sigma t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    exact set_consistent_not_both (qm_chain_mcs M₀ h₀ Sigma t).1
      (Formula.box φ) h_box_t h_neg_box_t
  · intro h_box_M0
    rcases le_or_gt 0 t with h_pos | h_neg
    · have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_M0
      simp only [qm_chain, if_pos h_pos]
      exact qm_fwd_chain_g_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_G
    · have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      simp only [qm_chain, if_neg (not_le.mpr h_neg)]
      exact qm_bwd_chain_h_content_trans M₀ h₀ Sigma (Nat.zero_le _) h_H

/-! ## Oracle BFMCS Construction

Build `qm_bfmcs` by taking one `shifted_qm_fmcs` per modal equivalence class of M₀.
This is structurally identical to `dd_bfmcs` but uses the oracle chain instead of
fwd_chain_of_sigma.
-/

/-- Oracle BFMCS. -/
noncomputable def qm_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_qm_fmcs N h_N Sigma s }
  nonempty := ⟨shifted_qm_fmcs M₀ h₀ Sigma 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_qm_chain N h_N Sigma φ (t - s)).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_qm_fmcs N' h_N' Sigma s').mcs t :=
      (box_stable_qm_chain N' h_N' Sigma φ (t - s')).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_qm_fmcs N' h_N' Sigma s').is_mcs t)
      (theorem_in_mcs ((shifted_qm_fmcs N' h_N' Sigma s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_qm_chain N h_N Sigma φ (t - s)).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_qm_fmcs v.formulas v.is_mcs Sigma t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_qm_fmcs N h_N Sigma s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_qm_fmcs v.formulas v.is_mcs Sigma t) h_fam_v_mem
    have h_mcs_eq := shifted_qm_fmcs_at_s v.formulas v.is_mcs Sigma t
    rw [h_mcs_eq] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_qm_fmcs M₀ h₀ Sigma 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

/-- Oracle chain Until-defect propagation: if φ U ψ ∈ qm_fwd_chain(n) and ψ ∉ qm_fwd_chain(n)
    and φ U ψ ∈ Sigma, then φ U ψ ∈ qm_fwd_chain(n+1). -/
theorem qm_fwd_chain_until_propagates (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (n : Nat) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas)
    (h_not_psi : ψ ∉ (qm_fwd_chain M₀ h₀ Sigma n).formulas)
    (h_sigma : Formula.untl φ ψ ∈ Sigma) :
    Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma (n + 1)).formulas :=
  Quasimodel.qm_oracle_step_until_in_next
    (qm_fwd_chain M₀ h₀ Sigma n) Sigma h_until h_not_psi h_sigma

/-- Until-defect persistence: if φ U ψ ∈ qm_fwd_chain(m) and ψ ∉ qm_fwd_chain at any step
    in [m, n], and φ U ψ ∈ Sigma, then φ U ψ ∈ qm_fwd_chain(n). -/
theorem qm_fwd_chain_until_persists (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) {m n : Nat} (h : m ≤ n) (φ ψ : Formula)
    (h_sigma : Formula.untl φ ψ ∈ Sigma)
    (h_until : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma m).formulas)
    (h_no_witness : ∀ k, m ≤ k → k ≤ n → ψ ∉ (qm_fwd_chain M₀ h₀ Sigma k).formulas) :
    Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    exact h_until
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact h_until
    · have h_le : m ≤ n := Nat.lt_succ_iff.mp h_lt
      have h_not_psi_n : ψ ∉ (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
        h_no_witness n h_le (Nat.le_succ n)
      have h_until_n : Formula.untl φ ψ ∈ (qm_fwd_chain M₀ h₀ Sigma n).formulas :=
        ih h_le (fun k hk1 hk2 => h_no_witness k hk1 (Nat.le_trans hk2 (Nat.le_succ n)))
      exact qm_fwd_chain_until_propagates M₀ h₀ Sigma n φ ψ h_until_n h_not_psi_n h_sigma

/-! ## Restricted Temporal Coherence for qm_bfmcs

Key theorem: `qm_bfmcs_restricted_tc` proves that for formulas in deferralClosure(root),
F-eventualities are eventually realized in the oracle chain.

The proof for the forward direction (F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s)) requires
showing that the oracle step eventually resolves F-obligations. This is the hardest
part: F(φ) is not an Until formula, so the oracle seed does not directly include it.

The correct proof requires:
1. By BX12: F(φ) → (⊤ U φ), so ⊤ U φ ∈ mcs(t).
2. ⊤ U φ is an Until-defect at mcs(t) if φ ∉ mcs(t).
3. If ⊤ U φ ∈ Sigma (which follows from φ ∈ deferralClosure(root) ⊆ sigma_list = Sigma.toList),
   then by qm_fwd_chain_until_persists, ⊤ U φ persists in the chain.
4. Until-defect persistence + eventuality resolution gives φ at some finite step.

SORRY: The complete proof of step 4 (finding the witness step) requires the quasimodel
chain existence theorem (hintikka_chain_exists), which needs defect_count to decrease.
The defect count decrease for ⊤ U φ under the oracle step is sorry'd in OracleStep.lean.
-/

/-- F-obligation persistence via F(φ) → ⊤ U φ (BX12).
    If F(φ) ∈ M and ⊤ U φ ∈ Sigma, then ⊤ U φ is an Until-defect at M when φ ∉ M. -/
theorem F_phi_gives_top_until_defect {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) (h_not_phi : φ ∉ M) :
    Formula.untl (Formula.bot.imp Formula.bot) φ ∈ M := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.F_until_equiv φ)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_F

/-- Restricted temporal coherence for qm_bfmcs.

The forward direction (F(φ) → eventual φ) relies on:
- BX12 gives ⊤ U φ ∈ mcs(t)
- Oracle step propagates Until defects
- defect_count decrease eventually forces resolution

The defect_count decrease for general Until-defects is sorry'd because the oracle
Lindenbaum extension may introduce new Until-defects. Closing this sorry requires
proving that the oracle step is "defect-monotone" for defects in Sigma.
-/
theorem qm_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ Sigma) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward: F(φ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u
    -- fam = shifted_qm_fmcs N h_N Sigma s, so fam.mcs t = qm_chain N h_N Sigma (t - s)
    intro t φ h_phi_dc h_F
    -- SORRY: The complete proof requires showing that the oracle chain eventually resolves
    -- F-obligations. The argument via BX12 + Until-defect persistence would need
    -- defect_count decrease under oracle steps, which is sorry'd in OracleStep.lean.
    -- The formal gap: qm_oracle_step_until_in_next propagates defects forward, but
    -- hintikka_chain_exists needs defect_count to strictly decrease to terminate.
    exact sorry
  · -- Backward: P(φ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u
    intro t φ h_phi_dc h_P
    -- Symmetric to the forward case, using the backward oracle chain.
    -- SORRY: Same defect_count decrease gap as in the forward direction.
    exact sorry

/-- Restricted backward until/since coherence for qm_bfmcs.

The backward direction requires the step transfer:
  φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r)

This step is provable when φ U ψ ∈ Sigma and the oracle chain propagates Until defects:
- If φ U ψ ∈ mcs(r) (i.e., it was a defect at step r), the oracle seed contains it → ✓
- If φ U ψ ∉ mcs(r): need φ U ψ ∈ mcs(r) from φ ∈ mcs(r) and φ U ψ ∈ mcs(r+1)

For the "φ U ψ ∉ mcs(r)" case:
- By BX4': H(F(φ U ψ)) ∈ mcs(r+1)
- By h_content: F(φ U ψ) ∈ mcs(r)
- Need: φ ∧ F(φ U ψ) → φ U ψ (NOT derivable in BX -- semantically invalid)

SORRY: The step transfer is NOT provable for the oracle chain. This is a fundamental
gap: φ ∧ F(φ U ψ) → φ U ψ is semantically invalid (counterexample: φ@t, φ U ψ absent @t,
φ U ψ @t+1 but ¬φ @t+1 and ψ @t+2). No BX axiom closes this gap.

Alternative proof strategy for a modified chain where Until formulas are preserved
backward: use an "enriched" oracle seed that also includes backward projections of
Until formulas. This would require a more complex construction.
-/
theorem qm_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Backward Until: witness gives φ U ψ
    intro t φ ψ _h_sigma ⟨u, h_le, h_psi, h_guard⟩
    -- Induction on u - t using backward_until_from_step.
    -- The step transfer φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r) is SORRY'd.
    apply backward_until_from_step (shifted_qm_fmcs N h_N Sigma s) φ ψ
      (fun r h_U_next h_phi_r => ?_) t u h_le h_psi h_guard
    -- Step transfer goal: show φ U ψ ∈ mcs(r) from φ U ψ ∈ mcs(r+1) and φ ∈ mcs(r)
    -- SORRY: Semantically invalid step. See docstring above.
    exact sorry
  · -- Backward Since: witness gives φ S ψ
    intro t φ ψ _h_sigma ⟨u, h_le, h_psi, h_guard⟩
    -- Symmetric to Until case.
    apply backward_since_from_step (shifted_qm_fmcs N h_N Sigma s) φ ψ
      (fun r h_S_prev h_phi_r => ?_) t u h_le h_psi h_guard
    -- Step transfer goal: show φ S ψ ∈ mcs(r) from φ S ψ ∈ mcs(r-1) and φ ∈ mcs(r)
    -- SORRY: Symmetric semantically invalid step.
    exact sorry

/-- Restricted forward until/since coherence for qm_bfmcs.

The forward Until coherence requires: φ U ψ ∈ mcs(t) → ∃ s ≥ t, ψ ∈ mcs(s) with guard.

The proof:
1. By BX10: F(ψ) ∈ mcs(t)
2. By restricted_tc (forward): ∃ u > t with ψ ∈ mcs(u) [but restricted_tc is also sorry'd]
3. Guard: for r ∈ [t, u), by oracle chain propagation, φ U ψ persists (being a defect)
4. At each step r where ψ ∉ mcs(r), by BX9: φ ∨ ψ ∈ mcs(r). Since ψ ∉ mcs(r), φ ∈ mcs(r).

Steps 3-4 would give the guard without additional sorries IF step 2 is available.
But step 2 depends on restricted_tc which is sorry'd.

SORRY: Depends on restricted_tc (sorry'd) for the witness existence.
Also the guard argument (step 4) is valid given oracle step propagation.
-/
theorem qm_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (Sigma : Finset Formula) (root : Formula) :
    (qm_bfmcs M₀ h₀ Sigma).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, _h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward Until: φ U ψ → witness
    intro t φ ψ _h_sigma h_untl
    -- We have φ U ψ ∈ fam.mcs t = qm_chain N h_N Sigma (t - s)
    -- SORRY: requires restricted_tc (sorry'd above) to find witness u
    exact sorry
  · -- Forward Since: φ S ψ → witness
    intro t φ ψ _h_sigma h_snce
    -- Symmetric.
    exact sorry

end Bimodal.Metalogic.BXCanonical
