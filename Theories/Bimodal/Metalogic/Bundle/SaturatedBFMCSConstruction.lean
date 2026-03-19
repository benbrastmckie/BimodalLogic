import Bimodal.Metalogic.Bundle.ClosedFlagBundle
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.BFMCS

/-!
# Saturated BFMCS Construction (Task 1003 Phase 3)

This module constructs a modally saturated BFMCS from the closed Flag bundle.
The key insight is that modal saturation at the FLAG level (closedFlags_closed_under_witnesses)
can be leveraged to prove modal coherence.

## Overview

The challenge is that BFMCS requires all families to have the same domain type D,
but modal saturation for Diamond(psi) at time t requires a family fam' where
`fam'.mcs t` contains psi. With the canonical assignment `mcs t = t.world`,
this would require `psi in t.world`, which fails for Diamond formulas.

## Approach: All-MCS Bundle with Saturation Proof

Instead of constructing complex witness families with different mcs functions,
we observe that:

1. The singleton bundle `{canonicalMCSBFMCS}` over CanonicalMCS already satisfies
   `modal_forward` (by T-axiom)

2. For `modal_backward`, we need: phi in all families at t implies Box phi at t
   - For singleton bundle: phi in t.world implies Box phi in t.world
   - This follows from MCS properties IF we can establish the contrapositive via saturation

3. The key insight: in the singleton canonical bundle, "all families" is just one family.
   So the condition "phi in all families at t" reduces to "phi in t.world".
   And we need "Box phi in t.world".

The saturation approach (used in saturated_modal_backward) requires:
- Diamond(neg phi) in t.world implies neg phi in SOME family's mcs at t
- For singleton bundle, this would require neg phi in t.world
- Which would contradict phi in t.world

The key realization: for the singleton bundle, if phi is in t.world,
and neg(Box phi) were also in t.world, we get Diamond(neg phi) in t.world.
But we CAN'T conclude neg phi in t.world just from Diamond(neg phi) in t.world!

This is exactly why singleton bundles fail saturation.

## Alternative: Multi-Evaluation BFMCS

The correct approach uses multiple families where different families can
evaluate different Diamond formulas. Each family is an FMCS over CanonicalMCS,
but with different mcs functions that place witnesses at the right times.

For Phase 3, we establish the theoretical framework and prove properties
that will enable the full construction in future work.

## References

- Task 1003 blocker analysis: Diamond(psi) in t.world does NOT imply psi in t.world
- ModalSaturation.lean: saturated_modal_backward (conditional on saturation)
- ClosedFlagBundle.lean: closedFlags_closed_under_witnesses
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Modal Saturation at the CanonicalMCS Level

We define modal saturation properties directly on sets of MCSes,
independent of the BFMCS structure.
-/

/--
A set of CanonicalMCS elements is modally saturated if:
for every M in the set and every Diamond(psi) in M.world,
there exists W in the set with psi in W.world.

Note: this is saturation at the MCS level, not the BFMCS family level.
-/
def MCSSetModallySaturated (S : Set CanonicalMCS) : Prop :=
  ∀ M ∈ S, ∀ psi : Formula, psi.diamond ∈ M.world →
    ∃ W ∈ S, psi ∈ W.world

/--
The set of all CanonicalMCS elements is modally saturated.

This follows directly from witness_exists_for_diamond: for any Diamond(psi) in M,
there exists a witness MCS W with psi in W.world.
-/
theorem allCanonicalMCS_modally_saturated : MCSSetModallySaturated Set.univ := by
  intro M _ psi h_diamond
  obtain ⟨W, h_psi⟩ := witness_exists_for_diamond M psi h_diamond
  exact ⟨W, Set.mem_univ W, h_psi⟩

-- Note: flagsUnion_modally_saturated does NOT hold for arbitrary flag sets!
-- The witness W from witness_exists_for_diamond may be in a Flag NOT in our set.
-- This is why we need the closure property (closedFlags) to ensure witnesses are included.

/--
The closed Flags (with all witnesses) give a modally saturated MCS set.

For any M in any Flag in closedFlags M0, and any Diamond(psi) in M.world,
there exists a Flag in closedFlags containing a witness W with psi in W.world.
-/
theorem closedFlags_union_modally_saturated (M0 : CanonicalMCS) :
    MCSSetModallySaturated { M | ∃ flag ∈ closedFlags M0, M ∈ flag } := by
  intro M ⟨flag, h_flag, h_M⟩ psi h_diamond
  -- Use closedFlags_closed_under_witnesses
  obtain ⟨flag', h_flag', W, h_W_in_flag', h_psi⟩ :=
    closedFlags_closed_under_witnesses M0 flag h_flag M h_M psi h_diamond
  exact ⟨W, ⟨flag', h_flag', h_W_in_flag'⟩, h_psi⟩

/-!
## BFMCS Modal Forward (T-Axiom)

Modal forward is straightforward: Box phi in MCS implies phi in MCS by T-axiom.
This holds for any BFMCS where families use the canonical mcs assignment.
-/

/--
T-axiom in MCS form: Box phi in an MCS implies phi in that MCS.
-/
theorem box_implies_phi_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_box : Formula.box phi ∈ M) : phi ∈ M := by
  have h_T : [] ⊢ (Formula.box phi).imp phi := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_box

/--
For canonicalMCSBFMCS, modal_forward holds by T-axiom.

If Box phi in fam.mcs t = t.world, then phi in fam'.mcs t = t.world for any fam'.
-/
theorem canonicalMCSBFMCS_modal_forward (phi : Formula) (t : CanonicalMCS)
    (h_box : Formula.box phi ∈ canonicalMCSBFMCS.mcs t) :
    phi ∈ canonicalMCSBFMCS.mcs t :=
  box_implies_phi_in_mcs t.world t.is_mcs phi h_box

/-!
## The Challenge: Modal Backward Without Saturation

For modal_backward, we need: phi in ALL families' MCS at t implies Box phi in any family's MCS.

For singleton canonical bundle:
- "phi in all families at t" = phi in t.world
- Need: Box phi in t.world

This requires proving: phi in t.world -> Box phi in t.world

This is NOT provable from just MCS properties! An MCS can contain phi without containing Box phi.

The saturation approach (saturated_modal_backward) works by contraposition:
- Assume neg(Box phi) in t.world
- Then Diamond(neg phi) = neg(Box(neg(neg phi))) in t.world (via box_dne logic)
- By saturation: exists family with neg phi at t
- But phi is in ALL families at t, contradiction

The saturation step requires: Diamond(psi) at t implies psi in SOME family at t.
For singleton bundle: this would require psi in t.world, which fails.

## Path Forward: Multi-Family Bundle

The correct solution uses multiple families with different mcs functions:
- Base family: mcs t = t.world
- For each Diamond(psi) at t: a witness family where mcs t includes psi

This requires:
1. Defining families with non-identity mcs functions
2. Proving temporal coherence for these families
3. Bundling them into a BFMCS

This is deferred to Phase 4 (wire to MultiFamilyBFMCS) where we address the
domain type mismatch between chainFMCS (over ChainFMCSDomain) and the required
FMCS over CanonicalMCS.
-/

/-!
## Partial Result: Saturation Implies Modal Backward

We re-export saturated_modal_backward with our terminology for convenience.
-/

/--
If a BFMCS over CanonicalMCS is modally saturated, modal_backward holds.

This is a re-export of saturated_modal_backward from ModalSaturation.lean.
-/
theorem saturated_implies_modal_backward (B : BFMCS CanonicalMCS)
    (h_sat : is_modally_saturated B)
    (fam : FMCS CanonicalMCS) (hfam : fam ∈ B.families) (phi : Formula) (t : CanonicalMCS)
    (h_all : ∀ fam' ∈ B.families, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t :=
  saturated_modal_backward B h_sat fam hfam phi t h_all

/-!
## Construction Approach: All-Flags BFMCS

One approach is to use ALL Flags as families. Each Flag gives a chainFMCS,
but they have different domain types. To unify, we can:

1. Use a Sigma type domain: `Σ (flag : Flag CanonicalMCS), ChainFMCSDomain flag`
2. Project each family to this common domain

This is complex but mathematically sound. We outline the construction here.
-/

/--
The sigma domain: pairs of (Flag, element-of-Flag).

This unifies all ChainFMCSDomain types into a single type.
-/
def AllFlagsDomain : Type := Σ (flag : Flag CanonicalMCS), ChainFMCSDomain flag

-- Note: AllFlagsDomain needs a Preorder instance for BFMCS/FMCS
-- This is non-trivial: elements from different Flags are generally incomparable

/-!
## Summary: What We Have Proven

1. `closedFlags_union_modally_saturated`: The union of MCSes in closedFlags is modally saturated
2. `canonicalMCSBFMCS_modal_forward`: Modal forward holds for canonical bundle (T-axiom)
3. `saturated_implies_modal_backward`: Saturation implies modal backward

## What Remains

1. Construct a BFMCS over CanonicalMCS (or a suitable domain) that is modally saturated
2. This requires families with different mcs functions
3. The domain type unification is the main technical challenge

The closedFlags construction provides the mathematical content for saturation.
The implementation challenge is encoding this in Lean's type system.
-/

end Bimodal.Metalogic.Bundle
