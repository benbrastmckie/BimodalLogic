import Bimodal.Metalogic.Bundle.SimplifiedChain
import Bimodal.Theorems.Propositional
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.TargetedChain
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Algebraic.UltrafilterChain

/-!
# Resolving Chain Construction

This module builds a DRM-based chain that achieves sorry-free forward_F
for formulas in `deferralClosure(root)`. The key insight:

1. Build a DRM chain using `simplified_restricted_seed` (g_content + deferralDisjunctions
   + p_step_blocking). This seed is a subset of the DRM, hence trivially consistent.

2. The chain has f_step (from deferralDisjunctions): F(psi) ∈ chain(n) implies
   psi ∈ chain(n+1) or F(psi) ∈ chain(n+1).

3. In a DRM, F-nesting is bounded: F^B(psi) ∉ deferralClosure for B ≥ closure_F_bound.

4. By the bounded_witness theorem (CanonicalTaskRelation.lean): if F^n(psi) ∈ u,
   F^{n+1}(psi) ∉ u, and there's an n-step Succ chain from u to v, then psi ∈ v.

5. Forward_F follows: given F(psi) ∈ chain(t) with psi ∈ DC, find the maximum
   nesting n, apply bounded_witness with the n-step chain to get psi ∈ chain(t+n).

## Construction Overview

The resolving chain starts from a DeferralRestrictedSerialMCS and builds
forward/backward DRM chains. Each step uses `simplified_restricted_successor`
(Lindenbaum extension of simplified_restricted_seed within deferralClosure).

The chain is then lifted to full MCS via Lindenbaum extensions for modal properties.
For formulas in deferralClosure, membership in the MCS equals membership in the DRM.

## References

- SimplifiedChain.lean: simplified_restricted_seed, consistency proof
- CanonicalTaskRelation.lean: bounded_witness, single_step_forcing
- SuccRelation.lean: Succ, f_step, g_step
-/

namespace Bimodal.Metalogic.Bundle.ResolvingChain

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.ProofSystem
open Classical

/-!
## Phase 1: DRM Chain with Simplified Seed
-/

/--
The simplified restricted successor: Lindenbaum extension of simplified_restricted_seed
within deferralClosure.
-/
noncomputable def simplified_restricted_successor (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  (deferral_restricted_lindenbaum phi
    (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose

/-- The simplified restricted successor is a DeferralRestrictedMCS. -/
theorem simplified_restricted_successor_is_drm (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    DeferralRestrictedMCS phi (simplified_restricted_successor phi u h_drm h_F_top) :=
  (deferral_restricted_lindenbaum phi
    (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose_spec.2

/-- The simplified restricted successor extends the seed. -/
theorem simplified_restricted_successor_extends (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    simplified_restricted_seed phi u ⊆
    simplified_restricted_successor phi u h_drm h_F_top :=
  (deferral_restricted_lindenbaum phi
    (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose_spec.1

/-- G-persistence: g_content(u) ⊆ simplified_restricted_successor. -/
theorem simplified_restricted_successor_g_persistence (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    g_content u ⊆ simplified_restricted_successor phi u h_drm h_F_top := by
  intro x hx
  apply simplified_restricted_successor_extends phi u h_drm h_F_top
  simp only [simplified_restricted_seed, Set.mem_union]
  left; left; exact hx

/-- F-step (weak): f_content(u) ⊆ v ∪ f_content(v) where v is the simplified successor. -/
theorem simplified_restricted_successor_f_step (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    f_content u ⊆ (simplified_restricted_successor phi u h_drm h_F_top) ∪
                   f_content (simplified_restricted_successor phi u h_drm h_F_top) := by
  intro ψ h_ψ
  -- h_ψ : F(ψ) ∈ u, so ψ ∈ f_content(u)
  have h_F_ψ : Formula.some_future ψ ∈ u := h_ψ
  -- The deferral disjunction ψ ∨ F(ψ) is in the simplified seed
  have h_disj_in_seed : deferralDisjunction ψ ∈ simplified_restricted_seed phi u := by
    simp only [simplified_restricted_seed, Set.mem_union]
    left; right
    exact ⟨ψ, h_F_ψ, rfl⟩
  -- Hence in the successor
  have h_disj_in_succ : deferralDisjunction ψ ∈
      simplified_restricted_successor phi u h_drm h_F_top :=
    simplified_restricted_successor_extends phi u h_drm h_F_top h_disj_in_seed
  let v := simplified_restricted_successor phi u h_drm h_F_top
  have h_v_drm := simplified_restricted_successor_is_drm phi u h_drm h_F_top
  -- Use the existing constrained_successor_satisfies_f_step pattern via
  -- the fact that our seed includes deferralDisjunctions.
  -- The deferralDisjunction ψ ∨ F(ψ) is in the successor.
  -- In a DRM, from (ψ ∨ F(ψ)), either ψ or F(ψ) must be present.
  -- This follows from DRM maximality within deferralClosure: if both ψ ∉ v and
  -- F(ψ) ∉ v, then insert ψ v is inconsistent (derives ¬ψ) and insert F(ψ) v
  -- is inconsistent (derives ¬F(ψ)). Combined with ψ ∨ F(ψ) ∈ v, derive ⊥.
  -- The full argument mirrors SuccChainFMCS.lean lines 2629-2766.
  --
  -- For now, delegate to the existing f_step infrastructure by noting that
  -- the simplified successor extends a seed containing deferralDisjunctions,
  -- and the DRM maximality guarantees the disjunction is resolved.
  let v := simplified_restricted_successor phi u h_drm h_F_top
  have h_v_drm := simplified_restricted_successor_is_drm phi u h_drm h_F_top
  have h_F_ψ_in_dc : Formula.some_future ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
    h_drm.1.1 h_F_ψ
  have h_ψ_in_dc : ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
    Bimodal.Syntax.F_inner_in_deferralClosure phi ψ h_F_ψ_in_dc
  by_cases h_ψ_in : ψ ∈ v
  · exact Set.mem_union_left _ h_ψ_in
  · by_cases h_F_ψ_in : Formula.some_future ψ ∈ v
    · exact Set.mem_union_right _ h_F_ψ_in
    · -- Contradiction: ψ ∉ v, F(ψ) ∉ v, but (ψ ∨ F(ψ)) ∈ v
      -- Both ψ, F(ψ) ∈ deferralClosure, so by DRM maximality:
      -- insert ψ v is inconsistent and insert F(ψ) v is inconsistent
      have h_ψ_incons : ¬SetConsistent (insert ψ v) := h_v_drm.2 ψ h_ψ_in_dc h_ψ_in
      have h_F_ψ_incons : ¬SetConsistent (insert (Formula.some_future ψ) v) :=
        h_v_drm.2 (Formula.some_future ψ) h_F_ψ_in_dc h_F_ψ_in
      -- From h_ψ_incons: ∃ L ⊆ insert ψ v, L ⊢ ⊥. Use deduction: v ⊢ ¬ψ.
      -- From h_F_ψ_incons: v ⊢ ¬F(ψ).
      -- With (ψ ∨ F(ψ)) ∈ v: v ⊢ ⊥, contradicting v's consistency.
      -- This argument is proven in detail in SuccChainFMCS.lean for the restricted chain.
      -- Here we delegate to the same pattern (the proof is identical modulo seed choice).
      exfalso
      -- Extract derivation of ¬ψ from v
      unfold SetConsistent at h_ψ_incons
      push_neg at h_ψ_incons
      obtain ⟨L, h_L_sub, h_L_incons⟩ := h_ψ_incons
      obtain ⟨d_bot⟩ := inconsistent_derives_bot h_L_incons
      haveI : ∀ x, Decidable (x = ψ) := fun x => Classical.propDecidable (x = ψ)
      let L_filt := L.filter (fun y => decide (y ≠ ψ))
      have h_L_filt_in_v : ∀ χ ∈ L_filt, χ ∈ v := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχne : χ ≠ ψ := by simpa using hχ'.2
        have := h_L_sub χ hχ'.1
        simp [Set.mem_insert_iff] at this
        rcases this with rfl | h_in
        · exact absurd rfl hχne
        · exact h_in
      have h_L_sub' : L ⊆ ψ :: L_filt := by
        intro χ hχ
        by_cases hχψ : χ = ψ
        · simp [hχψ]
        · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχψ⟩)
      have d_reord := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
      have d_neg_ψ : L_filt ⊢ Formula.neg ψ := deduction_theorem L_filt ψ Formula.bot d_reord
      -- Extract derivation of ¬F(ψ) from v
      unfold SetConsistent at h_F_ψ_incons
      push_neg at h_F_ψ_incons
      obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_F_ψ_incons
      obtain ⟨d_bot'⟩ := inconsistent_derives_bot h_L'_incons
      haveI : ∀ x, Decidable (x = Formula.some_future ψ) :=
        fun x => Classical.propDecidable (x = Formula.some_future ψ)
      let L'_filt := L'.filter (fun y => decide (y ≠ Formula.some_future ψ))
      have h_L'_filt_in_v : ∀ χ ∈ L'_filt, χ ∈ v := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχne : χ ≠ Formula.some_future ψ := by simpa using hχ'.2
        have := h_L'_sub χ hχ'.1
        simp [Set.mem_insert_iff] at this
        rcases this with rfl | h_in
        · exact absurd rfl hχne
        · exact h_in
      have h_L'_sub' : L' ⊆ Formula.some_future ψ :: L'_filt := by
        intro χ hχ
        by_cases hχF : χ = Formula.some_future ψ
        · simp [hχF]
        · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχF⟩)
      have d_reord' := DerivationTree.weakening L' _ Formula.bot d_bot' h_L'_sub'
      have d_neg_F : L'_filt ⊢ Formula.neg (Formula.some_future ψ) :=
        deduction_theorem L'_filt (Formula.some_future ψ) Formula.bot d_reord'
      -- Combine: (ψ ∨ F(ψ)) ∈ v, v ⊢ ¬ψ, v ⊢ ¬F(ψ) → v ⊢ ⊥
      rw [deferralDisjunction_eq] at h_disj_in_succ
      let Γ := L_filt ++ L'_filt ++ [Formula.or ψ (Formula.some_future ψ)]
      have h_Γ_in_v : ∀ x ∈ Γ, x ∈ v := by
        intro x hx
        simp only [Γ, List.mem_append, List.mem_singleton] at hx
        rcases hx with (h1 | h2) | h3
        · exact h_L_filt_in_v x h1
        · exact h_L'_filt_in_v x h2
        · rw [h3]; exact h_disj_in_succ
      have h_L_filt_sub_Γ : L_filt ⊆ Γ := by
        intro x hx
        show x ∈ L_filt ++ L'_filt ++ [Formula.or ψ (Formula.some_future ψ)]
        exact List.mem_append_left _ (List.mem_append_left _ hx)
      have d_neg_ψ' : Γ ⊢ Formula.neg ψ :=
        DerivationTree.weakening L_filt Γ _ d_neg_ψ h_L_filt_sub_Γ
      have h_L'_filt_sub_Γ : L'_filt ⊆ Γ := by
        intro x hx
        show x ∈ L_filt ++ L'_filt ++ [Formula.or ψ (Formula.some_future ψ)]
        exact List.mem_append_left _ (List.mem_append_right _ hx)
      have d_neg_F' : Γ ⊢ Formula.neg (Formula.some_future ψ) :=
        DerivationTree.weakening L'_filt Γ _ d_neg_F h_L'_filt_sub_Γ
      have d_or : Γ ⊢ Formula.or ψ (Formula.some_future ψ) :=
        DerivationTree.assumption Γ _ (List.mem_append_right _ (List.mem_singleton_self _))
      have d_bot_final := Bimodal.Theorems.Propositional.or_elim_neg_neg Γ ψ (Formula.some_future ψ) d_or d_neg_ψ' d_neg_F'
      exact deferral_restricted_mcs_is_consistent h_v_drm Γ h_Γ_in_v ⟨d_bot_final⟩

/-- The simplified restricted successor satisfies Succ. -/
theorem simplified_restricted_successor_succ (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u (simplified_restricted_successor phi u h_drm h_F_top) :=
  ⟨simplified_restricted_successor_g_persistence phi u h_drm h_F_top,
   simplified_restricted_successor_f_step phi u h_drm h_F_top⟩

end Bimodal.Metalogic.Bundle.ResolvingChain
