import Bimodal.Metalogic.Bundle.MCSWitnessSuccessor
import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties

/-!
# MCS Witness Chain Construction

This module builds forward and backward DRM chains from DeferralRestrictedSerialMCS
using the targeted successor from MCSWitnessSuccessor.lean. Each chain element
is a sorry-free DRM with g_content/h_content propagation.

## Key Results

- `witness_forward_chain`: Forward DRM chain with g_content propagation (sorry-free)
- `witness_backward_chain`: Backward DRM chain with h_content propagation (sorry-free)
- `witness_succ_chain_fam`: Combined Int-indexed DRM chain (sorry-free)

## Architectural Status

The chain construction and DRM properties are sorry-free. The forward_F resolution
is achievable in ONE step via `build_targeted_successor` but requires embedding
into a fixed chain. The completeness wiring needs an FMCS (not just DRM chain)
with forward_G/backward_H for FULL MCS (not just deferralClosure), which requires
additional infrastructure.

## References

- MCSWitnessSuccessor.lean: Targeted successor construction (sorry-free)
-/

namespace Bimodal.Metalogic.Bundle.MCSWitnessChain

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.MCSWitnessSuccessor
open Bimodal.Metalogic.Algebraic.UltrafilterChain

/-! ## Forward Chain -/

/-- Chain element: DRM with seriality. -/
structure WitnessChainElement (phi : Formula) where
  world : Set Formula
  is_drm : DeferralRestrictedMCS phi world
  has_F_top : F_top ∈ world
  has_P_top : P_top ∈ world

/-- Default forward step targeting neg(bot) (F_top = F(neg bot)). -/
noncomputable def witness_forward_default_step (phi : Formula)
    (e : WitnessChainElement phi) : WitnessChainElement phi where
  world := build_targeted_successor phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_F_top neg_bot_mem_deferralClosure
  is_drm := build_targeted_successor_is_drm phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_F_top neg_bot_mem_deferralClosure
  has_F_top := build_targeted_successor_has_F_top phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_F_top neg_bot_mem_deferralClosure
  has_P_top := build_targeted_successor_has_P_top phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_F_top neg_bot_mem_deferralClosure

/-- Default backward step targeting neg(bot) (P_top = P(neg bot)). -/
noncomputable def witness_backward_default_step (phi : Formula)
    (e : WitnessChainElement phi) : WitnessChainElement phi where
  world := build_targeted_predecessor phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_P_top neg_bot_mem_deferralClosure
  is_drm := build_targeted_predecessor_is_drm phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_P_top neg_bot_mem_deferralClosure
  has_F_top := build_targeted_predecessor_has_F_top phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_P_top neg_bot_mem_deferralClosure
  has_P_top := build_targeted_predecessor_has_P_top phi e.world e.is_drm
    (Formula.neg Formula.bot) e.has_P_top neg_bot_mem_deferralClosure

noncomputable def witnessForwardChainAt (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) : Nat → WitnessChainElement phi
  | 0 => ⟨M0.world, M0.is_drm, M0.has_F_top, M0.has_P_top⟩
  | n + 1 => witness_forward_default_step phi (witnessForwardChainAt phi M0 n)

noncomputable def witness_forward_chain (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) : Set Formula :=
  (witnessForwardChainAt phi M0 n).world

@[simp]
theorem witness_forward_chain_zero (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) :
    witness_forward_chain phi M0 0 = M0.world := rfl

theorem witness_forward_chain_is_drm (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    DeferralRestrictedMCS phi (witness_forward_chain phi M0 n) :=
  (witnessForwardChainAt phi M0 n).is_drm

theorem witness_forward_chain_has_F_top (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    F_top ∈ witness_forward_chain phi M0 n :=
  (witnessForwardChainAt phi M0 n).has_F_top

theorem witness_forward_chain_g_persistence (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    g_content (witness_forward_chain phi M0 n) ⊆
    witness_forward_chain phi M0 (n + 1) :=
  build_targeted_successor_g_persistence phi
    (witnessForwardChainAt phi M0 n).world
    (witnessForwardChainAt phi M0 n).is_drm
    (Formula.neg Formula.bot)
    (witnessForwardChainAt phi M0 n).has_F_top
    neg_bot_mem_deferralClosure

/-! ## Backward Chain -/

noncomputable def witnessBackwardChainAt (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) : Nat → WitnessChainElement phi
  | 0 => ⟨M0.world, M0.is_drm, M0.has_F_top, M0.has_P_top⟩
  | n + 1 => witness_backward_default_step phi (witnessBackwardChainAt phi M0 n)

noncomputable def witness_backward_chain (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) : Set Formula :=
  (witnessBackwardChainAt phi M0 n).world

@[simp]
theorem witness_backward_chain_zero (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) :
    witness_backward_chain phi M0 0 = M0.world := rfl

theorem witness_backward_chain_is_drm (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    DeferralRestrictedMCS phi (witness_backward_chain phi M0 n) :=
  (witnessBackwardChainAt phi M0 n).is_drm

theorem witness_backward_chain_h_persistence (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    h_content (witness_backward_chain phi M0 n) ⊆
    witness_backward_chain phi M0 (n + 1) :=
  build_targeted_predecessor_h_persistence phi
    (witnessBackwardChainAt phi M0 n).world
    (witnessBackwardChainAt phi M0 n).is_drm
    (Formula.neg Formula.bot)
    (witnessBackwardChainAt phi M0 n).has_P_top
    neg_bot_mem_deferralClosure

/-! ## Combined Int-indexed Chain -/

noncomputable def witness_succ_chain_fam (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => witness_forward_chain phi M0 k
  | Int.negSucc k => witness_backward_chain phi M0 (k + 1)

@[simp]
theorem witness_succ_chain_fam_zero (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) :
    witness_succ_chain_fam phi M0 0 = M0.world := rfl

theorem witness_succ_chain_fam_is_drm (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Int) :
    DeferralRestrictedMCS phi (witness_succ_chain_fam phi M0 n) := by
  match n with
  | Int.ofNat k => exact witness_forward_chain_is_drm phi M0 k
  | Int.negSucc k => exact witness_backward_chain_is_drm phi M0 (k + 1)

/-! ## One-Step F/P Resolution

These theorems show that for ANY F(psi) at position n, we CAN build a
successor at n+1 that resolves it. This is not the same as forward_F for
a FIXED chain, but provides the mathematical basis for completeness.
-/

/--
One-step F resolution: given DRM u with F(psi) in u and psi in deferralClosure,
the targeted successor contains psi. This is sorry-free.
-/
theorem one_step_F_resolution (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (psi : Formula) (h_F : Formula.some_future psi ∈ u)
    (h_dc : psi ∈ (deferralClosure phi : Set Formula)) :
    psi ∈ build_targeted_successor phi u h_drm psi h_F h_dc :=
  build_targeted_successor_has_target phi u h_drm psi h_F h_dc

/--
One-step P resolution: symmetric to F resolution.
-/
theorem one_step_P_resolution (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (psi : Formula) (h_P : Formula.some_past psi ∈ u)
    (h_dc : psi ∈ (deferralClosure phi : Set Formula)) :
    psi ∈ build_targeted_predecessor phi u h_drm psi h_P h_dc :=
  build_targeted_predecessor_has_target phi u h_drm psi h_P h_dc

end Bimodal.Metalogic.Bundle.MCSWitnessChain
