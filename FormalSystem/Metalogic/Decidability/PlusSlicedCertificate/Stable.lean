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

## What is landed here, and what is landed in `Tail.lean`

`TailStable` is defined here, it is `Decidable`, and the **forward** direction of its consequence is
proved here for every time down either periodic tail: `mem_L₀_of_live_tail` and
`forall_mem_R₀_of_live_head` are the transfer's own soundness iterated, which is what Phase 17's
universal side consumes. That direction needs the transfer to be sound for **two**-directional
`Live` and not only for `FwdLive` (`live_subset_stepBack`), which is why those lemmas are here and
not folded into the one-directional ones.

The **reverse** direction needs a genuine run — `Live` is witnessed only by a bi-infinite `LabRun`,
and no shift of a run is a run, because `LabRun.agrees` and `LabRun.steps` are conditions at *every*
time while the slice sequence is periodic only away from `mid` — so it is a construction and lives
in `Tail.lean`, together with the linchpin biconditionals `tailStable_iff_window` /
`tailStable_iff_window_fwd` it completes. `runOfPos` is the interface between the two modules: it is
defined here, because it is about position families and not about tails, and consumed there.

Sub-phase 16.2 is closed, but **not** by landing `exists_tailStable_repr` — the re-presentation that
was supposed to make the demand harmless for an arbitrary certificate. That lemma is **false**, and
`FixtureStable.lean` proves it false at `Fixture.cert`: no re-presentation of that certificate is
tail-stable. So `TailStable` is a demand on the frame together with its closure and not on the
presentation, and the corrected record is on `TailStable`'s own docstring below and in
`FixtureStable.lean`'s header. Nothing here is stubbed and no placeholder stands in; the lemma is
absent because it is not true, not because it is pending.

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
- `PlusSlicedCertificate.iterBack_liveAt_refBack` / `iterFwd_liveAt_refFwd` — one application
  iterated to `k`, at an arbitrary residue reference time, with `iterBack_L₀` / `iterFwd_R₀` as the
  `r = 0` instances
- `PlusSlicedCertificate.mem_L₀_of_live_tail` / `live_ref_of_live_tail` and mirrors — the forward
  half of the linchpin, the transfer's soundness iterated
- `PlusSlicedCertificate.runOfPos` — a `LabRun` from any family of positions stepping along `succP`
- `PlusSlicedCertificate.mem_L₀_iff_live` / `mem_R₀_iff_live` — exactness at the reference times
- `PlusSlicedCertificate.refBack_mem_winTimes` / `refFwd_mem_winTimes` — every residue reference
  time the demand names is a window time, which is what keeps it decidable
- `PlusSlicedCertificate.tailStable_back` / `tailStable_fwd` and the two raw mirrors — the `r = 0`
  projections, each recovering a pre-residue conjunct verbatim

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

/-! ### The computed **forward**-live set, and why the right tail needs it

`liveAt` reads `G.liveT`, which is two-directional. The repaired forward conjunct of `TailStable`
below filters by the **forward** half alone, and the asymmetry is forced: `FoldF` relates the
right-tail times `G.NM + G.NF + k * G.NF` to the reference time, so forward liveness carries down
from them (`mem_fwdLiveT_of_fwdLive_fold`), while `FoldB` relates only *negative* times and relates
none of them. There is no backward counterpart to filter by, and none is claimed.
-/

/-- **The computed forward-live positions at a time**, the one-directional counterpart of
`liveAt`. -/
def fwdLiveAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) : Finset G.Pos :=
  (G.posAt s).filter (fun p => (p, s) ∈ G.fwdLiveT)

theorem mem_fwdLiveAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) (p : G.Pos) :
    p ∈ G.fwdLiveAt s ↔ p ∈ G.posAt s ∧ (p, s) ∈ G.fwdLiveT := Finset.mem_filter

theorem fwdLiveAt_subset_posAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) :
    G.fwdLiveAt s ⊆ G.posAt s := Finset.filter_subset _ _

/-- **Two-directional liveness is one-directional liveness**, since
`liveT = fwdLiveT ∩ bwdLiveT`. -/
theorem liveAt_subset_fwdLiveAt (G : PlusSlicedCertificate Γ Del) (s : ℤ) :
    G.liveAt s ⊆ G.fwdLiveAt s := by
  intro p hp
  rw [G.mem_liveAt] at hp
  exact (G.mem_fwdLiveAt s p).mpr ⟨hp.1, ((G.mem_liveT (p, s)).mp hp.2).1⟩

/-- **`R₀fwd`**: the computed forward-live positions at the window's right reference time. -/
def R₀fwd (G : PlusSlicedCertificate Γ Del) : Finset G.Pos := G.fwdLiveAt (G.NM + G.NF)

theorem R₀_subset_R₀fwd (G : PlusSlicedCertificate Γ Del) : G.R₀ ⊆ G.R₀fwd :=
  G.liveAt_subset_fwdLiveAt _

/-- **Every right-tail period multiple is a forward fold of the right reference time.** Both times
are at or past `G.NM` and they differ by a multiple of `G.NF`, which is exactly `FoldF`. -/
theorem foldF_head (G : PlusSlicedCertificate Γ Del) (k : ℕ) :
    G.FoldF (G.NM + G.NF) (G.NM + G.NF + (k : ℤ) * G.NF) := by
  have hF := G.NF_pos
  have hk : (0 : ℤ) ≤ (k : ℤ) * G.NF := mul_nonneg (Int.natCast_nonneg k) (le_of_lt hF)
  have h1 : G.NM + G.NF - G.NM = G.NF := by omega
  have h2 : G.NM + G.NF + (k : ℤ) * G.NF - G.NM = G.NF + (k : ℤ) * G.NF := by omega
  refine Or.inr ⟨by omega, by omega, ?_⟩
  rw [h1, h2, Int.add_mul_emod_self_right]

/-- **The forward wrap never leaves the right periodic region.** At a window time at or past the
right reference time the successor time is either one later or the reference time itself, so a
forward walk out of `G.NM + G.NF` stays in the right tail. -/
theorem nextTime_ge_right (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes)
    (h : G.NM + G.NF ≤ u) : G.NM + G.NF ≤ G.nextTime u := by
  by_cases hw : u + 1 < G.winHi
  · simp only [nextTime, if_pos hw]
    omega
  · obtain ⟨-, he⟩ := G.nextTime_edge hu hw
    rw [he]

/-- **A position forward-live anywhere down the periodic right tail is in `R₀fwd`.** This is the
one soundness fact the liveness filter needs, and it is what makes the filtered demand usable where
a filter by `liveAt` would not be: `FoldF` reaches the whole right tail. -/
theorem mem_R₀fwd_of_fwdLive_head (G : PlusSlicedCertificate Γ Del) (k : ℕ) {q : G.Pos}
    (hq : G.FwdLive (G.NM + G.NF + (k : ℤ) * G.NF) q) : q ∈ G.R₀fwd := by
  rw [R₀fwd, G.mem_fwdLiveAt]
  refine ⟨?_, G.mem_fwdLiveT_of_fwdLive_fold G.NM_add_NF_mem_winTimes (G.foldF_head k) hq⟩
  rw [G.foldF_posAt (G.foldF_head k)]
  exact G.mem_posAt_of_fwdLive hq

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
**What it costs the checker.** Exactly one application of each period transfer beyond Phase 15's
fixpoints — `G.Φ_back` on `L₀` and `G.Φ_fwd` on `R₀`, each an iterate of the one-step `stepBack` /
`stepFwd` over one combined period — and one `Finset` equality test on each. Nothing recomputes a
fixpoint, and `iterBack_L₀` is what makes the single application stand in for every later one.

**What it costs a search on the paired repository's side — CORRECTED, and the correction is bad
news.** An earlier version of this paragraph said that an unstable countermodel need only be
**re-presented**, not rejected: that absorbing its pre-period into `mid` and multiplying its period
by the cycle length yields a tail-stable presentation of the same frame, so that tail-stability
would narrow the *presentations* a checker accepts and not the frames a countermodel may have.
**That is false**, and `FixtureStable.lean` proves it false at `Fixture.cert`:
`Fixture.not_tailStable` shows that **no** member of the re-presentation family
`Fixture.certRep a b c` is tail-stable, for any pre-period and any period multipliers, while
`Fixture.certRep_slice_shift` shows every member presents `Fixture.cert`'s own slice sequence
shifted. The obstruction is the forward conjunct and it is structural: `Φ_fwd` is a reachability
transfer, the one-step clauses do not constrain the arriving label's `untl`-membership, and
re-presentation changes neither `posAt` nor the reachability. Read `FixtureStable.lean`'s header for
the argument in full.

So the **raw** forward demand `Φ_fwd R₀ = R₀` is a demand on the **frame together with its
closure** and not on the presentation, and `exists_tailStable_repr` is not stated anywhere in this
subtree because it is false. The raw demand is kept below under its own name `TailStableRaw`,
together with every theorem stated from it; `TailStable` carries the **repaired** forward conjunct
documented at its own definition.

**Residue-indexed, at sub-phase 18.3.** Both conjuncts below are bounded quantifiers over their own
period's residues rather than single equations at `-G.NB` and `G.NM + G.NF`. The reason is recorded
in full on `TailStable`'s docstring; `TailStableRaw` is strengthened in the same way so that
`tailStable_of_raw` survives and the two demands keep differing in exactly one respect, the liveness
filter on the forward conjunct. The `r = 0` instances are the pre-residue conjuncts verbatim
(`tailStableRaw_back`, `tailStableRaw_fwd`).
-/
def TailStableRaw (G : PlusSlicedCertificate Γ Del) : Prop :=
  (∀ r ∈ Finset.range G.NBnat,
      G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
        = G.liveAt (-G.NB - (r : ℤ)))
  ∧ (∀ r ∈ Finset.range G.NFnat,
      G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
        = G.liveAt (G.NM + G.NF + (r : ℤ)))

instance decidableTailStableRaw (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStableRaw :=
  inferInstanceAs (Decidable
    ((∀ r ∈ Finset.range G.NBnat,
        G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
          = G.liveAt (-G.NB - (r : ℤ)))
      ∧ (∀ r ∈ Finset.range G.NFnat,
        G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
          = G.liveAt (G.NM + G.NF + (r : ℤ)))))

/--
**Tail-stability, with the forward conjunct liveness-filtered.**

The backward conjunct is the raw one: `Φ_back L₀ = L₀`, unchanged, and every theorem stated from it
is unchanged. The forward conjunct is **not** the raw `Φ_fwd R₀ = R₀`: it is

  `Φ_fwd R₀ ∩ R₀fwd = R₀`,

the transfer **filtered by the computed forward-live set** at the right reference time. Both sides
are computed `Finset`s, so the demand is decidable exactly as the raw one was.

**Why the raw forward demand had to go.** `Φ_fwd` is a reachability transfer and the one-step
clauses do not constrain the arriving label's `untl`-membership, so the raw equation demands that
every position at the window's right endpoint reachable from a live position be itself live. That is
unsatisfiable at a frame whose closure carries a tail-dead eventuality, and no re-presentation
removes the obstruction, because it changes neither `posAt` nor the reachability.
`FixtureStable.lean` proves exactly that, at a named certificate, for the whole re-presentation
family (`Fixture.Φ_fwd_R₀_ne`), and `Fixture.not_mem_R₀fwd_pR` proves that the filter removes that
family's witness.

**What the filter changes, and what it does not.** The filtered demand removes the
reachable-but-forward-dead positions rather than requiring them to be live, and it is strictly
weaker than the raw one (`tailStable_of_raw`, with `Fixture.Φ_fwd_R₀_ne` showing the implication
does not reverse). What it still buys is the whole tail collapse, in both directions and at every
period multiple:

* `→` (`mem_R₀_of_live_head`): a position live at `G.NM + G.NF + k * G.NF` is in `R₀`. The raw
  equation's functional form is **not** what supplies this any more — `iterFwd_R₀` is stated from
  `TailStableRaw`. The induction carries one period at a time, and the arriving position's filter
  membership comes from `mem_R₀fwd_of_fwdLive_head`, i.e. from `FoldF` carrying genuine forward
  liveness down the tail to the reference time.
* `←` (`live_of_mem_R₀_head`): needs only `R₀ ⊆ Φ_fwd R₀`, the filtered equation's `⊇` half,
  iterated by monotonicity in `R₀_subset_iterFwd`.

**Why the filter is the forward half and not `liveAt`.** `FoldB` relates two negative times only, so
no backward counterpart of `mem_fwdLiveT_of_fwdLive_fold` exists at the right tail and a filter by
the two-directional `liveAt` would have no soundness lemma to stand on. See the note at `fwdLiveAt`.

**Residue-indexed, at sub-phase 18.3, and the narrowing that costs.** Each conjunct is a bounded
quantifier over its own period's residues: the backward one over `r < G.NBnat` at reference time
`-G.NB - r`, the forward one over `r < G.NFnat` at `G.NM + G.NF + r`. The `r = 0` instances are the
pre-residue conjuncts verbatim (`tailStable_back`, `tailStable_fwd`), so nothing stated from the
single-equation form is weakened.

*Why the single equation was not enough.* The truth lemma's `⊡` clause is pinned to the time its
carrier element names — the comparison class is the histories agreeing at `τ.state t = (t, w)`,
whose first component *is* the time — so no shift normalizes it, and the clause is therefore
needed at **every** `t : ℤ`. Transporting the computed live set from an arbitrary `t` to a window
representative needs the tail collapse at `t`'s own residue class, and the single equation
`Φ_back L₀ = L₀` is a statement about one residue class only: nothing relates the live set at
`-G.NB` to the live set at `-G.NB - r` for `r ≠ 0`. Two derivations were worked through and both
fail — backward reachability from `L₀` satisfies the shifted equation but is not contained in the
live set at the shifted reference time, and the live set there satisfies no equation the
single-residue demand implies.

*What it costs.* The demand is strictly stronger, so the certificate class is narrower: a frame
whose liveness wraps faithfully at one residue but not at another is now rejected. Every reference
time named is still a window time (`refBack_mem_winTimes`, `refFwd_mem_winTimes`), which is what
keeps both sides computed `Finset`s and `decidableTailStable` a bounded conjunction of `Finset`
equality tests;
the checker's cost goes from two `Φ` applications to `G.NBnat + G.NFnat` of them.
-/
def TailStable (G : PlusSlicedCertificate Γ Del) : Prop :=
  (∀ r ∈ Finset.range G.NBnat,
      G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
        = G.liveAt (-G.NB - (r : ℤ)))
  ∧ (∀ r ∈ Finset.range G.NFnat,
      G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
        ∩ G.fwdLiveAt (G.NM + G.NF + (r : ℤ)) = G.liveAt (G.NM + G.NF + (r : ℤ)))

instance decidableTailStable (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable :=
  inferInstanceAs (Decidable
    ((∀ r ∈ Finset.range G.NBnat,
        G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
          = G.liveAt (-G.NB - (r : ℤ)))
      ∧ (∀ r ∈ Finset.range G.NFnat,
        G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
          ∩ G.fwdLiveAt (G.NM + G.NF + (r : ℤ)) = G.liveAt (G.NM + G.NF + (r : ℤ)))))

/-- **Both instances are synthesized, not asserted.** -/
example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStableRaw := inferInstance

/-! ### Every residue reference time is a window time

This is what keeps both demands decidable after the residue indexing: each side of each conjunct is
`G.liveAt` or `G.fwdLiveAt` read at a window time, hence a computed `Finset`.
-/

/-- **The left residue reference times `-G.NB - r`, `r < G.NBnat`, lie in the window.** The lower
bound is where the doubled window earns its factor: `-2 * G.NB ≤ -G.NB - r` holds exactly because
`r < G.NB`. -/
theorem refBack_mem_winTimes (G : PlusSlicedCertificate Γ Del) {r : ℕ} (hr : r < G.NBnat) :
    -G.NB - (r : ℤ) ∈ G.winTimes := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hrlt : (r : ℤ) < G.NB := by rw [NB]; exact_mod_cast hr
  have hrnn : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes]
  omega

/-- **The right residue reference times `G.NM + G.NF + r`, `r < G.NFnat`, lie in the window.** -/
theorem refFwd_mem_winTimes (G : PlusSlicedCertificate Γ Del) {r : ℕ} (hr : r < G.NFnat) :
    G.NM + G.NF + (r : ℤ) ∈ G.winTimes := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hrlt : (r : ℤ) < G.NF := by rw [NF]; exact_mod_cast hr
  have hrnn : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes]
  omega

/-- **The left residue reference times are negative**, which is what the leftward periodicity
lemmas ask for. -/
theorem refBack_neg (G : PlusSlicedCertificate Γ Del) (r : ℕ) : -G.NB - (r : ℤ) < 0 := by
  have hB := G.NB_pos
  have hrnn : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  omega

/-- **The right residue reference times are at or past `G.nm`**, which is what the rightward
periodicity lemmas ask for. -/
theorem nm_le_refFwd (G : PlusSlicedCertificate Γ Del) (r : ℕ) :
    G.nm ≤ G.NM + G.NF + (r : ℤ) := by
  have hF := G.NF_pos
  have hnm := G.nm_le_NM
  have hrnn : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  omega

/-! ### The `r = 0` projections

Each of the four recovers a pre-residue conjunct verbatim, so every declaration stated from the
single-equation form is unaffected by the residue indexing.
-/

/-- **The `r = 0` instance of the raw backward conjunct.** -/
theorem tailStableRaw_back (G : PlusSlicedCertificate Γ Del) (h : G.TailStableRaw) :
    G.Φ_back G.L₀ = G.L₀ := by
  have h0 := h.1 0 (Finset.mem_range.mpr G.NBnat_pos)
  rw [Φ_back, L₀]
  simpa using h0

/-- **The `r = 0` instance of the raw forward conjunct.** -/
theorem tailStableRaw_fwd (G : PlusSlicedCertificate Γ Del) (h : G.TailStableRaw) :
    G.Φ_fwd G.R₀ = G.R₀ := by
  have h0 := h.2 0 (Finset.mem_range.mpr G.NFnat_pos)
  rw [Φ_fwd, R₀]
  simpa using h0

/-- **The `r = 0` instance of the backward conjunct.** -/
theorem tailStable_back (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) :
    G.Φ_back G.L₀ = G.L₀ := by
  have h0 := hTS.1 0 (Finset.mem_range.mpr G.NBnat_pos)
  rw [Φ_back, L₀]
  simpa using h0

/-- **The `r = 0` instance of the filtered forward conjunct.** -/
theorem tailStable_fwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) :
    G.Φ_fwd G.R₀ ∩ G.R₀fwd = G.R₀ := by
  have h0 := hTS.2 0 (Finset.mem_range.mpr G.NFnat_pos)
  rw [Φ_fwd, R₀, R₀fwd]
  simpa using h0

/-- **The raw demand is the stronger one**, residue by residue. The converse fails:
`Fixture.Φ_fwd_R₀_ne` refutes the raw forward conjunct at a certificate, for every member of the
re-presentation family. -/
theorem tailStable_of_raw (G : PlusSlicedCertificate Γ Del) (h : G.TailStableRaw) :
    G.TailStable := by
  refine ⟨h.1, ?_⟩
  intro r hr
  rw [h.2 r hr]
  exact Finset.ext fun p =>
    ⟨fun hp => (Finset.mem_inter.mp hp).1,
      fun hp => Finset.mem_inter.mpr ⟨hp, G.liveAt_subset_fwdLiveAt _ hp⟩⟩

/-- **The `⊇` half of the filtered forward conjunct at an arbitrary residue**, which is all the `←`
direction of the tail collapse consumes. -/
theorem liveAt_refFwd_subset_Φ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) {r : ℕ}
    (hr : r < G.NFnat) :
    G.liveAt (G.NM + G.NF + (r : ℤ))
      ⊆ G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat := by
  intro p hp
  rw [← hTS.2 r (Finset.mem_range.mpr hr)] at hp
  exact (Finset.mem_inter.mp hp).1

/-- **The `r = 0` instance**, in the shape the pre-residue development cites. -/
theorem R₀_subset_Φ_fwd_R₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) :
    G.R₀ ⊆ G.Φ_fwd G.R₀ := by
  intro p hp
  rw [← G.tailStable_fwd hTS] at hp
  exact (Finset.mem_inter.mp hp).1

/-- **One application iterated, at an arbitrary left residue.** Under tail-stability every
whole-period leftward iterate of the live set at `-G.NB - r` is that same set again — the content
the plan's Scope Hypothesis calls "immediate from the equation", made a theorem because the
reference time moves with each period and the shift has to be justified by `iterBack_shift`. -/
theorem iterBack_liveAt_refBack (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) {r : ℕ}
    (hr : r < G.NBnat) (k : ℕ) :
    G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) (k * G.NBnat)
      = G.liveAt (-G.NB - (r : ℤ)) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterBack_add, ih,
      show ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB from by rw [NB, Nat.cast_mul],
      G.iterBack_shift (G.refBack_neg r) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat k]
    exact hTS.1 r (Finset.mem_range.mpr hr)

/-- **The `r = 0` instance**, the form the pre-residue development cites. -/
theorem iterBack_L₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    G.iterBack (-G.NB) G.L₀ (k * G.NBnat) = G.L₀ := by
  have h := G.iterBack_liveAt_refBack hTS G.NBnat_pos k
  rw [L₀]
  simpa using h

/-- **`Φ_fwd` iterated at an arbitrary right residue**, the mirror — stated from the **raw** demand
`TailStableRaw`, which is where the forward equation's functional form survives. `TailStable` does
not imply it: under the filtered forward conjunct the iterate may grow, and
`liveAt_refFwd_subset_iterFwd` is the one-sided replacement the tail collapse uses instead. -/
theorem iterFwd_liveAt_refFwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStableRaw) {r : ℕ}
    (hr : r < G.NFnat) (k : ℕ) :
    G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) (k * G.NFnat)
      = G.liveAt (G.NM + G.NF + (r : ℤ)) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterFwd_add, ih,
      show ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF from by rw [NF, Nat.cast_mul],
      G.iterFwd_shift (G.nm_le_refFwd r) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat k]
    exact hTS.2 r (Finset.mem_range.mpr hr)

/-- **The `r = 0` instance**, the form the pre-residue development cites. -/
theorem iterFwd_R₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStableRaw) (k : ℕ) :
    G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) = G.R₀ := by
  have h := G.iterFwd_liveAt_refFwd hTS G.NFnat_pos k
  rw [R₀]
  simpa using h

/-- **The one-sided replacement for `iterFwd_liveAt_refFwd` under the filtered forward conjunct.**
Only the `⊇` half of the filtered equation is used, iterated by monotonicity. -/
theorem liveAt_refFwd_subset_iterFwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) {r : ℕ}
    (hr : r < G.NFnat) (k : ℕ) :
    G.liveAt (G.NM + G.NF + (r : ℤ))
      ⊆ G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) (k * G.NFnat) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterFwd_add,
      show ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF from by rw [NF, Nat.cast_mul],
      G.iterFwd_shift (G.nm_le_refFwd r)
        (G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) (k * G.NFnat))
        G.NFnat k]
    exact subset_trans (G.liveAt_refFwd_subset_Φ hTS hr) (G.iterFwd_mono _ ih _)

/-- **The `r = 0` instance**, the form the pre-residue development cites. -/
theorem R₀_subset_iterFwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    G.R₀ ⊆ G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) := by
  have h := G.liveAt_refFwd_subset_iterFwd hTS G.NFnat_pos k
  rw [R₀]
  simpa using h

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

/--
**The mirror, on the right tail** — and the one declaration of this module whose **proof** the
repaired forward conjunct forced to be rewritten.

The raw demand proved this in one step: `live_subset_iterFwd` lands `q` in `Φ_fwd^k R₀`, and
`iterFwd_R₀` collapsed that to `R₀`. The filtered demand does not collapse the iterate, so the
induction runs one period at a time: the inductive hypothesis is the whole `∀ q` statement at `k`,
which is exactly the `hX` that `live_subset_iterFwd` asks for over the single period from
`G.NM + G.NF + k * G.NF`, and the filter membership of the arriving position comes from its genuine
forward liveness through `mem_R₀fwd_of_fwdLive_head`.
-/
theorem forall_mem_R₀_of_live_head (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    ∀ q : G.Pos, G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q → q ∈ G.R₀ := by
  have hnm : G.nm ≤ G.NM + G.NF := by
    have := G.NF_pos
    have := G.nm_le_NM
    omega
  induction k with
  | zero =>
    intro q hq
    exact G.mem_liveAt_of_live G.NM_add_NF_mem_winTimes (by simpa using hq)
  | succ k ih =>
    intro q hq
    have hsucc : ((k + 1 : ℕ) : ℤ) = (k : ℤ) + 1 := by push_cast; rfl
    have htime : G.NM + G.NF + (k : ℤ) * G.NF + G.NF
        = G.NM + G.NF + ((k + 1 : ℕ) : ℤ) * G.NF := by
      rw [hsucc, add_one_mul, ← add_assoc]
    have hq' : G.Live (G.NM + G.NF + (k : ℤ) * G.NF + ((G.NFnat : ℕ) : ℤ)) q := by
      rw [show ((G.NFnat : ℕ) : ℤ) = G.NF from by rw [NF], htime]
      exact hq
    have h1 := G.live_subset_iterFwd (G.NM + G.NF + (k : ℤ) * G.NF) G.R₀ ih G.NFnat q hq'
    rw [G.iterFwd_shift hnm G.R₀ G.NFnat k] at h1
    rw [← G.tailStable_fwd hTS]
    exact Finset.mem_inter.mpr ⟨h1, G.mem_R₀fwd_of_fwdLive_head (k + 1) hq.1⟩

/-- **The mirror of `mem_L₀_of_live_tail`**, in the shape the rest of this module cites. -/
theorem mem_R₀_of_live_head (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ)
    {q : G.Pos} (hq : G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q) : q ∈ G.R₀ :=
  G.forall_mem_R₀_of_live_head hTS k q hq

/-! ### The same two halves at an arbitrary reference time

The residue-indexed demand needs both halves at `-G.NB - r` and `G.NM + G.NF + r`, not only at the
two `r = 0` reference times. Each generic statement below takes the one-period stability it needs as
a hypothesis rather than reading it off `TailStable`, so that the `r = 0` and residue instances are
both one-liners and neither is privileged.
-/

/-- **The forward half at an arbitrary reference time.** `hstab` is the whole-period fixity of the
live set at `t₀`, which `iterBack_liveAt_refBack` supplies at every residue reference time. -/
theorem mem_liveAt_of_live_tail (G : PlusSlicedCertificate Γ Del) {t₀ : ℤ}
    (hwin : t₀ ∈ G.winTimes)
    (hstab : ∀ j : ℕ, G.iterBack t₀ (G.liveAt t₀) (j * G.NBnat) = G.liveAt t₀) (k : ℕ)
    {p : G.Pos} (hp : G.Live (t₀ - (k : ℤ) * G.NB) p) : p ∈ G.liveAt t₀ := by
  have hcast : ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB := by rw [NB, Nat.cast_mul]
  have hX : ∀ q, G.Live t₀ q → q ∈ G.liveAt t₀ := fun q hq => G.mem_liveAt_of_live hwin hq
  have hp' : G.Live (t₀ - ((k * G.NBnat : ℕ) : ℤ)) p := by rw [hcast]; exact hp
  have h := G.live_subset_iterBack t₀ (G.liveAt t₀) hX (k * G.NBnat) p hp'
  rwa [hstab k] at h

/-- **The forward half at an arbitrary left residue reference time.** -/
theorem mem_liveAt_of_live_refBack (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) {r : ℕ}
    (hr : r < G.NBnat) (k : ℕ) {p : G.Pos}
    (hp : G.Live (-G.NB - (r : ℤ) - (k : ℤ) * G.NB) p) : p ∈ G.liveAt (-G.NB - (r : ℤ)) :=
  G.mem_liveAt_of_live_tail (G.refBack_mem_winTimes hr) (G.iterBack_liveAt_refBack hTS hr) k hp

/-- **Every right-tail period multiple of an arbitrary reference time at or past `G.NM` is a forward
fold of it.** The generic form of `foldF_head`. -/
theorem foldF_shift (G : PlusSlicedCertificate Γ Del) {t₁ : ℤ} (hNM : G.NM ≤ t₁) (k : ℕ) :
    G.FoldF t₁ (t₁ + (k : ℤ) * G.NF) := by
  have hF := G.NF_pos
  have hk : (0 : ℤ) ≤ (k : ℤ) * G.NF := mul_nonneg (Int.natCast_nonneg k) (le_of_lt hF)
  refine Or.inr ⟨hNM, by omega, ?_⟩
  rw [show t₁ + (k : ℤ) * G.NF - G.NM = t₁ - G.NM + (k : ℤ) * G.NF from by omega,
    Int.add_mul_emod_self_right]

/-- **A position forward-live anywhere down the periodic right tail of an arbitrary window reference
time at or past `G.NM` is in that time's computed forward-live set.** The generic form of
`mem_R₀fwd_of_fwdLive_head`. -/
theorem mem_fwdLiveAt_of_fwdLive_head (G : PlusSlicedCertificate Γ Del) {t₁ : ℤ}
    (hwin : t₁ ∈ G.winTimes) (hNM : G.NM ≤ t₁) (k : ℕ) {q : G.Pos}
    (hq : G.FwdLive (t₁ + (k : ℤ) * G.NF) q) : q ∈ G.fwdLiveAt t₁ := by
  rw [G.mem_fwdLiveAt]
  refine ⟨?_, G.mem_fwdLiveT_of_fwdLive_fold hwin (G.foldF_shift hNM k) hq⟩
  rw [G.foldF_posAt (G.foldF_shift hNM k)]
  exact G.mem_posAt_of_fwdLive hq

/-- **The forward half on the right tail of an arbitrary reference time.** `hstab` is the one-period
filtered equation at `t₁`, which the residue-indexed demand supplies at every residue reference
time; the induction carries one period at a time, exactly as `forall_mem_R₀_of_live_head` does. -/
theorem forall_mem_liveAt_of_live_head (G : PlusSlicedCertificate Γ Del) {t₁ : ℤ}
    (hwin : t₁ ∈ G.winTimes) (hNM : G.NM ≤ t₁)
    (hstab : G.iterFwd t₁ (G.liveAt t₁) G.NFnat ∩ G.fwdLiveAt t₁ = G.liveAt t₁) (k : ℕ) :
    ∀ q : G.Pos, G.Live (t₁ + (k : ℤ) * G.NF) q → q ∈ G.liveAt t₁ := by
  have hnm : G.nm ≤ t₁ := le_trans G.nm_le_NM hNM
  induction k with
  | zero =>
    intro q hq
    exact G.mem_liveAt_of_live hwin (by simpa using hq)
  | succ k ih =>
    intro q hq
    have hsucc : ((k + 1 : ℕ) : ℤ) = (k : ℤ) + 1 := by push_cast; rfl
    have htime : t₁ + (k : ℤ) * G.NF + G.NF = t₁ + ((k + 1 : ℕ) : ℤ) * G.NF := by
      rw [hsucc, add_one_mul, ← add_assoc]
    have hq' : G.Live (t₁ + (k : ℤ) * G.NF + ((G.NFnat : ℕ) : ℤ)) q := by
      rw [show ((G.NFnat : ℕ) : ℤ) = G.NF from by rw [NF], htime]
      exact hq
    have h1 := G.live_subset_iterFwd (t₁ + (k : ℤ) * G.NF) (G.liveAt t₁) ih G.NFnat q hq'
    rw [G.iterFwd_shift hnm (G.liveAt t₁) G.NFnat k] at h1
    rw [← hstab]
    exact Finset.mem_inter.mpr ⟨h1, G.mem_fwdLiveAt_of_fwdLive_head hwin hNM (k + 1) hq.1⟩

/-- **The forward half at an arbitrary right residue reference time.** -/
theorem mem_liveAt_of_live_refFwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) {r : ℕ}
    (hr : r < G.NFnat) (k : ℕ) {q : G.Pos}
    (hq : G.Live (G.NM + G.NF + (r : ℤ) + (k : ℤ) * G.NF) q) :
    q ∈ G.liveAt (G.NM + G.NF + (r : ℤ)) := by
  have hNM : G.NM ≤ G.NM + G.NF + (r : ℤ) := by
    have hF := G.NF_pos
    have hrnn : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
    omega
  exact G.forall_mem_liveAt_of_live_head (G.refFwd_mem_winTimes hr) hNM
    (hTS.2 r (Finset.mem_range.mpr hr)) k q hq

/-! ### Every time is a residue reference time shifted by whole periods

The two arithmetic facts `exists_win_live_eq` runs on: outside the single-period window every time
factors as a residue reference time plus or minus a whole number of combined periods.
-/

/-- **Every time at or left of `-G.NB` is a left residue reference time shifted left by whole
periods.** -/
theorem exists_residue_back (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t ≤ -G.NB) :
    ∃ r k : ℕ, r < G.NBnat ∧ t = -G.NB - (r : ℤ) - (k : ℤ) * G.NB := by
  have hNB := G.NB_pos
  have hNBz : ((G.NBnat : ℕ) : ℤ) = G.NB := by rw [NB]
  obtain ⟨d, hd⟩ : ∃ d : ℕ, (d : ℤ) = -G.NB - t :=
    ⟨(-G.NB - t).toNat, Int.toNat_of_nonneg (by omega)⟩
  refine ⟨d % G.NBnat, d / G.NBnat, Nat.mod_lt _ G.NBnat_pos, ?_⟩
  have h : d % G.NBnat + d / G.NBnat * G.NBnat = d := Nat.mod_add_div' d G.NBnat
  have h' : ((d % G.NBnat : ℕ) : ℤ) + ((d / G.NBnat : ℕ) : ℤ) * G.NB = (d : ℤ) := by
    rw [← hNBz]
    exact_mod_cast h
  have ht' : t = -G.NB - (d : ℤ) := by omega
  rw [ht', ← h', sub_add_eq_sub_sub]

/-- **Every time at or right of `G.NM + G.NF` is a right residue reference time shifted right by
whole periods.** -/
theorem exists_residue_fwd (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.NM + G.NF ≤ t) :
    ∃ r k : ℕ, r < G.NFnat ∧ t = G.NM + G.NF + (r : ℤ) + (k : ℤ) * G.NF := by
  have hNF := G.NF_pos
  have hNFz : ((G.NFnat : ℕ) : ℤ) = G.NF := by rw [NF]
  obtain ⟨d, hd⟩ : ∃ d : ℕ, (d : ℤ) = t - (G.NM + G.NF) :=
    ⟨(t - (G.NM + G.NF)).toNat, Int.toNat_of_nonneg (by omega)⟩
  refine ⟨d % G.NFnat, d / G.NFnat, Nat.mod_lt _ G.NFnat_pos, ?_⟩
  have h : d % G.NFnat + d / G.NFnat * G.NFnat = d := Nat.mod_add_div' d G.NFnat
  have h' : ((d % G.NFnat : ℕ) : ℤ) + ((d / G.NFnat : ℕ) : ℤ) * G.NF = (d : ℤ) := by
    rw [← hNFz]
    exact_mod_cast h
  have ht' : t = G.NM + G.NF + (d : ℤ) := by omega
  rw [ht', ← h', ← add_assoc]

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

/-! ## A run from a time-indexed family of positions

`Bridge.lean` builds its `LabRun` out of two half-line **walks** and folds their times; the
construction the converse half needs has a finite middle region and so is not a pair of walks at
all. What both have in common is all a `LabRun` ever needs: a position at every time, each at its
own slice, each a `succP`-successor of the one before. `runOfPos` isolates exactly that, and the
five fields — including the box clause, where (C3b) enters and nothing else does — are read off
those two hypotheses.
-/

section RunOfPos

variable {G : PlusSlicedCertificate Γ Del}

/-- **The five local-coherence clauses of a position family's labelling.** The box clause consumes
(C3b) and `AgreesOnState` together; the two temporal clauses are the `succP` step's own
`StepClause`, read forwards at `t` and backwards at `t - 1`. -/
theorem coherent_of_pos (hbox : G.BoxLabelFaithful) {P : ℤ → G.Pos}
    (hP : ∀ t, P t ∈ G.posAt t) (hstep : ∀ t, P (t + 1) ∈ G.succP t (P t)) :
    PlusLocalCoherentSeqLab Γ Del G.bx (fun t => (P t).2.1) := by
  intro t
  obtain ⟨hlab, hagr⟩ := (G.mem_posAt t (P t)).mp (hP t)
  refine ⟨hlab.1, ?_, ?_, ?_, ?_⟩
  · intro a b hab
    have hc := hlab.2 _ hab
    simp only [impClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro χ hχ
    have hst : IsStateShape (PlusFormula.box χ) = true := rfl
    exact (hagr (PlusFormula.box χ) hχ hst).trans (hbox χ hχ t _)
  · intro g e hge
    have hc := ((G.mem_succP t (P t) (P (t + 1))).mp (hstep t)).2.2.1 _ hge
    simp only [untlClauseAt, decide_eq_true_eq] at hc
    exact hc
  · intro g e hge
    have hs := hstep (t - 1)
    rw [show t - 1 + 1 = t from by omega] at hs
    have hc := ((G.mem_succP (t - 1) (P (t - 1)) (P t)).mp hs).2.2.2 _ hge
    simp only [snceClauseAt, decide_eq_true_eq] at hc
    exact hc

/-- **The run a position family presents.** -/
def runOfPos (hbox : G.BoxLabelFaithful) {P : ℤ → G.Pos} (hP : ∀ t, P t ∈ G.posAt t)
    (hstep : ∀ t, P (t + 1) ∈ G.succP t (P t)) : G.LabRun where
  st := fun t => (P t).1
  lab := fun t => (P t).2.1
  lab_sub := fun t => G.pos_lab_sub (P t)
  agrees := fun t => ((G.mem_posAt t (P t)).mp (hP t)).2
  steps := fun t => ((G.mem_succP t (P t) (P (t + 1))).mp (hstep t)).2.1
  coherent := coherent_of_pos hbox hP hstep

@[simp] theorem runOfPos_lab (hbox : G.BoxLabelFaithful) {P : ℤ → G.Pos}
    (hP : ∀ t, P t ∈ G.posAt t) (hstep : ∀ t, P (t + 1) ∈ G.succP t (P t)) (t : ℤ) :
    (runOfPos hbox hP hstep).lab t = (P t).2.1 := rfl

theorem runOfPos_pos (hbox : G.BoxLabelFaithful) {P : ℤ → G.Pos} (hP : ∀ t, P t ∈ G.posAt t)
    (hstep : ∀ t, P (t + 1) ∈ G.succP t (P t)) (t : ℤ) :
    (runOfPos hbox hP hstep).pos t = P t := Prod.ext rfl (Subtype.ext rfl)

end RunOfPos

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
