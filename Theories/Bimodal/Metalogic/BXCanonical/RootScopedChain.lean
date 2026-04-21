import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma

/-!
# Schedule-Based BFMCS and Countermodel

Constructs a BFMCS from the schedule-based `bx_fmcs` / `shifted_bx_fmcs` chains
in CanonicalModel.lean. These chains are sorry-free by construction.

## Architecture

The defect-directed chain (`fwd_chain_of_sigma` / `dd_bfmcs`) has been archived to
`Boneyard/DefectDirectedChain/RootScopedChain.lean` — it was provably unfixable due to
`Classical.choice` opacity in the BX11 fold (dead ends 13–37 in ROADMAP).

Instead, `bx_bfmcs` wraps the schedule-based `shifted_bx_fmcs` construction from
CanonicalModel.lean. The schedule + `fwd_succ` / `bwd_pred` approach avoids BX11
entirely: each step targets one formula via round-robin scheduling, and
`schedule_surjective_above` guarantees every formula is visited infinitely often.

## Remaining Sorries

The restricted temporal coherence (`restricted_tc`) requires F-resolution (given
F(φ) in the chain, find φ at a later time) and P-resolution (symmetric for P).

**Forward chain F-resolution** (`fwd_chain_forward_F`): The simple Lindenbaum-based
chain does not preserve F-obligations across steps. When `fwd_succ` builds a new MCS
from `g_content(chain(n))`, the F(φ) formula may be absent from the result even though
it was present in chain(n). This means F(φ) can be permanently lost without φ ever
appearing. The same fundamental issue that blocked the defect-directed chain applies
here. Resolving this requires either:
(a) An enriched seed that includes all F-obligations at each step (blocked by BX11 opacity)
(b) A deterministic chain construction that controls exactly which formulas appear
(c) A completely different proof strategy (e.g., semantic methods)

**Cross-region coherence**: Even if F-resolution works within fwd_chain (t-s ≥ 0)
and P-resolution works within bwd_chain (t-s ≤ 0), the cross-region cases
(F in backward region, P in forward region) require additional propagation arguments.
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Classical

/-! ## BFMCS from schedule-based chains -/

/-- Bundle of FMCS families from the schedule-based chain construction.
Each family is a `shifted_bx_fmcs N h_N s` where N is box-equivalent to M₀. -/
noncomputable def bx_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_bx_fmcs N h_N s }
  nonempty := ⟨shifted_bx_fmcs M₀ h₀ 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_in_shifted_fmcs N h_N φ s t).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_bx_fmcs N' h_N' s').mcs t :=
      (box_stable_in_shifted_fmcs N' h_N' φ s' t).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_bx_fmcs N' h_N' s').is_mcs t)
      (theorem_in_mcs ((shifted_bx_fmcs N' h_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_in_shifted_fmcs N h_N φ s t).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_bx_fmcs v.formulas v.is_mcs t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_bx_fmcs N h_N s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_bx_fmcs v.formulas v.is_mcs t) h_fam_v_mem
    rw [shifted_bx_fmcs_at_s] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_bx_fmcs M₀ h₀ 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

/-! ## F/P-Obligation Monotonicity

Once F(φ) leaves the forward chain (or P(φ) leaves the backward chain), it never returns.
This is because G(¬φ) (resp. H(¬φ)) propagates via g_content (resp. h_content).
-/

/-- F-obligation monotonicity: once F(φ) leaves the forward chain, it never returns. -/
theorem fwd_chain_F_not_return (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (n : Nat) (φ : Formula) (h_not : Formula.some_future φ ∉ (fwd_chain M₀ h₀ n).val)
    (m : Nat) (h_le : n ≤ m) :
    Formula.some_future φ ∉ (fwd_chain M₀ h₀ m).val := by
  induction m with
  | zero => exact Nat.le_zero.mp h_le ▸ h_not
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with h_eq | h_lt
    · rw [← h_eq]; exact h_not
    · have h_not_m := ih (by omega)
      have h_mcs_m := (fwd_chain M₀ h₀ m).property
      -- ¬F(φ) ∈ chain(m), so by DNE: G(¬φ) ∈ chain(m)
      have h_neg_F : (Formula.some_future φ).neg ∈ (fwd_chain M₀ h₀ m).val := by
        rcases SetMaximalConsistent.negation_complete h_mcs_m (Formula.some_future φ) with h | h
        · exact absurd h h_not_m
        · exact h
      have h_G_neg : Formula.all_future (Formula.neg φ) ∈ (fwd_chain M₀ h₀ m).val :=
        SetMaximalConsistent.implication_property h_mcs_m
          (theorem_in_mcs h_mcs_m (dne (Formula.all_future (Formula.neg φ)))) h_neg_F
      -- G(G(¬φ)) ∈ chain(m) by temp_4, so G(¬φ) ∈ chain(m+1) via g_content
      have h_GG_neg := SetMaximalConsistent.all_future_all_future h_mcs_m h_G_neg
      have h_G_neg_succ : Formula.all_future (Formula.neg φ) ∈ (fwd_chain M₀ h₀ (m + 1)).val :=
        fwd_chain_g_content_step M₀ h₀ m h_GG_neg
      -- ¬F(φ) ∈ chain(m+1) follows from G(¬φ) ∈ chain(m+1)
      intro h_F_succ
      have h_neg_F_succ : (Formula.some_future φ).neg ∈ (fwd_chain M₀ h₀ (m + 1)).val :=
        SetMaximalConsistent.implication_property (fwd_chain M₀ h₀ (m + 1)).property
          (theorem_in_mcs (fwd_chain M₀ h₀ (m + 1)).property
            (dni (Formula.all_future (Formula.neg φ)))) h_G_neg_succ
      exact set_consistent_not_both (fwd_chain M₀ h₀ (m + 1)).property.1
        (Formula.some_future φ) h_F_succ h_neg_F_succ

/-- P-obligation monotonicity: once P(φ) leaves the backward chain, it never returns. -/
theorem bwd_chain_P_not_return (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (n : Nat) (φ : Formula) (h_not : Formula.some_past φ ∉ (bwd_chain M₀ h₀ n).val)
    (m : Nat) (h_le : n ≤ m) :
    Formula.some_past φ ∉ (bwd_chain M₀ h₀ m).val := by
  induction m with
  | zero => exact Nat.le_zero.mp h_le ▸ h_not
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with h_eq | h_lt
    · rw [← h_eq]; exact h_not
    · have h_not_m := ih (by omega)
      have h_mcs_m := (bwd_chain M₀ h₀ m).property
      have h_neg_P : (Formula.some_past φ).neg ∈ (bwd_chain M₀ h₀ m).val := by
        rcases SetMaximalConsistent.negation_complete h_mcs_m (Formula.some_past φ) with h | h
        · exact absurd h h_not_m
        · exact h
      have h_H_neg : Formula.all_past (Formula.neg φ) ∈ (bwd_chain M₀ h₀ m).val :=
        SetMaximalConsistent.implication_property h_mcs_m
          (theorem_in_mcs h_mcs_m (dne (Formula.all_past (Formula.neg φ)))) h_neg_P
      have h_HH_neg := SetMaximalConsistent.all_past_all_past h_mcs_m h_H_neg
      have h_H_neg_succ : Formula.all_past (Formula.neg φ) ∈ (bwd_chain M₀ h₀ (m + 1)).val :=
        bwd_chain_h_content_step M₀ h₀ m h_HH_neg
      intro h_P_succ
      have h_neg_P_succ : (Formula.some_past φ).neg ∈ (bwd_chain M₀ h₀ (m + 1)).val :=
        SetMaximalConsistent.implication_property (bwd_chain M₀ h₀ (m + 1)).property
          (theorem_in_mcs (bwd_chain M₀ h₀ (m + 1)).property
            (dni (Formula.all_past (Formula.neg φ)))) h_H_neg_succ
      exact set_consistent_not_both (bwd_chain M₀ h₀ (m + 1)).property.1
        (Formula.some_past φ) h_P_succ h_neg_P_succ

/-! ## Restricted Temporal Coherence -/

/-- Restricted temporal coherence for bx_bfmcs.

The forward F-resolution and backward P-resolution require proving that
F/P obligations in the chain eventually get resolved. This is currently
open due to the Lindenbaum step not preserving F/P obligations. -/
theorem bx_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (bx_bfmcs M₀ h₀).restricted_temporally_coherent root := by
  sorry

/-! ## Restricted Until/Since Coherence -/

theorem bx_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (bx_bfmcs M₀ h₀).restricted_backward_until_since_coherent root := by
  sorry

theorem bx_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (bx_bfmcs M₀ h₀).restricted_forward_until_since_coherent root := by
  sorry

/-! ## Countermodel -/

theorem dd_countermodel (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  refine ⟨Int, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (bx_bfmcs M h_mcs),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (shifted_bx_fmcs M h_mcs 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨shifted_bx_fmcs M h_mcs 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (shifted_bx_fmcs M h_mcs 0).mcs 0 := by
    rw [shifted_bx_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (bx_bfmcs M h_mcs) φ
    (bx_bfmcs_restricted_tc M h_mcs φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (bx_bfmcs_restricted_buc M h_mcs φ)
    (bx_bfmcs_restricted_fuc M h_mcs φ)
    φ (self_mem_subformulaClosure φ)
    (shifted_bx_fmcs M h_mcs 0) ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

end Bimodal.Metalogic.BXCanonical
