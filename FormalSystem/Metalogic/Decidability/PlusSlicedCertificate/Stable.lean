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

## What is landed here, and what remains of sub-phase 16.2

`TailStable` is defined here, it is `Decidable`, and **both** directions of its consequence are
proved, for every time down either periodic tail: `tailStable_iff_window` (with
`tailStable_iff_window_fwd`) says that under the demand the computed reference set `L₀` *is* the
true live set at every `-G.NB - k * G.NB`, and `R₀` at every `G.NM + G.NF + k * G.NF`. The two
halves are separately named — `mem_L₀_of_live_tail` is the transfer's soundness iterated, and
`live_of_mem_L₀_tail` the three-region run — because Phase 17's universal side needs only the first
and its existential side only the second.

Neither direction is cheap and neither is a formality. The forward one needs the transfer to be
sound for **two**-directional `Live` and not only for `FwdLive` (`live_subset_stepBack`), and the
reverse one needs a genuine run: `Live` is witnessed only by a bi-infinite `LabRun`, and no shift of
a run is a run, because `LabRun.agrees` and `LabRun.steps` are conditions at *every* time while the
slice sequence is periodic only away from `mid`. `runOfPos` and the three regions are how that is
discharged; the block headed "The converse half" states the construction and why each region is
closed under the direction its fulfilment half looks in.

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
- `PlusSlicedCertificate.iterBack_L₀` / `iterFwd_R₀` — one application iterated to `k`
- `PlusSlicedCertificate.mem_L₀_of_live_tail` / `live_ref_of_live_tail` and mirrors — the forward
  half of the linchpin, the transfer's soundness iterated
- `PlusSlicedCertificate.runOfPos` — a `LabRun` from any family of positions stepping along `succP`
- `PlusSlicedCertificate.exists_chain_of_mem_iterBack` / `exists_chain_of_mem_iterFwd` — the path an
  iterate witnesses, made explicit
- `PlusSlicedCertificate.live_of_mem_L₀_tail` / `live_of_mem_R₀_head` — the reverse half, by the
  three-region run
- `PlusSlicedCertificate.tailStable_iff_window` / `tailStable_iff_window_fwd` — **the linchpin**, as
  a biconditional at every time down either periodic tail
- `PlusSlicedCertificate.mem_L₀_iff_live` / `mem_R₀_iff_live` — exactness at the reference times,
  with `liveAt_tail_eq_L₀` / `liveAt_winLo_eq_L₀` as the `Finset` equalities a checker reads

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
-/
def TailStableRaw (G : PlusSlicedCertificate Γ Del) : Prop :=
  G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ = G.R₀

instance decidableTailStableRaw (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStableRaw :=
  inferInstanceAs (Decidable (G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ = G.R₀))

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
-/
def TailStable (G : PlusSlicedCertificate Γ Del) : Prop :=
  G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ ∩ G.R₀fwd = G.R₀

instance decidableTailStable (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable :=
  inferInstanceAs (Decidable (G.Φ_back G.L₀ = G.L₀ ∧ G.Φ_fwd G.R₀ ∩ G.R₀fwd = G.R₀))

/-- **Both instances are synthesized, not asserted.** -/
example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable := inferInstance

example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStableRaw := inferInstance

/-- **The raw demand is the stronger one.** The converse fails: `Fixture.Φ_fwd_R₀_ne` refutes the
raw forward conjunct at a certificate, for every member of the re-presentation family. -/
theorem tailStable_of_raw (G : PlusSlicedCertificate Γ Del) (h : G.TailStableRaw) :
    G.TailStable := by
  refine ⟨h.1, ?_⟩
  rw [h.2]
  exact Finset.ext fun p =>
    ⟨fun hp => (Finset.mem_inter.mp hp).1,
      fun hp => Finset.mem_inter.mpr ⟨hp, G.R₀_subset_R₀fwd hp⟩⟩

/-- **The `⊇` half of the filtered forward conjunct**, which is all the `←` direction of the tail
collapse consumes. -/
theorem R₀_subset_Φ_fwd_R₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) :
    G.R₀ ⊆ G.Φ_fwd G.R₀ := by
  intro p hp
  rw [← hTS.2] at hp
  exact (Finset.mem_inter.mp hp).1

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

/-- **`Φ_fwd` iterated**, the mirror — stated from the **raw** demand `TailStableRaw`, which is
where the forward equation's functional form survives. `TailStable` does not imply it: under the
filtered forward conjunct the iterate may grow, and `R₀_subset_iterFwd` is the one-sided replacement
the tail collapse uses instead. -/
theorem iterFwd_R₀ (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStableRaw) (k : ℕ) :
    G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) = G.R₀ := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterFwd_add, ih,
      show ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF from by rw [NF, Nat.cast_mul],
      G.iterFwd_shift (by have := G.NF_pos; have := G.nm_le_NM; omega) G.R₀ G.NFnat k]
    exact hTS.2

/-- **The one-sided replacement for `iterFwd_R₀` under the filtered forward conjunct.** Only the
`⊇` half of the filtered equation is used, iterated by monotonicity: `R₀ ⊆ Φ_fwd R₀` gives
`R₀ ⊆ Φ_fwd^k R₀` at every `k`, which is exactly what the `←` direction of the tail collapse
consumes. -/
theorem R₀_subset_iterFwd (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ) :
    G.R₀ ⊆ G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) := by
  have hnm : G.nm ≤ G.NM + G.NF := by
    have := G.NF_pos
    have := G.nm_le_NM
    omega
  induction k with
  | zero => simp
  | succ k ih =>
    rw [add_one_mul, G.iterFwd_add,
      show ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF from by rw [NF, Nat.cast_mul],
      G.iterFwd_shift hnm (G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat)) G.NFnat k]
    exact subset_trans (G.R₀_subset_Φ_fwd_R₀ hTS) (G.iterFwd_mono _ ih _)

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
    rw [← hTS.2]
    exact Finset.mem_inter.mpr ⟨h1, G.mem_R₀fwd_of_fwdLive_head (k + 1) hq.1⟩

/-- **The mirror of `mem_L₀_of_live_tail`**, in the shape the rest of this module cites. -/
theorem mem_R₀_of_live_head (G : PlusSlicedCertificate Γ Del) (hTS : G.TailStable) (k : ℕ)
    {q : G.Pos} (hq : G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q) : q ∈ G.R₀ :=
  G.forall_mem_R₀_of_live_head hTS k q hq

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

/-! ## The chain an iterate witnesses

`p ∈ G.iterBack t X k` is an existential about a path, unwound `k` times. This makes the path
explicit, because the converse half has to *walk* it and not merely know it is there. The hypothesis
`X ⊆ G.posAt t` is what pins the chain's last vertex to the reference slice; `L₀` satisfies it by
`liveAt_subset_posAt`.
-/

theorem exists_chain_of_mem_iterBack (G : PlusSlicedCertificate Γ Del) (t : ℤ)
    {X : Finset G.Pos} (hX : X ⊆ G.posAt t) (k : ℕ) {p : G.Pos}
    (hp : p ∈ G.iterBack t X k) :
    ∃ c : ℕ → G.Pos, c 0 = p ∧ c k ∈ X ∧ (∀ j ≤ k, c j ∈ G.posAt (t - (k : ℤ) + (j : ℤ))) ∧
      ∀ j < k, c (j + 1) ∈ G.succP (t - (k : ℤ) + (j : ℤ)) (c j) := by
  induction k generalizing p with
  | zero =>
    refine ⟨fun _ => p, rfl, hp, ?_, by omega⟩
    intro j hj
    have hj0 : j = 0 := by omega
    subst hj0
    simpa using hX hp
  | succ k ih =>
    rw [iterBack_succ, mem_stepBack] at hp
    obtain ⟨hppos, q, hq1, hq2⟩ := hp
    obtain ⟨c, hc0, hck, hcpos, hcstep⟩ := ih hq2
    refine ⟨fun j => Nat.rec p (fun i _ => c i) j, rfl, hck, ?_, ?_⟩
    · intro j hj
      match j with
      | 0 =>
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = t - (k : ℤ) - 1 from by push_cast; omega]
        exact hppos
      | (i + 1) =>
        have h := hcpos i (by omega)
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((i + 1 : ℕ) : ℤ) = t - (k : ℤ) + (i : ℤ) from by
          push_cast; omega]
        exact h
    · intro j hj
      match j with
      | 0 =>
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((0 : ℕ) : ℤ) = t - (k : ℤ) - 1 from by push_cast; omega]
        change c 0 ∈ G.succP (t - (k : ℤ) - 1) p
        rw [hc0]
        exact hq1
      | (i + 1) =>
        have h := hcstep i (by omega)
        rw [show t - ((k + 1 : ℕ) : ℤ) + ((i + 1 : ℕ) : ℤ) = t - (k : ℤ) + (i : ℤ) from by
          push_cast; omega]
        exact h

/-! ## The converse half: every member of `L₀` is live all the way down the tail

The construction, in the three regions the module header names.

* On `u ≤ t₀` (where `t₀ = -G.NB - k * G.NB`) the reference run of `p` itself, **shifted right by
  the whole distance**. A shift is not a run — `LabRun.agrees` and `LabRun.steps` are conditions at
  every time and the slice sequence is periodic only on the negatives — but on this region every
  time and its shift are negative, so `posAt_congr` and `succP_congr` transport both fields.
* On `t₀ ≤ u ≤ -G.NB` the finite `Φ_back`-chain that `G.Φ_back L₀ = L₀` supplies, iterated to `k`
  periods by `iterBack_L₀` and made explicit by `exists_chain_of_mem_iterBack`.
* On `-G.NB ≤ u` the reference run of the chain's **endpoint**, which is a member of `L₀` again and
  in general not `p`. That is why the construction needs two reference runs and not one.

The two seams are consistent rather than glued: at `t₀` the chain's first vertex *is* `p`, and at
`-G.NB` its last vertex *is* where the endpoint's run sits, so `tailPos_le` and `tailPos_ge` each
hold on a *closed* half-line and the case analysis never has a boundary to negotiate.

Fulfilment is not spliced either: `plusBwdFulfilling_of_le` reads the whole backward half off region
one and `plusFwdFulfilling_of_ge` the whole forward half off region three, because each region's own
reference run is fully fulfilling to begin with and each region is closed under the direction its
half looks in.
-/

section Tail

variable {G : PlusSlicedCertificate Γ Del}

/-- **The three-region position family.** `m` is the whole shift, `Rp` the reference run through the
chain's first vertex, `c` the chain, `Rq` the reference run through its last. -/
def tailPos (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) : G.Pos :=
  if u < -G.NB - (m : ℤ) then Rp.pos (u + (m : ℤ))
  else if u ≤ -G.NB then c (u - (-G.NB - (m : ℤ))).toNat
  else Rq.pos u

theorem tailPos_left (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (hu : u < -G.NB - (m : ℤ)) : G.tailPos Rp Rq c m u = Rp.pos (u + (m : ℤ)) := by
  rw [tailPos, if_pos hu]

theorem tailPos_mid (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (h1 : -G.NB - (m : ℤ) ≤ u) (h2 : u ≤ -G.NB) :
    G.tailPos Rp Rq c m u = c (u - (-G.NB - (m : ℤ))).toNat := by
  rw [tailPos, if_neg (by omega), if_pos h2]

theorem tailPos_right (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (hu : -G.NB < u) : G.tailPos Rp Rq c m u = Rq.pos u := by
  rw [tailPos, if_neg (by have := G.NB_pos; omega), if_neg (by omega)]

/-- **On the whole closed left half-line the family is the shifted reference run**, the seam
included. -/
theorem tailPos_le (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (hc0 : c 0 = Rp.pos (-G.NB)) (u : ℤ) (hu : u ≤ -G.NB - (m : ℤ)) :
    G.tailPos Rp Rq c m u = Rp.pos (u + (m : ℤ)) := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.tailPos_left Rp Rq c m u h
  · rw [G.tailPos_mid Rp Rq c m u (le_of_eq h.symm) (by have := G.NB_pos; omega),
      show u - (-G.NB - (m : ℤ)) = 0 from by omega,
      show u + (m : ℤ) = -G.NB from by omega]
    simpa using hc0

/-- **On the whole closed right half-line the family is the endpoint's reference run**, the seam
included. -/
theorem tailPos_ge (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (hcm : c m = Rq.pos (-G.NB)) (u : ℤ) (hu : -G.NB ≤ u) :
    G.tailPos Rp Rq c m u = Rq.pos u := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.tailPos_right Rp Rq c m u h
  · rw [← h, G.tailPos_mid Rp Rq c m (-G.NB) (by omega) le_rfl,
      show -G.NB - (-G.NB - (m : ℤ)) = (m : ℤ) from by omega]
    simpa using hcm

/-! ### The two hypotheses `runOfPos` asks for -/

theorem tailPos_mem_posAt (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos)
    (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NB)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (-G.NB - (m : ℤ) + (j : ℤ)))
    (hc0 : c 0 = Rp.pos (-G.NB)) (u : ℤ) :
    G.tailPos Rp Rq c m u ∈ G.posAt u := by
  have hNB := G.NB_pos
  by_cases h1 : u ≤ -G.NB - (m : ℤ)
  · rw [G.tailPos_le Rp Rq c m hc0 u h1]
    have h := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) - (m : ℤ) = u from by omega] at h
    rw [G.posAt_congr h]
    exact Rp.pos_mem_posAt _
  · by_cases h2 : u ≤ -G.NB
    · rw [G.tailPos_mid Rp Rq c m u (by omega) h2]
      have h := hcpos (u - (-G.NB - (m : ℤ))).toNat (by omega)
      rw [show (((u - (-G.NB - (m : ℤ))).toNat : ℕ) : ℤ) = u - (-G.NB - (m : ℤ)) from
          Int.toNat_of_nonneg (by omega),
        show -G.NB - (m : ℤ) + (u - (-G.NB - (m : ℤ))) = u from by omega] at h
      exact h
    · rw [G.tailPos_right Rp Rq c m u (by omega)]
      exact Rq.pos_mem_posAt _

theorem tailPos_mem_succP (G : PlusSlicedCertificate Γ Del) (Rp Rq : G.LabRun) (c : ℕ → G.Pos)
    (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NB)
    (hcstep : ∀ j < m, c (j + 1) ∈ G.succP (-G.NB - (m : ℤ) + (j : ℤ)) (c j))
    (hc0 : c 0 = Rp.pos (-G.NB)) (hcm : c m = Rq.pos (-G.NB)) (u : ℤ) :
    G.tailPos Rp Rq c m (u + 1) ∈ G.succP u (G.tailPos Rp Rq c m u) := by
  have hNB := G.NB_pos
  by_cases h1 : u + 1 ≤ -G.NB - (m : ℤ)
  · rw [G.tailPos_le Rp Rq c m hc0 (u + 1) h1, G.tailPos_le Rp Rq c m hc0 u (by omega)]
    have hs0 := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) - (m : ℤ) = u from by omega] at hs0
    have hs1 := G.slice_sub_mul_NB_of_neg (show u + (m : ℤ) + 1 < 0 from by omega) k
    rw [← hmc, show u + (m : ℤ) + 1 - (m : ℤ) = u + 1 from by omega] at hs1
    rw [G.succP_congr hs0 hs1 _]
    have h := Rp.pos_mem_succP (u + (m : ℤ))
    rwa [show u + (m : ℤ) + 1 = u + 1 + (m : ℤ) from by omega] at h
  · by_cases h2 : -G.NB ≤ u
    · rw [G.tailPos_ge Rp Rq c m hcm (u + 1) (by omega), G.tailPos_ge Rp Rq c m hcm u h2]
      exact Rq.pos_mem_succP u
    · rw [G.tailPos_mid Rp Rq c m (u + 1) (by omega) (by omega),
        G.tailPos_mid Rp Rq c m u (by omega) (by omega),
        show (u + 1 - (-G.NB - (m : ℤ))).toNat = (u - (-G.NB - (m : ℤ))).toNat + 1 from by omega]
      have h := hcstep (u - (-G.NB - (m : ℤ))).toNat (by omega)
      rw [show (((u - (-G.NB - (m : ℤ))).toNat : ℕ) : ℤ) = u - (-G.NB - (m : ℤ)) from
          Int.toNat_of_nonneg (by omega),
        show -G.NB - (m : ℤ) + (u - (-G.NB - (m : ℤ))) = u from by omega] at h
      exact h

/-! ### The headline

`live_of_mem_L₀_tail` is the converse the module header's scope note named as missing; with
`mem_L₀_of_live_tail` it makes `tailStable_iff_window` a genuine biconditional at every time down
the periodic tail.
-/

/-- **Every member of `L₀` is live at every time down the periodic left tail.** -/
theorem live_of_mem_L₀_tail (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {p : G.Pos} (hp : p ∈ G.L₀) :
    G.Live (-G.NB - (k : ℤ) * G.NB) p := by
  have hNB := G.NB_pos
  obtain ⟨Rp, hRpf, hRpp⟩ := G.exists_path_of_live (G.live_of_mem_L₀ hbox hp)
  have hmc : ((k * G.NBnat : ℕ) : ℤ) = (k : ℤ) * G.NB := by rw [NB, Nat.cast_mul]
  have hpm : p ∈ G.iterBack (-G.NB) G.L₀ (k * G.NBnat) := by
    rw [G.iterBack_L₀ hTS k]; exact hp
  obtain ⟨c, hc0, hck, hcpos, hcstep⟩ :=
    G.exists_chain_of_mem_iterBack (-G.NB) (G.liveAt_subset_posAt (-G.NB)) (k * G.NBnat) hpm
  obtain ⟨Rq, hRqf, hRqp⟩ := G.exists_path_of_live (G.live_of_mem_L₀ hbox hck)
  set m := k * G.NBnat with hmdef
  have hc0' : c 0 = Rp.pos (-G.NB) := by rw [hc0, hRpp]
  have hcm' : c m = Rq.pos (-G.NB) := hRqp.symm
  have hP := G.tailPos_mem_posAt Rp Rq c m k hmc hcpos hc0'
  have hS := G.tailPos_mem_succP Rp Rq c m k hmc hcstep hc0' hcm'
  -- the readouts on the two closed half-lines
  have hlabR : ∀ v : ℤ, -G.NB ≤ v → (G.tailPos Rp Rq c m v).2.1 = Rq.lab v := by
    intro v hv
    rw [G.tailPos_ge Rp Rq c m hcm' v hv]
    exact Rq.pos_snd v
  have hlabL : ∀ v : ℤ, v ≤ -G.NB - (m : ℤ) → (G.tailPos Rp Rq c m v).2.1
      = Rp.lab (v + (m : ℤ)) := by
    intro v hv
    rw [G.tailPos_le Rp Rq c m hc0' v hv]
    exact Rp.pos_snd _
  -- the run
  have hfwd : PlusFwdFulfilling (fun v => (G.tailPos Rp Rq c m v).2.1) := by
    refine plusFwdFulfilling_of_ge (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.tailPos Rp Rq c m v)) (-G.NB) ?_
    intro s hs g e hu
    rw [hlabR s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRqf.1 s g e hu
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hlabR r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hlabR v (by omega)]
      exact hr3 v hv1 hv2
  have hbwd : PlusBwdFulfilling (fun v => (G.tailPos Rp Rq c m v).2.1) := by
    refine plusBwdFulfilling_of_le (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.tailPos Rp Rq c m v)) (-G.NB - (m : ℤ)) ?_
    intro s hs g e hu
    rw [hlabL s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRpf.2 (s + (m : ℤ)) g e hu
    refine ⟨r - (m : ℤ), by omega, ?_, ?_⟩
    · rw [hlabL (r - (m : ℤ)) (by omega), show r - (m : ℤ) + (m : ℤ) = r from by omega]
      exact hr2
    · intro v hv1 hv2
      rw [hlabL v (by omega)]
      exact hr3 (v + (m : ℤ)) (by omega) (by omega)
  have hpos : (runOfPos hbox hP hS).pos (-G.NB - (m : ℤ)) = p := by
    rw [runOfPos_pos, G.tailPos_le Rp Rq c m hc0' _ le_rfl,
      show -G.NB - (m : ℤ) + (m : ℤ) = -G.NB from by omega, hRpp]
  rw [← hmc, ← hpos]
  exact G.live_of_path (runOfPos hbox hP hS) ⟨hfwd, hbwd⟩ _

end Tail

/-! ## The right tail

The mirror of everything above, and a **separate construction** rather than a symmetry argument:
`PlusSlicedCertificate` is not symmetric under time reversal (`mid` sits at `[0, G.nm)`, `slice_fwd`
is stated at or past `G.nm` and `slice_neg` strictly below `0`), and `runOfPos` asks for `succP`
steps in the one direction the carrier fixes. So the chain here runs along `predP` and is converted
by `mem_succP_iff_mem_predP`, which is exactly the adjointness that lemma was landed for.
-/

theorem exists_chain_of_mem_iterFwd (G : PlusSlicedCertificate Γ Del) (t : ℤ)
    {X : Finset G.Pos} (hX : X ⊆ G.posAt t) (k : ℕ) {q : G.Pos}
    (hq : q ∈ G.iterFwd t X k) :
    ∃ c : ℕ → G.Pos, c 0 = q ∧ c k ∈ X ∧ (∀ j ≤ k, c j ∈ G.posAt (t + (k : ℤ) - (j : ℤ))) ∧
      ∀ j < k, c (j + 1) ∈ G.predP (t + (k : ℤ) - (j : ℤ)) (c j) := by
  induction k generalizing q with
  | zero =>
    refine ⟨fun _ => q, rfl, hq, ?_, by omega⟩
    intro j hj
    have hj0 : j = 0 := by omega
    subst hj0
    simpa using hX hq
  | succ k ih =>
    rw [iterFwd_succ, mem_stepFwd] at hq
    obtain ⟨hqpos, p, hp1, hp2⟩ := hq
    obtain ⟨c, hc0, hck, hcpos, hcstep⟩ := ih hp2
    refine ⟨fun j => Nat.rec q (fun i _ => c i) j, rfl, hck, ?_, ?_⟩
    · intro j hj
      match j with
      | 0 =>
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((0 : ℕ) : ℤ) = t + (k : ℤ) + 1 from by push_cast; omega]
        exact hqpos
      | (i + 1) =>
        have h := hcpos i (by omega)
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((i + 1 : ℕ) : ℤ) = t + (k : ℤ) - (i : ℤ) from by
          push_cast; omega]
        exact h
    · intro j hj
      match j with
      | 0 =>
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((0 : ℕ) : ℤ) = t + (k : ℤ) + 1 from by push_cast; omega]
        change c 0 ∈ G.predP (t + (k : ℤ) + 1) q
        rw [hc0]
        exact hp1
      | (i + 1) =>
        have h := hcstep i (by omega)
        rw [show t + ((k + 1 : ℕ) : ℤ) - ((i + 1 : ℕ) : ℤ) = t + (k : ℤ) - (i : ℤ) from by
          push_cast; omega]
        exact h

section Head

variable {G : PlusSlicedCertificate Γ Del}

/-- **The three-region position family on the right**, the mirror of `tailPos`. -/
def headPos (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) : G.Pos :=
  if G.NM + G.NF + (m : ℤ) < u then Rq.pos (u - (m : ℤ))
  else if G.NM + G.NF ≤ u then c (G.NM + G.NF + (m : ℤ) - u).toNat
  else Rp.pos u

theorem headPos_far (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (hu : G.NM + G.NF + (m : ℤ) < u) :
    G.headPos Rq Rp c m u = Rq.pos (u - (m : ℤ)) := by
  rw [headPos, if_pos hu]

theorem headPos_mid (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (h1 : u ≤ G.NM + G.NF + (m : ℤ)) (h2 : G.NM + G.NF ≤ u) :
    G.headPos Rq Rp c m u = c (G.NM + G.NF + (m : ℤ) - u).toNat := by
  rw [headPos, if_neg (by omega), if_pos h2]

theorem headPos_near (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (u : ℤ) (hu : u < G.NM + G.NF) : G.headPos Rq Rp c m u = Rp.pos u := by
  rw [headPos, if_neg (by omega), if_neg (by omega)]

/-- **On the whole closed far half-line the family is the shifted reference run.** -/
theorem headPos_ge (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (hc0 : c 0 = Rq.pos (G.NM + G.NF)) (u : ℤ) (hu : G.NM + G.NF + (m : ℤ) ≤ u) :
    G.headPos Rq Rp c m u = Rq.pos (u - (m : ℤ)) := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.headPos_far Rq Rp c m u h
  · rw [G.headPos_mid Rq Rp c m u (le_of_eq h.symm) (by omega),
      show G.NM + G.NF + (m : ℤ) - u = 0 from by omega,
      show u - (m : ℤ) = G.NM + G.NF from by omega]
    simpa using hc0

/-- **On the whole closed near half-line the family is the endpoint's reference run.** -/
theorem headPos_le (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos) (m : ℕ)
    (hcm : c m = Rp.pos (G.NM + G.NF)) (u : ℤ) (hu : u ≤ G.NM + G.NF) :
    G.headPos Rq Rp c m u = Rp.pos u := by
  rcases lt_or_eq_of_le hu with h | h
  · exact G.headPos_near Rq Rp c m u h
  · rw [h, G.headPos_mid Rq Rp c m (G.NM + G.NF) (by omega) le_rfl,
      show G.NM + G.NF + (m : ℤ) - (G.NM + G.NF) = (m : ℤ) from by omega]
    simpa using hcm

theorem headPos_mem_posAt (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos)
    (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NF)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (G.NM + G.NF + (m : ℤ) - (j : ℤ)))
    (hc0 : c 0 = Rq.pos (G.NM + G.NF)) (u : ℤ) :
    G.headPos Rq Rp c m u ∈ G.posAt u := by
  have hNF := G.NF_pos
  have hnm := G.nm_le_NM
  by_cases h1 : G.NM + G.NF + (m : ℤ) ≤ u
  · rw [G.headPos_ge Rq Rp c m hc0 u h1]
    have h := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) from by omega) k
    rw [← hmc, show u - (m : ℤ) + (m : ℤ) = u from by omega] at h
    rw [G.posAt_congr h]
    exact Rq.pos_mem_posAt _
  · by_cases h2 : G.NM + G.NF ≤ u
    · rw [G.headPos_mid Rq Rp c m u (by omega) h2]
      have h := hcpos (G.NM + G.NF + (m : ℤ) - u).toNat (by omega)
      rw [show (((G.NM + G.NF + (m : ℤ) - u).toNat : ℕ) : ℤ) = G.NM + G.NF + (m : ℤ) - u from
          Int.toNat_of_nonneg (by omega),
        show G.NM + G.NF + (m : ℤ) - (G.NM + G.NF + (m : ℤ) - u) = u from by omega] at h
      exact h
    · rw [G.headPos_near Rq Rp c m u (by omega)]
      exact Rp.pos_mem_posAt _

theorem headPos_mem_succP (G : PlusSlicedCertificate Γ Del) (Rq Rp : G.LabRun) (c : ℕ → G.Pos)
    (m k : ℕ) (hmc : (m : ℤ) = (k : ℤ) * G.NF)
    (hcpos : ∀ j ≤ m, c j ∈ G.posAt (G.NM + G.NF + (m : ℤ) - (j : ℤ)))
    (hcstep : ∀ j < m, c (j + 1) ∈ G.predP (G.NM + G.NF + (m : ℤ) - (j : ℤ)) (c j))
    (hc0 : c 0 = Rq.pos (G.NM + G.NF)) (hcm : c m = Rp.pos (G.NM + G.NF)) (u : ℤ) :
    G.headPos Rq Rp c m (u + 1) ∈ G.succP u (G.headPos Rq Rp c m u) := by
  have hNF := G.NF_pos
  have hnm := G.nm_le_NM
  by_cases h1 : G.NM + G.NF + (m : ℤ) ≤ u
  · rw [G.headPos_ge Rq Rp c m hc0 (u + 1) (by omega), G.headPos_ge Rq Rp c m hc0 u h1]
    have hs0 := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) from by omega) k
    rw [← hmc, show u - (m : ℤ) + (m : ℤ) = u from by omega] at hs0
    have hs1 := G.slice_add_mul_NF_of_ge (show G.nm ≤ u - (m : ℤ) + 1 from by omega) k
    rw [← hmc, show u - (m : ℤ) + 1 + (m : ℤ) = u + 1 from by omega] at hs1
    rw [G.succP_congr hs0 hs1 _]
    have h := Rq.pos_mem_succP (u - (m : ℤ))
    rwa [show u - (m : ℤ) + 1 = u + 1 - (m : ℤ) from by omega] at h
  · by_cases h2 : u + 1 ≤ G.NM + G.NF
    · rw [G.headPos_le Rq Rp c m hcm (u + 1) h2, G.headPos_le Rq Rp c m hcm u (by omega)]
      exact Rp.pos_mem_succP u
    · rw [G.headPos_mid Rq Rp c m (u + 1) (by omega) (by omega),
        G.headPos_mid Rq Rp c m u (by omega) (by omega),
        show (G.NM + G.NF + (m : ℤ) - u).toNat
          = (G.NM + G.NF + (m : ℤ) - (u + 1)).toNat + 1 from by omega]
      have hi : ((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat : ℤ)
          = G.NM + G.NF + (m : ℤ) - (u + 1) := Int.toNat_of_nonneg (by omega)
      have harith : G.NM + G.NF + (m : ℤ) - (G.NM + G.NF + (m : ℤ) - (u + 1)) = u + 1 := by omega
      have hstep := hcstep (G.NM + G.NF + (m : ℤ) - (u + 1)).toNat (by omega)
      rw [hi, harith] at hstep
      have hp1 : c ((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat + 1) ∈ G.posAt u := by
        have h := hcpos ((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat + 1) (by omega)
        rw [show (((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat + 1 : ℕ) : ℤ)
            = G.NM + G.NF + (m : ℤ) - u from by push_cast [hi]; omega,
          show G.NM + G.NF + (m : ℤ) - (G.NM + G.NF + (m : ℤ) - u) = u from by omega] at h
        exact h
      have hp2 : c ((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat) ∈ G.posAt (u + 1) := by
        have h := hcpos ((G.NM + G.NF + (m : ℤ) - (u + 1)).toNat) (by omega)
        rw [hi, harith] at h
        exact h
      exact (G.mem_succP_iff_mem_predP u _ _ hp1 hp2).mpr hstep

/-- **Every member of `R₀` is live at every time up the periodic right tail**, the mirror of
`live_of_mem_L₀_tail`. -/
theorem live_of_mem_R₀_head (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) {q : G.Pos} (hq : q ∈ G.R₀) :
    G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q := by
  have hNF := G.NF_pos
  have hnm := G.nm_le_NM
  obtain ⟨Rq, hRqf, hRqp⟩ := G.exists_path_of_live (G.live_of_mem_R₀ hbox hq)
  have hmc : ((k * G.NFnat : ℕ) : ℤ) = (k : ℤ) * G.NF := by rw [NF, Nat.cast_mul]
  have hqm : q ∈ G.iterFwd (G.NM + G.NF) G.R₀ (k * G.NFnat) := G.R₀_subset_iterFwd hTS k hq
  obtain ⟨c, hc0, hck, hcpos, hcstep⟩ :=
    G.exists_chain_of_mem_iterFwd (G.NM + G.NF) (G.liveAt_subset_posAt (G.NM + G.NF))
      (k * G.NFnat) hqm
  obtain ⟨Rp, hRpf, hRpp⟩ := G.exists_path_of_live (G.live_of_mem_R₀ hbox hck)
  set m := k * G.NFnat with hmdef
  have hc0' : c 0 = Rq.pos (G.NM + G.NF) := by rw [hc0, hRqp]
  have hcm' : c m = Rp.pos (G.NM + G.NF) := hRpp.symm
  have hP := G.headPos_mem_posAt Rq Rp c m k hmc hcpos hc0'
  have hS := G.headPos_mem_succP Rq Rp c m k hmc hcpos hcstep hc0' hcm'
  have hlabF : ∀ v : ℤ, G.NM + G.NF + (m : ℤ) ≤ v →
      (G.headPos Rq Rp c m v).2.1 = Rq.lab (v - (m : ℤ)) := by
    intro v hv
    rw [G.headPos_ge Rq Rp c m hc0' v hv]
    exact Rq.pos_snd _
  have hlabN : ∀ v : ℤ, v ≤ G.NM + G.NF → (G.headPos Rq Rp c m v).2.1 = Rp.lab v := by
    intro v hv
    rw [G.headPos_le Rq Rp c m hcm' v hv]
    exact Rp.pos_snd v
  have hfwd : PlusFwdFulfilling (fun v => (G.headPos Rq Rp c m v).2.1) := by
    refine plusFwdFulfilling_of_ge (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.headPos Rq Rp c m v)) (G.NM + G.NF + (m : ℤ)) ?_
    intro s hs g e hu
    rw [hlabF s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRqf.1 (s - (m : ℤ)) g e hu
    refine ⟨r + (m : ℤ), by omega, ?_, ?_⟩
    · rw [hlabF (r + (m : ℤ)) (by omega), show r + (m : ℤ) - (m : ℤ) = r from by omega]
      exact hr2
    · intro v hv1 hv2
      rw [hlabF v (by omega)]
      exact hr3 (v - (m : ℤ)) (by omega) (by omega)
  have hbwd : PlusBwdFulfilling (fun v => (G.headPos Rq Rp c m v).2.1) := by
    refine plusBwdFulfilling_of_le (coherent_of_pos hbox hP hS)
      (fun v => G.pos_lab_sub (G.headPos Rq Rp c m v)) (G.NM + G.NF) ?_
    intro s hs g e hu
    rw [hlabN s hs] at hu
    obtain ⟨r, hr1, hr2, hr3⟩ := hRpf.2 s g e hu
    refine ⟨r, hr1, ?_, ?_⟩
    · rw [hlabN r (by omega)]; exact hr2
    · intro v hv1 hv2
      rw [hlabN v (by omega)]
      exact hr3 v hv1 hv2
  have hpos : (runOfPos hbox hP hS).pos (G.NM + G.NF + (m : ℤ)) = q := by
    rw [runOfPos_pos, G.headPos_ge Rq Rp c m hc0' _ le_rfl,
      show G.NM + G.NF + (m : ℤ) - (m : ℤ) = G.NM + G.NF from by omega, hRqp]
  rw [← hmc, ← hpos]
  exact G.live_of_path (runOfPos hbox hP hS) ⟨hfwd, hbwd⟩ _

end Head

/-! ## `tailStable_iff_window`

The plan's linchpin, now a genuine biconditional at every time down either periodic tail: under
tail-stability the computed reference set `L₀` **is** the true live set at every `-G.NB - k * G.NB`,
and `R₀` at every `G.NM + G.NF + k * G.NF`. The `→` direction is the transfer's soundness iterated
(`mem_L₀_of_live_tail`) and the `←` direction the three-region run (`live_of_mem_L₀_tail`); neither
is a `simp`, and neither would hold without the demand — `Fixture.live_not_determined_by_slice` is
a certificate where the two sides come apart at one period.
-/

/-- **The linchpin, on the left tail.** -/
theorem tailStable_iff_window (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (p : G.Pos) :
    p ∈ G.L₀ ↔ G.Live (-G.NB - (k : ℤ) * G.NB) p :=
  ⟨fun hp => G.live_of_mem_L₀_tail hbox hTS k hp, fun hp => G.mem_L₀_of_live_tail hTS k hp⟩

/-- **The linchpin, on the right tail.** -/
theorem tailStable_iff_window_fwd (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (q : G.Pos) :
    q ∈ G.R₀ ↔ G.Live (G.NM + G.NF + (k : ℤ) * G.NF) q :=
  ⟨fun hq => G.live_of_mem_R₀_head hbox hTS k hq, fun hq => G.mem_R₀_of_live_head hTS k hq⟩

/-- **The live set is the same at every period-multiple of the left tail.** The form a checker
reads: `liveAt` at any such time is literally `L₀`. -/
theorem liveAt_tail_eq_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) (k : ℕ) (hw : -G.NB - (k : ℤ) * G.NB ∈ G.winTimes) :
    G.liveAt (-G.NB - (k : ℤ) * G.NB) = G.L₀ := by
  ext p
  rw [G.mem_liveAt_iff_live hbox hw p]
  exact (G.tailStable_iff_window hbox hTS k p).symm

/-- **The window's own left endpoint is the `k = 1` instance**, with equality rather than the
inclusion `liveAt_winLo_subset_L₀` gives on its own. -/
theorem liveAt_winLo_eq_L₀ (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hTS : G.TailStable) : G.liveAt G.winLo = G.L₀ := by
  have hw : -G.NB - ((1 : ℕ) : ℤ) * G.NB = G.winLo := by
    rw [show G.winLo = -2 * G.NB from rfl]; push_cast; omega
  rw [← hw]
  exact G.liveAt_tail_eq_L₀ hbox hTS 1 (by rw [hw]; exact G.winLo_mem_winTimes)

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
