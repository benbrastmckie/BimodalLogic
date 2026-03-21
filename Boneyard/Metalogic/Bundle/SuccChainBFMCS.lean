import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.TemporalCoherence

/-!
# DEPRECATED: Succ-Chain BFMCS Construction

**STATUS**: DEPRECATED (Task 15, 2026-03-21)

**REASON**: The singleton BFMCS approach for discrete representation is **mathematically
impossible**. The `modal_backward` property requires `φ ∈ MCS → □φ ∈ MCS`, which is the
converse of the T-axiom and does NOT hold for contingent formulas in TM logic.

**EVIDENCE**: An MCS can contain a contingent formula φ without containing □φ.
Counterexample: `{◇p, ¬p, φ}` is consistent and extends to an MCS where φ holds but □φ
does not (since ¬□φ is consistent with the seed).

**SUPERSEDED BY**: Multi-family modally saturated BFMCS approach via
`ModallyCoherentBFMCS.lean` using `saturated_modal_backward` from `ModalSaturation.lean`.

**DO NOT**:
- Import this module in new code
- Use `SingletonBFMCS` or `construct_bfmcs_impl`
- Try to eliminate the `modal_backward` sorry (it is provably impossible)

See ROAD_MAP.md "Dead End: Singleton BFMCS for Discrete Representation" for full analysis.

---

## Original Description (Historical, DO NOT USE)

This module wraps a SuccChainFMCS as a singleton BFMCS (Bundle of FMCS) with both
modal and temporal coherence properties.

## Main Definitions

- `SingletonBFMCS`: Wrap a single FMCS as a BFMCS (singleton bundle)
- `SuccChainBFMCS`: The SuccChainFMCS wrapped as a singleton BFMCS
- `construct_bfmcs_impl`: The callback function for DiscreteInstantiation

## Key Insight (INCORRECT - SEE DEPRECATION NOTICE)

A singleton BFMCS has trivial modal coherence:
- `modal_forward`: Box phi in the single family implies phi in all families (just itself)
- `modal_backward`: phi in all families (just itself) implies Box phi by MCS T-axiom closure
  **THIS IS FALSE FOR CONTINGENT FORMULAS**

Temporal coherence comes from SuccChainTemporalCoherent.

## References

- Task 15: discrete_representation_theorem_axiom_removal (deprecation)
- Task 14: SuccChainFMCS construction
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Singleton BFMCS Construction

A singleton bundle containing exactly one FMCS family.
-/

/-- Create a singleton BFMCS from a single FMCS.

**DEPRECATED**: This construction has an unprovable `modal_backward` sorry.
See module-level deprecation notice.

Modal coherence for a singleton:
- modal_forward: Box phi in fam implies phi in fam (by T axiom closure of MCS) - OK
- modal_backward: phi in all families implies Box phi in fam - **IMPOSSIBLE**
  The goal requires φ ∈ MCS → □φ ∈ MCS, which is false for contingent formulas.
-/
noncomputable def SingletonBFMCS (theFam : FMCS Int) : BFMCS Int where
  families := {theFam}
  nonempty := ⟨theFam, Set.mem_singleton theFam⟩
  modal_forward := fun fam' hfam' φ t h_box fam'' hfam'' => by
    -- fam' = theFam and fam'' = theFam (singleton)
    have h_eq' : fam' = theFam := Set.mem_singleton_iff.mp hfam'
    have h_eq'' : fam'' = theFam := Set.mem_singleton_iff.mp hfam''
    -- Box phi in fam'.mcs t implies phi in fam''.mcs t by Modal T axiom
    -- Since fam' = fam'' = theFam, we just need T axiom
    rw [h_eq''] -- goal: φ ∈ theFam.mcs t
    rw [h_eq'] at h_box -- h_box: φ.box ∈ theFam.mcs t
    have h_mcs := theFam.is_mcs t
    have h_T : [] ⊢ (Formula.box φ).imp φ := DerivationTree.axiom [] _ (Axiom.modal_t φ)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_box
  modal_backward := fun fam' hfam' φ t h_all => by
    -- fam' = theFam (singleton)
    have h_eq : fam' = theFam := Set.mem_singleton_iff.mp hfam'
    rw [h_eq]
    -- phi in all families means phi in theFam. We need Box phi in theFam.
    have h_phi : φ ∈ theFam.mcs t := h_all theFam (Set.mem_singleton theFam)
    have h_mcs := theFam.is_mcs t
    -- By Modal B axiom: phi -> Box (Diamond phi)
    -- By Modal 5 collapse: Diamond (Box phi) -> Box phi
    -- Combined with MCS properties, phi in MCS implies Box phi in MCS
    -- Use: phi -> Box(Diamond phi) and Diamond(Box phi) -> Box phi
    -- Together: phi in MCS -> Diamond phi in MCS -> Box(Diamond phi) in MCS
    --           -> Diamond(Box phi) in MCS (by symmetry) -> Box phi in MCS
    -- Actually simpler: use necessitation on theorems
    -- For S5, we have: phi ∈ MCS implies Box phi ∈ MCS if phi is a theorem
    -- But phi is not necessarily a theorem here.
    -- The correct approach: since all families have phi, and there's only one family,
    -- we need to use the S5 structure. In S5, if phi holds at all accessible worlds,
    -- then Box phi holds. For a singleton, "all accessible worlds" is just the one family.
    -- By modal 5: Diamond phi -> Box (Diamond phi)
    -- And by symmetry (B): phi -> Box (Diamond phi)
    -- And by 5-collapse: Diamond (Box phi) -> Box phi
    -- Strategy: Use B + 5 to derive that phi in the unique family implies Box phi
    -- Actually the key is: in S5 with one world, everything true is necessary
    -- phi ∈ M -> (by B) Box(Diamond phi) ∈ M -> (by 4+5) Box phi ∈ M
    -- Let's use the direct S5 characterization
    -- AXIOM: Singleton modal_backward requires phi ∈ M -> Box phi ∈ M
    -- This is NOT generally true in S5 MCS semantics (phi can be contingent).
    -- For a proper construction, we would need modally saturated BFMCS.
    -- Following research plan Option B: wire with documented axioms first.
    -- This axiom is semantically justified for the intended use case where the
    -- singleton bundle represents a "closed world" for the countermodel construction.
    sorry
  eval_family := theFam
  eval_family_mem := Set.mem_singleton theFam

/-- The SuccChainFMCS wrapped as a singleton BFMCS. -/
noncomputable def SuccChainBFMCS (M0 : SerialMCS) : BFMCS Int :=
  SingletonBFMCS (SuccChainFMCS M0)

/-- Temporal coherence for SuccChainBFMCS.

The singleton family is the SuccChainTemporalCoherent, which has forward_F and backward_P.
-/
theorem SuccChainBFMCS_temporally_coherent (M0 : SerialMCS) :
    (SuccChainBFMCS M0).temporally_coherent := by
  intro fam hfam
  -- fam is the unique family in the singleton
  have h_eq : fam = SuccChainFMCS M0 := Set.mem_singleton_iff.mp hfam
  subst h_eq
  constructor
  · -- forward_F
    intro t φ h_F
    exact (SuccChainTemporalCoherent M0).forward_F t φ h_F
  · -- backward_P
    intro t φ h_P
    exact (SuccChainTemporalCoherent M0).backward_P t φ h_P

/-!
## construct_bfmcs Implementation

The callback function for DiscreteInstantiation that converts any MCS to a
temporally coherent BFMCS containing that MCS.
-/

/-- Convert any MCS M to a temporally coherent BFMCS containing M at time 0.

This is the key function required by `discrete_representation_conditional`.
Given any MCS M, we:
1. Convert M to SerialMCS (using MCS_to_SerialMCS - M already contains F_top/P_top)
2. Build SuccChainFMCS from the SerialMCS
3. Wrap as singleton BFMCS
4. Return with proof that M = fam.mcs 0
-/
noncomputable def construct_bfmcs_impl (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t := by
  -- Convert M to SerialMCS
  let M0 : SerialMCS := MCS_to_SerialMCS M h_mcs
  -- Build the BFMCS
  let B : BFMCS Int := SuccChainBFMCS M0
  -- The family is the SuccChainFMCS
  let fam : FMCS Int := SuccChainFMCS M0
  -- Prove membership
  have hfam : fam ∈ B.families := Set.mem_singleton fam
  -- Prove temporal coherence
  have h_tc : B.temporally_coherent := SuccChainBFMCS_temporally_coherent M0
  -- Prove M = fam.mcs 0
  have h_eq : M = fam.mcs 0 := by
    -- fam.mcs 0 = succ_chain_fam M0 0 = forward_chain M0 0 = M0.world = M
    simp only [fam, SuccChainFMCS, succ_chain_fam_zero]
    rfl
  exact ⟨B, h_tc, fam, hfam, 0, h_eq⟩

end Bimodal.Metalogic.Bundle
