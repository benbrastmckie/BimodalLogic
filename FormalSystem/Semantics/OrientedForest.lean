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
| `SimpleGraph.Walk.cons_tail_support` | the junction is not in its own support tail |
| `SimpleGraph.Walk.mem_support_append_iff` | the merge-point support transfer |

**Two deprecation pairs at this pin are live traps.** Reach for
`isAcyclic_iff_subsingleton_path` / `IsAcyclic.subsingleton_path`, never
`isAcyclic_iff_path_unique` / `IsAcyclic.path_unique`; and for `Walk.isPath_iff_nil` /
`Walk.length_eq_zero_iff`, never `Walk.isPath_iff_eq_nil` / `Walk.nil_iff_length_eq`, whose
statements also changed shape (`p.Nil` in place of `p = nil`). A **third** pair was measured
at this pin while landing the merge layer: `Walk.support_eq_cons` is deprecated in favour of
`Walk.cons_tail_support`, whose equation runs in the opposite direction
(`u :: p.support.tail = p.support`). A future Mathlib bump should re-check this table rather than
the proof bodies.

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

/-! ## The path-uniqueness layer

The four consequences of forest path uniqueness that everything downstream consumes. `mid_unique`
**is** the segment-subsingleton fact — report 03 section 1.2's steps 1 and 3 at once — so there
is no separate declaration for it.
-/

/--
The chosen undirected path realizing a directed walk, together with its length, last-step and
between-clause data (`pathOf_spec`).

`noncomputable` because it is an `Exists.choose`. This is sanctioned: the prohibition in
`rules/lean4.md` is on a `noncomputable` **`Decidable`-valued** declaration, which this is not.
-/
noncomputable def pathOf {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z : W}
    (h : iter E n a z) : (SimpleGraph.fromRel E).Walk a z :=
  (exists_isPath_of_iter hF n a z h).choose

/-- The defining data of `pathOf`: it is a path, it has the right length, its penultimate vertex
carries the last `E`-step, and every vertex of it splits the walk. -/
theorem pathOf_spec {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z : W}
    (h : iter E n a z) :
    (pathOf hF h).IsPath ∧ (pathOf hF h).length = n ∧
      (0 < n → E (pathOf hF h).penultimate z) ∧
      (∀ d ∈ (pathOf hF h).support, ∃ i, i ≤ n ∧ iter E i a d ∧ iter E (n - i) d z) :=
  (exists_isPath_of_iter hF n a z h).choose_spec

/-- Paths between two vertices of a forest agree. Routed through
`IsAcyclic.subsingleton_path` — **not** the deprecated `IsAcyclic.path_unique`. -/
theorem walk_unique {E : W → W → Prop} (hF : IsOrientedForest E) {a z : W}
    {p q : (SimpleGraph.fromRel E).Walk a z} (hp : p.IsPath) (hq : q.IsPath) : p = q :=
  Subtype.mk.inj ((hF.acyclic.subsingleton_path a z).elim ⟨p, hp⟩ ⟨q, hq⟩)

/-- **(UPL)** Unique path length: a directed walk's length is determined by its endpoints. -/
theorem iter_length_unique {E : W → W → Prop} (hF : IsOrientedForest E) {n m : ℕ} {a z : W}
    (hn : iter E n a z) (hm : iter E m a z) : n = m := by
  obtain ⟨hp, hplen, _⟩ := pathOf_spec hF hn
  obtain ⟨hq, hqlen, _⟩ := pathOf_spec hF hm
  rw [← hplen, ← hqlen, walk_unique hF hp hq]

/-- No directed cycles. Uses `Walk.isPath_iff_nil` and `Walk.length_eq_zero_iff` — **not** the
deprecated `Walk.isPath_iff_eq_nil` / `Walk.nil_iff_length_eq`, whose statements also changed
shape at this pin. -/
theorem not_iter_self {E : W → W → Prop} (hF : IsOrientedForest E) {s : ℕ} (hs : 0 < s)
    (d : W) : ¬ iter E s d d := fun h => by
  obtain ⟨hp, hlen, _⟩ := pathOf_spec hF h
  have := Walk.length_eq_zero_iff.mpr (Walk.isPath_iff_nil.mp hp)
  omega

/-- **(PEN)** The penultimate vertex of a directed walk of fixed length is determined. -/
theorem pen_unique {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z w w' : W}
    (hw : iter E n a w) (hEw : E w z) (hw' : iter E n a w') (hEw' : E w' z) : w = w' := by
  obtain ⟨hp, hplen, hppen, _⟩ := pathOf_spec hF hw
  obtain ⟨hq, hqlen, hqpen, _⟩ := pathOf_spec hF hw'
  have hadj := adj_of_step hF hEw
  have hadj' := adj_of_step hF hEw'
  have hzp : z ∉ (pathOf hF hw).support :=
    not_mem_support_of_step hF hp (by rw [hplen]; exact hppen) hEw
  have hzq : z ∉ (pathOf hF hw').support :=
    not_mem_support_of_step hF hq (by rw [hqlen]; exact hqpen) hEw'
  have heq := walk_unique hF (hp.concat hzp hadj) (hq.concat hzq hadj')
  have hpen := congrArg Walk.penultimate heq
  rwa [Walk.penultimate_concat, Walk.penultimate_concat] at hpen

/--
**(UIV)** The intermediate vertex of a directed walk at a fixed distance is determined.

This **is** the segment-subsingleton fact: report 03 section 1.2's steps 1 and 3 at once. A
`TaskFrame.Seg (ofStepRel E)` with nonnegative offsets unfolds to exactly this statement's
hypotheses, which is what `seg_subsingleton` below records.
-/
theorem mid_unique {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (j k : ℕ) (a z v v' : W), iter E k a v → iter E j v z → iter E k a v' → iter E j v' z →
      v = v' := by
  intro j
  induction j with
  | zero =>
    intro _ _ _ _ _ _ h1 _ h2
    exact ((iter_zero E _ _).mp h1).trans ((iter_zero E _ _).mp h2).symm
  | succ j ih =>
    intro k a z v v' hav hvz hav' hv'z
    obtain ⟨w, hvw, hEwz⟩ := (iter_succ E j v z).mp hvz
    obtain ⟨w', hvw', hEw'z⟩ := (iter_succ E j v' z).mp hv'z
    have haw : iter E (k + j) a w := (iter_add E k j a w).mpr ⟨v, hav, hvw⟩
    have haw' : iter E (k + j) a w' := (iter_add E k j a w').mpr ⟨v', hav', hvw'⟩
    have hww : w = w' := pen_unique hF haw hEwz haw' hEw'z
    subst hww
    exact ih k a w v v' hav hvw hav' hvw'

/-! ## The merge layer

`exists_merge` needs **no** `IsOrientedForest` hypothesis at all — it is a pure statement about
iterated relations. `meet_approach_disjoint` consumes only directed-path uniqueness
(`pen_unique`, `iter_length_unique`). Undirected acyclicity does not become load-bearing until
`mergePoint_unique` below.
-/

/--
**(MERGE)** Two directed walks into a common target factor through a last divergence point: the
merge vertex of report 03 section 1.2's step 4.

The divergence disjunct carries **explicit predecessors** (`k = kk + 1 ∧ l = ll + 1`) rather than
truncated subtraction, which is the shape the downstream consumers actually want.

This lemma takes no forest hypothesis.
-/
theorem exists_merge {E : W → W → Prop} :
    ∀ (n m : ℕ) (a b z : W), iter E n a z → iter E m b z →
      ∃ (c : W) (k l j : ℕ), iter E k a c ∧ iter E l b c ∧ iter E j c z ∧
        k + j = n ∧ l + j = m ∧
        (k = 0 ∨ l = 0 ∨ ∃ (kk ll : ℕ) (u u' : W), k = kk + 1 ∧ l = ll + 1 ∧
          u ≠ u' ∧ E u c ∧ E u' c ∧ iter E kk a u ∧ iter E ll b u') := by
  intro n
  induction n with
  | zero =>
    intro m a b z hn hm
    exact ⟨z, 0, m, 0, hn, hm, (iter_zero E z z).mpr rfl, by omega, by omega, Or.inl rfl⟩
  | succ n ih =>
    intro m a b z hn hm
    obtain ⟨w, haw, hEwz⟩ := (iter_succ E n a z).mp hn
    rcases m with _ | m
    · exact ⟨z, n + 1, 0, 0, hn, hm, (iter_zero E z z).mpr rfl, by omega, by omega,
        Or.inr (Or.inl rfl)⟩
    · obtain ⟨w', hbw', hEw'z⟩ := (iter_succ E m b z).mp hm
      by_cases hww : w = w'
      · subst hww
        obtain ⟨c, k, l, j, h1, h2, h3, h4, h5, h6⟩ := ih m a b w haw hbw'
        exact ⟨c, k, l, j + 1, h1, h2, (iter_succ E j c z).mpr ⟨w, h3, hEwz⟩,
          by omega, by omega, h6⟩
      · exact ⟨z, n + 1, m + 1, 0, hn, hm, (iter_zero E z z).mpr rfl, by omega, by omega,
          Or.inr (Or.inr ⟨n, m, w, w', rfl, rfl, hww, hEwz, hEw'z, haw, hbw'⟩)⟩

/--
**(DISJ)** At a *divergent* merge point `c` of `a` and `b` — the two last steps into `c` come
from distinct vertices — the two approach walks share no vertex but `c`.

This is the input to the step-4 independence claim, and it consumes only `pen_unique` and
`iter_length_unique`, i.e. only directed-path uniqueness.
-/
theorem meet_approach_disjoint {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c d u u' : W} {kk ll i j i' j' : ℕ}
    (hu : iter E kk a u) (hEu : E u c) (hu' : iter E ll b u') (hEu' : E u' c) (hne : u ≠ u')
    (h1 : iter E i a d) (h2 : iter E j d c) (hk : i + j = kk + 1)
    (h3 : iter E i' b d) (h4 : iter E j' d c) (hl : i' + j' = ll + 1) : d = c := by
  have hjj : j = j' := iter_length_unique hF h2 h4
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · subst hj0
    exact (iter_zero E d c).mp h2
  · exfalso
    obtain ⟨jm, hjm⟩ : ∃ jm, j = jm + 1 := ⟨j - 1, by omega⟩
    subst hjm
    obtain ⟨w, hdw, hEwc⟩ := (iter_succ E jm d c).mp h2
    have hik : i + jm = kk := by omega
    have hil : i' + jm = ll := by omega
    have haw : iter E kk a w := hik ▸ (iter_add E i jm a w).mpr ⟨d, h1, hdw⟩
    have hbw : iter E ll b w := hil ▸ (iter_add E i' jm b w).mpr ⟨d, h3, hdw⟩
    exact hne ((pen_unique hF haw hEwc hu hEu).symm.trans
      (pen_unique hF hbw hEwc hu' hEu'))

/--
A vertex that `b` reaches cannot be the `a`-side source of a divergent merge of `(a, b)`.

The bookkeeping lemma that rules out the degenerate branches of `exists_merge` once one
divergent merge of the pair is in hand: if `b` reaches `a` at all, then the two claimed
predecessors of the merge point sit at the same distance from `b`, so `pen_unique` identifies
them and the divergence hypothesis fails.
-/
theorem not_divergent_of_reach {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c u₁ u₂ : W} {kk ll l₂ : ℕ}
    (hreach : iter E l₂ b a)
    (hu₁ : iter E kk a u₁) (hE₁ : E u₁ c)
    (hu₂ : iter E ll b u₂) (hE₂ : E u₂ c) (hne : u₁ ≠ u₂) : False := by
  have hbu₁ : iter E (l₂ + kk) b u₁ := (iter_add E l₂ kk b u₁).mpr ⟨a, hreach, hu₁⟩
  have hbc₁ : iter E (l₂ + kk + 1) b c := (iter_succ E (l₂ + kk) b c).mpr ⟨u₁, hbu₁, hE₁⟩
  have hbc₂ : iter E (ll + 1) b c := (iter_succ E ll b c).mpr ⟨u₂, hu₂, hE₂⟩
  have hlen : l₂ + kk + 1 = ll + 1 := iter_length_unique hF hbc₁ hbc₂
  have hll : l₂ + kk = ll := by omega
  exact hne (pen_unique hF hbu₁ hE₁ (hll ▸ hu₂) hE₂)

/-! ## The concatenated approach walk

At a divergent merge point the two approach walks, concatenated with one reversed, form a
genuine undirected path between the two sources. That is the construction merge-point uniqueness
runs `walk_unique` against; the nodup side condition routes through `meet_approach_disjoint`
rather than through any new acyclicity appeal.
-/

/--
At a divergent merge point `c` of `(a, b)`, the walk
`(pathOf … : Walk a c).append ((pathOf … : Walk b c).reverse) : Walk a b` is an undirected path.

The support-disjointness side condition is exactly `meet_approach_disjoint`: a shared vertex `d`
of the two approach walks splits both, by `exists_isPath_of_iter`'s between-clause, and is
therefore `c` — which the reversed walk's own `IsPath` excludes from its support tail.
-/
theorem approach_concat_isPath {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c u u' : W} {kk ll : ℕ}
    (hu : iter E kk a u) (hEu : E u c) (hu' : iter E ll b u') (hEu' : E u' c) (hne : u ≠ u')
    (hac : iter E (kk + 1) a c) (hbc : iter E (ll + 1) b c) :
    ((pathOf hF hac).append (pathOf hF hbc).reverse).IsPath := by
  obtain ⟨hp, _, _, hpbtw⟩ := pathOf_spec hF hac
  obtain ⟨hq, _, _, hqbtw⟩ := pathOf_spec hF hbc
  have hqr : ((pathOf hF hbc).reverse).IsPath := hq.reverse
  have hcons : c :: ((pathOf hF hbc).reverse).support.tail
      = ((pathOf hF hbc).reverse).support := Walk.cons_tail_support _
  have hnd := hqr.support_nodup
  rw [← hcons] at hnd
  obtain ⟨hcnot, hndt⟩ := List.nodup_cons.mp hnd
  refine Walk.IsPath.mk' ?_
  rw [Walk.support_append]
  refine List.Nodup.append hp.support_nodup hndt ?_
  intro d hd hd'
  have hdrev : d ∈ ((pathOf hF hbc).reverse).support := by
    rw [← hcons]; exact List.mem_cons_of_mem _ hd'
  have hdq : d ∈ (pathOf hF hbc).support := by simpa using hdrev
  obtain ⟨i, hi, h1, h2⟩ := hpbtw d hd
  obtain ⟨i', hi', h3, h4⟩ := hqbtw d hdq
  have hdc : d = c :=
    meet_approach_disjoint hF hu hEu hu' hEu' hne h1 h2 (by omega) h3 h4 (by omega)
  exact hcnot (hdc ▸ hd')

/-- The length of the concatenated approach walk: the two approach lengths added. Recorded as a
named fact rather than re-derived inside a larger proof. -/
theorem approach_concat_length {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c : W} {kk ll : ℕ} (hac : iter E (kk + 1) a c) (hbc : iter E (ll + 1) b c) :
    ((pathOf hF hac).append (pathOf hF hbc).reverse).length = (kk + 1) + (ll + 1) := by
  obtain ⟨_, hplen, _⟩ := pathOf_spec hF hac
  obtain ⟨_, hqlen, _⟩ := pathOf_spec hF hbc
  rw [Walk.length_append, Walk.length_reverse, hplen, hqlen]

/-- The index of the merge point along the concatenated approach walk, as a named fact beside
`approach_concat_length`. -/
theorem approach_concat_getVert {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c : W} {kk ll : ℕ} (hac : iter E (kk + 1) a c) (hbc : iter E (ll + 1) b c) :
    ((pathOf hF hac).append (pathOf hF hbc).reverse).getVert (kk + 1) = c := by
  obtain ⟨_, hplen, _⟩ := pathOf_spec hF hac
  rw [Walk.getVert_append, hplen]
  simp

/-! ## Merge-point uniqueness — the residual step -/

/--
**A divergent merge point of a pair is unique**, with no reference to any common target.

This is the one declaration in the module whose proof consumes `acyclic` rather than only
`loopFree`/`oppFree`: `approach_concat_isPath` turns each divergent merge point into an
undirected path from `a` to `b`, and `walk_unique` — i.e. `IsAcyclic.subsingleton_path` —
identifies the two. The merge point `c'` is then a vertex of the *other* merge point's
concatenated walk, which `meet_approach_disjoint` forces to be `c`.

**Why the hypothesis cannot be weakened to directed-path uniqueness.** The four-node digraph
`a → c`, `b → c`, `a → y`, `b → y` has a unique directed path between any two of its vertices,
and `(a, b)` has *two* distinct divergent merge points, `c` and `y`. Its underlying undirected
multigraph is a 4-cycle, which `acyclic` excludes and directed-path uniqueness does not.
-/
theorem mergePoint_unique {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c c' u₁ u₂ u₁' u₂' : W} {k l k' l' : ℕ}
    (hu₁ : iter E k a u₁) (hE₁ : E u₁ c) (hu₂ : iter E l b u₂) (hE₂ : E u₂ c) (hne : u₁ ≠ u₂)
    (hu₁' : iter E k' a u₁') (hE₁' : E u₁' c') (hu₂' : iter E l' b u₂') (hE₂' : E u₂' c')
    (hne' : u₁' ≠ u₂') : c = c' := by
  have hac : iter E (k + 1) a c := (iter_succ E k a c).mpr ⟨u₁, hu₁, hE₁⟩
  have hbc : iter E (l + 1) b c := (iter_succ E l b c).mpr ⟨u₂, hu₂, hE₂⟩
  have hac' : iter E (k' + 1) a c' := (iter_succ E k' a c').mpr ⟨u₁', hu₁', hE₁'⟩
  have hbc' : iter E (l' + 1) b c' := (iter_succ E l' b c').mpr ⟨u₂', hu₂', hE₂'⟩
  have hP := approach_concat_isPath hF hu₁ hE₁ hu₂ hE₂ hne hac hbc
  have hP' := approach_concat_isPath hF hu₁' hE₁' hu₂' hE₂' hne' hac' hbc'
  have heq := walk_unique hF hP' hP
  have hc'mem : c' ∈ ((pathOf hF hac).append (pathOf hF hbc).reverse).support := by
    rw [← heq, Walk.mem_support_append_iff]
    exact Or.inl (Walk.end_mem_support _)
  rw [Walk.mem_support_append_iff] at hc'mem
  obtain ⟨_, _, _, hpbtw⟩ := pathOf_spec hF hac
  obtain ⟨_, _, _, hqbtw⟩ := pathOf_spec hF hbc
  rcases hc'mem with hA | hB
  · obtain ⟨i, hi, h1, h2⟩ := hpbtw c' hA
    have hcomp : iter E ((l' + 1) + (k + 1 - i)) b c :=
      (iter_add E (l' + 1) (k + 1 - i) b c).mpr ⟨c', hbc', h2⟩
    have hlen : (l' + 1) + (k + 1 - i) = l + 1 := iter_length_unique hF hcomp hbc
    exact (meet_approach_disjoint hF hu₁ hE₁ hu₂ hE₂ hne h1 h2 (by omega) hbc' h2 hlen).symm
  · have hB' : c' ∈ (pathOf hF hbc).support := by simpa using hB
    obtain ⟨i', hi', h3, h4⟩ := hqbtw c' hB'
    have hcomp : iter E ((k' + 1) + (l + 1 - i')) a c :=
      (iter_add E (k' + 1) (l + 1 - i') a c).mpr ⟨c', hac', h4⟩
    have hlen : (k' + 1) + (l + 1 - i') = k + 1 := iter_length_unique hF hcomp hac
    exact (meet_approach_disjoint hF hu₁ hE₁ hu₂ hE₂ hne hac' h4 hlen h3 h4 (by omega)).symm

/--
**The residual step of report 03 section 1.2.** A divergent merge point of a pair with a common
target, together with its three length parameters, is unique.

`mergePoint_unique` supplies `c = c'` without reference to `z`; the three length identities then
fall out of `iter_length_unique` alone.
-/
theorem merge_unique {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b z c c' u₁ u₂ u₁' u₂' : W} {k l j k' l' j' : ℕ}
    (hu₁ : iter E k a u₁) (hE₁ : E u₁ c) (hu₂ : iter E l b u₂) (hE₂ : E u₂ c) (hne : u₁ ≠ u₂)
    (hcz : iter E j c z)
    (hu₁' : iter E k' a u₁') (hE₁' : E u₁' c') (hu₂' : iter E l' b u₂') (hE₂' : E u₂' c')
    (hne' : u₁' ≠ u₂') (hc'z : iter E j' c' z) :
    c = c' ∧ k = k' ∧ l = l' ∧ j = j' := by
  have hcc : c = c' := mergePoint_unique hF hu₁ hE₁ hu₂ hE₂ hne hu₁' hE₁' hu₂' hE₂' hne'
  rw [hcc] at hE₁ hE₂ hcz
  refine ⟨hcc, ?_, ?_, iter_length_unique hF hcz hc'z⟩
  · have h1 : iter E (k + 1) a c' := (iter_succ E k a c').mpr ⟨u₁, hu₁, hE₁⟩
    have h2 : iter E (k' + 1) a c' := (iter_succ E k' a c').mpr ⟨u₁', hu₁', hE₁'⟩
    have hlen := iter_length_unique hF h1 h2
    omega
  · have h1 : iter E (l + 1) b c' := (iter_succ E l b c').mpr ⟨u₂, hu₂, hE₂⟩
    have h2 : iter E (l' + 1) b c' := (iter_succ E l' b c').mpr ⟨u₂', hu₂', hE₂'⟩
    have hlen := iter_length_unique hF h1 h2
    omega

/-! ## Saturation: the three reductions

The `Saturation` goal is reduced to the all-forward-fibre case in three steps, each a separately
named declaration rather than an inlined step of the final assembly.

The `hgen` hypothesis shared by this section and the next relates a task relation `R` on `ℤ` to
the one-step relation `E`: at a natural duration `R` is forward iteration, at its negation
backward iteration. `ofStepRel_gen` discharges it for `ofStepRel E` itself, so the extra
generality costs the headline theorem nothing and buys the primed variant for a consumer whose
relation is only *equal* to `ofStepRel E`.
-/

/--
**Reduction A.** A `⊇`-directed family of nonempty sets with a *subsingleton* member has
nonempty intersection: a nonempty subsingleton member is `⊆`-least outright, so
`TaskFrame.sInter_nonempty_of_directed_of_minimal` closes the goal. Consumes no forest input at
all.
-/
theorem sInter_nonempty_of_subsingleton_member {S : Set (Set W)}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty)
    {T : Set W} (hT : T ∈ S) (hsub : T.Subsingleton) : (⋂₀ S).Nonempty := by
  refine TaskFrame.sInter_nonempty_of_directed_of_minimal hd hne hT ?_
  intro T' hT' hT'sub
  obtain ⟨x, hx⟩ := hne T' hT'
  intro y hy
  have hyx : y = x := hsub hy (hT'sub hx)
  exact hyx ▸ hx

/-! ### Reduction C's symmetry: the opposite relation -/

/-- Iterating the opposite relation reverses the walk. -/
theorem iter_swap {E : W → W → Prop} : ∀ (n : ℕ) (a u : W),
    iter (Function.swap E) n a u ↔ iter E n u a := by
  intro n
  induction n with
  | zero =>
    intro a u
    rw [iter_zero, iter_zero]
    exact eq_comm
  | succ n ih =>
    intro a u
    rw [iter_succ]
    have hcomm : 1 + n = n + 1 := Nat.add_comm 1 n
    constructor
    · rintro ⟨v, hv, hE⟩
      have h1 : iter E 1 u v := (iter_one E u v).mpr hE
      have h2 : iter E (1 + n) u a := (iter_add E 1 n u a).mpr ⟨v, h1, (ih a v).mp hv⟩
      rwa [hcomm] at h2
    · intro h
      have h2 : iter E (1 + n) u a := by rwa [hcomm]
      obtain ⟨v, h1, h3⟩ := (iter_add E 1 n u a).mp h2
      exact ⟨v, (ih a v).mpr h3, (iter_one E u v).mp h1⟩

/-- `SimpleGraph.fromRel` forgets edge orientation, so it does not see the swap. -/
theorem fromRel_swap (E : W → W → Prop) :
    SimpleGraph.fromRel (Function.swap E) = SimpleGraph.fromRel E := by
  ext u v
  simp only [SimpleGraph.fromRel_adj, Function.swap]
  tauto

/-- `IsOrientedForest` is symmetric in `E` and its opposite: the underlying undirected
multigraph is the same object. This is what makes the all-backward case of `Saturation` the
all-forward case for `Function.swap E`. -/
theorem isOrientedForest_swap {E : W → W → Prop} (hF : IsOrientedForest E) :
    IsOrientedForest (Function.swap E) where
  loopFree u := hF.loopFree u
  oppFree u v h := hF.oppFree v u h
  acyclic := by rw [fromRel_swap]; exact hF.acyclic

/-! ### The segment-subsingleton bridge -/

/-- `ofStepRel E` satisfies the generator condition: this is what makes the primed headline
theorem's `hgen` free for `ofStepRel` itself. -/
theorem ofStepRel_gen {E : W → W → Prop} : ∀ (n : ℕ) (w u : W),
    (ofStepRel E w (n : ℤ) u ↔ iter E n w u) ∧
      (ofStepRel E w (-(n : ℤ)) u ↔ iter E n u w) := by
  intro n w u
  refine ⟨?_, ?_⟩
  · rw [ofStepRel_of_nonneg (Int.natCast_nonneg n) w u]; simp
  · rw [ofStepRel_of_nonpos (neg_nonpos.mpr (Int.natCast_nonneg n)) w u]; simp

/-- A forward fibre of `R` at a natural duration is a forward `E`-fibre. -/
theorem fib_natCast_eq {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    (w : W) (n : ℕ) : TaskFrame.Fib R w (n : ℤ) = {u | iter E n w u} := by
  ext u
  exact (hgen n w u).1

/-- A backward fibre of `R` is a forward fibre of the opposite one-step relation. -/
theorem fib_negNatCast_eq {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    (w : W) (n : ℕ) :
    TaskFrame.Fib R w (-(n : ℤ)) = {u | iter (Function.swap E) n w u} := by
  ext u
  rw [TaskFrame.mem_Fib, (hgen n w u).2]
  exact (iter_swap n w u).symm

/-- A segment at natural offsets is a subsingleton, by `mid_unique`. -/
theorem seg_natCast_subsingleton {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hF : IsOrientedForest E)
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    (w v : W) (m n : ℕ) : (TaskFrame.Seg R w v (m : ℤ) (n : ℤ)).Subsingleton := by
  intro p hp q hq
  rw [TaskFrame.mem_Seg] at hp hq
  exact mid_unique hF n m w v p q ((hgen m w p).1.mp hp.1) ((hgen n v p).2.mp hp.2)
    ((hgen m w q).1.mp hq.1) ((hgen n v q).2.mp hq.2)

/--
**The segment-subsingleton bridge.** A `TaskFrame.Seg R w v x y` with `0 ≤ x` and `0 ≤ y` —
exactly `TaskFrame.IsSegment`'s proviso — is a subsingleton.

This is report 03 section 1.2's steps 1 and 3, and it is `mid_unique` in disguise: the segment
unfolds to `{u | iter E x.natAbs w u ∧ iter E y.natAbs u v}`, which is the hypothesis shape of
`mid_unique`. Reduction C is step 3 **without** its "two directed paths" argument, which
`mid_unique` has already absorbed.
-/
theorem seg_subsingleton_of_gen {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hF : IsOrientedForest E)
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    (w v : W) {x y : ℤ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (TaskFrame.Seg R w v x y).Subsingleton := by
  obtain ⟨m, hm⟩ : ∃ m : ℕ, x = (m : ℤ) := ⟨x.natAbs, by omega⟩
  obtain ⟨n, hn⟩ : ∃ n : ℕ, y = (n : ℤ) := ⟨y.natAbs, by omega⟩
  subst hm
  subst hn
  exact seg_natCast_subsingleton hF hgen w v m n

/-- The bridge at `ofStepRel E` itself, through `ofStepRel_of_nonneg`/`ofStepRel_of_nonpos`
(which is what `ofStepRel_gen` packages). -/
theorem seg_subsingleton {E : W → W → Prop} (hF : IsOrientedForest E) (w v : W) {x y : ℤ}
    (hx : 0 ≤ x) (hy : 0 ≤ y) : (TaskFrame.Seg (ofStepRel E) w v x y).Subsingleton :=
  seg_subsingleton_of_gen hF ofStepRel_gen w v hx hy

/-! ### Reductions B and C -/

/-- A zero-duration fibre is the singleton of its base point. -/
theorem fib_zero_eq_singleton {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    (a : W) : TaskFrame.Fib R a (0 : ℤ) = {a} := by
  have h : TaskFrame.Fib R a ((0 : ℕ) : ℤ) = {u | iter E 0 a u} := fib_natCast_eq hgen a 0
  rw [Nat.cast_zero] at h
  rw [h]
  ext u
  simp [eq_comm]

/--
**Reduction B.** A family member that is a segment, or a fibre of duration zero, is a
subsingleton, so Reduction A closes the goal outright. Together with Reduction C this leaves only
the case in which every member is a fibre of nonzero duration, all of one sign.
-/
theorem sInter_nonempty_of_segment_or_zero_member {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hF : IsOrientedForest E)
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    {S : Set (Set W)} (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty) {T : Set W} (hT : T ∈ S)
    (hTkind : TaskFrame.IsSegment R T ∨ ∃ a, T = TaskFrame.Fib R a (0 : ℤ)) :
    (⋂₀ S).Nonempty := by
  refine sInter_nonempty_of_subsingleton_member hd hne hT ?_
  rcases hTkind with ⟨w, v, x, y, hx, hy, hTeq⟩ | ⟨a, hTeq⟩
  · rw [hTeq]
    exact seg_subsingleton_of_gen hF hgen w v hx hy
  · rw [hTeq, fib_zero_eq_singleton hgen a]
    exact Set.subsingleton_singleton

/--
**Reduction C.** If the family has a member that is a fibre of nonnegative duration *and* a
member that is a fibre of nonpositive duration, then directedness' witness inside their
intersection sits inside a **segment**, hence is a nonempty subsingleton member, and Reduction A
closes the goal.

This is where the all-backward case stops being a separate case: once both signs occur the
family is closed outright, so the remaining cases are "every member a forward fibre" and "every
member a backward fibre", and `isOrientedForest_swap` turns the second into the first.
-/
theorem sInter_nonempty_of_mixed_sign_fibres {R : W → ℤ → W → Prop} {E : W → W → Prop}
    (hF : IsOrientedForest E)
    (hgen : ∀ (n : ℕ) (w u : W),
      (R w (n : ℤ) u ↔ iter E n w u) ∧ (R w (-(n : ℤ)) u ↔ iter E n u w))
    {S : Set (Set W)} (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty)
    {T₁ T₂ : Set W} (hT₁ : T₁ ∈ S) (hT₂ : T₂ ∈ S)
    {w v : W} {x y : ℤ} (hx : 0 ≤ x) (hy : y ≤ 0)
    (hT₁eq : T₁ = TaskFrame.Fib R w x) (hT₂eq : T₂ = TaskFrame.Fib R v y) :
    (⋂₀ S).Nonempty := by
  obtain ⟨S', hS'mem, hS'sub⟩ := hd T₁ hT₁ T₂ hT₂
  refine sInter_nonempty_of_subsingleton_member hd hne hS'mem ?_
  have hmemSeg : ∀ u, u ∈ T₁ ∩ T₂ → u ∈ TaskFrame.Seg R w v x (-y) := by
    intro u hu
    rw [hT₁eq, hT₂eq] at hu
    rw [TaskFrame.mem_Seg, neg_neg]
    exact ⟨hu.1, hu.2⟩
  intro p hp q hq
  exact seg_subsingleton_of_gen hF hgen w v hx (by omega)
    (hmemSeg p (hS'sub hp)) (hmemSeg q (hS'sub hq))

end FormalSystem.Semantics
