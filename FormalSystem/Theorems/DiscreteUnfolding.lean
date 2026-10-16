/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Theorems.DeductionTheorem
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.TemporalDerived

/-!
# The Z-Exact One-Step Unfolding of `untl` at `FrameClass.ZTime`

The Hilbert-side counterpart of the discrete one-step unfolding

```
U(e, g)   ↔   X e  ∨  X (g ∧ U(e, g))
```

(and its table-shaped variant `U(e, g) ↔ X e ∨ (X g ∧ X U(e, g))`), where
`X ψ = Formula.next ψ = Formula.untl ⊥ ψ`.

The forward halves hold at `FrameClass.ZTime` and nowhere weaker: they consume
`succIndicator`, the discreteness indicator `U(⊤, ⊥)` ("the current point has an immediate
successor"), whose *negation* is `Axiom.dense_indicator`. The backward halves and `nextConj`
are already derivable at `FrameClass.Base`, and `nextConj` is stated `{fc}`-polymorphically.

## Main results

- `succIndicatorAt` — `⊢[fc] X ⊤` at every `fc` with `FrameClass.ZTime ≤ fc`, from
  `Axiom.serial_future` + `Axiom.prior_UZ` + guard monotonicity. No new axiom.
- `succIndicator` — `⊢[Discrete] X ⊤`, the `le_rfl` instantiation of `succIndicatorAt`.
- `prevIndicatorAt` / `prevIndicator` — `⊢[fc] Y ⊤` and its `le_rfl` instantiation, the free
  past mirrors of the pair above.
- `unfoldForward` / `unfoldBackward` — the `X (g ∧ U(e,g))` shape.
- `unfoldBackwardSince` — the `snce` mirror of `unfoldForward`, `S(g,e) → Y e ∨ Y (g ∧ S(g,e))`.
- `nextConj` — `{fc}`-polymorphic: `X A ∧ X B → X (A ∧ B)`, the functionality of the successor.
- `prevConj` — its free past mirror, `Y A ∧ Y B → Y (A ∧ B)`.
- `unfoldTableForward` / `unfoldTableBackward` — the `X g ∧ X U(e,g)` shape.
- `noBlockingTriple` — the schema does real work: at `Discrete` a world holding `U(p,q)` while
  omitting both `U(p,r)` and `U(q,s)` is derivably impossible.
- `nextAllFuture` / `prevAllPast` — `X (Gφ ∧ φ) → Gφ` and its free past dual
  `Y (Hφ ∧ φ) → Hφ`, obtained through `DerivationTree.time_reflection`.
- `z1EventBot` / `z1Schema` / `z1SchemaAt` — the paper's **Z1** schema
  `G(Gφ → φ) → (F Gφ → Gφ)`, as a direct derivation tree from UZ and US, with its gated
  companion.
- `dfSchema` — the paper's **DF** schema `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`, consumed by
  `FormalSystem.MinusLanguage.AxiomDischarge` for the `Discrete` row of the backward
  conservativity bridge. Derived syntactically; no completeness dependency.

## The past mirrors

`prevIndicatorAt`, `prevIndicator`, `unfoldBackwardSince` and `prevConj` are all built by the
`prevAllPast` recipe: `DerivationTree.time_reflection` is a primitive rule at every frame class,
so each mirror is its primary applied to reflected arguments, normalized by a single
`reflect_time_*_eq` lemma proved by one `simp only`. None of them introduces a past-mirrored
axiom, and each stays at its primary's frame class for the reason that pins the primary.

## Why `FrameClass.ZTime` is essential here

Every declaration below except `nextConj` and `succIndicatorAt` is stated at
`FrameClass.ZTime` rather than at a free `{fc}`, and the pin is not gratuitous.
`succIndicator` derives `U(⊤,⊥)`, which is *refuted* at `FrameClass.Dense` by
`Axiom.dense_indicator`; a `{fc}`-uniform version — one taking no hypothesis relating `fc` to
`FrameClass.ZTime` — would therefore make the dense system inconsistent. `succIndicatorAt` is
not that version: it carries the guard `h : FrameClass.ZTime ≤ fc`, which `FrameClass.Dense`
does not satisfy, so generalizing along `h` preserves the argument rather than defeating it.
`unfoldForward`, `unfoldTableForward` and `noBlockingTriple` all consume `succIndicator`.
`unfoldBackward` and `unfoldTableBackward` are stated at `FrameClass.Base` because that is the
*weakest* class at which they hold; they lift to any `fc` through `Combinators.baseThm`.

`FormalSystem.Metalogic.not_derivable_nil_bot_ztime` (`Metalogic/Soundness.lean`) is what
makes these results non-vacuous: the `Discrete` system is consistent, so `⊢[Discrete]` is not
the trivial predicate.

## Argument order

`Formula.untl` is **guard-first / event-second** (`Syntax/Formula.lean`;
`docs/architecture/untl-snce-argument-order.md`, DECIDED 2026-08-17): `Formula.untl g e` reads
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

/-! ## Result 1: the discreteness indicator is a theorem at `FrameClass.ZTime`

`U(⊤,⊥)` says "the current point has an immediate successor".  It is asserted by no axiom
of this tree (its *negation* is `Axiom.dense_indicator`, at `FrameClass.Dense`).  It is
nonetheless *derivable* at `FrameClass.ZTime`, from `Axiom.serial_future`,
`Axiom.prior_UZ` at `⊤`, and guard monotonicity. -/

/-- **`⊢[fc] U(⊤, ⊥)` at every `fc` above `FrameClass.ZTime`.**

The `{fc}`-*guarded* form of `succIndicator`. The guard `h : FrameClass.ZTime ≤ fc` is what
makes the generalization safe: `Axiom.prior_UZ` is admissible only from `Discrete` upwards, and a
guard-free `{fc}`-uniform version would derive `U(⊤,⊥)` at `FrameClass.Dense`, where
`Axiom.dense_indicator` refutes it — see "Why `FrameClass.ZTime` is essential here" above.

Only two of the three steps change relative to `succIndicator`: `Axiom.serial_future` sits at
`FrameClass.Base` and lifts by `FrameClass.base_le`, `Axiom.prior_UZ` lifts by `h`, and the
closing `guardMono` step is already `{fc}`-polymorphic. -/
def succIndicatorAt {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) :
    ⊢[fc] Formula.next Formula.top := by
  have h1 : ⊢[fc] Formula.someFuture Formula.top :=
    DerivationTree.modus_ponens _ Formula.top _
      (DerivedAxioms.serialFutureImpAt _) topThm
  have h2 : ⊢[fc] Formula.untl Formula.top.neg Formula.top :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.prior_UZ Formula.top) h) h1
  exact guardMono [] Formula.top Formula.top.neg Formula.bot topNegImpBot h2

/-- **`⊢[Discrete] U(⊤, ⊥)`.**

The `le_rfl` instantiation of `succIndicatorAt`; the proof lives there and is not duplicated
here. Kept as a declaration in its own right because every consumer below, and every consumer
outside this file, works at `FrameClass.ZTime` itself.

Paper: `sub:Extension`
-/
def succIndicator : ⊢[FrameClass.ZTime] Formula.next Formula.top := succIndicatorAt le_rfl

/-- The `reflectTime` image of `succIndicatorAt`'s statement, computed once so that
`prevIndicatorAt` is a `▸`-rewrite rather than a `simp` inside a term. -/
theorem reflect_time_next_top_eq :
    Formula.reflectTime (Formula.next Formula.top) = Formula.prev Formula.top := by
  simp only [Formula.next, Formula.prev, Formula.top, Formula.reflectTime]

/-- **`⊢[fc] Y ⊤` at every `fc` with `FrameClass.ZTime ≤ fc`.**

The past mirror of `succIndicatorAt`, and it is *free*: `DerivationTree.time_reflection` is a
primitive rule at every frame class, so applying it to `succIndicatorAt h` and normalizing with
`reflect_time_next_top_eq` returns exactly this statement. No past-mirrored axiom is introduced.

The guard `h : FrameClass.ZTime ≤ fc` is inherited from `succIndicatorAt` and is what makes the
`{fc}`-generalization safe: a guard-free version would derive `S(⊥,⊤)` at `FrameClass.Dense`,
where `Axiom.dense_indicator` refutes the future form and time reflection refutes this one.

Paper: — (the free past mirror of `succIndicatorAt`; no paper counterpart)
-/
def prevIndicatorAt {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) :
    ⊢[fc] Formula.prev Formula.top :=
  reflect_time_next_top_eq ▸ DerivationTree.time_reflection _ (succIndicatorAt h)

/-- **`⊢[Discrete] Y ⊤`.**

The `le_rfl` instantiation of `prevIndicatorAt`, following `succIndicator`'s convention: the
proof lives there and is not duplicated here, and the pinned form is kept as a declaration in
its own right because its consumers work at `FrameClass.ZTime` itself.

Paper: — (the free past mirror of `succIndicator`; no paper counterpart)
-/
def prevIndicator : ⊢[FrameClass.ZTime] Formula.prev Formula.top := prevIndicatorAt le_rfl

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
    ⊢[FrameClass.ZTime]
      (Formula.untl g e).imp
        ((Formula.next e).or (Formula.next (Formula.and g (Formula.untl g e)))) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set C := (Formula.next e).or (Formula.next G') with hC
  set Γ : Context := [Formula.untl g e] with hΓ
  refine deductionTheorem [] (Formula.untl g e) C ?_
  have h1 : Γ ⊢[FrameClass.ZTime] Formula.untl g e :=
    DerivationTree.assumption _ _ (by simp [hΓ])
  have h2 : Γ ⊢[FrameClass.ZTime] Formula.untl G' e :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.self_accum_until g e) (FrameClass.base_le _)) h1
  have h3 : Γ ⊢[FrameClass.ZTime] Formula.untl Formula.bot Formula.top :=
    wk _ _ succIndicator
  have h4 : Γ ⊢[FrameClass.ZTime]
      (Formula.untl G' e).and (Formula.untl Formula.bot Formula.top) := andIntro h2 h3
  have h5 : Γ ⊢[FrameClass.ZTime]
      ((Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)).or
        (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot))).or
        (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)) :=
    DerivationTree.modus_ponens _ _ _
      (DerivedAxioms.linearUntilLegacyAt _ G' e Formula.bot Formula.top) h4
  -- Disjunct 1: `U(e ∧ ⊤, G' ∧ ⊥)` collapses to `X e`.
  have d1 : Γ ⊢[FrameClass.ZTime]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.ZTime)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top) :: Γ)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.top)) (by simp)
    have a2 := guardMono _ (Formula.and e Formula.top) (Formula.and G' Formula.bot)
      Formula.bot (rceImp G' Formula.bot) a1
    have a3 := eventMono _ (Formula.and e Formula.top) e Formula.bot
      (lceImp e Formula.top) a2
    exact orIntroL _ _ _ a3
  -- Disjunct 2: `U(e ∧ ⊥, _)` has a refutable event.
  have d2 : Γ ⊢[FrameClass.ZTime]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.ZTime)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot) :: Γ)
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and e Formula.bot)) (by simp)
    have a2 := eventMono _ (Formula.and e Formula.bot) Formula.bot
      (Formula.and G' Formula.bot) (rceImp e Formula.bot) a1
    have a3 : _ ⊢[FrameClass.ZTime] Formula.bot :=
      DerivationTree.modus_ponens _ _ _ (wk _ _ (untlBotFalse _)) a2
    exact DerivationTree.modus_ponens _ _ _ (wk _ _ (efqAxiom C)) a3
  -- Disjunct 3: `U(G' ∧ ⊤, G' ∧ ⊥)` collapses to `X G'`.
  have d3 : Γ ⊢[FrameClass.ZTime]
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)).imp C := by
    refine deductionTheorem Γ
      (Formula.untl (Formula.and G' Formula.bot) (Formula.and G' Formula.top)) C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.ZTime)
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

/-- The `reflectTime` image of `unfoldForward`'s statement, computed once so that
`unfoldBackwardSince` is a `▸`-rewrite rather than a `simp` inside a term. -/
theorem reflect_time_unfold_forward_eq (e g : Formula) :
    Formula.reflectTime
      ((Formula.untl g.reflectTime e.reflectTime).imp
        ((Formula.next e.reflectTime).or
          (Formula.next (Formula.and g.reflectTime (Formula.untl g.reflectTime e.reflectTime)))))
      = (Formula.snce g e).imp
          ((Formula.prev e).or (Formula.prev (Formula.and g (Formula.snce g e)))) := by
  simp only [Formula.next, Formula.prev, Formula.or, Formula.and, Formula.neg,
    Formula.reflectTime, Formula.reflect_time_involution]

/-- **The `snce` mirror of `unfoldForward`**: one backward step out of a since-formula,

```
S(g, e)   ->   Y e  \/  Y (g /\ S(g, e))
```

The past dual of `unfoldForward`, and it is *free*: `DerivationTree.time_reflection` is a
primitive rule at every frame class, so applying it to `unfoldForward` on the reflected
arguments and normalizing with `reflect_time_unfold_forward_eq` returns exactly this statement.
No past-mirrored axiom is introduced.

Stated at `FrameClass.ZTime` because `unfoldForward` is: the forward half needs
`succIndicator`, which is a theorem only from `ZTime` upwards.

The `Base`-level converse — the mirror of `unfoldBackward` — is not needed by any consumer in
this tree and is deliberately not added; it would be the same two-line recipe.

Paper: — (the free past mirror of `unfoldForward`; no paper counterpart)
-/
def unfoldBackwardSince (e g : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.snce g e).imp
        ((Formula.prev e).or (Formula.prev (Formula.and g (Formula.snce g e)))) :=
  reflect_time_unfold_forward_eq e g ▸
    DerivationTree.time_reflection _ (unfoldForward e.reflectTime g.reflectTime)

/-! ### `X` distributes over conjunction (Base)

Needed to move between the schema's `X (g ∧ U(e,g))` and handoff §4.4's table shape
`g ∈ u ∧ U(e,g) ∈ u`.  The `←` direction is event monotonicity; the `→` direction below is
the functionality of the successor, and it is derivable at `Base` from `Axiom.linear_until`. -/
/-- `⊢ (XA ∧ XB) → X(A ∧ B)`: the next-operator distributes over conjunction. -/
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
      (DerivedAxioms.linearUntilLegacyAt Γ Formula.bot A Formula.bot B) h4
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

/-- The `reflectTime` image of `nextConj`'s statement, computed once so that `prevConj` is a
`▸`-rewrite rather than a `simp` inside a term. -/
theorem reflect_time_next_conj_eq (A B : Formula) :
    Formula.reflectTime
      (((Formula.next A.reflectTime).and (Formula.next B.reflectTime)).imp
        (Formula.next (Formula.and A.reflectTime B.reflectTime)))
      = ((Formula.prev A).and (Formula.prev B)).imp (Formula.prev (Formula.and A B)) := by
  simp only [Formula.next, Formula.prev, Formula.and, Formula.neg, Formula.reflectTime,
    Formula.reflect_time_involution]

/-- `⊢ (YA ∧ YB) → Y(A ∧ B)`: the previous-operator distributes over conjunction.

The past mirror of `nextConj`, and it is *free*: `DerivationTree.time_reflection` is a primitive
rule at every frame class, so applying it to `nextConj` on the reflected arguments and
normalizing with `reflect_time_next_conj_eq` returns exactly this statement. No past-mirrored
axiom is introduced. `{fc}`-polymorphic for the same reason `nextConj` is — the functionality of
the predecessor is already available at `FrameClass.Base`.

Paper: — (the free past mirror of `nextConj`; no paper counterpart)
-/
def prevConj {fc : FrameClass} (A B : Formula) :
    ⊢[fc] ((Formula.prev A).and (Formula.prev B)).imp (Formula.prev (Formula.and A B)) :=
  reflect_time_next_conj_eq A B ▸
    DerivationTree.time_reflection _ (nextConj A.reflectTime B.reflectTime)

/-! ### The unfolding in handoff §4.4's table shape

```
U(e, g)   <->   X e  \/  ( X g  /\  X U(e, g) )
```
-/

/-- Table shape, forward. -/
def unfoldTableForward (e g : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.untl g e).imp
        ((Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e)))) := by
  set G' := Formula.and g (Formula.untl g e) with hG'
  set C := (Formula.next e).or ((Formula.next g).and (Formula.next (Formula.untl g e))) with hC
  set Γ : Context := [Formula.untl g e] with hΓ
  refine deductionTheorem [] (Formula.untl g e) C ?_
  have h1 : Γ ⊢[FrameClass.ZTime] (Formula.next e).or (Formula.next G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward e g))
      (DerivationTree.assumption Γ (Formula.untl g e) (by simp [hΓ]))
  refine orElim Γ (Formula.next e) (Formula.next G') C h1 ?_ ?_
  · refine deductionTheorem Γ (Formula.next e) C ?_
    exact orIntroL _ _ _ (DerivationTree.assumption _ _ (by simp))
  · refine deductionTheorem Γ (Formula.next G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.ZTime) (Formula.next G' :: Γ)
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
At `FrameClass.ZTime` that pattern is *derivably* inconsistent, so no such `w` exists.  At
`FrameClass.Base` — where the closure MCS layer actually lives — this derivation is unavailable,
because `unfoldForward` is. -/
/-- `⊢ U(q,p) → (U(r,p) ∨ U(s,q))` at `ZTime`: the blocking pattern that would obstruct a
Lindenbaum-style construction of `filteredStep_fwd` is derivably inconsistent. -/
def noBlockingTriple (p q r s : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.untl q p).imp ((Formula.untl r p).or (Formula.untl s q)) := by
  set C := (Formula.untl r p).or (Formula.untl s q) with hC
  set Γ : Context := [Formula.untl q p] with hΓ
  set G' := Formula.and q (Formula.untl q p) with hG'
  refine deductionTheorem [] (Formula.untl q p) C ?_
  have h1 : Γ ⊢[FrameClass.ZTime] (Formula.next p).or (Formula.next G') :=
    DerivationTree.modus_ponens Γ _ _ (wk Γ _ (unfoldForward p q))
      (DerivationTree.assumption Γ (Formula.untl q p) (by simp [hΓ]))
  refine orElim Γ (Formula.next p) (Formula.next G') C h1 ?_ ?_
  · refine deductionTheorem Γ (Formula.next p) C ?_
    exact orIntroL _ _ _
      (guardMono (Formula.next p :: Γ) p Formula.bot r (efqAxiom r)
        (DerivationTree.assumption (Formula.next p :: Γ) (Formula.next p) (by simp)))
  · refine deductionTheorem Γ (Formula.next G') C ?_
    have a1 := DerivationTree.assumption (fc := FrameClass.ZTime) (Formula.next G' :: Γ)
      (Formula.next G') (by simp)
    have a2 := eventMono (Formula.next G' :: Γ) G' q Formula.bot (lceImp q (Formula.untl q p)) a1
    exact orIntroR _ _ _ (guardMono (Formula.next G' :: Γ) q Formula.bot s (efqAxiom s) a2)

/-! ## Result 4: the paper's **DF** schema at `FrameClass.ZTime`

```
(Hφ ∧ φ ∧ F⊤)  →  F (Hφ)
```

`DF` is the axiom distinguishing this tree's `TM_z` from `TM`
(JPL paper, `\S sub:Extension`). It is the one TM-side schema with no ready-made counterpart in
this tree, and `FormalSystem.MinusLanguage.AxiomDischarge` consumes `dfSchema` to close the
`Discrete` row of the backward conservativity bridge.

The derivation is **syntactic** and uses only `succIndicator`, `unfoldForward`, `nextConj`,
`Axiom.enrichment_until`, UE (`DerivedAxioms.untilF`) and propositional plumbing. In particular it
does
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
    ⊢[FrameClass.ZTime]
      (Formula.next (Formula.and φ.allFuture φ)).imp φ.allFuture := by
  set B0 := Formula.and φ.allFuture φ with hB0
  set Γ : Context := [Formula.next B0] with hΓ
  refine deductionTheorem [] (Formula.next B0) φ.allFuture ?_
  refine deductionTheorem Γ (Formula.someFuture φ.neg) Formula.bot ?_
  set Γ' : Context := Formula.someFuture φ.neg :: Γ with hΓ'
  have hF : Γ' ⊢[FrameClass.ZTime] Formula.someFuture φ.neg :=
    DerivationTree.assumption _ _ (by simp [hΓ'])
  have hXB : Γ' ⊢[FrameClass.ZTime] Formula.next B0 :=
    DerivationTree.assumption _ _ (by simp [hΓ', hΓ])
  have h1 : Γ' ⊢[FrameClass.ZTime]
      (Formula.next φ.neg).or
        (Formula.next (Formula.and Formula.top (Formula.untl Formula.top φ.neg))) :=
    ctxMp (wk _ _ (unfoldForward φ.neg Formula.top)) hF
  refine orElim Γ' (Formula.next φ.neg)
    (Formula.next (Formula.and Formula.top (Formula.untl Formula.top φ.neg)))
    Formula.bot h1 ?_ ?_
  · -- Disjunct 1: `X ¬φ` merged with `X (Gφ ∧ φ)` gives the event `¬φ ∧ (Gφ ∧ φ)`.
    refine deductionTheorem Γ' (Formula.next φ.neg) Formula.bot ?_
    have a1 : (Formula.next φ.neg :: Γ') ⊢[FrameClass.ZTime] Formula.next φ.neg :=
      DerivationTree.assumption _ _ (by simp)
    have a2 : (Formula.next φ.neg :: Γ') ⊢[FrameClass.ZTime] Formula.next B0 :=
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
    have a1 : (Formula.next E :: Γ') ⊢[FrameClass.ZTime] Formula.next E :=
      DerivationTree.assumption _ _ (by simp)
    have a2 : (Formula.next E :: Γ') ⊢[FrameClass.ZTime] Formula.next B0 :=
      DerivationTree.weakening _ _ _ hXB (by intro x hx; simp [hx])
    have a3 := ctxMp (wk _ _ (nextConj E B0)) (andIntro a1 a2)
    have a4 := eventMono _ (Formula.and E B0) Formula.bot Formula.bot
      (clashBot E B0 (Formula.someFuture φ.neg)
        (rceImp Formula.top (Formula.untl Formula.top φ.neg))
        (lceImp φ.allFuture φ)) a3
    exact ctxMp (wk _ _ (untlBotFalse Formula.bot)) a4

/-- The `reflectTime` image of `nextAllFuture`'s statement, computed once so that
`prevAllPast` is a `▸`-rewrite rather than a `simp` inside a term. -/
theorem reflect_time_next_all_future_eq (φ : Formula) :
    Formula.reflectTime
      ((Formula.next (Formula.and (φ.reflectTime).allFuture φ.reflectTime)).imp
        (φ.reflectTime).allFuture)
      = (Formula.prev (Formula.and φ.allPast φ)).imp φ.allPast := by
  simp only [Formula.next, Formula.prev, Formula.and, Formula.neg, Formula.reflectTime,
    Formula.reflect_time_all_future, Formula.reflect_time_involution]

/-- **Step 3, past form**: `⊢[Discrete] Y (Hφ ∧ φ) → Hφ`.

The past dual of `nextAllFuture`, and it is *free*: `DerivationTree.time_reflection` is a
primitive rule at every frame class, so applying it to `nextAllFuture (reflectTime φ)` and
using `Formula.reflect_time_involution` returns exactly this statement. No past-mirrored axiom
is introduced. -/
def prevAllPast (φ : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.prev (Formula.and φ.allPast φ)).imp φ.allPast :=
  reflect_time_next_all_future_eq φ ▸ DerivationTree.time_reflection _ (nextAllFuture φ.reflectTime)

/-- **`⊢[Discrete] (Hφ ∧ φ ∧ F⊤) → F(Hφ)`** — the paper's **DF** schema.

Three steps, in the order of the module note above:

1. `succIndicator` supplies `X ⊤`, the discreteness witness.
2. `Axiom.enrichment_until` at guard `⊥`, event `⊤`, and payload `p := Hφ ∧ φ` turns
   `(Hφ ∧ φ) ∧ X⊤` into `X (⊤ ∧ Y (Hφ ∧ φ))` — the payload is transported to the successor as
   a `Y`-formula because the successor's `snce`-guard interval is empty.
3. `prevAllPast` converts `Y (Hφ ∧ φ)` into `Hφ` at the successor, and UE
   (`DerivedAxioms.untilF`) at
   guard `⊥` weakens `X (Hφ)` to `F (Hφ)`.

The `F⊤` conjunct of the antecedent is not consumed: at `FrameClass.ZTime` the stronger
`X ⊤` is already a theorem. It is retained because the schema, not the derivation, is what the
translation of `MinusLanguage.Axiom.df` must match.

Association is pinned to `((Hφ ∧ φ) ∧ F⊤) → F(Hφ)` so that
`FormalSystem.MinusLanguage.AxiomDischarge` can use it without reassociating.

Paper: `sub:Extension`
-/
def dfSchema (φ : Formula) :
    ⊢[FrameClass.ZTime]
      ((φ.allPast.and φ).and Formula.top.someFuture).imp (φ.allPast.someFuture) := by
  set A := Formula.and φ.allPast φ with hA
  set ant := Formula.and A (Formula.someFuture Formula.top) with hant
  set Γ : Context := [ant] with hΓ
  refine deductionTheorem [] ant (φ.allPast.someFuture) ?_
  have h0 : Γ ⊢[FrameClass.ZTime] ant := DerivationTree.assumption _ _ (by simp [hΓ])
  have hA' : Γ ⊢[FrameClass.ZTime] A := andFst h0
  have hX : Γ ⊢[FrameClass.ZTime] Formula.untl Formula.bot Formula.top :=
    wk _ _ succIndicator
  have h2 : Γ ⊢[FrameClass.ZTime]
      Formula.untl Formula.bot (Formula.and Formula.top (Formula.snce Formula.bot A)) :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.enrichment_until Formula.bot Formula.top A)
      (FrameClass.base_le _)) (andIntro hA' hX)
  have h3 : Γ ⊢[FrameClass.ZTime] Formula.untl Formula.bot φ.allPast :=
    eventMono _ (Formula.and Formula.top (Formula.snce Formula.bot A)) φ.allPast Formula.bot
      (impTrans (rceImp Formula.top (Formula.snce Formula.bot A)) (prevAllPast φ)) h2
  exact ctxMp (thmIn (DerivedAxioms.untilF Formula.bot φ.allPast)) h3

/-! ## Result 4: Z1, the backward-induction principle of ℤ-time -/

/-- The event of the enriched UZ until-formula is refutable: `⊢[Discrete] ((Gφ ∧ φ) ∧
S(¬Gφ, ¬Gφ)) → ⊥`.

This is the whole content of `z1Schema`, isolated as a theorem so that the main derivation is a
single `eventMono` step. Read it at the nearest `Gφ`-witness `s` of the UZ interval:

1. `S(¬Gφ, ¬Gφ)` says `¬Gφ` held at some earlier point and throughout the interval since.
   `unfoldBackwardSince` takes one step back out of it, and both disjuncts give `Y ¬Gφ` — the
   second through `snceEventMono`.
2. `Gφ ∧ φ` holds at `s`, and `prevIndicator` supplies `Y ⊤`, so `DerivedAxioms.enrichmentSince`
   at guard `⊥`, event `⊤` and payload `Gφ ∧ φ` transports the payload to the predecessor as
   `Y (⊤ ∧ X (Gφ ∧ φ))` — the past mirror of the step `dfSchema` uses, and the step that makes
   the argument finite rather than an induction.
3. `prevConj` merges the two `Y`-formulas, `nextAllFuture` turns the inner `X (Gφ ∧ φ)` into
   `Gφ`, which clashes with the `¬Gφ` beside it, and `snceBotFalse` closes on `Y ⊥`.

Paper: `def:BX-z`
-/
def z1EventBot (φ : Formula) :
    ⊢[FrameClass.ZTime]
      (Formula.and (Formula.and φ.allFuture φ)
        (Formula.snce φ.allFuture.neg φ.allFuture.neg)).imp Formula.bot := by
  set A := φ.allFuture with hA
  set B := Formula.and A φ with hB
  set S := Formula.snce A.neg A.neg with hS
  set XB := Formula.untl Formula.bot B with hXB
  have hinner : ⊢[FrameClass.ZTime]
      (Formula.and A.neg (Formula.and Formula.top XB)).imp Formula.bot := by
    refine deductionTheorem [] (Formula.and A.neg (Formula.and Formula.top XB)) Formula.bot ?_
    have h := DerivationTree.assumption (fc := FrameClass.ZTime)
      [Formula.and A.neg (Formula.and Formula.top XB)]
      (Formula.and A.neg (Formula.and Formula.top XB)) (by simp)
    exact ctxMp (andFst h) (ctxMp (wk _ _ (nextAllFuture φ)) (andSnd (andSnd h)))
  refine deductionTheorem [] (Formula.and B S) Formula.bot ?_
  set E : Context := [Formula.and B S] with hE
  have h0 : E ⊢[FrameClass.ZTime] Formula.and B S :=
    DerivationTree.assumption _ _ (by simp [hE])
  have hB' : E ⊢[FrameClass.ZTime] B := andFst h0
  have hS' : E ⊢[FrameClass.ZTime] S := andSnd h0
  have hu : E ⊢[FrameClass.ZTime]
      (Formula.prev A.neg).or (Formula.prev (Formula.and A.neg S)) :=
    ctxMp (wk _ _ (unfoldBackwardSince A.neg A.neg)) hS'
  have hYnA : E ⊢[FrameClass.ZTime] Formula.prev A.neg := by
    refine orElim E _ _ (Formula.prev A.neg) hu (wk _ _ (identity _)) ?_
    refine deductionTheorem E (Formula.prev (Formula.and A.neg S)) (Formula.prev A.neg) ?_
    exact snceEventMono _ (Formula.and A.neg S) A.neg Formula.bot (lceImp A.neg S)
      (DerivationTree.assumption _ (Formula.prev (Formula.and A.neg S)) (by simp))
  have hYt : E ⊢[FrameClass.ZTime] Formula.prev Formula.top := wk _ _ prevIndicator
  have hYXB : E ⊢[FrameClass.ZTime] Formula.prev (Formula.and Formula.top XB) :=
    ctxMp (wk _ _ (DerivedAxioms.enrichmentSince Formula.bot Formula.top B))
      (andIntro hB' hYt)
  have hmerge : E ⊢[FrameClass.ZTime]
      Formula.prev (Formula.and A.neg (Formula.and Formula.top XB)) :=
    ctxMp (wk _ _ (prevConj A.neg (Formula.and Formula.top XB))) (andIntro hYnA hYXB)
  have hYbot : E ⊢[FrameClass.ZTime] Formula.prev Formula.bot :=
    snceEventMono _ _ Formula.bot Formula.bot hinner hmerge
  exact ctxMp (wk _ _ (snceBotFalse Formula.bot)) hYbot

/-- **`⊢[Discrete] G(Gφ → φ) → (F Gφ → Gφ)`** — the paper's **Z1** schema, as a direct
derivation tree from UZ, US and the BX/TM axioms.

Z1 is the characteristic backward-induction principle of the successor-Archimedean orders, and
UZ is what makes it finite: `Axiom.prior_UZ` hands back the *nearest* future `Gφ`-point, so the
argument looks one step back from that point instead of inducting along the interval.

Four steps, assuming `¬Gφ` for contradiction and discharging with `doubleNegation`:

1. `Axiom.prior_UZ` at `Gφ` turns the hypothesis `F Gφ` into `U(¬Gφ, Gφ)`.
2. The event is strengthened from `Gφ` to `Gφ ∧ φ` by `Axiom.right_mono_until`, whose
   `G(Gφ → (Gφ ∧ φ))` premise comes from the hypothesis `G(Gφ → φ)` through TK
   (`TemporalDerived.temporalKDistDerived`) applied to a propositional tautology.
3. `Axiom.enrichment_until` with payload `¬Gφ` — true now — carries it to the witness as
   `S(¬Gφ, ¬Gφ)`, so the witness holds `(Gφ ∧ φ) ∧ S(¬Gφ, ¬Gφ)`.
4. That event is refutable (`z1EventBot`), so `eventMono` drives the until-formula to
   `U(¬Gφ, ⊥)` and `untlBotFalse` closes.

Stated at `FrameClass.ZTime`, where UZ and the discreteness witness are theorems; `z1SchemaAt`
is the frame-class-gated companion.

Paper: `def:BX-z`
-/
def z1Schema (φ : Formula) :
    ⊢[FrameClass.ZTime]
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := by
  set A := φ.allFuture with hA
  set B := Formula.and A φ with hB
  set H1 := (A.imp φ).allFuture with hH1
  refine deductionTheorem [] H1 (A.someFuture.imp A) ?_
  refine deductionTheorem [H1] A.someFuture A ?_
  set Γ : Context := [A.someFuture, H1] with hΓ
  refine ctxMp (thmIn (doubleNegation A)) ?_
  refine deductionTheorem Γ A.neg Formula.bot ?_
  set Δ : Context := A.neg :: Γ with hΔ
  have hnA : Δ ⊢[FrameClass.ZTime] A.neg := DerivationTree.assumption _ _ (by simp [hΔ])
  have hFA : Δ ⊢[FrameClass.ZTime] A.someFuture :=
    DerivationTree.assumption _ _ (by simp [hΔ, hΓ])
  have hG : Δ ⊢[FrameClass.ZTime] H1 := DerivationTree.assumption _ _ (by simp [hΔ, hΓ])
  have h1 : Δ ⊢[FrameClass.ZTime] Formula.untl A.neg A :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.prior_UZ A) le_rfl) hFA
  have htaut : ⊢[FrameClass.ZTime] (A.imp φ).imp (A.imp B) := by
    refine deductionTheorem [] (A.imp φ) (A.imp B) ?_
    refine deductionTheorem [A.imp φ] A B ?_
    have ha : [A, A.imp φ] ⊢[FrameClass.ZTime] A := DerivationTree.assumption _ _ (by simp)
    have hf : [A, A.imp φ] ⊢[FrameClass.ZTime] A.imp φ :=
      DerivationTree.assumption _ _ (by simp)
    exact andIntro ha (ctxMp hf ha)
  have hGAB : Δ ⊢[FrameClass.ZTime] (A.imp B).allFuture :=
    ctxMp (ctxMp (wk _ _ (FormalSystem.Theorems.TemporalDerived.temporalKDistDerived
      (A.imp φ) (A.imp B))) (necG Δ _ htaut)) hG
  have h2 : Δ ⊢[FrameClass.ZTime] Formula.untl A.neg B :=
    ctxMp (ctxMp (DerivationTree.axiom _ _ (Axiom.right_mono_until A B A.neg)
      (FrameClass.base_le _)) hGAB) h1
  have h3 : Δ ⊢[FrameClass.ZTime]
      Formula.untl A.neg (Formula.and B (Formula.snce A.neg A.neg)) :=
    ctxMp (DerivationTree.axiom _ _ (Axiom.enrichment_until A.neg B A.neg)
      (FrameClass.base_le _)) (andIntro hnA h2)
  have h4 : Δ ⊢[FrameClass.ZTime] Formula.untl A.neg Formula.bot :=
    eventMono _ _ Formula.bot A.neg (z1EventBot φ) h3
  exact ctxMp (wk _ _ (untlBotFalse A.neg)) h4

/-- The frame-class-gated form of `z1Schema`, by `DerivationTree.lift`.

This is the shape `Automation/Tactics/Search.lean`'s `tryGatedDerivedMatch`, the
`plusValidIn_of_tm_deriv` branches in `Conservativity/Plus/AxiomValidity.lean` and
`BimodalTools/ProofExtractorMain.lean`'s `mkEntryAt` all consume; the argument order matches
`DerivedAxioms.priorSZ` so that the tactic's `apply`-then-`decide` gate discharge works
unchanged. `lift` is computable and structural, so the gated form costs one constructor-mapping
pass over the tree and nothing else — `Combinators.baseThm` and `succIndicatorAt` are the
existing instances of the same pattern.

Paper: `def:BX-z`
-/
def z1SchemaAt {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    ⊢[fc] ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  DerivationTree.lift h (z1Schema φ)

end FormalSystem.Theorems.DiscreteUnfolding
