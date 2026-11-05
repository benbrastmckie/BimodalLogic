/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Combinatorics.SimpleGraph.Acyclic
import FormalSystem.Semantics.IntNormalForm

/-!
# Oriented forests satisfy *Saturation*

Every relation `E : W → W → Prop` whose **underlying undirected multigraph is a forest**
satisfies the literal `TaskFrame.Saturation` predicate at `ofStepRel E` over `ℤ`. This is the
general lemma the ZTime decidability route's oriented-forest obligation needs: it is stated over
a bare one-step relation, with no forest *data structure* assumed and no finiteness anywhere.

## The hypothesis, and why it is not directed-path uniqueness

`IsOrientedForest E` carries three fields — `loopFree`, `oppFree`, `acyclic`. The third is
`(SimpleGraph.fromRel E).IsAcyclic`, and `SimpleGraph.fromRel` **deduplicates parallel edges**:
it forgets that `E u v` and `E v u` are two distinct edges of the multigraph, and it forgets a
loop `E u u` entirely. `loopFree` and `oppFree` are precisely what that deduplication would
otherwise readmit, so the three fields together say "the undirected multigraph underlying `E` is
a forest" rather than "the simple graph `fromRel E` is a forest". The predicate is manifestly
symmetric in `E` and `Function.swap E` (see `isOrientedForest_swap`), which is what the
all-backward reduction consumes.

**The hypothesis cannot be weakened to directed-path uniqueness.** The four-node digraph
`a → c`, `b → c`, `a → y`, `b → y` has a unique directed path between any two of its vertices,
and yet `(a, b)` has *two* distinct divergent merge points, `c` and `y`. Its underlying
undirected multigraph is a 4-cycle, which `IsOrientedForest` excludes. `mergePoint_unique` below
is the one declaration whose proof consumes `acyclic` rather than only `loopFree`/`oppFree`, and
that 4-cycle is exactly what it rules out.

## Step map

The argument is the five-step one recorded in the amended section 1.2 of the axiomatizability
rules-engine report. Which declaration discharges which step:

| Step | Content | Declaration |
|------|---------|-------------|
| 1, 3 | segments of the relation are subsingletons | `mid_unique` (via `seg_subsingleton`) |
| 2 | merges exist | `exists_merge` (needs **no** forest hypothesis) |
| 4 | the merge point is independent of the target | `mergePoint_unique`, through `merge_unique` |
| 5 | a `⊆`-least member closes a family | `TaskFrame.sInter_nonempty_of_directed_of_minimal` |

`mid_unique` **is** the segment-subsingleton fact (steps 1 and 3 at once); there is no separate
lemma for it, and a reader should not look for one.

Where the forest hypothesis enters, in order of increasing strength:

* `exists_merge` consumes nothing at all.
* `meet_approach_disjoint` consumes only directed-path uniqueness (`pen_unique`,
  `iter_length_unique`).
* `mergePoint_unique` is the first and only consumer of `acyclic` beyond what
  `exists_isPath_of_iter` already uses to build paths.

## Verified Mathlib names at this pin

Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1`. Every acyclicity-API name used below was checked
present at this pin:

| Name | Role |
|------|------|
| `SimpleGraph.IsAcyclic.subsingleton_path` | path uniqueness between two vertices |
| `SimpleGraph.IsAcyclic.eq_penultimate_of_adj_end` | the (C1) induction step |
| `SimpleGraph.Walk.IsPath.concat` | extend a path by one edge |
| `SimpleGraph.Walk.penultimate_concat` | last-step bookkeeping |
| `SimpleGraph.Walk.length_concat` / `support_concat` | length and support bookkeeping |
| `SimpleGraph.Walk.isPath_iff_nil` / `length_eq_zero_iff` | nil-case handling |
| `SimpleGraph.Walk.support_append` / `support_reverse` | the merge-point support transfer |

**Two deprecation pairs at this pin are live traps.** Reach for
`isAcyclic_iff_subsingleton_path` / `IsAcyclic.subsingleton_path`, never
`isAcyclic_iff_path_unique` / `IsAcyclic.path_unique`; and for `Walk.isPath_iff_nil` /
`Walk.length_eq_zero_iff`, never `Walk.isPath_iff_eq_nil` / `Walk.nil_iff_length_eq`, whose
statements also changed shape (`p.Nil` in place of `p = nil`). A future Mathlib bump should
re-check this table rather than the proof bodies.

## Main results

* `IsOrientedForest` — the hypothesis: the undirected multigraph underlying `E` is a forest
* `exists_isPath_of_iter` — **(C1)** a directed walk is an undirected path, its penultimate
  vertex carries the last step, and every vertex of it splits the walk
* `iter_length_unique` — **(UPL)** a directed walk's length is determined by its endpoints
* `not_iter_self` — no directed cycles
* `pen_unique` — **(PEN)** the penultimate vertex of a directed walk of fixed length is determined
* `mid_unique` — **(UIV)** the intermediate vertex at a fixed distance is determined
* `exists_merge` — **(MERGE)** two directed walks into a common target factor through a last
  divergence point
* `meet_approach_disjoint` — **(DISJ)** at a divergent merge the approach walks meet only there
* `merge_unique` — the residual step: a divergent merge point and its three length parameters
  are unique
* `saturation_of_orientedForest` — `TaskFrame.Saturation (ofStepRel E)` from `IsOrientedForest E`
* `saturation_of_orientedForest'` — the `hgen`-parameterised variant for a consumer holding a
  relation only *equal* to `ofStepRel E`

## Notes

`iter`, `iter_zero`, `iter_succ` and `iter_add` are taken from `IntNormalForm`, never redefined.
`pathOf` is `noncomputable` (it is an `Exists.choose`); that is sanctioned, since it is not a
`Decidable`-valued declaration. The measured axiom profile of both headline theorems is pinned
by `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean`.

## References

* `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.Saturation` and its `saturation_of_*` family
* `FormalSystem/Semantics/IntNormalForm.lean` — `iter`, `iter_add`, `ofStepRel`
-/

namespace FormalSystem.Semantics

open SimpleGraph

variable {W : Type}

/-! ## The hypothesis -/

/--
The underlying undirected **multigraph** of the one-step relation `E` is a forest.

The three fields are "no undirected 1-cycle", "no undirected 2-cycle", and "no undirected cycle
of length at least 3": `SimpleGraph.fromRel` deduplicates parallel edges, so `loopFree` and
`oppFree` are precisely what that deduplication would otherwise readmit. No forest data
structure is assumed, and the predicate is symmetric in `E`/`Function.swap E` by inspection
(`isOrientedForest_swap`).
-/
structure IsOrientedForest (E : W → W → Prop) : Prop where
  loopFree : ∀ u, ¬ E u u
  oppFree : ∀ u v, E u v → ¬ E v u
  acyclic : (SimpleGraph.fromRel E).IsAcyclic

/-- A directed step is an undirected adjacency. -/
theorem adj_of_step {E : W → W → Prop} (hF : IsOrientedForest E) {u v : W} (h : E u v) :
    (SimpleGraph.fromRel E).Adj u v :=
  ⟨fun h' => hF.loopFree u (h' ▸ h), Or.inl h⟩

/-- The step out of the endpoint of a directed path cannot re-enter the path. -/
theorem not_mem_support_of_step {E : W → W → Prop} (hF : IsOrientedForest E)
    {a w z : W} {p : (SimpleGraph.fromRel E).Walk a w} (hp : p.IsPath)
    (hpen : 0 < p.length → E p.penultimate w) (hEwz : E w z) : z ∉ p.support := by
  intro hz
  have hzp : z = p.penultimate :=
    hF.acyclic.eq_penultimate_of_adj_end hp (adj_of_step hF hEwz) hz
  rcases Nat.eq_zero_or_pos p.length with hn | hn
  · have hav : a = w := Walk.eq_of_length_eq_zero hn
    have hza : z = a := by rw [hzp]; simp [Walk.penultimate, hn]
    rw [← hav, hza] at hEwz
    exact hF.loopFree a hEwz
  · exact hF.oppFree w z hEwz (hzp ▸ hpen hn)

/-! ## (C1): a directed walk is an undirected path -/

/--
**(C1)** A directed `E`-walk of length `n` is an undirected path, its penultimate vertex carries
the last `E`-step, and every vertex of that path splits the walk at some distance from the
source.

The last conjunct — the *between-clause* — is what lets a shared vertex of two approach walks be
turned back into `iter` data, which is how `meet_approach_disjoint` and `mergePoint_unique`
consume path membership.
-/
theorem exists_isPath_of_iter {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (n : ℕ) (a z : W), iter E n a z →
      ∃ p : (SimpleGraph.fromRel E).Walk a z,
        p.IsPath ∧ p.length = n ∧ (0 < n → E p.penultimate z) ∧
        (∀ d ∈ p.support, ∃ i, i ≤ n ∧ iter E i a d ∧ iter E (n - i) d z) := by
  intro n
  induction n with
  | zero =>
    intro a z h
    have h' : a = z := (iter_zero E a z).mp h
    subst h'
    refine ⟨Walk.nil, Walk.IsPath.nil, rfl, by omega, ?_⟩
    intro d hd
    simp only [Walk.support_nil, List.mem_singleton] at hd
    exact ⟨0, Nat.le_refl 0, by simpa using hd.symm, by simpa using hd⟩
  | succ n ih =>
    intro a z h
    obtain ⟨v, hv, hEvz⟩ := (iter_succ E n a z).mp h
    obtain ⟨p, hp, hlen, hpen, hbtw⟩ := ih a v hv
    have hadj := adj_of_step hF hEvz
    have hz : z ∉ p.support :=
      not_mem_support_of_step hF hp (by rw [hlen]; exact hpen) hEvz
    refine ⟨p.concat hadj, hp.concat hz hadj, ?_, ?_, ?_⟩
    · rw [Walk.length_concat, hlen]
    · intro _; rw [Walk.penultimate_concat]; exact hEvz
    · intro d hd
      have hd : d ∈ p.support ∨ d = z := by
        simpa [Walk.support_concat, List.concat_eq_append] using hd
      rcases hd with hd | hd
      · obtain ⟨i, hi, h1, h2⟩ := hbtw d hd
        refine ⟨i, by omega, h1, ?_⟩
        have hsub : n + 1 - i = (n - i) + 1 := by omega
        rw [hsub]
        exact (iter_succ E (n - i) d z).mpr ⟨v, h2, hEvz⟩
      · exact ⟨n + 1, by omega, hd ▸ (iter_succ E n a z).mpr ⟨v, hv, hEvz⟩, by
          simpa using (iter_zero E d z).mpr hd⟩

end FormalSystem.Semantics
