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
theorem foldRel_L {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.window.FoldRel a b)
    (i : Fin S.lassos.length) : S.L i a = S.L i b := by
  rcases h with rfl | ⟨h1, h2, h3⟩
  · rfl
  · exact (S.data_congr_fwd h1 h2 h3).2 i

/-- Backward-folded times carry the same labels. -/
theorem foldRelB_L {S : PlusSharingWitnessFamily Γ Del} {a b : ℤ} (h : S.window.FoldRelB a b)
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

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
