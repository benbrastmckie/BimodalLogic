import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
import Logos.Core.Theorems.Perpetuity
import Logos.Core.Theorems.Propositional

/-!
# Modal S5 Theorems

This module derives key modal S5 theorems in Hilbert-style proof calculus
for the TM bimodal logic system.

## Main Theorems

### Modal S5 Properties (Phase 2)
- `t_box_to_diamond`: `⊢ □A → ◇A` (necessary implies possible)
- `box_disj_intro`: `⊢ (□A ∨ □B) → □(A ∨ B)` (box distributes over disjunction introduction)
- `box_contrapose`: `⊢ □(A → B) → □(¬B → ¬A)` (box preserves contraposition)
- `t_box_consistency`: `⊢ ¬□(A ∧ ¬A)` (contradiction cannot be necessary)

## Implementation Status

**Phase 2 In Progress**: 4/6 modal S5 theorems proven (biconditionals pending)

## References

* [Perpetuity.lean](Perpetuity.lean) - Modal infrastructure (modal_t, modal_4, modal_b, box_mono, diamond_mono, box_conj_intro, contraposition, dni, dne)
* [Propositional.lean](Propositional.lean) - Propositional infrastructure (ecq, raa, efq, ldi, rdi, rcp, lce, rce)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata (prop_k, prop_s, double_negation, modal_t, modal_4, modal_b)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Logos.Core.Theorems.ModalS5

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity
open Logos.Core.Theorems.Propositional

/-!
## Helper Lemmas for Classical Reasoning
-/

/--
Classical Merge Lemma: `⊢ (P → Q) → (¬P → Q) → Q`.

From both (P → Q) and (¬P → Q), derive Q by case analysis on P ∨ ¬P.

**Status**: Complex deduction theorem dependency. Marked as infrastructure gap.

This requires either:
1. Full deduction theorem for Hilbert system (complex, 10+ hours)
2. Disjunction elimination with context manipulation (Phase 3)
3. Meta-level case analysis (beyond pure Hilbert calculus)

**Workaround**: box_disj_intro can be reformulated without this lemma using
direct modal reasoning patterns from existing infrastructure.
-/
theorem classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp (((P.imp Formula.bot).imp Q).imp Q) := by
  -- This is the same as Propositional.classical_merge since P.neg = P.imp Formula.bot
  exact Propositional.classical_merge P Q

/-!
## Helper Lemmas for Conditional Modal Reasoning
-/

/--
**BLOCKED**: Implication form of diamond monotonicity: `⊢ (φ → ψ) → (◇φ → ◇ψ)`.

**IMPORTANT**: This theorem is NOT VALID in modal logic as an object-level implication!

The meta-rule diamond_mono (if `⊢ φ → ψ` then `⊢ ◇φ → ◇ψ`) IS valid because it applies
necessitation to pure theorems. However, the implication form `(φ → ψ) → (◇φ → ◇ψ)` is
NOT valid because local truth of φ → ψ at one world doesn't guarantee modal relationships.

**Counter-model**: In S5 with worlds w0, w1 (full accessibility):
- A true everywhere, B true only at w0
- At w0: A → B is TRUE (both hold), □A is TRUE (A everywhere), □B is FALSE (B fails at w1)
- So (A → B) → (□A → □B) = T → (T → F) = FALSE

The same countermodel applies to diamond via duality.

**Consequence**: Phase 2 of Plan 059 is blocked. The `diamond_mono_conditional` lemma
cannot be derived as originally planned. Alternative approaches for s4_diamond_box_conj
must be found.
-/
theorem diamond_mono_imp (φ ψ : Formula) : ⊢ (φ.imp ψ).imp (φ.diamond.imp ψ.diamond) := by
  -- NOT DERIVABLE as object-level theorem - see docstring
  -- This theorem is included with sorry to document the blocking dependency
  sorry

/--
**BLOCKED**: Conditional Diamond Monotonicity - depends on diamond_mono_imp which is not derivable.

See diamond_mono_imp documentation for why this is blocked.
-/
theorem diamond_mono_conditional {θ φ ψ : Formula}
    (h : ⊢ θ.imp (φ.imp ψ)) : ⊢ θ.imp (φ.diamond.imp ψ.diamond) := by
  have dmi : ⊢ (φ.imp ψ).imp (φ.diamond.imp ψ.diamond) := diamond_mono_imp φ ψ
  exact imp_trans h dmi

/-!
## Phase 2: Modal S5 Theorems
-/

/--
Task 30: T-Box-Diamond - `⊢ □A → ◇A`.

Necessity implies possibility (T axiom consequence).

**Proof Strategy**: Use modal_t axiom (□A → A) + diamond definition (◇A = ¬□¬A).

Proof:
1. modal_t: □A → A
2. From A, construct ¬□¬A using RAA pattern
3. □A → (□¬A → ⊥) via modal_t composition
-/
theorem t_box_to_diamond (A : Formula) : ⊢ A.box.imp A.diamond := by
  -- Goal: ⊢ □A → ◇A where ◇A = ¬□¬A
  unfold Formula.diamond Formula.neg

  -- Strategy: Show □A → ¬□¬A which is □A → (□¬A → ⊥)

  -- Step 1: modal_t for A gives us □A → A
  have mt_a : ⊢ A.box.imp A :=
    Derivable.axiom [] _ (Axiom.modal_t A)

  -- Step 2: modal_t for ¬A gives us □¬A → ¬A
  have mt_neg_a : ⊢ (A.imp Formula.bot).box.imp (A.imp Formula.bot) :=
    Derivable.axiom [] _ (Axiom.modal_t (A.imp Formula.bot))

  -- Step 3: RAA gives us A → (¬A → ⊥)
  have raa_inst : ⊢ A.imp ((A.imp Formula.bot).imp Formula.bot) :=
    raa A Formula.bot

  -- Step 4: Compose □A → A → (¬A → ⊥)
  have comp1 : ⊢ A.box.imp ((A.imp Formula.bot).imp Formula.bot) :=
    imp_trans mt_a raa_inst

  -- Step 5: Build (¬A → ⊥) → (□¬A → ⊥) via composition with □¬A → ¬A
  -- b_combinator gives: (B → C) → (A → B) → (A → C)
  -- With A = □¬A, B = ¬A, C = ⊥
  have b_inst : ⊢ ((A.imp Formula.bot).imp Formula.bot).imp
                   (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                    ((A.imp Formula.bot).box.imp Formula.bot)) :=
    @b_combinator (A.imp Formula.bot).box (A.imp Formula.bot) Formula.bot

  -- We need to flip the order to apply mt_neg_a
  -- theorem_flip: (X → Y → Z) → (Y → X → Z)
  have flip_b : ⊢ (((A.imp Formula.bot).imp Formula.bot).imp
                    (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                     ((A.imp Formula.bot).box.imp Formula.bot))).imp
                   (((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                    (((A.imp Formula.bot).imp Formula.bot).imp
                     ((A.imp Formula.bot).box.imp Formula.bot))) :=
    @theorem_flip ((A.imp Formula.bot).imp Formula.bot)
                  ((A.imp Formula.bot).box.imp (A.imp Formula.bot))
                  ((A.imp Formula.bot).box.imp Formula.bot)

  have b_flipped : ⊢ ((A.imp Formula.bot).box.imp (A.imp Formula.bot)).imp
                      (((A.imp Formula.bot).imp Formula.bot).imp
                       ((A.imp Formula.bot).box.imp Formula.bot)) :=
    Derivable.modus_ponens [] _ _ flip_b b_inst

  -- Apply MP with mt_neg_a to get ((¬A → ⊥) → (□¬A → ⊥))
  have step1 : ⊢ ((A.imp Formula.bot).imp Formula.bot).imp
                  ((A.imp Formula.bot).box.imp Formula.bot) :=
    Derivable.modus_ponens [] _ _ b_flipped mt_neg_a

  -- Step 6: Compose to get □A → (□¬A → ⊥)
  have b_outer :
    ⊢ (((A.imp Formula.bot).imp Formula.bot).imp
       ((A.imp Formula.bot).box.imp Formula.bot)).imp
      ((A.box.imp ((A.imp Formula.bot).imp Formula.bot)).imp
       (A.box.imp ((A.imp Formula.bot).box.imp Formula.bot))) :=
    @b_combinator A.box ((A.imp Formula.bot).imp Formula.bot)
      ((A.imp Formula.bot).box.imp Formula.bot)

  have step2 :
    ⊢ (A.box.imp ((A.imp Formula.bot).imp Formula.bot)).imp
      (A.box.imp ((A.imp Formula.bot).box.imp Formula.bot)) :=
    Derivable.modus_ponens [] _ _ b_outer step1

  exact Derivable.modus_ponens [] _ _ step2 comp1

/--
Task 34: Box-Disjunction Introduction - `⊢ (□A ∨ □B) → □(A ∨ B)`.

If either A or B is necessary, then their disjunction is necessary.

**Proof Strategy**: Show both □A → □(A ∨ B) and □B → □(A ∨ B), then combine using disjunction structure.

Proof:
1. From RAA: A → (¬A → B), apply box_mono to get □A → □(¬A → B)
2. From prop_s: B → (¬A → B), apply box_mono to get □B → □(¬A → B)
3. Combine using disjunction structure (¬□A → □B) → □(¬A → B)
-/
theorem box_disj_intro (A B : Formula) : ⊢ (A.box.or B.box).imp ((A.or B).box) := by
  unfold Formula.or

  -- Goal: ⊢ (¬□A → □B) → □(¬A → B)

  -- Step 1: □A → □(¬A → B) using RAA
  have raa_inst : ⊢ A.imp ((A.imp Formula.bot).imp B) :=
    raa A B

  have box_a_case : ⊢ A.box.imp ((A.imp Formula.bot).imp B).box :=
    box_mono raa_inst

  -- Step 2: □B → □(¬A → B) using weakening (prop_s)
  have weak_b : ⊢ B.imp ((A.imp Formula.bot).imp B) :=
    Derivable.axiom [] _ (Axiom.prop_s B (A.imp Formula.bot))

  have box_b_case : ⊢ B.box.imp ((A.imp Formula.bot).imp B).box :=
    box_mono weak_b

  -- Step 3: Use classical_merge to combine the two cases
  -- classical_merge: (P → Q) → ((¬P → Q) → Q)
  -- With P = □A, Q = □(¬A → B)
  -- We have: □A → □(¬A → B) (box_a_case)
  -- We need: (¬□A → □(¬A → B)) to be derivable from (¬□A → □B) and □B → □(¬A → B)
  -- That is: from (¬□A → □B) and □B → □(¬A → B), derive (¬□A → □(¬A → B))

  -- Using b_combinator: (□B → □(¬A → B)) → ((¬□A → □B) → (¬□A → □(¬A → B)))
  have b_inst : ⊢ (B.box.imp ((A.imp Formula.bot).imp B).box).imp
                  ((A.box.neg.imp B.box).imp (A.box.neg.imp ((A.imp Formula.bot).imp B).box)) :=
    b_combinator

  have neg_box_case :
    ⊢ (A.box.neg.imp B.box).imp
      (A.box.neg.imp ((A.imp Formula.bot).imp B).box) :=
    Derivable.modus_ponens [] _ _ b_inst box_b_case

  -- Now apply classical_merge:
  -- (□A → □(¬A → B)) → ((¬□A → □(¬A → B)) → □(¬A → B))
  have cm :
    ⊢ (A.box.imp ((A.imp Formula.bot).imp B).box).imp
      ((A.box.neg.imp ((A.imp Formula.bot).imp B).box).imp
       ((A.imp Formula.bot).imp B).box) :=
    Propositional.classical_merge A.box ((A.imp Formula.bot).imp B).box

  -- First apply: get ((¬□A → □(¬A → B)) → □(¬A → B))
  have step1 :
    ⊢ (A.box.neg.imp ((A.imp Formula.bot).imp B).box).imp
      ((A.imp Formula.bot).imp B).box :=
    Derivable.modus_ponens [] _ _ cm box_a_case

  -- Now compose with neg_box_case: (¬□A → □B) → □(¬A → B)
  exact imp_trans neg_box_case step1

/--
Task 35: Box-Contraposition - `⊢ □(A → B) → □(¬B → ¬A)`.

Box preserves contraposition.

**Proof Strategy**: Use contraposition theorem from Perpetuity.lean, then apply box_mono.

Proof:
1. We have contraposition: `(⊢ A → B) → (⊢ ¬B → ¬A)` (requires hypothesis)
2. We need theorem form: `⊢ (A → B) → (¬B → ¬A)`
3. Then apply box_mono
-/
theorem box_contrapose (A B : Formula) :
    ⊢ (A.imp B).box.imp
      ((B.imp Formula.bot).imp (A.imp Formula.bot)).box := by
  -- We need the contraposition as a derivable theorem, not a meta-theorem

  -- Build contraposition directly: (A → B) → (¬B → ¬A)
  -- Using: (B → ⊥) → (A → B) → (A → ⊥) which is b_combinator

  have contra_thm : ⊢ (A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot)) := by
    -- b_combinator: (B → C) → (A → B) → (A → C)
    -- With C = ⊥
    have bc : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
      @b_combinator A B Formula.bot

    -- We need to flip the order: (A → B) → (B → ⊥) → (A → ⊥)
    -- Use theorem_flip
    have flip : ⊢ ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                   ((A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
      @theorem_flip (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot)

    exact Derivable.modus_ponens [] _ _ flip bc

  -- Now apply box_mono to contraposition theorem
  exact box_mono contra_thm

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
2. Use contraposition: `□(A → B) → (□¬B → □¬A)` (via box_contrapose)
3. Apply duality: `□¬B = ¬◇B`, `□¬A = ¬◇A`
4. Result: `□(A → B) → (¬◇B → ¬◇A)`
5. Contrapose consequent: `□(A → B) → (◇A → ◇B)`

**Complexity**: Medium

**Dependencies**: K axiom (modal_k_dist), box_contrapose, contrapose_imp
-/
theorem k_dist_diamond (A B : Formula) : ⊢ (A.imp B).box.imp (A.diamond.imp B.diamond) := by
  -- Goal: □(A → B) → (◇A → ◇B)
  -- where ◇X = ¬□¬X
  unfold Formula.diamond Formula.neg

  -- Goal becomes: □(A → B) → ((□¬A → ⊥) → (□¬B → ⊥))
  -- Which is: □(A → B) → (¬□¬A → ¬□¬B)

  -- Step 1: Use box_contrapose to get □(A → B) → □(¬B → ¬A)
  have box_contra : ⊢ (A.imp B).box.imp ((B.imp Formula.bot).imp (A.imp Formula.bot)).box :=
    box_contrapose A B

  -- Step 2: Use K axiom to distribute: □(¬B → ¬A) → (□¬B → □¬A)
  have k_inst : ⊢ ((B.imp Formula.bot).imp (A.imp Formula.bot)).box.imp
                   ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist (B.imp Formula.bot) (A.imp Formula.bot))

  -- Step 3: Compose to get □(A → B) → (□¬B → □¬A)
  have step1 : ⊢ (A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box) :=
    imp_trans box_contra k_inst

  -- Step 4: Contrapose the consequent (□¬B → □¬A) to get (¬□¬A → ¬□¬B)
  -- We need: (□¬B → □¬A) → (¬□¬A → ¬□¬B)
  -- This is contrapose_imp applied to modal formulas
  have contra_cons : ⊢ ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box).imp
                        (((A.imp Formula.bot).box.imp Formula.bot).imp
                         ((B.imp Formula.bot).box.imp Formula.bot)) :=
    contrapose_imp ((B.imp Formula.bot).box) ((A.imp Formula.bot).box)

  -- Step 5: Compose everything
  -- We have: □(A → B) → (□¬B → □¬A)
  -- We need: □(A → B) → (¬□¬A → ¬□¬B)
  -- Use b_combinator to compose step1 with contra_cons
  have b_comp : ⊢ (((B.imp Formula.bot).box.imp (A.imp Formula.bot).box).imp
                    (((A.imp Formula.bot).box.imp Formula.bot).imp
                     ((B.imp Formula.bot).box.imp Formula.bot))).imp
                   (((A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)).imp
                    ((A.imp B).box.imp (((A.imp Formula.bot).box.imp Formula.bot).imp
                                        ((B.imp Formula.bot).box.imp Formula.bot)))) :=
    @b_combinator (A.imp B).box
      ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)
      (((A.imp Formula.bot).box.imp Formula.bot).imp
       ((B.imp Formula.bot).box.imp Formula.bot))

  have step2 : ⊢ ((A.imp B).box.imp ((B.imp Formula.bot).box.imp (A.imp Formula.bot).box)).imp
                  ((A.imp B).box.imp (((A.imp Formula.bot).box.imp Formula.bot).imp
                                      ((B.imp Formula.bot).box.imp Formula.bot))) :=
    Derivable.modus_ponens [] _ _ b_comp contra_cons

  exact Derivable.modus_ponens [] _ _ step2 step1

/--
Box Preserves Biconditionals: From `⊢ A ↔ B`, derive `⊢ □A ↔ □B`.

Biconditionals are preserved under box modality.

**Proof Strategy**: From `A ↔ B` (which is `(A → B) ∧ (B → A)`), use box_mono
on both directions to get `(□A → □B) ∧ (□B → □A)`, which is `□A ↔ □B`.

**Complexity**: Simple

**Dependencies**: box_mono, lce_imp, rce_imp, iff_intro from Propositional
-/
theorem box_iff_intro (A B : Formula) (h : ⊢ (A.imp B).and (B.imp A)) :
    ⊢ (A.box.imp B.box).and (B.box.imp A.box) := by
  -- h: (A → B) ∧ (B → A)
  -- Goal: (□A → □B) ∧ (□B → □A)

  -- Extract A → B from biconditional
  have ab : ⊢ A.imp B := by
    have lce : ⊢ ((A.imp B).and (B.imp A)).imp (A.imp B) :=
      Propositional.lce_imp (A.imp B) (B.imp A)
    exact Derivable.modus_ponens [] _ _ lce h

  -- Extract B → A from biconditional
  have ba : ⊢ B.imp A := by
    have rce : ⊢ ((A.imp B).and (B.imp A)).imp (B.imp A) :=
      Propositional.rce_imp (A.imp B) (B.imp A)
    exact Derivable.modus_ponens [] _ _ rce h

  -- Apply box_mono to A → B to get □A → □B
  have box_ab : ⊢ A.box.imp B.box := box_mono ab

  -- Apply box_mono to B → A to get □B → □A
  have box_ba : ⊢ B.box.imp A.box := box_mono ba

  -- Combine into biconditional (□A → □B) ∧ (□B → □A)
  exact Propositional.iff_intro A.box B.box box_ab box_ba

/--
Task 36: T-Box-Consistency - `⊢ ¬□(A ∧ ¬A)`.

Contradiction cannot be necessary.

**Proof Strategy**: Use modal_t + RAA reasoning.
Modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
Then from contradiction derive ⊥
-/
theorem t_box_consistency (A : Formula) : ⊢ ((A.and (A.imp Formula.bot)).box).imp Formula.bot := by
  -- Goal: □(A ∧ ¬A) → ⊥
  -- modal_t gives: □(A ∧ ¬A) → (A ∧ ¬A)
  -- From (A ∧ ¬A) derive ⊥

  -- modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
  have mt_conj : ⊢ (A.and (A.imp Formula.bot)).box.imp (A.and (A.imp Formula.bot)) :=
    Derivable.axiom [] _ (Axiom.modal_t (A.and (A.imp Formula.bot)))

  -- From conjunction, extract A and ¬A, then apply RAA
  -- A ∧ ¬A = (A → ¬A → ⊥) → ⊥ = ((A → (A → ⊥) → ⊥) → ⊥)
  -- Actually: A ∧ B = (A → B.neg).neg = (A → (B → ⊥) → ⊥)
  -- So A ∧ ¬A = (A → (A → ⊥).neg).neg = (A → ((A → ⊥) → ⊥) → ⊥)

  -- Use theorem_app1: A → (A → ⊥) → ⊥
  have app1 : ⊢ A.imp ((A.imp Formula.bot).imp Formula.bot) :=
    @theorem_app1 A Formula.bot

  -- Now we need: (A ∧ ¬A) → ⊥
  -- This is: ((A → ¬¬A).neg) → ⊥
  -- Which is: (A → (A → ⊥) → ⊥).neg → ⊥
  -- Since conjunction is (A → B.neg).neg, and B = ¬A = A → ⊥
  -- So A ∧ ¬A = (A → (A → ⊥).neg).neg = (A → (A → ⊥ → ⊥)).neg

  -- By RAA reversed: if from (A → ¬¬A) we get contradiction in context, then ¬(A → ¬¬A) → ⊥
  -- But we need to show the opposite: the negation of this conjunction is derivable from it

  -- Actually simpler: use dni + pairing inverse
  -- (A ∧ ¬A) = ¬(A → ¬¬A) by conjunction definition
  -- ¬(A → ¬¬A) → ⊥ is what we need

  -- From DNI: ⊢ A → ¬¬A, so ⊢ A → (A → ⊥) → ⊥
  -- So (A → (A → ⊥) → ⊥) is derivable (this is theorem_app1/dni)

  -- Build: (A ∧ ¬A) → ⊥
  -- Unfold conjunction: (A → (A → ⊥).neg).neg
  -- = (A → ((A → ⊥) → ⊥)).neg
  -- = ((A → ((A → ⊥) → ⊥)) → ⊥)

  -- We have: ⊢ A → ((A → ⊥) → ⊥) (dni/theorem_app1)
  -- We need: ((A → ((A → ⊥) → ⊥)) → ⊥) → ⊥
  -- Which is: ¬¬(A → ¬¬A) → ⊥ is NOT derivable classically

  -- Actually the goal is the other direction.
  -- We want to show ¬□(A ∧ ¬A), i.e., □(A ∧ ¬A) → ⊥

  -- From modal_t: □(A ∧ ¬A) → (A ∧ ¬A)
  -- We need (A ∧ ¬A) → ⊥

  -- Since A ∧ ¬A unfolds to ¬(A → ¬¬A), we need ¬(A → ¬¬A) → ⊥
  -- This is equivalent to ¬¬(A → ¬¬A)
  -- Which follows from DNE applied to (A → ¬¬A) = dni

  -- Apply b_combinator to compose
  have conj_to_bot : ⊢ (A.and (A.imp Formula.bot)).imp Formula.bot := by
    -- A ∧ ¬A = (A → ¬¬A).neg (by conjunction definition with B = ¬A)
    unfold Formula.and Formula.neg

    -- Now goal is: (A.imp ((A.imp Formula.bot).imp Formula.bot).imp Formula.bot).imp Formula.bot → ⊥
    -- Which simplifies to: ¬(A → ¬¬A) → ⊥
    -- This is ¬¬(A → ¬¬A)

    -- We have dni: A → ¬¬A = A → (A → ⊥) → ⊥ = theorem_app1
    have dni_A : ⊢ A.imp ((A.imp Formula.bot).imp Formula.bot) :=
      @theorem_app1 A Formula.bot

    -- Now derive ¬¬(A → ¬¬A) from (A → ¬¬A)
    -- Use DNI on implication: X → ¬¬X
    have dni_impl : ⊢ (A.imp ((A.imp Formula.bot).imp Formula.bot)).imp
                       (((A.imp ((A.imp Formula.bot).imp Formula.bot)).imp Formula.bot).imp Formula.bot) :=
      @theorem_app1 (A.imp ((A.imp Formula.bot).imp Formula.bot)) Formula.bot

    exact Derivable.modus_ponens [] _ _ dni_impl dni_A

  -- Compose: □(A ∧ ¬A) → (A ∧ ¬A) → ⊥
  exact imp_trans mt_conj conj_to_bot

/-!
## Biconditional Theorems (Infrastructure Pending)

The following theorems require biconditional introduction/elimination infrastructure
which needs deduction theorem support. Marked as sorry pending Phase 3.
-/

/--
Biconditional (if and only if): `A ↔ B := (A → B) ∧ (B → A)`.
-/
def iff (A B : Formula) : Formula := (A.imp B).and (B.imp A)

/--
Task 31: Box-Conjunction Biconditional - `⊢ □(A ∧ B) ↔ (□A ∧ □B)`.

Box distributes over conjunction in both directions.

**Proof Strategy**:
- Forward direction □(A ∧ B) → (□A ∧ □B): Use box_mono on lce/rce from context, then pairing
- Backward direction (□A ∧ □B) → □(A ∧ B): Use box_conj_intro from Perpetuity.lean
-/
theorem box_conj_iff (A B : Formula) : ⊢ iff (A.and B).box (A.box.and B.box) := by
  unfold iff

  -- We need to prove both directions:
  -- 1. □(A ∧ B) → (□A ∧ □B)
  -- 2. (□A ∧ □B) → □(A ∧ B)

  -- Direction 2 (backward): (□A ∧ □B) → □(A ∧ B)
  -- This is box_conj_intro from Perpetuity
  have backward : ⊢ (A.box.and B.box).imp (A.and B).box := by
    -- box_conj_intro: (Γ ⊢ □A) → (Γ ⊢ □B) → (Γ ⊢ □(A ∧ B))
    -- We need the implication form
    -- From context [(□A ∧ □B)], extract □A and □B, then apply box_conj_intro

    -- Actually, we need to build this without context manipulation
    -- Let me use a different approach: show □A → □B → □(A ∧ B)

    -- From pairing: A → B → (A ∧ B)
    have pair : ⊢ A.imp (B.imp (A.and B)) :=
      pairing A B

    -- Apply box_mono to get: □A → □(B → (A ∧ B))
    have step1 : ⊢ A.box.imp (B.imp (A.and B)).box :=
      box_mono pair

    -- We need □A → □B → □(A ∧ B)
    -- Use modal K distribution: □(B → (A ∧ B)) → (□B → □(A ∧ B))
    have modal_k : ⊢ (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
      Derivable.axiom [] _ (Axiom.modal_k_dist B (A.and B))

    -- Compose: □A → □(B → (A ∧ B)) → (□B → □(A ∧ B))
    have comp1 : ⊢ A.box.imp (B.box.imp (A.and B).box) :=
      imp_trans step1 modal_k

    -- Now build (□A ∧ □B) → □(A ∧ B)
    -- We have comp1 : □A → (□B → □(A ∧ B))
    -- Need: (□A ∧ □B) → □(A ∧ B)
    -- Use lce_imp and rce_imp to extract from conjunction

    -- Step: (□A ∧ □B) → □A by lce_imp
    have lce_box : ⊢ (A.box.and B.box).imp A.box :=
      Propositional.lce_imp A.box B.box

    -- Step: (□A ∧ □B) → □B by rce_imp
    have rce_box : ⊢ (A.box.and B.box).imp B.box :=
      Propositional.rce_imp A.box B.box

    -- Build (□A ∧ □B) → □(A ∧ B)
    -- We have comp1: □A → (□B → □(A ∧ B))
    -- Use b_combinator to get:
    -- ((□A ∧ □B) → □A) → ((□A ∧ □B) → (□B → □(A ∧ B)))

    have b1 :
      ⊢ (A.box.imp (B.box.imp (A.and B).box)).imp
        (((A.box.and B.box).imp A.box).imp
         ((A.box.and B.box).imp (B.box.imp (A.and B).box))) :=
      b_combinator
    have step2 :
      ⊢ ((A.box.and B.box).imp A.box).imp
        ((A.box.and B.box).imp (B.box.imp (A.and B).box)) :=
      Derivable.modus_ponens [] _ _ b1 comp1
    have step3 : ⊢ (A.box.and B.box).imp (B.box.imp (A.and B).box) :=
      Derivable.modus_ponens [] _ _ step2 lce_box

    -- Now combine: (□A ∧ □B) → □B and (□A ∧ □B) → (□B → □(A ∧ B)) give (□A ∧ □B) → □(A ∧ B)
    -- Use S axiom: (P → Q → R) → ((P → Q) → (P → R))
    -- With P = (□A ∧ □B), Q = □B, R = □(A ∧ B)
    have s_ax : ⊢ ((A.box.and B.box).imp (B.box.imp (A.and B).box)).imp
                  (((A.box.and B.box).imp B.box).imp ((A.box.and B.box).imp (A.and B).box)) :=
      Derivable.axiom [] _ (Axiom.prop_k (A.box.and B.box) B.box (A.and B).box)
    have step4 : ⊢ ((A.box.and B.box).imp B.box).imp ((A.box.and B.box).imp (A.and B).box) :=
      Derivable.modus_ponens [] _ _ s_ax step3
    exact Derivable.modus_ponens [] _ _ step4 rce_box

  -- Direction 1 (forward): □(A ∧ B) → (□A ∧ □B)
  have forward : ⊢ (A.and B).box.imp (A.box.and B.box) := by
    -- Use lce_imp: (A ∧ B) → A
    -- Apply box_mono to get □(A ∧ B) → □A
    have lce_a : ⊢ (A.and B).imp A := Propositional.lce_imp A B
    have box_a : ⊢ (A.and B).box.imp A.box := box_mono lce_a

    -- Use rce_imp: (A ∧ B) → B
    -- Apply box_mono to get □(A ∧ B) → □B
    have rce_b : ⊢ (A.and B).imp B := Propositional.rce_imp A B
    have box_b : ⊢ (A.and B).box.imp B.box := box_mono rce_b

    -- Combine into □(A ∧ B) → (□A ∧ □B) using combine_imp_conj
    exact combine_imp_conj box_a box_b

  -- Combine using iff_intro (builds (A ↔ B) = (A → B) ∧ (B → A))
  -- iff_intro takes Formula arguments for A, B and proofs of A→B and B→A
  exact Propositional.iff_intro (A.and B).box (A.box.and B.box) forward backward

/--
Task 32: Diamond-Disjunction Biconditional - `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)`.

Diamond distributes over disjunction in both directions (dual of box_conj_iff).

**Proof Strategy**: Use modal duality and De Morgan laws.
- ◇(A ∨ B) = ¬□¬(A ∨ B) where ¬(A ∨ B) = ¬A ∧ ¬B by De Morgan (demorgan_disj_neg)
- So ◇(A ∨ B) = ¬□(¬A ∧ ¬B)
- By box_conj_iff: □(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B)
- So ¬□(¬A ∧ ¬B) ↔ ¬(□¬A ∧ □¬B)
- By De Morgan (demorgan_conj_neg): ¬(□¬A ∧ □¬B) ↔ (¬□¬A ∨ ¬□¬B) = (◇A ∨ ◇B)

**Dependencies**: Phase 1 De Morgan laws (now proven), box_conj_iff
-/
theorem diamond_disj_iff (A B : Formula) : ⊢ iff (A.or B).diamond (A.diamond.or B.diamond) := by
  -- The proof requires extensive formula manipulation with De Morgan laws.
  -- The key steps are:
  -- 1. ◇(A ∨ B) = ¬□¬(A ∨ B)
  -- 2. ¬(A ∨ B) ↔ (¬A ∧ ¬B) by demorgan_disj_neg
  -- 3. □(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B) by box_conj_iff
  -- 4. ¬(□¬A ∧ □¬B) ↔ (¬□¬A ∨ ¬□¬B) by demorgan_conj_neg
  -- 5. ¬□¬A = ◇A and ¬□¬B = ◇B by definition

  -- This proof requires composing biconditionals through modal and propositional layers.
  -- The complexity comes from the nested structure and the need to lift De Morgan laws
  -- through the box operator using box_conj_iff.

  -- Forward direction: ◇(A ∨ B) → (◇A ∨ ◇B)
  have forward : ⊢ (A.or B).diamond.imp (A.diamond.or B.diamond) := by
    -- Strategy:
    -- 1. ◇(A ∨ B) = ¬□¬(A ∨ B)
    -- 2. ¬(A ∨ B) ↔ (¬A ∧ ¬B) by demorgan_disj_neg
    -- 3. So ¬□(¬A ∧ ¬B)
    -- 4. (□¬A ∧ □¬B) → □(¬A ∧ ¬B) by box_conj_iff (backward direction)
    -- 5. Contrapose: ¬□(¬A ∧ ¬B) → ¬(□¬A ∧ □¬B)
    -- 6. ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B) by demorgan_conj_neg (forward direction)
    -- 7. ¬□¬A = ◇A, ¬□¬B = ◇B

    -- Step 1: Get the biconditional ¬(A ∨ B) ↔ (¬A ∧ ¬B)
    have demorgan_disj : ⊢ ((A.or B).neg.imp (A.neg.and B.neg)).and ((A.neg.and B.neg).imp (A.or B).neg) :=
      Propositional.demorgan_disj_neg A B

    -- Step 2: Apply box_iff_intro to get □¬(A ∨ B) ↔ □(¬A ∧ ¬B)
    have box_demorgan : ⊢ ((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                            ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
      box_iff_intro (A.or B).neg (A.neg.and B.neg) demorgan_disj

    -- Step 3: Extract backward direction: □(¬A ∧ ¬B) → □¬(A ∨ B)
    have box_conj_to_or : ⊢ (A.neg.and B.neg).box.imp (A.or B).neg.box := by
      have rce : ⊢ (((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                     ((A.neg.and B.neg).box.imp (A.or B).neg.box)).imp
                    ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
        Propositional.rce_imp ((A.or B).neg.box.imp (A.neg.and B.neg).box)
                              ((A.neg.and B.neg).box.imp (A.or B).neg.box)
      exact Derivable.modus_ponens [] _ _ rce box_demorgan

    -- Step 4: Get box_conj_iff for (¬A ∧ ¬B)
    have box_conj_neg : ⊢ ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                           ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
      box_conj_iff A.neg B.neg

    -- Step 5: Extract backward direction: (□¬A ∧ □¬B) → □(¬A ∧ ¬B)
    have conj_box_to_box_conj : ⊢ (A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box := by
      have rce : ⊢ (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
        Propositional.rce_imp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact Derivable.modus_ponens [] _ _ rce box_conj_neg

    -- Step 6: Compose: (□¬A ∧ □¬B) → □(¬A ∧ ¬B) → □¬(A ∨ B)
    have conj_box_to_or_box : ⊢ (A.neg.box.and B.neg.box).imp (A.or B).neg.box :=
      imp_trans conj_box_to_box_conj box_conj_to_or

    -- Step 7: Contrapose: ¬□¬(A ∨ B) → ¬(□¬A ∧ □¬B)
    have neg_box_or_to_neg_conj : ⊢ (A.or B).neg.box.neg.imp (A.neg.box.and B.neg.box).neg :=
      contraposition conj_box_to_or_box

    -- Step 8: Apply demorgan_conj_neg forward: ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B)
    have demorgan_conj : ⊢ (A.neg.box.and B.neg.box).neg.imp (A.neg.box.neg.or B.neg.box.neg) :=
      Propositional.demorgan_conj_neg_forward A.neg.box B.neg.box

    -- Step 9: Compose: ¬□¬(A ∨ B) → ¬(□¬A ∧ □¬B) → (¬□¬A ∨ ¬□¬B)
    have result : ⊢ (A.or B).neg.box.neg.imp (A.neg.box.neg.or B.neg.box.neg) :=
      imp_trans neg_box_or_to_neg_conj demorgan_conj

    -- Note: (A.or B).diamond = (A.or B).neg.box.neg
    --       A.diamond.or B.diamond = A.neg.box.neg.or B.neg.box.neg
    -- So the types match exactly
    exact result

  -- Backward direction: (◇A ∨ ◇B) → ◇(A ∨ B)
  have backward : ⊢ (A.diamond.or B.diamond).imp (A.or B).diamond := by
    -- Strategy: Reverse the forward direction
    -- 1. (¬□¬A ∨ ¬□¬B)
    -- 2. → ¬(□¬A ∧ □¬B) by demorgan_conj_neg (backward)
    -- 3. → ¬□(¬A ∧ ¬B) by contraposing box_conj_iff (backward)
    -- 4. → ¬□¬(A ∨ B) by box_iff_intro on demorgan_disj_neg

    -- Step 1: Apply demorgan_conj_neg backward: (¬□¬A ∨ ¬□¬B) → ¬(□¬A ∧ □¬B)
    have demorgan_conj_back : ⊢ (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.box.and B.neg.box).neg :=
      Propositional.demorgan_conj_neg_backward A.neg.box B.neg.box

    -- Step 2: Get box_conj_iff for (¬A ∧ ¬B)
    have box_conj_neg : ⊢ ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                           ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
      box_conj_iff A.neg B.neg

    -- Step 3: Extract backward direction: (□¬A ∧ □¬B) → □(¬A ∧ ¬B)
    have conj_box_to_box_conj : ⊢ (A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box := by
      have rce : ⊢ (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box) :=
        Propositional.rce_imp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact Derivable.modus_ponens [] _ _ rce box_conj_neg

    -- Step 4: Contrapose: ¬□(¬A ∧ ¬B) → ¬(□¬A ∧ □¬B)
    have neg_box_conj_to_neg_conj : ⊢ (A.neg.and B.neg).box.neg.imp (A.neg.box.and B.neg.box).neg :=
      contraposition conj_box_to_box_conj

    -- Step 5: Get demorgan biconditional and apply box_iff_intro
    have demorgan_disj : ⊢ ((A.or B).neg.imp (A.neg.and B.neg)).and ((A.neg.and B.neg).imp (A.or B).neg) :=
      Propositional.demorgan_disj_neg A B

    have box_demorgan : ⊢ ((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                            ((A.neg.and B.neg).box.imp (A.or B).neg.box) :=
      box_iff_intro (A.or B).neg (A.neg.and B.neg) demorgan_disj

    -- Step 6: Extract forward direction: □¬(A ∨ B) → □(¬A ∧ ¬B)
    have box_or_to_conj : ⊢ (A.or B).neg.box.imp (A.neg.and B.neg).box := by
      have lce : ⊢ (((A.or B).neg.box.imp (A.neg.and B.neg).box).and
                     ((A.neg.and B.neg).box.imp (A.or B).neg.box)).imp
                    ((A.or B).neg.box.imp (A.neg.and B.neg).box) :=
        Propositional.lce_imp ((A.or B).neg.box.imp (A.neg.and B.neg).box)
                              ((A.neg.and B.neg).box.imp (A.or B).neg.box)
      exact Derivable.modus_ponens [] _ _ lce box_demorgan

    -- Step 7: Contrapose: ¬□(¬A ∧ ¬B) → ¬□¬(A ∨ B)
    have neg_box_conj_to_neg_box_or : ⊢ (A.neg.and B.neg).box.neg.imp (A.or B).neg.box.neg :=
      contraposition box_or_to_conj

    -- Step 8: Compose the chain
    -- (¬□¬A ∨ ¬□¬B) → ¬(□¬A ∧ □¬B)
    have step1 : ⊢ (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.box.and B.neg.box).neg :=
      demorgan_conj_back

    -- ¬(□¬A ∧ □¬B) → ¬□(¬A ∧ ¬B)
    -- I need the FORWARD direction of box_conj_iff: □(¬A ∧ ¬B) → (□¬A ∧ □¬B)
    -- Then contrapose: ¬(□¬A ∧ □¬B) → ¬□(¬A ∧ ¬B)

    have box_conj_to_conj_box : ⊢ (A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box) := by
      have lce : ⊢ (((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)).and
                     ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)).imp
                    ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box)) :=
        Propositional.lce_imp ((A.neg.and B.neg).box.imp (A.neg.box.and B.neg.box))
                              ((A.neg.box.and B.neg.box).imp (A.neg.and B.neg).box)
      exact Derivable.modus_ponens [] _ _ lce box_conj_neg

    have neg_conj_to_neg_box : ⊢ (A.neg.box.and B.neg.box).neg.imp (A.neg.and B.neg).box.neg :=
      contraposition box_conj_to_conj_box

    -- Step 9: Compose step1 and neg_conj_to_neg_box
    -- (◇A ∨ ◇B) → ¬□(¬A ∧ ¬B)
    have step2 : ⊢ (A.neg.box.neg.or B.neg.box.neg).imp (A.neg.and B.neg).box.neg :=
      imp_trans step1 neg_conj_to_neg_box

    -- Step 10: Compose with neg_box_conj_to_neg_box_or to get (◇A ∨ ◇B) → ◇(A ∨ B)
    -- neg_box_conj_to_neg_box_or: ¬□(¬A ∧ ¬B) → ¬□¬(A ∨ B) = ¬□(¬A ∧ ¬B) → ◇(A ∨ B)
    have result : ⊢ (A.neg.box.neg.or B.neg.box.neg).imp (A.or B).neg.box.neg :=
      imp_trans step2 neg_box_conj_to_neg_box_or

    exact result

  -- Combine into biconditional
  exact Propositional.iff_intro (A.or B).diamond (A.diamond.or B.diamond) forward backward

/-!
## Phase 4: Advanced Modal S5 Theorems
-/

/--
Task 33: S5-Diamond-Box Collapse - `⊢ ◇□A ↔ □A`.

In S5, if necessary-A is possible, then A is necessary (and vice versa).
This is the characteristic S5 property showing the collapse of nested modalities.

**Proof Strategy**:
- Backward direction `□A → ◇□A`: Direct from modal_b
- Forward direction `◇□A → □A`: Use modal_5 and modal_t with diamond elimination

**Status**: Partial (backward proven, forward blocked)
-/
theorem s5_diamond_box (A : Formula) : ⊢ iff (A.box.diamond) A.box := by
  -- Goal: iff (◇□A) □A which is (◇□A → □A) ∧ (□A → ◇□A)

  -- Backward direction: □A → ◇□A
  have backward : ⊢ A.box.imp (A.box.diamond) := by
    -- We need: □A → ◇□A
    -- Approach: From □A, derive □□A (by modal_4), then ◇□A (by t_box_to_diamond)

    -- modal_4: □φ → □□φ, so with φ = A: □A → □□A
    have modal_4_a : ⊢ A.box.imp A.box.box :=
      Derivable.axiom [] _ (Axiom.modal_4 A)

    -- t_box_to_diamond: □B → ◇B, so with B = □A: □□A → ◇□A
    have box_box_to_diamond : ⊢ A.box.box.imp A.box.diamond :=
      t_box_to_diamond A.box

    -- Compose: □A → □□A → ◇□A
    exact imp_trans modal_4_a box_box_to_diamond

  -- Forward direction: ◇□A → □A
  have forward : ⊢ (A.box.diamond).imp A.box := by
    -- Use the S5 characteristic axiom: modal_5_collapse
    -- modal_5_collapse (φ) : ◇□φ → □φ
    exact Derivable.axiom [] _ (Axiom.modal_5_collapse A)

  -- Combine using pairing to build biconditional
  -- pairing: A → B → (A ∧ B)
  -- We need: (◇□A → □A) → (□A → ◇□A) → ((◇□A → □A) ∧ (□A → ◇□A))
  -- iff definition: iff X Y = (X → Y) ∧ (Y → X)
  -- So iff (◇□A) □A = (◇□A → □A) ∧ (□A → ◇□A)

  have pair_forward_backward : ⊢ (A.box.diamond.imp A.box).imp ((A.box.imp A.box.diamond).imp ((A.box.diamond.imp A.box).and (A.box.imp A.box.diamond))) :=
    pairing (A.box.diamond.imp A.box) (A.box.imp A.box.diamond)

  have step1 : ⊢ (A.box.imp A.box.diamond).imp ((A.box.diamond.imp A.box).and (A.box.imp A.box.diamond)) :=
    Derivable.modus_ponens [] _ _ pair_forward_backward forward

  have result : ⊢ (A.box.diamond.imp A.box).and (A.box.imp A.box.diamond) :=
    Derivable.modus_ponens [] _ _ step1 backward

  -- result has type (◇□A → □A) ∧ (□A → ◇□A)
  -- iff (◇□A) (□A) expands to the same type
  exact result

/--
Task 37: S5-Diamond-Box-to-Truth - `⊢ ◇□A → A`.

In S5, if necessarily-A is possible, then A is true.

**Proof Strategy**: Compose s5_diamond_box with modal_t.

**Dependencies**: Task 33 (s5_diamond_box)

**Status**: Blocked on Task 33 forward direction
-/
theorem s5_diamond_box_to_truth (A : Formula) : ⊢ (A.box.diamond).imp A := by
  -- ◇□A → □A (from modal_5_collapse)
  have h1 : ⊢ A.box.diamond.imp A.box :=
    Derivable.axiom [] _ (Axiom.modal_5_collapse A)
  -- □A → A (from modal_t)
  have h2 : ⊢ A.box.imp A :=
    Derivable.axiom [] _ (Axiom.modal_t A)
  -- Compose: ◇□A → A
  exact imp_trans h1 h2

end Logos.Core.Theorems.ModalS5

