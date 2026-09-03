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

`ValidDiscrete` quantifies over *every* discrete duration carrier `D` — every nontrivial
successor-Archimedean ordered abelian group. This module shows that quantifier is redundant:
one carrier, `ℤ`, already decides it. The headline result is

  `validDiscrete_iff_validInt : ValidDiscrete φ ↔ ValidInt φ`

and the machinery that gets there is a generic transport of the whole semantic stack —
the frame, `TaskModel`, `WorldHistory`, `TruthAt` — along an arbitrary ordered-group
isomorphism `e : D ≃+o E`. The isomorphism that specializes it to `ℤ` is
`DurationClassification.lean`'s `intIso`.

Note the transport is stated for `≃+o`, an *additive order* isomorphism, not `≃o`. Durations
**add** — `TaskRel`'s Compositionality is stated at `x + y` — so an order-only isomorphism
cannot carry a frame across. This is why `orderIsoIntOfLinearSuccPredArch`, which fits the
`ValidDiscrete` binder bundle verbatim, is not the route; see the `archimedean_of_lub` docstring
in `Semantics/DurationClassification.lean` for the full recorded finding.

## Design decision: `Aligned`, not `Equiv`

There is no `WorldHistory F ≃ WorldHistory (F.map e)` here, and there deliberately is not one.
Round-tripping `WorldHistory.map` and `WorldHistory.comap` forces a *dependent* equality on the
`states` field — `states` is indexed by a proof of `domain`, so the two round-tripped fields do
not even have the same type until the domain equation is transported — and the proof degenerates
into `HEq` wrangling.

The `Prop`-valued relation `Aligned` avoids this entirely. `Aligned.st` is a **non-dependent**
equation between two `F.WorldState` terms, because `(FrameOver.map F e).WorldState` is
*definitionally* `F.WorldState`. Its one genuine transport is discharged by the tree's existing
`WorldHistory.states_eq_of_time_eq`. Do not replace `Aligned` with an `Equiv`.

`Aligned e` is, verbatim, the `Rel` field of a `Semantics.TruthCorr` (`alignedCorr` below): the
generic relational transport `Truth.truthAt_of_truthCorr` asks for a relation on histories, atomic
agreement on related pairs, and existence of a related total history in each direction — never
for an inverse. That is why no `Equiv` was ever needed, and why `truthAt_map` is now a one-line
instance of the generic lemma rather than its own induction.

## Recorded tactic traps

Two measured failures, recorded so a future editor does not re-hit them:

* `simpa` does **not** close `(WorldHistory.comap e ρ').domain s` from `ρ'.domain (e s)`. The
  equality is *definitional* and `simp` normalizes straight past it. Use the bare term
  `fun s => hρ' (e s)` (`alignedCorr.total_bwd`).
* `linarith` does not fire on the bare `AddCommGroup` + `LinearOrder` bundle these lemmas run
  on — there is no ring structure. (This one bites in `DurationClassification.lean`'s
  `succ_eq_add_succ_zero`, not here, but it is the same binder bundle.)

## Main results

- `FrameOver.map`: transport a task frame along `e : D ≃+o E`, all seven fields.
- `TaskModel.map`, `WorldHistory.map`, `WorldHistory.comap`: the model and history transports.
- `Aligned`, `aligned_map`, `aligned_comap`, `isTotal_map`: the `HEq`-free correspondence
  between a history and its transport.
- `alignedCorr`: `Aligned e` packaged as a `TruthCorr M (M.map e)`.
- `truthAt_map`: `TruthAt M σ t φ ↔ TruthAt (M.map e) σ' (e t) φ` for aligned `σ`, `σ'` —
  `Truth.truthAt_of_truthCorr` at `alignedCorr`.
- `ValidInt`: validity over `ℤ`-frames only.
- `validDiscrete_iff_validInt`: **carrier normalization** — `ValidDiscrete φ ↔ ValidInt φ`.
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

| field | what it uses | needs |
|---|---|---|
| `nullity_identity`, `converse` | `map_zero`, `map_neg` | a group hom |
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
pulling back along `e.symm`. Each of the seven fields is then the original field composed with
`e.symm`, with `map_add`/`map_neg`/`map_sub` and `map_le_map_iff`/`map_lt_map_iff` supplying the
compatibility.

The *Saturation* field is the cheapest of the interesting ones rather than the most expensive:
under an ordered-group isomorphism the fiber and segment predicates (`TaskFrame.Fib`,
`TaskFrame.Seg`) pick out the *identical* subsets of `WorldState`, so `F.saturation` is handed
back the **same** directed family. No directedness argument is reconstructed.
-/
def FrameOver.map (F : FrameOver D) (e : ↑D ≃+o ↑E) : FrameOver E where
  WorldState := F.WorldState
  worldNonempty := F.worldNonempty
  TaskRel := fun w d u => F.TaskRel w (e.symm d) u
  nullity_identity := by
    intro w u
    simpa using F.nullity_identity w u
  comp := by
    intro w v x y hx hy
    have hx' : (0 : ↑D) ≤ e.symm x := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
    have hy' : (0 : ↑D) ≤ e.symm y := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
    have := F.comp w v (e.symm x) (e.symm y) hx' hy'
    simpa [map_add] using this
  converse := by
    intro w d u
    simpa [map_neg] using F.converse w (e.symm d) u
  serial := by
    intro w x hx
    have hx' : (0 : ↑D) ≤ e.symm x := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
    exact F.serial w (e.symm x) hx'
  limit := by
    intro w u h
    refine F.limit w u ?_
    intro x hx
    obtain ⟨n, hn, hR⟩ := h (e x) (by simpa using (map_lt_map_iff e (a := 0) (b := x)).mpr hx)
    refine ⟨e.symm n, ?_, hR⟩
    have : |e.symm n| = e.symm |n| := (map_abs e.symm n).symm
    rw [this]
    have := (map_lt_map_iff e.symm (a := |n|) (b := e x)).mpr hn
    simpa using this
  saturation := by
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
      · simp [TaskFrame.Seg, TaskFrame.Fib, map_neg]

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
def WorldHistory.map {F : FrameOver D} (τ : WorldHistory F.toTaskFrame) (e : ↑D ≃+o ↑E) :
    WorldHistory (FrameOver.map F e).toTaskFrame where
  domain := fun n => τ.domain (e.symm n)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    exact ⟨e t, by simpa using ht⟩
  states := fun n h => τ.states (e.symm n) h
  respects_task := by
    intro s t hs ht
    have := τ.respects_task (e.symm s) (e.symm t) hs ht
    show F.TaskRel _ (e.symm (t - s)) _
    simpa [map_sub] using this
  convex := by
    intro x z hx hz y hxy hyz
    exact τ.convex (e.symm x) (e.symm z) hx hz (e.symm y)
      ((map_le_map_iff e.symm).mpr hxy) ((map_le_map_iff e.symm).mpr hyz)

/--
Two histories over corresponding frames agree pointwise under `e`.

**Why a relation and not an `Equiv`.** The obvious alternative — an equivalence
`WorldHistory F ≃ WorldHistory (FrameOver.map F e).toTaskFrame` — does not survive contact with the `states`
field, which is *dependent*: it is indexed by a proof of `domain`. Round-tripping `map` and
`comap` therefore forces a dependent structure equality and degenerates into `HEq` wrangling.

`Aligned` sidesteps this. Because `(FrameOver.map F e).WorldState` is **definitionally**
`F.WorldState`, the field `st` is an ordinary non-dependent equation between two `F.WorldState`
terms, and its only genuine transport (in `aligned_comap`) is discharged by the tree's existing
`WorldHistory.states_eq_of_time_eq`. No `HEq` appears anywhere in this module; an `HEq` showing
up is the signal that the forbidden `Equiv` route was taken.
-/
structure Aligned {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) : Prop where
  /-- The two domains correspond under `e.symm`. -/
  dom : ∀ n, σ'.domain n ↔ σ.domain (e.symm n)
  /-- The two state assignments agree at corresponding times. -/
  st : ∀ (n : ↑E) (h' : σ'.domain n) (h : σ.domain (e.symm n)),
        σ'.states n h' = σ.states (e.symm n) h

/-- A history is aligned with its own forward transport, definitionally. -/
theorem aligned_map {F : FrameOver D} (e : ↑D ≃+o ↑E) (τ : WorldHistory F.toTaskFrame) :
    Aligned e τ (WorldHistory.map τ e) :=
  ⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩

/-- Totality transfers across an alignment. -/
theorem isTotal_map {F : FrameOver D} (e : ↑D ≃+o ↑E) {σ : WorldHistory F.toTaskFrame}
    {σ' : WorldHistory (FrameOver.map F e).toTaskFrame} (ha : Aligned e σ σ') (h : σ.IsTotal) :
    σ'.IsTotal := fun n => (ha.dom n).mpr (h _)

/--
Pull a history back along `e` from the transported frame to the original.

This is the direction `truthAt_map`'s `box` case needs: `□` quantifies over histories of the
*ambient* frame, so the forward direction is handed a `WorldHistory (FrameOver.map F e).toTaskFrame` and must
produce a `WorldHistory F`.
-/
def WorldHistory.comap {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) : WorldHistory F.toTaskFrame where
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
    simpa [FrameOver.map, this] using h2
  convex := by
    intro x z hx hz y hxy hyz
    exact σ'.convex (e x) (e z) hx hz (e y)
      ((map_le_map_iff e).mpr hxy) ((map_le_map_iff e).mpr hyz)

/--
A pulled-back history is aligned with the one it came from.

Unlike `aligned_map` this is not definitional: the domain and state equations sit at
`e (e.symm n)` rather than `n`. The `dom` half is `simp`; the `st` half is exactly what the
tree's existing `WorldHistory.states_eq_of_time_eq` is for, and no new transport lemma is needed.
-/
theorem aligned_comap {F : FrameOver D} (e : ↑D ≃+o ↑E)
    (σ' : WorldHistory (FrameOver.map F e).toTaskFrame) : Aligned e (WorldHistory.comap e σ') σ' := by
  constructor
  · intro n
    show σ'.domain n ↔ σ'.domain (e (e.symm n))
    simp
  · intro n h' h
    show σ'.states n h' = σ'.states (e (e.symm n)) h
    exact WorldHistory.states_eq_of_time_eq σ' n (e (e.symm n)) (by simp) h' h

/--
**The frame transport is a truth correspondence.** `Aligned e` is the relation, `e` (as an order
isomorphism) the time reindexing, and the two totality witnesses are `WorldHistory.map` (forward,
with `isTotal_map`) and `WorldHistory.comap` (backward).

The `atom` field is the only place any real work happens: it is the domain/state agreement of
`Aligned` unfolded at one time, with `σ.states_eq_of_time_eq` bridging `e.symm (e t)` and `t`.

Trap, recorded: in `total_bwd`, `(WorldHistory.comap e σ').domain s` follows from
`σ'.domain (e s)` **definitionally**, and `simpa` normalizes past it and fails. The bare term
`fun s => hσ' (e s)` is the proof.
-/
def alignedCorr {F : FrameOver D} (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) :
    TruthCorr M (TaskModel.map M e) where
  dur := e.toOrderIso
  Rel := Aligned e
  atom := by
    intro σ σ' ha t p
    show (∃ h : σ.domain t, M.valuation (σ.states t h) p) ↔
      ∃ h' : σ'.domain (e t), M.valuation (σ'.states (e t) h') p
    constructor
    · rintro ⟨h, hv⟩
      have h' : σ'.domain (e t) := (ha.dom (e t)).mpr (by simpa using h)
      refine ⟨h', ?_⟩
      rw [ha.st (e t) h' (by simpa using h),
        σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ h]
      exact hv
    · rintro ⟨h', hv⟩
      have h : σ.domain t := by simpa using (ha.dom (e t)).mp h'
      refine ⟨h, ?_⟩
      rw [ha.st (e t) h' (by simpa using h),
        σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ h] at hv
      exact hv
  total_fwd := fun σ hσ =>
    ⟨WorldHistory.map σ e, isTotal_map e (aligned_map e σ) hσ, aligned_map e σ⟩
  total_bwd := fun σ' hσ' =>
    -- TRAP: `simpa` fails here; `(comap e σ').domain s` is *definitionally* `σ'.domain (e s)`.
    ⟨WorldHistory.comap e σ', fun s => hσ' (e s), aligned_comap e σ'⟩

/--
**Truth transfers across the frame transport.** For aligned histories `σ` and `σ'`, `φ` holds at
`t` in `M` along `σ` exactly when it holds at `e t` in `M.map e` along `σ'`.

This is `Truth.truthAt_of_truthCorr` at the instance `alignedCorr e M`; the six-case induction
lives there, generalised over both histories and the time exactly as this theorem's statement is.
Statement unchanged (arbitrary aligned pair), so `validDiscrete_iff_validInt` is untouched.
-/
theorem truthAt_map {F : FrameOver D} (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : Formula) :
    ∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame), Aligned e σ σ' →
      ∀ t : ↑D, (TruthAt M σ t φ ↔ TruthAt (TaskModel.map M e) σ' (e t) φ) :=
  fun σ σ' ha t => Truth.truthAt_of_truthCorr (alignedCorr e M) φ σ σ' ha t

/--
A formula is **`ℤ`-valid** if it is true in every model over a `ℤ`-frame, at every total
history, at every time.

This is `ValidDiscrete` with the carrier quantifier collapsed to the single carrier `ℤ`. All
eight instance binders of `ValidDiscrete` vanish here: `ℤ` supplies every one of them from
Mathlib with no instance work.
-/
def ValidInt (φ : Formula) : Prop :=
  ∀ (F : FrameOver intOrder) (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (_ : τ.IsTotal) (t : ℤ),
    TruthAt M τ t φ

/--
**Carrier normalization.** Quantifying over every discrete duration carrier is the same as
quantifying over `ℤ` alone.

The forward direction is a single instantiation: `ℤ` discharges the whole `ValidDiscrete` binder
bundle, so `h ℤ F M τ hτ t` is the proof.

The reverse direction is where the work is. Given an arbitrary discrete carrier `D`,
`DurationClassification.lean`'s `intIso : D ≃+o ℤ` normalizes it, `FrameOver.map` /
`TaskModel.map` / `WorldHistory.map` carry the model across, `isTotal_map` carries totality, and
`truthAt_map` carries truth back. Note the transfer must be an *additive* order isomorphism:
durations add, so the order-only `orderIsoIntOfLinearSuccPredArch` could not be used here.

`ValidDiscrete`'s `PredOrder`/`IsPredArchimedean` binders go unused — `intIso` needs only the
successor half.
-/
theorem validDiscrete_iff_validInt (φ : Formula) : ValidDiscrete φ ↔ ValidInt φ := by
  constructor
  · intro h F M τ hτ t
    exact ValidIn.apply_total h F.toTaskFrame
      (TaskFrame.isSuccArchDiscrete_of_instances _) M τ hτ t
  · intro h
    refine ValidIn.of_forall_total ?_
    intro F hF M τ hτ t
    sat_intro hF
    -- Ascribe the target at `↑intOrder`, not at `ℤ`: the transport's `E` is a `TemporalOrder`,
    -- and Lean cannot invert `↑E ≟ ℤ` to recover `E := intOrder` on its own.
    let e : ↑F.Duration ≃+o ↑intOrder := intIso
    refine (truthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M φ τ
      (WorldHistory.map τ e) (aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ)
      t).mpr ?_
    exact h (FrameOver.map F.toFibre e) (TaskModel.map (F := F.toFibre) M e)
      (WorldHistory.map τ e)
      (isTotal_map (D := F.Duration) (E := intOrder) e
        (aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ) hτ) (e t)

end FormalSystem.Semantics
