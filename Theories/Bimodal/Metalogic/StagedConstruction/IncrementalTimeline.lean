import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed
import Bimodal.Metalogic.Domain.DiscreteTimeline
import Mathlib.Order.Antisymmetrization

/-!
# Incremental Timeline Construction

This module implements the **incremental/staged construction** approach for eliminating
the `discrete_Icc_finite_axiom`. The key insight is that covering holds BY CONSTRUCTION
when the timeline is built stage-by-stage rather than all-at-once.

## Background

The standard approach builds all MCSs simultaneously in the canonical model, then
tries to prove covering (no intermediate K between M and its successor W) post-hoc.
This fails because blocking formulas constrain W but not arbitrary intermediate K.

The incremental approach from Segerberg/Verbrugge instead builds the timeline
incrementally:
- At each stage n, define the partial timeline
- The immediate successor at stage n is a FRESH element at stage n+1
- Since K doesn't exist yet when we add the successor, covering is trivial

## Key Definitions

- `DiscreteTimelineQuot_at_stage n`: Timeline quotient at stage n
- `stage_embed`: Embedding from stage n to stage n+1
- `succ_at_stage`: Immediate successor function at each stage
- `covering_at_stage`: Covering holds trivially by freshness

## References

- Task 981: Remove axiom technical debt from task 979
- research-006.md: Incremental construction approach
- Segerberg (1970), Verbrugge et al.: Constructive tense logic methods
-/

namespace Bimodal.Metalogic.StagedConstruction.IncrementalTimeline

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.Domain

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Phase 1: Stage-Indexed Timeline Types

Define `DiscreteTimelineElem_at_stage n` and `DiscreteTimelineQuot_at_stage n`
for each construction stage. These are the partial timelines at each stage.
-/

/-- Elements of the discrete timeline at stage n.

This is the set of StagedPoints that have been added up to and including stage n
in the discrete staged build. -/
def DiscreteTimelineElem_at_stage (n : Nat) : Type :=
  { p : StagedPoint // p ∈ discreteStagedBuild root_mcs root_mcs_proof n }

/-- Preorder on stage-indexed elements (inherited from StagedPoint). -/
noncomputable instance preorder_at_stage (n : Nat) :
    Preorder (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) where
  le a b := StagedPoint.le a.1 b.1
  le_refl a := StagedPoint.le_refl a.1
  le_trans a b c hab hbc := StagedPoint.le_trans a.1 b.1 c.1 hab hbc

/-- The preorder at each stage is total (inherited from discreteStagedBuild_linear). -/
instance isTotal_at_stage (n : Nat) :
    IsTotal (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) (· ≤ ·) where
  total a b := discreteStagedBuild_linear root_mcs root_mcs_proof n a.1 a.2 b.1 b.2

/-- Decidable ≤ at each stage. -/
noncomputable instance decidableLE_at_stage (n : Nat) :
    DecidableLE (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) :=
  fun _ _ => Classical.propDecidable _

/-- Decidable < at each stage. -/
noncomputable instance decidableLT_at_stage (n : Nat) :
    DecidableLT (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) :=
  fun _ _ => Classical.propDecidable _

/-- The discrete timeline quotient at stage n: antisymmetrization of elements at stage n. -/
def DiscreteTimelineQuot_at_stage (n : Nat) : Type :=
  Antisymmetrization (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) (· ≤ ·)

/-- IsPreorder instance needed for Antisymmetrization lemmas. -/
noncomputable instance isPreorder_at_stage (n : Nat) :
    IsPreorder (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) (· ≤ ·) where
  refl := fun a => StagedPoint.le_refl a.1
  trans := fun a b c hab hbc => StagedPoint.le_trans a.1 b.1 c.1 hab hbc

/-- Linear order on the stage-indexed quotient. -/
noncomputable instance linearOrder_at_stage (n : Nat) :
    LinearOrder (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :=
  inferInstanceAs (LinearOrder (Antisymmetrization
    (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) (· ≤ ·)))

/-- The stage-0 quotient is nonempty (contains the root). -/
instance nonempty_at_stage_0 :
    Nonempty (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof 0) := by
  have h := rootPoint_in_discreteStagedBuild_0 root_mcs root_mcs_proof
  exact ⟨toAntisymmetrization (· ≤ ·) ⟨rootPoint root_mcs root_mcs_proof, h⟩⟩

/-- Every stage is nonempty (monotonicity from stage 0). -/
instance nonempty_at_stage (n : Nat) :
    Nonempty (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) := by
  have h0 := rootPoint_in_discreteStagedBuild_0 root_mcs root_mcs_proof
  have h := discreteStagedBuild_monotone_le root_mcs root_mcs_proof 0 n (Nat.zero_le n) h0
  exact ⟨toAntisymmetrization (· ≤ ·) ⟨rootPoint root_mcs root_mcs_proof, h⟩⟩

/-!
## Helper: Extract MCS from Stage-Indexed Quotient

We need to extract the underlying MCS from a quotient element.
-/

/-- Extract a representative element from a stage-indexed quotient. -/
noncomputable def quot_rep_at_stage (n : Nat)
    (a : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :
    DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n :=
  ofAntisymmetrization (· ≤ ·) a

/-- Extract the underlying MCS from a stage-indexed quotient element. -/
noncomputable def quotMCS_at_stage (n : Nat)
    (a : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) : Set Formula :=
  (quot_rep_at_stage root_mcs root_mcs_proof n a).1.mcs

/-- The extracted MCS is indeed an MCS. -/
theorem quotMCS_at_stage_is_mcs (n : Nat)
    (a : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :
    SetMaximalConsistent (quotMCS_at_stage root_mcs root_mcs_proof n a) :=
  (quot_rep_at_stage root_mcs root_mcs_proof n a).1.is_mcs

/-- Two elements in the same equivalence class have the same MCS. -/
theorem quot_same_class_same_mcs (n : Nat)
    (p q : DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n)
    (h_pq : p ≤ q) (h_qp : q ≤ p) :
    p.1.mcs = q.1.mcs := by
  have h_pq' : StagedPoint.le p.1 q.1 := h_pq
  have h_qp' : StagedPoint.le q.1 p.1 := h_qp
  simp only [StagedPoint.le] at h_pq' h_qp'
  cases h_pq' with
  | inl h_eq => exact h_eq
  | inr h_R_pq =>
    cases h_qp' with
    | inl h_eq => exact h_eq.symm
    | inr h_R_qp =>
      -- Both CanonicalR directions hold, contradicting irreflexivity
      have h_trans := canonicalR_transitive p.1.mcs q.1.mcs p.1.mcs p.1.is_mcs h_R_pq h_R_qp
      exact absurd h_trans (Canonical.canonicalR_irreflexive p.1.mcs p.1.is_mcs)

/-!
## Finiteness at Each Stage

Each stage contains finitely many elements (discreteStagedBuild returns a Finset).
This is crucial for LocallyFiniteOrder.
-/

/-- The number of elements at stage n is finite. -/
noncomputable instance finite_at_stage (n : Nat) :
    Finite (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) := by
  -- discreteStagedBuild returns a Finset, so the subtype is finite
  have h : Finite { p : StagedPoint // p ∈ discreteStagedBuild root_mcs root_mcs_proof n } := by
    apply Set.finite_coe_iff.mpr
    exact Finset.finite_toSet (discreteStagedBuild root_mcs root_mcs_proof n)
  exact h

/-- The quotient at stage n is finite (quotient of finite set). -/
noncomputable instance finite_quot_at_stage (n : Nat) :
    Finite (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) := by
  haveI := finite_at_stage root_mcs root_mcs_proof n
  exact Quotient.finite _

/-- Convert finiteness to Fintype for concrete computation. -/
noncomputable instance fintype_at_stage (n : Nat) :
    Fintype (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) :=
  Fintype.ofFinite _

noncomputable instance fintype_quot_at_stage (n : Nat) :
    Fintype (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :=
  Fintype.ofFinite _

/-!
## LocallyFiniteOrder at Each Stage

Since each stage is finite, LocallyFiniteOrder is trivial.
-/

/-- All intervals at each stage are finite (because the whole type is finite). -/
theorem icc_finite_at_stage (n : Nat)
    (a b : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :
    (Set.Icc a b).Finite := by
  haveI := finite_quot_at_stage root_mcs root_mcs_proof n
  exact Set.toFinite _

/-- LocallyFiniteOrder instance at each stage. -/
noncomputable instance locallyFiniteOrder_at_stage (n : Nat) :
    LocallyFiniteOrder (DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :=
  LocallyFiniteOrder.ofFiniteIcc (icc_finite_at_stage root_mcs root_mcs_proof n)

/-!
## Connection to Full DiscreteTimelineQuot

Show that DiscreteTimelineQuot is the "colimit" of the stage-indexed quotients.
Each element of DiscreteTimelineQuot comes from some stage.
-/

/-- Embed stage n elements into the full timeline.

The full timeline uses StagedTimeline.union which is { p | ∃ n, p ∈ at_stage n }. -/
def embed_to_full (n : Nat)
    (p : DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) :
    DiscreteTimelineElem root_mcs root_mcs_proof :=
  ⟨p.1, ⟨n, p.2⟩⟩

/-- The embedding preserves order. -/
theorem embed_to_full_mono (n : Nat)
    (p q : DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n)
    (h : p ≤ q) :
    embed_to_full root_mcs root_mcs_proof n p ≤ embed_to_full root_mcs root_mcs_proof n q := by
  -- h : StagedPoint.le p.1 q.1
  -- Goal: StagedPoint.le (embed_to_full p).1 (embed_to_full q).1
  -- But (embed_to_full p).1 = p.1, so this is the same
  exact h

/-- IsPreorder instance for full DiscreteTimelineElem (needed for Antisymmetrization). -/
noncomputable instance isPreorder_full :
    IsPreorder (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·) where
  refl a := StagedPoint.le_refl a.1
  trans a b c hab hbc := StagedPoint.le_trans a.1 b.1 c.1 hab hbc

/-- Embed stage n quotient into the full quotient. -/
noncomputable def embed_quot_to_full (n : Nat)
    (a : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n) :
    DiscreteTimelineQuot root_mcs root_mcs_proof :=
  toAntisymmetrization (· ≤ ·)
    (embed_to_full root_mcs root_mcs_proof n (ofAntisymmetrization (· ≤ ·) a))

/-- Every element of DiscreteTimelineQuot comes from some stage. -/
theorem quot_from_stage (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    ∃ n, ∃ a' : DiscreteTimelineQuot_at_stage root_mcs root_mcs_proof n,
      embed_quot_to_full root_mcs root_mcs_proof n a' = a := by
  -- Get representative from quotient (use the full IsPreorder instance)
  haveI inst_full : IsPreorder (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·) :=
    isPreorder_full root_mcs root_mcs_proof
  let p := ofAntisymmetrization (· ≤ ·) a
  -- p.1 ∈ union = { q | ∃ n, q ∈ at_stage n }
  obtain ⟨n, hn⟩ := p.2
  -- Make the IsPreorder instance for stage n available
  haveI inst_n : IsPreorder (DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n) (· ≤ ·) :=
    isPreorder_at_stage root_mcs root_mcs_proof n
  let p' : DiscreteTimelineElem_at_stage root_mcs root_mcs_proof n := ⟨p.1, hn⟩
  use n, toAntisymmetrization (· ≤ ·) p'
  -- Need to show embed_quot_to_full n (toAnti p') = a
  -- Unfold the definition
  simp only [embed_quot_to_full, embed_to_full]

  -- Use the fact that toAnti (ofAnti x) = x for any x in the quotient
  have h_roundtrip : @toAntisymmetrization _ (· ≤ ·) inst_full p = a :=
    @toAntisymmetrization_ofAntisymmetrization _ (· ≤ ·) inst_full a

  -- Key fact: ofAnti (toAnti p') is in the same equivalence class as p'
  -- This means their underlying StagedPoints have the same ≤ relationship
  let rep := @ofAntisymmetrization _ (· ≤ ·) inst_n (@toAntisymmetrization _ (· ≤ ·) inst_n p')

  -- The key is that rep and p' are in the same quotient class
  have h_class_eq : @toAntisymmetrization _ (· ≤ ·) inst_n rep = @toAntisymmetrization _ (· ≤ ·) inst_n p' :=
    @toAntisymmetrization_ofAntisymmetrization _ (· ≤ ·) inst_n (@toAntisymmetrization _ (· ≤ ·) inst_n p')

  -- From the class equality, we can derive the AntisymmRel
  have h_class_stage : AntisymmRel (· ≤ ·) rep p' := by
    constructor
    · -- rep ≤ p' : rewrite using simp lemma then use equality
      simp only [← toAntisymmetrization_le_toAntisymmetrization_iff]
      rw [h_class_eq]
    · -- p' ≤ rep : Similarly
      simp only [← toAntisymmetrization_le_toAntisymmetrization_iff]
      rw [← h_class_eq]

  -- The stage-level equivalence gives same underlying StagedPoint properties
  -- Since rep.1 and p'.1 have StagedPoint.le in both directions (that's what ≤ means at stage level)
  -- And p'.1 = p.1 by construction
  -- embed_to_full just wraps with different membership proof, keeping the same StagedPoint
  have h_class_full : AntisymmRel (· ≤ ·)
      (embed_to_full root_mcs root_mcs_proof n rep) p := by
    constructor
    · -- embed_to_full rep ≤ p
      show StagedPoint.le _ _
      -- h_class_stage.1 is rep ≤ p' at stage level, i.e., StagedPoint.le rep.1 p'.1
      have h1 : StagedPoint.le rep.1 p'.1 := h_class_stage.1
      simp only [embed_to_full]
      -- (embed_to_full rep).1 = rep.1 and p.1 = p'.1
      exact h1
    · -- p ≤ embed_to_full rep
      show StagedPoint.le _ _
      have h2 : StagedPoint.le p'.1 rep.1 := h_class_stage.2
      simp only [embed_to_full]
      exact h2

  -- Finally, two elements in the same equivalence class have the same image under toAntisymmetrization
  rw [← h_roundtrip]
  exact Quotient.sound h_class_full

end Bimodal.Metalogic.StagedConstruction.IncrementalTimeline
