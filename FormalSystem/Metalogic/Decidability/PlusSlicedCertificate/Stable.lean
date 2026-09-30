/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture

/-!
# The One-Period Transfer Operators on Position Sets

`Φ_back` transfers a set of positions **leftward through one back period**, and `Φ_fwd` transfers
one **rightward through one forward period**. Both are monotone, both are built from a single
one-step operator, and both are `Finset`-valued and decidable.

## What these operators are for

`Fixture.live_not_determined_by_slice` shows that liveness at a time is **not** a function of the
slice at that time: the fixture's slice at `-1` is literally its slice at `-2`, its position set is
the same at both, and yet one position is live at `-1` and occupied by no run at `-2`. So a checker
that reads liveness at a folded window time owes a proof that the fold is faithful, and the object
that proof is about is the orbit of a position set under one period. `Φ_back` is that one-period
map.

The reference times are chosen to match the doubled window endpoints the fixture forces:
`Φ_back` runs from `-G.nb` to `-2 * G.nb` (`Φ_back_subset_posAt`), and `Φ_fwd` from `G.nm + G.nf` to
`G.nm + 2 * G.nf` (`Φ_fwd_subset_posAt`). Those are `cohWindowLo` / `cohWindowHi` of
`WitnessFamily/Sharing/Decide.lean` re-indexed to the sliced certificate's own segment lengths —
window endpoints computed from the certificate's data, never bounds imposed on it.

## Why the operators are sound in the direction they are used

`Φ` is an *over*-approximation and is used as one. `fwdLive_subset_stepBack` is the soundness
statement: if `X` contains every forward-live position at `t`, then one step of the leftward
transfer contains every forward-live position at `t - 1`. The converse is false in general and is
not claimed — a position with a successor in `X` need not be live, because liveness demands a whole
fulfilling run and not merely one edge. That asymmetry is exactly why `TailStable` (sub-phase 16.2)
has to be an equation `Φ_back L₀ = L₀` rather than an inclusion.

## What this module does NOT contain, and where it went

`TailStable`, `L₀` / `R₀`, `tailStable_iff_window` and `exists_tailStable_repr` are **not** here.
They depend on sub-phase 15.3's rolled timed carrier and its computed liveness `Finset` — there is
no computed liveness object yet for `L₀` to be — and the plan's sub-phase split (recorded at its
Phase 16 heading) puts them in 16.2, after 15.3. Nothing is stubbed for them and no placeholder
stands in: the declarations simply do not exist yet.

## Main definitions

- `PlusSlicedCertificate.stepBack` / `stepFwd` — the one-step transfers, with their membership
  characterizations
- `PlusSlicedCertificate.iterBack` / `iterFwd` — the `k`-fold iterates from a reference time
- `PlusSlicedCertificate.Φ_back` / `Φ_fwd` — one full period, at the doubled window's endpoints

## Main results

- `PlusSlicedCertificate.stepBack_mono` / `stepFwd_mono`, `iterBack_mono` / `iterFwd_mono`,
  `Φ_back_mono` / `Φ_fwd_mono` — monotonicity, at each level
- `PlusSlicedCertificate.Φ_back_subset_posAt` / `Φ_fwd_subset_posAt` — the operators land on the
  doubled window's endpoint slices
- `PlusSlicedCertificate.fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` — the soundness
  direction, from `Live.lean`'s `fwdLive_step` / `bwdLive_step`

## Tags

plus-language · certificate · time-sliced · transfer · monotone
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The one-step transfers -/

/--
**One step leftward.** The positions of slice `t - 1` that have a `succP`-successor in `X`.

`X` is read as a set of positions *at slice `t`*; the time is an argument rather than part of the
carrier, exactly as it is for `posAt` and `succP`.
-/
def stepBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) : Finset G.Pos :=
  (G.posAt (t - 1)).filter (fun p => (G.succP (t - 1) p ∩ X).Nonempty)

/-- **One step rightward**, the mirror: the positions of slice `t + 1` that have a
`predP`-predecessor in `X`. -/
def stepFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) : Finset G.Pos :=
  (G.posAt (t + 1)).filter (fun q => (G.predP (t + 1) q ∩ X).Nonempty)

theorem mem_stepBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (p : G.Pos) :
    p ∈ G.stepBack t X ↔ p ∈ G.posAt (t - 1) ∧ ∃ q ∈ G.succP (t - 1) p, q ∈ X := by
  rw [stepBack, Finset.mem_filter]
  constructor
  · rintro ⟨h1, x, hx⟩
    rw [Finset.mem_inter] at hx
    exact ⟨h1, x, hx.1, hx.2⟩
  · rintro ⟨h1, q, hq1, hq2⟩
    exact ⟨h1, q, Finset.mem_inter.mpr ⟨hq1, hq2⟩⟩

theorem mem_stepFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (q : G.Pos) :
    q ∈ G.stepFwd t X ↔ q ∈ G.posAt (t + 1) ∧ ∃ p ∈ G.predP (t + 1) q, p ∈ X := by
  rw [stepFwd, Finset.mem_filter]
  constructor
  · rintro ⟨h1, x, hx⟩
    rw [Finset.mem_inter] at hx
    exact ⟨h1, x, hx.1, hx.2⟩
  · rintro ⟨h1, p, hp1, hp2⟩
    exact ⟨h1, p, Finset.mem_inter.mpr ⟨hp1, hp2⟩⟩

theorem stepBack_subset_posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) :
    G.stepBack t X ⊆ G.posAt (t - 1) := Finset.filter_subset _ _

theorem stepFwd_subset_posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) :
    G.stepFwd t X ⊆ G.posAt (t + 1) := Finset.filter_subset _ _

theorem stepBack_mono (G : PlusSlicedCertificate Γ Del) (t : ℤ) {X Y : Finset G.Pos}
    (h : X ⊆ Y) : G.stepBack t X ⊆ G.stepBack t Y := by
  intro p hp
  rw [mem_stepBack] at hp ⊢
  obtain ⟨hpos, q, hq1, hq2⟩ := hp
  exact ⟨hpos, q, hq1, h hq2⟩

theorem stepFwd_mono (G : PlusSlicedCertificate Γ Del) (t : ℤ) {X Y : Finset G.Pos}
    (h : X ⊆ Y) : G.stepFwd t X ⊆ G.stepFwd t Y := by
  intro q hq
  rw [mem_stepFwd] at hq ⊢
  obtain ⟨hpos, p, hp1, hp2⟩ := hq
  exact ⟨hpos, p, hp1, h hp2⟩

/-! ## The iterates -/

/--
**The `k`-fold leftward transfer from reference time `t`.** `iterBack t X k` is a set of
positions at slice `t - k`: each step decrements the time it is applied at, so the times visited
are `t, t - 1, …, t - k`.
-/
def iterBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) : ℕ → Finset G.Pos
  | 0 => X
  | (k + 1) => G.stepBack (t - (k : ℤ)) (G.iterBack t X k)

/-- **The `k`-fold rightward transfer from reference time `t`**, landing on slice `t + k`. -/
def iterFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) : ℕ → Finset G.Pos
  | 0 => X
  | (k + 1) => G.stepFwd (t + (k : ℤ)) (G.iterFwd t X k)

@[simp] theorem iterBack_zero (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) :
    G.iterBack t X 0 = X := rfl

@[simp] theorem iterFwd_zero (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) :
    G.iterFwd t X 0 = X := rfl

theorem iterBack_succ (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (k : ℕ) :
    G.iterBack t X (k + 1) = G.stepBack (t - (k : ℤ)) (G.iterBack t X k) := rfl

theorem iterFwd_succ (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (k : ℕ) :
    G.iterFwd t X (k + 1) = G.stepFwd (t + (k : ℤ)) (G.iterFwd t X k) := rfl

/-- **The leftward iterate lands on the slice it says it does.** -/
theorem iterBack_subset_posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (k : ℕ) : G.iterBack t X (k + 1) ⊆ G.posAt (t - (k + 1 : ℤ)) := by
  rw [iterBack_succ]
  have h : t - (k : ℤ) - 1 = t - (k + 1 : ℤ) := by omega
  rw [← h]
  exact stepBack_subset_posAt _ _ _

/-- **The rightward iterate lands on the slice it says it does.** -/
theorem iterFwd_subset_posAt (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (k : ℕ) : G.iterFwd t X (k + 1) ⊆ G.posAt (t + (k + 1 : ℤ)) := by
  rw [iterFwd_succ]
  have h : t + (k : ℤ) + 1 = t + (k + 1 : ℤ) := by omega
  rw [← h]
  exact stepFwd_subset_posAt _ _ _

theorem iterBack_mono (G : PlusSlicedCertificate Γ Del) (t : ℤ) {X Y : Finset G.Pos} (h : X ⊆ Y)
    (k : ℕ) : G.iterBack t X k ⊆ G.iterBack t Y k := by
  induction k with
  | zero => exact h
  | succ k ih => exact G.stepBack_mono _ ih

theorem iterFwd_mono (G : PlusSlicedCertificate Γ Del) (t : ℤ) {X Y : Finset G.Pos} (h : X ⊆ Y)
    (k : ℕ) : G.iterFwd t X k ⊆ G.iterFwd t Y k := by
  induction k with
  | zero => exact h
  | succ k ih => exact G.stepFwd_mono _ ih

/-! ## One full period

The reference times are the endpoints of the **single**-period window, and the images are the
endpoints of the **doubled** one. That is the arithmetic content of the fixture's verdict, stated as
two subset lemmas rather than left implicit in the definitions.
-/

/-- **`Φ_back`**: the one-period leftward transfer, from `-G.nb` to `-2 * G.nb`. -/
def Φ_back (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) : Finset G.Pos :=
  G.iterBack (-G.nb) X G.back.length

/-- **`Φ_fwd`**: the one-period rightward transfer, from `G.nm + G.nf` to `G.nm + 2 * G.nf`. -/
def Φ_fwd (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) : Finset G.Pos :=
  G.iterFwd (G.nm + G.nf) X G.fwd.length

theorem Φ_back_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.Pos} (h : X ⊆ Y) :
    G.Φ_back X ⊆ G.Φ_back Y := G.iterBack_mono _ h _

theorem Φ_fwd_mono (G : PlusSlicedCertificate Γ Del) {X Y : Finset G.Pos} (h : X ⊆ Y) :
    G.Φ_fwd X ⊆ G.Φ_fwd Y := G.iterFwd_mono _ h _

/-- **`Φ_back` is monotone**, in the lattice sense `Finset` carries. -/
theorem monotone_Φ_back (G : PlusSlicedCertificate Γ Del) : Monotone G.Φ_back :=
  fun _ _ h => G.Φ_back_mono h

/-- **`Φ_fwd` is monotone.** -/
theorem monotone_Φ_fwd (G : PlusSlicedCertificate Γ Del) : Monotone G.Φ_fwd :=
  fun _ _ h => G.Φ_fwd_mono h

/-- **`Φ_back` lands on the doubled window's left endpoint slice.** -/
theorem Φ_back_subset_posAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) :
    G.Φ_back X ⊆ G.posAt (-2 * G.nb) := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, G.back.length = k + 1 := by
    have h : G.back.length ≠ 0 := fun h => G.back_ne (List.eq_nil_of_length_eq_zero h)
    exact ⟨G.back.length - 1, by omega⟩
  have hnb : G.nb = ((k : ℤ) + 1) := by
    rw [show G.nb = (G.back.length : ℤ) from rfl, hk]
    push_cast
    omega
  rw [Φ_back, hk]
  have h := G.iterBack_subset_posAt (-G.nb) X k
  rw [show -G.nb - ((k : ℤ) + 1) = -2 * G.nb from by rw [hnb]; omega] at h
  exact h

/-- **`Φ_fwd` lands on the doubled window's right endpoint slice.** -/
theorem Φ_fwd_subset_posAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) :
    G.Φ_fwd X ⊆ G.posAt (G.nm + 2 * G.nf) := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, G.fwd.length = k + 1 := by
    have h : G.fwd.length ≠ 0 := fun h => G.fwd_ne (List.eq_nil_of_length_eq_zero h)
    exact ⟨G.fwd.length - 1, by omega⟩
  have hnf : G.nf = ((k : ℤ) + 1) := by
    rw [show G.nf = (G.fwd.length : ℤ) from rfl, hk]
    push_cast
    omega
  rw [Φ_fwd, hk]
  have h := G.iterFwd_subset_posAt (G.nm + G.nf) X k
  rw [show G.nm + G.nf + ((k : ℤ) + 1) = G.nm + 2 * G.nf from by rw [hnf]; omega] at h
  exact h

/-! ## Soundness of the transfer

The direction the design uses, and the only one available: `Φ` over-approximates. See this module's
header for why the converse is false and why `TailStable` is therefore an equation.
-/

/--
**One leftward step preserves a forward-liveness over-approximation.**

If `X` contains every forward-live position at `t`, then `G.stepBack t X` contains every
forward-live position at `t - 1`. The witness is `Live.lean`'s `fwdLive_step`: a forward-live
position has a `succP`-successor that is itself forward-live one slice later.
-/
theorem fwdLive_subset_stepBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ q, G.FwdLive t q → q ∈ X) {p : G.Pos} (hp : G.FwdLive (t - 1) p) :
    p ∈ G.stepBack t X := by
  rw [mem_stepBack]
  refine ⟨G.mem_posAt_of_fwdLive hp, ?_⟩
  obtain ⟨q, hq1, hq2⟩ := G.fwdLive_step hp
  rw [show t - 1 + 1 = t from by omega] at hq2
  exact ⟨q, hq1, hX q hq2⟩

/--
**One rightward step preserves a backward-liveness over-approximation**, the mirror of
`fwdLive_subset_stepBack`, with `bwdLive_step` as the witness.
-/
theorem bwdLive_subset_stepFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ p, G.BwdLive t p → p ∈ X) {q : G.Pos} (hq : G.BwdLive (t + 1) q) :
    q ∈ G.stepFwd t X := by
  rw [mem_stepFwd]
  refine ⟨?_, ?_⟩
  · obtain ⟨R, -, hR⟩ := hq
    rw [← hR]
    exact R.pos_mem_posAt (t + 1)
  · obtain ⟨p, hp1, hp2⟩ := G.bwdLive_step hq
    exact ⟨p, hp1, hX p hp2⟩

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
