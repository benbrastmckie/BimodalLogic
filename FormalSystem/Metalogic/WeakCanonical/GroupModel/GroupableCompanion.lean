/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import Mathlib.Order.CountableDenseLinearOrder

/-!
# The groupable companion lemma

The general companion lemma at the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`: **every
countable discrete unbounded-both-ways monadic structure is `goodGroupable` at every depth
`k`** (`companionGeneral`), together with its instantiation at the Base-MCS chronicle
structure (`companionChronicle`) — the Base analogue of `limitdom_is_good`
(`IntegerModel/ReynoldsBridge.lean`), and the deliverable the discrete-branch replacement of
`countermodel_discrete` consumes.

## Source and reading

Doets 1987, ch. 7 (pp. 89-93) proves Segerberg-style completeness over `ζ` by compressing the
canonical structure's block decomposition into a single `ζ`, using the modified Löb axioms at
steps 10-11 (pp. 92-93) to give bounded definable sets maxima. A Base MCS lacks exactly that
compression device. This module replaces *compression-to-`ℤ`* by *inflation-to-`ℚ ×ₗ ℤ`*:
instead of forcing definable sets to attain maxima, the non-Archimedean target absorbs the
unresolved tails. Löb never enters. The chain is:

1. Block decomposition (`GroupModel/BlockDecomposition.lean`): `M ≃o Σ_{i∈I} (ℤ, cᵢ)`.
2. Per-block inflation (`GroupModel/RamseyFactorization.lean`): each block is `≡ₖ` itself
   with coloured copies of `ℚ ×ₗ ℤ` on both sides (`inflate_both` below composes the two
   one-sided absorptions), via Ramsey factorization and the threshold machinery of
   `GroupModel/MonoDiscrete.lean`.
3. `ℚ`-condensation: the index order `I` is carried *verbatim* to the target —
   `I ×ₗ (ℚ + 1 + ℚ)` is countable, dense and unbounded regardless of `I`, hence `≃o ℚ` by
   Cantor's theorem (`Order.iso_of_countable_dense`); no Läuchli–Leonard normal-form
   machinery is involved.
4. Assembly: the fully inflated sum is order-isomorphic to a structure on the whole of
   `ℚ ×ₗ ℤ` (the glue `Σ_{i∈I} (Cᵢ ×ₗ ℤ) ≃o ℚ ×ₗ ℤ`), and `goodGroupable` transports
   backwards along `≡ₖ`.

The carrier is used in full — never as an interval type — per the design rulings recorded in
`GroupModel/GoodGroupable.lean`.

## Main results

* `inflate_both` — both-sided per-block inflation, composed from `inflate_right` and
  `inflate_left`.
* `companionGeneral` — the companion lemma: countable discrete unbounded `M` is
  `goodGroupable sig k M` for every `k`.
* `companionChronicle` — the instantiation at `limitdomMonadicStructure A h_mcs φ` for a
  Base MCS `A` with `□(nextTop) ∈ A`.

## References

- Doets 1987, ch. 7 (pp. 89-93); ch. 3 (pp. 36-57); ch. 1 (pp. 1-22).
- Reynolds 1992, §8 (printed p.185): the `good` vocabulary transposed in
  `GroupModel/GoodGroupable.lean`.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order
open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical.Chronicle

/-! ## Two-summand sums and both-sided inflation -/

/-- The ordered sum of two structures over `Bool` (`false < true`). -/
noncomputable def pairSum (sig : MonadicSignature) (X Y : OrderedMonadicStructure sig) :
    OrderedMonadicStructure sig :=
  orderedSum sig Bool (fun b => if b then Y else X)

/-- **Both-sided per-block inflation**: a coloured `ℤ`-block is `≡ₖ` itself with suitably
coloured copies of `ℚ ×ₗ ℤ` on both sides, composing the two one-sided absorptions through
`doets_lemma_1_4`. -/
theorem inflate_both (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (c : sig.preds → ℤ → Prop) :
    ∃ (eL eR : sig.preds → ℚ ×ₗ ℤ → Prop),
      KEquiv sig k (zFiber sig c)
        (pairSum sig (qzFiber sig eL)
          (pairSum sig (zFiber sig c) (qzFiber sig eR))) := by
  obtain ⟨eR, hR⟩ := inflate_right sig k c
  obtain ⟨eL, hL⟩ := inflate_left sig k c
  refine ⟨eL, eR, hL.trans ?_⟩
  exact doets_lemma_1_4 sig k Bool
    (fun b => if b then zFiber sig c else qzFiber sig eL)
    (fun b => if b then pairSum sig (zFiber sig c) (qzFiber sig eR) else qzFiber sig eL)
    (fun b => by cases b with
      | false => rfl
      | true => exact hR)

/-! ## The condensation fiber `ℚ + 1 + ℚ` -/

/-- The fiber shape of the `ℚ`-condensation: a bottom copy of `ℚ` (absorbing tails from
below), a single point (the block), and a top copy of `ℚ` (absorbing tails from above).
Every fiber has this shape, so `I ×ₗ CondFiber` is countable, dense and unbounded for
*every* countable nonempty `I` — the index order is carried verbatim to `ℚ`. -/
abbrev CondFiber : Type := ℚ ⊕ₗ (Unit ⊕ₗ ℚ)

instance : Countable CondFiber := inferInstanceAs (Countable (ℚ ⊕ (Unit ⊕ ℚ)))

instance : Nonempty CondFiber := ⟨toLex (Sum.inl 0)⟩

instance : NoMaxOrder CondFiber := by
  constructor
  intro x
  rcases sumLex_cases x with ⟨q, rfl⟩ | ⟨y, rfl⟩
  · exact ⟨toLex (Sum.inr (toLex (Sum.inl ()))), Sum.Lex.inl_lt_inr _ _⟩
  · rcases sumLex_cases y with ⟨u, rfl⟩ | ⟨q, rfl⟩
    · exact ⟨toLex (Sum.inr (toLex (Sum.inr 0))),
        Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inl_lt_inr _ _)⟩
    · exact ⟨toLex (Sum.inr (toLex (Sum.inr (q + 1)))),
        Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inr_lt_inr_iff.mpr (by norm_num))⟩

instance : NoMinOrder CondFiber := by
  constructor
  intro x
  rcases sumLex_cases x with ⟨q, rfl⟩ | ⟨y, rfl⟩
  · exact ⟨toLex (Sum.inl (q - 1)), Sum.Lex.inl_lt_inl_iff.mpr (by norm_num)⟩
  · exact ⟨toLex (Sum.inl 0), Sum.Lex.inl_lt_inr _ _⟩

instance : DenselyOrdered CondFiber := by
  constructor
  intro a b hab
  rcases sumLex_cases a with ⟨q, rfl⟩ | ⟨y, rfl⟩
  · rcases sumLex_cases b with ⟨q', rfl⟩ | ⟨y', rfl⟩
    · have hqq : q < q' := Sum.Lex.inl_lt_inl_iff.mp hab
      obtain ⟨r, hr1, hr2⟩ := exists_between hqq
      exact ⟨toLex (Sum.inl r), Sum.Lex.inl_lt_inl_iff.mpr hr1,
        Sum.Lex.inl_lt_inl_iff.mpr hr2⟩
    · exact ⟨toLex (Sum.inl (q + 1)), Sum.Lex.inl_lt_inl_iff.mpr (by norm_num),
        Sum.Lex.inl_lt_inr _ _⟩
  · rcases sumLex_cases b with ⟨q', rfl⟩ | ⟨y', rfl⟩
    · exact absurd hab Sum.Lex.not_inr_lt_inl
    · have hyy : y < y' := Sum.Lex.inr_lt_inr_iff.mp hab
      rcases sumLex_cases y with ⟨u, rfl⟩ | ⟨q, rfl⟩
      · rcases sumLex_cases y' with ⟨u', rfl⟩ | ⟨q', rfl⟩
        · exact absurd hyy (by
            have : toLex (Sum.inl u) = (toLex (Sum.inl u') : Unit ⊕ₗ ℚ) := rfl
            rw [this]
            exact lt_irrefl _)
        · refine ⟨toLex (Sum.inr (toLex (Sum.inr (q' - 1)))),
            Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inl_lt_inr _ _),
            Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inr_lt_inr_iff.mpr (by norm_num))⟩
      · rcases sumLex_cases y' with ⟨u', rfl⟩ | ⟨q', rfl⟩
        · exact absurd hyy Sum.Lex.not_inr_lt_inl
        · have hqq : q < q' := Sum.Lex.inr_lt_inr_iff.mp hyy
          obtain ⟨r, hr1, hr2⟩ := exists_between hqq
          exact ⟨toLex (Sum.inr (toLex (Sum.inr r))),
            Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inr_lt_inr_iff.mpr hr1),
            Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inr_lt_inr_iff.mpr hr2)⟩

section Condensation

variable (I : Type) [LinearOrder I]

/-- The condensation order `I ×ₗ (ℚ + 1 + ℚ)` is dense: within a fiber by fiber density,
across fibers because every fiber is unbounded above. -/
private theorem condL_dense : DenselyOrdered (I ×ₗ CondFiber) := by
  constructor
  intro a b hab
  rcases Prod.Lex.lt_iff.mp hab with hii | ⟨hii, hww⟩
  · obtain ⟨w, hw⟩ := exists_gt ((ofLex a).2)
    refine ⟨toLex ((ofLex a).1, w), ?_, ?_⟩
    · exact Prod.Lex.lt_iff.mpr (Or.inr ⟨rfl, hw⟩)
    · exact Prod.Lex.lt_iff.mpr (Or.inl hii)
  · obtain ⟨w, hw1, hw2⟩ := exists_between hww
    refine ⟨toLex ((ofLex a).1, w), ?_, ?_⟩
    · exact Prod.Lex.lt_iff.mpr (Or.inr ⟨rfl, hw1⟩)
    · exact Prod.Lex.lt_iff.mpr (Or.inr ⟨hii, hw2⟩)

private theorem condL_noMax : NoMaxOrder (I ×ₗ CondFiber) := by
  constructor
  intro a
  obtain ⟨w, hw⟩ := exists_gt ((ofLex a).2)
  exact ⟨toLex ((ofLex a).1, w), Prod.Lex.lt_iff.mpr (Or.inr ⟨rfl, hw⟩)⟩

private theorem condL_noMin : NoMinOrder (I ×ₗ CondFiber) := by
  constructor
  intro a
  obtain ⟨w, hw⟩ := exists_lt ((ofLex a).2)
  exact ⟨toLex ((ofLex a).1, w), Prod.Lex.lt_iff.mpr (Or.inr ⟨rfl, hw⟩)⟩

/-- **`ℚ`-condensation** (Cantor): for every countable nonempty index order `I`, the
condensation order `I ×ₗ (ℚ + 1 + ℚ)` is order-isomorphic to `ℚ`. -/
private theorem condensationOfQ [Countable I] [Nonempty I] :
    Nonempty ((I ×ₗ CondFiber) ≃o ℚ) := by
  haveI : Countable (I ×ₗ CondFiber) := inferInstanceAs (Countable (I × CondFiber))
  haveI : Nonempty (I ×ₗ CondFiber) := inferInstanceAs (Nonempty (I × CondFiber))
  haveI := condL_dense I
  haveI := condL_noMax I
  haveI := condL_noMin I
  exact Order.iso_of_countable_dense _ _

end Condensation

/-! ## Transport of `goodGroupable` along a carrier isomorphism -/

/-- Any structure whose carrier is order-isomorphic to `ℚ ×ₗ ℤ` is `goodGroupable`: the
target structure is obtained by transporting the predicates along the isomorphism. -/
theorem goodGroupable_of_carrier_iso (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (M : OrderedMonadicStructure sig)
    (Φ : M.carrier ≃o ℚ ×ₗ ℤ) : goodGroupable sig k M := by
  refine ⟨⟨fun p x => M.interp p (Φ.symm x)⟩, ?_⟩
  refine k_equiv_of_iso sig k M _ Φ ?_
  intro p x
  show M.interp p x ↔ M.interp p (Φ.symm (Φ x))
  rw [OrderIso.symm_apply_apply]


/-! ## The glue: the inflated sum is a structure on all of `ℚ ×ₗ ℤ` -/

section Glue

variable (sig : MonadicSignature) (I : Type) [LinearOrder I]
variable (cL cR : I → sig.preds → ℚ ×ₗ ℤ → Prop) (c : I → sig.preds → ℤ → Prop)

/-- The fully inflated sum: every block flanked by its two tail copies of `ℚ ×ₗ ℤ`. -/
private noncomputable def inflatedSum : OrderedMonadicStructure sig :=
  orderedSum sig I (fun i => pairSum sig (qzFiber sig (cL i))
    (pairSum sig (zFiber sig (c i)) (qzFiber sig (cR i))))

/-- Send an inflated-sum point to its position in `ℚ ×ₗ ℤ`: the `ψ`-image of its
`(fiber, region)` coordinate, at the height of its `ℤ`-coordinate. -/
private noncomputable def glueMap (ψ : (I ×ₗ CondFiber) ≃o ℚ) :
    (inflatedSum sig I cL cR c).carrier → ℚ ×ₗ ℤ :=
  fun s =>
    match s with
    | ⟨i, ⟨false, v⟩⟩ =>
        toLex (ψ (toLex (i, toLex (Sum.inl (ofLex v).1))), (ofLex v).2)
    | ⟨i, ⟨true, ⟨false, z⟩⟩⟩ =>
        toLex (ψ (toLex (i, toLex (Sum.inr (toLex (Sum.inl ()))))), z)
    | ⟨i, ⟨true, ⟨true, v⟩⟩⟩ =>
        toLex (ψ (toLex (i, toLex (Sum.inr (toLex (Sum.inr (ofLex v).1))))), (ofLex v).2)

private theorem glueMap_strictMono (ψ : (I ×ₗ CondFiber) ≃o ℚ) :
    StrictMono (glueMap sig I cL cR c ψ) := by
  intro s s' hst
  have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) s s' := hst
  cases h with
  | left a b hij =>
    rename_i i j
    have hres : ∀ (xa xb : CondFiber) (za zb : ℤ),
        (toLex (ψ (toLex (i, xa)), za) : ℚ ×ₗ ℤ) < toLex (ψ (toLex (j, xb)), zb) :=
      fun xa xb za zb => Prod.Lex.toLex_lt_toLex.mpr (Or.inl (ψ.strictMono
        (Prod.Lex.toLex_lt_toLex.mpr (Or.inl hij))))
    obtain ⟨ba, va⟩ := a
    obtain ⟨bb, vb⟩ := b
    cases ba with
    | false =>
      cases bb with
      | false => exact hres _ _ _ _
      | true =>
        obtain ⟨bb2, vb2⟩ := vb
        cases bb2 with
        | false => exact hres _ _ _ _
        | true => exact hres _ _ _ _
    | true =>
      obtain ⟨ba2, va2⟩ := va
      cases ba2 with
      | false =>
        cases bb with
        | false => exact hres _ _ _ _
        | true =>
          obtain ⟨bb2, vb2⟩ := vb
          cases bb2 with
          | false => exact hres _ _ _ _
          | true => exact hres _ _ _ _
      | true =>
        cases bb with
        | false => exact hres _ _ _ _
        | true =>
          obtain ⟨bb2, vb2⟩ := vb
          cases bb2 with
          | false => exact hres _ _ _ _
          | true => exact hres _ _ _ _
  | right a b hab =>
    rename_i i
    have hreg : ∀ (xa xb : CondFiber) (za zb : ℤ), xa < xb →
        (toLex (ψ (toLex (i, xa)), za) : ℚ ×ₗ ℤ) < toLex (ψ (toLex (i, xb)), zb) :=
      fun xa xb za zb hx => Prod.Lex.toLex_lt_toLex.mpr (Or.inl (ψ.strictMono
        (Prod.Lex.toLex_lt_toLex.mpr (Or.inr ⟨rfl, hx⟩))))
    have hsame : ∀ (xa : CondFiber) (za zb : ℤ), za < zb →
        (toLex (ψ (toLex (i, xa)), za) : ℚ ×ₗ ℤ) < toLex (ψ (toLex (i, xa)), zb) :=
      fun xa za zb hz => Prod.Lex.toLex_lt_toLex.mpr (Or.inr ⟨rfl, hz⟩)
    have h2 : Sigma.Lex (· < ·) (fun _ => (· < ·)) a b := hab
    cases h2 with
    | left a2 b2 hij2 =>
      rename_i ba bb
      cases ba with
      | false =>
        cases bb with
        | false => exact absurd hij2 (lt_irrefl _)
        | true =>
          obtain ⟨bb2, vb2⟩ := b2
          cases bb2 with
          | false => exact hreg _ _ _ _ (Sum.Lex.inl_lt_inr _ _)
          | true => exact hreg _ _ _ _ (Sum.Lex.inl_lt_inr _ _)
      | true =>
        cases bb with
        | false => exact absurd hij2 (by decide)
        | true => exact absurd hij2 (lt_irrefl _)
    | right a2 b2 hab2 =>
      rename_i bi
      cases bi with
      | false =>
        rcases Prod.Lex.lt_iff.mp hab2 with hq | ⟨hq, hz⟩
        · exact hreg _ _ _ _ (Sum.Lex.inl_lt_inl_iff.mpr hq)
        · have hXY : ψ (toLex (i, toLex (Sum.inl (ofLex a2).1))) =
              ψ (toLex (i, toLex (Sum.inl (ofLex b2).1))) :=
            congrArg (fun r => ψ (toLex (i, toLex (Sum.inl r)))) hq
          exact Prod.Lex.toLex_lt_toLex.mpr (Or.inr ⟨hXY, hz⟩)
      | true =>
        have h3 : Sigma.Lex (· < ·) (fun _ => (· < ·)) a2 b2 := hab2
        cases h3 with
        | left a3 b3 hij3 =>
          rename_i ba3 bb3
          cases ba3 with
          | false =>
            cases bb3 with
            | false => exact absurd hij3 (lt_irrefl _)
            | true =>
              exact hreg _ _ _ _
                (Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inl_lt_inr _ _))
          | true =>
            cases bb3 with
            | false => exact absurd hij3 (by decide)
            | true => exact absurd hij3 (lt_irrefl _)
        | right a3 b3 hab3 =>
          rename_i bi3
          cases bi3 with
          | false => exact hsame _ _ _ hab3
          | true =>
            rcases Prod.Lex.lt_iff.mp hab3 with hq | ⟨hq, hz⟩
            · exact hreg _ _ _ _
                (Sum.Lex.inr_lt_inr_iff.mpr (Sum.Lex.inr_lt_inr_iff.mpr hq))
            · have hXY : ψ (toLex (i, toLex (Sum.inr (toLex (Sum.inr (ofLex a3).1))))) =
                  ψ (toLex (i, toLex (Sum.inr (toLex (Sum.inr (ofLex b3).1))))) :=
                congrArg (fun r => ψ (toLex (i, toLex (Sum.inr (toLex (Sum.inr r)))))) hq
              exact Prod.Lex.toLex_lt_toLex.mpr (Or.inr ⟨hXY, hz⟩)

private theorem glueMap_surjective (ψ : (I ×ₗ CondFiber) ≃o ℚ) :
    Function.Surjective (glueMap sig I cL cR c ψ) := by
  intro y
  set u : I ×ₗ CondFiber := ψ.symm ((ofLex y).1) with hu
  have hψu : ψ u = (ofLex y).1 := ψ.apply_symm_apply _
  have heta : u = toLex ((ofLex u).1, (ofLex u).2) := rfl
  rcases sumLex_cases ((ofLex u).2) with ⟨q, hq⟩ | ⟨w, hw⟩
  · refine ⟨⟨(ofLex u).1, ⟨false, toLex (q, (ofLex y).2)⟩⟩, ?_⟩
    show (toLex (ψ (toLex ((ofLex u).1,
        toLex (Sum.inl (ofLex (toLex (q, (ofLex y).2))).1))),
        (ofLex (toLex (q, (ofLex y).2))).2) : ℚ ×ₗ ℤ) = y
    have h1 : (ofLex (toLex (q, (ofLex y).2))).1 = q := rfl
    have h2 : (ofLex (toLex (q, (ofLex y).2))).2 = (ofLex y).2 := rfl
    rw [h1, h2, ← hq, ← heta, hψu]
    rfl
  · rcases sumLex_cases w with ⟨un, hun⟩ | ⟨q, hq2⟩
    · have hun' : w = toLex (Sum.inl ()) := hun.trans rfl
      refine ⟨⟨(ofLex u).1, ⟨true, ⟨false, (ofLex y).2⟩⟩⟩, ?_⟩
      show (toLex (ψ (toLex ((ofLex u).1, toLex (Sum.inr (toLex (Sum.inl ()))))),
        (ofLex y).2) : ℚ ×ₗ ℤ) = y
      rw [← hun', ← hw, ← heta, hψu]
      rfl
    · refine ⟨⟨(ofLex u).1, ⟨true, ⟨true, toLex (q, (ofLex y).2)⟩⟩⟩, ?_⟩
      show (toLex (ψ (toLex ((ofLex u).1,
          toLex (Sum.inr (toLex (Sum.inr (ofLex (toLex (q, (ofLex y).2))).1))))),
          (ofLex (toLex (q, (ofLex y).2))).2) : ℚ ×ₗ ℤ) = y
      have h1 : (ofLex (toLex (q, (ofLex y).2))).1 = q := rfl
      have h2 : (ofLex (toLex (q, (ofLex y).2))).2 = (ofLex y).2 := rfl
      rw [h1, h2, ← hq2, ← hw, ← heta, hψu]
      rfl

end Glue

/-! ## The companion lemma -/

/--
**The groupable companion lemma** (general form): every countable discrete
unbounded-both-ways monadic structure is `goodGroupable` at every depth `k` — there is a
structure on the full carrier `ℚ ×ₗ ℤ` that is `≡ₖ` to it. Doets ch. 7 with the
Löb-dependent compression steps 10-11 replaced by inflation into the non-Archimedean target.
-/
theorem companionGeneral (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (M : OrderedMonadicStructure sig) [Countable M.carrier]
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [Nonempty M.carrier] :
    goodGroupable sig k M := by
  obtain ⟨I, iLin, iCnt, iNe, c, f, hpred⟩ := blockDecomposition sig M
  have hA : KEquiv sig k M (orderedSum sig I (fun i => zFiber sig (c i))) :=
    k_equiv_of_iso sig k M _ f (fun p x => hpred p x)
  choose eL eR hE using fun i => inflate_both sig k (c i)
  have hB : KEquiv sig k (orderedSum sig I (fun i => zFiber sig (c i)))
      (inflatedSum sig I eL eR c) :=
    doets_lemma_1_4 sig k I _ _ hE
  obtain ⟨ψ⟩ := condensationOfQ I
  have hgood : goodGroupable sig k (inflatedSum sig I eL eR c) :=
    goodGroupable_of_carrier_iso sig k _
      (StrictMono.orderIsoOfSurjective _ (glueMap_strictMono sig I eL eR c ψ)
        (glueMap_surjective sig I eL eR c ψ))
  exact goodGroupable_of_kEquiv sig k (hA.trans hB) hgood

/--
**The chronicle companion** — the Base analogue of `limitdom_is_good`
(`IntegerModel/ReynoldsBridge.lean`): at a Base MCS `A` with `□(nextTop) ∈ A`, the
limit-domain structure is `goodGroupable` at every depth. Unlike `limitdom_is_good`, no
`Discrete ≤ fc` hypothesis enters: discreteness of the flow comes from `□(nextTop)` alone,
and the target absorbs what the Löb-style compression would otherwise have to collapse.
-/
theorem companionChronicle {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box : Formula.box nextTop ∈ A)
    (φ : Formula) (k : ℕ) :
    goodGroupable (mkSigFrom φ) k (limitdomMonadicStructure A h_mcs φ) := by
  have h_discrete := box_discrete_gives_discreteness fc A h_mcs h_box
  letI : SuccOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
    limitdomMonadicStructureSuccOrder A h_mcs φ h_discrete
  letI : PredOrder (limitdomMonadicStructure A h_mcs φ).carrier :=
    limitdomMonadicStructurePredOrder A h_mcs φ h_discrete
  exact companionGeneral (mkSigFrom φ) k (limitdomMonadicStructure A h_mcs φ)

end FormalSystem.Metalogic.WeakCanonical

