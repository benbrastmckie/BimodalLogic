/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Core

/-!
# The Z-Exact One-Step Unfolding of `untl` at `FrameClass.Discrete`

The Hilbert-side counterpart of the discrete one-step unfolding

```
U(e, g)   ↔   X e  ∨  X (g ∧ U(e, g))
```

(and its table-shaped variant `U(e, g) ↔ X e ∨ (X g ∧ X U(e, g))`), where
`X ψ = Formula.next ψ = Formula.untl ⊥ ψ`.

The forward halves hold at `FrameClass.Discrete` and nowhere weaker: they consume
`succIndicator`, the discreteness indicator `U(⊤, ⊥)` ("the current point has an immediate
successor"), whose *negation* is `Axiom.dense_indicator`. The backward halves and `nextConj`
are already derivable at `FrameClass.Base`, and `nextConj` is stated `{fc}`-polymorphically.

## Main results

- `succIndicator` — `⊢[Discrete] X ⊤`, from `Axiom.serial_future` + `Axiom.prior_UZ` + guard
  monotonicity. No new axiom.
- `unfoldForward` / `unfoldBackward` — the `X (g ∧ U(e,g))` shape.
- `nextConj` — `{fc}`-polymorphic: `X A ∧ X B → X (A ∧ B)`, the functionality of the successor.
- `unfoldTableForward` / `unfoldTableBackward` — the `X g ∧ X U(e,g)` shape.
- `noBlockingTriple` — the schema does real work: at `Discrete` a world holding `U(p,q)` while
  omitting both `U(p,r)` and `U(q,s)` is derivably impossible.

## Why `FrameClass.Discrete` is essential here

Every declaration below except `nextConj` is stated at `FrameClass.Discrete` rather than at a
free `{fc}`, and the pin is not gratuitous. `succIndicator` derives `U(⊤,⊥)`, which is
*refuted* at `FrameClass.Dense` by `Axiom.dense_indicator`; a `{fc}`-uniform version would
therefore make the dense system inconsistent. `unfoldForward`, `unfoldTableForward` and
`noBlockingTriple` all consume `succIndicator`. `unfoldBackward` and `unfoldTableBackward` are
stated at `FrameClass.Base` because that is the *weakest* class at which they hold; they lift to
any `fc` through `Combinators.baseThm`.

`FormalSystem.Metalogic.not_derivable_nil_bot_discrete` (`Metalogic/Soundness.lean`) is what
makes these results non-vacuous: the `Discrete` system is consistent, so `⊢[Discrete]` is not
the trivial predicate.

## Argument order

`Formula.untl` is **guard-first / event-second** (`Syntax/Formula.lean`;
`specs/decisions/untl-snce-argument-order.md`, DECIDED 2026-08-17): `Formula.untl g e` reads
"the guard `g` holds throughout the open interval `(t, s)` and the event `e` is witnessed at
`s > t`". The pretty-printer's prefix rendering `U(e, g)` is event-first and is what the prose
above uses. The two renderings legitimately coexist; the constructor order below is the
guard-first one and must not be "fixed" to match the rendering.

The helper parameter orders inherited from `Combinators.guardMono` (`(event, guard, guard')`)
and `Combinators.eventMono` (`(event, event', guard)`) are a third, independent convention —
see those declarations' docstrings.
-/

namespace FormalSystem.Theorems.DiscreteUnfolding

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional

noncomputable section

/-! ## Result 1: the discreteness indicator is a theorem at `FrameClass.Discrete`

`U(⊤,⊥)` says "the current point has an immediate successor".  It is asserted by no axiom
of this tree (its *negation* is `Axiom.dense_indicator`, at `FrameClass.Dense`).  It is
nonetheless *derivable* at `FrameClass.Discrete`, from `Axiom.serial_future`,
`Axiom.prior_UZ` at `⊤`, and guard monotonicity. -/

/-- **`⊢[Discrete] U(⊤, ⊥)`.** -/
def succIndicator : ⊢[FrameClass.Discrete] Formula.next Formula.top := by
  have h1 : ⊢[FrameClass.Discrete] Formula.someFuture Formula.top :=
    DerivationTree.modus_ponens _ Formula.top _
      (DerivationTree.axiom _ _ Axiom.serial_future (by decide)) topThm
  have h2 : ⊢[FrameClass.Discrete] Formula.untl Formula.top.neg Formula.top :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.prior_UZ Formula.top) (by decide)) h1
  exact guardMono [] Formula.top Formula.top.neg Formula.bot topNegImpBot h2

/-! ## Result 2: the Z-exact one-step unfolding schema

```
U(e, g)   <->   X e  \/  X (g /\ U(e, g))
```

with `X ψ := U(ψ, ⊥)`.  Forward at `Discrete` (it needs `succIndicator`); backward already
at `Base`. -/

/-- Forward half of the unfolding.  Engine: `Axiom.self_accum_until` enriches the guard with
the eventuality itself, then `Axiom.linear_until` compares that `untl` against `U(⊤,⊥)`,
and the middle disjunct is killed by `untlBotFalse`. -/
def unfoldForward (e g : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl g e).imp
        ((Formula.next e).or (Formula.next (Formula.and g (Formula.untl g e)))) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set C := (Formula.next e).or (Formula.next G') with hC
  set Γ : Context := [Formula.untl g e] with hΓ
  refine deductionTheorem [] (Formula.untl g e) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] Formula.untl g e :=
    DerivationTree.assumption _ _ (by simp [hΓ])
  have h2 : Γ ⊢[FrameClass.Discrete] Formula.untl G' e :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.self_accum_until g e) (FrameClass.base_le _)) h1
  have h3 : Γ ⊢[FrameClass.Discrete] Formula.untl Formula.bot Formula.top :=
    wk _ _ succIndicator
  have h4 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl G' e).and (Formula.untl Formula.bot Formula.top) := andIntro h2 h3
  have h5 : Γ ⊢[FrameClass.Discrete]
      ((Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)).or
        (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot))).or
        (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)) :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.linear_until G' e Formula.bot Formula.top)
        (FrameClass.base_le _)) h4
  -- Disjunct 1: `U(e ∧ ⊤, G' ∧ ⊥)` collapses to `X e`.
  have d1 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top) :: Γ)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)) (by simp)
    have a2 := guardMono _ (Formula.and e Formula.top) (Formula.and G' Formula.bot)
      Formula.bot (rceImp G' Formula.bot) a1
    have a3 := eventMono _ (Formula.and e Formula.top) e Formula.bot
      (lceImp e Formula.top) a2
    exact orIntroL _ _ _ a3
  -- Disjunct 2: `U(e ∧ ⊥, _)` has a refutable event.
  have d2 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot) :: Γ)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)) (by simp)
    have a2 := eventMono _ (Formula.and e Formula.bot) Formula.bot
      (Formula.and G' Formula.bot) (rceImp e Formula.bot) a1
    have a3 : _ ⊢[FrameClass.Discrete] Formula.bot :=
      DerivationTree.modus_ponens _ _ _ (wk _ _ (untlBotFalse _)) a2
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (efqAxiom C)) a3
  -- Disjunct 3: `U(G' ∧ ⊤, G' ∧ ⊥)` collapses to `X G'`.
  have d3 : Γ ⊢[FrameClass.Discrete]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top) :: Γ)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)) (by simp)
    have a2 := guardMono _ (Formula.and G' Formula.top) (Formula.and G' Formula.bot)
      Formula.bot (rceImp G' Formula.bot) a1
    have a3 := eventMono _ (Formula.and G' Formula.top) G' Formula.bot
      (lceImp G' Formula.top) a2
    exact orIntroR _ _ _ a3
  refine orElim Γ _ _ C h5 ?_ d3
  exact deductionTheorem _ _ _ (orElim _ _ _ C (DerivationTree.assumption _ _ (by simp))
    (DerivationTree.weakening _ _ _ d1 (by intro x hx; simp [hx]))
    (DerivationTree.weakening _ _ _ d2 (by intro x hx; simp [hx])))

/-- Backward half of the unfolding — already derivable at `FrameClass.Base`.
Engine: guard weakening `⊥ → g`, then `Axiom.absorb_until`. -/
def unfoldBackward (e g : Formula) :
    ⊢[FrameClass.Base]
      ((Formula.next e).or (Formula.next (Formula.and g (Formula.untl g e)))).imp
        (Formula.untl g e) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set A := (Formula.next e).or (Formula.next G') with hA
  set Δ : Context := [A] with hΔ
  refine deductionTheorem [] A (Formula.untl g e) ?_
  refine orElim Δ (Formula.next e) (Formula.next G') (Formula.untl g e)
    (DerivationTree.assumption Δ A (by simp [hΔ])) ?_ ?_
  · refine deductionTheorem Δ (Formula.next e) (Formula.untl g e) ?_
    exact guardMono (Formula.next e :: Δ) e Formula.bot g (efqAxiom g)
      (DerivationTree.assumption (Formula.next e :: Δ) (Formula.next e) (by simp))
  · refine deductionTheorem Δ (Formula.next G') (Formula.untl g e) ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Base) (Formula.next G' :: Δ)
      (Formula.next G') (by simp)
    have a2 := guardMono (Formula.next G' :: Δ) G' Formula.bot g (efqAxiom g) a1
    exact DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.absorb_until g e) (FrameClass.base_le _)) a2

/-! ### `X` distributes over conjunction (Base)

Needed to move between the schema's `X (g ∧ U(e,g))` and handoff §4.4's table shape
`g ∈ u ∧ U(e,g) ∈ u`.  The `←` direction is event monotonicity; the `→` direction below is
the functionality of the successor, and it is derivable at `Base` from `Axiom.linear_until`. -/
def nextConj {fc : FrameClass} (A B : Formula) :
    ⊢[fc] ((Formula.next A).and (Formula.next B)).imp (Formula.next (Formula.and A B)) := by
  set T := Formula.next (Formula.and A B) with hT
  set D := (Formula.next A).and (Formula.next B) with hD
  set Γ : Context := [D] with hΓ
  set W := Formula.and Formula.bot Formula.bot with hW
  set E1 := Formula.untl W (Formula.and A B) with hE1
  set E2 := Formula.untl W (Formula.and A Formula.bot) with hE2
  set E3 := Formula.untl W (Formula.and Formula.bot B) with hE3
  refine deductionTheorem [] D T ?_
  have h4 : Γ ⊢[fc] D := DerivationTree.assumption Γ D (by simp [hΓ])
  have h5 : Γ ⊢[fc] (E1.or E2).or E3 :=
    DerivationTree.modus_ponens Γ _ _
      (DerivationTree.axiom Γ _ (Axiom.linear_until Formula.bot A Formula.bot B)
        (FrameClass.base_le _)) h4
  have kill : ∀ (Δ : Context) (E : Formula), (⊢[fc] E.imp Formula.bot) →
      (Δ ⊢[fc] (Formula.untl W E).imp T) := by
    intro Δ E hE
    refine deductionTheorem Δ (Formula.untl W E) T ?_
    have a1 := DerivationTree.assumption (fc := fc) (Formula.untl W E :: Δ)
      (Formula.untl W E) (by simp)
    have a2 := eventMono (Formula.untl W E :: Δ) E Formula.bot W hE a1
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (efqAxiom T))
      (DerivationTree.modus_ponens _ _ _ (wk _ _ (untlBotFalse _)) a2)
  have keep : ∀ Δ : Context, Δ ⊢[fc] E1.imp T := by
    intro Δ
    refine deductionTheorem Δ E1 T ?_
    exact guardMono (E1 :: Δ) (Formula.and A B) W Formula.bot
      (rceImp Formula.bot Formula.bot)
      (DerivationTree.assumption (E1 :: Δ) E1 (by simp))
  refine orElim Γ (E1.or E2) E3 T h5 ?_ (kill Γ _ (lceImp Formula.bot B))
  refine deductionTheorem Γ (E1.or E2) T ?_
  exact orElim (E1.or E2 :: Γ) E1 E2 T
    (DerivationTree.assumption (E1.or E2 :: Γ) (E1.or E2) (by simp))
    (keep _) (kill _ _ (rceImp A Formula.bot))

/-! ### The unfolding in handoff §4.4's table shape

```
U(e, g)   <->   X e  \/  ( X g  /\  X U(e, g) )
```
-/

/-- Table shape, forward. -/
def unfoldTableForward (e g : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl g e).imp
        ((Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e)))) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set C := (Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e))) with hC
  set Γ : Context := [Formula.untl g e] with hΓ
  refine deductionTheorem [] (Formula.untl g e) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] (Formula.next e).or (Formula.next G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward e g))
      (DerivationTree.assumption Γ (Formula.untl g e) (by simp [hΓ]))
  refine orElim Γ (Formula.next e) (Formula.next G') C h1 ?_ ?_
  · refine deductionTheorem Γ (Formula.next e) C ?_
    exact orIntroL _ _ _ (DerivationTree.assumption _ _ (by simp))
  · refine deductionTheorem Γ (Formula.next G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete) (Formula.next G' :: Γ)
      (Formula.next G') (by simp)
    have a2 := eventMono (Formula.next G' :: Γ) G' g Formula.bot (lceImp g (Formula.untl g e)) a1
    have a3 := eventMono (Formula.next G' :: Γ) G' (Formula.untl g e) Formula.bot
      (rceImp g (Formula.untl g e)) a1
    exact orIntroR _ _ _ (andIntro a2 a3)

/-- Table shape, backward (still `Base`). -/
def unfoldTableBackward (e g : Formula) :
    ⊢[FrameClass.Base]
      ((Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e)))).imp
        (Formula.untl g e) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set A := (Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e))) with hA
  set Δ : Context := [A] with hΔ
  refine deductionTheorem [] A (Formula.untl g e) ?_
  refine orElim Δ (Formula.next e) ((Formula.next g).and (Formula.next (Formula.untl g e)))
    (Formula.untl g e)
    (DerivationTree.assumption Δ A (by simp [hΔ])) ?_ ?_
  · refine deductionTheorem Δ (Formula.next e) (Formula.untl g e) ?_
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (unfoldBackward e g))
      (orIntroL _ _ _ (DerivationTree.assumption _ _ (by simp)))
  · refine deductionTheorem Δ ((Formula.next g).and (Formula.next (Formula.untl g e)))
      (Formula.untl g e) ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Base)
      ((Formula.next g).and (Formula.next (Formula.untl g e)) :: Δ)
      ((Formula.next g).and (Formula.next (Formula.untl g e))) (by simp)
    have a2 := DerivationTree.modus_ponens _ _ _
      (wk _ _ (nextConj g (Formula.untl g e))) a1
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (unfoldBackward e g))
      (orIntroR _ _ _ a2)

/-! ### The schema does real work: no over-determined successor at `Discrete`

The pattern that would block a Lindenbaum-style construction of `filteredStep_fwd` is a world
`w` holding `U(p,q)` while omitting both `U(p,r)` and `U(q,s)`: the first demands that the
successor carry `p` or carry `q` together with `U(p,q)`, and the other two forbid exactly those.
At `FrameClass.Discrete` that pattern is *derivably* inconsistent, so no such `w` exists.  At
`FrameClass.Base` — where the closure MCS layer actually lives — this derivation is unavailable,
because `unfoldForward` is. -/
def noBlockingTriple (p q r s : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.untl q p).imp ((Formula.untl r p).or (Formula.untl s q)) := by
  set C := (Formula.untl r p).or (Formula.untl s q) with hC
  set Γ : Context := [Formula.untl q p] with hΓ
  set G' := Formula.and q (Formula.untl q p) with hG'
  refine deductionTheorem [] (Formula.untl q p) C ?_
  have h1 : Γ ⊢[FrameClass.Discrete] (Formula.next p).or (Formula.next G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward p q))
      (DerivationTree.assumption Γ (Formula.untl q p) (by simp [hΓ]))
  refine orElim Γ (Formula.next p) (Formula.next G') C h1 ?_ ?_
  · refine deductionTheorem Γ (Formula.next p) C ?_
    exact orIntroL _ _ _
      (guardMono (Formula.next p :: Γ) p Formula.bot r (efqAxiom r)
        (DerivationTree.assumption (Formula.next p :: Γ) (Formula.next p) (by simp)))
  · refine deductionTheorem Γ (Formula.next G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.Discrete) (Formula.next G' :: Γ)
      (Formula.next G') (by simp)
    have a2 := eventMono (Formula.next G' :: Γ) G' q Formula.bot (lceImp q (Formula.untl q p)) a1
    exact orIntroR _ _ _ (guardMono (Formula.next G' :: Γ) q Formula.bot s (efqAxiom s) a2)
end -- noncomputable section

end FormalSystem.Theorems.DiscreteUnfolding
