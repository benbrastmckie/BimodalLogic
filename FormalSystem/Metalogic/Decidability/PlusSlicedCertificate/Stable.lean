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

## Why the period is the combined one

The reference times are the endpoints of the window itself: `Φ_back` runs from `-G.NB` to
`G.winLo = -2 * G.NB` (`Φ_back_subset_posAt`), and `Φ_fwd` from `G.NM + G.NF` to
`G.winHi = G.NM + 2 * G.NF` (`Φ_fwd_subset_posAt`). Those are `cohWindowLo` / `cohWindowHi` of
`WitnessFamily/Sharing/Decide.lean` re-indexed to the sliced certificate's own combined segment
lengths — window endpoints computed from the certificate's data, never bounds imposed on it.

The period is `Window.lean`'s **combined** `G.NB` / `G.NF` and not the single-object `G.nb` /
`G.nf`, and the reason is forced rather than stylistic. `Timed.lean`'s fold is what tail-stability
exists to certify, and `prevTime_edge` / `nextTime_edge` say which times that fold identifies: the
left edge sends the unwrapped predecessor `-2 * G.NB - 1` to the window time `-G.NB - 1`, a shift of
`G.NB`, and the right edge shifts by `G.NF`. An operator fixed for one `G.nb`-period would say
nothing about a fold that moves by `G.NB`. The two reference times are therefore both window times
(`neg_NB_mem_winTimes`, `NM_add_NF_mem_winTimes`), and the sets `L₀` / `R₀` read off `G.liveT` at
them are exactly the declarative live sets there (`mem_liveAt_iff_live`).

## Why the operators are sound in the direction they are used

`Φ` is an *over*-approximation and is used as one. `fwdLive_subset_stepBack` is the soundness
statement: if `X` contains every forward-live position at `t`, then one step of the leftward
transfer contains every forward-live position at `t - 1`. The converse is false in general and is
not claimed — a position with a successor in `X` need not be live, because liveness demands a whole
fulfilling run and not merely one edge. That asymmetry is exactly why `TailStable` (sub-phase 16.2)
has to be an equation `Φ_back L₀ = L₀` rather than an inclusion.

## SCOPE: which half of the design's linchpin is landed here, and which is not

`TailStable` is defined here, it is `Decidable`, and the direction of its consequence that a
soundness argument needs is **proved** here for every time down the periodic tail:
`mem_L₀_of_live_tail` and `live_ref_of_live_tail` (with their right-tail mirrors). The converse
direction — that every member of `L₀` is genuinely live at every tail time, and not only at the
reference time where `live_of_mem_L₀` gives it — is **not** here, and nothing below is stated as
though it were.

That converse is not a formality and it is not obtainable from the material in this module. `Live`
is witnessed only by a bi-infinite `LabRun`, and no shift of a run is a run: `LabRun.agrees` and
`LabRun.steps` are conditions at *every* time, while the slice sequence is periodic only on the
negatives. The route that does work, recorded here so it is not rediscovered, is a **three-region**
run: the reference run's left half shifted by `k * G.NB` on `u ≤ -(k + 1) * G.NB`, then the finite
`Φ_back`-path that `L₀ ⊆ G.Φ_back L₀` supplies, then the reference run of the path's endpoint on
`u ≥ -G.NB`; fulfilment in both directions then comes from `plusFwdFulfilling_of_ge` and
`plusBwdFulfilling_of_le`, and the seams from the same assembly `Bridge.lean`'s `runOfWalks` already
performs for two regions. It is the remaining obligation of sub-phase 16.2, together with
`exists_tailStable_repr` and the fixture's worked example; neither is stubbed and no placeholder
stands in for either.

## Main definitions

- `PlusSlicedCertificate.stepBack` / `stepFwd` — the one-step transfers, with their membership
  characterizations
- `PlusSlicedCertificate.iterBack` / `iterFwd` — the `k`-fold iterates from a reference time
- `PlusSlicedCertificate.Φ_back` / `Φ_fwd` — one full combined period, at the window's endpoints
- `PlusSlicedCertificate.liveAt` — the computed live positions at a time
- `PlusSlicedCertificate.L₀` / `R₀` — those sets at the two reference times
- `PlusSlicedCertificate.TailStable` — the wrap-faithfulness demand, with `decidableTailStable`

## Main results

- `PlusSlicedCertificate.stepBack_mono` / `stepFwd_mono`, `iterBack_mono` / `iterFwd_mono`,
  `Φ_back_mono` / `Φ_fwd_mono` — monotonicity, at each level
- `PlusSlicedCertificate.Φ_back_subset_posAt` / `Φ_fwd_subset_posAt` — the operators land on the
  window's own endpoint slices
- `PlusSlicedCertificate.fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` — the soundness
  direction, from `Live.lean`'s `fwdLive_step` / `bwdLive_step`
- `PlusSlicedCertificate.live_subset_stepBack` / `live_subset_stepFwd` and their iterates — the same
  soundness for two-directional `Live`, which is what `L₀` is a set of
- `PlusSlicedCertificate.stepBack_congr` / `iterBack_congr` / `iterBack_shift` and mirrors — the
  transfer transported along a period of the slice sequence
- `PlusSlicedCertificate.iterBack_L₀` / `iterFwd_R₀` — one application iterated to `k`
- `PlusSlicedCertificate.mem_L₀_of_live_tail` / `live_ref_of_live_tail` and mirrors — **the half of
  the linchpin that is landed**; see the scope note above
- `PlusSlicedCertificate.mem_L₀_iff_live` / `mem_R₀_iff_live` — exactness at the reference times

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

The reference times are the endpoints of the **window itself**, `[G.winLo, G.winHi)`: `Φ_back` runs
from `-G.NB` (`= G.winLo + G.NB`) to `G.winLo` (`= -2 * G.NB`), and `Φ_fwd` from `G.NM + G.NF`
(`= G.winHi - G.NF`) to `G.winHi` (`= G.NM + 2 * G.NF`). The period is the **combined** `G.NB` /
`G.NF` of `Window.lean` and not the single-object `G.nb` / `G.nf`; see "Why the period is the
combined one" in this module's header.
-/

theorem NBnat_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.NBnat := by
  have h := G.NB_pos
  rw [NB] at h
  exact_mod_cast h

theorem NFnat_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.NFnat := by
  have h := G.NF_pos
  rw [NF] at h
  exact_mod_cast h

/-- **`Φ_back`**: the one-period leftward transfer, from `-G.NB` to `G.winLo = -2 * G.NB`. -/
def Φ_back (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) : Finset G.Pos :=
  G.iterBack (-G.NB) X G.NBnat

/-- **`Φ_fwd`**: the one-period rightward transfer, from `G.NM + G.NF` to
`G.winHi = G.NM + 2 * G.NF`. -/
def Φ_fwd (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) : Finset G.Pos :=
  G.iterFwd (G.NM + G.NF) X G.NFnat

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

/-- **`Φ_back` lands on the window's own left endpoint slice.** -/
theorem Φ_back_subset_posAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) :
    G.Φ_back X ⊆ G.posAt G.winLo := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, G.NBnat = k + 1 := ⟨G.NBnat - 1, by have := G.NBnat_pos; omega⟩
  have hNB : G.NB = ((k : ℤ) + 1) := by
    rw [NB, hk]
    push_cast
    omega
  rw [Φ_back, hk]
  have h := G.iterBack_subset_posAt (-G.NB) X k
  rw [show -G.NB - ((k : ℤ) + 1) = G.winLo from by
    rw [show G.winLo = -2 * G.NB from rfl, hNB]; omega] at h
  exact h

/-- **`Φ_fwd` lands on the window's own right endpoint slice.** -/
theorem Φ_fwd_subset_posAt (G : PlusSlicedCertificate Γ Del) (X : Finset G.Pos) :
    G.Φ_fwd X ⊆ G.posAt G.winHi := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, G.NFnat = k + 1 := ⟨G.NFnat - 1, by have := G.NFnat_pos; omega⟩
  have hNF : G.NF = ((k : ℤ) + 1) := by
    rw [NF, hk]
    push_cast
    omega
  rw [Φ_fwd, hk]
  have h := G.iterFwd_subset_posAt (G.NM + G.NF) X k
  rw [show G.NM + G.NF + ((k : ℤ) + 1) = G.winHi from by
    rw [show G.winHi = G.NM + 2 * G.NF from rfl, hNF]; omega] at h
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

/-! ## Transporting the transfer along the slice sequence

`stepBack t` reads the time only through `G.slice (t - 1)` (via `posAt (t - 1)` and `edge (t - 1)`)
and `G.slice t` (via `posAt t`, inside `succP (t - 1)`); `stepFwd t` mirrors it. So each iterate
is a function of the finitely many slices it touches, and on the negatives — where the slice
sequence is `G.nb`-periodic, hence `G.NB`-periodic — an iterate may be **shifted by a whole
period** without changing it. That is the one fact every statement in the rest of this module
rests on, and it is proved here rather than assumed.
-/

theorem stepBack_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (h0 : G.slice t = G.slice s)
    (h1 : G.slice (t - 1) = G.slice (s - 1)) (X : Finset G.Pos) :
    G.stepBack t X = G.stepBack s X := by
  have hsucc : ∀ p : G.Pos, G.succP (t - 1) p = G.succP (s - 1) p := by
    intro p
    refine G.succP_congr h1 ?_ p
    rw [show t - 1 + 1 = t from by omega, show s - 1 + 1 = s from by omega]
    exact h0
  ext p
  rw [mem_stepBack, mem_stepBack, G.posAt_congr h1, hsucc p]

theorem stepFwd_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (h0 : G.slice t = G.slice s)
    (h1 : G.slice (t + 1) = G.slice (s + 1)) (X : Finset G.Pos) :
    G.stepFwd t X = G.stepFwd s X := by
  have hpred : ∀ q : G.Pos, G.predP (t + 1) q = G.predP (s + 1) q := by
    intro q
    refine G.predP_congr ?_ q
    rw [show t + 1 - 1 = t from by omega, show s + 1 - 1 = s from by omega]
    exact h0
  ext q
  rw [mem_stepFwd, mem_stepFwd, G.posAt_congr h1, hpred q]

/-- **The leftward iterate depends on its reference time only through the slices it visits.** -/
theorem iterBack_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (X : Finset G.Pos) (k : ℕ)
    (h : ∀ j : ℕ, j ≤ k → G.slice (t - (j : ℤ)) = G.slice (s - (j : ℤ))) :
    G.iterBack t X k = G.iterBack s X k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [iterBack_succ, iterBack_succ, ih (fun j hj => h j (by omega))]
    refine G.stepBack_congr (h k (by omega)) ?_ _
    rw [show t - (k : ℤ) - 1 = t - ((k + 1 : ℕ) : ℤ) from by push_cast; omega,
      show s - (k : ℤ) - 1 = s - ((k + 1 : ℕ) : ℤ) from by push_cast; omega]
    exact h (k + 1) le_rfl

/-- **The rightward iterate**, likewise. -/
theorem iterFwd_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (X : Finset G.Pos) (k : ℕ)
    (h : ∀ j : ℕ, j ≤ k → G.slice (t + (j : ℤ)) = G.slice (s + (j : ℤ))) :
    G.iterFwd t X k = G.iterFwd s X k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [iterFwd_succ, iterFwd_succ, ih (fun j hj => h j (by omega))]
    refine G.stepFwd_congr (h k (by omega)) ?_ _
    rw [show t + (k : ℤ) + 1 = t + ((k + 1 : ℕ) : ℤ) from by push_cast; omega,
      show s + (k : ℤ) + 1 = s + ((k + 1 : ℕ) : ℤ) from by push_cast; omega]
    exact h (k + 1) le_rfl

/-! ### Composition

Splitting an iterate at an intermediate time. This is what turns the **one**-application demand
`Φ_back L₀ = L₀` into the `k`-application fact `Φ_back^[k] L₀ = L₀` without ever writing
`Function.iterate`: the `k`-th period's iterate is the first period's iterate, run from a reference
time one period further left.
-/

theorem iterBack_add (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (a b : ℕ) :
    G.iterBack t X (a + b) = G.iterBack (t - (a : ℤ)) (G.iterBack t X a) b := by
  induction b with
  | zero => rfl
  | succ b ih =>
    rw [← add_assoc, iterBack_succ, iterBack_succ, ih,
      show t - (a : ℤ) - (b : ℤ) = t - ((a + b : ℕ) : ℤ) from by push_cast; omega]

theorem iterFwd_add (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos) (a b : ℕ) :
    G.iterFwd t X (a + b) = G.iterFwd (t + (a : ℤ)) (G.iterFwd t X a) b := by
  induction b with
  | zero => rfl
  | succ b ih =>
    rw [← add_assoc, iterFwd_succ, iterFwd_succ, ih,
      show t + (a : ℤ) + (b : ℤ) = t + ((a + b : ℕ) : ℤ) from by push_cast; omega]

/-! ### Periodicity at a multiple of the period

`Basic.lean`'s `slice_periodic_back` / `slice_periodic_fwd` shift by **one** component period. The
shift a whole `Φ` application needs is by a multiple of the **combined** one, and these four lemmas
supply it by residue rather than by iterating the one-step form.
-/

/-- **The slice sequence on the negatives is invariant under any nonnegative multiple of
`G.nb`.** -/
theorem slice_sub_dvd_of_neg (G : PlusSlicedCertificate Γ Del) {t m : ℤ} (ht : t < 0)
    (hm : 0 ≤ m) (hdvd : G.nb ∣ m) : G.slice (t - m) = G.slice t := by
  rw [G.slice_neg (show t - m < 0 from by omega), G.slice_neg ht]
  refine Periodic.cyc_congr ?_
  have h0 : m ≡ 0 [ZMOD G.nb] := Int.modEq_zero_iff_dvd.mpr hdvd
  have h1 : t - m ≡ t [ZMOD G.nb] := by
    simpa using Int.ModEq.sub (Int.ModEq.refl t) h0
  exact h1

/-- **The slice sequence at or past `G.nm` is invariant under any nonnegative multiple of
`G.nf`.** -/
theorem slice_add_dvd_of_ge (G : PlusSlicedCertificate Γ Del) {t m : ℤ} (ht : G.nm ≤ t)
    (hm : 0 ≤ m) (hdvd : G.nf ∣ m) : G.slice (t + m) = G.slice t := by
  rw [G.slice_fwd (show G.nm ≤ t + m from by omega), G.slice_fwd ht]
  refine Periodic.cyc_congr ?_
  have h0 : m ≡ 0 [ZMOD G.nf] := Int.modEq_zero_iff_dvd.mpr hdvd
  have h1 : t + m - G.nm ≡ t - G.nm [ZMOD G.nf] := by
    simpa using Int.ModEq.sub_right G.nm ((Int.ModEq.refl t).add h0)
  exact h1

theorem slice_sub_mul_NB_of_neg (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) (k : ℕ) :
    G.slice (t - (k : ℤ) * G.NB) = G.slice t :=
  G.slice_sub_dvd_of_neg ht
    (mul_nonneg (Int.natCast_nonneg k) (le_of_lt G.NB_pos)) (G.nb_dvd_NB.mul_left _)

theorem slice_add_mul_NF_of_ge (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.nm ≤ t) (k : ℕ) :
    G.slice (t + (k : ℤ) * G.NF) = G.slice t :=
  G.slice_add_dvd_of_ge ht
    (mul_nonneg (Int.natCast_nonneg k) (le_of_lt G.NF_pos)) (G.nf_dvd_NF.mul_left _)

/-- **An iterate on the negatives may be shifted left by any multiple of the combined back
period.** -/
theorem iterBack_shift (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) (X : Finset G.Pos)
    (j k : ℕ) : G.iterBack (t - (k : ℤ) * G.NB) X j = G.iterBack t X j := by
  refine G.iterBack_congr X j (fun i _ => ?_)
  rw [sub_right_comm]
  exact G.slice_sub_mul_NB_of_neg (by omega) k

/-- **An iterate at or past `G.nm` may be shifted right by any multiple of the combined forward
period.** -/
theorem iterFwd_shift (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.nm ≤ t) (X : Finset G.Pos)
    (j k : ℕ) : G.iterFwd (t + (k : ℤ) * G.NF) X j = G.iterFwd t X j := by
  refine G.iterFwd_congr X j (fun i _ => ?_)
  rw [add_right_comm]
  exact G.slice_add_mul_NF_of_ge (by omega) k

/-! ## The live-position sets at the two reference times

`L₀` and `R₀` are read off sub-phase 15.3's **computed** liveness `Finset` `G.liveT` and not off the
declarative `Live`, because that is what makes them decidable. `Bridge.lean`'s `live_iff_mem_liveT`
is what says the choice costs nothing at a window time: there the two agree exactly.

Both reference times are window times (`neg_NB_mem_winTimes`, `NM_add_NF_mem_winTimes`), which is
the whole reason the reference times were re-indexed to the combined periods — see the deviation
note at the plan's Phase 16 heading.
-/

/-- **The computed live positions at a time**, as a set of positions rather than of timed ones. -/
def liveAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) : Finset G.Pos :=
  (G.posAt s).filter (fun p => (p, s) ∈ G.liveT)

theorem mem_liveAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) (p : G.Pos) :
    p ∈ G.liveAt s ↔ p ∈ G.posAt s ∧ (p, s) ∈ G.liveT := Finset.mem_filter

theorem liveAt_subset_posAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) :
    G.liveAt s ⊆ G.posAt s := Finset.filter_subset _ _

theorem mem_liveAt_of_live (G : PlusSlicedCertificate Γ Del) {s : ℤ} (hs : s ∈ G.winTimes)
    {p : G.Pos} (hp : G.Live s p) : p ∈ G.liveAt s :=
  (G.mem_liveAt s p).mpr ⟨G.mem_posAt_of_live hp, G.mem_liveT_of_live hs hp⟩

theorem live_of_mem_liveAt (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {s : ℤ}
    (hs : s ∈ G.winTimes) {p : G.Pos} (hp : p ∈ G.liveAt s) : G.Live s p :=
  (G.live_iff_mem_liveT hbox hs p).mpr ((G.mem_liveAt s p).mp hp).2

/-- **At a window time `liveAt` is exactly the declarative live set.** -/
theorem mem_liveAt_iff_live (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {s : ℤ}
    (hs : s ∈ G.winTimes) (p : G.Pos) : p ∈ G.liveAt s ↔ G.Live s p :=
  ⟨G.live_of_mem_liveAt hbox hs, G.mem_liveAt_of_live hs⟩

/-! ### The three reference times are window times -/

theorem neg_NB_mem_winTimes (G : PlusSlicedCertificate Γ Del) : -G.NB ∈ G.winTimes := by
  have h1 := G.NB_pos
  have h2 := G.NF_pos
  have h3 := G.NM_nonneg
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes]
  omega

theorem NM_add_NF_mem_winTimes (G : PlusSlicedCertificate Γ Del) : G.NM + G.NF ∈ G.winTimes := by
  have h1 := G.NB_pos
  have h2 := G.NF_pos
  have h3 := G.NM_nonneg
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes]
  omega

theorem winLo_mem_winTimes (G : PlusSlicedCertificate Γ Del) : G.winLo ∈ G.winTimes := by
  rw [G.mem_winTimes]
  exact ⟨le_rfl, G.winLo_lt_winHi⟩

/-! ## Tail-stability -/

/-- **`L₀`**: the computed live positions at the window's left reference time `-G.NB`. -/
def L₀ (G : PlusSlicedCertificate Γ Del) : Finset G.Pos := G.liveAt (-G.NB)

/-- **`R₀`**: the computed live positions at the window's right reference time `G.NM + G.NF`. -/
def R₀ (G : PlusSlicedCertificate Γ Del) : Finset G.Pos := G.liveAt (G.NM + G.NF)

/--
**Tail-stability.** One application of each period transfer leaves the reference set fixed.

This is a **wrap-faithfulness** demand and not a finiteness device: termination of the liveness
computation already comes from `Nu.gfp`'s explicit `V.card` bound on the rolled carrier. What is at
stake here is whether the liveness read at a folded window time really is the liveness at every
time that window time represents — and `Fixture.live_not_determined_by_slice` proves that it need
not be, so something has to be demanded. This is that demand.

It is an **equation** and not an inclusion because `Φ` over-approximates in only one direction:
`fwdLive_subset_stepBack` holds and its converse fails, since a position with a successor in `X`
need not be live. The equation is what closes the gap the inclusion leaves.
-/
def TailStable (G : PlusSlicedCertificate Γ Del) : Prop :=
  G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ = G.R₀

instance decidableTailStable (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable :=
  inferInstanceAs (Decidable (G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ = G.R₀))

/-- **The instance is synthesized, not asserted.** -/
example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable := inferInstance

/-- **One application iterated.** Under tail-stability every whole-period leftward iterate of `L₀`
from the reference time is `L₀` again — the content the plan's Scope Hypothesis calls "immediate
from the equation", made a theorem because the reference time moves with each period and the shift
has to be justified by `iterBack_shift`. -/
theorem iterBack_L₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    G.iterBack (-G.NB) G.L₀ (k * G.NBnat) = G.L₀ := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterBack_add, ih,
      show ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB from by rw [NB, Nat.cast_mul],
      G.iterBack_shift (by have := G.NB_pos; omega) G.L₀ G.NBnat k]
    exact hTS.1

/-- **`Φ_fwd` iterated**, the mirror. -/
theorem iterFwd_R₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) = G.R₀ := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterFwd_add, ih,
      show ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF from by rw [NF, Nat.cast_mul],
      G.iterFwd_shift (by have := G.NF_pos; have := G.nm_le_NM; omega) G.R₀ G.NFnat k]
    exact hTS.2

/-! ## The transfer is sound for two-directional liveness too

`fwdLive_subset_stepBack` is about `FwdLive`, and `L₀` is a set of **two**-directionally live
positions, so the soundness statement the headline needs is this one rather than that one. It is not
a weakening of it: the witness is `live_iff`'s single fully fulfilling run, and every position that
run occupies is live in both directions at once (`live_of_path`), so no second splice is needed.
-/

theorem live_subset_stepBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ q, G.Live t q → q ∈ X) {p : G.Pos} (hp : G.Live (t - 1) p) :
    p ∈ G.stepBack t X := by
  obtain ⟨R, hf, hpos⟩ := G.exists_path_of_live hp
  rw [mem_stepBack]
  refine ⟨G.mem_posAt_of_live hp, R.pos t, ?_, hX _ (G.live_of_path R hf t)⟩
  rw [← hpos]
  have h := R.pos_mem_succP (t - 1)
  rw [show t - 1 + 1 = t from by omega] at h
  exact h

theorem live_subset_stepFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ p, G.Live t p → p ∈ X) {q : G.Pos} (hq : G.Live (t + 1) q) :
    q ∈ G.stepFwd t X := by
  obtain ⟨R, hf, hpos⟩ := G.exists_path_of_live hq
  rw [mem_stepFwd]
  refine ⟨G.mem_posAt_of_live hq, R.pos t, ?_, hX _ (G.live_of_path R hf t)⟩
  rw [← hpos]
  exact R.pos_mem_predP t

theorem live_subset_iterBack (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ q, G.Live t q → q ∈ X) (k : ℕ) :
    ∀ p : G.Pos, G.Live (t - (k : ℤ)) p → p ∈ G.iterBack t X k := by
  induction k with
  | zero =>
    intro p hp
    exact hX p (by simpa using hp)
  | succ k ih =>
    intro p hp
    rw [iterBack_succ]
    refine G.live_subset_stepBack (t - (k : ℤ)) _ (fun q hq => ih q hq) ?_
    rw [show t - (k : ℤ) - 1 = t - ((k + 1 : ℕ) : ℤ) from by push_cast; omega]
    exact hp

theorem live_subset_iterFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ) (X : Finset G.Pos)
    (hX : ∀ p, G.Live t p → p ∈ X) (k : ℕ) :
    ∀ q : G.Pos, G.Live (t + (k : ℤ)) q → q ∈ G.iterFwd t X k := by
  induction k with
  | zero =>
    intro q hq
    exact hX q (by simpa using hq)
  | succ k ih =>
    intro q hq
    rw [iterFwd_succ]
    refine G.live_subset_stepFwd (t + (k : ℤ)) _ (fun p hp => ih p hp) ?_
    rw [show t + (k : ℤ) + 1 = t + ((k + 1 : ℕ) : ℤ) from by push_cast; omega]
    exact hq

/-! ## What tail-stability buys: the tail collapses onto the reference time

The two implications below are the halves of the plan's `tailStable_iff_window`. Read the scope note
in this module's header before citing either: the **first** half is proved here for every time down
the periodic tail, and the **second** is proved here only *at* the reference time. Nothing pretends
otherwise, and no declaration below is stated more strongly than it is proved.
-/

/--
**First half: liveness anywhere down the periodic left tail is captured by `L₀`.**

The `∀ t` claim Phase 17's *universal* side needs. A universal clause checked against the positions
of `L₀` therefore holds at every time `-G.NB - k * G.NB`, without the checker ever looking outside
the window.
-/
theorem mem_L₀_of_live_tail (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ)
    {p : G.Pos} (hp : G.Live (-G.NB - (k : ℤ) * G.NB) p) : p ∈ G.L₀ := by
  have hcast : ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB := by rw [NB, Nat.cast_mul]
  have hX : ∀ q, G.Live (-G.NB) q → q ∈ G.L₀ := fun q hq =>
    G.mem_liveAt_of_live G.neg_NB_mem_winTimes hq
  have hp' : G.Live (-G.NB - ((k * G.NBnat : ℕ) : ℤ)) p := by rw [hcast]; exact hp
  have h := G.live_subset_iterBack (-G.NB) G.L₀ hX (k * G.NBnat) p hp'
  rwa [G.iterBack_L₀ hTS k] at h

/-- **The mirror, on the right tail.** -/
theorem mem_R₀_of_live_head (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ)
    {q : G.Pos} (hq : G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q) : q ∈ G.R₀ := by
  have hcast : ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF := by rw [NF, Nat.cast_mul]
  have hX : ∀ p, G.Live (G.NM + G.NF) p → p ∈ G.R₀ := fun p hp =>
    G.mem_liveAt_of_live G.NM_add_NF_mem_winTimes hp
  have hq' : G.Live (G.NM + G.NF + ((k * G.NFnat : ℕ) : ℤ)) q := by rw [hcast]; exact hq
  have h := G.live_subset_iterFwd (G.NM + G.NF) G.R₀ hX (k * G.NFnat) q hq'
  rwa [G.iterFwd_R₀ hTS k] at h

/-- **Second half, at the reference time.** No tail-stability is needed here: it is
`Bridge.lean`'s equality read at a window time. -/
theorem live_of_mem_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {p : G.Pos}
    (hp : p ∈ G.L₀) : G.Live (-G.NB) p :=
  G.live_of_mem_liveAt hbox G.neg_NB_mem_winTimes hp

/-- **The mirror.** -/
theorem live_of_mem_R₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) {q : G.Pos}
    (hq : q ∈ G.R₀) : G.Live (G.NM + G.NF) q :=
  G.live_of_mem_liveAt hbox G.NM_add_NF_mem_winTimes hq

/-- **`L₀` is exactly the live set at its own reference time.** -/
theorem mem_L₀_iff_live (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) (p : G.Pos) :
    p ∈ G.L₀ ↔ G.Live (-G.NB) p :=
  G.mem_liveAt_iff_live hbox G.neg_NB_mem_winTimes p

/-- **`R₀` is exactly the live set at its own reference time.** -/
theorem mem_R₀_iff_live (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful) (q : G.Pos) :
    q ∈ G.R₀ ↔ G.Live (G.NM + G.NF) q :=
  G.mem_liveAt_iff_live hbox G.NM_add_NF_mem_winTimes q

/--
**The collapse, as one statement.** Under tail-stability, a position live anywhere down the periodic
left tail is live at the window's left reference time. This is the form Phase 17's universal side
cites: it turns a `∀ t` obligation over the whole left half-line into an obligation at one window
time.
-/
theorem live_ref_of_live_tail (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {p : G.Pos}
    (hp : G.Live (-G.NB - (k : ℤ) * G.NB) p) : G.Live (-G.NB) p :=
  G.live_of_mem_L₀ hbox (G.mem_L₀_of_live_tail hTS k hp)

/-- **The mirror, on the right tail.** -/
theorem live_ref_of_live_head (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {q : G.Pos}
    (hq : G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q) : G.Live (G.NM + G.NF) q :=
  G.live_of_mem_R₀ hbox (G.mem_R₀_of_live_head hTS k hq)

/--
**The window endpoint is the `k = 1` instance.** `G.winLo` is `-G.NB - 1 * G.NB`, so the live set at
the window's own left endpoint is contained in `L₀` — the first place where tail-stability says
something the bridge alone does not, since `G.winLo` and `-G.NB` are *both* window times and their
live sets are nevertheless unrelated without the demand.
-/
theorem liveAt_winLo_subset_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) : G.liveAt G.winLo ⊆ G.L₀ := by
  intro p hp
  refine G.mem_L₀_of_live_tail hTS 1 ?_
  rw [show -G.NB - ((1 : ℕ) : ℤ) * G.NB = G.winLo from by
    rw [show G.winLo = -2 * G.NB from rfl]; push_cast; omega]
  exact G.live_of_mem_liveAt hbox G.winLo_mem_winTimes hp

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
