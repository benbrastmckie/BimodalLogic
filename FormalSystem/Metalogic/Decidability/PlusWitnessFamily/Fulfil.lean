/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Decide
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

/-!
# The Position Graph and the `A[g U e]` Fixpoint at L⁺

(C2') at L⁺ is `PlusSharingWitnessFamily.PlusThreadFulfilling`: every **thread** through a
position discharges the eventualities labelled there. As on the `Formula` side, the quantifier
ranges over infinitely many walks once histories recombine, so the condition is made decidable by
a finite graph and a least fixpoint over it. This module supplies that computational core at
`PlusFormula`; the semantic reduction and the decision instance are the next module's subject,
and nothing here claims them.

## Almost none of this is new

Two layers are **inherited verbatim** rather than re-indexed, and the size of what remains is
the measure of how much the re-indexing actually costs:

* **`AUFix`** — the operator, its iteration, the stabilization bound, `lfp`, `lfp_fixed`,
  `lfp_least`, `mem_lfp_iff` and `lfp_induction` — is stated at an arbitrary vertex type with an
  arbitrary `Finset`-valued successor function and two arbitrary Boolean predicates. Nothing in
  it mentions a formula, so it is imported from `Sharing/Fulfil.lean` and used as-is.
* **The position graph** — the window's times, the vertices, `nextTime`/`prevTime` and their
  wraps, `succF`/`predF`, the two folding relations, and the walk layer `FwdWalk`/`BwdWalk`
  together with their `toThread` — lives on `SharingWindow` (`Sharing/Window.lean`), which is a
  function of the family's `window` projection alone. It is inherited, not transcribed.

What is genuinely re-indexed here is exactly the part that reads a label: that the two wraps and
the two folds preserve the *labels* (`L_nextTime`, `L_prevTime`, `foldRel_L`, `foldRelB_L`), and
the two fixpoints themselves, which are `AUFix.lfp` instantiated at a label test.

## Why the window is the right object to inherit from

The combined periods `(NB, NF, NM)` are not functions of `SharingSkeleton`: `perBack` is
`|repBack| * ∏ᵢ |lassoᵢ.back|`, a join of the skeleton's representative-segment lengths with the
lassos' label-segment lengths. `SharingWindow` carries them as data instead, which is what lets
the graph factor even though it does not factor through the bare skeleton.

## Main Definitions

- `PlusSharingWitnessFamily.Pos` / `winTimes` / `verts` — the inherited position graph
- `PlusSharingWitnessFamily.atPos` — the label test at a position
- `PlusSharingWitnessFamily.untlFix` / `snceFix` — the two fixpoints

## Main Results

- `PlusSharingWitnessFamily.L_nextTime` / `L_prevTime` — the wraps preserve the labels
- `PlusSharingWitnessFamily.foldRel_L` / `foldRelB_L` — the folds preserve the labels
- `PlusSharingWitnessFamily.mem_untlFix_iff` / `mem_snceFix_iff` — the fixpoint equations
- `PlusSharingWitnessFamily.untlFix_induction` / `snceFix_induction` — induction along them
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-! ## The position graph, inherited from the window -/

/-- A position of the family: a lasso index and a time. The window's own position type, whose
index count is the family's lasso count definitionally. -/
abbrev Pos (S : PlusSharingWitnessFamily Γ Del) : Type := S.window.Pos

/-- The times of the combined window. -/
abbrev winTimes (S : PlusSharingWitnessFamily Γ Del) : Finset ℤ := S.window.winTimes

/-- The vertices of the position graph: every lasso index at every window time. -/
abbrev verts (S : PlusSharingWitnessFamily Γ Del) : Finset S.Pos := S.window.verts

/-- The successor time inside the window. -/
abbrev nextTime (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) : ℤ := S.window.nextTime u

/-- The predecessor time inside the window. -/
abbrev prevTime (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) : ℤ := S.window.prevTime u

/-- The successors of a position. -/
abbrev succF (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) : Finset S.Pos := S.window.succF v

/-- The predecessors of a position. -/
abbrev predF (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) : Finset S.Pos := S.window.predF v

theorem mem_winTimes (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) :
    u ∈ S.winTimes ↔ S.cohWindowLo ≤ u ∧ u < S.cohWindowHi := S.window.mem_winTimes u

theorem mem_verts (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) :
    v ∈ S.verts ↔ v.2 ∈ S.winTimes := S.window.mem_verts v

/-- **The forward folding relation** on times. -/
abbrev FoldRel (S : PlusSharingWitnessFamily Γ Del) (a b : ℤ) : Prop := S.window.FoldRel a b

/-- **The backward folding relation** on times. -/
abbrev FoldRelB (S : PlusSharingWitnessFamily Γ Del) (a b : ℤ) : Prop := S.window.FoldRelB a b

/-- An infinite forward walk in the position graph. -/
abbrev FwdWalk (S : PlusSharingWitnessFamily Γ Del) : Type := S.window.FwdWalk

/-- An infinite backward walk in the position graph. -/
abbrev BwdWalk (S : PlusSharingWitnessFamily Γ Del) : Type := S.window.BwdWalk

theorem mem_succF (S : PlusSharingWitnessFamily Γ Del) (v w : S.Pos) :
    w ∈ S.succF v ↔ w ∈ S.verts ∧ w.2 = S.nextTime v.2 ∧
      (S.transRaw v.2 v.1 w.1 = true ∧ S.share (v.2 + 1) v.1 w.1) :=
  S.window.mem_succF v w

theorem mem_predF (S : PlusSharingWitnessFamily Γ Del) (v w : S.Pos) :
    w ∈ S.predF v ↔ w ∈ S.verts ∧ w.2 = S.prevTime v.2 ∧
      (S.transRaw (S.prevTime v.2) w.1 v.1 = true ∧ S.share v.2 v.1 w.1) :=
  S.window.mem_predF v w

theorem succF_subset (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) : S.succF v ⊆ S.verts :=
  S.window.succF_subset v

theorem predF_subset (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) : S.predF v ⊆ S.verts :=
  S.window.predF_subset v

theorem nextTime_mem (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.nextTime u ∈ S.winTimes := S.window.nextTime_mem hu

theorem prevTime_mem (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.prevTime u ∈ S.winTimes := S.window.prevTime_mem hu

theorem foldRel_refl (S : PlusSharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRel a a :=
  S.window.foldRel_refl a

theorem foldRelB_refl (S : PlusSharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRelB a a :=
  S.window.foldRelB_refl a

theorem foldRel_trans {S : PlusSharingWitnessFamily Γ Del} {a b c : ℤ} (h1 : S.FoldRel a b)
    (h2 : S.FoldRel b c) : S.FoldRel a c := SharingWindow.foldRel_trans h1 h2

theorem foldRelB_trans {S : PlusSharingWitnessFamily Γ Del} {a b c : ℤ} (h1 : S.FoldRelB a b)
    (h2 : S.FoldRelB b c) : S.FoldRelB a c := SharingWindow.foldRelB_trans h1 h2

theorem foldRel_succ {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.FoldRel (a + 1) (b + 1) := SharingWindow.foldRel_succ h

theorem foldRelB_pred {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.FoldRelB (a - 1) (b - 1) := SharingWindow.foldRelB_pred h

theorem foldRel_rep {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.rep a = S.rep b := SharingWindow.foldRel_rep h

theorem foldRelB_rep {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.rep a = S.rep b := SharingWindow.foldRelB_rep h

/-- Folded times carry the same succession matrix. -/
theorem foldRel_transRaw {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b) :
    S.transRaw a = S.transRaw b := SharingWindow.foldRel_transRaw h

/-- Folded times carry the same succession matrix, backward. -/
theorem foldRelB_transRaw {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b) :
    S.transRaw a = S.transRaw b := SharingWindow.foldRelB_transRaw h

theorem foldRel_nextTime (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.FoldRel (S.nextTime u) (u + 1) := S.window.foldRel_nextTime hu

theorem foldRelB_prevTime (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes) :
    S.FoldRelB (S.prevTime u) (u - 1) := S.window.foldRelB_prevTime hu

/-- **Every time at or after the window's left edge folds forward into the window.** -/
theorem exists_fold_fwd (S : PlusSharingWitnessFamily Γ Del) {t : ℤ} (ht : S.cohWindowLo ≤ t) :
    ∃ t' : ℤ, t' ∈ S.winTimes ∧ S.FoldRel t' t := S.window.exists_fold_fwd ht

/-- **Every time before the window's right edge folds backward into the window.** -/
theorem exists_fold_back (S : PlusSharingWitnessFamily Γ Del) {t : ℤ} (ht : t < S.cohWindowHi) :
    ∃ t' : ℤ, t' ∈ S.winTimes ∧ S.FoldRelB t' t := S.window.exists_fold_back ht

/-- The window's left edge is a vertex time. -/
theorem cohWindow_lo_mem (S : PlusSharingWitnessFamily Γ Del) : S.cohWindowLo ∈ S.winTimes := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  rw [S.mem_winTimes]
  omega

/-- The position one short of the window's right edge is a vertex time. -/
theorem cohWindow_hi_pred_mem (S : PlusSharingWitnessFamily Γ Del) :
    S.cohWindowHi - 1 ∈ S.winTimes := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  have hLo : S.cohWindowLo = -2 * S.NB := rfl
  have hHi : S.cohWindowHi = S.NM + 2 * S.NF := rfl
  rw [S.mem_winTimes]
  omega

/-! ## The wraps and the folds preserve the labels

The representative half of each statement below is already discharged on `SharingWindow`
(`rep_nextTime`, `rep_prevTime`, `foldRel_rep`, `foldRelB_rep`). What the window cannot know is
that the family's *labels* are equally unmoved, because it carries no labels. That half is
re-indexed here, against the same `data_congr_fwd`/`data_congr_back` the window's own half runs
against.
-/

/-- The forward wrap does not change any lasso's label. -/
theorem L_nextTime (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (i : Fin S.lassos.length) : S.L i (S.nextTime u) = S.L i (u + 1) := by
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  by_cases hw : u + 1 < S.window.cohWindowHi
  · rw [show S.nextTime u = u + 1 from if_pos hw]
  · obtain ⟨hue, he⟩ := S.window.nextTime_edge hu hw
    rw [show S.nextTime u = S.NM + S.NF from he, show u + 1 = S.NM + 2 * S.NF from hue]
    refine (S.data_congr_fwd (by omega) (by omega) ?_).2 i
    rw [show S.NM + S.NF - S.NM = 0 + 1 * S.NF by omega,
      show S.NM + 2 * S.NF - S.NM = 0 + 2 * S.NF by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- The backward wrap does not change any lasso's label. -/
theorem L_prevTime (S : PlusSharingWitnessFamily Γ Del) {u : ℤ} (hu : u ∈ S.winTimes)
    (i : Fin S.lassos.length) : S.L i (S.prevTime u) = S.L i (u - 1) := by
  have hNB := S.NB_pos
  by_cases hw : S.window.cohWindowLo ≤ u - 1
  · rw [show S.prevTime u = u - 1 from if_pos hw]
  · obtain ⟨hue, he⟩ := S.window.prevTime_edge hu hw
    rw [show S.prevTime u = -S.NB - 1 from he, show u - 1 = -2 * S.NB - 1 from hue]
    refine (S.data_congr_back (by omega) (by omega) ?_).2 i
    rw [show -S.NB - 1 = (-1 - S.NB) + 0 * S.NB by omega,
      show -2 * S.NB - 1 = (-1 - S.NB) + (-1) * S.NB by omega,
      Periodic.emod_add_mul, Periodic.emod_add_mul]

/-- Forward-folded times carry the same labels. -/
theorem foldRel_L {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRel a b)
    (i : Fin S.lassos.length) : S.L i a = S.L i b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_fwd h1 h2 h3).2 i

/-- Backward-folded times carry the same labels. -/
theorem foldRelB_L {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.FoldRelB a b)
    (i : Fin S.lassos.length) : S.L i a = S.L i b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_back h1 h2 h3).2 i

/-! ## The two fixpoints

`AUFix` is imported from the `Formula`-side module and instantiated here; it is stated at an
arbitrary vertex type and an arbitrary successor function, so neither the operator nor any of
its theory is developed a second time. The `snce` direction is `predF` for `succF` and nothing
else changed.
-/

/-- Whether an L⁺ formula is labelled at a position. -/
def atPos (S : PlusSharingWitnessFamily Γ Del) (χ : PlusFormula) (v : S.Pos) : Bool :=
  decide (χ ∈ S.L v.1 v.2)

theorem atPos_iff (S : PlusSharingWitnessFamily Γ Del) (χ : PlusFormula) (v : S.Pos) :
    S.atPos χ v = true ↔ χ ∈ S.L v.1 v.2 := by
  simp [atPos]

/--
**`A[g U e]` over the position graph**: the least set of positions from which every forward walk
delivers `e`, with `g` labelled at every strictly intermediate position.
-/
def untlFix (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) : Finset S.Pos :=
  AUFix.lfp S.verts S.succF (S.atPos e) (S.atPos g)

/--
**The `snce` dual**, on the reversed graph.

`AUFix.lfp` with `predF` for `succF`, and nothing else: the dual is an instantiation of the
same operator, not a second development.
-/
def snceFix (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) : Finset S.Pos :=
  AUFix.lfp S.verts S.predF (S.atPos e) (S.atPos g)

theorem untlFix_subset (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) :
    S.untlFix g e ⊆ S.verts := AUFix.lfp_subset _ _ _ _

theorem snceFix_subset (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) :
    S.snceFix g e ⊆ S.verts := AUFix.lfp_subset _ _ _ _

theorem mem_untlFix_iff (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) (v : S.Pos) :
    v ∈ S.untlFix g e ↔
      v ∈ S.verts ∧ ∀ w ∈ S.succF v,
        e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ w ∈ S.untlFix g e) := by
  rw [untlFix, AUFix.mem_lfp_iff]
  simp only [S.atPos_iff]

theorem mem_snceFix_iff (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) (v : S.Pos) :
    v ∈ S.snceFix g e ↔
      v ∈ S.verts ∧ ∀ w ∈ S.predF v,
        e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ w ∈ S.snceFix g e) := by
  rw [snceFix, AUFix.mem_lfp_iff]
  simp only [S.atPos_iff]

/-- Induction along the forward fixpoint's iteration. -/
theorem untlFix_induction (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula)
    {P : S.Pos → Prop}
    (hstep : ∀ v ∈ S.verts,
      (∀ w ∈ S.succF v, e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ P w)) → P v) :
    ∀ v ∈ S.untlFix g e, P v := by
  refine AUFix.lfp_induction S.verts S.succF (S.atPos e) (S.atPos g) (fun v hv h => ?_)
  refine hstep v hv (fun w hw => ?_)
  rcases h w hw with he | ⟨hg, hp⟩
  · exact Or.inl ((S.atPos_iff e w).mp he)
  · exact Or.inr ⟨(S.atPos_iff g w).mp hg, hp⟩

/-- Induction along the backward fixpoint's iteration. -/
theorem snceFix_induction (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula)
    {P : S.Pos → Prop}
    (hstep : ∀ v ∈ S.verts,
      (∀ w ∈ S.predF v, e ∈ S.L w.1 w.2 ∨ (g ∈ S.L w.1 w.2 ∧ P w)) → P v) :
    ∀ v ∈ S.snceFix g e, P v := by
  refine AUFix.lfp_induction S.verts S.predF (S.atPos e) (S.atPos g) (fun v hv h => ?_)
  refine hstep v hv (fun w hw => ?_)
  rcases h w hw with he | ⟨hg, hp⟩
  · exact Or.inl ((S.atPos_iff e w).mp he)
  · exact Or.inr ⟨(S.atPos_iff g w).mp hg, hp⟩

/-! ## (C1') propagation along a thread

The far-left (and far-right) case of the window reduction below turns on a fact with no
counterpart in the deterministic device: an unfulfilled eventuality is **carried along every
thread together with its guard**. That is a consequence of (C1') `PlusLocalCoherentShare` alone,
and it is what lets a position outside the combined window discharge its obligation by walking
into the window rather than by folding into it.

Recorded plainly, because it is the reason the window equivalence below is stated relative to
`PlusLocalCoherentShare` rather than as a standalone `Decidable (PlusThreadFulfilling S)`
instance.
-/

/-- **One step of the `untl` unfolding along a thread.** -/
theorem plusUntl_thread_step {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusLocalCoherentShare)
    (θ : S.Thread) {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del))
    {t : ℤ} (ht : PlusFormula.untl g e ∈ S.L (θ.idx t) t) :
    e ∈ S.L (θ.idx (t + 1)) (t + 1) ∨
      (g ∈ S.L (θ.idx (t + 1)) (t + 1) ∧
        PlusFormula.untl g e ∈ S.L (θ.idx (t + 1)) (t + 1)) :=
  ((h (θ.idx t) t).2.2.2.1 (θ.idx (t + 1)) (Thread.step θ t) g e hc).mp ht

/--
**A thread's step read *into* `t`.** The succession fact the `snce` clause of (C1') now consumes:
the index at `t - 1` succeeds to the index at `t`. The Plus-side twin of
`SharingWitnessFamily.thread_trans_pred`.

Note the argument order: the predecessor is the *source* of the succession, so the index at
`t - 1` comes first, where `plusThread_share_pred` — a symmetric relation — puts the index at `t`
first.
-/
theorem plusThread_trans_pred {S : PlusSharingWitnessFamily Γ Del} (θ : S.Thread) (t : ℤ) :
    S.trans (t - 1) (θ.idx (t - 1)) (θ.idx t) := by
  have hstep := Thread.step θ (t - 1)
  rwa [show t - 1 + 1 = t by omega] at hstep

/-- A thread's index at `t` shares the state at `t` with its index at `t - 1`. -/
theorem plusThread_share_pred {S : PlusSharingWitnessFamily Γ Del} (θ : S.Thread) (t : ℤ) :
    S.share t (θ.idx t) (θ.idx (t - 1)) := by
  have hstep := thread_share_succ θ (t - 1)
  rw [show t - 1 + 1 = t by omega] at hstep
  exact S.share_symm hstep

/-- **One step of the `snce` unfolding along a thread.** -/
theorem plusSnce_thread_step {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusLocalCoherentShare)
    (θ : S.Thread) {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del))
    {t : ℤ} (ht : PlusFormula.snce g e ∈ S.L (θ.idx t) t) :
    e ∈ S.L (θ.idx (t - 1)) (t - 1) ∨
      (g ∈ S.L (θ.idx (t - 1)) (t - 1) ∧
        PlusFormula.snce g e ∈ S.L (θ.idx (t - 1)) (t - 1)) :=
  ((h (θ.idx t) t).2.2.2.2 (θ.idx (t - 1)) (plusThread_trans_pred θ t) g e hc).mp ht

/-- **(C1') propagation, forward, by step count.** -/
theorem plusUntl_propagate {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusLocalCoherentShare)
    (θ : S.Thread) {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del))
    {t : ℤ} (ht : PlusFormula.untl g e ∈ S.L (θ.idx t) t) :
    ∀ n : ℕ, (∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → e ∉ S.L (θ.idx r) r) →
      (∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → g ∈ S.L (θ.idx r) r) ∧
        PlusFormula.untl g e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) := by
  intro n
  induction n with
  | zero =>
      intro hno
      simp only [Nat.cast_zero, add_zero] at hno ⊢
      have hne : e ∉ S.L (θ.idx (t + 1)) (t + 1) := hno (t + 1) (by omega) (le_refl _)
      rcases plusUntl_thread_step h θ hc ht with he | ⟨hg, hu⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, hu⟩
        have hre : r = t + 1 := by omega
        subst hre
        exact hg
  | succ n ih =>
      intro hno
      have hno' : ∀ r : ℤ, t < r → r ≤ t + 1 + (n : ℤ) → e ∉ S.L (θ.idx r) r := by
        intro r hr1 hr2
        exact hno r hr1 (by push_cast; omega)
      obtain ⟨hg, hu⟩ := ih hno'
      have hne : e ∉ S.L (θ.idx (t + 1 + (n : ℤ) + 1)) (t + 1 + (n : ℤ) + 1) := by
        refine hno _ (by omega) ?_
        push_cast
        omega
      have hcast : t + 1 + ((n + 1 : ℕ) : ℤ) = t + 1 + (n : ℤ) + 1 := by push_cast; omega
      rcases plusUntl_thread_step h θ hc hu with he | ⟨hg2, hu2⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, ?_⟩
        · rcases lt_or_ge (t + 1 + (n : ℤ)) r with hgt | hle
          · have hre : r = t + 1 + (n : ℤ) + 1 := by rw [hcast] at hr2; omega
            subst hre
            exact hg2
          · exact hg r hr1 hle
        · rw [hcast]
          exact hu2

/-- **(C1') propagation, forward, at an arbitrary later time.** -/
theorem plusUntl_propagate_le {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusLocalCoherentShare)
    (θ : S.Thread) {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del))
    {t s : ℤ} (hts : t < s) (ht : PlusFormula.untl g e ∈ S.L (θ.idx t) t)
    (hno : ∀ r : ℤ, t < r → r ≤ s → e ∉ S.L (θ.idx r) r) :
    (∀ r : ℤ, t < r → r ≤ s → g ∈ S.L (θ.idx r) r) ∧
      PlusFormula.untl g e ∈ S.L (θ.idx s) s := by
  have hs : t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s := by omega
  have hmain := plusUntl_propagate h θ hc ht (s - t - 1).toNat (by rw [hs]; exact hno)
  rw [hs] at hmain
  exact hmain

/-- **(C1') propagation, backward, by step count.** -/
theorem plusSnce_propagate {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusLocalCoherentShare)
    (θ : S.Thread) {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del))
    {t : ℤ} (ht : PlusFormula.snce g e ∈ S.L (θ.idx t) t) :
    ∀ n : ℕ, (∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → e ∉ S.L (θ.idx r) r) →
      (∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → g ∈ S.L (θ.idx r) r) ∧
        PlusFormula.snce g e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) := by
  intro n
  induction n with
  | zero =>
      intro hno
      simp only [Nat.cast_zero, sub_zero] at hno ⊢
      have hne : e ∉ S.L (θ.idx (t - 1)) (t - 1) := hno (t - 1) (le_refl _) (by omega)
      rcases plusSnce_thread_step h θ hc ht with he | ⟨hg, hu⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, hu⟩
        have hre : r = t - 1 := by omega
        subst hre
        exact hg
  | succ n ih =>
      intro hno
      have hno' : ∀ r : ℤ, t - 1 - (n : ℤ) ≤ r → r < t → e ∉ S.L (θ.idx r) r := by
        intro r hr1 hr2
        exact hno r (by push_cast; omega) hr2
      obtain ⟨hg, hu⟩ := ih hno'
      have hne : e ∉ S.L (θ.idx (t - 1 - (n : ℤ) - 1)) (t - 1 - (n : ℤ) - 1) := by
        refine hno _ ?_ (by omega)
        push_cast
        omega
      have hcast : t - 1 - ((n + 1 : ℕ) : ℤ) = t - 1 - (n : ℤ) - 1 := by push_cast; omega
      rcases plusSnce_thread_step h θ hc hu with he | ⟨hg2, hu2⟩
      · exact absurd he hne
      · refine ⟨fun r hr1 hr2 => ?_, ?_⟩
        · rcases lt_or_ge r (t - 1 - (n : ℤ)) with hgt | hle
          · have hre : r = t - 1 - (n : ℤ) - 1 := by rw [hcast] at hr1; omega
            subst hre
            exact hg2
          · exact hg r hle hr2
        · rw [hcast]
          exact hu2

/-- **(C1') propagation, backward, at an arbitrary earlier time.** -/
theorem plusSnce_propagate_ge {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) (θ : S.Thread) {g e : PlusFormula}
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) {t s : ℤ} (hts : s < t)
    (ht : PlusFormula.snce g e ∈ S.L (θ.idx t) t)
    (hno : ∀ r : ℤ, s ≤ r → r < t → e ∉ S.L (θ.idx r) r) :
    (∀ r : ℤ, s ≤ r → r < t → g ∈ S.L (θ.idx r) r) ∧
      PlusFormula.snce g e ∈ S.L (θ.idx s) s := by
  have hs : t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s := by omega
  have hmain := plusSnce_propagate h θ hc ht (t - s - 1).toNat (by rw [hs]; exact hno)
  rw [hs] at hmain
  exact hmain

/-- **From an event to a fulfilment.** Under (C1'), an `untl` obligation that meets its event at
*some* later time meets it at the *first* such time, and propagation supplies the guard over the
strictly intermediate positions. -/
theorem plusUntl_fulfil_of_exists {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) (θ : S.Thread) {g e : PlusFormula}
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) {t : ℤ}
    (ht : PlusFormula.untl g e ∈ S.L (θ.idx t) t)
    (hex : ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s) :
    ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
      ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r := by
  classical
  have hex' : ∃ n : ℕ, e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) := by
    obtain ⟨s, hs1, hs2⟩ := hex
    refine ⟨(s - t - 1).toNat, ?_⟩
    rwa [show t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s by omega]
  obtain ⟨n, hspec, hmin⟩ :
      ∃ n : ℕ, e ∈ S.L (θ.idx (t + 1 + (n : ℤ))) (t + 1 + (n : ℤ)) ∧
        ∀ m : ℕ, m < n → e ∉ S.L (θ.idx (t + 1 + (m : ℤ))) (t + 1 + (m : ℤ)) :=
    ⟨Nat.find hex', Nat.find_spec hex', fun m hm => Nat.find_min hex' hm⟩
  refine ⟨t + 1 + (n : ℤ), by omega, hspec, ?_⟩
  intro r hr1 hr2
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · exfalso
    rw [hn0] at hr2
    simp only [Nat.cast_zero, add_zero] at hr2
    omega
  · have hno : ∀ r' : ℤ, t < r' → r' ≤ t + (n : ℤ) → e ∉ S.L (θ.idx r') r' := by
      intro r' hr1' hr2'
      have hre : r' = t + 1 + (((r' - t - 1).toNat : ℕ) : ℤ) := by omega
      rw [hre]
      exact hmin _ (by omega)
    have hprop := plusUntl_propagate_le h θ hc (show t < t + (n : ℤ) by omega) ht hno
    exact hprop.1 r hr1 (by omega)

/-- **From an event to a fulfilment**, the backward mirror. -/
theorem plusSnce_fulfil_of_exists {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) (θ : S.Thread) {g e : PlusFormula}
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) {t : ℤ}
    (ht : PlusFormula.snce g e ∈ S.L (θ.idx t) t)
    (hex : ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s) :
    ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
      ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r := by
  classical
  have hex' : ∃ n : ℕ, e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) := by
    obtain ⟨s, hs1, hs2⟩ := hex
    refine ⟨(t - s - 1).toNat, ?_⟩
    rwa [show t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s by omega]
  obtain ⟨n, hspec, hmin⟩ :
      ∃ n : ℕ, e ∈ S.L (θ.idx (t - 1 - (n : ℤ))) (t - 1 - (n : ℤ)) ∧
        ∀ m : ℕ, m < n → e ∉ S.L (θ.idx (t - 1 - (m : ℤ))) (t - 1 - (m : ℤ)) :=
    ⟨Nat.find hex', Nat.find_spec hex', fun m hm => Nat.find_min hex' hm⟩
  refine ⟨t - 1 - (n : ℤ), by omega, hspec, ?_⟩
  intro r hr1 hr2
  rcases Nat.eq_zero_or_pos n with hn0 | hnpos
  · exfalso
    rw [hn0] at hr1
    simp only [Nat.cast_zero, sub_zero] at hr1
    omega
  · have hno : ∀ r' : ℤ, t - (n : ℤ) ≤ r' → r' < t → e ∉ S.L (θ.idx r') r' := by
      intro r' hr1' hr2'
      have hre : r' = t - 1 - (((t - r' - 1).toNat : ℕ) : ℤ) := by omega
      rw [hre]
      exact hmin _ (by omega)
    have hprop := plusSnce_propagate_ge h θ hc (show t - (n : ℤ) < t by omega) ht hno
    exact hprop.1 r (by omega) hr2

/-! ## Soundness: the fixpoint implies the semantic condition

Both directions are proved by the induction principles above, transported along the fold
relations. Nothing here needs `PlusLocalCoherentShare`: the fold carries a thread's real position
to a graph vertex step by step, and the fixpoint's own unfolding does the rest.
-/

/-- **Soundness of `untlFix`.** A vertex in the forward fixpoint discharges the eventuality
along every thread through every time it folds. -/
theorem thread_untl_of_mem_untlFix (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) :
    ∀ v ∈ S.untlFix g e, ∀ t : ℤ, S.FoldRel v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r := by
  refine S.untlFix_induction g e
    (P := fun v => ∀ t : ℤ, S.FoldRel v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, t < s ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, t < r → r < s → g ∈ S.L (θ.idx r) r)
    (fun v hv H t hft θ hθ => ?_)
  have hvw : v.2 ∈ S.winTimes := (S.mem_verts v).mp hv
  have hfs : S.FoldRel (S.nextTime v.2) (t + 1) :=
    foldRel_trans (S.foldRel_nextTime hvw) (foldRel_succ hft)
  have hwv : ((θ.idx (t + 1), S.nextTime v.2) : S.Pos) ∈ S.verts :=
    (S.mem_verts _).mpr (S.nextTime_mem hvw)
  have hws : ((θ.idx (t + 1), S.nextTime v.2) : S.Pos) ∈ S.succF v := by
    rw [S.mem_succF]
    refine ⟨hwv, rfl, ?_, ?_⟩
    · -- The succession half of the thread's step, transported along the fold.
      have ht := ((S.trans_def t (θ.idx t) (θ.idx (t + 1))).mp (Thread.step θ t)).1
      rw [← hθ, foldRel_transRaw hft]
      exact ht
    · have hrep : S.rep (v.2 + 1) = S.rep (t + 1) := foldRel_rep (foldRel_succ hft)
      have hs := thread_share_succ θ t
      rw [S.share_def] at hs
      rw [← hθ, S.share_def, hrep]
      exact hs
  have hLeq : ∀ χ : PlusFormula,
      χ ∈ S.L (θ.idx (t + 1)) (S.nextTime v.2) ↔ χ ∈ S.L (θ.idx (t + 1)) (t + 1) := by
    intro χ
    rw [foldRel_L hfs (θ.idx (t + 1))]
  rcases H _ hws with he | ⟨hg, hP⟩
  · refine ⟨t + 1, by omega, (hLeq e).mp he, ?_⟩
    intro r hr1 hr2
    exfalso
    omega
  · obtain ⟨s, hs1, hs2, hs3⟩ := hP (t + 1) hfs θ rfl
    refine ⟨s, by omega, hs2, ?_⟩
    intro r hr1 hr2
    rcases eq_or_lt_of_le (show t + 1 ≤ r by omega) with heq | hlt
    · rw [← heq]
      exact (hLeq g).mp hg
    · exact hs3 r hlt hr2

/-- **Soundness of `snceFix`**, the backward mirror. -/
theorem thread_snce_of_mem_snceFix (S : PlusSharingWitnessFamily Γ Del) (g e : PlusFormula) :
    ∀ v ∈ S.snceFix g e, ∀ t : ℤ, S.FoldRelB v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r := by
  refine S.snceFix_induction g e
    (P := fun v => ∀ t : ℤ, S.FoldRelB v.2 t → ∀ θ : S.Thread, θ.idx t = v.1 →
      ∃ s : ℤ, s < t ∧ e ∈ S.L (θ.idx s) s ∧
        ∀ r : ℤ, s < r → r < t → g ∈ S.L (θ.idx r) r)
    (fun v hv H t hft θ hθ => ?_)
  have hvw : v.2 ∈ S.winTimes := (S.mem_verts v).mp hv
  have hfs : S.FoldRelB (S.prevTime v.2) (t - 1) :=
    foldRelB_trans (S.foldRelB_prevTime hvw) (foldRelB_pred hft)
  have hwv : ((θ.idx (t - 1), S.prevTime v.2) : S.Pos) ∈ S.verts :=
    (S.mem_verts _).mpr (S.prevTime_mem hvw)
  have hws : ((θ.idx (t - 1), S.prevTime v.2) : S.Pos) ∈ S.predF v := by
    rw [S.mem_predF]
    refine ⟨hwv, rfl, ?_, ?_⟩
    · -- The succession half, read one step back and transported along the backward fold.
      have ht := ((S.trans_def (t - 1) (θ.idx (t - 1)) (θ.idx (t - 1 + 1))).mp
        (Thread.step θ (t - 1))).1
      rw [show t - 1 + 1 = t by omega, hθ] at ht
      rw [foldRelB_transRaw hfs]
      exact ht
    · have hrep : S.rep v.2 = S.rep t := foldRelB_rep hft
      have hs := plusThread_share_pred θ t
      rw [S.share_def] at hs
      rw [← hθ, S.share_def, hrep]
      exact hs
  have hLeq : ∀ χ : PlusFormula,
      χ ∈ S.L (θ.idx (t - 1)) (S.prevTime v.2) ↔ χ ∈ S.L (θ.idx (t - 1)) (t - 1) := by
    intro χ
    rw [foldRelB_L hfs (θ.idx (t - 1))]
  rcases H _ hws with he | ⟨hg, hP⟩
  · refine ⟨t - 1, by omega, (hLeq e).mp he, ?_⟩
    intro r hr1 hr2
    exfalso
    omega
  · obtain ⟨s, hs1, hs2, hs3⟩ := hP (t - 1) hfs θ rfl
    refine ⟨s, by omega, hs2, ?_⟩
    intro r hr1 hr2
    rcases eq_or_lt_of_le (show r ≤ t - 1 by omega) with heq | hlt
    · rw [heq]
      exact (hLeq g).mp hg
    · exact hs3 r hr1 hlt

/-! ## The window form of (C2'), and its decision procedure

`PlusThreadFulfilling` quantifies over all of `ℤ` and over all threads; the check below
quantifies over the finite vertex set and the finite closure and reads the two fixpoints. The two
are equivalent **relative to (C1')**.

The `stab` clause is trivially true, exactly as `atom`, `bot`, `imp` and `box` are: (C2') is a
condition on *eventualities*, and the stability modal is not one. What pins `stab` is (C5)
`StabFaithful`, a separate condition with its own decision procedure.
-/

/-- The fulfilment clause a single closure member imposes at a position. -/
def plusFulfilClauseAt (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) : PlusFormula → Prop
  | PlusFormula.atom _ => True
  | PlusFormula.bot => True
  | PlusFormula.imp _ _ => True
  | PlusFormula.box _ => True
  | PlusFormula.stab _ => True
  | PlusFormula.untl g e => PlusFormula.untl g e ∈ S.L v.1 v.2 → v ∈ S.untlFix g e
  | PlusFormula.snce g e => PlusFormula.snce g e ∈ S.L v.1 v.2 → v ∈ S.snceFix g e

/-- `plusFulfilClauseAt` is decidable at every L⁺ formula. -/
instance instDecidablePlusFulfilClauseAt (S : PlusSharingWitnessFamily Γ Del) (v : S.Pos) :
    DecidablePred (S.plusFulfilClauseAt v) := by
  intro ψ
  cases ψ <;> (dsimp only [plusFulfilClauseAt]; infer_instance)

/--
**The window form of (C2').** Every vertex of the position graph whose label carries an
eventuality lies in the corresponding fixpoint.

Finite in both quantifiers — the vertex set and the closure are `Finset`s — so it decides by a
bounded scan.
-/
def PlusFulfilWindow (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ v ∈ S.verts, ∀ ψ ∈ plusClosureOf (Γ ++ Del), S.plusFulfilClauseAt v ψ

instance decidablePlusFulfilWindow (S : PlusSharingWitnessFamily Γ Del) :
    Decidable S.PlusFulfilWindow := by
  dsimp only [PlusFulfilWindow]
  infer_instance

theorem untlFix_of_window {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusFulfilWindow)
    {v : S.Pos} (hv : v ∈ S.verts) {g e : PlusFormula}
    (hm : PlusFormula.untl g e ∈ S.L v.1 v.2) : v ∈ S.untlFix g e :=
  h v hv _ (S.subset_plusClosureOf v.1 v.2 hm) hm

theorem snceFix_of_window {S : PlusSharingWitnessFamily Γ Del} (h : S.PlusFulfilWindow)
    {v : S.Pos} (hv : v ∈ S.verts) {g e : PlusFormula}
    (hm : PlusFormula.snce g e ∈ S.L v.1 v.2) : v ∈ S.snceFix g e :=
  h v hv _ (S.subset_plusClosureOf v.1 v.2 hm) hm

/-! ### The window check implies (C2'), given (C1')

The fold handles every position at or after the window's left edge directly. A position strictly
left of it is **not** folded: the forward ray from far left winds around the backward cycle more
times than any window representative's does, and a *universal* path quantifier is not obviously
preserved by that. Instead the obligation is *walked* into the window by (C1') propagation,
which is exactly where `plusUntl_propagate_le` is consumed, and which is why this direction — and
only this direction — carries `PlusLocalCoherentShare` as a hypothesis.
-/

/-- **The window check implies (C2')**, given (C1'). -/
theorem plusThreadFulfilling_of_window {S : PlusSharingWitnessFamily Γ Del}
    (hlc : S.PlusLocalCoherentShare) (hw : S.PlusFulfilWindow) : S.PlusThreadFulfilling := by
  have hNB := S.NB_pos
  have hNF := S.NF_pos
  have hNM := S.NM_nonneg
  constructor
  · intro i u g e hm θ hθ
    have hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) := S.subset_plusClosureOf i u hm
    have hmθ : PlusFormula.untl g e ∈ S.L (θ.idx u) u := by rw [hθ]; exact hm
    have hev : ∃ s : ℤ, u < s ∧ e ∈ S.L (θ.idx s) s := by
      by_cases hlo : S.cohWindowLo ≤ u
      · obtain ⟨u', hu'w, hfold⟩ := S.exists_fold_fwd hlo
        have hmem : PlusFormula.untl g e ∈ S.L (θ.idx u) u' := by
          rw [foldRel_L hfold (θ.idx u)]
          exact hmθ
        have hvv : ((θ.idx u, u') : S.Pos) ∈ S.verts := (S.mem_verts _).mpr hu'w
        obtain ⟨s, hs1, hs2, _⟩ := S.thread_untl_of_mem_untlFix g e _
          (untlFix_of_window hw hvv hmem) u hfold θ rfl
        exact ⟨s, hs1, hs2⟩
      · push Not at hlo
        by_cases hno : ∀ r : ℤ, u < r → r ≤ S.cohWindowLo → e ∉ S.L (θ.idx r) r
        · have hprop := plusUntl_propagate_le hlc θ hc (by omega) hmθ hno
          have hvv : ((θ.idx S.cohWindowLo, S.cohWindowLo) : S.Pos) ∈ S.verts :=
            (S.mem_verts _).mpr S.cohWindow_lo_mem
          obtain ⟨s, hs1, hs2, _⟩ := S.thread_untl_of_mem_untlFix g e _
            (untlFix_of_window hw hvv hprop.2) S.cohWindowLo
            (S.foldRel_refl S.cohWindowLo) θ rfl
          exact ⟨s, by omega, hs2⟩
        · push Not at hno
          obtain ⟨r, hr1, hr2, hr3⟩ := hno
          exact ⟨r, hr1, hr3⟩
    exact plusUntl_fulfil_of_exists hlc θ hc hmθ hev
  · intro i u g e hm θ hθ
    have hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) := S.subset_plusClosureOf i u hm
    have hmθ : PlusFormula.snce g e ∈ S.L (θ.idx u) u := by rw [hθ]; exact hm
    have hev : ∃ s : ℤ, s < u ∧ e ∈ S.L (θ.idx s) s := by
      by_cases hhi : u < S.cohWindowHi
      · obtain ⟨u', hu'w, hfold⟩ := S.exists_fold_back hhi
        have hmem : PlusFormula.snce g e ∈ S.L (θ.idx u) u' := by
          rw [foldRelB_L hfold (θ.idx u)]
          exact hmθ
        have hvv : ((θ.idx u, u') : S.Pos) ∈ S.verts := (S.mem_verts _).mpr hu'w
        obtain ⟨s, hs1, hs2, _⟩ := S.thread_snce_of_mem_snceFix g e _
          (snceFix_of_window hw hvv hmem) u hfold θ rfl
        exact ⟨s, hs1, hs2⟩
      · push Not at hhi
        by_cases hno : ∀ r : ℤ, S.cohWindowHi - 1 ≤ r → r < u → e ∉ S.L (θ.idx r) r
        · have hprop := plusSnce_propagate_ge hlc θ hc (by omega) hmθ hno
          have hvv : ((θ.idx (S.cohWindowHi - 1), S.cohWindowHi - 1) : S.Pos) ∈ S.verts :=
            (S.mem_verts _).mpr S.cohWindow_hi_pred_mem
          obtain ⟨s, hs1, hs2, _⟩ := S.thread_snce_of_mem_snceFix g e _
            (snceFix_of_window hw hvv hprop.2) (S.cohWindowHi - 1)
            (S.foldRelB_refl (S.cohWindowHi - 1)) θ rfl
          exact ⟨s, by omega, hs2⟩
        · push Not at hno
          obtain ⟨r, hr1, hr2, hr3⟩ := hno
          exact ⟨r, hr2, hr3⟩
    exact plusSnce_fulfil_of_exists hlc θ hc hmθ hev

/-! ### (C2') implies the window check

Unconditional, and the direction that needs a counterexample thread. A vertex outside the
fixpoint admits an escape edge; iterating the escape gives an infinite walk which
`FwdWalk.toThread` turns into a genuine bi-infinite thread. That the pumping is legitimate here
— no position is skipped, and no two distinct times are identified — is because the *time*
coordinate is carried in the vertex.
-/

/-- **(C2') implies the window check.** -/
theorem window_of_plusThreadFulfilling {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusThreadFulfilling) : S.PlusFulfilWindow := by
  classical
  intro v hv ψ _
  cases ψ with
  | atom _ => exact trivial
  | bot => exact trivial
  | imp _ _ => exact trivial
  | box _ => exact trivial
  | stab _ => exact trivial
  | untl g e =>
      dsimp only [plusFulfilClauseAt]
      intro hm
      by_contra hcon
      have hesc : ∀ z : S.Pos, ∃ y : S.Pos,
          (z ∈ S.verts → y ∈ S.succF z) ∧
          (z ∈ S.verts → z ∉ S.untlFix g e →
            (e ∉ S.L y.1 y.2 ∧ (g ∈ S.L y.1 y.2 → y ∉ S.untlFix g e))) := by
        intro z
        by_cases hz : z ∈ S.verts
        · have hdef : ((z.1, S.nextTime z.2) : S.Pos) ∈ S.succF z := by
            rw [S.mem_succF]
            exact ⟨(S.mem_verts _).mpr (S.nextTime_mem ((S.mem_verts z).mp hz)), rfl,
              S.transRaw_refl z.2 z.1, S.share_refl (z.2 + 1) z.1⟩
          by_cases hnf : z ∈ S.untlFix g e
          · exact ⟨(z.1, S.nextTime z.2), fun _ => hdef, fun _ hb => absurd hnf hb⟩
          · have hnot : ¬ ∀ y ∈ S.succF z,
                e ∈ S.L y.1 y.2 ∨ (g ∈ S.L y.1 y.2 ∧ y ∈ S.untlFix g e) := by
              intro hall
              exact hnf ((S.mem_untlFix_iff g e z).mpr ⟨hz, hall⟩)
            obtain ⟨y, hy1, hy2⟩ : ∃ y, y ∈ S.succF z ∧
                ¬ (e ∈ S.L y.1 y.2 ∨ (g ∈ S.L y.1 y.2 ∧ y ∈ S.untlFix g e)) := by
              by_contra hcc
              push Not at hcc
              exact hnot (fun y hy => hcc y hy)
            exact ⟨y, fun _ => hy1,
              fun _ _ => ⟨fun hE => hy2 (Or.inl hE), fun hG hF => hy2 (Or.inr ⟨hG, hF⟩)⟩⟩
        · exact ⟨z, fun hz' => absurd hz' hz, fun hz' => absurd hz' hz⟩
      choose f hf1 hf2 using hesc
      set p : ℕ → S.Pos := fun k => f^[k] v with hpdef
      have hp0 : p 0 = v := rfl
      have hpsucc : ∀ k, p (k + 1) = f (p k) := fun k => Function.iterate_succ_apply' f k v
      have hpv : ∀ k, p k ∈ S.verts := by
        intro k
        induction k with
        | zero => rw [hp0]; exact hv
        | succ k ih => rw [hpsucc k]; exact S.succF_subset _ (hf1 (p k) ih)
      obtain ⟨w, hwp⟩ : ∃ w : S.FwdWalk, w.pos = p :=
        ⟨{ pos := p, start_mem := by rw [hp0]; exact hv,
           step := fun k => by rw [hpsucc k]; exact hf1 (p k) (hpv k) }, rfl⟩
      have hw0 : w.pos 0 = v := by rw [hwp, hp0]
      have hidxp : ∀ k : ℕ, w.toThread.idx (v.2 + (k : ℤ)) = (p k).1 := by
        intro k
        have hk := w.walkIdx_add k
        rw [hw0, hwp] at hk
        exact hk
      have hLp : ∀ k : ℕ, S.L (p k).1 (p k).2 = S.L (p k).1 (v.2 + (k : ℤ)) := by
        intro k
        have hk := foldRel_L (S := S) (w.foldRel k) (w.pos k).1
        rw [hw0, hwp] at hk
        exact hk
      have hstepbad : ∀ n : ℕ, p n ∉ S.untlFix g e →
          (e ∉ S.L (p (n + 1)).1 (p (n + 1)).2 ∧
            (g ∈ S.L (p (n + 1)).1 (p (n + 1)).2 → p (n + 1) ∉ S.untlFix g e)) := by
        intro n hn
        have hb := hf2 (p n) (hpv n) hn
        rw [hpsucc n]
        exact hb
      have hthr : w.toThread.idx v.2 = v.1 := by
        have h0 := hidxp 0
        rw [hp0] at h0
        simpa using h0
      obtain ⟨s, hs1, hs2, hs3⟩ := h.1 v.1 v.2 g e hm w.toThread hthr
      have hks : v.2 + (((s - v.2).toNat : ℕ) : ℤ) = s := by omega
      have hk1 : 1 ≤ (s - v.2).toNat := by omega
      have hek : e ∈ S.L (p (s - v.2).toNat).1 (p (s - v.2).toNat).2 := by
        rw [hLp, hks, ← hidxp, hks]
        exact hs2
      by_cases hall : ∀ n : ℕ, p n ∉ S.untlFix g e
      · have hb := (hstepbad ((s - v.2).toNat - 1) (hall ((s - v.2).toNat - 1))).1
        rw [show (s - v.2).toNat - 1 + 1 = (s - v.2).toNat from by omega] at hb
        exact hb hek
      · push Not at hall
        obtain ⟨n0, hn0⟩ := hall
        have hex : ∃ n : ℕ, p n ∈ S.untlFix g e := ⟨n0, hn0⟩
        obtain ⟨N, hN, hNmin⟩ : ∃ N : ℕ, p N ∈ S.untlFix g e ∧
            ∀ m, m < N → p m ∉ S.untlFix g e :=
          ⟨Nat.find hex, Nat.find_spec hex, fun m hm => Nat.find_min hex hm⟩
        have hN1 : 1 ≤ N := by
          rcases Nat.eq_zero_or_pos N with h0 | h1
          · exfalso
            rw [h0, hp0] at hN
            exact hcon hN
          · exact h1
        have hgN : g ∉ S.L (p N).1 (p N).2 := by
          have hb := hstepbad (N - 1) (hNmin (N - 1) (by omega))
          rw [show N - 1 + 1 = N from by omega] at hb
          exact fun hg => hb.2 hg hN
        have hnoE : ∀ m : ℕ, 1 ≤ m → m ≤ N → e ∉ S.L (p m).1 (p m).2 := by
          intro m hm1 hm2
          have hb := hstepbad (m - 1) (hNmin (m - 1) (by omega))
          rw [show m - 1 + 1 = m from by omega] at hb
          exact hb.1
        have hkN : N < (s - v.2).toNat := by
          by_contra hcc
          exact hnoE (s - v.2).toNat hk1 (by omega) hek
        have hgv : g ∈ S.L (w.toThread.idx (v.2 + (N : ℤ))) (v.2 + (N : ℤ)) :=
          hs3 (v.2 + (N : ℤ)) (by omega) (by omega)
        rw [hidxp N, ← hLp N] at hgv
        exact hgN hgv
  | snce g e =>
      dsimp only [plusFulfilClauseAt]
      intro hm
      by_contra hcon
      have hesc : ∀ z : S.Pos, ∃ y : S.Pos,
          (z ∈ S.verts → y ∈ S.predF z) ∧
          (z ∈ S.verts → z ∉ S.snceFix g e →
            (e ∉ S.L y.1 y.2 ∧ (g ∈ S.L y.1 y.2 → y ∉ S.snceFix g e))) := by
        intro z
        by_cases hz : z ∈ S.verts
        · have hdef : ((z.1, S.prevTime z.2) : S.Pos) ∈ S.predF z := by
            rw [S.mem_predF]
            exact ⟨(S.mem_verts _).mpr (S.prevTime_mem ((S.mem_verts z).mp hz)), rfl,
              S.transRaw_refl (S.prevTime z.2) z.1, S.share_refl z.2 z.1⟩
          by_cases hnf : z ∈ S.snceFix g e
          · exact ⟨(z.1, S.prevTime z.2), fun _ => hdef, fun _ hb => absurd hnf hb⟩
          · have hnot : ¬ ∀ y ∈ S.predF z,
                e ∈ S.L y.1 y.2 ∨ (g ∈ S.L y.1 y.2 ∧ y ∈ S.snceFix g e) := by
              intro hall
              exact hnf ((S.mem_snceFix_iff g e z).mpr ⟨hz, hall⟩)
            obtain ⟨y, hy1, hy2⟩ : ∃ y, y ∈ S.predF z ∧
                ¬ (e ∈ S.L y.1 y.2 ∨ (g ∈ S.L y.1 y.2 ∧ y ∈ S.snceFix g e)) := by
              by_contra hcc
              push Not at hcc
              exact hnot (fun y hy => hcc y hy)
            exact ⟨y, fun _ => hy1,
              fun _ _ => ⟨fun hE => hy2 (Or.inl hE), fun hG hF => hy2 (Or.inr ⟨hG, hF⟩)⟩⟩
        · exact ⟨z, fun hz' => absurd hz' hz, fun hz' => absurd hz' hz⟩
      choose f hf1 hf2 using hesc
      set p : ℕ → S.Pos := fun k => f^[k] v with hpdef
      have hp0 : p 0 = v := rfl
      have hpsucc : ∀ k, p (k + 1) = f (p k) := fun k => Function.iterate_succ_apply' f k v
      have hpv : ∀ k, p k ∈ S.verts := by
        intro k
        induction k with
        | zero => rw [hp0]; exact hv
        | succ k ih => rw [hpsucc k]; exact S.predF_subset _ (hf1 (p k) ih)
      obtain ⟨w, hwp⟩ : ∃ w : S.BwdWalk, w.pos = p :=
        ⟨{ pos := p, start_mem := by rw [hp0]; exact hv,
           step := fun k => by rw [hpsucc k]; exact hf1 (p k) (hpv k) }, rfl⟩
      have hw0 : w.pos 0 = v := by rw [hwp, hp0]
      have hidxp : ∀ k : ℕ, w.toThread.idx (v.2 - (k : ℤ)) = (p k).1 := by
        intro k
        have hk := w.walkIdx_sub k
        rw [hw0, hwp] at hk
        exact hk
      have hLp : ∀ k : ℕ, S.L (p k).1 (p k).2 = S.L (p k).1 (v.2 - (k : ℤ)) := by
        intro k
        have hk := foldRelB_L (S := S) (w.foldRelB k) (w.pos k).1
        rw [hw0, hwp] at hk
        exact hk
      have hstepbad : ∀ n : ℕ, p n ∉ S.snceFix g e →
          (e ∉ S.L (p (n + 1)).1 (p (n + 1)).2 ∧
            (g ∈ S.L (p (n + 1)).1 (p (n + 1)).2 → p (n + 1) ∉ S.snceFix g e)) := by
        intro n hn
        have hb := hf2 (p n) (hpv n) hn
        rw [hpsucc n]
        exact hb
      have hthr : w.toThread.idx v.2 = v.1 := by
        have h0 := hidxp 0
        rw [hp0] at h0
        simpa using h0
      obtain ⟨s, hs1, hs2, hs3⟩ := h.2 v.1 v.2 g e hm w.toThread hthr
      have hks : v.2 - (((v.2 - s).toNat : ℕ) : ℤ) = s := by omega
      have hk1 : 1 ≤ (v.2 - s).toNat := by omega
      have hek : e ∈ S.L (p (v.2 - s).toNat).1 (p (v.2 - s).toNat).2 := by
        rw [hLp, hks, ← hidxp, hks]
        exact hs2
      by_cases hall : ∀ n : ℕ, p n ∉ S.snceFix g e
      · have hb := (hstepbad ((v.2 - s).toNat - 1) (hall ((v.2 - s).toNat - 1))).1
        rw [show (v.2 - s).toNat - 1 + 1 = (v.2 - s).toNat from by omega] at hb
        exact hb hek
      · push Not at hall
        obtain ⟨n0, hn0⟩ := hall
        have hex : ∃ n : ℕ, p n ∈ S.snceFix g e := ⟨n0, hn0⟩
        obtain ⟨N, hN, hNmin⟩ : ∃ N : ℕ, p N ∈ S.snceFix g e ∧
            ∀ m, m < N → p m ∉ S.snceFix g e :=
          ⟨Nat.find hex, Nat.find_spec hex, fun m hm => Nat.find_min hex hm⟩
        have hN1 : 1 ≤ N := by
          rcases Nat.eq_zero_or_pos N with h0 | h1
          · exfalso
            rw [h0, hp0] at hN
            exact hcon hN
          · exact h1
        have hgN : g ∉ S.L (p N).1 (p N).2 := by
          have hb := hstepbad (N - 1) (hNmin (N - 1) (by omega))
          rw [show N - 1 + 1 = N from by omega] at hb
          exact fun hg => hb.2 hg hN
        have hnoE : ∀ m : ℕ, 1 ≤ m → m ≤ N → e ∉ S.L (p m).1 (p m).2 := by
          intro m hm1 hm2
          have hb := hstepbad (m - 1) (hNmin (m - 1) (by omega))
          rw [show m - 1 + 1 = m from by omega] at hb
          exact hb.1
        have hkN : N < (v.2 - s).toNat := by
          by_contra hcc
          exact hnoE (v.2 - s).toNat hk1 (by omega) hek
        have hgv : g ∈ S.L (w.toThread.idx (v.2 - (N : ℤ))) (v.2 - (N : ℤ)) :=
          hs3 (v.2 - (N : ℤ)) (by omega) (by omega)
        rw [hidxp N, ← hLp N] at hgv
        exact hgN hgv

/-! ## The decision procedure for (C2') at L⁺ -/

/--
**(C2') is exactly the window check, given (C1').**

The hypothesis is not an artefact of the proof: the far-left case of the forward direction
cannot be closed without it, for the reason recorded above.
-/
theorem plusThreadFulfilling_iff_window {S : PlusSharingWitnessFamily Γ Del}
    (hlc : S.PlusLocalCoherentShare) : S.PlusThreadFulfilling ↔ S.PlusFulfilWindow :=
  ⟨window_of_plusThreadFulfilling, plusThreadFulfilling_of_window hlc⟩

/--
**(C2') decides, given (C1').**

A `Decidable` *term* rather than an `instance`, because it takes a proof argument. The bundled
form below is the one a certificate consumes, and it is a genuine `instance`.
-/
def decidablePlusThreadFulfilling {S : PlusSharingWitnessFamily Γ Del}
    (hlc : S.PlusLocalCoherentShare) : Decidable S.PlusThreadFulfilling :=
  decidable_of_iff S.PlusFulfilWindow (plusThreadFulfilling_iff_window hlc).symm

/--
**(C1') and (C2') decide jointly**, with no hypothesis, because the conjunction supplies its own.

This is the form the L⁺ certificate consumes: the bundle already carries
`PlusLocalCoherentShare`, so nothing downstream needs the standalone instance.
-/
instance decidablePlusCoherentShareAndFulfilling (S : PlusSharingWitnessFamily Γ Del) :
    Decidable (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) :=
  decidable_of_iff (S.PlusLocalCoherentShare ∧ S.PlusFulfilWindow)
    (by
      constructor
      · rintro ⟨h1, h2⟩
        exact ⟨h1, plusThreadFulfilling_of_window h1 h2⟩
      · rintro ⟨h1, h2⟩
        exact ⟨h1, window_of_plusThreadFulfilling h2⟩)

/-- The bundled instance the L⁺ certificate consumes, confirmed by synthesis rather than
asserted. -/
example (S : PlusSharingWitnessFamily Γ Del) :
    Decidable (S.PlusLocalCoherentShare ∧ S.PlusThreadFulfilling) := inferInstance

/-! ## A computed smoke test

The fixpoint is a *computation*, so it can be wrong in a way no lemma above would catch: an
operator that never fires, a window that decodes to the wrong times, an edge relation that is
empty. The `#guard`s below run it on the smallest L⁺ family that has anything to say and check
the answer against a hand computation. They are a mechanical non-vacuity check on the
computation, not a mathematical claim.

The family has one lasso with `back = [∅]`, `mid = [{p}]`, `fwd = [∅]` and identity
representative maps, so `NB = NF = 1`, `NM = 2` and the window is `[-2, 4)`: six positions,
labelled `∅, ∅, {p}, ∅, ∅, ∅` at `-2, -1, 0, 1, 2, 3`. `nextTime` is `u + 1` except at `3`,
where it wraps back to `3`; `prevTime` is `u - 1` except at `-2`, where it wraps to `-2`.

With `g = e = p`, `A[p U p]` holds exactly at `-1` — the one position whose every successor
carries `p` — and nowhere else. The `snce` dual is the mirror image at `1`. That the two answers
are singletons rather than `∅` or the whole window is the point: the operator fires, and it does
not fire everywhere.
-/

section SmokeTest

open FormalSystem.Syntax

/-- The single atom of the smoke test. -/
private def smokeAtom : Atom := Atom.mkBase "p"

/-- The single L⁺ formula of the smoke test. -/
private def smokeP : PlusFormula := PlusFormula.atom smokeAtom

/-- The smoke test's premise context. -/
private def smokeCtx : PlusContext := [smokeP]

private theorem smokeP_mem : smokeP ∈ plusClosureOf (smokeCtx ++ ([] : PlusContext)) :=
  self_mem_plusClosureOf (by simp [smokeCtx])

private theorem smokeLabel_sub :
    ({smokeP} : Finset PlusFormula) ⊆ plusClosureOf (smokeCtx ++ ([] : PlusContext)) := by
  intro ψ hψ
  rw [Finset.mem_singleton] at hψ
  exact hψ ▸ smokeP_mem

/-- One lasso carrying `p` at the origin and nothing anywhere else. -/
private def smokeLasso : PlusLabelledLasso (plusClosureOf (smokeCtx ++ ([] : PlusContext))) where
  back := [∅]
  mid := [{smokeP}]
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact Finset.empty_subset _
    · exact smokeLabel_sub
    · exact Finset.empty_subset _

/-- The smallest L⁺ sharing family: one lasso, identity representatives, so `share` is total and
the graph is a single folded line. -/
private def smokeFamily : PlusSharingWitnessFamily smokeCtx [] where
  bx := fun _ => false
  lassos := [smokeLasso]
  lassos_ne := by simp
  repBack := [id]
  repMid := [id]
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl
  transBack := transFullOf _ [id]
  transMid := transFullOf _ [id]
  transFwd := transFullOf _ [id]
  transBack_len := transFullOf_length _ _
  transMid_len := transFullOf_length _ _
  transFwd_len := transFullOf_length _ _
  trans_refl := transFullOf_refl _ _ _ _
  lift := liftable_of_transFullOf _ _ _ _ (by simp) (by simp)

-- linter.hashCommand: these `#guard`s run the compiled definitions, which is the point of a
-- smoke test — a `theorem … := by decide` would check the same fact without exercising the
-- evaluator the model checker will use.
set_option linter.hashCommand false in
#guard smokeFamily.winTimes = ({-2, -1, 0, 1, 2, 3} : Finset ℤ)

-- linter.hashCommand: this `#guard` runs the compiled fixpoint, which is the point of a
-- smoke test — deleting the suppression would silence the command, not the check.
set_option linter.hashCommand false in
#guard (smokeFamily.untlFix smokeP smokeP).image Prod.snd = ({-1} : Finset ℤ)

-- linter.hashCommand: this `#guard` runs the compiled fixpoint, which is the point of a
-- smoke test — deleting the suppression would silence the command, not the check.
set_option linter.hashCommand false in
#guard (smokeFamily.snceFix smokeP smokeP).image Prod.snd = ({1} : Finset ℤ)

end SmokeTest

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
