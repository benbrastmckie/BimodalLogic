/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Window

/-!
# The Rolled Timed Carrier, and the Wrapping Time Successors

`Position.lean`'s carrier factors time **out**: `Pos := Fin G.n × Lab Γ Del`, so time reappears
as an index on `posAt` and `succP`. A greatest fixpoint of a slice-indexed condition therefore
lives in `(Finset Pos)^ℤ`, a lattice of infinite height. This module rolls the time back **in** —
`TPos := G.Pos × ℤ` — and puts the finiteness on a `Finset` of vertices instead, which is what
makes a `Finset` iteration terminate.

## `TPos` is deliberately NOT a `Fintype`

It cannot be: its time coordinate is `ℤ`. That is not an oversight to be patched with an instance —
keeping the time coordinate in the carrier is the whole point, and it is exactly what
`WitnessFamily/Sharing/Fulfil.lean`'s own docstring records about `SharingWitnessFamily.Pos` (whose
`Fin S.lassos.length × ℤ` this module mirrors name for name). Finiteness lives on `verts`, a
`Finset TPos`, and the `Fintype` a fixpoint needs comes free from it — confirmed by an `example`
below rather than asserted.

`AUFix` is stated at `{α : Type*} [DecidableEq α]` with an explicit `V : Finset α` and terminates by
`V.card`, so it applies here with no `Fintype` anywhere. Termination never needed eventual
periodicity.

## What eventual periodicity IS for: the wrap

`nextTime` steps to `u + 1` except at the window's right edge, where it folds back by one combined
forward period; `prevTime` mirrors it at the left edge. The fold is sound because the slice
sequence **and** the target path are both periodic there — which is why the window has to be the
combined one of `Window.lean` and not `Basic.lean`'s single-source one. The four faithfulness
lemmas `slice_nextTime`, `slice_prevTime`, `target_datum_nextTime` and `target_datum_prevTime` are
what "sound" means, and each is a residue computation against a divisor of the combined period,
not an induction.

`posAt_nextTime` / `posAt_prevTime` lift that to the position space, and they are the reason the
graph of the next sub-step may read `succP` at the **unwrapped** time while placing its result
at the **wrapped** one.

## Why the window must be doubled, not merely combined

`Fixture.window_verdict` proves that a position can be live at `-NB` and dead at `-2 * NB` with
the slice and the position set literally equal at both. So `prevTime`'s fold at the left edge must
land at `-NB - 1`'s representative and not conflate the first period with the rest;
`winLo = -2 * NB` is what makes that possible. The fixture is a proved lemma about a named
certificate, not an expectation.

## What this module does NOT yet contain

The timed graph `succT` / `predT` (STEP 4), the two fixpoints (STEP 5) and the bridge proving the
computed object equals `Live.lean`'s declarative `Live` at the times the checker reads (STEP 6) are
**not** here. Nothing is stubbed for them and no placeholder stands in. `slice_nextTime_pred` and
`slice_prevTime_succ` are landed here because they are what STEP 4's adjointness will need, and they
belong with the other wrap lemmas rather than with the graph.

## Main definitions

- `PlusSlicedCertificate.TPos` — the rolled timed carrier
- `PlusSlicedCertificate.verts` — the finite vertex set: genuine positions at window times
- `PlusSlicedCertificate.nextTime` / `prevTime` — the wrapping time successors

## Main results

- `PlusSlicedCertificate.mem_verts`, and the `Fintype` on `verts`' subtype by `inferInstance`
- `PlusSlicedCertificate.nextTime_edge` / `prevTime_edge` — what the fold does at each edge
- `PlusSlicedCertificate.nextTime_mem` / `prevTime_mem` — the graph never leaves the window
- `PlusSlicedCertificate.slice_nextTime` / `slice_prevTime` / `target_datum_nextTime` /
  `target_datum_prevTime` — the wraps preserve **both** objects' data
- `PlusSlicedCertificate.posAt_congr`, `posAt_nextTime` / `posAt_prevTime`
- `PlusSlicedCertificate.slice_nextTime_pred` / `slice_prevTime_succ`

## Tags

plus-language · certificate · time-sliced · rolled-carrier · wrapping
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The position space depends on the time only through the slice

Two small lemmas that belong with `Position.lean`'s development and are landed here instead so that
no already-landed module has to be reopened. They are what lets every wrap lemma below be stated
about `slice` and then used about `posAt`.
-/

/-- The slice labelling depends on the time only through the slice. -/
theorem slab_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (h : G.slice t = G.slice s)
    (w : Fin G.n) : G.slab t w = G.slab s w := by
  rw [slab, slab, h]

/-- **The position space depends on the time only through the slice.** -/
theorem posAt_congr (G : PlusSlicedCertificate Γ Del) {t s : ℤ} (h : G.slice t = G.slice s) :
    G.posAt t = G.posAt s := by
  ext p
  rw [mem_posAt, mem_posAt]
  constructor
  · intro hp
    refine ⟨hp.1, fun ψ hψ hst => ?_⟩
    rw [← G.slab_congr h p.1]
    exact hp.2 ψ hψ hst
  · intro hp
    refine ⟨hp.1, fun ψ hψ hst => ?_⟩
    rw [G.slab_congr h p.1]
    exact hp.2 ψ hψ hst

/-! ## The rolled carrier -/

/-- **A timed position**: a slice position together with a time. Deliberately **not** a `Fintype`;
see this module's header. -/
abbrev TPos (G : PlusSlicedCertificate Γ Del) : Type := G.Pos × ℤ

/--
**The vertices of the timed graph**: the genuine positions of their own slice, at window times.

The `posAt` filter is a deliberate departure from `SharingWitnessFamily.verts`, which is
`Finset.univ ×ˢ winTimes` outright. There the first coordinate is a lasso index and every index is
legitimate at every time; here it is a (state, label) pair and `Position.lean`'s `posAt` is exactly
the predicate separating the legitimate ones. Starting a greatest-fixpoint iteration from a set
containing label-state pairs that are not positions of their slice would make the fixpoint's
statement harder rather than easier.
-/
def verts (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  (Finset.univ ×ˢ G.winTimes).filter (fun v => v.1 ∈ G.posAt v.2)

theorem mem_verts (G : PlusSlicedCertificate Γ Del) (v : G.TPos) :
    v ∈ G.verts ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2 := by
  simp [verts, Finset.mem_product]

theorem snd_mem_winTimes_of_mem_verts (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (h : v ∈ G.verts) : v.2 ∈ G.winTimes := ((G.mem_verts v).mp h).1

theorem fst_mem_posAt_of_mem_verts (G : PlusSlicedCertificate Γ Del) {v : G.TPos}
    (h : v ∈ G.verts) : v.1 ∈ G.posAt v.2 := ((G.mem_verts v).mp h).2

/-- **The `Fintype` a fixpoint needs comes free from `verts`**, with `TPos` itself remaining
infinite. Confirmed rather than asserted. -/
example (G : PlusSlicedCertificate Γ Del) : Fintype {v : G.TPos // v ∈ G.verts} := inferInstance

/-- **`DecidableEq` is all `AUFix` asks of the carrier**, and it is available. -/
example (G : PlusSlicedCertificate Γ Del) : DecidableEq G.TPos := inferInstance

/-! ## The wrapping time successors -/

/-- The successor time inside the window: `u + 1`, folded back by one combined forward period at the
right edge so the graph never leaves the window. -/
def nextTime (G : PlusSlicedCertificate Γ Del) (u : ℤ) : ℤ :=
  if u + 1 < G.winHi then u + 1 else u + 1 - G.NF

/-- The predecessor time inside the window, the leftward mirror of `nextTime`. -/
def prevTime (G : PlusSlicedCertificate Γ Del) (u : ℤ) : ℤ :=
  if G.winLo ≤ u - 1 then u - 1 else u - 1 + G.NB

/-- **What the fold does at the right edge.** -/
theorem nextTime_edge (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes)
    (hw : ¬ u + 1 < G.winHi) : u + 1 = G.NM + 2 * G.NF ∧ G.nextTime u = G.NM + G.NF := by
  rw [G.mem_winTimes] at hu
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  refine ⟨by omega, ?_⟩
  simp only [nextTime, if_neg hw]
  omega

/-- **What the fold does at the left edge.** -/
theorem prevTime_edge (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes)
    (hw : ¬ G.winLo ≤ u - 1) : u - 1 = -2 * G.NB - 1 ∧ G.prevTime u = -G.NB - 1 := by
  rw [G.mem_winTimes] at hu
  have hLo : G.winLo = -2 * G.NB := rfl
  refine ⟨by omega, ?_⟩
  simp only [prevTime, if_neg hw]
  omega

/-- **The graph never leaves the window, forwards.** -/
theorem nextTime_mem (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.nextTime u ∈ G.winTimes := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes] at hu ⊢
  by_cases hw : u + 1 < G.winHi
  · simp only [nextTime, if_pos hw]
    omega
  · obtain ⟨-, he⟩ := G.nextTime_edge (by rw [G.mem_winTimes]; exact hu) hw
    rw [he]
    omega

/-- **The graph never leaves the window, backwards.** -/
theorem prevTime_mem (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.prevTime u ∈ G.winTimes := by
  have hB := G.NB_pos
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hLo : G.winLo = -2 * G.NB := rfl
  have hHi : G.winHi = G.NM + 2 * G.NF := rfl
  rw [G.mem_winTimes] at hu ⊢
  by_cases hw : G.winLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
    omega
  · obtain ⟨-, he⟩ := G.prevTime_edge (by rw [G.mem_winTimes]; exact hu) hw
    rw [he]
    omega

/-! ### The wraps preserve both objects' data

The four lemmas that make the fold sound. Each is a residue computation: the two times differ by one
**combined** period, and each object's own period divides it (`nb_dvd_NB`, `nf_dvd_NF`, and the two
target-side facts). This is where the combined window of `Window.lean` earns its definition — a
single-source window could not state these at all, because one of the two objects would be folded by
a period that is not its own.
-/

/-- **The forward wrap preserves the slice sequence.** -/
theorem slice_nextTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.slice (G.nextTime u) = G.slice (u + 1) := by
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hnm := G.nm_le_NM
  by_cases hw : u + 1 < G.winHi
  · simp only [nextTime, if_pos hw]
  · obtain ⟨hue, he⟩ := G.nextTime_edge hu hw
    rw [he, hue, G.slice_fwd (by omega), G.slice_fwd (by omega)]
    refine Periodic.cyc_congr (Int.modEq_iff_dvd.mpr ?_)
    rw [show G.NM + 2 * G.NF - G.nm - (G.NM + G.NF - G.nm) = G.NF from by omega]
    exact G.nf_dvd_NF

/-- **The backward wrap preserves the slice sequence.** -/
theorem slice_prevTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.slice (G.prevTime u) = G.slice (u - 1) := by
  have hB := G.NB_pos
  by_cases hw : G.winLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
  · obtain ⟨hue, he⟩ := G.prevTime_edge hu hw
    rw [he, hue, G.slice_neg (by omega), G.slice_neg (by omega)]
    refine Periodic.cyc_congr (Int.ModEq.symm (Int.modEq_iff_dvd.mpr ?_))
    rw [show -G.NB - 1 - (-2 * G.NB - 1) = G.NB from by omega]
    exact G.nb_dvd_NB

/-- **The forward wrap preserves the target path's data.** -/
theorem target_datum_nextTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.target.datum (G.nextTime u) = G.target.datum (u + 1) := by
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hnm := G.target_nm_le_NM
  by_cases hw : u + 1 < G.winHi
  · simp only [nextTime, if_pos hw]
  · obtain ⟨hue, he⟩ := G.nextTime_edge hu hw
    rw [he, hue, G.target.datum_fwd (by omega), G.target.datum_fwd (by omega)]
    refine @Periodic.cyc_congr _ G.target.inh _ _ _ (Int.modEq_iff_dvd.mpr ?_)
    rw [show G.NM + 2 * G.NF - G.target.nm - (G.NM + G.NF - G.target.nm) = G.NF from by omega]
    exact G.target_nf_dvd_NF

/-- **The backward wrap preserves the target path's data.** -/
theorem target_datum_prevTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.target.datum (G.prevTime u) = G.target.datum (u - 1) := by
  have hB := G.NB_pos
  by_cases hw : G.winLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
  · obtain ⟨hue, he⟩ := G.prevTime_edge hu hw
    rw [he, hue, G.target.datum_neg (by omega), G.target.datum_neg (by omega)]
    refine @Periodic.cyc_congr _ G.target.inh _ _ _
      (Int.ModEq.symm (Int.modEq_iff_dvd.mpr ?_))
    rw [show -G.NB - 1 - (-2 * G.NB - 1) = G.NB from by omega]
    exact G.target_nb_dvd_NB

/-! ### The wraps preserve the position space

What lets the timed graph read `succP` at the **unwrapped** time and place the result at the
**wrapped** one.
-/

/-- **The forward wrap preserves the position space.** -/
theorem posAt_nextTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.posAt (G.nextTime u) = G.posAt (u + 1) :=
  G.posAt_congr (G.slice_nextTime hu)

/-- **The backward wrap preserves the position space.** -/
theorem posAt_prevTime (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.posAt (G.prevTime u) = G.posAt (u - 1) :=
  G.posAt_congr (G.slice_prevTime hu)

/-! ### The two lemmas STEP 4's adjointness will need

Landed with the other wrap lemmas rather than with the graph, because they are facts about the fold
and not about any edge relation.
-/

/-- **One step back from the forward wrap's target recovers the source slice.** -/
theorem slice_nextTime_pred (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.slice (G.nextTime u - 1) = G.slice u := by
  have hF := G.NF_pos
  have hM := G.NM_nonneg
  have hnm := G.nm_le_NM
  by_cases hw : u + 1 < G.winHi
  · simp only [nextTime, if_pos hw]
    rw [show u + 1 - 1 = u from by omega]
  · obtain ⟨hue, he⟩ := G.nextTime_edge hu hw
    rw [he, G.slice_fwd (by omega), G.slice_fwd (by omega)]
    refine Periodic.cyc_congr (Int.modEq_iff_dvd.mpr ?_)
    rw [show u - G.nm - (G.NM + G.NF - 1 - G.nm) = G.NF from by omega]
    exact G.nf_dvd_NF

/-- **One step forward from the backward wrap's target recovers the source slice.** -/
theorem slice_prevTime_succ (G : PlusSlicedCertificate Γ Del) {u : ℤ} (hu : u ∈ G.winTimes) :
    G.slice (G.prevTime u + 1) = G.slice u := by
  have hB := G.NB_pos
  by_cases hw : G.winLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
    rw [show u - 1 + 1 = u from by omega]
  · obtain ⟨hue, he⟩ := G.prevTime_edge hu hw
    rw [he, G.slice_neg (by omega), G.slice_neg (by omega)]
    refine Periodic.cyc_congr (Int.ModEq.symm (Int.modEq_iff_dvd.mpr ?_))
    rw [show -G.NB - 1 + 1 - u = G.NB from by omega]
    exact G.nb_dvd_NB

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
