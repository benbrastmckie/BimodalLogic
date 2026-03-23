import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Bundle.CanonicalFrame

/-!
# ExistsTask Recovery from CanonicalTask

This module establishes relationships between the duration-agnostic `ExistsTask`
relation and the duration-precise `CanonicalTask` relation built from Succ-chains.

## Two-Level Abstraction

- **CanonicalTask** (Layer 1): Duration-precise primitive built from Succ-chains.
  Used for TaskFrame axiom proofs and F-nesting depth bounds.
- **ExistsTask** (Layer 2): Duration-agnostic derived relation (`g_content M ⊆ M'`).
  Used for transitivity chains, Preorder definitions, and backward compatibility.

## Main Theorems

### Forward Direction (CanonicalTask -> ExistsTask)
- `canonicalTask_forward_MCS_implies_canonicalR`: MCS-annotated chain implies ExistsTask
- `Succ_chain_implies_canonicalR`: Plain Succ + ExistsTask transitivity

### Backward Direction (ExistsTask -> CanonicalTask)
- `canonicalR_implies_canonicalTask_forward`: sorry pending full construction

### Backward-Compatibility Layer
- `canonical_forward_G_from_task`: G-forward via CanonicalTask (n >= 1)
- `canonical_forward_G_from_succ`: G-forward via single Succ step
- `canonical_forward_F_with_canonicalR`: F-forward with ExistsTask witness (re-export)
- `successor_from_seriality`: Successor existence (re-export)

## References

- Task 13 research report: 01_canonicalr-recovery-analysis.md
- CanonicalFrame.lean: ExistsTask definition and key theorems
- CanonicalTaskRelation.lean: CanonicalTask definition and TaskFrame axioms
- SuccRelation.lean: Succ relation and single-step forcing
- SuccExistence.lean: Successor and predecessor existence theorems
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Phase 2: Forward Direction (CanonicalTask implies ExistsTask)

Every forward Succ-chain of length >= 1 implies ExistsTask. Since each Succ step
includes `g_content u ⊆ v` as its first condition (which IS ExistsTask), and
ExistsTask is transitive (via temp_4), the forward direction follows by induction.

We use `CanonicalTask_forward_MCS` which carries MCS proofs for all intermediate
worlds, enabling the use of `canonicalR_transitive` at each step.

**Note on reflexivity**: The temporal order is strict (irreflexive), so
`ExistsTask u u` (g_content u ⊆ u) does NOT hold in general. In particular,
`G phi in u` does NOT imply `phi in u`. Therefore the forward direction only
gives ExistsTask for chains of length >= 1 (where at least one Succ step occurs).
For n = 0, we get identity (u = v) instead.
-/

/--
Forward direction (MCS-annotated version): A forward MCS-chain implies ExistsTask
or identity.

For n = 0: u = v (identity).
For n >= 1: Each Succ step gives ExistsTask via its first condition, and
canonicalR_transitive chains them together.
-/
theorem canonicalTask_forward_MCS_implies_canonicalR
    {u v : Set Formula} {n : Nat}
    (h_task : CanonicalTask_forward_MCS u n v) :
    u = v ∨ ExistsTask u v := by
  induction h_task with
  | base _ => exact Or.inl rfl
  | step h_mcs_u _ h_succ _ ih =>
    have h_R_uw : ExistsTask _ _ := h_succ.1
    rcases ih with rfl | h_R_wv
    · exact Or.inr h_R_uw
    · exact Or.inr (canonicalR_transitive _ _ _ h_mcs_u h_R_uw h_R_wv)

/--
Single Succ step implies ExistsTask. Convenience re-export.
-/
theorem Succ_to_CanonicalR {u v : Set Formula} (h : Succ u v) :
    ExistsTask u v :=
  Succ_implies_CanonicalR u v h

/--
Forward chain of length 1 implies ExistsTask.

When a chain has exactly 1 step, it is a single Succ, which directly gives ExistsTask.
-/
theorem canonicalTask_forward_one_implies_canonicalR
    {u v : Set Formula}
    (h_task : CanonicalTask_forward u 1 v) :
    ExistsTask u v := by
  obtain ⟨w, h_succ, h_base⟩ := CanonicalTask_forward.step_inv h_task
  cases h_base with
  | base => exact Succ_implies_CanonicalR u v h_succ

/--
Forward chain of any length >= 1 with MCS annotations implies ExistsTask.

This eliminates the identity disjunct from `canonicalTask_forward_MCS_implies_canonicalR`
for chains of positive length. Even if the chain loops back to u = v, at least one
Succ step occurred, giving ExistsTask u w for some w, and transitivity gives ExistsTask u v.
-/
theorem canonicalTask_forward_MCS_pos_implies_canonicalR
    {u v : Set Formula} {n : Nat}
    (h_pos : n ≥ 1)
    (h_task : CanonicalTask_forward_MCS u n v) :
    ExistsTask u v := by
  -- Extract the first step
  have h_n : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  obtain ⟨k, rfl⟩ := h_n
  obtain ⟨w, h_mcs_u, h_mcs_w, h_succ, h_chain⟩ := CanonicalTask_forward_MCS.step_inv h_task
  have h_R_uw : ExistsTask u w := Succ_implies_CanonicalR u w h_succ
  rcases canonicalTask_forward_MCS_implies_canonicalR h_chain with rfl | h_R_wv
  · exact h_R_uw
  · exact canonicalR_transitive u w v h_mcs_u h_R_uw h_R_wv

/-!
## Phase 3: Backward Direction (ExistsTask implies CanonicalTask)

The backward direction states: if ExistsTask u v (i.e., g_content u ⊆ v),
then there exists a Succ-chain from u to v.

This is significantly harder because ExistsTask only guarantees g_content
propagation, while Succ additionally requires the f_content step condition.
The construction requires:
1. Using successor_exists to build intermediate MCS worlds
2. Showing that eventually the chain reaches v
3. Bounding the chain length by F-nesting depth

This is left as sorry pending the full bounded witness construction.
-/

/--
Backward direction: ExistsTask implies existence of a forward CanonicalTask chain.

**Status**: sorry - requires decomposition of g_content subset into Succ steps.

The full proof requires:
1. `successor_exists` to construct each intermediate world
2. A convergence argument showing the chain eventually reaches v
3. F-nesting depth bounds for termination

The key difficulty is that ExistsTask (g_content u ⊆ v) does not directly
give a Succ step because Succ also requires the f_content condition.
-/
theorem canonicalR_implies_canonicalTask_forward
    {u v : Set Formula}
    (h_mcs_u : SetMaximalConsistent u)
    (h_mcs_v : SetMaximalConsistent v)
    (h_R : ExistsTask u v) :
    ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward u n v := by
  sorry

/-!
## Phase 4: Backward-Compatibility Layer

These theorems provide a bridge between CanonicalTask chains and the existing
canonical model API based on ExistsTask.

**Important**: The temporal order is strict (irreflexive), so `G phi in M` does
NOT imply `phi in M`. The G-forward property only holds for chains of length >= 1
(i.e., when we actually move to a different/successor world).
-/

/--
G-forward property via single Succ step.

If Succ M M' and G(phi) in M, then phi in M'. This is immediate since
Succ implies ExistsTask, and canonical_forward_G applies.
-/
theorem canonical_forward_G_from_succ
    {M M' : Set Formula}
    (h_succ : Succ M M')
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    phi ∈ M' :=
  canonical_forward_G M M' (Succ_implies_CanonicalR M M' h_succ) phi h_G

/--
G-forward property via CanonicalTask MCS-chain of length >= 1.

If we have a forward MCS-chain from M to M' of positive length and G(phi)
is in M, then phi is in M'.

**Requires n >= 1**: For n = 0, M = M' and G phi in M does NOT imply phi in M
(the temporal order is strict/irreflexive).
-/
theorem canonical_forward_G_from_task
    {M M' : Set Formula} {n : Nat}
    (h_pos : n ≥ 1)
    (h_task : CanonicalTask_forward_MCS M n M')
    (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    phi ∈ M' := by
  have h_R := canonicalTask_forward_MCS_pos_implies_canonicalR h_pos h_task
  exact canonical_forward_G M M' h_R phi h_G

/--
F-forward property with ExistsTask witness.

If F(psi) is in MCS M, then there exists an MCS W such that ExistsTask M W
and psi is in W. This is a re-export of the existing `canonical_forward_F`
for use in the recovery module.
-/
theorem canonical_forward_F_with_canonicalR
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ ExistsTask M W ∧ psi ∈ W :=
  canonical_forward_F M h_mcs psi h_F

/--
Successor existence from seriality.

If F(top) is in MCS M, there exists an MCS W with Succ M W.
This is a re-export of `successor_exists` for use in the recovery module.
-/
theorem successor_from_seriality
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ Succ M W :=
  successor_exists M h_mcs h_F_top

/-!
## Equivalence Summary

The relationship between ExistsTask and CanonicalTask is:

**Forward (proven)**: `CanonicalTask_forward_MCS u n v → (u = v ∨ ExistsTask u v)`
  For n >= 1: `CanonicalTask_forward_MCS u n v → ExistsTask u v`

**Backward (sorry)**: `ExistsTask u v → ∃ n ≥ 1, CanonicalTask_forward u n v`
  Requires constructing a Succ-chain from g_content inclusion.

**Practical Impact**: The forward direction is the more commonly needed one,
since CanonicalTask chains are constructed explicitly in the discrete completeness
proof, and one often needs to derive ExistsTask from them for use with existing
lemmas (Preorder instance, parametric canonical model, etc.).
-/

end Bimodal.Metalogic.Bundle
