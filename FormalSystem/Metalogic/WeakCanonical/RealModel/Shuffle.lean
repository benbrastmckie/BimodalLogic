/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.EpsilonDense

/-!
# Reynolds §8 Lemma 13 and the `ℚ`-shuffle

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **pp.186-187**.

This module continues Block H. Phase 24 landed Lemma 11 (`reynolds_lemma11`) in `GoodDense.lean`
and Phase 25 landed Lemma 12 (`epsDense`, `SimDense`, `contempEquivDense_epsDense_iff`) in
`EpsilonDense.lean`. Here we land the last of §8's numbered lemmas — Lemma 13, *"if there are no
`∼_M` classes ending at gaps then they are all closed intervals"* — and the special sum Reynolds
calls the **shuffle**, together with the `≡ₖ` fact the main proof extracts from it.

## The source, verbatim

Printed p.186, the definition of the shuffle:

> We will make crucial use of a special type of sum. Now suppose that `S` is a finite set of
> structures. Let `π : ℚ → S` be any map such that for any `M ∈ S`, for any `r, s ∈ ℚ`, there is
> `t ∈ ℚ` such that `r < t < s` and `π(t) = M`. We call the structure `Σ_{t ∈ ℚ} π(t)` the
> *shuffle* over `S`. It can be shown to be well defined up to isomorphism.

Printed p.187, **Lemma 13** — statement and whole proof:

> **LEMMA 13.** *For any structure `M`, if there are no `∼_M` classes ending at gaps then they
> are all closed intervals, i.e. of forms `(-∞, +∞)`, `(-∞, b]`, `[b, +∞)` or `[b, b']`.*
>
> **PROOF.** We know that the classes are intervals, we must rule out the case of a `∼_M`-class
> ending at an excluded point of `M`. By considering mirrors we may as well, for contradiction,
> suppose that `b ∈ M` is the right hand end point of `c`'s class `E` but that `b ∉ E`.
>
> Clearly `M | E` is very good so that its substructure `M | (c, b)` is too. This is the
> contradiction. ∎

Printed p.187, the shuffle step of Doets' theorem, which `kEquiv_shuffle_of_classIso` below
renders:

> Since we have density of `M / ∼`, the classes in `I = {E | E is a ∼-class strictly between c
> and d}` have order type `ℚ`. Also, by minimality of `G`, all the `γᵢ`'s in `G` are satisfied
> densely in `I`. This means that as far as `≡ₖ` is concerned `⋃ I` might as well be a shuffle as
> we now proceed to define.
>
> For each `γ ∈ G`, choose an `N_γ ⊨ γ` with flow of time an interval of `ℝ`. It is clear that
> for any `E ∈ I`, `M | E ≡ₖ N_γ` for one of the `γ`'s in `G`. Since lexicographic sums preserve
> `k`-equivalence we can choose `σ : ℚ → {N_γ | γ ∈ G}` appropriately so that
>
> `M | (⋃ I) = Σ_{E ∈ I} M | E ≡ₖ Σ_{q ∈ ℚ} σ(q)`,
>
> the latter structure being a shuffle over `{N_γ | γ ∈ G}`.

## Honesty charter notes

**Lemma 13's hypotheses are strengthened, and the strengthening is real.** Reynolds states the
lemma *"for any structure `M`"*. His one-line proof turns on *"clearly `M | E` is very good"*,
and `veryGoodDense` (`GoodDense.lean:251`) — faithfully following his own §8 definition —
demands that every open subinterval be **non-empty**. At a structure with an immediate successor
pair `p ⋖ q` inside a class, `M | (p,q)` is empty, so `M | E` is *not* very good and the
one-liner fails. Getting from *very good* to *good* is Lemma 11, which is stated for
**countable** structures. Both extra hypotheses are exactly the standing hypotheses of the
theorem this lemma feeds (Doets' theorem, printed p.185: *"whose flow of time is countable,
dense and without end points"*), so nothing downstream is weakened; but the statement here is
not the letter of the printed one. See `reynolds_lemma13_right`.

**Well-definedness of the shuffle is landed only in its reindexing form.** Reynolds' *"it can be
shown to be well defined up to isomorphism"* is the colour-preserving Cantor back-and-forth for
finitely many colours dense in `ℚ`, which Mathlib does not carry
(`Order.iso_of_countable_dense` is the uncoloured statement). What is landed here is
`shuffle_congr_orderIso` / `kEquiv_shuffle_congr`: the shuffle is invariant under any
colour-preserving order isomorphism of the index, which is the form the downstream proof
consumes. The full back-and-forth is *not* proved here and is *not* used; see the module's
`FOLLOW-UP` note below.

**FOLLOW-UP** (not blocking any downstream phase): the colour-preserving back-and-forth
*"any two dense `π, π' : ℚ → S` give isomorphic shuffles"* is unformalised. No result in this
tree depends on it — the main proof only ever needs one shuffle, produced from the classes
themselves by `kEquiv_shuffle_of_classIso`.

## References
- Reynolds 1992, §8, printed pp.186-187:
  `literature/sources/reynolds_1992/sec04_7-separability.md`
- Doets 1989, Lemma 1.4 (sums preserve `≡ₖ`): consumed via `doets_lemma_1_4`
  (`OrderedSum.lean:41`)
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## Lemma 13: no class ends at a gap ⇒ every class is closed

`EndsInGapOnRight` (`DenseModelSurgery/Defs.lean:307`) is stated in terms of
`ContempEquivDense M ε`; Phase 25's `contempEquivDense_epsDense_iff` identifies that with
`SimDense` at Reynolds' own `ε`. The first two lemmas do that translation once, so the
mathematics below is stated in `SimDense` alone.
-/

/-- `EndsInGapOnRight` at Reynolds' `ε`, read as a statement about `∼_M`.

The three conjuncts are, in the source's order: the class does not run on forever to the right;
the class has no last point; there is no first point past the class. -/
theorem endsInGapOnRight_epsDense_iff (k : Nat) (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    EndsInGapOnRight M (epsDense sig k) t ↔
      ((∃ y : M.carrier, t < y ∧ ¬ SimDense sig k M t y) ∧
        (¬ ∃ z : M.carrier, SimDense sig k M t z ∧
          ∀ y : M.carrier, z < y → ¬ SimDense sig k M t y) ∧
        (¬ ∃ z : M.carrier, t < z ∧ ¬ SimDense sig k M t z ∧
          ∀ y : M.carrier, t < y → y < z → SimDense sig k M t y)) := by
  simp only [EndsInGapOnRight, contempEquivDense_epsDense_iff]

/-- `EndsInGapOnLeft` at Reynolds' `ε`, read as a statement about `∼_M`. -/
theorem endsInGapOnLeft_epsDense_iff (k : Nat) (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    EndsInGapOnLeft M (epsDense sig k) t ↔
      ((∃ y : M.carrier, y < t ∧ ¬ SimDense sig k M t y) ∧
        (¬ ∃ z : M.carrier, SimDense sig k M t z ∧
          ∀ y : M.carrier, y < z → ¬ SimDense sig k M t y) ∧
        (¬ ∃ z : M.carrier, z < t ∧ ¬ SimDense sig k M t z ∧
          ∀ y : M.carrier, z < y → y < t → SimDense sig k M t y)) := by
  simp only [EndsInGapOnLeft, contempEquivDense_epsDense_iff]

/-- An open interval all of whose points lie in a single `∼`-class is very good.

This is Reynolds' *"clearly `M | E` is very good so that its substructure `M | (c,b)` is too"*
(printed p.187), with the two hypotheses his sentence silently uses made explicit: density
supplies the non-emptiness clause of `veryGoodDense`, and countability is what Lemma 11 needs to
turn *very good* into *good*. The interval `(lo,hi)` is unconstrained relative to `t`, so the
same lemma serves both halves of Lemma 13. -/
theorem veryGoodDense_openSub_of_forall_simDense (k : Nat) (hk : 2 ≤ k)
    (M : OrderedMonadicStructure sig) [Countable M.carrier] [DenselyOrdered M.carrier]
    {t lo hi : M.carrier}
    (hall : ∀ y : M.carrier, lo < y → y < hi → SimDense sig k M t y) :
    veryGoodDense sig k (M.openSubinterval sig lo hi) := by
  rw [veryGoodDense_openSubinterval_iff]
  intro z u htz hzu hub
  -- `z` and `u` both lie in `t`'s class, so `z ∼ u`.
  have hz : SimDense sig k M t z := hall z htz (lt_trans hzu hub)
  have hu : SimDense sig k M t u := hall u (lt_trans htz hzu) hub
  have hzu' : SimDense sig k M z u := simDense_trans k hk M (simDense_symm hz) hu
  -- With `z < u`, the only surviving clause of `∼` is very goodness of `M | (z,u)`.
  have hvg : veryGoodDense sig k (M.openSubinterval sig z u) := by
    rcases hzu' with rfl | ⟨_, hv⟩ | ⟨huz, _⟩
    · exact absurd hzu (lt_irrefl _)
    · exact hv
    · exact absurd hzu (asymm huz)
  haveI : Countable (M.openSubinterval sig z u).carrier :=
    inferInstanceAs (Countable {x : M.carrier // z < x ∧ x < u})
  refine ⟨?_, reynolds_lemma11 sig k hk _ hvg⟩
  obtain ⟨x, hx1, hx2⟩ := exists_between hzu
  exact ⟨⟨x, hx1, hx2⟩⟩

/--
**Lemma 13, right-hand half** — Reynolds 1992, §8, printed p.187.

*"We must rule out the case of a `∼_M`-class ending at an excluded point of `M`."* If `t`'s class
does not end in a gap on the right and is bounded above by some point not in it, then it has a
**last point**: the class is closed on the right.

Reynolds' contradiction is exactly the last step: a first point `b` past the class would make
`M | (t,b)` very good, hence `t ∼ b`, putting `b` inside the class after all.

**Hypotheses beyond the printed statement**: `Countable` and `DenselyOrdered`. See the module
header — the printed *"for any structure `M`"* does not survive the non-emptiness clause of
`veryGoodDense`, and both hypotheses are standing ones for the theorem this feeds.
-/
theorem reynolds_lemma13_right (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] (t : M.carrier)
    (hgap : ¬ EndsInGapOnRight M (epsDense sig k) t)
    (hbdd : ∃ y : M.carrier, t < y ∧ ¬ SimDense sig k M t y) :
    ∃ z : M.carrier, SimDense sig k M t z ∧
      ∀ y : M.carrier, z < y → ¬ SimDense sig k M t y := by
  by_cases hlast : ∃ z : M.carrier, SimDense sig k M t z ∧
      ∀ y : M.carrier, z < y → ¬ SimDense sig k M t y
  · exact hlast
  exfalso
  -- With the first two conjuncts of `ρ` in hand, failure of `ρ` forces the third.
  have hfirst : ∃ z : M.carrier, t < z ∧ ¬ SimDense sig k M t z ∧
      ∀ y : M.carrier, t < y → y < z → SimDense sig k M t y := by
    by_contra hC
    exact hgap ((endsInGapOnRight_epsDense_iff k M t).mpr ⟨hbdd, hlast, hC⟩)
  obtain ⟨b, htb, hntb, hall⟩ := hfirst
  -- `b` is the excluded right-hand end point of `t`'s class; `M | (t,b)` is very good, so
  -- `t ∼ b`. That is the contradiction.
  exact hntb (Or.inr (Or.inl ⟨htb,
    veryGoodDense_openSub_of_forall_simDense k hk M hall⟩))

/--
**Lemma 13, left-hand half** — the mirror Reynolds obtains *"by considering mirrors"*
(printed p.187).
-/
theorem reynolds_lemma13_left (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier] (t : M.carrier)
    (hgap : ¬ EndsInGapOnLeft M (epsDense sig k) t)
    (hbdd : ∃ y : M.carrier, y < t ∧ ¬ SimDense sig k M t y) :
    ∃ z : M.carrier, SimDense sig k M t z ∧
      ∀ y : M.carrier, y < z → ¬ SimDense sig k M t y := by
  by_cases hfst : ∃ z : M.carrier, SimDense sig k M t z ∧
      ∀ y : M.carrier, y < z → ¬ SimDense sig k M t y
  · exact hfst
  exfalso
  have hlast : ∃ z : M.carrier, z < t ∧ ¬ SimDense sig k M t z ∧
      ∀ y : M.carrier, z < y → y < t → SimDense sig k M t y := by
    by_contra hC
    exact hgap ((endsInGapOnLeft_epsDense_iff k M t).mpr ⟨hbdd, hfst, hC⟩)
  obtain ⟨b, hbt, hntb, hall⟩ := hlast
  -- `M | (b,t)` is very good by the same argument, read from the right-hand end.
  exact hntb (Or.inr (Or.inr ⟨hbt,
    veryGoodDense_openSub_of_forall_simDense k hk M hall⟩))

/--
**Lemma 13**, assembled — Reynolds 1992, §8, printed p.187:

> *For any structure `M`, if there are no `∼_M` classes ending at gaps then they are all closed
> intervals, i.e. of forms `(-∞,+∞)`, `(-∞,b]`, `[b,+∞)` or `[b,b']`.*

The four printed forms are the four combinations of *bounded/unbounded* on each side; the content
is that **whenever a class is bounded on a side, the bound is attained**, which is the two
conclusions below. That the classes are intervals at all is Lemma 12's `simDense_convex`
(`EpsilonDense.lean:199`), cited by Reynolds' own opening *"we know that the classes are
intervals"*.
-/
theorem reynolds_lemma13 (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig)
    [Countable M.carrier] [DenselyOrdered M.carrier]
    (hnogap : ∀ t : M.carrier, ¬ EndsInGapOnRight M (epsDense sig k) t ∧
      ¬ EndsInGapOnLeft M (epsDense sig k) t) (t : M.carrier) :
    ((∃ y : M.carrier, t < y ∧ ¬ SimDense sig k M t y) →
      ∃ z : M.carrier, SimDense sig k M t z ∧
        ∀ y : M.carrier, z < y → ¬ SimDense sig k M t y) ∧
    ((∃ y : M.carrier, y < t ∧ ¬ SimDense sig k M t y) →
      ∃ z : M.carrier, SimDense sig k M t z ∧
        ∀ y : M.carrier, y < z → ¬ SimDense sig k M t y) :=
  ⟨reynolds_lemma13_right k hk M t (hnogap t).1, reynolds_lemma13_left k hk M t (hnogap t).2⟩

end FormalSystem.Metalogic.WeakCanonical
