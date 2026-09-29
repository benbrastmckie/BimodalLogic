/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Types
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle
import FormalSystem.Semantics.Periodicity
import Mathlib.Data.Int.LeastGreatest

/-!
# Good Cycles over L⁺ Type Space, with an Explicit Length Bound

The L⁺ twin of `WitnessFamily/Compression/Cycle.lean`: the same combinatorial core over
`PlusTypeState C`, subsets of the L⁺ certificate closure.

## What is reused and what is transcribed

The `Formula`-side module's pigeonhole pair `exists_iterT_lt_card_aux` / `exists_iterT_lt_card`
is stated over an abstract `{W : Type} [Finite W] [Nonempty W]` and a bare relation
`R : W → W → Prop`. Neither signature mentions `Formula` or `TypeState C` anywhere, load-bearing
or otherwise, so both are **reused by import** rather than re-proved. This module therefore
imports the `Formula`-side `Compression/Cycle.lean` for exactly those two declarations, and the
import is recorded here so it is a decision rather than an accident.

Everything else is transcribed, because everything else is monomorphic in `Formula` through
`TypeState C = {S : Finset Formula // S ∈ C.powerset}`. No instantiation reaches it: `Formula`
and `PlusFormula` are separate inductives sharing no supertype, so `Finset Formula` and
`Finset PlusFormula` are unrelated types and the subtype cannot be re-indexed.

**The trigger that retires the duplication** is the same one the `Formula`-side module records:
once a shared periodic-label presentation lands, both cores should be redefined as its instances
and the duplicated plumbing deleted.

## The derived bound

`(2k + 1) · 2^k` with `k = C.card`, identical in shape to the `Formula` side and for the same
reason: each mark is reached by an out-and-back excursion `x ⟶ mark ⟶ x`, contributing **two**
shortened segments rather than one, so `2m` segments for the marks plus one base cycle, with
`m ≤ k`. The L⁺ closure is larger than the `Formula` closure of a corresponding formula — it has
a `stab` tier — but the bound's *form* is unchanged, because `⊡` contributes no event and so no
excursion. That is Phase 4's observation, carried here for the arithmetic.

## Main Definitions

- `PlusTypeState` — the finite datum space: subsets of the L⁺ target closure
- `plusTypeOfT` — the type component of a datum
- `PlusSeqStepT` — the edge relation induced by an arbitrary L⁺ datum sequence
- `plusJoinPathT` — concatenation of two walks

## Main Results

- `natCard_plusTypeState` — the datum space has exactly `2 ^ C.card` elements
- `iter_plusSeqStepT` — a stretch of the datum sequence is an iterate of its edge relation
- `plusJoinPathT_left` / `plusJoinPathT_right` / `plusJoinPathT_steps` — the joining interface
- `exists_recurring_plusTypeState` — some datum recurs at arbitrarily large indices

Argument order is **guard first**: `PlusFormula.untl g e`, `PlusFormula.snce g e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## The L⁺ datum space -/

/--
The presentation-free L⁺ pigeonhole datum: a subset of the L⁺ target closure.

Declared `abbrev` rather than `def` so that the subtype's `Fintype`, `DecidableEq` and `Finite`
instances are available without restating them, exactly as `TypeState` is.
-/
abbrev PlusTypeState (C : Finset PlusFormula) : Type := {S : Finset PlusFormula // S ∈ C.powerset}

variable {C : Finset PlusFormula}

/-- The type component of an L⁺ datum, as a plain `Finset PlusFormula`. -/
def plusTypeOfT (x : PlusTypeState C) : Finset PlusFormula := x.1

/-- A datum's type is a set of closure formulas — the subtype's own side condition, unpacked. -/
theorem plusTypeOfT_subset (x : PlusTypeState C) : plusTypeOfT x ⊆ C :=
  Finset.mem_powerset.mp x.2

/-- **The cardinality of the L⁺ datum type**, in `Fintype.card` normal form. -/
theorem card_plusTypeState (C : Finset PlusFormula) :
    Fintype.card (PlusTypeState C) = 2 ^ C.card := by
  rw [Fintype.card_coe, Finset.card_powerset]

/--
The same count in `Nat.card` normal form.

**This is the form the downstream bounds use**, because `Semantics/Periodicity.lean`'s
`exists_lt_iter_of_card_le` is stated with `Nat.card`.
-/
theorem natCard_plusTypeState (C : Finset PlusFormula) :
    Nat.card (PlusTypeState C) = 2 ^ C.card := by
  rw [Nat.card_eq_fintype_card, card_plusTypeState]

/-- The L⁺ datum type is inhabited by the empty subset. -/
instance instInhabitedPlusTypeState : Inhabited (PlusTypeState C) :=
  ⟨⟨∅, Finset.mem_powerset.mpr (Finset.empty_subset _)⟩⟩

@[simp] theorem plusTypeOfT_default :
    plusTypeOfT (default : PlusTypeState C) = (∅ : Finset PlusFormula) := rfl

/-! ## Walks in an L⁺ datum sequence -/

/--
The edge relation induced by an L⁺ datum sequence: `x` steps to `y` when some index carries `x`
and its successor carries `y`.

Generic in the sequence, which is what lets the backward cycle reuse the forward construction at
the reversed sequence `fun u => d (-u)` rather than duplicating the construction with the
temporal direction flipped.
-/
def PlusSeqStepT (d : ℤ → PlusTypeState C) : PlusTypeState C → PlusTypeState C → Prop :=
  fun x y => ∃ u : ℤ, d u = x ∧ d (u + 1) = y

/-- A stretch of the L⁺ datum sequence is an iterate of its edge relation. -/
theorem iter_plusSeqStepT (d : ℤ → PlusTypeState C) (a : ℤ) (n : ℕ) :
    iter (PlusSeqStepT d) n (d a) (d (a + (n : ℤ))) := by
  induction n with
  | zero => simp
  | succ n ih =>
    refine ⟨d (a + (n : ℤ)), ih, ⟨a + (n : ℤ), rfl, ?_⟩⟩
    congr 1
    omega

/-! ### Concatenating walks -/

/-- Concatenation of two walks: `p` on `[0, L]`, then `q` shifted to start at `L`. -/
def plusJoinPathT (p q : ℕ → PlusTypeState C) (L : ℕ) : ℕ → PlusTypeState C :=
  fun j => if j ≤ L then p j else q (j - L)

theorem plusJoinPathT_left (p q : ℕ → PlusTypeState C) {L j : ℕ} (h : j ≤ L) :
    plusJoinPathT p q L j = p j := if_pos h

theorem plusJoinPathT_right (p q : ℕ → PlusTypeState C) (L : ℕ) (hpq : p L = q 0) (i : ℕ) :
    plusJoinPathT p q L (L + i) = q i := by
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · simp [plusJoinPathT, hpq]
  · have hnot : ¬ (L + i ≤ L) := by omega
    have hsub : L + i - L = i := by omega
    simp only [plusJoinPathT, if_neg hnot, hsub]

theorem plusJoinPathT_steps {d : ℤ → PlusTypeState C} (p q : ℕ → PlusTypeState C) (L L' : ℕ)
    (hpq : p L = q 0)
    (hp : ∀ j, j < L → PlusSeqStepT d (p j) (p (j + 1)))
    (hq : ∀ j, j < L' → PlusSeqStepT d (q j) (q (j + 1))) :
    ∀ j, j < L + L' → PlusSeqStepT d (plusJoinPathT p q L j) (plusJoinPathT p q L (j + 1)) := by
  intro j hj
  rcases lt_or_ge j L with h | h
  · rw [plusJoinPathT_left p q (le_of_lt h), plusJoinPathT_left p q (by omega : j + 1 ≤ L)]
    exact hp j h
  · obtain ⟨i, rfl⟩ : ∃ i, j = L + i := ⟨j - L, by omega⟩
    rw [plusJoinPathT_right p q L hpq i, show L + i + 1 = L + (i + 1) by omega,
      plusJoinPathT_right p q L hpq (i + 1)]
    exact hq i (by omega)

/-! ## Recurrence -/

/--
**Some L⁺ datum recurs at arbitrarily large indices.**

Pure finiteness: if every datum had a last occurrence, the finitely many last occurrences would
have an upper bound, and the datum at that bound would occur after its own last occurrence.
-/
theorem exists_recurring_plusTypeState (d : ℤ → PlusTypeState C) :
    ∃ x : PlusTypeState C, ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x := by
  classical
  by_contra hcon
  push Not at hcon
  choose f hf using hcon
  have hne : (Finset.univ : Finset (PlusTypeState C)).Nonempty := Finset.univ_nonempty
  have hle : f (d (Finset.univ.sup' hne f)) ≤ Finset.univ.sup' hne f :=
    Finset.le_sup' f (Finset.mem_univ _)
  exact hf _ _ hle rfl

end FormalSystem.Metalogic.Decidability
