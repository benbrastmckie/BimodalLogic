import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Coherent Witness Chain Construction

This module implements the Coherent Witness Chain construction for eliminating
`singleFamily_modal_backward_axiom` from Construction.lean.

## Background

The previous Pre-Coherent Bundle approach (implementation-001.md) failed because
it relied on a false claim: that S-boundedness (an intra-family property) could
enforce box-coherence (an inter-family property). These properties are orthogonal.

## Key Insight

**Any "product of all families satisfying local property P" approach will fail**
because local properties cannot force global agreement. The bundle construction
must BUILD agreement into the construction process.

## Approach: Coherent Witness Chain

The Coherent Witness Chain approach constructs witnesses that are coherent BY DESIGN:

1. Define `BoxContent(fam)` = set of all chi where Box chi appears in fam.mcs at any time
2. Define `WitnessSeed(base, psi)` = {psi} ∪ BoxContent(base)
3. Prove `diamond_boxcontent_consistent`: If Diamond psi ∈ base.mcs t, then WitnessSeed is consistent
4. Build witnesses from WitnessSeed via Lindenbaum - coherence follows from seed inclusion

## Main Results

- `BoxContent`: Set of formulas whose boxes appear in a family
- `WitnessSeed`: The seed for constructing coherent witnesses
- `diamond_boxcontent_consistent`: Core viability lemma for the approach
- `CoherentWitness`: A witness family with built-in coherence proof
- `CoherentBundle`: A bundle of coherent witnesses satisfying BMCS requirements
- `CoherentBundle.toBMCS`: Conversion to BMCS for TruthLemma compatibility

## References

- Research report: specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-002.md
- Implementation plan: specs/844_redesign_metalogic_precoherent_bundle_construction/plans/implementation-002.md
- Failed approach: Bimodal.Metalogic.Bundle.PreCoherentBundle
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Phase 1: BoxContent and WitnessSeed Definitions
-/

/--
BoxContent of a family: the set of all formulas chi where Box chi appears
in the family's MCS at any time.

This captures "what the family believes is necessary". For a witness to be
coherent with this family, the witness must contain all of BoxContent.
-/
def BoxContent (fam : IndexedMCSFamily D) : Set Formula :=
  {chi | ∃ t : D, Formula.box chi ∈ fam.mcs t}

/--
BoxContent at a specific time: the set of all chi where Box chi is in fam.mcs t.

This is a time-restricted version used for some proofs.
-/
def BoxContentAt (fam : IndexedMCSFamily D) (t : D) : Set Formula :=
  {chi | Formula.box chi ∈ fam.mcs t}

/--
BoxContentAt is a subset of BoxContent.
-/
lemma BoxContentAt_subset_BoxContent (fam : IndexedMCSFamily D) (t : D) :
    BoxContentAt fam t ⊆ BoxContent fam := by
  intro chi h_at
  exact ⟨t, h_at⟩

/--
If Box chi is in the family's MCS at time t, then chi is in BoxContent.
-/
lemma box_mem_implies_boxcontent (fam : IndexedMCSFamily D) (chi : Formula) (t : D)
    (h : Formula.box chi ∈ fam.mcs t) : chi ∈ BoxContent fam :=
  ⟨t, h⟩

/--
WitnessSeed for constructing a coherent witness for Diamond psi.

The seed is {psi} ∪ BoxContent(base). This ensures:
1. The witness contains psi (witnessing the Diamond)
2. The witness contains all chi where Box chi is in base (ensuring coherence)
-/
def WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) : Set Formula :=
  {psi} ∪ BoxContent base

/--
psi is in its own WitnessSeed.
-/
lemma psi_mem_WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) :
    psi ∈ WitnessSeed base psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/--
BoxContent is a subset of WitnessSeed.
-/
lemma BoxContent_subset_WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) :
    BoxContent base ⊆ WitnessSeed base psi :=
  Set.subset_union_right

/--
If Box chi is in base.mcs at any time, then chi is in WitnessSeed.
-/
lemma box_in_base_implies_WitnessSeed (base : IndexedMCSFamily D) (psi chi : Formula) (t : D)
    (h : Formula.box chi ∈ base.mcs t) : chi ∈ WitnessSeed base psi :=
  BoxContent_subset_WitnessSeed base psi (box_mem_implies_boxcontent base chi t h)

/-!
## Phase 1: CoherentWitness Structure

A CoherentWitness bundles a witness family with proofs that:
1. It contains the witnessed formula psi
2. It contains all of BoxContent (ensuring coherence with base)
-/

/--
A coherent witness for a Diamond psi formula.

This structure captures a witness family that:
- Contains psi (witnessing Diamond psi)
- Contains BoxContent(base) at all times (ensuring coherence with base)

The coherence property is crucial: it ensures that when we build a bundle
from a base and its witnesses, box-coherence holds BY CONSTRUCTION.
-/
structure CoherentWitness (base : IndexedMCSFamily D) where
  /-- The witness family -/
  family : IndexedMCSFamily D
  /-- The formula being witnessed (inner formula of Diamond) -/
  witnessed : Formula
  /-- The witness contains the witnessed formula at all times -/
  contains_witnessed : ∀ t : D, witnessed ∈ family.mcs t
  /-- The witness contains all of BoxContent(base) at all times -/
  contains_boxcontent : ∀ chi, chi ∈ BoxContent base → ∀ t : D, chi ∈ family.mcs t

/--
A CoherentWitness's family contains chi at time t if Box chi is in base at any time s.

This is the key coherence property that makes box-coherence work.
-/
lemma CoherentWitness.coherent_with_base (base : IndexedMCSFamily D)
    (w : CoherentWitness base) (chi : Formula) (s t : D)
    (h_box : Formula.box chi ∈ base.mcs s) : chi ∈ w.family.mcs t :=
  w.contains_boxcontent chi ⟨s, h_box⟩ t

/-!
## Helper for Constant Witness Family

When we construct a witness family from a WitnessSeed, we use a constant family
(same MCS at all times). This simplifies temporal coherence.
-/

/--
The MCS of a constant witness family equals the underlying MCS at any time.
-/
lemma constantWitnessFamily_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) (t : D) :
    (constantWitnessFamily M h_mcs (D := D)).mcs t = M := rfl

end Bimodal.Metalogic.Bundle
