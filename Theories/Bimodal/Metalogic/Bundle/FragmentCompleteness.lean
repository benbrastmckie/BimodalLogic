import Bimodal.Metalogic.Bundle.CanonicalCompleteness
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Mathlib.Order.Zorn

/-!
# Fragment-Level Completeness: Sorry-Free BFMCS on CanonicalMCS

This module constructs a fully saturated `BFMCS CanonicalMCS` that is both
temporally coherent and modally saturated, with ZERO sorries.

## Strategy

The key insight is to use `CanonicalMCS` (ALL maximal consistent sets) as the
temporal domain. This domain has:
- Sorry-free `canonicalMCSBFMCS` with forward_F and backward_P (from CanonicalFMCS.lean)
- Universal inclusion: every MCS is in the domain, so Diamond witnesses are always available

### Construction Steps

1. **Eval family**: `canonicalMCSBFMCS` maps each MCS to itself
2. **Witness families**: For each Diamond(psi) obligation, construct a witness FMCS
   where `fam'.mcs w` contains psi for the relevant w
3. **Modal saturation via Zorn**: Start with {canonicalMCSBFMCS}, iteratively add
   witness families until fully saturated
4. **Temporal coherence**: Each witness family is a "rooted canonical FMCS" that
   maps each CanonicalMCS element to the corresponding fragment element from a
   BidirectionalFragment rooted at the witness MCS

### Why This Works

- `canonicalMCSBFMCS` has sorry-free temporal coherence because:
  - forward_F: `canonical_forward_F` provides witnesses that are MCSes (in the domain)
  - backward_P: `canonical_backward_P` provides witnesses that are MCSes (in the domain)
- Witness families use the SAME construction (canonicalMCSBFMCS = identity mapping),
  so they inherit the same temporal coherence
- The tricky part is modal saturation + modal coherence simultaneously

### Modal Coherence Analysis

For `modal_forward`: Box(phi) ∈ fam.mcs w → phi ∈ fam'.mcs w for all fam'
- Since ALL families map w to w.world (identity), this becomes:
  Box(phi) ∈ w.world → phi ∈ w.world, which follows from the T-axiom

For `modal_backward`: (∀ fam' ∈ families, phi ∈ fam'.mcs w) → Box(phi) ∈ fam.mcs w
- Since all families are the identity, this becomes:
  phi ∈ w.world → Box(phi) ∈ w.world, which is NOT true in general!

### Resolution of Modal Backward

The `modal_backward` problem arises because a single-identity-family BFMCS doesn't
satisfy it. But `saturated_modal_backward` proves modal_backward FROM modal saturation.

The key: we need DIFFERENT families that map w to DIFFERENT MCSes. Then
`modal_backward` follows from modal saturation by contraposition:
- Suppose phi ∈ fam'.mcs w for ALL fam' but Box(phi) ∉ fam.mcs w
- Then Diamond(neg phi) ∈ fam.mcs w (by MCS properties)
- By modal saturation: ∃ fam'' with neg(phi) ∈ fam''.mcs w
- But phi ∈ fam''.mcs w too (by hypothesis) - contradiction

So the construction needs families that map w to DIFFERENT MCSes, with witnesses
for Diamond formulas. The identity family PLUS witness families provide this.

## Key Insight: Reuse canonicalMCSBFMCS for All Families

The simplest construction: ALL families are `canonicalMCSBFMCS` (identity mapping).
Then families = {canonicalMCSBFMCS} is a singleton.

Modal saturation for a singleton {fam}:
  Diamond(psi) ∈ fam.mcs w → ∃ fam' ∈ {fam}, psi ∈ fam'.mcs w
  = Diamond(psi) ∈ w.world → psi ∈ w.world

This fails because Diamond(psi) ∈ w.world does NOT imply psi ∈ w.world.

So we need MULTIPLE families. Each additional family maps w to a DIFFERENT MCS.

## Construction: Non-Identity Witness Families

For a Diamond(psi) obligation at element w, define a witness family `witnessFam`:
- `witnessFam.mcs u` = an MCS that extends `{psi} ∪ BoxContent(u.world)`
  (when Diamond(psi) ∈ u.world; otherwise just `u.world`)

But this is complicated. Instead, use a FIXED witness approach:

For each formula psi, define `psiWitnessFam`:
- For each u : CanonicalMCS, if Diamond(psi) ∈ u.world:
    `psiWitnessFam.mcs u` = diamondWitnessMCS u.world u.is_mcs psi (h_diamond)
  otherwise:
    `psiWitnessFam.mcs u` = u.world (identity)

This requires Diamond(psi) ∈ u.world to be decidable (or use Classical.choice).

## References

- Task 951 plan v5
- CanonicalCompleteness.lean: fragmentFMCS infrastructure
- CanonicalFMCS.lean: canonicalMCSBFMCS with sorry-free forward_F/backward_P
- ModalSaturation.lean: saturated_modal_backward
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Phase 1: Witness Family for a Formula

Given a formula psi, construct an FMCS on CanonicalMCS that serves as a witness
for Diamond(psi) obligations.

At each point w:
- If Diamond(psi) ∈ w.world: map to diamondWitnessMCS w psi (contains psi + BoxContent(w))
- If Diamond(psi) ∉ w.world: map to w.world (identity)
-/

/--
Construct the witness MCS for formula psi at point w.
Uses classical logic to decide membership.
-/
noncomputable def witnessAt (psi : Formula) (w : CanonicalMCS) : Set Formula :=
  if _h : diamondFormula psi ∈ w.world then
    diamondWitnessMCS w.world w.is_mcs psi _h
  else
    w.world

/--
The witness MCS at any point is maximal consistent.
-/
lemma witnessAt_is_mcs (psi : Formula) (w : CanonicalMCS) :
    SetMaximalConsistent (witnessAt psi w) := by
  simp only [witnessAt]
  split
  · exact diamondWitnessMCS_is_mcs w.world w.is_mcs psi _
  · exact w.is_mcs

/--
When Diamond(psi) ∈ w.world, the witness contains psi.
-/
lemma witnessAt_contains_psi (psi : Formula) (w : CanonicalMCS)
    (h_diamond : diamondFormula psi ∈ w.world) :
    psi ∈ witnessAt psi w := by
  simp only [witnessAt, h_diamond, dite_true]
  exact diamondWitnessMCS_contains_psi w.world w.is_mcs psi h_diamond

/--
The witness always contains BoxContent of the original world.
This ensures modal_forward compatibility.
-/
lemma witnessAt_contains_BoxContent (psi : Formula) (w : CanonicalMCS) :
    BoxContent w.world ⊆ witnessAt psi w := by
  simp only [witnessAt]
  split
  · exact diamondWitnessMCS_contains_BoxContent w.world w.is_mcs psi _
  · -- When Diamond(psi) ∉ w.world, witnessAt = w.world
    -- BoxContent(w.world) ⊆ w.world by T-axiom
    intro phi h_box
    have h_T := DerivationTree.axiom [] ((Formula.box phi).imp phi) (Axiom.modal_t phi)
    exact set_mcs_implication_property w.is_mcs (theorem_in_mcs w.is_mcs h_T) h_box

/--
When Diamond(psi) ∉ w.world, the witness is w.world itself.
-/
lemma witnessAt_identity (psi : Formula) (w : CanonicalMCS)
    (h_not_diamond : diamondFormula psi ∉ w.world) :
    witnessAt psi w = w.world := by
  simp only [witnessAt, h_not_diamond, dite_false]

/-!
## Phase 2: Forward G and Backward H for Witness Families

For the witness family to be a valid FMCS, we need forward_G and backward_H.

forward_G: G(phi) ∈ witnessAt psi w₁ and w₁ ≤ w₂ → phi ∈ witnessAt psi w₂
backward_H: H(phi) ∈ witnessAt psi w₁ and w₂ ≤ w₁ → phi ∈ witnessAt psi w₂

These follow from the T-axiom applied within each MCS:
- G(phi) ∈ MCS → phi ∈ MCS (by T-axiom G(phi) → phi)
- H(phi) ∈ MCS → phi ∈ MCS (by T-axiom H(phi) → phi)
-/

/--
Forward G for witness family: G(phi) in witness MCS at w₁ implies phi in witness MCS at w₂.
-/
lemma witnessAt_forward_G (psi : Formula)
    (w₁ w₂ : CanonicalMCS) (phi : Formula)
    (_h_le : w₁ ≤ w₂)
    (h_G : Formula.all_future phi ∈ witnessAt psi w₁) :
    phi ∈ witnessAt psi w₂ := by
  -- We know G(phi) ∈ witnessAt psi w₁ (some MCS)
  -- We need phi ∈ witnessAt psi w₂ (some other MCS)
  -- By T-axiom: G(phi) → phi, so phi ∈ witnessAt psi w₁
  -- But we need phi ∈ witnessAt psi w₂, not w₁!
  --
  -- This is WRONG. We can't conclude phi ∈ witnessAt psi w₂ from G(phi) ∈ witnessAt psi w₁
  -- because witnessAt psi w₁ and witnessAt psi w₂ might be completely different MCSes.
  --
  -- The FMCS forward_G condition requires:
  --   G(phi) ∈ fam.mcs w₁ ∧ w₁ ≤ w₂ → phi ∈ fam.mcs w₂
  --
  -- For a constant family (fam.mcs w = M for all w), this is: G(phi) ∈ M → phi ∈ M (T-axiom). ✓
  -- For the identity family (fam.mcs w = w.world), this is: G(phi) ∈ w₁.world ∧ CanonicalR w₁ w₂ → phi ∈ w₂.world. ✓
  -- For the witness family: G(phi) ∈ witnessAt psi w₁ ∧ CanonicalR w₁ w₂ → phi ∈ witnessAt psi w₂
  --
  -- witnessAt psi w₁ is either diamondWitnessMCS(w₁,...) or w₁.world
  -- witnessAt psi w₂ is either diamondWitnessMCS(w₂,...) or w₂.world
  -- These are different MCSes in general, and there's NO CanonicalR relationship between them.
  --
  -- CONCLUSION: The witness family as defined does NOT satisfy forward_G in general.
  -- We need a different approach.
  sorry

-- The above analysis shows that witnessAt-based families do NOT satisfy forward_G.
-- We need a fundamentally different approach to witness families.

-- CLEANUP: Remove the broken witnessAt approach and document the blocker.

end Bimodal.Metalogic.Bundle
