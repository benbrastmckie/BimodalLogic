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
`ParamTaskFrame`, `TaskModel`, `WorldHistory`, `TruthAt` — along an arbitrary ordered-group
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
equation between two `F.WorldState` terms, because `(ParamTaskFrame.map F e).WorldState` is
*definitionally* `F.WorldState`. Its one genuine transport is discharged by the tree's existing
`WorldHistory.states_eq_of_time_eq`. Do not replace `Aligned` with an `Equiv`.

## Recorded tactic traps

Two measured failures, recorded so a future editor does not re-hit them:

* `simpa` does **not** close `(WorldHistory.comap e ρ').domain s` from `ρ'.domain (e s)`. The
  equality is *definitional* and `simp` normalizes straight past it. Use the bare term
  `fun s => hρ' (e s)` (`truthAt_map`, `box` case).
* `linarith` does not fire on the bare `AddCommGroup` + `LinearOrder` bundle these lemmas run
  on — there is no ring structure. (This one bites in `DurationClassification.lean`'s
  `succ_eq_add_succ_zero`, not here, but it is the same binder bundle.)

## Main results

- `ParamTaskFrame.map`: transport a task frame along `e : D ≃+o E`, all seven fields.
- `TaskModel.map`, `WorldHistory.map`, `WorldHistory.comap`: the model and history transports.
- `Aligned`, `aligned_map`, `aligned_comap`, `isTotal_map`: the `HEq`-free correspondence
  between a history and its transport.
- `truthAt_map`: `TruthAt M σ t φ ↔ TruthAt (M.map e) σ' (e t) φ` for aligned `σ`, `σ'`.
- `ValidInt`: validity over `ℤ`-frames only.
- `validDiscrete_iff_validInt`: **carrier normalization** — `ValidDiscrete φ ↔ ValidInt φ`.
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {D E : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E]

/--
Transport a task frame along an ordered-group isomorphism of duration types.

The world states are carried over unchanged — only the duration index of `TaskRel` moves, by
pulling back along `e.symm`. Each of the seven fields is then the original field composed with
`e.symm`, with `map_add`/`map_neg`/`map_sub` and `map_le_map_iff`/`map_lt_map_iff` supplying the
compatibility.

The *Spherical* field is the cheapest of the interesting ones rather than the most expensive:
under an ordered-group isomorphism the fiber and segment predicates (`ParamTaskFrame.Fib`,
`ParamTaskFrame.Seg`) pick out the *identical* subsets of `WorldState`, so `F.spherical` is handed
back the **same** directed family. No directedness argument is reconstructed.
-/
def ParamTaskFrame.map (F : ParamTaskFrame D) (e : D ≃+o E) : ParamTaskFrame E where
  WorldState := F.WorldState
  nonempty := F.nonempty
  TaskRel := fun w d u => F.TaskRel w (e.symm d) u
  nullity_identity := by
    intro w u
    simpa using F.nullity_identity w u
  comp := by
    intro w v x y hx hy
    have hx' : (0 : D) ≤ e.symm x := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
    have hy' : (0 : D) ≤ e.symm y := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
    have := F.comp w v (e.symm x) (e.symm y) hx' hy'
    simpa [map_add] using this
  converse := by
    intro w d u
    simpa [map_neg] using F.converse w (e.symm d) u
  serial := by
    intro w x hx
    have hx' : (0 : D) ≤ e.symm x := by
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
  spherical := by
    -- `F.spherical` is handed the *identical* directed family: `Seg`/`Fib` under `e` pick out
    -- the same subsets of `F.WorldState`, so only the duration witnesses need translating.
    intro S hS hmem
    refine F.spherical S hS ?_
    intro s hs
    obtain ⟨hfs, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hfs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · exact Or.inl ⟨w, e.symm x, rfl⟩
    · refine Or.inr ⟨w, v, e.symm x, e.symm y, ?_, ?_, ?_⟩
      · simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
      · simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
      · simp [ParamTaskFrame.Seg, ParamTaskFrame.Fib, map_neg]

/--
Transport a task model along `e`. The valuation is carried over verbatim: `ParamTaskFrame.map` leaves
`WorldState` unchanged, so `M.valuation` already has the right type.
-/
def TaskModel.map {F : ParamTaskFrame D} (M : TaskModel F) (e : D ≃+o E) :
    TaskModel (ParamTaskFrame.map F e) where
  valuation := M.valuation

/--
Push a history forward along `e`: the domain and states are reindexed by `e.symm`.
-/
def WorldHistory.map {F : ParamTaskFrame D} (τ : WorldHistory F) (e : D ≃+o E) :
    WorldHistory (ParamTaskFrame.map F e) where
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
`WorldHistory F ≃ WorldHistory (ParamTaskFrame.map F e)` — does not survive contact with the `states`
field, which is *dependent*: it is indexed by a proof of `domain`. Round-tripping `map` and
`comap` therefore forces a dependent structure equality and degenerates into `HEq` wrangling.

`Aligned` sidesteps this. Because `(ParamTaskFrame.map F e).WorldState` is **definitionally**
`F.WorldState`, the field `st` is an ordinary non-dependent equation between two `F.WorldState`
terms, and its only genuine transport (in `aligned_comap`) is discharged by the tree's existing
`WorldHistory.states_eq_of_time_eq`. No `HEq` appears anywhere in this module; an `HEq` showing
up is the signal that the forbidden `Equiv` route was taken.
-/
structure Aligned {F : ParamTaskFrame D} (e : D ≃+o E)
    (σ : WorldHistory F) (σ' : WorldHistory (ParamTaskFrame.map F e)) : Prop where
  /-- The two domains correspond under `e.symm`. -/
  dom : ∀ n, σ'.domain n ↔ σ.domain (e.symm n)
  /-- The two state assignments agree at corresponding times. -/
  st : ∀ (n : E) (h' : σ'.domain n) (h : σ.domain (e.symm n)),
        σ'.states n h' = σ.states (e.symm n) h

/-- A history is aligned with its own forward transport, definitionally. -/
theorem aligned_map {F : ParamTaskFrame D} (e : D ≃+o E) (τ : WorldHistory F) :
    Aligned e τ (WorldHistory.map τ e) :=
  ⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩

/-- Totality transfers across an alignment. -/
theorem isTotal_map {F : ParamTaskFrame D} (e : D ≃+o E) {σ : WorldHistory F}
    {σ' : WorldHistory (ParamTaskFrame.map F e)} (ha : Aligned e σ σ') (h : σ.IsTotal) :
    σ'.IsTotal := fun n => (ha.dom n).mpr (h _)

/--
Pull a history back along `e` from the transported frame to the original.

This is the direction `truthAt_map`'s `box` case needs: `□` quantifies over histories of the
*ambient* frame, so the forward direction is handed a `WorldHistory (ParamTaskFrame.map F e)` and must
produce a `WorldHistory F`.
-/
def WorldHistory.comap {F : ParamTaskFrame D} (e : D ≃+o E)
    (σ' : WorldHistory (ParamTaskFrame.map F e)) : WorldHistory F where
  domain := fun t => σ'.domain (e t)
  nonempty_domain := by
    obtain ⟨n, hn⟩ := σ'.nonempty_domain
    exact ⟨e.symm n, by simpa using hn⟩
  states := fun t h => σ'.states (e t) h
  respects_task := by
    intro s t hs ht
    have := σ'.respects_task (e s) (e t) hs ht
    have h2 : (ParamTaskFrame.map F e).TaskRel (σ'.states (e s) hs) (e t - e s) (σ'.states (e t) ht) :=
      this
    show F.TaskRel _ (t - s) _
    have : e.symm (e t - e s) = t - s := by simp [map_sub]
    simpa [ParamTaskFrame.map, this] using h2
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
theorem aligned_comap {F : ParamTaskFrame D} (e : D ≃+o E)
    (σ' : WorldHistory (ParamTaskFrame.map F e)) : Aligned e (WorldHistory.comap e σ') σ' := by
  constructor
  · intro n
    show σ'.domain n ↔ σ'.domain (e (e.symm n))
    simp
  · intro n h' h
    show σ'.states n h' = σ'.states (e (e.symm n)) h
    exact WorldHistory.states_eq_of_time_eq σ' n (e (e.symm n)) (by simp) h' h

/--
**Truth transfers across the frame transport.** For aligned histories `σ` and `σ'`, `φ` holds at
`t` in `M` along `σ` exactly when it holds at `e t` in `M.map e` along `σ'`.

The induction is on `φ`, generalizing over **both** histories and the time. That generalization
is exactly what makes the two hard cases go through: `box` swaps the history (it quantifies over
all histories of the ambient frame, so the forward direction consumes `WorldHistory.comap`), and
`untl`/`snce` move the time. `box` is the only case that touches `comap`; `untl` and `snce` are
pure order transfer, riding on `map_lt_map_iff`.

Trap, recorded: in the `box` forward case, `(WorldHistory.comap e ρ').domain s` follows from
`ρ'.domain (e s)` **definitionally**, and `simpa` normalizes past it and fails. The bare term
`fun s => hρ' (e s)` is the proof.
-/
theorem truthAt_map {F : ParamTaskFrame D} (e : D ≃+o E) (M : TaskModel F) (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory (ParamTaskFrame.map F e)), Aligned e σ σ' →
      ∀ t : D, (TruthAt M σ t φ ↔ TruthAt (TaskModel.map M e) σ' (e t) φ) := by
  induction φ with
  | atom p =>
    intro σ σ' ha t
    constructor
    · rintro ⟨ht, hv⟩
      have ht' : σ'.domain (e t) := (ha.dom (e t)).mpr (by simpa using ht)
      refine ⟨ht', ?_⟩
      have := ha.st (e t) ht' (by simpa using ht)
      show (TaskModel.map M e).valuation (σ'.states (e t) ht') p
      rw [this]
      show M.valuation (σ.states (e.symm (e t)) _) p
      rw [σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ ht]
      exact hv
    · rintro ⟨ht', hv⟩
      have ht : σ.domain t := by
        have := (ha.dom (e t)).mp ht'
        simpa using this
      refine ⟨ht, ?_⟩
      have heq := ha.st (e t) ht' (by simpa using ht)
      rw [heq] at hv
      rw [σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ ht] at hv
      exact hv
  | bot => intro σ σ' ha t; exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    intro σ σ' ha t
    exact imp_congr (ihψ σ σ' ha t) (ihχ σ σ' ha t)
  | box ψ ih =>
    intro σ σ' ha t
    constructor
    · intro h ρ' hρ'
      -- TRAP: `simpa` fails here; `(comap e ρ').domain s` is *definitionally* `ρ'.domain (e s)`.
      exact (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp
        (h _ (fun s => hρ' (e s)))
    · intro h ρ hρ
      exact (ih ρ (WorldHistory.map ρ e) (aligned_map e ρ) t).mpr
        (h _ (isTotal_map e (aligned_map e ρ) hρ))
  | untl ψ χ ihψ ihχ =>
    intro σ σ' ha t
    constructor
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e s, (map_lt_map_iff e).mpr hts, (ihχ σ σ' ha s).mp hχ, ?_⟩
      intro r htr hrs
      have hr : t < e.symm r := by simpa using (map_lt_map_iff e.symm).mpr htr
      have hr2 : e.symm r < s := by simpa using (map_lt_map_iff e.symm).mpr hrs
      have := (ihψ σ σ' ha (e.symm r)).mp (hψ _ hr hr2)
      simpa using this
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e.symm s, ?_, ?_, ?_⟩
      · simpa using (map_lt_map_iff e.symm).mpr hts
      · refine (ihχ σ σ' ha (e.symm s)).mpr ?_; simpa using hχ
      · intro r htr hrs
        refine (ihψ σ σ' ha r).mpr (hψ (e r) ((map_lt_map_iff e).mpr htr) ?_)
        simpa using (map_lt_map_iff e).mpr hrs
  | snce ψ χ ihψ ihχ =>
    intro σ σ' ha t
    constructor
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e s, (map_lt_map_iff e).mpr hts, (ihχ σ σ' ha s).mp hχ, ?_⟩
      intro r hsr hrt
      have hr : s < e.symm r := by simpa using (map_lt_map_iff e.symm).mpr hsr
      have hr2 : e.symm r < t := by simpa using (map_lt_map_iff e.symm).mpr hrt
      have := (ihψ σ σ' ha (e.symm r)).mp (hψ _ hr hr2)
      simpa using this
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e.symm s, ?_, ?_, ?_⟩
      · simpa using (map_lt_map_iff e.symm).mpr hts
      · refine (ihχ σ σ' ha (e.symm s)).mpr ?_; simpa using hχ
      · intro r hsr hrt
        refine (ihψ σ σ' ha r).mpr (hψ (e r) ?_ ((map_lt_map_iff e).mpr hrt))
        simpa using (map_lt_map_iff e).mpr hsr

/--
A formula is **`ℤ`-valid** if it is true in every model over a `ℤ`-frame, at every total
history, at every time.

This is `ValidDiscrete` with the carrier quantifier collapsed to the single carrier `ℤ`. All
eight instance binders of `ValidDiscrete` vanish here: `ℤ` supplies every one of them from
Mathlib with no instance work.
-/
def ValidInt (φ : Formula) : Prop :=
  ∀ (F : ParamTaskFrame ℤ) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : ℤ),
    TruthAt M τ t φ

/--
**Carrier normalization.** Quantifying over every discrete duration carrier is the same as
quantifying over `ℤ` alone.

The forward direction is a single instantiation: `ℤ` discharges the whole `ValidDiscrete` binder
bundle, so `h ℤ F M τ hτ t` is the proof.

The reverse direction is where the work is. Given an arbitrary discrete carrier `D`,
`DurationClassification.lean`'s `intIso : D ≃+o ℤ` normalizes it, `ParamTaskFrame.map` /
`TaskModel.map` / `WorldHistory.map` carry the model across, `isTotal_map` carries totality, and
`truthAt_map` carries truth back. Note the transfer must be an *additive* order isomorphism:
durations add, so the order-only `orderIsoIntOfLinearSuccPredArch` could not be used here.

`ValidDiscrete`'s `PredOrder`/`IsPredArchimedean` binders go unused — `intIso` needs only the
successor half.
-/
theorem validDiscrete_iff_validInt (φ : Formula) : ValidDiscrete φ ↔ ValidInt φ := by
  constructor
  · intro h F M τ hτ t
    exact h ℤ F M τ hτ t
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    let e : D ≃+o ℤ := intIso
    refine (truthAt_map e M φ τ (WorldHistory.map τ e) (aligned_map e τ) t).mpr ?_
    exact h (ParamTaskFrame.map F e) (TaskModel.map M e) (WorldHistory.map τ e)
      (isTotal_map e (aligned_map e τ) hτ) (e t)

end FormalSystem.Semantics
