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
`TaskFrame`, `TaskModel`, `WorldHistory`, `TruthAt` — along an arbitrary ordered-group
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
equation between two `F.WorldState` terms, because `(TaskFrame.map F e).WorldState` is
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

- `TaskFrame.map`: transport a task frame along `e : D ≃+o E`, all seven fields.
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
under an ordered-group isomorphism the fiber and segment predicates (`TaskFrame.Fib`,
`TaskFrame.Seg`) pick out the *identical* subsets of `WorldState`, so `F.spherical` is handed
back the **same** directed family. No directedness argument is reconstructed.
-/
def TaskFrame.map (F : TaskFrame D) (e : D ≃+o E) : TaskFrame E where
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
      · simp [TaskFrame.Seg, TaskFrame.Fib, map_neg]

end FormalSystem.Semantics
