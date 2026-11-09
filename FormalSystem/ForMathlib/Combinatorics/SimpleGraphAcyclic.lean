/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Combinatorics.SimpleGraph.Acyclic

/-!
# A rank/parent criterion for acyclicity

**`SimpleGraph.isAcyclic_of_rank_parent`**: a simple graph is acyclic as soon as it admits a
rank function `rk : V → ℕ` and a parent map `par : V → V` such that the rank never increases
along `par`, and every adjacency is a parent edge with a strict rank drop — one endpoint is the
parent of the other, and the parent has the strictly smaller rank.

This is a *construction-side* criterion: it discharges `IsAcyclic` from data that an inductively
built carrier already carries (a length and a drop-the-last-step map), without ever mentioning
`SimpleGraph.Walk.IsCycle`.

**Mathlib does not carry this at pin `v4.33.0-rc1`.**
`Mathlib/Combinatorics/SimpleGraph/Acyclic.lean`
characterises acyclicity (bridges, path subsingletons, `IsTree`) and derives consequences of it,
but offers no sufficient condition stated over a rank and a parent map; the nearest constructions,
`Quiver.arborescenceMk` and `SimpleGraph.IsTree.*`, either produce a different structure
(`Quiver.Arborescence`) or already assume what is wanted here.

## Main results

* `SimpleGraph.isAcyclic_of_rank_parent` — the criterion.

## The proof

Through `isAcyclic_iff_forall_adj_isBridge` and `isBridge_iff` (which is `.rfl`): it suffices
that for every adjacency the two endpoints are unreachable from one another once that edge is
deleted. Orient the adjacency so that `par v = u` with `rk u < rk v`, and carry the invariant
"`v` is reached from here by some iterate of `par`" along every walk of the edge-deleted graph.
The invariant holds at `v` with iterate count zero; it is preserved along each edge of the
deleted graph (in the branch where the walk steps *down* to a parent it is preserved with a
*positive* count, because the count-zero case would name precisely the deleted edge); and it
fails at `u`, since the rank is non-increasing along `par` while `rk u < rk v`. No cycle, and no
maximality argument, appears anywhere.

## Naming

`isAcyclic_of_rank_parent` sits in Mathlib's own `SimpleGraph` namespace, with the
`isAcyclic_of_*` prefix of the sufficient-condition family, so that upstreaming is a file move
and no consumer changes a name.
-/

namespace SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- The rank is non-increasing along every iterate of the parent map. -/
private theorem rk_iterate_le {rk : V → ℕ} {par : V → V} (hle : ∀ v, rk (par v) ≤ rk v)
    (n : ℕ) (x : V) : rk (par^[n] x) ≤ rk x := by
  induction n generalizing x with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply]
    exact (ih (par x)).trans (hle x)

/--
**The invariant carried along the edge-deleted graph**: along any walk of
`G.deleteEdges {e}`, where `e` is the edge joining `v` to its parent `u`, "some iterate of `par`
reaches `v`" is preserved.

The `cons` step splits on the two ways the plan's adjacency hypothesis can orient an edge. In the
branch where the step goes *down* to a parent, the iterate count must already be positive: a
count of zero would place the walk at `v` itself, taking the step `v → par v = u`, which is the
one edge the deleted graph does not have.
-/
private theorem iterate_reaches_of_walk {rk : V → ℕ} {par : V → V}
    (hadj : ∀ ⦃a b : V⦄, G.Adj a b →
      (par b = a ∧ rk a < rk b) ∨ (par a = b ∧ rk b < rk a))
    {u v : V} {e : Sym2 V} (he : s(v, u) = e) (hpar : par v = u) :
    ∀ {x y : V}, (G.deleteEdges {e}).Walk x y →
      (∃ n, par^[n] x = v) → ∃ n, par^[n] y = v := by
  intro x y q
  induction q with
  | nil => exact id
  | @cons x z y h q ih =>
    intro hx
    refine ih ?_
    simp only [deleteEdges_adj] at h
    obtain ⟨hG, hne⟩ := h
    obtain ⟨n, hn⟩ := hx
    rcases hadj hG with ⟨hpz, _⟩ | ⟨hpx, _⟩
    · exact ⟨n + 1, by rw [Function.iterate_succ_apply, hpz]; exact hn⟩
    · cases n with
      | zero =>
        rw [Function.iterate_zero_apply] at hn
        have hzu : z = u := by rw [← hpx, hn, hpar]
        exact absurd (by rw [Set.mem_singleton_iff, hn, hzu]; exact he) hne
      | succ n =>
        rw [Function.iterate_succ_apply, hpx] at hn
        exact ⟨n, hn⟩

/--
**The two endpoints of a parent edge are unreachable once it is deleted.**

`e` is passed as an arbitrary edge *equal* to `s(v, u)` rather than as the literal pair, so that
the main theorem's two symmetric branches can both cite this lemma: one of them supplies
`Sym2.eq_swap` for `he` and the other `rfl`.
-/
private theorem not_reachable_deleteEdges_of_rank_parent {rk : V → ℕ} {par : V → V}
    (hle : ∀ v, rk (par v) ≤ rk v)
    (hadj : ∀ ⦃a b : V⦄, G.Adj a b →
      (par b = a ∧ rk a < rk b) ∨ (par a = b ∧ rk b < rk a))
    {u v : V} {e : Sym2 V} (he : s(v, u) = e) (hpar : par v = u) (hlt : rk u < rk v) :
    ¬ (G.deleteEdges {e}).Reachable v u := by
  rintro ⟨p⟩
  obtain ⟨n, hn⟩ := iterate_reaches_of_walk hadj he hpar p ⟨0, rfl⟩
  have hrk := rk_iterate_le hle n u
  rw [hn] at hrk
  omega

/--
**A rank and a parent map suffice for acyclicity.**

If every adjacency of `G` is a parent edge across a strict rank drop — one endpoint is the other's
`par`-image, and the parent carries the strictly smaller rank — and the rank never increases along
`par`, then `G` is acyclic.

This is the form an inductively built carrier can discharge directly: `rk` is the construction's
own length and `par` its drop-the-last-step map, and the adjacency hypothesis is the structural
case analysis of the construction's step relation. Nothing about cycles is needed.
-/
theorem isAcyclic_of_rank_parent (rk : V → ℕ) (par : V → V) (hle : ∀ v, rk (par v) ≤ rk v)
    (hadj : ∀ ⦃u v : V⦄, G.Adj u v →
      (par v = u ∧ rk u < rk v) ∨ (par u = v ∧ rk v < rk u)) :
    G.IsAcyclic := by
  rw [isAcyclic_iff_forall_adj_isBridge]
  intro a b hab
  rw [isBridge_iff]
  rcases hadj hab with ⟨hp, hlt⟩ | ⟨hp, hlt⟩
  · exact fun h =>
      not_reachable_deleteEdges_of_rank_parent hle hadj Sym2.eq_swap.symm hp hlt h.symm
  · exact not_reachable_deleteEdges_of_rank_parent hle hadj rfl hp hlt

end SimpleGraph
