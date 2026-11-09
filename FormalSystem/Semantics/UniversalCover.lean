/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.OrientedForest
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.ForMathlib.Combinatorics.SimpleGraphAcyclic

/-!
# The universal cover of a doubly serial one-step relation

For a one-step relation `E : W → W → Prop` this module builds the **universal cover** of `E`
as a type of *reduced walks*, proves its own one-step relation is an oriented forest and doubly
serial, and proves the endpoint projection is surjective and `TwoWayBounded`. Composed with
`saturation_of_orientedForest` and `TwoWayBounded.plus_invariance_of_isZTime`, this makes the
cover a regular `FrameOver intOrder` along which L⁺ truth transfers from any regular base frame.

## The construction

A cover point is a reduced walk in the **undirected multigraph** underlying `E`, together with
the base point it starts from and the base state it ends at. A *move* traverses an edge of `E`
either forward (`E b c`, going `b → c`) or backward (`E c b`, going `b → c` against the edge).
A walk is **reduced** when no move immediately undoes the previous one.

`RWalk E a b m` is the type of reduced walks from `a` to `b` whose last move is recorded by
`m : Option (Bool × W)`: `none` for the empty walk, `some (true, x)` for a final forward move
`x → b`, and `some (false, x)` for a final backward move `x → b`. Reducedness is a *constructor
side condition on data already in the type* — extending by a forward move to `c` requires
`m ≠ some (false, c)`, and by a backward move out of `c` requires `m ≠ some (true, c)` — rather
than a predicate over a flat vertex list.

## The multigraph convention, and how the reducedness rule forces it

`fromRel` deduplicates parallel edges, so the convention has to be carried by the walk type:

* An **opposite-edge pair** `E u v` and `E v u` lifts to **two distinct edges**. From a point
  ending at `u`, the forward move along `E u v` lands on a point with last-move tag
  `some (true, u)`, while the backward move along `E v u` lands on a point with last-move tag
  `some (false, u)`. The tags differ, so the two targets are distinct cover points.
* A **loop** `E u u` lifts to a **ray**. A forward move along `E u u` has last-move tag
  `some (true, u)`, and the reducedness side condition on a further forward move forbids only
  `some (false, u)`, so the loop can be traversed forward indefinitely and never closes.

## Base points over all of `W`

Base points are taken over **all** of `W`, not one per connected component. The cover is then a
redundant disjoint union of the components' universal covers: a disjoint union of forests is a
forest, double seriality is a per-point property, and the endpoint projection is surjective
because `w` is the endpoint of the length-zero walk at `w`. Every connectivity,
component-quotient, base-point-choice and `Classical.choice` obligation disappears from the
construction at no cost to the two consumers.

## Why not Mathlib's `Quiver/Covering.lean`

That file defines the covering *property* (`Prefunctor.IsCovering`, star/costar bijectivity) and
constructs nothing; at this pin there is no reduced-path predicate, no universal cover of a
quiver or a `SimpleGraph`, and no `Quiver` instance on `Digraph`. Routing through it would still
leave `(SimpleGraph.fromRel ·).IsAcyclic` — the actual `acyclic` field of `IsOrientedForest` —
owed in full, since `Quiver.arborescenceMk` yields `Quiver.Arborescence` rather than acyclicity
of the `fromRel` graph. Its one genuine contribution is kept: the positive and negative
orientation tags of `Quiver.Symmetrify` confirm that the `Bool` direction tag used here is the
standard encoding.

## Main definitions

* `RWalk` — reduced walks, indexed by origin, endpoint and last move
* `CoverPt` — a bundled cover point
* `RWalk.length`, `CoverPt.length` — the number of moves
* `RWalk.parent`, `CoverPt.parent` — drop the last move (the empty walk is its own parent)
* `CoverStep` — the cover's one-step relation

## Notes

`cases` on `CoverStep` happens in exactly one place, `coverStep_cases`; every later proof reads
that lemma instead, so no `HEq` ever reaches a downstream goal. `RWalk.length` is defined by
structural recursion over a three-index inductive and therefore does **not** reduce by `rfl` at
its constructors; the three `@[simp]` equation lemmas beside it restore those reductions, and
downstream proofs use `simp` rather than `rfl` for a length equation. `RWalk.parent`, being
non-recursive, does reduce by `rfl`.
-/

namespace FormalSystem.Semantics

variable {W : Type}

/-! ## The carrier -/

/--
A **reduced walk** in the undirected multigraph underlying `E`, from `a` to `b`, whose last move
is recorded by the third index: `none` for the empty walk, `some (true, x)` for a final forward
move `x → b`, and `some (false, x)` for a final backward move `x → b`.

The reducedness side conditions `hred` are exactly "the new move does not undo the last one":
extending by a forward move to `c` is forbidden when the previous move was the backward move
`c → b` (which traversed the same edge `E b c`), and symmetrically for `bwd`.
-/
inductive RWalk (E : W → W → Prop) : W → W → Option (Bool × W) → Type
  /-- The empty walk at a base point. -/
  | nil (a : W) : RWalk E a a none
  /-- Extend by a forward move along `E b c`, unless the last move was the backward move
  `c → b`. -/
  | fwd {a b : W} {m : Option (Bool × W)} (p : RWalk E a b m) {c : W} (h : E b c)
      (hred : m ≠ some (false, c)) : RWalk E a c (some (true, b))
  /-- Extend by a backward move along `E c b`, unless the last move was the forward move
  `c → b`. -/
  | bwd {a b : W} {m : Option (Bool × W)} (p : RWalk E a b m) {c : W} (h : E c b)
      (hred : m ≠ some (true, c)) : RWalk E a c (some (false, b))

/-- A **cover point**: a reduced walk together with its origin, its endpoint and its last move. -/
structure CoverPt (E : W → W → Prop) : Type where
  /-- The base point the walk starts from. -/
  origin : W
  /-- The base state the walk ends at — the value of the projection to the base. -/
  endpt : W
  /-- The last move of the walk, `none` exactly for the empty walk. -/
  last : Option (Bool × W)
  /-- The walk itself. -/
  walk : RWalk E origin endpt last

namespace RWalk

/-- The number of moves in a reduced walk. -/
def length {E : W → W → Prop} : ∀ {a b : W} {m : Option (Bool × W)}, RWalk E a b m → ℕ
  | _, _, _, .nil _ => 0
  | _, _, _, .fwd p _ _ => p.length + 1
  | _, _, _, .bwd p _ _ => p.length + 1

@[simp] theorem length_nil {E : W → W → Prop} (a : W) :
    (RWalk.nil a : RWalk E a a none).length = 0 := by simp [length]

@[simp] theorem length_fwd {E : W → W → Prop} {a b : W} {m : Option (Bool × W)}
    (p : RWalk E a b m) {c : W} (h : E b c) (hred : m ≠ some (false, c)) :
    (p.fwd h hred).length = p.length + 1 := by simp [length]

@[simp] theorem length_bwd {E : W → W → Prop} {a b : W} {m : Option (Bool × W)}
    (p : RWalk E a b m) {c : W} (h : E c b) (hred : m ≠ some (true, c)) :
    (p.bwd h hred).length = p.length + 1 := by simp [length]

/-- Drop the last move. The empty walk is its own parent, which is what makes the rank
inequality of `SimpleGraph.isAcyclic_of_rank_parent` hold without a side condition. -/
def parent {E : W → W → Prop} : ∀ {a b : W} {m : Option (Bool × W)}, RWalk E a b m → CoverPt E
  | _, _, _, .nil c => ⟨c, c, none, .nil c⟩
  | _, _, _, .fwd p _ _ => ⟨_, _, _, p⟩
  | _, _, _, .bwd p _ _ => ⟨_, _, _, p⟩

end RWalk

namespace CoverPt

/-- The number of moves of a cover point's walk — the rank fed to the acyclicity criterion. -/
def length {E : W → W → Prop} (x : CoverPt E) : ℕ := x.walk.length

/-- Drop the last move of a cover point's walk — the parent map fed to the acyclicity
criterion. -/
def parent {E : W → W → Prop} (x : CoverPt E) : CoverPt E := x.walk.parent

@[simp] theorem length_mk {E : W → W → Prop} {a b : W} {m : Option (Bool × W)}
    (p : RWalk E a b m) : (CoverPt.mk a b m p).length = p.length := rfl

@[simp] theorem parent_mk {E : W → W → Prop} {a b : W} {m : Option (Bool × W)}
    (p : RWalk E a b m) : (CoverPt.mk a b m p).parent = p.parent := rfl

instance instNonempty {E : W → W → Prop} [h : Nonempty W] : Nonempty (CoverPt E) :=
  h.elim fun w => ⟨⟨w, w, none, RWalk.nil w⟩⟩

end CoverPt

/--
The cover's **one-step relation**, as an inductive rather than an equation between cover points
so that `HEq` stays out of every subsequent proof.

`up` lengthens the walk by a forward move; `down` shortens it, reading off the backward move the
longer walk ends with. Both project to a single `E`-step on endpoints — `E b c` in the first case
and `E c b` in the second, where the longer walk's endpoint is `c` — which is what makes the
endpoint map a morphism of one-step relations.

`cases` on this relation is confined to `coverStep_cases` below; every other proof in this module
and downstream reads that lemma instead, so the three indices of the two endpoints never surface
as stray index equations.
-/
inductive CoverStep (E : W → W → Prop) : CoverPt E → CoverPt E → Prop
  /-- Extend the source by a forward move. -/
  | up {a b : W} {m : Option (Bool × W)} (p : RWalk E a b m) {c : W} (h : E b c)
      (hred : m ≠ some (false, c)) :
      CoverStep E ⟨a, b, m, p⟩ ⟨a, c, some (true, b), RWalk.fwd p h hred⟩
  /-- Drop the source's final backward move. -/
  | down {a b : W} {m : Option (Bool × W)} (p : RWalk E a b m) {c : W} (h : E c b)
      (hred : m ≠ some (true, c)) :
      CoverStep E ⟨a, c, some (false, b), RWalk.bwd p h hred⟩ ⟨a, b, m, p⟩

end FormalSystem.Semantics
