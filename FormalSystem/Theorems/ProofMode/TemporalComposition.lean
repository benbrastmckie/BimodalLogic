/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Basic
import FormalSystem.Theorems.ProofMode.PlusDiscrete
import FormalSystem.Theorems.ProofMode.ScopeConversions
import FormalSystem.PlusLanguage.TemporalViews

/-!
# Native temporal composition rules (P3)

Derivation-producing rules for the P3 temporal frontend, for TM (`DerivationTree`) and TM⁺
(`PlusDerivationTree`). Every rule is a source-calculus derivation: closed schemata are built
from axioms, primitive rules and existing derived theorems, then applied in a context by
modus ponens. No semantics, completeness, or `Nonempty` extraction is used.

All Until/Since arguments are **guard first, event second**, matching `Formula.untl guard event`.
`DiscreteUnfolding.unfoldForward/unfoldBackward/unfoldBackwardSince` take `(event guard)`;
the wrappers here fix that order once.

* **Fold/unfold.** `untilFoldRule`/`sinceFoldRule` hold at every frame class; the Since fold
  is the closed time reflection of the existing Base Until fold. Forward unfolding keeps the
  explicit `FrameClass.ZTime ≤ fc` gate; `untilUnfoldCases` exposes both one-step branches
  without stripping `X`/`Y` from either.
* **Introduction.** `untilIntro` derives `U g e` from persistent `G g` and eventual `F e`.
  It derives a formula; it does not extract a witness time from native data.
* **Contextual reflection.** `reflectContext` maps the whole context with the conclusion;
  `reflectGoal` is the goal-direction form, justified by the reflection involution.
* **Strict leads-to.** Current (`φ → Fψ`) and persistent (`G(φ → Fψ)`) consequence,
  transitivity and case composition. A source strengthening is demanded at the scope of the
  guarantee, a target weakening always under `G`; temporal 4 retains it inside a persistent
  body. Strict `G` omits the present, so no rule turns `[φ, G(φ → Fψ)]` into `Fψ`.
* **Persistence.** `futureKeep` (temporal 4) supplies `G(G P)`, so a body entered through `G`
  or at an eventuality witness still holds `G P`. `nextOfAllFuture` moves `G φ` under an
  existing `X ψ`; it asserts no successor. At ZTime, `succIndicatorAt` supplies `X ⊤`.

Past rules are closed time reflections of future schemata, or the same propositional schema at
past arguments. TM⁺ rules transfer closed TM schemata with `PlusDerivationTree.ofTMSubst` at
arbitrary TM⁺ arguments, including arguments containing `⊡`.
-/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators FormalSystem.Theorems.TemporalDerived

variable {fc : FrameClass} {Γ : Context}

/-- Closed time reflection read at its computed statement. -/
private def reflectThm {A B : Formula} (h : ⊢[fc] A) (hEq : A.reflectTime = B) : ⊢[fc] B :=
  hEq ▸ DerivationTree.time_reflection _ h

/-- Close a uniform binary contextual rule into a theorem schema. -/
private def closed2 {A B C : Formula}
    (f : ∀ {Δ : Context}, DerivationTree fc Δ A → DerivationTree fc Δ B →
      DerivationTree fc Δ C) : ⊢[fc] A.imp (B.imp C) :=
  deductionTheorem [] A _ (deductionTheorem [A] B C
    (f (.assumption _ A (by simp)) (.assumption _ B (by simp))))

/-- Close a uniform ternary contextual rule into a theorem schema. -/
private def closed3 {A B C D : Formula}
    (f : ∀ {Δ : Context}, DerivationTree fc Δ A → DerivationTree fc Δ B →
      DerivationTree fc Δ C → DerivationTree fc Δ D) :
    ⊢[fc] A.imp (B.imp (C.imp D)) :=
  deductionTheorem [] A _ (deductionTheorem [A] B _ (deductionTheorem [B, A] C D
    (f (.assumption _ A (by simp)) (.assumption _ B (by simp)) (.assumption _ C (by simp)))))

/-! ## One-step fold and unfold -/

/-- `X e ∨ X(g ∧ U g e) → U g e`, at every frame class. -/
def untilFoldRule (guard event : Formula) :
    ⊢[fc] ((Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))).imp
      (Formula.untl guard event) :=
  (DiscreteUnfolding.unfoldBackward event guard).lift (FrameClass.base_le fc)

/-- `Y e ∨ Y(g ∧ S g e) → S g e`, at every frame class: closed time reflection of the Base
Until fold. -/
def sinceFoldRule (guard event : Formula) :
    ⊢[fc] ((Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))).imp
      (Formula.snce guard event) :=
  reflectThm (untilFoldRule guard.reflectTime event.reflectTime) (by
    simp only [Formula.next, Formula.prev, Formula.or, Formula.and, Formula.neg,
      Formula.reflectTime, Formula.reflect_time_involution])

/-- `U g e → X e ∨ X(g ∧ U g e)`, requiring integer time. -/
def untilUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : Formula) :
    ⊢[fc] (Formula.untl guard event).imp
      ((Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))) :=
  (DiscreteUnfolding.unfoldForward event guard).lift hFrame

/-- `S g e → Y e ∨ Y(g ∧ S g e)`, requiring integer time. -/
def sinceUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : Formula) :
    ⊢[fc] (Formula.snce guard event).imp
      ((Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))) :=
  (DiscreteUnfolding.unfoldBackwardSince event guard).lift hFrame

/-- Reduce an Until goal to its one-step disjunction, at every frame class. -/
def untilFold {guard event : Formula}
    (h : Γ ⊢[fc] (Formula.next event).or (Formula.next (guard.and (Formula.untl guard event)))) :
    Γ ⊢[fc] Formula.untl guard event :=
  ctxMp (thmIn (untilFoldRule guard event)) h

/-- Reduce a Since goal to its one-step disjunction, at every frame class. -/
def sinceFold {guard event : Formula}
    (h : Γ ⊢[fc] (Formula.prev event).or (Formula.prev (guard.and (Formula.snce guard event)))) :
    Γ ⊢[fc] Formula.snce guard event :=
  ctxMp (thmIn (sinceFoldRule guard event)) h

/-- Unfold an Until fact one step on integer time. Both branches keep their `X` and must prove
the common conclusion. -/
def untilUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : Formula}
    (h : Γ ⊢[fc] Formula.untl guard event)
    (hEvent : Formula.next event :: Γ ⊢[fc] C)
    (hContinue : Formula.next (guard.and (Formula.untl guard event)) :: Γ ⊢[fc] C) :
    Γ ⊢[fc] C :=
  orCases (ctxMp (thmIn (untilUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- Unfold a Since fact one step on integer time, keeping `Y` in both branches. -/
def sinceUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : Formula}
    (h : Γ ⊢[fc] Formula.snce guard event)
    (hEvent : Formula.prev event :: Γ ⊢[fc] C)
    (hContinue : Formula.prev (guard.and (Formula.snce guard event)) :: Γ ⊢[fc] C) :
    Γ ⊢[fc] C :=
  orCases (ctxMp (thmIn (sinceUnfoldRule hFrame guard event)) h) hEvent hContinue

/-! ## Contextual time reflection -/

/-- Reflect a derivation together with its whole context. Structural recursion on the context:
deduction closes the context, closed time reflection acts, and reverse deduction reopens it.
`reflectTime` commutes with implication definitionally. -/
def reflectContext : (Γ : Context) → (A : Formula) → (Γ ⊢[fc] A) →
    Context.map Formula.reflectTime Γ ⊢[fc] A.reflectTime
  | [], A, h => .time_reflection A h
  | B :: Γ, A, h =>
      reverseDeduction (reflectContext Γ (B.imp A) (deductionTheorem Γ B A h))

/-- Reflecting a context twice returns it. -/
theorem reflectContext_involution (Γ : Context) :
    Context.map Formula.reflectTime (Context.map Formula.reflectTime Γ) = Γ := by
  simp [Context.map, Function.comp_def, Formula.reflect_time_involution]

/-- Goal-direction reflection: prove a goal from its reflection over the reflected context. -/
def reflectGoal {A : Formula}
    (h : Context.map Formula.reflectTime Γ ⊢[fc] A.reflectTime) : Γ ⊢[fc] A := by
  have d := reflectContext _ _ h
  rwa [reflectContext_involution, Formula.reflect_time_involution] at d

/-! ## Until/Since introduction -/

/-- `⊢ G φ → G(ψ → φ)`: a persistent fact is a persistent consequence of anything. -/
private def gWeaken (φ ψ : Formula) : ⊢[fc] φ.allFuture.imp (ψ.imp φ).allFuture :=
  mp (DerivationTree.temporal_necessitation _
      (DerivationTree.axiom [] _ (Axiom.prop_s φ ψ) (FrameClass.base_le fc)))
    (gDistribution φ (ψ.imp φ))

/-- `G g → (F e → U g e)`: guard monotonicity from the `⊤` guard of `F e`. -/
private def untilIntroRule (guard event : Formula) :
    ⊢[fc] guard.allFuture.imp (event.someFuture.imp (Formula.untl guard event)) :=
  impTrans (gWeaken guard Formula.top) (untilMonoGuard Formula.top guard event)

/-- `H g → (P e → S g e)`, by closed time reflection. -/
private def sinceIntroRule (guard event : Formula) :
    ⊢[fc] guard.allPast.imp (event.somePast.imp (Formula.snce guard event)) :=
  reflectThm (untilIntroRule guard.reflectTime event.reflectTime) (by
    simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- Introduce `U g e` from persistent `G g` and eventual `F e`. -/
def untilIntro {guard event : Formula} (hGuard : Γ ⊢[fc] guard.allFuture)
    (hEvent : Γ ⊢[fc] event.someFuture) : Γ ⊢[fc] Formula.untl guard event :=
  ctxMp (ctxMp (thmIn (untilIntroRule guard event)) hGuard) hEvent

/-- Introduce `S g e` from persistent `H g` and past `P e`. -/
def sinceIntro {guard event : Formula} (hGuard : Γ ⊢[fc] guard.allPast)
    (hEvent : Γ ⊢[fc] event.somePast) : Γ ⊢[fc] Formula.snce guard event :=
  ctxMp (ctxMp (thmIn (sinceIntroRule guard event)) hGuard) hEvent

/-! ## Persistence through scope entry -/

/-- Temporal 4: `G P` yields `G(G P)`, so a body entered under `G` (or at an eventuality
witness) still has `G P`. -/
def futureKeep {P : Formula} (h : Γ ⊢[fc] P.allFuture) : Γ ⊢[fc] P.allFuture.allFuture :=
  ctxMp (thmIn (gTransitivity P)) h

/-- The past mirror of `futureKeep`. -/
def pastKeep {P : Formula} (h : Γ ⊢[fc] P.allPast) : Γ ⊢[fc] P.allPast.allPast :=
  ctxMp (thmIn (hTransitivity P)) h

/-- `G φ → (X ψ → X φ)`: persistent information holds at an existing successor. -/
private def nextOfAllFutureRule (φ ψ : Formula) : ⊢[fc] φ.allFuture.imp (ψ.next.imp φ.next) :=
  impTrans (gWeaken φ ψ) (untilMonoEvent ψ φ Formula.bot)

/-- `H φ → (Y ψ → Y φ)`, by closed time reflection. -/
private def prevOfAllPastRule (φ ψ : Formula) : ⊢[fc] φ.allPast.imp (ψ.prev.imp φ.prev) :=
  reflectThm (nextOfAllFutureRule φ.reflectTime ψ.reflectTime) (by
    simp only [Formula.reflectTime, Formula.reflect_time_all_future, Formula.reflect_time_next,
      Formula.reflect_time_involution])

/-- Move a persistent fact under an existing next witness. Frame-polymorphic: the witness is a
premise. With `futureKeep` and `succIndicatorAt` it supplies `X(G P)` for `generalizedNextK`. -/
def nextOfAllFuture {φ ψ : Formula} (hφ : Γ ⊢[fc] φ.allFuture) (hNext : Γ ⊢[fc] ψ.next) :
    Γ ⊢[fc] φ.next :=
  ctxMp (ctxMp (thmIn (nextOfAllFutureRule φ ψ)) hφ) hNext

/-- Move a persistent past fact under an existing previous witness. -/
def prevOfAllPast {φ ψ : Formula} (hφ : Γ ⊢[fc] φ.allPast) (hPrev : Γ ⊢[fc] ψ.prev) :
    Γ ⊢[fc] φ.prev :=
  ctxMp (ctxMp (thmIn (prevOfAllPastRule φ ψ)) hφ) hPrev

/-! ## Strict leads-to: consequence, transitivity and cases

The current form is `φ → Fψ`; the persistent form is `G(φ → Fψ)`. -/

/-- `(φ' → φ) → G(ψ → ψ') → (φ → Fψ) → (φ' → Fψ')`. -/
private def leadsToConsequenceRule (φ' φ ψ ψ' : Formula) :
    ⊢[fc] (φ'.imp φ).imp ((ψ.imp ψ').allFuture.imp
      ((φ.imp ψ.someFuture).imp (φ'.imp ψ'.someFuture))) :=
  closed3 fun hPre hPost h =>
    deductionTheorem _ φ' _
      (futureConsequence (.weakening _ _ _ hPost (List.subset_cons_self _ _))
        (ctxMp (.weakening _ _ _ h (List.subset_cons_self _ _)) (reverseDeduction hPre)))

/-- `(φ → Fψ) → G(ψ → Fχ) → (φ → Fχ)`. -/
private def leadsToTransRule (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ.someFuture).imp ((ψ.imp χ.someFuture).allFuture.imp
      (φ.imp χ.someFuture)) :=
  closed2 fun h hNext =>
    deductionTheorem _ φ _ (futureBind (.weakening _ _ _ hNext (List.subset_cons_self _ _))
      (ctxMp (.weakening _ _ _ h (List.subset_cons_self _ _)) (.assumption _ φ (by simp))))

/-- `(φ₁ → χ) → (φ₂ → χ) → (φ₁ ∨ φ₂ → χ)`. -/
private def casesRule (φ₁ φ₂ χ : Formula) :
    ⊢[fc] (φ₁.imp χ).imp ((φ₂.imp χ).imp ((φ₁.or φ₂).imp χ)) :=
  closed2 fun h₁ h₂ =>
    deductionTheorem _ _ _ (Propositional.orElim _ φ₁ φ₂ χ (.assumption _ _ (by simp))
      (.weakening _ _ _ h₁ (List.subset_cons_self _ _))
      (.weakening _ _ _ h₂ (List.subset_cons_self _ _)))

/-- `(φ' → φ) → H(ψ → ψ') → (φ → Pψ) → (φ' → Pψ')`, by closed time reflection. -/
private def pastLeadsToConsequenceRule (φ' φ ψ ψ' : Formula) :
    ⊢[fc] (φ'.imp φ).imp ((ψ.imp ψ').allPast.imp
      ((φ.imp ψ.somePast).imp (φ'.imp ψ'.somePast))) :=
  reflectThm (leadsToConsequenceRule φ'.reflectTime φ.reflectTime ψ.reflectTime ψ'.reflectTime)
    (by simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- `(φ → Pψ) → H(ψ → Pχ) → (φ → Pχ)`, by closed time reflection. -/
private def pastLeadsToTransRule (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ.somePast).imp ((ψ.imp χ.somePast).allPast.imp (φ.imp χ.somePast)) :=
  reflectThm (leadsToTransRule φ.reflectTime ψ.reflectTime χ.reflectTime)
    (by simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_some_future, Formula.reflect_time_involution])

/-- Distribute a `G`-scoped implication. -/
private def futureMp {A B : Formula} (hAB : Γ ⊢[fc] (A.imp B).allFuture)
    (hA : Γ ⊢[fc] A.allFuture) : Γ ⊢[fc] B.allFuture :=
  ctxMp (ctxMp (thmIn (gDistribution A B)) hAB) hA

/-- Distribute an `H`-scoped implication. -/
private def pastMp {A B : Formula} (hAB : Γ ⊢[fc] (A.imp B).allPast)
    (hA : Γ ⊢[fc] A.allPast) : Γ ⊢[fc] B.allPast :=
  ctxMp (ctxMp (thmIn (hDistribution A B)) hAB) hA

/-- Current leads-to consequence: strengthen the source now, weaken the target under `G`. -/
def leadsToConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] φ'.imp φ)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allFuture) (h : Γ ⊢[fc] φ.imp ψ.someFuture) :
    Γ ⊢[fc] φ'.imp ψ'.someFuture :=
  ctxMp (ctxMp (ctxMp (thmIn (leadsToConsequenceRule φ' φ ψ ψ')) hPre) hPost) h

/-- A current leads-to followed by a persistent one. -/
def leadsToTrans {φ ψ χ : Formula} (h : Γ ⊢[fc] φ.imp ψ.someFuture)
    (hNext : Γ ⊢[fc] (ψ.imp χ.someFuture).allFuture) : Γ ⊢[fc] φ.imp χ.someFuture :=
  ctxMp (ctxMp (thmIn (leadsToTransRule φ ψ χ)) h) hNext

/-- Persistent leads-to consequence. Both side conditions are `G`-scoped; temporal 4 retains
the target weakening inside the persistent body. -/
def progressConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] (φ'.imp φ).allFuture)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allFuture) (h : Γ ⊢[fc] (φ.imp ψ.someFuture).allFuture) :
    Γ ⊢[fc] (φ'.imp ψ'.someFuture).allFuture :=
  futureMp (futureMp (futureMp
    (thmIn (DerivationTree.temporal_necessitation _ (leadsToConsequenceRule φ' φ ψ ψ'))) hPre)
    (futureKeep hPost)) h

/-- Persistent finite-case composition: two persistent leads-to guarantees with a common
target cover their disjoined source. Iterate for more cases. -/
def progressCases {φ₁ φ₂ ψ : Formula} (h₁ : Γ ⊢[fc] (φ₁.imp ψ.someFuture).allFuture)
    (h₂ : Γ ⊢[fc] (φ₂.imp ψ.someFuture).allFuture) :
    Γ ⊢[fc] ((φ₁.or φ₂).imp ψ.someFuture).allFuture :=
  futureMp (futureMp
    (thmIn (DerivationTree.temporal_necessitation _ (casesRule φ₁ φ₂ ψ.someFuture))) h₁) h₂

/-- Current past leads-to consequence. -/
def pastLeadsToConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] φ'.imp φ)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allPast) (h : Γ ⊢[fc] φ.imp ψ.somePast) :
    Γ ⊢[fc] φ'.imp ψ'.somePast :=
  ctxMp (ctxMp (ctxMp (thmIn (pastLeadsToConsequenceRule φ' φ ψ ψ')) hPre) hPost) h

/-- A current past leads-to followed by a persistent one. -/
def pastLeadsToTrans {φ ψ χ : Formula} (h : Γ ⊢[fc] φ.imp ψ.somePast)
    (hNext : Γ ⊢[fc] (ψ.imp χ.somePast).allPast) : Γ ⊢[fc] φ.imp χ.somePast :=
  ctxMp (ctxMp (thmIn (pastLeadsToTransRule φ ψ χ)) h) hNext

/-- Persistent past leads-to consequence; `hPost` is retained by past temporal 4. -/
def pastProgressConsequence {φ' φ ψ ψ' : Formula} (hPre : Γ ⊢[fc] (φ'.imp φ).allPast)
    (hPost : Γ ⊢[fc] (ψ.imp ψ').allPast) (h : Γ ⊢[fc] (φ.imp ψ.somePast).allPast) :
    Γ ⊢[fc] (φ'.imp ψ'.somePast).allPast :=
  pastMp (pastMp (pastMp
    (thmIn (pastNecessitation _ (pastLeadsToConsequenceRule φ' φ ψ ψ'))) hPre)
    (pastKeep hPost)) h

/-- Persistent past finite-case composition. -/
def pastProgressCases {φ₁ φ₂ ψ : Formula} (h₁ : Γ ⊢[fc] (φ₁.imp ψ.somePast).allPast)
    (h₂ : Γ ⊢[fc] (φ₂.imp ψ.somePast).allPast) :
    Γ ⊢[fc] ((φ₁.or φ₂).imp ψ.somePast).allPast :=
  pastMp (pastMp (thmIn (pastNecessitation _ (casesRule φ₁ φ₂ ψ.somePast))) h₁) h₂

end FormalSystem.Theorems.ProofMode

/-! ## TM⁺

Each rule transfers the closed TM schema at fresh atoms with `ofTMSubst`, substituting the TM⁺
arguments; the expected types check each substitution against the TM⁺ statement
definitionally. Contextual reflection is native, through `liftContext`. -/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

private def atom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign4 (A B C D : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | some 1 => B
  | some 2 => C
  | _ => D

/-- Apply a transferred closed binary schema in context. -/
private def apply2 {σ : Atom → PlusFormula} {A B C : Formula}
    (rule : DerivationTree fc [] (A.imp (B.imp C)))
    (hA : PlusDerivationTree fc Γ (substPlus σ A)) (hB : PlusDerivationTree fc Γ (substPlus σ B)) :
    PlusDerivationTree fc Γ (substPlus σ C) :=
  ctxMp (ctxMp (thmIn (.ofTMSubst σ rule)) hA) hB

/-- Apply a transferred closed ternary schema in context. -/
private def apply3 {σ : Atom → PlusFormula} {A B C D : Formula}
    (rule : DerivationTree fc [] (A.imp (B.imp (C.imp D))))
    (hA : PlusDerivationTree fc Γ (substPlus σ A)) (hB : PlusDerivationTree fc Γ (substPlus σ B))
    (hC : PlusDerivationTree fc Γ (substPlus σ C)) : PlusDerivationTree fc Γ (substPlus σ D) :=
  ctxMp (ctxMp (ctxMp (thmIn (.ofTMSubst σ rule)) hA) hB) hC

/-! ### Fold and unfold -/

/-- `X e ∨ X(g ∧ U g e) → U g e`, at every frame class. -/
def untilFoldRule (guard event : PlusFormula) :
    PlusDerivationTree fc [] (((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event)))).imp (.untl guard event)) :=
  .ofTMSubst (assign4 guard event guard guard) (Theorems.ProofMode.untilFoldRule (atom 0) (atom 1))

/-- `Y e ∨ Y(g ∧ S g e) → S g e`, at every frame class. -/
def sinceFoldRule (guard event : PlusFormula) :
    PlusDerivationTree fc [] (((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event)))).imp (.snce guard event)) :=
  .ofTMSubst (assign4 guard event guard guard) (Theorems.ProofMode.sinceFoldRule (atom 0) (atom 1))

/-- `U g e → X e ∨ X(g ∧ U g e)`, requiring integer time. -/
def untilUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : PlusFormula) :
    PlusDerivationTree fc [] ((PlusFormula.untl guard event).imp ((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event))))) :=
  .ofTMSubst (assign4 guard event guard guard)
    (Theorems.ProofMode.untilUnfoldRule hFrame (atom 0) (atom 1))

/-- `S g e → Y e ∨ Y(g ∧ S g e)`, requiring integer time. -/
def sinceUnfoldRule (hFrame : FrameClass.ZTime ≤ fc) (guard event : PlusFormula) :
    PlusDerivationTree fc [] ((PlusFormula.snce guard event).imp ((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event))))) :=
  .ofTMSubst (assign4 guard event guard guard)
    (Theorems.ProofMode.sinceUnfoldRule hFrame (atom 0) (atom 1))

/-- Reduce an Until goal to its one-step disjunction, at every frame class. -/
def untilFold {guard event : PlusFormula}
    (h : PlusDerivationTree fc Γ ((PlusFormula.next event).or
      (PlusFormula.next (guard.and (.untl guard event))))) :
    PlusDerivationTree fc Γ (.untl guard event) :=
  ctxMp (thmIn (untilFoldRule guard event)) h

/-- Reduce a Since goal to its one-step disjunction, at every frame class. -/
def sinceFold {guard event : PlusFormula}
    (h : PlusDerivationTree fc Γ ((PlusFormula.prev event).or
      (PlusFormula.prev (guard.and (.snce guard event))))) :
    PlusDerivationTree fc Γ (.snce guard event) :=
  ctxMp (thmIn (sinceFoldRule guard event)) h

/-- Unfold an Until fact one step on integer time, keeping `X` in both branches. -/
def untilUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : PlusFormula}
    (h : PlusDerivationTree fc Γ (.untl guard event))
    (hEvent : PlusDerivationTree fc (PlusFormula.next event :: Γ) C)
    (hContinue : PlusDerivationTree fc
      (PlusFormula.next (guard.and (.untl guard event)) :: Γ) C) :
    PlusDerivationTree fc Γ C :=
  orCases (ctxMp (thmIn (untilUnfoldRule hFrame guard event)) h) hEvent hContinue

/-- Unfold a Since fact one step on integer time, keeping `Y` in both branches. -/
def sinceUnfoldCases (hFrame : FrameClass.ZTime ≤ fc) {guard event C : PlusFormula}
    (h : PlusDerivationTree fc Γ (.snce guard event))
    (hEvent : PlusDerivationTree fc (PlusFormula.prev event :: Γ) C)
    (hContinue : PlusDerivationTree fc
      (PlusFormula.prev (guard.and (.snce guard event)) :: Γ) C) :
    PlusDerivationTree fc Γ C :=
  orCases (ctxMp (thmIn (sinceUnfoldRule hFrame guard event)) h) hEvent hContinue

/-! ### Contextual time reflection -/

/-- Reflect a TM⁺ derivation with its whole context, by native `liftContext`. Reflection
commutes with implication definitionally, so its distribution schema is identity. -/
def reflectContext (Γ : PlusContext) (A : PlusFormula) (h : PlusDerivationTree fc Γ A) :
    PlusDerivationTree fc (Γ.map PlusFormula.reflectTime) A.reflectTime :=
  liftContext PlusFormula.reflectTime (fun A h => .time_reflection A h)
    (fun A B => identity (A.reflectTime.imp B.reflectTime)) Γ A h

/-- Reflecting a TM⁺ context twice returns it. -/
theorem reflectContext_involution (Γ : PlusContext) :
    (Γ.map PlusFormula.reflectTime).map PlusFormula.reflectTime = Γ := by
  simp [Function.comp_def, PlusFormula.reflect_time_involution]

/-- Goal-direction reflection over the reflected context. -/
def reflectGoal {A : PlusFormula}
    (h : PlusDerivationTree fc (Γ.map PlusFormula.reflectTime) A.reflectTime) :
    PlusDerivationTree fc Γ A := by
  have d := reflectContext _ _ h
  rwa [reflectContext_involution, PlusFormula.reflect_time_involution] at d

/-! ### Introduction and persistence -/

/-- Introduce `U g e` from persistent `G g` and eventual `F e`. -/
def untilIntro {guard event : PlusFormula} (hGuard : PlusDerivationTree fc Γ guard.allFuture)
    (hEvent : PlusDerivationTree fc Γ event.someFuture) :
    PlusDerivationTree fc Γ (.untl guard event) :=
  apply2 (σ := assign4 guard event guard guard)
    (Theorems.ProofMode.untilIntroRule (atom 0) (atom 1)) hGuard hEvent

/-- Introduce `S g e` from persistent `H g` and past `P e`. -/
def sinceIntro {guard event : PlusFormula} (hGuard : PlusDerivationTree fc Γ guard.allPast)
    (hEvent : PlusDerivationTree fc Γ event.somePast) :
    PlusDerivationTree fc Γ (.snce guard event) :=
  apply2 (σ := assign4 guard event guard guard)
    (Theorems.ProofMode.sinceIntroRule (atom 0) (atom 1)) hGuard hEvent

/-- Temporal 4: retain `G P` inside a body entered under `G` or at an eventuality witness. -/
def futureKeep {P : PlusFormula} (h : PlusDerivationTree fc Γ P.allFuture) :
    PlusDerivationTree fc Γ P.allFuture.allFuture :=
  ctxMp (thmIn (futureIteration P)) h

/-- Past temporal 4. -/
def pastKeep {P : PlusFormula} (h : PlusDerivationTree fc Γ P.allPast) :
    PlusDerivationTree fc Γ P.allPast.allPast :=
  ctxMp (thmIn (pastIteration P)) h

/-- Move a persistent fact under an existing next witness; no successor is asserted. -/
def nextOfAllFuture {φ ψ : PlusFormula} (hφ : PlusDerivationTree fc Γ φ.allFuture)
    (hNext : PlusDerivationTree fc Γ ψ.next) : PlusDerivationTree fc Γ φ.next :=
  apply2 (σ := assign4 φ ψ φ φ) (Theorems.ProofMode.nextOfAllFutureRule (atom 0) (atom 1)) hφ hNext

/-- Move a persistent past fact under an existing previous witness. -/
def prevOfAllPast {φ ψ : PlusFormula} (hφ : PlusDerivationTree fc Γ φ.allPast)
    (hPrev : PlusDerivationTree fc Γ ψ.prev) : PlusDerivationTree fc Γ φ.prev :=
  apply2 (σ := assign4 φ ψ φ φ) (Theorems.ProofMode.prevOfAllPastRule (atom 0) (atom 1)) hφ hPrev

/-! ### Strict leads-to -/

/-- Current leads-to consequence: strengthen the source now, weaken the target under `G`. -/
def leadsToConsequence {φ' φ ψ ψ' : PlusFormula} (hPre : PlusDerivationTree fc Γ (φ'.imp φ))
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allFuture)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture)) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.someFuture) :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.leadsToConsequenceRule (atom 0) (atom 1)
    (atom 2) (atom 3)) hPre hPost h

/-- A current leads-to followed by a persistent one. -/
def leadsToTrans {φ ψ χ : PlusFormula} (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture))
    (hNext : PlusDerivationTree fc Γ (ψ.imp χ.someFuture).allFuture) :
    PlusDerivationTree fc Γ (φ.imp χ.someFuture) :=
  apply2 (σ := assign4 φ ψ χ χ)
    (Theorems.ProofMode.leadsToTransRule (atom 0) (atom 1) (atom 2)) h hNext

/-- Persistent leads-to consequence, with both side conditions `G`-scoped. -/
def progressConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ).allFuture)
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allFuture)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.someFuture).allFuture) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.someFuture).allFuture :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.closed3 fun hPre hPost h =>
    Theorems.ProofMode.progressConsequence (φ' := atom 0) (φ := atom 1) (ψ := atom 2)
      (ψ' := atom 3) hPre hPost h) hPre hPost h

/-- Persistent finite-case composition over a disjoined source. -/
def progressCases {φ₁ φ₂ ψ : PlusFormula}
    (h₁ : PlusDerivationTree fc Γ (φ₁.imp ψ.someFuture).allFuture)
    (h₂ : PlusDerivationTree fc Γ (φ₂.imp ψ.someFuture).allFuture) :
    PlusDerivationTree fc Γ ((φ₁.or φ₂).imp ψ.someFuture).allFuture :=
  apply2 (σ := assign4 φ₁ φ₂ ψ ψ) (Theorems.ProofMode.closed2 fun h₁ h₂ =>
    Theorems.ProofMode.progressCases (φ₁ := atom 0) (φ₂ := atom 1) (ψ := atom 2) h₁ h₂) h₁ h₂

/-- Current past leads-to consequence. -/
def pastLeadsToConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ))
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allPast)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast)) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.somePast) :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.pastLeadsToConsequenceRule (atom 0) (atom 1)
    (atom 2) (atom 3)) hPre hPost h

/-- A current past leads-to followed by a persistent one. -/
def pastLeadsToTrans {φ ψ χ : PlusFormula} (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast))
    (hNext : PlusDerivationTree fc Γ (ψ.imp χ.somePast).allPast) :
    PlusDerivationTree fc Γ (φ.imp χ.somePast) :=
  apply2 (σ := assign4 φ ψ χ χ)
    (Theorems.ProofMode.pastLeadsToTransRule (atom 0) (atom 1) (atom 2)) h hNext

/-- Persistent past leads-to consequence. -/
def pastProgressConsequence {φ' φ ψ ψ' : PlusFormula}
    (hPre : PlusDerivationTree fc Γ (φ'.imp φ).allPast)
    (hPost : PlusDerivationTree fc Γ (ψ.imp ψ').allPast)
    (h : PlusDerivationTree fc Γ (φ.imp ψ.somePast).allPast) :
    PlusDerivationTree fc Γ (φ'.imp ψ'.somePast).allPast :=
  apply3 (σ := assign4 φ' φ ψ ψ') (Theorems.ProofMode.closed3 fun hPre hPost h =>
    Theorems.ProofMode.pastProgressConsequence (φ' := atom 0) (φ := atom 1) (ψ := atom 2)
      (ψ' := atom 3) hPre hPost h) hPre hPost h

/-- Persistent past finite-case composition. -/
def pastProgressCases {φ₁ φ₂ ψ : PlusFormula}
    (h₁ : PlusDerivationTree fc Γ (φ₁.imp ψ.somePast).allPast)
    (h₂ : PlusDerivationTree fc Γ (φ₂.imp ψ.somePast).allPast) :
    PlusDerivationTree fc Γ ((φ₁.or φ₂).imp ψ.somePast).allPast :=
  apply2 (σ := assign4 φ₁ φ₂ ψ ψ) (Theorems.ProofMode.closed2 fun h₁ h₂ =>
    Theorems.ProofMode.pastProgressCases (φ₁ := atom 0) (φ₂ := atom 1) (ψ := atom 2) h₁ h₂)
    h₁ h₂

end FormalSystem.PlusLanguage.ProofMode

/-! ## Kept facts at an adjacent point -/

namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Theorems.Combinators

variable {fc : FrameClass} {Γ : Context}

/-- `G P` yields `X(G P)` on integer time: temporal 4, then the successor indicator. -/
def nextKeep (hFrame : FrameClass.ZTime ≤ fc) {P : Formula} (h : Γ ⊢[fc] P.allFuture) :
    Γ ⊢[fc] P.allFuture.next :=
  nextOfAllFuture (futureKeep h) (thmIn (DiscreteUnfolding.succIndicatorAt hFrame))

/-- `H P` yields `Y(H P)` on integer time: past temporal 4, then the predecessor indicator. -/
def prevKeep (hFrame : FrameClass.ZTime ≤ fc) {P : Formula} (h : Γ ⊢[fc] P.allPast) :
    Γ ⊢[fc] P.allPast.prev :=
  prevOfAllPast (pastKeep h) (thmIn (DiscreteUnfolding.prevIndicatorAt hFrame))

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.ProofSystem (FrameClass DerivationTree)

variable {fc : FrameClass} {Γ : PlusContext}

/-- TM⁺ `G P` yields `X(G P)` on integer time, for arbitrary TM⁺ `P`. -/
def nextKeep (hFrame : FrameClass.ZTime ≤ fc) {P : PlusFormula}
    (h : PlusDerivationTree fc Γ P.allFuture) : PlusDerivationTree fc Γ P.allFuture.next :=
  nextOfAllFuture (ψ := PlusFormula.top) (futureKeep h)
    (thmIn (.ofTMSubst (fun _ => P)
      (FormalSystem.Theorems.DiscreteUnfolding.succIndicatorAt hFrame)))

/-- TM⁺ `H P` yields `Y(H P)` on integer time, for arbitrary TM⁺ `P`. -/
def prevKeep (hFrame : FrameClass.ZTime ≤ fc) {P : PlusFormula}
    (h : PlusDerivationTree fc Γ P.allPast) : PlusDerivationTree fc Γ P.allPast.prev :=
  prevOfAllPast (ψ := PlusFormula.top) (pastKeep h)
    (thmIn (.ofTMSubst (fun _ => P)
      (FormalSystem.Theorems.DiscreteUnfolding.prevIndicatorAt hFrame)))

end FormalSystem.PlusLanguage.ProofMode


namespace FormalSystem.Theorems.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Theorems.Combinators

/-- Native equivalence with the exact inclusive expansion; guard first, event second. -/
def inclusiveUntilIff {fc : FrameClass} (g e : Formula) :
    DerivationTree fc []
      (((Formula.inclusiveUntil g e).imp (e.or (g.and (Formula.untl g e)))).and
        ((e.or (g.and (Formula.untl g e))).imp (Formula.inclusiveUntil g e))) :=
  andIntro (FormalSystem.Theorems.Combinators.identity _)
    (FormalSystem.Theorems.Combinators.identity _)

/-- Native equivalence with the exact inclusive expansion; guard first, event second. -/
def inclusiveSinceIff {fc : FrameClass} (g e : Formula) :
    DerivationTree fc []
      (((Formula.inclusiveSince g e).imp (e.or (g.and (Formula.snce g e)))).and
        ((e.or (g.and (Formula.snce g e))).imp (Formula.inclusiveSince g e))) :=
  andIntro (FormalSystem.Theorems.Combinators.identity _)
    (FormalSystem.Theorems.Combinators.identity _)

end FormalSystem.Theorems.ProofMode

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Theorems.Combinators

/-- Native equivalence with the exact inclusive expansion; guard first, event second. -/
def inclusiveUntilIff {fc : FrameClass} (g e : PlusFormula) :
    PlusDerivationTree fc []
      (((PlusFormula.inclusiveUntil g e).imp (e.or (g.and (PlusFormula.untl g e)))).and
        ((e.or (g.and (PlusFormula.untl g e))).imp (PlusFormula.inclusiveUntil g e))) :=
  andIntro (identity _) (identity _)

/-- Native equivalence with the exact inclusive expansion; guard first, event second. -/
def inclusiveSinceIff {fc : FrameClass} (g e : PlusFormula) :
    PlusDerivationTree fc []
      (((PlusFormula.inclusiveSince g e).imp (e.or (g.and (PlusFormula.snce g e)))).and
        ((e.or (g.and (PlusFormula.snce g e))).imp (PlusFormula.inclusiveSince g e))) :=
  andIntro (identity _) (identity _)

end FormalSystem.PlusLanguage.ProofMode
