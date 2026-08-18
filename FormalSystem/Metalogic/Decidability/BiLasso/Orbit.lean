/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.List.GetD
import FormalSystem.Metalogic.Decidability.BiLasso.Extend
import FormalSystem.Metalogic.Decidability.BiLasso.Successor

/-!
# Orbit Decomposition: from a Window to a Bi-Lasso

This module supplies the construction that *produces* a `PlacedBiLasso` from a contiguous window
of states. The shape of the argument is the classical rho: follow the chosen successor out of the
window's right endpoint, and since the carrier is finite the orbit must revisit a state, so the
forward continuation splits into a finite **tail** followed by a finite **cycle**. Mirroring the
whole argument through `predOf` gives the same splitting to the left, and the two decompositions
plus the window are exactly the three segments a `BiLasso` carries.

## Where `Classical.choice` enters, and where it does not

The revisit is forced by pigeonhole, and every route to pigeonhole in Mathlib carries
`Classical.choice` — `Finset.card_le_card`, the most primitive counting statement in the library,
already does, so every counting lemma downstream of it does too. `orbit_repeat` below therefore
measures `[propext, Classical.choice, Quot.sound]`, and that is expected rather than a defect.

What does **not** carry it is the successor selection: `IntPresentation.succOf` is
`[propext, Quot.sound]` and `#eval`-able (`BiLasso/Successor.lean`). The orbit whose repeat is
being detected is a computable object; only the *proof that it repeats* reaches for the library's
counting API.

## Main Definitions

- `IntPresentation.fwdTail` / `IntPresentation.fwdCycle` — the forward rho decomposition, as lists
- `IntPresentation.bwdTail` / `IntPresentation.bwdCycle` — the backward mirror, both in
  **increasing time order** so they drop straight into `BiLasso`'s segment convention

## Main Results

- `IntPresentation.orbit_repeat` / `IntPresentation.orbit_repeat_pred` — the pigeonhole
- `IntPresentation.iterSucc_periodic` / `IntPresentation.iterPred_periodic` — a repeat makes the
  orbit periodic from the repeat's first index onward
- `IntPresentation.fwdCycle_ne_nil` / `IntPresentation.bwdCycle_ne_nil` — both cycles are
  non-empty, which is what `BiLasso.back_ne` and `BiLasso.fwd_ne` demand
- `IntPresentation.fwdCycle_wrap` / `IntPresentation.bwdCycle_wrap` — the cycles close up
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

namespace IntPresentation

variable (P : IntPresentation)

/-! ## Composing orbit steps -/

/-- The forward orbit composes: running `m + n` steps is running `m` and then `n`. -/
theorem iterSucc_add (w : Fin P.card) (m n : ℕ) :
    P.iterSucc w (m + n) = P.iterSucc (P.iterSucc w m) n := by
  induction n with
  | zero => rfl
  | succ n ih => rw [← Nat.add_assoc, iterSucc_succ, iterSucc_succ, ih]

/-- The backward orbit composes. -/
theorem iterPred_add (w : Fin P.card) (m n : ℕ) :
    P.iterPred w (m + n) = P.iterPred (P.iterPred w m) n := by
  induction n with
  | zero => rfl
  | succ n ih => rw [← Nat.add_assoc, iterPred_succ, iterPred_succ, ih]

/-! ## Pigeonhole on an orbit -/

/--
**The forward orbit revisits a state.** Within the first `P.card` steps out of any state, the
orbit under the chosen successor repeats.

The route is `Fintype.card_le_of_injective`: if no repeat occurred at indices `0 … P.card`, the
map `Fin (P.card + 1) → Fin P.card` sending `k` to `iterSucc w k` would be injective, forcing
`P.card + 1 ≤ P.card`.
-/
theorem orbit_repeat (w : Fin P.card) :
    ∃ i j : ℕ, i < j ∧ j ≤ P.card ∧ P.iterSucc w i = P.iterSucc w j := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective (fun k : Fin (P.card + 1) => P.iterSucc w (k : ℕ)) := by
    intro a b hab
    by_contra hne
    have hne' : (a : ℕ) ≠ (b : ℕ) := fun h => hne (Fin.ext h)
    rcases Nat.lt_or_ge (a : ℕ) (b : ℕ) with hlt | hge
    · exact absurd hab (hcon a b hlt (by have := b.isLt; omega))
    · have hlt : (b : ℕ) < (a : ℕ) := by omega
      exact absurd hab.symm (hcon b a hlt (by have := a.isLt; omega))
  have hcard := Fintype.card_le_of_injective _ hinj
  simp only [Fintype.card_fin] at hcard
  omega

/-- **The backward orbit revisits a state**, by the identical argument through `iterPred`. -/
theorem orbit_repeat_pred (w : Fin P.card) :
    ∃ i j : ℕ, i < j ∧ j ≤ P.card ∧ P.iterPred w i = P.iterPred w j := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective (fun k : Fin (P.card + 1) => P.iterPred w (k : ℕ)) := by
    intro a b hab
    by_contra hne
    have hne' : (a : ℕ) ≠ (b : ℕ) := fun h => hne (Fin.ext h)
    rcases Nat.lt_or_ge (a : ℕ) (b : ℕ) with hlt | hge
    · exact absurd hab (hcon a b hlt (by have := b.isLt; omega))
    · have hlt : (b : ℕ) < (a : ℕ) := by omega
      exact absurd hab.symm (hcon b a hlt (by have := a.isLt; omega))
  have hcard := Fintype.card_le_of_injective _ hinj
  simp only [Fintype.card_fin] at hcard
  omega

/-! ## A repeat makes the orbit periodic -/

/--
**Forward periodicity from a repeat.** If the orbit revisits at `i < j`, then from index `i`
onward it has period `j - i`. Proved by induction on the offset past `i`, each step applying the
chosen successor to both sides.
-/
theorem iterSucc_periodic {w : Fin P.card} {i j : ℕ} (hij : i < j)
    (h : P.iterSucc w i = P.iterSucc w j) {n : ℕ} (hn : i ≤ n) :
    P.iterSucc w (n + (j - i)) = P.iterSucc w n := by
  obtain ⟨m, rfl⟩ : ∃ m, n = i + m := ⟨n - i, by omega⟩
  induction m with
  | zero => simpa [show i + (j - i) = j by omega] using h.symm
  | succ m ih =>
    have hstep : i + (m + 1) + (j - i) = (i + m + (j - i)) + 1 := by omega
    rw [hstep, iterSucc_succ, ih (by omega), show i + (m + 1) = (i + m) + 1 by omega,
      iterSucc_succ]

/-- **Backward periodicity from a repeat**, the exact mirror through `iterPred`. -/
theorem iterPred_periodic {w : Fin P.card} {i j : ℕ} (hij : i < j)
    (h : P.iterPred w i = P.iterPred w j) {n : ℕ} (hn : i ≤ n) :
    P.iterPred w (n + (j - i)) = P.iterPred w n := by
  obtain ⟨m, rfl⟩ : ∃ m, n = i + m := ⟨n - i, by omega⟩
  induction m with
  | zero => simpa [show i + (j - i) = j by omega] using h.symm
  | succ m ih =>
    have hstep : i + (m + 1) + (j - i) = (i + m + (j - i)) + 1 := by omega
    rw [hstep, iterPred_succ, ih (by omega), show i + (m + 1) = (i + m) + 1 by omega,
      iterPred_succ]

/-! ## The rho decomposition as lists

Both directions are recorded in **increasing time order**, which is `BiLasso`'s convention for
all three of its segments. The forward lists read the orbit index directly; the backward lists
reverse it, because a larger `iterPred` index is an *earlier* time.
-/

/-- The forward pre-period: the orbit entries at indices `0 … i - 1`, in increasing time order. -/
def fwdTail (w : Fin P.card) (i : ℕ) : List (Fin P.card) :=
  (List.range i).map fun k => P.iterSucc w k

/-- The forward cycle: the orbit entries at indices `i … j - 1`, in increasing time order. -/
def fwdCycle (w : Fin P.card) (i j : ℕ) : List (Fin P.card) :=
  (List.range (j - i)).map fun k => P.iterSucc w (i + k)

/-- The backward pre-period, in **increasing time order**: index `k` of the list sits at orbit
index `i - 1 - k`, so the list's last entry is the orbit's index `0` — the latest of them. -/
def bwdTail (w : Fin P.card) (i : ℕ) : List (Fin P.card) :=
  (List.range i).map fun k => P.iterPred w (i - 1 - k)

/-- The backward cycle, in **increasing time order**: index `k` sits at orbit index `j - 1 - k`. -/
def bwdCycle (w : Fin P.card) (i j : ℕ) : List (Fin P.card) :=
  (List.range (j - i)).map fun k => P.iterPred w (j - 1 - k)

@[simp]
theorem fwdTail_length (w : Fin P.card) (i : ℕ) : (P.fwdTail w i).length = i := by
  simp [fwdTail]

@[simp]
theorem fwdCycle_length (w : Fin P.card) (i j : ℕ) : (P.fwdCycle w i j).length = j - i := by
  simp [fwdCycle]

@[simp]
theorem bwdTail_length (w : Fin P.card) (i : ℕ) : (P.bwdTail w i).length = i := by
  simp [bwdTail]

@[simp]
theorem bwdCycle_length (w : Fin P.card) (i j : ℕ) : (P.bwdCycle w i j).length = j - i := by
  simp [bwdCycle]

/-- **The forward cycle is non-empty** — this is what discharges `BiLasso.fwd_ne`. -/
theorem fwdCycle_ne_nil (w : Fin P.card) {i j : ℕ} (hij : i < j) : P.fwdCycle w i j ≠ [] := by
  intro h
  have := P.fwdCycle_length w i j
  rw [h] at this
  simp at this
  omega

/-- **The backward cycle is non-empty** — this is what discharges `BiLasso.back_ne`. -/
theorem bwdCycle_ne_nil (w : Fin P.card) {i j : ℕ} (hij : i < j) : P.bwdCycle w i j ≠ [] := by
  intro h
  have := P.bwdCycle_length w i j
  rw [h] at this
  simp at this
  omega

/-- The forward cycle is no longer than the carrier, given the pigeonhole's own bound `j ≤ card`.
This is what bounds the period in `extend_periodic`'s conclusion. -/
theorem fwdCycle_length_le (w : Fin P.card) {i j : ℕ} (hj : j ≤ P.card) :
    (P.fwdCycle w i j).length ≤ P.card := by
  rw [P.fwdCycle_length]; omega

/-- The backward cycle is no longer than the carrier. -/
theorem bwdCycle_length_le (w : Fin P.card) {i j : ℕ} (hj : j ≤ P.card) :
    (P.bwdCycle w i j).length ≤ P.card := by
  rw [P.bwdCycle_length]; omega

/-! ## Entry-wise readout

Each list reads back the orbit entry at the index its position denotes. These are the lemmas the
assembly consumes: once every segment position is known to be an orbit entry, adjacency along the
segments is `iterSucc_step` / `iterPred_step` and nothing more.
-/

theorem fwdTail_getD (w : Fin P.card) {i n : ℕ} (hn : n < i) :
    (P.fwdTail w i).getD n default = P.iterSucc w n := by
  rw [List.getD_eq_getElem _ _ (by simp [fwdTail]; omega)]
  simp [fwdTail]

theorem fwdCycle_getD (w : Fin P.card) {i j n : ℕ} (hn : n < j - i) :
    (P.fwdCycle w i j).getD n default = P.iterSucc w (i + n) := by
  rw [List.getD_eq_getElem _ _ (by simp [fwdCycle]; omega)]
  simp [fwdCycle]

theorem bwdTail_getD (w : Fin P.card) {i n : ℕ} (hn : n < i) :
    (P.bwdTail w i).getD n default = P.iterPred w (i - 1 - n) := by
  rw [List.getD_eq_getElem _ _ (by simp [bwdTail]; omega)]
  simp [bwdTail]

theorem bwdCycle_getD (w : Fin P.card) {i j n : ℕ} (hn : n < j - i) :
    (P.bwdCycle w i j).getD n default = P.iterPred w (j - 1 - n) := by
  rw [List.getD_eq_getElem _ _ (by simp [bwdCycle]; omega)]
  simp [bwdCycle]

/-! ## The cycles close up

Adjacency *within* each segment is `iterSucc_step` / `iterPred_step` at the relevant index, since
every segment position is an orbit entry. The one adjacency that is not an instance of those is
the wrap-around, where the cycle's last entry must step to its first; that is exactly where the
repeat hypothesis is spent.
-/

/-- **The forward cycle wraps.** The orbit entry at index `j - 1` steps to the entry at index `i`,
which is the first entry of the cycle — because the repeat identifies index `j` with index `i`. -/
theorem fwdCycle_wrap {w : Fin P.card} {i j : ℕ} (hij : i < j)
    (h : P.iterSucc w i = P.iterSucc w j) :
    P.step (P.iterSucc w (j - 1)) (P.iterSucc w i) = true := by
  rw [h, show j = (j - 1) + 1 by omega]
  exact P.iterSucc_step w (j - 1)

/-- **The backward cycle wraps**, mirrored: the orbit entry at index `i` — the *latest* time in
the cycle — is stepped to from the entry at index `j - 1`, the earliest. -/
theorem bwdCycle_wrap {w : Fin P.card} {i j : ℕ} (hij : i < j)
    (h : P.iterPred w i = P.iterPred w j) :
    P.step (P.iterPred w i) (P.iterPred w (j - 1)) = true := by
  rw [h, show j = (j - 1) + 1 by omega]
  exact P.iterPred_step w (j - 1)

end IntPresentation

end FormalSystem.Metalogic.Decidability
