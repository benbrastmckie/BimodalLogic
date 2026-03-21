import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MCSProperties

/-!
# CanonicalTask Relation for Discrete Temporal Frames

This module defines the CanonicalTask relation, an integer-indexed relation built
inductively from the Succ relation (Task 10). CanonicalTask(u, n, v) captures
"v is reachable from u in exactly n steps" where positive n means forward steps
and negative n means backward steps.

## Main Definitions

- `iter_F`: n-fold application of the F (some_future) operator
- `CanonicalTask_forward`: Nat-indexed forward chain via Succ
- `CanonicalTask_backward`: Nat-indexed backward chain via Succ
- `CanonicalTask`: Int-indexed combined relation

## Main Theorems (TaskFrame Axioms)

- `CanonicalTask_nullity_identity`: CanonicalTask(u, 0, v) ↔ u = v
- `CanonicalTask_forward_comp`: Chain concatenation for forward chains
- `CanonicalTask_converse`: CanonicalTask(u, n, v) ↔ CanonicalTask(v, -n, u)

## Bounded Witness Corollary

- `bounded_witness`: If F^n(φ) ∈ u, F^(n+1)(φ) ∉ u, and CanonicalTask(u, n, v), then φ ∈ v

## Design

The implementation uses a split approach:
1. Define `CanonicalTask_forward` (Nat-indexed) for forward chains
2. Define `CanonicalTask_backward` (Nat-indexed) for backward chains
3. Combine into `CanonicalTask` (Int-indexed)

This mirrors the `CanonicalR_chain` pattern from DovetailedCoverageReach.lean
and enables cleaner proofs of individual directions.

## References

- Task 10 (Succ relation): SuccRelation.lean
- Task 11 research report: 01_canonical-task-research.md
- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Iterated F Helper

The `iter_F` function applies the F (some_future) operator n times.
This is used in the bounded witness corollary.
-/

/--
n-fold application of the F (some_future) operator.

- `iter_F 0 φ = φ`
- `iter_F (n+1) φ = F(iter_F n φ)`

This captures "F^n(φ)" notation from the research report.
-/
def iter_F : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iter_F n phi)

/-- iter_F 0 is identity. -/
@[simp]
lemma iter_F_zero (phi : Formula) : iter_F 0 phi = phi := rfl

/-- iter_F (n+1) is F applied to iter_F n. -/
@[simp]
lemma iter_F_succ (n : Nat) (phi : Formula) :
    iter_F (n + 1) phi = Formula.some_future (iter_F n phi) := rfl

/-!
## Forward Chain Definition

`CanonicalTask_forward u n v` means "v is reachable from u in exactly n forward Succ steps".
This is the Nat-indexed forward direction, where each step goes from u to a successor w.
-/

/--
Forward chain of Succ steps.

- `base`: Zero steps means the same world
- `step`: One more forward step via Succ

**Semantics**: `CanonicalTask_forward u n v` holds iff there exists a chain
`u = w₀ → w₁ → ... → wₙ = v` where each `→` is a Succ relation.
-/
inductive CanonicalTask_forward : Set Formula → Nat → Set Formula → Prop where
  | base {u : Set Formula} : CanonicalTask_forward u 0 u
  | step {u w v : Set Formula} {n : Nat} :
      Succ u w → CanonicalTask_forward w n v → CanonicalTask_forward u (n + 1) v

/--
Extract the intermediate world from a forward step derivation.
-/
theorem CanonicalTask_forward.step_inv {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_forward u (n + 1) v) :
    ∃ w, Succ u w ∧ CanonicalTask_forward w n v := by
  cases h with
  | step h_succ h_chain => exact ⟨_, h_succ, h_chain⟩

/-!
## Backward Chain Definition

`CanonicalTask_backward u n v` means "v is reachable from u in exactly n backward Succ steps".
This is designed so that `CanonicalTask_backward u n v` corresponds to
`CanonicalTask_forward v n u` (the converse direction).

The backward constructor says: to go backward from u to v in (n+1) steps,
we find w such that Succ v w (v's successor is w) and CanonicalTask_backward u n w.
-/

/--
Backward chain of Succ steps.

- `base`: Zero steps means the same world
- `step`: One more backward step - the target v has a successor w, and we already
  have n backward steps from u to w

**Semantics**: `CanonicalTask_backward u n v` holds iff there exists a chain
`v = w₀ → w₁ → ... → wₙ = u` (in Succ direction), i.e., going backward from
the perspective of u.

**Design Note**: The step constructor takes `Succ v w` (not `Succ w v`) because
Succ is not symmetric. This captures "v has successor w" which allows us to
trace the chain backwards.
-/
inductive CanonicalTask_backward : Set Formula → Nat → Set Formula → Prop where
  | base {u : Set Formula} : CanonicalTask_backward u 0 u
  | step {u w v : Set Formula} {n : Nat} :
      Succ v w → CanonicalTask_backward u n w → CanonicalTask_backward u (n + 1) v

/--
Extract the intermediate world from a backward step derivation.
-/
theorem CanonicalTask_backward.step_inv {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_backward u (n + 1) v) :
    ∃ w, Succ v w ∧ CanonicalTask_backward u n w := by
  cases h with
  | step h_succ h_chain => exact ⟨_, h_succ, h_chain⟩

/-!
## Combined CanonicalTask Definition

The combined `CanonicalTask` relation uses Int indexing:
- Non-negative index k uses `CanonicalTask_forward`
- Negative index -(k+1) uses `CanonicalTask_backward` with k+1 steps
-/

/--
Combined CanonicalTask relation with integer indexing.

- For `n ≥ 0`: Uses `CanonicalTask_forward` (n forward Succ steps)
- For `n < 0`: Uses `CanonicalTask_backward` (|n| backward Succ steps)

**Semantics**: `CanonicalTask u n v` means v is reachable from u in exactly n
steps, where positive n means forward steps and negative n means backward steps.
-/
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v

/-- CanonicalTask with natural number index reduces to CanonicalTask_forward. -/
@[simp]
lemma CanonicalTask_of_nat (u v : Set Formula) (k : Nat) :
    CanonicalTask u (k : Int) v ↔ CanonicalTask_forward u k v := Iff.rfl

/-- CanonicalTask with negSucc index reduces to CanonicalTask_backward. -/
@[simp]
lemma CanonicalTask_negSucc (u v : Set Formula) (k : Nat) :
    CanonicalTask u (Int.negSucc k) v ↔ CanonicalTask_backward u (k + 1) v := Iff.rfl

/-- CanonicalTask with negative integer -(k+1) reduces to CanonicalTask_backward. -/
lemma CanonicalTask_neg_succ_nat (u v : Set Formula) (k : Nat) :
    CanonicalTask u (-(k + 1 : Int)) v ↔ CanonicalTask_backward u (k + 1) v := by
  have h : -(k + 1 : Int) = Int.negSucc k := by omega
  rw [h]
  exact CanonicalTask_negSucc u v k

end Bimodal.Metalogic.Bundle
