/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.SmallModel

/-!
# The Realised-Datum Graph and the Splice Lemma

`BiLasso/SmallModel.lean` establishes that the *type sequence* of a genuine history satisfies the
conditions an annotation must satisfy, and isolates the pigeonhole datum — the pair
`(state, type)` — the extraction has to loop on. This module turns that datum into a **finite
graph** and proves the one lemma that licenses cutting and pasting walks in it.

## Why a graph, and why this graph

The extraction must produce an annotated bi-lasso from an arbitrary total history. A bi-lasso is
three finite lists, so the history's bi-infinite datum sequence has to be compressed into finitely
many positions, and the compression is done by excising stretches between two positions carrying
the *same* datum. Two things must hold for that to be sound:

1. The datum must range over a **finite** type, so that a repeat is forced. That is
   `PigeonState`, whose cardinality is computed exactly in `card_pigeonState`.
2. Excision must preserve local coherence. That is `localCoherentSeq_of_edges`.

## Local coherence is an edge condition, and that is the whole point

`LocalCoherentSeq` (`SmallModel.lean`) is a conjunction of six clauses at each position `t`. Read
them carefully and every one of them mentions at most **two adjacent positions**:

- `atom`, `bot`, `imp`, `box` read position `t` alone (`box` additionally reads the oracle, which
  is a global `Formula → Bool` and mentions no position at all);
- the `untl` clause relates `lab t` to `lab (t + 1)` — it reads the edge to the **right**;
- the `snce` clause relates `lab t` to `lab (t - 1)` — it reads the edge to the **left**.

So local coherence of a whole sequence is exactly "every consecutive pair is a `CoherentEdge`".
`CoherentEdge` packages the six obligations as a relation on *data*, not on positions, and
`localCoherentSeq_of_edges` converts a family of edges back into a `LocalCoherentSeq`.

**This is why splicing is sound.** If positions `u` and `v` carry the same datum, then the
sequence obtained by jumping from `u` straight to `v + 1` still has every consecutive pair a
`CoherentEdge` — the new seam `(datum u, datum (v + 1))` is the old edge `(datum v, datum (v + 1))`
because `datum u = datum v`, and the datum is *all* the six clauses can see. No clause reaches two
steps away, so nothing at the seam can notice the excision. The absence of this lemma is what
blocked the previous round's assembly step: without it, "cut the walk at a repeat" was a picture
rather than a proof.

## Main Definitions

- `PigeonState` — the finite type of pigeonhole data: a state together with a closure-subset type
- `stateOf` / `typeOf` — its two projections
- `datum` — the subtype refinement of `SmallModel.lean`'s `pigeonDatum`
- `RealizedStep` — the edge relation: `x → y` when some source time carries `x` and its successor
  carries `y`
- `CoherentEdge` — the six local-coherence clauses read across one edge

## Main Results

- `card_pigeonState` / `natCard_pigeonState` — the cardinality is exactly `P.card · 2^k`
- `realizedStep_step` — a realised edge is `P.step`-adjacent in its state components
- `coherentEdge_of_realizedStep` — every realised edge is coherent
- `localCoherentSeq_of_edges` — **the splice lemma**: a walk of coherent edges induces a
  `LocalCoherentSeq`

Argument order throughout is **guard first**: `Formula.untl g e` and `Formula.snce g e` have guard
`g` and event `e`, matching `Semantics/Truth.lean`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-! ## The finite type of pigeonhole data -/

/--
The pigeonhole datum, as a **type** rather than as a value in an ambient infinite type.

`SmallModel.lean`'s `pigeonDatum` lands in `Fin P.card × Finset Formula`, which is not finite;
`pigeonDatum_mem` records that its second component is confined to `(subformulaClosure φ).powerset`.
Refining the second component into that `Finset`'s coercion is what makes the whole thing a
`Fintype`, and hence what makes the pigeonhole helpers of `FMP/Periodicity.lean` — all of which
are stated at `[Finite W]` — applicable.

Declared `abbrev` rather than `def` so that the product's `Fintype`, `DecidableEq` and `Finite`
instances, and the two structure projections, are available without restating them.
-/
abbrev PigeonState (P : IntPresentation) (φ : Formula) : Type :=
  Fin P.card × {S : Finset Formula // S ∈ (subformulaClosure φ).powerset}

/-- The state component of a datum. -/
def stateOf (x : PigeonState P φ) : Fin P.card := x.1

/-- The type component of a datum, as a plain `Finset Formula`. -/
def typeOf (x : PigeonState P φ) : Finset Formula := x.2.1

/-- A datum's type is a set of closure formulas — the subtype's own side condition, unpacked. -/
theorem typeOf_subset (x : PigeonState P φ) : typeOf x ⊆ subformulaClosure φ :=
  Finset.mem_powerset.mp x.2.2

/--
**The cardinality of the datum type**, in `Fintype.card` normal form.

`P.card` choices of state times `2 ^ k` subsets of a `k`-element closure. This is the quantity
every bound downstream is expressed in, and it is *proved* here rather than asserted, so that the
extraction can cite a theorem instead of re-deriving the arithmetic.
-/
theorem card_pigeonState (P : IntPresentation) (φ : Formula) :
    Fintype.card (PigeonState P φ) = P.card * 2 ^ subformulaClosureCard φ := by
  rw [Fintype.card_prod, Fintype.card_fin, Fintype.card_coe, Finset.card_powerset,
    subformulaClosureCard]

/--
The same count in `Nat.card` normal form.

**This is the form the downstream bounds use**, because `FMP/Periodicity.lean`'s
`exists_lt_iter_of_card_le` and `exists_repeat_of_card_lt` are both stated with `Nat.card`. Both
normal forms are recorded so that neither consumer has to insert a conversion at its use site.
-/
theorem natCard_pigeonState (P : IntPresentation) (φ : Formula) :
    Nat.card (PigeonState P φ) = P.card * 2 ^ subformulaClosureCard φ := by
  rw [Nat.card_eq_fintype_card, card_pigeonState]

/-- The datum type is inhabited: `P.card_pos` gives a state and `∅` is a closure subset. -/
instance instInhabitedPigeonState : Inhabited (PigeonState P φ) :=
  ⟨⟨⟨0, P.card_pos⟩, ⟨∅, Finset.mem_powerset.mpr (Finset.empty_subset _)⟩⟩⟩

/-! ## The datum of a position -/

/--
The pigeonhole datum of a position, refined into `PigeonState`.

This is `SmallModel.lean`'s `pigeonDatum` with its second component carrying the membership proof
`pigeonDatum_mem` supplies. It is `noncomputable` for exactly the reason `typeAt` is — `TruthAt`'s
box clause quantifies over all total histories — and like `typeAt` it appears only inside proofs,
never on any path `check` can reach.
-/
noncomputable def datum (P : IntPresentation) (φ : Formula)
    (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (u : ℤ) : PigeonState P φ :=
  (τ.states u (hτ u), ⟨typeAt P φ τ u, Finset.mem_powerset.mpr (typeAt_subset τ u)⟩)

variable {τ : WorldHistory P.toTaskFrame} {hτ : τ.IsTotal}

/-- Projection: the state component of a position's datum is the history's state there. -/
@[simp]
theorem datum_state (u : ℤ) : stateOf (datum P φ τ hτ u) = τ.states u (hτ u) := rfl

/-- Projection: the type component of a position's datum is the position's type. -/
@[simp]
theorem datum_type (u : ℤ) : typeOf (datum P φ τ hτ u) = typeAt P φ τ u := rfl

/-- `datum` really is the landed `pigeonDatum`, forgetting the membership proof. -/
theorem datum_eq_pigeonDatum (u : ℤ) :
    (stateOf (datum P φ τ hτ u), typeOf (datum P φ τ hτ u)) = pigeonDatum P φ τ hτ u := rfl

/-! ## The realised-step relation -/

/--
The **realised-step relation**: `x` steps to `y` when some source time carries `x` and its
successor carries `y`.

Only edges the history actually traverses are admitted. That is what keeps the graph sound —
`coherentEdge_of_realizedStep` below reads every clause off the history's own semantics — while
finiteness of `PigeonState` is what keeps it useful.
-/
def RealizedStep (P : IntPresentation) (φ : Formula)
    (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) :
    PigeonState P φ → PigeonState P φ → Prop :=
  fun x y => ∃ u : ℤ, datum P φ τ hτ u = x ∧ datum P φ τ hτ (u + 1) = y

/-- Every position contributes a realised edge to the next. -/
theorem realizedStep_datum (u : ℤ) :
    RealizedStep P φ τ hτ (datum P φ τ hτ u) (datum P φ τ hτ (u + 1)) :=
  ⟨u, rfl, rfl⟩

/--
**A realised edge is adjacent in its state components.**

The history is a bi-infinite step path of the presented frame (`TaskFrame.HF.isStepPath`), and
`IntPresentation.isStepPath_iff` reads that off as the adjacency matrix at consecutive times. This
is what lets the extraction discharge a bi-lasso's `coherent` field from a walk in this graph.
-/
theorem realizedStep_step {x y : PigeonState P φ} (h : RealizedStep P φ τ hτ x y) :
    P.step (stateOf x) (stateOf y) = true := by
  obtain ⟨u, hx, hy⟩ := h
  subst hx; subst hy
  have hpath : IsStepPath P.toTaskFrame (fun t => τ.states t (hτ t)) :=
    TaskFrame.HF.isStepPath (F := P.toTaskFrame) ⟨τ, hτ⟩
  exact (P.isStepPath_iff _).mp hpath u

/-! ## Coherence as an edge condition -/

/--
**The six local-coherence clauses, read across one edge.**

Positions do not appear: each clause reads the source datum `x`, the target datum `y`, and the
global oracle `bx`. The `atom`, `bot`, `imp` and `box` clauses constrain the source alone; the
`untl` clause relates source to target; the `snce` clause relates *target* to source, since
`LocalCoherentSeq`'s `snce` clause at a position looks one step to its left.

Guard first: `Formula.untl g e` and `Formula.snce g e` have guard `g`, event `e`.
-/
def CoherentEdge (P : IntPresentation) (φ : Formula) (bx : Formula → Bool)
    (x y : PigeonState P φ) : Prop :=
  (∀ p : Atom, Formula.atom p ∈ subformulaClosure φ →
      (Formula.atom p ∈ typeOf x ↔ P.val p (stateOf x) = true)) ∧
  (Formula.bot ∉ typeOf x) ∧
  (∀ a b : Formula, Formula.imp a b ∈ subformulaClosure φ →
      (Formula.imp a b ∈ typeOf x ↔ (a ∈ typeOf x → b ∈ typeOf x))) ∧
  (∀ χ : Formula, Formula.box χ ∈ subformulaClosure φ →
      (Formula.box χ ∈ typeOf x ↔ bx χ = true)) ∧
  (∀ g e : Formula, Formula.untl g e ∈ subformulaClosure φ →
      (Formula.untl g e ∈ typeOf x ↔
        (e ∈ typeOf y ∨ (g ∈ typeOf y ∧ Formula.untl g e ∈ typeOf y)))) ∧
  (∀ g e : Formula, Formula.snce g e ∈ subformulaClosure φ →
      (Formula.snce g e ∈ typeOf y ↔
        (e ∈ typeOf x ∨ (g ∈ typeOf x ∧ Formula.snce g e ∈ typeOf x))))

/--
**Every realised edge is coherent.**

Directly from `typeAt_localCoherentSeq` (`SmallModel.lean`): the first five clauses are its
clauses at the source position `u`, and the `snce` clause is its `snce` clause at `u + 1`, whose
backward reference `(u + 1) - 1` is `u`.
-/
theorem coherentEdge_of_realizedStep (hbx : BoxOracleSound P bx)
    {x y : PigeonState P φ} (h : RealizedStep P φ τ hτ x y) :
    CoherentEdge P φ bx x y := by
  obtain ⟨u, hx, hy⟩ := h
  subst hx; subst hy
  have hseq := typeAt_localCoherentSeq (φ := φ) hbx τ hτ
  obtain ⟨ha, hb, hi, hbox, hu, _⟩ := hseq u
  obtain ⟨_, _, _, _, _, hs⟩ := hseq (u + 1)
  refine ⟨ha, hb, hi, hbox, hu, ?_⟩
  intro g e hge
  have hs' := hs g e hge
  rwa [show u + 1 - 1 = u by omega] at hs'

/-! ## The splice lemma -/

/--
**The splice lemma: a walk of coherent edges induces a locally coherent sequence.**

Given a datum sequence `d : ℤ → PigeonState P φ` whose every consecutive pair is a
`CoherentEdge`, the state sequence `stateOf ∘ d` and the label sequence `typeOf ∘ d` satisfy
`LocalCoherentSeq`.

**This is the lemma that makes cutting and pasting sound**, and it is worth saying exactly why.
Each of the six clauses at a position `t` reads only:

- that position's label and state (`atom`, `bot`, `imp`, `box`),
- the label one step to the right (`untl`),
- the label one step to the left (`snce`),

and nothing else. No clause reaches two steps away, and no clause mentions `t` itself. So a
sequence assembled by splicing together stretches of a genuine history — jumping from a position
`u` to a position `v + 1` whenever `d u = d v` — still satisfies every clause: the seam edge
`(d u, d (v + 1))` is literally the edge `(d v, d (v + 1))`, which the history realised.

The hypotheses are stated against arbitrary `st` and `lab` linked to `d` by `hst` and `hlab`,
rather than against `stateOf ∘ d` and `typeOf ∘ d` directly, because the assembly step consumes
this at label and state sequences that were built independently (from an `Annot`'s three lists)
and only afterwards shown to agree with a datum walk.
-/
theorem localCoherentSeq_of_edges {st : ℤ → Fin P.card} {lab : ℤ → Finset Formula}
    (d : ℤ → PigeonState P φ)
    (hst : ∀ t : ℤ, stateOf (d t) = st t)
    (hlab : ∀ t : ℤ, typeOf (d t) = lab t)
    (hedge : ∀ t : ℤ, CoherentEdge P φ bx (d t) (d (t + 1))) :
    LocalCoherentSeq P φ bx lab st := by
  intro t
  obtain ⟨ha, hb, hi, hbox, hu, _⟩ := hedge t
  -- The `snce` clause at `t` is the edge condition on the pair `(t - 1, t)`.
  obtain ⟨_, _, _, _, _, hs⟩ := hedge (t - 1)
  rw [show t - 1 + 1 = t by omega] at hs
  rw [← hst t] at *
  rw [← hlab t, ← hlab (t + 1), ← hlab (t - 1)]
  exact ⟨ha, hb, hi, hbox, hu, hs⟩

end FormalSystem.Metalogic.Decidability
