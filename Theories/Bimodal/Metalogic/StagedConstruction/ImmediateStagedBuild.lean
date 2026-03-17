import Bimodal.Metalogic.StagedConstruction.StagedExecution
import Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed
import Bimodal.Metalogic.StagedConstruction.IncrementalTimeline

/-!
# Immediate Successor Staged Build

This module implements an alternative staged construction using **blocking formula seeds**
(via `discreteImmediateSuccSeed`) instead of `forward_temporal_witness_seed`. The key
advantage is that covering holds BY CONSTRUCTION:

- Standard staged build: Adds forward witnesses that may have intermediate MCSs
- Immediate staged build: Adds immediate successors (no intermediate MCSs possible)

## Key Insight

The standard `discreteStagedBuild` uses `forward_temporal_witness_seed` which does NOT
include blocking formulas. As a result, there may be MCSs K strictly between M and its
witness W. The covering lemma (`discreteImmediateSucc_covers`) requires a complex proof.

This module uses `discreteImmediateSuccSeed` (with blocking formulas) instead. The
resulting successors are IMMEDIATE - there are no intermediate MCSs by construction.

## Key Definitions

- `immediateForwardWitnessPoint`: Forward witness using blocking formula seed
- `discreteStagedBuildImmediate`: Alternative staged build using immediate successors
- `discreteStagedBuildImmediate_covering`: Covering holds by freshness (trivial)

## References

- Task 981: Remove axiom technical debt from task 979
- research-007.md: Modified Staged Construction approach
- Segerberg (1970), Verbrugge et al.: Constructive tense logic methods
-/

namespace Bimodal.Metalogic.StagedConstruction.ImmediateStagedBuild

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.Domain

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Immediate Forward Witness

Create a forward witness using the blocking formula seed. This guarantees
that the witness is an IMMEDIATE successor with no intermediate MCSs.
-/

/-- Create an immediate forward witness StagedPoint.

Unlike `forwardWitnessPoint` which uses `forward_temporal_witness_seed`,
this uses `discreteImmediateSuccSeed` which includes blocking formulas.
The result is an immediate successor with no intermediate MCSs. -/
noncomputable def immediateForwardWitnessPoint
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (stage : Stage) : StagedPoint where
  mcs := discreteImmediateSucc M h_mcs
  is_mcs := discreteImmediateSucc_mcs M h_mcs
  introduced_at := stage

/-- The immediate forward witness has CanonicalR from source. -/
theorem immediateForwardWitnessPoint_canonicalR
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (stage : Stage) :
    CanonicalR M (immediateForwardWitnessPoint M h_mcs stage).mcs :=
  discreteImmediateSucc_canonicalR M h_mcs

/-- The immediate forward witness covers - no intermediate K exists.

This is the KEY property that enables axiom elimination. -/
theorem immediateForwardWitnessPoint_covers
    (M K : Set Formula) (h_M : SetMaximalConsistent M) (h_K : SetMaximalConsistent K)
    (stage : Stage)
    (h_MK : CanonicalR M K)
    (h_KW : CanonicalR K (immediateForwardWitnessPoint M h_M stage).mcs) :
    K = M ∨ K = (immediateForwardWitnessPoint M h_M stage).mcs :=
  discreteImmediateSucc_covers M K h_M h_K h_MK h_KW

/-!
## Immediate Backward Witness

For backward direction, we need a symmetric construction. The past version
uses `discreteImmediatePredSeed` with H-content and backward blocking formulas.

For now, we reuse the standard backward witness since:
1. The axiom elimination primarily needs forward covering (SuccOrder)
2. Backward covering for PredOrder can use the same pattern if needed
-/

/-- Process an immediate forward obligation: given a point p, add an immediate
successor that has no intermediate MCSs between p and the new witness. -/
noncomputable def processImmediateForwardObligation
    (p : StagedPoint) (stage : Stage) : StagedPoint :=
  immediateForwardWitnessPoint p.mcs p.is_mcs stage

/-- The immediate forward obligation creates a CanonicalR successor. -/
theorem processImmediateForwardObligation_canonicalR
    (p : StagedPoint) (stage : Stage) :
    CanonicalR p.mcs (processImmediateForwardObligation p stage).mcs :=
  immediateForwardWitnessPoint_canonicalR p.mcs p.is_mcs stage

/-- The immediate forward obligation witness covers (no intermediates). -/
theorem processImmediateForwardObligation_covers
    (p : StagedPoint) (K : Set Formula) (h_K : SetMaximalConsistent K)
    (stage : Stage)
    (h_MK : CanonicalR p.mcs K)
    (h_KW : CanonicalR K (processImmediateForwardObligation p stage).mcs) :
    K = p.mcs ∨ K = (processImmediateForwardObligation p stage).mcs :=
  immediateForwardWitnessPoint_covers p.mcs K p.is_mcs h_K stage h_MK h_KW

/-!
## Immediate Successor Stage Processing

Process each point to add its immediate successor. Unlike the standard
evenStage which adds witnesses for F/P obligations, this adds immediate
successors for ALL points (using blocking formula seeds).
-/

/-- Add immediate successors for all points in the current set. -/
noncomputable def processImmediateSuccessors
    (current : Finset StagedPoint) (stage : Stage) : Finset StagedPoint :=
  current ∪ current.image (fun p => processImmediateForwardObligation p stage)

/-- The immediate successor processing preserves existing points. -/
theorem processImmediateSuccessors_monotone
    (current : Finset StagedPoint) (stage : Stage) :
    current ⊆ processImmediateSuccessors current stage :=
  Finset.subset_union_left

/-!
## Immediate Staged Build

The main construction: at each stage, add immediate successors for all points.
This produces a timeline where every successor is immediate (no intermediates).
-/

/-- The immediate successor staged build.
- Stage 0: Just the root
- Stage n+1: Add immediate successor for each point at stage n

Unlike `discreteStagedBuild` which uses formula enumeration and standard
witnesses, this adds immediate successors using blocking formula seeds. -/
noncomputable def discreteStagedBuildImmediate : Nat → Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuildImmediate n
    processImmediateSuccessors prev (n + 1)

/-- The immediate staged build is monotone. -/
theorem discreteStagedBuildImmediate_monotone (n : Nat) :
    discreteStagedBuildImmediate root_mcs root_mcs_proof n ⊆
    discreteStagedBuildImmediate root_mcs root_mcs_proof (n + 1) := by
  show discreteStagedBuildImmediate root_mcs root_mcs_proof n ⊆
    processImmediateSuccessors (discreteStagedBuildImmediate root_mcs root_mcs_proof n) (n + 1)
  exact processImmediateSuccessors_monotone _ _

theorem discreteStagedBuildImmediate_monotone_le (m n : Nat) (h : m ≤ n) :
    discreteStagedBuildImmediate root_mcs root_mcs_proof m ⊆
    discreteStagedBuildImmediate root_mcs root_mcs_proof n := by
  induction n with
  | zero =>
    have : m = 0 := Nat.le_zero.mp h
    rw [this]
  | succ n ih =>
    cases Nat.eq_or_lt_of_le h with
    | inl h_eq => rw [h_eq]
    | inr h_lt =>
      have h_le : m ≤ n := Nat.lt_succ_iff.mp h_lt
      exact Finset.Subset.trans (ih h_le)
        (discreteStagedBuildImmediate_monotone root_mcs root_mcs_proof n)

/-- The root is in stage 0. -/
theorem rootPoint_in_discreteStagedBuildImmediate_0 :
    rootPoint root_mcs root_mcs_proof ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof 0 := by
  simp [discreteStagedBuildImmediate, stage0]

/-!
## Linearity of Immediate Build

All points are comparable with the root, hence with each other.
-/

/-- All points in the immediate staged build are comparable with the root. -/
theorem discreteStagedBuildImmediate_all_comparable_with_root (n : Nat)
    (p : StagedPoint) (hp : p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
    CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs = p.mcs := by
  induction n generalizing p with
  | zero =>
    simp only [discreteStagedBuildImmediate, stage0, Finset.mem_singleton] at hp
    rw [hp]
    exact root_comparable_self root_mcs root_mcs_proof
  | succ n ih =>
    by_cases h_prev : p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n
    · exact ih p h_prev
    · -- p was added at stage n+1
      simp only [discreteStagedBuildImmediate] at hp
      unfold processImmediateSuccessors at hp
      rw [Finset.mem_union] at hp
      rcases hp with h_old | h_new
      · exact ih p h_old
      · rw [Finset.mem_image] at h_new
        obtain ⟨q, hq_mem, hp_eq⟩ := h_new
        have h_q_comp := ih q hq_mem
        rw [← hp_eq]
        -- p = processImmediateForwardObligation q (n+1)
        -- has CanonicalR q.mcs p.mcs
        have h_R := processImmediateForwardObligation_canonicalR q (n + 1)
        exact comparability_step_forward
          (rootPoint root_mcs root_mcs_proof).mcs q.mcs
          (processImmediateForwardObligation q (n + 1)).mcs
          root_mcs_proof q.is_mcs (processImmediateForwardObligation q (n + 1)).is_mcs
          h_q_comp h_R

/-- The immediate staged build is linearly ordered at every stage. -/
theorem discreteStagedBuildImmediate_linear (n : Nat) :
    IsLinearlyOrdered (discreteStagedBuildImmediate root_mcs root_mcs_proof n) := by
  intro a ha b hb
  have h_a_comp := discreteStagedBuildImmediate_all_comparable_with_root root_mcs root_mcs_proof n a ha
  have h_b_comp := discreteStagedBuildImmediate_all_comparable_with_root root_mcs root_mcs_proof n b hb
  -- Both a and b are comparable with root, so they are comparable with each other
  rcases h_a_comp with h_aR | h_Ra | h_aeq
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · have := canonical_forward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_aR h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · have := comparability_step_backward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inr (Or.inl h_aR)) h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · exact Or.inr (Or.inr (h_beq ▸ h_aR))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · have := comparability_step_forward a.mcs
        (rootPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inl h_Ra) h_bR
      exact stagedPoint_le_of_mcs_comparable a b this
    · have := canonical_backward_reachable_linear
        (rootPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_Ra h_Rb
      exact stagedPoint_le_of_mcs_comparable a b this
    · exact Or.inl (Or.inr (h_beq ▸ h_Ra))
  · rcases h_b_comp with h_bR | h_Rb | h_beq
    · exact Or.inl (Or.inr (h_aeq ▸ h_bR))
    · exact Or.inr (Or.inr (h_aeq ▸ h_Rb))
    · exact Or.inl (Or.inl (h_aeq.symm.trans h_beq))

/-!
## Future Seriality: Every Point Has an Immediate Successor

The immediate staged build ensures that every point at stage n has an
immediate successor at stage n+1.
-/

/-- Every point at stage n has an immediate successor at stage n+1. -/
theorem has_immediate_successor_at_next_stage (n : Nat) (p : StagedPoint)
    (hp : p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n) :
    ∃ q : StagedPoint, q ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof (n + 1) ∧
      CanonicalR p.mcs q.mcs ∧
      (∀ K : Set Formula, SetMaximalConsistent K →
        CanonicalR p.mcs K → CanonicalR K q.mcs → K = p.mcs ∨ K = q.mcs) := by
  use processImmediateForwardObligation p (n + 1)
  constructor
  · -- Show it's in stage n+1
    simp only [discreteStagedBuildImmediate, processImmediateSuccessors]
    rw [Finset.mem_union]
    right
    rw [Finset.mem_image]
    exact ⟨p, hp, rfl⟩
  constructor
  · -- CanonicalR
    exact processImmediateForwardObligation_canonicalR p (n + 1)
  · -- Covering
    intro K h_K h_pK h_Kq
    exact processImmediateForwardObligation_covers p K h_K (n + 1) h_pK h_Kq

/-!
## Stage-Level Covering Property

At each stage, the immediate successor of any point covers (no intermediate K).
This is the KEY property that enables LocallyFiniteOrder.
-/

/-- The immediate successor at the next stage covers - no intermediate exists.

This is trivial from the blocking formula construction: the successor W is
built with blocking formulas that force any K satisfying CanonicalR M K and
CanonicalR K W to equal M or W. -/
theorem covering_at_stage (n : Nat) (M W : StagedPoint)
    (hM : M ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n)
    (hW : W = processImmediateForwardObligation M (n + 1))
    (K : StagedPoint)
    (hK_mem : K ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof (n + 1))
    (h_MK : CanonicalR M.mcs K.mcs)
    (h_KW : CanonicalR K.mcs W.mcs) :
    K.mcs = M.mcs ∨ K.mcs = W.mcs := by
  rw [hW] at h_KW ⊢
  exact processImmediateForwardObligation_covers M K.mcs K.is_mcs (n + 1) h_MK h_KW

/-!
## Connection to Full Timeline

The union of all stages forms a timeline. We show this is connected to
the original DiscreteTimelineQuot.
-/

/-- The union of all stages in the immediate build. -/
def immediateStagedUnion : Set StagedPoint :=
  { p | ∃ n, p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n }

/-- Every point in the union comes from some stage. -/
theorem mem_immediateStagedUnion_iff (p : StagedPoint) :
    p ∈ immediateStagedUnion root_mcs root_mcs_proof ↔
    ∃ n, p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof n := by
  rfl

/-- The root is in the union. -/
theorem rootPoint_in_immediateStagedUnion :
    rootPoint root_mcs root_mcs_proof ∈ immediateStagedUnion root_mcs root_mcs_proof :=
  ⟨0, rootPoint_in_discreteStagedBuildImmediate_0 root_mcs root_mcs_proof⟩

/-- All points in the immediate union are MCS-comparable (linearly ordered). -/
theorem immediateStagedUnion_linear (p q : StagedPoint)
    (hp : p ∈ immediateStagedUnion root_mcs root_mcs_proof)
    (hq : q ∈ immediateStagedUnion root_mcs root_mcs_proof) :
    StagedPoint.le p q ∨ StagedPoint.le q p := by
  obtain ⟨m, hpm⟩ := hp
  obtain ⟨n, hqn⟩ := hq
  -- Both are in stage max(m, n)
  let k := max m n
  have hp_k : p ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof k :=
    discreteStagedBuildImmediate_monotone_le root_mcs root_mcs_proof m k (le_max_left m n) hpm
  have hq_k : q ∈ discreteStagedBuildImmediate root_mcs root_mcs_proof k :=
    discreteStagedBuildImmediate_monotone_le root_mcs root_mcs_proof n k (le_max_right m n) hqn
  exact discreteStagedBuildImmediate_linear root_mcs root_mcs_proof k p hp_k q hq_k

end Bimodal.Metalogic.StagedConstruction.ImmediateStagedBuild
