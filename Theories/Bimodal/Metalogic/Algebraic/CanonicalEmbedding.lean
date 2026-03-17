import Bimodal.Metalogic.StagedConstruction.CantorApplication
import Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
import Bimodal.Metalogic.Bundle.TemporalCoherence

/-!
# Canonical Embedding Infrastructure for Dense Algebraic Completeness

This module provides the infrastructure to construct a BFMCS over Rat by using
the existing TimelineQuot → ℚ isomorphism from Cantor's theorem.

## Overview

The construction uses existing infrastructure:
1. `TimelineQuot M₀` - dense staged timeline from a root MCS M₀
2. `cantor_iso` - order isomorphism `TimelineQuot M₀ ≃o ℚ`
3. `timelineQuotFMCS` - FMCS structure over TimelineQuot

We transfer the FMCS structure from TimelineQuot to ℚ via the isomorphism.

## Main Results

- `ratFMCS` - FMCS over ℚ transferred from TimelineQuot
- `ratFMCS_forward_F` - Forward F coherence for the Rat FMCS
- `ratFMCS_backward_P` - Backward P coherence for the Rat FMCS
- `construct_bfmcs_rat` - The BFMCS construction required by `dense_representation_conditional`

## Design

Rather than embedding CanonicalMCS into ℚ directly (which has typing issues since
CanonicalMCS has Preorder not LinearOrder), we use the full TimelineQuot construction
which already has all the necessary properties (LinearOrder, Countable, Dense, no endpoints).

## References

- Task 988: Dense Algebraic Completeness
- CantorApplication.lean: `cantor_iso : Nonempty (TimelineQuot M₀ ≃o ℚ)`
- TimelineQuotCanonical.lean: `timelineQuotFMCS : FMCS (TimelineQuot M₀)`
-/

namespace Bimodal.Metalogic.Algebraic.CanonicalEmbedding

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical

/-!
## FMCS over Rat via Cantor Isomorphism

Given a root MCS M₀, we construct an FMCS over ℚ by:
1. Building TimelineQuot from M₀
2. Using cantor_iso to get an isomorphism to ℚ
3. Pulling back timelineQuotFMCS through the isomorphism inverse
-/

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/--
The Cantor isomorphism for a specific root MCS.

This is `Nonempty` so we use `Classical.choice` to extract a witness.
-/
noncomputable def canonicalIso : TimelineQuot root_mcs root_mcs_proof ≃o ℚ :=
  Classical.choice (cantor_iso root_mcs root_mcs_proof)

/--
MCS assignment for the Rat FMCS: maps ℚ to Set Formula via the Cantor isomorphism.

For each rational q, we:
1. Map q back to TimelineQuot via (canonicalIso).symm
2. Extract the MCS from that TimelineQuot element
-/
noncomputable def ratMCS (q : ℚ) : Set Formula :=
  timelineQuotMCS root_mcs root_mcs_proof ((canonicalIso root_mcs root_mcs_proof).symm q)

/--
Each ratMCS value is maximal consistent.
-/
theorem ratMCS_is_mcs (q : ℚ) : SetMaximalConsistent (ratMCS root_mcs root_mcs_proof q) :=
  timelineQuotMCS_is_mcs root_mcs root_mcs_proof _

/--
Forward G coherence for ratMCS: if G φ ∈ mcs(q) and q < q', then φ ∈ mcs(q').

Uses the isomorphism to transfer from TimelineQuot's forward_G coherence.
-/
theorem ratMCS_forward_G (q q' : ℚ) (phi : Formula)
    (h_lt : q < q')
    (h_G : Formula.all_future phi ∈ ratMCS root_mcs root_mcs_proof q) :
    phi ∈ ratMCS root_mcs root_mcs_proof q' := by
  -- Transfer the < relation to TimelineQuot
  let iso := canonicalIso root_mcs root_mcs_proof
  have h_lt_TQ : iso.symm q < iso.symm q' := by
    rw [← OrderIso.lt_iff_lt iso.symm]
    simp [h_lt]
  -- Use TimelineQuot's forward_G
  exact timelineQuot_forward_G root_mcs root_mcs_proof
    (iso.symm q) (iso.symm q') phi h_lt_TQ h_G

/--
Backward H coherence for ratMCS: if H φ ∈ mcs(q) and q' < q, then φ ∈ mcs(q').

Uses the isomorphism to transfer from TimelineQuot's backward_H coherence.
-/
theorem ratMCS_backward_H (q q' : ℚ) (phi : Formula)
    (h_lt : q' < q)
    (h_H : Formula.all_past phi ∈ ratMCS root_mcs root_mcs_proof q) :
    phi ∈ ratMCS root_mcs root_mcs_proof q' := by
  let iso := canonicalIso root_mcs root_mcs_proof
  have h_lt_TQ : iso.symm q' < iso.symm q := by
    rw [← OrderIso.lt_iff_lt iso.symm]
    simp [h_lt]
  exact timelineQuot_backward_H root_mcs root_mcs_proof
    (iso.symm q) (iso.symm q') phi h_lt_TQ h_H

/--
The FMCS structure over ℚ, constructed via the Cantor isomorphism.
-/
noncomputable def ratFMCS : FMCS ℚ where
  mcs := ratMCS root_mcs root_mcs_proof
  is_mcs := ratMCS_is_mcs root_mcs root_mcs_proof
  forward_G := fun q q' phi h_lt h_G =>
    ratMCS_forward_G root_mcs root_mcs_proof q q' phi h_lt h_G
  backward_H := fun q q' phi h_lt h_H =>
    ratMCS_backward_H root_mcs root_mcs_proof q q' phi h_lt h_H

/-!
## Temporal Coherence (Forward F and Backward P)

For BFMCS temporal coherence, we need forward_F and backward_P properties.
These follow from the corresponding properties of the dense staged timeline.
-/

/--
Forward F coherence: if F φ ∈ mcs(q), then ∃ q' > q with φ ∈ mcs(q').

Uses dense_timeline_has_future to find a witness in TimelineQuot, then transfers to ℚ.
-/
theorem ratFMCS_forward_F (q : ℚ) (phi : Formula)
    (h_F : Formula.some_future phi ∈ ratMCS root_mcs root_mcs_proof q) :
    ∃ q' : ℚ, q < q' ∧ phi ∈ ratMCS root_mcs root_mcs_proof q' := by
  let iso := canonicalIso root_mcs root_mcs_proof
  let t := iso.symm q
  -- h_F says F φ ∈ timelineQuotMCS(t)
  -- We need to use canonical_forward_F to get a witness MCS
  -- The witness is in the dense timeline, so it maps to some TimelineQuot element
  have h_F_MCS : Formula.some_future phi ∈ timelineQuotMCS root_mcs root_mcs_proof t := h_F

  -- From the staged construction, dense_timeline_has_future gives a future witness
  -- Actually, we need forward_F for TimelineQuot, not just has_future
  -- The staged timeline has F-witnesses, but we need to connect this to timelineQuotMCS

  -- Use canonical_forward_F: F φ ∈ M implies ∃ W with CanonicalR M W ∧ φ ∈ W
  have h_MCS := timelineQuotMCS_is_mcs root_mcs root_mcs_proof t
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ :=
    canonical_forward_F (timelineQuotMCS root_mcs root_mcs_proof t) h_MCS phi h_F_MCS

  -- W is an MCS. We need to show W is in the dense timeline (i.e., comes from some TimelineQuot element)
  -- This is the key step: the dense timeline contains all CanonicalR-reachable MCSs from root

  -- The dense timeline is built from root_mcs. The witness W from canonical_forward_F
  -- is constructed via Lindenbaum from {phi} ∪ g_content(t.mcs).
  -- For W to be in the dense timeline, we need that the staged construction includes it.

  -- Actually, this is where the gap is: canonical_forward_F gives a witness MCS,
  -- but that witness may not be in the particular TimelineQuot we constructed.
  -- We need to use the fact that the staged construction ADDS witnesses for all F-demands.

  -- Looking at DenseTimeline.lean, the construction adds density intermediates,
  -- but does it add F-witnesses?

  -- From CantorPrereqs.lean, staged_timeline_has_future shows the timeline has no maximum,
  -- using the F-seriality axiom. The witness there IS in the staged timeline.

  -- Let me check: the staged execution adds points for F-demands...
  -- Yes, StagedExecution adds forward seeds based on someSuccForward.
  -- These should include F-witnesses.

  -- For now, we'll need to prove this connection exists.
  sorry

/--
Backward P coherence: if P φ ∈ mcs(q), then ∃ q' < q with φ ∈ mcs(q').

Symmetric to forward_F.
-/
theorem ratFMCS_backward_P (q : ℚ) (phi : Formula)
    (h_P : Formula.some_past phi ∈ ratMCS root_mcs root_mcs_proof q) :
    ∃ q' : ℚ, q' < q ∧ phi ∈ ratMCS root_mcs root_mcs_proof q' := by
  -- Symmetric argument to forward_F
  sorry

/-!
## BFMCS Construction over ℚ

Now we build the full BFMCS structure needed by dense_representation_conditional.
-/

/--
The single-family BFMCS over ℚ.

Since we have one FMCS (ratFMCS), we create a singleton bundle.
Modal coherence is trivial for a singleton bundle.
-/
noncomputable def ratBFMCS : BFMCS ℚ where
  families := {ratFMCS}
  nonempty := ⟨ratFMCS, Set.mem_singleton _⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    -- In a singleton bundle, fam = fam' = ratFMCS
    simp only [Set.mem_singleton_iff] at hfam hfam'
    rw [hfam, hfam']
    -- Box φ ∈ mcs(t) implies φ ∈ mcs(t) by T-axiom closure
    have h_mcs := ratMCS_is_mcs t
    exact SetMaximalConsistent.box_closure h_mcs h_box
  modal_backward := by
    intro fam hfam φ t h_all
    simp only [Set.mem_singleton_iff] at hfam
    rw [hfam]
    -- φ ∈ mcs(t) for all families means φ ∈ mcs(t)
    -- Need Box φ ∈ mcs(t)
    -- This uses the MCS property: if φ ∈ M, and ⊢ φ → Box φ (which is S5's 5 axiom)
    -- Actually, S5's 5 axiom is ◇φ → □◇φ, not φ → □φ.
    -- The correct approach: in a singleton bundle, Box φ iff φ (since all "worlds" are the same)
    -- But actually no - the box is about MODAL worlds, not temporal positions.
    -- For a single-family bundle, modal_backward should give Box φ when φ is in all families at t.
    -- Since there's only one family, h_all gives φ ∈ mcs(t).
    -- We need to derive Box φ ∈ mcs(t).
    -- This requires the 5 axiom pattern for MCS, but that's not immediate.
    sorry
  eval_family := ratFMCS
  eval_family_mem := Set.mem_singleton _

/--
The ratBFMCS is temporally coherent.
-/
theorem ratBFMCS_temporally_coherent :
    ratBFMCS.temporally_coherent := by
  intro fam hfam
  simp only [Set.mem_singleton_iff] at hfam
  rw [hfam]
  constructor
  · -- forward_F
    intro t φ h_F
    exact ratFMCS_forward_F t φ h_F
  · -- backward_P
    intro t φ h_P
    exact ratFMCS_backward_P t φ h_P

/-!
## Root MCS Membership

We need to show that the root MCS M₀ appears at some time in the ratFMCS.
-/

/--
The root MCS appears in the ratFMCS at time 0 (mapped from the root TimelineQuot element).

Actually, the root is at whatever rational the root TimelineQuot element maps to.
-/
noncomputable def ratFMCS_root_time : ℚ :=
  let root_TQ : TimelineQuot root_mcs root_mcs_proof :=
    toAntisymmetrization (· ≤ ·) ⟨rootPoint root_mcs root_mcs_proof,
      base_union_subset_dense root_mcs root_mcs_proof
        ⟨0, rootPoint_in_stagedBuild_0 root_mcs root_mcs_proof⟩⟩
  canonicalIso root_TQ

/--
The root MCS is the mcs at ratFMCS_root_time.
-/
theorem ratFMCS_root_eq :
    ratMCS ratFMCS_root_time = root_mcs := by
  unfold ratFMCS_root_time ratMCS
  -- iso.symm (iso root_TQ) = root_TQ by OrderIso.symm_apply_apply
  rw [OrderIso.symm_apply_apply]
  -- Now need timelineQuotMCS root_TQ = root_mcs
  -- root_TQ is the equivalence class of rootPoint
  -- timelineQuotMCS extracts via ofAntisymmetrization, which should give rootPoint or equivalent
  sorry

/-!
## The Main Construction Function

This is what dense_representation_conditional needs.
-/

/--
Construct a temporally coherent BFMCS over ℚ containing the root MCS.

This takes the root MCS from the variable and constructs a BFMCS containing it.

**Status**: SORRY - requires completion of forward_F, backward_P, modal_backward, and root_eq
-/
noncomputable def construct_bfmcs_rat_for_root :
    Σ' (B : BFMCS ℚ) (h_tc : B.temporally_coherent)
       (fam : FMCS ℚ) (hfam : fam ∈ B.families) (t : ℚ),
       root_mcs = fam.mcs t := by
  sorry

end Bimodal.Metalogic.Algebraic.CanonicalEmbedding

namespace Bimodal.Metalogic.Algebraic

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/--
Construct a temporally coherent BFMCS over ℚ containing any given MCS.

Given an MCS M, we use M as the root for the dense timeline construction,
then transfer to ℚ via Cantor isomorphism.

This is the main function needed by `dense_representation_conditional`.

**Status**: SORRY - depends on construct_bfmcs_rat_for_root which has sorries
-/
noncomputable def construct_bfmcs_rat (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS ℚ) (h_tc : B.temporally_coherent)
       (fam : FMCS ℚ) (hfam : fam ∈ B.families) (t : ℚ),
       M = fam.mcs t :=
  CanonicalEmbedding.construct_bfmcs_rat_for_root M h_mcs

end Bimodal.Metalogic.Algebraic
