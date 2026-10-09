/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Closure
import FormalSystem.PlusLanguage.PlusTruth

/-!
# The anchor layer of requirement (W): closure types, cells, and the fixpoint equations

Requirement (W) of the `RaySummary/` README's verdict asks for ONE finite object that witnesses
`¬ PlusValidZTime φ` for some regular `ℤ`-model, history and time — an object carrying "for every
time, the `box` anchor across the whole slice and, for every state, the `stab` anchor, nested
under `untl`/`snce`". This module is the half of that object the semantics lets one state on
every model with no hypothesis at all: the **anchor layer**. The other half — the `untl`/`snce`
nesting, which lives in type sequences over `ℤ` and needs the path set of a yet-to-be-built frame
— is the **run layer**, and it is BLOCKED on three named obligations recorded in the README's
"(W): what landed and what did not"; nothing here touches it.

**Why the anchor layer is a per-STATE object, not a per-time one.** `box_global`
(`PlusLanguage/PlusTruth.lean`) says `□ψ` has one truth value per model — along every history at
every time — because the history set of a task frame is shift-closed; and `stab_state_only` says
`⊡ψ` is a function of the world state alone. So the "for every time" quantifier the requirement
names does not exist in this semantics: the `box` letters of a closure-wide object are
`|{□ψ ∈ cl φ}|` global bits, and the `stab` letters are one bit per (`⊡ψ`, world state). The
objects here follow that shape exactly.

**(a) Closure types.** `tpOf M φ σ z` is the set of closure formulas (`plusSubformulaClosure φ`)
true at the point `(σ, z)` — HWZ 2000 Definition 10's type `t`, as a `Finset`, read off a model
(`mem_tpOf_iff`). It is classical in `PlusTruthAt` and hence noncomputable; the carrier is a
`Finset` so that the cardinality bound of the finite object is a two-step `Finset.card_powerset`
computation rather than `Set` plumbing. Shifting the history shifts the time
(`tpOf_timeShift`, from `plusTruthAt_timeShift`).

**(b) Cells.** `cellAt M φ w z` is the set of closure types realized at the world state `w` at
time `z` — by the histories through `(z, w)`. It is time-independent (`cellAt_eq_cellAt`): a
history through `(z, w)` shifts to one through `(z', w)` with the same type, by
`WorldHistory.timeShift_state` and `tpOf_timeShift`. That is why a cell is a per-STATE datum, and
why the finite object of (W) is a set of cells (sets of types) rather than a set of types: the
wired probe `quasistate-does-not-determine-hit.lean` shows per-time sets of types do not
determine `⊡`, and the cell is exactly the data `⊡` reads (`stab_iff`: all histories through the
same state at the same time).

**(c) The fixpoint equations.** Four equations a closure type satisfies by the truth clauses
alone, each a direct unfolding of a clause of `PlusTruthAt` with a closure projection from
`Subformulas.lean`:

* `bot_not_mem_tpOf` — `⊥` is in no type (`LocalRun.bot` on types);
* `imp_mem_tpOf_iff` — `ψ → χ` is in a type iff `ψ` in it implies `χ` in it (`LocalRun.imp`);
* `box_mem_tpOf_iff` — `□ψ` is in a type iff `ψ` is in EVERY type of EVERY point of the model:
  `Anchored.box` with its per-time quantifier gone (`box_time_invariant`), one global bit;
* `stab_mem_tpOf_iff` — `⊡ψ` is in a type at `(σ, z)` iff `ψ` is in the type of every history
  through `σ`'s state at `z`: `Anchored.stab` on types, one bit per cell.

`AnchorCons` (below the equations in this module) bundles these as consistency conditions on a
set of cells, `anchorCons_anchorCells` says EVERY model's cells satisfy them, and
`anchorCells_ncard_le` bounds the number of cells by `2 ^ (2 ^ |cl φ|)`; `AnchorConsFin` is the
same bundle on a concrete `Finset`, decidable field for field.

**What is NOT here.** No `[F.IsRegular]`: the anchor layer is a consequence of shift-closure and
the truth clauses on every `ℤ`-frame, the regular case is an instance, and the requirement's
`[F.IsRegular]` is the minimum hypothesis a CLAIM ABOUT VALIDITY must carry, not a hypothesis
these definitions need. Nothing about `PlusValidZTime`: no declaration of this module mentions
it, and no object here witnesses a non-validity — that is the run layer. Nothing decidable about
a MODEL: the one `Decidable` instance (`decidableAnchorConsFin`) is on a concrete
`Finset (Finset (Finset PlusFormula))` and is a statement about a finite set, not about L⁺.
No `untl`/`snce` equation: those clauses quantify over times along a history and are not
conditions on a type or a cell. No finiteness or presentation hypothesis on any model, no
backward Bool-fixture bridge (the fixtures of this collection are forward-only), and no
complexity bound of any kind — `anchorCells_ncard_le` counts cells, it does not time anything.

## References

* Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal logics*,
  Definitions 10-12 (types, state candidates, runs, quasimodels) — a guide to shape; every claim
  here is proved from `PlusTruth.lean`'s clauses
* `FormalSystem/PlusLanguage/PlusTruth.lean` — `box_time_invariant`, `box_global`,
  `stab_state_only`, `plusTruthAt_timeShift`, the clause lemmas
* `FormalSystem/Metalogic/Decidability/RaySummary/Closure.lean` — `Anchored`, `LocalRun`, the
  one-seam shapes these equations generalize
* `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — "The verdict", requirement (W),
  and "(W): what landed and what did not"

## Tags

decidability · ray-summary · anchor-layer · closure-type · quasimodel
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

variable {F : FrameOver intOrder}

/-! ## Closure types -/

open Classical in
/-- The closure type of the point `(σ, z)`: the subformulas of `φ` true there (HWZ 2000,
Definition 10's `t`, read off a model). Classical in `PlusTruthAt`, hence noncomputable; a
`Finset` so that the bound on the finite object below is a `Finset.card_powerset` count. -/
noncomputable def tpOf (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : Finset PlusFormula :=
  (plusSubformulaClosure φ).filter (fun ψ => PlusTruthAt M σ z ψ)

open Classical in
theorem mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) (ψ : PlusFormula) :
    ψ ∈ tpOf M φ σ z ↔ ψ ∈ plusSubformulaClosure φ ∧ PlusTruthAt M σ z ψ := by
  unfold tpOf
  exact Finset.mem_filter

open Classical in
/-- A closure type is a subset of the closure. -/
theorem tpOf_subset (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : tpOf M φ σ z ⊆ plusSubformulaClosure φ :=
  Finset.filter_subset _ _

/-- Shifting the history shifts the time of the type (`plusTruthAt_timeShift`). -/
theorem tpOf_timeShift (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z Δ : ℤ) :
    tpOf M φ (σ.timeShift Δ) z = tpOf M φ σ (z + Δ) := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff, plusTruthAt_timeShift]

/-! ## Cells -/

/-- The cell of a world state at a time: the closure types realized at that state by histories
through it at that time. Time-independent (`cellAt_eq_cellAt`), so a per-STATE datum. -/
def cellAt (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState) (z : ℤ) :
    Set (Finset PlusFormula) :=
  {T | ∃ σ : WorldHistory F.toTaskFrame, σ.state z = w ∧ tpOf M φ σ z = T}

theorem mem_cellAt_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState)
    (z : ℤ) (T : Finset PlusFormula) :
    T ∈ cellAt M φ w z ↔ ∃ σ : WorldHistory F.toTaskFrame, σ.state z = w ∧ tpOf M φ σ z = T :=
  Iff.rfl

/-- One inclusion of `cellAt_eq_cellAt`: a history through `(z, w)` shifts to one through
`(z', w)` with the same type. -/
theorem cellAt_subset_cellAt (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState)
    (z z' : ℤ) : cellAt M φ w z ⊆ cellAt M φ w z' := by
  rintro T ⟨σ, hs, rfl⟩
  refine ⟨σ.timeShift (z - z'), ?_, ?_⟩
  · rw [WorldHistory.timeShift_state, add_sub_cancel]
    exact hs
  · rw [tpOf_timeShift, add_sub_cancel]

/-- **Cells are time-independent**: the closure types realized at a world state do not depend
on the time at which the state is visited. This is why the anchor layer of (W) is a set of
per-STATE cells and carries no "for every time" quantifier. -/
theorem cellAt_eq_cellAt (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState)
    (z z' : ℤ) : cellAt M φ w z = cellAt M φ w z' :=
  Set.Subset.antisymm (cellAt_subset_cellAt M φ w z z') (cellAt_subset_cellAt M φ w z' z)

/-! ## The fixpoint equations

Each is a clause of `PlusTruthAt` unfolded on a type, with the closure projection that keeps the
components inside `plusSubformulaClosure φ`. -/

/-- `⊥` is in no closure type (`LocalRun.bot` on types). -/
theorem bot_not_mem_tpOf (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : PlusFormula.bot ∉ tpOf M φ σ z := by
  rw [mem_tpOf_iff]
  exact fun h => PlusTruth.bot_false M σ z h.2

/-- `ψ → χ` is in a closure type iff `ψ` in it implies `χ` in it (`LocalRun.imp` on types). -/
theorem imp_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ χ : PlusFormula}
    (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) :
    PlusFormula.imp ψ χ ∈ tpOf M φ σ z ↔ (ψ ∈ tpOf M φ σ z → χ ∈ tpOf M φ σ z) := by
  have hψ := plusClosure_imp_left φ ψ χ h
  have hχ := plusClosure_imp_right φ ψ χ h
  rw [mem_tpOf_iff, mem_tpOf_iff, mem_tpOf_iff, PlusTruth.imp_iff]
  constructor
  · rintro ⟨_, himp⟩ ⟨_, hψ'⟩
    exact ⟨hχ, himp hψ'⟩
  · intro H
    exact ⟨h, fun hψ' => (H ⟨hψ, hψ'⟩).2⟩

/-- **The closure-wide `box` equation**: `□ψ` is in a closure type iff `ψ` is in every closure
type of every point of the model. `Anchored.box` on types with the per-time quantifier gone
(`box_time_invariant`): one global bit per `□`-subformula. -/
theorem box_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ : PlusFormula}
    (h : PlusFormula.box ψ ∈ plusSubformulaClosure φ) :
    PlusFormula.box ψ ∈ tpOf M φ σ z ↔
      ∀ (σ' : WorldHistory F.toTaskFrame) (z' : ℤ), ψ ∈ tpOf M φ σ' z' := by
  have hψ := plusClosure_box φ ψ h
  rw [mem_tpOf_iff]
  constructor
  · rintro ⟨_, hb⟩ σ' z'
    rw [mem_tpOf_iff]
    refine ⟨hψ, ?_⟩
    have hb' := (box_time_invariant M σ z z' ψ).mp hb
    exact (PlusTruth.box_iff M σ z' ψ).mp hb' σ'
  · intro H
    refine ⟨h, ?_⟩
    rw [PlusTruth.box_iff]
    intro σ'
    exact ((mem_tpOf_iff M φ σ' z ψ).mp (H σ' z)).2

/-- **The closure-wide `stab` equation**: `⊡ψ` is in the closure type at `(σ, z)` iff `ψ` is in
the closure type of every history through `σ`'s state at `z`. `Anchored.stab` on types: one bit
per (`⊡`-subformula, world state), i.e. per cell. -/
theorem stab_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ : PlusFormula}
    (h : PlusFormula.stab ψ ∈ plusSubformulaClosure φ) :
    PlusFormula.stab ψ ∈ tpOf M φ σ z ↔
      ∀ σ' : WorldHistory F.toTaskFrame, σ.state z = σ'.state z → ψ ∈ tpOf M φ σ' z := by
  have hψ := plusClosure_stab φ ψ h
  rw [mem_tpOf_iff, PlusTruth.stab_iff]
  constructor
  · rintro ⟨_, hs⟩ σ' hσ'
    exact (mem_tpOf_iff M φ σ' z ψ).mpr ⟨hψ, hs σ' hσ'⟩
  · intro H
    exact ⟨h, fun σ' hσ' => ((mem_tpOf_iff M φ σ' z ψ).mp (H σ' hσ')).2⟩

end FormalSystem.Metalogic.Decidability.RaySummary
