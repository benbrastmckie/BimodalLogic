/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Order.Preorder.Chain
import Mathlib.Data.Set.Lattice

/-!
# Ball spaces: nests, spherical completeness, and the cofinal-nest reduction

A **ball space** on a type `W`, in the sense of Ćmiel, Kuhlmann and Kuhlmann, is a distinguished
collection of subsets of `W` — the *balls* — and the hierarchy `S₁`, `S₁ᵈ`, `S₂`, … grades how
much intersection behaviour that collection has. Mathlib carries **no ball-space API at all**: a
search for `spherically` returns nothing relevant, and its `Sierpinski*`-style near-misses are
about unrelated notions. This file supplies the bottom of that hierarchy.

Everything here is stated over an arbitrary ball predicate `P : Set W → Prop`, with no structure
on `W` beyond its being a type. That is deliberate and is the criterion that put the file in
`ForMathlib/`: nothing below mentions a relation, a frame, or a duration type, so the material is
upstreamable as it stands.

## Main definitions

* `Order.IsNest` — a **nest**: a nonempty `⊆`-chain of sets.
* `Order.SphericallyComplete` — the condition `S₁` over the ball space `{s | P s}`: every nest of
  nonempty balls has nonempty intersection.
* `Order.HasCofinalNest` — a family of sets contains a nest refining every member.

## Main results

* `Order.IsNest.exists_subset_inter` — a nest is `⊇`-directed in the members-witness sense. This
  is the entire mathematical content of the hierarchy's implication `S₁ᵈ → S₁`.
* `Order.sInter_nonempty_of_sphericallyComplete` — **the reduction**: spherical completeness plus
  a cofinal nest plus nonempty members gives a point common to the whole family.

## Dependency rule

Nothing under `FormalSystem/ForMathlib/` imports `FormalSystem.*`; the import direction is
strictly `Mathlib → ForMathlib → FormalSystem.* → downstream`. That rule is why the instantiation
at a task relation's own ball space of fibers and segments — which necessarily mentions
`TaskFrame.IsFiber` and `TaskFrame.IsSegment` — lives in `FormalSystem/Semantics/TaskFrame.lean`
rather than here.
-/

namespace Order

/--
A **nest**: a nonempty `⊆`-chain of sets.

The nonemptiness of the family is part of the notion, matching the way a `⊇`-directed family
carries its own nonemptiness downstream; the nonemptiness of the *members* is a separate
hypothesis wherever it is needed.

Paper: — (general order-theoretic material staged for upstreaming; the manuscript has no anchor
for it)
-/
def IsNest {W : Type*} (S : Set (Set W)) : Prop :=
  S.Nonempty ∧ IsChain (· ⊆ ·) S

/--
A nest is `⊇`-directed in the members-witness sense: of any two members, the smaller refines both.

**This is the entire content of the ball-space hierarchy's implication `S₁ᵈ → S₁`**, stated in the
members-witness shape so that a project-side instantiation needs no directed-family definition of
its own.

Paper: — (general order-theoretic material staged for upstreaming; the manuscript has no anchor
for it)
-/
theorem IsNest.exists_subset_inter {W : Type*} {S : Set (Set W)} (h : IsNest S) :
    ∀ s₁ ∈ S, ∀ s₂ ∈ S, ∃ s' ∈ S, s' ⊆ s₁ ∩ s₂ := by
  intro s₁ h₁ s₂ h₂
  rcases eq_or_ne s₁ s₂ with rfl | hne
  · exact ⟨s₁, h₁, Set.subset_inter le_rfl le_rfl⟩
  · rcases h.2 h₁ h₂ hne with hle | hle
    · exact ⟨s₁, h₁, Set.subset_inter le_rfl hle⟩
    · exact ⟨s₂, h₂, Set.subset_inter hle le_rfl⟩

/--
**Spherical completeness** `S₁`, over the ball space `{s | P s}`: every nest of nonempty balls has
nonempty intersection.

This is the standard condition of the Ćmiel–Kuhlmann–Kuhlmann hierarchy, stated over an arbitrary
ball predicate so that it is upstreamable. Its `⊇`-directed strengthening `S₁ᵈ` replaces the nest
by a `⊇`-directed system of balls; `IsNest.exists_subset_inter` is what makes `S₁ᵈ → S₁`
immediate at any instantiation.

Paper: — (general order-theoretic material staged for upstreaming; the manuscript has no anchor
for it)
-/
def SphericallyComplete {W : Type*} (P : Set W → Prop) : Prop :=
  ∀ S : Set (Set W), IsNest S → (∀ s ∈ S, P s ∧ s.Nonempty) → (⋂₀ S).Nonempty

/--
A family of sets containing a nest that refines every member.

This is the exact indexing property that makes the nest form as strong as the directed form **at
one family**. It is a property of the family, never of the ambient structure — which is why a
hypothesis of this shape belongs on a theorem rather than in a definition of the structure the
family is drawn from.

Paper: — (general order-theoretic material staged for upstreaming; the manuscript has no anchor
for it)
-/
def HasCofinalNest {W : Type*} (F : Set (Set W)) : Prop :=
  ∃ C ⊆ F, IsNest C ∧ ∀ c ∈ F, ∃ c' ∈ C, c' ⊆ c

/--
**The reduction.** Spherical completeness plus a cofinal nest plus nonempty members gives a point
common to the whole family — no frame, no relation, no duration type.

Apply `S₁` to the cofinal nest to get a point of its intersection; every member of the family is
refined by some member of the nest, so that point lies in it too.

Paper: — (general order-theoretic material staged for upstreaming; the manuscript has no anchor
for it)
-/
theorem sInter_nonempty_of_sphericallyComplete {W : Type*} {P : Set W → Prop}
    (hS1 : SphericallyComplete P) {F : Set (Set W)} (hP : ∀ c ∈ F, P c)
    (hne : ∀ c ∈ F, c.Nonempty) (hcof : HasCofinalNest F) : (⋂₀ F).Nonempty := by
  obtain ⟨C, hCF, hCnest, hcofin⟩ := hcof
  obtain ⟨u, hu⟩ := hS1 C hCnest fun s hs => ⟨hP s (hCF hs), hne s (hCF hs)⟩
  refine ⟨u, Set.mem_sInter.2 fun c hc => ?_⟩
  obtain ⟨c', hc', hsub⟩ := hcofin c hc
  exact hsub (Set.mem_sInter.1 hu c' hc')

end Order
