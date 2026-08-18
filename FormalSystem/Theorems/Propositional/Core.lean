/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Automation.LemmaDB

/-!
# Core Propositional Proof Combinators: LEM, negImp, botOfAndNeg, impNegImp, Disjunction Intro,
Conjunction Elim

Core propositional reasoning combinators for the Hilbert-style proof system.
Contains LEM, ex falso quodlibet (negImp), ex contradictione quodlibet (botOfAndNeg),
reductio ad absurdum (impNegImp), left/right disjunction introduction (orInl, orInr),
left/right conjunction elimination (andLeft, andRight), and right conjunction principle
(impOfNegImpNeg).
-/

namespace FormalSystem.Theorems.Propositional

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

noncomputable section

/-!
## Helper Lemmas
-/

/--
Law of Excluded Middle: `⊢ A ∨ ¬A`.

This is a classical logic principle that states every proposition is either true or false.

**Derivation**: Use double negation elimination and propositional axioms.

In TM logic, we have:
- `doubleNegation`: `¬¬φ → φ`
- `notNotIntro`: `φ → ¬¬φ`

We derive LEM by showing `¬(A ∨ ¬A)` leads to contradiction.

Recall: `A ∨ B = ¬A → B`
So: `A ∨ ¬A = ¬A → ¬A = identity ¬A`

Therefore: `⊢ A ∨ ¬A` is immediate from identity.
-/
@[tmLemma]
def em {fc : FrameClass} (A : Formula) : ⊢[fc] A.or A.neg := by
  -- A ∨ ¬A = ¬A → ¬A (by definition of disjunction)
  unfold Formula.or
  -- Now goal is: ⊢ A.neg.imp A.neg
  exact identity A.neg


/-!
## Axiomatic Helpers and Derived Classical Principles

This section defines axiom wrappers (efqAxiom, peirceAxiom) and derives
the double negation elimination theorem from these axioms.
-/

/--
Ex falso quodlibet (axiomatic): `⊢ ⊥ → φ`.

A thin wrapper around the `Axiom.ex_falso` axiom, lifted to an arbitrary frame
class via `FrameClass.base_le`, so that proofs can cite it by name rather than
rebuilding the axiom application.
-/
@[tmLemma]
def efqAxiom {fc : FrameClass} (φ : Formula) : ⊢[fc] Formula.bot.imp φ :=
  DerivationTree.axiom [] _ (Axiom.ex_falso φ) (FrameClass.base_le fc)

/--
Peirce's Law (axiomatic): `⊢ ((φ → ψ) → φ) → φ`.

Classical reasoning in pure implicational form. This is now an axiom.

This theorem provides a convenient wrapper around Peirce's Law axiom for use in proofs.
-/
@[tmLemma]
def peirceAxiom {fc : FrameClass} (φ ψ : Formula) : ⊢[fc] ((φ.imp ψ).imp φ).imp φ :=
  DerivationTree.axiom [] _ (Axiom.peirce φ ψ) (FrameClass.base_le fc)

/-!
## Derivable Classical Principles

Classical logic principles derivable from the EFQ and Peirce axioms.

These theorems demonstrate that the classical reasoning power of Double Negation
Elimination (DNE), Law of Excluded Middle (LEM), and related principles are all
derivable from the more foundational EFQ + Peirce axiomatization.

**Historical Note**: The replacement of DNE with EFQ + Peirce separates two concerns:
1. **EFQ** characterizes what `⊥` (absurdity) means - accepted in both
   classical and intuitionistic logic
2. **Peirce** provides classical (vs intuitionistic) reasoning - uses only implication

This modular presentation aligns with modern logic textbooks (Mendelson, van Dalen, Prawitz)
and makes the logical structure more transparent.
-/

/--
Double Negation Elimination (derived): `⊢ ¬¬φ → φ`.

Classical principle: if a formula is not false, it is true.

**Derivation from EFQ + Peirce**:
This theorem is now derived from the more foundational axioms EFQ (`⊥ → φ`) and
Peirce's Law (`((φ → ψ) → φ) → φ`), demonstrating that these axioms provide
the same classical reasoning power as DNE while offering better conceptual modularity.

**Proof Strategy**:
1. `¬¬φ = (φ → ⊥) → ⊥` (definition of negation)
2. Peirce with `ψ = ⊥`: `⊢ ((φ → ⊥) → φ) → φ`
3. EFQ: `⊢ ⊥ → φ`
4. Compose using bCombinator: from `⊥ → φ` derive `(φ → ⊥) → φ` (given `(φ → ⊥) → ⊥`)
5. Apply Peirce to get `φ`

**Dependencies**: Only requires prop_k, prop_s, EFQ, Peirce, and bCombinator.
No circular dependencies - bCombinator is derived from K and S without using DNE.

**Complexity**: Medium (7 proof steps)

**Historical Note**: Previously an axiom, now a derived theorem. This change
improves the foundational structure without affecting derivational power.
-/
@[tmLemma]
def doubleNegation {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.neg.neg.imp φ := by
  -- ¬¬φ = (φ → ⊥) → ⊥ (definition)
  unfold Formula.neg
  -- Goal: ⊢[fc] ((φ → ⊥) → ⊥) → φ

  -- Step 1: Peirce with ψ = ⊥ gives us: ⊢ ((φ → ⊥) → φ) → φ
  have peirce_inst : ⊢[fc] ((φ.imp Formula.bot).imp φ).imp φ :=
    peirceAxiom φ Formula.bot
  -- Step 2: EFQ gives us: ⊢ ⊥ → φ
  have efq_inst : ⊢[fc] Formula.bot.imp φ :=
    efqAxiom φ
  -- Step 3: Use bCombinator to compose (⊥ → φ) with ((φ → ⊥) → ⊥)
  have b_inst : ⊢[fc] (Formula.bot.imp φ).imp
                   (((φ.imp Formula.bot).imp Formula.bot).imp
                    ((φ.imp Formula.bot).imp φ)) :=
    bCombinator
  -- Step 4: Apply modus ponens with efq_inst
  have step1 : ⊢[fc] ((φ.imp Formula.bot).imp Formula.bot).imp
                  ((φ.imp Formula.bot).imp φ) :=
    DerivationTree.modus_ponens [] _ _ b_inst efq_inst
  -- Step 5: Now compose with Peirce
  have b_final : ⊢[fc] (((φ.imp Formula.bot).imp φ).imp φ).imp
                    ((((φ.imp Formula.bot).imp Formula.bot).imp
                      ((φ.imp Formula.bot).imp φ)).imp
                     (((φ.imp Formula.bot).imp Formula.bot).imp φ)) :=
    bCombinator
  -- Step 6: Apply modus ponens with peirce_inst
  have step2 : ⊢[fc] (((φ.imp Formula.bot).imp Formula.bot).imp
                   ((φ.imp Formula.bot).imp φ)).imp
                  (((φ.imp Formula.bot).imp Formula.bot).imp φ) :=
    DerivationTree.modus_ponens [] _ _ b_final peirce_inst
  -- Step 7: Final modus ponens
  exact DerivationTree.modus_ponens [] _ _ step2 step1

/-!
## Phase 1: Propositional Foundations

Core propositional theorems for negation, conjunction, disjunction, and contraposition.
-/

/--
Ex Contradictione Quodlibet: `[A, ¬A] ⊢ B`.

From a contradiction (both A and ¬A), anything follows. This is the principle of explosion
in classical logic.

## Parameters
- `A`: The formula that is both asserted and negated
- `B`: Any arbitrary formula to be derived

## Returns
A derivation of B from the contradictory context [A, ¬A]

## Proof Strategy
1. From ¬A in context, we have A → ⊥
2. From A in context and A → ⊥, derive ⊥ via modus ponens
3. From ⊥, derive ¬¬B using prop_s
4. Apply double negation elimination to get B

## Related Theorems
- `impNegImp`: Reductio ad Absurdum - the implication form `A → (¬A → B)`
- `impOfNeg`: Ex Falso Quodlibet - from ¬A and A, derive B
- `doubleNegation`: DNE used in the proof

## Example
```lean
-- From both P and ¬P, we can derive any formula Q
example (P Q : Formula) : [P, P.neg] ⊢ Q := botOfAndNeg P Q
```
-/
def botOfAndNeg {fc : FrameClass} (A B : Formula) : [A, A.neg] ⊢[fc] B := by
  -- Goal: [A, ¬A] ⊢ B where ¬A = A → ⊥
  -- From ¬A in context, we have A → ⊥
  -- From A in context, we get ⊥
  -- From ⊥, derive B using DNE

  -- Step 1: Get ¬A from context (second assumption)
  have h_neg_a : [A, A.neg] ⊢[fc] A.neg := by
    apply DerivationTree.assumption
    simp
  -- Step 2: Get A from context (first assumption)
  have h_a : [A, A.neg] ⊢[fc] A := by
    apply DerivationTree.assumption
    simp
  -- Step 3: Apply modus ponens to get ⊥
  -- ¬A = A → ⊥, so from A and (A → ⊥), we get ⊥
  have h_bot : [A, A.neg] ⊢[fc] Formula.bot :=
    DerivationTree.modus_ponens [A, A.neg] A Formula.bot h_neg_a h_a
  -- Step 4: From ⊥, derive B using DNE
  -- We derive ¬¬B from ⊥, then apply DNE

  -- By prop_s: ⊥ → (B.neg → ⊥) which is ⊥ → ¬¬B
  have bot_to_neg_neg_b : ⊢[fc] Formula.bot.imp B.neg.neg :=
    DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot B.neg) (FrameClass.base_le fc)
  -- Weaken to context
  have bot_to_neg_neg_b_ctx : [A, A.neg] ⊢[fc] Formula.bot.imp B.neg.neg :=
    DerivationTree.weakening [] [A, A.neg] _ bot_to_neg_neg_b (by intro; simp)
  -- Apply modus ponens to get ¬¬B from ⊥
  have neg_neg_b : [A, A.neg] ⊢[fc] B.neg.neg :=
    DerivationTree.modus_ponens [A, A.neg] Formula.bot B.neg.neg bot_to_neg_neg_b_ctx h_bot
  -- Now use DNE: ¬¬B → B
  have dne_b : ⊢[fc] B.neg.neg.imp B :=
    doubleNegation B
  -- Weaken to context [A, ¬A]
  have dne_b_ctx : [A, A.neg] ⊢[fc] B.neg.neg.imp B :=
    DerivationTree.weakening [] [A, A.neg] _ dne_b (by intro; simp)
  -- Apply modus ponens to get B
  exact DerivationTree.modus_ponens [A, A.neg] B.neg.neg B dne_b_ctx neg_neg_b

/--
Reductio ad Absurdum: `⊢ A → (¬A → B)`.

Classical proof by contradiction: if assuming A and ¬A together allows deriving B,
then the implication holds.

**Proof Strategy**: From A and ¬A, derive contradiction, then anything follows (ECQ).

Proof:
1. By ECQ: `[A, ¬A] ⊢ B`
2. Use deduction theorem pattern to lift to `⊢ A → (¬A → B)`
-/
@[tmLemma]
def impNegImp {fc : FrameClass} (A B : Formula) : ⊢[fc] A.imp (A.neg.imp B) := by
  -- We need to show: ⊢ A → (¬A → B)
  -- Strategy: From A and ¬A, we get ⊥, then from ⊥ we derive B

  -- First, use EFQ: ⊥ → B
  have bot_to_b : ⊢[fc] Formula.bot.imp B :=
    efqAxiom B
  -- Now derive A → ¬A → ⊥ using theoremApp1
  -- theoremApp1: ⊢ A → (A → ⊥) → ⊥
  have a_to_neg_a_to_bot : ⊢[fc] A.imp A.neg.neg :=
    @theoremApp1 fc A Formula.bot
  -- Compose: A → ¬¬A and ¬¬A → ¬A → B
  -- We need to build: (¬¬A → ⊥) → (¬A → B) which is (A.neg → ⊥) → (A.neg → B)
  -- This is exactly: (⊥ → B) applied at the A.neg level

  -- Use bCombinator at inner level: (⊥ → B) → (A.neg → ⊥) → (A.neg → B)
  have b_inner : ⊢[fc] (Formula.bot.imp B).imp (A.neg.neg.imp (A.neg.imp B)) :=
    @bCombinator fc A.neg Formula.bot B
  have step2 : ⊢[fc] A.neg.neg.imp (A.neg.imp B) :=
    DerivationTree.modus_ponens [] _ _ b_inner bot_to_b
  -- Finally compose: A → ¬¬A → (¬A → B)
  have b_outer : ⊢[fc] (A.neg.neg.imp (A.neg.imp B)).imp
                    ((A.imp A.neg.neg).imp (A.imp (A.neg.imp B))) :=
    @bCombinator fc A A.neg.neg (A.neg.imp B)
  have step3 : ⊢[fc] (A.imp A.neg.neg).imp (A.imp (A.neg.imp B)) :=
    DerivationTree.modus_ponens [] _ _ b_outer step2
  exact DerivationTree.modus_ponens [] _ _ step3 a_to_neg_a_to_bot

/-
Ex Falso Quodlibet (axiomatic): `⊢ ⊥ → φ`.

From absurdity (`⊥`), anything can be derived. This is now an axiom (EFQ).

This theorem provides a convenient wrapper around the EFQ axiom for use in proofs.
-/

/--
Ex Falso Quodlibet (negation form): `⊢ ¬A → (A → B)`.

From a negated formula and its affirmation, anything follows. This is the flipped
form of RAA (Reductio ad Absurdum).

## Parameters
- `A`: The formula that appears both negated and affirmed
- `B`: Any arbitrary formula to be derived

## Returns
A proof that ¬A → (A → B) holds unconditionally

## Proof Strategy
1. Use RAA to get A → (¬A → B)
2. Apply theoremFlip to swap the arguments: ¬A → (A → B)

## Related Theorems
- `impNegImp`: Reductio ad Absurdum - `A → (¬A → B)`
- `botOfAndNeg`: Ex Contradictione Quodlibet - context-based form `[A, ¬A] ⊢ B`
- `theoremFlip`: Used to swap implication arguments

## Example
```lean
-- If we have ¬P, then from P we can derive any Q
example (P Q : Formula) : ⊢ P.neg.imp (P.imp Q) := impOfNeg P Q
```

## Note
This is the primary `negImp` definition. The old `negImp` name is deprecated and aliased
to this function for backward compatibility.
-/
@[tmLemma]
def impOfNeg {fc : FrameClass} (A B : Formula) : ⊢[fc] A.neg.imp (A.imp B) := by
  -- Goal: ¬A → (A → B)
  -- We have RAA: A → (¬A → B)
  -- Apply theoremFlip
  have raa_inst : ⊢[fc] A.imp (A.neg.imp B) :=
    impNegImp A B
  have flip_inst : ⊢[fc] (A.imp (A.neg.imp B)).imp (A.neg.imp (A.imp B)) :=
    @theoremFlip fc A A.neg B
  exact DerivationTree.modus_ponens [] _ _ flip_inst raa_inst

/--
Ex Falso Quodlibet (backward compatibility alias).

This alias maintains backward compatibility with code using the old `negImp` name.
-/
@[deprecated impOfNeg (since := "2025-12-14")]
def negImp {fc : FrameClass} (A B : Formula) : ⊢[fc] A.neg.imp (A.imp B) := impOfNeg A B

/--
Left Disjunction Introduction: `[A] ⊢ A ∨ B`.

If A holds, then A ∨ B holds.

**Proof Strategy**: Use definition of disjunction and EFQ.

Recall: A ∨ B = ¬A → B
From A, we need ¬A → B. From ¬A and A, we get ⊥, then B follows by EFQ.
-/
def orInl {fc : FrameClass} (A B : Formula) : [A] ⊢[fc] A.or B := by
  -- A ∨ B = ¬A → B (by definition)
  unfold Formula.or
  -- Goal: [A] ⊢ ¬A → B

  -- We have EFQ: ⊢ ¬A → (A → B)
  -- We need to get ¬A → B from this and A in context

  -- Strategy: From EFQ and A in context, derive the result
  have efq_inst : ⊢[fc] A.neg.imp (A.imp B) :=
    impOfNeg A B
  -- Get A from context
  have h_a : [A] ⊢[fc] A := by
    apply DerivationTree.assumption
    simp
  -- Weaken EFQ to context [A]
  have efq_ctx : [A] ⊢[fc] A.neg.imp (A.imp B) :=
    DerivationTree.weakening [] [A] _ efq_inst (by intro; simp)
  -- We need: ¬A → B from ¬A → (A → B) and A

  -- Use prop_k: (¬A → (A → B)) → ((¬A → A) → (¬A → B))
  have k_inst : ⊢[fc] (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k A.neg A B) (FrameClass.base_le fc)
  -- Weaken to context
  have k_ctx : [A] ⊢[fc] (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    DerivationTree.weakening [] [A] _ k_inst (by intro; simp)
  -- Apply MP
  have step1 : [A] ⊢[fc] (A.neg.imp A).imp (A.neg.imp B) :=
    DerivationTree.modus_ponens [A] _ _ k_ctx efq_ctx
  -- Now we need: ¬A → A
  -- This is derivable from A using prop_s: A → (¬A → A)
  have s_inst : ⊢[fc] A.imp (A.neg.imp A) :=
    DerivationTree.axiom [] _ (Axiom.prop_s A A.neg) (FrameClass.base_le fc)
  -- Weaken to context
  have s_ctx : [A] ⊢[fc] A.imp (A.neg.imp A) :=
    DerivationTree.weakening [] [A] _ s_inst (by intro; simp)
  -- Apply MP to get ¬A → A
  have step2 : [A] ⊢[fc] A.neg.imp A :=
    DerivationTree.modus_ponens [A] A _ s_ctx h_a
  -- Finally, apply MP to get ¬A → B
  exact DerivationTree.modus_ponens [A] _ _ step1 step2

/--
Right Disjunction Introduction: `[B] ⊢ A ∨ B`.

If B holds, then A ∨ B holds.

**Proof Strategy**: Use definition of disjunction and identity.

Recall: A ∨ B = ¬A → B
From B, we need ¬A → B, which is trivial by weakening (prop_s).
-/
def orInr {fc : FrameClass} (A B : Formula) : [B] ⊢[fc] A.or B := by
  -- A ∨ B = ¬A → B (by definition)
  unfold Formula.or
  -- Goal: [B] ⊢ ¬A → B

  -- By prop_s: B → (¬A → B)
  have s_inst : ⊢[fc] B.imp (A.neg.imp B) :=
    DerivationTree.axiom [] _ (Axiom.prop_s B A.neg) (FrameClass.base_le fc)
  -- Get B from context
  have h_b : [B] ⊢[fc] B := by
    apply DerivationTree.assumption
    simp
  -- Weaken s_inst to context
  have s_ctx : [B] ⊢[fc] B.imp (A.neg.imp B) :=
    DerivationTree.weakening [] [B] _ s_inst (by intro; simp)
  -- Apply MP
  exact DerivationTree.modus_ponens [B] B _ s_ctx h_b


/--
Reverse Contraposition: `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`.

From `¬A → ¬B`, derive `B → A` using double negation.

**Proof Strategy**: Chain B → ¬¬B → ¬¬A → A using notNotIntro, contraposition, and dne.

Proof:
1. DNI for B: `B → ¬¬B`
2. Contrapose h: `¬¬B → ¬¬A` from `¬A → ¬B`
3. DNE for A: `¬¬A → A`
4. Compose all three using bCombinator
-/
def impOfNegImpNeg {fc : FrameClass} (Γ : Context) (A B : Formula) (h : Γ ⊢[fc] A.neg.imp B.neg) : Γ ⊢[fc] B.imp A := by
  -- Strategy: B → ¬¬B → ¬¬A → A

  -- Step 1: DNI for B
  have dni_b : ⊢[fc] B.imp B.neg.neg :=
    notNotIntro B
  have dni_b_ctx : Γ ⊢[fc] B.imp B.neg.neg :=
    DerivationTree.weakening [] Γ _ dni_b (by intro; simp)
  -- Step 2: Contrapose h to get ¬¬B → ¬¬A
  -- We have h : Γ ⊢ A.neg → B.neg
  -- Apply contraposition: (A.neg → B.neg) → (B.neg.neg → A.neg.neg)
  have contra_thm : ⊢[fc] (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) := by
    -- Build contraposition for ¬A → ¬B
    -- bCombinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z))
    -- So we need to flip the order
    unfold Formula.neg
    have bc :
      ⊢[fc] ((B.imp Formula.bot).imp Formula.bot).imp
        (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
         ((A.imp Formula.bot).imp Formula.bot)) :=
      @bCombinator fc (A.imp Formula.bot) (B.imp Formula.bot) Formula.bot
    -- Flip to get the right order
    have flip :
      ⊢[fc] (((B.imp Formula.bot).imp Formula.bot).imp
         (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
          ((A.imp Formula.bot).imp Formula.bot))).imp
        (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
         (((B.imp Formula.bot).imp Formula.bot).imp
          ((A.imp Formula.bot).imp Formula.bot))) :=
      @theoremFlip fc ((B.imp Formula.bot).imp Formula.bot)
                    ((A.imp Formula.bot).imp (B.imp Formula.bot))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc
  have contra_thm_ctx : Γ ⊢[fc] (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) :=
    DerivationTree.weakening [] Γ _ contra_thm (by intro; simp)
  have contraposed : Γ ⊢[fc] B.neg.neg.imp A.neg.neg :=
    DerivationTree.modus_ponens Γ _ _ contra_thm_ctx h
  -- Step 3: Compose B → ¬¬B → ¬¬A
  have b_comp1 : ⊢[fc] (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    @bCombinator fc B B.neg.neg A.neg.neg
  have b_comp1_ctx : Γ ⊢[fc] (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    DerivationTree.weakening [] Γ _ b_comp1 (by intro; simp)
  have step1 : Γ ⊢[fc] (B.imp B.neg.neg).imp (B.imp A.neg.neg) :=
    DerivationTree.modus_ponens Γ _ _ b_comp1_ctx contraposed
  have b_to_neg_neg_a : Γ ⊢[fc] B.imp A.neg.neg :=
    DerivationTree.modus_ponens Γ _ _ step1 dni_b_ctx
  -- Step 4: Apply DNE to A
  have dne_a : ⊢[fc] A.neg.neg.imp A :=
    doubleNegation A
  have dne_a_ctx : Γ ⊢[fc] A.neg.neg.imp A :=
    DerivationTree.weakening [] Γ _ dne_a (by intro; simp)
  -- Step 5: Compose B → ¬¬A → A
  have b_final : ⊢[fc] (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    @bCombinator fc B A.neg.neg A
  have b_final_ctx : Γ ⊢[fc] (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    DerivationTree.weakening [] Γ _ b_final (by intro; simp)
  have step2 : Γ ⊢[fc] (B.imp A.neg.neg).imp (B.imp A) :=
    DerivationTree.modus_ponens Γ _ _ b_final_ctx dne_a_ctx
  exact DerivationTree.modus_ponens Γ _ _ step2 b_to_neg_neg_a

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
def andLeft {fc : FrameClass} (A B : Formula) : [A.and B] ⊢[fc] A := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive A

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢[fc] A.and B := by
    apply DerivationTree.assumption
    simp
  -- Unfold conjunction: A ∧ B = (A → B.neg).neg
  have h_conj_unf : [A.and B] ⊢[fc] (A.imp B.neg).neg := by
    unfold Formula.and at h_conj
    exact h_conj
  -- We need to show: A.neg → (A → B.neg)
  -- This is trivial by EFQ: A.neg → (A → X) for any X
  have efq_helper : ⊢[fc] A.neg.imp (A.imp B.neg) :=
    impOfNeg A B.neg
  have efq_ctx : [A.and B] ⊢[fc] A.neg.imp (A.imp B.neg) :=
    DerivationTree.weakening [] [A.and B] _ efq_helper (by intro; simp)
  -- Now we need: (A.neg → (A → B.neg)) → ((A → B.neg).neg → A.neg.neg)
  -- This is contraposition
  have contra_step :
    ⊢[fc] (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) := by
    -- bCombinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc :
      ⊢[fc] ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
        (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         ((A.imp Formula.bot).imp Formula.bot)) :=
      @bCombinator fc (A.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip :
      ⊢[fc] (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
         (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
          ((A.imp Formula.bot).imp Formula.bot))).imp
        (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
          ((A.imp Formula.bot).imp Formula.bot))) :=
      @theoremFlip fc ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc
  have contra_step_ctx :
    [A.and B] ⊢[fc] (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) :=
    DerivationTree.weakening [] [A.and B] _ contra_step (by intro; simp)
  -- Apply MP to get (A → B.neg).neg → A.neg.neg
  have step1 : [A.and B] ⊢[fc] (A.imp B.neg).neg.imp A.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ contra_step_ctx efq_ctx
  -- Apply MP with conjunction to get A.neg.neg
  have neg_neg_a : [A.and B] ⊢[fc] A.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ step1 h_conj_unf
  -- Apply DNE
  have dne_a : ⊢[fc] A.neg.neg.imp A :=
    doubleNegation A
  have dne_a_ctx : [A.and B] ⊢[fc] A.neg.neg.imp A :=
    DerivationTree.weakening [] [A.and B] _ dne_a (by intro; simp)
  exact DerivationTree.modus_ponens [A.and B] _ _ dne_a_ctx neg_neg_a

/--
Right Conjunction Elimination: `[A ∧ B] ⊢ B`.

From a conjunction A ∧ B, extract the right conjunct B.

**Proof Strategy**: Similar to LCE, but derive ¬¬B instead.

From `[(A → ¬B).neg]`, we derive `B`:
1. Show `B.neg → (A → B.neg)` (if B is false, then A → B is false is trivial)
2. From conjunction and step 1, derive `B.neg.neg`
3. Apply DNE to get `B`
-/
def andRight {fc : FrameClass} (A B : Formula) : [A.and B] ⊢[fc] B := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive B

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢[fc] A.and B := by
    apply DerivationTree.assumption
    simp
  -- Unfold conjunction
  have h_conj_unf : [A.and B] ⊢[fc] (A.imp B.neg).neg := by
    unfold Formula.and at h_conj
    exact h_conj
  -- We need: B.neg → (A → B.neg)
  -- This is prop_s: B.neg → (A → B.neg)
  have s_helper : ⊢[fc] B.neg.imp (A.imp B.neg) :=
    DerivationTree.axiom [] _ (Axiom.prop_s B.neg A) (FrameClass.base_le fc)
  have s_ctx : [A.and B] ⊢[fc] B.neg.imp (A.imp B.neg) :=
    DerivationTree.weakening [] [A.and B] _ s_helper (by intro; simp)
  -- Contrapose: (B.neg → (A → B.neg)) → ((A → B.neg).neg → B.neg.neg)
  have contra_step :
    ⊢[fc] (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) := by
    -- bCombinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc :
      ⊢[fc] ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
        (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         ((B.imp Formula.bot).imp Formula.bot)) :=
      @bCombinator fc (B.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip :
      ⊢[fc] (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
         (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
          ((B.imp Formula.bot).imp Formula.bot))).imp
        (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
          ((B.imp Formula.bot).imp Formula.bot))) :=
      @theoremFlip fc ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((B.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc
  have contra_step_ctx :
    [A.and B] ⊢[fc] (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) :=
    DerivationTree.weakening [] [A.and B] _ contra_step (by intro; simp)
  -- Apply MP
  have step1 : [A.and B] ⊢[fc] (A.imp B.neg).neg.imp B.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ contra_step_ctx s_ctx
  -- Apply MP with conjunction
  have neg_neg_b : [A.and B] ⊢[fc] B.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ step1 h_conj_unf
  -- Apply DNE
  have dne_b : ⊢[fc] B.neg.neg.imp B :=
    doubleNegation B
  have dne_b_ctx : [A.and B] ⊢[fc] B.neg.neg.imp B :=
    DerivationTree.weakening [] [A.and B] _ dne_b (by intro; simp)
  exact DerivationTree.modus_ponens [A.and B] _ _ dne_b_ctx neg_neg_b

/--
Left Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → A`.

Extract left conjunct as an implication (no context).

**Proof**: Discharge the context of `andLeft` with the deduction theorem, then lift to an
arbitrary frame class via `FrameClass.base_le`.

Unlike the context-based `andLeft`, this form composes without context manipulation, which is
what `boxConjIff`'s forward direction in ModalS5.lean needs.
-/
@[tmLemma]
def lceImp {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.and B).imp A := by
  -- Use deduction theorem: from [A ∧ B] ⊢ A, derive ⊢ (A ∧ B) → A
  have h : [A.and B] ⊢[fc] A := andLeft A B
  exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.and B) A h

/--
Right Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → B`.

Extract right conjunct as an implication (no context).

**Proof**: Discharge the context of `andRight` with the deduction theorem, then lift to an
arbitrary frame class via `FrameClass.base_le`.

Unlike the context-based `andRight`, this form composes without context manipulation, which is
what `boxConjIff`'s forward direction in ModalS5.lean needs.
-/
@[tmLemma]
def rceImp {fc : FrameClass} (A B : Formula) : ⊢[fc] (A.and B).imp B := by
  -- Use deduction theorem: from [A ∧ B] ⊢ B, derive ⊢ (A ∧ B) → B
  have h : [A.and B] ⊢[fc] B := andRight A B
  exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.and B) B h


/-! ## Context plumbing that needs the propositional axioms

These combinators are `{fc}`-polymorphic but depend on `efqAxiom` / `peirceAxiom` /
`lceImp` / `rceImp` and on `deductionTheorem`, so they cannot live in `Theorems/Combinators.lean`
(which sits below `Propositional` in the import graph). They were previously duplicated as
`private` helpers in `Theorems/DedekindDerived.lean` and again in the Discrete-unfolding spike.
-/

/-- Left conjunction elimination in context. -/
def andFst {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] A.and B) : Γ ⊢[fc] A :=
  ctxMp (thmIn (lceImp A B)) h

/-- Right conjunction elimination in context. -/
def andSnd {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] A.and B) : Γ ⊢[fc] B :=
  ctxMp (thmIn (rceImp A B)) h

/-- Disjunction introduction (left). -/
def orIntroL {fc : FrameClass} (Γ : Context) (A B : Formula) (hA : Γ ⊢[fc] A) :
    Γ ⊢[fc] A.or B := by
  have step : (A.neg :: Γ) ⊢[fc] B := by
    have h1 : (A.neg :: Γ) ⊢[fc] A.neg := DerivationTree.assumption _ _ (by simp)
    have h2 : (A.neg :: Γ) ⊢[fc] A :=
      DerivationTree.weakening Γ _ A hA (by intro x hx; simp [hx])
    exact DerivationTree.modus_ponens _ Formula.bot B (wk _ _ (efqAxiom B))
      (DerivationTree.modus_ponens _ A Formula.bot h1 h2)
  exact FormalSystem.Metalogic.Core.deductionTheorem Γ A.neg B step

/-- Disjunction introduction (right). -/
def orIntroR {fc : FrameClass} (Γ : Context) (A B : Formula) (hB : Γ ⊢[fc] B) :
    Γ ⊢[fc] A.or B :=
  FormalSystem.Metalogic.Core.deductionTheorem Γ A.neg B
    (DerivationTree.weakening Γ _ B hB (by intro x hx; simp [hx]))

/-- Classical disjunction elimination, via Peirce. -/
def orElim {fc : FrameClass} (Γ : Context) (A B C : Formula)
    (hor : Γ ⊢[fc] A.or B) (hA : Γ ⊢[fc] A.imp C) (hB : Γ ⊢[fc] B.imp C) :
    Γ ⊢[fc] C := by
  have step : (C.neg :: Γ) ⊢[fc] C := by
    have hnc : (C.neg :: Γ) ⊢[fc] C.neg := DerivationTree.assumption _ _ (by simp)
    have hA' : (C.neg :: Γ) ⊢[fc] A.imp C :=
      DerivationTree.weakening Γ _ _ hA (by intro x hx; simp [hx])
    have hB' : (C.neg :: Γ) ⊢[fc] B.imp C :=
      DerivationTree.weakening Γ _ _ hB (by intro x hx; simp [hx])
    have hor' : (C.neg :: Γ) ⊢[fc] A.neg.imp B :=
      DerivationTree.weakening Γ _ _ hor (by intro x hx; simp [hx])
    -- `A.neg` : from `A` we would get `C`, contradicting `C.neg`
    have hna : (C.neg :: Γ) ⊢[fc] A.neg := by
      refine FormalSystem.Metalogic.Core.deductionTheorem _ A Formula.bot ?_
      have hnc2 : (A :: C.neg :: Γ) ⊢[fc] C.neg :=
        DerivationTree.assumption _ _ (by simp)
      have ha2 : (A :: C.neg :: Γ) ⊢[fc] A := DerivationTree.assumption _ _ (by simp)
      have hA2 : (A :: C.neg :: Γ) ⊢[fc] A.imp C :=
        DerivationTree.weakening _ _ _ hA' (by intro x hx; simp [hx])
      exact DerivationTree.modus_ponens _ C Formula.bot hnc2
        (DerivationTree.modus_ponens _ A C hA2 ha2)
    exact DerivationTree.modus_ponens _ B C hB'
      (DerivationTree.modus_ponens _ A.neg B hor' hna)
  exact DerivationTree.modus_ponens Γ (C.neg.imp C) C
    (wk Γ _ (peirceAxiom C Formula.bot))
    (FormalSystem.Metalogic.Core.deductionTheorem Γ C.neg C step)

/-- `⊢[fc] ¬⊤ → ⊥`. -/
def topNegImpBot {fc : FrameClass} : ⊢[fc] Formula.top.neg.imp Formula.bot := by
  refine FormalSystem.Metalogic.Core.deductionTheorem [] Formula.top.neg Formula.bot ?_
  exact DerivationTree.modus_ponens _ Formula.top Formula.bot
    (DerivationTree.assumption _ _ (by simp [Formula.neg])) (wk _ _ topThm)

/-- `⊢[fc] U(X, ⊥) → ⊥`: an `untl` whose *event* is refutable is itself refutable.

Route: `Axiom.until_F` to `F ⊥`, event monotonicity to `F ¬¬⊥`, and temporal necessitation of
`¬⊥`, whose `allFuture` unfolds to exactly `¬F ¬¬⊥`. Arguments are guard-first
(`Formula.untl X Formula.bot` has guard `X`, event `⊥`). -/
def untlBotFalse {fc : FrameClass} (X : Formula) :
    ⊢[fc] (Formula.untl X Formula.bot).imp Formula.bot := by
  refine FormalSystem.Metalogic.Core.deductionTheorem []
    (Formula.untl X Formula.bot) Formula.bot ?_
  have h1 : [Formula.untl X Formula.bot] ⊢[fc] Formula.untl X Formula.bot :=
    DerivationTree.assumption _ _ (by simp)
  have h2 : [Formula.untl X Formula.bot] ⊢[fc] Formula.someFuture Formula.bot :=
    DerivationTree.modus_ponens _ _ _
      (DerivationTree.axiom _ _ (Axiom.until_F X Formula.bot) (FrameClass.base_le fc)) h1
  have h3 : [Formula.untl X Formula.bot] ⊢[fc] Formula.someFuture Formula.bot.neg.neg :=
    eventMono _ Formula.bot Formula.bot.neg.neg Formula.top (efqAxiom _) h2
  have h4 : [Formula.untl X Formula.bot] ⊢[fc] Formula.allFuture Formula.bot.neg :=
    wk _ _ (DerivationTree.temporal_necessitation _ (efqAxiom Formula.bot))
  exact DerivationTree.modus_ponens _ _ _ h4 h3

end -- noncomputable section

end FormalSystem.Theorems.Propositional
