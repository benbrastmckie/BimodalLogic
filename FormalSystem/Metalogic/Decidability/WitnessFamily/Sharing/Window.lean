/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Decide

/-!
# The Label-Free Position Graph

`SharingSkeleton` carries the branching substrate — the per-time equivalence `share`, the
threads, the quotient frame and its histories — and mentions no formula and no label. What it
does **not** carry is the *combined window*: the bounded interval of times whose check decides
a condition at every time.

That is not an oversight. A certificate's combined backward period is

```
perBack = |repBack| * ∏ᵢ |lassoᵢ.back|
```

— a join of the skeleton's representative-segment lengths with the **lassos'** label-segment
lengths — so it is not a function of the skeleton alone, and neither is anything defined over
the window. The measurement that opened this module recorded exactly that: the position graph
does not factor onto `SharingSkeleton`.

`SharingWindow` is the structure it factors onto instead. It extends `SharingSkeleton` by the
combined-period triple `(NB, NF, NM)` as **data**, together with the six facts that make the
triple a legitimate window for the skeleton's own representative maps: positivity, and
compatibility with the three representative-segment lengths. A certificate supplies the triple
from its own combined periods; nothing here computes them, and nothing here knows what a label
is.

## What lives here, and why all of it

Every declaration below is label-free, and that is the whole content of the module's claim to
exist:

* the window `cohWindowLo`/`cohWindowHi` and its times;
* the position graph — vertices, the two wrapped time-steps, the two edge relations;
* the two folding relations that read a graph walk as a walk in the bi-infinite position space;
* the walk layer, `FwdWalk`/`BwdWalk` and their `toThread`.

What is *not* here is everything that reads a label: the `atPos` predicate, the two `A[g U e]`
fixpoints instantiated at a language's formulas, and the window form of (C2'). Those are
per-language and live with their language's certificate.

## The window is two periods wide on each side

`cohWindowLo`/`cohWindowHi` are two combined periods wide rather than one, because the
conditions that run against this window read `t - 1` and `t + 1` as well as `t`: a representative
must have its whole one-step neighbourhood inside the periodic region, not merely itself.

## The time coordinate stays in the vertex

`Pos` is `Fin n × ℤ` and is deliberately **not** a `Fintype`: finiteness lives on `verts`, a
`Finset` of `Pos`, and the graph is carried as a `Finset`-valued successor function rather than
as a relation on a `Fintype`. Keeping the time coordinate in the carrier is what makes the
pigeonhole step that collapses a finite digraph's positions inapplicable to this design.

## Main Definitions

- `SharingWindow` — a skeleton together with a combined-period triple
- `SharingWindow.cohWindowLo` / `cohWindowHi` / `winTimes` — the window
- `SharingWindow.Pos` / `verts` — the position graph's vertices
- `SharingWindow.nextTime` / `prevTime` — the two wrapped time-steps
- `SharingWindow.succF` / `predF` — the two edge relations
- `SharingWindow.FoldRel` / `FoldRelB` — the two folding relations
- `SharingWindow.FwdWalk` / `BwdWalk` and their `toThread` — walks as threads

## Main Results

- `SharingWindow.rep_congr_NB` / `rep_congr_NF` — the representatives read only their residue
- `SharingWindow.nextTime_mem` / `prevTime_mem` — the graph never leaves the window
- `SharingWindow.rep_nextTime` / `rep_prevTime` — the wraps preserve the representatives
- `SharingWindow.succF_nonempty` / `predF_nonempty` — the graph has no dead ends
- `SharingWindow.exists_fold_fwd` / `exists_fold_back` — every time folds into the window
- `SharingWindow.FwdWalk.toThread` / `BwdWalk.toThread` — a graph walk is a genuine thread
-/

namespace FormalSystem.Metalogic.Decidability

/--
**A branching substrate together with a combined window.**

The triple `(NB, NF, NM)` is data rather than a computation: a certificate's combined periods
join its representative-segment lengths with its lassos' label-segment lengths, so they are not
functions of the skeleton. The six facts are what make the triple usable — positivity of the two
periods, non-negativity of the offset, and compatibility with the skeleton's own three segment
lengths, which is what lets `rep_congr_NB`/`rep_congr_NF` descend from `Periodic`'s congruences.
-/
structure SharingWindow extends SharingSkeleton where
  /-- The combined backward period. -/
  NB : ℤ
  /-- The combined forward period. -/
  NF : ℤ
  /-- The combined window offset: at or past it, every rightward decoding is periodic. -/
  NM : ℤ
  /-- The combined backward period is positive. -/
  NB_pos : 0 < NB
  /-- The combined forward period is positive. -/
  NF_pos : 0 < NF
  /-- The combined window offset is non-negative. -/
  NM_nonneg : 0 ≤ NM
  /-- The combined backward period is a multiple of the representative cycle's length. -/
  nbr_dvd_NB : (repBack.length : ℤ) ∣ NB
  /-- The combined forward period is a multiple of the representative cycle's length. -/
  nfr_dvd_NF : (repFwd.length : ℤ) ∣ NF
  /-- The combined offset is at or past the representative window's end. -/
  nmr_le_NM : (repMid.length : ℤ) ≤ NM

namespace SharingWindow

/-! ## The representative maps read only their residue -/

/-- Negative times with equal residues modulo the representative cycle decode equally. -/
theorem rep_congr_back (W : SharingWindow) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % W.nbr = v % W.nbr) : W.rep u = W.rep v :=
  Periodic.unrollOf_congr_back (repIdInhabited _) W.repBack W.repMid W.repFwd hu hv h

/-- Times at or past the representative window with equal residues decode equally. -/
theorem rep_congr_fwd (W : SharingWindow) {u v : ℤ} (hu : W.nmr ≤ u) (hv : W.nmr ≤ v)
    (h : (u - W.nmr) % W.nfr = (v - W.nmr) % W.nfr) : W.rep u = W.rep v :=
  Periodic.unrollOf_congr_fwd (repIdInhabited _) W.repBack W.repMid W.repFwd hu hv h

/--
**Leftward congruence at the combined period.** The representative-cycle length divides `NB`, so
a congruence at the combined period descends to one at the cycle.
-/
theorem rep_congr_NB (W : SharingWindow) {u v : ℤ} (hu : u < 0) (hv : v < 0)
    (h : u % W.NB = v % W.NB) : W.rep u = W.rep v :=
  W.rep_congr_back hu hv (emod_of_dvd W.nbr_dvd_NB h)

/--
**Rightward congruence at the combined period.** The comparison is stated at the combined offset
`NM`, so it must first be shifted to the representative offset `nmr`, which `nmr_le_NM` and
`emod_shift` do.
-/
theorem rep_congr_NF (W : SharingWindow) {u v : ℤ} (hu : W.NM ≤ u) (hv : W.NM ≤ v)
    (h : (u - W.NM) % W.NF = (v - W.NM) % W.NF) : W.rep u = W.rep v := by
  have h1 : (u - W.NM) % W.nfr = (v - W.NM) % W.nfr := emod_of_dvd W.nfr_dvd_NF h
  have h2 : ((u - W.NM) + (W.NM - W.nmr)) % W.nfr = ((v - W.NM) + (W.NM - W.nmr)) % W.nfr :=
    LabelledLasso.emod_shift h1
  rw [show (u - W.NM) + (W.NM - W.nmr) = u - W.nmr by omega,
    show (v - W.NM) + (W.NM - W.nmr) = v - W.nmr by omega] at h2
  exact W.rep_congr_fwd (le_trans W.nmr_le_NM hu) (le_trans W.nmr_le_NM hv) h2

/-! ## The combined window -/

/-- Lower end of the combined window. -/
def cohWindowLo (W : SharingWindow) : ℤ := -2 * W.NB

/-- Upper end (exclusive) of the combined window. -/
def cohWindowHi (W : SharingWindow) : ℤ := W.NM + 2 * W.NF

/-- The times of the combined window. -/
def winTimes (W : SharingWindow) : Finset ℤ :=
  Finset.Ico W.cohWindowLo W.cohWindowHi

theorem mem_winTimes (W : SharingWindow) (u : ℤ) :
    u ∈ W.winTimes ↔ W.cohWindowLo ≤ u ∧ u < W.cohWindowHi := Finset.mem_Ico

/-! ## The position graph -/

/-- A position: an index and a time. -/
abbrev Pos (W : SharingWindow) : Type := Fin W.n × ℤ

/-- The vertices of the position graph: every index at every window time. -/
def verts (W : SharingWindow) : Finset W.Pos := Finset.univ ×ˢ W.winTimes

theorem mem_verts (W : SharingWindow) (v : W.Pos) : v ∈ W.verts ↔ v.2 ∈ W.winTimes := by
  simp [verts, Finset.mem_product]

/--
**The vertex set is finite.**

`Pos` itself is not a `Fintype` and cannot be: its time coordinate is `ℤ`, and keeping the time
coordinate in the carrier is precisely the feature that makes a pigeonhole collapse of the
graph's positions inapplicable to this design. Finiteness therefore lives on `verts`, a `Finset`
of `Pos`, and the `Fintype` a fixpoint over the graph needs comes free from it.
-/
example (W : SharingWindow) : Fintype {v : W.Pos // v ∈ W.verts} := inferInstance

/--
The successor time inside the window: `u + 1`, wrapped back by one forward period at the right
edge so the graph never leaves the window.
-/
def nextTime (W : SharingWindow) (u : ℤ) : ℤ :=
  if u + 1 < W.cohWindowHi then u + 1 else u + 1 - W.NF

/-- The predecessor time inside the window, the leftward mirror of `nextTime`. -/
def prevTime (W : SharingWindow) (u : ℤ) : ℤ :=
  if W.cohWindowLo ≤ u - 1 then u - 1 else u - 1 + W.NB

/-- At the right edge of the window the successor time is exactly the wrap target. -/
theorem nextTime_edge (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes)
    (hw : ¬ u + 1 < W.cohWindowHi) : u + 1 = W.NM + 2 * W.NF ∧ W.nextTime u = W.NM + W.NF := by
  obtain ⟨_, hhi⟩ := (W.mem_winTimes u).mp hu
  have hHi : W.cohWindowHi = W.NM + 2 * W.NF := rfl
  refine ⟨by omega, ?_⟩
  simp only [nextTime, if_neg hw]
  omega

/-- At the left edge of the window the predecessor time is exactly the wrap target. -/
theorem prevTime_edge (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes)
    (hw : ¬ W.cohWindowLo ≤ u - 1) : u - 1 = -2 * W.NB - 1 ∧ W.prevTime u = -W.NB - 1 := by
  obtain ⟨hlo, _⟩ := (W.mem_winTimes u).mp hu
  have hLo : W.cohWindowLo = -2 * W.NB := rfl
  refine ⟨by omega, ?_⟩
  simp only [prevTime, if_neg hw]
  omega

theorem nextTime_mem (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.nextTime u ∈ W.winTimes := by
  have hNB := W.NB_pos
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  obtain ⟨hlo, hhi⟩ := (W.mem_winTimes u).mp hu
  have hLo : W.cohWindowLo = -2 * W.NB := rfl
  have hHi : W.cohWindowHi = W.NM + 2 * W.NF := rfl
  rw [W.mem_winTimes]
  by_cases hw : u + 1 < W.cohWindowHi
  · simp only [nextTime, if_pos hw]; omega
  · obtain ⟨_, he⟩ := W.nextTime_edge hu hw
    rw [he]; omega

theorem prevTime_mem (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.prevTime u ∈ W.winTimes := by
  have hNB := W.NB_pos
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  obtain ⟨hlo, hhi⟩ := (W.mem_winTimes u).mp hu
  have hLo : W.cohWindowLo = -2 * W.NB := rfl
  have hHi : W.cohWindowHi = W.NM + 2 * W.NF := rfl
  rw [W.mem_winTimes]
  by_cases hw : W.cohWindowLo ≤ u - 1
  · simp only [prevTime, if_pos hw]; omega
  · obtain ⟨_, he⟩ := W.prevTime_edge hu hw
    rw [he]; omega

/-! ### The wraps preserve the representative maps -/

/-- The forward wrap does not change the representative map. -/
theorem rep_nextTime (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.rep (W.nextTime u) = W.rep (u + 1) := by
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  by_cases hw : u + 1 < W.cohWindowHi
  · simp only [nextTime, if_pos hw]
  · obtain ⟨hue, he⟩ := W.nextTime_edge hu hw
    rw [he, hue]
    refine W.rep_congr_NF (by omega) (by omega) ?_
    rw [show W.NM + W.NF - W.NM = 0 + 1 * W.NF by omega,
      show W.NM + 2 * W.NF - W.NM = 0 + 2 * W.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- The backward wrap does not change the representative map. -/
theorem rep_prevTime (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.rep (W.prevTime u) = W.rep (u - 1) := by
  have hNB := W.NB_pos
  by_cases hw : W.cohWindowLo ≤ u - 1
  · simp only [prevTime, if_pos hw]
  · obtain ⟨hue, he⟩ := W.prevTime_edge hu hw
    rw [he, hue]
    refine W.rep_congr_NB (by omega) (by omega) ?_
    rw [show -W.NB - 1 = (-1 - W.NB) + 0 * W.NB by omega,
      show -2 * W.NB - 1 = (-1 - W.NB) + (-1) * W.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-! ### The two edge relations -/

/--
The successors of a position: every index sharing the state one step later, at the window's
successor time. `Step` at the underlying times, folded into the window.
-/
def succF (W : SharingWindow) (v : W.Pos) : Finset W.Pos :=
  W.verts.filter (fun w => w.2 = W.nextTime v.2 ∧ W.share (v.2 + 1) v.1 w.1)

/-- The predecessors of a position, the converse edge relation. -/
def predF (W : SharingWindow) (v : W.Pos) : Finset W.Pos :=
  W.verts.filter (fun w => w.2 = W.prevTime v.2 ∧ W.share v.2 v.1 w.1)

theorem mem_succF (W : SharingWindow) (v w : W.Pos) :
    w ∈ W.succF v ↔ w ∈ W.verts ∧ w.2 = W.nextTime v.2 ∧ W.share (v.2 + 1) v.1 w.1 :=
  Finset.mem_filter

theorem mem_predF (W : SharingWindow) (v w : W.Pos) :
    w ∈ W.predF v ↔ w ∈ W.verts ∧ w.2 = W.prevTime v.2 ∧ W.share v.2 v.1 w.1 :=
  Finset.mem_filter

theorem succF_subset (W : SharingWindow) (v : W.Pos) : W.succF v ⊆ W.verts :=
  Finset.filter_subset _ _

theorem predF_subset (W : SharingWindow) (v : W.Pos) : W.predF v ⊆ W.verts :=
  Finset.filter_subset _ _

/-- **Every vertex has a successor**: staying on the same index is always a step, because
`share` is reflexive. The graph has no dead ends, so a walk can always be continued. -/
theorem succF_nonempty (W : SharingWindow) {v : W.Pos} (hv : v ∈ W.verts) :
    (W.succF v).Nonempty := by
  refine ⟨(v.1, W.nextTime v.2), ?_⟩
  rw [W.mem_succF]
  exact ⟨(W.mem_verts _).mpr (W.nextTime_mem ((W.mem_verts v).mp hv)), rfl,
    W.share_refl (v.2 + 1) v.1⟩

/-- **Every vertex has a predecessor**, for the same reason. -/
theorem predF_nonempty (W : SharingWindow) {v : W.Pos} (hv : v ∈ W.verts) :
    (W.predF v).Nonempty := by
  refine ⟨(v.1, W.prevTime v.2), ?_⟩
  rw [W.mem_predF]
  exact ⟨(W.mem_verts _).mpr (W.prevTime_mem ((W.mem_verts v).mp hv)), rfl,
    W.share_refl v.2 v.1⟩

/-! ## Folding a ℤ-time into the window

A walk in the position graph is not literally a walk in the bi-infinite position space: at the
two window edges `nextTime` and `prevTime` wrap. `FoldRel` is the equivalence the forward wrap
generates and `FoldRelB` the one the backward wrap generates, and `foldRel_rep`/`foldRelB_rep`
say that neither can change the representative map. That is what lets a graph walk be read as a
ℤ-walk and back.

Agreement of the representatives is not itself preserved by `+1` at the boundaries — two times
may carry the same representatives by accident and diverge one step later — which is why the
relation carries the residue condition rather than the agreement it implies.
-/

/-- **The forward folding relation**: equal, or both at or past the combined window offset and
congruent modulo the combined forward period. -/
def FoldRel (W : SharingWindow) (a b : ℤ) : Prop :=
  a = b ∨ (W.NM ≤ a ∧ W.NM ≤ b ∧ (a - W.NM) % W.NF = (b - W.NM) % W.NF)

/-- **The backward folding relation**, the leftward mirror of `FoldRel`. -/
def FoldRelB (W : SharingWindow) (a b : ℤ) : Prop :=
  a = b ∨ (a < 0 ∧ b < 0 ∧ a % W.NB = b % W.NB)

theorem foldRel_refl (W : SharingWindow) (a : ℤ) : W.FoldRel a a := Or.inl rfl

theorem foldRelB_refl (W : SharingWindow) (a : ℤ) : W.FoldRelB a a := Or.inl rfl

theorem foldRel_symm {W : SharingWindow} {a b : ℤ} (h : W.FoldRel a b) : W.FoldRel b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldRelB_symm {W : SharingWindow} {a b : ℤ} (h : W.FoldRelB a b) : W.FoldRelB b a := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · exact Or.inr ⟨h2, h1, h3.symm⟩

theorem foldRel_trans {W : SharingWindow} {a b c : ℤ} (h1 : W.FoldRel a b)
    (h2 : W.FoldRel b c) : W.FoldRel a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨_, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

theorem foldRelB_trans {W : SharingWindow} {a b c : ℤ} (h1 : W.FoldRelB a b)
    (h2 : W.FoldRelB b c) : W.FoldRelB a c := by
  rcases h1 with rfl | ⟨p1, p2, p3⟩
  · exact h2
  · rcases h2 with rfl | ⟨_, q2, q3⟩
    · exact Or.inr ⟨p1, p2, p3⟩
    · exact Or.inr ⟨p1, q2, p3.trans q3⟩

/-- Folded times carry the same representative map. -/
theorem foldRel_rep {W : SharingWindow} {a b : ℤ} (h : W.FoldRel a b) : W.rep a = W.rep b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact W.rep_congr_NF h1 h2 h3

/-- Folded times carry the same representative map, backward. -/
theorem foldRelB_rep {W : SharingWindow} {a b : ℤ} (h : W.FoldRelB a b) :
    W.rep a = W.rep b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact W.rep_congr_NB h1 h2 h3

/-- The forward relation is closed under a common successor. -/
theorem foldRel_succ {W : SharingWindow} {a b : ℤ} (h : W.FoldRel a b) :
    W.FoldRel (a + 1) (b + 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · refine Or.inr ⟨by omega, by omega, ?_⟩
    have h4 := LabelledLasso.emod_shift (k := 1) h3
    rwa [show a - W.NM + 1 = a + 1 - W.NM by omega,
      show b - W.NM + 1 = b + 1 - W.NM by omega] at h4

/-- The backward relation is closed under a common predecessor. -/
theorem foldRelB_pred {W : SharingWindow} {a b : ℤ} (h : W.FoldRelB a b) :
    W.FoldRelB (a - 1) (b - 1) := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · exact Or.inl rfl
  · refine Or.inr ⟨by omega, by omega, ?_⟩
    have h4 := LabelledLasso.emod_shift (k := -1) h3
    rwa [show a + (-1 : ℤ) = a - 1 by omega, show b + (-1 : ℤ) = b - 1 by omega] at h4

/-- **The forward wrap is a fold**: the graph's successor time is folding-equivalent to the
genuine successor time. -/
theorem foldRel_nextTime (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.FoldRel (W.nextTime u) (u + 1) := by
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  by_cases hw : u + 1 < W.cohWindowHi
  · exact Or.inl (by simp only [nextTime, if_pos hw])
  · obtain ⟨hue, he⟩ := W.nextTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show W.NM + W.NF - W.NM = 0 + 1 * W.NF by omega,
      show W.NM + 2 * W.NF - W.NM = 0 + 2 * W.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- **The backward wrap is a fold**, the mirror of `foldRel_nextTime`. -/
theorem foldRelB_prevTime (W : SharingWindow) {u : ℤ} (hu : u ∈ W.winTimes) :
    W.FoldRelB (W.prevTime u) (u - 1) := by
  have hNB := W.NB_pos
  by_cases hw : W.cohWindowLo ≤ u - 1
  · exact Or.inl (by simp only [prevTime, if_pos hw])
  · obtain ⟨hue, he⟩ := W.prevTime_edge hu hw
    refine Or.inr ?_
    rw [he, hue]
    refine ⟨by omega, by omega, ?_⟩
    rw [show -W.NB - 1 = (-1 - W.NB) + 0 * W.NB by omega,
      show -2 * W.NB - 1 = (-1 - W.NB) + (-1) * W.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- **Every time at or after the window's left edge folds forward into the window.** -/
theorem exists_fold_fwd (W : SharingWindow) {t : ℤ} (ht : W.cohWindowLo ≤ t) :
    ∃ t' : ℤ, t' ∈ W.winTimes ∧ W.FoldRel t' t := by
  have hNB := W.NB_pos
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  have hHi : W.cohWindowHi = W.NM + 2 * W.NF := rfl
  have hLo : W.cohWindowLo = -2 * W.NB := rfl
  by_cases hin : t < W.cohWindowHi
  · exact ⟨t, (W.mem_winTimes t).mpr ⟨ht, hin⟩, W.foldRel_refl t⟩
  · have h0 : 0 ≤ (t - W.NM) % W.NF := Int.emod_nonneg _ (by omega)
    have h1 : (t - W.NM) % W.NF < W.NF := Int.emod_lt_of_pos _ hNF
    refine ⟨W.NM + (t - W.NM) % W.NF + W.NF, (W.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show W.NM + (t - W.NM) % W.NF + W.NF - W.NM = (t - W.NM) % W.NF + 1 * W.NF by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

/-- **Every time before the window's right edge folds backward into the window.** -/
theorem exists_fold_back (W : SharingWindow) {t : ℤ} (ht : t < W.cohWindowHi) :
    ∃ t' : ℤ, t' ∈ W.winTimes ∧ W.FoldRelB t' t := by
  have hNB := W.NB_pos
  have hNF := W.NF_pos
  have hNM := W.NM_nonneg
  have hHi : W.cohWindowHi = W.NM + 2 * W.NF := rfl
  have hLo : W.cohWindowLo = -2 * W.NB := rfl
  by_cases hin : W.cohWindowLo ≤ t
  · exact ⟨t, (W.mem_winTimes t).mpr ⟨hin, ht⟩, W.foldRelB_refl t⟩
  · have h0 : 0 ≤ t % W.NB := Int.emod_nonneg _ (by omega)
    have h1 : t % W.NB < W.NB := Int.emod_lt_of_pos _ hNB
    refine ⟨t % W.NB - 2 * W.NB, (W.mem_winTimes _).mpr (by omega), ?_⟩
    refine Or.inr ⟨by omega, by omega, ?_⟩
    rw [show t % W.NB - 2 * W.NB = t % W.NB + (-2) * W.NB by omega,
      Periodic.emod_add_mul, Int.emod_emod_of_dvd _ (dvd_refl _)]

/-! ## Reading a graph walk as a thread

A thread is a bi-infinite object and a graph walk is a one-sided infinite one, so the
translation pads: before the walk's start time the thread stands still on the start index,
which is legitimate because `share` is reflexive. Forward of the start time it follows the
walk, and the fold invariant `FwdWalk.foldRel` is what makes the walk's `share` obligations at
*graph* times discharge the thread's obligations at *real* times.
-/

/-- An infinite forward walk in the position graph. -/
structure FwdWalk (W : SharingWindow) where
  /-- The positions visited, in order. -/
  pos : ℕ → W.Pos
  /-- The walk starts at a vertex. -/
  start_mem : pos 0 ∈ W.verts
  /-- Each position is a graph successor of its predecessor. -/
  step : ∀ k, pos (k + 1) ∈ W.succF (pos k)

/-- An infinite backward walk in the position graph. -/
structure BwdWalk (W : SharingWindow) where
  /-- The positions visited, in order of increasing distance into the past. -/
  pos : ℕ → W.Pos
  /-- The walk starts at a vertex. -/
  start_mem : pos 0 ∈ W.verts
  /-- Each position is a graph predecessor of its predecessor in the enumeration. -/
  step : ∀ k, pos (k + 1) ∈ W.predF (pos k)

namespace FwdWalk

variable {W : SharingWindow}

theorem mem_verts (w : W.FwdWalk) : ∀ k, w.pos k ∈ W.verts
  | 0 => w.start_mem
  | k + 1 => W.succF_subset _ (w.step k)

theorem time_succ (w : W.FwdWalk) (k : ℕ) : (w.pos (k + 1)).2 = W.nextTime (w.pos k).2 :=
  ((W.mem_succF _ _).mp (w.step k)).2.1

theorem share_succ (w : W.FwdWalk) (k : ℕ) :
    W.share ((w.pos k).2 + 1) (w.pos k).1 (w.pos (k + 1)).1 :=
  ((W.mem_succF _ _).mp (w.step k)).2.2

/-- **The fold invariant.** The walk's `k`-th graph time folds the genuine time `u + k`. -/
theorem foldRel (w : W.FwdWalk) (k : ℕ) :
    W.FoldRel (w.pos k).2 ((w.pos 0).2 + (k : ℤ)) := by
  induction k with
  | zero => simp only [Nat.cast_zero, add_zero]; exact W.foldRel_refl _
  | succ k ih =>
      have hw : (w.pos k).2 ∈ W.winTimes := (W.mem_verts _).mp (w.mem_verts k)
      have hnext := W.foldRel_trans (W.foldRel_nextTime hw) (W.foldRel_succ ih)
      rw [w.time_succ k,
        show (w.pos 0).2 + ((k + 1 : ℕ) : ℤ) = (w.pos 0).2 + (k : ℤ) + 1 by omega]
      exact hnext

/-- The index function of the thread that follows the walk. -/
def walkIdx (w : W.FwdWalk) (t : ℤ) : Fin W.n :=
  if (w.pos 0).2 ≤ t then (w.pos (t - (w.pos 0).2).toNat).1 else (w.pos 0).1

theorem walkIdx_add (w : W.FwdWalk) (k : ℕ) :
    w.walkIdx ((w.pos 0).2 + (k : ℤ)) = (w.pos k).1 := by
  have h : ((w.pos 0).2 + (k : ℤ) - (w.pos 0).2).toNat = k := by omega
  simp only [walkIdx, if_pos (show (w.pos 0).2 ≤ (w.pos 0).2 + (k : ℤ) by omega), h]

theorem walkIdx_le (w : W.FwdWalk) {t : ℤ} (h : t ≤ (w.pos 0).2) :
    w.walkIdx t = (w.pos 0).1 := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · have h0 := w.walkIdx_add 0
    simpa using h0
  · simp only [walkIdx, if_neg (by omega : ¬ (w.pos 0).2 ≤ t)]

theorem walkIdx_step (w : W.FwdWalk) (t : ℤ) :
    W.share (t + 1) (w.walkIdx t) (w.walkIdx (t + 1)) := by
  by_cases h1 : (w.pos 0).2 ≤ t
  · have hkt : (w.pos 0).2 + (((t - (w.pos 0).2).toNat : ℕ) : ℤ) = t := by omega
    have e1 : w.walkIdx t = (w.pos (t - (w.pos 0).2).toNat).1 := by
      simp only [walkIdx, if_pos h1]
    have e2 : w.walkIdx (t + 1) = (w.pos ((t - (w.pos 0).2).toNat + 1)).1 := by
      have hx : (t + 1 - (w.pos 0).2).toNat = (t - (w.pos 0).2).toNat + 1 := by omega
      simp only [walkIdx, if_pos (show (w.pos 0).2 ≤ t + 1 by omega), hx]
    have hf : W.FoldRel ((w.pos (t - (w.pos 0).2).toNat).2 + 1) (t + 1) := by
      have hff := W.foldRel_succ (w.foldRel (t - (w.pos 0).2).toNat)
      rwa [hkt] at hff
    have hrep : W.rep ((w.pos (t - (w.pos 0).2).toNat).2 + 1) = W.rep (t + 1) :=
      W.foldRel_rep hf
    have hs := w.share_succ (t - (w.pos 0).2).toNat
    rw [W.share_def] at hs
    rw [e1, e2, W.share_def, ← hrep]
    exact hs
  · rw [w.walkIdx_le (by omega), w.walkIdx_le (by omega)]

/-- **The thread following a forward walk.** -/
def toThread (w : W.FwdWalk) : W.Thread where
  idx := w.walkIdx
  step := w.walkIdx_step

@[simp]
theorem toThread_idx (w : W.FwdWalk) (t : ℤ) : w.toThread.idx t = w.walkIdx t := rfl

end FwdWalk

namespace BwdWalk

variable {W : SharingWindow}

theorem mem_verts (w : W.BwdWalk) : ∀ k, w.pos k ∈ W.verts
  | 0 => w.start_mem
  | k + 1 => W.predF_subset _ (w.step k)

theorem time_succ (w : W.BwdWalk) (k : ℕ) : (w.pos (k + 1)).2 = W.prevTime (w.pos k).2 :=
  ((W.mem_predF _ _).mp (w.step k)).2.1

theorem share_succ (w : W.BwdWalk) (k : ℕ) :
    W.share (w.pos k).2 (w.pos k).1 (w.pos (k + 1)).1 :=
  ((W.mem_predF _ _).mp (w.step k)).2.2

/-- **The fold invariant**, the backward mirror. -/
theorem foldRelB (w : W.BwdWalk) (k : ℕ) :
    W.FoldRelB (w.pos k).2 ((w.pos 0).2 - (k : ℤ)) := by
  induction k with
  | zero => simp only [Nat.cast_zero, sub_zero]; exact W.foldRelB_refl _
  | succ k ih =>
      have hw : (w.pos k).2 ∈ W.winTimes := (W.mem_verts _).mp (w.mem_verts k)
      have hnext := W.foldRelB_trans (W.foldRelB_prevTime hw) (W.foldRelB_pred ih)
      rw [w.time_succ k,
        show (w.pos 0).2 - ((k + 1 : ℕ) : ℤ) = (w.pos 0).2 - (k : ℤ) - 1 by omega]
      exact hnext

/-- The index function of the thread that follows the backward walk. -/
def walkIdx (w : W.BwdWalk) (t : ℤ) : Fin W.n :=
  if t ≤ (w.pos 0).2 then (w.pos ((w.pos 0).2 - t).toNat).1 else (w.pos 0).1

theorem walkIdx_sub (w : W.BwdWalk) (k : ℕ) :
    w.walkIdx ((w.pos 0).2 - (k : ℤ)) = (w.pos k).1 := by
  have h : ((w.pos 0).2 - ((w.pos 0).2 - (k : ℤ))).toNat = k := by omega
  simp only [walkIdx, if_pos (show (w.pos 0).2 - (k : ℤ) ≤ (w.pos 0).2 by omega), h]

theorem walkIdx_ge (w : W.BwdWalk) {t : ℤ} (h : (w.pos 0).2 ≤ t) :
    w.walkIdx t = (w.pos 0).1 := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · have h0 := w.walkIdx_sub 0
    simpa using h0
  · simp only [walkIdx, if_neg (by omega : ¬ t ≤ (w.pos 0).2)]

theorem walkIdx_step (w : W.BwdWalk) (t : ℤ) :
    W.share (t + 1) (w.walkIdx t) (w.walkIdx (t + 1)) := by
  by_cases h1 : t + 1 ≤ (w.pos 0).2
  · have hkt : (w.pos 0).2 - (((w.pos 0).2 - t - 1).toNat : ℤ) = t + 1 := by omega
    have e1 : w.walkIdx t = (w.pos (((w.pos 0).2 - t - 1).toNat + 1)).1 := by
      have hx : ((w.pos 0).2 - t).toNat = ((w.pos 0).2 - t - 1).toNat + 1 := by omega
      simp only [walkIdx, if_pos (show t ≤ (w.pos 0).2 by omega), hx]
    have e2 : w.walkIdx (t + 1) = (w.pos ((w.pos 0).2 - t - 1).toNat).1 := by
      have hx : ((w.pos 0).2 - (t + 1)).toNat = ((w.pos 0).2 - t - 1).toNat := by omega
      simp only [walkIdx, if_pos h1, hx]
    have hf : W.FoldRelB (w.pos ((w.pos 0).2 - t - 1).toNat).2 (t + 1) := by
      have hff := w.foldRelB ((w.pos 0).2 - t - 1).toNat
      rwa [hkt] at hff
    have hrep : W.rep (w.pos ((w.pos 0).2 - t - 1).toNat).2 = W.rep (t + 1) :=
      W.foldRelB_rep hf
    have hs := w.share_succ ((w.pos 0).2 - t - 1).toNat
    rw [W.share_def] at hs
    rw [e1, e2, W.share_def, ← hrep]
    exact hs.symm
  · rw [w.walkIdx_ge (by omega), w.walkIdx_ge (by omega)]

/-- **The thread following a backward walk.** -/
def toThread (w : W.BwdWalk) : W.Thread where
  idx := w.walkIdx
  step := w.walkIdx_step

@[simp]
theorem toThread_idx (w : W.BwdWalk) (t : ℤ) : w.toThread.idx t = w.walkIdx t := rfl

end BwdWalk

end SharingWindow

end FormalSystem.Metalogic.Decidability
