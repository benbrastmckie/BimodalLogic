import Mathlib.Data.Nat.Pairing
import Bimodal.Metalogic.StagedConstruction.StagedExecution

/-!
# Dovetailing Infrastructure for Dense Completeness

This module provides the Cantor-pairing dovetailing enumeration used in the
full dovetailing construction for dense completeness.

## Overview

The standard staged construction processes formulas in order of their encoding:
formula with encoding k is processed at stage 2k+1. This creates a gap:
points entering at stage m > 2k+1 miss having their F(phi_k) obligations processed.

Full dovetailing fixes this by processing (point_index, formula_encoding) pairs
using Cantor pairing. Every pair is eventually processed, ensuring all F/P
obligations are satisfied.

## Key Types

- `ProcessObligation`: A (point_index, formula_encoding) pair to process
- `obligationAtStep`: The obligation processed at step n = unpair(n)

## Key Theorems

- `forall_obligation_eventually_processed`: Every (p, f) pair is processed
  at step `pair(p, f)`

## References

- Task 982: Wire dense completeness via full dovetailing
- reports/16_dovetailing-analysis.md: Detailed dovetailing analysis
- Henkin 1949: Original completeness via enumeration
- Mathlib.Data.Nat.Pairing: Cantor pairing functions
-/

namespace Bimodal.Metalogic.StagedConstruction.Dovetailing

open Nat

/-!
## Cantor Pairing Wrapper

We use Mathlib's `Nat.pair` and `Nat.unpair` directly. These implement
the standard Cantor pairing function with the triangular encoding:

  pair(a, b) = triangle(a + b) + a
  unpair(n) = (n - triangle(k), k - (n - triangle(k)))
    where k = floor((sqrt(8n+1) - 1) / 2)

Key properties:
- `pair` is a bijection Nat x Nat -> Nat
- `unpair` is its inverse
- Both are computable
-/

/-- Alias for Nat.pair for clarity in dovetailing context. -/
abbrev dovetailPair : Nat → Nat → Nat := Nat.pair

/-- Alias for Nat.unpair for clarity in dovetailing context. -/
abbrev dovetailUnpair : Nat → Nat × Nat := Nat.unpair

/-- Pairing and unpairing are inverses: pair(unpair(n)) = n. -/
theorem dovetailPair_dovetailUnpair (n : Nat) :
    dovetailPair (dovetailUnpair n).1 (dovetailUnpair n).2 = n :=
  Nat.pair_unpair n

/-- Pairing and unpairing are inverses: unpair(pair(a, b)) = (a, b). -/
theorem dovetailUnpair_dovetailPair (a b : Nat) :
    dovetailUnpair (dovetailPair a b) = (a, b) :=
  Nat.unpair_pair a b

/-- pair is injective: pair(a, b) = pair(c, d) implies a = c and b = d. -/
theorem dovetailPair_injective {a b c d : Nat}
    (h : dovetailPair a b = dovetailPair c d) : a = c ∧ b = d :=
  Nat.pair_eq_pair.mp h

/-- pair is surjective: for every n, there exist a, b with pair(a, b) = n. -/
theorem dovetailPair_surjective (n : Nat) :
    ∃ a b, dovetailPair a b = n :=
  ⟨(dovetailUnpair n).1, (dovetailUnpair n).2, dovetailPair_dovetailUnpair n⟩

/-!
## Process Obligation Type

An obligation represents a (point_index, formula_encoding) pair that
needs to be processed during the dovetailed construction.
-/

/-- An obligation to process: point index p, formula encoding f.
    When processed, if point p exists and formula f decodes to some phi,
    we process F(phi) and P(phi) obligations for point p. -/
structure ProcessObligation where
  /-- Index of the point in the current timeline. -/
  point_index : Nat
  /-- Encoding of the formula to process. -/
  formula_encoding : Nat
  deriving DecidableEq, Repr

/-- Create an obligation from indices. -/
def mkObligation (p f : Nat) : ProcessObligation :=
  { point_index := p, formula_encoding := f }

instance : Inhabited ProcessObligation :=
  ⟨mkObligation 0 0⟩

/-!
## Obligation Enumeration

The key insight: step n processes obligation (p, f) = unpair(n).
This ensures every (p, f) pair is eventually processed at step pair(p, f).
-/

/-- The obligation to process at step n.
    Uses Cantor unpairing: step n processes obligation unpair(n) = (p, f). -/
def obligationAtStep (n : Nat) : ProcessObligation :=
  let (p, f) := dovetailUnpair n
  { point_index := p, formula_encoding := f }

/-- The step at which obligation (p, f) is processed.
    By the pairing property, this is pair(p, f). -/
def stepForObligation (obl : ProcessObligation) : Nat :=
  dovetailPair obl.point_index obl.formula_encoding

/-- obligationAtStep and stepForObligation are inverses. -/
theorem obligationAtStep_stepForObligation (obl : ProcessObligation) :
    obligationAtStep (stepForObligation obl) = obl := by
  simp only [obligationAtStep, stepForObligation, dovetailUnpair_dovetailPair]

/-- stepForObligation and obligationAtStep are inverses. -/
theorem stepForObligation_obligationAtStep (n : Nat) :
    stepForObligation (obligationAtStep n) = n := by
  simp only [stepForObligation, obligationAtStep, dovetailPair_dovetailUnpair]

/-!
## Coverage Theorem

The fundamental property: every (point_index, formula_encoding) pair
is eventually processed.
-/

/-- Every obligation (p, f) is processed exactly at step pair(p, f).
    This is THE key theorem that ensures full coverage in the dovetailed
    construction: no matter when a point enters and no matter what formula
    appears in its MCS, the corresponding obligation will be processed. -/
theorem forall_obligation_eventually_processed (p f : Nat) :
    ∃ n, obligationAtStep n = mkObligation p f := by
  use dovetailPair p f
  simp only [obligationAtStep, dovetailUnpair_dovetailPair, mkObligation]

/-- The converse: at each step, we process exactly one obligation. -/
theorem obligation_processed_at_unique_step (obl : ProcessObligation) :
    ∃! n, obligationAtStep n = obl := by
  use stepForObligation obl
  constructor
  · exact obligationAtStep_stepForObligation obl
  · intro m hm
    calc m = stepForObligation (obligationAtStep m) := (stepForObligation_obligationAtStep m).symm
    _ = stepForObligation obl := by rw [hm]

/-- Explicit formula: obligation (p, f) is processed at step pair(p, f). -/
theorem obligation_step_is_pair (p f : Nat) :
    stepForObligation (mkObligation p f) = dovetailPair p f := rfl

/-- At step pair(p, f), the obligation has point_index = p. -/
theorem obligationAtStep_point_index (p f : Nat) :
    (obligationAtStep (dovetailPair p f)).point_index = p := by
  simp only [obligationAtStep, dovetailUnpair_dovetailPair]

/-- At step pair(p, f), the obligation has formula_encoding = f. -/
theorem obligationAtStep_formula_encoding (p f : Nat) :
    (obligationAtStep (dovetailPair p f)).formula_encoding = f := by
  simp only [obligationAtStep, dovetailUnpair_dovetailPair]

/-!
## Point Index Bounds

Useful facts about when a point index first appears and how often.
-/

/-- The left component of unpair(n) is at most n. -/
theorem unpair_fst_le (n : Nat) : (dovetailUnpair n).1 ≤ n :=
  Nat.unpair_left_le n

/-- The right component of unpair(n) is at most n. -/
theorem unpair_snd_le (n : Nat) : (dovetailUnpair n).2 ≤ n :=
  Nat.unpair_right_le n

/-- If point_index p appears in obligation at step n, then p ≤ n. -/
theorem point_index_le_step (n : Nat) :
    (obligationAtStep n).point_index ≤ n :=
  unpair_fst_le n

/-- If formula_encoding f appears in obligation at step n, then f ≤ n. -/
theorem formula_encoding_le_step (n : Nat) :
    (obligationAtStep n).formula_encoding ≤ n :=
  unpair_snd_le n

/-- pair(a, b) is at least a + b. -/
theorem pair_ge_sum (a b : Nat) : a + b ≤ dovetailPair a b :=
  Nat.add_le_pair a b

/-- pair(a, b) is at least a. -/
theorem pair_ge_left (a b : Nat) : a ≤ dovetailPair a b :=
  Nat.left_le_pair a b

/-- pair(a, b) is at least b. -/
theorem pair_ge_right (a b : Nat) : b ≤ dovetailPair a b :=
  Nat.right_le_pair a b

/-!
## Iteration Patterns

For proving coverage properties, we often need to iterate over all
obligations up to a certain step.
-/

/-- The set of all obligations processed in steps 0..n-1. -/
def obligationsUpTo (n : Nat) : Finset ProcessObligation :=
  Finset.image obligationAtStep (Finset.range n)

/-- An obligation is in obligationsUpTo iff its step is < n. -/
theorem mem_obligationsUpTo_iff (obl : ProcessObligation) (n : Nat) :
    obl ∈ obligationsUpTo n ↔ stepForObligation obl < n := by
  simp only [obligationsUpTo, Finset.mem_image, Finset.mem_range]
  constructor
  · intro ⟨m, hm, hob⟩
    rw [← hob, stepForObligation_obligationAtStep]
    exact hm
  · intro h
    exact ⟨stepForObligation obl, h, obligationAtStep_stepForObligation obl⟩

/-- Obligation (p, f) is in obligationsUpTo n iff pair(p, f) < n. -/
theorem mkObligation_mem_obligationsUpTo_iff (p f n : Nat) :
    mkObligation p f ∈ obligationsUpTo n ↔ dovetailPair p f < n := by
  rw [mem_obligationsUpTo_iff]
  rfl

end Bimodal.Metalogic.StagedConstruction.Dovetailing
