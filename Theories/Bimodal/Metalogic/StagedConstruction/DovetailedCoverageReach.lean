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

end Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach
