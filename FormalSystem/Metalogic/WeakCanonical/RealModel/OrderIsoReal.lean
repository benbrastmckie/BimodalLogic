/-
# The order characterization of `ℝ`

**Statement source**: Reynolds 1992, §8, printed p.188 — *"But then `R` being Dedekind complete,
dense, without end points and with a countable dense subset must be isomorphic to the reals."*
Reynolds asserts this in a single sentence and gives no proof; it is the classical
order-characterization of the real line, due to Cantor.

**Proof source**: NONE in this task's corpus. The proof below is original work for this
development. It is the standard argument (Cantor's back-and-forth on the countable dense subsets,
extended to the whole order by the cut map), but no source in the corpus states it in a form that
could be transcribed, so it is written here from first principles.

## Mathlib search — the negative result, recorded so it is not repeated

Searched at the time of writing (Lean `v4.33.0-rc1`, Mathlib tag `v4.33.0-rc1`):

* `loogle` for `Nonempty (?a ≃o ℝ)` — **no results at all**.
* `loogle` for `?a ≃o ℝ` — only `Real.tanOrderIso`, `Real.sinhOrderIso`,
  `CircleDeg1Lift.toOrderIso`, i.e. specific isomorphisms, never a characterization.
* `Mathlib.Order.CountableDenseLinearOrder` has `Order.iso_of_countable_dense` (Cantor's
  isomorphism theorem for *countable* dense endpointless orders) and
  `Order.embedding_from_countable_to_dense`, and stops there.
* Uniqueness of `ℝ` in Mathlib is **field**-theoretic, not order-theoretic:
  `Mathlib.Algebra.Order.CompleteField` characterizes `ℝ` among
  `ConditionallyCompleteLinearOrderedField`s. That hypothesis is unavailable here — the orders
  this development characterizes are flows of temporal structures and carry no field structure.

So the order-theoretic characterization **is absent from Mathlib** and is built here. Only step 1
(Cantor on the countable dense subset) is delegated to Mathlib; steps 2-3 are new.

## Structure of the argument

1. The countable dense subset `D ⊆ R` is itself countable, densely ordered, endpointless and
   non-empty, so `Order.iso_of_countable_dense` supplies `e : ↥D ≃o ℚ`.
2. `cutMap e x := sSup {(e d : ℝ) | d ∈ D, d < x}` is well defined: the set is non-empty because
   `R` has no least element and `D` is dense, and bounded above because `R` has no greatest
   element and `D` is dense.
3. `cutMap e` is strictly monotone by density of `D`, and surjective by Dedekind completeness of
   `R` played against completeness of `ℝ`. `StrictMono.orderIsoOfSurjective` finishes.
-/
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Order.Hom.Set
import Mathlib.Data.Set.Countable
import Mathlib.Data.Rat.Denumerable
import Mathlib.Algebra.Order.Archimedean.Real.Basic

namespace FormalSystem.Metalogic.WeakCanonical

/-! ## The hypothesis bundle -/

/-- **The order-theoretic hypotheses that characterize `ℝ`** (Reynolds 1992, §8, printed p.188).

A linear order is `IsRealLike` when it is non-empty, densely ordered, without endpoints, Dedekind
complete, and separable (has a countable order-dense subset).

**What this excludes** (honesty-charter Rule 6). Each clause is doing work and none is implied by
the others:

* `nonempty'` excludes the empty order, which satisfies every other clause vacuously and is not
  order-isomorphic to `ℝ`.
* `dense` excludes `ℤ` and every discrete order.
* `noMax` / `noMin` exclude the closed and half-closed intervals `[0,1]`, `[0,1)`, `(0,1]`, all of
  which are dense, Dedekind complete and separable.
* `lub` (Dedekind completeness) excludes `ℚ` itself, and excludes `(0,1) \ {1/2}`, which is dense,
  endpointless and separable.
* `sep` excludes the long line and, more relevantly here, every order of cardinality `> 𝔠`;
  without it the previous clauses characterize only "Dedekind complete dense linear continuum",
  a strictly larger class.

Deliberately **not** included: any field, group, topological, or metric structure. The whole point
of this characterization is that the order alone suffices — the flows this development applies it
to (ordered sums of monadic structures) carry no arithmetic. -/
structure IsRealLike (R : Type*) [LinearOrder R] : Prop where
  /-- The order is inhabited. -/
  nonempty' : Nonempty R
  /-- The order is densely ordered. -/
  dense : ∀ x y : R, x < y → ∃ z, x < z ∧ z < y
  /-- The order has no greatest element. -/
  noMax : ∀ x : R, ∃ y, x < y
  /-- The order has no least element. -/
  noMin : ∀ x : R, ∃ y, y < x
  /-- The order is Dedekind complete: every non-empty subset bounded above has a least upper
  bound. -/
  lub : ∀ S : Set R, S.Nonempty → BddAbove S → ∃ u, IsLUB S u
  /-- The order is separable: it has a countable order-dense subset. -/
  sep : ∃ D : Set R, D.Countable ∧ ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y

/-! ## Step 1 — Cantor on the countable dense subset

This is the one step delegated to Mathlib. Everything below it is new. -/

section Cantor

variable {R : Type*} [LinearOrder R] {D : Set R}

/-- **A countable order-dense subset of an endpointless order is order-isomorphic to `ℚ`.**

The content is entirely `Order.iso_of_countable_dense` (Cantor's isomorphism theorem); the work
here is checking that `↥D` inherits countability, density and endpointlessness from `R` and the
density of `D` in `R`. -/
theorem nonempty_orderIso_rat_of_countableDense
    (hDc : D.Countable) (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y)
    (hne : Nonempty R) (hmax : ∀ x : R, ∃ y, x < y) (hmin : ∀ x : R, ∃ y, y < x) :
    Nonempty (D ≃o ℚ) := by
  haveI : Countable D := hDc.to_subtype
  haveI : DenselyOrdered D := ⟨fun a b hab => by
    obtain ⟨d, hd, h₁, h₂⟩ := hDd a.1 b.1 hab
    exact ⟨⟨d, hd⟩, h₁, h₂⟩⟩
  haveI : NoMaxOrder D := ⟨fun a => by
    obtain ⟨y, hy⟩ := hmax a.1
    obtain ⟨d, hd, h₁, -⟩ := hDd a.1 y hy
    exact ⟨⟨d, hd⟩, h₁⟩⟩
  haveI : NoMinOrder D := ⟨fun a => by
    obtain ⟨y, hy⟩ := hmin a.1
    obtain ⟨d, hd, -, h₂⟩ := hDd y a.1 hy
    exact ⟨⟨d, hd⟩, h₂⟩⟩
  haveI : Nonempty D := by
    obtain ⟨x⟩ := hne
    obtain ⟨y, hy⟩ := hmax x
    obtain ⟨d, hd, -, -⟩ := hDd x y hy
    exact ⟨⟨d, hd⟩⟩
  exact Order.iso_of_countable_dense (α := D) (β := ℚ)

end Cantor

/-! ## Step 2 — the cut map and its two well-definedness facts -/

section CutMap

variable {R : Type*} [LinearOrder R] {D : Set R}

/-- The rationals below `x`, read through `e`, as a set of reals.

This is the *Dedekind cut of `x` in `D`*, transported to `ℝ` along `e`. -/
def cutSet (e : D ≃o ℚ) (x : R) : Set ℝ :=
  (fun d : D => (e d : ℝ)) '' {d : D | (d : R) < x}

/-- **The cut map.** `cutMap e x` is the supremum in `ℝ` of the rationals that `e` assigns to the
elements of `D` strictly below `x`. This is the map that will be shown to be an order isomorphism
`R ≃o ℝ`. -/
noncomputable def cutMap (e : D ≃o ℚ) (x : R) : ℝ := sSup (cutSet e x)

theorem cutSet_nonempty (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y) (hmin : ∀ x : R, ∃ y, y < x) (x : R) :
    (cutSet e x).Nonempty := by
  obtain ⟨y, hy⟩ := hmin x
  obtain ⟨d, hd, -, h₂⟩ := hDd y x hy
  exact ⟨(e ⟨d, hd⟩ : ℝ), ⟨d, hd⟩, h₂, rfl⟩

/-- Any element of `D` lying above `x` bounds the cut set of `x`. -/
theorem cutSet_bddAbove_of (e : D ≃o ℚ) {x : R} {d₀ : D} (hd₀ : x < (d₀ : R)) :
    BddAbove (cutSet e x) := by
  refine ⟨(e d₀ : ℝ), ?_⟩
  rintro _ ⟨d, hd, rfl⟩
  have hlt : d < d₀ :=
    Subtype.coe_lt_coe.mp (lt_trans (show (d : R) < x from hd) hd₀)
  show ((e d : ℚ) : ℝ) ≤ ((e d₀ : ℚ) : ℝ)
  exact_mod_cast le_of_lt ((e.lt_iff_lt).mpr hlt)

theorem cutSet_bddAbove (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y) (hmax : ∀ x : R, ∃ y, x < y) (x : R) :
    BddAbove (cutSet e x) := by
  obtain ⟨y, hy⟩ := hmax x
  obtain ⟨d, hd, h₁, -⟩ := hDd x y hy
  exact cutSet_bddAbove_of e (d₀ := ⟨d, hd⟩) h₁

/-- If `d₀ ∈ D` lies above `x`, then `cutMap e x ≤ e d₀`. -/
theorem cutMap_le_of (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y) (hmin : ∀ x : R, ∃ y, y < x)
    {x : R} {d₀ : D} (hd₀ : x < (d₀ : R)) : cutMap e x ≤ (e d₀ : ℝ) := by
  refine csSup_le (cutSet_nonempty e hDd hmin x) ?_
  rintro _ ⟨d, hd, rfl⟩
  have hlt : d < d₀ :=
    Subtype.coe_lt_coe.mp (lt_trans (show (d : R) < x from hd) hd₀)
  show ((e d : ℚ) : ℝ) ≤ ((e d₀ : ℚ) : ℝ)
  exact_mod_cast le_of_lt ((e.lt_iff_lt).mpr hlt)

/-- If `d₀ ∈ D` lies below `x`, then `e d₀ ≤ cutMap e x`. -/
theorem le_cutMap_of (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y) (hmax : ∀ x : R, ∃ y, x < y)
    {x : R} {d₀ : D} (hd₀ : (d₀ : R) < x) : (e d₀ : ℝ) ≤ cutMap e x :=
  le_csSup (cutSet_bddAbove e hDd hmax x) ⟨d₀, hd₀, rfl⟩

/-! ## Step 3a — strict monotonicity -/

/-- **The cut map is strictly monotone.** Two applications of density of `D` in `R` produce
`d₁ < d₂` strictly between `x` and `y`; the cut of `x` is below `e d₁` and the cut of `y` is above
`e d₂`. -/
theorem strictMono_cutMap (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y)
    (hmax : ∀ x : R, ∃ y, x < y) (hmin : ∀ x : R, ∃ y, y < x) :
    StrictMono (cutMap e) := by
  intro x y hxy
  obtain ⟨d₁, hd₁, hx₁, h₁y⟩ := hDd x y hxy
  obtain ⟨d₂, hd₂, h₁₂, h₂y⟩ := hDd d₁ y h₁y
  have hlt : (⟨d₁, hd₁⟩ : D) < ⟨d₂, hd₂⟩ := h₁₂
  calc cutMap e x ≤ (e ⟨d₁, hd₁⟩ : ℝ) := cutMap_le_of e hDd hmin hx₁
    _ < (e ⟨d₂, hd₂⟩ : ℝ) := by exact_mod_cast (e.lt_iff_lt).mpr hlt
    _ ≤ cutMap e y := le_cutMap_of e hDd hmax h₂y

/-! ## Step 3b — surjectivity -/

/-- The elements of `D` whose `e`-image is strictly below `r`, as a subset of `R`. This is the
`R`-side Dedekind cut determined by the real number `r`. -/
def preCut (e : D ≃o ℚ) (r : ℝ) : Set R := (fun d : D => (d : R)) '' {d : D | (e d : ℝ) < r}

theorem preCut_nonempty (e : D ≃o ℚ) (r : ℝ) : (preCut e r).Nonempty := by
  obtain ⟨q, hq⟩ := exists_rat_lt r
  exact ⟨(e.symm q : R), e.symm q, by simpa using hq, rfl⟩

theorem preCut_bddAbove (e : D ≃o ℚ) (r : ℝ) : BddAbove (preCut e r) := by
  obtain ⟨q, hq⟩ := exists_rat_gt r
  refine ⟨(e.symm q : R), ?_⟩
  rintro _ ⟨d, hd, rfl⟩
  have hq' : (e d : ℝ) < ((e (e.symm q) : ℚ) : ℝ) := by simpa using lt_trans hd hq
  have : d < e.symm q := (e.lt_iff_lt).mp (by exact_mod_cast hq')
  exact le_of_lt this

/-- **The cut map hits every real.** `u` is the least upper bound in `R` of the `D`-elements sent
below `r`; its cut is exactly `r`. Dedekind completeness of `R` supplies `u`, and completeness of
`ℝ` (through `exists_rat_btwn`) closes both inequalities. -/
theorem cutMap_surjective (e : D ≃o ℚ)
    (hDd : ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y)
    (hmax : ∀ x : R, ∃ y, x < y) (hmin : ∀ x : R, ∃ y, y < x)
    (hlub : ∀ S : Set R, S.Nonempty → BddAbove S → ∃ u, IsLUB S u) :
    Function.Surjective (cutMap e) := by
  intro r
  obtain ⟨u, hu⟩ := hlub (preCut e r) (preCut_nonempty e r) (preCut_bddAbove e r)
  refine ⟨u, le_antisymm ?_ ?_⟩
  · -- `cutMap e u ≤ r`: every `d ∈ D` below `u` is strictly below some member of the pre-cut.
    refine csSup_le (cutSet_nonempty e hDd hmin u) ?_
    rintro _ ⟨d, hd, rfl⟩
    show ((e d : ℚ) : ℝ) ≤ r
    have hdu : (d : R) < u := hd
    have hnub : (d : R) ∉ upperBounds (preCut e r) := fun hmem =>
      absurd (hu.2 hmem) (not_le.mpr hdu)
    rw [mem_upperBounds] at hnub
    push Not at hnub
    obtain ⟨a, ha, hda⟩ := hnub
    obtain ⟨d', hd', rfl⟩ := ha
    have hdd' : d < d' := Subtype.coe_lt_coe.mp hda
    have h₁ : ((e d : ℚ) : ℝ) < ((e d' : ℚ) : ℝ) := by
      exact_mod_cast (e.lt_iff_lt).mpr hdd'
    exact le_of_lt (lt_trans h₁ hd')
  · -- `r ≤ cutMap e u`: every rational strictly below `r` is `≤ cutMap e u`.
    by_contra hcon
    push Not at hcon
    obtain ⟨q, hq₁, hq₂⟩ := exists_rat_btwn hcon
    -- `e.symm q` lies in the pre-cut, hence `≤ u`; in fact `< u`.
    have hmemq : (e.symm q : R) ∈ preCut e r := ⟨e.symm q, by simpa using hq₂, rfl⟩
    have hleu : (e.symm q : R) ≤ u := hu.1 hmemq
    have hltu : (e.symm q : R) < u := by
      rcases lt_or_eq_of_le hleu with h | h
      · exact h
      · -- if `e.symm q = u`, a rational strictly between `q` and `r` contradicts leastness
        exfalso
        obtain ⟨q', hq'₁, hq'₂⟩ := exists_rat_btwn hq₂
        have hmemq' : (e.symm q' : R) ∈ preCut e r := ⟨e.symm q', by simpa using hq'₂, rfl⟩
        have hcoe : (e.symm q' : R) ≤ (e.symm q : R) := by rw [h]; exact hu.1 hmemq'
        have hle' : e.symm q' ≤ e.symm q := Subtype.coe_le_coe.mp hcoe
        have hqq : q' ≤ q := (e.symm.le_iff_le).mp hle'
        exact absurd hq'₁ (not_lt.mpr (by exact_mod_cast hqq))
    have hfin : ((e (e.symm q) : ℚ) : ℝ) ≤ cutMap e u := le_cutMap_of e hDd hmax hltu
    simp only [OrderIso.apply_symm_apply] at hfin
    exact absurd hq₁ (not_lt.mpr hfin)

end CutMap

/-! ## The characterization -/

/-- **The order characterization of `ℝ`** (statement: Reynolds 1992, §8, printed p.188 —
*"But then `R` being Dedekind complete, dense, without end points and with a countable dense
subset must be isomorphic to the reals."*).

Any non-empty, densely ordered, endpointless, Dedekind complete linear order with a countable
order-dense subset is order-isomorphic to `ℝ`.

The proof is original to this development (see the module docstring for the recorded Mathlib
search): Cantor's isomorphism theorem transports the countable dense subset to `ℚ`, and the cut
map `x ↦ sSup {e d | d < x}` is then strictly monotone by density and surjective by Dedekind
completeness. -/
theorem orderIsoRealOfDedekindDenseSeparable {R : Type*} [LinearOrder R] (h : IsRealLike R) :
    Nonempty (R ≃o ℝ) := by
  obtain ⟨D, hDc, hDd⟩ := h.sep
  obtain ⟨e⟩ := nonempty_orderIso_rat_of_countableDense hDc hDd h.nonempty' h.noMax h.noMin
  exact ⟨StrictMono.orderIsoOfSurjective (cutMap e) (strictMono_cutMap e hDd h.noMax h.noMin)
    (cutMap_surjective e hDd h.noMax h.noMin h.lub)⟩

/-- Convenience form: the same statement with the hypotheses spelled out rather than bundled. -/
theorem nonempty_orderIso_real_of_facts {R : Type*} [LinearOrder R] [Nonempty R]
    (hdense : ∀ x y : R, x < y → ∃ z, x < z ∧ z < y)
    (hmax : ∀ x : R, ∃ y, x < y) (hmin : ∀ x : R, ∃ y, y < x)
    (hlub : ∀ S : Set R, S.Nonempty → BddAbove S → ∃ u, IsLUB S u)
    (hsep : ∃ D : Set R, D.Countable ∧ ∀ x y : R, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    Nonempty (R ≃o ℝ) :=
  orderIsoRealOfDedekindDenseSeparable
    ⟨inferInstance, hdense, hmax, hmin, hlub, hsep⟩

/-! ## Anti-vacuity

`IsRealLike` would be worthless if nothing satisfied it. `ℝ` itself does — the trivial instance,
recorded first so that the bundle is known to be consistent. The genuinely non-trivial
instantiation, at the `ℝ`-shuffle of a family of monadic structures, is landed in
`RealModel/ShuffleReal.lean`, which imports this module; it is not `ℝ` in disguise, since its
carrier is a lexicographic `Sigma` type over `ℝ` with arbitrary summands. -/

section AntiVacuity

/-- The rationals, as a subset of `ℝ`, are countable and order-dense. -/
theorem countableDense_rat_real :
    (Set.range ((↑) : ℚ → ℝ)).Countable ∧
      ∀ x y : ℝ, x < y → ∃ d ∈ Set.range ((↑) : ℚ → ℝ), x < d ∧ d < y := by
  refine ⟨Set.countable_range _, fun x y hxy => ?_⟩
  obtain ⟨q, hq₁, hq₂⟩ := exists_rat_btwn hxy
  exact ⟨(q : ℝ), ⟨q, rfl⟩, hq₁, hq₂⟩

/-- **Anti-vacuity, base case**: `ℝ` is `IsRealLike`. -/
theorem isRealLike_real : IsRealLike ℝ where
  nonempty' := ⟨0⟩
  dense := fun _ _ h => exists_between h
  noMax := fun x => ⟨x + 1, by linarith⟩
  noMin := fun x => ⟨x - 1, by linarith⟩
  lub := fun S hS hbdd => ⟨sSup S, isLUB_csSup hS hbdd⟩
  sep := ⟨Set.range ((↑) : ℚ → ℝ), countableDense_rat_real.1, countableDense_rat_real.2⟩

/-- **Anti-vacuity, base case, concluded**: the characterization applied to `ℝ` itself returns an
order isomorphism. This is not circular — it exercises the whole construction (Cantor on `ℚ ⊆ ℝ`,
then the cut map) and would fail if any step were vacuous. -/
theorem nonempty_orderIso_real_real : Nonempty (ℝ ≃o ℝ) :=
  orderIsoRealOfDedekindDenseSeparable isRealLike_real

end AntiVacuity

end FormalSystem.Metalogic.WeakCanonical
