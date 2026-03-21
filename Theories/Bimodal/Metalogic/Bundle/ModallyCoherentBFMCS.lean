import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.ClosedFlagBundle
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.SaturatedBFMCSConstruction
import Bimodal.Metalogic.Bundle.BFMCS

/-!
# Modally Coherent BFMCS Construction (Task 15 Phase 2)

This module constructs the infrastructure for a modally saturated BFMCS over
CanonicalMCS domain with sorry-free `modal_backward` using the multi-family
saturation approach.

## Background: Why Singleton BFMCS Fails

The singleton BFMCS approach (SuccChainBFMCS.lean) has an **unprovable** `modal_backward`
sorry. For a singleton bundle, `modal_backward` requires `φ ∈ MCS → □φ ∈ MCS`, which is
the converse of the T-axiom and mathematically impossible for contingent formulas.

## Solution: Multi-Family Modally Saturated BFMCS

A BFMCS is **modally saturated** when for every `◇ψ` in any family's MCS at time `t`,
there exists a *different* family in the bundle whose MCS at `t` contains `ψ` as a witness.

With modal saturation, `modal_backward` is provable by contraposition via
`saturated_modal_backward` from `ModalSaturation.lean`.

## Phase 2 Deliverables

This phase establishes the theoretical infrastructure:

1. **MCS-level saturation**: Proven via `closedFlags_union_modally_saturated`
2. **Conditional modal_backward**: `saturated_modal_backward` requires saturation proof
3. **Modal forward**: T-axiom gives modal_forward for identity-mcs families
4. **Temporal coherence**: All F/P/G/H conditions proven in `canonicalMCSBFMCS`

## Key Insight: The Domain Problem

The BFMCS modal_backward condition quantifies over families AT THE SAME TIME t:
  ∀ fam ∈ families, ∀ φ t, (∀ fam' ∈ families, φ ∈ fam'.mcs t) → □φ ∈ fam.mcs t

For this to work without the impossible φ → □φ axiom, we need families with
DIFFERENT values of `mcs t` for the same t. This means families must have
different `mcs` functions that produce different MCS for the same input.

With D = CanonicalMCS and `mcs t = t.world` (identity), all families produce
the same MCS at each time, collapsing saturation.

The solution requires either:
1. Flag-based chains where different Flags give different chains (Phase 3)
2. Generalized parametric framework accepting `D = CanonicalMCS` (alternative)
3. Domain transfer from CanonicalMCS to Int (Phase 4)

## References

- Task 15 plan v2: specs/015_discrete_representation_theorem_axiom_removal/plans/02_multi-bfmcs-plan.md
- ModalSaturation.lean: saturated_modal_backward (sorry-free)
- ClosedFlagBundle.lean: closedFlags_union_modally_saturated (sorry-free)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Saturation Infrastructure

Re-export and document the key saturation theorems from the existing infrastructure.
-/

/--
Modal forward for any FMCS over CanonicalMCS with identity mcs: T-axiom applies.

If □φ in fam.mcs t = t.world, then φ in t.world by T-axiom.
-/
theorem identity_mcs_modal_forward (fam : FMCS CanonicalMCS)
    (h_identity : ∀ t : CanonicalMCS, fam.mcs t = t.world)
    (φ : Formula) (t : CanonicalMCS) (h_box : Formula.box φ ∈ fam.mcs t) :
    φ ∈ fam.mcs t := by
  rw [h_identity] at h_box ⊢
  exact box_implies_phi_in_mcs t.world t.is_mcs φ h_box

/--
The `canonicalMCSBFMCS` family uses identity mcs.
-/
theorem canonicalMCSBFMCS_identity_mcs (t : CanonicalMCS) :
    canonicalMCSBFMCS.mcs t = t.world := rfl

/--
Modal forward for canonicalMCSBFMCS specifically.
-/
theorem canonicalMCSBFMCS_modal_forward' (φ : Formula) (t : CanonicalMCS)
    (h_box : Formula.box φ ∈ canonicalMCSBFMCS.mcs t) :
    φ ∈ canonicalMCSBFMCS.mcs t :=
  identity_mcs_modal_forward canonicalMCSBFMCS canonicalMCSBFMCS_identity_mcs φ t h_box

/-!
## Key Saturation Theorems (Re-exported)

These theorems are already proven sorry-free in the respective modules.
We document their signatures and usage here for Phase 3/4 implementation.
-/

-- Saturation implies modal_backward (from ModalSaturation.lean)
#check @saturated_modal_backward

-- closedFlags provides modal saturation at MCS level (from SaturatedBFMCSConstruction.lean)
#check @closedFlags_union_modally_saturated

-- Predicate for modal saturation (from ModalSaturation.lean)
#check @is_modally_saturated

-- Temporal coherence theorems (from CanonicalFMCS.lean)
#check @canonicalMCS_forward_F
#check @canonicalMCS_backward_P
#check @canonicalMCS_forward_G
#check @canonicalMCS_backward_H

/--
Summary theorem: Given a modally saturated BFMCS B over CanonicalMCS, modal_backward holds.

This is a re-export of `saturated_modal_backward` with explicit documentation
for the Phase 3/4 implementation.
-/
theorem modal_backward_from_saturation (B : BFMCS CanonicalMCS)
    (h_sat : is_modally_saturated B)
    (fam : FMCS CanonicalMCS) (hfam : fam ∈ B.families)
    (φ : Formula) (t : CanonicalMCS)
    (h_all : ∀ fam' ∈ B.families, φ ∈ fam'.mcs t) :
    Formula.box φ ∈ fam.mcs t :=
  saturated_modal_backward B h_sat fam hfam φ t h_all

/-!
## Direct MCS-Level Modal Coherence

The key insight from TimelineQuotBFMCS is that modal_backward can be proven
DIRECTLY at the MCS level using saturation, without constructing a BFMCS
with different `mcs` functions.

The proof is by contraposition:
1. Assume □φ not in M.world
2. Then ¬□φ = ◇(¬φ) is in M.world (by MCS negation completeness)
3. By saturation, exists W with ¬φ in W.world
4. But φ is in ALL W by hypothesis, contradiction

This approach works because:
- Saturation is at the MCS level (closedFlags_union_modally_saturated)
- The hypothesis quantifies over all MCS in the closed set
- No explicit BFMCS family structure is needed for this proof

The following theorems establish this pattern for the discrete case.
-/

variable (M0 : CanonicalMCS)

/--
The closed Flags for a root MCS M0.

This is `closedFlags M0` from ClosedFlagBundle.lean - the set of Flags closed
under modal witnesses.
-/
abbrev discreteClosedFlags := closedFlags M0

/--
The set of all MCS in the closed Flags.
-/
def discreteClosedMCS : Set CanonicalMCS :=
  { M | ∃ flag ∈ closedFlags M0, M ∈ flag }

/--
The closed MCS set is modally saturated.

For any ◇ψ in any MCS M in the closed set, there exists a witness W
in the closed set with ψ in W.world.
-/
theorem discreteClosedMCS_modally_saturated :
    MCSSetModallySaturated (discreteClosedMCS M0) :=
  closedFlags_union_modally_saturated M0

/--
The root MCS is in the closed set.
-/
theorem root_in_discreteClosedMCS :
    M0 ∈ discreteClosedMCS M0 := by
  obtain ⟨flag, h_flag, h_mem⟩ := root_in_closedFlags M0
  exact ⟨flag, h_flag, h_mem⟩

/--
Modal forward at MCS level: □φ in M.world implies φ in M.world.

Uses T-axiom.
-/
theorem discreteMCS_modal_forward (M : CanonicalMCS) (φ : Formula)
    (h_box : Formula.box φ ∈ M.world) :
    φ ∈ M.world :=
  box_implies_phi_in_mcs M.world M.is_mcs φ h_box

/--
Modal backward at MCS level for closed MCS set.

If φ is in every MCS in the closed set, then □φ is in every MCS in the closed set.

**Proof**: By contraposition using saturation.
1. Assume □φ not in M.world for some M in closed set
2. Then ¬□φ in M.world (MCS negation completeness)
3. ¬□φ is equivalent to ◇(¬φ) via box-diamond duality
4. By modal saturation, exists W in closed set with ¬φ in W.world
5. But φ is in ALL W in closed set, contradiction
-/
theorem discreteMCS_modal_backward
    (M : CanonicalMCS)
    (h_M : M ∈ discreteClosedMCS M0)
    (φ : Formula)
    (h_all : ∀ W ∈ discreteClosedMCS M0, φ ∈ W.world) :
    Formula.box φ ∈ M.world := by
  by_contra h_not_box
  have h_mcs := M.is_mcs
  -- neg(Box phi) is in M.world by negation completeness
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h_box | h_neg_box
  · exact h_not_box h_box
  · -- neg(Box phi) = Diamond(neg phi) in M.world (after DNE reasoning)
    -- Diamond(psi) = neg(Box(neg psi))
    -- neg(Box phi) = neg(Box(neg(neg phi))) = Diamond(neg phi) (via DNE modal equivalence)
    --
    -- We have neg(Box phi) in M.world
    -- We need to derive Diamond(neg phi) in M.world
    --
    -- Box phi and Box(neg(neg phi)) are equivalent (DNE)
    -- So neg(Box phi) and neg(Box(neg(neg phi))) = Diamond(neg phi) are equivalent
    have h_dne_box : [] ⊢ (Formula.box (Formula.neg (Formula.neg φ))).imp (Formula.box φ) := by
      have h_dne : [] ⊢ (Formula.neg (Formula.neg φ)).imp φ := dne_theorem φ
      have h_nec : [] ⊢ Formula.box ((Formula.neg (Formula.neg φ)).imp φ) :=
        DerivationTree.necessitation _ h_dne
      have h_K : [] ⊢ (Formula.box ((Formula.neg (Formula.neg φ)).imp φ)).imp
                     ((Formula.box (Formula.neg (Formula.neg φ))).imp (Formula.box φ)) :=
        DerivationTree.axiom [] _ (Axiom.modal_k_dist _ _)
      exact DerivationTree.modus_ponens [] _ _ h_K h_nec
    -- Contrapositive: neg(Box phi) implies neg(Box(neg(neg phi)))
    have h_contra : (Formula.box φ).neg ∈ M.world →
        (Formula.box (Formula.neg (Formula.neg φ))).neg ∈ M.world := by
      intro h
      exact SetMaximalConsistent.contrapositive h_mcs h_dne_box h
    have h_diamond : (Formula.neg φ).diamond ∈ M.world := by
      -- Diamond(neg phi) = neg(Box(neg(neg phi))) by definition
      -- We have neg(Box phi) in M.world
      -- By h_contra, neg(Box(neg(neg phi))) in M.world
      exact h_contra h_neg_box
    -- By saturation, exists W with neg phi in W.world
    have h_sat := discreteClosedMCS_modally_saturated M0 M h_M (Formula.neg φ) h_diamond
    obtain ⟨W, h_W_in, h_neg_phi⟩ := h_sat
    -- But phi is in ALL W in closed set
    have h_phi := h_all W h_W_in
    -- Contradiction: phi and neg phi in W.world
    exact set_consistent_not_both W.is_mcs.1 φ h_phi h_neg_phi

/-!
## Summary: Sorry-Free Modal Coherence Infrastructure

We have established:

1. `discreteClosedMCS M0`: The set of all MCS in closedFlags M0
2. `discreteClosedMCS_modally_saturated`: Modal saturation at MCS level
3. `discreteMCS_modal_forward`: □φ → φ via T-axiom
4. `discreteMCS_modal_backward`: φ-in-all → □φ via saturation

These theorems are ALL sorry-free and provide the foundation for:
- Phase 4: Wiring to DiscreteInstantiation
- Domain transfer from CanonicalMCS to Int

The key insight is that modal coherence can be established directly at the
MCS level without constructing explicit BFMCS families with different `mcs`
functions. The saturation property at the MCS level is sufficient.
-/

end Bimodal.Metalogic.Bundle
