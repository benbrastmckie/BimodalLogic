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

- `succIndicatorAt` — `⊢[fc] X ⊤` at every `fc` with `FrameClass.Discrete ≤ fc`, from
  `Axiom.serial_future` + `Axiom.prior_UZ` + guard monotonicity. No new axiom.
- `succIndicator` — `⊢[Discrete] X ⊤`, the `le_rfl` instantiation of `succIndicatorAt`.
- `unfoldForward` / `unfoldBackward` — the `X (g ∧ U(e,g))` shape.
- `nextConj` — `{fc}`-polymorphic: `X A ∧ X B → X (A ∧ B)`, the functionality of the successor.
- `unfoldTableForward` / `unfoldTableBackward` — the `X g ∧ X U(e,g)` shape.
- `noBlockingTriple` — the schema does real work: at `Discrete` a world holding `U(p,q)` while
  omitting both `U(p,r)` and `U(q,s)` is derivably impossible.
- `nextAllFuture` / `prevAllPast` — `X (Gφ ∧ φ) → Gφ` and its free past dual
  `Y (Hφ ∧ φ) → Hφ`, obtained through `DerivationTree.temporal_duality`.
- `dfSchema` — the paper's **DF** schema `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`, consumed by
  `FormalSystem.BaseLanguage.AxiomDischarge` for the `Discrete` row of the backward
  conservativity bridge. Derived syntactically; no completeness dependency.

## Why `FrameClass.Discrete` is essential here

Every declaration below except `nextConj` and `succIndicatorAt` is stated at
`FrameClass.Discrete` rather than at a free `{fc}`, and the pin is not gratuitous.
`succIndicator` derives `U(⊤,⊥)`, which is *refuted* at `FrameClass.Dense` by
`Axiom.dense_indicator`; a `{fc}`-uniform version — one taking no hypothesis relating `fc` to
`FrameClass.Discrete` — would therefore make the dense system inconsistent. `succIndicatorAt` is
not that version: it carries the guard `h : FrameClass.Discrete ≤ fc`, which `FrameClass.Dense`
does not satisfy, so generalizing along `h` preserves the argument rather than defeating it. `unfoldForward`, `unfoldTableForward` and
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

/-- **`⊢[fc] U(⊤, ⊥)` at every `fc` above `FrameClass.Discrete`.**

The `{fc}`-*guarded* form of `succIndicator`. The guard `h : FrameClass.Discrete ≤ fc` is what
makes the generalization safe: `Axiom.prior_UZ` is admissible only from `Discrete` upwards, and a
guard-free `{fc}`-uniform version would derive `U(⊤,⊥)` at `FrameClass.Dense`, where
`Axiom.dense_indicator` refutes it — see "Why `FrameClass.Discrete` is essential here" above.

Only two of the three steps change relative to `succIndicator`: `Axiom.serial_future` sits at
`FrameClass.Base` and lifts by `FrameClass.base_le`, `Axiom.prior_UZ` lifts by `h`, and the
closing `guardMono` step is already `{fc}`-polymorphic. -/
def succIndicatorAt {fc : FrameClass} (h : FrameClass.Discrete ≤ fc) :
    ⊢[fc] Formula.next Formula.top := by
  have h1 : ⊢[fc] Formula.someFuture Formula.top :=
    DerivationTree.modus_ponens _ Formula.top _
      (DerivationTree.axiom _ _ Axiom.serial_future (FrameClass.base_le fc)) topThm
  have h2 : ⊢[fc] Formula.untl Formula.top.neg Formula.top :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.prior_UZ Formula.top) h) h1
  exact guardMono [] Formula.top Formula.top.neg Formula.bot topNegImpBot h2

/-- **`⊢[Discrete] U(⊤, ⊥)`.**

The `le_rfl` instantiation of `succIndicatorAt`; the proof lives there and is not duplicated
here. Kept as a declaration in its own right because every consumer below, and every consumer
outside this file, works at `FrameClass.Discrete` itself. -/
def succIndicator : ⊢[FrameClass.Discrete] Formula.next Formula.top := succIndicatorAt le_rfl

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

/-! ## Result 4: the paper's **DF** schema at `FrameClass.Discrete`

```
(Hφ ∧ φ ∧ F⊤)  →  F (Hφ)
```

`DF` is the axiom distinguishing the paper's `TM_f` from `TM`
(JPL paper, `\S sub:Extension`). It is the one TM-side schema with no ready-made counterpart in
this tree, and `FormalSystem.BaseLanguage.AxiomDischarge` consumes `dfSchema` to close the
`Discrete` row of the backward conservativity bridge.

The derivation is **syntactic** and uses only `succIndicator`, `unfoldForward`, `nextConj`,
`Axiom.enrichment_until`, `Axiom.until_F` and propositional plumbing. In particular it does
**not** route through any completeness theorem: a proof-theoretic bridge must not depend on the
completeness machinery it is meant to feed, so `#print axioms dfSchema` mentioning a
`completeness_*` result would be a defect, not an optimisation.

Semantically the schema holds because at the immediate successor `s` of `t` every time `< s` is
`≤ t`; the three syntactic steps below are exactly that argument.
-/

/-- `⊢[fc] (A ∧ B) → ⊥`, given `A → C` and `B → ¬C`.

A three-line composition of `andFst`/`andSnd`/`ctxMp` from `Theorems/Propositional/Core.lean`,
not a re-derivation of anything: it is the shape in which `eventMono` wants a refutable event. -/
private def clashBot {fc : FrameClass} (A B C : Formula)
    (hA : ⊢[fc] A.imp C) (hB : ⊢[fc] B.imp C.neg) :
    ⊢[fc] (Formula.and A B).imp Formula.bot := by
  refine deductionTheorem [] (Formula.and A B) Formula.bot ?_
  have h := DerivationTree.assumption (fc := fc) [Formula.and A B] (Formula.and A B) (by simp)
  have hc : [Formula.and A B] ⊢[fc] C := ctxMp (wk _ _ hA) (andFst h)
  have hnc : [Formula.and A B] ⊢[fc] C.neg := ctxMp (wk _ _ hB) (andSnd h)
  exact ctxMp hnc hc

/-- **Step 3, future form**: `⊢[Discrete] X (Gφ ∧ φ) → Gφ`.

If the immediate successor carries both `Gφ` and `φ`, then `Gφ` already holds now: every
`u > t` is either the successor `s` itself (where `φ` holds) or lies beyond it (where `Gφ`
covers it), and nothing lies strictly between `t` and `s`.

Engine: assume `F¬φ`, unfold it one step with `unfoldForward` at guard `⊤`, and in each
disjunct pair the resulting `X`-formula with the hypothesis `X (Gφ ∧ φ)` through `nextConj`.
Both merged events are refutable — `¬φ ∧ φ` in the first, `F¬φ ∧ ¬F¬φ` in the second — so
`eventMono` drives them to `U(⊥,⊥)` and `untlBotFalse` closes. -/
def nextAllFuture (φ : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.next (Formula.and φ.allFuture φ)).imp φ.allFuture := by
  set B0 := Formula.and φ.allFuture φ with hB0
  set Γ : Context := [Formula.next B0] with hΓ
  refine deductionTheorem [] (Formula.next B0) φ.allFuture ?_
  refine deductionTheorem Γ (Formula.someFuture φ.neg) Formula.bot ?_
  set Γ' : Context := Formula.someFuture φ.neg :: Γ with hΓ'
  have hF : Γ' ⊢[FrameClass.Discrete] Formula.someFuture φ.neg :=
    DerivationTree.assumption _ _ (by simp [hΓ'])
  have hXB : Γ' ⊢[FrameClass.Discrete] Formula.next B0 :=
    DerivationTree.assumption _ _ (by simp [hΓ', hΓ])
  have h1 : Γ' ⊢[FrameClass.Discrete]
      (Formula.next φ.neg).or
        (Formula.next (Formula.and Formula.top (Formula.untl Formula.top φ.neg))) :=
    ctxMp (wk _ _ (unfoldForward φ.neg Formula.top)) hF
  refine orElim Γ' (Formula.next φ.neg)
    (Formula.next (Formula.and Formula.top (Formula.untl Formula.top φ.neg)))
    Formula.bot h1 ?_ ?_
  · -- Disjunct 1: `X ¬φ` merged with `X (Gφ ∧ φ)` gives the event `¬φ ∧ (Gφ ∧ φ)`.
    refine deductionTheorem Γ' (Formula.next φ.neg) Formula.bot ?_
    have a1 : (Formula.next φ.neg :: Γ') ⊢[FrameClass.Discrete] Formula.next φ.neg :=
      DerivationTree.assumption _ _ (by simp)
    have a2 : (Formula.next φ.neg :: Γ') ⊢[FrameClass.Discrete] Formula.next B0 :=
      DerivationTree.weakening _ _ _ hXB (by intro x hx; simp [hx])
    have a3 := ctxMp (wk _ _ (nextConj φ.neg B0)) (andIntro a1 a2)
    have a4 := eventMono _ (Formula.and φ.neg B0) Formula.bot Formula.bot
      (clashBot φ.neg B0 φ.neg (identity φ.neg)
        (impTrans (rceImp φ.allFuture φ) (notNotIntro φ))) a3
    exact ctxMp (wk _ _ (untlBotFalse Formula.bot)) a4
  · -- Disjunct 2: `X (⊤ ∧ F¬φ)` merged with `X (Gφ ∧ φ)` gives the event `F¬φ ∧ ¬F¬φ`.
    refine deductionTheorem Γ'
      (Formula.next (Formula.and Formula.top (Formula.untl Formula.top φ.neg))) Formula.bot ?_
    set E := Formula.and Formula.top (Formula.untl Formula.top φ.neg) with hE
    have a1 : (Formula.next E :: Γ') ⊢[FrameClass.Discrete] Formula.next E :=
      DerivationTree.assumption _ _ (by simp)
    have a2 : (Formula.next E :: Γ') ⊢[FrameClass.Discrete] Formula.next B0 :=
      DerivationTree.weakening _ _ _ hXB (by intro x hx; simp [hx])
    have a3 := ctxMp (wk _ _ (nextConj E B0)) (andIntro a1 a2)
    have a4 := eventMono _ (Formula.and E B0) Formula.bot Formula.bot
      (clashBot E B0 (Formula.someFuture φ.neg)
        (rceImp Formula.top (Formula.untl Formula.top φ.neg))
        (lceImp φ.allFuture φ)) a3
    exact ctxMp (wk _ _ (untlBotFalse Formula.bot)) a4

/-- The `swapTemporal` image of `nextAllFuture`'s statement, computed once so that
`prevAllPast` is a `▸`-rewrite rather than a `simp` inside a term. -/
theorem swap_next_all_future_eq (φ : Formula) :
    Formula.swapTemporal
      ((Formula.next (Formula.and (φ.swapTemporal).allFuture φ.swapTemporal)).imp
        (φ.swapTemporal).allFuture)
      = (Formula.prev (Formula.and φ.allPast φ)).imp φ.allPast := by
  simp only [Formula.next, Formula.prev, Formula.and, Formula.neg, Formula.swapTemporal,
    Formula.swap_temporal_all_future, Formula.swap_temporal_involution]

/-- **Step 3, past form**: `⊢[Discrete] Y (Hφ ∧ φ) → Hφ`.

The past dual of `nextAllFuture`, and it is *free*: `DerivationTree.temporal_duality` is a
primitive rule at every frame class, so applying it to `nextAllFuture (swapTemporal φ)` and
using `Formula.swap_temporal_involution` returns exactly this statement. No past-mirrored axiom
is introduced. -/
def prevAllPast (φ : Formula) :
    ⊢[FrameClass.Discrete]
      (Formula.prev (Formula.and φ.allPast φ)).imp φ.allPast :=
  swap_next_all_future_eq φ ▸ DerivationTree.temporal_duality _ (nextAllFuture φ.swapTemporal)

/-- **`⊢[Discrete] (Hφ ∧ φ ∧ F⊤) → F(Hφ)`** — the paper's **DF** schema.

Three steps, in the order of the module note above:

1. `succIndicator` supplies `X ⊤`, the discreteness witness.
2. `Axiom.enrichment_until` at guard `⊥`, event `⊤`, and payload `p := Hφ ∧ φ` turns
   `(Hφ ∧ φ) ∧ X⊤` into `X (⊤ ∧ Y (Hφ ∧ φ))` — the payload is transported to the successor as
   a `Y`-formula because the successor's `snce`-guard interval is empty.
3. `prevAllPast` converts `Y (Hφ ∧ φ)` into `Hφ` at the successor, and `Axiom.until_F` at
   guard `⊥` weakens `X (Hφ)` to `F (Hφ)`.

The `F⊤` conjunct of the antecedent is not consumed: at `FrameClass.Discrete` the stronger
`X ⊤` is already a theorem. It is retained because the schema, not the derivation, is what the
translation of `BaseLanguage.Axiom.df` must match.

Association is pinned to `((Hφ ∧ φ) ∧ F⊤) → F(Hφ)` so that
`FormalSystem.BaseLanguage.AxiomDischarge` can use it without reassociating. -/
def dfSchema (φ : Formula) :
    ⊢[FrameClass.Discrete]
      ((φ.allPast.and φ).and Formula.top.someFuture).imp (φ.allPast.someFuture) := by
  set A := Formula.and φ.allPast φ with hA
  set ant := Formula.and A (Formula.someFuture Formula.top) with hant
  set Γ : Context := [ant] with hΓ
  refine deductionTheorem [] ant (φ.allPast.someFuture) ?_
  have h0 : Γ ⊢[FrameClass.Discrete] ant := DerivationTree.assumption _ _ (by simp [hΓ])
  have hA' : Γ ⊢[FrameClass.Discrete] A := andFst h0
  have hX : Γ ⊢[FrameClass.Discrete] Formula.untl Formula.bot Formula.top :=
    wk _ _ succIndicator
  have h2 : Γ ⊢[FrameClass.Discrete]
      Formula.untl Formula.bot (Formula.and Formula.top (Formula.snce Formula.bot A)) :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.enrichment_until Formula.bot Formula.top A)
      (FrameClass.base_le _)) (andIntro hA' hX)
  have h3 : Γ ⊢[FrameClass.Discrete] Formula.untl Formula.bot φ.allPast :=
    eventMono _ (Formula.and Formula.top (Formula.snce Formula.bot A)) φ.allPast Formula.bot
      (impTrans (rceImp Formula.top (Formula.snce Formula.bot A)) (prevAllPast φ)) h2
  exact ctxMp (DerivationTree.axiom _ _ (Axiom.until_F Formula.bot φ.allPast)
    (FrameClass.base_le _)) h3

end -- noncomputable section

end FormalSystem.Theorems.DiscreteUnfolding
