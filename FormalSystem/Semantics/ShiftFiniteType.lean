/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntNormalFormEffective

/-!
# `H_F` over ℤ as a Shift of Finite Type

The specification this module transcribes, verbatim from
`JPL/appendix_cut_material.tex` under the header
`\section*{Categorical connections (cut from sub:Conclusion)}`:

> When $W$ is finite and $D = \Z$, the set of possible worlds $H_{\F}$ is a shift of finite
> type: world states correspond to alphabet symbols, the unit-step task relation to the edges of
> a labeled graph, and possible worlds to the bi-infinite paths through that graph.

That sentence is **cut** from the live paper; `JPL/possible_worlds.tex` retains only a
`% PARAGRAPH CUT (category-theory connections)` record at the cut site, and its live replacement
paragraph mentions only the sheaf and Johnstone route. It is therefore a specification this
module formalizes, not a published theorem it cites. The entry of record is
`docs/reference/paper-definitions-of-record.md`, "The finite-case effectiveness footnote".

## The dictionary, spelled out

| Symbolic dynamics | Here |
|---|---|
| alphabet symbol | a world state, `F.WorldState` |
| edge of the labelled graph | the one-step relation, `FrameOver.step` (`⇒₁`) |
| configuration, `ℤ → alphabet` | a function `f : ℤ → F.WorldState` |
| bi-infinite path through the graph | `IsStepPath F f` |
| forbidden 2-block | `Forbidden F w u`, a **non**-edge of `(W, ⇒₁)` |
| the subshift | the possible worlds, `{f | ∃ τ : WorldHistory F, τ.path = f}` |
| *of finite type* | `finite_forbiddenBlocks`: finitely many forbidden blocks |

Two halves, and they are proved separately on purpose. `mem_HF_iff_no_forbidden` is the
**identification**: `H_F` is cut out of the full shift by a condition on 2-blocks, which is what
makes it a subshift presented by forbidden words at all. `finite_forbiddenBlocks` is what earns
the phrase **finite type**: that the presenting set of forbidden words is finite. Folding the
second into the first would hide which hypothesis buys which half — the identification holds at
*any* carrier, finite or not, and only the finite-type claim needs `[Finite W]`.

## Not `Semantics/ShiftSet.lean`

That module proves an unrelated representation theorem — task models correspond to *shift sets*,
a structure on sets of histories. The word "shift" is shared and nothing else is. This module is
about symbolic dynamics on the one-step graph of a single frame.

## Why the identification is choice-free and the finiteness is not

`mem_HF_iff_no_forbidden` routes its substantive content through `IntNormalFormEffective.lean`'s
`mem_HF_iff_adjacent_int` rather than through `IntNormalForm.lean`'s `mem_HF_iff_adjacent`, so
the membership chain contributes no choice. The statement nonetheless measures
`[propext, Classical.choice, Quot.sound]`, because `Forbidden` is a negation and "no forbidden
block" therefore asks for double-negation elimination at a `Prop`-valued relation — classical
reasoning in the statement, not in the route. Its own docstring carries the full accounting, and
names `mem_HF_iff_adjacent_int` as the choice-free form of the same identification, which is
what every downstream result in this cluster consumes. `finite_forbiddenBlocks` goes through
`Set.toFinite` at `[Finite W]` and measures the same profile. Both values are recorded here as
the measurements they are, and pinned by guard blocks in
`Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean`.

## *Saturation* needs no separate work here

For a finite carrier, *Saturation* is already `TaskFrame.saturation_of_finite`, so the
finite-carrier hypothesis below buys the finite-type half and nothing else has to be
re-discharged for it.

## Where the same graph appears elsewhere

Two durable anchors, neither of them a cited theorem:

- The paper's `cor:path-fibration` at `D = ℤ`. Iterating *Compositionality* identifies `⇒ₙ` with
  the `n`-fold composite of `⇒₁` (that is `FrameOver.taskRel_natCast_iff_iter`) and `⇒₀` with the
  identity (`FrameOver.nullity_identity`), so a function on `[0, l]` is a convex history exactly
  when it is a length-`l` path in `(W, ⇒₁)` — and `Path(F)`, the category whose morphisms are the
  convex histories from one world state to another, is then the free category on that graph. That
  last clause is *described* rather than cited: no `Path(F)` exists in this tree.
- The decidability route's root-path presentation.
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` and
  `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` ("ultimately periodic
  (lasso) root paths") present the decision procedure's search space as the root paths of a
  finite class graph — the same graph-theoretic reading of a finite carrier, applied to a
  different object.

## Main Definitions

- `FrameOver.Forbidden` — the forbidden 2-block predicate: a non-edge of `(W, ⇒₁)`
- `FrameOver.forbiddenBlocks` — the same, as a set of pairs
- `FrameOver.instDecidableForbidden` — the block test, executable at `[DecidableRel F.step]`

## Main Results

- `FrameOver.finite_forbiddenBlocks` — the forbidden-block set is finite: the *finite type* half
- `FrameOver.mem_HF_iff_no_forbidden` — the shift-of-finite-type identification

## Tags

ztime · symbolic-dynamics · shift-of-finite-type · subshift
-/

namespace FormalSystem.Semantics

namespace FrameOver

open TaskFrame

/--
A **forbidden 2-block** of the frame's one-step graph: the ordered pair `(w, u)` is forbidden
exactly when `w` does *not* step to `u` — that is, when `(w, u)` is a non-edge of `(W, ⇒₁)`.

The presentation of a subshift by forbidden words is complementary to the presentation by allowed
ones, and the forbidden side is the one the phrase "of finite type" is about: a subshift is of
finite type when it can be presented by *finitely many* forbidden words. Here every forbidden word
has length two, so the presenting set is a set of pairs.
-/
def Forbidden (F : FrameOver intOrder) (w u : F.WorldState) : Prop := ¬ F.step w u

theorem forbidden_def (F : FrameOver intOrder) (w u : F.WorldState) :
    Forbidden F w u ↔ ¬ F.step w u := Iff.rfl

/-- The forbidden 2-blocks as a set of pairs, so the finiteness statement has an object to be
about. -/
def forbiddenBlocks (F : FrameOver intOrder) : Set (F.WorldState × F.WorldState) :=
  {b | Forbidden F b.1 b.2}

@[simp]
theorem mem_forbiddenBlocks (F : FrameOver intOrder) (b : F.WorldState × F.WorldState) :
    b ∈ forbiddenBlocks F ↔ Forbidden F b.1 b.2 := Iff.rfl

/--
**The *finite type* half.** Over a finite carrier the forbidden-block set is finite, so the
subshift identified below is presented by finitely many forbidden words.

This is the declaration that earns the word "finite" in "shift of finite type", and it is stated
apart from the identification because it is the only part of the claim that needs `[Finite W]`.
Measured `[propext, Classical.choice, Quot.sound]`: `Set.toFinite` routes through `Set.Finite`,
which carries choice at `[Finite α]`. That is a property of the finiteness API, not of the
content — a subset of a finite type being finite is not in doubt — and it is recorded rather than
scrubbed, because no choice-free `Set.Finite` is available and the identification, which is the
result the rest of this task builds on, does not depend on it.
-/
theorem finite_forbiddenBlocks (F : FrameOver intOrder) [Finite F.WorldState] :
    {b : F.WorldState × F.WorldState | Forbidden F b.1 b.2}.Finite :=
  Set.toFinite _

/--
**The shift-of-finite-type identification.**

A function `f : ℤ → W` is the underlying path of a possible world exactly when it contains no
forbidden 2-block — that is, exactly when every consecutive pair `(f n, f (n+1))` is an edge of
`(W, ⇒₁)`. Together with `finite_forbiddenBlocks` this says `H_F` is the subshift of the full
shift on the alphabet `W` presented by the finite set `forbiddenBlocks F`: world states are the
alphabet symbols, the unit-step task relation supplies the edges, and the possible worlds are the
bi-infinite paths through the resulting labelled graph.

The identification itself holds at *any* carrier; `[Finite W]` is carried here only so the
statement reads as the specification does, and it is the finiteness theorem above that uses it.

**Measured `[propext, Classical.choice, Quot.sound]`, and unavoidably so.** The substantive
content routes through `mem_HF_iff_adjacent_int`, deliberately not through
`mem_HF_iff_adjacent`, so the ℤ membership chain contributes no choice here. What does is the
shape of the statement itself: `Forbidden` is a negation, so "no forbidden block at `n`" is
`¬¬ F.step (f n) (f (n + 1))`, and recovering `F.step` from it is double-negation elimination at
a `Prop`-valued relation with no `Decidable` instance in scope. That is not a route that can be
scrubbed — it is classical reasoning in the statement, exactly as `Nat.card` is classical
reasoning in the statement of `FrameOver.extend_periodic`. Adding `[DecidableRel F.step]` would
make the step constructive and is deliberately *not* done: it would weaken the theorem for the
sake of its own axiom profile.

The choice-free form of the same identification, and the one every downstream result in this
cluster actually consumes, is `FrameOver.mem_HF_iff_adjacent_int`: `H_F` over ℤ is exactly the
configurations all of whose consecutive pairs are edges. Read the two together — this one names
the forbidden-block presentation, that one carries it choice-free.
-/
theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular] [Finite F.WorldState]
    (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ ∀ n : ℤ, ¬ Forbidden F (f n) (f (n + 1)) := by
  rw [F.mem_HF_iff_adjacent_int f]
  constructor
  · intro h n hn
    exact hn (h n)
  · intro h n
    exact Classical.not_not.mp (h n)

/-- The block test is executable: at a decidable one-step relation, forbiddenness of a 2-block
decides. -/
instance instDecidableForbidden (F : FrameOver intOrder) [DecidableRel F.step]
    (w u : F.WorldState) : Decidable (Forbidden F w u) :=
  inferInstanceAs (Decidable (¬ F.step w u))

end FrameOver

end FormalSystem.Semantics
