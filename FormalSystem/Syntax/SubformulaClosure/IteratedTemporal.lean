/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.SubformulaClosure.NestingDepth

/-!
# Iterated Temporal Operators

`iterF` and `iterP` -- the n-fold applications of the F (`someFuture`) and P (`somePast`)
operators -- together with their complexity, injectivity, nesting-depth and
closure-escape lemmas.

These are pure syntax: nothing here mentions maximal consistent sets, derivability, frame
classes, or the `Succ` relation. They were relocated verbatim from
`Metalogic/Bundle/CanonicalTaskRelation.lean`, whose bounded-witness corollary is their
original consumer, so that `Metalogic/Core/RestrictedMCS/Basic.lean` could reach them without
the `Core -> Bundle` directory import edge that relocation removed.

## Main Definitions

- `iterF`: n-fold application of the F (`someFuture`) operator
- `iterP`: n-fold application of the P (`somePast`) operator
- `closureFBound` / `closurePBound`: iteration counts past which the iterate leaves
  `closureWithNeg`

## Main Theorems

- `iter_F_injective` / `iter_P_injective`: distinct iteration counts give distinct formulas
- `iter_F_leaves_closure` / `iter_P_leaves_closure`: the iterate at the bound is outside
  `closureWithNeg`

## References

- `NestingDepth.lean`: `fNestingDepth`, `pNestingDepth`, `maxFNestingDepth`, `maxPNestingDepth`
-/

namespace FormalSystem.Syntax

open FormalSystem.Syntax

/-!
## Iterated F Helper

The `iterF` function applies the F (someFuture) operator n times.
This is used in the bounded witness corollary.
-/

/--
n-fold application of the F (someFuture) operator.

- `iterF 0 φ = φ`
- `iterF (n+1) φ = F(iterF n φ)`

This captures "F^n(φ)" notation from the research report.
-/
def iterF : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.someFuture (iterF n phi)

/-- iterF 0 is identity. -/
@[simp]
lemma iter_F_zero (phi : Formula) : iterF 0 phi = phi := rfl

/-- iterF (n+1) is F applied to iterF n. -/
@[simp]
lemma iter_F_succ (n : Nat) (phi : Formula) :
    iterF (n + 1) phi = Formula.someFuture (iterF n phi) := rfl

/-!
## iterF Complexity and Injectivity

Helper lemmas establishing that iterF produces distinct formulas with
strictly increasing complexity. These are used to prove f_nesting_boundary.
-/

/-- Complexity of someFuture: F(phi) adds 1 to complexity.

With pattern-aware complexity, `someFuture phi = untl top phi` is recognized
as a derived temporal operator with overhead 1 (matching box).
-/
lemma some_future_complexity (phi : Formula) :
    Formula.complexity (Formula.someFuture phi) = 1 + Formula.complexity phi := by
  rfl

/-- Complexity of iterF: each F-application adds 1 to complexity.

`complexity (iterF n phi) = n + complexity phi`
-/
lemma iter_F_complexity (n : Nat) (phi : Formula) :
    Formula.complexity (iterF n phi) = n + Formula.complexity phi := by
  induction n with
  | zero => simp [iter_F_zero]
  | succ k ih =>
    simp only [iter_F_succ, some_future_complexity, ih]
    omega

/-- iterF strictly increases complexity for positive iterations. -/
lemma iter_F_complexity_strictly_increasing (n : Nat) (phi : Formula) :
    Formula.complexity (iterF (n + 1) phi) > Formula.complexity (iterF n phi) := by
  simp only [iter_F_complexity]
  omega

/-- iterF is injective: distinct iteration depths give distinct formulas. -/
lemma iter_F_injective (phi : Formula) (m n : Nat) (h : iterF m phi = iterF n phi) : m = n := by
  -- Proof by complexity: if iterF m phi = iterF n phi, then their complexities are equal
  have h_cmplx : Formula.complexity (iterF m phi) = Formula.complexity (iterF n phi) :=
    congrArg Formula.complexity h
  simp only [iter_F_complexity] at h_cmplx
  omega

/-- iterF 1 equals someFuture. -/
lemma iter_F_one_eq_some_future (phi : Formula) :
    iterF 1 phi = Formula.someFuture phi := rfl

/-!
## iterF and F-Nesting Depth

These lemmas connect iterF with the fNestingDepth measure from SubformulaClosure,
enabling proofs that iterF eventually leaves closureWithNeg.
-/

/-- F-nesting depth of iterF n phi is n + fNestingDepth phi.

This is the key lemma connecting iterF iteration count to fNestingDepth.
Since fNestingDepth counts consecutive outermost F applications, and iterF
applies F n times at the outermost level, the depth increases by n.
-/
lemma iter_F_f_nesting_depth (n : Nat) (phi : Formula) :
    FormalSystem.Syntax.fNestingDepth (iterF n phi) = n + FormalSystem.Syntax.fNestingDepth
        phi := by
  induction n with
  | zero => simp only [iter_F_zero, Nat.zero_add]
  | succ k ih =>
    simp only [iter_F_succ, FormalSystem.Syntax.f_nesting_depth_some_future, ih]
    omega

/-- The bound on n for iterF to leave closureWithNeg.

If n > maxFDepthInClosure(phi), then iterF n phi is not in closureWithNeg(phi).
We define closureFBound as max_F_depth + 1 to get the first n that leaves the closure.
-/
def closureFBound (phi : Formula) : Nat :=
  max (FormalSystem.Syntax.maxFDepthInClosure phi) 1 + 1

/-- iterF exceeds the max F-depth bound for large n.

If n >= closureFBound(phi), then the fNestingDepth of iterF n phi
exceeds max(maxFDepthInClosure(phi), 1) -- the deferralClosure bound.
-/
lemma iter_F_exceeds_max_depth (phi : Formula) (n : Nat) (h : n ≥ closureFBound phi) :
    FormalSystem.Syntax.fNestingDepth (iterF n phi) > max
        (FormalSystem.Syntax.maxFDepthInClosure phi)
        1 := by
  rw [iter_F_f_nesting_depth]
  unfold closureFBound at h
  have h_depth_nonneg : FormalSystem.Syntax.fNestingDepth phi ≥ 0 := Nat.zero_le _
  omega

/-- **Main Theorem**: iterF n phi is not in closureWithNeg(phi) for large enough n.

This is the key result establishing that iterF eventually leaves any fixed closure.
The proof uses fNestingDepth: if iterF n phi were in closureWithNeg(phi),
its fNestingDepth would be bounded by maxFDepthInClosure(phi), but
iterF increases depth beyond that bound.
-/
theorem iter_F_not_mem_closureWithNeg (phi : Formula) (n : Nat) (h : n ≥ closureFBound phi) :
    iterF n phi ∉ FormalSystem.Syntax.closureWithNeg phi := by
  intro h_mem
  have h_depth_bound : FormalSystem.Syntax.fNestingDepth (iterF n phi) ≤
      FormalSystem.Syntax.maxFDepthInClosure phi :=
    FormalSystem.Syntax.f_depth_le_max h_mem
  have h_exceeds := iter_F_exceeds_max_depth phi n h
  omega

/-- Explicit form: iterF at the bound leaves closureWithNeg. -/
theorem iter_F_leaves_closure (phi : Formula) :
    iterF (closureFBound phi) phi ∉ FormalSystem.Syntax.closureWithNeg phi :=
  iter_F_not_mem_closureWithNeg phi (closureFBound phi) (Nat.le_refl _)

/--
Helper lemma: iterF (k+1) is F applied to iterF k.
-/
lemma iter_F_succ_eq (k : Nat) (phi : Formula) :
    iterF (k + 1) phi = Formula.someFuture (iterF k phi) := rfl

/--
n-fold application of the P (somePast) operator.

- `iterP 0 φ = φ`
- `iterP (n+1) φ = P(iterP n φ)`

This captures "P^n(φ)" notation, symmetric to iterF.
-/
def iterP : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.somePast (iterP n phi)

/-- iterP 0 is identity. -/
@[simp]
lemma iter_P_zero (phi : Formula) : iterP 0 phi = phi := rfl

/-- iterP (n+1) is P applied to iterP n. -/
@[simp]
lemma iter_P_succ (n : Nat) (phi : Formula) :
    iterP (n + 1) phi = Formula.somePast (iterP n phi) := rfl

/--
Helper: iterP k (P(φ)) = iterP (k+1) φ = P(iterP k φ).
-/
lemma iter_P_some_past (k : Nat) (phi : Formula) :
    iterP k (Formula.somePast phi) = iterP (k + 1) phi := by
  induction k with
  | zero => rfl
  | succ n ih => simp only [iter_P_succ, ih]

/--
Helper lemma: iterP (k+1) is P applied to iterP k.
-/
lemma iter_P_succ_eq (k : Nat) (phi : Formula) :
    iterP (k + 1) phi = Formula.somePast (iterP k phi) := rfl

/-!
## iterP Complexity and Injectivity

Helper lemmas establishing that iterP produces distinct formulas with
strictly increasing complexity. Symmetric to iterF lemmas.
-/

/-- Complexity of somePast: P(phi) adds 1 to complexity.

With pattern-aware complexity, `somePast phi = snce top phi` is recognized
as a derived temporal operator with overhead 1 (matching box).
-/
lemma some_past_complexity (phi : Formula) :
    Formula.complexity (Formula.somePast phi) = 1 + Formula.complexity phi := by
  rfl

/-- Complexity of iterP: each P-application adds 1 to complexity.

`complexity (iterP n phi) = n + complexity phi`
-/
lemma iter_P_complexity (n : Nat) (phi : Formula) :
    Formula.complexity (iterP n phi) = n + Formula.complexity phi := by
  induction n with
  | zero => simp [iter_P_zero]
  | succ k ih =>
    simp only [iter_P_succ, some_past_complexity, ih]
    omega

/-- iterP strictly increases complexity for positive iterations. -/
lemma iter_P_complexity_strictly_increasing (n : Nat) (phi : Formula) :
    Formula.complexity (iterP (n + 1) phi) > Formula.complexity (iterP n phi) := by
  simp only [iter_P_complexity]
  omega

/-- iterP is injective: distinct iteration depths give distinct formulas. -/
lemma iter_P_injective (phi : Formula) (m n : Nat) (h : iterP m phi = iterP n phi) : m = n := by
  have h_cmplx : Formula.complexity (iterP m phi) = Formula.complexity (iterP n phi) :=
    congrArg Formula.complexity h
  simp only [iter_P_complexity] at h_cmplx
  omega

/-- iterP 1 equals somePast. -/
lemma iter_P_one_eq_some_past (phi : Formula) :
    iterP 1 phi = Formula.somePast phi := rfl

/-!
## iterP and P-Nesting Depth

These lemmas connect iterP with the pNestingDepth measure from SubformulaClosure,
enabling proofs that iterP eventually leaves closureWithNeg.
Symmetric to the iterF and fNestingDepth lemmas.
-/

/-- P-nesting depth of iterP n phi is n + pNestingDepth phi.

This is the key lemma connecting iterP iteration count to pNestingDepth.
Since pNestingDepth counts consecutive outermost P applications, and iterP
applies P n times at the outermost level, the depth increases by n.
-/
lemma iter_P_p_nesting_depth (n : Nat) (phi : Formula) :
    FormalSystem.Syntax.pNestingDepth (iterP n phi) = n + FormalSystem.Syntax.pNestingDepth
        phi := by
  induction n with
  | zero => simp only [iter_P_zero, Nat.zero_add]
  | succ k ih =>
    simp only [iter_P_succ, FormalSystem.Syntax.p_nesting_depth_some_past, ih]
    omega

/-- The bound on n for iterP to leave closureWithNeg.

If n > maxPDepthInClosure(phi), then iterP n phi is not in closureWithNeg(phi).
We define closurePBound as max_P_depth + 1 to get the first n that leaves the closure.
-/
def closurePBound (phi : Formula) : Nat :=
  max (FormalSystem.Syntax.maxPDepthInClosure phi) 1 + 1

/-- iterP exceeds the max P-depth bound for large n.

If n >= closurePBound(phi), then the pNestingDepth of iterP n phi
exceeds max(maxPDepthInClosure(phi), 1) -- the deferralClosure bound.
-/
lemma iter_P_exceeds_max_depth (phi : Formula) (n : Nat) (h : n ≥ closurePBound phi) :
    FormalSystem.Syntax.pNestingDepth (iterP n phi) > max
        (FormalSystem.Syntax.maxPDepthInClosure phi)
        1 := by
  rw [iter_P_p_nesting_depth]
  unfold closurePBound at h
  have h_depth_nonneg : FormalSystem.Syntax.pNestingDepth phi ≥ 0 := Nat.zero_le _
  omega

/-- **Main Theorem**: iterP n phi is not in closureWithNeg(phi) for large enough n.

This is the key result establishing that iterP eventually leaves any fixed closure.
The proof uses pNestingDepth: if iterP n phi were in closureWithNeg(phi),
its pNestingDepth would be bounded by maxPDepthInClosure(phi), but
iterP increases depth beyond that bound.
-/
theorem iter_P_not_mem_closureWithNeg (phi : Formula) (n : Nat) (h : n ≥ closurePBound phi) :
    iterP n phi ∉ FormalSystem.Syntax.closureWithNeg phi := by
  intro h_mem
  have h_depth_bound : FormalSystem.Syntax.pNestingDepth (iterP n phi) ≤
      FormalSystem.Syntax.maxPDepthInClosure phi :=
    FormalSystem.Syntax.p_depth_le_max h_mem
  have h_exceeds := iter_P_exceeds_max_depth phi n h
  omega

/-- Explicit form: iterP at the bound leaves closureWithNeg. -/
theorem iter_P_leaves_closure (phi : Formula) :
    iterP (closurePBound phi) phi ∉ FormalSystem.Syntax.closureWithNeg phi :=
  iter_P_not_mem_closureWithNeg phi (closurePBound phi) (Nat.le_refl _)

end FormalSystem.Syntax
