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

/-! ## The blocks `N | {a} + S`

Reynolds' summand, printed p.186: `N | {a_i} + R_i`. The `+` is the two-element lexicographic
sum, so the block is `orderedSum` over `Bool` with the singleton `N | {a}` first.
-/

/-- The two-element family `[M | {a}, S]` whose lexicographic sum is `M | {a} + S`. -/
noncomputable def pointSumFamily (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a : M.carrier) (S : OrderedMonadicStructure sig) : Bool → OrderedMonadicStructure sig :=
  fun c => if c = false then M.subinterval sig a a else S

/-- Reynolds' block `M | {a} + S`: the singleton at `a`, followed by `S`. -/
noncomputable def pointSum (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a : M.carrier) (S : OrderedMonadicStructure sig) : OrderedMonadicStructure sig :=
  orderedSum sig Bool (pointSumFamily sig M a S)

/-- `M | {a} + −` preserves `k`-equivalence: one application of `doets_lemma_1_4` over `Bool`. -/
theorem kEquiv_pointSum (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (M : OrderedMonadicStructure sig) (a : M.carrier)
    {S S' : OrderedMonadicStructure sig} (h : KEquiv sig k S S') :
    KEquiv sig k (pointSum sig M a S) (pointSum sig M a S') :=
  doets_lemma_1_4 sig k Bool _ _ (fun c => by
    simp only [pointSumFamily]
    split
    · rfl
    · exact h)

/-- The substructure `M | [a,b)` on the half-open interval.

    This is the shape of the block `[a_i, a_{i+1})` that `N` decomposes into; it is
    `k`-equivalent to Reynolds' `M | {a} + M | (a,b)` by `kEquiv_halfOpen_pointSum`. -/
def OrderedMonadicStructure.halfOpenSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x < b}
  interp p x := M.interp p x.val
  carrierOrder := inferInstance

/-- `M | [a,b) ≡_k M | {a} + M | (a,b)`: splitting off the left end point of a half-open block. -/
theorem kEquiv_halfOpen_pointSum (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (M : OrderedMonadicStructure sig) (a b : M.carrier)
    (hab : a < b) :
    KEquiv sig k (M.halfOpenSubinterval sig a b)
      (pointSum sig M a (M.openSubinterval sig a b)) := by
  letI fam := pointSumFamily sig M a (M.openSubinterval sig a b)
  letI inst_ord : LinearOrder (orderedSum sig Bool fam).carrier :=
    (orderedSum sig Bool fam).carrierOrder
  let e : (M.halfOpenSubinterval sig a b).carrier ≃ (orderedSum sig Bool fam).carrier := {
    toFun := fun x =>
      if h : x.val ≤ a then orderedSumPt (ms := fam) false ⟨x.val, x.property.1, h⟩
      else orderedSumPt (ms := fam) true ⟨x.val, lt_of_not_ge h, x.property.2⟩
    invFun := fun y => match y with
      | ⟨false, z⟩ => ⟨z.val, z.property.1, lt_of_le_of_lt z.property.2 hab⟩
      | ⟨true, z⟩ => ⟨z.val, le_of_lt z.property.1, z.property.2⟩
    left_inv := by intro x; simp only; split_ifs with h <;> rfl
    right_inv := by
      intro ⟨c, z⟩
      match c with
      | false =>
        have hle : z.val ≤ a := z.property.2
        simp only [dif_pos hle]
        exact Sigma.ext rfl (heq_of_eq (Subtype.ext rfl))
      | true =>
        have hgt : ¬ z.val ≤ a := not_le.mpr z.property.1
        simp only [dif_neg hgt]
        exact Sigma.ext rfl (heq_of_eq (Subtype.ext rfl))
  }
  have hm1 : Monotone e := by
    intro x y (hxy : x.val ≤ y.val)
    simp only [e, Equiv.coe_fn_mk]
    split_ifs with hx hy hy
    · exact Sigma.Lex.le_def.mpr (Or.inr ⟨rfl, hxy⟩)
    · exact Sigma.Lex.le_def.mpr (Or.inl Bool.false_lt_true)
    · exact absurd (le_trans hxy hy) hx
    · exact Sigma.Lex.le_def.mpr (Or.inr ⟨rfl, hxy⟩)
  have hm2 : Monotone e.symm := by
    intro y z hyz
    obtain ⟨cy, ey⟩ := y; obtain ⟨cz, ez⟩ := z
    have hyz' := Sigma.Lex.le_def.mp hyz
    change (e.symm ⟨cy, ey⟩).val ≤ (e.symm ⟨cz, ez⟩).val
    revert hyz'; cases cy <;> cases cz <;> simp only [e, Equiv.coe_fn_symm_mk] <;> intro hyz'
    · rcases hyz' with h | ⟨_, h⟩
      · exact absurd h (lt_irrefl _)
      · exact h
    · exact le_trans ey.property.2 (le_of_lt ez.property.1)
    · rcases hyz' with h | ⟨h, _⟩
      · exact absurd h (by decide)
      · exact absurd h (by decide)
    · rcases hyz' with h | ⟨_, h⟩
      · exact absurd h (lt_irrefl _)
      · exact h
  have h_pred : ∀ (p : sig.preds) (x : (M.halfOpenSubinterval sig a b).carrier),
      (M.halfOpenSubinterval sig a b).interp p x ↔ (orderedSum sig Bool fam).interp p (e x) := by
    intro p x
    have he : e x =
        if h : x.val ≤ a then orderedSumPt (ms := fam) false ⟨x.val, x.property.1, h⟩
        else orderedSumPt (ms := fam) true ⟨x.val, lt_of_not_ge h, x.property.2⟩ := rfl
    rw [he]; split_ifs with h <;>
      simp [fam, pointSumFamily, orderedSumPt, OrderedMonadicStructure.subinterval,
        OrderedMonadicStructure.openSubinterval, OrderedMonadicStructure.halfOpenSubinterval,
        orderedSum]
  exact k_equiv_of_iso sig k _ _ (Equiv.toOrderIso e hm1 hm2) h_pred

/-! ## Density, and end points across `≡_k`

Reynolds' preliminaries, printed p.185: *"Note that since `k ≥ 2`, if `M ≡_k N` then `M` and `N`
either both have a right (respectively left) hand end point or both do not have a right
(resp. left) hand end point."* Both halves are used in Lemma 11, to know that the witness
supplied by goodness of `N | (a_i,a_{i+1})` really does have an **open** interval as its flow.
-/

/-- *"has a right hand end point"*, at quantifier depth 2. -/
def hasMaxSent (sig : MonadicSignature) : MonadicSentence sig :=
  .ex (.all (.not (.lt 1 0)))

/-- *"has a left hand end point"*, at quantifier depth 2. -/
def hasMinSent (sig : MonadicSignature) : MonadicSentence sig :=
  .ex (.all (.not (.lt 0 1)))

/-- *"is non-empty"*, at quantifier depth 1. -/
def nonemptySent (sig : MonadicSignature) : MonadicSentence sig :=
  .ex (.not (.lt 0 0))

/-- A sentence of quantifier depth at most `k` transfers across `k`-equivalence.

    This is `doets_lemma_1_1` packaged at the sentence level, with the `KEquiv`-to-normal-form
    bridge done once instead of at each call site. -/
theorem eval_transfer_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (φ : MonadicSentence sig)
    (hdepth : φ.quantifierDepth ≤ k) {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) :
    eval M Fin.elim0 φ ↔ eval N Fin.elim0 φ := by
  have h_same : ∀ nf : NormalForm sig k 0,
      NfEvalNf M k 0 Fin.elim0 nf ↔ NfEvalNf N k 0 Fin.elim0 nf := by
    intro nf
    have hp := congr_fun h nf
    simp only [kTypeOf, decide_eq_decide] at hp
    exact_mod_cast hp
  exact doets_lemma_1_1 k 0 φ hdepth M N Fin.elim0 Fin.elim0 h_same

theorem eval_hasMaxSent (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (hasMaxSent sig) ↔ ∃ x : M.carrier, ∀ y : M.carrier, ¬ x < y := by
  simp [hasMaxSent, eval]

theorem eval_hasMinSent (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (hasMinSent sig) ↔ ∃ x : M.carrier, ∀ y : M.carrier, ¬ y < x := by
  simp [hasMinSent, eval]

theorem eval_nonemptySent (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    eval M Fin.elim0 (nonemptySent sig) ↔ Nonempty M.carrier := by
  constructor
  · rintro ⟨x, -⟩; exact ⟨x⟩
  · rintro ⟨x⟩; exact ⟨x, lt_irrefl _⟩

/-- Non-emptiness transfers across `k`-equivalence for `k ≥ 1`. -/
theorem nonempty_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 1 ≤ k) {M N : OrderedMonadicStructure sig} (h : KEquiv sig k M N)
    [Nonempty M.carrier] : Nonempty N.carrier := by
  have hdepth : (nonemptySent sig).quantifierDepth ≤ k := by
    simpa [nonemptySent, MonadicFormula.quantifierDepth] using hk
  exact (eval_nonemptySent sig N).mp
    ((eval_transfer_of_kEquiv sig k _ hdepth h).mp ((eval_nonemptySent sig M).mpr ‹_›))

/-- *"no right hand end point"* transfers across `k`-equivalence for `k ≥ 2`. -/
theorem noMaxOrder_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) {M N : OrderedMonadicStructure sig} (h : KEquiv sig k M N)
    [NoMaxOrder M.carrier] : NoMaxOrder N.carrier := by
  have hdepth : (hasMaxSent sig).quantifierDepth ≤ k := by
    simpa [hasMaxSent, MonadicFormula.quantifierDepth] using hk
  refine ⟨fun a => ?_⟩
  by_contra hcon
  push Not at hcon
  have hN : eval N Fin.elim0 (hasMaxSent sig) :=
    (eval_hasMaxSent sig N).mpr ⟨a, fun y => not_lt.mpr (hcon y)⟩
  obtain ⟨x, hx⟩ := (eval_hasMaxSent sig M).mp
    ((eval_transfer_of_kEquiv sig k _ hdepth h).mpr hN)
  obtain ⟨y, hy⟩ := exists_gt x
  exact hx y hy

/-- *"no left hand end point"* transfers across `k`-equivalence for `k ≥ 2`. -/
theorem noMinOrder_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) {M N : OrderedMonadicStructure sig} (h : KEquiv sig k M N)
    [NoMinOrder M.carrier] : NoMinOrder N.carrier := by
  have hdepth : (hasMinSent sig).quantifierDepth ≤ k := by
    simpa [hasMinSent, MonadicFormula.quantifierDepth] using hk
  refine ⟨fun a => ?_⟩
  by_contra hcon
  push Not at hcon
  have hN : eval N Fin.elim0 (hasMinSent sig) :=
    (eval_hasMinSent sig N).mpr ⟨a, fun y => not_lt.mpr (hcon y)⟩
  obtain ⟨x, hx⟩ := (eval_hasMinSent sig M).mp
    ((eval_transfer_of_kEquiv sig k _ hdepth h).mpr hN)
  obtain ⟨y, hy⟩ := exists_lt x
  exact hx y hy

/-- A very good structure is densely ordered: the non-emptiness clause of `veryGoodDense` is
    exactly density. -/
theorem denselyOrdered_of_veryGoodDense (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) {M : OrderedMonadicStructure sig}
    (h : veryGoodDense sig k M) : DenselyOrdered M.carrier := by
  refine ⟨fun a b hab => ?_⟩
  obtain ⟨⟨x, hx⟩⟩ := (h a b hab).1
  exact ⟨x, hx.1, hx.2⟩

/-- An open subinterval of a densely ordered structure has no right hand end point. -/
theorem noMaxOrder_openSubinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    [DenselyOrdered M.carrier] (a b : M.carrier) :
    NoMaxOrder (M.openSubinterval sig a b).carrier := by
  refine ⟨fun x => ?_⟩
  obtain ⟨y, hxy, hyb⟩ := exists_between x.property.2
  exact ⟨⟨y, lt_trans x.property.1 hxy, hyb⟩, hxy⟩

/-- An open subinterval of a densely ordered structure has no left hand end point. -/
theorem noMinOrder_openSubinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    [DenselyOrdered M.carrier] (a b : M.carrier) :
    NoMinOrder (M.openSubinterval sig a b).carrier := by
  refine ⟨fun x => ?_⟩
  obtain ⟨y, hay, hyx⟩ := exists_between x.property.1
  exact ⟨⟨y, hay, lt_trans hyx x.property.2⟩, hyx⟩

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

/-! ## *"with an open interval of `R` as a flow"*

Reynolds, printed p.185. Goodness hands back *some* interval of `ℝ`; because `k ≥ 2` carries end
points across `≡_k`, a good structure with no end points is `k`-equivalent to one whose flow is
an interval with no end points, and such an interval can be moved onto any prescribed `(c,d)`.
-/

/--
A good structure with no end points is `k`-equivalent to a structure whose flow is **any**
prescribed non-degenerate bounded open interval `(c,d)` of `ℝ`.
-/
theorem exists_ioo_witness (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (hk : 2 ≤ k) (M : OrderedMonadicStructure sig) [Nonempty M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier] (hM : goodDense sig k M) {c d : ℝ}
    (hcd : c < d) :
    ∃ R : RIntervalStructure sig, R.carrierSet = Set.Ioo c d ∧ KEquiv sig k M (R.toOrdered sig) := by
  obtain ⟨R₀, hR₀⟩ := hM
  haveI hne : Nonempty {x : ℝ // x ∈ R₀.carrierSet} :=
    nonempty_of_kEquiv sig k (le_trans one_le_two hk) hR₀
  haveI : NoMaxOrder {x : ℝ // x ∈ R₀.carrierSet} := noMaxOrder_of_kEquiv sig k hk hR₀
  haveI : NoMinOrder {x : ℝ // x ∈ R₀.carrierSet} := noMinOrder_of_kEquiv sig k hk hR₀
  obtain ⟨φ⟩ := exists_orderIso_ioo01_of_ordConnected R₀.carrierSet R₀.ordConnected
    (by obtain ⟨x⟩ := hne; exact ⟨x.val, x.property⟩)
    (by
      intro x hx
      obtain ⟨y, hy⟩ := exists_gt (⟨x, hx⟩ : {v : ℝ // v ∈ R₀.carrierSet})
      exact ⟨y.val, y.property, hy⟩)
    (by
      intro x hx
      obtain ⟨y, hy⟩ := exists_lt (⟨x, hx⟩ : {v : ℝ // v ∈ R₀.carrierSet})
      exact ⟨y.val, y.property, hy⟩)
  obtain ⟨ψ⟩ : Nonempty (R₀.carrierSet ≃o Set.Ioo c d) :=
    ⟨φ.trans (iooIsoIoo (by norm_num) hcd)⟩
  refine ⟨{ carrierSet := Set.Ioo c d
            ordConnected := Set.ordConnected_Ioo
            interp := fun p x =>
              if h : x ∈ Set.Ioo c d then R₀.interp p (ψ.symm ⟨x, h⟩).val else False }, rfl, ?_⟩
  refine hR₀.trans (k_equiv_of_iso sig k _ _ ψ ?_)
  intro p x
  show R₀.interp p x.val ↔
    (if h : (ψ x).val ∈ Set.Ioo c d then R₀.interp p (ψ.symm ⟨(ψ x).val, h⟩).val else False)
  rw [dif_pos (ψ x).property]
  show R₀.interp p x.val ↔ R₀.interp p (ψ.symm (ψ x)).val
  exact (iff_of_eq (congrArg (R₀.interp p)
    (congrArg Subtype.val (ψ.symm_apply_apply x)))).symm

/-! ## The `ℤ`-indexed decomposition of `N`

Reynolds, printed pp.185-186: *"Choose `a_i ∈ N` for each integer `i` such that `i < j` implies
`a_i < a_j` and for all `t ∈ N`, there is `i,j` such that `a_i < t < a_j`."* The choice is used
only through the induced block map `t ↦ the i with a_i ≤ t < a_{i+1}`, so that is what the
decomposition lemma takes as its hypothesis.
-/

/--
`N` is `k`-equivalent to the lexicographic sum over `ℤ` of its half-open blocks
`N | [a_i, a_{i+1})`.

The `k`-equivalence is in fact an order isomorphism: every point lies in exactly one block.
-/
theorem kEquiv_sum_halfOpen (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (M : OrderedMonadicStructure sig) (spine : ℤ → M.carrier)
    (hmono : StrictMono spine) (blockOf : M.carrier → ℤ)
    (hlo : ∀ x, spine (blockOf x) ≤ x) (hhi : ∀ x, x < spine (blockOf x + 1)) :
    KEquiv sig k M
      (orderedSum sig ℤ (fun i => M.halfOpenSubinterval sig (spine i) (spine (i + 1)))) := by
  letI fam := fun i : ℤ => M.halfOpenSubinterval sig (spine i) (spine (i + 1))
  -- `f` collapses a block element to the underlying point of `M`.
  have hstrict : StrictMono (fun y : (orderedSum sig ℤ fam).carrier => y.2.val) := by
    rintro ⟨i, y⟩ ⟨j, z⟩ hlt
    rcases Sigma.Lex.lt_def.mp hlt with hij | ⟨hij, hyz⟩
    · have hij' : i < j := hij
      exact lt_of_lt_of_le y.property.2
        (le_trans (hmono.monotone (by omega : i + 1 ≤ j)) z.property.1)
    · have heq : i = j := hij
      subst heq
      exact hyz
  have hright : Function.RightInverse
      (fun x : M.carrier => (⟨blockOf x, ⟨x, hlo x, hhi x⟩⟩ : (orderedSum sig ℤ fam).carrier))
      (fun y : (orderedSum sig ℤ fam).carrier => y.2.val) := fun _ => rfl
  let g : (orderedSum sig ℤ fam).carrier ≃o M.carrier :=
    StrictMono.orderIsoOfRightInverse _ hstrict _ hright
  refine (k_equiv_of_iso sig k (orderedSum sig ℤ fam) M g ?_).symm
  rintro p ⟨i, y⟩
  exact Iff.rfl

/-! ## *"and this latter has flow isomorphic to `R`"*

Reynolds, printed p.186. The sum `Σ_{i∈ℤ}(N | {a_i} + R_i)` is carried onto `ℝ` in two steps:
each block `N | {a_i} + R_i` becomes the half-open real interval `[i, i+1)`, and the sum of those
blocks over `ℤ` becomes the whole line.
-/

/-- The block `M | {a} + R` realized on the half-open real interval `[c,d)`: the point `a` sits
    at the left end point `c`, and `R`'s open interval `(c,d)` follows it. -/
noncomputable def icoBlock (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a : M.carrier) (R : RIntervalStructure sig) (c d : ℝ) :
    RIntervalStructure sig where
  carrierSet := Set.Ico c d
  ordConnected := Set.ordConnected_Ico
  interp p x := if x = c then M.interp p a else R.interp p x

/-- `M | {a} + R ≡_k` the half-open real block, when `R`'s flow is the open interval `(c,d)`. -/
theorem kEquiv_pointSum_icoBlock (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (M : OrderedMonadicStructure sig) (a : M.carrier)
    (R : RIntervalStructure sig) {c d : ℝ} (hcd : c < d) (hR : R.carrierSet = Set.Ioo c d) :
    KEquiv sig k (pointSum sig M a (R.toOrdered sig))
      ((icoBlock sig M a R c d).toOrdered sig) := by
  letI fam := pointSumFamily sig M a (R.toOrdered sig)
  letI inst_ord : LinearOrder (orderedSum sig Bool fam).carrier :=
    (orderedSum sig Bool fam).carrierOrder
  -- Membership in `R.carrierSet` is transported through `hR` by `Set.ext_iff`, never by `rw`:
  -- the subtype's own type mentions `R.carrierSet`, so rewriting it breaks the motive.
  have hmem : ∀ y : {x : ℝ // x ∈ R.carrierSet}, c < y.val ∧ y.val < d :=
    fun y => (Set.ext_iff.mp hR y.val).mp y.property
  have hmk : ∀ v : ℝ, c < v → v < d → v ∈ R.carrierSet :=
    fun v h1 h2 => (Set.ext_iff.mp hR v).mpr ⟨h1, h2⟩
  let e : ((icoBlock sig M a R c d).toOrdered sig).carrier ≃
      (orderedSum sig Bool fam).carrier := {
    toFun := fun x =>
      if h : x.val = c then orderedSumPt (ms := fam) false ⟨a, le_refl a, le_refl a⟩
      else orderedSumPt (ms := fam) true
        ⟨x.val, hmk x.val (lt_of_le_of_ne x.property.1 (Ne.symm h)) x.property.2⟩
    invFun := fun w => match w with
      | ⟨false, _⟩ => ⟨c, le_refl c, hcd⟩
      | ⟨true, y⟩ => ⟨y.val, le_of_lt (hmem y).1, (hmem y).2⟩
    left_inv := by
      intro x
      by_cases h : x.val = c
      · simp only [dif_pos h]; exact Subtype.ext h.symm
      · simp only [dif_neg h]; exact Subtype.ext rfl
    right_inv := by
      intro ⟨cw, w⟩
      match cw with
      | false =>
        simp only [dite_true]
        refine Sigma.ext rfl (heq_of_eq (Subtype.ext ?_))
        exact (le_antisymm w.property.2 w.property.1).symm
      | true =>
        simp only [dif_neg (hmem w).1.ne']
        exact Sigma.ext rfl (heq_of_eq (Subtype.ext rfl))
  }
  have hm1 : Monotone e := by
    intro x y (hxy : x.val ≤ y.val)
    simp only [e, Equiv.coe_fn_mk]
    split_ifs with hx hy hy
    · exact le_refl _
    · exact Sigma.Lex.le_def.mpr (Or.inl Bool.false_lt_true)
    · exact absurd (le_antisymm (hxy.trans_eq hy) x.property.1) hx
    · exact Sigma.Lex.le_def.mpr (Or.inr ⟨rfl, hxy⟩)
  have hm2 : Monotone e.symm := by
    intro w w' hww
    obtain ⟨cw, w⟩ := w; obtain ⟨cw', w'⟩ := w'
    have hww' := Sigma.Lex.le_def.mp hww
    change ((e.symm ⟨cw, w⟩).val ≤ (e.symm ⟨cw', w'⟩).val)
    revert hww'; cases cw <;> cases cw' <;> simp only [e, Equiv.coe_fn_symm_mk] <;> intro hww'
    · exact le_refl _
    · exact le_of_lt (hmem w').1
    · rcases hww' with h | ⟨h, _⟩
      · exact absurd h (by decide)
      · exact absurd h (by decide)
    · rcases hww' with h | ⟨_, h⟩
      · exact absurd h (lt_irrefl _)
      · exact h
  have h_pred : ∀ (p : sig.preds) (x : ((icoBlock sig M a R c d).toOrdered sig).carrier),
      ((icoBlock sig M a R c d).toOrdered sig).interp p x ↔
        (orderedSum sig Bool fam).interp p (e x) := by
    intro p x
    have he : e x =
        if h : x.val = c then orderedSumPt (ms := fam) false ⟨a, le_refl a, le_refl a⟩
        else orderedSumPt (ms := fam) true
          ⟨x.val, hmk x.val (lt_of_le_of_ne x.property.1 (Ne.symm h)) x.property.2⟩ := rfl
    have hL : ((icoBlock sig M a R c d).toOrdered sig).interp p x
        = (if x.val = c then M.interp p a else R.interp p x.val) := rfl
    rw [hL, he]
    split_ifs with h <;>
      simp [fam, pointSumFamily, orderedSumPt, OrderedMonadicStructure.subinterval,
        RIntervalStructure.toOrdered, orderedSum]
  exact (k_equiv_of_iso sig k _ _ (Equiv.toOrderIso e hm1 hm2) h_pred).symm

/-- The whole real line, assembled from a `ℤ`-indexed family of half-open real blocks. -/
noncomputable def realLine (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (blocks : ℤ → RIntervalStructure sig) : RIntervalStructure sig where
  carrierSet := Set.univ
  ordConnected := Set.ordConnected_univ
  interp p x := (blocks ⌊x⌋).interp p x

/-- The lexicographic sum over `ℤ` of the blocks `[i, i+1)` is the real line — *"this latter has
    flow isomorphic to `R`"*. -/
theorem kEquiv_sum_realLine (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (blocks : ℤ → RIntervalStructure sig)
    (hb : ∀ i : ℤ, (blocks i).carrierSet = Set.Ico (i : ℝ) ((i : ℝ) + 1)) :
    KEquiv sig k (orderedSum sig ℤ (fun i => (blocks i).toOrdered sig))
      ((realLine sig blocks).toOrdered sig) := by
  letI fam := fun i : ℤ => (blocks i).toOrdered sig
  have hmem : ∀ (i : ℤ) (y : {x : ℝ // x ∈ (blocks i).carrierSet}),
      (i : ℝ) ≤ y.val ∧ y.val < (i : ℝ) + 1 := by
    -- `rw [hb i] at y.property` is not available: `y`'s own type mentions
    -- `(blocks i).carrierSet`, so abstracting it breaks the motive. Go through `Set.ext_iff`.
    intro i y; exact (Set.ext_iff.mp (hb i) y.val).mp y.property
  have hfloor : ∀ (i : ℤ) (y : (fam i).carrier), ⌊y.val⌋ = i := by
    intro i y
    exact Int.floor_eq_iff.mpr ⟨(hmem i y).1, (hmem i y).2⟩
  have hstrict : StrictMono (fun w : (orderedSum sig ℤ fam).carrier =>
      (⟨w.2.val, Set.mem_univ _⟩ : {x : ℝ // x ∈ Set.univ})) := by
    rintro ⟨i, y⟩ ⟨j, z⟩ hlt
    rcases Sigma.Lex.lt_def.mp hlt with hij | ⟨hij, hyz⟩
    · have hij' : i < j := hij
      have h1 : ((i : ℝ) + 1) ≤ (j : ℝ) := by exact_mod_cast (by omega : i + 1 ≤ j)
      exact Subtype.mk_lt_mk.mpr
        (lt_of_lt_of_le (hmem i y).2 (le_trans h1 (hmem j z).1))
    · have heq : i = j := hij
      subst heq
      exact Subtype.mk_lt_mk.mpr hyz
  have hright : Function.RightInverse
      (fun x : {v : ℝ // v ∈ (Set.univ : Set ℝ)} =>
        (orderedSumPt (ms := fam) ⌊x.val⌋
          ⟨x.val, by
            rw [hb]
            exact ⟨Int.floor_le _, Int.lt_floor_add_one _⟩⟩))
      (fun w : (orderedSum sig ℤ fam).carrier =>
        (⟨w.2.val, Set.mem_univ _⟩ : {x : ℝ // x ∈ Set.univ})) :=
    fun _ => Subtype.ext rfl
  refine k_equiv_of_iso sig k _ _ (StrictMono.orderIsoOfRightInverse _ hstrict _ hright) ?_
  rintro p ⟨i, y⟩
  show (blocks i).interp p y.val ↔ (blocks ⌊y.val⌋).interp p y.val
  rw [hfloor i y]

end FormalSystem.Metalogic.WeakCanonical
