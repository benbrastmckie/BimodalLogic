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

Not in the pigeonhole. Every route to pigeonhole in Mathlib carries `Classical.choice` —
`Finset.card_le_card`, the most primitive counting statement in the library, already does — so a
revisit proved through the library would be choice-carrying. `exists_dup_lt` below avoids that by
proving pigeonhole on `Fin` directly, by deleting a value and inducting on the codomain, and
`orbit_repeat` / `orbit_repeat_pred` are consequently `[propext, Quot.sound]`.

Nor in the successor selection: `IntPresentation.succOf` is `[propext, Quot.sound]` and
`#eval`-able (`BiLasso/Successor.lean`).

Where it does enter is the assembly, through two incidental library facts: `BiLasso`'s decoding
lemmas (via `BiLasso.length_pos_int`, in a module held byte-stable and so not scrubbable here) and
Mathlib's `List.getD` indexing lemmas. `IntPresentation.extend_periodic`'s docstring carries the
full accounting.

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

/-!
## A choice-free pigeonhole on `Fin`

Every pigeonhole in Mathlib carries `Classical.choice`, `Finset.card_le_card` included, because
`Finset.card` sits on `Multiset` / `Quot` machinery that pulls it in at the base. That is an API
fact rather than a logical obstruction: pigeonhole over a carrier with decidable equality is
constructively valid, and the proof below is a direct construction, measured at
`[propext, Quot.sound]`.

The induction deletes a value. Given a map `ℕ → Fin (N + 1)` on a window longer than `N + 1`,
either some earlier index already collides with the last one — found by `List.find?`, so the
search is a computation and not an appeal to excluded middle — or none does, in which case the
last value is missed by all the others and can be deleted from the codomain, shrinking `N + 1` to
`N` and invoking the inductive hypothesis.

**What this does and does not buy.** `orbit_repeat` and `orbit_repeat_pred` below become
choice-free. `IntPresentation.extend_periodic` does **not**: its conclusion asserts
`IsStepPath`, which routes through `BiLasso.unroll_isStepPath`, and that lemma is choice-carrying
for reasons entirely internal to the decoding module — which is held byte-stable and so is not
scrubbable from here. See `extend_periodic`'s own docstring for the resulting accounting.
-/

/-- Delete the value `v` from `Fin (N + 1)`, landing in `Fin N`. Injective away from `v`, which is
all that is asked of it. -/
private def deleteVal {N : ℕ} (hN : 0 < N) (v x : Fin (N + 1)) : Fin N :=
  if hx : x.val < v.val then ⟨x.val, by have := v.isLt; omega⟩
  else ⟨x.val - 1, by have := x.isLt; omega⟩

/-- `deleteVal v` is injective on the complement of `v`. -/
private theorem deleteVal_inj {N : ℕ} (hN : 0 < N) (v x y : Fin (N + 1))
    (hx : x ≠ v) (hy : y ≠ v) (h : deleteVal hN v x = deleteVal hN v y) : x = y := by
  have hxl := x.isLt
  have hyl := y.isLt
  have hvl := v.isLt
  have hx' : x.val ≠ v.val := fun he => hx (Fin.ext he)
  have hy' : y.val ≠ v.val := fun he => hy (Fin.ext he)
  apply Fin.ext
  unfold deleteVal at h
  split at h <;> split at h <;> simp only [Fin.mk.injEq] at h <;> omega

/--
**Pigeonhole on `Fin`, choice-free.** Any `n > N` consecutive values of a map into `Fin N` repeat,
and the repeat is exhibited by indices.

Measured at `[propext, Quot.sound]` — see this section's docstring for why that is worth the
duplication against Mathlib's own pigeonhole.
-/
theorem exists_dup_lt : ∀ (N n : ℕ), N < n → ∀ g : ℕ → Fin N,
    ∃ i j : ℕ, i < j ∧ j < n ∧ g i = g j := by
  intro N
  induction N with
  | zero => intro n hn g; exact absurd (g 0).isLt (by omega)
  | succ N ih =>
    intro n hn g
    -- The comparison is spelled `Nat.beq` on the underlying values rather than `==` on `Fin`.
    -- That is not cosmetic: with the full library in scope, `==` at `Fin` resolves through a
    -- `LawfulBEq` route whose `beq_iff_eq` and `eq_of_beq` are themselves choice-carrying, which
    -- would silently reintroduce `Classical.choice` into this proof. `Nat.beq` does not.
    cases hfind : (List.range (n - 1)).find?
        (fun i => Nat.beq (g i).val (g (n - 1)).val) with
    | some i =>
        have hmem : i ∈ List.range (n - 1) := List.mem_of_find?_eq_some hfind
        have heq : Nat.beq (g i).val (g (n - 1)).val = true :=
          List.find?_some (p := fun k => Nat.beq (g k).val (g (n - 1)).val) hfind
        exact ⟨i, n - 1, by have := List.mem_range.mp hmem; omega, by omega,
          Fin.ext (Nat.eq_of_beq_eq_true heq)⟩
    | none =>
        have hbeq : ∀ a b : ℕ, a = b → Nat.beq a b = true := by
          intro a b hab
          cases hab
          exact Nat.beq_refl a
        have hall : ∀ i, i < n - 1 → g i ≠ g (n - 1) := by
          intro i hi he
          exact List.find?_eq_none.mp hfind i (List.mem_range.mpr hi)
            (hbeq _ _ (congrArg Fin.val he))
        rcases Nat.eq_zero_or_pos N with hN0 | hNpos
        · subst hN0
          have hone : g 0 = g (n - 1) :=
            Fin.ext (by have := (g 0).isLt; have := (g (n - 1)).isLt; omega)
          exact absurd hone (hall 0 (by omega))
        · obtain ⟨i, j, hij, hjn, heq⟩ :=
            ih (n - 1) (by omega) (fun k => deleteVal hNpos (g (n - 1)) (g k))
          exact ⟨i, j, hij, by omega,
            deleteVal_inj hNpos _ _ _ (hall i (by omega)) (hall j (by omega)) heq⟩

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
  obtain ⟨i, j, hij, hjn, heq⟩ :=
    exists_dup_lt P.card (P.card + 1) (by omega) (fun k => P.iterSucc w k)
  exact ⟨i, j, hij, by omega, heq⟩

/-- **The backward orbit revisits a state**, by the identical argument through `iterPred`. -/
theorem orbit_repeat_pred (w : Fin P.card) :
    ∃ i j : ℕ, i < j ∧ j ≤ P.card ∧ P.iterPred w i = P.iterPred w j := by
  obtain ⟨i, j, hij, hjn, heq⟩ :=
    exists_dup_lt P.card (P.card + 1) (by omega) (fun k => P.iterPred w k)
  exact ⟨i, j, hij, by omega, heq⟩

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


/-! ## The intended path of a window

Assembling a `BiLasso` from a window means writing down three lists whose decoding is a
particular bi-infinite path: the window on its own times, the backward orbit strictly before it,
the forward orbit strictly after it. That path is worth naming, because every adjacency obligation
the assembly incurs — the two within-segment chains, the two seams, and both wrap-arounds —
reduces to a statement about it.
-/

/-- The first entry of the window. -/
def winHead (P : IntPresentation) (win : List (Fin P.card)) : Fin P.card := win.getD 0 default

/-- The last entry of the window. -/
def winLast (P : IntPresentation) (win : List (Fin P.card)) : Fin P.card :=
  win.getD (win.length - 1) default

/-- The state immediately **before** the window: the chosen predecessor of its first entry. This
is the backward orbit's basepoint, sitting at absolute time `origin - 1`. -/
def winPred (P : IntPresentation) (win : List (Fin P.card)) : Fin P.card :=
  P.predOf (P.winHead win)

/-- The state immediately **after** the window: the chosen successor of its last entry. This is the
forward orbit's basepoint, sitting at absolute time `origin + |win|`. -/
def winSucc (P : IntPresentation) (win : List (Fin P.card)) : Fin P.card :=
  P.succOf (P.winLast win)

/--
**The intended path.** The window `win` occupies the absolute times
`[origin, origin + |win|)`; strictly to its left the path runs the backward orbit out of
`winPred`, and at or past `origin + |win|` the forward orbit out of `winSucc`.
-/
def windowPath (P : IntPresentation) (win : List (Fin P.card)) (origin : ℤ) (t : ℤ) :
    Fin P.card :=
  if t < origin then P.iterPred (P.winPred win) (origin - 1 - t).toNat
  else if t < origin + (win.length : ℤ) then win.getD (t - origin).toNat default
  else P.iterSucc (P.winSucc win) (t - origin - (win.length : ℤ)).toNat

/--
**The intended path is a walk in the adjacency matrix**, at every integer time.

The five cases are the whole adjacency story of the assembly: within the backward orbit, across
the backward-to-window seam, within the window, across the window-to-forward seam, and within the
forward orbit. The two seams are exactly where `predOf_step` and `succOf_step` are spent; the
three within-segment cases are `iterPred_step`, the window's own hypothesis, and `iterSucc_step`.
-/
theorem windowPath_step (P : IntPresentation) {win : List (Fin P.card)} (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    (origin t : ℤ) :
    P.step (P.windowPath win origin t) (P.windowPath win origin (t + 1)) = true := by
  have hm : 0 < win.length := Nat.pos_of_ne_zero fun h => hne (List.eq_nil_of_length_eq_zero h)
  have hmz : (0 : ℤ) < (win.length : ℤ) := by exact_mod_cast hm
  rcases lt_or_ge t (origin - 1) with h1 | h1
  · -- Within the backward orbit.
    have ht : t < origin := by omega
    have ht1 : t + 1 < origin := by omega
    simp only [windowPath, if_pos ht, if_pos ht1]
    rw [show (origin - 1 - t).toNat = (origin - 1 - (t + 1)).toNat + 1 by omega]
    exact P.iterPred_step _ _
  rcases eq_or_lt_of_le h1 with h2 | h2
  · -- The backward-to-window seam.
    have ht : t < origin := by omega
    have ht1 : ¬ (t + 1 < origin) := by omega
    have ht1' : t + 1 < origin + (win.length : ℤ) := by omega
    simp only [windowPath, if_pos ht, if_neg ht1, if_pos ht1']
    rw [show (origin - 1 - t).toNat = 0 by omega, show (t + 1 - origin).toNat = 0 by omega]
    exact P.predOf_step _
  -- From here on `origin ≤ t`.
  have hge : origin ≤ t := by omega
  have hnlt : ¬ (t < origin) := by omega
  rcases lt_or_ge t (origin + (win.length : ℤ) - 1) with h3 | h3
  · -- Within the window.
    have ht : t < origin + (win.length : ℤ) := by omega
    have ht1 : ¬ (t + 1 < origin) := by omega
    have ht1' : t + 1 < origin + (win.length : ℤ) := by omega
    simp only [windowPath, if_neg hnlt, if_pos ht, if_neg ht1, if_pos ht1']
    rw [show (t + 1 - origin).toNat = (t - origin).toNat + 1 by omega]
    exact hadj _ (by omega)
  rcases eq_or_lt_of_le h3 with h4 | h4
  · -- The window-to-forward seam.
    have ht : t < origin + (win.length : ℤ) := by omega
    have ht1 : ¬ (t + 1 < origin) := by omega
    have ht1' : ¬ (t + 1 < origin + (win.length : ℤ)) := by omega
    simp only [windowPath, if_neg hnlt, if_pos ht, if_neg ht1, if_neg ht1']
    rw [show (t + 1 - origin - (win.length : ℤ)).toNat = 0 by omega,
      show (t - origin).toNat = win.length - 1 by omega]
    exact P.succOf_step _
  · -- Within the forward orbit.
    have ht : ¬ (t < origin + (win.length : ℤ)) := by omega
    have ht1 : ¬ (t + 1 < origin) := by omega
    have ht1' : ¬ (t + 1 < origin + (win.length : ℤ)) := by omega
    simp only [windowPath, if_neg hnlt, if_neg ht, if_neg ht1, if_neg ht1']
    rw [show (t + 1 - origin - (win.length : ℤ)).toNat
        = (t - origin - (win.length : ℤ)).toNat + 1 by omega]
    exact P.iterSucc_step _ _

/-- The intended path reads the window directly on the window's own times. -/
theorem windowPath_window (P : IntPresentation) (win : List (Fin P.card)) (origin : ℤ) {k : ℕ}
    (hk : k < win.length) :
    P.windowPath win origin (origin + (k : ℤ)) = win.getD k default := by
  have h1 : ¬ (origin + (k : ℤ) < origin) := by omega
  have h2 : origin + (k : ℤ) < origin + (win.length : ℤ) := by
    have : (k : ℤ) < (win.length : ℤ) := by exact_mod_cast hk
    omega
  simp only [windowPath, if_neg h1, if_pos h2]
  rw [show (origin + (k : ℤ) - origin).toNat = k by omega]

/-! ## Assembly: the three segments

The segment layout is fixed here, once, because `BiLasso`'s fields are positional and getting the
convention wrong is silent:

```
   back = bwdCycle          mid = bwdTail ++ win ++ fwdTail          fwd = fwdCycle
   (period, leftward)       (lasso times [0, |mid|))                 (period, rightward)
```

with the lasso's own time `0` sitting at absolute time `origin - |bwdTail|` — that is, at the
earliest time the backward pre-period reaches, since everything strictly left of it is already
covered by the periodic `back` segment.
-/

/-- The lasso's leftward cycle: the backward orbit's cycle, in increasing time order. -/
def windowBack (P : IntPresentation) (win : List (Fin P.card)) (bi bj : ℕ) :
    List (Fin P.card) := P.bwdCycle (P.winPred win) bi bj

/-- The lasso's finite window: the backward pre-period, then the caller's window, then the forward
pre-period. -/
def windowMid (P : IntPresentation) (win : List (Fin P.card)) (bi fi : ℕ) :
    List (Fin P.card) :=
  P.bwdTail (P.winPred win) bi ++ (win ++ P.fwdTail (P.winSucc win) fi)

/-- The lasso's rightward cycle: the forward orbit's cycle. -/
def windowFwd (P : IntPresentation) (win : List (Fin P.card)) (fi fj : ℕ) :
    List (Fin P.card) := P.fwdCycle (P.winSucc win) fi fj

@[simp]
theorem windowBack_length (P : IntPresentation) (win : List (Fin P.card)) (bi bj : ℕ) :
    (P.windowBack win bi bj).length = bj - bi := by simp [windowBack]

@[simp]
theorem windowFwd_length (P : IntPresentation) (win : List (Fin P.card)) (fi fj : ℕ) :
    (P.windowFwd win fi fj).length = fj - fi := by simp [windowFwd]

@[simp]
theorem windowMid_length (P : IntPresentation) (win : List (Fin P.card)) (bi fi : ℕ) :
    (P.windowMid win bi fi).length = bi + win.length + fi := by
  simp [windowMid, Nat.add_assoc]

/-- The intended path is invariant under shifting the origin and the time together. -/
theorem windowPath_shift (P : IntPresentation) (win : List (Fin P.card)) (o k t : ℤ) :
    P.windowPath win (o + k) (t + k) = P.windowPath win o t := by
  unfold windowPath
  rw [show o + k - 1 - (t + k) = o - 1 - t by omega,
    show t + k - (o + k) = t - o by omega]
  by_cases h1 : t < o
  · rw [if_pos (show t + k < o + k by omega), if_pos h1]
  · rw [if_neg (show ¬ (t + k < o + k) by omega), if_neg h1]
    by_cases h2 : t < o + (win.length : ℤ)
    · rw [if_pos (show t + k < o + k + (win.length : ℤ) by omega), if_pos h2]
    · rw [if_neg (show ¬ (t + k < o + k + (win.length : ℤ)) by omega), if_neg h2]

/--
**The three segments decode to the intended path**, throughout one full `coherent` window.

This is the single lemma that discharges `BiLasso.coherent` for the assembly: once the decoding is
known to agree with `windowPath` on `[-|back| - 1, |mid| + |fwd|]`, adjacency across that window is
`windowPath_step` and nothing else.

The range is closed at the top rather than half-open because `coherent`'s last index still asks
about the time one step further, and it is exactly at the two endpoints that the two repeat
hypotheses are spent — `hbeq` at `t = -|back| - 1`, where the leftward cycle wraps, and `hfeq` at
`t = |mid| + |fwd|`, where the rightward cycle does.
-/
theorem unrollOf_windowSegments (P : IntPresentation) {win : List (Fin P.card)}
    {bi bj fi fj : ℕ} (hbij : bi < bj)
    (hbeq : P.iterPred (P.winPred win) bi = P.iterPred (P.winPred win) bj)
    (hfij : fi < fj)
    (hfeq : P.iterSucc (P.winSucc win) fi = P.iterSucc (P.winSucc win) fj)
    {t : ℤ} (hlo : (bi : ℤ) - (bj : ℤ) - 1 ≤ t)
    (hhi : t ≤ (bi : ℤ) + (win.length : ℤ) + (fj : ℤ)) :
    BiLasso.unrollOf P (P.windowBack win bi bj) (P.windowMid win bi fi) (P.windowFwd win fi fj) t
      = P.windowPath win (bi : ℤ) t := by
  have hbl : ((P.windowBack win bi bj).length : ℤ) = (bj : ℤ) - (bi : ℤ) := by
    rw [P.windowBack_length]; omega
  have hml : ((P.windowMid win bi fi).length : ℤ)
      = (bi : ℤ) + (win.length : ℤ) + (fi : ℤ) := by
    rw [P.windowMid_length]; omega
  have hfl : ((P.windowFwd win fi fj).length : ℤ) = (fj : ℤ) - (fi : ℤ) := by
    rw [P.windowFwd_length]; omega
  rcases lt_or_ge t 0 with hneg | hpos
  · -- Left of the lasso origin: the leftward cycle.
    simp only [BiLasso.unrollOf, if_pos hneg, BiLasso.cyc, hbl]
    rw [windowPath, if_pos (show t < (bi : ℤ) by omega)]
    rcases eq_or_lt_of_le hlo with hwrap | hin
    · -- `t = -|back| - 1`: the leftward cycle wraps, and `hbeq` is what closes it.
      have hr : t % ((bj : ℤ) - (bi : ℤ)) = (bj : ℤ) - (bi : ℤ) - 1 := by
        have h1 : (t + ((bj : ℤ) - (bi : ℤ)) * 2) % ((bj : ℤ) - (bi : ℤ))
            = t % ((bj : ℤ) - (bi : ℤ)) :=
          Int.add_mul_emod_self_left _ _ _
        rw [← h1, Int.emod_eq_of_lt (by omega) (by omega)]
        omega
      rw [hr, windowBack, P.bwdCycle_getD _ (by omega)]
      rw [show bj - 1 - ((bj : ℤ) - (bi : ℤ) - 1).toNat = bi by omega, hbeq]
      congr 1
      omega
    · -- `-|back| ≤ t < 0`: a direct read of the leftward cycle.
      have hr : t % ((bj : ℤ) - (bi : ℤ)) = t + ((bj : ℤ) - (bi : ℤ)) := by
        have h1 : (t + ((bj : ℤ) - (bi : ℤ)) * 1) % ((bj : ℤ) - (bi : ℤ))
            = t % ((bj : ℤ) - (bi : ℤ)) :=
          Int.add_mul_emod_self_left _ _ _
        rw [← h1, Int.emod_eq_of_lt (by omega) (by omega)]
        omega
      rw [hr, windowBack, P.bwdCycle_getD _ (by omega)]
      congr 1
      omega
  rcases lt_or_ge t ((bi : ℤ) + (win.length : ℤ) + (fi : ℤ)) with hmid | hfwd
  · -- Inside the lasso's finite window.
    simp only [BiLasso.unrollOf, if_neg (show ¬ (t < 0) by omega), hml, if_pos hmid]
    rcases lt_or_ge t (bi : ℤ) with hb | hb
    · -- The backward pre-period.
      rw [windowMid, List.getD_append _ _ _ _ (by rw [P.bwdTail_length]; omega),
        P.bwdTail_getD _ (by omega)]
      rw [windowPath, if_pos hb]
      congr 1
      omega
    rcases lt_or_ge t ((bi : ℤ) + (win.length : ℤ)) with hw | hw
    · -- The caller's window.
      rw [windowMid, List.getD_append_right _ _ _ _ (by rw [P.bwdTail_length]; omega),
        List.getD_append _ _ _ _ (by rw [P.bwdTail_length]; omega)]
      rw [windowPath, if_neg (show ¬ (t < (bi : ℤ)) by omega), if_pos hw]
      rw [P.bwdTail_length]
      congr 1
      omega
    · -- The forward pre-period.
      rw [windowMid, List.getD_append_right _ _ _ _ (by rw [P.bwdTail_length]; omega),
        List.getD_append_right _ _ _ _ (by rw [P.bwdTail_length]; omega),
        P.bwdTail_length, P.fwdTail_getD _ (by omega)]
      rw [windowPath, if_neg (show ¬ (t < (bi : ℤ)) by omega),
        if_neg (show ¬ (t < (bi : ℤ) + (win.length : ℤ)) by omega)]
      congr 1
      omega
  · -- Right of the lasso's window: the rightward cycle.
    simp only [BiLasso.unrollOf, if_neg (show ¬ (t < 0) by omega), hml,
      if_neg (show ¬ (t < (bi : ℤ) + (win.length : ℤ) + (fi : ℤ)) by omega), BiLasso.cyc, hfl]
    rw [windowPath, if_neg (show ¬ (t < (bi : ℤ)) by omega),
      if_neg (show ¬ (t < (bi : ℤ) + (win.length : ℤ)) by omega)]
    rcases eq_or_lt_of_le hhi with hwrap | hin
    · -- `t = |mid| + |fwd|`: the rightward cycle wraps, and `hfeq` closes it.
      have hr : (t - ((bi : ℤ) + (win.length : ℤ) + (fi : ℤ))) % ((fj : ℤ) - (fi : ℤ)) = 0 := by
        rw [show t - ((bi : ℤ) + (win.length : ℤ) + (fi : ℤ)) = ((fj : ℤ) - (fi : ℤ)) * 1 by omega]
        simp
      rw [hr, windowFwd, P.fwdCycle_getD _ (by omega)]
      simp only [Int.toNat_zero, Nat.add_zero]
      rw [hfeq]
      congr 1
      omega
    · -- A direct read of the rightward cycle.
      have hr : (t - ((bi : ℤ) + (win.length : ℤ) + (fi : ℤ))) % ((fj : ℤ) - (fi : ℤ))
          = t - ((bi : ℤ) + (win.length : ℤ) + (fi : ℤ)) :=
        Int.emod_eq_of_lt (by omega) (by omega)
      rw [hr, windowFwd, P.fwdCycle_getD _ (by omega)]
      congr 1
      omega

/-! ## The constructor

`lassoOfWindow` takes the window **and the two repeats as data** — the pair of orbit indices in
each direction, together with the proofs that they really are repeats. That is deliberate: a model
checker's search is what finds those indices, and handing them in keeps the constructor a genuine
computable `def` rather than something that must extract data from a `Prop`-level existential.
`IntPresentation.extend_periodic` is where the existentials are discharged, once, by pigeonhole.
-/

/--
**The bi-lasso of a contiguous window.** Three lists, assembled at the layout fixed above, with
`back_ne` and `fwd_ne` from the two cycles' non-emptiness and `coherent` from
`unrollOf_windowSegments` composed with `windowPath_step`.
-/
def lassoOfWindow (P : IntPresentation) (win : List (Fin P.card)) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    {bi bj fi fj : ℕ} (hbij : bi < bj)
    (hbeq : P.iterPred (P.winPred win) bi = P.iterPred (P.winPred win) bj)
    (hfij : fi < fj)
    (hfeq : P.iterSucc (P.winSucc win) fi = P.iterSucc (P.winSucc win) fj) :
    BiLasso P where
  back := P.windowBack win bi bj
  mid := P.windowMid win bi fi
  fwd := P.windowFwd win fi fj
  back_ne := P.bwdCycle_ne_nil _ hbij
  fwd_ne := P.fwdCycle_ne_nil _ hfij
  coherent := by
    have hbl : (P.windowBack win bi bj).length = bj - bi := P.windowBack_length win bi bj
    have hml : (P.windowMid win bi fi).length = bi + win.length + fi :=
      P.windowMid_length win bi fi
    have hfl : (P.windowFwd win fi fj).length = fj - fi := P.windowFwd_length win fi fj
    intro idx
    have hidx : (idx : ℕ) < (bj - bi) + 1 + (bi + win.length + fi) + (fj - fi) := by
      have h := idx.isLt
      omega
    have htv : BiLasso.windowTime P (P.windowBack win bi bj) (idx : ℕ)
        = ((idx : ℕ) : ℤ) - ((bj : ℤ) - (bi : ℤ)) - 1 := by
      unfold BiLasso.windowTime
      omega
    rw [htv,
      P.unrollOf_windowSegments hbij hbeq hfij hfeq (by omega) (by omega),
      P.unrollOf_windowSegments hbij hbeq hfij hfeq (by omega) (by omega)]
    exact P.windowPath_step hne hadj _ _

@[simp]
theorem lassoOfWindow_back (P : IntPresentation) (win : List (Fin P.card)) (hne) (hadj)
    {bi bj fi fj : ℕ} (hbij) (hbeq) (hfij) (hfeq) :
    (P.lassoOfWindow win hne hadj (bi := bi) (bj := bj) (fi := fi) (fj := fj)
      hbij hbeq hfij hfeq).back = P.windowBack win bi bj := rfl

@[simp]
theorem lassoOfWindow_mid (P : IntPresentation) (win : List (Fin P.card)) (hne) (hadj)
    {bi bj fi fj : ℕ} (hbij) (hbeq) (hfij) (hfeq) :
    (P.lassoOfWindow win hne hadj (bi := bi) (bj := bj) (fi := fi) (fj := fj)
      hbij hbeq hfij hfeq).mid = P.windowMid win bi fi := rfl

@[simp]
theorem lassoOfWindow_fwd (P : IntPresentation) (win : List (Fin P.card)) (hne) (hadj)
    {bi bj fi fj : ℕ} (hbij) (hbeq) (hfij) (hfeq) :
    (P.lassoOfWindow win hne hadj (bi := bi) (bj := bj) (fi := fi) (fj := fj)
      hbij hbeq hfij hfeq).fwd = P.windowFwd win fi fj := rfl

/--
**The placed bi-lasso of a window at an arbitrary absolute time.** The origin is set to
`origin - |bwdTail|`, so that the window's first entry lands at exactly the caller's `origin`.
-/
def placedOfWindow (P : IntPresentation) (win : List (Fin P.card)) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    (origin : ℤ) {bi bj fi fj : ℕ} (hbij : bi < bj)
    (hbeq : P.iterPred (P.winPred win) bi = P.iterPred (P.winPred win) bj)
    (hfij : fi < fj)
    (hfeq : P.iterSucc (P.winSucc win) fi = P.iterSucc (P.winSucc win) fj) :
    PlacedBiLasso P :=
  ⟨P.lassoOfWindow win hne hadj hbij hbeq hfij hfeq, origin - (bi : ℤ)⟩

/-- The placed decoding is the intended path, throughout one full coherence window measured from
the caller's own origin. -/
theorem placedOfWindow_unroll (P : IntPresentation) (win : List (Fin P.card)) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    (origin : ℤ) {bi bj fi fj : ℕ} (hbij : bi < bj)
    (hbeq : P.iterPred (P.winPred win) bi = P.iterPred (P.winPred win) bj)
    (hfij : fi < fj)
    (hfeq : P.iterSucc (P.winSucc win) fi = P.iterSucc (P.winSucc win) fj)
    {t : ℤ} (hlo : origin - (bj : ℤ) - 1 ≤ t)
    (hhi : t ≤ origin + (win.length : ℤ) + (fj : ℤ)) :
    (P.placedOfWindow win hne hadj origin hbij hbeq hfij hfeq).unroll t
      = P.windowPath win origin t := by
  have hshift : P.windowPath win (bi : ℤ) (t - (origin - (bi : ℤ)))
      = P.windowPath win origin t := by
    have h := P.windowPath_shift win origin ((bi : ℤ) - origin) t
    rwa [show origin + ((bi : ℤ) - origin) = (bi : ℤ) by omega,
      show t + ((bi : ℤ) - origin) = t - (origin - (bi : ℤ)) by omega] at h
  show BiLasso.unroll (P.lassoOfWindow win hne hadj hbij hbeq hfij hfeq)
      (t - (origin - (bi : ℤ))) = _
  rw [BiLasso.unroll_def]
  simp only [lassoOfWindow_back, lassoOfWindow_mid, lassoOfWindow_fwd]
  rw [P.unrollOf_windowSegments hbij hbeq hfij hfeq (by omega) (by omega)]
  exact hshift

/--
**Fidelity: the certificate really does carry the window.** At every one of the window's own
absolute times, the placed decoding reproduces the window entry. This is what makes the object a
*certificate* about the given bounded history rather than about some other path.
-/
theorem placedOfWindow_unroll_window (P : IntPresentation) (win : List (Fin P.card))
    (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    (origin : ℤ) {bi bj fi fj : ℕ} (hbij : bi < bj)
    (hbeq : P.iterPred (P.winPred win) bi = P.iterPred (P.winPred win) bj)
    (hfij : fi < fj)
    (hfeq : P.iterSucc (P.winSucc win) fi = P.iterSucc (P.winSucc win) fj)
    {k : ℕ} (hk : k < win.length) :
    (P.placedOfWindow win hne hadj origin hbij hbeq hfij hfeq).unroll (origin + (k : ℤ))
      = win.getD k default := by
  have hkz : (k : ℤ) < (win.length : ℤ) := by exact_mod_cast hk
  rw [P.placedOfWindow_unroll win hne hadj origin hbij hbeq hfij hfeq (by omega) (by omega),
    P.windowPath_window win origin hk]

/-! ## Tier A: the effective extension theorem -/

/--
**Effective periodic extension over a presented frame.**

Every non-empty contiguous window of adjacent states, placed at an arbitrary absolute time,
extends to a bi-infinite step path of the presented frame that is **finitely represented**: three
finite lists plus one integer origin, ultimately periodic in both directions with both periods
bounded by `P.card`. The certificate agrees with the window at every one of its own times, and
`BiLasso.coherent` — the property that makes the object a *valid* certificate rather than merely a
well-typed one — is a quantifier over a `Fin`, hence `decide`-able, so a consumer re-verifies a
received certificate without re-running this proof.

## No seriality hypothesis, and that is deliberate

The informal statement of this result says "given a serial relation". No seriality hypothesis
appears here because seriality is already a *field* of the input: `IntPresentation.fwd` and
`IntPresentation.bwd` are exactly forward and backward one-step seriality, and they are what make
`IntPresentation.succOf` and `IntPresentation.predOf` total. Adding a hypothesis would duplicate a
structure field. Read the absence as discharged, not as omitted.

## Contiguous windows only

The window is contiguous by construction — a `List` with adjacency between consecutive entries.
A partial history over a *gapped* finite domain is not handled at this tier; see the
`PartialHistory` wrapper's note below for why a gapped certificate would not be data, and where
the gapped case is delivered instead.

## ON CHOICE

Measured, not asserted:

```
'FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
```

`Classical.choice` is present, from two sources, **neither of which is the successor selection**,
and **neither of which is finiteness**:

1. **The reused decoding lemmas.** `BiLasso.unroll_isStepPath` and both `BiLasso.unroll_*`
   periodicity lemmas measure `[propext, Classical.choice, Quot.sound]`. It enters there
   incidentally, through `BiLasso.length_pos_int`'s `exact_mod_cast` step, and has nothing to do
   with `ℤ` or with the frame. That module is held byte-stable, so this source is not scrubbable
   from here.
2. **Mathlib's list-indexing API.** `List.getD_eq_getElem` and `List.getD_append` both measure
   `[propext, Classical.choice, Quot.sound]`, and every segment-readout lemma here is stated in
   terms of `List.getD`, so `unrollOf_windowSegments` inherits it. The `Nat`-to-`ℤ` coercion step
   in `windowPath_step` carries it by the same mechanism as source 1.

**Pigeonhole is *not* a source, and its absence was work.** The obvious third source — the
finiteness API that forces the orbit to revisit a state — has been removed. Every route to
pigeonhole in Mathlib carries `Classical.choice`, `Finset.card_le_card` included, because
`Finset.card` sits on `Multiset` / `Quot` machinery that pulls it in at the base. That is an API
fact and not a logical obstruction: pigeonhole over a carrier with decidable equality is
constructively valid, and `exists_dup_lt` above proves it directly, by deleting a value and
inducting, at `[propext, Quot.sound]`. `IntPresentation.orbit_repeat` and
`IntPresentation.orbit_repeat_pred` are therefore choice-free.

The successor selection is not a source either. `IntPresentation.succOf` and
`IntPresentation.predOf` measure `[propext, Quot.sound]`, are built from `List.find?` over
`List.finRange`, and are `#eval`-able; so are the three segment lists `windowBack` / `windowMid` /
`windowFwd` this theorem's witness is assembled from, and the intended path `windowPath` they
decode to. The *data* of the certificate is computable throughout; what remains classical is the
*proofs about* it, and both remaining sources are incidental library facts about lists and
numeric coercions rather than anything about frames, finiteness, or time.

Contrast `ParamTaskFrame.spherical_of_finite`, where the obstruction **is** logical and proved:
`wlem_of_spherical` derives weak excluded middle from *Spherical* at the carrier `Bool` over
`D = ℤ` from `[propext, Quot.sound]` alone, so a choice-free proof there would prove WLEM in
Lean's intuitionistic core and cannot exist. Nothing of that kind is known here, and nothing of
that kind is claimed. **No constructivity claim and no impossibility claim is made for
`extend_periodic`** — the two remaining sources look as scrubbable in principle as the pigeonhole
turned out to be, but neither is scrubbable from this module, and no more is asserted than has
been measured.

What *is* preserved, and is a real, non-vacuous difference from the general Extension Theorem:
**no Zorn.** This proof does not route through `PartialHistory.exists_maximal_extension`, and no
module created for it imports `FormalSystem.Semantics.Extension.Extension` — `Extends` and
`PartialHistory` come from `FormalSystem/Semantics/PartialHistory.lean`, which carries no Zorn
route. The general theorem is untouched and remains exactly as it is for arbitrary `W` and `D`;
this strengthens the finite discrete case only.
-/
theorem extend_periodic (P : IntPresentation) (win : List (Fin P.card)) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true)
    (origin : ℤ) :
    ∃ L : PlacedBiLasso P,
      IsStepPath P.toFibre L.unroll ∧
      (∀ k : ℕ, k < win.length → L.unroll (origin + (k : ℤ)) = win.getD k default) ∧
      0 < L.lasso.back.length ∧ L.lasso.back.length ≤ P.card ∧
      0 < L.lasso.fwd.length ∧ L.lasso.fwd.length ≤ P.card ∧
      (∀ t : ℤ, t < L.origin → L.unroll (t - (L.lasso.back.length : ℤ)) = L.unroll t) ∧
      (∀ t : ℤ, L.origin + (L.lasso.mid.length : ℤ) ≤ t →
        L.unroll (t + (L.lasso.fwd.length : ℤ)) = L.unroll t) := by
  obtain ⟨bi, bj, hbij, hbj, hbeq⟩ := P.orbit_repeat_pred (P.winPred win)
  obtain ⟨fi, fj, hfij, hfj, hfeq⟩ := P.orbit_repeat (P.winSucc win)
  refine ⟨P.placedOfWindow win hne hadj origin hbij hbeq hfij hfeq, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact PlacedBiLasso.unroll_isStepPath _
  · intro k hk
    exact P.placedOfWindow_unroll_window win hne hadj origin hbij hbeq hfij hfeq hk
  · show 0 < (P.windowBack win bi bj).length
    rw [P.windowBack_length]; omega
  · show (P.windowBack win bi bj).length ≤ P.card
    rw [P.windowBack_length]; omega
  · show 0 < (P.windowFwd win fi fj).length
    rw [P.windowFwd_length]; omega
  · show (P.windowFwd win fi fj).length ≤ P.card
    rw [P.windowFwd_length]; omega
  · intro t ht
    exact PlacedBiLasso.unroll_sub_back_length _ ht
  · intro t ht
    exact PlacedBiLasso.unroll_add_fwd_length _ ht

/-!
### The `PartialHistory` wrapper

`extend_periodic` takes the window as a list plus an absolute origin, which is the form a search
produces it in. The paper's hypothesis is a bounded world history, so the statement is also given
here in `PartialHistory` vocabulary, over a domain that is exactly an integer interval `[a, b]`.

**Tier A is contiguous-window-only, and deliberately so.** `PartialHistory.domain` is an arbitrary
predicate, so `{0, 5}` is a legal domain with a four-time hole. Filling such a hole needs a path
between two states at a known distance, and the only tool for that here
(`FormalSystem.Semantics.exists_path_of_iter`) yields a `Prop`-level existential filler — so a
gapped certificate would not be *data*, which is the entire point of this tier. The gapped case is
delivered at the frame level instead, where a `Prop`-level conclusion is what is wanted anyway. A
computable gap filler would need a bounded path search over the presentation; that is recorded as
follow-up work rather than silently omitted.
-/

/--
**Effective periodic extension from a bounded partial history.** The same conclusion as
`IntPresentation.extend_periodic`, with the window supplied as a `PartialHistory` whose domain is
the integer interval `[a, b]`.
-/
theorem extend_periodic_of_icc (P : IntPresentation)
    (τ : FormalSystem.Semantics.PartialHistory P.toTaskFrame) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ L : PlacedBiLasso P,
      IsStepPath P.toFibre L.unroll ∧
      (∀ (t : ℤ) (ht : τ.domain t), L.unroll t = τ.states t ht) ∧
      0 < L.lasso.back.length ∧ L.lasso.back.length ≤ P.card ∧
      0 < L.lasso.fwd.length ∧ L.lasso.fwd.length ≤ P.card ∧
      (∀ t : ℤ, t < L.origin → L.unroll (t - (L.lasso.back.length : ℤ)) = L.unroll t) ∧
      (∀ t : ℤ, L.origin + (L.lasso.mid.length : ℤ) ≤ t →
        L.unroll (t + (L.lasso.fwd.length : ℤ)) = L.unroll t) := by
  classical
  -- The states of `τ`, extended by an irrelevant default off its domain.
  set f : ℤ → Fin P.card := fun t => if h : τ.domain t then τ.states t h else default with hf
  set n : ℕ := (b + 1 - a).toNat with hn
  set win : List (Fin P.card) := (List.range n).map (fun k : ℕ => f (a + (k : ℤ))) with hwin
  have hnpos : 0 < n := by omega
  have hlen : win.length = n := by rw [hwin]; simp
  have hget : ∀ k : ℕ, k < n → win.getD k default = f (a + (k : ℤ)) := by
    intro k hk
    rw [hwin]
    rw [List.getD_eq_getElem _ _ (by simp only [List.length_map, List.length_range]; exact hk)]
    simp
  have hne : win ≠ [] := by
    intro h
    have hz : win.length = 0 := by rw [h]; rfl
    omega
  have hfstep : ∀ s : ℤ, a ≤ s → s + 1 ≤ b → P.step (f s) (f (s + 1)) = true := by
    intro s h1 h2
    have hs : τ.domain s := (hdom s).mpr ⟨by omega, by omega⟩
    have hs1 : τ.domain (s + 1) := (hdom (s + 1)).mpr ⟨by omega, by omega⟩
    have hrel := τ.respects_task s (s + 1) hs hs1
    rw [show s + 1 - s = (1 : ℤ) by omega] at hrel
    have hstep : P.toFibre.step (τ.states s hs) (τ.states (s + 1) hs1) :=
      (P.toFibre.taskRel_one_iff_step _ _).mp hrel
    have hb := (P.step_iff _ _).mp hstep
    simpa [hf, hs, hs1] using hb
  have hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true := by
    intro k hk
    rw [hlen] at hk
    rw [hget k (by omega), hget (k + 1) (by omega),
      show a + (((k + 1 : ℕ) : ℕ) : ℤ) = (a + (k : ℤ)) + 1 by push_cast; omega]
    exact hfstep _ (by omega) (by omega)
  obtain ⟨L, hpath, hwindow, h1, h2, h3, h4, h5, h6⟩ := P.extend_periodic win hne hadj a
  refine ⟨L, hpath, ?_, h1, h2, h3, h4, h5, h6⟩
  intro t ht
  obtain ⟨hta, htb⟩ := (hdom t).mp ht
  have hkn : (t - a).toNat < n := by omega
  have hk : (t - a).toNat < win.length := by rw [hlen]; exact hkn
  have hw := hwindow (t - a).toNat hk
  rw [hget _ hkn] at hw
  rw [show a + (((t - a).toNat : ℕ) : ℤ) = t by omega] at hw
  rw [hw, hf]
  exact dif_pos ht

end IntPresentation

end FormalSystem.Metalogic.Decidability
