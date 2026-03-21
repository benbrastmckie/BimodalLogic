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

/-!
## Nullity Identity Axiom

The first TaskFrame axiom: CanonicalTask(u, 0, v) ↔ u = v.
Zero steps means staying at the same world.
-/

/--
Nullity identity for forward chains: CanonicalTask_forward u 0 v ↔ u = v.
-/
@[simp]
theorem CanonicalTask_forward_zero (u v : Set Formula) :
    CanonicalTask_forward u 0 v ↔ u = v := by
  constructor
  · intro h
    cases h with
    | base => rfl
  · intro h
    subst h
    exact CanonicalTask_forward.base

/--
Nullity identity for backward chains: CanonicalTask_backward u 0 v ↔ u = v.
-/
@[simp]
theorem CanonicalTask_backward_zero (u v : Set Formula) :
    CanonicalTask_backward u 0 v ↔ u = v := by
  constructor
  · intro h
    cases h with
    | base => rfl
  · intro h
    subst h
    exact CanonicalTask_backward.base

/--
**Nullity Identity Axiom**: CanonicalTask(u, 0, v) ↔ u = v.

This is the first of the three TaskFrame axioms. Zero steps means staying
at the same world.
-/
@[simp]
theorem CanonicalTask_nullity_identity (u v : Set Formula) :
    CanonicalTask u 0 v ↔ u = v := by
  -- 0 : Int = Int.ofNat 0
  show CanonicalTask_forward u 0 v ↔ u = v
  exact CanonicalTask_forward_zero u v

/-!
## Forward Compositionality

The second TaskFrame axiom: chain concatenation.
If we can go from u to w in m steps, and from w to v in n steps,
then we can go from u to v in m + n steps.
-/

/--
Forward compositionality for forward chains (Nat version).

Chain concatenation: if `CanonicalTask_forward u m w` and `CanonicalTask_forward w n v`,
then `CanonicalTask_forward u (m + n) v`.
-/
theorem CanonicalTask_forward_comp (u w v : Set Formula) (m n : Nat) :
    CanonicalTask_forward u m w → CanonicalTask_forward w n v → CanonicalTask_forward u (m + n) v := by
  intro h1 h2
  induction h1 with
  | base =>
    -- m = 0, so u = w, and we need CanonicalTask_forward u (0 + n) v = CanonicalTask_forward u n v
    simp only [Nat.zero_add]
    exact h2
  | step h_succ h_chain ih =>
    -- h_succ : Succ u w'
    -- h_chain : CanonicalTask_forward w' m' w (for some m' with step index m' + 1)
    -- ih : CanonicalTask_forward w n v → CanonicalTask_forward w' (m' + n) v
    -- Goal: CanonicalTask_forward u ((m' + 1) + n) v
    have h_wn := ih h2
    -- h_wn : CanonicalTask_forward w' (m' + n) v
    -- We need: CanonicalTask_forward u ((m' + 1) + n) v
    -- Note: (m' + 1) + n = (m' + n) + 1
    simp only [Nat.succ_add]
    exact CanonicalTask_forward.step h_succ h_wn

/--
Backward compositionality for backward chains (Nat version).

Chain concatenation for backward chains: if `CanonicalTask_backward u m w` and
`CanonicalTask_backward w n v`, then `CanonicalTask_backward u (m + n) v`.

The proof works by induction on the second chain. When h2 is:
- `base`: w = v, so the result is just h1 with 0 added
- `step`: We have Succ v w' and CanonicalTask_backward w k w' where n = k + 1.
  The IH gives us CanonicalTask_backward u (m + k) w' from h1 and h_chain.
  Then step gives CanonicalTask_backward u (m + k + 1) v = CanonicalTask_backward u (m + n) v.
-/
theorem CanonicalTask_backward_comp (u w v : Set Formula) (m n : Nat) :
    CanonicalTask_backward u m w → CanonicalTask_backward w n v → CanonicalTask_backward u (m + n) v := by
  intro h1 h2
  -- Induction on n, not on h2 directly
  induction n generalizing v with
  | zero =>
    -- n = 0, so CanonicalTask_backward w 0 v means w = v
    cases h2 with
    | base => simp only [Nat.add_zero]; exact h1
  | succ k ih =>
    -- n = k + 1, so we have Succ v w' and CanonicalTask_backward w k w'
    obtain ⟨w', h_succ, h_chain⟩ := CanonicalTask_backward.step_inv h2
    -- By IH: CanonicalTask_backward u (m + k) w'
    have h_mk := ih w' h_chain
    -- Apply step: Succ v w' and CanonicalTask_backward u (m + k) w'
    -- gives CanonicalTask_backward u (m + k + 1) v
    have h_eq : m + (k + 1) = (m + k) + 1 := by omega
    rw [h_eq]
    exact CanonicalTask_backward.step h_succ h_mk

/--
Forward compositionality for the combined CanonicalTask (restricted to non-negative).

For non-negative m and n:
`CanonicalTask u m w → CanonicalTask w n v → CanonicalTask u (m + n) v`
-/
theorem CanonicalTask_forward_comp_int (u w v : Set Formula) (m n : Nat) :
    CanonicalTask u (m : Int) w → CanonicalTask w (n : Int) v → CanonicalTask u ((m + n : Nat) : Int) v := by
  simp only [CanonicalTask_of_nat]
  exact CanonicalTask_forward_comp u w v m n

/-!
## Converse Theorem

The third TaskFrame axiom: CanonicalTask(u, n, v) ↔ CanonicalTask(v, -n, u).

The key insight is that forward chains from u to v in n steps correspond exactly
to backward chains from v to u in n steps. The converse theorem then follows from
the design of the forward and backward constructors.
-/

/--
Forward chain to backward chain: CanonicalTask_forward u n v → CanonicalTask_backward v n u.

Proof by induction on the forward chain:
- `base`: u = v, and CanonicalTask_backward v 0 v holds by base constructor
- `step`: Succ u w and CanonicalTask_forward w k v. By IH, CanonicalTask_backward v k w.
  We need CanonicalTask_backward v (k+1) u, which requires Succ u w' and
  CanonicalTask_backward v k w'. Since Succ u w, we have exactly what we need.
-/
theorem CanonicalTask_forward_to_backward (u v : Set Formula) (n : Nat) :
    CanonicalTask_forward u n v → CanonicalTask_backward v n u := by
  intro h
  induction h with
  | base => exact CanonicalTask_backward.base
  | step h_succ h_chain ih =>
    -- h_succ : Succ u w
    -- h_chain : CanonicalTask_forward w k v
    -- ih : CanonicalTask_backward v k w
    -- Goal: CanonicalTask_backward v (k + 1) u
    -- We need: Succ u w and CanonicalTask_backward v k w
    exact CanonicalTask_backward.step h_succ ih

/--
Backward chain to forward chain: CanonicalTask_backward u n v → CanonicalTask_forward v n u.

Proof by induction on n:
- n = 0: u = v, and CanonicalTask_forward v 0 v holds by base constructor
- n = k + 1: We have Succ v w and CanonicalTask_backward u k w.
  By IH, CanonicalTask_forward w k u.
  We need CanonicalTask_forward v (k+1) u, which requires Succ v w' and
  CanonicalTask_forward w' k u. We have Succ v w and the IH gives us exactly that.
-/
theorem CanonicalTask_backward_to_forward (u v : Set Formula) (n : Nat) :
    CanonicalTask_backward u n v → CanonicalTask_forward v n u := by
  intro h
  induction n generalizing v with
  | zero =>
    cases h with
    | base => exact CanonicalTask_forward.base
  | succ k ih =>
    obtain ⟨w, h_succ, h_chain⟩ := CanonicalTask_backward.step_inv h
    -- h_succ : Succ v w
    -- h_chain : CanonicalTask_backward u k w
    -- ih : CanonicalTask_backward u k w → CanonicalTask_forward w k u
    have h_fwd := ih w h_chain
    -- h_fwd : CanonicalTask_forward w k u
    -- Goal: CanonicalTask_forward v (k + 1) u
    exact CanonicalTask_forward.step h_succ h_fwd

/--
Forward/backward flip: CanonicalTask_forward u n v ↔ CanonicalTask_backward v n u.

This establishes the fundamental duality between forward and backward chains:
going forward from u to v in n steps is the same as going backward from v to u
in n steps.
-/
theorem CanonicalTask_forward_backward_flip (u v : Set Formula) (n : Nat) :
    CanonicalTask_forward u n v ↔ CanonicalTask_backward v n u := by
  constructor
  · exact CanonicalTask_forward_to_backward u v n
  · exact CanonicalTask_backward_to_forward v u n

/--
**Converse Theorem**: CanonicalTask(u, n, v) ↔ CanonicalTask(v, -n, u).

This is the third of the three TaskFrame axioms. Going from u to v in n steps
is equivalent to going from v to u in -n steps.

The proof works by case analysis on the sign of n:
- For n ≥ 0 (Int.ofNat k): forward u k v ↔ backward v k u ↔ forward v (-k) u (when k > 0)
- For n < 0 (Int.negSucc k): backward u (k+1) v ↔ forward v (k+1) u
-/
theorem CanonicalTask_converse (u v : Set Formula) (n : Int) :
    CanonicalTask u n v ↔ CanonicalTask v (-n) u := by
  match n with
  | Int.ofNat 0 =>
    -- n = 0, -n = 0
    -- CanonicalTask u 0 v ↔ CanonicalTask v 0 u
    -- Both reduce to forward 0, which is u = v (resp v = u)
    show CanonicalTask_forward u 0 v ↔ CanonicalTask_forward v 0 u
    simp only [CanonicalTask_forward_zero]
    constructor <;> intro h <;> exact h.symm
  | Int.ofNat (k + 1) =>
    -- n = k + 1 > 0, -n = -(k+1) = Int.negSucc k
    -- CanonicalTask u (k+1) v ↔ CanonicalTask v (-(k+1)) u
    -- CanonicalTask_forward u (k+1) v ↔ CanonicalTask_backward v (k+1) u
    show CanonicalTask_forward u (k + 1) v ↔ CanonicalTask v (-(Int.ofNat (k + 1))) u
    have h_neg : -(Int.ofNat (k + 1)) = Int.negSucc k := rfl
    rw [h_neg]
    show CanonicalTask_forward u (k + 1) v ↔ CanonicalTask_backward v (k + 1) u
    exact CanonicalTask_forward_backward_flip u v (k + 1)
  | Int.negSucc k =>
    -- n = Int.negSucc k = -(k+1) < 0, -n = k+1
    -- CanonicalTask u (Int.negSucc k) v ↔ CanonicalTask v (k+1) u
    -- CanonicalTask_backward u (k+1) v ↔ CanonicalTask_forward v (k+1) u
    show CanonicalTask_backward u (k + 1) v ↔ CanonicalTask v (-(Int.negSucc k)) u
    have h_neg : -(Int.negSucc k) = Int.ofNat (k + 1) := rfl
    rw [h_neg]
    show CanonicalTask_backward u (k + 1) v ↔ CanonicalTask_forward v (k + 1) u
    exact (CanonicalTask_forward_backward_flip v u (k + 1)).symm

/-!
## Bounded Witness Corollary

If F^n(φ) ∈ u and F^(n+1)(φ) ∉ u, and we have a forward chain of n steps from u to v,
then φ ∈ v. This generalizes `single_step_forcing` to n steps.

**Note**: The theorem requires MCS assumptions for the intermediate worlds in the chain.
In the canonical model construction, all worlds are MCS by construction, so this
requirement is always satisfied in practice.
-/

/--
Helper lemma: iter_F (k+1) is F applied to iter_F k.
-/
lemma iter_F_succ_eq (k : Nat) (phi : Formula) :
    iter_F (k + 1) phi = Formula.some_future (iter_F k phi) := rfl

/--
A forward chain with MCS witnesses at each step.
This version carries the MCS proofs for all worlds in the chain.
-/
inductive CanonicalTask_forward_MCS : Set Formula → Nat → Set Formula → Prop where
  | base {u : Set Formula} (h_mcs : SetMaximalConsistent u) :
      CanonicalTask_forward_MCS u 0 u
  | step {u w v : Set Formula} {n : Nat}
      (h_mcs_u : SetMaximalConsistent u) (h_mcs_w : SetMaximalConsistent w)
      (h_succ : Succ u w) (h_chain : CanonicalTask_forward_MCS w n v) :
      CanonicalTask_forward_MCS u (n + 1) v

/--
Extract the MCS property of the starting world from a forward MCS chain.
-/
theorem CanonicalTask_forward_MCS.start_mcs {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_forward_MCS u n v) : SetMaximalConsistent u := by
  cases h with
  | base h_mcs => exact h_mcs
  | step h_mcs_u _ _ _ => exact h_mcs_u

/--
Extract the MCS property of the ending world from a forward MCS chain.
-/
theorem CanonicalTask_forward_MCS.end_mcs {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_forward_MCS u n v) : SetMaximalConsistent v := by
  induction h with
  | base h_mcs => exact h_mcs
  | step _ _ _ _ ih => exact ih

/--
A forward MCS chain implies a regular forward chain.
-/
theorem CanonicalTask_forward_MCS.to_forward {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_forward_MCS u n v) : CanonicalTask_forward u n v := by
  induction h with
  | base _ => exact CanonicalTask_forward.base
  | step _ _ h_succ _ ih => exact CanonicalTask_forward.step h_succ ih

/--
Extract the step from a forward MCS chain.
-/
theorem CanonicalTask_forward_MCS.step_inv {u v : Set Formula} {n : Nat}
    (h : CanonicalTask_forward_MCS u (n + 1) v) :
    ∃ w, SetMaximalConsistent u ∧ SetMaximalConsistent w ∧ Succ u w ∧ CanonicalTask_forward_MCS w n v := by
  cases h with
  | step h_mcs_u h_mcs_w h_succ h_chain => exact ⟨_, h_mcs_u, h_mcs_w, h_succ, h_chain⟩

/--
Helper lemma: G(neg(iter_F k phi)) propagates through Succ to ensure F(iter_F k phi) ∉ w.

When we have GG(neg(iter_F k phi)) ∈ u and Succ u w, the G-persistence gives us
G(neg(iter_F k phi)) ∈ w, which by G_neg_implies_not_F gives F(iter_F k phi) ∉ w.
-/
lemma succ_propagates_F_not
    (u w : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_w : SetMaximalConsistent w)
    (h_succ : Succ u w) (psi : Formula)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ u) :
    Formula.some_future psi ∉ w := by
  -- FF(psi) ∉ u → neg(FF(psi)) ∈ u by negation completeness
  -- neg(FF(psi)) ∈ u → GG(neg(psi)) ∈ u by neg_FF_implies_GG_neg_in_mcs
  -- GG(neg(psi)) ∈ u → G(neg(psi)) ∈ g_content(u)
  -- G(neg(psi)) ∈ w by Succ G-persistence
  -- G(neg(psi)) ∈ w → F(psi) ∉ w by G_neg_implies_not_F

  have h_neg_FF : (Formula.some_future (Formula.some_future psi)).neg ∈ u := by
    cases SetMaximalConsistent.negation_complete h_mcs_u (Formula.some_future (Formula.some_future psi)) with
    | inl h_in => exact absurd h_in h_FF_not
    | inr h_neg => exact h_neg

  have h_GG_neg : Formula.all_future (Formula.all_future psi.neg) ∈ u :=
    neg_FF_implies_GG_neg_in_mcs u h_mcs_u psi h_neg_FF

  have h_G_neg_in_g : Formula.all_future psi.neg ∈ g_content u := h_GG_neg

  have h_G_neg_in_w : Formula.all_future psi.neg ∈ w := h_succ.1 h_G_neg_in_g

  exact G_neg_implies_not_F w h_mcs_w psi h_G_neg_in_w

/--
**Bounded Witness Corollary**: If F^n(φ) ∈ u, F^(n+1)(φ) ∉ u, and CanonicalTask_forward_MCS u n v,
then φ ∈ v.

This generalizes `single_step_forcing` from 1 step to n steps. The proof is by
induction on n:

**Base case (n = 0)**:
- iter_F 0 φ = φ ∈ u
- CanonicalTask_forward_MCS u 0 v means u = v
- So φ ∈ v

**Inductive case (n = k + 1)**:
- iter_F (k+1) φ = F(iter_F k φ) ∈ u
- iter_F (k+2) φ = F(F(iter_F k φ)) ∉ u
- CanonicalTask_forward_MCS u (k+1) v means ∃w, Succ u w ∧ CanonicalTask_forward_MCS w k v
- By single_step_forcing: iter_F k φ ∈ w
- By succ_propagates_F_not: iter_F (k+1) φ ∉ w
- By IH: φ ∈ v
-/
theorem bounded_witness
    (u v : Set Formula) (phi : Formula) (n : Nat)
    (h_Fn : iter_F n phi ∈ u)
    (h_Fn1_not : iter_F (n + 1) phi ∉ u)
    (h_task : CanonicalTask_forward_MCS u n v) :
    phi ∈ v := by
  induction n generalizing u v with
  | zero =>
    -- n = 0: iter_F 0 φ = φ ∈ u, and u = v
    cases h_task with
    | base _ => exact h_Fn
  | succ k ih =>
    -- n = k + 1
    -- iter_F (k+1) φ = F(iter_F k φ) ∈ u
    -- iter_F (k+2) φ = F(F(iter_F k φ)) ∉ u
    obtain ⟨w, h_mcs_u, h_mcs_w, h_succ, h_chain⟩ := CanonicalTask_forward_MCS.step_inv h_task

    -- Apply single_step_forcing to get iter_F k φ ∈ w
    -- h_Fn : iter_F (k+1) φ = F(iter_F k φ) ∈ u
    -- h_Fn1_not : iter_F (k+2) φ = F(F(iter_F k φ)) ∉ u
    have h_iter_k_in_w : iter_F k phi ∈ w :=
      single_step_forcing u w h_mcs_u h_mcs_w (iter_F k phi) h_Fn h_Fn1_not h_succ

    -- Show iter_F (k+1) φ ∉ w using succ_propagates_F_not
    have h_iter_k1_not_w : iter_F (k + 1) phi ∉ w :=
      succ_propagates_F_not u w h_mcs_u h_mcs_w h_succ (iter_F k phi) h_Fn1_not

    -- Apply IH
    exact ih w v h_iter_k_in_w h_iter_k1_not_w h_chain

end Bimodal.Metalogic.Bundle
