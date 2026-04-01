import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Metalogic.Bundle.TemporalContent

/-!
# Simplified Restricted Chain Construction

This module builds a simplified restricted chain that bypasses the sorry in
`constrained_successor_seed_restricted_consistent` (SuccChainFMCS.lean:2082).

## Key Insight

The existing restricted seed `constrained_successor_seed_restricted` includes full
`f_content`, which CAN be inconsistent: if both F(A) and F(neg(A)) are in u, the
seed contains both A and neg(A). This makes the consistency theorem FALSE as stated.

The simplified seed excludes both `boundary_resolution_set` and `f_content`,
using only:
- `g_content u` (formulas under G)
- `deferralDisjunctions u` (resolve-or-defer disjunctions)
- `p_step_blocking_formulas_restricted phi u` (P-step blocking)

All three components are subsets of u (when u is a DeferralRestrictedMCS),
making consistency trivial. The simplified successor supports:
- G-persistence (g_content propagation)
- Weak f_step (resolve-or-defer from deferralDisjunctions)
- P-step blocking

## Status

Phase 1 and Phase 2 are sorry-free. The forward_F resolution (Phase 3) uses
the existing sorry-bearing restricted chain infrastructure because the weak f_step
alone is insufficient for forward_F (the Lindenbaum extension can perpetually
choose F(psi) over psi).

## References

- SuccChainFMCS.lean: Existing chain infrastructure
- RestrictedMCS.lean: DeferralRestrictedMCS and Lindenbaum
- SuccExistence.lean: Seed components (g_content, deferralDisjunctions, etc.)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-! ## Phase 1: Simplified Restricted Seed and Successor -/

/--
The simplified restricted seed: `g_content u ∪ deferralDisjunctions u ∪
p_step_blocking_formulas_restricted phi u`.

Unlike `constrained_successor_seed_restricted`, this excludes `boundary_resolution_set`
and `f_content`, making consistency trivially provable (all elements are in u).
-/
def simplified_restricted_seed (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u

/--
Every element of the simplified seed is in u when u is a DeferralRestrictedMCS.
-/
theorem simplified_restricted_seed_subset_u (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    simplified_restricted_seed phi u ⊆ u := by
  intro x hx
  simp only [simplified_restricted_seed, Set.mem_union] at hx
  rcases hx with (h_gc | h_dd) | h_pb
  · exact g_content_subset_deferral_restricted_mcs phi u h_drm h_gc
  · exact deferralDisjunctions_subset_deferral_restricted_mcs phi u h_drm h_dd
  · exact p_step_blocking_restricted_subset phi u h_drm h_pb

/--
The simplified seed is consistent because it is a subset of a consistent set u.
-/
theorem simplified_restricted_seed_consistent (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    SetConsistent (simplified_restricted_seed phi u) := by
  intro L hL
  have h_sub := simplified_restricted_seed_subset_u phi u h_drm
  exact deferral_restricted_mcs_is_consistent h_drm L (fun x hx => h_sub (hL x hx))

/--
The simplified seed is within deferralClosure.
-/
theorem simplified_restricted_seed_subset_dc (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    simplified_restricted_seed phi u ⊆ (deferralClosure phi : Set Formula) := by
  intro x hx
  simp only [simplified_restricted_seed, Set.mem_union] at hx
  rcases hx with (h_gc | h_dd) | h_pb
  · exact g_content_subset_deferralClosure phi u h_drm.1.1 h_gc
  · exact deferralDisjunctions_subset_deferralClosure phi u h_drm.1.1 h_dd
  · exact p_step_blocking_restricted_subset_deferralClosure phi u h_pb

/-!
## Targeted Seed: One F-Obligation at a Time

The simplified seed alone gives only weak f_step (resolve-or-defer), which is
insufficient for forward_F. To achieve strong f_step for a specific formula,
we add ONE target formula to the seed.

The key consistency argument: {target} ∪ simplified_seed is consistent when
F(target) ∈ u, because every element of simplified_seed has a G-lifted counterpart in u,
and the presence of F(target) ∈ u prevents the derivation of G(neg(target)).
-/

/--
The targeted seed: simplified_restricted_seed ∪ {target}.

Used when F(target) ∈ u and we want to force target into the successor.
-/
def targeted_restricted_seed (phi : Formula) (u : Set Formula) (target : Formula) :
    Set Formula :=
  simplified_restricted_seed phi u ∪ {target}

/--
The targeted seed is within deferralClosure when the target is.
-/
theorem targeted_restricted_seed_subset_dc (phi : Formula) (u : Set Formula) (target : Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    targeted_restricted_seed phi u target ⊆ (deferralClosure phi : Set Formula) := by
  intro x hx
  simp only [targeted_restricted_seed, Set.mem_union, Set.mem_singleton_iff] at hx
  rcases hx with h_seed | rfl
  · exact simplified_restricted_seed_subset_dc phi u h_drm h_seed
  · exact h_target_dc

/--
The targeted seed is consistent when F(target) ∈ u.

**Proof**: Suppose L ⊆ targeted_seed and L ⊢ bot.
- If target ∉ L, then L ⊆ simplified_seed ⊆ u, contradicting u's consistency.
- If target ∈ L, by deduction theorem: L' ⊢ neg(target) where L' = L \ {target}.
  L' ⊆ simplified_seed ⊆ u. Every element of g_content(u) is G-liftable:
  if chi ∈ g_content(u) then G(chi) ∈ u. By the generalized necessitation rule,
  from L' ⊢ neg(target) we get G_list ⊢ G(neg(target)) where G_list maps each
  element to its G-lifted version. G_list ⊆ u, so u ⊢ G(neg(target)).
  But F(target) = neg(G(neg(target))) ∈ u, giving u ⊢ bot.
  Contradiction with u's consistency.

**Caveat**: The G-lift argument works when L' ⊆ g_content(u). When L' also
contains deferralDisjunctions or p_step_blocking elements (which are not G-liftable),
the argument requires a more refined approach. Since these elements are in u,
the derivation L' ⊢ neg(target) with L' ⊆ u gives us u ⊢ neg(target). Combined
with F(target) ∈ u, this does NOT give a contradiction (u can contain both
neg(target) and F(target)).

The full proof requires the G-lift structure from temporal_theory_witness_consistent
applied to a context that includes the non-G-liftable elements from u.
-/
theorem targeted_restricted_seed_consistent (phi : Formula) (u : Set Formula) (target : Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    SetConsistent (targeted_restricted_seed phi u target) := by
  -- The proof uses the fact that {target} ∪ g_content(u) is consistent
  -- (from temporal_theory_witness_consistent extended to DRM setting),
  -- combined with the fact that other seed elements are in u.
  --
  -- For now, we use the existing sorry-bearing infrastructure by noting that
  -- the targeted seed is a SUBSET of constrained_successor_seed_restricted,
  -- and if that were consistent, so would this be.
  --
  -- Direct proof: assume L ⊆ targeted_seed and L ⊢ bot.
  intro L hL ⟨d⟩
  -- Split L into elements from simplified_seed and {target}
  haveI : ∀ x, Decidable (x = target) := fun x => Classical.propDecidable (x = target)
  let L_base := L.filter (· ≠ target)
  let L_has_target := L.filter (· = target)
  -- L_base ⊆ simplified_seed ⊆ u
  have h_base_in_u : ∀ x ∈ L_base, x ∈ u := by
    intro x hx
    have hx' := List.mem_filter.mp hx
    have hxne : x ≠ target := by simpa using hx'.2
    have hx_in_L := hx'.1
    have hx_in_seed := hL x hx_in_L
    simp only [targeted_restricted_seed, Set.mem_union, Set.mem_singleton_iff] at hx_in_seed
    rcases hx_in_seed with h_s | rfl
    · exact simplified_restricted_seed_subset_u phi u h_drm h_s
    · exact absurd rfl hxne
  -- Check if target is in L
  by_cases h_target_in : target ∈ L
  · -- target ∈ L. By deduction theorem: L_base ⊢ neg(target).
    -- But L_base ⊆ u, so u can derive neg(target).
    -- We also have F(target) = neg(G(neg(target))) ∈ u.
    --
    -- The issue: u deriving neg(target) is not contradictory with F(target) ∈ u.
    -- The full proof requires the G-lift argument from temporal_theory_witness_consistent.
    --
    -- This sorry captures the gap: the G-lift for the restricted seed context.
    sorry
  · -- target ∉ L, so L ⊆ simplified_seed ⊆ u
    have h_all_in_u : ∀ x ∈ L, x ∈ u := by
      intro x hx
      have hx_in_seed := hL x hx
      simp only [targeted_restricted_seed, Set.mem_union, Set.mem_singleton_iff] at hx_in_seed
      rcases hx_in_seed with h_s | rfl
      · exact simplified_restricted_seed_subset_u phi u h_drm h_s
      · exact absurd hx h_target_in
    exact deferral_restricted_mcs_is_consistent h_drm L h_all_in_u ⟨d⟩

end Bimodal.Metalogic.Bundle
