import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Metalogic.Bundle.TemporalContent

/-!
# MCS Witness Successor Construction

This module builds a sorry-free successor construction for DeferralRestrictedSerialMCS
by leveraging `temporal_theory_witness_exists` (sorry-free) from UltrafilterChain.lean.

## Strategy

Given a DRM u over phi with F(target) in u:
1. Extend u to a full MCS M via `set_lindenbaum` (u is consistent)
2. F(target) in M (since u subset M)
3. Apply `temporal_theory_witness_exists` to M and target: get MCS W with:
   - target in W
   - G-agree: G(a) in M -> G(a) in W
   - box_class_agree(M, W)
4. Intersect W with deferralClosure(phi) to get a DeferralRestricted consistent seed
5. Extend via `deferral_restricted_lindenbaum` to get a DRM successor
6. The successor contains target (from seed) and g_content(u) (from G-agree + T-axiom)

## References

- `temporal_theory_witness_exists` (UltrafilterChain.lean:2212) - sorry-free
- `past_theory_witness_exists` (UltrafilterChain.lean:2439) - sorry-free
- `deferral_restricted_lindenbaum` (RestrictedMCS.lean) - sorry-free
- `g_content_subset_deferralClosure` (SuccChainFMCS.lean) - sorry-free
-/

namespace Bimodal.Metalogic.Bundle.MCSWitnessSuccessor

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.UltrafilterChain

/-! ## Extending DRM to Full MCS -/

/--
Extend a DRM u to a full MCS. Since u is consistent, Lindenbaum gives an MCS extending u.
-/
noncomputable def drm_extend_to_mcs (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : Set Formula :=
  (set_lindenbaum u (deferral_restricted_mcs_is_consistent h_drm)).choose

theorem drm_extend_to_mcs_extends (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    u ⊆ drm_extend_to_mcs phi u h_drm :=
  (set_lindenbaum u (deferral_restricted_mcs_is_consistent h_drm)).choose_spec.1

theorem drm_extend_to_mcs_is_mcs (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    SetMaximalConsistent (drm_extend_to_mcs phi u h_drm) :=
  (set_lindenbaum u (deferral_restricted_mcs_is_consistent h_drm)).choose_spec.2

/-! ## DRM from any MCS via Witness Seed -/

/--
The witness seed: W intersected with deferralClosure(phi).
This is DeferralRestricted and consistent (subset of consistent W).
-/
def mcs_witness_seed (phi : Formula) (W : Set Formula) : Set Formula :=
  W ∩ (deferralClosure phi : Set Formula)

theorem mcs_witness_seed_restricted (phi : Formula) (W : Set Formula) :
    DeferralRestricted phi (mcs_witness_seed phi W) :=
  fun _ hx => hx.2

theorem mcs_witness_seed_consistent (phi : Formula) (W : Set Formula)
    (h_mcs : SetMaximalConsistent W) :
    SetConsistent (mcs_witness_seed phi W) :=
  fun L hL => h_mcs.1 L (fun x hx => (hL x hx).1)

/--
The MCS witness successor DRM: extend W ∩ deferralClosure(phi) to a DRM.
-/
noncomputable def mcs_witness_successor_drm (phi : Formula) (W : Set Formula)
    (h_mcs : SetMaximalConsistent W) : Set Formula :=
  (deferral_restricted_lindenbaum phi (mcs_witness_seed phi W)
    (mcs_witness_seed_restricted phi W)
    (mcs_witness_seed_consistent phi W h_mcs)).choose

theorem mcs_witness_successor_drm_extends (phi : Formula) (W : Set Formula)
    (h_mcs : SetMaximalConsistent W) :
    mcs_witness_seed phi W ⊆ mcs_witness_successor_drm phi W h_mcs :=
  (deferral_restricted_lindenbaum phi (mcs_witness_seed phi W)
    (mcs_witness_seed_restricted phi W)
    (mcs_witness_seed_consistent phi W h_mcs)).choose_spec.1

theorem mcs_witness_successor_is_drm (phi : Formula) (W : Set Formula)
    (h_mcs : SetMaximalConsistent W) :
    DeferralRestrictedMCS phi (mcs_witness_successor_drm phi W h_mcs) :=
  (deferral_restricted_lindenbaum phi (mcs_witness_seed phi W)
    (mcs_witness_seed_restricted phi W)
    (mcs_witness_seed_consistent phi W h_mcs)).choose_spec.2

/--
If a formula is in W and in deferralClosure(phi), it is in the successor DRM.
-/
theorem in_witness_and_dc_implies_in_successor (phi : Formula) (W : Set Formula)
    (h_mcs : SetMaximalConsistent W)
    (psi : Formula) (h_in_W : psi ∈ W) (h_dc : psi ∈ deferralClosure phi) :
    psi ∈ mcs_witness_successor_drm phi W h_mcs :=
  mcs_witness_successor_drm_extends phi W h_mcs ⟨h_in_W, h_dc⟩

/-! ## Forward Witness: temporal_theory_witness_exists -/

/--
The forward temporal witness bundle: packages the MCS W and all its properties
from `temporal_theory_witness_exists`.
-/
noncomputable def forward_witness_bundle
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    { W : Set Formula // SetMaximalConsistent W ∧ target ∈ W ∧
      (∀ a, Formula.all_future a ∈ drm_extend_to_mcs phi u h_drm →
        Formula.all_future a ∈ W) ∧
      box_class_agree (drm_extend_to_mcs phi u h_drm) W } :=
  let M := drm_extend_to_mcs phi u h_drm
  let h_mcs := drm_extend_to_mcs_is_mcs phi u h_drm
  let h_F_in_M := drm_extend_to_mcs_extends phi u h_drm h_F_target
  let h := temporal_theory_witness_exists M h_mcs target h_F_in_M
  ⟨h.choose, h.choose_spec⟩

/--
The forward witness MCS.
-/
noncomputable def witness_mcs
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    Set Formula :=
  (forward_witness_bundle phi u h_drm target h_F_target).val

theorem witness_mcs_is_mcs
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    SetMaximalConsistent (witness_mcs phi u h_drm target h_F_target) :=
  (forward_witness_bundle phi u h_drm target h_F_target).property.1

theorem witness_mcs_has_target
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    target ∈ witness_mcs phi u h_drm target h_F_target :=
  (forward_witness_bundle phi u h_drm target h_F_target).property.2.1

theorem witness_mcs_G_agree
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    ∀ a, Formula.all_future a ∈ drm_extend_to_mcs phi u h_drm →
    Formula.all_future a ∈ witness_mcs phi u h_drm target h_F_target :=
  (forward_witness_bundle phi u h_drm target h_F_target).property.2.2.1

theorem witness_mcs_box_agree
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u) :
    box_class_agree (drm_extend_to_mcs phi u h_drm)
      (witness_mcs phi u h_drm target h_F_target) :=
  (forward_witness_bundle phi u h_drm target h_F_target).property.2.2.2

/-! ## Backward Witness: past_theory_witness_exists -/

/--
The backward temporal witness bundle.
-/
noncomputable def backward_witness_bundle
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    { W : Set Formula // SetMaximalConsistent W ∧ target ∈ W ∧
      (∀ a, Formula.all_past a ∈ drm_extend_to_mcs phi u h_drm →
        Formula.all_past a ∈ W) ∧
      box_class_agree (drm_extend_to_mcs phi u h_drm) W } :=
  let M := drm_extend_to_mcs phi u h_drm
  let h_mcs := drm_extend_to_mcs_is_mcs phi u h_drm
  let h_P_in_M := drm_extend_to_mcs_extends phi u h_drm h_P_target
  let h := past_theory_witness_exists M h_mcs target h_P_in_M
  ⟨h.choose, h.choose_spec⟩

noncomputable def past_witness_mcs
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    Set Formula :=
  (backward_witness_bundle phi u h_drm target h_P_target).val

theorem past_witness_mcs_is_mcs
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    SetMaximalConsistent (past_witness_mcs phi u h_drm target h_P_target) :=
  (backward_witness_bundle phi u h_drm target h_P_target).property.1

theorem past_witness_mcs_has_target
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    target ∈ past_witness_mcs phi u h_drm target h_P_target :=
  (backward_witness_bundle phi u h_drm target h_P_target).property.2.1

theorem past_witness_mcs_H_agree
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    ∀ a, Formula.all_past a ∈ drm_extend_to_mcs phi u h_drm →
    Formula.all_past a ∈ past_witness_mcs phi u h_drm target h_P_target :=
  (backward_witness_bundle phi u h_drm target h_P_target).property.2.2.1

theorem past_witness_mcs_box_agree
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u) :
    box_class_agree (drm_extend_to_mcs phi u h_drm)
      (past_witness_mcs phi u h_drm target h_P_target) :=
  (backward_witness_bundle phi u h_drm target h_P_target).property.2.2.2

/-! ## Targeted Forward Successor -/

/--
Build a targeted DRM successor from a DRM u with F(target) in u.
The successor contains target and preserves g_content(u).
-/
noncomputable def build_targeted_successor
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    Set Formula :=
  mcs_witness_successor_drm phi
    (witness_mcs phi u h_drm target h_F_target)
    (witness_mcs_is_mcs phi u h_drm target h_F_target)

theorem build_targeted_successor_is_drm
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    DeferralRestrictedMCS phi
      (build_targeted_successor phi u h_drm target h_F_target h_target_dc) :=
  mcs_witness_successor_is_drm phi _ _

theorem build_targeted_successor_has_target
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    target ∈ build_targeted_successor phi u h_drm target h_F_target h_target_dc :=
  in_witness_and_dc_implies_in_successor phi _ _ target
    (witness_mcs_has_target phi u h_drm target h_F_target) h_target_dc

theorem build_targeted_successor_g_persistence
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    g_content u ⊆ build_targeted_successor phi u h_drm target h_F_target h_target_dc := by
  intro a ha
  have h_Ga_u : Formula.all_future a ∈ u := ha
  have h_Ga_M := drm_extend_to_mcs_extends phi u h_drm h_Ga_u
  have h_Ga_W := witness_mcs_G_agree phi u h_drm target h_F_target a h_Ga_M
  have h_W_mcs := witness_mcs_is_mcs phi u h_drm target h_F_target
  have h_a_W : a ∈ witness_mcs phi u h_drm target h_F_target :=
    SetMaximalConsistent.implication_property h_W_mcs
      (theorem_in_mcs h_W_mcs
        (DerivationTree.axiom _ _ (Axiom.temp_t_future a))) h_Ga_W
  have h_a_dc := g_content_subset_deferralClosure phi u h_drm.1.1 ha
  exact in_witness_and_dc_implies_in_successor phi _ h_W_mcs a h_a_W h_a_dc

theorem build_targeted_successor_has_F_top
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    F_top ∈ build_targeted_successor phi u h_drm target h_F_target h_target_dc :=
  theorem_in_drm (build_targeted_successor_is_drm phi u h_drm target h_F_target h_target_dc)
    F_top_theorem (Bimodal.Syntax.F_top_mem_deferralClosure phi)

theorem build_targeted_successor_has_P_top
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    P_top ∈ build_targeted_successor phi u h_drm target h_F_target h_target_dc :=
  theorem_in_drm (build_targeted_successor_is_drm phi u h_drm target h_F_target h_target_dc)
    P_top_theorem (Bimodal.Syntax.P_top_mem_deferralClosure phi)

/-! ## Targeted Backward Predecessor -/

noncomputable def build_targeted_predecessor
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    Set Formula :=
  mcs_witness_successor_drm phi
    (past_witness_mcs phi u h_drm target h_P_target)
    (past_witness_mcs_is_mcs phi u h_drm target h_P_target)

theorem build_targeted_predecessor_is_drm
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    DeferralRestrictedMCS phi
      (build_targeted_predecessor phi u h_drm target h_P_target h_target_dc) :=
  mcs_witness_successor_is_drm phi _ _

theorem build_targeted_predecessor_has_target
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    target ∈ build_targeted_predecessor phi u h_drm target h_P_target h_target_dc :=
  in_witness_and_dc_implies_in_successor phi _ _ target
    (past_witness_mcs_has_target phi u h_drm target h_P_target) h_target_dc

theorem build_targeted_predecessor_h_persistence
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    h_content u ⊆ build_targeted_predecessor phi u h_drm target h_P_target h_target_dc := by
  intro a ha
  have h_Ha_u : Formula.all_past a ∈ u := ha
  have h_Ha_M := drm_extend_to_mcs_extends phi u h_drm h_Ha_u
  have h_Ha_W := past_witness_mcs_H_agree phi u h_drm target h_P_target a h_Ha_M
  have h_W_mcs := past_witness_mcs_is_mcs phi u h_drm target h_P_target
  have h_a_W : a ∈ past_witness_mcs phi u h_drm target h_P_target :=
    SetMaximalConsistent.implication_property h_W_mcs
      (theorem_in_mcs h_W_mcs
        (DerivationTree.axiom _ _ (Axiom.temp_t_past a))) h_Ha_W
  have h_a_dc := h_content_subset_deferralClosure phi u h_drm.1.1 ha
  exact in_witness_and_dc_implies_in_successor phi _ h_W_mcs a h_a_W h_a_dc

theorem build_targeted_predecessor_has_F_top
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    F_top ∈ build_targeted_predecessor phi u h_drm target h_P_target h_target_dc :=
  theorem_in_drm (build_targeted_predecessor_is_drm phi u h_drm target h_P_target h_target_dc)
    F_top_theorem (Bimodal.Syntax.F_top_mem_deferralClosure phi)

theorem build_targeted_predecessor_has_P_top
    (phi : Formula) (u : Set Formula) (h_drm : DeferralRestrictedMCS phi u)
    (target : Formula) (h_P_target : Formula.some_past target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    P_top ∈ build_targeted_predecessor phi u h_drm target h_P_target h_target_dc :=
  theorem_in_drm (build_targeted_predecessor_is_drm phi u h_drm target h_P_target h_target_dc)
    P_top_theorem (Bimodal.Syntax.P_top_mem_deferralClosure phi)

end Bimodal.Metalogic.Bundle.MCSWitnessSuccessor
