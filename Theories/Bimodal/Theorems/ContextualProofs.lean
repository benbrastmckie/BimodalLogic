import Bimodal.ProofSystem.Derivation
import Bimodal.Theorems.Combinators

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

namespace Bimodal.Theorems.ContextualProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

/-! ## Membership helpers for list positions -/
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
private def weakenCons {A : Formula} {Γ : Context} (extra : Formula)
    (d : DerivationTree .Base Γ A) : DerivationTree .Base (extra :: Γ) A :=
  .weakening Γ (extra :: Γ) A d (List.subset_cons_of_subset extra (List.Subset.refl Γ))

/-!
## Category A: Propositional in Context (12 theorems)
-/

/-- Identity in context: `[A] |- A`. 1 assumption step. -/
def identity_in_ctx (A : Formula) : [A] ⊢ A :=
  .assumption [A] A mem0

/-- Modus ponens in context: `[A -> B, A] |- B`. 2 assumption + 1 MP. -/
def mp_in_context (A B : Formula) : [A.imp B, A] ⊢ B :=
  .modus_ponens [A.imp B, A] A B
    (.assumption _ (A.imp B) mem0)
    (.assumption _ A mem1)

/-- MP chain (2): `[A -> B, B -> C, A] |- C`. 3 assumption + 2 MP. -/
def mp_chain_2 (A B C : Formula) : [A.imp B, B.imp C, A] ⊢ C :=
  let ctx := [A.imp B, B.imp C, A]
  .modus_ponens ctx B C
    (.assumption ctx (B.imp C) mem1)
    (.modus_ponens ctx A B
      (.assumption ctx (A.imp B) mem0)
      (.assumption ctx A mem2))

/-- MP chain (3): `[A -> B, B -> C, C -> D, A] |- D`. 4 assumption + 3 MP. -/
def mp_chain_3 (A B C D : Formula) : [A.imp B, B.imp C, C.imp D, A] ⊢ D :=
  let ctx := [A.imp B, B.imp C, C.imp D, A]
  .modus_ponens ctx C D
    (.assumption ctx (C.imp D) mem2)
    (.modus_ponens ctx B C
      (.assumption ctx (B.imp C) mem1)
      (.modus_ponens ctx A B
        (.assumption ctx (A.imp B) mem0)
        (.assumption ctx A mem3)))

/-- Projection left: `[A -> B, A] |- A`. 1 assumption step (second element). -/
def conj_proj_left (A B : Formula) : [A.imp B, A] ⊢ A :=
  .assumption [A.imp B, A] A mem1

/-- Projection right: `[A -> B, A] |- A -> B`. 1 assumption step (first element). -/
def conj_proj_right (A B : Formula) : [A.imp B, A] ⊢ (A.imp B) :=
  .assumption [A.imp B, A] (A.imp B) mem0

/-- Apply in context: `[A, A -> B -> C, B] |- C`. 3 assumption + 2 MP. -/
def apply_in_ctx (A B C : Formula) : [A, A.imp (B.imp C), B] ⊢ C :=
  let ctx := [A, A.imp (B.imp C), B]
  .modus_ponens ctx B C
    (.modus_ponens ctx A (B.imp C)
      (.assumption ctx (A.imp (B.imp C)) mem1)
      (.assumption ctx A mem0))
    (.assumption ctx B mem2)

/-- Weakened axiom: `[psi] |- box(A) -> A`. 1 weakening + 1 axiom. -/
def weakened_axiom (A psi : Formula) : [psi] ⊢ (Formula.box A).imp A :=
  weakenEmpty (.axiom [] _ (Axiom.modal_t A) trivial)

/-- ECQ computable: `[A, A.neg] |- B`. 2 assumption + 1 axiom + 1 weakening + 2 MP. -/
def ecq_computable (A B : Formula) : [A, A.neg] ⊢ B :=
  let ctx := [A, A.neg]
  let bot_deriv : DerivationTree .Base ctx Formula.bot :=
    .modus_ponens ctx A Formula.bot
      (.assumption ctx A.neg mem1)
      (.assumption ctx A mem0)
  let ef : DerivationTree .Base ctx (Formula.bot.imp B) :=
    weakenEmpty (.axiom [] _ (Axiom.ex_falso B) trivial)
  .modus_ponens ctx Formula.bot B ef bot_deriv

/-- Left disjunction introduction: `[A] |- A or B`.
    Uses ⊢ A → A∨B (composed from app1 + ex_falso via b_combinator). -/
def ldi_computable (A B : Formula) : [A] ⊢ A.or B :=
  let a_imp_or : DerivationTree .Base [] (A.imp (A.or B)) :=
    -- A → (¬A → B): compose A → (¬A → ⊥) with b_combinator on (⊥ → B)
    let h1 : ⊢ A.imp (A.neg.imp Formula.bot) := @theorem_app1 .Base A Formula.bot
    let h2 : ⊢ Formula.bot.imp B := .axiom [] _ (Axiom.ex_falso B) trivial
    let h3 : ⊢ (Formula.bot.imp B).imp ((A.neg.imp Formula.bot).imp (A.neg.imp B)) :=
      @b_combinator .Base A.neg Formula.bot B
    let h4 : ⊢ (A.neg.imp Formula.bot).imp (A.neg.imp B) := mp h2 h3
    imp_trans h1 h4
  .modus_ponens [A] A (A.or B)
    (weakenEmpty a_imp_or)
    (.assumption [A] A mem0)

/-- Right disjunction introduction: `[B] |- A or B`.
    A∨B = ¬A→B. prop_s gives B→(¬A→B). -/
def rdi_computable (A B : Formula) : [B] ⊢ A.or B :=
  .modus_ponens [B] B (A.neg.imp B)
    (weakenEmpty (.axiom [] _ (Axiom.prop_s B A.neg) trivial))
    (.assumption [B] B mem0)

/-- Conjunction introduction: `[A, B] |- A and B`. 2 assumption + 1 weakening + 2 MP + pairing steps. -/
def conj_intro_ctx (A B : Formula) : [A, B] ⊢ A.and B :=
  let ctx := [A, B]
  let pair_weak : DerivationTree .Base ctx (A.imp (B.imp (A.and B))) :=
    weakenEmpty (pairing A B)
  let step1 : DerivationTree .Base ctx (B.imp (A.and B)) :=
    .modus_ponens ctx A (B.imp (A.and B)) pair_weak (.assumption ctx A mem0)
  .modus_ponens ctx B (A.and B) step1 (.assumption ctx B mem1)

/-!
## Category B: Modal in Context (8 theorems)
-/

/-- Box elimination: `[box A] |- A`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def box_elim_ctx (A : Formula) : [Formula.box A] ⊢ A :=
  .modus_ponens [Formula.box A] (Formula.box A) A
    (weakenEmpty (.axiom [] _ (Axiom.modal_t A) trivial))
    (.assumption _ (Formula.box A) mem0)

/-- Box 4: `[box A] |- box(box A)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def box_4_ctx (A : Formula) : [Formula.box A] ⊢ Formula.box (Formula.box A) :=
  .modus_ponens [Formula.box A] (Formula.box A) (Formula.box (Formula.box A))
    (weakenEmpty (.axiom [] _ (Axiom.modal_4 A) trivial))
    (.assumption _ (Formula.box A) mem0)

/-- Box B: `[A] |- box(diamond A)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def box_b_ctx (A : Formula) : [A] ⊢ Formula.box A.diamond :=
  .modus_ponens [A] A (Formula.box A.diamond)
    (weakenEmpty (.axiom [] _ (Axiom.modal_b A) trivial))
    (.assumption _ A mem0)

/-- Box to diamond: `[box A] |- diamond A`.
    Chain: □A →(T) A →(B) □◇A →(T) ◇A. -/
def box_to_diamond_ctx (A : Formula) : [Formula.box A] ⊢ A.diamond :=
  let thm : ⊢ (Formula.box A).imp A.diamond :=
    imp_trans
      (imp_trans
        (DerivationTree.axiom [] _ (Axiom.modal_t A) trivial)
        (DerivationTree.axiom [] _ (Axiom.modal_b A) trivial))
      (DerivationTree.axiom [] _ (Axiom.modal_t A.diamond) trivial)
  .modus_ponens [Formula.box A] (Formula.box A) A.diamond
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-- K distribution: `[box(A -> B), box A] |- box B`. 2 assumption + 1 weakening + 1 axiom + 2 MP. -/
def k_dist_ctx (A B : Formula) : [Formula.box (A.imp B), Formula.box A] ⊢ Formula.box B :=
  let ctx := [Formula.box (A.imp B), Formula.box A]
  let step1 :=
    .modus_ponens ctx (Formula.box (A.imp B)) ((Formula.box A).imp (Formula.box B))
      (weakenEmpty (.axiom [] _ (Axiom.modal_k_dist A B) trivial))
      (.assumption ctx (Formula.box (A.imp B)) mem0)
  .modus_ponens ctx (Formula.box A) (Formula.box B)
    step1
    (.assumption ctx (Formula.box A) mem1)

/-- Box pair: `[box A, box B] |- box A and box B`. 2 assumption + 1 weakening + 2 MP + pairing. -/
def box_pair_ctx (A B : Formula) : [Formula.box A, Formula.box B] ⊢ (Formula.box A).and (Formula.box B) :=
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
def diamond_5_ctx (A : Formula) : [A.diamond] ⊢ Formula.box A.diamond.diamond :=
  .modus_ponens [A.diamond] A.diamond (Formula.box A.diamond.diamond)
    (weakenEmpty (.axiom [] _ (Axiom.modal_b A.diamond) trivial))
    (.assumption _ A.diamond mem0)

/-- Box to future: `[box A] |- G(A)`. Uses MF + T composition. -/
def box_to_future_ctx (A : Formula) : [Formula.box A] ⊢ A.all_future :=
  let thm := imp_trans
    (DerivationTree.axiom [] _ (Axiom.modal_future A) trivial)
    (DerivationTree.axiom [] _ (Axiom.modal_t A.all_future) trivial)
  .modus_ponens [Formula.box A] (Formula.box A) A.all_future
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-!
## Category C: Temporal in Context (8 theorems)
-/

/-- Temporal MP in enriched context: `[A -> B, A, G(A -> B), G(A)] |- B`. 2 assumption + 1 MP. -/
def temp_k_ctx (A B : Formula) :
    [A.imp B, A, (A.imp B).all_future, A.all_future] ⊢ B :=
  let ctx := [A.imp B, A, (A.imp B).all_future, A.all_future]
  .modus_ponens ctx A B
    (.assumption ctx (A.imp B) mem0)
    (.assumption ctx A mem1)

/-- Connect future in context: `[A] |- G(P(A))`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def connect_future_ctx (A : Formula) : [A] ⊢ A.some_past.all_future :=
  .modus_ponens [A] A A.some_past.all_future
    (weakenEmpty (.axiom [] _ (Axiom.connect_future A) trivial))
    (.assumption _ A mem0)

/-- Connect past in context: `[A] |- H(F(A))`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def connect_past_ctx (A : Formula) : [A] ⊢ A.some_future.all_past :=
  .modus_ponens [A] A A.some_future.all_past
    (weakenEmpty (.axiom [] _ (Axiom.connect_past A) trivial))
    (.assumption _ A mem0)

/-- Box future in context: `[box A] |- G(box A)`. Uses temp_future_derived. -/
def box_future_ctx (A : Formula) : [Formula.box A] ⊢ (Formula.box A).all_future :=
  .modus_ponens [Formula.box A] (Formula.box A) (Formula.box A).all_future
    (weakenEmpty (temp_future_derived A))
    (.assumption _ (Formula.box A) mem0)

/-- Box past in context: `[box A] |- H(F(A))`. Chain: □A →(T) A →(connect_past) H(F(A)). -/
def box_past_ctx (A : Formula) : [Formula.box A] ⊢ A.some_future.all_past :=
  let thm := imp_trans
    (DerivationTree.axiom [] _ (Axiom.modal_t A) trivial)
    (DerivationTree.axiom [] _ (Axiom.connect_past A) trivial)
  .modus_ponens [Formula.box A] (Formula.box A) A.some_future.all_past
    (weakenEmpty thm)
    (.assumption _ (Formula.box A) mem0)

/-- Until implies F in context: `[U(psi, phi)] |- F(psi)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def until_F_ctx (phi psi : Formula) : [Formula.untl psi phi] ⊢ psi.some_future :=
  .modus_ponens [Formula.untl psi phi] (Formula.untl psi phi) psi.some_future
    (weakenEmpty (.axiom [] _ (Axiom.until_F phi psi) trivial))
    (.assumption _ (Formula.untl psi phi) mem0)

/-- Since implies P in context: `[S(psi, phi)] |- P(psi)`. 1 assumption + 1 weakening + 1 axiom + 1 MP. -/
def since_P_ctx (phi psi : Formula) : [Formula.snce psi phi] ⊢ psi.some_past :=
  .modus_ponens [Formula.snce psi phi] (Formula.snce psi phi) psi.some_past
    (weakenEmpty (.axiom [] _ (Axiom.since_P phi psi) trivial))
    (.assumption _ (Formula.snce psi phi) mem0)

/-- Serial future in context: `[A] |- F(top)`. 2 weakening + 1 axiom + identity steps + 1 MP. -/
def serial_future_ctx (A : Formula) : [A] ⊢ Formula.top.some_future :=
  let top_ctx : DerivationTree .Base [A] Formula.top :=
    weakenEmpty (identity Formula.bot)
  let sf_ctx : DerivationTree .Base [A] (Formula.top.imp Formula.top.some_future) :=
    weakenEmpty (.axiom [] _ Axiom.serial_future trivial)
  .modus_ponens [A] Formula.top Formula.top.some_future sf_ctx top_ctx

/-!
## Weakening Variants

These take existing contextual derivations and weaken them to larger contexts,
adding explicit weakening steps. `weakenCons X d` produces `(X :: Gamma) |- A`.
-/

/-- `[C, A -> B, A] |- B` -/
def mp_in_context_weak (A B C : Formula) : [C, A.imp B, A] ⊢ B :=
  weakenCons C (mp_in_context A B)

/-- `[D, A -> B, B -> C, A] |- C` -/
def mp_chain_2_weak (A B C D : Formula) : [D, A.imp B, B.imp C, A] ⊢ C :=
  weakenCons D (mp_chain_2 A B C)

/-- `[C, A, A.neg] |- B` -/
def ecq_computable_weak (A B C : Formula) : [C, A, A.neg] ⊢ B :=
  weakenCons C (ecq_computable A B)

/-- `[B, box A] |- A` -/
def box_elim_ctx_weak (A B : Formula) : [B, Formula.box A] ⊢ A :=
  weakenCons B (box_elim_ctx A)

/-- `[C, box(A -> B), box A] |- box B` -/
def k_dist_ctx_weak (A B C : Formula) : [C, Formula.box (A.imp B), Formula.box A] ⊢ Formula.box B :=
  weakenCons C (k_dist_ctx A B)

/-- `[B, box A] |- box(box A)` -/
def box_4_ctx_weak (A B : Formula) : [B, Formula.box A] ⊢ Formula.box (Formula.box A) :=
  weakenCons B (box_4_ctx A)

/-- `[B, A] |- box(diamond A)` -/
def box_b_ctx_weak (A B : Formula) : [B, A] ⊢ Formula.box A.diamond :=
  weakenCons B (box_b_ctx A)

/-- `[B, A] |- G(P(A))` -/
def connect_future_ctx_weak (A B : Formula) : [B, A] ⊢ A.some_past.all_future :=
  weakenCons B (connect_future_ctx A)

/-- `[B, A] |- H(F(A))` -/
def connect_past_ctx_weak (A B : Formula) : [B, A] ⊢ A.some_future.all_past :=
  weakenCons B (connect_past_ctx A)

/-- `[C, U(psi, phi)] |- F(psi)` -/
def until_F_ctx_weak (phi psi C : Formula) : [C, Formula.untl psi phi] ⊢ psi.some_future :=
  weakenCons C (until_F_ctx phi psi)

/-- `[C, S(psi, phi)] |- P(psi)` -/
def since_P_ctx_weak (phi psi C : Formula) : [C, Formula.snce psi phi] ⊢ psi.some_past :=
  weakenCons C (since_P_ctx phi psi)

/-- `[B, A] |- A` -/
def identity_in_ctx_weak (A B : Formula) : [B, A] ⊢ A :=
  weakenCons B (identity_in_ctx A)

/-- `[D, A, A -> B -> C, B] |- C` -/
def apply_in_ctx_weak (A B C D : Formula) : [D, A, A.imp (B.imp C), B] ⊢ C :=
  weakenCons D (apply_in_ctx A B C)

/-- `[C, A, B] |- A and B` -/
def conj_intro_ctx_weak (A B C : Formula) : [C, A, B] ⊢ A.and B :=
  weakenCons C (conj_intro_ctx A B)

/-- `[C, box A, box B] |- box A and box B` -/
def box_pair_ctx_weak (A B C : Formula) : [C, Formula.box A, Formula.box B] ⊢ (Formula.box A).and (Formula.box B) :=
  weakenCons C (box_pair_ctx A B)

/-- `[B, box A] |- G(box A)` -/
def box_future_ctx_weak (A B : Formula) : [B, Formula.box A] ⊢ (Formula.box A).all_future :=
  weakenCons B (box_future_ctx A)

/-- `[B, box A] |- H(F(A))` -/
def box_past_ctx_weak (A B : Formula) : [B, Formula.box A] ⊢ A.some_future.all_past :=
  weakenCons B (box_past_ctx A)

/-- `[B, A] |- F(top)` -/
def serial_future_ctx_weak (A B : Formula) : [B, A] ⊢ Formula.top.some_future :=
  weakenCons B (serial_future_ctx A)

/-!
## Pure Weakening Entries

Existing empty-context theorems weakened to non-empty contexts.
Each generates at least 1 weakening step.
-/

/-- `[psi] |- A -> A` -/
def identity_weakened (A psi : Formula) : [psi] ⊢ A.imp A :=
  weakenEmpty (identity A)

/-- `[psi] |- (B -> C) -> (A -> B) -> (A -> C)` -/
def b_combinator_weakened {A B C : Formula} (psi : Formula) : [psi] ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) :=
  weakenEmpty b_combinator

/-- `[psi] |- A -> neg(neg A)` -/
def dni_weakened (A psi : Formula) : [psi] ⊢ A.imp A.neg.neg :=
  weakenEmpty (dni A)

/-- `[psi] |- A -> G(P(A))` -/
def connect_future_weakened (A psi : Formula) : [psi] ⊢ A.imp A.some_past.all_future :=
  weakenEmpty (.axiom [] _ (Axiom.connect_future A) trivial)

/-- `[psi] |- A -> H(F(A))` -/
def connect_past_weakened (A psi : Formula) : [psi] ⊢ A.imp A.some_future.all_past :=
  weakenEmpty (.axiom [] _ (Axiom.connect_past A) trivial)

/-- `[psi] |- box(A) -> G(box(A))` -/
def temp_future_weakened (A psi : Formula) : [psi] ⊢ (Formula.box A).imp (Formula.box A).all_future :=
  weakenEmpty (temp_future_derived A)

/-- `[psi] |- A -> B -> A and B` -/
def pairing_weakened (A B psi : Formula) : [psi] ⊢ A.imp (B.imp (A.and B)) :=
  weakenEmpty (pairing A B)

/-- `[psi] |- box(A) -> A` -/
def modal_t_weakened (A psi : Formula) : [psi] ⊢ (Formula.box A).imp A :=
  weakenEmpty (.axiom [] _ (Axiom.modal_t A) trivial)

/-- `[psi] |- box(A) -> box(box(A))` -/
def modal_4_weakened (A psi : Formula) : [psi] ⊢ (Formula.box A).imp (Formula.box (Formula.box A)) :=
  weakenEmpty (.axiom [] _ (Axiom.modal_4 A) trivial)

/-- `[psi] |- A -> box(diamond(A))` -/
def modal_b_weakened (A psi : Formula) : [psi] ⊢ A.imp (Formula.box A.diamond) :=
  weakenEmpty (.axiom [] _ (Axiom.modal_b A) trivial)

/-- `[psi] |- box(A -> B) -> (box A -> box B)` -/
def modal_k_dist_weakened (A B psi : Formula) : [psi] ⊢ (Formula.box (A.imp B)).imp ((Formula.box A).imp (Formula.box B)) :=
  weakenEmpty (.axiom [] _ (Axiom.modal_k_dist A B) trivial)

/-- `[psi] |- bot -> A` -/
def ex_falso_weakened (A psi : Formula) : [psi] ⊢ Formula.bot.imp A :=
  weakenEmpty (.axiom [] _ (Axiom.ex_falso A) trivial)

/-- `[psi] |- (A -> (B -> C)) -> ((A -> B) -> (A -> C))` -/
def prop_k_weakened (A B C psi : Formula) : [psi] ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
  weakenEmpty (.axiom [] _ (Axiom.prop_k A B C) trivial)

/-- `[psi] |- A -> (B -> A)` -/
def prop_s_weakened (A B psi : Formula) : [psi] ⊢ A.imp (B.imp A) :=
  weakenEmpty (.axiom [] _ (Axiom.prop_s A B) trivial)

/-- `[psi] |- U(B, A) -> F(B)` -/
def until_F_weakened (A B psi : Formula) : [psi] ⊢ (Formula.untl B A).imp B.some_future :=
  weakenEmpty (.axiom [] _ (Axiom.until_F A B) trivial)

/-- `[psi] |- S(B, A) -> P(B)` -/
def since_P_weakened (A B psi : Formula) : [psi] ⊢ (Formula.snce B A).imp B.some_past :=
  weakenEmpty (.axiom [] _ (Axiom.since_P A B) trivial)

/-- `[psi] |- top -> F(top)` -/
def serial_future_weakened (psi : Formula) : [psi] ⊢ Formula.top.imp Formula.top.some_future :=
  weakenEmpty (.axiom [] _ Axiom.serial_future trivial)

/-- `[psi] |- top -> P(top)` -/
def serial_past_weakened (psi : Formula) : [psi] ⊢ Formula.top.imp Formula.top.some_past :=
  weakenEmpty (.axiom [] _ Axiom.serial_past trivial)

/-- `[psi] |- (A -> B -> C) -> (B -> A -> C)` -/
def theorem_flip_weakened {A B C : Formula} (psi : Formula) : [psi] ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C)) :=
  weakenEmpty theorem_flip

/-- `[psi] |- A -> (A -> B) -> B` -/
def theorem_app1_weakened {A B : Formula} (psi : Formula) : [psi] ⊢ A.imp ((A.imp B).imp B) :=
  weakenEmpty theorem_app1

end Bimodal.Theorems.ContextualProofs
