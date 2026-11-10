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
* `coverFrame` — the cover presented as a regular `FrameOver intOrder`

## Main results

* `coverStep_cases` — the structural case lemma, and the single `cases`-on-`CoverStep` site
* `coverStep_loopFree`, `coverStep_oppFree`, `coverStep_acyclic` — the three oriented-forest
  obligations, the third through `SimpleGraph.isAcyclic_of_rank_parent` with the walk length as the
  rank and drop-the-last-move as the parent map
* `coverStep_isOrientedForest` — the three assembled
* `exists_coverStep_fwd`, `exists_coverStep_bwd` — the two one-step lifts, which is where
  "directed walks are reduced paths" becomes a theorem
* `coverStep_serial_fwd`, `coverStep_serial_bwd` — double seriality of the cover
* `endpt_surjective` — the endpoint projection is surjective (axiom-free)
* `endpt_iter`, `exists_iter_coverStep_fwd`, `exists_iter_coverStep_bwd` — the three iterated lifts
* `endpt_twoWayBounded` — the endpoint projection is `TwoWayBounded`
* `exists_orientedForest_cover` — **the headline**: every regular frame over `intOrder` has a
  regular cover frame whose endpoint projection is surjective and two-way bounded, with the L⁺
  truth transfer along it

## What is deliberately absent

**Unique path lifting is not stated**, and neither is any of the `Prefunctor.IsCovering`
machinery. `TwoWayBounded` has exactly two fields, `forth` and `step`, and
`TwoWayBounded.plus_invariance_of_isZTime` consumes those two plus `Function.Surjective`; unique
lifting is over-strong for that consumer, so stating it would cost the covering-property
machinery for nothing. It is addable later if a consumer needs it.

**Countability of the cover is not claimed.** The consumer's countable-model step runs *inside* the
cover and is a separate step; the cover must be taken before it.

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

/-! ## The structural lemma and the oriented-forest fields -/

/--
**The structural case lemma** — the single `cases`-on-`CoverStep` site in the development.

A cover step either *lengthens* by one, with the target's last-move tag recording a forward move
out of the source's endpoint and the target's parent equal to the source, or *shortens* by one,
with the source's last-move tag recording a backward move out of the target's endpoint and the
source's parent equal to the target. Either way the endpoints carry one `E`-step.

Every one of `coverStep_loopFree`, `coverStep_oppFree`, `coverStep_acyclic` and the
endpoint-iteration lemma is proved from this disjunction alone.
-/
theorem coverStep_cases {E : W → W → Prop} {x y : CoverPt E} (h : CoverStep E x y) :
    E x.endpt y.endpt ∧
      ((y.length = x.length + 1 ∧ y.last = some (true, x.endpt) ∧ y.parent = x) ∨
        (x.length = y.length + 1 ∧ x.last = some (false, y.endpt) ∧ x.parent = y)) := by
  cases h with
  | up p hE hred => exact ⟨hE, Or.inl ⟨by simp, rfl, rfl⟩⟩
  | down p hE hred => exact ⟨hE, Or.inr ⟨by simp, rfl, rfl⟩⟩

/-- A cover step projects to an `E`-step on endpoints. -/
theorem step_endpt_of_coverStep {E : W → W → Prop} {x y : CoverPt E} (h : CoverStep E x y) :
    E x.endpt y.endpt := (coverStep_cases h).1

/-- Dropping the last move never increases the length. -/
theorem parent_length_le {E : W → W → Prop} (x : CoverPt E) : x.parent.length ≤ x.length := by
  obtain ⟨a, b, m, p⟩ := x
  cases p with
  | nil => simp [RWalk.parent]
  | fwd q h hred => simp [RWalk.parent]
  | bwd q h hred => simp [RWalk.parent]

/-- **No loops in the cover**: both disjuncts of the structural lemma degenerate to a length
equal to its own successor. -/
theorem coverStep_loopFree {E : W → W → Prop} (x : CoverPt E) : ¬ CoverStep E x x := by
  intro h
  rcases (coverStep_cases h).2 with ⟨hl, _, _⟩ | ⟨hl, _, _⟩ <;> omega

/--
**No directed 2-cycles in the cover** — this is where the multigraph convention becomes a
theorem.

Of the four pairings of the structural lemma's disjuncts, the two same-side ones contradict on
length; the two cross pairings agree on length and contradict on the direction tag, since an
opposite-edge pair of the base lifts to two *distinct* cover edges whose targets carry different
tags.
-/
theorem coverStep_oppFree {E : W → W → Prop} (x y : CoverPt E) (h : CoverStep E x y) :
    ¬ CoverStep E y x := by
  intro h'
  rcases (coverStep_cases h).2 with ⟨hl, ht, _⟩ | ⟨hl, ht, _⟩ <;>
    rcases (coverStep_cases h').2 with ⟨hl', ht', _⟩ | ⟨hl', ht', _⟩
  · omega
  · rw [ht] at ht'; simp at ht'
  · rw [ht'] at ht; simp at ht
  · omega

/--
**The cover's underlying undirected graph is acyclic**, by `SimpleGraph.isAcyclic_of_rank_parent`
with the walk length as the rank and drop-the-last-move as the parent map.

The rank inequality is `parent_length_le` (the `nil` case is where the parent is its own parent),
and the adjacency hypothesis is the structural lemma read through `SimpleGraph.fromRel_adj`. No
cycle is ever mentioned.
-/
theorem coverStep_acyclic {E : W → W → Prop} :
    (SimpleGraph.fromRel (CoverStep E)).IsAcyclic := by
  refine SimpleGraph.isAcyclic_of_rank_parent CoverPt.length CoverPt.parent parent_length_le ?_
  intro x y hxy
  rw [SimpleGraph.fromRel_adj] at hxy
  obtain ⟨_, hst⟩ := hxy
  rcases hst with hst | hst
  · rcases (coverStep_cases hst).2 with ⟨hl, _, hp⟩ | ⟨hl, _, hp⟩
    · exact Or.inl ⟨hp, by omega⟩
    · exact Or.inr ⟨hp, by omega⟩
  · rcases (coverStep_cases hst).2 with ⟨hl, _, hp⟩ | ⟨hl, _, hp⟩
    · exact Or.inr ⟨hp, by omega⟩
    · exact Or.inl ⟨hp, by omega⟩

/-- **The cover is an oriented forest**: the three fields over the three preceding lemmas. -/
theorem coverStep_isOrientedForest {E : W → W → Prop} : IsOrientedForest (CoverStep E) where
  loopFree := coverStep_loopFree
  oppFree := coverStep_oppFree
  acyclic := coverStep_acyclic


/-! ## Double seriality and the two one-step lifts -/

/--
A cover point whose last move is the backward move `b → c` steps to its own parent, whose
endpoint is `b`.

This is the walk-destructuring half of the forward lift: `cases` on the *walk* (not on
`CoverStep`) is legitimate, and the last-move index `some (false, b)` already rules out `nil` and
`fwd`.
-/
theorem coverStep_parent_of_last_bwd {E : W → W → Prop} {o c b : W}
    (p : RWalk E o c (some (false, b))) :
    CoverStep E (CoverPt.mk o c (some (false, b)) p)
        (CoverPt.mk o c (some (false, b)) p).parent ∧
      (CoverPt.mk o c (some (false, b)) p).parent.endpt = b := by
  cases p with
  | bwd q h hred => exact ⟨CoverStep.down q h hred, rfl⟩

/-- A cover point whose last move is the forward move `b → c` is stepped into by its own parent,
whose endpoint is `b`. The mirror of `coverStep_parent_of_last_bwd`. -/
theorem coverStep_parent_of_last_fwd {E : W → W → Prop} {o c b : W}
    (p : RWalk E o c (some (true, b))) :
    CoverStep E (CoverPt.mk o c (some (true, b)) p).parent
        (CoverPt.mk o c (some (true, b)) p) ∧
      (CoverPt.mk o c (some (true, b)) p).parent.endpt = b := by
  cases p with
  | fwd q h hred => exact ⟨CoverStep.up q h hred, rfl⟩

/--
**The forward one-step lift** — the mathematical heart: every base edge out of a cover point's
endpoint lifts to a cover step out of that point.

The lift is **total**, and the case split says why: the one move the reducedness rule forbids is
precisely the move whose target is *already* a cover-neighbour. If the point's last move is not
the backward move out of the target, extend by `fwd` — admitted by that very hypothesis. If it
is, the point was built by `bwd` from a walk ending at the target, so `down` applies to its
parent, whose endpoint is the target.
-/
theorem exists_coverStep_fwd {E : W → W → Prop} (x : CoverPt E) {c : W} (h : E x.endpt c) :
    ∃ y : CoverPt E, CoverStep E x y ∧ y.endpt = c := by
  obtain ⟨o, b, m, p⟩ := x
  by_cases hlast : m = some (false, c)
  · subst hlast
    exact ⟨_, (coverStep_parent_of_last_bwd p).1, (coverStep_parent_of_last_bwd p).2⟩
  · exact ⟨⟨o, c, some (true, b), RWalk.fwd p h hlast⟩, CoverStep.up p h hlast, rfl⟩

/-- **The backward one-step lift**, by the mirrored case split on the forward-move tag. -/
theorem exists_coverStep_bwd {E : W → W → Prop} (x : CoverPt E) {c : W} (h : E c x.endpt) :
    ∃ y : CoverPt E, CoverStep E y x ∧ y.endpt = c := by
  obtain ⟨o, b, m, p⟩ := x
  by_cases hlast : m = some (true, c)
  · subst hlast
    exact ⟨_, (coverStep_parent_of_last_fwd p).1, (coverStep_parent_of_last_fwd p).2⟩
  · exact ⟨⟨o, c, some (false, b), RWalk.bwd p h hlast⟩, CoverStep.down p h hlast, rfl⟩

/-- **Forward seriality of the cover**, from the base relation's own forward seriality through
the forward lift. -/
theorem coverStep_serial_fwd {E : W → W → Prop} (hfwd : ∀ w, ∃ u, E w u) (x : CoverPt E) :
    ∃ y, CoverStep E x y := by
  obtain ⟨c, hc⟩ := hfwd x.endpt
  obtain ⟨y, hy, _⟩ := exists_coverStep_fwd x hc
  exact ⟨y, hy⟩

/-- **Backward seriality of the cover**, from the base relation's own backward seriality through
the backward lift. -/
theorem coverStep_serial_bwd {E : W → W → Prop} (hbwd : ∀ w, ∃ v, E v w) (x : CoverPt E) :
    ∃ y, CoverStep E y x := by
  obtain ⟨c, hc⟩ := hbwd x.endpt
  obtain ⟨y, hy, _⟩ := exists_coverStep_bwd x hc
  exact ⟨y, hy⟩

/-- **The endpoint projection is surjective**: the length-zero walk at `w` is the witness, which
is exactly what taking base points over all of `W` buys. -/
theorem endpt_surjective {E : W → W → Prop} :
    Function.Surjective (CoverPt.endpt : CoverPt E → W) :=
  fun w => ⟨⟨w, w, none, RWalk.nil w⟩, rfl⟩

/-! ## Iterated lifts and two-way boundedness -/

/-- The endpoint projection carries iterated cover steps to iterated base steps. -/
theorem endpt_iter {E : W → W → Prop} (n : ℕ) {x y : CoverPt E}
    (h : iter (CoverStep E) n x y) : iter E n x.endpt y.endpt := by
  induction n generalizing y with
  | zero =>
    have hxy : x = y := h
    exact congrArg CoverPt.endpt hxy
  | succ n ih =>
    obtain ⟨z, hz, hstep⟩ := h
    exact ⟨z.endpt, ih hz, step_endpt_of_coverStep hstep⟩

/-- **The iterated forward lift**: an `n`-step base walk out of a cover point's endpoint lifts to
an `n`-step cover walk out of that point. -/
theorem exists_iter_coverStep_fwd {E : W → W → Prop} (n : ℕ) :
    ∀ (x : CoverPt E) (v : W), iter E n x.endpt v →
      ∃ y : CoverPt E, iter (CoverStep E) n x y ∧ y.endpt = v := by
  induction n with
  | zero => intro x v h; exact ⟨x, rfl, h⟩
  | succ n ih =>
    intro x v h
    obtain ⟨z, hz, hstep⟩ := h
    obtain ⟨y', hy', hy'e⟩ := ih x z hz
    have hstep' : E y'.endpt v := by rw [hy'e]; exact hstep
    obtain ⟨y, hy, hye⟩ := exists_coverStep_fwd y' hstep'
    exact ⟨y, ⟨y', hy', hy⟩, hye⟩

/--
**The iterated backward lift**: an `n`-step base walk *into* a cover point's endpoint lifts to an
`n`-step cover walk into that point.

The one-step lift is applied **first** and the induction hypothesis **second**, at the lifted
predecessor — the order the right-appending shape of `iter` forces.
-/
theorem exists_iter_coverStep_bwd {E : W → W → Prop} (n : ℕ) :
    ∀ (x : CoverPt E) (v : W), iter E n v x.endpt →
      ∃ y : CoverPt E, iter (CoverStep E) n y x ∧ y.endpt = v := by
  induction n with
  | zero => intro x v h; exact ⟨x, rfl, h.symm⟩
  | succ n ih =>
    intro x v h
    obtain ⟨z, hz, hstep⟩ := h
    obtain ⟨y', hy', hy'e⟩ := exists_coverStep_bwd x hstep
    obtain ⟨y, hy, hye⟩ := ih y' v (by rw [hy'e]; exact hz)
    exact ⟨y, ⟨y', hy, hy'⟩, hye⟩

/--
**The cover frame** of a regular frame over `intOrder`: the `Saturation`-parameterised frame
constructor applied to the cover's one-step relation, its two seriality witnesses, and
`saturation_of_orientedForest` of the oriented-forest proof.

`FrameOver.ofStep` cannot present it: the cover carrier is infinite whenever the base has any
edge, and `ofStep`'s `[Finite W]` binder is consumed exactly to obtain *Saturation*.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
def coverFrame (F : FrameOver intOrder) [F.IsRegular] : FrameOver intOrder :=
  FrameOver.ofStepSat (CoverStep F.step)
    (coverStep_serial_fwd fun w => (F.serial w 1 zero_le_one).1)
    (coverStep_serial_bwd fun w => (F.serial w 1 zero_le_one).2)
    (saturation_of_orientedForest coverStep_isOrientedForest)

/-- The cover frame's task relation is the one generated by the cover's one-step relation. -/
theorem coverFrame_taskRel (F : FrameOver intOrder) [F.IsRegular] :
    (coverFrame F).TaskRel = ofStepRel (CoverStep F.step) :=
  FrameOver.ofStepSat_taskRel _ _ _ _

/-- The cover frame is regular. -/
instance coverFrame_isRegular (F : FrameOver intOrder) [F.IsRegular] :
    (coverFrame F).IsRegular :=
  FrameOver.ofStepSat_isRegular _ _ _ _

/--
**The endpoint projection is two-way bounded.**

`forth` is the endpoint-iteration lemma on the two sign-guarded conjuncts of `ofStepRel`, read
against the base's `taskRel_eq_iter`; `step` is the two iterated lifts, one per sign.
-/
theorem endpt_twoWayBounded (F : FrameOver intOrder) [F.IsRegular] :
    TwoWayBounded (F' := coverFrame F) (F := F) CoverPt.endpt := by
  constructor
  · intro a x b hab
    rw [coverFrame_taskRel] at hab
    rw [F.taskRel_eq_iter]
    exact ⟨fun hx => endpt_iter _ (hab.1 hx), fun hx => endpt_iter _ (hab.2 hx)⟩
  · intro a x v hv
    rw [F.taskRel_eq_iter] at hv
    rcases le_or_gt 0 x with hx | hx
    · have hx' : (0 : ℤ) ≤ x := hx
      obtain ⟨y, hy, hye⟩ := exists_iter_coverStep_fwd x.natAbs a v (hv.1 hx')
      refine ⟨y, ?_, hye⟩
      rw [coverFrame_taskRel]
      exact (ofStepRel_of_nonneg hx' a y).mpr hy
    · have hx' : x ≤ (0 : ℤ) := le_of_lt hx
      obtain ⟨y, hy, hye⟩ := exists_iter_coverStep_bwd x.natAbs a v (hv.2 hx')
      refine ⟨y, ?_, hye⟩
      rw [coverFrame_taskRel]
      exact (ofStepRel_of_nonpos hx' a y).mpr hy


/-! ## Assembly -/

open FormalSystem.PlusLanguage in
/--
**Every regular frame over `intOrder` has an oriented-forest cover with surjective, two-way
bounded endpoint projection, along which L⁺ truth transfers.**

The cover frame is `coverFrame F`; the projection is `CoverPt.endpt`; two-way boundedness is
`endpt_twoWayBounded` and surjectivity is `endpt_surjective`; and
`TwoWayBounded.plus_invariance_of_isZTime` supplies the history morphism together with the truth
biconditional.

No generation hypothesis and no doubly-serial-base hypothesis are taken: `FrameOver.taskRel_eq_iter`
already proves every regular frame over `intOrder` is generated by its one-step relation, and
`F.serial w 1 zero_le_one` is exactly the pair of seriality witnesses for `F.step`.

**Unique path lifting is deliberately not stated.** `plus_invariance_of_isZTime` consumes `forth`,
`step` and surjectivity and nothing else, so the covering-property machinery would cost the
module its weight for no consumer.
-/
theorem exists_orientedForest_cover (F : FrameOver intOrder) [F.IsRegular]
    (M : TaskModel F.toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' F, g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ :=
  ⟨coverFrame F, inferInstance, CoverPt.endpt, endpt_twoWayBounded F, endpt_surjective,
    @TwoWayBounded.plus_invariance_of_isZTime intOrder (coverFrame F) F _ _
      (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
      CoverPt.endpt (endpt_twoWayBounded F) endpt_surjective M⟩

end FormalSystem.Semantics
