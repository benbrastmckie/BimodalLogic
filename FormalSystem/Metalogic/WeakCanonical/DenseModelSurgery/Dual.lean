/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Defs

/-!
# The order-duality transport layer for Reynolds §6

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*.

Reynolds states §6's lemmas on **one side only** and discharges every dual with a single
sentence. Printed **p.178**:

> *Dually we can define `λ(x)` about left ends.*

and, closing Lemma 2, the bare sentence *"Dually L."*; and closing Lemma 6 (printed **p.180**):

> *Using mirror images of the above and previous results we get our proof.*

This module makes that sentence a **construction** rather than a second proof. It builds the
order-dual `dual M` of an `OrderedMonadicStructure`, the syntactic dualization `dualize` of a
`MonadicFormula` and `swapUS` of a `Formula`, and proves that `eval`, `TemporalTruth`, the
Prior-U/Prior-S pair, `∼` and the gap predicates all transport across. A §6 *"mirror image"*
then costs an instantiation at `(dual M, dualize ε)` rather than a hand-written module.

## Why `d` and not `OrderDual.toDual`

`dual M` reverses the order by taking `carrier := (M.carrier)ᵒᵈ`. Points are moved across with

```lean
def d (x : M.carrier) : (dual M).carrier := x
```

which is the **identity function**, definitionally. This is deliberate and load-bearing: routing
points through `OrderDual.toDual` instead reproduces the `.carrier`-unfolding mismatch that this
tree already documents for `orderedSum` at `NEquivalence.lean:134`, and it is what forces the
binder cases of `eval_dualize` into `Fin.cons` bookkeeping. With `d` in place those cases are
one-liners and the `lt` case of the transport is `Iff.rfl` — **order reversal is definitional**.

For the same instance-diamond reason `dual` is deliberately **not** `@[reducible]`.

## What does *not* transport: `IsContempEquivDense` clause (iii)

`IsContempEquivDense` (`Defs.lean`) has three clauses. Clauses (i) *"`∼_M` is an equivalence
relation"* and (ii) *"`∼_M` partitions `M` into intervals"* transport through
`contempEquivDense_dual` below. Clause (iii) — *"`ε` depends only on contemporary properties:
`M ⊨ ε(a,b)` iff `M | [a,b] ⊨ ε(a,b)`"* — **does not transport definitionally.**

The obstruction is **this tree's rendering, not Reynolds'**, and is recorded here as such.
Reynolds' `M | [a,b]` is an *unordered* interval: the pair `(a,b)` is not presumed ordered and
the interval is the same object either way round. `M.subinterval` (`MonadicFO.lean:215`) renders
it as a `Subtype` over the predicate `min a b ≤ x ∧ x ≤ max a b`; under order reversal `min` and
`max` exchange and the dual's predicate is the *same two conjuncts in the opposite order*, which
is not definitionally equal. There is no `eval`-along-a-carrier-isomorphism lemma in the tree to
bridge them (`Kamp.eval_rename` is variable renaming, not carrier transport).

**The escape taken here** is to build the missing bridge rather than to route around it:
`StructIso` and `eval_iso` below prove `eval` invariant along any order- and
interpretation-preserving equivalence of carriers, and `subintervalDualIso` instantiates that at
`Equiv.subtypeEquivRight (fun _ => and_comm)`, which is exactly the conjunct exchange. Clause
(iii) then transports like the other two, `IsContempEquivDense` is left unweakened and unrenamed,
and `eval_iso` is reusable for any later carrier transport (`Kamp.eval_rename` covers only
variable renaming).

For the record, had that bridge resisted, nothing would have been lost by dropping clause (iii)
instead: repo-wide it is consumed **nowhere** — `contemporary` appears only at its own
declaration and in the construction of the `epsTop` witness, and every §6 use of
`IsContempEquivDense` goes through `contemp_refl` / `contemp_symm` / `contemp_trans` /
`contemp_of_between` (`Lemma34.lean:176-199`), all of which read only clauses (i) and (ii).

## Retrospective subsumption

This layer subsumes two past/future mirrors this tree already paid for by hand — the Lemma 7
mirror at `BadIntervals.lean:968-1225` (258 lines) and `Kamp/Lemma53FaithfulPast.lean` (364
lines). **Neither is deleted, refactored or deprecated**; both stay landed exactly as they are,
and every existing consumer is untouched. The point of recording the subsumption is forward
looking: no later phase should derive a third mirror by hand when an instantiation at
`(dual M, dualize ε)` will do.

## Standing conditionality caveat

Every §6 result below Lemma 2 — including everything this module is used to build — is
**conditional**. `IsContempEquivDense ε` together with `SemanticPriorU` / `SemanticPriorS` are
hypotheses, and the only `ε` this tree can currently exhibit satisfying them is `epsTop`, for
which `EndsInGapOnRight` is empty. There is therefore **no live non-trivial instance** of any of
these lemmas yet, and nothing here is discharged in the unconditional sense. The anti-vacuity
witness arrives with Lemma 9 / Theorem 4.

## References

- Reynolds 1992, §6, printed p.178 (the duality convention, *"Dually we can define `λ(x)`"*).
- Reynolds 1992, §6 Lemma 6, printed p.180 (*"using mirror images of the above and previous
  results"*).
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## The dual structure -/

/-- **The order-dual of an ordered monadic structure**: the same points and the same predicate
interpretations, with the order reversed.

Deliberately **not** `@[reducible]`: making it reducible lets the elaborator unfold `.carrier`
during instance search and reproduces the diamond documented at `NEquivalence.lean:134`. -/
def dual (M : OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := (M.carrier)ᵒᵈ
  interp p x := M.interp p (OrderDual.ofDual x)
  carrierOrder := inferInstance

@[simp] theorem dual_carrier (M : OrderedMonadicStructure sig) :
    (dual M).carrier = (M.carrier)ᵒᵈ := rfl

/-- **Move a point across, definitionally.** This is the identity function; naming it is what
keeps the elaborator from unfolding `.carrier` under instance search, and it is what collapses
the binder cases of `eval_dualize` to one-liners. -/
def d {M : OrderedMonadicStructure sig} (x : M.carrier) : (dual M).carrier := x

/-- **Order reversal is definitional.** -/
theorem d_lt {M : OrderedMonadicStructure sig} (x y : M.carrier) :
    d x < d y ↔ y < x := Iff.rfl

/-! ## Syntactic dualization -/

/-- **`dualize`** — flip every order comparison in a monadic formula. Atoms, connectives and
binders are untouched; only `.lt i j ↦ .lt j i` changes. -/
def dualize {sig : MonadicSignature} : {n : Nat} → MonadicFormula sig n → MonadicFormula sig n
  | _, .atom p i => .atom p i
  | _, .lt i j => .lt j i
  | _, .not α => .not (dualize α)
  | _, .and α β => .and (dualize α) (dualize β)
  | _, .all α => .all (dualize α)
  | _, .ex α => .ex (dualize α)

/-- `dualize` is an involution. -/
theorem dualize_involutive {sig : MonadicSignature} :
    ∀ {n : Nat} (α : MonadicFormula sig n), dualize (dualize α) = α
  | _, .atom _ _ => rfl
  | _, .lt _ _ => rfl
  | _, .not α => by rw [dualize, dualize, dualize_involutive α]
  | _, .and α β => by rw [dualize, dualize, dualize_involutive α, dualize_involutive β]
  | _, .all α => by rw [dualize, dualize, dualize_involutive α]
  | _, .ex α => by rw [dualize, dualize, dualize_involutive α]

/-- **The `eval` transport.** Evaluating the dualized formula in the dual structure, at the
transported environment, is evaluating the original in the original.

The `lt` case is `Iff.rfl` — order reversal is definitional — and the two binder cases are
one-liners because `d` is the identity. -/
theorem eval_dualize {M : OrderedMonadicStructure sig} :
    ∀ {n : Nat} (env : Fin n → M.carrier) (φ : MonadicFormula sig n),
      eval (dual M) (d ∘ env) (dualize φ) ↔ eval M env φ
  | _, _, .atom _ _ => Iff.rfl
  | _, _, .lt _ _ => Iff.rfl
  | _, env, .not α => not_congr (eval_dualize env α)
  | _, env, .and α β => and_congr (eval_dualize env α) (eval_dualize env β)
  | _, env, .all α =>
      ⟨fun h x => (eval_dualize (M := M) (Fin.cons x env) α).mp (h (d x)),
       fun h x => (eval_dualize (M := M) (Fin.cons x env) α).mpr (h x)⟩
  | _, env, .ex α =>
      ⟨fun ⟨x, hx⟩ => ⟨x, (eval_dualize (M := M) (Fin.cons x env) α).mp hx⟩,
       fun ⟨x, hx⟩ => ⟨d x, (eval_dualize (M := M) (Fin.cons x env) α).mpr hx⟩⟩

/-! ## Temporal dualization -/

/-- **`swapUS`** — exchange `U` and `S` throughout a temporal formula.

`.box φ` is left **opaque**, which is required rather than optional: `TemporalTruth` reads a
box-subformula through `atomMap (.box φ)` as an atom of the signature, so recursing into it
would change which atom is being read. -/
def swapUS : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (swapUS φ) (swapUS ψ)
  | .box φ => .box φ
  | .untl φ ψ => .snce (swapUS φ) (swapUS ψ)
  | .snce φ ψ => .untl (swapUS φ) (swapUS ψ)

/-- `swapUS` is an involution. -/
theorem swapUS_involutive : ∀ A : Formula, swapUS (swapUS A) = A
  | .atom _ => rfl
  | .bot => rfl
  | .imp φ ψ => by rw [swapUS, swapUS, swapUS_involutive φ, swapUS_involutive ψ]
  | .box _ => rfl
  | .untl φ ψ => by rw [swapUS, swapUS, swapUS_involutive φ, swapUS_involutive ψ]
  | .snce φ ψ => by rw [swapUS, swapUS, swapUS_involutive φ, swapUS_involutive ψ]

/-- **The `TemporalTruth` transport.** Truth of `A` in the dual is truth of `swapUS A` in the
original, at the same point. -/
theorem temporalTruth_dual {M : OrderedMonadicStructure sig} (atomMap : Formula → sig.preds)
    (t : M.carrier) (A : Formula) :
    TemporalTruth (dual M) atomMap (d t) A ↔ TemporalTruth M atomMap t (swapUS A) := by
  induction A generalizing t with
  | atom _ => exact Iff.rfl
  | bot => exact Iff.rfl
  | box _ => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact imp_congr (ihφ t) (ihψ t)
  | untl φ ψ ihφ ihψ =>
      constructor
      · rintro ⟨s, hts, hφ, hψ⟩
        exact ⟨s, hts, (ihφ s).mp hφ, fun r h₁ h₂ => (ihψ r).mp (hψ r h₂ h₁)⟩
      · rintro ⟨s, hst, hφ, hψ⟩
        exact ⟨d s, hst, (ihφ s).mpr hφ, fun r h₁ h₂ => (ihψ r).mpr (hψ r h₂ h₁)⟩
  | snce φ ψ ihφ ihψ =>
      constructor
      · rintro ⟨s, hst, hφ, hψ⟩
        exact ⟨s, hst, (ihφ s).mp hφ, fun r h₁ h₂ => (ihψ r).mp (hψ r h₂ h₁)⟩
      · rintro ⟨s, hts, hφ, hψ⟩
        exact ⟨d s, hts, (ihφ s).mpr hφ, fun r h₁ h₂ => (ihψ r).mpr (hψ r h₂ h₁)⟩

/-! ## The Prior hypotheses

`SemanticPriorU` and `SemanticPriorS` (`PriorDefsDense.lean:119`, `:138`) are exact mirrors of
one another and are both quantified over **all** formulas `p`, which is what makes the exchange
go through: a Prior-S instance at `swapUS p` is a Prior-U instance at `p` in the dual. -/

/-- **Prior-S transports to Prior-U across the dual.** -/
theorem semanticPriorU_dual {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : SemanticPriorS M atomMap) : SemanticPriorU (dual M) atomMap := by
  intro t p hstretch hfail
  obtain ⟨s, hst, hbelow, hcase⟩ := h t (swapUS p)
    (by
      obtain ⟨s, hts, hall⟩ := hstretch
      exact ⟨s, hts, fun r h₁ h₂ => (temporalTruth_dual (M := M) atomMap r p).mp (hall r h₂ h₁)⟩)
    (by
      obtain ⟨u, htu, hnu⟩ := hfail
      exact ⟨u, htu, fun h' => hnu ((temporalTruth_dual (M := M) atomMap u p).mpr h')⟩)
  refine ⟨s, hst, fun r h₁ h₂ => (temporalTruth_dual (M := M) atomMap r p).mpr (hbelow r h₂ h₁), ?_⟩
  rcases hcase with hns | ⟨hs, hk⟩
  · exact Or.inl fun h' => hns ((temporalTruth_dual (M := M) atomMap s p).mp h')
  · refine Or.inr ⟨(temporalTruth_dual (M := M) atomMap s p).mpr hs, fun u hsu => ?_⟩
    obtain ⟨r, h₁, h₂, hnr⟩ := hk u hsu
    exact ⟨r, h₂, h₁, fun h' => hnr ((temporalTruth_dual (M := M) atomMap r p).mp h')⟩

/-- **Prior-U transports to Prior-S across the dual** — the exact mirror of
`semanticPriorU_dual`. -/
theorem semanticPriorS_dual {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : SemanticPriorU M atomMap) : SemanticPriorS (dual M) atomMap := by
  intro t p hstretch hfail
  obtain ⟨s, hts, hbelow, hcase⟩ := h t (swapUS p)
    (by
      obtain ⟨s, hst, hall⟩ := hstretch
      exact ⟨s, hst, fun r h₁ h₂ => (temporalTruth_dual (M := M) atomMap r p).mp (hall r h₂ h₁)⟩)
    (by
      obtain ⟨u, hut, hnu⟩ := hfail
      exact ⟨u, hut, fun h' => hnu ((temporalTruth_dual (M := M) atomMap u p).mpr h')⟩)
  refine ⟨s, hts, fun r h₁ h₂ => (temporalTruth_dual (M := M) atomMap r p).mpr (hbelow r h₂ h₁), ?_⟩
  rcases hcase with hns | ⟨hs, hk⟩
  · exact Or.inl fun h' => hns ((temporalTruth_dual (M := M) atomMap s p).mp h')
  · refine Or.inr ⟨(temporalTruth_dual (M := M) atomMap s p).mpr hs, fun u hus => ?_⟩
    obtain ⟨r, h₁, h₂, hnr⟩ := hk u hus
    exact ⟨r, h₂, h₁, fun h' => hnr ((temporalTruth_dual (M := M) atomMap r p).mp h')⟩

/-! ## `∼` and the gap predicates -/

/-- **`∼` is the same relation on the dual.** `ε` is a two-variable formula and `dualize` only
flips order comparisons, so the relation it defines is unchanged. -/
theorem contempEquivDense_dual {M : OrderedMonadicStructure sig} (ε : MonadicFormula sig 2)
    (a b : M.carrier) :
    ContempEquivDense (dual M) (dualize ε) (d a) (d b) ↔ ContempEquivDense M ε a b := by
  have h := eval_dualize (M := M) ![a, b] ε
  have he : (d ∘ ![a, b] : Fin 2 → (dual M).carrier) = ![d a, d b] := by
    funext k; fin_cases k <;> rfl
  rw [he] at h
  exact h

/-- **The gap predicates exchange across the dual.**

*"`x`'s `∼`-class ends in a gap on the right"* in `dual M` is *"`x`'s `∼`-class ends in a gap on
the left"* in `M`. The first two conjuncts transport clause by clause; in the third the two inner
implications arrive in the opposite order, which is what the closing `fun h h₁ h₂ => h h₂ h₁`
pair repairs. -/
theorem endsInGapOnRight_dual {M : OrderedMonadicStructure sig} (ε : MonadicFormula sig 2)
    (t : M.carrier) :
    EndsInGapOnRight (dual M) (dualize ε) (d t) ↔ EndsInGapOnLeft M ε t := by
  refine and_congr ?_ (and_congr ?_ ?_)
  · exact exists_congr fun y => and_congr Iff.rfl (not_congr (contempEquivDense_dual ε t y))
  · refine not_congr (exists_congr fun z => and_congr (contempEquivDense_dual ε t z) ?_)
    exact forall_congr' fun y => imp_congr Iff.rfl (not_congr (contempEquivDense_dual ε t y))
  · refine not_congr (exists_congr fun z => ?_)
    refine and_congr Iff.rfl (and_congr (not_congr (contempEquivDense_dual ε t z)) ?_)
    refine forall_congr' fun y => ⟨fun h h₁ h₂ => ?_, fun h h₁ h₂ => ?_⟩
    · exact (contempEquivDense_dual ε t y).mp (h h₂ h₁)
    · exact (contempEquivDense_dual ε t y).mpr (h h₂ h₁)

/-- **The mirror of `endsInGapOnRight_dual`.** -/
theorem endsInGapOnLeft_dual {M : OrderedMonadicStructure sig} (ε : MonadicFormula sig 2)
    (t : M.carrier) :
    EndsInGapOnLeft (dual M) (dualize ε) (d t) ↔ EndsInGapOnRight M ε t := by
  refine and_congr ?_ (and_congr ?_ ?_)
  · exact exists_congr fun y => and_congr Iff.rfl (not_congr (contempEquivDense_dual ε t y))
  · refine not_congr (exists_congr fun z => and_congr (contempEquivDense_dual ε t z) ?_)
    exact forall_congr' fun y => imp_congr Iff.rfl (not_congr (contempEquivDense_dual ε t y))
  · refine not_congr (exists_congr fun z => ?_)
    refine and_congr Iff.rfl (and_congr (not_congr (contempEquivDense_dual ε t z)) ?_)
    refine forall_congr' fun y => ⟨fun h h₁ h₂ => ?_, fun h h₁ h₂ => ?_⟩
    · exact (contempEquivDense_dual ε t y).mp (h h₂ h₁)
    · exact (contempEquivDense_dual ε t y).mpr (h h₂ h₁)

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
