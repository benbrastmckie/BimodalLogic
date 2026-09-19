/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.FMCSDef
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Order.Filter.Ultrafilter.Basic
import Mathlib.Topology.Order.LeftRightNhds
import Mathlib.Topology.Instances.Real.Lemmas

/-!
# LimitMCS: the limit set of a rational MCS family at a real point

This module defines the *limit set* of a family of maximal consistent sets indexed by `Rat`,
taken at an arbitrary real point, and proves that it is consistent.

The construction is the first half of the seam that carries the dense canonical model from
`Rat` to `ℝ`. The back-and-forth (Cantor) chronicle layer that produces the rational family
stays at `Rat` — Cantor's theorem needs a *countable* dense order without endpoints — and only
the carrier-generic layer beneath it moves to `ℝ`. See `Bundle/FMCSDef.lean` for the family
structure and `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` for the rational
chronicle whose families this module consumes.

## Main definitions

- `TemporalSide`: `below` or `above` — which one-sided neighbourhood of a real point a limit
  filter/set/MCS is taken from. `limitFilter`, `limitSet` and `limitMCS` are stated once,
  parameterized on it; `limitSetBelow`, `limitSetAbove`, `limitFilterBelow`, `limitFilterAbove`,
  `limitMCSBelow` and `limitMCSAbove` are its thin definitional specializations. The `Below`
  names are unchanged from before this parameterization — ~57 external references across seven
  files (five under `BXCanonical/Chronicle/`) depend on them keeping their exact identity and
  statement shape.
- `limitSetBelow m r`: the formulas that are *eventually* in `m q` as the rational `q`
  approaches the real `r` from below. `limitSetAbove m r` is the past-side dual.

## Main results

- `limitSet_consistent`: the limit set is `SetConsistent` whenever every `m q` is maximal
  consistent, on *either* side — the argument is pure `Filter` algebra (`Filter.inter_mem` +
  `Filter.nonempty_of_mem`) and does not depend on which one-sided neighbourhood is selected.
  `limitSetBelow_consistent` / `limitSetAbove_consistent` are its two instantiations.
- `limitSetBelow_of_rat` / `limitSetAbove_of_rat`: what the rational family's own temporal
  coherence transfers into the limit set at a rational point.
- `limitMCS` / `limitMCS_is_mcs`: a maximal consistent set *extending* `limitSet side m r`,
  obtained as an ultrafilter limit of `m` along `limitFilter side r`. See "Why the limit set
  itself is not maximal" below. `limitMCSBelow` is its `below` instantiation, unchanged from
  before; `limitMCSAbove` is the previously-missing `above` instantiation this parameterization
  delivers.
- `limitMCSBelow_cofinal_below`: every member of `limitMCSBelow m r` is realised at rationals
  arbitrarily close below `r`. This is the descent handle the extension's temporal coherence
  needs, and it is the reason an ultrafilter limit is used rather than an arbitrary Lindenbaum
  extension. (Kept `below`-specific: the direction-dependent interval-threshold statement does
  not generalize as cleanly as the filter-algebra results above, and no `above` instantiation of
  it is consumed anywhere.)
- `fc_theorem_true_in_parametric_model`: every theorem of `fc` is true at every point of the
  parametric canonical model.

## Why the limit set itself is not maximal

`limitSetBelow m r` is consistent but **not** negation-complete, and no strengthening of the
family's coherence conditions makes it so. Negation-completeness of the limit set says: for
every formula `A` there is a threshold `z < r` past which `A` has a *constant* truth value on
the rationals in `(z, r)`. A formula whose membership pattern is dense and co-dense in every
left neighbourhood of `r` violates this while satisfying every coherence condition available,
because the coherence conditions relate membership only along the strict order.

It is tempting to read Reynolds' no-definable-gaps lemma as supplying eventual constancy. It
does not, and the distinction is the crux of this module. Reynolds (1992, §5, printed p.176)
defines `γ⁺(A)` to hold "exactly when `A` remains true for a while after now but only up until
a gap after which `A` is arbitrarily soon false", and calls the indicated gap a *definable gap*;
a Prior structure — one satisfying every substitution instance of Prior-U and Prior-S — has no
definable gaps. The hypothesis of that lemma already requires `A` to be **constantly true on an
interval abutting the gap**. Prior-U (`ProofSystem/Axioms.lean`, `Axiom.prior_U_gap`) makes the
same requirement explicitly: its antecedent is `U(⊤, φ) ∧ F(¬φ)`, and `U(⊤, φ)` says `φ` holds
throughout some initial future segment. So the axiom is vacuous on exactly the formulas that
would refute negation-completeness — those with no interval of constancy at all. "No definable
gaps" is therefore strictly weaker than "every formula is eventually constant approaching `r`",
and cannot be used to derive it.

A second, independent obstruction: Prior-U and Prior-S are statements about `untl` and `snce`.
Turning membership of a Prior instance in `m q` into a fact about membership at *other*
rationals requires Until/Since coherence for the family (`Bundle/TemporalCoherence.lean`,
`BFMCS.ForwardUntilSinceCoherent` / `BFMCS.BackwardUntilSinceCoherent`), which is not among
this module's hypotheses, and which the back-and-forth chronicle supplies only in its
*Restricted* form, scoped to the deferral closure of a single root formula.

**Route taken.** Maximality is therefore obtained by extending the consistent limit set, not by
proving it maximal. `limitMCSBelow` takes the ultrafilter limit of the family along the
left-neighbourhood filter of `r` (`limitFilterBelow`). It is maximal for the same reason any
ultrafilter limit is, it contains `limitSetBelow m r` because the ultrafilter refines that
filter, and, crucially, it retains the descent handle: every one of its members is realised at
rationals arbitrarily close below `r` (`limitMCSBelow_cofinal_below`). Consumers that need to
reason from a membership at an unselected real point back to the rational family must use
`limitMCSBelow` and that lemma.

## Scope of the limit construction

Reynolds (1992), §1, printed p.169, is explicit that the Prior axioms enforce a *definably*
Dedekind complete model: there may be gaps in the order, but they are not visible to temporal
formulas. Accordingly nothing here claims an order-theoretic completion; the limit set is a
purely syntactic "eventually true approaching `r`" set, and its maximality is a separate
question argued from the no-definable-gaps lemma rather than from any property of `ℝ`.

## What `limitSetBelow_of_rat` does and does not say

At a rational point `q`, the *left limit* `limitSetBelow m (q : ℝ)` is **not** equal to `m q`,
and no strengthening of the rational family's coherence conditions makes it so. Both inclusions
fail:

- `limitSetBelow m (q : ℝ) ⊆ m q` fails: an atom `P` may lie in `m p` for every rational
  `p < q` and yet not lie in `m q`. The family's coherence conditions are `forward_G` and
  `backward_H` (`Bundle/FMCSDef.lean`), both stated with *strict* inequalities, so neither
  constrains membership at `q` from membership strictly below `q`. There is no axiom of the
  shape `H φ → φ` to appeal to: `allPast` is the strict past operator.
- `m q ⊆ limitSetBelow m (q : ℝ)` fails symmetrically: membership at `q` says nothing about
  membership strictly below `q`.

What coherence *does* transfer is the whole-past and whole-future content, and that is what is
proved below: `allPast A ∈ m q` puts `A` into the set approached from below, and
`allFuture A ∈ m q` puts `A` into the set approached from above. Consumers that need genuine
agreement at rational points must select `m q` directly at rational arguments rather than
taking a one-sided limit there.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## `TemporalSide`: below vs. above, as a single parameter -/

/-- Which one-sided neighbourhood of a real point a limit filter/set/MCS is taken from. -/
inductive TemporalSide
  | below
  | above
  deriving DecidableEq

/-- The one-sided real neighbourhood `side` selects at a point `r`: `Set.Iio r` for `below`,
`Set.Ioi r` for `above`. -/
def TemporalSide.nbhd : TemporalSide → ℝ → Set ℝ
  | .below, r => Set.Iio r
  | .above, r => Set.Ioi r

/-! ## The `side`-neighbourhood filter -/

/--
The **`side`-neighbourhood filter** of a real point `r` on the rationals: the pullback along
`Rat.cast` of `ℝ`'s neighbourhood filter within `side.nbhd r`. A set of rationals is large
exactly when it contains every rational in some one-sided interval abutting `r` on `side`'s
side — `mem_limitFilterBelow` / `mem_limitFilterAbove` unfold this from Mathlib's order-topology
basis for `nhdsWithin r (side.nbhd r)`.
-/
def limitFilter (side : TemporalSide) (r : ℝ) : Filter Rat :=
  Filter.comap (Rat.cast : Rat → ℝ) (nhdsWithin r (side.nbhd r))

/-- The **below** specialization of `limitFilter`, unchanged from before this parameterization. -/
def limitFilterBelow (r : ℝ) : Filter Rat := limitFilter .below r

/-- The **above** specialization of `limitFilter` — previously missing, delivered by the
parameterization. -/
def limitFilterAbove (r : ℝ) : Filter Rat := limitFilter .above r

/-- Membership in `limitFilterBelow`, unfolded to the interval-threshold shape. -/
theorem mem_limitFilterBelow {r : ℝ} {S : Set Rat} :
    S ∈ limitFilterBelow r ↔ ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → q ∈ S := by
  have hbasis := (nhdsLT_basis_of_exists_lt (a := r) ⟨r - 1, by linarith⟩).comap
    (Rat.cast : Rat → ℝ)
  unfold limitFilterBelow limitFilter TemporalSide.nbhd
  rw [hbasis.mem_iff]
  constructor
  · rintro ⟨z, hz, hsub⟩
    exact ⟨z, hz, fun q h1 h2 => hsub ⟨h1, h2⟩⟩
  · rintro ⟨z, hz, h⟩
    exact ⟨z, hz, fun q ⟨h1, h2⟩ => h q h1 h2⟩

/-- Membership in `limitFilterAbove`, unfolded to the interval-threshold shape. Dual of
`mem_limitFilterBelow`. -/
theorem mem_limitFilterAbove {r : ℝ} {S : Set Rat} :
    S ∈ limitFilterAbove r ↔ ∃ z : ℝ, r < z ∧ ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → q ∈ S := by
  have hbasis := (nhdsGT_basis_of_exists_gt (a := r) ⟨r + 1, by linarith⟩).comap
    (Rat.cast : Rat → ℝ)
  unfold limitFilterAbove limitFilter TemporalSide.nbhd
  rw [hbasis.mem_iff]
  constructor
  · rintro ⟨z, hz, hsub⟩
    exact ⟨z, hz, fun q h1 h2 => hsub ⟨h2, h1⟩⟩
  · rintro ⟨z, hz, h⟩
    exact ⟨z, hz, fun q ⟨h1, h2⟩ => h q h2 h1⟩

/-- The `side`-neighbourhood filter is proper on either side: every one-sided interval abutting
`r` contains a rational, by `exists_rat_btwn`. -/
instance limitFilter_neBot (side : TemporalSide) (r : ℝ) : (limitFilter side r).NeBot := by
  cases side with
  | below =>
    rw [show limitFilter .below r = limitFilterBelow r from rfl, Filter.neBot_iff, Ne,
      ← Filter.empty_mem_iff_bot, mem_limitFilterBelow]
    rintro ⟨z, hz, hmem⟩
    obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
    exact hmem q hq1 hq2
  | above =>
    rw [show limitFilter .above r = limitFilterAbove r from rfl, Filter.neBot_iff, Ne,
      ← Filter.empty_mem_iff_bot, mem_limitFilterAbove]
    rintro ⟨z, hz, hmem⟩
    obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
    exact hmem q hq2 hq1

/-- `limitFilterBelow r` is proper. The named filter is a `def`, so instance search does not see
through it to `limitFilter .below r`; this instance re-exports `limitFilter_neBot` under the
name callers actually write. -/
instance limitFilterBelow_neBot (r : ℝ) : (limitFilterBelow r).NeBot := limitFilter_neBot .below r
/-- `limitFilterAbove r` is proper. The named filter is a `def`, so instance search does not see
through it to `limitFilter .above r`; this instance re-exports `limitFilter_neBot` under the
name callers actually write. -/
instance limitFilterAbove_neBot (r : ℝ) : (limitFilterAbove r).NeBot := limitFilter_neBot .above r

/-! ## The limit sets -/

/--
The **limit set on `side`** of a rational family `m` at a real point `r`: the `A`s that are
eventually in `m q` for `limitFilter side r`.
-/
def limitSet (side : TemporalSide) (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | ∀ᶠ q in limitFilter side r, A ∈ m q}

/-- The **limit set from below** — unchanged from before this parameterization. -/
def limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula := limitSet .below m r

/-- The **limit set from above** — the past-side dual of `limitSetBelow`. -/
def limitSetAbove (m : Rat → Set Formula) (r : ℝ) : Set Formula := limitSet .above m r

/--
Membership in `limitSetBelow`, unfolded to the interval-threshold shape via
`mem_limitFilterBelow`. **The one unfolding lemma** every downstream file uses -- `limitSetBelow`
itself is no longer unfolded directly outside this module.
-/
theorem mem_limitSetBelow {m : Rat → Set Formula} {r : ℝ} {A : Formula} :
    A ∈ limitSetBelow m r ↔ ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → A ∈ m q :=
  mem_limitFilterBelow

/-- Membership in `limitSetAbove`, unfolded to the interval-threshold shape. Dual of
`mem_limitSetBelow`. -/
theorem mem_limitSetAbove {m : Rat → Set Formula} {r : ℝ} {A : Formula} :
    A ∈ limitSetAbove m r ↔ ∃ z : ℝ, r < z ∧ ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → A ∈ m q :=
  mem_limitFilterAbove

/-! ## Consistency of the limit sets -/

/--
**The limit set is consistent, on either side.**

`SetConsistent` (`Core/MaximalConsistent.lean`) is a property of finite subsets. Every finite
list drawn from `limitSet side m r` gives a finite intersection of `limitFilter side r`-large
sets, which is itself large (`Filter.inter_mem`, by induction on the list) and hence nonempty
(`Filter.nonempty_of_mem`, via the `limitFilter_neBot` instance) -- so some `q` realises the
whole list, and `m q`'s own consistency finishes it. The argument is pure `Filter` algebra: it
never inspects which one-sided neighbourhood `limitFilter side r` selects.
-/
theorem limitSet_consistent {fc : FrameClass} (side : TemporalSide) (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSet side m r) := by
  intro L hL
  have key : ∀ L : List Formula, (∀ A ∈ L, A ∈ limitSet side m r) →
      {q : Rat | ∀ A ∈ L, A ∈ m q} ∈ limitFilter side r := by
    intro L
    induction L with
    | nil =>
      intro _
      have huniv : {q : Rat | ∀ A ∈ ([] : List Formula), A ∈ m q} = Set.univ := by
        ext q; simp
      rw [huniv]
      exact Filter.univ_mem
    | cons A L ih =>
      intro hL'
      have hA : {q : Rat | A ∈ m q} ∈ limitFilter side r := hL' A (by simp)
      have hrest := ih (fun B hB => hL' B (List.mem_cons_of_mem _ hB))
      refine Filter.mem_of_superset (Filter.inter_mem hA hrest) ?_
      rintro q ⟨hq1, hq2⟩ B hB
      rcases List.mem_cons.mp hB with rfl | hB'
      · exact hq1
      · exact hq2 B hB'
  obtain ⟨q, hq⟩ := Filter.nonempty_of_mem (key L hL)
  exact (hm q).1 L hq

/-- **The limit set from below is consistent.** Instantiation of `limitSet_consistent` at
`.below`, unchanged in statement from before this parameterization. -/
theorem limitSetBelow_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetBelow m r) :=
  limitSet_consistent .below m hm r

/-- **The limit set from above is consistent.** Instantiation of `limitSet_consistent` at
`.above`. -/
theorem limitSetAbove_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetAbove m r) :=
  limitSet_consistent .above m hm r

/-! ## Behaviour at rational points

See the module docstring for why equality with `m q` is unavailable here, and what is available
instead.
-/

/--
What the rational family's `backward_H` coherence transfers into the limit set from below at a
rational point: if the whole strict past of `q` is asserted at `q`, the asserted formula is in
the left limit at `q`.

The hypothesis `hH` is exactly the `backward_H` field of `FMCS` (`Bundle/FMCSDef.lean`),
specialised to `D := Rat`, and is taken as an argument so that this lemma is usable before the
real-carrier family is assembled.
-/
theorem limitSetBelow_of_rat (m : Rat → Set Formula)
    (hH : ∀ (s t : Rat) (φ : Formula), t < s → Formula.allPast φ ∈ m s → φ ∈ m t)
    (q : Rat) (A : Formula) (hA : Formula.allPast A ∈ m q) :
    A ∈ limitSetBelow m (q : ℝ) := by
  rw [mem_limitSetBelow]
  refine ⟨(q : ℝ) - 1, by linarith, ?_⟩
  intro p _ hp2
  exact hH q p A (by exact_mod_cast hp2) hA

/--
Dual of `limitSetBelow_of_rat`: `forward_G` coherence transfers the whole strict future of `q`
into the limit set from above at `q`.
-/
theorem limitSetAbove_of_rat (m : Rat → Set Formula)
    (hG : ∀ (s t : Rat) (φ : Formula), s < t → Formula.allFuture φ ∈ m s → φ ∈ m t)
    (q : Rat) (A : Formula) (hA : Formula.allFuture A ∈ m q) :
    A ∈ limitSetAbove m (q : ℝ) := by
  rw [mem_limitSetAbove]
  refine ⟨(q : ℝ) + 1, by linarith, ?_⟩
  intro p _ hp2
  exact hG q p A (by exact_mod_cast hp2) hA

/-! ## Maximality by ultrafilter limit

The extension consumers should use. Its members are exactly the formulas whose membership set
`{q | A ∈ m q}` is "large" for a fixed ultrafilter refining `limitFilter side r`, so maximality
is immediate from the ultrafilter dichotomy while every member remains realised at rationals
arbitrarily close to `r` on `side`'s side.
-/

/-- A fixed ultrafilter refining `limitFilter side r`. -/
noncomputable def limitUltrafilter (side : TemporalSide) (r : ℝ) : Ultrafilter Rat :=
  Ultrafilter.of (limitFilter side r)

/-- A fixed ultrafilter refining the left-neighbourhood filter of `r` -- unchanged from before
this parameterization. Still needed directly (not merely as `limitUltrafilter .below`):
`limitMCSBelow`, `limitMCSBelow_cofinal_below`, `limitMCSBelow_finite_subset_mem` and
`limitMCSBelow_is_mcs` are all stated over it. -/
noncomputable def limitUltrafilterBelow (r : ℝ) : Ultrafilter Rat := limitUltrafilter .below r

theorem limitFilter_le (side : TemporalSide) (r : ℝ) {S : Set Rat} (hS : S ∈ limitFilter side r) :
    S ∈ (limitUltrafilter side r : Filter Rat) :=
  Ultrafilter.of_le (limitFilter side r) hS

theorem limitFilterBelow_le (r : ℝ) {S : Set Rat} (hS : S ∈ limitFilterBelow r) :
    S ∈ (limitUltrafilterBelow r : Filter Rat) :=
  limitFilter_le .below r hS

/--
The **ultrafilter limit on `side`** of the rational family `m` at the real point `r`: the
formulas whose membership set is large for `limitUltrafilter side r`.
-/
def limitMCS (side : TemporalSide) (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | {q : Rat | A ∈ m q} ∈ (limitUltrafilter side r : Filter Rat)}

/-- The **below** specialization of `limitMCS`, unchanged from before this parameterization. -/
def limitMCSBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula := limitMCS .below m r

/-- The **above** specialization of `limitMCS` -- previously missing, delivered by the
parameterization. -/
def limitMCSAbove (m : Rat → Set Formula) (r : ℝ) : Set Formula := limitMCS .above m r

theorem mem_limitMCSBelow {m : Rat → Set Formula} {r : ℝ} {A : Formula} :
    A ∈ limitMCSBelow m r ↔ {q : Rat | A ∈ m q} ∈ (limitUltrafilterBelow r : Filter Rat) :=
  Iff.rfl

/--
**The ultrafilter limit extends the limit set, on either side.** An "eventually true
approaching `r`" formula has a membership set that is already large for `limitFilter side r`,
hence large for the refining ultrafilter -- by `limitFilter_le`, unfolding both sides
definitionally as `Filter.Eventually`.
-/
theorem limitSet_subset_limitMCS (side : TemporalSide) (m : Rat → Set Formula) (r : ℝ) :
    limitSet side m r ⊆ limitMCS side m r :=
  fun _ hA => limitFilter_le side r hA

/--
The ultrafilter limit **extends** the limit set: an "eventually true approaching `r` from
below" formula has a membership set that is already large for the left-neighbourhood filter.
Instantiation of `limitSet_subset_limitMCS` at `.below`, unchanged in statement.
-/
theorem limitSetBelow_subset_limitMCSBelow (m : Rat → Set Formula) (r : ℝ) :
    limitSetBelow m r ⊆ limitMCSBelow m r :=
  limitSet_subset_limitMCS .below m r

/--
**The descent handle.** Every member of the ultrafilter limit at `r` is realised at rationals
arbitrarily close below `r`.

This is what an arbitrary Lindenbaum extension cannot provide, and it is what lets a membership
at a real point be traced back to the rational family. The proof is the ultrafilter's
properness: the membership set and the interval `(z, r)` are both large, so they meet. Kept
`below`-specific -- see the module docstring.
-/
theorem limitMCSBelow_cofinal_below (m : Rat → Set Formula) (r : ℝ) {A : Formula}
    (hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) :
    ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ A ∈ m q := by
  have hbasis : {q : Rat | z < (q : ℝ) ∧ (q : ℝ) < r} ∈ (limitUltrafilterBelow r : Filter Rat) :=
    limitFilterBelow_le r (mem_limitFilterBelow.mpr ⟨z, hz, fun q h1 h2 => ⟨h1, h2⟩⟩)
  obtain ⟨q, hq⟩ := Filter.nonempty_of_mem (Filter.inter_mem hA hbasis)
  exact ⟨q, hq.2.1, hq.2.2, hq.1⟩

/--
Every finite list drawn from the ultrafilter limit on `side` is contained in a single `m q`.

The set of rationals carrying the whole list is a finite intersection of large sets, hence
large, hence nonempty. Pure `Filter` algebra, generic in `side`.
-/
theorem limitMCS_finite_subset_mem (side : TemporalSide) (m : Rat → Set Formula) (r : ℝ)
    (L : List Formula) (hL : ∀ A ∈ L, A ∈ limitMCS side m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  have key : ∀ L : List Formula, (∀ A ∈ L, A ∈ limitMCS side m r) →
      {q : Rat | ∀ A ∈ L, A ∈ m q} ∈ (limitUltrafilter side r : Filter Rat) := by
    intro L
    induction L with
    | nil =>
      intro _
      have huniv : {q : Rat | ∀ A ∈ ([] : List Formula), A ∈ m q} = Set.univ := by
        ext q; simp
      rw [huniv]
      exact Filter.univ_mem
    | cons A L ih =>
      intro hL'
      have hA : {q : Rat | A ∈ m q} ∈ (limitUltrafilter side r : Filter Rat) := hL' A (by simp)
      have hrest := ih (fun B hB => hL' B (List.mem_cons_of_mem _ hB))
      refine Filter.mem_of_superset (Filter.inter_mem hA hrest) ?_
      rintro q ⟨hq1, hq2⟩ B hB
      rcases List.mem_cons.mp hB with rfl | hB'
      · exact hq1
      · exact hq2 B hB'
  obtain ⟨q, hq⟩ := Filter.nonempty_of_mem (key L hL)
  exact ⟨q, hq⟩

/-- **Below** instantiation of `limitMCS_finite_subset_mem`, unchanged in statement. -/
theorem limitMCSBelow_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitMCSBelow m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q :=
  limitMCS_finite_subset_mem .below m r L hL

/--
**The ultrafilter limit is maximal consistent, on either side.**

Consistency is the finite-subset argument above. Negation-completeness is the ultrafilter
dichotomy: if `{q | A ∈ m q}` is not large then its complement is, and each `m q` in the
complement carries `A.neg` by negation-completeness of `m q`. Generic in `side`.
-/
theorem limitMCS_is_mcs {fc : FrameClass} (side : TemporalSide) (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetMaximalConsistent (fc := fc) (limitMCS side m r) := by
  have hcons : SetConsistent (fc := fc) (limitMCS side m r) := by
    intro L hL
    obtain ⟨q, hq⟩ := limitMCS_finite_subset_mem side m r L hL
    exact (hm q).1 L hq
  refine ⟨hcons, ?_⟩
  intro φ hφ hins
  have hcompl : {q : Rat | φ ∈ m q}ᶜ ∈ (limitUltrafilter side r : Filter Rat) :=
    (limitUltrafilter side r).compl_mem_iff_notMem.2 hφ
  have hneg : Formula.neg φ ∈ limitMCS side m r := by
    refine Filter.mem_of_superset hcompl ?_
    intro q hq
    exact ((hm q).negation_complete φ).resolve_left hq
  exact set_consistent_not_both hins φ (Set.mem_insert _ _) (Set.mem_insert_of_mem _ hneg)

/-- **Below** instantiation of `limitMCS_is_mcs`, unchanged in statement. -/
theorem limitMCSBelow_is_mcs {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetMaximalConsistent (fc := fc) (limitMCSBelow m r) :=
  limitMCS_is_mcs .below m hm r

/-- **Above** instantiation of `limitMCS_is_mcs` -- previously missing, delivered by the
parameterization. -/
theorem limitMCSAbove_is_mcs {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetMaximalConsistent (fc := fc) (limitMCSAbove m r) :=
  limitMCS_is_mcs .above m hm r

end FormalSystem.Metalogic.Bundle
