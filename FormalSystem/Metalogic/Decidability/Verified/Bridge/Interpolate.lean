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

* the **region structure** on `D` induced by a placement — the partition of the carrier the
  placement cuts it into;
* the **extension operator** `regionExtend`, which turns any region-indexed assignment into a
  function **total on `D`**; and
* the **invariance** lemmas: truth at a point of a region agrees with truth at any other point of
  the same region, one complete lemma per formula constructor.

## The region structure: singletons and open gaps, not half-open intervals

The plan text specifies the intervals as half-open, `[d_i, d_{i+1})`. **That partition is wrong**,
and the correction is not cosmetic — it is forced by a measured counterexample, recorded here so
it is not re-attempted:

> Take `D = ℚ` with placed points `{0, 1}`, and a model constant on the half-open regions with an
> atom `p` true exactly on `[0, 1)`. Then `somePast p` is **false** at `0` (nothing below `0`
> satisfies `p`) and **true** at `1/2` (witness `1/4`). But `0` and `1/2` are half-open
> region-mates. Invariance fails.

The asymmetry is exactly the asymmetry of `[d_i, d_{i+1})`: it is closed on the left, so its least
element `d_i` has no region-mate below it, and every past-directed operator can tell `d_i` apart
from the rest of its own region. The dual failure would afflict future-directed operators under
`(d_i, d_{i+1}]`. No choice of half-open orientation works.

The partition that does work treats each placed point as **its own region** and each gap between
consecutive placed points as **an open region**:

`SameRegion f r r'` iff `r` and `r'` stand in the same order relation (`<`, `=`, `>`) to every
placed point.

The regions are then the singletons `{d_i}` together with the open intervals `(d_i, d_{i+1})` and
the two open rays. A singleton region is invariant for trivial reasons (`sameRegion_singleton`);
an open region has members on both sides of any of its members, which is precisely what the
temporal cases need. The definition is manifestly an equivalence relation, manifestly convex, and
needs neither a successor operation nor an enumeration of the placed points.

## Density is load-bearing, and `ℤ` is a genuine obstruction

"An open region has members strictly above and strictly below any of its members" is **false on
`ℤ`**: with placed points `{0, 2}` the gap `(0, 2)` is the singleton `{1}`, which is neither a
placed point nor an interval with room to move. `not_exists_gt_sameRegion_int` proves this, so the
obstruction is on record rather than a suspicion.

Consequently the temporal cases carry `[DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]`. Three of
the four frame classes are unaffected — `.Base ℚ`, `.Dense ℚ` and `.Dedekind ℝ` all have densely
ordered carriers with no endpoints. **`.Discrete ℤ` is not covered by these lemmas** and needs a
separate route; that is a genuine finding about the bridge's shape, not a gap in these proofs.

## "Total on `D` — never an island"

The countermodel may not be defined only at the placed points, with the rest of `D` left out of
the model: an *island* model does not refute `⊨ φ`, because `⊨ φ` quantifies over the honest
carrier. `regionExtend f g : D → W` is a genuine total function — defined at every `r : D` by
`g (regionCode f r)`, with no partiality, no `Option`, and no domain side condition — and
`region_total` records that every `r : D` really does fall in a region: a placed point, one of the
two rays, or a gap with an identified pair of endpoints.

## What the invariance lemmas quantify over

`InterpInvariant f M Om χ` says: for every history **in `Om`** and every pair of `SameRegion`
points, `χ` has the same truth value. The quantifier over `Om` rather than over the single history
under consideration is what makes the `box` case go through: `TruthAt … (box φ)` is a universal
over `Om` at a *fixed* time, so the induction hypothesis has to be available at every history of
`Om` simultaneously. It is available at no cost, because the atom case's hypothesis
(`RegionConstant`) is likewise imposed on all of `Om`. `box` carries **no accessibility
relation** — `TruthAt` quantifies over `Om` outright — so that case is pure transport and needs
nothing from the order.

## What the temporal cases turned out *not* to need

The plan anticipated the temporal cases consuming the branch saturation (`sat_*`) family. They do
not, and this is a simplification rather than a shortcut: `InterpInvariant` is a statement about
the *constructed model*, not about the branch, so it is provable from density and the region
structure alone. The branch's saturation facts are consumed one level up, by Phase 7's truth
lemma, which is where the model's values are tied to what the branch asserts. The lemma statements
here are the ones the plan specifies; only their hypothesis lists are shorter.

## Inherited constraints

The placement comes from `exists_monotone_placement`, which states monotonicity against an
explicit `(BranchOrder b ord h).le` rather than an instance-in-statement `letI` — `Fin`'s own
`instLEFin` otherwise wins. `exists_region_placement` below preserves that shape verbatim for the
same reason. Nothing here re-derives transitivity of `strictBefore` (false at fixed fuel) or
extends a partial branch order (unsound); the order used is the total one already packaged by
`Bridge/BranchOrder.lean`.
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
The *code* of `r` against the placement: which placed points lie strictly below `r`, and which lie
strictly above. Two points of `D` are indistinguishable to the branch exactly when their codes
agree, so the code is the canonical name of the region containing `r`.
-/
def regionCode (f : ι → D) (r : D) : Set ι × Set ι := ({i | f i < r}, {i | r < f i})

/--
`r` and `r'` lie in the same region cut out by the placement `f`: they stand in the same order
relation to every placed point.

The regions are the singletons `{f i}` together with the open gaps between consecutive placed
points and the two open rays. See the module docstring for the measured counterexample that rules
out the half-open alternative, `sameRegion_singleton` for the placed-point case,
`sameRegion_of_gap` for the gap case, and `region_total` for exhaustiveness.
-/
def SameRegion (f : ι → D) (r r' : D) : Prop :=
  ∀ i, (f i < r ↔ f i < r') ∧ (r < f i ↔ r' < f i)

/-- `SameRegion` is exactly equality of codes. -/
theorem sameRegion_iff_regionCode_eq {f : ι → D} {r r' : D} :
    SameRegion f r r' ↔ regionCode f r = regionCode f r' := by
  constructor
  · intro h
    refine Prod.ext ?_ ?_ <;> ext i
    · exact (h i).1
    · exact (h i).2
  · intro h i
    refine ⟨?_, ?_⟩
    · exact Set.ext_iff.mp (congrArg Prod.fst h) i
    · exact Set.ext_iff.mp (congrArg Prod.snd h) i

@[refl]
theorem SameRegion.refl (f : ι → D) (r : D) : SameRegion f r r := fun _ => ⟨Iff.rfl, Iff.rfl⟩

theorem SameRegion.symm {f : ι → D} {r r' : D} (h : SameRegion f r r') : SameRegion f r' r :=
  fun i => ⟨(h i).1.symm, (h i).2.symm⟩

theorem SameRegion.trans {f : ι → D} {r r' r'' : D} (h : SameRegion f r r')
    (h' : SameRegion f r' r'') : SameRegion f r r'' :=
  fun i => ⟨(h i).1.trans (h' i).1, (h i).2.trans (h' i).2⟩

/--
Regions are convex: anything between two points of one region is in that region.

This is what makes a region an *interval* rather than an arbitrary code class, and it is the form
the temporal cases consume — a guard verified anywhere in a region holds throughout it.
-/
theorem sameRegion_convex {f : ι → D} {r s t : D} (h : SameRegion f r t)
    (h₁ : r ≤ s) (h₂ : s ≤ t) : SameRegion f r s := by
  intro i
  refine ⟨⟨fun hi => lt_of_lt_of_le hi h₁, fun hi => (h i).1.mpr (lt_of_lt_of_le hi h₂)⟩, ?_⟩
  exact ⟨fun hi => lt_of_le_of_lt h₂ ((h i).2.mp hi), fun hi => lt_of_le_of_lt h₁ hi⟩

/--
A placed point is alone in its region: the singleton regions really are singletons.

This is the half of the partition that the half-open alternative got wrong — under
`[d_i, d_{i+1})` the placed point `d_i` shares its region with the whole gap above it, and every
past-directed operator can then tell it apart from its own region-mates.
-/
theorem sameRegion_singleton {f : ι → D} {r r' : D} {i : ι} (h : SameRegion f r r')
    (hi : f i = r) : r = r' := by
  have h₁ : ¬ f i < r := by rw [hi]; exact lt_irrefl _
  have h₂ : ¬ r < f i := by rw [hi]; exact lt_irrefl _
  have h₁' : ¬ f i < r' := fun hlt => h₁ ((h i).1.mpr hlt)
  have h₂' : ¬ r' < f i := fun hlt => h₂ ((h i).2.mpr hlt)
  have hfi : f i = r' := le_antisymm (not_lt.mp h₂') (not_lt.mp h₁')
  rw [← hi, hfi]

/--
Two points of a common region that are actually distinct force the region to be a gap: no placed
point can then lie in it.

This is how the temporal cases discharge the side condition of `exists_gt_sameRegion` and
`exists_lt_sameRegion` — either `r = r'` and there is nothing to prove, or the region is open.
-/
theorem placed_ne_of_sameRegion_ne {f : ι → D} {r r' : D} (h : SameRegion f r r') (hne : r ≠ r') :
    (∀ i, f i ≠ r) ∧ (∀ i, f i ≠ r') :=
  ⟨fun _ hi => hne (sameRegion_singleton h hi),
   fun _ hi => hne (sameRegion_singleton h.symm hi).symm⟩

/--
Two points with the same strict-below trace, neither of them placed, share a region.

The gap picture: `r` and `r'` sit strictly between the same consecutive pair of placed points.
-/
theorem sameRegion_of_gap {f : ι → D} {r r' : D} (h : ∀ i, (f i < r ↔ f i < r'))
    (hr : ∀ i, f i ≠ r) (hr' : ∀ i, f i ≠ r') : SameRegion f r r' := by
  intro i
  refine ⟨h i, ⟨fun hlt => ?_, fun hlt => ?_⟩⟩
  · by_contra hc
    push_neg at hc
    exact absurd ((h i).mpr (lt_of_le_of_ne hc (hr' i))) (asymm hlt)
  · by_contra hc
    push_neg at hc
    exact absurd ((h i).mp (lt_of_le_of_ne hc (hr i))) (asymm hlt)

/-! ### The extension operator -/

/--
Extend a region-indexed assignment `g` to a function **total on `D`**.

Every `r : D` gets a value, unconditionally: the value `g` assigns to `r`'s region. This is the
"never an island" construction — the countermodel is defined at every point of the carrier, not
merely at the placed branch times — and `regionExtend_congr` is the sense in which it is
*constant on each region*.
-/
def regionExtend {W : Type*} (f : ι → D) (g : Set ι × Set ι → W) : D → W :=
  fun r => g (regionCode f r)

@[simp]
theorem regionExtend_apply {W : Type*} (f : ι → D) (g : Set ι × Set ι → W) (r : D) :
    regionExtend f g r = g (regionCode f r) := rfl

/-- The extension is constant on regions. -/
theorem regionExtend_congr {W : Type*} {f : ι → D} {g : Set ι × Set ι → W} {r r' : D}
    (h : SameRegion f r r') : regionExtend f g r = regionExtend f g r' := by
  simp only [regionExtend_apply, sameRegion_iff_regionCode_eq.mp h]

/--
The extension is a total function: it is defined, with a value, at every point of `D`.

Trivial by construction — recorded as a lemma because "total on `D`, never an island" is a
standing constraint on the countermodel and this is where it is discharged for the valuation.
-/
theorem regionExtend_total {W : Type*} (f : ι → D) (g : Set ι × Set ι → W) (r : D) :
    ∃ w : W, regionExtend f g r = w := ⟨_, rfl⟩

/-! ### Room to move inside an open region

The two lemmas the temporal cases run on. Both are **false without density** — see
`not_exists_gt_sameRegion_int`.
-/

variable [Fintype ι]

/-- Below a point with some placed point strictly under it there is a greatest such placed point. -/
theorem exists_greatest_placed_lt (f : ι → D) (r : D) (h₀ : ∃ i, f i < r) :
    ∃ i, f i < r ∧ ∀ j, f j < r → f j ≤ f i := by
  classical
  obtain ⟨i₀, hi₀⟩ := h₀
  have hne : (Finset.univ.filter (fun i : ι => f i < r)).Nonempty :=
    ⟨i₀, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi₀⟩⟩
  obtain ⟨i, hi, hmax⟩ :=
    Finset.exists_max_image (Finset.univ.filter (fun i : ι => f i < r)) f hne
  exact ⟨i, (Finset.mem_filter.mp hi).2,
    fun j hj => hmax j (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hj⟩)⟩

/-- Above a point with some placed point strictly over it there is a least such placed point. -/
theorem exists_least_placed_gt (f : ι → D) (r : D) (h₀ : ∃ i, r < f i) :
    ∃ i, r < f i ∧ ∀ j, r < f j → f i ≤ f j := by
  classical
  obtain ⟨i₀, hi₀⟩ := h₀
  have hne : (Finset.univ.filter (fun i : ι => r < f i)).Nonempty :=
    ⟨i₀, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi₀⟩⟩
  obtain ⟨i, hi, hmin⟩ :=
    Finset.exists_min_image (Finset.univ.filter (fun i : ι => r < f i)) f hne
  exact ⟨i, (Finset.mem_filter.mp hi).2,
    fun j hj => hmin j (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hj⟩)⟩

/--
An open region has a member strictly above any of its members.

Needs density: on `ℤ` the gap `(0, 2)` is the singleton `{1}` and the conclusion fails
(`not_exists_gt_sameRegion_int`).
-/
theorem exists_gt_sameRegion [DenselyOrdered D] [NoMaxOrder D] {f : ι → D} {r : D}
    (hr : ∀ i, f i ≠ r) : ∃ s, r < s ∧ SameRegion f r s := by
  by_cases h : ∃ i, r < f i
  · obtain ⟨i, hi, hmin⟩ := exists_least_placed_gt f r h
    obtain ⟨s, hrs, hsi⟩ := exists_between hi
    have hs : ∀ k, f k ≠ s := by
      intro k hk
      have hrk : r < f k := by rw [hk]; exact hrs
      have hle : f i ≤ f k := hmin k hrk
      rw [hk] at hle
      exact absurd hle (not_le.mpr hsi)
    refine ⟨s, hrs, sameRegion_of_gap (fun k => ⟨fun hk => lt_trans hk hrs, fun hk => ?_⟩) hr hs⟩
    rcases lt_trichotomy (f k) r with hlt | heq | hgt
    · exact hlt
    · exact absurd heq (hr k)
    · exact absurd (hmin k hgt) (not_le.mpr (lt_trans hk hsi))
  · push_neg at h
    obtain ⟨s, hs⟩ := exists_gt r
    have hlt : ∀ k, f k < r := fun k => lt_of_le_of_ne (h k) (hr k)
    have hns : ∀ k, f k ≠ s := by
      intro k hk
      have hks : f k < s := lt_trans (hlt k) hs
      rw [hk] at hks
      exact absurd hks (lt_irrefl _)
    exact ⟨s, hs, sameRegion_of_gap
      (fun k => ⟨fun _ => lt_trans (hlt k) hs, fun _ => hlt k⟩) hr hns⟩

/--
An open region has a member strictly below any of its members.

The mirror image of `exists_gt_sameRegion`, and equally dependent on density.
-/
theorem exists_lt_sameRegion [DenselyOrdered D] [NoMinOrder D] {f : ι → D} {r : D}
    (hr : ∀ i, f i ≠ r) : ∃ s, s < r ∧ SameRegion f r s := by
  by_cases h : ∃ i, f i < r
  · obtain ⟨i, hi, hmax⟩ := exists_greatest_placed_lt f r h
    obtain ⟨s, his, hsr⟩ := exists_between hi
    have hs : ∀ k, f k ≠ s := by
      intro k hk
      have hkr : f k < r := by rw [hk]; exact hsr
      have hle : f k ≤ f i := hmax k hkr
      rw [hk] at hle
      exact absurd hle (not_le.mpr his)
    refine ⟨s, hsr, sameRegion_of_gap (fun k => ⟨fun hk => ?_, fun hk => lt_trans hk hsr⟩) hr hs⟩
    exact lt_of_le_of_lt (hmax k hk) his
  · push_neg at h
    obtain ⟨s, hs⟩ := exists_lt r
    have hgt : ∀ k, r < f k := fun k => lt_of_le_of_ne (h k) (Ne.symm (hr k))
    have hns : ∀ k, f k ≠ s := by
      intro k hk
      have hsk : s < f k := lt_trans hs (hgt k)
      rw [hk] at hsk
      exact absurd hsk (lt_irrefl _)
    exact ⟨s, hs, sameRegion_of_gap
      (fun k => ⟨fun hk => absurd (lt_trans (hgt k) hk) (lt_irrefl _),
        fun hk => absurd (lt_trans hk hs) (asymm (hgt k))⟩)
      hr hns⟩

/--
The regions exhaust `D`: every point is a placed point, or below everything placed, or above
everything placed, or in a gap with an identified pair of endpoints.

This is "never an island" at the level of the carrier — no point of `D` is outside the
construction.
-/
theorem region_total (f : ι → D) (r : D) :
    (∃ i, f i = r) ∨ (∀ i, r < f i) ∨ (∀ i, f i < r) ∨
      ∃ i j, (f i < r ∧ ∀ k, f k < r → f k ≤ f i) ∧ (r < f j ∧ ∀ k, r < f k → f j ≤ f k) := by
  by_cases hplaced : ∃ i, f i = r
  · exact Or.inl hplaced
  · push_neg at hplaced
    by_cases hbelow : ∃ i, f i < r
    · by_cases habove : ∃ i, r < f i
      · obtain ⟨i, hi⟩ := exists_greatest_placed_lt f r hbelow
        obtain ⟨j, hj⟩ := exists_least_placed_gt f r habove
        exact Or.inr (Or.inr (Or.inr ⟨i, j, hi, hj⟩))
      · push_neg at habove
        exact Or.inr (Or.inr (Or.inl fun k => lt_of_le_of_ne (habove k) (hplaced k)))
    · push_neg at hbelow
      exact Or.inr (Or.inl fun k => lt_of_le_of_ne (hbelow k) (Ne.symm (hplaced k)))

end Regions

/-! ## The measured obstruction at `ℤ`

`exists_gt_sameRegion` is not an artefact of the proof: its conclusion is genuinely false on a
discrete carrier, so the density hypothesis cannot be dropped and the `.Discrete` frame class
cannot be served by these lemmas.
-/

/--
On `ℤ` an open region can be a **singleton that is not a placed point**, so it has no member
strictly above its members.

Placement `n ↦ 2n`, point `r = 1`: the gap `(0, 2)` is `{1}`. Any `s > 1` has `2 ≤ s`, and then
`1 < 2` while `¬ (s < 2)`, so `s` is in a different region.
-/
theorem not_exists_gt_sameRegion_int :
    ∃ (f : ℕ → ℤ) (r : ℤ), (∀ i, f i ≠ r) ∧ ¬ ∃ s, r < s ∧ SameRegion f r s := by
  refine ⟨fun n => 2 * (n : ℤ), 1, fun i => ?_, ?_⟩
  · show 2 * (i : ℤ) ≠ 1
    omega
  rintro ⟨s, hs, hreg⟩
  have h := (hreg 1).2
  simp only [Nat.cast_one, mul_one] at h
  omega

/-! ## Regions from a branch placement -/

section BranchRegions

variable {D : Type} [LinearOrder D] {b : Branch}

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
      (∀ r : D, (∃ i, f i = r) ∨ (∀ i, r < f i) ∨ (∀ i, f i < r) ∨
        ∃ i j, (f i < r ∧ ∀ k, f k < r → f k ≤ f i) ∧
          (r < f j ∧ ∀ k, r < f k → f j ≤ f k)) := by
  obtain ⟨f, hinj, hmono⟩ := exists_monotone_placement fc D h
  refine ⟨f, hinj, hmono, fun i j hij hreg => hij (hinj ?_), fun r => region_total f r⟩
  exact (sameRegion_singleton hreg rfl)

end BranchRegions

/-! ## Interpolated truth: the invariance induction -/

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
The invariance property for a single formula: across the total histories, truth of `χ` does not
distinguish points of a common region.

Quantified over all total histories rather than over one history, because `box` is a universal
over the total histories at a fixed time and its case needs the induction hypothesis at every
such history simultaneously. `Om` survives only as `TruthAt`'s inert carrier argument; the
quantifier tracks the box clause, which is totality (`def:BL-semantics`,
`specs/paper-definitions-of-record.md`), not `Ω`-membership.
-/
def InterpInvariant (f : ι → D) (M : TaskModel F) (Om : Set (WorldHistory F))
    (χ : Formula) : Prop :=
  ∀ τ : WorldHistory F, τ.IsTotal →
    ∀ r r' : D, SameRegion f r r' → (TruthAt M Om τ r χ ↔ TruthAt M Om τ r' χ)

variable {f : ι → D} {M : TaskModel F} {Om : Set (WorldHistory F)}

/-! ### Propositional and modal cases -/

/--
**Atom case.** An atom is true at `r` iff `r` is in the history's domain and the valuation holds
at the state there; a region-constant history agrees with its region-mates on both, so the atom's
truth value is a function of the region alone.
-/
theorem interpInvariant_atom (hRC : ∀ τ : WorldHistory F, τ.IsTotal → RegionConstant f τ)
    (p : Atom) :
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
**Box case.** `TruthAt … (box φ)` is a universal over the *total* histories at a *fixed* time,
with no accessibility relation to move the time, so the case is pure transport of the induction
hypothesis across those histories. This is exactly why `InterpInvariant` quantifies over the
total histories rather than over a single history.
-/
theorem interpInvariant_box {φ : Formula} (hφ : InterpInvariant f M Om φ) :
    InterpInvariant f M Om φ.box := by
  intro _ _ r r' hrr'
  simp only [TruthAt]
  exact forall_congr' fun σ => imp_congr_right fun hσ => hφ σ hσ r r' hrr'

/-- **Negation.** `¬φ` is `φ → ⊥` by definition, so it inherits invariance from `φ`. -/
theorem interpInvariant_neg {φ : Formula} (hφ : InterpInvariant f M Om φ) :
    InterpInvariant f M Om φ.neg :=
  interpInvariant_imp hφ interpInvariant_bot

/-- **Verum.** `⊤` is `⊥ → ⊥` by definition; `someFuture`/`somePast` guard with it. -/
theorem interpInvariant_top : InterpInvariant f M Om (Formula.top : Formula) :=
  interpInvariant_imp interpInvariant_bot interpInvariant_bot

/-! ### Temporal cases

Both directions of both temporal constructors, for a region with room to move. The shape of every
argument is the same: a witness or a guard point that falls inside the region is transported to
the other endpoint by the induction hypothesis, and a fresh witness inside the region is produced
by `exists_gt_sameRegion` / `exists_lt_sameRegion` when the original witness has been overtaken.
-/

variable [Fintype ι] [DenselyOrdered D]

/-- One direction of the `untl` case, for `r < r'`. The other follows by symmetry of the setup. -/
private theorem untl_forward [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ)
    {τ : WorldHistory F} (hτ : τ.IsTotal) {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r (φ.untl ψ)) : TruthAt M Om τ r' (φ.untl ψ) := by
  obtain ⟨s, hrs, hφs, hg⟩ := h
  by_cases hcase : r' < s
  · exact ⟨s, hcase, hφs, fun x hx hxs => hg x (lt_trans hlt hx) hxs⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hrs.le hcase
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hr's', hs'reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
    obtain ⟨x₀, hx₀l, hx₀r⟩ := exists_between hrs
    have hx₀reg : SameRegion f r x₀ := sameRegion_convex hsreg hx₀l.le hx₀r.le
    have hψx₀ : TruthAt M Om τ x₀ ψ := hg x₀ hx₀l hx₀r
    refine ⟨s', hr's', ?_, ?_⟩
    · exact (hφ τ hτ s s' ((hsreg.symm.trans hrr').trans hs'reg)).mp hφs
    · intro x hx hxs'
      have hxreg : SameRegion f r' x := sameRegion_convex hs'reg hx.le hxs'.le
      exact (hψ τ hτ x₀ x ((hx₀reg.symm.trans hrr').trans hxreg)).mp hψx₀

/-- The reverse direction of the `untl` case, for `r < r'`. -/
private theorem untl_backward [NoMaxOrder D] {φ ψ : Formula}
    (hψ : InterpInvariant f M Om ψ)
    {τ : WorldHistory F} (hτ : τ.IsTotal) {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r' (φ.untl ψ)) : TruthAt M Om τ r (φ.untl ψ) := by
  obtain ⟨s, hr's, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hr's₁, hs₁reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
  obtain ⟨y, hyl, hyr⟩ := exists_between (lt_min hr's hr's₁)
  have hys : y < s := lt_of_lt_of_le hyr (min_le_left _ _)
  have hys₁ : y < s₁ := lt_of_lt_of_le hyr (min_le_right _ _)
  have hyreg : SameRegion f r' y := sameRegion_convex hs₁reg hyl.le hys₁.le
  have hψy : TruthAt M Om τ y ψ := hg y hyl hys
  refine ⟨s, lt_trans hlt hr's, hφs, ?_⟩
  intro x hx hxs
  by_cases hcase : r' < x
  · exact hg x hcase hxs
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hx.le hcase
    exact (hψ τ hτ y x ((hyreg.symm.trans hrr'.symm).trans hxreg)).mp hψy

/--
**Until case.** `U(φ, ψ)` is region-invariant when `φ` and `ψ` are, on a densely ordered carrier
with no greatest element.

The open guard interval `(t, s)` is exactly what the region structure is for: any guard point that
falls inside the region is pinned by `ψ`'s invariance, and any witness that has been overtaken is
replaced by a fresh one inside the region.
-/
theorem interpInvariant_untl [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ) :
    InterpInvariant f M Om (Formula.untl φ ψ) := by
  intro τ hτ r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨untl_forward hφ hψ hτ hrr' hlt, untl_backward hψ hτ hrr' hlt⟩
  · rw [heq]
  · exact ⟨untl_backward hψ hτ hrr'.symm hgt, untl_forward hφ hψ hτ hrr'.symm hgt⟩

/-- One direction of the `snce` case, for `r < r'`. -/
private theorem snce_forward [NoMinOrder D] {φ ψ : Formula}
    (hψ : InterpInvariant f M Om ψ)
    {τ : WorldHistory F} (hτ : τ.IsTotal) {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r (φ.snce ψ)) : TruthAt M Om τ r' (φ.snce ψ) := by
  obtain ⟨s, hsr, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hs₁r, hs₁reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
  obtain ⟨y, hyl, hyr⟩ := exists_between (max_lt hsr hs₁r)
  have hsy : s < y := lt_of_le_of_lt (le_max_left _ _) hyl
  have hs₁y : s₁ < y := lt_of_le_of_lt (le_max_right _ _) hyl
  have hyreg : SameRegion f r y := hs₁reg.trans (sameRegion_convex hs₁reg.symm hs₁y.le hyr.le)
  have hψy : TruthAt M Om τ y ψ := hg y hsy hyr
  refine ⟨s, lt_trans hsr hlt, hφs, ?_⟩
  intro x hsx hxr'
  by_cases hcase : x < r
  · exact hg x hsx hcase
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hcase hxr'.le
    exact (hψ τ hτ y x (hyreg.symm.trans hxreg)).mp hψy

/-- The reverse direction of the `snce` case, for `r < r'`. -/
private theorem snce_backward [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ)
    {τ : WorldHistory F} (hτ : τ.IsTotal) {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r' (φ.snce ψ)) : TruthAt M Om τ r (φ.snce ψ) := by
  obtain ⟨s, hsr', hφs, hg⟩ := h
  by_cases hcase : s < r
  · exact ⟨s, hcase, hφs, fun x hsx hxr => hg x hsx (lt_trans hxr hlt)⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hcase hsr'.le
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hs'r, hs'reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
    obtain ⟨y, hyl, hyr⟩ := exists_between hsr'
    have hyreg : SameRegion f s y := sameRegion_convex (hsreg.symm.trans hrr') hyl.le hyr.le
    have hψy : TruthAt M Om τ y ψ := hg y hyl hyr
    refine ⟨s', hs'r, ?_, ?_⟩
    · exact (hφ τ hτ s s' (hsreg.symm.trans hs'reg)).mp hφs
    · intro x hs'x hxr
      have hxreg : SameRegion f r x :=
        hs'reg.trans (sameRegion_convex hs'reg.symm hs'x.le hxr.le)
      exact (hψ τ hτ y x ((hyreg.symm.trans hsreg.symm).trans hxreg)).mp hψy

/--
**Since case.** The mirror image of `interpInvariant_untl`, on a densely ordered carrier with no
least element.
-/
theorem interpInvariant_snce [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariant f M Om φ) (hψ : InterpInvariant f M Om ψ) :
    InterpInvariant f M Om (Formula.snce φ ψ) := by
  intro τ hτ r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨snce_forward hψ hτ hrr' hlt, snce_backward hφ hψ hτ hrr' hlt⟩
  · rw [heq]
  · exact ⟨snce_backward hφ hψ hτ hrr'.symm hgt, snce_forward hψ hτ hrr'.symm hgt⟩

/-! ### The derived temporal operators

`someFuture`, `somePast`, `allFuture` and `allPast` are definitionally `untl`/`snce` composed with
`imp`/`bot` (`Syntax/Formula.lean`), so they need no cases of their own.
-/

/-- **`F φ`.** `someFuture φ` is `U(φ, ⊤)`. -/
theorem interpInvariant_someFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariant f M Om φ) : InterpInvariant f M Om φ.someFuture :=
  interpInvariant_untl hφ interpInvariant_top

/-- **`P φ`.** `somePast φ` is `S(φ, ⊤)`. -/
theorem interpInvariant_somePast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariant f M Om φ) : InterpInvariant f M Om φ.somePast :=
  interpInvariant_snce hφ interpInvariant_top

/-- **`G φ`.** `allFuture φ` is `¬ F ¬ φ`. -/
theorem interpInvariant_allFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariant f M Om φ) : InterpInvariant f M Om φ.allFuture :=
  interpInvariant_neg (interpInvariant_someFuture (interpInvariant_neg hφ))

/-- **`H φ`.** `allPast φ` is `¬ P ¬ φ`. -/
theorem interpInvariant_allPast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariant f M Om φ) : InterpInvariant f M Om φ.allPast :=
  interpInvariant_neg (interpInvariant_somePast (interpInvariant_neg hφ))

/-! ### The assembled induction -/

/--
**Interpolation invariance.** On a densely ordered carrier with no endpoints, truth of *every*
formula is constant on each region cut out by the placement, provided every history of `Om` is
region-constant.

This is the whole of stage 3 of the semantic bridge: it is what lets Phase 7's truth lemma read
truth at an arbitrary point of the carrier off the branch time whose region that point is in.
-/
theorem interpInvariant [NoMaxOrder D] [NoMinOrder D]
    (hRC : ∀ τ : WorldHistory F, τ.IsTotal → RegionConstant f τ) (χ : Formula) :
    InterpInvariant f M Om χ := by
  induction χ with
  | atom p => exact interpInvariant_atom hRC p
  | bot => exact interpInvariant_bot
  | imp φ ψ hφ hψ => exact interpInvariant_imp hφ hψ
  | box φ hφ => exact interpInvariant_box hφ
  | untl φ ψ hφ hψ => exact interpInvariant_untl hφ hψ
  | snce φ ψ hφ hψ => exact interpInvariant_snce hφ hψ

end Invariance

/-! ## Sanity checks

Exercised by name so that a definition that stops elaborating fails here rather than downstream.
-/

section Checks

/-- The region relation is reflexive at an arbitrary carrier point. -/
example (r : ℚ) : SameRegion (fun _ : Fin 3 => (0 : ℚ)) r r := SameRegion.refl _ _

/-- The extension is a genuine total function, defined at an arbitrary point of the carrier. -/
example : regionExtend (fun i : Fin 2 => (i : ℚ)) (fun s => (0 : Fin 2) ∈ s.1) (7 : ℚ) =
    ((0 : Fin 2) ∈ (regionCode (fun i : Fin 2 => (i : ℚ)) 7).1) := rfl

/-- The three dense carriers have the endpoints-free density the temporal cases need. -/
example : DenselyOrdered ℚ := inferInstance
example : NoMaxOrder ℚ := inferInstance
example : NoMinOrder ℚ := inferInstance
example : DenselyOrdered ℝ := inferInstance
example : NoMaxOrder ℝ := inferInstance
example : NoMinOrder ℝ := inferInstance

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
