/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PartialHistory

/-!
# Gluing two convex histories along a nonempty overlap

The paper's Gluing lemma `app:gluing`, in full generality. Two convex histories `τ₁` and `τ₂`
over a task frame `F`, whose domains share at least one point and which agree at every shared
point, have a union `τ₁ ∪ τ₂` that is the **unique** convex history on the union of the two
domains restricting to each of them. That is `gluing_clause`, with `convexGlue` the history it
exhibits.

The statement lives here, at the convex-history layer, rather than inside any of the special
cases the tree already carries: the two closed-interval seam gluings in
`Semantics/Presheaf/Sheaf.lean` and `Semantics/Presheaf/Ray.lean`, and the directed-family
gluing in `Semantics/Presheaf/Directed.lean`. `app:gluing` is what the convex-history layer
actually consumes — the pasting operation `ρ ⌢_z σ` of the paper's cut argument is one instance
of it — so it is stated once, at the layer that uses it, and the special cases keep their own
proofs (see the Implementation Notes).

## The paper's proof, as a step map

`app:gluing`'s proof runs in four movements, and each is a separate declaration here:

1. *Well-definedness on the overlap.* The paper observes that `τ₁ ∪ τ₂` is a function because the
   two agree on `X₁ ∩ X₂`. Here that is discharged by construction: `convexGlue`'s `states` field
   is a `dite` on `τ₁.domain t`, so it is a function before anything is proved, and the agreement
   hypothesis is spent instead in `convexGlue_states_right`, the one reading equation that needs
   it.
2. *Convexity of `X₁ ∪ X₂`.* `isConvex_union`, the paper's argument verbatim: for `a ≤ b ≤ c` with
   `a ∈ X₁` and `c ∈ X₂`, compare `b` against the fixed overlap point `z` and land in whichever
   of the two convex domains covers it.
3. *The constraint `τ(x) ⇒_{y-x} τ(y)`.* Inherited from `τᵢ` when both times lie in one domain;
   `rel_mixed_left` and `rel_mixed_right` otherwise, each of which either slides a time into the
   other domain by convexity or composes through `z` by *Compositionality*, via
   `PartialHistory.rel_across_seam`. `convexGlue`'s `respects_task` field assembles the four
   cases.
4. *Uniqueness.* `convexGlue_unique`: anything with the right domain extending both agrees with
   `τ₁` on `X₁` and with `τ₂` on `X₂`, hence with the glued history everywhere, hence is equal to
   it by `partialHistory_ext`.

The vocabulary is `def:world-history`'s (verbatim: "A \textit{convex history} is any partial
history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever $x, z \in X$ and
$x < y < z$", and "A partial history $\sigma$ \textit{extends} $\tau$ just in case
$\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$"),
carried by `PartialHistory.IsConvex` and `PartialHistory.Extends`.

## Main Definitions

- `convexGlue` — the glued convex history `τ₁ ∪ τ₂`, left-biased on `τ₁`: its state at `t` is
  `τ₁`'s where `τ₁.domain t`, and `τ₂`'s otherwise
- `decPastRay` — the decidability instance the ray witness needs at its call site

## Main Results

- `isConvex_union` — convexity of the union domain, at **no** frame constraint and **no**
  decidability
- `rel_mixed_left`, `rel_mixed_right` — the two mixed-pair seam steps, the only place
  *Compositionality* is used
- `convexGlue_domain`, `convexGlue_mem_left`, `convexGlue_mem_right` — the domain readings
- `convexGlue_states_left`, `convexGlue_states_not_left` — the two branches of the `dite`,
  literally `dif_pos` and `dif_neg`
- `convexGlue_states_right` — the right-hand reading, the one declaration that consumes the
  agreement hypothesis
- `convexGlue_isConvex`, `convexGlue_extends_left`, `convexGlue_extends_right` — the glued
  history is convex and restricts to each argument
- `convexGlue_unique` — uniqueness, at **no** frame constraint, **no** convexity and **no**
  overlap
- `gluing_clause` — `app:gluing`, with the overlap point explicit
- `gluing_clause_of_overlap` — `app:gluing` under the paper's own hypothesis `X₁ ∩ X₂ ≠ ∅`
- `pastRay_isConvex`, `futRay_isConvex`, `convexGlue_rays_isTotal`,
  `convexGlue_rays_states_past` — the ray witness: the paper's `ρ ⌢_z σ` exhibited as this
  gluing at two ray domains, total and reading as `ρ` below the seam

## Implementation Notes

**`DecidablePred τ₁.domain` is what Lean charges for defining a function by cases on a union.**
The paper's `τ₁ ∪ τ₂` is a set-theoretic union of graphs; Lean's `convexGlue` has to produce a
`states` field, a *function into a `Type`*, and deciding which of the two arguments supplies the
state at `t` means eliminating the two-constructor `Prop` `τ₁.domain t ∨ τ₂.domain t` into a
`Type`. Mathlib charges the same toll at the same place — `Set.piecewise` and
`PartialEquiv.piecewise` both take a `DecidablePred` on the splitting set — so this is the
idiomatic encoding of a case split on a union, not a weakening of the paper's ZF-level claim.
Every domain this tree and the paper actually glue supplies the instance for free from the
frame's `LinearOrder`: closed intervals, rays, and translates of both. Three escapes were
considered and rejected:

* `Classical.propDecidable` reinstates `Classical.choice` in the axiom set, destroying the pin
  `rmk:choice` asks for and this module exists to land.
* Unique choice — deriving the function from the fact that the value is uniquely determined — is
  unavailable in Lean 4 without `Classical.choice`.
* A disjointification (restrict `τ₂` to the complement of `τ₁.domain` first, as
  `PlusLanguage/PlusPasting.lean`'s `pasteAt` does at a seam) does not generalize: with
  `X₁ = [0,10]`, `X₂ = [5,6]` and `z = 5` the disjointified predicate is `[0,6]`, not `X₁ ∪ X₂`.

**The backwards-orientation branches go through `TaskFrame.reflection_of_ne`, never
`FrameOver.reflection`.** `respects_task` is unconditional, so two of its four cases arrive with
the times in the wrong order and have to be flipped. The *off-zero* reflection law
`TaskFrame.reflection_of_ne` closes them at no frame constraint; the unrestricted
`FrameOver.reflection` closes exactly the same goals and measures `Classical.choice`. Swapping
one for the other during a later cleanup would leave the build green while silently destroying
the choice-free record below — which is why both declarations are pinned by `C14` in
`scripts/check-module-invariants.sh` and the build fails the moment the measured axiom set moves.
The `t - s ≠ 0` side condition the off-zero law needs comes from the domain-membership asymmetry
of the branch itself, by `sub_ne_zero_of_ne`.

**Measured axiom profile.** `#print axioms`, as pinned:

| Declaration | Axioms |
| --- | --- |
| `isConvex_union`, `pastRay_isConvex`, `futRay_isConvex`, `decPastRay` | `[propext]` |
| every other declaration in this module | `[propext, Quot.sound]` |

`Classical.choice` appears in none of them, which is `rmk:choice`'s claim for `app:gluing`. The
import closure is evidence of the same thing by a second route: this module imports
`Semantics/PartialHistory.lean` and nothing else, so it provably cannot reach the `Extension/`
cluster, where Zorn's lemma enters.

**The construction is left-biased, and the paper's "relabeling if necessary" is not a symmetry of
it.** `convexGlue` reads `τ₁` wherever `τ₁` is defined, so the two arguments are not
interchangeable at the level of the definition — `convexGlue … τ₁ τ₂ …` and `convexGlue … τ₂ τ₁ …`
are distinct terms, equal only by uniqueness. Where the paper relabels, the proofs here take a
`Prop`-level `le_total` or `by_cases` split instead, which is why `rel_mixed_left` and
`rel_mixed_right` are two declarations rather than one applied twice.

**The three landed special cases are left independent, by decision.** `Presheaf.sheaf_clause`,
`Ray.seamGlue` and `Presheaf.directed_gluing_clause` are **not** re-derived from `convexGlue`:

* The two seam cases *are* instances, and that claim is discharged by **witness**, in the
  `RayInstance` section below, rather than by replacing their proofs. Re-deriving them would
  exchange their own `dite` tests for `τ₁.domain z`, and `Sheaf.lean`'s Implementation Notes
  record that `glue_states_le` / `glue_states_not_le` being *literally* `dif_pos` / `dif_neg` is
  load-bearing downstream.
* `Presheaf.directed_gluing_clause` is independent as a matter of mathematics, not of filing. It
  measures `Classical.choice`, because a directed family of arbitrary cardinality genuinely needs
  *Saturation* — `app:gluing`'s own ℚ counterexample is what shows the two-member case is the
  special one.

The optional bridge equation `paste ρ σ z hsame = ⟨convexGlue …⟩`, in the shape of
`PlusLanguage/PlusPasting.lean`'s existing `paste_eq_pasteAt`, would turn the ray witness into an
equation. It is a strictly additive follow-up, deferred, and must touch neither `Sheaf.lean` nor
`Ray.lean`.

**Relation to the limit presentation of `H_F`.** Reading the convex histories as a limit of
behavior sections makes a compatible family of sections exactly a gluing datum, of which this is
the two-member case. That is a different statement, with a dependency in neither direction: it
quantifies over a diagram, where `app:gluing` fixes two histories and one overlap point, and it
is not folded in here.

## References

* JPL paper `app:gluing` — the Gluing lemma this module proves, cited by name. The repository
  record carries it as a `LIVE-UNPINNED` row, so it is deliberately not block-quoted here
* JPL paper `rmk:choice` — the choice-freeness claim pinned by `C14` on `convexGlue` and
  `gluing_clause`
* JPL paper `def:world-history` — partial, convex and world histories, and extension; the two
  verbatim clauses quoted above
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `IsConvex`, `IsTotal`,
  `Extends`, `restrict`, `partialHistory_ext`, and `rel_across_seam`, the single home of the seam
  argument this module's mixed-pair steps instantiate
* `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.Compositional` and the off-zero reflection
  law `TaskFrame.reflection_of_ne`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — the closed-interval seam case, left independent
* `FormalSystem/Semantics/Presheaf/Ray.lean` — the ray-layer seam case, left independent and
  witnessed below
* `FormalSystem/Semantics/Presheaf/Directed.lean` — the directed-family case, independent as
  mathematics: it needs *Saturation*

## Tags

gluing · convex-history · overlap · choice-free · app:gluing
-/

namespace FormalSystem.Semantics.PartialHistory

variable {F : TaskFrame}

/-! ## Convexity of the union domain -/

/-- Step 2 of `app:gluing`'s proof: the union of two convex domains sharing a point is convex.
For `a ≤ b ≤ c` with `a` and `c` in different domains, compare `b` against the shared point `z`
and apply convexity on whichever side covers it. No frame constraint, no decidability. -/
theorem isConvex_union {τ₁ τ₂ : PartialHistory F} (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z) :
    ∀ a c : F.Duration, (τ₁.domain a ∨ τ₂.domain a) → (τ₁.domain c ∨ τ₂.domain c) →
      ∀ b : F.Duration, a ≤ b → b ≤ c → (τ₁.domain b ∨ τ₂.domain b) := by
  intro a c ha hc b hab hbc
  rcases ha with ha | ha <;> rcases hc with hc | hc
  · exact Or.inl (h₁ a c ha hc b hab hbc)
  · rcases le_total b z with hbz | hzb
    · exact Or.inl (h₁ a z ha hz₁ b hab hbz)
    · exact Or.inr (h₂ z c hz₂ hc b hzb hbc)
  · rcases le_total b z with hbz | hzb
    · exact Or.inr (h₂ a z ha hz₂ b hab hbz)
    · exact Or.inl (h₁ z c hz₁ hc b hzb hbc)
  · exact Or.inr (h₂ a c ha hc b hab hbc)

/-! ## The two mixed-pair seam steps -/

/-- Step 3 of `app:gluing`'s proof, the mixed pair left-to-right: `x` in the first domain, `y` in
the second only. Either `x` slides into the second domain by convexity, or `x ≤ z ≤ y` and the
two constraints compose through the shared state by *Compositionality*. -/
theorem rel_mixed_left {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₁ : τ₁.domain x) (hy₂ : τ₂.domain y) (hy₁ : ¬ τ₁.domain y)
    (hxy : x ≤ y) :
    F.TaskRel (τ₁.states x hx₁) (y - x) (τ₂.states y hy₂) := by
  have hzy : z ≤ y := by
    by_contra hc
    exact hy₁ (h₁ x z hx₁ hz₁ y hxy (le_of_lt (not_le.mp hc)))
  rcases le_total x z with hxz | hzx
  · exact PartialHistory.rel_across_seam hcomp hz₁ hz₂ (hagree z hz₁ hz₂) hx₁ hy₂ hxz hzy
      (by rw [add_comm]; exact (sub_add_sub_cancel y z x).symm)
  · have hx₂ : τ₂.domain x := h₂ z y hz₂ hy₂ x hzx hxy
    rw [hagree x hx₁ hx₂]
    exact τ₂.respects_task x y hx₂ hy₂

/-- The mirror of `rel_mixed_left`: `x` in the second domain only, `y` in the first. -/
theorem rel_mixed_right {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₂ : τ₂.domain x) (hy₁ : τ₁.domain y) (hx₁ : ¬ τ₁.domain x)
    (hxy : x ≤ y) :
    F.TaskRel (τ₂.states x hx₂) (y - x) (τ₁.states y hy₁) := by
  have hxz : x ≤ z := by
    by_contra hc
    exact hx₁ (h₁ z y hz₁ hy₁ x (le_of_lt (not_le.mp hc)) hxy)
  rcases le_total z y with hzy | hyz
  · exact PartialHistory.rel_across_seam hcomp hz₂ hz₁ (hagree z hz₁ hz₂).symm hx₂ hy₁ hxz hzy
      (by rw [add_comm]; exact (sub_add_sub_cancel y z x).symm)
  · have hy₂ : τ₂.domain y := h₂ x z hx₂ hz₂ y hxy hyz
    rw [hagree y hy₁ hy₂]
    exact τ₂.respects_task x y hx₂ hy₂

/-! ## The glued convex history -/

/--
The glued convex history `τ₁ ∪ τ₂` of `app:gluing`, **left-biased on `τ₁`**: its state at `t` is
`τ₁`'s wherever `τ₁.domain t` holds, and `τ₂`'s otherwise.

The `DecidablePred τ₁.domain` binder is what Lean charges for a function defined by cases on a
union — see this module's Implementation Notes for the Mathlib precedent and the three rejected
escapes. The two backwards-orientation cases of the unconditional `respects_task` field go
through `TaskFrame.reflection_of_ne`, the *off-zero* law, and must not be rerouted through
`FrameOver.reflection`, which closes the same goals and measures `Classical.choice`.
-/
def convexGlue (hcomp : TaskFrame.Compositional F.TaskRel) (τ₁ τ₂ : PartialHistory F)
    [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    PartialHistory F where
  domain := fun t => τ₁.domain t ∨ τ₂.domain t
  nonempty_domain := ⟨z, Or.inl hz₁⟩
  states := fun t ht =>
    if h : τ₁.domain t then τ₁.states t h else τ₂.states t (ht.resolve_left h)
  respects_task := by
    intro s t hs ht
    by_cases hs₁ : τ₁.domain s <;> by_cases ht₁ : τ₁.domain t
    · rw [dif_pos hs₁, dif_pos ht₁]; exact τ₁.respects_task s t hs₁ ht₁
    · have ht₂ : τ₂.domain t := ht.resolve_left ht₁
      rw [dif_pos hs₁, dif_neg ht₁]
      rcases le_total s t with hst | hts
      · exact rel_mixed_left hcomp h₁ h₂ hz₁ hz₂ hagree hs₁ ht₂ ht₁ hst
      · have hne : t - s ≠ 0 := sub_ne_zero_of_ne (fun h : t = s => ht₁ (h.symm ▸ hs₁))
        rw [TaskFrame.reflection_of_ne F hne, neg_sub]
        exact rel_mixed_right hcomp h₁ h₂ hz₁ hz₂ hagree ht₂ hs₁ ht₁ hts
    · have hs₂ : τ₂.domain s := hs.resolve_left hs₁
      rw [dif_neg hs₁, dif_pos ht₁]
      rcases le_total s t with hst | hts
      · exact rel_mixed_right hcomp h₁ h₂ hz₁ hz₂ hagree hs₂ ht₁ hs₁ hst
      · have hne : t - s ≠ 0 := sub_ne_zero_of_ne (fun h : t = s => hs₁ (h ▸ ht₁))
        rw [TaskFrame.reflection_of_ne F hne, neg_sub]
        exact rel_mixed_left hcomp h₁ h₂ hz₁ hz₂ hagree ht₁ hs₂ hs₁ hts
    · rw [dif_neg hs₁, dif_neg ht₁]
      exact τ₂.respects_task s t (hs.resolve_left hs₁) (ht.resolve_left ht₁)

/-! ## Reading equations, convexity, restriction identities, uniqueness -/

section Readings

variable {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
  [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex) {z : F.Duration}
  (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
  (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
    τ₁.states t p = τ₂.states t q)

/-- The glued domain is the union of the two, on the nose. -/
theorem convexGlue_domain (t : F.Duration) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t ↔ (τ₁.domain t ∨ τ₂.domain t) := Iff.rfl

/-- Membership in the glued domain, from the left. -/
theorem convexGlue_mem_left {t : F.Duration} (h : τ₁.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := Or.inl h

/-- Membership in the glued domain, from the right. -/
theorem convexGlue_mem_right {t : F.Duration} (h : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := Or.inr h

/-- The left branch of the construction's `dite`, literally `dif_pos`. -/
theorem convexGlue_states_left {t : F.Duration}
    {ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : τ₁.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₁.states t h := dif_pos h

/-- The right branch of the construction's `dite`, literally `dif_neg`. -/
theorem convexGlue_states_not_left {t : F.Duration}
    {ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : ¬ τ₁.domain t)
    (h' : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := dif_neg h

/-- The right-hand reading **where the agreement hypothesis is consumed**: on the overlap the
`dite` lands in the left branch, and only `hagree` closes the gap to `τ₂`. -/
theorem convexGlue_states_right {t : F.Duration}
    (ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t) (h' : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := by
  by_cases h : τ₁.domain t
  · rw [convexGlue_states_left hcomp h₁ h₂ hz₁ hz₂ hagree h]; exact hagree t h h'
  · exact convexGlue_states_not_left hcomp h₁ h₂ hz₁ hz₂ hagree h h'

/-- The glued history is convex, by `isConvex_union`. -/
theorem convexGlue_isConvex : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).IsConvex :=
  isConvex_union h₁ h₂ hz₁ hz₂

/-- The glued history extends `τ₁`. -/
theorem convexGlue_extends_left : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₁ :=
  ⟨fun _ ht => Or.inl ht, fun _ ht => dif_pos ht⟩

/-- The glued history extends `τ₂`. The `agree` component is supplied as a named lemma fed as a
field: the `dite` is not visible through `.states` at implicit transparency, so a `refine` plus
`rw [dif_…]` shape does not close it. -/
theorem convexGlue_extends_right : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₂ :=
  { subset := fun _ ht => convexGlue_mem_right hcomp h₁ h₂ hz₁ hz₂ hagree ht
    agree := fun _t ht => convexGlue_states_right hcomp h₁ h₂ hz₁ hz₂ hagree _ ht }

/-- Uniqueness, step 4 of `app:gluing`'s proof: **no frame constraint, no convexity, no
overlap**. Anything with the union as its domain extending both arguments is the glued history. -/
theorem convexGlue_unique (υ : PartialHistory F)
    (hdom : ∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t))
    (he₁ : υ.Extends τ₁) (he₂ : υ.Extends τ₂) :
    υ = convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree := by
  refine partialHistory_ext (funext fun t => propext (hdom t)) ?_
  intro r hr hr'
  by_cases h : τ₁.domain r
  · rw [convexGlue_states_left hcomp h₁ h₂ hz₁ hz₂ hagree h]
    exact he₁.agree r h
  · rw [convexGlue_states_not_left hcomp h₁ h₂ hz₁ hz₂ hagree h (hr'.resolve_left h)]
    exact he₂.agree r (hr'.resolve_left h)

-- `linter.unusedDecidableInType`, scoped to this declaration. The clause is an `∃!` over
-- `PartialHistory F`, so `[DecidablePred τ₁.domain]` is absent from its *type*, which is all this
-- linter reads; the proof needs it, because it exhibits `convexGlue`. It cannot be `omit`ted — the
-- proof reaches it through `convexGlue`'s own instance argument rather than by name, so `omit` is
-- refused as a referenced section variable — and the linter's suggested remedy, `classical`, is
-- exactly the escape this module rejects: it reinstates `Classical.choice` and destroys the
-- choice-free record `rmk:choice` asks for. A scoped suppression is therefore the only route.
set_option linter.unusedDecidableInType false in
include hcomp h₁ h₂ hz₁ hz₂ hagree in
/-- `app:gluing` itself, with the overlap point explicit: the union of two convex histories
agreeing at a shared point is the **unique** convex history on the union of their domains
restricting to each of them.

Paper: `app:gluing`
-/
theorem gluing_clause :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ :=
  ⟨convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree,
   ⟨convexGlue_domain hcomp h₁ h₂ hz₁ hz₂ hagree,
    convexGlue_isConvex hcomp h₁ h₂ hz₁ hz₂ hagree,
    convexGlue_extends_left hcomp h₁ h₂ hz₁ hz₂ hagree,
    convexGlue_extends_right hcomp h₁ h₂ hz₁ hz₂ hagree⟩,
   fun _ h => convexGlue_unique hcomp h₁ h₂ hz₁ hz₂ hagree _ h.1 h.2.2.1 h.2.2.2⟩

end Readings

/-! ## The clause under the paper's own hypothesis `X₁ ∩ X₂ ≠ ∅`

The overlap witness has to be an explicit parameter of the *construction* `convexGlue` —
extracting it from an existential would need `Classical.choose`. The **clause**, however, is a
`Prop`, so the existential form is available choice-free by ordinary `Exists.elim`.
-/

-- `linter.unusedDecidableInType`, scoped to this declaration, for the reason recorded at
-- `gluing_clause`: the instance is absent from the `∃!` statement and required by the proof, and
-- dropping it would force `classical`.
set_option linter.unusedDecidableInType false in
/-- `app:gluing` under the paper's own hypothesis that the overlap is nonempty. -/
theorem gluing_clause_of_overlap {τ₁ τ₂ : PartialHistory F}
    (hcomp : TaskFrame.Compositional F.TaskRel) [DecidablePred τ₁.domain]
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    (hov : ∃ z : F.Duration, τ₁.domain z ∧ τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ := by
  obtain ⟨z, hz₁, hz₂⟩ := hov
  exact gluing_clause hcomp h₁ h₂ hz₁ hz₂ hagree

/-! ## The paper's `ρ ⌢_z σ` as an instance: ray domains

The seam cases this tree already carries keep their own proofs (see the Implementation Notes), so
the claim that they *are* instances of `app:gluing` is discharged by witness instead: the general
gluing at a past ray of `ρ` and a future ray of `σ` is total and reads as `ρ` below the seam,
which is exactly the paper's pasting operation.
-/

section RayInstance

variable (ρ σ : WorldHistory F) (z : F.Duration)

/-- The past ray of a possible world is convex. -/
theorem pastRay_isConvex : (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).IsConvex :=
  fun _ _ _ hc _ _ hyc => le_trans hyc hc

/-- The future ray of a possible world is convex. -/
theorem futRay_isConvex : (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩).IsConvex :=
  fun _ _ ha _ _ hay _ => le_trans ha hay

/-- The decidability instance `convexGlue` needs at a past ray. Required, not cosmetic: a
restriction's `domain` does not reduce to the restricting predicate at instance-reducible
transparency, so the instance is not found without this declaration. -/
instance decPastRay :
    DecidablePred (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).domain :=
  fun t => inferInstanceAs (Decidable (t ≤ z))

/-- The paper's `ρ ⌢_z σ` is the general gluing at two ray domains, and it is **total**. -/
theorem convexGlue_rays_isTotal (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) :
    (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).IsTotal :=
  fun t => le_total t z

/-- Below the seam the ray gluing reads as `ρ`. -/
theorem convexGlue_rays_states_past (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) (t : F.Duration) (ht : t ≤ z)
    (hmem : (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).domain t) :
    (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).states t hmem
      = ρ.state t :=
  convexGlue_states_left _ _ _ _ _ _ ht

end RayInstance

end FormalSystem.Semantics.PartialHistory

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
