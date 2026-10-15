/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Dynamics.SymbolicDynamics.Basic
import FormalSystem.Semantics.ShiftFiniteType

/-!
# The Dictionary against Mathlib's Forbidden-Pattern Subshift

`ShiftFiniteType.lean` identifies `H_F` over ℤ with the configurations of `(W, ⇒₁)` avoiding
every forbidden 2-block, in this repository's own vocabulary. This module says the same thing in
Mathlib's: the step-paths are exactly the configurations in
`SymbolicDynamics.FullShift.forbidden` of the patterns whose two values form a non-edge.

## Why this is a separate module

**Every declaration reachable from here measures `[propext, Classical.choice, Quot.sound]`**,
and that is a property of the API rather than of this file's proofs.
`Mathlib.Dynamics.SymbolicDynamics.Basic` is a `noncomputable section` whose
`Pattern.occursInAt` and `forbidden` both carry choice, and
the theorem below additionally needs double-negation elimination for the same reason
`mem_HF_iff_no_forbidden` does: `Forbidden` is a negation and `forbidden`'s membership condition
is another one, so recovering `F.step` from "no forbidden pattern occurs" is classical.

Keeping the Mathlib import confined to this one leaf module is what lets the rest of the cluster
— the choice-free chain, the effective toolkit, the extension theorem and the certificate — stay
measured and scrubbed. Nothing imports this file.

Mathlib's own doc list for that file advertises a `subshift_of_finite_type F`; no declaration of
that name exists in it. The bundling is therefore written out here rather than imported.

## Name resolution

`Mathlib.Dynamics.SymbolicDynamics.Basic` is a new-module-system file (`module` /
`public import` / `@[expose] public section`). Its names are written below under their full
`SymbolicDynamics.FullShift.` prefix, which is the form that resolves; an `open` of the namespace
is deliberately not used.

## `Inhabited`, as data

`Pattern` requires `[Inhabited A]` — its `condition` field says the configuration is `default`
off the support. `F.worldNonempty` is `Prop`-level, so deriving an `Inhabited F.WorldState` from
it would be `Classical.inhabited_of_nonempty`: a second, avoidable use of choice. The binder
below takes the inhabitant as **data** supplied by the caller instead.

## Main Definitions

- `FrameOver.nonEdgePatterns` — the forbidden patterns: supported on `{0, 1}`, with their two
  values a non-edge of `(W, ⇒₁)`

## Main Results

- `FrameOver.isStepPath_iff_mem_forbidden` — the dictionary: the bi-infinite step-paths are
  exactly Mathlib's forbidden-pattern subshift for `nonEdgePatterns`

## Tags

ztime · symbolic-dynamics · subshift · mathlib-dictionary
-/

namespace FormalSystem.Semantics

namespace FrameOver

open TaskFrame

/--
The forbidden patterns of the one-step graph, in Mathlib's sense: those supported on
`{0, 1} : Finset ℤ` whose two values form a forbidden 2-block — that is, a non-edge of
`(W, ⇒₁)`.

Names from `Mathlib.Dynamics.SymbolicDynamics.Basic` resolve only under their full
`SymbolicDynamics.FullShift.` prefix; see this module's docstring.
-/
def nonEdgePatterns (F : FrameOver intOrder) [Inhabited F.WorldState] :
    Set (SymbolicDynamics.FullShift.Pattern F.WorldState ℤ) :=
  {p | p.support = {0, 1} ∧ Forbidden F (p.config 0) (p.config 1)}

/--
**The dictionary.** A configuration is a bi-infinite step-path of `(W, ⇒₁)` exactly when it
avoids every pattern in `nonEdgePatterns F` — Mathlib's own forbidden-pattern presentation of a
subshift, at `G = ℤ`.

The `→` direction is direct: an occurrence of a pattern supported on `{0, 1}` at `g` pins
`f g` and `f (g + 1)` to the pattern's two values, which adjacency then contradicts.

The `←` direction realizes each would-be non-edge by an explicit pattern —
`fun g => if g = 0 then f n else if g = 1 then f (n + 1) else default`, whose `condition` field
is discharged from `g ∉ ({0, 1} : Finset ℤ)` — and reads the contradiction back.

**Measured `[propext, Classical.choice, Quot.sound]`.** This is a recorded measurement, not a
defect: see this module's docstring for the two independent sources (Mathlib's `noncomputable`
symbolic-dynamics API, and the double negation in the `←` direction). The choice-free
identification of the same set is `FrameOver.mem_HF_iff_adjacent_int`.
-/
theorem isStepPath_iff_mem_forbidden (F : FrameOver intOrder) [Inhabited F.WorldState]
    (f : ℤ → F.WorldState) :
    IsStepPath F f ↔ f ∈ SymbolicDynamics.FullShift.forbidden (nonEdgePatterns F) := by
  constructor
  · intro hstep p hp g hocc
    have h0 : f (g + 0) = p.config 0 := hocc 0 (by rw [hp.1]; decide)
    have h1 : f (g + 1) = p.config 1 := hocc 1 (by rw [hp.1]; decide)
    rw [add_zero] at h0
    exact hp.2 (h0 ▸ h1 ▸ hstep g)
  · intro hmem n
    by_contra hnot
    refine hmem
      { config := fun g => if g = 0 then f n else if g = 1 then f (n + 1) else default
        support := {0, 1}
        condition := fun g hg => by
          have hg0 : g ≠ 0 := by rintro rfl; exact hg (by decide)
          have hg1 : g ≠ 1 := by rintro rfl; exact hg (by decide)
          simp [hg0, hg1] }
      ⟨rfl, by rw [forbidden_def]; simpa using hnot⟩ n ?_
    intro h hh
    have hh' : h = 0 ∨ h = 1 := by simpa using hh
    rcases hh' with rfl | rfl <;> simp

end FrameOver

end FormalSystem.Semantics
