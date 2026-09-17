/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.DurationClassification
import Mathlib.Algebra.Order.Hom.Monoid
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

/-!
# Carrier Normalization: Transporting the Semantics along a Duration Isomorphism

`ValidZTime` quantifies over *every* discrete duration carrier `D` — every nontrivial
successor-Archimedean ordered abelian group. This module shows that quantifier is redundant:
one carrier, `ℤ`, already decides it. The headline result is

  `validZTime_iff_validInt : ValidZTime φ ↔ ValidInt φ`

and the machinery that gets there is a generic transport of the whole semantic stack —
the frame, `TaskModel`, `WorldHistory`, `TruthAt` — along an arbitrary ordered-group
isomorphism `e : D ≃+o E`. The isomorphism that specializes it to `ℤ` is
`DurationClassification.lean`'s `intIso`.

Note the transport is stated for `≃+o`, an *additive order* isomorphism, not `≃o`. Durations
**add** — `TaskRel`'s Compositionality is stated at `x + y` — so an order-only isomorphism
cannot carry a frame across. This is why `orderIsoIntOfLinearSuccPredArch`, which fits the
`ValidZTime` binder bundle verbatim, is not the route; see the `archimedean_of_lub` docstring
in `Semantics/DurationClassification.lean` for the full recorded finding.

## Design decision: `Aligned`, a relation

The history transport is the `Prop`-valued relation `Aligned`: `σ'.state n = σ.state (e.symm n)`
for every `n`. It is a **non-dependent** equation between two `F.WorldState` terms, because
`(FrameOver.map F e).WorldState` is *definitionally* `F.WorldState` and `WorldHistory.state` needs
no domain proof.

`Aligned e` is, verbatim, the `Rel` field of a `Semantics.TruthCorr` (`alignedCorr` below): the
generic relational transport `Truth.truthAt_of_truthCorr` asks for a relation on world histories,
atomic agreement on related pairs, and existence of a related world history in each direction —
never for an inverse. That is why `truthAt_map` is a one-line instance of the generic lemma rather
than its own induction.

## Recorded tactic trap

`linarith` does not fire on the bare `AddCommGroup` + `LinearOrder` bundle these lemmas run on —
there is no ring structure. (This one bites in `DurationClassification.lean`'s
`succ_eq_add_succ_zero`, not here, but it is the same binder bundle.)

## Main results

- `FrameOver.map`: transport a task frame along `e : D ≃+o E`, every field.
- `TaskModel.map`, `PartialHistory.map`, `PartialHistory.comap`, `WorldHistory.map`,
  `WorldHistory.comap`: the model and history transports.
- `Aligned`, `aligned_map`, `aligned_comap`: the pointwise correspondence between a world
  history and its transport.
- `alignedCorr`: `Aligned e` packaged as a `TruthCorr M (M.map e)`.
- `truthAt_map`: `TruthAt M σ t φ ↔ TruthAt (M.map e) σ' (e t) φ` for aligned `σ`, `σ'` —
  `Truth.truthAt_of_truthCorr` at `alignedCorr`.
- `ValidInt`: validity over `ℤ`-frames only.
- `validZTime_iff_validInt`: **carrier normalization** — `ValidZTime φ ↔ ValidInt φ`.

## Tags

ztime · transfer · normal-form
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {D E : TemporalOrder}

/-!
## Is this base change along a temporal-order morphism?

**Verdict: only along isomorphisms, and that restriction is forced — not incidental.**

`FrameOver.map F e` *is* reindexing: it leaves `WorldState` alone and precomposes `TaskRel`'s
duration argument with `e.symm`, so as a construction it is base change along `e.symm : ↑E → ↑D`,
carrying the fibre over `D` to the fibre over `E`. To that extent the suspicion is correct and the
fibration language names something already here.

But the construction does **not** generalize to a one-directional morphism, and the obstruction is
identifiable to a single axiom. Read the field proofs:

| obligation | what it uses | needs |
|---|---|---|
| reflection law | `map_neg` | a group hom |
| `comp`, `serial`, `saturation` | `map_le_map_iff e.symm` in the `.mpr` direction | `e.symm` order-reflecting |
| **`limit`** | `map_lt_map_iff e` **and** `map_lt_map_iff e.symm` | **both directions** |

*Limit* is the one that forces it. Its hypothesis is instantiated at `e x` — pushing a duration
*forward* — while its witness is produced as `e.symm n`, pulling one *back*. A base change along a
morphism `g : ↑E → ↑D` with no inverse has nothing to instantiate the hypothesis with. Nor is this
an artifact of the proof: *Limit* says every positive cone shrinks to a point, and a
non-surjective reindexing can omit precisely the small durations that witness it.

Everything downstream inherits the restriction. `WorldHistory.comap`, and through it the `box`
case of `truthAt_map`, consume `e` in the *forward* direction, so the truth-transfer theorem is an
equivalence of fibres induced by an isomorphism of bases, not a functorial action of a morphism.

**Consequence for scope.** There is no general `FrameOver.baseChange` hiding in this file waiting
to be named, and introducing one would require new mathematics — a genuine theory of
temporal-order morphisms, with *Limit* re-proved under whatever weaker hypothesis turns out to
suffice. That is out of scope here and is recorded as a finding, not a deferral: what this module
contains is the statement that **the fibres over isomorphic temporal orders are equivalent**, at
the frame (`map`), model (`TaskModel.map`), history (`map`/`comap`/`Aligned`) and truth
(`truthAt_map`) levels. The declarations below are migrated to the fibre and otherwise left
exactly as they were.
-/

/--
Transport a task frame along an ordered-group isomorphism of temporal orders.

The world states are carried over unchanged — only the duration index of `TaskRel` moves, by
pulling back along `e.symm`. Each field is then the original field composed with
`e.symm`, with `map_add`/`map_neg`/`map_sub` and `map_le_map_iff`/`map_lt_map_iff` supplying the
compatibility.

The *Saturation* field is the cheapest of the interesting ones rather than the most expensive:
under an ordered-group isomorphism the fiber and segment predicates (`TaskFrame.Fib`,
`TaskFrame.Seg`) pick out the *identical* subsets of `WorldState`, so `F.saturation` is handed
back the **same** directed family. No directedness argument is reconstructed.
-/
def FrameOver.map (F : FrameOver D) (e : ↑D ≃+o ↑E) : FrameOver E :=
  FrameOver.ofReflective F.WorldState (fun w d u => F.TaskRel w (e.symm d) u)
    (by
      intro w d u
      simpa [map_neg] using F.reflection w (e.symm d) u)
    (by
      intro w v x y hx hy
      have hx' : (0 : ↑D) ≤ e.symm x := by
        simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
      have hy' : (0 : ↑D) ≤ e.symm y := by
        simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
      have := F.comp w v (e.symm x) (e.symm y) hx' hy'
      simpa [map_add] using this)
    (by
      intro w x hx
      have hx' : (0 : ↑D) ≤ e.symm x := by
        simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
      exact F.serial w (e.symm x) hx')
    (by
      intro w u h
      refine F.limit w u ?_
      intro x hx
      obtain ⟨n, hn, hR⟩ := h (e x) (by simpa using (map_lt_map_iff e (a := 0) (b := x)).mpr hx)
      refine ⟨e.symm n, ?_, hR⟩
      have : |e.symm n| = e.symm |n| := (map_abs e.symm n).symm
      rw [this]
      have := (map_lt_map_iff e.symm (a := |n|) (b := e x)).mpr hn
      simpa using this)
    (by
      -- `F.saturation` is handed the *identical* directed family: `Seg`/`Fib` under `e` pick out
      -- the same subsets of `F.WorldState`, so only the duration witnesses need translating.
      intro S hS hmem
      refine F.saturation S hS ?_
      intro s hs
      obtain ⟨hfs, hne⟩ := hmem s hs
      refine ⟨?_, hne⟩
      rcases hfs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
      · exact Or.inl ⟨w, e.symm x, rfl⟩
      · refine Or.inr ⟨w, v, e.symm x, e.symm y, ?_, ?_, ?_⟩
        · simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
        · simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
        · simp [TaskFrame.Seg, TaskFrame.Fib, map_neg])

/-- The transported frame's task relation is the original one, reindexed by `e.symm`. -/
@[simp]
theorem FrameOver.map_taskRel (F : FrameOver D) (e : ↑D ≃+o ↑E) (w : F.WorldState) (d : ↑E)
    (u : F.WorldState) : (FrameOver.map F e).TaskRel w d u ↔ F.TaskRel w (e.symm d) u :=
  FrameOver.ofReflective_taskRel

/--
Transport a task model along `e`. The valuation is carried over verbatim: `FrameOver.map` leaves
`WorldState` unchanged, so `M.valuation` already has the right type.
-/
def TaskModel.map {F : FrameOver D} (M : TaskModel F.toTaskFrame) (e : ↑D ≃+o ↑E) :
    TaskModel (FrameOver.map F e).toTaskFrame where
  valuation := M.valuation

/--
Push a history forward along `e`: the domain and states are reindexed by `e.symm`.
-/
def PartialHistory.map {F : FrameOver D} (τ : PartialHistory F.toTaskFrame) (e : ↑D ≃+o ↑E) :
    PartialHistory (FrameOver.map F e).toTaskFrame where
  domain := fun n => τ.domain (e.symm n)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    exact ⟨e t, by simpa using ht⟩
  states := fun n h => τ.states (e.symm n) h
  respects_task := by
    intro s t hs ht
    have := τ.respects_task (e.symm s) (e.symm t) hs ht
    refine (FrameOver.map_taskRel F e _ _ _).mpr ?_
    show F.TaskRel _ (e.symm (t - s)) _
    simpa [map_sub] using this

/-- Push a world history forward along `e`. Totality is read off at `e.symm n`. -/
def WorldHistory.map {F : FrameOver D} (τ : WorldHistory F.toTaskFrame) (e : ↑D ≃+o ↑E) :
    WorldHistory (FrameOver.map F e).toTaskFrame :=
  ⟨PartialHistory.map τ.val e, fun n => τ.property (e.symm n)⟩

/--
Pull a history back along `e` from the transported frame to the original.

This is the direction `truthAt_map`'s `box` case needs: `□` quantifies over histories of the
*ambient* frame, so the forward direction is handed a `PartialHistory (FrameOver.map F e).toTaskFrame` and must
produce a `PartialHistory F`.
-/
def PartialHistory.comap {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ' : PartialHistory (FrameOver.map F e).toTaskFrame) : PartialHistory F.toTaskFrame where
  domain := fun t => σ'.domain (e t)
  nonempty_domain := by
    obtain ⟨n, hn⟩ := σ'.nonempty_domain
    exact ⟨e.symm n, by simpa using hn⟩
  states := fun t h => σ'.states (e t) h
  respects_task := by
    intro s t hs ht
    have := σ'.respects_task (e s) (e t) hs ht
    have h2 : (FrameOver.map F e).TaskRel (σ'.states (e s) hs) (e t - e s) (σ'.states (e t) ht) :=
      this
    show F.TaskRel _ (t - s) _
    have : e.symm (e t - e s) = t - s := by simp [map_sub]
    have h3 := (FrameOver.map_taskRel F e _ _ _).mp h2
    rw [this] at h3
    exact h3

/-- Pull a world history back along `e`. Totality is read off at `e t`. -/
def WorldHistory.comap {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) : WorldHistory F.toTaskFrame :=
  ⟨PartialHistory.comap e σ'.val, fun t => σ'.property (e t)⟩

/--
Two world histories over corresponding frames agree pointwise under `e`.

Because `(FrameOver.map F e).WorldState` is **definitionally** `F.WorldState`, this is an
ordinary non-dependent equation between two `F.WorldState` terms.
-/
def Aligned {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) : Prop :=
  ∀ n : ↑E, σ'.state n = σ.state (e.symm n)

/-- A world history is aligned with its own forward transport, definitionally. -/
theorem aligned_map {F : FrameOver D} (e : ↑D ≃+o ↑E) (τ : WorldHistory F.toTaskFrame) :
    Aligned e τ (τ.map e) :=
  fun _ => rfl

/--
A pulled-back world history is aligned with the one it came from.

Unlike `aligned_map` this is not definitional: the state equation sits at `e (e.symm n)` rather
than `n`, and is transported along `e.apply_symm_apply`.
-/
theorem aligned_comap {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) :
    Aligned e (WorldHistory.comap e σ') σ' :=
  fun n => (congrArg σ'.state (e.apply_symm_apply n)).symm

/--
**The frame transport is a truth correspondence.** `Aligned e` is the relation, `e` (as an order
isomorphism) the time reindexing, and the two existence witnesses are `WorldHistory.map` (forward)
and `WorldHistory.comap` (backward).

The `atom` field is the state agreement of `Aligned` at one time, with `e.symm_apply_apply`
bridging `e.symm (e t)` and `t`.
-/
def alignedCorr {F : FrameOver D} (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) :
    TruthCorr M (TaskModel.map M e) where
  dur := e.toOrderIso
  Rel := Aligned e
  atom := by
    intro σ σ' ha t p
    show M.valuation (σ.state t) p ↔ M.valuation (σ'.state (e t)) p
    rw [ha (e t), e.symm_apply_apply]
  fwd := fun σ => ⟨σ.map e, aligned_map e σ⟩
  bwd := fun σ' => ⟨WorldHistory.comap e σ', aligned_comap e σ'⟩

/--
**Truth transfers across the frame transport.** For aligned world histories `σ` and `σ'`, `φ` holds at
`t` in `M` along `σ` exactly when it holds at `e t` in `M.map e` along `σ'`.

This is `Truth.truthAt_of_truthCorr` at the instance `alignedCorr e M`; the six-case induction
lives there, generalised over both histories and the time exactly as this theorem's statement is.
Statement unchanged (arbitrary aligned pair), so `validZTime_iff_validInt` is untouched.
-/
theorem truthAt_map {F : FrameOver D} (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : Formula) :
    ∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame),
      Aligned e σ σ' →
      ∀ t : ↑D, (TruthAt M σ t φ ↔ TruthAt (TaskModel.map M e) σ' (e t) φ) :=
  fun σ σ' ha t => Truth.truthAt_of_truthCorr (alignedCorr e M) φ σ σ' ha t

/--
A formula is **`ℤ`-valid** if it is true in every model over a `ℤ`-frame, at every world
history, at every time.

This is `ValidZTime` with the carrier quantifier collapsed to the single carrier `ℤ`. All
eight instance binders of `ValidZTime` vanish here: `ℤ` supplies every one of them from
Mathlib with no instance work.
-/
def ValidInt (φ : Formula) : Prop :=
  ∀ (F : FrameOver intOrder) (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
    TruthAt M τ t φ

/--
**Carrier normalization.** Quantifying over every discrete duration carrier is the same as
quantifying over `ℤ` alone.

The forward direction is a single instantiation: `ℤ` discharges the whole `ValidZTime` binder
bundle, so `h F hF M τ t` is the proof.

The reverse direction is where the work is. Given an arbitrary discrete carrier `D`,
`DurationClassification.lean`'s `intIso : D ≃+o ℤ` normalizes it, `FrameOver.map` /
`TaskModel.map` / `WorldHistory.map` carry the model across, and `truthAt_map` carries truth
back. Note the transfer must be an *additive* order isomorphism:
durations add, so the order-only `orderIsoIntOfLinearSuccPredArch` could not be used here.

`ValidZTime`'s `PredOrder`/`IsPredArchimedean` binders go unused — `intIso` needs only the
successor half.
-/
theorem validZTime_iff_validInt (φ : Formula) : ValidZTime φ ↔ ValidInt φ := by
  constructor
  · intro h F M τ t
    exact h F.toTaskFrame (TaskFrame.isZTime_of_instances _) M τ t
  · intro h F hF M τ t
    sat_intro hF
    -- Ascribe the target at `↑intOrder`, not at `ℤ`: the transport's `E` is a `TemporalOrder`,
    -- and Lean cannot invert `↑E ≟ ℤ` to recover `E := intOrder` on its own.
    let e : ↑F.Duration ≃+o ↑intOrder := intIso
    refine (truthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M φ τ
      (WorldHistory.map τ e) (aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ)
      t).mpr ?_
    exact h (FrameOver.map F.toFibre e) (TaskModel.map (F := F.toFibre) M e)
      (WorldHistory.map τ e) (e t)

end FormalSystem.Semantics
