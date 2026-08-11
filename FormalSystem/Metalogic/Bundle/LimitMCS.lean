/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Order.Filter.Ultrafilter.Basic

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

- `limitSetBelow m r`: the formulas that are *eventually* in `m q` as the rational `q`
  approaches the real `r` from below.
- `limitSetAbove m r`: the past-side dual, approaching `r` from above.

## Main results

- `limitSetBelow_mono_directed` / `limitSetAbove_mono_directed`: the defining family of
  witness intervals is directed, so any finite list of members shares one witness interval.
- `limitSetBelow_consistent` / `limitSetAbove_consistent`: the limit set is `SetConsistent`
  whenever every `m q` is maximal consistent. Every finite subset is contained in a single
  `m q`, and consistency is a property of finite subsets by definition
  (`Core/MaximalConsistent.lean`, `SetConsistent`).
- `limitSetBelow_of_rat` / `limitSetAbove_of_rat`: what the rational family's own temporal
  coherence transfers into the limit set at a rational point.
- `limitMCSBelow` and `limitMCSBelow_is_mcs`: a maximal consistent set *extending*
  `limitSetBelow m r`, obtained as an ultrafilter limit of `m` along the left-neighbourhood
  filter of `r`. See "Why the limit set itself is not maximal" below.
- `limitMCSBelow_cofinal_below`: every member of `limitMCSBelow m r` is realised at rationals
  arbitrarily close below `r`. This is the descent handle the extension's temporal coherence
  needs, and it is the reason an ultrafilter limit is used rather than an arbitrary Lindenbaum
  extension.
- `limitMCSLindenbaum`: the arbitrary-extension variant, recorded for comparison.
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
proving it maximal. Two extensions are provided. `limitMCSLindenbaum` is the bare
`set_lindenbaum` extension; it is maximal but the choice is arbitrary, so nothing about the
extension's members descends back to the rational family. `limitMCSBelow` — the one intended for
consumers — takes the ultrafilter limit of the family along the left-neighbourhood filter of `r`
(`limitFilterBelow`). It is maximal for the same reason any ultrafilter limit is, it contains
`limitSetBelow m r` because the ultrafilter refines that filter, and, crucially, it retains the
descent handle: every one of its members is realised at rationals arbitrarily close below `r`
(`limitMCSBelow_cofinal_below`). Consumers that need to reason from a membership at an
unselected real point back to the rational family must use `limitMCSBelow` and that lemma.

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

/-! ## The limit sets -/

/--
The **limit set from below** of a rational family `m` at a real point `r`: the formulas that
are eventually in `m q` as the rational `q` increases to `r`.

"Eventually" is witnessed by a real threshold `z < r`: every rational strictly between `z` and
`r` already carries the formula.
-/
def limitSetBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → A ∈ m q}

/--
The **limit set from above** of a rational family `m` at a real point `r`: the past-side dual
of `limitSetBelow`, with the witness threshold `z` now above `r`.
-/
def limitSetAbove (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | ∃ z : ℝ, r < z ∧ ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → A ∈ m q}

/-! ## Directedness of the witness intervals -/

/--
The witness intervals of `limitSetBelow` are **directed**: any finite list of members of
`limitSetBelow m r` shares a single threshold `z < r` that works for all of them
simultaneously.

Proved by list induction, taking the maximum of the two thresholds at each cons step. The
empty list is witnessed by `r - 1`.
-/
theorem limitSetBelow_mono_directed (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetBelow m r) :
    ∃ z : ℝ, z < r ∧ ∀ A ∈ L, ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → A ∈ m q := by
  induction L with
  | nil =>
    refine ⟨r - 1, by linarith, ?_⟩
    intro A hA
    exact absurd hA (List.not_mem_nil)
  | cons A L ih =>
    obtain ⟨zA, hzA, hAmem⟩ := hL A (by simp)
    obtain ⟨zL, hzL, hLmem⟩ := ih (fun B hB => hL B (List.mem_cons_of_mem _ hB))
    refine ⟨max zA zL, max_lt hzA hzL, ?_⟩
    intro B hB q hq1 hq2
    rcases List.mem_cons.mp hB with rfl | hB'
    · exact hAmem q (lt_of_le_of_lt (le_max_left _ _) hq1) hq2
    · exact hLmem B hB' q (lt_of_le_of_lt (le_max_right _ _) hq1) hq2

/--
The witness intervals of `limitSetAbove` are directed. Dual of `limitSetBelow_mono_directed`,
with `min` in place of `max` and `r + 1` witnessing the empty list.
-/
theorem limitSetAbove_mono_directed (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetAbove m r) :
    ∃ z : ℝ, r < z ∧ ∀ A ∈ L, ∀ q : Rat, (q : ℝ) < z → r < (q : ℝ) → A ∈ m q := by
  induction L with
  | nil =>
    refine ⟨r + 1, by linarith, ?_⟩
    intro A hA
    exact absurd hA (List.not_mem_nil)
  | cons A L ih =>
    obtain ⟨zA, hzA, hAmem⟩ := hL A (by simp)
    obtain ⟨zL, hzL, hLmem⟩ := ih (fun B hB => hL B (List.mem_cons_of_mem _ hB))
    refine ⟨min zA zL, lt_min hzA hzL, ?_⟩
    intro B hB q hq1 hq2
    rcases List.mem_cons.mp hB with rfl | hB'
    · exact hAmem q (lt_of_lt_of_le hq1 (min_le_left _ _)) hq2
    · exact hLmem B hB' q (lt_of_lt_of_le hq1 (min_le_right _ _)) hq2

/-! ## Consistency of the limit sets -/

/--
Every finite list drawn from `limitSetBelow m r` is contained in a **single** `m q`.

This is the content that makes the limit set consistent: directedness supplies one threshold
`z < r`, and the density of `ℚ` in `ℝ` (`exists_rat_btwn`) supplies a rational strictly between
`z` and `r`.
-/
theorem limitSetBelow_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetBelow m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  obtain ⟨z, hz, hzL⟩ := limitSetBelow_mono_directed m r L hL
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
  exact ⟨q, fun A hA => hzL A hA q hq1 hq2⟩

/-- Dual of `limitSetBelow_finite_subset_mem` for the past side. -/
theorem limitSetAbove_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitSetAbove m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  obtain ⟨z, hz, hzL⟩ := limitSetAbove_mono_directed m r L hL
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
  exact ⟨q, fun A hA => hzL A hA q hq2 hq1⟩

/--
**The limit set from below is consistent.**

`SetConsistent` (`Core/MaximalConsistent.lean`) is a property of finite subsets, and every
finite subset of `limitSetBelow m r` sits inside a single `m q`, which is consistent by
hypothesis.
-/
theorem limitSetBelow_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetBelow m r) := by
  intro L hL
  obtain ⟨q, hq⟩ := limitSetBelow_finite_subset_mem m r L hL
  exact (hm q).1 L hq

/-- **The limit set from above is consistent.** Dual of `limitSetBelow_consistent`. -/
theorem limitSetAbove_consistent {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetConsistent (fc := fc) (limitSetAbove m r) := by
  intro L hL
  obtain ⟨q, hq⟩ := limitSetAbove_finite_subset_mem m r L hL
  exact (hm q).1 L hq

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
  refine ⟨(q : ℝ) + 1, by linarith, ?_⟩
  intro p _ hp2
  exact hG q p A (by exact_mod_cast hp2) hA

/-! ## Maximality by arbitrary extension

The bare `set_lindenbaum` extension of the limit set. It is maximal, but the choice is
arbitrary: nothing relates a member of `limitMCSLindenbaum` back to the rational family beyond
the members already in `limitSetBelow m r`. Recorded for comparison with the ultrafilter limit
below, which is the extension consumers should use.
-/

/--
An arbitrary maximal consistent extension of `limitSetBelow m r`, obtained from
`set_lindenbaum` and the consistency of the limit set.
-/
noncomputable def limitMCSLindenbaum {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) : Set Formula :=
  (set_lindenbaum (fc := fc) (limitSetBelow m r) (limitSetBelow_consistent m hm r)).choose

theorem limitSetBelow_subset_limitMCSLindenbaum {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    limitSetBelow m r ⊆ limitMCSLindenbaum m hm r :=
  (set_lindenbaum (fc := fc) (limitSetBelow m r) (limitSetBelow_consistent m hm r)).choose_spec.1

theorem limitMCSLindenbaum_is_mcs {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetMaximalConsistent (fc := fc) (limitMCSLindenbaum m hm r) :=
  (set_lindenbaum (fc := fc) (limitSetBelow m r) (limitSetBelow_consistent m hm r)).choose_spec.2

/-! ## Maximality by ultrafilter limit

The extension consumers should use. Its members are exactly the formulas whose membership set
`{q | A ∈ m q}` is "large" for a fixed ultrafilter refining the left-neighbourhood filter of
`r`, so maximality is immediate from the ultrafilter dichotomy while every member remains
realised at rationals arbitrarily close below `r`.
-/

/--
The **left-neighbourhood filter** of a real point `r` on the rationals: a set of rationals is
large when it contains every rational in some interval `(z, r)` with `z < r`.

The filter axioms are the same directedness argument as `limitSetBelow_mono_directed`, taking
the maximum of two thresholds for intersections.
-/
def limitFilterBelow (r : ℝ) : Filter Rat where
  sets := {S | ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → q ∈ S}
  univ_sets := ⟨r - 1, by linarith, fun _ _ _ => Set.mem_univ _⟩
  sets_of_superset := by
    rintro S T ⟨z, hz, hS⟩ hST
    exact ⟨z, hz, fun q h1 h2 => hST (hS q h1 h2)⟩
  inter_sets := by
    rintro S T ⟨zS, hzS, hSm⟩ ⟨zT, hzT, hTm⟩
    exact ⟨max zS zT, max_lt hzS hzT, fun q h1 h2 =>
      ⟨hSm q (lt_of_le_of_lt (le_max_left _ _) h1) h2,
        hTm q (lt_of_le_of_lt (le_max_right _ _) h1) h2⟩⟩

/-- Membership in `limitFilterBelow` unfolded. -/
theorem mem_limitFilterBelow {r : ℝ} {S : Set Rat} :
    S ∈ limitFilterBelow r ↔ ∃ z : ℝ, z < r ∧ ∀ q : Rat, z < (q : ℝ) → (q : ℝ) < r → q ∈ S :=
  Iff.rfl

/--
The left-neighbourhood filter is proper: every interval `(z, r)` with `z < r` contains a
rational, by `exists_rat_btwn`.
-/
instance limitFilterBelow_neBot (r : ℝ) : (limitFilterBelow r).NeBot := by
  rw [Filter.neBot_iff, Ne, ← Filter.empty_mem_iff_bot]
  rintro ⟨z, hz, hmem⟩
  obtain ⟨q, hq1, hq2⟩ := exists_rat_btwn hz
  exact hmem q hq1 hq2

/-- A fixed ultrafilter refining the left-neighbourhood filter of `r`. -/
noncomputable def limitUltrafilterBelow (r : ℝ) : Ultrafilter Rat :=
  Ultrafilter.of (limitFilterBelow r)

theorem limitFilterBelow_le (r : ℝ) {S : Set Rat} (hS : S ∈ limitFilterBelow r) :
    S ∈ (limitUltrafilterBelow r : Filter Rat) :=
  Ultrafilter.of_le (limitFilterBelow r) hS

/--
The **ultrafilter limit** of the rational family `m` at the real point `r`: the formulas whose
membership set is large for `limitUltrafilterBelow r`.
-/
def limitMCSBelow (m : Rat → Set Formula) (r : ℝ) : Set Formula :=
  {A | {q : Rat | A ∈ m q} ∈ (limitUltrafilterBelow r : Filter Rat)}

theorem mem_limitMCSBelow {m : Rat → Set Formula} {r : ℝ} {A : Formula} :
    A ∈ limitMCSBelow m r ↔ {q : Rat | A ∈ m q} ∈ (limitUltrafilterBelow r : Filter Rat) :=
  Iff.rfl

/--
The ultrafilter limit **extends** the limit set: an "eventually true approaching `r` from
below" formula has a membership set that is already large for the left-neighbourhood filter.
-/
theorem limitSetBelow_subset_limitMCSBelow (m : Rat → Set Formula) (r : ℝ) :
    limitSetBelow m r ⊆ limitMCSBelow m r := by
  rintro A ⟨z, hz, hA⟩
  exact limitFilterBelow_le r ⟨z, hz, fun q h1 h2 => hA q h1 h2⟩

/--
**The descent handle.** Every member of the ultrafilter limit at `r` is realised at rationals
arbitrarily close below `r`.

This is what an arbitrary Lindenbaum extension cannot provide, and it is what lets a membership
at a real point be traced back to the rational family. The proof is the ultrafilter's
properness: the membership set and the interval `(z, r)` are both large, so they meet.
-/
theorem limitMCSBelow_cofinal_below (m : Rat → Set Formula) (r : ℝ) {A : Formula}
    (hA : A ∈ limitMCSBelow m r) (z : ℝ) (hz : z < r) :
    ∃ q : Rat, z < (q : ℝ) ∧ (q : ℝ) < r ∧ A ∈ m q := by
  have hbasis : {q : Rat | z < (q : ℝ) ∧ (q : ℝ) < r} ∈ (limitUltrafilterBelow r : Filter Rat) :=
    limitFilterBelow_le r ⟨z, hz, fun q h1 h2 => ⟨h1, h2⟩⟩
  obtain ⟨q, hq⟩ := Filter.nonempty_of_mem (Filter.inter_mem hA hbasis)
  exact ⟨q, hq.2.1, hq.2.2, hq.1⟩

/--
Every finite list drawn from the ultrafilter limit is contained in a single `m q`.

The set of rationals carrying the whole list is a finite intersection of large sets, hence
large, hence nonempty.
-/
theorem limitMCSBelow_finite_subset_mem (m : Rat → Set Formula) (r : ℝ) (L : List Formula)
    (hL : ∀ A ∈ L, A ∈ limitMCSBelow m r) :
    ∃ q : Rat, ∀ A ∈ L, A ∈ m q := by
  have key : ∀ L : List Formula, (∀ A ∈ L, A ∈ limitMCSBelow m r) →
      {q : Rat | ∀ A ∈ L, A ∈ m q} ∈ (limitUltrafilterBelow r : Filter Rat) := by
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
      have hA : {q : Rat | A ∈ m q} ∈ (limitUltrafilterBelow r : Filter Rat) := hL' A (by simp)
      have hrest := ih (fun B hB => hL' B (List.mem_cons_of_mem _ hB))
      refine Filter.mem_of_superset (Filter.inter_mem hA hrest) ?_
      rintro q ⟨hq1, hq2⟩ B hB
      rcases List.mem_cons.mp hB with rfl | hB'
      · exact hq1
      · exact hq2 B hB'
  obtain ⟨q, hq⟩ := Filter.nonempty_of_mem (key L hL)
  exact ⟨q, hq⟩

/--
**The ultrafilter limit is maximal consistent.**

Consistency is the finite-subset argument above. Negation-completeness is the ultrafilter
dichotomy: if `{q | A ∈ m q}` is not large then its complement is, and each `m q` in the
complement carries `A.neg` by negation-completeness of `m q`.
-/
theorem limitMCSBelow_is_mcs {fc : FrameClass} (m : Rat → Set Formula)
    (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q)) (r : ℝ) :
    SetMaximalConsistent (fc := fc) (limitMCSBelow m r) := by
  have hcons : SetConsistent (fc := fc) (limitMCSBelow m r) := by
    intro L hL
    obtain ⟨q, hq⟩ := limitMCSBelow_finite_subset_mem m r L hL
    exact (hm q).1 L hq
  refine ⟨hcons, ?_⟩
  intro φ hφ hins
  have hcompl : {q : Rat | φ ∈ m q}ᶜ ∈ (limitUltrafilterBelow r : Filter Rat) :=
    (limitUltrafilterBelow r).compl_mem_iff_notMem.2 hφ
  have hneg : Formula.neg φ ∈ limitMCSBelow m r := by
    refine Filter.mem_of_superset hcompl ?_
    intro q hq
    exact ((hm q).negation_complete φ).resolve_left hq
  exact set_consistent_not_both hins φ (Set.mem_insert _ _) (Set.mem_insert_of_mem _ hneg)

/-! ## Theorems of the frame class are true in the bundle flow model -/

open FormalSystem.Metalogic.Algebraic
open FormalSystem.Semantics

/--
**Every theorem of `fc` inside the root's subformula closure is true at every point of the
bundle flow model.**

The one-line composition of `theorem_in_mcs` (`Core/MaximalConsistent.lean`) with the forward
direction of `bundleFlow_truth_lemma` (`Algebraic/FlowFrame.lean`). This is how a frame-class
theorem — Prior-U, Prior-S or Sep, for instance — gets from membership in every maximal
consistent set to truth in the model.

The *restricted* truth lemma is used deliberately: it demands only root-restricted Until/Since
coherence, which the back-and-forth chronicle supplies. The price is the `h_sub` hypothesis:
the theorem must lie in `subformulaClosure root`. Note `D` is `Type` (not `Type*`), matching
the flow-frame carrier.
-/
theorem fc_theorem_true_in_bundle_flow_model {fc : FrameClass} {D : Type}
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (B : BFMCS (fc := fc) D) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (h_deriv : DerivationTree fc [] φ)
    (fam : FMCS (fc := fc) D) (hfam : fam ∈ B.families) (w₀ t : D) :
    TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ :=
  (bundleFlow_truth_lemma B root h_rtc h_buc h_fuc φ h_sub ⟨fam, hfam⟩ w₀ t).mp
    (theorem_in_mcs (fam.is_mcs (w₀ + t)) h_deriv)

end FormalSystem.Metalogic.Bundle
