import Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.BFMCS

/-!
# DovetailedFMCS: FMCS over DovetailedTimelineQuot

This module constructs the FMCS (Family of Maximal Consistent Sets) structure
over `DovetailedTimelineQuot`, with temporal coherence conditions satisfied
via the sorry-free coverage lemmas from DovetailedCoverage.lean.

## Overview

The FMCS structure assigns an MCS to each time point in DovetailedTimelineQuot
and proves temporal coherence:
- `forward_G`: G φ at t, t < t' implies φ at t'
- `backward_H`: H φ at t, t' < t implies φ at t'

## Key Results

- `dovetailedFMCS`: The FMCS structure over DovetailedTimelineQuot
- `dovetailedTimelineQuot_lt_implies_canonicalR`: Core linking lemma

## References

- Task 988: Dense algebraic completeness
- DovetailedTimelineQuot.lean: Base domain construction
- DovetailedCoverage.lean: Coverage lemmas
- TimelineQuotCanonical.lean: Pattern for FMCS construction
-/

namespace Bimodal.Metalogic.StagedConstruction.DovetailedFMCS

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.Metalogic.StagedConstruction.DovetailedBuild
open Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Phase 3.1: Core Linking Lemma

The central bridge between DovetailedTimelineQuot ordering and CanonicalR accessibility.
-/

/--
**Core Linking Lemma**: If t < t' in DovetailedTimelineQuot, then CanonicalR between their MCSs.

**Proof Idea**:
- t < t' means: for representatives p, q, we have p ≤ q and ¬(q ≤ p)
- DovetailedPoint.le p q means: p.mcs = q.mcs or CanonicalR p.mcs q.mcs
- The equality case is excluded by ¬(q ≤ p)
- Therefore CanonicalR p.mcs q.mcs
-/
theorem dovetailedTimelineQuot_lt_implies_canonicalR
    (t t' : DovetailedTimelineQuot root_mcs root_mcs_proof)
    (h : t < t') :
    CanonicalR (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
               (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t') := by
  -- Inject the IsPreorder instance for use in this proof
  haveI : IsPreorder (DovetailedTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    instIsPreorderDovetailedTimelineElem root_mcs root_mcs_proof
  -- Use induction to work with representatives
  induction t using Antisymmetrization.ind with
  | _ p =>
    induction t' using Antisymmetrization.ind with
    | _ q =>
      -- t < t' becomes p < q in the preorder sense (strict)
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at h
      obtain ⟨h_le, h_not_le⟩ := h
      -- h_le : p ≤ q (which is DovetailedPoint.le p.1 q.1)
      -- h_not_le : ¬(q ≤ p)
      have h_le' : DovetailedPoint.le p.1 q.1 := h_le
      have h_not_le' : ¬DovetailedPoint.le q.1 p.1 := h_not_le
      -- DovetailedPoint.le is: a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs
      simp only [DovetailedPoint.le] at h_le' h_not_le'
      push_neg at h_not_le'
      -- h_le' : p.1.mcs = q.1.mcs ∨ CanonicalR p.1.mcs q.1.mcs
      -- h_not_le' : q.1.mcs ≠ p.1.mcs ∧ ¬CanonicalR q.1.mcs p.1.mcs
      cases h_le' with
      | inl h_eq =>
        -- p.1.mcs = q.1.mcs contradicts h_not_le'.1 (q.1.mcs ≠ p.1.mcs)
        exact absurd h_eq.symm h_not_le'.1
      | inr h_R =>
        -- We have CanonicalR p.1.mcs q.1.mcs
        -- Now connect to dovetailedTimelineQuotMCS
        simp only [dovetailedTimelineQuotMCS]

        let rep_p := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
        let rep_q := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

        have h_rep_p_class : toAntisymmetrization (· ≤ ·) rep_p = toAntisymmetrization (· ≤ ·) p :=
          toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
        have h_rep_q_class : toAntisymmetrization (· ≤ ·) rep_q = toAntisymmetrization (· ≤ ·) q :=
          toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

        have h_rep_p_equiv : AntisymmRel (· ≤ ·) rep_p p := by
          constructor
          · show rep_p ≤ p
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_p_class]
          · show p ≤ rep_p
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_p_class]

        have h_rep_q_equiv : AntisymmRel (· ≤ ·) rep_q q := by
          constructor
          · show rep_q ≤ q
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_q_class]
          · show q ≤ rep_q
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_q_class]

        have h_mcs_p : rep_p.1.mcs = p.1.mcs :=
          dovetailedTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_p p
            h_rep_p_equiv.1 h_rep_p_equiv.2

        have h_mcs_q : rep_q.1.mcs = q.1.mcs :=
          dovetailedTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_q q
            h_rep_q_equiv.1 h_rep_q_equiv.2

        rw [h_mcs_p, h_mcs_q]
        exact h_R

/--
Converse direction: CanonicalR implies ≤ in DovetailedTimelineQuot.
-/
theorem canonicalR_implies_dovetailedTimelineQuot_le
    (t t' : DovetailedTimelineQuot root_mcs root_mcs_proof)
    (h : CanonicalR (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
                    (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t')) :
    t ≤ t' := by
  haveI : IsPreorder (DovetailedTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    instIsPreorderDovetailedTimelineElem root_mcs root_mcs_proof
  induction t using Antisymmetrization.ind with
  | _ p =>
    induction t' using Antisymmetrization.ind with
    | _ q =>
      rw [toAntisymmetrization_le_toAntisymmetrization_iff]
      show DovetailedPoint.le p.1 q.1
      simp only [DovetailedPoint.le]
      simp only [dovetailedTimelineQuotMCS] at h
      let rep_p := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
      let rep_q := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

      have h_rep_p_class : toAntisymmetrization (· ≤ ·) rep_p = toAntisymmetrization (· ≤ ·) p :=
        toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
      have h_rep_q_class : toAntisymmetrization (· ≤ ·) rep_q = toAntisymmetrization (· ≤ ·) q :=
        toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

      have h_rep_p_equiv : AntisymmRel (· ≤ ·) rep_p p := by
        constructor
        · show rep_p ≤ p
          rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_p_class]
        · show p ≤ rep_p
          rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_p_class]

      have h_rep_q_equiv : AntisymmRel (· ≤ ·) rep_q q := by
        constructor
        · show rep_q ≤ q
          rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_q_class]
        · show q ≤ rep_q
          rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_q_class]

      have h_mcs_p : rep_p.1.mcs = p.1.mcs :=
        dovetailedTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_p p
          h_rep_p_equiv.1 h_rep_p_equiv.2
      have h_mcs_q : rep_q.1.mcs = q.1.mcs :=
        dovetailedTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_q q
          h_rep_q_equiv.1 h_rep_q_equiv.2

      rw [h_mcs_p, h_mcs_q] at h
      exact Or.inr h

/-!
## Phase 3.2: Temporal Coherence Properties
-/

/--
Forward G coherence for DovetailedTimelineQuot: G φ at t, t < t' implies φ at t'.

Uses dovetailedTimelineQuot_lt_implies_canonicalR + canonical_forward_G.
-/
theorem dovetailedTimelineQuot_forward_G
    (t t' : DovetailedTimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_lt : t < t')
    (h_G : Formula.all_future phi ∈ dovetailedTimelineQuotMCS root_mcs root_mcs_proof t) :
    phi ∈ dovetailedTimelineQuotMCS root_mcs root_mcs_proof t' := by
  have h_R := dovetailedTimelineQuot_lt_implies_canonicalR root_mcs root_mcs_proof t t' h_lt
  exact canonical_forward_G
    (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
    (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t')
    h_R phi h_G

/--
Backward H coherence for DovetailedTimelineQuot: H φ at t, t' < t implies φ at t'.

Uses dovetailedTimelineQuot_lt_implies_canonicalR + g_content/h_content duality.
-/
theorem dovetailedTimelineQuot_backward_H
    (t t' : DovetailedTimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_lt : t' < t)
    (h_H : Formula.all_past phi ∈ dovetailedTimelineQuotMCS root_mcs root_mcs_proof t) :
    phi ∈ dovetailedTimelineQuotMCS root_mcs root_mcs_proof t' := by
  have h_R := dovetailedTimelineQuot_lt_implies_canonicalR root_mcs root_mcs_proof t' t h_lt
  have h_t'_mcs := dovetailedTimelineQuotMCS_is_mcs root_mcs root_mcs_proof t'
  have h_t_mcs := dovetailedTimelineQuotMCS_is_mcs root_mcs root_mcs_proof t
  have h_R_past : CanonicalR_past
      (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
      (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t') :=
    g_content_subset_implies_h_content_reverse
      (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t')
      (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
      h_t'_mcs h_t_mcs h_R
  exact canonical_backward_H
    (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t)
    (dovetailedTimelineQuotMCS root_mcs root_mcs_proof t')
    h_R_past phi h_H

/-!
## Phase 3.3: FMCS Construction
-/

/--
The FMCS structure over DovetailedTimelineQuot.

Each time point t maps to its MCS via dovetailedTimelineQuotMCS.
Temporal coherence follows from the linking lemma.
-/
noncomputable def dovetailedFMCS : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof) where
  mcs := dovetailedTimelineQuotMCS root_mcs root_mcs_proof
  is_mcs := dovetailedTimelineQuotMCS_is_mcs root_mcs root_mcs_proof
  forward_G := fun t t' phi h_lt h_G =>
    dovetailedTimelineQuot_forward_G root_mcs root_mcs_proof t t' phi h_lt h_G
  backward_H := fun t t' phi h_lt h_H =>
    dovetailedTimelineQuot_backward_H root_mcs root_mcs_proof t t' phi h_lt h_H

/-!
## Phase 3.4: Root MCS at Time 0

The root point maps to time 0 in DovetailedTimelineQuot.
-/

/--
The root MCS is at some time in DovetailedTimelineQuot.

The root point of the dovetailed construction exists in the timeline union.
-/
theorem dovetailedTimelineQuot_root_exists :
    ∃ t : DovetailedTimelineQuot root_mcs root_mcs_proof,
      dovetailedTimelineQuotMCS root_mcs root_mcs_proof t = root_mcs := by
  haveI : IsPreorder (DovetailedTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    instIsPreorderDovetailedTimelineElem root_mcs root_mcs_proof
  -- The root point is in the timeline at step 0
  obtain ⟨p, hp, hp_mcs, _⟩ := root_in_dovetailedBuild_0 root_mcs root_mcs_proof
  let p_elem : DovetailedTimelineElem root_mcs root_mcs_proof := ⟨p, ⟨0, hp⟩⟩
  let t := toAntisymmetrization (· ≤ ·) p_elem
  use t
  simp only [dovetailedTimelineQuotMCS]
  -- Need to show: (ofAntisymmetrization (toAntisymmetrization p_elem)).1.mcs = root_mcs
  let rep := ofAntisymmetrization (· ≤ ·) t
  have h_class : toAntisymmetrization (· ≤ ·) rep = t :=
    toAntisymmetrization_ofAntisymmetrization (· ≤ ·) t
  have h_equiv : AntisymmRel (· ≤ ·) rep p_elem := by
    unfold AntisymmRel
    -- Since t = toAntisymmetrization p_elem and rep = ofAntisymmetrization t,
    -- and toAntisymmetrization rep = t, we have:
    -- toAntisymmetrization rep = t = toAntisymmetrization p_elem
    have h_eq : toAntisymmetrization (· ≤ ·) rep = toAntisymmetrization (· ≤ ·) p_elem := h_class
    constructor
    · -- rep ≤ p_elem
      have h1 : toAntisymmetrization (· ≤ ·) rep ≤ toAntisymmetrization (· ≤ ·) p_elem := by
        rw [h_eq]
      exact toAntisymmetrization_le_toAntisymmetrization_iff.mp h1
    · -- p_elem ≤ rep
      have h1 : toAntisymmetrization (· ≤ ·) p_elem ≤ toAntisymmetrization (· ≤ ·) rep := by
        rw [h_eq]
      exact toAntisymmetrization_le_toAntisymmetrization_iff.mp h1
  have h_mcs_eq := dovetailedTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof
    rep p_elem h_equiv.1 h_equiv.2
  rw [h_mcs_eq, hp_mcs]

end Bimodal.Metalogic.StagedConstruction.DovetailedFMCS
