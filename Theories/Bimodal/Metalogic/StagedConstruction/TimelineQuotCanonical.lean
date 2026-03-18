import Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom

/-!
# TimelineQuot Canonical Model Construction

This module builds the canonical FMCS/BFMCS structure over TimelineQuot,
connecting the syntactically-derived dense linear order to the MCS-based
semantics needed for completeness.

## Overview

The key insight from research-005 is that D (time domain) and WorldState
(space of MCSs) must remain mathematically distinct:

- D = TimelineQuot (syntactically-derived time domain)
- WorldState = CanonicalWorldState (space of MCSs as subtypes)
- FMCS : D → Set Formula (assigns MCS to each time)
- BFMCS : Set (FMCS D) (bundle with modal coherence)

## Key Results

- `timelineQuot_lt_implies_canonicalR`: The core linking lemma connecting
  TimelineQuot ordering to CanonicalR accessibility
- `timelineQuotFMCS`: FMCS structure over TimelineQuot
- `timelineQuotBFMCS`: BFMCS bundle for countermodel construction

## References

- Task 982: Wire dense completeness domain connection
- research-005.md: Rigorous mathematical analysis
- implementation-003.md: Implementation plan v3
-/

namespace Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
open Bimodal.Metalogic.Canonical

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

-- Provide IsPreorder instance for DenseTimelineElem (needed for Antisymmetrization lemmas)
-- Use the EXACT form that Lean's elaboration produces: `fun x1 x2 ↦ x1 ≤ x2`
-- NOTE: Variable names x1, x2 match what Lean produces from (· ≤ ·)
noncomputable instance denseTimelineElemIsPreorder :
    IsPreorder (DenseTimelineElem root_mcs root_mcs_proof) (fun x1 x2 ↦ x1 ≤ x2) where
  refl := fun a => le_refl a
  trans := fun a b c => le_trans

/-!
## Phase 1: Core Linking Lemma

The central bridge between TimelineQuot ordering and CanonicalR accessibility.
-/

/--
Key helper: If two DenseTimelineElems are mutually ≤ (i.e., in the same equivalence class),
then their underlying MCSs are equal.

**Proof**: Mutual ≤ means both StagedPoint.le directions hold.
- StagedPoint.le p q means: p.mcs = q.mcs ∨ CanonicalR p.mcs q.mcs
- StagedPoint.le q p means: q.mcs = p.mcs ∨ CanonicalR q.mcs p.mcs

If both are CanonicalR, then by transitivity we get CanonicalR p.mcs p.mcs,
contradicting canonicalR_irreflexive. So at least one must be equality.
-/
theorem denseTimelineElem_mutual_le_implies_mcs_eq
    (p q : DenseTimelineElem root_mcs root_mcs_proof)
    (h_pq : p ≤ q) (h_qp : q ≤ p) :
    p.1.mcs = q.1.mcs := by
  -- The ≤ on DenseTimelineElem is StagedPoint.le
  have h_pq' : StagedPoint.le p.1 q.1 := h_pq
  have h_qp' : StagedPoint.le q.1 p.1 := h_qp
  simp only [StagedPoint.le] at h_pq' h_qp'
  cases h_pq' with
  | inl h_eq => exact h_eq
  | inr h_R_pq =>
    cases h_qp' with
    | inl h_eq => exact h_eq.symm
    | inr h_R_qp =>
      -- Both are CanonicalR: CanonicalR p.mcs q.mcs and CanonicalR q.mcs p.mcs
      -- By transitivity: CanonicalR p.mcs p.mcs
      have h_trans := canonicalR_transitive p.1.mcs q.1.mcs p.1.mcs p.1.is_mcs h_R_pq h_R_qp
      -- This contradicts irreflexivity
      exact absurd h_trans (Canonical.canonicalR_irreflexive p.1.mcs p.1.is_mcs)

/--
**Core Linking Lemma**: If t < t' in TimelineQuot, then CanonicalR between their underlying MCSs.

**Proof Idea**:
- t < t' in TimelineQuot means: for representatives p, q, we have p ≤ q and ¬(q ≤ p)
- StagedPoint.le p q means: p.mcs = q.mcs or CanonicalR p.mcs q.mcs
- The equality case is excluded by ¬(q ≤ p), which requires p.mcs ≠ q.mcs
- Therefore CanonicalR p.mcs q.mcs

The key insight is that representatives from the SAME equivalence class have the same MCS
(by denseTimelineElem_mutual_le_implies_mcs_eq), so timelineQuotMCS is well-defined on the quotient.
-/
theorem timelineQuot_lt_implies_canonicalR (t t' : TimelineQuot root_mcs root_mcs_proof)
    (h : t < t') :
    CanonicalR (timelineQuotMCS root_mcs root_mcs_proof t)
               (timelineQuotMCS root_mcs root_mcs_proof t') := by
  -- Inject the IsPreorder instance for use in this proof
  haveI : IsPreorder (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    denseTimelineElemIsPreorder root_mcs root_mcs_proof
  -- Use induction to work with representatives
  induction t using Antisymmetrization.ind with
  | _ p =>
    induction t' using Antisymmetrization.ind with
    | _ q =>
      -- t < t' becomes p < q in the preorder sense (strict)
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at h
      obtain ⟨h_le, h_not_le⟩ := h
      -- h_le : p ≤ q (which is StagedPoint.le p.1 q.1)
      -- h_not_le : ¬(q ≤ p)
      have h_le' : StagedPoint.le p.1 q.1 := h_le
      have h_not_le' : ¬StagedPoint.le q.1 p.1 := h_not_le
      -- StagedPoint.le is: a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs
      simp only [StagedPoint.le] at h_le' h_not_le'
      push_neg at h_not_le'
      -- h_le' : p.1.mcs = q.1.mcs ∨ CanonicalR p.1.mcs q.1.mcs
      -- h_not_le' : q.1.mcs ≠ p.1.mcs ∧ ¬CanonicalR q.1.mcs p.1.mcs
      cases h_le' with
      | inl h_eq =>
        -- p.1.mcs = q.1.mcs contradicts h_not_le'.1 (q.1.mcs ≠ p.1.mcs)
        exact absurd h_eq.symm h_not_le'.1
      | inr h_R =>
        -- We have CanonicalR p.1.mcs q.1.mcs
        -- Now we need to connect this to timelineQuotMCS t and timelineQuotMCS t'
        -- timelineQuotMCS extracts via ofAntisymmetrization, which gives SOME representative
        -- The key is that all representatives of the same class have the same MCS
        -- For the class of toAntisymmetrization p, ofAntisymmetrization gives back
        -- something that is AntisymmRel to p, hence has the same MCS
        simp only [timelineQuotMCS]
        -- ofAntisymmetrization (toAntisymmetrization p) is in the same class as p
        -- The representatives have the same MCS by denseTimelineElem_mutual_le_implies_mcs_eq
        -- For now, we observe that the extracted MCS is still p.1.mcs and q.1.mcs
        -- because any representative in the same class has the same MCS

        -- Need to show: CanonicalR
        --   (ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)).1.mcs
        --   (ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)).1.mcs

        -- Let rep_p = ofAntisymmetrization (toAntisymmetrization p)
        -- Let rep_q = ofAntisymmetrization (toAntisymmetrization q)
        -- By construction, toAntisymmetrization rep_p = toAntisymmetrization p (both in same class)
        -- This means AntisymmRel rep_p p, i.e., rep_p ≤ p ∧ p ≤ rep_p
        -- By denseTimelineElem_mutual_le_implies_mcs_eq, rep_p.1.mcs = p.1.mcs
        -- Similarly rep_q.1.mcs = q.1.mcs
        -- Therefore goal becomes CanonicalR p.1.mcs q.1.mcs, which is h_R

        let rep_p := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
        let rep_q := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

        -- rep_p is AntisymmRel to p (they represent the same class)
        -- Key fact: toAntisymmetrization (ofAntisymmetrization a) = a
        have h_rep_p_class : toAntisymmetrization (· ≤ ·) rep_p = toAntisymmetrization (· ≤ ·) p :=
          toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
        have h_rep_q_class : toAntisymmetrization (· ≤ ·) rep_q = toAntisymmetrization (· ≤ ·) q :=
          toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

        have h_rep_p_equiv : AntisymmRel (· ≤ ·) rep_p p := by
          constructor
          · -- rep_p ≤ p
            show rep_p ≤ p
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_p_class]
          · -- p ≤ rep_p
            show p ≤ rep_p
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_p_class]

        have h_rep_q_equiv : AntisymmRel (· ≤ ·) rep_q q := by
          constructor
          · -- rep_q ≤ q
            show rep_q ≤ q
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_rep_q_class]
          · -- q ≤ rep_q
            show q ≤ rep_q
            rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_rep_q_class]

        -- Now use the fact that equivalent elements have same MCS
        have h_mcs_p : rep_p.1.mcs = p.1.mcs :=
          denseTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_p p
            h_rep_p_equiv.1 h_rep_p_equiv.2

        have h_mcs_q : rep_q.1.mcs = q.1.mcs :=
          denseTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_q q
            h_rep_q_equiv.1 h_rep_q_equiv.2

        -- Substitute to get the goal
        rw [h_mcs_p, h_mcs_q]
        exact h_R

/--
Converse direction: CanonicalR implies ≤ in TimelineQuot.

This is used to show the FMCS coherence conditions.
-/
theorem canonicalR_implies_timelineQuot_le
    (t t' : TimelineQuot root_mcs root_mcs_proof)
    (h : CanonicalR (timelineQuotMCS root_mcs root_mcs_proof t)
                    (timelineQuotMCS root_mcs root_mcs_proof t')) :
    t ≤ t' := by
  -- Inject the IsPreorder instance for use in this proof
  haveI : IsPreorder (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    denseTimelineElemIsPreorder root_mcs root_mcs_proof
  induction t using Antisymmetrization.ind with
  | _ p =>
    induction t' using Antisymmetrization.ind with
    | _ q =>
      rw [toAntisymmetrization_le_toAntisymmetrization_iff]
      show StagedPoint.le p.1 q.1
      simp only [StagedPoint.le]
      -- Extract the MCS equality from the representatives
      simp only [timelineQuotMCS] at h
      let rep_p := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) p)
      let rep_q := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) q)

      -- Key facts: toAntisymmetrization (ofAntisymmetrization a) = a
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
        denseTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_p p
          h_rep_p_equiv.1 h_rep_p_equiv.2
      have h_mcs_q : rep_q.1.mcs = q.1.mcs :=
        denseTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof rep_q q
          h_rep_q_equiv.1 h_rep_q_equiv.2
      -- h : CanonicalR rep_p.1.mcs rep_q.1.mcs
      -- After substitution: CanonicalR p.1.mcs q.1.mcs
      rw [h_mcs_p, h_mcs_q] at h
      exact Or.inr h

/-!
## Phase 2: FMCS over TimelineQuot
-/

/--
Forward G coherence for TimelineQuot: G φ at t, t < t' implies φ at t'.

Uses timelineQuot_lt_implies_canonicalR + canonical_forward_G.
-/
theorem timelineQuot_forward_G
    (t t' : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_lt : t < t')
    (h_G : Formula.all_future phi ∈ timelineQuotMCS root_mcs root_mcs_proof t) :
    phi ∈ timelineQuotMCS root_mcs root_mcs_proof t' := by
  have h_R := timelineQuot_lt_implies_canonicalR root_mcs root_mcs_proof t t' h_lt
  exact canonical_forward_G
    (timelineQuotMCS root_mcs root_mcs_proof t)
    (timelineQuotMCS root_mcs root_mcs_proof t')
    h_R phi h_G

/--
Backward H coherence for TimelineQuot: H φ at t, t' < t implies φ at t'.

Uses timelineQuot_lt_implies_canonicalR + g_content/h_content duality.
-/
theorem timelineQuot_backward_H
    (t t' : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_lt : t' < t)
    (h_H : Formula.all_past phi ∈ timelineQuotMCS root_mcs root_mcs_proof t) :
    phi ∈ timelineQuotMCS root_mcs root_mcs_proof t' := by
  -- t' < t implies CanonicalR between their MCSs
  have h_R := timelineQuot_lt_implies_canonicalR root_mcs root_mcs_proof t' t h_lt
  -- CanonicalR t'.mcs t.mcs implies h_content(t.mcs) ⊆ t'.mcs (duality)
  have h_t'_mcs := timelineQuotMCS_is_mcs root_mcs root_mcs_proof t'
  have h_t_mcs := timelineQuotMCS_is_mcs root_mcs root_mcs_proof t
  have h_R_past : CanonicalR_past
      (timelineQuotMCS root_mcs root_mcs_proof t)
      (timelineQuotMCS root_mcs root_mcs_proof t') :=
    g_content_subset_implies_h_content_reverse
      (timelineQuotMCS root_mcs root_mcs_proof t')
      (timelineQuotMCS root_mcs root_mcs_proof t)
      h_t'_mcs h_t_mcs h_R
  exact canonical_backward_H
    (timelineQuotMCS root_mcs root_mcs_proof t)
    (timelineQuotMCS root_mcs root_mcs_proof t')
    h_R_past phi h_H

/--
The FMCS structure over TimelineQuot.

Each time point t maps to its MCS via timelineQuotMCS.
Temporal coherence follows from the linking lemma.
-/
noncomputable def timelineQuotFMCS : FMCS (TimelineQuot root_mcs root_mcs_proof) where
  mcs := timelineQuotMCS root_mcs root_mcs_proof
  is_mcs := timelineQuotMCS_is_mcs root_mcs root_mcs_proof
  forward_G := fun t t' phi h_lt h_G =>
    timelineQuot_forward_G root_mcs root_mcs_proof t t' phi h_lt h_G
  backward_H := fun t t' phi h_lt h_H =>
    timelineQuot_backward_H root_mcs root_mcs_proof t t' phi h_lt h_H

/-!
## Phase 2: TaskFrame over TimelineQuot

The W/D-separated TaskFrame instantiation for dense completeness.
-/

-- Make algebraic instances available for ParametricCanonicalTaskFrame instantiation
attribute [local instance] timelineQuotAddCommGroup timelineQuotIsOrderedAddMonoid

open Algebraic.ParametricCanonical

/--
The W/D-separated TaskFrame for dense completeness over TimelineQuot.

- **WorldState** = `ParametricCanonicalWorldState` (MCSs as subtypes)
- **D** = `TimelineQuot` (syntactically-derived dense timeline)
- **task_rel** = `parametric_canonical_task_rel` (uses CanonicalR)

This is the correct architecture for dense completeness:
- W (world states) = ALL maximal consistent sets (D-independent)
- D (duration domain) = TimelineQuot (emerges from density axiom via Cantor)
- task_rel uses CanonicalR between MCSs, not W = D translation

The TaskFrame axioms are proven sorry-free in `ParametricCanonical.lean`.
The Cantor isomorphism (TimelineQuot ≃o Q) provides the algebraic structure.
-/
noncomputable def timelineQuotParametricTaskFrame :
    @TaskFrame (TimelineQuot root_mcs root_mcs_proof)
      (timelineQuotAddCommGroup root_mcs root_mcs_proof)
      (inferInstance : LinearOrder (TimelineQuot root_mcs root_mcs_proof))
      (timelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof) :=
  @ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)
    (timelineQuotAddCommGroup root_mcs root_mcs_proof)
    (inferInstance)
    (timelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof)

/--
The world state type of the TimelineQuot TaskFrame is `ParametricCanonicalWorldState`.

This confirms W ≠ D: world states are MCSs, not timeline elements.
-/
theorem timelineQuotParametricTaskFrame_worldState :
    (@timelineQuotParametricTaskFrame root_mcs root_mcs_proof).WorldState =
    ParametricCanonicalWorldState := rfl

/--
The task relation is `parametric_canonical_task_rel`, which uses CanonicalR.

This confirms the task relation is a genuine accessibility relation between MCSs,
not the degenerate W = D translation (w + d = w').
-/
theorem timelineQuotParametricTaskFrame_task_rel :
    (@timelineQuotParametricTaskFrame root_mcs root_mcs_proof).task_rel =
    parametric_canonical_task_rel := rfl

/-!
## Phase 4: Forward-Only Truth Lemma (Stub)

For the countermodel construction, we only need the FORWARD direction of the truth lemma:
  MCS membership → semantic truth

This avoids the `modal_backward` issue in singleton BFMCS.

**Note**: The full forward truth lemma implementation is in `SeparatedHistory.lean` and
related files. This stub documents the required theorems for completeness.
-/

/--
The root point of the dense timeline construction, wrapped as a DenseTimelineElem.
-/
noncomputable def rootTimelineElem : DenseTimelineElem root_mcs root_mcs_proof :=
  ⟨rootPoint root_mcs root_mcs_proof,
   ⟨0, stagedBuild_subset_denseStage root_mcs root_mcs_proof 0
       (rootPoint_in_stagedBuild_0 root_mcs root_mcs_proof)⟩⟩

/--
The time in TimelineQuot corresponding to the root MCS.
This is the equivalence class of the root point under Antisymmetrization.
-/
noncomputable def rootTime : TimelineQuot root_mcs root_mcs_proof :=
  toAntisymmetrization (· ≤ ·) (rootTimelineElem root_mcs root_mcs_proof)

/--
The MCS at root time equals the root MCS.

**Proof**: The root time is the equivalence class of rootTimelineElem.
By `denseTimelineElem_mutual_le_implies_mcs_eq`, all representatives in
the same class have the same MCS. Since rootTimelineElem has mcs = root_mcs,
any representative (including what ofAntisymmetrization returns) has this MCS.
-/
theorem timelineQuotMCS_root_time_eq :
    timelineQuotMCS root_mcs root_mcs_proof (rootTime root_mcs root_mcs_proof) = root_mcs := by
  haveI : IsPreorder (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    denseTimelineElemIsPreorder root_mcs root_mcs_proof
  simp only [timelineQuotMCS, rootTime]
  -- ofAntisymmetrization returns a representative of the equivalence class
  -- We need to show its MCS equals rootTimelineElem's MCS (which is root_mcs)
  set root_elem := rootTimelineElem root_mcs root_mcs_proof with h_root_elem
  set rep := ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) root_elem) with h_rep
  -- rep is in the same equivalence class as root_elem
  have h_class : toAntisymmetrization (· ≤ ·) rep = toAntisymmetrization (· ≤ ·) root_elem :=
    toAntisymmetrization_ofAntisymmetrization (· ≤ ·) (toAntisymmetrization (· ≤ ·) root_elem)
  -- Extract the ≤ relationships from being in the same class
  have h_rep_le_root : rep ≤ root_elem := by
    rw [← toAntisymmetrization_le_toAntisymmetrization_iff, h_class]
  have h_root_le_rep : root_elem ≤ rep := by
    rw [← toAntisymmetrization_le_toAntisymmetrization_iff, ← h_class]
  -- By mutual_le_implies_mcs_eq, their MCSs are equal
  have h_mcs_eq := denseTimelineElem_mutual_le_implies_mcs_eq root_mcs root_mcs_proof
    rep root_elem h_rep_le_root h_root_le_rep
  -- root_elem.1.mcs = root_mcs by definition
  have h_root : root_elem.1.mcs = root_mcs := rfl
  -- Combine
  exact h_mcs_eq.trans h_root

/--
**DEPRECATED**: Use `timelineQuotMCS_root_time_eq` with `rootTime` instead.

The claim that the AddCommGroup zero equals root_mcs is NOT necessarily true
because the Cantor isomorphism is non-constructive and arbitrary.
-/
theorem timelineQuotMCS_at_zero_eq_root :
    timelineQuotMCS root_mcs root_mcs_proof 0 = root_mcs := by
  -- This theorem is likely false as stated.
  -- The 0 element is ratOrderIso.symm 0 where ratOrderIso is an arbitrary Cantor isomorphism.
  -- Instead, use rootTime and timelineQuotMCS_root_time_eq.
  sorry  -- Intentionally left as sorry - use timelineQuotMCS_root_time_eq instead

end Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
