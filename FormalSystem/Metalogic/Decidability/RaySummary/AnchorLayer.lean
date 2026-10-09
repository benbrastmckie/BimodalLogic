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

/-! ## The cells of a model -/

/-- The cells of a model: one per world state, read at time `0` (without loss, by
`cellAt_eq_cellAt`). -/
def anchorCells (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    Set (Set (Finset PlusFormula)) :=
  Set.range (fun w : F.WorldState => cellAt M φ w 0)

theorem mem_anchorCells_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (C : Set (Finset PlusFormula)) :
    C ∈ anchorCells M φ ↔ ∃ w : F.WorldState, cellAt M φ w 0 = C :=
  Set.mem_range

/-- The type of any point of the model lies in the cell of that point's state, read at
time `0`: the shift of the history by the point's time passes through `(0, w)` with the same
type (`cellAt_eq_cellAt` unfolded for one direction). -/
theorem tpOf_mem_cellAt_zero (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : tpOf M φ σ z ∈ cellAt M φ (σ.state z) 0 := by
  refine ⟨σ.timeShift z, ?_, ?_⟩
  · rw [WorldHistory.timeShift_state, zero_add]
  · rw [tpOf_timeShift, zero_add]

/-! ## The finite anchor object -/

/-- **The closure-wide anchor object**: a set of cells satisfying the Hintikka clauses and the
`box`/`stab` fixpoint equations. `Anchored.box`/`Anchored.stab`/`LocalRun.bot`/`LocalRun.imp` on
types rather than on one seam's colouring: `box` is one GLOBAL bit per `□`-subformula (`∀ C' ∈
𝒞, ∀ T' ∈ C'`, no time in sight — `box_time_invariant`), `stab` one bit per (`⊡`-subformula,
cell). The `untl`/`snce` nesting is NOT here — it is the run layer, blocked (README, "(W): what
landed and what did not"). Every quantifier is bounded by `plusSubformulaClosure φ` so that the
`Finset` twin `AnchorConsFin` is decidable field for field. -/
structure AnchorCons (φ : PlusFormula) (𝒞 : Set (Set (Finset PlusFormula))) : Prop where
  closure : ∀ C ∈ 𝒞, ∀ T ∈ C, T ⊆ plusSubformulaClosure φ
  bot : ∀ C ∈ 𝒞, ∀ T ∈ C, PlusFormula.bot ∉ T
  imp : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ, ∀ χ ∈ plusSubformulaClosure φ,
    PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ →
      (PlusFormula.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))
  box : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.box ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')
  stab : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.stab ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')

/-- **Completeness of the anchor layer, for EVERY model**: the cells of any `TaskModel` on a
`ℤ`-frame form an anchor object. No presentation, no `Presented`, no finiteness hypothesis on
the model, no regularity — the absence of hypotheses is the content. Field by field from the
four equations: the `box` field routes `∀ C' ∈ anchorCells, ∀ T' ∈ C'` through
`box_mem_tpOf_iff`'s `∀ σ' z'` by `tpOf_mem_cellAt_zero`; the `stab` field is
`stab_mem_tpOf_iff` with `σ.state 0 = w = σ'.state 0`. No new induction. -/
theorem anchorCons_anchorCells (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    AnchorCons φ (anchorCells M φ) where
  closure := by
    rintro C ⟨w, rfl⟩ T ⟨σ, rfl, rfl⟩
    exact tpOf_subset M φ σ 0
  bot := by
    rintro C ⟨w, rfl⟩ T ⟨σ, rfl, rfl⟩
    exact bot_not_mem_tpOf M φ σ 0
  imp := by
    rintro C ⟨w, rfl⟩ T ⟨σ, rfl, rfl⟩ ψ _ χ _ h
    exact imp_mem_tpOf_iff M φ σ 0 h
  box := by
    rintro C ⟨w, rfl⟩ T ⟨σ, rfl, rfl⟩ ψ _ h
    rw [box_mem_tpOf_iff M φ σ 0 h]
    constructor
    · rintro H C' ⟨w', rfl⟩ T' ⟨σ', _, rfl⟩
      exact H σ' 0
    · intro H σ' z'
      exact H _ ⟨σ'.state z', rfl⟩ _ (tpOf_mem_cellAt_zero M φ σ' z')
  stab := by
    rintro C ⟨w, rfl⟩ T ⟨σ, rfl, rfl⟩ ψ _ h
    rw [stab_mem_tpOf_iff M φ σ 0 h]
    constructor
    · rintro H T' ⟨σ', hσ', rfl⟩
      exact H σ' hσ'.symm
    · intro H σ' hσ'
      exact H _ ⟨σ', hσ'.symm, rfl⟩

/-! ## Finiteness and the bound -/

/-- A cell is a set of subsets of the closure. -/
theorem anchorCells_subset_powerset (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    anchorCells M φ ⊆ 𝒫 (↑(plusSubformulaClosure φ).powerset : Set (Finset PlusFormula)) := by
  rintro C ⟨w, rfl⟩ T ⟨σ, _, rfl⟩
  rw [Finset.mem_coe, Finset.mem_powerset]
  exact tpOf_subset M φ σ 0

theorem anchorCells_finite (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    (anchorCells M φ).Finite :=
  Set.Finite.subset ((Finset.finite_toSet _).powerset) (anchorCells_subset_powerset M φ)

/-- The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model,
syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there are at most
`2 ^ (2 ^ |cl φ|)` of them. It is not a complexity bound of any kind: it counts cells, it does
not time anything, and it must not be described as a bound on any procedure's running time. -/
theorem anchorCells_ncard_le (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    (anchorCells M φ).ncard ≤ 2 ^ (2 ^ (plusSubformulaClosure φ).card) := by
  calc (anchorCells M φ).ncard
      ≤ (𝒫 (↑(plusSubformulaClosure φ).powerset : Set (Finset PlusFormula))).ncard :=
        Set.ncard_le_ncard (anchorCells_subset_powerset M φ)
          ((Finset.finite_toSet _).powerset)
    _ = 2 ^ (↑(plusSubformulaClosure φ).powerset : Set (Finset PlusFormula)).ncard :=
        Set.ncard_powerset _ (Finset.finite_toSet _)
    _ = 2 ^ (plusSubformulaClosure φ).powerset.card := by rw [Set.ncard_coe_finset]
    _ = 2 ^ (2 ^ (plusSubformulaClosure φ).card) := by rw [Finset.card_powerset]

/-! ## The decidable checker on a concrete finite object -/

/-- The `Finset` twin of `AnchorCons`: the same five equations on a concrete finite object. -/
structure AnchorConsFin (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    Prop where
  closure : ∀ C ∈ 𝒞, ∀ T ∈ C, T ⊆ plusSubformulaClosure φ
  bot : ∀ C ∈ 𝒞, ∀ T ∈ C, PlusFormula.bot ∉ T
  imp : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ, ∀ χ ∈ plusSubformulaClosure φ,
    PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ →
      (PlusFormula.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))
  box : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.box ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')
  stab : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.stab ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')

/-- Decidable on a concrete finite object: every quantifier is bounded by a `Finset`
(`Finset.decidableDforallFinset`) and every atom is a `Finset` membership on `PlusFormula`,
which has derived `DecidableEq`. A statement about a finite set, not about L⁺ and not about any
model — `AnchorConsFin φ 𝒞` says nothing about whether `𝒞` is the cell set of a model. -/
instance decidableAnchorConsFin (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    Decidable (AnchorConsFin φ 𝒞) :=
  decidable_of_iff
    ((∀ C ∈ 𝒞, ∀ T ∈ C, T ⊆ plusSubformulaClosure φ) ∧
      (∀ C ∈ 𝒞, ∀ T ∈ C, PlusFormula.bot ∉ T) ∧
      (∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ, ∀ χ ∈ plusSubformulaClosure φ,
        PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ →
          (PlusFormula.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))) ∧
      (∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
        PlusFormula.box ψ ∈ plusSubformulaClosure φ →
          (PlusFormula.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')) ∧
      (∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
        PlusFormula.stab ψ ∈ plusSubformulaClosure φ →
          (PlusFormula.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')))
    ⟨fun ⟨h₁, h₂, h₃, h₄, h₅⟩ => ⟨h₁, h₂, h₃, h₄, h₅⟩,
     fun ⟨h₁, h₂, h₃, h₄, h₅⟩ => ⟨h₁, h₂, h₃, h₄, h₅⟩⟩

/-- The `Finset` twin agrees with `AnchorCons` on the image of the object under coercion:
`Set.mem_image`/`Finset.mem_coe` rewriting on each field, no content. -/
theorem anchorConsFin_iff (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    AnchorConsFin φ 𝒞 ↔
      AnchorCons φ ((fun C : Finset (Finset PlusFormula) => (↑C : Set (Finset PlusFormula))) '' ↑𝒞) := by
  constructor
  · intro h
    refine ⟨?_, ?_, ?_, ?_, ?_⟩
    · rintro C ⟨C₀, hC₀, rfl⟩ T hT
      exact h.closure C₀ hC₀ T hT
    · rintro C ⟨C₀, hC₀, rfl⟩ T hT
      exact h.bot C₀ hC₀ T hT
    · rintro C ⟨C₀, hC₀, rfl⟩ T hT ψ hψ χ hχ hi
      exact h.imp C₀ hC₀ T hT ψ hψ χ hχ hi
    · rintro C ⟨C₀, hC₀, rfl⟩ T hT ψ hψ hb
      rw [h.box C₀ hC₀ T hT ψ hψ hb]
      constructor
      · rintro H C' ⟨C₀', hC₀', rfl⟩ T' hT'
        exact H C₀' hC₀' T' hT'
      · intro H C₀' hC₀' T' hT'
        exact H _ ⟨C₀', hC₀', rfl⟩ T' hT'
    · rintro C ⟨C₀, hC₀, rfl⟩ T hT ψ hψ hs
      exact h.stab C₀ hC₀ T hT ψ hψ hs
  · intro h
    refine ⟨?_, ?_, ?_, ?_, ?_⟩
    · intro C₀ hC₀ T hT
      exact h.closure _ ⟨C₀, hC₀, rfl⟩ T hT
    · intro C₀ hC₀ T hT
      exact h.bot _ ⟨C₀, hC₀, rfl⟩ T hT
    · intro C₀ hC₀ T hT ψ hψ χ hχ hi
      exact h.imp _ ⟨C₀, hC₀, rfl⟩ T hT ψ hψ χ hχ hi
    · intro C₀ hC₀ T hT ψ hψ hb
      rw [h.box _ ⟨C₀, hC₀, rfl⟩ T hT ψ hψ hb]
      constructor
      · intro H C₀' hC₀' T' hT'
        exact H _ ⟨C₀', hC₀', rfl⟩ T' hT'
      · rintro H C' ⟨C₀', hC₀', rfl⟩ T' hT'
        exact H C₀' hC₀' T' hT'
    · intro C₀ hC₀ T hT ψ hψ hs
      exact h.stab _ ⟨C₀, hC₀, rfl⟩ T hT ψ hψ hs

end FormalSystem.Metalogic.Decidability.RaySummary
