/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Topology.Baire.CompleteMetrizable
import Mathlib.Topology.Baire.Lemmas
import Mathlib.Topology.Order.Monotone
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas

/-!
# Sierpiński's theorem: a countable closed partition of the line is trivial

Sierpiński's theorem says that a continuum cannot be partitioned into countably many — but more
than one — nonempty pairwise disjoint closed sets. This file proves the real-line case in the
form a consumer actually wants:

> a map `h : ℝ → V` whose range is countable and all of whose level sets are closed is constant.

**Mathlib does not carry this.** Every `Sierpinski*` declaration in `Mathlib/Topology/` is about
the Sierpiński *space* (the two-point space with one open point), not about closed partitions of
a continuum, so the theorem is proved here from scratch.

## Main definitions

* `Sierpinski.levelSet h a` — the level set `{t | h t = a}`, at an arbitrary topological space.
* `Sierpinski.locallyConstantLocus h` — the union of the interiors of the level sets: the points
  at which `h` is locally constant.

## Main results

* `Sierpinski.const_of_isPreconnected` — on a preconnected subset of the locally-constant locus,
  `h` is constant. Uses only openness and preconnectedness, so it is stated at an arbitrary
  topological space.
* `Sierpinski.const_of_isClosed_levelSet` — Sierpiński's theorem at a countable codomain.
* `Sierpinski.const_of_countable_range` — the sharp form: only the *range* has to be countable.

## The proof

The locally-constant locus `U` is open, being a union of interiors. If `U` is everything then
`ℝ` is connected and `const_of_isPreconnected` finishes outright.

Otherwise `Uᶜ` is nonempty and closed, hence a complete metric space, hence Baire. The countably
many closed traces `Subtype.val ⁻¹' levelSet h a` cover it, so
`nonempty_interior_of_iUnion_of_closed` produces a value `a`, a point `t ∈ Uᶜ` and a radius
`r > 0` such that every point of `Uᶜ` within `r` of `t` carries the value `a`.

That value then propagates across the *whole* window `(t - r, t + r)`, including the points that
lie in `U`: given such a point `x < t`, the infimum `c` of `Uᶜ ∩ [x, t]` lies in `Uᶜ`
(`IsClosed.csInf_mem`) and satisfies `x < c`, so `[x, c)` is a preconnected subset of `U` on
which `const_of_isPreconnected` makes `h` constant, and the closedness of `levelSet h (h x)`
carries that value to the endpoint `c`, where it must equal `a`. The case `t < x` is symmetric,
with `IsClosed.csSup_mem`. Hence `h` is constantly `a` on an open neighbourhood of `t`, so
`t ∈ U` — contradicting `t ∈ Uᶜ`.

Note that the argument never needs `Uᶜ` to be perfect, which is where the textbook proof of the
general theorem spends most of its effort; on the line, the sup/inf propagation replaces it.

## Implementation notes

The helper layer (`levelSet`, `locallyConstantLocus`, `mem_levelSet`,
`isOpen_locallyConstantLocus`, `mem_locallyConstantLocus_iff`, `const_of_isPreconnected`) is
stated at an arbitrary topological space, since it uses nothing else. The two main theorems are
stated at `ℝ`: they use Baire together with the order structure of the line.
-/

namespace Sierpinski

variable {α : Type*} [TopologicalSpace α] {W : Type*}

/-- The level set of `a` under `h`: the points where `h` takes the value `a`. -/
def levelSet (h : α → W) (a : W) : Set α := {t | h t = a}

/-- The **locally-constant locus** of `h`: the union of the interiors of its level sets,
equivalently the points at which `h` is constant on a neighbourhood. It is open, and its
complement is where the Baire argument of `const_of_isClosed_levelSet` lives. -/
def locallyConstantLocus (h : α → W) : Set α := ⋃ a, interior (levelSet h a)

omit [TopologicalSpace α] in
/-- Membership in a level set is the defining equation. -/
theorem mem_levelSet {h : α → W} {t : α} {a : W} : t ∈ levelSet h a ↔ h t = a := Iff.rfl

/-- The locally-constant locus is open, being a union of interiors. -/
theorem isOpen_locallyConstantLocus (h : α → W) : IsOpen (locallyConstantLocus h) :=
  isOpen_iUnion fun _ => isOpen_interior

/-- A point lies in the locally-constant locus iff it lies in the interior of *its own* level
set: the union over all values collapses to the single relevant one. -/
theorem mem_locallyConstantLocus_iff {h : α → W} {t : α} :
    t ∈ locallyConstantLocus h ↔ t ∈ interior (levelSet h (h t)) := by
  constructor
  · rintro ⟨s, ⟨a, rfl⟩, hts⟩
    have ha : h t = a := mem_levelSet.mp (interior_subset hts)
    subst ha; exact hts
  · intro ht; exact Set.mem_iUnion.mpr ⟨h t, ht⟩

/-- On a preconnected subset of the locally-constant locus, `h` is constant. Proved by splitting
the level-set interiors into "the value at `c₀`" and "all the others", which is a separation of
the subset unless every point carries the value at `c₀`. -/
theorem const_of_isPreconnected {h : α → W} {C : Set α} (hC : IsPreconnected C)
    (hCU : C ⊆ locallyConstantLocus h) {c₀ : α} (hc₀ : c₀ ∈ C) :
    ∀ t ∈ C, h t = h c₀ := by
  by_contra hcon
  push Not at hcon
  obtain ⟨t, htC, hne⟩ := hcon
  set u : Set α := interior (levelSet h (h c₀)) with hu
  set v : Set α := ⋃ a ∈ {a : W | a ≠ h c₀}, interior (levelSet h a) with hv
  have hopenu : IsOpen u := isOpen_interior
  have hopenv : IsOpen v := isOpen_biUnion fun _ _ => isOpen_interior
  have hsub : C ⊆ u ∪ v := by
    intro x hx
    have hx' := mem_locallyConstantLocus_iff.mp (hCU hx)
    by_cases hxa : h x = h c₀
    · left; rw [hu, ← hxa]; exact hx'
    · right; exact Set.mem_biUnion hxa hx'
  have hCu : (C ∩ u).Nonempty := ⟨c₀, hc₀, mem_locallyConstantLocus_iff.mp (hCU hc₀)⟩
  have hCv : (C ∩ v).Nonempty :=
    ⟨t, htC, Set.mem_biUnion hne (mem_locallyConstantLocus_iff.mp (hCU htC))⟩
  obtain ⟨x, _, hxu, hxv⟩ := hC u v hopenu hopenv hsub hCu hCv
  obtain ⟨a, ha, hxa⟩ := Set.mem_iUnion₂.mp hxv
  exact ha ((mem_levelSet.mp (interior_subset hxa)).symm.trans
    (mem_levelSet.mp (interior_subset hxu)))

/--
**Sierpiński's theorem, real-line form.** A map `ℝ → V` with `V` countable and all level sets
closed is constant.

If the locally-constant locus is everything, `ℝ` is connected and `const_of_isPreconnected`
finishes. Otherwise its complement is a nonempty closed — hence complete, hence Baire —
subspace covered by the countably many closed traces of the level sets, so one trace has
interior there: some value `a` is carried by every point of the complement within a radius `r`
of some `t`. A sup/inf argument propagates `a` across the whole of `(t - r, t + r)`, so `h` is
locally constant at `t` after all. See the module docstring for the full outline.
-/
theorem const_of_isClosed_levelSet {V : Type*} [Countable V] (h : ℝ → V)
    (hc : ∀ a, IsClosed (levelSet h a)) : ∀ s t : ℝ, h s = h t := by
  by_contra hcon
  push Not at hcon
  obtain ⟨s₀, t₀, hne⟩ := hcon
  have hBclosed : IsClosed (locallyConstantLocus h)ᶜ :=
    (isOpen_locallyConstantLocus h).isClosed_compl
  rcases Set.eq_empty_or_nonempty (locallyConstantLocus h)ᶜ with hBempty | hBne
  · have hUuniv : locallyConstantLocus h = Set.univ := Set.compl_empty_iff.mp hBempty
    exact hne (const_of_isPreconnected (h := h) isPreconnected_univ (by rw [hUuniv])
      (Set.mem_univ t₀) s₀ (Set.mem_univ s₀))
  · haveI : Nonempty ((locallyConstantLocus h)ᶜ : Set ℝ) := hBne.to_subtype
    haveI : CompleteSpace ((locallyConstantLocus h)ᶜ : Set ℝ) := hBclosed.completeSpace_coe
    have hcov : (⋃ a : V,
        (Subtype.val ⁻¹' (levelSet h a) : Set ((locallyConstantLocus h)ᶜ : Set ℝ)))
        = Set.univ := by
      ext x
      simp only [Set.mem_iUnion, Set.mem_preimage, Set.mem_univ, iff_true]
      exact ⟨h x.1, rfl⟩
    have hclosed : ∀ a : V,
        IsClosed (Subtype.val ⁻¹' (levelSet h a) : Set ((locallyConstantLocus h)ᶜ : Set ℝ)) :=
      fun a => (hc a).preimage continuous_subtype_val
    obtain ⟨a, tB, htint⟩ := nonempty_interior_of_iUnion_of_closed hclosed hcov
    rw [mem_interior_iff_mem_nhds, Metric.mem_nhds_iff] at htint
    obtain ⟨r, hr, hball⟩ := htint
    set t : ℝ := tB.1 with htdef
    have htB : t ∉ locallyConstantLocus h := tB.2
    have hkey : ∀ x : ℝ, x ∉ locallyConstantLocus h → |x - t| < r → h x = a := by
      intro x hxB hxd
      refine mem_levelSet.mp (hball (show
        dist (⟨x, hxB⟩ : ((locallyConstantLocus h)ᶜ : Set ℝ)) tB < r from ?_))
      rw [Subtype.dist_eq, Real.dist_eq]; exact hxd
    have hta : h t = a := hkey t htB (by simpa using hr)
    have hmain : ∀ x ∈ Set.Ioo (t - r) (t + r), h x = a := by
      intro x hx
      by_cases hxB : x ∉ locallyConstantLocus h
      · exact hkey x hxB (by rw [abs_lt]; exact ⟨by linarith [hx.1], by linarith [hx.2]⟩)
      · push Not at hxB
        rcases lt_trichotomy x t with hlt | heq | hgt
        · have hKclosed : IsClosed ((locallyConstantLocus h)ᶜ ∩ Set.Icc x t) :=
            hBclosed.inter isClosed_Icc
          have hKne : ((locallyConstantLocus h)ᶜ ∩ Set.Icc x t).Nonempty :=
            ⟨t, htB, le_of_lt hlt, le_refl t⟩
          have hKbdd : BddBelow ((locallyConstantLocus h)ᶜ ∩ Set.Icc x t) :=
            ⟨x, fun y hy => hy.2.1⟩
          set c := sInf ((locallyConstantLocus h)ᶜ ∩ Set.Icc x t) with hcdef
          have hcK : c ∈ (locallyConstantLocus h)ᶜ ∩ Set.Icc x t := hKclosed.csInf_mem hKne hKbdd
          have hcB : c ∉ locallyConstantLocus h := hcK.1
          have hxc : x < c := lt_of_le_of_ne hcK.2.1 (fun hh => hcB (by rw [← hh]; exact hxB))
          have hct : c ≤ t := hcK.2.2
          have hca : h c = a := hkey c hcB (by rw [abs_lt]; exact ⟨by linarith [hx.1], by linarith⟩)
          have hIco : Set.Ico x c ⊆ locallyConstantLocus h := by
            intro y hy
            by_contra hyU
            exact absurd hy.2 (not_lt.mpr (csInf_le hKbdd ⟨hyU, hy.1,
              le_trans (le_of_lt hy.2) hct⟩))
          have hconst := const_of_isPreconnected isPreconnected_Ico hIco
            (⟨le_refl x, hxc⟩ : x ∈ Set.Ico x c)
          have hcclos : c ∈ closure (Set.Ico x c) := by
            rw [closure_Ico (ne_of_lt hxc)]; exact ⟨le_of_lt hxc, le_refl c⟩
          have hmem : c ∈ levelSet h (h x) :=
            (hc (h x)).closure_subset_iff.mpr (fun y hy => hconst y hy) hcclos
          exact (mem_levelSet.mp hmem).symm.trans hca
        · rw [heq]; exact hta
        · have hKclosed : IsClosed ((locallyConstantLocus h)ᶜ ∩ Set.Icc t x) :=
            hBclosed.inter isClosed_Icc
          have hKne : ((locallyConstantLocus h)ᶜ ∩ Set.Icc t x).Nonempty :=
            ⟨t, htB, le_refl t, le_of_lt hgt⟩
          have hKbdd : BddAbove ((locallyConstantLocus h)ᶜ ∩ Set.Icc t x) :=
            ⟨x, fun y hy => hy.2.2⟩
          set c := sSup ((locallyConstantLocus h)ᶜ ∩ Set.Icc t x) with hcdef
          have hcK : c ∈ (locallyConstantLocus h)ᶜ ∩ Set.Icc t x := hKclosed.csSup_mem hKne hKbdd
          have hcB : c ∉ locallyConstantLocus h := hcK.1
          have hct : t ≤ c := hcK.2.1
          have hcx : c < x := lt_of_le_of_ne hcK.2.2 (fun hh => hcB (by rw [hh]; exact hxB))
          have hca : h c = a := hkey c hcB (by rw [abs_lt]; exact ⟨by linarith, by linarith [hx.2]⟩)
          have hIoc : Set.Ioc c x ⊆ locallyConstantLocus h := by
            intro y hy
            by_contra hyU
            exact absurd hy.1
              (not_lt.mpr (le_csSup hKbdd ⟨hyU, le_trans hct (le_of_lt hy.1), hy.2⟩))
          have hconst := const_of_isPreconnected isPreconnected_Ioc hIoc
            (⟨hcx, le_refl x⟩ : x ∈ Set.Ioc c x)
          have hcclos : c ∈ closure (Set.Ioc c x) := by
            rw [closure_Ioc (ne_of_lt hcx)]; exact ⟨le_refl c, le_of_lt hcx⟩
          have hmem : c ∈ levelSet h (h x) :=
            (hc (h x)).closure_subset_iff.mpr (fun y hy => hconst y hy) hcclos
          exact (mem_levelSet.mp hmem).symm.trans hca
    exact htB (mem_locallyConstantLocus_iff.mpr (by
      rw [hta]
      exact mem_interior.mpr ⟨Set.Ioo (t - r) (t + r), fun y hy => mem_levelSet.mpr (hmain y hy),
        isOpen_Ioo, ⟨by linarith, by linarith⟩⟩))

/-- **Countable-range form of Sierpiński's theorem.** Only the *range* of `f` has to be
countable, not its codomain: corestrict `f` to its range, which is a countable type whose level
sets are the original ones. -/
theorem const_of_countable_range {V : Type*} (f : ℝ → V) (hcount : (Set.range f).Countable)
    (hcl : ∀ a : V, IsClosed (levelSet f a)) : ∀ s t : ℝ, f s = f t := by
  haveI : Countable (Set.range f) := hcount.to_subtype
  have hlev : ∀ a : (Set.range f),
      IsClosed (levelSet (fun t : ℝ => (⟨f t, ⟨t, rfl⟩⟩ : Set.range f)) a) := by
    intro a
    have hset : levelSet (fun t : ℝ => (⟨f t, ⟨t, rfl⟩⟩ : Set.range f)) a = levelSet f a.1 := by
      ext t; exact ⟨fun hh => congrArg Subtype.val hh, fun hh => Subtype.ext hh⟩
    rw [hset]; exact hcl a.1
  intro s t
  exact congrArg Subtype.val (const_of_isClosed_levelSet _ hlev s t)

end Sierpinski
