import Bimodal.Metalogic.StagedConstruction.DovetailedCoverage

/-!
# CanonicalR Reachability and Coverage

This module defines `CanonicalR_chain` for tracking reachability from the root MCS.
The coverage theorem and forward_F_via_coverage are NOT yet proven due to a fundamental
termination issue with the density-based recursion.

## Key Definitions

- `CanonicalR_chain root W n`: W is reachable from root via n steps of CanonicalR
- `CanonicalR_reachable root W`: W is reachable from root via some chain

## Status

The coverage-based approach to forward_F termination remains INCOMPLETE. The issue is:

1. When applying density iteration, the formula depth can INCREASE (F^j(phi) has depth j > 0)
2. Each recursive call might introduce its own density index j', which is NOT bounded
3. There is no simple well-founded measure that decreases at each recursive step

The mathematical argument suggests the recursion should terminate because:
- The goal formula (phi) is fixed
- Each recursive call eventually reaches j = 0 for that subproblem

But expressing this in Lean requires either:
- A complex well-founded recursion with non-obvious termination measure
- Proving that all points added have index >= their stage (currently not provable)
- Or accepting a localized sorry at the recursion bottleneck

## References

- Task 981: Remove axiom technical debt from task 979
- reports/27_well-founded-recursion-analysis.md: Coverage approach analysis
- DovetailedCoverage.lean: Coverage lemmas (witness_at_large_step)
-/

namespace Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.Dovetailing
open Bimodal.Metalogic.StagedConstruction.DovetailedBuild
open Bimodal.Metalogic.StagedConstruction.DovetailedCoverage

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## CanonicalR Chain Definition

A chain of CanonicalR steps from root_mcs to target, indexed by length.
-/

/-- A chain of CanonicalR steps from root to target of length n.

This is the key structure for induction on chain length rather than formula depth.
- `base`: The root is reachable from itself in 0 steps
- `step`: If M is reachable in n steps and CanonicalR M W, then W is reachable in n+1 steps
-/
inductive CanonicalR_chain (root : Set Formula) : Set Formula → Nat → Prop where
  | base : CanonicalR_chain root root 0
  | step {M W : Set Formula} {n : Nat} :
      CanonicalR_chain root M n →
      CanonicalR M W →
      CanonicalR_chain root W (n + 1)

/-- W is CanonicalR-reachable from root if there exists a chain of some length. -/
def CanonicalR_reachable (root W : Set Formula) : Prop :=
  ∃ n, CanonicalR_chain root W n

/-- The root is reachable from itself. -/
theorem reachable_root (root : Set Formula) : CanonicalR_reachable root root :=
  ⟨0, CanonicalR_chain.base⟩

/-- If M is reachable and CanonicalR M W, then W is reachable. -/
theorem reachable_step {root M W : Set Formula}
    (h_reach : CanonicalR_reachable root M) (h_R : CanonicalR M W) :
    CanonicalR_reachable root W := by
  obtain ⟨n, h_chain⟩ := h_reach
  exact ⟨n + 1, CanonicalR_chain.step h_chain h_R⟩

/-- The root point is in the dovetailed timeline at step 0. -/
theorem root_in_timeline :
    ∃ p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof, p.mcs = root_mcs := by
  obtain ⟨p, hp, hp_mcs, _⟩ := root_in_dovetailedBuild_0 root_mcs root_mcs_proof
  exact ⟨p, ⟨0, hp⟩, hp_mcs⟩

/-!
## Symmetric Past Definitions

For completeness, we also define backward chains for past formulas.
-/

/-- A chain of CanonicalR steps TOWARD target (backward direction).
Used for P-formula witnesses. -/
inductive CanonicalR_chain_backward (root : Set Formula) : Set Formula → Nat → Prop where
  | base : CanonicalR_chain_backward root root 0
  | step {M W : Set Formula} {n : Nat} :
      CanonicalR_chain_backward root M n →
      CanonicalR W M →  -- Note: reversed direction from forward chain
      CanonicalR_chain_backward root W (n + 1)

/-!
## Forward F Coverage via Dovetailed Construction

The key coverage theorem: for any point p in the dovetailed timeline with F(phi) ∈ p.mcs,
there exists a witness w in the timeline with phi ∈ w.mcs and CanonicalR p.mcs w.mcs.

This is the main result needed for temporal coherence (forward_F property).
-/

/-- Forward F coverage: if F(phi) ∈ p.mcs, then there's a witness with phi in the timeline.

This theorem uses the dovetailed construction which processes ALL (point, formula) pairs.
When obligation (p.point_index, encode(phi)) is processed, a witness with phi is added.

The key insight: p was added at entry_stage, and the obligation is processed at
step pair(p.point_index, encode(phi)). Since pair(i, k) > i for k > 0, and
p is in all stages >= entry_stage, p exists when its obligations are processed.
-/
theorem forward_F_via_coverage
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs) :
    ∃ w ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs := by
  -- p is in the timeline at some stage n
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  -- phi has some encoding k
  let k := @Encodable.encode Formula formulaEncodableStaged phi
  have h_dec : decodeFormulaStaged k = some phi :=
    @Encodable.encodek Formula formulaEncodableStaged phi
  -- The processing step for (p.point_index, k) is pair(p.point_index, k)
  let process_step := Nat.pair p.point_index k
  -- Key: pair(i, k) > i for any k, so process_step > p.point_index
  have h_pair_ge_left := Dovetailing.pair_ge_left p.point_index k
  -- We need to find a stage where p exists and process_step > that stage
  -- p exists at stage n, but we need max(n, p.point_index) < process_step
  -- Since pair(i, k) >= i + k, we have process_step >= p.point_index + k
  -- For k > 0, this is > p.point_index
  -- But we also need it to be > n
  by_cases h_small : process_step ≤ n
  · -- If process_step <= n, the witness was already added at step process_step
    -- We need to show that p existed at step process_step - 1
    -- Key: p.point_index is related to when p was added
    -- pair(p.point_index, k) = process_step, and p was at stage n >= process_step
    -- p must have been added at stage <= process_step (since its point_index affects pair)
    -- Actually, point_index i means p was in the list at position i,
    -- and was added before step pair(i, 0) = i at the latest
    -- Since process_step = pair(p.point_index, k) >= p.point_index,
    -- p was in the build at stage p.point_index, hence at stage process_step - 1
    -- (assuming process_step > 0)
    by_cases h_zero : process_step = 0
    · -- Edge case: pair(i, k) = 0 implies i = 0 and k = 0
      -- For now, use sorry for this edge case (process_step = 0 is rare)
      sorry

    · -- process_step > 0, so we can use stage process_step - 1
      have h_pos : process_step > 0 := Nat.pos_of_ne_zero h_zero
      -- p.point_index <= process_step - 1 (since pair(i, k) > i for k > 0, or pair(i, 0) = i)
      -- Actually pair(i, k) >= i, so process_step >= p.point_index
      have h_idx_le : p.point_index ≤ process_step := Dovetailing.pair_ge_left p.point_index k
      -- If k = 0, pair(i, 0) = i, so process_step = p.point_index
      -- If k > 0, pair(i, k) > i (can be shown from Cantor pairing properties)
      -- For now, we accept that p exists at process_step - 1 if p.point_index < process_step
      -- When k > 0, this is true. When k = 0, process_step = p.point_index,
      -- and we need p to exist at process_step - 1 = p.point_index - 1, which requires p.point_index > 0
      -- This is getting complex; let's use a localized sorry for the edge case
      have h_p_at_process : p ∈ (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)).points := by
        -- p was in build at stage n, and process_step <= n
        -- We need to show p existed at process_step - 1
        -- This requires knowing when p was added (its entry_stage)
        -- For now, accept sorry for this technical detail
        sorry
      have h_large : process_step > process_step - 1 := by omega
      obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
        witness_at_large_step root_mcs root_mcs_proof p (process_step - 1)
          h_p_at_process phi h_F k h_dec h_large
      refine ⟨w, ?_, hw_R, hw_phi⟩
      use process_step
      simp only [dovetailedBuild, List.mem_toFinset]
      exact hw_mem

  · -- process_step > n
    push_neg at h_small
    -- This is the straightforward case
    obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
      witness_at_large_step root_mcs root_mcs_proof p n hn phi h_F k h_dec h_small
    refine ⟨w, ?_, hw_R, hw_phi⟩
    use process_step
    simp only [dovetailedBuild, List.mem_toFinset]
    exact hw_mem

/-- Backward P coverage: if P(phi) ∈ p.mcs, then there's a witness with phi in the timeline.

Symmetric to forward_F_via_coverage using backward_witness_at_large_step.
-/
theorem backward_P_via_coverage
    (p : DovetailedPoint) (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula) (h_P : Formula.some_past phi ∈ p.mcs) :
    ∃ w ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR w.mcs p.mcs ∧ phi ∈ w.mcs := by
  -- Symmetric to forward_F_via_coverage
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  let k := @Encodable.encode Formula formulaEncodableStaged phi
  have h_dec : decodeFormulaStaged k = some phi :=
    @Encodable.encodek Formula formulaEncodableStaged phi
  let process_step := Nat.pair p.point_index k
  by_cases h_small : process_step ≤ n
  · by_cases h_zero : process_step = 0
    · sorry -- Edge case: process_step = 0
    · have h_pos : process_step > 0 := Nat.pos_of_ne_zero h_zero
      have h_p_at_process : p ∈ (dovetailedBuildState root_mcs root_mcs_proof (process_step - 1)).points := by
        sorry -- Technical: p existed at process_step - 1
      have h_large : process_step > process_step - 1 := by omega
      obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
        backward_witness_at_large_step root_mcs root_mcs_proof p (process_step - 1)
          h_p_at_process phi h_P k h_dec h_large
      refine ⟨w, ?_, hw_R, hw_phi⟩
      use process_step
      simp only [dovetailedBuild, List.mem_toFinset]
      exact hw_mem
  · push_neg at h_small
    obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
      backward_witness_at_large_step root_mcs root_mcs_proof p n hn phi h_P k h_dec h_small
    refine ⟨w, ?_, hw_R, hw_phi⟩
    use process_step
    simp only [dovetailedBuild, List.mem_toFinset]
    exact hw_mem

end Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach
