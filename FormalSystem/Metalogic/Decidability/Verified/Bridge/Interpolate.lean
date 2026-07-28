/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Carrier

/-!
# Interpolation — filling the carrier between the placed branch times

`Bridge/Carrier.lean` ends with `exists_monotone_placement`: a saturated branch's finitely many
times are placed order-faithfully at points `f i` of the carrier `D`. That is not yet a model.
`D` is `ℚ`, `ℤ` or `ℝ`; between two consecutive placed points lie points the branch says nothing
about, and `TruthAt`'s `untl`/`snce` clauses quantify over **all** of `D`, not over the placed
points. Something has to be said at every point of `D`, and it has to be said in a way that the
truth induction can survive.

This file is stage 3 of the semantic bridge (report 02 §5.2): the *interpolation*. It supplies

* the **region structure** on `D` induced by a placement — the partition of the carrier into the
  half-open intervals the placement cuts it into;
* the **extension operator** `regionExtend`, which turns any region-indexed assignment into a
  function **total on `D`**; and
* the **invariance** lemmas: truth at a point of a region agrees with truth at any other point of
  the same region, one lemma per formula constructor.

## The region structure, and why it is `∀ i, (f i ≤ r ↔ f i ≤ r')`

The intended partition is by half-open intervals `[f i, f (i+1))`, together with the initial ray
`(-∞, f i₀)` below every placed point. Rather than index those intervals by a successor operation
on branch times — which would need `f`'s image to be enumerated in order, and would make every
downstream lemma carry an off-by-one — the same partition is defined by its *trace*:

`SameRegion f r r'` iff every placed point lies weakly below `r` exactly when it lies weakly below
`r'`.

Two points are `SameRegion` precisely when no placed point separates them, which is precisely
membership in a common half-open interval. The definition is manifestly an equivalence relation,
manifestly convex, and needs neither a successor nor an enumeration. `sameRegion_anchor` recovers
the interval picture (`r` is in the region of `f i` when `f i ≤ r` and no placed point sits in
`(f i, r]`), and `region_total` is the statement that the partition really is a partition of all
of `D`.

## "Total on `D` — never an island"

The countermodel may not be defined only at the placed points, with the rest of `D` left out of
the model: an *island* model does not refute `⊨ φ`, because `⊨ φ` quantifies over the honest
carrier. `regionExtend f g : D → W` is a genuine total function — it is defined at every `r : D`
by `g (regionTrace f r)`, with no partiality, no `Option`, and no domain side condition — and
`region_total` records that every `r : D` really does fall in a region, either the initial ray or
the region anchored at some placed point. The two together are the formal content of "total on
`D`, never an island".

## What the invariance lemmas quantify over

`InterpInvariant f M Om χ` says: for every history **in `Om`** and every pair of `SameRegion`
points, `χ` has the same truth value. The quantifier over `Om` rather than over the single history
under consideration is what makes the `box` case go through: `TruthAt … (box φ)` is a universal
over `Om` at a *fixed* time, so the induction hypothesis has to be available at every history of
`Om` simultaneously. It is available, at no cost, because the atom case's hypothesis
(`RegionConstant`) is likewise imposed on all of `Om`.

`box` carries **no accessibility relation** — `TruthAt` quantifies over `Om` outright — so the
`box` case is pure transport of the induction hypothesis and needs nothing from the order.

## Scope of this file at the current stage

Landed here, sorry-free: the region structure, the extension operator, and the `atom` / `bot` /
`imp` / `box` cases of the invariance induction, plus the `neg`/`top` corollaries that
`someFuture`/`allFuture` unfold through.

**Deliberately not yet stated as theorems**: the `untl` and `snce` cases, and hence the assembled
induction `InterpInvariant f M Om χ` for arbitrary `χ`. They are not stubbed with `sorry`; the
file is instead structured as one complete lemma per constructor, so that the temporal cases
arrive as further complete lemmas rather than as the discharge of a placeholder. Their target
statements are recorded verbatim in the `Temporal cases` section below. `allFuture`, `allPast`,
`someFuture` and `somePast` are *definitionally* `untl`/`snce` wrapped in `imp`/`bot`
(`Syntax/Formula.lean`), so they need no separate cases once `untl` and `snce` land.

## Inherited constraints

The placement comes from `exists_monotone_placement`, which states monotonicity against an
explicit `(BranchOrder b ord h).le` rather than an instance-in-statement `letI` — `Fin`'s own
`instLEFin` otherwise wins over the branch order. `exists_region_placement` below preserves that
shape verbatim for the same reason. Nothing here re-derives transitivity of `strictBefore`
(false at fixed fuel) or extends a partial branch order (unsound); the order used is the total
one already packaged by `Bridge/BranchOrder.lean`.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.ProofSystem

/-! ## The region structure induced by a placement

Everything in this section is about an arbitrary family `f : ι → D` of points of a linear order.
The branch enters only in the next section, where `ι` is instantiated at `BranchTime b`.
-/

section Regions

variable {ι : Type*} {D : Type*} [LinearOrder D]

/--
The *trace* of `r` against the placement: which placed points lie weakly below `r`.

Two points of `D` are indistinguishable to the branch exactly when their traces agree, so the
trace is the canonical name of the region containing `r`.
-/
def regionTrace (f : ι → D) (r : D) : Set ι := {i | f i ≤ r}

/--
`r` and `r'` lie in the same region cut out by the placement `f`: no placed point separates them.

This is the half-open-interval partition of `D` — `[f i, f j)` for consecutive placed points,
together with the initial ray below every placed point — presented by its trace rather than by a
successor operation on indices. See `sameRegion_anchor` for the interval picture and
`region_total` for the fact that the regions exhaust `D`.
-/
def SameRegion (f : ι → D) (r r' : D) : Prop := ∀ i, (f i ≤ r ↔ f i ≤ r')

@[simp]
theorem regionTrace_apply (f : ι → D) (r : D) (i : ι) : i ∈ regionTrace f r ↔ f i ≤ r := Iff.rfl

/-- `SameRegion` is exactly equality of traces. -/
theorem sameRegion_iff_regionTrace_eq {f : ι → D} {r r' : D} :
    SameRegion f r r' ↔ regionTrace f r = regionTrace f r' := by
  constructor
  · intro h
    ext i
    exact h i
  · intro h i
    exact Set.ext_iff.mp h i

@[refl]
theorem SameRegion.refl (f : ι → D) (r : D) : SameRegion f r r := fun _ => Iff.rfl

theorem SameRegion.symm {f : ι → D} {r r' : D} (h : SameRegion f r r') : SameRegion f r' r :=
  fun i => (h i).symm

theorem SameRegion.trans {f : ι → D} {r r' r'' : D} (h : SameRegion f r r')
    (h' : SameRegion f r' r'') : SameRegion f r r'' :=
  fun i => (h i).trans (h' i)

/--
Regions are convex: anything between two points of one region is in that region.

This is what makes a region an *interval* rather than an arbitrary trace class, and it is the
form the `untl`/`snce` guard obligation will consume — a guard verified at the endpoints of a
region holds throughout it.
-/
theorem sameRegion_convex {f : ι → D} {r s t : D} (h : SameRegion f r t)
    (h₁ : r ≤ s) (h₂ : s ≤ t) : SameRegion f r s := by
  intro i
  constructor
  · intro hi
    exact le_trans hi h₁
  · intro hi
    exact (h i).mpr (le_trans hi h₂)

/--
The interval picture: `r` lies in the region anchored at the placed point `f i` when `f i ≤ r`
and no placed point sits in `(f i, r]`.

Read left to right this says `r ∈ [f i, f j)` for the next placed point `f j` above `f i`.
-/
theorem sameRegion_anchor {f : ι → D} {r : D} {i : ι} (h₁ : f i ≤ r)
    (h₂ : ∀ j, f j ≤ r → f j ≤ f i) : SameRegion f r (f i) := by
  intro j
  exact ⟨h₂ j, fun hj => le_trans hj h₁⟩

/-- Two points both strictly below every placed point lie in the common initial region. -/
theorem sameRegion_initial {f : ι → D} {r r' : D} (h : ∀ i, r < f i) (h' : ∀ i, r' < f i) :
    SameRegion f r r' := by
  intro i
  exact ⟨fun hle => absurd hle (not_le.mpr (h i)), fun hle => absurd hle (not_le.mpr (h' i))⟩

/-- A point in the region of `f i` is weakly above `f i`. -/
theorem le_of_sameRegion_placed {f : ι → D} {r : D} {i : ι} (h : SameRegion f r (f i)) :
    f i ≤ r :=
  (h i).mpr le_rfl

/--
A placed point strictly above the anchor of `r`'s region is strictly above `r`.

The half-open half of the interval picture, and the form in which the temporal cases will use it:
nothing on the branch happens between `r` and the next placed point.
-/
theorem lt_of_sameRegion_placed {f : ι → D} {r : D} {i j : ι} (h : SameRegion f r (f i))
    (hij : f i < f j) : r < f j := by
  by_contra hcon
  exact absurd ((h j).mp (not_lt.mp hcon)) (not_le.mpr hij)

/--
Distinct placed points are never in a common region: an injective placement separates the branch
times, so no two branch times are collapsed by the interpolation.
-/
theorem not_sameRegion_of_ne {f : ι → D} (hinj : Function.Injective f) {i j : ι} (hij : i ≠ j) :
    ¬ SameRegion f (f i) (f j) := by
  intro h
  exact hij (hinj (le_antisymm ((h i).mp le_rfl) ((h j).mpr le_rfl)))

/-! ### The extension operator -/

/--
Extend a region-indexed assignment `g` to a function **total on `D`**.

Every `r : D` gets a value, unconditionally: the value `g` assigns to `r`'s region. This is the
"never an island" construction — the countermodel is defined at every point of the carrier, not
merely at the placed branch times — and `regionExtend_congr` is the sense in which it is
*constant on the half-open intervals*.
-/
def regionExtend {W : Type*} (f : ι → D) (g : Set ι → W) : D → W := fun r => g (regionTrace f r)

@[simp]
theorem regionExtend_apply {W : Type*} (f : ι → D) (g : Set ι → W) (r : D) :
    regionExtend f g r = g (regionTrace f r) := rfl

/-- The extension is constant on regions — constant on each half-open interval. -/
theorem regionExtend_congr {W : Type*} {f : ι → D} {g : Set ι → W} {r r' : D}
    (h : SameRegion f r r') : regionExtend f g r = regionExtend f g r' := by
  simp only [regionExtend_apply, sameRegion_iff_regionTrace_eq.mp h]

/--
The extension is a total function: it is defined, with a value, at every point of `D`.

Trivial by construction — recorded as a lemma because "total on `D`, never an island" is a
standing constraint on the countermodel and this is where it is discharged for the valuation.
-/
theorem regionExtend_total {W : Type*} (f : ι → D) (g : Set ι → W) (r : D) :
    ∃ w : W, regionExtend f g r = w := ⟨_, rfl⟩

end Regions

/-! ## Regions from a branch placement

Instantiating the region structure at the branch's own times, and recording that the regions
exhaust the carrier. `BranchTime b` is a `Fintype`, which is what makes the anchor exist.
-/

section BranchRegions

variable {D : Type} [LinearOrder D] {b : Branch}

/--
Below any point at which some branch time has been placed there is a **greatest** such placed
time: the anchor of that point's region.

Finiteness of `BranchTime b` is essential and is where it is used; on an infinite placement the
supremum need not be attained and the half-open-interval picture would fail.
-/
theorem exists_greatest_placed_le (f : BranchTime b → D) (r : D) (h₀ : ∃ i, f i ≤ r) :
    ∃ i, f i ≤ r ∧ ∀ j, f j ≤ r → f j ≤ f i := by
  classical
  obtain ⟨i₀, hi₀⟩ := h₀
  have hne : (Finset.univ.filter (fun i : BranchTime b => f i ≤ r)).Nonempty :=
    ⟨i₀, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi₀⟩⟩
  obtain ⟨i, hi, hmax⟩ :=
    Finset.exists_max_image (Finset.univ.filter (fun i : BranchTime b => f i ≤ r)) f hne
  refine ⟨i, (Finset.mem_filter.mp hi).2, fun j hj => ?_⟩
  exact hmax j (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hj⟩)

/--
The regions partition **all** of `D`: every point is either below every placed time — the initial
ray — or sits in the region anchored at a greatest placed time below it.

This is the "never an island" statement at the level of the carrier: no point of `D` is outside
the construction.
-/
theorem region_total (f : BranchTime b → D) (r : D) :
    (∀ i, r < f i) ∨ ∃ i, f i ≤ r ∧ ∀ j, f j ≤ r → f j ≤ f i := by
  by_cases h : ∃ i, f i ≤ r
  · exact Or.inr (exists_greatest_placed_le f r h)
  · exact Or.inl fun i => lt_of_not_ge fun hle => h ⟨i, hle⟩

/--
Every point of `D` lies in the region of some placed branch time, or in the common initial
region — stated in `SameRegion` form, which is how the truth induction consumes it.
-/
theorem exists_sameRegion_rep (f : BranchTime b → D) (r : D) :
    (∀ i, r < f i) ∨ ∃ i, SameRegion f r (f i) := by
  rcases region_total f r with h | ⟨i, h₁, h₂⟩
  · exact Or.inl h
  · exact Or.inr ⟨i, sameRegion_anchor h₁ h₂⟩

/--
The Phase 6 entry point: `exists_monotone_placement` upgraded to the region structure.

The monotonicity clause is stated against an explicit `(BranchOrder b ord h).le`, verbatim as
`Carrier.lean` states it — an instance-in-statement `letI` loses to `Fin`'s own `instLEFin`.
-/
theorem exists_region_placement (fc : FrameClass) (D : Type)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [TemporalCarrier fc D]
    {b : Branch} {ord : TimeOrdering} (h : branchOrderValid b ord = true) :
    ∃ f : BranchTime b → D, Function.Injective f ∧
      (∀ i j, (BranchOrder b ord h).le i j ↔ f i ≤ f j) ∧
      (∀ i j, i ≠ j → ¬ SameRegion f (f i) (f j)) ∧
      (∀ r : D, (∀ i, r < f i) ∨ ∃ i, SameRegion f r (f i)) := by
  obtain ⟨f, hinj, hmono⟩ := exists_monotone_placement fc D h
  exact ⟨f, hinj, hmono, fun _ _ hij => not_sameRegion_of_ne hinj hij,
    fun r => exists_sameRegion_rep f r⟩

end BranchRegions

/-! ## Interpolated truth: the invariance induction

One lemma per formula constructor. The propositional and modal cases are here; the temporal cases
are recorded as target statements at the end of the file and land as further complete lemmas.
-/

section Invariance

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
variable {F : TaskFrame D} {ι : Type*}

/--
A history is *region-constant* for the placement `f`: it cannot tell two points of one region
apart, either in its domain or in the state it assigns.

This is the hypothesis the interpolated construction supplies — the history is built by
`regionExtend`, so it is constant on regions by construction — and the only hypothesis the atom
case of the invariance induction needs.
-/
structure RegionConstant (f : ι → D) (τ : WorldHistory F) : Prop where
  /-- Region-mates are both in the domain or both out of it. -/
  domain_congr : ∀ {r r' : D}, SameRegion f r r' → (τ.domain r ↔ τ.domain r')
  /-- Region-mates carry the same world state. -/
  states_congr : ∀ {r r' : D} (_h : SameRegion f r r') (hr : τ.domain r) (hr' : τ.domain r'),
      τ.states r hr = τ.states r' hr'

/--
The invariance property for a single formula: within `Om`, truth of `χ` does not distinguish
points of a common region.

Quantified over all of `Om` rather than over one history, because `box` is a universal over `Om`
at a fixed time and its case needs the induction hypothesis at every history simultaneously.
-/
def InterpInvariant (f : ι → D) (M : TaskModel F) (Om : Set (WorldHistory F))
    (χ : Formula) : Prop :=
  ∀ τ ∈ Om, ∀ r r' : D, SameRegion f r r' → (TruthAt M Om τ r χ ↔ TruthAt M Om τ r' χ)

variable {f : ι → D} {M : TaskModel F} {Om : Set (WorldHistory F)}

/--
**Atom case.** An atom is true at `r` iff `r` is in the history's domain and the valuation holds
at the state there; a region-constant history agrees with its region-mates on both, so the atom's
truth value is a function of the region alone.
-/
theorem interpInvariant_atom (hRC : ∀ τ ∈ Om, RegionConstant f τ) (p : Atom) :
    InterpInvariant f M Om (Formula.atom p) := by
  intro τ hτ r r' hrr'
  have hC := hRC τ hτ
  simp only [TruthAt]
  constructor
  · rintro ⟨hr, hv⟩
    have hr' : τ.domain r' := (hC.domain_congr hrr').mp hr
    refine ⟨hr', ?_⟩
    rwa [← hC.states_congr hrr' hr hr']
  · rintro ⟨hr', hv⟩
    have hr : τ.domain r := (hC.domain_congr hrr').mpr hr'
    refine ⟨hr, ?_⟩
    rwa [hC.states_congr hrr' hr hr']

/-- **Bottom case.** `⊥` is false everywhere, so it is in particular region-invariant. -/
theorem interpInvariant_bot : InterpInvariant f M Om Formula.bot := by
  intro _ _ _ _ _
  exact Iff.rfl

/-- **Implication case.** The material conditional of two region-invariant formulas. -/
theorem interpInvariant_imp {φ ψ : Formula} (hφ : InterpInvariant f M Om φ)
    (hψ : InterpInvariant f M Om ψ) : InterpInvariant f M Om (φ.imp ψ) := by
  intro τ hτ r r' hrr'
  exact imp_congr (hφ τ hτ r r' hrr') (hψ τ hτ r r' hrr')

/--
**Box case.** `TruthAt … (box φ)` is a universal over `Om` at a *fixed* time, with no
accessibility relation to move the time, so the case is pure transport of the induction
hypothesis across the histories of `Om`. This is exactly why `InterpInvariant` quantifies over
`Om` rather than over a single history.
-/
theorem interpInvariant_box {φ : Formula} (hφ : InterpInvariant f M Om φ) :
    InterpInvariant f M Om φ.box := by
  intro _ _ r r' hrr'
  simp only [TruthAt]
  exact forall_congr' fun σ => imp_congr_right fun hσ => hφ σ hσ r r' hrr'

/-! ### Corollaries the derived connectives unfold through -/

/-- **Negation.** `¬φ` is `φ → ⊥` by definition, so it inherits invariance from `φ`. -/
theorem interpInvariant_neg {φ : Formula} (hφ : InterpInvariant f M Om φ) :
    InterpInvariant f M Om φ.neg :=
  interpInvariant_imp hφ interpInvariant_bot

/-- **Verum.** `⊤` is `⊥ → ⊥` by definition. Needed because `someFuture`/`somePast` guard with it. -/
theorem interpInvariant_top : InterpInvariant f M Om (Formula.top : Formula) :=
  interpInvariant_imp interpInvariant_bot interpInvariant_bot

end Invariance

/-! ## Temporal cases — target statements

The `untl` and `snce` cases are **not** stubbed here. Nothing in this file contains `sorry`; the
induction is carried as one complete lemma per constructor, and the temporal constructors arrive
as two further complete lemmas rather than as the discharge of a placeholder. Their statements
are fixed now so that the later work is a fill-in and not a re-design:

```
theorem interpInvariant_untl {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ)
    (hguard : …the branch-side guard fact…) :
    InterpInvariant f M Om (Formula.untl φ ψ)

theorem interpInvariant_snce {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ)
    (hguard : …the branch-side guard fact…) :
    InterpInvariant f M Om (Formula.snce φ ψ)
```

and then, by induction on `χ`,

```
theorem interpInvariant (hRC : ∀ τ ∈ Om, RegionConstant f τ) (…) (χ : Formula) :
    InterpInvariant f M Om χ
```

Three facts already proved above are what those cases will consume, and they are stated in the
form the cases need:

* `lt_of_sameRegion_placed` — nothing on the branch happens strictly between `r` and the next
  placed point above `r`'s anchor. This is what lets a witness `s` for `untl` be moved from an
  arbitrary point of a region to that region's anchor.
* `sameRegion_convex` — a guard verified at the endpoints of a region holds throughout it, which
  is how the *open* guard interval `(t, s)` of `untl`/`snce` is reduced from all of `D` to the
  finitely many placed points inside it.
* `region_total` / `exists_sameRegion_rep` — the reduction is exhaustive: every point of the open
  guard interval is in some region, so no point of `D` escapes the argument.

`allFuture`, `allPast`, `someFuture` and `somePast` need no cases of their own: they are
definitionally `untl`/`snce` composed with `imp`/`bot` (`Syntax/Formula.lean`), so
`interpInvariant_untl`/`_snce` together with `interpInvariant_imp`, `interpInvariant_bot` and
`interpInvariant_top` cover them.
-/

/-! ## Sanity checks

Exercised by name so that a definition that stops elaborating fails here rather than downstream.
-/

section Checks

/-- The region relation really is reflexive at an arbitrary carrier point. -/
example (r : ℚ) : SameRegion (fun _ : Fin 3 => (0 : ℚ)) r r := SameRegion.refl _ _

/-- The extension is a genuine total function, defined at an arbitrary point of the carrier. -/
example : regionExtend (fun i : Fin 2 => (i : ℚ)) (fun s => (0 : Fin 2) ∈ s) (7 : ℚ) =
    ((0 : Fin 2) ∈ regionTrace (fun i : Fin 2 => (i : ℚ)) 7) := rfl

/-- The extension is constant on a region: `1/2` and `0` are region-mates for this placement. -/
example (g : Set ℕ → ℕ) :
    regionExtend (fun n : ℕ => (n : ℚ)) g (1 / 2 : ℚ) =
      regionExtend (fun n : ℕ => (n : ℚ)) g ((0 : ℕ) : ℚ) := by
  refine regionExtend_congr (sameRegion_anchor (by norm_num) ?_)
  intro j hj
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · simp [hj0]
  · exfalso
    have h1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj0
    linarith

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
