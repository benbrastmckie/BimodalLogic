/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Automation.LemmaDB

/-!
# Modal S5 Theorems

This module derives key modal S5 theorems in Hilbert-style proof calculus
for the TM bimodal logic system.

## Main Theorems

### Modal S5 Properties (Phase 2)
- `tBoxToDiamond`: `⊢ □A → ◇A` (necessary implies possible)
- `boxDisjIntro`: `⊢ (□A ∨ □B) → □(A ∨ B)` (box distributes over disjunction introduction)
- `boxContrapose`: `⊢ □(A → B) → □(¬B → ¬A)` (box preserves contraposition)
- `tBoxConsistency`: `⊢ ¬□(A ∧ ¬A)` (contradiction cannot be necessary)

## Implementation Status

All modal S5 theorems in this module are fully proven, including the biconditionals
(`boxIffIntro`, `boxConjIff`, `diamondDisjIff`); this module is sorry-free.

## References

* [Perpetuity.lean](Perpetuity.lean) - Modal infrastructure
  (modal_t, modal_4, modal_b, boxMono, diamondMono, boxConjIntro, contraposition, notNotIntro, dne)
* [Propositional.lean](Propositional.lean) - Propositional infrastructure
  (botOfAndNeg, impNegImp, negImp, orInl, orInr, impOfNegImpNeg, andLeft, andRight)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata
  (prop_k, prop_s, doubleNegation, modal_t, modal_4, modal_b)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace FormalSystem.Theorems.ModalS5

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.Propositional

/-!
## Helper Lemmas for Classical Reasoning
-/

/--
Classical Merge Lemma: `⊢ (P → Q) → (¬P → Q) → Q`.

From both (P → Q) and (¬P → Q), derive Q by case analysis on P ∨ ¬P.

Proven by direct appeal to `Propositional.classicalMerge`, which states the same
thing with `¬P` spelled out as `P → ⊥`.
-/
noncomputable def classicalMerge {fc : FrameClass} (P Q : Formula) :
    ⊢[fc] (P.imp Q).imp (((P.imp Formula.bot).imp Q).imp Q) := by
  -- This is the same as Propositional.classicalMerge since P.neg = P.imp Formula.bot
  exact Propositional.classicalMerge P Q

/-!
## Note on Diamond Monotonicity

The theorem `(φ → ψ) → (◇φ → ◇ψ)` (diamond monotonicity as object-level implication)
is **NOT VALID** in modal logic and cannot be derived.

**Why it fails**: The meta-rule diamondMono (if `⊢ φ → ψ` then `⊢ ◇φ → ◇ψ`) IS valid
because it applies necessitation to pure theorems. However, the implication form
`(φ → ψ) → (◇φ → ◇ψ)` is NOT valid because local truth of φ → ψ at one world doesn't
guarantee modal relationships across worlds.

**Counter-model**: In S5 with worlds w0, w1 (full accessibility):
- A true everywhere, B true only at w0
- At w0: A → B is TRUE (both hold), □A is TRUE (A everywhere), □B is FALSE (B fails at w1)
- So (A → B) → (□A → □B) = T → (T → F) = FALSE
- The same countermodel applies to diamond via duality.

**Valid Alternative**: Use `kDistDiamond` below: `□(A → B) → (◇A → ◇B)`.
This works because the implication A → B must be NECESSARY (hold at all worlds),
not just locally true. See `kDistDiamond` at line ~316 for the fully proven version.
-/

/-!
## Phase 2: Modal S5 Theorems
-/

/--
T-Box-Diamond - `⊢ □A → ◇A`.

Necessity implies possibility (T axiom consequence).

**Proof Strategy**: Use modal_t axiom (□A → A) + diamond definition (◇A = ¬□¬A).

Proof:
1. modal_t: □A → A
2. From A, construct ¬□¬A using RAA pattern
3. □A → (□¬A → ⊥) via modal_t composition
-/
@[tmLemma]
def tBoxToDiamond {fc : FrameClass} (A : Formula) : ⊢[fc] A.box.imp A.diamond := by
  -- Goal: ⊢ □A → ◇A where ◇A = ¬□¬A
  unfold Formula.diamond Formula.neg
  -- Strategy: Show □A → ¬□¬A which is □A → (□¬A → ⊥)

  -- Step 1: modal_t for A gives us □A → A
  have mt_a : ⊢[fc] A.box.imp A :=
    DerivationTree.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc)
  -- Step 2: modal_t for ¬A gives us □¬A → ¬A
  have mt_neg_a : ⊢[fc] (A.imp Formula.bot).box.imp (A.imp Formula.bot) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (A.imp Formula.bot)) (FrameClass.base_le fc)
  -- Step 3: RAA gives us A → (¬A → ⊥)
  have raa_inst : ⊢[fc] A.imp ((A.imp Formula.bot).imp Formula.bot) :=
    impNegImp A Formula.bot
  -- Step 4: Compose □A → A → (¬A → ⊥)
  have comp1 : ⊢[fc] A.box.imp ((A.imp Formula.bot).imp Formula.bot) :=
    impTrans mt_a raa_inst
  -- Step 5: Build (¬A → ⊥) → (□¬A → ⊥) via composition with □¬A → ¬A
  -- bCombinator gives: (B → C) → (A → B) → (A → C)
  -- With A = □¬A, B = ¬A, C = ⊥
  have b_inst : ⊢[fc] ((A.imp Formula.bot).imp Formula.bot).imp
                   (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                    ((A.imp Formula.bot).box.imp Formula.bot)) :=
    @bCombinator fc (A.imp Formula.bot).box (A.imp Formula.bot) Formula.bot
  -- We need to flip the order to apply mt_neg_a
  -- theoremFlip: (X → Y → Z) → (Y → X → Z)
  have flip_b : ⊢[fc] (((A.imp Formula.bot).imp Formula.bot).imp
                    (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                     ((A.imp Formula.bot).box.imp Formula.bot))).imp
                   (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                    (((A.imp Formula.bot).imp Formula.bot).imp
                     ((A.imp Formula.bot).box.imp Formula.bot))) :=
    @theoremFlip fc ((A.imp Formula.bot).imp Formula.bot)
                  ((A.imp Formula.bot).box.imp (A.imp Formula.bot))
                  ((A.imp Formula.bot).box.imp Formula.bot)
  have b_flipped : ⊢[fc] ((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                      (((A.imp Formula.bot).imp Formula.bot).imp
                       ((A.imp Formula.bot).box.imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ flip_b b_inst
  -- Apply MP with mt_neg_a to get ((¬A → ⊥) → (□¬A → ⊥))
  have step1 : ⊢[fc] ((A.imp Formula.bot).imp Formula.bot).imp
                  ((A.imp Formula.bot).box.imp Formula.bot) :=
    DerivationTree.modus_ponens [] _ _ b_flipped mt_neg_a
  -- Step 6: Compose to get □A → (□¬A → ⊥)
  have b_outer :
    ⊢[fc] (((A.imp Formula.bot).imp Formula.bot).imp
       ((A.imp Formula.bot).box.imp Formula.bot)).imp
      ((A.box.imp ((A.imp Formula.bot).imp Formula.bot)).imp
       (A.box.imp ((A.imp Formula.bot).box.imp Formula.bot))) :=
    @bCombinator fc A.box ((A.imp Formula.bot).imp Formula.bot)
      ((A.imp Formula.bot).box.imp Formula.bot)
  have step2 :
    ⊢[fc] (A.box.imp ((A.imp Formula.bot).imp Formula.bot)).imp
      (A.box.imp ((A.imp Formula.bot).box.imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ b_outer step1
  exact DerivationTree.modus_ponens [] _ _ step2 comp1

/--
Box-Disjunction Introduction - `⊢ (□A ∨ □B) → □(A ∨ B)`.

If either A or B is necessary, then their disjunction is necessary.

**Proof Strategy**: Show both □A → □(A ∨ B) and □B → □(A ∨ B),
then combine using disjunction structure.

Proof:
1. From RAA: A → (¬A → B), apply boxMono to get □A → □(¬A → B)
2. From prop_s: B → (¬A → B), apply boxMono to get □B → □(¬A → B)
3. Combine using disjunction structure (¬□A → □B) → □(¬A → B)
-/
@[tmLemma]
noncomputable def boxDisjIntro {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.box.or B.box).imp ((A.or B).box) := by
  unfold Formula.or
  -- Goal: ⊢ (¬□A → □B) → □(¬A → B)

  -- Step 1: □A → □(¬A → B) using RAA
  have raa_inst : ⊢[fc] A.imp ((A.imp Formula.bot).imp B) :=
    impNegImp A B
  have box_a_case : ⊢[fc] A.box.imp ((A.imp Formula.bot).imp B).box :=
    boxMono raa_inst
  -- Step 2: □B → □(¬A → B) using weakening (prop_s)
  have weak_b : ⊢[fc] B.imp ((A.imp Formula.bot).imp B) :=
    DerivationTree.axiom [] _ (Axiom.prop_s B (A.imp Formula.bot)) (FrameClass.base_le fc)
  have box_b_case : ⊢[fc] B.box.imp ((A.imp Formula.bot).imp B).box :=
    boxMono weak_b
  -- Step 3: Use classicalMerge to combine the two cases
  -- classicalMerge: (P → Q) → ((¬P → Q) → Q)
  -- With P = □A, Q = □(¬A → B)
  -- We have: □A → □(¬A → B) (box_a_case)
  -- We need: (¬□A → □(¬A → B)) to be derivable from (¬□A → □B) and □B → □(¬A → B)
  -- That is: from (¬□A → □B) and □B → □(¬A → B), derive (¬□A → □(¬A → B))

  -- Using bCombinator: (□B → □(¬A → B)) → ((¬□A → □B) → (¬□A → □(¬A → B)))
  have b_inst : ⊢[fc] (B.box.imp ((A.imp Formula.bot).imp B).box).imp
                  ((A.box.neg.imp B.box).imp (A.box.neg.imp ((A.imp Formula.bot).imp B).box)) :=
    bCombinator
  have neg_box_case :
    ⊢[fc] (A.box.neg.imp B.box).imp
      (A.box.neg.imp ((A.imp Formula.bot).imp B).box) :=
    DerivationTree.modus_ponens [] _ _ b_inst box_b_case
  -- Now apply classicalMerge:
  -- (□A → □(¬A → B)) → ((¬□A → □(¬A → B)) → □(¬A → B))
  have cm :
    ⊢[fc] (A.box.imp ((A.imp Formula.bot).imp B).box).imp
      ((A.box.neg.imp ((A.imp Formula.bot).imp B).box).imp
       ((A.imp Formula.bot).imp B).box) :=
    Propositional.classicalMerge A.box ((A.imp Formula.bot).imp B).box
  -- First apply: get ((¬□A → □(¬A → B)) → □(¬A → B))
  have step1 :
    ⊢[fc] (A.box.neg.imp ((A.imp Formula.bot).imp B).box).imp
      ((A.imp Formula.bot).imp B).box :=
    DerivationTree.modus_ponens [] _ _ cm box_a_case
  -- Now compose with neg_box_case: (¬□A → □B) → □(¬A → B)
  exact impTrans neg_box_case step1

/--
Box-Contraposition - `⊢ □(A → B) → □(¬B → ¬A)`.

Box preserves contraposition.

**Proof Strategy**: Use contraposition theorem from Perpetuity.lean, then apply boxMono.

Proof:
1. We have contraposition: `(⊢ A → B) → (⊢ ¬B → ¬A)` (requires hypothesis)
2. We need theorem form: `⊢ (A → B) → (¬B → ¬A)`
3. Then apply boxMono
-/
def boxContrapose {fc : FrameClass} (A B : Formula) :
    ⊢[fc] (A.imp B).box.imp
      ((B.imp Formula.bot).imp (A.imp Formula.bot)).box := by
  -- We need the contraposition as a derivable theorem, not a meta-theorem

  -- Build contraposition directly: (A → B) → (¬B → ¬A)
  -- Using: (B → ⊥) → (A → B) → (A → ⊥) which is bCombinator
  have contra_thm : ⊢[fc] (A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot)) := by
    -- bCombinator: (B → C) → (A → B) → (A → C)
    -- With C = ⊥
    have bc : ⊢[fc] (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
      @bCombinator fc A B Formula.bot
    -- We need to flip the order: (A → B) → (B → ⊥) → (A → ⊥)
    -- Use theoremFlip
    have flip : ⊢[fc] ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                   ((A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
      @theoremFlip fc (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc
  -- Now apply boxMono to contraposition theorem
  exact boxMono contra_thm

/-!
## K Distribution for Diamond (Plan 060 Phase 1)

The valid form of diamond monotonicity requires boxing the implication:
`□(A → B) → (◇A → ◇B)` is derivable, while `(A → B) → (◇A → ◇B)` is NOT.
-/

/--
K Distribution for Diamond: `⊢ □(A → B) → (◇A → ◇B)`.

This is the valid form of diamond monotonicity, derived from K axiom via duality.

**Proof Strategy**:
1. Start with K axiom for ¬B, ¬A: `□(¬B → ¬A) → (□¬B → □¬A)`
2. Use contraposition: `□(A → B) → (□¬B → □¬A)` (via boxContrapose)
3. Apply duality: `□¬B = ¬◇B`, `□¬A = ¬◇A`
4. Result: `□(A → B) → (¬◇B → ¬◇A)`
5. Contrapose consequent: `□(A → B) → (◇A → ◇B)`

**Complexity**: Medium

**Dependencies**: K axiom (modal_k_dist), boxContrapose, contraposeImp
-/
@[tmLemma]
def kDistDiamond {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.imp B).box.imp (A.diamond.imp B.diamond) := by
  -- Goal: □(A → B) → (◇A → ◇B)
  -- where ◇X = ¬□¬X
  unfold Formula.diamond Formula.neg
  -- Goal becomes: □(A → B) → ((□¬A → ⊥) → (□¬B → ⊥))
  -- Which is: □(A → B) → (¬□¬A → ¬□¬B)

  -- Step 1: Use boxContrapose to get □(A → B) → □(¬B → ¬A)
  have box_contra : ⊢[fc] (A.imp B).box.imp ((B.imp Formula.bot).imp (A.imp Formula.bot)).box :=
    boxContrapose A B
  -- Step 2: Use K axiom to distribute: □(¬B → ¬A) → (□¬B → □¬A)
  have k_inst : ⊢[fc] ((B.imp Formula.bot).imp (A.imp Formula.bot)).box.imp
                   ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist (B.imp Formula.bot) (A.imp Formula.bot)) (FrameClass.base_le fc)
  -- Step 3: Compose to get □(A → B) → (□¬B → □¬A)
  have step1 : ⊢[fc] (A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box) :=
    impTrans box_contra k_inst
  -- Step 4: Contrapose the consequent (□¬B → □¬A) to get (¬□¬A → ¬□¬B)
  -- We need: (□¬B → □¬A) → (¬□¬A → ¬□¬B)
  -- This is contraposeImp applied to modal formulas
  have contra_cons : ⊢[fc] ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box).imp
                        (((A.imp Formula.bot).box.imp Formula.bot).imp
                         ((B.imp Formula.bot).box.imp Formula.bot)) :=
    contraposeImp ((B.imp Formula.bot).box) ((A.imp Formula.bot).box)
  -- Step 5: Compose everything
  -- We have: □(A → B) → (□¬B → □¬A)
  -- We need: □(A → B) → (¬□¬A → ¬□¬B)
  -- Use bCombinator to compose step1 with contra_cons
  have b_comp : ⊢[fc] (((B.imp Formula.bot).box.imp (A.imp Formula.bot).box).imp
                    (((A.imp Formula.bot).box.imp Formula.bot).imp
                     ((B.imp Formula.bot).box.imp Formula.bot))).imp
                   (((A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)).imp
                    ((A.imp B).box.imp (((A.imp Formula.bot).box.imp Formula.bot).imp
                                        ((B.imp Formula.bot).box.imp Formula.bot)))) :=
    @bCombinator fc (A.imp B).box
      ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)
      (((A.imp Formula.bot).box.imp Formula.bot).imp
       ((B.imp Formula.bot).box.imp Formula.bot))
  have step2 : ⊢[fc] ((A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)).imp
                  ((A.imp B).box.imp (((A.imp Formula.bot).box.imp Formula.bot).imp
                                      ((B.imp Formula.bot).box.imp Formula.bot))) :=
    DerivationTree.modus_ponens [] _ _ b_comp contra_cons
  exact DerivationTree.modus_ponens [] _ _ step2 step1

/--
Box Preserves Biconditionals: From `⊢ A ↔ B`, derive `⊢ □A ↔ □B`.

Biconditionals are preserved under box modality.

**Proof Strategy**: From `A ↔ B` (which is `(A → B) ∧ (B → A)`), use boxMono
on both directions to get `(□A → □B) ∧ (□B → □A)`, which is `□A ↔ □B`.

**Complexity**: Simple

**Dependencies**: boxMono, lceImp, rceImp, iffIntro from Propositional
-/
noncomputable def boxIffIntro {fc : FrameClass} (A B : Formula) (h : ⊢[fc] (A.imp B).and (B.imp A)) :
    ⊢[fc] (A.box.imp B.box).and (B.box.imp A.box) := by
  -- h: (A → B) ∧ (B → A)
  -- Goal: (□A → □B) ∧ (□B → □A)

  -- Extract A → B from biconditional
  have ab : ⊢[fc] A.imp B := by
    have lce : ⊢[fc] ((A.imp B).and (B.imp A)).imp (A.imp B) :=
      Propositional.lceImp (A.imp B) (B.imp A)
    exact DerivationTree.modus_ponens [] _ _ lce h
  -- Extract B → A from biconditional
  have ba : ⊢[fc] B.imp A := by
    have rce : ⊢[fc] ((A.imp B).and (B.imp A)).imp (B.imp A) :=
      Propositional.rceImp (A.imp B) (B.imp A)
    exact DerivationTree.modus_ponens [] _ _ rce h
  -- Apply boxMono to A → B to get □A → □B
  have box_ab : ⊢[fc] A.box.imp B.box := boxMono ab
  -- Apply boxMono to B → A to get □B → □A
  have box_ba : ⊢[fc] B.box.imp A.box := boxMono ba
  -- Combine into biconditional (□A → □B) ∧ (□B → □A)
  exact Propositional.iffIntro A.box B.box box_ab box_ba

/--
T-Box-Consistency - `⊢ ¬□(A ∧ ¬A)`.

Contradiction cannot be necessary.

**Proof Strategy**: Use modal_t + RAA reasoning.
Modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
Then from contradiction derive ⊥
-/
@[tmLemma]
def tBoxConsistency {fc : FrameClass} (A : Formula) : ⊢[fc] ((A.and (A.imp Formula.bot)).box).imp Formula.bot := by
  -- Goal: □(A ∧ ¬A) → ⊥
  -- modal_t gives: □(A ∧ ¬A) → (A ∧ ¬A)
  -- From (A ∧ ¬A) derive ⊥

  -- modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
  have mt_conj : ⊢[fc] (A.and (A.imp Formula.bot)).box.imp (A.and (A.imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.modal_t (A.and (A.imp Formula.bot))) (FrameClass.base_le fc)
  -- From conjunction, extract A and ¬A, then apply RAA
  -- A ∧ ¬A = (A → ¬A → ⊥) → ⊥ = ((A → (A → ⊥) → ⊥) → ⊥)
  -- Actually: A ∧ B = (A → B.neg).neg = (A → (B → ⊥) → ⊥)
  -- So A ∧ ¬A = (A → (A → ⊥).neg).neg = (A → ((A → ⊥) → ⊥) → ⊥)

  -- Use theoremApp1: A → (A → ⊥) → ⊥
  have app1 : ⊢[fc] A.imp ((A.imp Formula.bot).imp Formula.bot) :=
    @theoremApp1 fc A Formula.bot
  -- Now we need: (A ∧ ¬A) → ⊥
  -- This is: ((A → ¬¬A).neg) → ⊥
  -- Which is: (A → (A → ⊥) → ⊥).neg → ⊥
  -- Since conjunction is (A → B.neg).neg, and B = ¬A = A → ⊥
  -- So A ∧ ¬A = (A → (A → ⊥).neg).neg = (A → (A → ⊥ → ⊥)).neg

  -- By RAA reversed: if from (A → ¬¬A) we get contradiction in context, then ¬(A → ¬¬A) → ⊥
  -- But we need to show the opposite: the negation of this conjunction is derivable from it

  -- Actually simpler: use notNotIntro + pairing inverse
  -- (A ∧ ¬A) = ¬(A → ¬¬A) by conjunction definition
  -- ¬(A → ¬¬A) → ⊥ is what we need

  -- From DNI: ⊢ A → ¬¬A, so ⊢ A → (A → ⊥) → ⊥
  -- So (A → (A → ⊥) → ⊥) is derivable (this is theoremApp1/notNotIntro)

  -- Build: (A ∧ ¬A) → ⊥
  -- Unfold conjunction: (A → (A → ⊥).neg).neg
  -- = (A → ((A → ⊥) → ⊥)).neg
  -- = ((A → ((A → ⊥) → ⊥)) → ⊥)

  -- We have: ⊢ A → ((A → ⊥) → ⊥) (notNotIntro/theoremApp1)
  -- We need: ((A → ((A → ⊥) → ⊥)) → ⊥) → ⊥
  -- Which is: ¬¬(A → ¬¬A) → ⊥ is NOT derivable classically

  -- Actually the goal is the other direction.
  -- We want to show ¬□(A ∧ ¬A), i.e., □(A ∧ ¬A) → ⊥

  -- From modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
  -- We need (A ∧ ¬A) → ⊥

  -- Since A ∧ ¬A unfolds to ¬(A → ¬¬A), we need ¬(A → ¬¬A) → ⊥
  -- This is equivalent to ¬¬(A → ¬¬A)
  -- Which follows from DNE applied to (A → ¬¬A) = notNotIntro

  -- Apply bCombinator to compose
  have conj_to_bot : ⊢[fc] (A.and (A.imp Formula.bot)).imp Formula.bot := by
    -- A ∧ ¬A = (A → ¬¬A).neg (by conjunction definition with B = ¬A)
    unfold Formula.and Formula.neg
    -- Now goal is:
    -- (A.imp ((A.imp Formula.bot).imp Formula.bot).imp Formula.bot).imp Formula.bot → ⊥
    -- Which simplifies to: ¬(A → ¬¬A) → ⊥
    -- This is ¬¬(A → ¬¬A)

    -- We have notNotIntro: A → ¬¬A = A → (A → ⊥) → ⊥ = theoremApp1
    have dni_A : ⊢[fc] A.imp ((A.imp Formula.bot).imp Formula.bot) :=
      @theoremApp1 fc A Formula.bot
    -- Now derive ¬¬(A → ¬¬A) from (A → ¬¬A)
    -- Use DNI on implication: X → ¬¬X
    have dni_impl :
      ⊢[fc] (A.imp ((A.imp Formula.bot).imp Formula.bot)).imp
        (((A.imp ((A.imp Formula.bot).imp Formula.bot)).imp Formula.bot).imp Formula.bot) :=
      @theoremApp1 fc (A.imp ((A.imp Formula.bot).imp Formula.bot)) Formula.bot
    exact DerivationTree.modus_ponens [] _ _ dni_impl dni_A
  -- Compose: □(A ∧ ¬A) → (A ∧ ¬A) → ⊥
  exact impTrans mt_conj conj_to_bot

/-!
## Biconditional Theorems

The biconditional connective `iff` is defined below, together with the S5 biconditional
theorems built on it. All carry complete derivations: `boxConjIff`, `diamondDisjIff`,
`s5DiamondBox`, and `s5DiamondBoxToTruth`. They are proved from `boxIffIntro`
(above) plus the `boxMono`, `impTrans`, `pairing`, and `boxConjIntro` infrastructure
already available — no deduction theorem support is required.
-/

/--
Biconditional (if and only if): `A ↔ B := (A → B) ∧ (B → A)`.

**No frame-class parameter**: this is a `Formula`-level abbreviation, not a derivation, so it
has no frame class to be parameterised by. It is the only declaration in this module without an
`{fc : FrameClass}` binder, and its absence is a type-level fact rather than a `Base` pin.
-/
def iff (A B : Formula) : Formula := (A.imp B).and (B.imp A)

/--
Box-Conjunction Biconditional - `⊢ □(A ∧ B) ↔ (□A ∧ □B)`.

Box distributes over conjunction in both directions.

**Proof Strategy**:
- Forward direction □(A ∧ B) → (□A ∧ □B): Use boxMono on andLeft/andRight from context, then pairing
- Backward direction (□A ∧ □B) → □(A ∧ B): Use boxConjIntro from Perpetuity.lean
-/
noncomputable def boxConjIff {fc : FrameClass} (A B : Formula) : ⊢[fc] iff (A.and B).box (A.box.and B.box) := by
  unfold iff
  -- We need to prove both directions:
  -- 1. □(A ∧ B) → (□A ∧ □B)
  -- 2. (□A ∧ □B) → □(A ∧ B)

  -- Direction 2 (backward): (□A ∧ □B) → □(A ∧ B)
  -- This is boxConjIntro from Perpetuity
  have backward : ⊢[fc] (A.box.and B.box).imp (A.and B).box := by
    -- boxConjIntro: (Γ ⊢ □A) → (Γ ⊢ □B) → (Γ ⊢ □(A ∧ B))
    -- We need the implication form
    -- From context [(□A ∧ □B)], extract □A and □B, then apply boxConjIntro

    -- Actually, we need to build this without context manipulation
    -- Let me use a different approach: show □A → □B → □(A ∧ B)

    -- From pairing: A → B → (A ∧ B)
    have pair : ⊢[fc] A.imp (B.imp (A.and B)) :=
      pairing A B
    -- Apply boxMono to get: □A → □(B → (A ∧ B))
    have step1 : ⊢[fc] A.box.imp (B.imp (A.and B)).box :=
      boxMono pair
    -- We need □A → □B → □(A ∧ B)
    -- Use modal K distribution: □(B → (A ∧ B)) → (□B → □(A ∧ B))
    have modal_k : ⊢[fc] (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist B (A.and B)) (FrameClass.base_le fc)
    -- Compose: □A → □(B → (A ∧ B)) → (□B → □(A ∧ B))
    have comp1 : ⊢[fc] A.box.imp (B.box.imp (A.and B).box) :=
      impTrans step1 modal_k
    -- Now build (□A ∧ □B) → □(A ∧ B)
    -- We have comp1 : □A → (□B → □(A ∧ B))
    -- Need: (□A ∧ □B) → □(A ∧ B)
    -- Use lceImp and rceImp to extract from conjunction

    -- Step: (□A ∧ □B) → □A by lceImp
    have lce_box : ⊢[fc] (A.box.and B.box).imp A.box :=
      Propositional.lceImp A.box B.box
    -- Step: (□A ∧ □B) → □B by rceImp
    have rce_box : ⊢[fc] (A.box.and B.box).imp B.box :=
      Propositional.rceImp A.box B.box
    -- Build (□A ∧ □B) → □(A ∧ B)
    -- We have comp1: □A → (□B → □(A ∧ B))
    -- Use bCombinator to get:
    -- ((□A ∧ □B) → □A) → ((□A ∧ □B) → (□B → □(A ∧ B)))
    have b1 :
      ⊢[fc] (A.box.imp (B.box.imp (A.and B).box)).imp
        (((A.box.and B.box).imp A.box).imp
         ((A.box.and B.box).imp (B.box.imp (A.and B).box))) :=
      bCombinator
    have step2 :
      ⊢[fc] ((A.box.and B.box).imp A.box).imp
        ((A.box.and B.box).imp (B.box.imp (A.and B).box)) :=
      DerivationTree.modus_ponens [] _ _ b1 comp1
    have step3 : ⊢[fc] (A.box.and B.box).imp (B.box.imp (A.and B).box) :=
      DerivationTree.modus_ponens [] _ _ step2 lce_box
    -- Now combine: (□A ∧ □B) → □B and (□A ∧ □B) → (□B → □(A ∧ B)) give (□A ∧ □B) → □(A ∧ B)
    -- Use S axiom: (P → Q → R) → ((P → Q) → (P → R))
    -- With P = (□A ∧ □B), Q = □B, R = □(A ∧ B)
    have s_ax : ⊢[fc] ((A.box.and B.box).imp (B.box.imp (A.and B).box)).imp
                  (((A.box.and B.box).imp B.box).imp ((A.box.and B.box).imp (A.and B).box)) :=
      DerivationTree.axiom [] _ (Axiom.prop_k (A.box.and B.box) B.box (A.and B).box) (FrameClass.base_le fc)
    have step4 : ⊢[fc] ((A.box.and B.box).imp B.box).imp ((A.box.and B.box).imp (A.and B).box) :=
      DerivationTree.modus_ponens [] _ _ s_ax step3
    exact DerivationTree.modus_ponens [] _ _ step4 rce_box
  -- Direction 1 (forward): □(A ∧ B) → (□A ∧ □B)
  have forward : ⊢[fc] (A.and B).box.imp (A.box.and B.box) := by
    -- Use lceImp: (A ∧ B) → A
    -- Apply boxMono to get □(A ∧ B) → □A
    have lce_a : ⊢[fc] (A.and B).imp A := Propositional.lceImp A B
    have box_a : ⊢[fc] (A.and B).box.imp A.box := boxMono lce_a
    -- Use rceImp: (A ∧ B) → B
    -- Apply boxMono to get □(A ∧ B) → □B
    have rce_b : ⊢[fc] (A.and B).imp B := Propositional.rceImp A B
    have box_b : ⊢[fc] (A.and B).box.imp B.box := boxMono rce_b
    -- Combine into □(A ∧ B) → (□A ∧ □B) using combineImpConj
    exact combineImpConj box_a box_b
  -- Combine using iffIntro (builds (A ↔ B) = (A → B) ∧ (B → A))
  -- iffIntro takes Formula arguments for A, B and proofs of A→B and B→A
  exact Propositional.iffIntro (A.and B).box (A.box.and B.box) forward backward

/--
Diamond-Disjunction Biconditional - `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)`.

Diamond distributes over disjunction in both directions (dual of boxConjIff).

**Proof Strategy**: Use modal duality and De Morgan laws.
- ◇(A ∨ B) = ¬□¬(A ∨ B) where ¬(A ∨ B) = ¬A ∧ ¬B by De Morgan (demorganDisjNeg)
- So ◇(A ∨ B) = ¬□(¬A ∧ ¬B)
- By boxConjIff: □(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B)
- So ¬□(¬A ∧ ¬B) ↔ ¬(□¬A ∧ □¬B)
- By De Morgan (demorganConjNeg): ¬(□¬A ∧ □¬B) ↔ (¬□¬A ∨ ¬□¬B) = (◇A ∨ ◇B)

**Dependencies**: Phase 1 De Morgan laws (now proven), boxConjIff
-/
noncomputable def diamondDisjIff {fc : FrameClass} (A B : Formula) :
    ⊢[fc] iff (A.or B).diamond (A.diamond.or B.diamond) := by
  -- The proof requires extensive formula manipulation with De Morgan laws.
  -- The key steps are:
  -- 1. ◇(A ∨ B) = ¬□¬(A ∨ B)
  -- 2. ¬(A ∨ B) ↔ (¬A ∧ ¬B) by demorganDisjNeg
  -- 3. □(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B) by boxConjIff
  -- 4. ¬(□¬A ∧ □¬B) ↔ (¬□¬A ∨ ¬□¬B) by demorganConjNeg
  -- 5. ¬□¬A = ◇A and ¬□¬B = ◇B by definition

  -- This proof requires composing biconditionals through modal and propositional layers.
  -- The complexity comes from the nested structure and the need to lift De Morgan laws
  -- through the box operator using boxConjIff.

  -- Forward direction: ◇(A ∨ B) → (◇A ∨ ◇B)
  have forward : ⊢[fc] (A.or B).diamond.imp (A.diamond.or B.diamond) := by
    -- Strategy:
    -- 1. ◇(A ∨ B) = ¬□¬(A ∨ B)
    -- 2. ¬(A ∨ B) ↔ (¬A ∧ ¬B) by demorganDisjNeg
    -- 3. So ¬□(¬A ∧ ¬B)
    -- 4. (□¬A ∧ □¬B) → □(¬A ∧ ¬B) by boxConjIff (backward direction)
    -- 5. Contrapose: ¬□(¬A ∧ ¬B) → ¬(□¬A ∧ □¬B)
    -- 6. ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B) by demorganConjNeg (forward direction)
    -- 7. ¬□¬A = ◇A, ¬□¬B = ◇B

    -- Step 1: Get the biconditional ¬(A ∨ B) ↔ (¬A ∧ ¬B)
    have demorgan_disj :
      ⊢[fc] ((A.or B).neg.imp (A.neg.and B.neg)).and
        ((A.neg.and B.neg).imp (A.or B).neg) :=
      Propositional.demorganDisjNeg A B
    -- Step 2: Apply boxIffIntro to get □¬(A ∨ B) ↔ □(¬A ∧ ¬B)
    have box_demorgan : ⊢[fc] ((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                            ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
      boxIffIntro (A.or B).neg (A.neg.and B.neg) demorgan_disj
    -- Step 3: Extract backward direction: □(¬A ∧ ¬B) → □¬(A ∨ B)
    have box_conj_to_or : ⊢[fc] (A.neg.and B.neg).box.imp (A.or B).neg.box := by
      have rce : ⊢[fc] (((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                     ((A.neg.and B.neg).box.imp (A.or B).neg.box)).imp
                    ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
        Propositional.rceImp ((A.or B).neg.box.imp (A.neg.and B.neg).box)
                              ((A.neg.and B.neg).box.imp (A.or B).neg.box)
      exact DerivationTree.modus_ponens [] _ _ rce box_demorgan
    -- Step 4: Get boxConjIff for (¬A ∧ ¬B)
    have box_conj_neg : ⊢[fc] ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                           ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
      boxConjIff A.neg B.neg
    -- Step 5: Extract backward direction: (□¬A ∧ □¬B) → □(¬A ∧ ¬B)
    have conj_box_to_box_conj : ⊢[fc] (A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box := by
      have rce : ⊢[fc] (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
        Propositional.rceImp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact DerivationTree.modus_ponens [] _ _ rce box_conj_neg
    -- Step 6: Compose: (□¬A ∧ □¬B) → □(¬A ∧ ¬B) → □¬(A ∨ B)
    have conj_box_to_or_box : ⊢[fc] (A.neg.box.and B.neg.box).imp (A.or B).neg.box :=
      impTrans conj_box_to_box_conj box_conj_to_or
    -- Step 7: Contrapose: ¬□¬(A ∨ B) → ¬(□¬A ∧ □¬B)
    have neg_box_or_to_neg_conj : ⊢[fc] (A.or B).neg.box.neg.imp (A.neg.box.and B.neg.box).neg :=
      Propositional.contraposition conj_box_to_or_box
    -- Step 8: Apply demorganConjNeg forward: ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B)
    have demorgan_conj : ⊢[fc] (A.neg.box.and B.neg.box).neg.imp (A.neg.box.neg.or B.neg.box.neg) :=
      Propositional.demorganConjNegForward A.neg.box B.neg.box
    -- Step 9: Compose: ¬□¬(A ∨ B) → ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B)
    have result : ⊢[fc] (A.or B).neg.box.neg.imp (A.neg.box.neg.or B.neg.box.neg) :=
      impTrans neg_box_or_to_neg_conj demorgan_conj
    -- Note: (A.or B).diamond = (A.or B).neg.box.neg
    --       A.diamond.or B.diamond = A.neg.box.neg.or B.neg.box.neg
    -- So the types match exactly
    exact result
  -- Backward direction: (◇A ∨ ◇B) → ◇(A ∨ B)
  have backward : ⊢[fc] (A.diamond.or B.diamond).imp (A.or B).diamond := by
    -- Strategy: Reverse the forward direction
    -- 1. (¬□¬A ∨ ¬□¬B)
    -- 2. → ¬(□¬A ∧ □¬B) by demorganConjNeg (backward)
    -- 3. → ¬□(¬A ∧ ¬B) by contraposing boxConjIff (backward)
    -- 4. → ¬□¬(A ∨ B) by boxIffIntro on demorganDisjNeg

    -- Step 1: Apply demorganConjNeg backward: (¬□¬A ∨ ¬□¬B) → ¬(□¬A ∧ □¬B)
    have demorgan_conj_back :
      ⊢[fc] (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.box.and B.neg.box).neg :=
      Propositional.demorganConjNegBackward A.neg.box B.neg.box
    -- Step 2: Get boxConjIff for (¬A ∧ ¬B)
    have box_conj_neg : ⊢[fc] ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                           ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
      boxConjIff A.neg B.neg
    -- Step 3: Extract backward direction: (□¬A ∧ □¬B) → □(¬A ∧ ¬B)
    have conj_box_to_box_conj : ⊢[fc] (A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box := by
      have rce : ⊢[fc] (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
        Propositional.rceImp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact DerivationTree.modus_ponens [] _ _ rce box_conj_neg
    -- Step 4: Contrapose: ¬□(¬A ∧ ¬B) → ¬(□¬A ∧ □¬B)
    have neg_box_conj_to_neg_conj : ⊢[fc] (A.neg.and B.neg).box.neg.imp (A.neg.box.and B.neg.box).neg :=
      Propositional.contraposition conj_box_to_box_conj
    -- Step 5: Get demorgan biconditional and apply boxIffIntro
    have demorgan_disj :
      ⊢[fc] ((A.or B).neg.imp (A.neg.and B.neg)).and
        ((A.neg.and B.neg).imp (A.or B).neg) :=
      Propositional.demorganDisjNeg A B
    have box_demorgan : ⊢[fc] ((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                            ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
      boxIffIntro (A.or B).neg (A.neg.and B.neg) demorgan_disj
    -- Step 6: Extract forward direction: □¬(A ∨ B) → □(¬A ∧ ¬B)
    have box_or_to_conj : ⊢[fc] (A.or B).neg.box.imp (A.neg.and B.neg).box := by
      have lce : ⊢[fc] (((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                     ((A.neg.and B.neg).box.imp (A.or B).neg.box)).imp
                    ((A.or B).neg.box.imp (A.neg.and B.neg).box) :=
        Propositional.lceImp ((A.or B).neg.box.imp (A.neg.and B.neg).box)
                              ((A.neg.and B.neg).box.imp (A.or B).neg.box)
      exact DerivationTree.modus_ponens [] _ _ lce box_demorgan
    -- Step 7: Contrapose: ¬□(¬A ∧ ¬B) → ¬□¬(A ∨ B)
    have neg_box_conj_to_neg_box_or : ⊢[fc] (A.neg.and B.neg).box.neg.imp (A.or B).neg.box.neg :=
      Propositional.contraposition box_or_to_conj
    -- Step 8: Compose the chain
    -- (¬□¬A ∨ ¬□¬B) → ¬(□¬A ∧ □¬B)
    have step1 : ⊢[fc] (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.box.and B.neg.box).neg :=
      demorgan_conj_back
    -- ¬(□¬A ∧ □¬B) → ¬□(¬A ∧ ¬B)
    -- I need the FORWARD direction of boxConjIff: □(¬A ∧ ¬B) → (□¬A ∧ □¬B)
    -- Then contrapose: ¬(□¬A ∧ □¬B) → ¬□(¬A ∧ ¬B)
    have box_conj_to_conj_box : ⊢[fc] (A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box) := by
      have lce : ⊢[fc] (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)) :=
        Propositional.lceImp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact DerivationTree.modus_ponens [] _ _ lce box_conj_neg
    have neg_conj_to_neg_box : ⊢[fc] (A.neg.box.and B.neg.box).neg.imp (A.neg.and B.neg).box.neg :=
      Propositional.contraposition box_conj_to_conj_box
    -- Step 9: Compose step1 and neg_conj_to_neg_box
    -- (◇A ∨ ◇B) → ¬□(¬A ∧ ¬B)
    have step2 : ⊢[fc] (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.and B.neg).box.neg :=
      impTrans step1 neg_conj_to_neg_box
    -- Step 10: Compose with neg_box_conj_to_neg_box_or to get (◇A ∨ ◇B) → ◇(A ∨ B)
    -- neg_box_conj_to_neg_box_or: ¬□(¬A ∧ ¬B) → ¬□¬(A ∨ B) = ¬□(¬A ∧ ¬B) → ◇(A ∨ B)
    have result : ⊢[fc] (A.neg.box.neg.or B.neg.box.neg).imp (A.or B).neg.box.neg :=
      impTrans step2 neg_box_conj_to_neg_box_or
    exact result
  -- Combine into biconditional
  exact Propositional.iffIntro (A.or B).diamond (A.diamond.or B.diamond) forward backward

/-!
## Phase 4: Advanced Modal S5 Theorems
-/

/--
S5-Diamond-Box Collapse - `⊢ ◇□A ↔ □A`.

In S5, if necessary-A is possible, then A is necessary (and vice versa).
This is the characteristic S5 property showing the collapse of nested modalities.

**Proof**:
- Backward direction `□A → ◇□A`: `modal_4` to reach `□□A`, then `tBoxToDiamond`
- Forward direction `◇□A → □A`: directly the `modal_5_collapse` axiom
-/
def s5DiamondBox {fc : FrameClass} (A : Formula) : ⊢[fc] iff (A.box.diamond) A.box := by
  -- Goal: iff (◇□A) □A which is (◇□A → □A) ∧ (□A → ◇□A)

  -- Backward direction: □A → ◇□A
  have backward : ⊢[fc] A.box.imp (A.box.diamond) := by
    -- We need: □A → ◇□A
    -- Approach: From □A, derive □□A (by modal_4), then ◇□A (by tBoxToDiamond)

    -- modal_4: □φ → □□φ, so with φ = A: □A → □□A
    have modal_4_a : ⊢[fc] A.box.imp A.box.box :=
      DerivationTree.axiom [] _ (Axiom.modal_4 A) (FrameClass.base_le fc)
    -- tBoxToDiamond: □B → ◇B, so with B = □A: □□A → ◇□A
    have box_box_to_diamond : ⊢[fc] A.box.box.imp A.box.diamond :=
      tBoxToDiamond A.box
    -- Compose: □A → □□A → ◇□A
    exact impTrans modal_4_a box_box_to_diamond
  -- Forward direction: ◇□A → □A
  have forward : ⊢[fc] (A.box.diamond).imp A.box := by
    -- Use the S5 characteristic axiom: modal_5_collapse
    -- modal_5_collapse (φ) : ◇□φ → □φ
    exact DerivationTree.axiom [] _ (Axiom.modal_5_collapse A) (FrameClass.base_le fc)
  -- Combine using pairing to build biconditional
  -- pairing: A → B → (A ∧ B)
  -- We need: (◇□A → □A) → (□A → ◇□A) → ((◇□A → □A) ∧ (□A → ◇□A))
  -- iff definition: iff X Y = (X → Y) ∧ (Y → X)
  -- So iff (◇□A) □A = (◇□A → □A) ∧ (□A → ◇□A)
  have pair_forward_backward :
    ⊢[fc] (A.box.diamond.imp A.box).imp
      ((A.box.imp A.box.diamond).imp
       ((A.box.diamond.imp A.box).and (A.box.imp A.box.diamond))) :=
    pairing (A.box.diamond.imp A.box) (A.box.imp A.box.diamond)
  have step1 :
    ⊢[fc] (A.box.imp A.box.diamond).imp
      ((A.box.diamond.imp A.box).and (A.box.imp A.box.diamond)) :=
    DerivationTree.modus_ponens [] _ _ pair_forward_backward forward
  have result : ⊢[fc] (A.box.diamond.imp A.box).and (A.box.imp A.box.diamond) :=
    DerivationTree.modus_ponens [] _ _ step1 backward
  -- result has type (◇□A → □A) ∧ (□A → ◇□A)
  -- iff (◇□A) (□A) expands to the same type
  exact result

/--
S5-Diamond-Box-to-Truth - `⊢ ◇□A → A`.

In S5, if necessarily-A is possible, then A is true.

**Proof**: Compose the `modal_5_collapse` axiom (`◇□A → □A`) with `modal_t` (`□A → A`).
Note this goes through the axiom directly rather than through `s5DiamondBox`.
-/
def s5DiamondBoxToTruth {fc : FrameClass} (A : Formula) : ⊢[fc] (A.box.diamond).imp A := by
  -- ◇□A → □A (from modal_5_collapse)
  have h1 : ⊢[fc] A.box.diamond.imp A.box :=
    DerivationTree.axiom [] _ (Axiom.modal_5_collapse A) (FrameClass.base_le fc)
  -- □A → A (from modal_t)
  have h2 : ⊢[fc] A.box.imp A :=
    DerivationTree.axiom [] _ (Axiom.modal_t A) (FrameClass.base_le fc)
  -- Compose: ◇□A → A
  exact impTrans h1 h2

end FormalSystem.Theorems.ModalS5

