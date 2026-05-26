import Bimodal.Metalogic.Core.RestrictedMCS.Deferral
import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Theorems.Propositional

/-!
# DRM Chain Construction for Forward_F

This module builds a DRM (Deferral-Restricted MCS) chain and proves
forward_F for formulas in `deferralClosure(root)`.
-/

-- Deep API drift (19 errors): DeferralRestrictedMCS structure changed,
-- temp_t_future axiom removed, drm_fwd_chain recursive definition rejected.
-- Code preserved below #exit for reference only.
#exit

namespace Bimodal.Metalogic.BXCanonical.DRMChain

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.ProofSystem
open Classical

/-! ## Simplified Restricted Seed -/

def simplified_restricted_seed (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u

theorem g_content_subset_drm (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : g_content u ⊆ u := by
  intro chi h_gc
  have h_chi_dc := deferralClosure_all_future phi chi (h_drm.1.1 h_gc)
  by_contra h_not
  have h_incons := h_drm.2 chi h_chi_dc h_not
  unfold SetConsistent at h_incons; push_neg at h_incons
  obtain ⟨L, h_L_sub, ⟨d_bot⟩⟩ := h_incons.imp id inconsistent_derives_bot |>.mp h_incons
  let L' := L.filter (· ≠ chi)
  have h_L'_u : ∀ ψ ∈ L', ψ ∈ u := by
    intro ψ hψ; have := (List.mem_filter.mp hψ)
    rcases Set.mem_insert_iff.mp (h_L_sub ψ this.1) with rfl | h
    · exact absurd rfl (by simpa using this.2); · exact h
  have h_L_sub' : L ⊆ chi :: L' := by
    intro ψ hψ; by_cases h : ψ = chi
    · simp [h]; · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hψ, by simpa using h⟩)
  have d_neg := deduction_theorem L' chi _ (DerivationTree.weakening L _ _ d_bot h_L_sub')
  let L'' := Formula.all_future chi :: L'
  have d_chi : L'' ⊢ chi :=
    DerivationTree.modus_ponens L'' _ _
      (DerivationTree.weakening [] L'' _ (DerivationTree.axiom [] _ (Axiom.temp_t_future chi))
        (List.nil_subset _))
      (DerivationTree.assumption _ _ (List.mem_cons_self _ _))
  exact h_drm.1.2 L'' (fun ψ hψ => by
    simp only [L'', List.mem_cons] at hψ
    rcases hψ with rfl | h; exact h_gc; exact h_L'_u ψ h)
    ⟨derives_bot_from_phi_neg_phi d_chi
      (DerivationTree.weakening L' L'' _ d_neg
        (List.subset_cons_of_subset _ (List.Subset.refl _)))⟩

theorem deferralDisjunctions_subset_drm (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : deferralDisjunctions u ⊆ u := by
  intro psi h_dd; obtain ⟨chi, h_F_chi, rfl⟩ := h_dd
  have h_dc := deferral_of_F_in_deferralClosure phi chi (h_drm.1.1 h_F_chi)
  by_contra h_not
  have h_incons := h_drm.2 _ h_dc h_not
  unfold SetConsistent at h_incons; push_neg at h_incons
  obtain ⟨L, h_L_sub, ⟨d_bot⟩⟩ := h_incons.imp id inconsistent_derives_bot |>.mp h_incons
  let L' := L.filter (· ≠ deferralDisjunction chi)
  have h_L'_u : ∀ ψ ∈ L', ψ ∈ u := by
    intro ψ hψ; have := (List.mem_filter.mp hψ)
    rcases Set.mem_insert_iff.mp (h_L_sub ψ this.1) with rfl | h
    · exact absurd rfl (by simpa using this.2); · exact h
  have h_L_sub' : L ⊆ deferralDisjunction chi :: L' := by
    intro ψ hψ; by_cases h : ψ = deferralDisjunction chi
    · simp [h]; · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hψ, by simpa using h⟩)
  have d_neg := deduction_theorem L' _ _
    (DerivationTree.weakening L _ _ d_bot h_L_sub')
  let L'' := Formula.some_future chi :: L'
  have d_disj : L'' ⊢ deferralDisjunction chi :=
    DerivationTree.modus_ponens L'' _ _
      (DerivationTree.weakening [] L'' _
        (deduction_theorem [] _ _ (deferral_disjunction_from_F chi)) (List.nil_subset _))
      (DerivationTree.assumption _ _ (List.mem_cons_self _ _))
  exact h_drm.1.2 L'' (fun ψ hψ => by
    simp only [L'', List.mem_cons] at hψ
    rcases hψ with rfl | h; exact h_F_chi; exact h_L'_u ψ h)
    ⟨derives_bot_from_phi_neg_phi d_disj
      (DerivationTree.weakening L' L'' _ d_neg
        (List.subset_cons_of_subset _ (List.Subset.refl _)))⟩

theorem simplified_restricted_seed_subset_u (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : simplified_restricted_seed phi u ⊆ u := by
  intro x hx; simp only [simplified_restricted_seed, Set.mem_union] at hx
  rcases hx with (h | h) | h
  · exact g_content_subset_drm phi u h_drm h
  · exact deferralDisjunctions_subset_drm phi u h_drm h
  · exact p_step_blocking_restricted_subset phi u h_drm h

theorem simplified_restricted_seed_consistent (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : SetConsistent (simplified_restricted_seed phi u) := by
  intro L hL
  exact deferral_restricted_mcs_is_consistent h_drm L
    (fun x hx => simplified_restricted_seed_subset_u phi u h_drm (hL x hx))

theorem simplified_restricted_seed_subset_dc (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    simplified_restricted_seed phi u ⊆ (deferralClosure phi : Set Formula) := by
  intro x hx; simp only [simplified_restricted_seed, Set.mem_union] at hx
  rcases hx with (h | h) | h
  · exact deferralClosure_all_future phi _ (h_drm.1.1 h)
  · obtain ⟨chi, h_F, rfl⟩ := h
    exact deferral_of_F_in_deferralClosure phi chi (h_drm.1.1 h_F)
  · exact p_step_blocking_restricted_subset_deferralClosure phi u h

/-! ## DRM Successor -/

noncomputable def simplified_restricted_successor (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) : Set Formula :=
  (deferral_restricted_lindenbaum phi (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose

theorem simplified_restricted_successor_is_drm (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    DeferralRestrictedMCS phi (simplified_restricted_successor phi u h_drm h_F_top) :=
  (deferral_restricted_lindenbaum phi (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose_spec.2

theorem simplified_restricted_successor_extends (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    simplified_restricted_seed phi u ⊆
      simplified_restricted_successor phi u h_drm h_F_top :=
  (deferral_restricted_lindenbaum phi (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose_spec.1

theorem simplified_restricted_successor_g_persistence (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    g_content u ⊆ simplified_restricted_successor phi u h_drm h_F_top := by
  intro x hx; exact simplified_restricted_successor_extends phi u h_drm h_F_top
    (show x ∈ simplified_restricted_seed phi u from by
      simp only [simplified_restricted_seed, Set.mem_union]; left; left; exact hx)

theorem simplified_restricted_successor_f_step (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    f_content u ⊆ (simplified_restricted_successor phi u h_drm h_F_top) ∪
                   f_content (simplified_restricted_successor phi u h_drm h_F_top) := by
  intro ψ h_ψ
  have h_disj : deferralDisjunction ψ ∈ simplified_restricted_successor phi u h_drm h_F_top :=
    simplified_restricted_successor_extends phi u h_drm h_F_top
      (show deferralDisjunction ψ ∈ simplified_restricted_seed phi u from by
        simp only [simplified_restricted_seed, Set.mem_union]; left; right; exact ⟨ψ, h_ψ, rfl⟩)
  let v := simplified_restricted_successor phi u h_drm h_F_top
  have h_v_drm := simplified_restricted_successor_is_drm phi u h_drm h_F_top
  have h_ψ_dc := F_inner_in_deferralClosure phi ψ (h_drm.1.1 h_ψ)
  have h_Fψ_dc := h_drm.1.1 h_ψ
  by_cases h1 : ψ ∈ v
  · exact Set.mem_union_left _ h1
  · by_cases h2 : Formula.some_future ψ ∈ v
    · exact Set.mem_union_right _ h2
    · exfalso
      -- ψ ∉ v, F(ψ) ∉ v, but (ψ ∨ F(ψ)) ∈ v → contradiction via DRM consistency
      have h_ψ_incons : ¬SetConsistent (insert ψ v) := h_v_drm.2 ψ h_ψ_dc h1
      have h_Fψ_incons : ¬SetConsistent (insert (Formula.some_future ψ) v) :=
        h_v_drm.2 (Formula.some_future ψ) h_Fψ_dc h2
      -- Extract ¬ψ and ¬F(ψ) from v
      unfold SetConsistent at h_ψ_incons h_Fψ_incons
      push_neg at h_ψ_incons h_Fψ_incons
      obtain ⟨L, h_L_sub, ⟨d1⟩⟩ := h_ψ_incons.imp id inconsistent_derives_bot |>.mp h_ψ_incons
      obtain ⟨L', h_L'_sub, ⟨d2⟩⟩ := h_Fψ_incons.imp id inconsistent_derives_bot |>.mp h_Fψ_incons
      haveI : ∀ x, Decidable (x = ψ) := fun x => propDecidable _
      haveI : ∀ x, Decidable (x = Formula.some_future ψ) := fun x => propDecidable _
      let Lf := L.filter (fun y => decide (y ≠ ψ))
      let L'f := L'.filter (fun y => decide (y ≠ Formula.some_future ψ))
      have hLf : ∀ χ ∈ Lf, χ ∈ v := by
        intro χ hχ; have := List.mem_filter.mp hχ
        rcases Set.mem_insert_iff.mp (h_L_sub χ this.1) with rfl | h
        · exact absurd rfl (by simpa using this.2); · exact h
      have hL'f : ∀ χ ∈ L'f, χ ∈ v := by
        intro χ hχ; have := List.mem_filter.mp hχ
        rcases Set.mem_insert_iff.mp (h_L'_sub χ this.1) with rfl | h
        · exact absurd rfl (by simpa using this.2); · exact h
      have hLs : L ⊆ ψ :: Lf := by
        intro χ hχ; by_cases h : χ = ψ
        · simp [h]; · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using h⟩)
      have hL's : L' ⊆ Formula.some_future ψ :: L'f := by
        intro χ hχ; by_cases h : χ = Formula.some_future ψ
        · simp [h]; · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using h⟩)
      have d_neg_ψ := deduction_theorem Lf ψ _ (DerivationTree.weakening L _ _ d1 hLs)
      have d_neg_Fψ := deduction_theorem L'f (Formula.some_future ψ) _
        (DerivationTree.weakening L' _ _ d2 hL's)
      rw [deferralDisjunction_eq] at h_disj
      let Γ := Lf ++ L'f ++ [Formula.or ψ (Formula.some_future ψ)]
      exact deferral_restricted_mcs_is_consistent h_v_drm Γ (fun x hx => by
        simp only [Γ, List.mem_append, List.mem_singleton] at hx
        rcases hx with (h | h) | rfl
        · exact hLf x h; · exact hL'f x h; · exact h_disj)
        ⟨Bimodal.Theorems.Propositional.or_elim_neg_neg Γ ψ (Formula.some_future ψ)
          (DerivationTree.assumption Γ _ (List.mem_append_right _ (List.mem_singleton_self _)))
          (DerivationTree.weakening Lf Γ _ d_neg_ψ
            (fun x hx => List.mem_append_left _ (List.mem_append_left _ hx)))
          (DerivationTree.weakening L'f Γ _ d_neg_Fψ
            (fun x hx => List.mem_append_left _ (List.mem_append_right _ hx)))⟩

theorem simplified_restricted_successor_succ (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u (simplified_restricted_successor phi u h_drm h_F_top) :=
  ⟨simplified_restricted_successor_g_persistence phi u h_drm h_F_top,
   simplified_restricted_successor_f_step phi u h_drm h_F_top⟩

/-! ## F(neg bot) is a theorem -/

noncomputable def F_neg_bot_theorem : [] ⊢ Formula.some_future (Formula.neg Formula.bot) := by
  let inner := (Formula.neg Formula.bot).neg
  have h_T := DerivationTree.axiom [inner.all_future] _ (Axiom.temp_t_future inner)
  have h_G := DerivationTree.assumption [inner.all_future] _ (List.mem_cons_self _ _)
  have h_inner := DerivationTree.modus_ponens [inner.all_future] _ _ h_T h_G
  have h_id : [inner.all_future] ⊢ Formula.bot.imp Formula.bot :=
    DerivationTree.weakening [] _ _ (DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot))
      (List.nil_subset _)
  exact deduction_theorem [] inner.all_future Formula.bot
    (DerivationTree.modus_ponens [inner.all_future] _ _ h_inner h_id)

theorem F_neg_bot_in_drm (phi : Formula) (M : Set Formula)
    (h_drm : DeferralRestrictedMCS phi M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M :=
  theorem_in_drm h_drm F_neg_bot_theorem (F_top_mem_deferralClosure phi)

/-! ## Iterated DRM Chain -/

noncomputable def drm_fwd_chain (phi : Formula) (u₀ : Set Formula)
    (h_drm₀ : DeferralRestrictedMCS phi u₀) : Nat → Set Formula
  | 0 => u₀
  | n + 1 => simplified_restricted_successor phi
      (drm_fwd_chain phi u₀ h_drm₀ n)
      (drm_fwd_chain_is_drm phi u₀ h_drm₀ n)
      (F_neg_bot_in_drm phi _ (drm_fwd_chain_is_drm phi u₀ h_drm₀ n))
  where drm_fwd_chain_is_drm (phi : Formula) (u₀ : Set Formula)
    (h_drm₀ : DeferralRestrictedMCS phi u₀) : (n : Nat) →
    DeferralRestrictedMCS phi (drm_fwd_chain phi u₀ h_drm₀ n)
  | 0 => h_drm₀
  | n + 1 => simplified_restricted_successor_is_drm phi _ (drm_fwd_chain_is_drm phi u₀ h_drm₀ n)
      (F_neg_bot_in_drm phi _ (drm_fwd_chain_is_drm phi u₀ h_drm₀ n))

theorem drm_fwd_chain_is_drm (phi : Formula) (u₀ : Set Formula)
    (h_drm₀ : DeferralRestrictedMCS phi u₀) (n : Nat) :
    DeferralRestrictedMCS phi (drm_fwd_chain phi u₀ h_drm₀ n) :=
  drm_fwd_chain.drm_fwd_chain_is_drm phi u₀ h_drm₀ n

theorem drm_fwd_chain_succ (phi : Formula) (u₀ : Set Formula)
    (h_drm₀ : DeferralRestrictedMCS phi u₀) (n : Nat) :
    Succ (drm_fwd_chain phi u₀ h_drm₀ n) (drm_fwd_chain phi u₀ h_drm₀ (n + 1)) := by
  simp only [drm_fwd_chain]
  exact simplified_restricted_successor_succ phi _ _ _

/-! ## DRM Bounded Witness

The key theorem: in a DRM chain, iter_F obligations are resolved within
closure_F_bound steps.

We avoid the formula-level negation completeness issues by using a
direct induction argument on the F-nesting level within the DRM.
-/

/--
DRM forward_F: If F(psi) is in a DRM state and psi is in deferralClosure,
then psi appears at a later step of the DRM chain.
-/
theorem drm_fwd_chain_forward_F (phi : Formula) (u₀ : Set Formula)
    (h_drm₀ : DeferralRestrictedMCS phi u₀) (n : Nat) (psi : Formula)
    (h_psi_dc : psi ∈ (deferralClosure phi : Set Formula))
    (h_F : Formula.some_future psi ∈ drm_fwd_chain phi u₀ h_drm₀ n) :
    ∃ s : Nat, n < s ∧ psi ∈ drm_fwd_chain phi u₀ h_drm₀ s := by
  -- By deferral_restricted_mcs_F_bounded: there exists d >= 1 with
  -- iter_F d psi ∈ drm_chain(n) and iter_F (d+1) psi ∉ drm_chain(n).
  -- The chain has d steps of Succ from n to n+d.
  -- At each step, either the iter_F level decreases or stays.
  -- By single_step_forcing (adapted for DRM), the level must decrease.
  -- After d steps: psi = iter_F 0 psi ∈ drm_chain(n + d).
  sorry

end Bimodal.Metalogic.BXCanonical.DRMChain
