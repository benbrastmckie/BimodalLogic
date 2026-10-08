/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment

/-!
# The computable `k`-type of a finite decidable structure

`kTypeOf sig k M` (`NEquivalence.lean`) is classical by design: it decides `NfEvalNf M k 0
Fin.elim0 nf` with `Classical.dec`, because the carrier of an arbitrary `OrderedMonadicStructure`
may be infinite. On a **finite** carrier with decidable order and decidable predicates that
choice is unnecessary: `NfEvalNf` is a finite conjunction of finite quantifications, so a
`Decidable` instance follows by induction on the depth `k` (`decNfEvalNf`), and the `k`-type
read off from it (`kTypeOfFin`) is the library's `kTypeOf` pointwise (`kTypeOfFin_eq`) — `decide`
does not depend on which instance decides the proposition. The same induction, on the formula
instead of the depth, decides Tarski satisfaction `eval` outright (`decEval`).

## What is computed, and what is not

* **Computed**: the depth-`k` type of a finite decidable structure, and in particular of every
  half-open segment `segZ sig c a b` of a decidable colouring of `ℤ` (`kTypeOfFin_segZ`). These
  are `def`s, never `noncomputable def`s, and they evaluate.
* **Not decided**: anything about `⊡` or about the realized family triples `Hit` of
  `RaySummary/SeamMulti.lean`. This module composes nothing and summarizes no history; it is the
  computability witness that the summary alphabet `kTypeOf sig k (segZ sig c a b)` can be read
  off a finite segment effectively, nothing more. Realizability — which colourings are traces
  of histories through a seam — is a separate device, not built here; the backward (`⊡ Pp`)
  side has no `Bool`-fixture bridge at all, and nothing here changes that.
* **No complexity bound** is claimed, upper or lower. `decide` on `KType sig k` is exponential
  in `|NormalForm sig k 0|`; the witnesses in `Tests/` run at depth 1 on short segments.

## The `ℤ`-instance hazard

Every instance for the segment carrier `{t : ℤ // a ≤ t ∧ t < b}` below is an **explicit term**.
`inferInstanceAs` on a `ℤ`-subtype's order or equality resolves through
`Int.instConditionallyCompleteLinearOrder`, which is noncomputable, and would make the whole
device noncomputable for no mathematical reason. So: `DecidableEq` goes through `Int.decEq`,
`DecidableRel (· < ·)` through `Int.decLt`, both via `decidable_of_iff` with the **target
proposition first** in the `@` form (`@decidable_of_iff (target) (source) iff inst`), and
`Fintype` through `Fintype.subtype` on `Finset.Ico` with `Int.instLinearOrder` and
`Int.instLocallyFiniteOrder` named outright. The generic `LinearOrder M.carrier` instance from
`Expressiveness/MonadicFO.lean` also supplies `DecidableEq`/`DecidableRel`; it is never used by
the decision procedures here, which take their decidability data from the explicit binders
`[DecidableEq M.carrier] [DecidableRel (α := M.carrier) (· < ·)]` and name them when they decide
an atom.

## Main definitions and results

* `decNfEvalNf` — `NfEvalNf` is decidable on a finite decidable structure, by induction on `k`.
* `kTypeOfFin` — the computable `k`-type.
* `kTypeOfFin_eq` — it equals the classical `kTypeOf sig k M`.
* `decEval` — Tarski satisfaction `eval M env α` is decidable on a finite decidable structure.
* `segZFintype`, `segZDecidableEq`, `segZDecidableLT`, `segZDecidablePred` — the explicit
  instances for a segment of a decidable colouring.
* `kTypeOfFin_segZ` — the computable `k`-type of a segment is the segment's `k`-type.

## References

* [K. Doets, *Completeness and Definability*, 1987, Def 1.6.1] for the normal-form idiom
  the depth induction follows.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

section FiniteDecidable

variable (M : OrderedMonadicStructure sig)

/-- An atom is decidable from the explicit predicate and order instances (never from the
generic `LinearOrder` on the carrier — see the module header). -/
def decAtomEval [dlt : DecidableRel (α := M.carrier) (· < ·)]
    [dint : ∀ p, DecidablePred (M.interp p)] {n : ℕ} (env : Fin n → M.carrier) :
    (a : AtomKind sig n) → Decidable (AtomEval M env a)
  | .pred p i => dint p (env i)
  | .order i j _ => dlt (env i) (env j)

/-- `NfEvalNf` is decidable on a finite decidable structure, by induction on the depth: at
depth `0` a finite conjunction over `AtomKind sig n`; at depth `k + 1` that conjunction together
with, for each depth-`k` normal form in one more variable, a finite existential over the
carrier decided by the induction hypothesis. -/
def decNfEvalNf [finM : Fintype M.carrier] [DecidableEq M.carrier]
    [DecidableRel (α := M.carrier) (· < ·)] [∀ p, DecidablePred (M.interp p)] :
    (k n : ℕ) → (env : Fin n → M.carrier) → (nf : NormalForm sig k n) →
      Decidable (NfEvalNf M k n env nf)
  | 0, n, env, nf =>
      @Fintype.decidableForallFintype (AtomKind sig n)
        (fun a => AtomEval M env a ↔ (nf a = true))
        (fun a => @instDecidableIff _ _ (decAtomEval M env a) (instDecidableEqBool _ _))
        (atomKindFintype sig n)
  | k + 1, n, env, ⟨atomA, quantA⟩ =>
      let dAtoms : Decidable (∀ a : AtomKind sig n, AtomEval M env a ↔ (atomA a = true)) :=
        @Fintype.decidableForallFintype (AtomKind sig n)
          (fun a => AtomEval M env a ↔ (atomA a = true))
          (fun a => @instDecidableIff _ _ (decAtomEval M env a) (instDecidableEqBool _ _))
          (atomKindFintype sig n)
      let dEx : ∀ sub_nf : NormalForm sig k (n + 1),
          Decidable (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) :=
        fun sub_nf =>
          @Fintype.decidableExistsFintype M.carrier
            (fun x => NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf)
            (fun x => decNfEvalNf k (n + 1) (Fin.cons x env) sub_nf)
            finM
      let dQuant : Decidable (∀ sub_nf : NormalForm sig k (n + 1),
          (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) ↔
            (quantA sub_nf = true)) :=
        @Fintype.decidableForallFintype (NormalForm sig k (n + 1))
          (fun sub_nf => (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) ↔
            (quantA sub_nf = true))
          (fun sub_nf => @instDecidableIff _ _ (dEx sub_nf) (instDecidableEqBool _ _))
          (normalFormFintype sig k (n + 1))
      @instDecidableAnd _ _ dAtoms dQuant

/-- **The computable `k`-type** of a finite decidable structure. -/
def kTypeOfFin [Fintype M.carrier] [DecidableEq M.carrier]
    [DecidableRel (α := M.carrier) (· < ·)] [∀ p, DecidablePred (M.interp p)] (k : ℕ) :
    KType sig k :=
  fun nf => @decide (NfEvalNf M k 0 Fin.elim0 nf) (decNfEvalNf M k 0 Fin.elim0 nf)

/-- The computable `k`-type is the library's classical `k`-type: `decide` does not depend on
the instance deciding the proposition. -/
theorem kTypeOfFin_eq [Fintype M.carrier] [DecidableEq M.carrier]
    [DecidableRel (α := M.carrier) (· < ·)] [∀ p, DecidablePred (M.interp p)] (k : ℕ) :
    kTypeOfFin M k = kTypeOf sig k M := by
  funext nf
  unfold kTypeOfFin kTypeOf
  exact decide_eq_decide.mpr Iff.rfl

/-- Tarski satisfaction `eval M env α` is decidable on a finite decidable structure, by
structural induction on the formula: atoms and `lt` from the explicit binders, the connectives
from the induction hypotheses, the quantifiers as finite quantifications over the carrier. -/
def decEval [finM : Fintype M.carrier] [DecidableEq M.carrier]
    [dlt : DecidableRel (α := M.carrier) (· < ·)] [dint : ∀ p, DecidablePred (M.interp p)] :
    {n : ℕ} → (env : Fin n → M.carrier) → (α : MonadicFormula sig n) →
    Decidable (eval M env α)
  | _, env, .atom p i => dint p (env i)
  | _, env, .lt i j => dlt (env i) (env j)
  | _, env, .not α => @instDecidableNot _ (decEval env α)
  | _, env, .and α β => @instDecidableAnd _ _ (decEval env α) (decEval env β)
  | _, env, .all α =>
      @Fintype.decidableForallFintype M.carrier (fun x => eval M (Fin.cons x env) α)
        (fun x => decEval (Fin.cons x env) α) finM
  | _, env, .ex α =>
      @Fintype.decidableExistsFintype M.carrier (fun x => eval M (Fin.cons x env) α)
        (fun x => decEval (Fin.cons x env) α) finM

end FiniteDecidable

/-! ## Segments of a decidable colouring

The four instances a segment `segZ sig c a b` of a decidable colouring carries, each an explicit
term for the reason the module header gives. They are stated on the carrier of `segZ` itself so
that instance resolution finds them for `kTypeOfFin (segZ sig c a b) k` without unfolding
`segZ`. -/

section Segment

variable (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ)

/-- A segment is finite: it is the subtype of `Finset.Ico a b`, with the integer order and
its locally-finite-order instance named outright. -/
instance segZFintype : Fintype (segZ sig c a b).carrier :=
  Fintype.subtype (@Finset.Ico ℤ Int.instLinearOrder.toPartialOrder.toPreorder
    Int.instLocallyFiniteOrder a b) (fun _ => Finset.mem_Ico)

/-- Equality on a segment is decided through `Int.decEq` on the underlying integers. -/
instance segZDecidableEq : DecidableEq (segZ sig c a b).carrier :=
  fun x y =>
    @decidable_of_iff (x = y) (x.1 = y.1) ⟨Subtype.ext, congrArg Subtype.val⟩ (Int.decEq x.1 y.1)

/-- The order on a segment is decided through `Int.decLt` on the underlying integers. -/
instance segZDecidableLT : DecidableRel (α := (segZ sig c a b).carrier) (· < ·) :=
  fun x y => @decidable_of_iff (x < y) (x.1 < y.1) Iff.rfl (Int.decLt x.1 y.1)

/-- A segment's predicates are decided by the colouring's own instances. -/
instance segZDecidablePred : ∀ p, DecidablePred ((segZ sig c a b).interp p) :=
  fun p t => inferInstanceAs (Decidable (c p t.1))

/-- The computable `k`-type of a segment of a decidable colouring is the segment's `k`-type —
the summary alphabet of `KTypeSummary/Segment.lean`, now read off effectively. -/
theorem kTypeOfFin_segZ (k : ℕ) :
    kTypeOfFin (segZ sig c a b) k = kTypeOf sig k (segZ sig c a b) :=
  kTypeOfFin_eq _ k

end Segment

end FormalSystem.Metalogic.WeakCanonical
