/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.TemporalDerived
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.DeductionTheorem

/-!
# Linearity and Density as Derived Schemata

Two schemata the paper lists under `def:BX` and `def:BX-d` are theorems of the reduced
primitive system:

* `tempLinearity` — TL, `Fφ ∧ Fψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`, in the paper's
  disjunct order, right-associated. Derived from CN (`Axiom.linear_until`) with UF
  (`self_accum_until`) to turn each `F` into an Until with a self-accumulating guard, then UE
  (`DerivedAxioms.untilF`) and `someFutureMono` to collapse each CN disjunct back to an `F`.
  This is the precise sense in which TL is subsumed by CN: Xu 1988 §4 Theorem 4.3 shows the
  G/H-level linearity formula (13) is strictly weaker than the Until-level (10), and §3 proves
  Σ₄ complete for linear frames without Burgess's A4a. The former record of TL's
  "underivability" (`ProofSystem/LinearityDerivedFacts.lean`) rested on a branching frame
  that refutes CN itself, so it was never a model of the current base.
* `density` — DN, `GGφ → Gφ` at every `fc ≥ Dense`, derived directly from NN
  (`Axiom.dense_indicator`) with UG (`left_mono_until_G`), UF, UE, UC (`right_mono_until`) and
  G-monotonicity: `GGφ` gives `G(⊤ → Gφ)`, so UG widens `F¬φ = U(⊤, ¬φ)` to `U(Gφ, ¬φ)` and UF to
  `U(Gφ ∧ U(Gφ, ¬φ), ¬φ)`; the guard entails `Gφ ∧ F¬φ` (by UE), a contradiction, so it
  collapses to `⊥`; widening the event to `⊤` gives `U(⊥, ⊤) = X⊤`, which NN refutes.

The legacy disjunct order `tempLinearityLegacy` and the past mirror `tempLinearityPast` are
derived here from `tempLinearity` by `orRotate`.

## Computability

As in `Theorems/ConnectDerived.lean`, every definition here is **computable** (the runtime proof
search and the dataset tooling traverse `tempLinearityLegacy`/`tempLinearityPast` trees), so the
disjunction elimination is the explicit classical term `orElimThm` (via consequentia mirabilis
`claviusThm`) rather than the noncomputable `Propositional.orElim`.
-/

namespace FormalSystem.Theorems.LinearityDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.ProofSystem.DerivedAxioms (untilF impTop ofReflect orRotate guardMonoThm
  eventMonoThm lift)
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.TemporalDerived (someFutureMono)
open FormalSystem.Theorems.ConnectDerived (compLeft compRight lceImpThm rceImpThm gMonoThm)

/-! ## Computable disjunction stock -/

/-- `A → A ∨ B` (`A ∨ B` is `¬A → B`): `A → ¬¬A`, then EFQ under the binder. -/
def orInlThm {fc : FrameClass} (A B : Formula) : ⊢[fc] A.imp (A.or B) :=
  impTrans (notNotIntro A) (compLeft (efqAxiom B))

/-- `B → A ∨ B`: K. -/
def orInrThm {fc : FrameClass} (A B : Formula) : ⊢[fc] B.imp (A.or B) :=
  DerivationTree.axiom [] _ (Axiom.prop_s B A.neg) (FrameClass.base_le fc)

/-- Consequentia mirabilis, `(¬C → C) → C`: S on `¬C → ¬C` gives `(¬C → C) → ¬¬C`, then DNE. -/
def claviusThm {fc : FrameClass} (C : Formula) : ⊢[fc] (C.neg.imp C).imp C :=
  impTrans
    (mp (identity C.neg)
      (DerivationTree.axiom [] _ (Axiom.prop_k C.neg C Formula.bot) (FrameClass.base_le fc)))
    (doubleNegation C)

/-- Classical disjunction elimination at theorem level: from `⊢ X → C` and `⊢ Y → C` derive
`⊢ (X ∨ Y) → C`. `X ∨ Y` is `¬X → Y`; compose with `Y → C`, then with `¬C → ¬X`
(contrapositive of the first premise), and close `(¬C → C) → C` by `claviusThm`. -/
def orElimThm {fc : FrameClass} {X Y C : Formula} (hX : ⊢[fc] X.imp C) (hY : ⊢[fc] Y.imp C) :
    ⊢[fc] (X.or Y).imp C :=
  impTrans (compLeft hY) (impTrans (compRight (mp hX (contraposeImp X C))) (claviusThm C))

/-! ## TL and DN -/

/-- TL: `Fφ ∧ Fψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))` (the paper's TL verbatim,
right-associated), derived from CN. With `gᵢ := ⊤ ∧ Fχᵢ`, UF turns `Fφ`, `Fψ` into `U(g₁, φ)`,
`U(g₂, ψ)`; CN on the pair gives a disjunction of three Untils with guard `g₁ ∧ g₂`, and each
disjunct collapses by UE and `someFutureMono` onto the matching TL disjunct.

Paper: `def:BX`
-/
@[tmLemma]
def tempLinearity {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))))) :=
  let g₁ : Formula := Formula.and Formula.top (Formula.untl Formula.top φ)
  let g₂ : Formula := Formula.and Formula.top (Formula.untl Formula.top ψ)
  let A : Formula := Formula.someFuture (Formula.and φ.someFuture ψ)
  let B₁ : Formula := Formula.someFuture (Formula.and φ ψ)
  let B₂ : Formula := Formula.someFuture (Formula.and φ ψ.someFuture)
  let hUFφ : ⊢[fc] (Formula.and φ.someFuture ψ.someFuture).imp (Formula.untl g₁ φ) :=
    impTrans (lceImpThm φ.someFuture ψ.someFuture)
      (DerivationTree.axiom [] _ (Axiom.self_accum_until Formula.top φ) (FrameClass.base_le fc))
  let hUFψ : ⊢[fc] (Formula.and φ.someFuture ψ.someFuture).imp (Formula.untl g₂ ψ) :=
    impTrans (rceImpThm φ.someFuture ψ.someFuture)
      (DerivationTree.axiom [] _ (Axiom.self_accum_until Formula.top ψ) (FrameClass.base_le fc))
  let hCN : ⊢[fc] (Formula.and φ.someFuture ψ.someFuture).imp
      (Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ))
        (Formula.or (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂))
          (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ)))) :=
    impTrans (combineImpConj hUFφ hUFψ)
      (DerivationTree.axiom [] _ (Axiom.linear_until g₁ φ g₂ ψ) (FrameClass.base_le fc))
  -- CN disjunct 1, `U(g₁∧g₂, φ∧ψ)`, gives `F(φ ∧ ψ)` = B₁
  let hD1 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _) (impTrans (orInlThm B₁ B₂) (orInrThm A _))
  -- CN disjunct 2, `U(g₁∧g₂, φ∧g₂)`, gives `F(φ ∧ Fψ)` = B₂ since `g₂ → Fψ`
  let hD2 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and φ g₂)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj (lceImpThm φ g₂)
          (impTrans (rceImpThm φ g₂) (rceImpThm Formula.top _))))
        (impTrans (orInrThm B₁ B₂) (orInrThm A _)))
  -- CN disjunct 3, `U(g₁∧g₂, g₁∧ψ)`, gives `F(Fφ ∧ ψ)` = A since `g₁ → Fφ`
  let hD3 : ⊢[fc] (Formula.untl (Formula.and g₁ g₂) (Formula.and g₁ ψ)).imp
      (A.or (B₁.or B₂)) :=
    impTrans (untilF _ _)
      (impTrans (someFutureMono (combineImpConj
          (impTrans (lceImpThm g₁ ψ) (rceImpThm Formula.top _)) (rceImpThm g₁ ψ)))
        (orInlThm A _))
  impTrans hCN (orElimThm hD1 (orElimThm hD2 hD3))

/-- DN: `GGφ → Gφ` wherever NN is available (`FrameClass.Dense ≤ fc`), derived directly.
`GGφ` gives `G(⊤ → Gφ)` by G-monotonicity, so UG turns `F¬φ = U(⊤, ¬φ)` into `U(Gφ, ¬φ)`, and
UF into `U(Gφ ∧ U(Gφ, ¬φ), ¬φ)`. The guard entails `Gφ ∧ F¬φ` (by UE), a contradiction, so it
collapses to `⊥`; widening the event to `⊤` gives `U(⊥, ⊤) = X⊤`, which NN refutes. Composing
under the `U(⊤, ¬φ) →` binder gives `GGφ → ¬U(⊤, ¬φ) = GGφ → Gφ`.

Paper: `def:BX-d`
-/
def density {fc : FrameClass} (h : FrameClass.Dense ≤ fc) (φ : Formula) :
    ⊢[fc] φ.allFuture.allFuture.imp φ.allFuture :=
  let G : Formula := φ.allFuture
  let U' : Formula := Formula.untl G φ.neg
  -- GGφ → G(⊤ → Gφ)
  let hG : ⊢[fc] G.allFuture.imp (Formula.top.imp G).allFuture :=
    gMonoThm (DerivationTree.axiom [] _ (Axiom.prop_s G Formula.top) (FrameClass.base_le fc))
  -- G(⊤ → Gφ) → (U(⊤, ¬φ) → U(Gφ, ¬φ))
  let hUG : ⊢[fc] (Formula.top.imp G).allFuture.imp ((Formula.untl Formula.top φ.neg).imp U') :=
    DerivationTree.axiom [] _ (Axiom.left_mono_until_G Formula.top G φ.neg)
      (FrameClass.base_le fc)
  -- the guard `Gφ ∧ U(Gφ, ¬φ)` is contradictory: `Gφ = ¬F¬φ` and `U(Gφ, ¬φ) → F¬φ`
  let hGimpNotU : ⊢[fc] G.imp U'.neg := compRight (C := Formula.bot) (untilF G φ.neg)
  let hχ : ⊢[fc] (Formula.and G U').imp Formula.bot := mp hGimpNotU (notNotIntro (G.imp U'.neg))
  -- U(Gφ, ¬φ) → U(Gφ ∧ U(Gφ, ¬φ), ¬φ) → U(⊥, ¬φ) → U(⊥, ⊤) → ⊥
  let tail : ⊢[fc] U'.imp Formula.bot :=
    impTrans
      (DerivationTree.axiom [] _ (Axiom.self_accum_until G φ.neg) (FrameClass.base_le fc))
      (impTrans (guardMonoThm _ _ _ hχ)
        (impTrans (eventMonoThm _ _ _ (impTop φ.neg))
          (DerivationTree.axiom [] _ Axiom.dense_indicator h)))
  impTrans (impTrans hG hUG) (compLeft tail)

/-! ## Legacy disjunct order and the past mirror -/

/-- The former statement of TL, `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ (F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))`: the
paper's TL with its disjuncts rotated twice. -/
@[tmLemma]
def tempLinearityLegacy {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) :=
  impTrans (tempLinearity φ ψ) (impTrans orRotate orRotate)

/-- Past linearity `P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ (P(φ ∧ Pψ) ∨ P(Pφ ∧ ψ))`: TR of the paper's TL,
then its disjuncts rotated twice. -/
@[tmLemma]
def tempLinearityPast {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) :=
  let tr : ⊢[fc] (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and (Formula.somePast φ) ψ))
        (Formula.or (Formula.somePast (Formula.and φ ψ))
          (Formula.somePast (Formula.and φ (Formula.somePast ψ)))))) :=
    ofReflect (tempLinearity φ.reflectTime ψ.reflectTime)
      (by simp [Formula.reflectTime, Formula.someFuture, Formula.somePast, Formula.top,
        Formula.and, Formula.or, Formula.neg, Formula.reflect_time_involution])
  impTrans tr (impTrans orRotate orRotate)

/-- Context-lifted `tempLinearityLegacy`. -/
def tempLinearityLegacyAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) :=
  lift Γ (tempLinearityLegacy φ ψ)

/-- Context-lifted `tempLinearityPast`. -/
def tempLinearityPastAt {fc : FrameClass} (Γ : Context) (φ ψ : Formula) :
    Γ ⊢[fc] (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) :=
  lift Γ (tempLinearityPast φ ψ)

end FormalSystem.Theorems.LinearityDerived
