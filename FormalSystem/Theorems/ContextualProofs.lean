/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Theorems.Combinators

/-!
# Contextual Proofs - Derivations from Non-Empty Contexts

This module provides computable derivation trees that use non-empty contexts,
exercising the `assumption` and `weakening` inference rules. All 310 existing
registered theorems derive from empty context (`[] |- phi`), so these two
constructors never appear in the proof step dataset. This file fills that gap.

## Design Principles

1. **Computability**: All definitions are computable (no `noncomputable`).
   We import only `Derivation.lean` and `Combinators.lean`, avoiding the
   `DeductionTheorem.lean` import chain that introduces noncomputability.

2. **Hand-constructed trees**: Each derivation tree is built explicitly using
   the `DerivationTree` constructors (`assumption`, `weakening`, `modus_ponens`,
   `axiom`), not via tactics that might introduce classical reasoning.

3. **Three categories**: Propositional in context, modal in context, and
   temporal in context.

## References

* [Derivation.lean](../ProofSystem/Derivation.lean) - DerivationTree constructors
* [Combinators.lean](./Combinators.lean) - Propositional combinators
-/

namespace FormalSystem.Theorems.ContextualProofs

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

/-! ## Membership helpers for list positions

**No frame-class parameter**: `mem0`-`mem3` are `List.Mem` proofs about an arbitrary type `α`,
not derivations, so they have no frame class to be parameterised by. They are the only four
declarations in this module without an `{fc : FrameClass}` binder, and the absence is a
type-level fact rather than a `FrameClass.Base` pin.
-/
private abbrev mem0 {α : Type} {a : α} {l : List α} : a ∈ (a :: l) := List.Mem.head _
private abbrev mem1 {α : Type} {a b : α} {l : List α} : a ∈ (b :: a :: l) :=
  List.Mem.tail _ (List.Mem.head _)
private abbrev mem2 {α : Type} {a b c : α} {l : List α} : a ∈ (b :: c :: a :: l) :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))
private abbrev mem3 {α : Type} {a b c d : α} {l : List α} : a ∈ (b :: c :: d :: a :: l) :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))

/-! ## Helper: weaken from [] to Gamma -/
private def weakenEmpty {fc : FrameClass} {A : Formula} {Γ : Context}
    (d : DerivationTree fc [] A) : DerivationTree fc Γ A :=
  .weakening [] Γ A d nofun

/-! ## Helper: weaken from Gamma to (extra :: Gamma) -/
private def weakenCons {fc : FrameClass} {A : Formula} {Γ : Context} (extra : Formula)
    (d : DerivationTree fc Γ A) : DerivationTree fc (extra :: Γ) A :=
  .weakening Γ (extra :: Γ) A d (List.subset_cons_of_subset extra (List.Subset.refl Γ))

/-!
## Category A: Propositional in Context (12 theorems)
-/

/-- Identity in context: `[A] |- A`. 1 assumption step. -/
def identityInCtx {fc : FrameClass} (A : Formula) : [A] ⊢[fc] A :=
  .assumption [A] A mem0

/-- Modus ponens in context: `[A -> B, A] |- B`. 2 assumption + 1 MP. -/
def mpInContext {fc : FrameClass} (A B : Formula) : [A.imp B, A] ⊢[fc] B :=
  .modus_ponens [A.imp B, A] A B
    (.assumption _ (A.imp B) mem0)
    (.assumption _ A mem1)

/-- MP chain (2): `[A -> B, B -> C, A] |- C`. 3 assumption + 2 MP. -/
def mpChain2 {fc : FrameClass} (A B C : Formula) : [A.imp B, B.imp C, A] ⊢[fc] C :=
  let ctx := [A.imp B, B.imp C, A]
  .modus_ponens ctx B C
    (.assumption ctx (B.imp C) mem1)
    (.modus_ponens ctx A B
      (.assumption ctx (A.imp B) mem0)
      (.assumption ctx A mem2))

/-- MP chain (3): `[A -> B, B -> C, C -> D, A] |- D`. 4 assumption + 3 MP. -/
def mpChain3 {fc : FrameClass} (A B C D : Formula) : [A.imp B, B.imp C, C.imp D, A] ⊢[fc] D :=
  let ctx := [A.imp B, B.imp C, C.imp D, A]
  .modus_ponens ctx C D
    (.assumption ctx (C.imp D) mem2)
    (.modus_ponens ctx B C
      (.assumption ctx (B.imp C) mem1)
      (.modus_ponens ctx A B
        (.assumption ctx (A.imp B) mem0)
        (.assumption ctx A mem3)))

/-- Projection left: `[A -> B, A] |- A`. 1 assumption step (second element). -/
def conjProjLeft {fc : FrameClass} (A B : Formula) : [A.imp B, A] ⊢[fc] A :=
  .assumption [A.imp B, A] A mem1

/-- Projection right: `[A -> B, A] |- A -> B`. 1 assumption step (first element). -/
def conjProjRight {fc : FrameClass} (A B : Formula) : [A.imp B, A] ⊢[fc] (A.imp B) :=
  .assumption [A.imp B, A] (A.imp B) mem0

/-- Apply in context: `[A, A -> B -> C, B] |- C`. 3 assumption + 2 MP. -/
def applyInCtx {fc : FrameClass} (A B C : Formula) : [A, A.imp (B.imp C), B] ⊢[fc] C :=
  let ctx := [A, A.imp (B.imp C), B]
  .modus_ponens ctx B C
    (.modus_ponens ctx A (B.imp C)
      (.assumption ctx (A.imp (B.imp C)) mem1)
      (.assumption ctx A mem0))
    (.assumption ctx B mem2)

/-- Weakened axiom: `[psi] |- box(A) -> A`. 1 weakening + 1 axiom. -/
def weakenedAxiom {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] (Formula.box A).imp A :=
  weakenEmpty (.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc))

/-- ECQ computable: `[A, A.neg] |- B`. 2 assumption + 1 axiom + 1 weakening + 2 MP. -/
def ecqComputable {fc : FrameClass} (A B : Formula) : [A, A.neg] ⊢[fc] B :=
  let ctx := [A, A.neg]
  let bot_deriv : DerivationTree fc ctx Formula.bot :=
    .modus_ponens ctx A Formula.bot
      (.assumption ctx A.neg mem1)
      (.assumption ctx A mem0)
  let ef : DerivationTree fc ctx (Formula.bot.imp B) :=
    weakenEmpty (.axiom [] _ (Axiom.ex_falso B) (FrameClass.base_le fc))
  .modus_ponens ctx Formula.bot B ef bot_deriv

/-- Left disjunction introduction: `[A] |- A or B`.
    Uses ⊢ A → A∨B (composed from app1 + ex_falso via bCombinator). -/
def ldiComputable {fc : FrameClass} (A B : Formula) : [A] ⊢[fc] A.or B :=
  let a_imp_or : DerivationTree fc [] (A.imp (A.or B)) :=
    -- A → (¬A → B): compose A → (¬A → ⊥) with bCombinator on (⊥ → B)
    let h1 : ⊢[fc] A.imp (A.neg.imp Formula.bot) := @theoremApp1 fc A Formula.bot
    let h2 : ⊢[fc] Formula.bot.imp B := .axiom [] _ (Axiom.ex_falso B) (FrameClass.base_le fc)
    let h3 : ⊢[fc] (Formula.bot.imp B).imp ((A.neg.imp Formula.bot).imp (A.neg.imp B)) :=
      @bCombinator fc A.neg Formula.bot B
    let h4 : ⊢[fc] (A.neg.imp Formula.bot).imp (A.neg.imp B) := mp h2 h3
    impTrans h1 h4
  .modus_ponens [A] A (A.or B)
    (weakenEmpty a_imp_or)
    (.assumption [A] A mem0)

/-- Right disjunction introduction: `[B] |- A or B`.
    A∨B = ¬A→B. prop_s gives B→(¬A→B). -/
def rdiComputable {fc : FrameClass} (A B : Formula) : [B] ⊢[fc] A.or B :=
  .modus_ponens [B] B (A.neg.imp B)
    (weakenEmpty (.axiom [] _ (Axiom.prop_s B A.neg) (FrameClass.base_le fc)))
    (.assumption [B] B mem0)

/-- Conjunction introduction:
  `[A, B] |- A and B`. 2 assumption + 1 weakening + 2 MP + pairing steps. -/
def conjIntroCtx {fc : FrameClass} (A B : Formula) : [A, B] ⊢[fc] A.and B :=
  let ctx := [A, B]
  let pair_weak : DerivationTree fc ctx (A.imp (B.imp (A.and B))) :=
    weakenEmpty (pairing A B)
  let step1 : DerivationTree fc ctx (B.imp (A.and B)) :=
    .modus_ponens ctx A (B.imp (A.and B)) pair_weak (.assumption ctx A mem0)
  .modus_ponens ctx B (A.and B) step1 (.assumption ctx B mem1)

/-!
## Category B: Modal in Context (8 theorems)
-/

/-- Box elimination: `[box A] |- A`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def boxElimCtx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc] A :=
  .modus_ponens [Formula.box A] (Formula.box A) A
    (weakenEmpty (.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc)))
    (.assumption _ (Formula.box A) mem0)

/-- Box 4: `[box A] |- box(box A)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def box4Ctx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc] Formula.box (Formula.box A) :=
  .modus_ponens [Formula.box A] (Formula.box A) (Formula.box (Formula.box A))
    (weakenEmpty (DerivedAxioms.modal4 A))
    (.assumption _ (Formula.box A) mem0)

/-- Box B: `[A] |- box(diamond A)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def boxBCtx {fc : FrameClass} (A : Formula) : [A] ⊢[fc] Formula.box A.diamond :=
  .modus_ponens [A] A (Formula.box A.diamond)
    (weakenEmpty (DerivedAxioms.modalB A))
    (.assumption _ A mem0)

/-- Box to diamond: `[box A] |- diamond A`.
    Chain: □A →(T) A →(B) □◇A →(T) ◇A. -/
def boxToDiamondCtx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc] A.diamond :=
  let thm : ⊢[fc] (Formula.box A).imp A.diamond :=
    impTrans
      (impTrans
        (DerivationTree.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc))
        (DerivedAxioms.modalB A))
      (DerivationTree.axiom [] _ (Axiom.modal_t A.diamond) (FrameClass.base_le fc))
  .modus_ponens [Formula.box A] (Formula.box A) A.diamond
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-- K distribution: `[box(A -> B), box A] |- box B`. 2 assumption + 1 weakening + 1 axiom + 2 MP. -/
def kDistCtx {fc : FrameClass} (A B : Formula) : [Formula.box (A.imp B),
    Formula.box A] ⊢[fc] Formula.box B :=
  let ctx := [Formula.box (A.imp B), Formula.box A]
  let step1 :=
    .modus_ponens ctx (Formula.box (A.imp B)) ((Formula.box A).imp (Formula.box B))
      (weakenEmpty (.axiom [] _ (Axiom.modal_k_dist A B) (FrameClass.base_le fc)))
      (.assumption ctx (Formula.box (A.imp B)) mem0)
  .modus_ponens ctx (Formula.box A) (Formula.box B)
    step1
    (.assumption ctx (Formula.box A) mem1)

/-- Box pair: `[box A, box B] |- box A and box B`. 2 assumption + 1 weakening + 2 MP + pairing. -/
def boxPairCtx {fc : FrameClass} (A B : Formula) :
    [Formula.box A, Formula.box B] ⊢[fc] (Formula.box A).and (Formula.box B) :=
  let ctx := [Formula.box A, Formula.box B]
  let step1 :=
    .modus_ponens ctx (Formula.box A) ((Formula.box B).imp ((Formula.box A).and (Formula.box B)))
      (weakenEmpty (pairing (Formula.box A) (Formula.box B)))
      (.assumption ctx (Formula.box A) mem0)
  .modus_ponens ctx (Formula.box B) ((Formula.box A).and (Formula.box B))
    step1
    (.assumption ctx (Formula.box B) mem1)

/-- Diamond via B axiom: `[diamond A] |- box(diamond(diamond A))`.
    Uses modal_b at ◇A. -/
def diamond5Ctx {fc : FrameClass} (A : Formula) : [A.diamond] ⊢[fc] Formula.box A.diamond.diamond :=
  .modus_ponens [A.diamond] A.diamond (Formula.box A.diamond.diamond)
    (weakenEmpty (DerivedAxioms.modalB A.diamond))
    (.assumption _ A.diamond mem0)

/-- Box to future: `[box A] |- G(A)`. Uses MF + T composition. -/
def boxToFutureCtx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc] A.allFuture :=
  let thm := impTrans
    (DerivationTree.axiom [] _ (Axiom.modal_future A) (FrameClass.base_le fc))
    (DerivationTree.axiom [] _ (Axiom.modal_t A.allFuture) (FrameClass.base_le fc))
  .modus_ponens [Formula.box A] (Formula.box A) A.allFuture
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-!
## Category C: Temporal in Context (8 theorems)
-/

/-- Temporal MP in enriched context: `[A -> B, A, G(A -> B), G(A)] |- B`. 2 assumption + 1 MP. -/
def tempKCtx {fc : FrameClass} (A B : Formula) :
    [A.imp B, A, (A.imp B).allFuture, A.allFuture] ⊢[fc] B :=
  let ctx := [A.imp B, A, (A.imp B).allFuture, A.allFuture]
  .modus_ponens ctx A B
    (.assumption ctx (A.imp B) mem0)
    (.assumption ctx A mem1)

/-- Connect future in context: `[A] |- G(P(A))`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def connectFutureCtx {fc : FrameClass} (A : Formula) : [A] ⊢[fc] A.somePast.allFuture :=
  .modus_ponens [A] A A.somePast.allFuture
    (weakenEmpty (.axiom [] _ (Axiom.connect_future A) (FrameClass.base_le fc)))
    (.assumption _ A mem0)

/-- Connect past in context: `[A] |- H(F(A))`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def connectPastCtx {fc : FrameClass} (A : Formula) : [A] ⊢[fc] A.someFuture.allPast :=
  .modus_ponens [A] A A.someFuture.allPast
    (weakenEmpty (DerivedAxioms.connectPast A))
    (.assumption _ A mem0)

/-- Box future in context: `[box A] |- G(box A)`. Uses temporalFutureDerived. -/
def boxFutureCtx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc]
    (Formula.box A).allFuture :=
  .modus_ponens [Formula.box A] (Formula.box A) (Formula.box A).allFuture
    (weakenEmpty (temporalFutureDerived A))
    (.assumption _ (Formula.box A) mem0)

/-- Box past in context: `[box A] |- H(F(A))`. Chain: □A →(T) A →(connect_past) H(F(A)). -/
def boxPastCtx {fc : FrameClass} (A : Formula) : [Formula.box A] ⊢[fc] A.someFuture.allPast :=
  let thm := impTrans
    (DerivationTree.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc))
    (DerivedAxioms.connectPast A)
  .modus_ponens [Formula.box A] (Formula.box A) A.someFuture.allPast
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-- Until implies F in context:
  `[U(psi, phi)] |- F(psi)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def untilFCtx {fc : FrameClass} (phi psi : Formula) : [Formula.untl phi psi] ⊢[fc] psi.someFuture :=
  .modus_ponens [Formula.untl phi psi] (Formula.untl phi psi) psi.someFuture
    (weakenEmpty (.axiom [] _ (Axiom.until_F phi psi) (FrameClass.base_le fc)))
    (.assumption _ (Formula.untl phi psi) mem0)

/-- Since implies P in context:
  `[S(psi, phi)] |- P(psi)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def sincePCtx {fc : FrameClass} (phi psi : Formula) : [Formula.snce phi psi] ⊢[fc] psi.somePast :=
  .modus_ponens [Formula.snce phi psi] (Formula.snce phi psi) psi.somePast
    (weakenEmpty (DerivedAxioms.sinceP phi psi))
    (.assumption _ (Formula.snce phi psi) mem0)

/-- Serial future in context: `[A] |- F(top)`. 2 weakening + 1 axiom + identity steps + 1 MP. -/
def serialFutureCtx {fc : FrameClass} (A : Formula) : [A] ⊢[fc] Formula.top.someFuture :=
  let top_ctx : DerivationTree fc [A] Formula.top :=
    weakenEmpty (identity Formula.bot)
  let sf_ctx : DerivationTree fc [A] (Formula.top.imp Formula.top.someFuture) :=
    weakenEmpty (DerivedAxioms.serialFutureImp)
  .modus_ponens [A] Formula.top Formula.top.someFuture sf_ctx top_ctx

/-!
## Weakening Variants

These take existing contextual derivations and weaken them to larger contexts,
adding explicit weakening steps. `weakenCons X d` produces `(X :: Gamma) |- A`.
-/

/-- `[C, A -> B, A] |- B` -/
def mpInContextWeak {fc : FrameClass} (A B C : Formula) : [C, A.imp B, A] ⊢[fc] B :=
  weakenCons C (mpInContext A B)

/-- `[D, A -> B, B -> C, A] |- C` -/
def mpChain2Weak {fc : FrameClass} (A B C D : Formula) : [D, A.imp B, B.imp C, A] ⊢[fc] C :=
  weakenCons D (mpChain2 A B C)

/-- `[C, A, A.neg] |- B` -/
def ecqComputableWeak {fc : FrameClass} (A B C : Formula) : [C, A, A.neg] ⊢[fc] B :=
  weakenCons C (ecqComputable A B)

/-- `[B, box A] |- A` -/
def boxElimCtxWeak {fc : FrameClass} (A B : Formula) : [B, Formula.box A] ⊢[fc] A :=
  weakenCons B (boxElimCtx A)

/-- `[C, box(A -> B), box A] |- box B` -/
def kDistCtxWeak {fc : FrameClass} (A B C : Formula) : [C, Formula.box (A.imp B),
    Formula.box A] ⊢[fc] Formula.box B :=
  weakenCons C (kDistCtx A B)

/-- `[B, box A] |- box(box A)` -/
def box4CtxWeak {fc : FrameClass} (A B : Formula) : [B,
    Formula.box A] ⊢[fc] Formula.box (Formula.box A) :=
  weakenCons B (box4Ctx A)

/-- `[B, A] |- box(diamond A)` -/
def boxBCtxWeak {fc : FrameClass} (A B : Formula) : [B, A] ⊢[fc] Formula.box A.diamond :=
  weakenCons B (boxBCtx A)

/-- `[B, A] |- G(P(A))` -/
def connectFutureCtxWeak {fc : FrameClass} (A B : Formula) : [B, A] ⊢[fc] A.somePast.allFuture :=
  weakenCons B (connectFutureCtx A)

/-- `[B, A] |- H(F(A))` -/
def connectPastCtxWeak {fc : FrameClass} (A B : Formula) : [B, A] ⊢[fc] A.someFuture.allPast :=
  weakenCons B (connectPastCtx A)

/-- `[C, U(psi, phi)] |- F(psi)` -/
def untilFCtxWeak {fc : FrameClass} (phi psi C : Formula) : [C,
    Formula.untl phi psi] ⊢[fc] psi.someFuture :=
  weakenCons C (untilFCtx phi psi)

/-- `[C, S(psi, phi)] |- P(psi)` -/
def sincePCtxWeak {fc : FrameClass} (phi psi C : Formula) : [C,
    Formula.snce phi psi] ⊢[fc] psi.somePast :=
  weakenCons C (sincePCtx phi psi)

/-- `[B, A] |- A` -/
def identityInCtxWeak {fc : FrameClass} (A B : Formula) : [B, A] ⊢[fc] A :=
  weakenCons B (identityInCtx A)

/-- `[D, A, A -> B -> C, B] |- C` -/
def applyInCtxWeak {fc : FrameClass} (A B C D : Formula) : [D, A, A.imp (B.imp C), B] ⊢[fc] C :=
  weakenCons D (applyInCtx A B C)

/-- `[C, A, B] |- A and B` -/
def conjIntroCtxWeak {fc : FrameClass} (A B C : Formula) : [C, A, B] ⊢[fc] A.and B :=
  weakenCons C (conjIntroCtx A B)

/-- `[C, box A, box B] |- box A and box B` -/
def boxPairCtxWeak {fc : FrameClass} (A B C : Formula) :
    [C, Formula.box A, Formula.box B] ⊢[fc] (Formula.box A).and (Formula.box B) :=
  weakenCons C (boxPairCtx A B)

/-- `[B, box A] |- G(box A)` -/
def boxFutureCtxWeak {fc : FrameClass} (A B : Formula) : [B,
    Formula.box A] ⊢[fc] (Formula.box A).allFuture :=
  weakenCons B (boxFutureCtx A)

/-- `[B, box A] |- H(F(A))` -/
def boxPastCtxWeak {fc : FrameClass} (A B : Formula) : [B,
    Formula.box A] ⊢[fc] A.someFuture.allPast :=
  weakenCons B (boxPastCtx A)

/-- `[B, A] |- F(top)` -/
def serialFutureCtxWeak {fc : FrameClass} (A B : Formula) : [B, A] ⊢[fc] Formula.top.someFuture :=
  weakenCons B (serialFutureCtx A)

/-!
## Pure Weakening Entries

Existing empty-context theorems weakened to non-empty contexts.
Each generates at least 1 weakening step.
-/

/-- `[psi] |- A -> A` -/
def identityWeakened {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] A.imp A :=
  weakenEmpty (identity A)

/-- `[psi] |- (B -> C) -> (A -> B) -> (A -> C)` -/
def bCombinatorWeakened {fc : FrameClass} {A B C : Formula} (psi : Formula) :
    [psi] ⊢[fc] (B.imp C).imp ((A.imp B).imp (A.imp C)) :=
  weakenEmpty bCombinator

/-- `[psi] |- A -> neg(neg A)` -/
def dniWeakened {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] A.imp A.neg.neg :=
  weakenEmpty (notNotIntro A)

/-- `[psi] |- A -> G(P(A))` -/
def connectFutureWeakened {fc : FrameClass}
    (A psi : Formula) : [psi] ⊢[fc] A.imp A.somePast.allFuture :=
  weakenEmpty (.axiom [] _ (Axiom.connect_future A) (FrameClass.base_le fc))

/-- `[psi] |- A -> H(F(A))` -/
def connectPastWeakened {fc : FrameClass}
    (A psi : Formula) : [psi] ⊢[fc] A.imp A.someFuture.allPast :=
  weakenEmpty (DerivedAxioms.connectPast A)

/-- `[psi] |- box(A) -> G(box(A))` -/
def tempFutureWeakened {fc : FrameClass} (A psi : Formula) :
    [psi] ⊢[fc] (Formula.box A).imp (Formula.box A).allFuture :=
  weakenEmpty (temporalFutureDerived A)

/-- `[psi] |- A -> B -> A and B` -/
def pairingWeakened {fc : FrameClass} (A B psi : Formula) : [psi] ⊢[fc] A.imp (B.imp (A.and B)) :=
  weakenEmpty (pairing A B)

/-- `[psi] |- box(A) -> A` -/
def modalTWeakened {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] (Formula.box A).imp A :=
  weakenEmpty (.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc))

/-- `[psi] |- box(A) -> box(box(A))` -/
def modal4Weakened {fc : FrameClass} (A psi : Formula) :
    [psi] ⊢[fc] (Formula.box A).imp (Formula.box (Formula.box A)) :=
  weakenEmpty (DerivedAxioms.modal4 A)

/-- `[psi] |- A -> box(diamond(A))` -/
def modalBWeakened {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] A.imp
    (Formula.box A.diamond) :=
  weakenEmpty (DerivedAxioms.modalB A)

/-- `[psi] |- box(A -> B) -> (box A -> box B)` -/
def modalKDistWeakened {fc : FrameClass} (A B psi : Formula) :
    [psi] ⊢[fc] (Formula.box (A.imp B)).imp ((Formula.box A).imp (Formula.box B)) :=
  weakenEmpty (.axiom [] _ (Axiom.modal_k_dist A B) (FrameClass.base_le fc))

/-- `[psi] |- bot -> A` -/
def exFalsoWeakened {fc : FrameClass} (A psi : Formula) : [psi] ⊢[fc] Formula.bot.imp A :=
  weakenEmpty (.axiom [] _ (Axiom.ex_falso A) (FrameClass.base_le fc))

/-- `[psi] |- (A -> (B -> C)) -> ((A -> B) -> (A -> C))` -/
def propKWeakened {fc : FrameClass} (A B C psi : Formula) :
    [psi] ⊢[fc] (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
  weakenEmpty (.axiom [] _ (Axiom.prop_k A B C) (FrameClass.base_le fc))

/-- `[psi] |- A -> (B -> A)` -/
def propSWeakened {fc : FrameClass} (A B psi : Formula) : [psi] ⊢[fc] A.imp (B.imp A) :=
  weakenEmpty (.axiom [] _ (Axiom.prop_s A B) (FrameClass.base_le fc))

/-- `[psi] |- U(B, A) -> F(B)` -/
def untilFWeakened {fc : FrameClass} (A B psi : Formula) : [psi] ⊢[fc]
    (Formula.untl A B).imp B.someFuture :=
  weakenEmpty (.axiom [] _ (Axiom.until_F A B) (FrameClass.base_le fc))

/-- `[psi] |- S(B, A) -> P(B)` -/
def sincePWeakened {fc : FrameClass} (A B psi : Formula) : [psi] ⊢[fc]
    (Formula.snce A B).imp B.somePast :=
  weakenEmpty (DerivedAxioms.sinceP A B)

/-- `[psi] |- top -> F(top)` -/
def serialFutureWeakened {fc : FrameClass}
    (psi : Formula) : [psi] ⊢[fc] Formula.top.imp Formula.top.someFuture :=
  weakenEmpty (DerivedAxioms.serialFutureImp)

/-- `[psi] |- top -> P(top)` -/
def serialPastWeakened {fc : FrameClass}
    (psi : Formula) : [psi] ⊢[fc] Formula.top.imp Formula.top.somePast :=
  weakenEmpty (DerivedAxioms.serialPast)

/-- `[psi] |- (A -> B -> C) -> (B -> A -> C)` -/
def theoremFlipWeakened {fc : FrameClass} {A B C : Formula} (psi : Formula) :
    [psi] ⊢[fc] (A.imp (B.imp C)).imp (B.imp (A.imp C)) :=
  weakenEmpty theoremFlip

/-- `[psi] |- A -> (A -> B) -> B` -/
def theoremApp1Weakened {fc : FrameClass} {A B : Formula} (psi : Formula) : [psi] ⊢[fc] A.imp
    ((A.imp B).imp B) :=
  weakenEmpty theoremApp1

end FormalSystem.Theorems.ContextualProofs
