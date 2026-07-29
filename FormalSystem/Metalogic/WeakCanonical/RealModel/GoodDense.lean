/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Mathlib.Order.Interval.Set.IsoIoo
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Reynolds §8 Lemma 11: countable + very good ⇒ good, at `ℝ`-intervals

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **pp.185-186**.

This module opens Block H, the `ℝ`-side of Doets' theorem. It lands the two `ℝ`-interval
notions Reynolds fixes in §8's preliminaries — `goodDense` and `veryGoodDense` — and the first
result stated with them, Lemma 11.

## The source, verbatim

Printed p.185, the two definitions from §8's preliminaries:

> First some preliminaries. Fix `k ≥ 2`.
>
> Here a *structure* will mean a linear temporal structure in our finite language.
>
> If `M` and `N` are structures we write `M ≡_k N` if and only if `M` and `N` agree on the truth
> of monadic sentences of quantifier depth at most `k`. Note that since `k ≥ 2`, if `M ≡_k N`
> then `M` and `N` either both have a right (respectively left) hand end point or both do not
> have a right (resp. left) hand end point.
>
> Say that `M` is *good* if and only if there is some `N ≡_k M` such that the flow of time of `N`
> is an interval of the reals.
>
> Say that `M` is *very good* if and only if, for all `t < u` in `M`, the substructure `M | (t,u)`
> is non-empty and good.

Printed pp.185-186, **Lemma 11** — statement and whole proof:

> **LEMMA 11** ([8] lemma 6.4) *If `N` is countable and very good then it is good.*
>
> **PROOF.** All one point structures are good and no bigger but finite structures are very good
> so suppose that `N` has countably infinite domain. First the case when `N` has no end points.
>
> Choose `a_i ∈ N` for each integer `i` such that `i < j` implies `a_i < a_j` and for all
> `t ∈ N`, there is `i,j` such that `a_i < t < a_j`. Since `N` is very good, `N | (a_i, a_{i+1})`
> is good. Take `R_i ≡_k N | (a_i, a_{i+1})` with an open interval of `R` as a flow.
>
> Because `≡_k` is preserved under lexicographic sums,
>
> `N ≡_k Σ_{i∈Z}(N | {a_i} + R_i)`
>
> and this latter has flow isomorphic to `R`.
>
> Now if `N` has one or two end points, then, by the very goodness of `N`, its interior does not
> have end points so we can use the above result and then use the lexicographic sum result to add
> appropriate singleton structures to the end(s). ∎

Both blocks above were read off the 200 dpi page images
(`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF pages 21 and 22) and then
compared against the pre-segmented corpus chunk.

## Corpus and page-measurement notes

**Page reference, corrected.** Plan v10's Phase 24 cites *"printed p.186"* for Lemma 11 and for
the two definitions. Measured off the 200 dpi images: §8 *Doets' Theorem* opens on printed
**p.184**; the preliminaries fixing `k ≥ 2`, `good` and `very good` are on **p.185**; Lemma 11's
statement is the last display of **p.185** and its proof **spans pp.185-186**, the first two
sentences and the choice of the `a_i` sitting on p.185 and the lexicographic-sum display, the
`ℝ`-isomorphism claim and the endpoint cases on p.186. So the citation for this module is
`pp.185-186`, not `p.186`.

The offset measured for §6 and re-measured for §7 (`printed page = PDF 1-based page + 164`)
**does** carry over to §8: PDF page 21 is printed p.185 and PDF page 22 is printed p.186, read
off the running heads. The plan's *content* attribution again did not, which is why it was
re-measured rather than assumed.

**Corpus reliability.** The §8 chunk is the tail of `sec04_7-separability.md` (the segmenter put
the `## 8 Doets' Theorem` heading inside the §7 file). It was compared sentence-by-sentence
against the p.185 and p.186 images across the whole of §8's preliminaries and Lemma 11,
**including the one displayed formula** (`N ≡_k Σ_{i∈Z}(N | {a_i} + R_i)`), and is **clean** —
no defect of the kind §6's displays carried. **No source defect is claimed or repaired by this
module.**

## Proof step to declaration map

| Reynolds' step (printed pp.185-186) | Declaration |
|---|---|
| *"the flow of time of `N` is an interval of the reals"* | `RIntervalStructure`, `RIntervalStructure.toOrdered` |
| *"`M` is good"* | `goodDense` |
| *"`M` is very good"* | `veryGoodDense` |
| *"since `k ≥ 2` … both have a right (resp. left) hand end point"* | `noMaxOrder_of_kEquiv`, `noMinOrder_of_kEquiv` |
| *"All one point structures are good"* | `goodDense_of_subsingleton` |
| *"no bigger but finite structures are very good"* | `not_veryGoodDense_of_finite_two_lt` |
| *"suppose that `N` has countably infinite domain"* | the `[Countable]` hypothesis of `reynolds_lemma11` |
| *"First the case when `N` has no end points"* | `reynolds_lemma11_no_endpoints` |
| *"Choose `a_i ∈ N` … `a_i < t < a_j`"* | `veryGoodSpine`, `veryGoodSpine_strictMono`, `veryGoodSpine_cofinal` |
| *"Since `N` is very good, `N \| (a_i,a_{i+1})` is good"* | `veryGoodDense`, applied at `spine i < spine (i+1)` |
| *"Take `R_i ≡_k N \| (a_i,a_{i+1})` with an open interval of `R` as a flow"* | `exists_iooUnit_witness` |
| *"Because `≡_k` is preserved under lexicographic sums"* | `doets_lemma_1_4` (`OrderedSum.lean:41`), applied twice |
| *"`N ≡_k Σ_{i∈Z}(N \| {a_i} + R_i)`"* | `kEquiv_blockSum` |
| *"and this latter has flow isomorphic to `R`"* | `blockSumWitness_iso_real` |
| *"Now if `N` has one or two end points … add appropriate singleton structures"* | `reynolds_lemma11` (the four endpoint cases) |

## ADAPTED-FROM

`FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` is the `ℤ` analogue of
this module: it lands `ZIntervalStructure` (`:35`), `good` (`:78`) and `VeryGood` (`:86`) for
Reynolds' *discrete* development (Lemma 14, printed p.190). That file is **read, not edited**,
by this module.

What changed, and why it is not cosmetic:

* `ZIntervalStructure` carries `lo hi : Option ℤ` — every bounded interval of `ℤ` is closed, so
  two `Option` endpoints determine it. An interval of `ℝ` is not determined by its endpoints:
  `(0,1)`, `[0,1)` and `[0,1]` share theirs. `RIntervalStructure` therefore carries the carrier
  **as a set** together with `Set.OrdConnected`, which is exactly *"is an interval"* for `ℝ`.
* `VeryGood` (`:86`) quantifies over **closed** subintervals `a ≤ b`; Reynolds' dense form
  quantifies over **open** ones at strict `t < u`, and adds the *non-emptiness* clause the
  discrete form has no need of. `veryGoodDense` follows the source.
* The open/closed choice is what makes the lemma true. `Σ_{i∈ℤ}(N|{a_i} + R_i)` has flow
  isomorphic to `ℝ` because each block `{a_i} + R_i` is a point followed by an **open** real
  interval, hence a half-open `[0,1)`; had `R_i` been closed the sum would have two consecutive
  points at every join and would not be dense, let alone `ℝ`.
* `good`'s witness is `KEquiv sig k M (Z.toOrdered sig)` with the `ℤ`-interval on the right;
  `goodDense` keeps that orientation, so the two are stated the same way up.

## What this module does not claim

This module consumes **no** §6 or §7 result: Lemma 11 is proved from the ordered-sum layer, the
subinterval layer and Cantor's theorem alone. It therefore neither discharges nor weakens the
standing §6 conditionality caveat recorded in `DenseModelSurgery/`: `IsContempEquivDense ε`
remains a hypothesis there, `epsTop` remains the only `ε` this tree can exhibit, and there is
still no live non-trivial instance of any §6 result below Lemma 2.

`goodDense` is a statement about `KEquiv` at a fixed depth `k`, as in the source. Nothing here
asserts that a single `ℝ`-flowed structure works for all `k` at once.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open Set

/-! ## `ℝ`-interval structures -/

/--
An `ℝ`-interval structure: a monadic structure whose carrier is an interval of `ℝ`.

Reynolds, printed p.185: *"there is some `N ≡_k M` such that the flow of time of `N` is an
interval of the reals"*. The carrier is the **actual** interval, carried as a set together with
`Set.OrdConnected` — the order-theoretic content of *"is an interval"*, and the formulation that
keeps `(t,u)`, `[t,u)` and `[t,u]` genuinely distinct.

This is the dense analogue of `ZIntervalStructure`; see this module's `ADAPTED-FROM` note for
what changed and why.
-/
structure RIntervalStructure (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    where
  /-- The flow of time: a set of reals. -/
  carrierSet : Set ℝ
  /-- The flow is an interval: it contains `[x,y]` whenever it contains `x` and `y`. -/
  ordConnected : carrierSet.OrdConnected
  /-- Predicate interpretations, given on all of `ℝ` and read off on `carrierSet`. -/
  interp (p : sig.preds) : ℝ → Prop

/-- The interval carrier: the subtype of `ℝ` cut out by `carrierSet`. -/
def RIntervalStructure.intervalCarrier {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (R : RIntervalStructure sig) : Type :=
  {x : ℝ // x ∈ R.carrierSet}

noncomputable instance RIntervalStructure.intervalCarrierLinearOrder {sig : MonadicSignature}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (R : RIntervalStructure sig) : LinearOrder R.intervalCarrier :=
  Subtype.instLinearOrder _

/-- Convert an `ℝ`-interval structure to a monadic structure (carrier = the interval). -/
def RIntervalStructure.toMonadic (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (R : RIntervalStructure sig) :
    MonadicStructure sig where
  carrier := R.intervalCarrier
  interp p x := R.interp p x.val

/-- Convert an `ℝ`-interval structure to an ordered monadic structure, with `ℝ`'s order
    inherited through the subtype. -/
noncomputable def RIntervalStructure.toOrdered (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (R : RIntervalStructure sig) :
    OrderedMonadicStructure sig where
  carrier := R.intervalCarrier
  interp p x := R.interp p x.val
  carrierOrder := inferInstance

/-! ## Open subintervals

Reynolds' §8 works throughout with `M | (t,u)`, the substructure on the **open** interval. The
tree's `OrderedMonadicStructure.subinterval` (`MonadicFO.lean:215`) is the closed `M | [a,b]`,
used by the discrete development; the open form is new here.
-/

/--
The substructure `M | (a,b)` on the open interval between `a` and `b`.

Distinct from `OrderedMonadicStructure.subinterval`, which is the closed `M | [a,b]`.
-/
def OrderedMonadicStructure.openSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a < x ∧ x < b}
  interp p x := M.interp p x.val
  carrierOrder := inferInstance

/-! ## Good and very good, at `ℝ`-intervals -/

/--
`M` is **good** (at depth `k`): it is `k`-equivalent to a structure whose flow of time is an
interval of the reals.

Reynolds, printed p.185: *"Say that `M` is good if and only if there is some `N ≡_k M` such that
the flow of time of `N` is an interval of the reals."*
-/
def goodDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (R : RIntervalStructure sig), KEquiv sig k M (R.toOrdered sig)

/--
`M` is **very good** (at depth `k`): every open subinterval is non-empty and good.

Reynolds, printed p.185: *"Say that `M` is very good if and only if, for all `t < u` in `M`, the
substructure `M | (t,u)` is non-empty and good."*

Note the two differences from the discrete `VeryGood` (`GoodStructures.lean:86`): the interval is
**open** and the quantifier is at **strict** `t < u`, and non-emptiness is part of the
definition. The non-emptiness clause is what forces a very good structure to be densely ordered.
-/
def veryGoodDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  ∀ (t u : M.carrier), t < u →
    Nonempty (M.openSubinterval sig t u).carrier ∧ goodDense sig k (M.openSubinterval sig t u)

/-! ## Elementary transfer -/

/-- `goodDense` transfers along `k`-equivalence. -/
theorem goodDense_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) {M N : OrderedMonadicStructure sig} (h : KEquiv sig k M N)
    (hN : goodDense sig k N) : goodDense sig k M := by
  obtain ⟨R, hR⟩ := hN
  exact ⟨R, h.trans hR⟩

/-- `goodDense` transfers along an order isomorphism preserving predicates. -/
theorem goodDense_of_orderIso (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) {M N : OrderedMonadicStructure sig} (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x))
    (hN : goodDense sig k N) : goodDense sig k M :=
  goodDense_of_kEquiv sig k (k_equiv_of_iso sig k M N f h_pred) hN

/-! ## Which sets of reals are open intervals

Reynolds' *"with an open interval of `R` as a flow"* and *"has flow isomorphic to `R`"* are the
two places §8 leans on the order type of the real line. Both need the same fact: an interval of
`ℝ` with no end points is order-isomorphic to `(0,1)`. That is proved here, once, and consumed
twice.
-/

/-- The affine order isomorphism `(a,b) ≃o (c,d)` between two non-degenerate bounded open
    intervals of `ℝ`. -/
noncomputable def iooIsoIoo {a b c d : ℝ} (hab : a < b) (hcd : c < d) :
    Set.Ioo a b ≃o Set.Ioo c d := by
  have hba : (0 : ℝ) < b - a := sub_pos.mpr hab
  have hdc : (0 : ℝ) < d - c := sub_pos.mpr hcd
  refine StrictMono.orderIsoOfRightInverse
    (fun x => ⟨c + (x.val - a) * ((d - c) / (b - a)), ?_, ?_⟩) ?_
    (fun y => ⟨a + (y.val - c) * ((b - a) / (d - c)), ?_, ?_⟩) ?_
  · have hx : a < x.val := x.property.1
    have : 0 < (x.val - a) * ((d - c) / (b - a)) :=
      mul_pos (sub_pos.mpr hx) (div_pos hdc hba)
    linarith
  · have hx : x.val < b := x.property.2
    have h1 : (x.val - a) * ((d - c) / (b - a)) < (b - a) * ((d - c) / (b - a)) :=
      mul_lt_mul_of_pos_right (by linarith) (div_pos hdc hba)
    have h2 : (b - a) * ((d - c) / (b - a)) = d - c := by field_simp
    linarith [h1, h2 ▸ h1]
  · intro x y hxy
    have hxy' : x.val < y.val := hxy
    have : (x.val - a) * ((d - c) / (b - a)) < (y.val - a) * ((d - c) / (b - a)) :=
      mul_lt_mul_of_pos_right (by linarith) (div_pos hdc hba)
    exact Subtype.mk_lt_mk.mpr (by linarith)
  · have hy : c < y.val := y.property.1
    have : 0 < (y.val - c) * ((b - a) / (d - c)) :=
      mul_pos (sub_pos.mpr hy) (div_pos hba hdc)
    linarith
  · have hy : y.val < d := y.property.2
    have h1 : (y.val - c) * ((b - a) / (d - c)) < (d - c) * ((b - a) / (d - c)) :=
      mul_lt_mul_of_pos_right (by linarith) (div_pos hba hdc)
    have h2 : (d - c) * ((b - a) / (d - c)) = b - a := by field_simp
    linarith [h1, h2 ▸ h1]
  · intro y
    apply Subtype.ext
    show c + ((a + (y.val - c) * ((b - a) / (d - c))) - a) * ((d - c) / (b - a)) = y.val
    have hba' : b - a ≠ 0 := ne_of_gt hba
    have hdc' : d - c ≠ 0 := ne_of_gt hdc
    field_simp
    ring

/-- `(a, ∞) ≃o ℝ`, by `x ↦ log (x - a)`. -/
noncomputable def ioiIsoReal (a : ℝ) : Set.Ioi a ≃o ℝ := by
  refine StrictMono.orderIsoOfRightInverse (fun x => Real.log (x.val - a)) ?_
    (fun y => ⟨a + Real.exp y, ?_⟩) ?_
  · intro x y hxy
    exact Real.log_lt_log (sub_pos.mpr x.property) (by have : x.val < y.val := hxy; linarith)
  · have := Real.exp_pos y
    simp only [Set.mem_Ioi]
    linarith
  · intro y
    show Real.log (a + Real.exp y - a) = y
    rw [show a + Real.exp y - a = Real.exp y by ring, Real.log_exp]

/-- `(-∞, b) ≃o ℝ`, by `x ↦ -log (b - x)`. -/
noncomputable def iioIsoReal (b : ℝ) : Set.Iio b ≃o ℝ := by
  refine StrictMono.orderIsoOfRightInverse (fun x => -Real.log (b - x.val)) ?_
    (fun y => ⟨b - Real.exp (-y), ?_⟩) ?_
  · intro x y hxy
    have hxy' : x.val < y.val := hxy
    have : Real.log (b - y.val) < Real.log (b - x.val) :=
      Real.log_lt_log (sub_pos.mpr y.property) (by linarith)
    simpa using this
  · have := Real.exp_pos (-y)
    simp only [Set.mem_Iio]
    linarith
  · intro y
    show -Real.log (b - (b - Real.exp (-y))) = y
    rw [show b - (b - Real.exp (-y)) = Real.exp (-y) by ring, Real.log_exp, neg_neg]

/-- `ℝ ≃o (0,1)`, from Mathlib's `orderIsoIooNegOneOne` composed with an affine rescaling. -/
noncomputable def realIsoIoo01 : ℝ ≃o Set.Ioo (0 : ℝ) 1 :=
  (orderIsoIooNegOneOne ℝ).trans (iooIsoIoo (by norm_num : (-1 : ℝ) < 1) (by norm_num))

/-- `Set.univ ≃o ℝ`. -/
def univIsoReal : (Set.univ : Set ℝ) ≃o ℝ where
  toFun x := x.val
  invFun y := ⟨y, Set.mem_univ y⟩
  left_inv _ := rfl
  right_inv _ := rfl
  map_rel_iff' := Iff.rfl

/--
An interval of `ℝ` with no end points is order-isomorphic to `(0,1)`.

The four shapes an interval with no end points can take — `(a,b)`, `(a,∞)`, `(-∞,b)` and `ℝ` —
are separated by `BddBelow`/`BddAbove` and identified through `sInf`/`sSup`; each is then carried
to `(0,1)`.

This is the content behind Reynolds' *"with an open interval of `R` as a flow"* (printed p.185).
-/
theorem exists_orderIso_ioo01_of_ordConnected (s : Set ℝ) (hc : s.OrdConnected)
    (hne : s.Nonempty) (hmax : ∀ x ∈ s, ∃ y ∈ s, x < y) (hmin : ∀ x ∈ s, ∃ y ∈ s, y < x) :
    Nonempty (s ≃o Set.Ioo (0 : ℝ) 1) := by
  -- Every point of `s` is strictly inside whichever bounds `s` has.
  have h_inf_lt : ∀ x ∈ s, BddBelow s → sInf s < x := by
    intro x hx hb
    obtain ⟨y, hy, hyx⟩ := hmin x hx
    exact lt_of_le_of_lt (csInf_le hb hy) hyx
  have h_lt_sup : ∀ x ∈ s, BddAbove s → x < sSup s := by
    intro x hx ha
    obtain ⟨y, hy, hxy⟩ := hmax x hx
    exact lt_of_lt_of_le hxy (le_csSup ha hy)
  by_cases hb : BddBelow s <;> by_cases ha : BddAbove s
  · -- Bounded both ways: `s = (sInf s, sSup s)`.
    obtain ⟨p, hp⟩ := hne
    have hlt : sInf s < sSup s := lt_trans (h_inf_lt p hp hb) (h_lt_sup p hp ha)
    have hs : s = Set.Ioo (sInf s) (sSup s) := by
      ext x
      constructor
      · intro hx; exact ⟨h_inf_lt x hx hb, h_lt_sup x hx ha⟩
      · rintro ⟨h1, h2⟩
        obtain ⟨y, hy, hyx⟩ := exists_lt_of_csInf_lt ⟨p, hp⟩ h1
        obtain ⟨z, hz, hxz⟩ := exists_lt_of_lt_csSup ⟨p, hp⟩ h2
        exact hc.out hy hz ⟨le_of_lt hyx, le_of_lt hxz⟩
    exact ⟨(OrderIso.setCongr _ _ hs).trans (iooIsoIoo hlt (by norm_num))⟩
  · -- Bounded below only: `s = (sInf s, ∞)`.
    obtain ⟨p, hp⟩ := hne
    have hs : s = Set.Ioi (sInf s) := by
      ext x
      constructor
      · intro hx; exact h_inf_lt x hx hb
      · intro h1
        obtain ⟨y, hy, hyx⟩ := exists_lt_of_csInf_lt ⟨p, hp⟩ h1
        obtain ⟨z, hz, hxz⟩ := (not_bddAbove_iff.mp ha) x
        exact hc.out hy hz ⟨le_of_lt hyx, le_of_lt hxz⟩
    exact ⟨((OrderIso.setCongr _ _ hs).trans (ioiIsoReal _)).trans realIsoIoo01⟩
  · -- Bounded above only: `s = (-∞, sSup s)`.
    obtain ⟨p, hp⟩ := hne
    have hs : s = Set.Iio (sSup s) := by
      ext x
      constructor
      · intro hx; exact h_lt_sup x hx ha
      · intro h2
        obtain ⟨z, hz, hxz⟩ := exists_lt_of_lt_csSup ⟨p, hp⟩ h2
        obtain ⟨y, hy, hyx⟩ := (not_bddBelow_iff.mp hb) x
        exact hc.out hy hz ⟨le_of_lt hyx, le_of_lt hxz⟩
    exact ⟨((OrderIso.setCongr _ _ hs).trans (iioIsoReal _)).trans realIsoIoo01⟩
  · -- Unbounded both ways: `s = ℝ`.
    have hs : s = Set.univ := by
      ext x
      constructor
      · intro _; trivial
      · intro _
        obtain ⟨y, hy, hyx⟩ := (not_bddBelow_iff.mp hb) x
        obtain ⟨z, hz, hxz⟩ := (not_bddAbove_iff.mp ha) x
        exact hc.out hy hz ⟨le_of_lt hyx, le_of_lt hxz⟩
    exact ⟨((OrderIso.setCongr _ _ hs).trans univIsoReal).trans realIsoIoo01⟩

end FormalSystem.Metalogic.WeakCanonical
