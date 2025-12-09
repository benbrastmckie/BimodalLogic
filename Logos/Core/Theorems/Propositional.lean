import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
import Logos.Core.Theorems.Perpetuity

/-!
# Propositional Theorems

This module derives key propositional theorems in Hilbert-style proof calculus
for the TM bimodal logic system.

## Main Theorems

### Negation and Contradiction (Phase 1)
- `ecq`: Ex Contradictione Quodlibet - `[A, ¬A] ⊢ B` (from contradiction, anything follows)
- `raa`: Reductio ad Absurdum - `⊢ A → (¬A → B)` (proof by contradiction)
- `efq`: Ex Falso Quodlibet - `⊢ ¬A → (A → B)` (from falsehood, anything follows)

### Conjunction and Disjunction (Phase 1)
- `lce`: Left Conjunction Elimination - `[A ∧ B] ⊢ A`
- `rce`: Right Conjunction Elimination - `[A ∧ B] ⊢ B`
- `ldi`: Left Disjunction Introduction - `[A] ⊢ A ∨ B`
- `rdi`: Right Disjunction Introduction - `[B] ⊢ A ∨ B`

### Contraposition (Phase 1)
- `rcp`: Reverse Contraposition - `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`

## Implementation Status

**Phase 1 Complete**: ECQ, RAA, EFQ, LDI, RDI, RCP, LCE, RCE (8 theorems proven, zero sorry)

## References

* [Perpetuity.lean](Perpetuity.lean) - Combinator infrastructure (imp_trans, identity, b_combinator, theorem_flip, pairing, dni)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata (prop_k, prop_s, double_negation)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Logos.Core.Theorems.Propositional

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity

/-!
## Helper Lemmas
-/

/--
Law of Excluded Middle: `⊢ A ∨ ¬A`.

This is a classical logic principle that states every proposition is either true or false.

**Derivation**: Use double negation elimination and propositional axioms.

In TM logic, we have:
- `double_negation`: `¬¬φ → φ`
- `dni`: `φ → ¬¬φ`

We derive LEM by showing `¬(A ∨ ¬A)` leads to contradiction.

Recall: `A ∨ B = ¬A → B`
So: `A ∨ ¬A = ¬A → ¬A = identity ¬A`

Therefore: `⊢ A ∨ ¬A` is immediate from identity.
-/
theorem lem (A : Formula) : ⊢ A.or A.neg := by
  -- A ∨ ¬A = ¬A → ¬A (by definition of disjunction)
  unfold Formula.or
  -- Now goal is: ⊢ A.neg.imp A.neg
  exact identity A.neg

/-!
## Phase 1: Propositional Foundations

Core propositional theorems for negation, conjunction, disjunction, and contraposition.
-/

/--
Ex Contradictione Quodlibet: `[A, ¬A] ⊢ B`.

From a contradiction (both A and ¬A), any formula B can be derived.

**Proof Strategy**: Use EFQ pattern - from ¬A and A, derive B.

Proof:
1. Assume A and ¬A in context
2. By weakening, derive ¬A → (A → B) using prop_s
3. Apply modus ponens twice
-/
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B := by
  -- Goal: [A, ¬A] ⊢ B where ¬A = A → ⊥
  -- From ¬A in context, we have A → ⊥
  -- From A in context, we get ⊥
  -- From ⊥, derive B using DNE

  -- Step 1: Get ¬A from context (second assumption)
  have h_neg_a : [A, A.neg] ⊢ A.neg := by
    apply Derivable.assumption
    simp

  -- Step 2: Get A from context (first assumption)
  have h_a : [A, A.neg] ⊢ A := by
    apply Derivable.assumption
    simp

  -- Step 3: Apply modus ponens to get ⊥
  -- ¬A = A → ⊥, so from A and (A → ⊥), we get ⊥
  have h_bot : [A, A.neg] ⊢ Formula.bot :=
    Derivable.modus_ponens [A, A.neg] A Formula.bot h_neg_a h_a

  -- Step 4: From ⊥, derive B using DNE
  -- We derive ¬¬B from ⊥, then apply DNE

  -- By prop_s: ⊥ → (B.neg → ⊥) which is ⊥ → ¬¬B
  have bot_to_neg_neg_b : ⊢ Formula.bot.imp B.neg.neg :=
    Derivable.axiom [] _ (Axiom.prop_s Formula.bot B.neg)

  -- Weaken to context
  have bot_to_neg_neg_b_ctx : [A, A.neg] ⊢ Formula.bot.imp B.neg.neg :=
    Derivable.weakening [] [A, A.neg] _ bot_to_neg_neg_b (by intro; simp)

  -- Apply modus ponens to get ¬¬B from ⊥
  have neg_neg_b : [A, A.neg] ⊢ B.neg.neg :=
    Derivable.modus_ponens [A, A.neg] Formula.bot B.neg.neg bot_to_neg_neg_b_ctx h_bot

  -- Now use DNE: ¬¬B → B
  have dne_b : ⊢ B.neg.neg.imp B :=
    Derivable.axiom [] _ (Axiom.double_negation B)

  -- Weaken to context [A, ¬A]
  have dne_b_ctx : [A, A.neg] ⊢ B.neg.neg.imp B :=
    Derivable.weakening [] [A, A.neg] _ dne_b (by intro; simp)

  -- Apply modus ponens to get B
  exact Derivable.modus_ponens [A, A.neg] B.neg.neg B dne_b_ctx neg_neg_b

/--
Reductio ad Absurdum: `⊢ A → (¬A → B)`.

Classical proof by contradiction: if assuming A and ¬A together allows deriving B,
then the implication holds.

**Proof Strategy**: From A and ¬A, derive contradiction, then anything follows (ECQ).

Proof:
1. By ECQ: `[A, ¬A] ⊢ B`
2. Use deduction theorem pattern to lift to `⊢ A → (¬A → B)`
-/
theorem raa (A B : Formula) : ⊢ A.imp (A.neg.imp B) := by
  -- We need to show: ⊢ A → (¬A → B)
  -- Strategy: From A and ¬A, we get ⊥, then from ⊥ we derive B

  -- First, derive ⊥ → B
  -- ⊥ → ¬¬B is prop_s: ⊥ → (B.neg → ⊥)
  have bot_implies_neg_neg_b : ⊢ Formula.bot.imp B.neg.neg :=
    Derivable.axiom [] _ (Axiom.prop_s Formula.bot B.neg)

  -- DNE: ¬¬B → B
  have dne_b : ⊢ B.neg.neg.imp B :=
    Derivable.axiom [] _ (Axiom.double_negation B)

  -- Compose to get ⊥ → B using b_combinator
  have b_comp : ⊢ (B.neg.neg.imp B).imp
                   ((Formula.bot.imp B.neg.neg).imp (Formula.bot.imp B)) :=
    @b_combinator Formula.bot B.neg.neg B

  have step1 : ⊢ (Formula.bot.imp B.neg.neg).imp (Formula.bot.imp B) :=
    Derivable.modus_ponens [] _ _ b_comp dne_b

  have bot_to_b : ⊢ Formula.bot.imp B :=
    Derivable.modus_ponens [] _ _ step1 bot_implies_neg_neg_b

  -- Now derive A → ¬A → ⊥ using theorem_app1
  -- theorem_app1: ⊢ A → (A → ⊥) → ⊥
  have a_to_neg_a_to_bot : ⊢ A.imp A.neg.neg :=
    @theorem_app1 A Formula.bot

  -- Compose: A → ¬¬A and ¬¬A → ¬A → B
  -- We need to build: (¬¬A → ⊥) → (¬A → B) which is (A.neg → ⊥) → (A.neg → B)
  -- This is exactly: (⊥ → B) applied at the A.neg level

  -- Use b_combinator at inner level: (⊥ → B) → (A.neg → ⊥) → (A.neg → B)
  have b_inner : ⊢ (Formula.bot.imp B).imp (A.neg.neg.imp (A.neg.imp B)) :=
    @b_combinator A.neg Formula.bot B

  have step2 : ⊢ A.neg.neg.imp (A.neg.imp B) :=
    Derivable.modus_ponens [] _ _ b_inner bot_to_b

  -- Finally compose: A → ¬¬A → (¬A → B)
  have b_outer : ⊢ (A.neg.neg.imp (A.neg.imp B)).imp
                    ((A.imp A.neg.neg).imp (A.imp (A.neg.imp B))) :=
    @b_combinator A A.neg.neg (A.neg.imp B)

  have step3 : ⊢ (A.imp A.neg.neg).imp (A.imp (A.neg.imp B)) :=
    Derivable.modus_ponens [] _ _ b_outer step2

  exact Derivable.modus_ponens [] _ _ step3 a_to_neg_a_to_bot

/--
Ex Falso Quodlibet: `⊢ ¬A → (A → B)`.

From falsehood (¬A), anything can be derived given A (which creates contradiction).

This is the dual of RAA.

**Proof Strategy**: Apply theorem_flip to RAA.
-/
theorem efq (A B : Formula) : ⊢ A.neg.imp (A.imp B) := by
  -- Goal: ¬A → (A → B)
  -- We have RAA: A → (¬A → B)
  -- We need to flip the arguments

  -- By theorem_flip: (X → Y → Z) → (Y → X → Z)
  -- With X=A, Y=¬A, Z=B
  have raa_inst : ⊢ A.imp (A.neg.imp B) :=
    raa A B

  have flip_inst : ⊢ (A.imp (A.neg.imp B)).imp (A.neg.imp (A.imp B)) :=
    @theorem_flip A A.neg B

  exact Derivable.modus_ponens [] _ _ flip_inst raa_inst

/--
Left Disjunction Introduction: `[A] ⊢ A ∨ B`.

If A holds, then A ∨ B holds.

**Proof Strategy**: Use definition of disjunction (¬A → B) and propositional reasoning.

Recall: A ∨ B = ¬A → B
Goal: From A, derive ¬A → B
This is exactly EFQ: ¬A → (A → B), then apply A
-/
theorem ldi (A B : Formula) : [A] ⊢ A.or B := by
  -- A ∨ B = ¬A → B (by definition)
  unfold Formula.or

  -- Goal: [A] ⊢ ¬A → B

  -- We have EFQ: ⊢ ¬A → (A → B)
  -- We need to get ¬A → B from this and A in context

  -- Strategy: From EFQ and A in context, derive the result

  have efq_inst : ⊢ A.neg.imp (A.imp B) :=
    efq A B

  -- Get A from context
  have h_a : [A] ⊢ A := by
    apply Derivable.assumption
    simp

  -- Weaken EFQ to context [A]
  have efq_ctx : [A] ⊢ A.neg.imp (A.imp B) :=
    Derivable.weakening [] [A] _ efq_inst (by intro; simp)

  -- We need: ¬A → B from ¬A → (A → B) and A

  -- Use prop_k: (¬A → (A → B)) → ((¬A → A) → (¬A → B))
  have k_inst : ⊢ (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    Derivable.axiom [] _ (Axiom.prop_k A.neg A B)

  -- Weaken to context
  have k_ctx : [A] ⊢ (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    Derivable.weakening [] [A] _ k_inst (by intro; simp)

  -- Apply MP
  have step1 : [A] ⊢ (A.neg.imp A).imp (A.neg.imp B) :=
    Derivable.modus_ponens [A] _ _ k_ctx efq_ctx

  -- Now we need: ¬A → A
  -- This is derivable from A using prop_s: A → (¬A → A)
  have s_inst : ⊢ A.imp (A.neg.imp A) :=
    Derivable.axiom [] _ (Axiom.prop_s A A.neg)

  -- Weaken to context
  have s_ctx : [A] ⊢ A.imp (A.neg.imp A) :=
    Derivable.weakening [] [A] _ s_inst (by intro; simp)

  -- Apply MP to get ¬A → A
  have step2 : [A] ⊢ A.neg.imp A :=
    Derivable.modus_ponens [A] A _ s_ctx h_a

  -- Finally, apply MP to get ¬A → B
  exact Derivable.modus_ponens [A] _ _ step1 step2

/--
Right Disjunction Introduction: `[B] ⊢ A ∨ B`.

If B holds, then A ∨ B holds.

**Proof Strategy**: Use definition of disjunction and identity.

Recall: A ∨ B = ¬A → B
From B, we need ¬A → B, which is trivial by weakening (prop_s).
-/
theorem rdi (A B : Formula) : [B] ⊢ A.or B := by
  -- A ∨ B = ¬A → B (by definition)
  unfold Formula.or

  -- Goal: [B] ⊢ ¬A → B

  -- By prop_s: B → (¬A → B)
  have s_inst : ⊢ B.imp (A.neg.imp B) :=
    Derivable.axiom [] _ (Axiom.prop_s B A.neg)

  -- Get B from context
  have h_b : [B] ⊢ B := by
    apply Derivable.assumption
    simp

  -- Weaken s_inst to context
  have s_ctx : [B] ⊢ B.imp (A.neg.imp B) :=
    Derivable.weakening [] [B] _ s_inst (by intro; simp)

  -- Apply MP
  exact Derivable.modus_ponens [B] B _ s_ctx h_b


/--
Reverse Contraposition: `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`.

From `¬A → ¬B`, derive `B → A` using double negation.

**Proof Strategy**: Chain B → ¬¬B → ¬¬A → A using dni, contraposition, and dne.

Proof:
1. DNI for B: `B → ¬¬B`
2. Contrapose h: `¬¬B → ¬¬A` from `¬A → ¬B`
3. DNE for A: `¬¬A → A`
4. Compose all three using b_combinator
-/
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := by
  -- Strategy: B → ¬¬B → ¬¬A → A

  -- Step 1: DNI for B
  have dni_b : ⊢ B.imp B.neg.neg :=
    dni B

  have dni_b_ctx : Γ ⊢ B.imp B.neg.neg :=
    Derivable.weakening [] Γ _ dni_b (by intro; simp)

  -- Step 2: Contrapose h to get ¬¬B → ¬¬A
  -- We have h : Γ ⊢ A.neg → B.neg
  -- Apply contraposition: (A.neg → B.neg) → (B.neg.neg → A.neg.neg)

  have contra_thm : ⊢ (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) := by
    -- Build contraposition for ¬A → ¬B
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z))
    -- So we need to flip the order
    unfold Formula.neg
    have bc : ⊢ ((B.imp Formula.bot).imp Formula.bot).imp
                 (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp ((A.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (A.imp Formula.bot) (B.imp Formula.bot) Formula.bot
    -- Flip to get the right order
    have flip : ⊢ (((B.imp Formula.bot).imp Formula.bot).imp
                    (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp ((A.imp Formula.bot).imp Formula.bot))).imp
                   (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
                    (((B.imp Formula.bot).imp Formula.bot).imp ((A.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((B.imp Formula.bot).imp Formula.bot)
                    ((A.imp Formula.bot).imp (B.imp Formula.bot))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact Derivable.modus_ponens [] _ _ flip bc

  have contra_thm_ctx : Γ ⊢ (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) :=
    Derivable.weakening [] Γ _ contra_thm (by intro; simp)

  have contraposed : Γ ⊢ B.neg.neg.imp A.neg.neg :=
    Derivable.modus_ponens Γ _ _ contra_thm_ctx h

  -- Step 3: Compose B → ¬¬B → ¬¬A
  have b_comp1 : ⊢ (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    @b_combinator B B.neg.neg A.neg.neg

  have b_comp1_ctx : Γ ⊢ (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    Derivable.weakening [] Γ _ b_comp1 (by intro; simp)

  have step1 : Γ ⊢ (B.imp B.neg.neg).imp (B.imp A.neg.neg) :=
    Derivable.modus_ponens Γ _ _ b_comp1_ctx contraposed

  have b_to_neg_neg_a : Γ ⊢ B.imp A.neg.neg :=
    Derivable.modus_ponens Γ _ _ step1 dni_b_ctx

  -- Step 4: Apply DNE to A
  have dne_a : ⊢ A.neg.neg.imp A :=
    Derivable.axiom [] _ (Axiom.double_negation A)

  have dne_a_ctx : Γ ⊢ A.neg.neg.imp A :=
    Derivable.weakening [] Γ _ dne_a (by intro; simp)

  -- Step 5: Compose B → ¬¬A → A
  have b_final : ⊢ (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    @b_combinator B A.neg.neg A

  have b_final_ctx : Γ ⊢ (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    Derivable.weakening [] Γ _ b_final (by intro; simp)

  have step2 : Γ ⊢ (B.imp A.neg.neg).imp (B.imp A) :=
    Derivable.modus_ponens Γ _ _ b_final_ctx dne_a_ctx

  exact Derivable.modus_ponens Γ _ _ step2 b_to_neg_neg_a

/--
Left Conjunction Elimination: `[A ∧ B] ⊢ A`.

From a conjunction A ∧ B, extract the left conjunct A.

**Proof Strategy**: Use conjunction definition and derive ¬¬A, then apply DNE.

Recall: `A ∧ B = (A → B.neg).neg`

From `[(A → ¬B).neg]`, we derive `A`:
1. Show `A.neg → (A → B.neg)` (if A is false, then A → anything)
2. From conjunction in context and step 1, derive `A.neg.neg`
3. Apply DNE to get `A`
-/
theorem lce (A B : Formula) : [A.and B] ⊢ A := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive A

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢ A.and B := by
    apply Derivable.assumption
    simp

  -- Unfold conjunction: A ∧ B = (A → B.neg).neg
  have h_conj_unf : [A.and B] ⊢ (A.imp B.neg).neg := by
    unfold Formula.and at h_conj
    exact h_conj

  -- We need to show: A.neg → (A → B.neg)
  -- This is trivial by EFQ: A.neg → (A → X) for any X
  have efq_helper : ⊢ A.neg.imp (A.imp B.neg) :=
    efq A B.neg

  have efq_ctx : [A.and B] ⊢ A.neg.imp (A.imp B.neg) :=
    Derivable.weakening [] [A.and B] _ efq_helper (by intro; simp)

  -- Now we need: (A.neg → (A → B.neg)) → ((A → B.neg).neg → A.neg.neg)
  -- This is contraposition
  have contra_step : ⊢ (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) := by
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc : ⊢ ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
                 (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp ((A.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (A.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip : ⊢ (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
                    (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp ((A.imp Formula.bot).imp Formula.bot))).imp
                   (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
                    (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp ((A.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact Derivable.modus_ponens [] _ _ flip bc

  have contra_step_ctx : [A.and B] ⊢ (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) :=
    Derivable.weakening [] [A.and B] _ contra_step (by intro; simp)

  -- Apply MP to get (A → B.neg).neg → A.neg.neg
  have step1 : [A.and B] ⊢ (A.imp B.neg).neg.imp A.neg.neg :=
    Derivable.modus_ponens [A.and B] _ _ contra_step_ctx efq_ctx

  -- Apply MP with conjunction to get A.neg.neg
  have neg_neg_a : [A.and B] ⊢ A.neg.neg :=
    Derivable.modus_ponens [A.and B] _ _ step1 h_conj_unf

  -- Apply DNE
  have dne_a : ⊢ A.neg.neg.imp A :=
    Derivable.axiom [] _ (Axiom.double_negation A)

  have dne_a_ctx : [A.and B] ⊢ A.neg.neg.imp A :=
    Derivable.weakening [] [A.and B] _ dne_a (by intro; simp)

  exact Derivable.modus_ponens [A.and B] _ _ dne_a_ctx neg_neg_a

/--
Right Conjunction Elimination: `[A ∧ B] ⊢ B`.

From a conjunction A ∧ B, extract the right conjunct B.

**Proof Strategy**: Similar to LCE, but derive ¬¬B instead.

From `[(A → ¬B).neg]`, we derive `B`:
1. Show `B.neg → (A → B.neg)` (if B is false, then A → B is false is trivial)
2. From conjunction and step 1, derive `B.neg.neg`
3. Apply DNE to get `B`
-/
theorem rce (A B : Formula) : [A.and B] ⊢ B := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive B

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢ A.and B := by
    apply Derivable.assumption
    simp

  -- Unfold conjunction
  have h_conj_unf : [A.and B] ⊢ (A.imp B.neg).neg := by
    unfold Formula.and at h_conj
    exact h_conj

  -- We need: B.neg → (A → B.neg)
  -- This is prop_s: B.neg → (A → B.neg)
  have s_helper : ⊢ B.neg.imp (A.imp B.neg) :=
    Derivable.axiom [] _ (Axiom.prop_s B.neg A)

  have s_ctx : [A.and B] ⊢ B.neg.imp (A.imp B.neg) :=
    Derivable.weakening [] [A.and B] _ s_helper (by intro; simp)

  -- Contrapose: (B.neg → (A → B.neg)) → ((A → B.neg).neg → B.neg.neg)
  have contra_step : ⊢ (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) := by
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc : ⊢ ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
                 (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp ((B.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (B.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip : ⊢ (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
                    (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp ((B.imp Formula.bot).imp Formula.bot))).imp
                   (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
                    (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((B.imp Formula.bot).imp Formula.bot)
    exact Derivable.modus_ponens [] _ _ flip bc

  have contra_step_ctx : [A.and B] ⊢ (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) :=
    Derivable.weakening [] [A.and B] _ contra_step (by intro; simp)

  -- Apply MP
  have step1 : [A.and B] ⊢ (A.imp B.neg).neg.imp B.neg.neg :=
    Derivable.modus_ponens [A.and B] _ _ contra_step_ctx s_ctx

  -- Apply MP with conjunction
  have neg_neg_b : [A.and B] ⊢ B.neg.neg :=
    Derivable.modus_ponens [A.and B] _ _ step1 h_conj_unf

  -- Apply DNE
  have dne_b : ⊢ B.neg.neg.imp B :=
    Derivable.axiom [] _ (Axiom.double_negation B)

  have dne_b_ctx : [A.and B] ⊢ B.neg.neg.imp B :=
    Derivable.weakening [] [A.and B] _ dne_b (by intro; simp)

  exact Derivable.modus_ponens [A.and B] _ _ dne_b_ctx neg_neg_b

/--
Left Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → A`.

Extract left conjunct as an implication (no context).

**Status**: Requires full deduction theorem or extremely complex nested combinator proof.

The context-based version `lce` is proven. This implication form would enable:
- More compositional reasoning without context manipulation
- box_conj_iff forward direction in ModalS5.lean

**Workaround**: Use `lce` with weakening when contexts are available.
-/
theorem lce_imp (A B : Formula) : ⊢ (A.and B).imp A := by
  sorry -- Requires deduction theorem infrastructure

/--
Right Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → B`.

Extract right conjunct as an implication (no context).

**Status**: Requires full deduction theorem or extremely complex nested combinator proof.

The context-based version `rce` is proven. This implication form would enable:
- More compositional reasoning without context manipulation
- box_conj_iff forward direction in ModalS5.lean

**Workaround**: Use `rce` with weakening when contexts are available.
-/
theorem rce_imp (A B : Formula) : ⊢ (A.and B).imp B := by
  sorry -- Requires deduction theorem infrastructure

/-!
## Phase 3: Context Manipulation and Classical Reasoning

Infrastructure theorems for context-dependent reasoning and classical logic principles.
-/

/--
Classical Merge Lemma: `⊢ (P → Q) → ((¬P → Q) → Q)`.

From both (P → Q) and (¬P → Q), derive Q by case analysis on P ∨ ¬P (LEM).

**Proof Strategy**: Use DNE (Double Negation Elimination).

Key insight: From ¬Q, we can derive both ¬P and ¬¬P, which is a contradiction.
1. From (P → Q), contrapose to get (¬Q → ¬P)
2. From (¬P → Q), contrapose to get (¬Q → ¬¬P)
3. From ¬Q, derive both ¬P and ¬¬P (contradiction)
4. Therefore ¬¬Q, hence Q by DNE

Proof:
1. Contrapose (P → Q) to get (¬Q → ¬P)
2. Contrapose (¬P → Q) to get (¬Q → ¬¬P)
3. Build (¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q) using RAA pattern
4. Compose with DNE to get Q
-/
theorem classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q) := by
  -- Goal: (P → Q) → ((¬P → Q) → Q)
  -- This is case analysis on P using LEM.
  --
  -- This requires deduction theorem infrastructure or sequent calculus machinery.
  -- Marked as sorry pending Phase 3 development.
  --
  -- Previous attempt (275 lines) had type errors in complex combinator manipulation.
  -- The proof requires either:
  -- 1. Deduction theorem for Hilbert systems
  -- 2. Disjunction elimination with sophisticated context handling
  -- 3. Meta-level case analysis beyond pure Hilbert calculus
  sorry
theorem iff_intro (A B : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp A) :
    ⊢ (A.imp B).and (B.imp A) := by
  -- Use pairing: A → B → (A ∧ B)
  have pair_inst : ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
    pairing (A.imp B) (B.imp A)

  -- Apply MP twice
  have step1 : ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
    Derivable.modus_ponens [] _ _ pair_inst h1

  exact Derivable.modus_ponens [] _ _ step1 h2

/--
Left Biconditional Elimination: From `A ↔ B` and `A`, derive `B`.

**Proof Strategy**: Extract `A → B` from biconditional using lce, then apply modus ponens.
-/
theorem iff_elim_left (A B : Formula) : [((A.imp B).and (B.imp A)), A] ⊢ B := by
  -- Get A from context
  have h_a : [((A.imp B).and (B.imp A)), A] ⊢ A := by
    apply Derivable.assumption
    simp

  -- Get biconditional from context and extract (A → B) using lce
  have h_iff : [((A.imp B).and (B.imp A)), A] ⊢ (A.imp B).and (B.imp A) := by
    apply Derivable.assumption
    simp

  -- Extract (A → B) using lce
  have h_imp : [((A.imp B).and (B.imp A)), A] ⊢ A.imp B := by
    -- We need lce but with the specific context
    -- lce gives us [X ∧ Y] ⊢ X
    -- We have [(A → B) ∧ (B → A), A] and need (A → B)
    -- Use weakening from lce
    have lce_inst : [(A.imp B).and (B.imp A)] ⊢ A.imp B :=
      lce (A.imp B) (B.imp A)
    exact Derivable.weakening [(A.imp B).and (B.imp A)] _ _ lce_inst (by intro x; simp; intro h; left; exact h)

  -- Apply modus ponens
  exact Derivable.modus_ponens _ _ _ h_imp h_a

/--
Right Biconditional Elimination: From `A ↔ B` and `B`, derive `A`.

**Proof Strategy**: Extract `B → A` from biconditional using rce, then apply modus ponens.
-/
theorem iff_elim_right (A B : Formula) : [((A.imp B).and (B.imp A)), B] ⊢ A := by
  -- Get B from context
  have h_b : [((A.imp B).and (B.imp A)), B] ⊢ B := by
    apply Derivable.assumption
    simp

  -- Get biconditional from context and extract (B → A) using rce
  have h_imp : [((A.imp B).and (B.imp A)), B] ⊢ B.imp A := by
    -- Use weakening from rce
    have rce_inst : [(A.imp B).and (B.imp A)] ⊢ B.imp A :=
      rce (A.imp B) (B.imp A)
    exact Derivable.weakening [(A.imp B).and (B.imp A)] _ _ rce_inst (by intro x; simp; intro h; left; exact h)

  -- Apply modus ponens
  exact Derivable.modus_ponens _ _ _ h_imp h_b

end Logos.Core.Theorems.Propositional
