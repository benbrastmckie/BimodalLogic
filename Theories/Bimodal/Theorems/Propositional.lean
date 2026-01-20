import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Metalogic_v2.Core.DeductionTheorem

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

* [Combinators.lean](Combinators.lean) - Combinator infrastructure
  (imp_trans, identity, b_combinator, theorem_flip, pairing, dni)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata (prop_k, prop_s, ex_falso, peirce)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Bimodal.Theorems.Propositional

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

noncomputable section

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
def lem (A : Formula) : ⊢ A.or A.neg := by
  -- A ∨ ¬A = ¬A → ¬A (by definition of disjunction)
  unfold Formula.or
  -- Now goal is: ⊢ A.neg.imp A.neg
  exact identity A.neg


/-!
## Axiomatic Helpers and Derived Classical Principles

This section defines axiom wrappers (efq_axiom, peirce_axiom) and derives
the double negation elimination theorem from these axioms.
-/

def efq_axiom (φ : Formula) : ⊢ Formula.bot.imp φ :=
  DerivationTree.axiom [] _ (Axiom.ex_falso φ)

/--
Peirce's Law (axiomatic): `⊢ ((φ → ψ) → φ) → φ`.

Classical reasoning in pure implicational form. This is now an axiom.

This theorem provides a convenient wrapper around Peirce's Law axiom for use in proofs.
-/
def peirce_axiom (φ ψ : Formula) : ⊢ ((φ.imp ψ).imp φ).imp φ :=
  DerivationTree.axiom [] _ (Axiom.peirce φ ψ)

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
4. Compose using b_combinator: from `⊥ → φ` derive `(φ → ⊥) → φ` (given `(φ → ⊥) → ⊥`)
5. Apply Peirce to get `φ`

**Dependencies**: Only requires prop_k, prop_s, EFQ, Peirce, and b_combinator.
No circular dependencies - b_combinator is derived from K and S without using DNE.

**Complexity**: Medium (7 proof steps)

**Historical Note**: Previously an axiom, now a derived theorem. This change
improves the foundational structure without affecting derivational power.
-/
def double_negation (φ : Formula) : ⊢ φ.neg.neg.imp φ := by
  -- ¬¬φ = (φ → ⊥) → ⊥ (definition)
  unfold Formula.neg

  -- Goal: ⊢ ((φ → ⊥) → ⊥) → φ

  -- Step 1: Peirce with ψ = ⊥ gives us: ⊢ ((φ → ⊥) → φ) → φ
  have peirce_inst : ⊢ ((φ.imp Formula.bot).imp φ).imp φ :=
    peirce_axiom φ Formula.bot

  -- Step 2: EFQ gives us: ⊢ ⊥ → φ
  have efq_inst : ⊢ Formula.bot.imp φ :=
    efq_axiom φ

  -- Step 3: Use b_combinator to compose (⊥ → φ) with ((φ → ⊥) → ⊥)
  -- b_combinator: (B → C) → (A → B) → (A → C)
  -- With A = (φ → ⊥), B = ⊥, C = φ
  -- Gives: (⊥ → φ) → ((φ → ⊥) → ⊥) → ((φ → ⊥) → φ)
  have b_inst : ⊢ (Formula.bot.imp φ).imp
                   (((φ.imp Formula.bot).imp Formula.bot).imp
                    ((φ.imp Formula.bot).imp φ)) :=
    b_combinator

  -- Step 4: Apply modus ponens with efq_inst
  have step1 : ⊢ ((φ.imp Formula.bot).imp Formula.bot).imp
                  ((φ.imp Formula.bot).imp φ) :=
    DerivationTree.modus_ponens [] _ _ b_inst efq_inst

  -- Step 5: Now compose with Peirce
  -- We have: ((φ → ⊥) → ⊥) → ((φ → ⊥) → φ)  [step1]
  -- We have: ((φ → ⊥) → φ) → φ                [peirce_inst]
  -- Goal:    ((φ → ⊥) → ⊥) → φ
  -- Use b_combinator to compose

  have b_final : ⊢ (((φ.imp Formula.bot).imp φ).imp φ).imp
                    ((((φ.imp Formula.bot).imp Formula.bot).imp
                      ((φ.imp Formula.bot).imp φ)).imp
                     (((φ.imp Formula.bot).imp Formula.bot).imp φ)) :=
    b_combinator

  -- Step 6: Apply modus ponens with peirce_inst
  have step2 : ⊢ (((φ.imp Formula.bot).imp Formula.bot).imp
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
- `raa`: Reductio ad Absurdum - the implication form `A → (¬A → B)`
- `efq_neg`: Ex Falso Quodlibet - from ¬A and A, derive B
- `double_negation`: DNE used in the proof

## Example
```lean
-- From both P and ¬P, we can derive any formula Q
example (P Q : Formula) : [P, P.neg] ⊢ Q := ecq P Q
```
-/
def ecq (A B : Formula) : [A, A.neg] ⊢ B := by
  -- Goal: [A, ¬A] ⊢ B where ¬A = A → ⊥
  -- From ¬A in context, we have A → ⊥
  -- From A in context, we get ⊥
  -- From ⊥, derive B using DNE

  -- Step 1: Get ¬A from context (second assumption)
  have h_neg_a : [A, A.neg] ⊢ A.neg := by
    apply DerivationTree.assumption
    simp

  -- Step 2: Get A from context (first assumption)
  have h_a : [A, A.neg] ⊢ A := by
    apply DerivationTree.assumption
    simp

  -- Step 3: Apply modus ponens to get ⊥
  -- ¬A = A → ⊥, so from A and (A → ⊥), we get ⊥
  have h_bot : [A, A.neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens [A, A.neg] A Formula.bot h_neg_a h_a

  -- Step 4: From ⊥, derive B using DNE
  -- We derive ¬¬B from ⊥, then apply DNE

  -- By prop_s: ⊥ → (B.neg → ⊥) which is ⊥ → ¬¬B
  have bot_to_neg_neg_b : ⊢ Formula.bot.imp B.neg.neg :=
    DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot B.neg)

  -- Weaken to context
  have bot_to_neg_neg_b_ctx : [A, A.neg] ⊢ Formula.bot.imp B.neg.neg :=
    DerivationTree.weakening [] [A, A.neg] _ bot_to_neg_neg_b (by intro; simp)

  -- Apply modus ponens to get ¬¬B from ⊥
  have neg_neg_b : [A, A.neg] ⊢ B.neg.neg :=
    DerivationTree.modus_ponens [A, A.neg] Formula.bot B.neg.neg bot_to_neg_neg_b_ctx h_bot

  -- Now use DNE: ¬¬B → B
  have dne_b : ⊢ B.neg.neg.imp B :=
    double_negation B

  -- Weaken to context [A, ¬A]
  have dne_b_ctx : [A, A.neg] ⊢ B.neg.neg.imp B :=
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

def raa (A B : Formula) : ⊢ A.imp (A.neg.imp B) := by
  -- We need to show: ⊢ A → (¬A → B)
  -- Strategy: From A and ¬A, we get ⊥, then from ⊥ we derive B

  -- First, use EFQ: ⊥ → B
  have bot_to_b : ⊢ Formula.bot.imp B :=
    efq_axiom B

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
    DerivationTree.modus_ponens [] _ _ b_inner bot_to_b

  -- Finally compose: A → ¬¬A → (¬A → B)
  have b_outer : ⊢ (A.neg.neg.imp (A.neg.imp B)).imp
                    ((A.imp A.neg.neg).imp (A.imp (A.neg.imp B))) :=
    @b_combinator A A.neg.neg (A.neg.imp B)

  have step3 : ⊢ (A.imp A.neg.neg).imp (A.imp (A.neg.imp B)) :=
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
2. Apply theorem_flip to swap the arguments: ¬A → (A → B)

## Related Theorems
- `raa`: Reductio ad Absurdum - `A → (¬A → B)`
- `ecq`: Ex Contradictione Quodlibet - context-based form `[A, ¬A] ⊢ B`
- `theorem_flip`: Used to swap implication arguments

## Example
```lean
-- If we have ¬P, then from P we can derive any Q
example (P Q : Formula) : ⊢ P.neg.imp (P.imp Q) := efq_neg P Q
```

## Note
This is the primary `efq` definition. The old `efq` name is deprecated and aliased
to this function for backward compatibility.
-/
def efq_neg (A B : Formula) : ⊢ A.neg.imp (A.imp B) := by
  -- Goal: ¬A → (A → B)
  -- We have RAA: A → (¬A → B)
  -- Apply theorem_flip

  have raa_inst : ⊢ A.imp (A.neg.imp B) :=
    raa A B

  have flip_inst : ⊢ (A.imp (A.neg.imp B)).imp (A.neg.imp (A.imp B)) :=
    @theorem_flip A A.neg B

  exact DerivationTree.modus_ponens [] _ _ flip_inst raa_inst

/--
Ex Falso Quodlibet (backward compatibility alias).

This alias maintains backward compatibility with code using the old `efq` name.
-/
@[deprecated efq_neg (since := "2025-12-14")]
def efq (A B : Formula) : ⊢ A.neg.imp (A.imp B) := efq_neg A B

/--
Left Disjunction Introduction: `[A] ⊢ A ∨ B`.

If A holds, then A ∨ B holds.

**Proof Strategy**: Use definition of disjunction and EFQ.

Recall: A ∨ B = ¬A → B
From A, we need ¬A → B. From ¬A and A, we get ⊥, then B follows by EFQ.
-/
def ldi (A B : Formula) : [A] ⊢ A.or B := by
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
    apply DerivationTree.assumption
    simp

  -- Weaken EFQ to context [A]
  have efq_ctx : [A] ⊢ A.neg.imp (A.imp B) :=
    DerivationTree.weakening [] [A] _ efq_inst (by intro; simp)

  -- We need: ¬A → B from ¬A → (A → B) and A

  -- Use prop_k: (¬A → (A → B)) → ((¬A → A) → (¬A → B))
  have k_inst : ⊢ (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k A.neg A B)

  -- Weaken to context
  have k_ctx : [A] ⊢ (A.neg.imp (A.imp B)).imp ((A.neg.imp A).imp (A.neg.imp B)) :=
    DerivationTree.weakening [] [A] _ k_inst (by intro; simp)

  -- Apply MP
  have step1 : [A] ⊢ (A.neg.imp A).imp (A.neg.imp B) :=
    DerivationTree.modus_ponens [A] _ _ k_ctx efq_ctx

  -- Now we need: ¬A → A
  -- This is derivable from A using prop_s: A → (¬A → A)
  have s_inst : ⊢ A.imp (A.neg.imp A) :=
    DerivationTree.axiom [] _ (Axiom.prop_s A A.neg)

  -- Weaken to context
  have s_ctx : [A] ⊢ A.imp (A.neg.imp A) :=
    DerivationTree.weakening [] [A] _ s_inst (by intro; simp)

  -- Apply MP to get ¬A → A
  have step2 : [A] ⊢ A.neg.imp A :=
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
def rdi (A B : Formula) : [B] ⊢ A.or B := by
  -- A ∨ B = ¬A → B (by definition)
  unfold Formula.or

  -- Goal: [B] ⊢ ¬A → B

  -- By prop_s: B → (¬A → B)
  have s_inst : ⊢ B.imp (A.neg.imp B) :=
    DerivationTree.axiom [] _ (Axiom.prop_s B A.neg)

  -- Get B from context
  have h_b : [B] ⊢ B := by
    apply DerivationTree.assumption
    simp

  -- Weaken s_inst to context
  have s_ctx : [B] ⊢ B.imp (A.neg.imp B) :=
    DerivationTree.weakening [] [B] _ s_inst (by intro; simp)

  -- Apply MP
  exact DerivationTree.modus_ponens [B] B _ s_ctx h_b


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
def rcp (Γ : Context) (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := by
  -- Strategy: B → ¬¬B → ¬¬A → A

  -- Step 1: DNI for B
  have dni_b : ⊢ B.imp B.neg.neg :=
    dni B

  have dni_b_ctx : Γ ⊢ B.imp B.neg.neg :=
    DerivationTree.weakening [] Γ _ dni_b (by intro; simp)

  -- Step 2: Contrapose h to get ¬¬B → ¬¬A
  -- We have h : Γ ⊢ A.neg → B.neg
  -- Apply contraposition: (A.neg → B.neg) → (B.neg.neg → A.neg.neg)

  have contra_thm : ⊢ (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) := by
    -- Build contraposition for ¬A → ¬B
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z))
    -- So we need to flip the order
    unfold Formula.neg
    have bc :
      ⊢ ((B.imp Formula.bot).imp Formula.bot).imp
        (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
         ((A.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (A.imp Formula.bot) (B.imp Formula.bot) Formula.bot
    -- Flip to get the right order
    have flip :
      ⊢ (((B.imp Formula.bot).imp Formula.bot).imp
         (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
          ((A.imp Formula.bot).imp Formula.bot))).imp
        (((A.imp Formula.bot).imp (B.imp Formula.bot)).imp
         (((B.imp Formula.bot).imp Formula.bot).imp
          ((A.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((B.imp Formula.bot).imp Formula.bot)
                    ((A.imp Formula.bot).imp (B.imp Formula.bot))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc

  have contra_thm_ctx : Γ ⊢ (A.neg.imp B.neg).imp (B.neg.neg.imp A.neg.neg) :=
    DerivationTree.weakening [] Γ _ contra_thm (by intro; simp)

  have contraposed : Γ ⊢ B.neg.neg.imp A.neg.neg :=
    DerivationTree.modus_ponens Γ _ _ contra_thm_ctx h

  -- Step 3: Compose B → ¬¬B → ¬¬A
  have b_comp1 : ⊢ (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    @b_combinator B B.neg.neg A.neg.neg

  have b_comp1_ctx : Γ ⊢ (B.neg.neg.imp A.neg.neg).imp ((B.imp B.neg.neg).imp (B.imp A.neg.neg)) :=
    DerivationTree.weakening [] Γ _ b_comp1 (by intro; simp)

  have step1 : Γ ⊢ (B.imp B.neg.neg).imp (B.imp A.neg.neg) :=
    DerivationTree.modus_ponens Γ _ _ b_comp1_ctx contraposed

  have b_to_neg_neg_a : Γ ⊢ B.imp A.neg.neg :=
    DerivationTree.modus_ponens Γ _ _ step1 dni_b_ctx

  -- Step 4: Apply DNE to A
  have dne_a : ⊢ A.neg.neg.imp A :=
    double_negation A

  have dne_a_ctx : Γ ⊢ A.neg.neg.imp A :=
    DerivationTree.weakening [] Γ _ dne_a (by intro; simp)

  -- Step 5: Compose B → ¬¬A → A
  have b_final : ⊢ (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    @b_combinator B A.neg.neg A

  have b_final_ctx : Γ ⊢ (A.neg.neg.imp A).imp ((B.imp A.neg.neg).imp (B.imp A)) :=
    DerivationTree.weakening [] Γ _ b_final (by intro; simp)

  have step2 : Γ ⊢ (B.imp A.neg.neg).imp (B.imp A) :=
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
def lce (A B : Formula) : [A.and B] ⊢ A := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive A

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢ A.and B := by
    apply DerivationTree.assumption
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
    DerivationTree.weakening [] [A.and B] _ efq_helper (by intro; simp)

  -- Now we need: (A.neg → (A → B.neg)) → ((A → B.neg).neg → A.neg.neg)
  -- This is contraposition
  have contra_step :
    ⊢ (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) := by
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc :
      ⊢ ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
        (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         ((A.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (A.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip :
      ⊢ (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
         (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
          ((A.imp Formula.bot).imp Formula.bot))).imp
        (((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
          ((A.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((A.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((A.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc

  have contra_step_ctx :
    [A.and B] ⊢ (A.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp A.neg.neg) :=
    DerivationTree.weakening [] [A.and B] _ contra_step (by intro; simp)

  -- Apply MP to get (A → B.neg).neg → A.neg.neg
  have step1 : [A.and B] ⊢ (A.imp B.neg).neg.imp A.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ contra_step_ctx efq_ctx

  -- Apply MP with conjunction to get A.neg.neg
  have neg_neg_a : [A.and B] ⊢ A.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ step1 h_conj_unf

  -- Apply DNE
  have dne_a : ⊢ A.neg.neg.imp A :=
    double_negation A

  have dne_a_ctx : [A.and B] ⊢ A.neg.neg.imp A :=
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
def rce (A B : Formula) : [A.and B] ⊢ B := by
  -- A ∧ B = (A → ¬B).neg
  -- Goal: from [(A → ¬B).neg] derive B

  -- Get conjunction from context
  have h_conj : [A.and B] ⊢ A.and B := by
    apply DerivationTree.assumption
    simp

  -- Unfold conjunction
  have h_conj_unf : [A.and B] ⊢ (A.imp B.neg).neg := by
    unfold Formula.and at h_conj
    exact h_conj

  -- We need: B.neg → (A → B.neg)
  -- This is prop_s: B.neg → (A → B.neg)
  have s_helper : ⊢ B.neg.imp (A.imp B.neg) :=
    DerivationTree.axiom [] _ (Axiom.prop_s B.neg A)

  have s_ctx : [A.and B] ⊢ B.neg.imp (A.imp B.neg) :=
    DerivationTree.weakening [] [A.and B] _ s_helper (by intro; simp)

  -- Contrapose: (B.neg → (A → B.neg)) → ((A → B.neg).neg → B.neg.neg)
  have contra_step :
    ⊢ (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) := by
    -- b_combinator gives: (Y → Z) → (X → Y) → (X → Z)
    -- We need: (X → Y) → ((Y → Z) → (X → Z)), so flip
    unfold Formula.neg
    have bc :
      ⊢ ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
        (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         ((B.imp Formula.bot).imp Formula.bot)) :=
      @b_combinator (B.imp Formula.bot) (A.imp (B.imp Formula.bot)) Formula.bot
    have flip :
      ⊢ (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
         (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
          ((B.imp Formula.bot).imp Formula.bot))).imp
        (((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot))).imp
         (((A.imp (B.imp Formula.bot)).imp Formula.bot).imp
          ((B.imp Formula.bot).imp Formula.bot))) :=
      @theorem_flip ((A.imp (B.imp Formula.bot)).imp Formula.bot)
                    ((B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)))
                    ((B.imp Formula.bot).imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip bc

  have contra_step_ctx :
    [A.and B] ⊢ (B.neg.imp (A.imp B.neg)).imp ((A.imp B.neg).neg.imp B.neg.neg) :=
    DerivationTree.weakening [] [A.and B] _ contra_step (by intro; simp)

  -- Apply MP
  have step1 : [A.and B] ⊢ (A.imp B.neg).neg.imp B.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ contra_step_ctx s_ctx

  -- Apply MP with conjunction
  have neg_neg_b : [A.and B] ⊢ B.neg.neg :=
    DerivationTree.modus_ponens [A.and B] _ _ step1 h_conj_unf

  -- Apply DNE
  have dne_b : ⊢ B.neg.neg.imp B :=
    double_negation B

  have dne_b_ctx : [A.and B] ⊢ B.neg.neg.imp B :=
    DerivationTree.weakening [] [A.and B] _ dne_b (by intro; simp)

  exact DerivationTree.modus_ponens [A.and B] _ _ dne_b_ctx neg_neg_b

/--
Left Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → A`.

Extract left conjunct as an implication (no context).

**Status**: Requires full deduction theorem or extremely complex nested combinator proof.

The context-based version `lce` is proven. This implication form would enable:
- More compositional reasoning without context manipulation
- box_conj_iff forward direction in ModalS5.lean

**Workaround**: Use `lce` with weakening when contexts are available.
-/
def lce_imp (A B : Formula) : ⊢ (A.and B).imp A := by
  -- Use deduction theorem: from [A ∧ B] ⊢ A, derive ⊢ (A ∧ B) → A
  have h : [A.and B] ⊢ A := lce A B
  exact Bimodal.Metalogic_v2.Core.deduction_theorem [] (A.and B) A h

/--
Right Conjunction Elimination (Implication Form): `⊢ (A ∧ B) → B`.

Extract right conjunct as an implication (no context).

**Status**: Requires full deduction theorem or extremely complex nested combinator proof.

The context-based version `rce` is proven. This implication form would enable:
- More compositional reasoning without context manipulation
- box_conj_iff forward direction in ModalS5.lean

**Workaround**: Use `rce` with weakening when contexts are available.
-/
def rce_imp (A B : Formula) : ⊢ (A.and B).imp B := by
  -- Use deduction theorem: from [A ∧ B] ⊢ B, derive ⊢ (A ∧ B) → B
  have h : [A.and B] ⊢ B := rce A B
  exact Bimodal.Metalogic_v2.Core.deduction_theorem [] (A.and B) B h

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
def classical_merge (P Q : Formula) : ⊢ (P.imp Q).imp ((P.neg.imp Q).imp Q) := by
  -- Goal: (P → Q) → ((¬P → Q) → Q)
  -- This is case analysis on P using LEM.
  --
  -- Proof using deduction theorem and contraposition:
  -- 1. From (P → Q), contrapose to get (¬Q → ¬P)
  -- 2. From (¬P → Q), contrapose to get (¬Q → ¬¬P)
  -- 3. Build (¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q) using RAA pattern
  -- 4. Compose with DNE to get Q
  --
  -- Using deduction theorem: From [P → Q, ¬P → Q] derive Q
  -- Then by deduction theorem twice: ⊢ (P → Q) → ((¬P → Q) → Q)

  -- Step 1: Derive [P → Q, ¬P → Q] ⊢ Q
  -- From context, we have P → Q and ¬P → Q
  -- Use deduction theorem on nested structure

  -- Actually, let's use contraposition directly with composition

  -- Key insight: (¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q)
  -- This is: (A → B) → ((A → ¬B) → ¬A) where A = ¬Q, B = ¬P

  -- First, prove: (A → B) → ((A → ¬B) → ¬A) for any A, B
  -- Let's call this `contradiction_intro`
  have contradiction_intro : ∀ A B : Formula,
      ⊢ (A.imp B).imp ((A.imp B.neg).imp A.neg) := by
    intro A B
    -- Goal: (A → B) → ((A → ¬B) → ¬A)
    -- Where ¬X = X → ⊥
    -- Goal: (A → B) → ((A → B → ⊥) → (A → ⊥))
    --
    -- Use deduction theorem: assume [A → B, A → B → ⊥, A] then derive ⊥
    -- From A → B and A, get B
    -- From A → B → ⊥ and A, get B → ⊥
    -- From B → ⊥ and B, get ⊥
    -- Done!

    -- Derive in context [A, A → ¬B, A → B] ⊢ ⊥
    -- (ordering for deduction theorem: A at head, then A → ¬B, then A → B)
    have h_in_ctx : [A, (A.imp B.neg), (A.imp B)] ⊢ Formula.bot := by
      -- Get A from context
      have h_a : [A, (A.imp B.neg), (A.imp B)] ⊢ A := by
        apply DerivationTree.assumption
        simp
      -- Get A → B from context
      have h_ab : [A, (A.imp B.neg), (A.imp B)] ⊢ A.imp B := by
        apply DerivationTree.assumption
        simp
      -- Get A → ¬B from context
      have h_a_neg_b : [A, (A.imp B.neg), (A.imp B)] ⊢ A.imp B.neg := by
        apply DerivationTree.assumption
        simp
      -- Apply modus ponens: get B
      have h_b : [A, (A.imp B.neg), (A.imp B)] ⊢ B :=
        DerivationTree.modus_ponens _ A B h_ab h_a
      -- Apply modus ponens: get ¬B = B → ⊥
      have h_neg_b : [A, (A.imp B.neg), (A.imp B)] ⊢ B.neg :=
        DerivationTree.modus_ponens _ A B.neg h_a_neg_b h_a
      -- Apply modus ponens: get ⊥
      exact DerivationTree.modus_ponens _ B Formula.bot h_neg_b h_b

    -- Apply deduction theorem: [A → ¬B, A → B] ⊢ A → ⊥ = ¬A
    have step1 : [(A.imp B.neg), (A.imp B)] ⊢ A.neg :=
      Bimodal.Metalogic_v2.Core.deduction_theorem
        [(A.imp B.neg), (A.imp B)] A Formula.bot h_in_ctx

    -- Apply deduction theorem: [A → B] ⊢ (A → ¬B) → ¬A
    have step2 : [(A.imp B)] ⊢ (A.imp B.neg).imp A.neg :=
      Bimodal.Metalogic_v2.Core.deduction_theorem
        [(A.imp B)] (A.imp B.neg) A.neg step1

    -- Apply deduction theorem: [] ⊢ (A → B) → ((A → ¬B) → ¬A)
    exact Bimodal.Metalogic_v2.Core.deduction_theorem
      [] (A.imp B) ((A.imp B.neg).imp A.neg) step2

  -- Now use this with A = ¬Q, B = ¬P
  have ci_inst : ⊢ (Q.neg.imp P.neg).imp ((Q.neg.imp P.neg.neg).imp Q.neg.neg) :=
    contradiction_intro Q.neg P.neg

  -- We need to compose:
  -- 1. (P → Q) → (¬Q → ¬P)  [contraposition]
  -- 2. (¬P → Q) → (¬Q → ¬¬P) [contraposition]
  -- 3. (¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q) [ci_inst]
  -- 4. ¬¬Q → Q [DNE]
  -- Goal: (P → Q) → ((¬P → Q) → Q)

  -- Build (P → Q) → (¬Q → ¬P) using contraposition theorem form
  -- Actually we need the implication form, not the meta theorem
  -- Let's build it using b_combinator style

  -- Contraposition as theorem: (A → B) → (¬B → ¬A)
  have contrapose_thm : ∀ A B : Formula, ⊢ (A.imp B).imp (B.neg.imp A.neg) := by
    intro A B
    -- This is b_combinator: (B → C) → (A → B) → (A → C)
    -- With B := B, C := ⊥ (so B.neg = B → ⊥)
    -- b_combinator gives: (B → ⊥) → (A → B) → (A → ⊥)
    -- We need: (A → B) → (B → ⊥) → (A → ⊥)
    -- Use theorem_flip to swap arguments
    have b : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
      b_combinator
    -- theorem_flip : (X → Y → Z) → (Y → X → Z)
    -- With X = B → ⊥, Y = A → B, Z = A → ⊥
    -- We get: ((B → ⊥) → (A → B) → (A → ⊥)) → ((A → B) → (B → ⊥) → (A → ⊥))
    have flip_inst : ⊢ ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                       ((A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
      @theorem_flip (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot)
    exact DerivationTree.modus_ponens [] _ _ flip_inst b

  -- Now compose everything
  -- From (P → Q):
  --   Get (¬Q → ¬P) via contrapose_thm
  -- From (¬P → Q):
  --   Get (¬Q → ¬¬P) via contrapose_thm

  have contra1 : ⊢ (P.imp Q).imp (Q.neg.imp P.neg) := contrapose_thm P Q
  have contra2 : ⊢ (P.neg.imp Q).imp (Q.neg.imp P.neg.neg) := contrapose_thm P.neg Q

  -- DNE for Q
  have dne_q : ⊢ Q.neg.neg.imp Q := double_negation Q

  -- Use deduction theorem to combine
  -- From [P → Q, ¬P → Q]:
  --   Get (¬Q → ¬P) from contra1 and first assumption
  --   Get (¬Q → ¬¬P) from contra2 and second assumption
  --   Get ¬¬Q from ci_inst
  --   Get Q from dne_q

  -- Context ordering for deduction theorem: newest assumption at HEAD
  -- First apply: deduction_theorem [P → Q] (¬P → Q) Q needs [(¬P → Q), (P → Q)] ⊢ Q
  -- Second apply: deduction_theorem [] (P → Q) _ needs [(P → Q)] ⊢ (¬P → Q) → Q
  have h_combined : [(P.neg.imp Q), (P.imp Q)] ⊢ Q := by
    -- Get assumptions (note: ¬P → Q at head, P → Q second)
    have h_pq : [(P.neg.imp Q), (P.imp Q)] ⊢ P.imp Q := by
      apply DerivationTree.assumption
      simp
    have h_npq : [(P.neg.imp Q), (P.imp Q)] ⊢ P.neg.imp Q := by
      apply DerivationTree.assumption
      simp

    -- Weaken the pure theorems to context
    have contra1_ctx : [(P.neg.imp Q), (P.imp Q)] ⊢ (P.imp Q).imp (Q.neg.imp P.neg) :=
      DerivationTree.weakening [] _ _ contra1 (List.nil_subset _)
    have contra2_ctx : [(P.neg.imp Q), (P.imp Q)] ⊢ (P.neg.imp Q).imp (Q.neg.imp P.neg.neg) :=
      DerivationTree.weakening [] _ _ contra2 (List.nil_subset _)
    have ci_ctx : [(P.neg.imp Q), (P.imp Q)] ⊢
        (Q.neg.imp P.neg).imp ((Q.neg.imp P.neg.neg).imp Q.neg.neg) :=
      DerivationTree.weakening [] _ _ ci_inst (List.nil_subset _)
    have dne_ctx : [(P.neg.imp Q), (P.imp Q)] ⊢ Q.neg.neg.imp Q :=
      DerivationTree.weakening [] _ _ dne_q (List.nil_subset _)

    -- Apply modus ponens to get (¬Q → ¬P)
    have h_nq_np : [(P.neg.imp Q), (P.imp Q)] ⊢ Q.neg.imp P.neg :=
      DerivationTree.modus_ponens _ _ _ contra1_ctx h_pq

    -- Apply modus ponens to get (¬Q → ¬¬P)
    have h_nq_nnp : [(P.neg.imp Q), (P.imp Q)] ⊢ Q.neg.imp P.neg.neg :=
      DerivationTree.modus_ponens _ _ _ contra2_ctx h_npq

    -- Apply ci_ctx: (¬Q → ¬P) → ((¬Q → ¬¬P) → ¬¬Q)
    have step1 : [(P.neg.imp Q), (P.imp Q)] ⊢ (Q.neg.imp P.neg.neg).imp Q.neg.neg :=
      DerivationTree.modus_ponens _ _ _ ci_ctx h_nq_np

    -- Apply step1 with h_nq_nnp
    have step2 : [(P.neg.imp Q), (P.imp Q)] ⊢ Q.neg.neg :=
      DerivationTree.modus_ponens _ _ _ step1 h_nq_nnp

    -- Apply DNE
    exact DerivationTree.modus_ponens _ _ _ dne_ctx step2

  -- Apply deduction theorem twice
  -- deduction_theorem Γ A B h requires h : (A :: Γ) ⊢ B
  -- For step1: Γ = [P → Q], A = (¬P → Q), so need [(¬P → Q), (P → Q)] ⊢ Q ✓
  have step1 : [(P.imp Q)] ⊢ (P.neg.imp Q).imp Q :=
    Bimodal.Metalogic_v2.Core.deduction_theorem [(P.imp Q)] (P.neg.imp Q) Q h_combined

  exact Bimodal.Metalogic_v2.Core.deduction_theorem [] (P.imp Q) ((P.neg.imp Q).imp Q) step1

/--
Biconditional Introduction: From `⊢ A → B` and `⊢ B → A`, derive `⊢ A ↔ B`.

Construct a biconditional from two implications.

**Recall**: `A ↔ B = (A → B) ∧ (B → A)`

**Proof Strategy**: Use `pairing` to combine the two implications into a conjunction.
-/
def iff_intro (A B : Formula) (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp A) :
    ⊢ (A.imp B).and (B.imp A) := by
  -- Use pairing: A → B → (A ∧ B)
  have pair_inst : ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
    pairing (A.imp B) (B.imp A)

  -- Apply MP twice
  have step1 : ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
    DerivationTree.modus_ponens [] _ _ pair_inst h1

  exact DerivationTree.modus_ponens [] _ _ step1 h2

/--
Left Biconditional Elimination: From `A ↔ B` and `A`, derive `B`.

**Proof Strategy**: Extract `A → B` from biconditional using lce, then apply modus ponens.
-/
def iff_elim_left (A B : Formula) : [((A.imp B).and (B.imp A)), A] ⊢ B := by
  -- Get A from context
  have h_a : [((A.imp B).and (B.imp A)), A] ⊢ A := by
    apply DerivationTree.assumption
    simp

  -- Get biconditional from context and extract (A → B) using lce
  have h_iff : [((A.imp B).and (B.imp A)), A] ⊢ (A.imp B).and (B.imp A) := by
    apply DerivationTree.assumption
    simp

  -- Extract (A → B) using lce
  have h_imp : [((A.imp B).and (B.imp A)), A] ⊢ A.imp B := by
    -- We need lce but with the specific context
    -- lce gives us [X ∧ Y] ⊢ X
    -- We have [(A → B) ∧ (B → A), A] and need (A → B)
    -- Use weakening from lce
    have lce_inst : [(A.imp B).and (B.imp A)] ⊢ A.imp B :=
      lce (A.imp B) (B.imp A)
    exact DerivationTree.weakening [(A.imp B).and (B.imp A)] _ _ lce_inst
      (by intro x; simp; intro h; left; exact h)

  -- Apply modus ponens
  exact DerivationTree.modus_ponens _ _ _ h_imp h_a

/--
Right Biconditional Elimination: From `A ↔ B` and `B`, derive `A`.

**Proof Strategy**: Extract `B → A` from biconditional using rce, then apply modus ponens.
-/
def iff_elim_right (A B : Formula) : [((A.imp B).and (B.imp A)), B] ⊢ A := by
  -- Get B from context
  have h_b : [((A.imp B).and (B.imp A)), B] ⊢ B := by
    apply DerivationTree.assumption
    simp

  -- Get biconditional from context and extract (B → A) using rce
  have h_imp : [((A.imp B).and (B.imp A)), B] ⊢ B.imp A := by
    -- Use weakening from rce
    have rce_inst : [(A.imp B).and (B.imp A)] ⊢ B.imp A :=
      rce (A.imp B) (B.imp A)
    exact DerivationTree.weakening [(A.imp B).and (B.imp A)] _ _ rce_inst
      (by intro x; simp; intro h; left; exact h)

  -- Apply modus ponens
  exact DerivationTree.modus_ponens _ _ _ h_imp h_b

/-!
## Phase 4: De Morgan Laws

De Morgan laws for propositional logic, enabling modal duality transformations.

These laws relate negated conjunctions to disjunctions of negations and vice versa:
- `¬(A ∧ B) ↔ (¬A ∨ ¬B)`
- `¬(A ∨ B) ↔ (¬A ∧ ¬B)`

**Implementation Status**: Phase 1 of Plan 059 (Modal Theorems S5 Completion)
-/

/--
Contraposition theorem (implication form): `⊢ (A → B) → (¬B → ¬A)`.

From implication, derive its contrapositive.

**Proof Strategy**: Use b_combinator and theorem_flip to build contraposition.
-/
def contrapose_imp (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg) := by
  -- b_combinator: (B → ⊥) → (A → B) → (A → ⊥)
  have bc : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    b_combinator
  -- theorem_flip: (X → Y → Z) → (Y → X → Z)
  have flip : ⊢ ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                 ((A.imp B).imp ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
    @theorem_flip (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot)
  exact DerivationTree.modus_ponens [] _ _ flip bc

/--
Contraposition (helper): From `⊢ A → B`, derive `⊢ ¬B → ¬A`.

This is a convenience wrapper that applies contrapose_imp via modus ponens.
-/
def contraposition {A B : Formula} (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  have cp : ⊢ (A.imp B).imp (B.neg.imp A.neg) := contrapose_imp A B
  exact DerivationTree.modus_ponens [] _ _ cp h

/-!
## Biconditional Manipulation Helpers (Plan 060 Phase 2)

Infrastructure for working with biconditionals under negation and modalities.
-/

/--
Contraposition for Biconditionals: From `⊢ A ↔ B`, derive `⊢ ¬A ↔ ¬B`.

Biconditionals are preserved under negation.

**Proof Strategy**: From `A ↔ B` (which is `(A → B) ∧ (B → A)`), use contrapose_imp
on both directions to get `(¬B → ¬A) ∧ (¬A → ¬B)`, which is `¬A ↔ ¬B`.

**Complexity**: Medium

**Dependencies**: contrapose_imp, lce_imp, rce_imp, iff_intro
-/
def contrapose_iff (A B : Formula) (h : ⊢ (A.imp B).and (B.imp A)) :
    ⊢ (A.neg.imp B.neg).and (B.neg.imp A.neg) := by
  -- h: (A → B) ∧ (B → A)
  -- Goal: (¬A → ¬B) ∧ (¬B → ¬A)

  -- Extract A → B from biconditional
  have ab : ⊢ A.imp B := by
    have lce : ⊢ ((A.imp B).and (B.imp A)).imp (A.imp B) := lce_imp (A.imp B) (B.imp A)
    exact DerivationTree.modus_ponens [] _ _ lce h

  -- Extract B → A from biconditional
  have ba : ⊢ B.imp A := by
    have rce : ⊢ ((A.imp B).and (B.imp A)).imp (B.imp A) := rce_imp (A.imp B) (B.imp A)
    exact DerivationTree.modus_ponens [] _ _ rce h

  -- Contrapose A → B to get ¬B → ¬A
  have nb_na : ⊢ B.neg.imp A.neg := by
    have cp : ⊢ (A.imp B).imp (B.neg.imp A.neg) := contrapose_imp A B
    exact DerivationTree.modus_ponens [] _ _ cp ab

  -- Contrapose B → A to get ¬A → ¬B
  have na_nb : ⊢ A.neg.imp B.neg := by
    have cp : ⊢ (B.imp A).imp (A.neg.imp B.neg) := contrapose_imp B A
    exact DerivationTree.modus_ponens [] _ _ cp ba

  -- Combine into biconditional (¬A → ¬B) ∧ (¬B → ¬A)
  exact iff_intro A.neg B.neg na_nb nb_na

/--
Biconditional Introduction for Negations: From `⊢ ¬A → ¬B` and `⊢ ¬B → ¬A`, derive `⊢ ¬A ↔ ¬B`.

Direct application of iff_intro for negated formulas.

**Complexity**: Simple

**Dependencies**: iff_intro
-/
def iff_neg_intro (A B : Formula) (h1 : ⊢ A.neg.imp B.neg) (h2 : ⊢ B.neg.imp A.neg) :
    ⊢ (A.neg.imp B.neg).and (B.neg.imp A.neg) := by
  exact iff_intro A.neg B.neg h1 h2

/--
De Morgan Law 1 (Forward Direction): `⊢ ¬(A ∧ B) → (¬A ∨ ¬B)`.

From negated conjunction, derive disjunction of negations.

**Recall**: `A ∧ B = ¬(A → ¬B)` and `¬A ∨ ¬B = ¬¬A → ¬B`

So goal: `¬¬(A → ¬B) → (¬¬A → ¬B)`

**Proof Strategy**: Use DNE and composition.
-/
def demorgan_conj_neg_forward (A B : Formula) :
    ⊢ (A.and B).neg.imp (A.neg.or B.neg) := by
  -- Unfold definitions
  -- A.and B = (A.imp B.neg).neg
  -- (A.and B).neg = (A.imp B.neg).neg.neg
  -- A.neg.or B.neg = A.neg.neg.imp B.neg
  unfold Formula.and Formula.or Formula.neg

  -- Goal: ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp Formula.bot).imp
  --       (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))

  -- This is: ¬¬(A → ¬B) → (¬¬A → ¬B)

  -- Step 1: DNE on (A → ¬B): ¬¬(A → ¬B) → (A → ¬B)
  have dne_inner : ⊢ ((A.imp (B.imp Formula.bot)).imp Formula.bot).imp Formula.bot |>.imp
                      (A.imp (B.imp Formula.bot)) :=
    double_negation (A.imp (B.imp Formula.bot))

  -- Step 2: (A → ¬B) → (¬¬A → ¬B)
  -- This is b_combinator flipped: (A → C) → ((B → A) → (B → C))
  -- With B = ¬¬A, C = ¬B
  -- We need DNE on A: ¬¬A → A
  have dne_a : ⊢ ((A.imp Formula.bot).imp Formula.bot).imp A :=
    double_negation A

  -- b_combinator: (A → C) → (B → A) → (B → C)
  -- With B = ¬¬A, A = A, C = ¬B
  have b1 : ⊢ (A.imp (B.imp Formula.bot)).imp
               ((((A.imp Formula.bot).imp Formula.bot).imp A).imp
                (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))) :=
    b_combinator

  -- Flip to get: (¬¬A → A) → ((A → ¬B) → (¬¬A → ¬B))
  have flip : ⊢ ((A.imp (B.imp Formula.bot)).imp
                  ((((A.imp Formula.bot).imp Formula.bot).imp A).imp
                   (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot)))).imp
                 ((((A.imp Formula.bot).imp Formula.bot).imp A).imp
                  ((A.imp (B.imp Formula.bot)).imp
                   (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot)))) :=
    @theorem_flip (A.imp (B.imp Formula.bot))
                  (((A.imp Formula.bot).imp Formula.bot).imp A)
                  (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))

  have step1 : ⊢ (((A.imp Formula.bot).imp Formula.bot).imp A).imp
                  ((A.imp (B.imp Formula.bot)).imp
                   (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))) :=
    DerivationTree.modus_ponens [] _ _ flip b1

  have step2 : ⊢ (A.imp (B.imp Formula.bot)).imp
                  (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ step1 dne_a

  -- Compose: ¬¬(A → ¬B) → (A → ¬B) → (¬¬A → ¬B)
  exact imp_trans dne_inner step2

/--
De Morgan Law 1 (Backward Direction): `⊢ (¬A ∨ ¬B) → ¬(A ∧ B)`.

From disjunction of negations, derive negated conjunction.

**Recall**: `¬A ∨ ¬B = ¬¬A → ¬B` and `A ∧ B = ¬(A → ¬B)`

So goal: `(¬¬A → ¬B) → ¬(A → ¬B)`

**Proof Strategy**: Use contraposition and DNI.
-/
def demorgan_conj_neg_backward (A B : Formula) :
    ⊢ (A.neg.or B.neg).imp (A.and B).neg := by
  unfold Formula.and Formula.or Formula.neg

  -- Goal: (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot)).imp
  --       ((A.imp (B.imp Formula.bot)).imp Formula.bot)

  -- This is: (¬¬A → ¬B) → ¬(A → ¬B)

  -- Contrapose: (¬¬A → ¬B) → (¬¬B → ¬¬¬A)
  -- Simplify: (¬¬A → ¬B) → (¬¬B → ¬A) by DNE/DNI

  -- Actually, let's think differently:
  -- We want: (¬¬A → ¬B) → ¬(A → ¬B)
  -- Equivalently: (¬¬A → ¬B) → ((A → ¬B) → ⊥)

  -- Assume ¬¬A → ¬B and A → ¬B
  -- From DNI: A → ¬¬A
  -- Compose: A → ¬¬A → ¬B
  -- So both A → ¬B (assumption) and A → ¬¬A → ¬B (derived)
  -- Wait, both give A → ¬B, no contradiction yet

  -- Different approach: assume (¬¬A → ¬B) and (A → ¬B)
  -- From (¬¬A → ¬B), contrapose to get (¬¬B → ¬¬¬A) = (¬¬B → ¬A)
  -- From (A → ¬B), contrapose to get (¬¬B → ¬A) - same!

  -- Let me think again about the logic...
  -- ¬¬A → ¬B means: if A is true (classically), then B is false
  -- A → ¬B means: if A is true, then B is false
  -- These seem equivalent classically!

  -- But wait, ¬¬A → ¬B is NOT equivalent to A → ¬B in general
  -- Because ¬¬A → ¬B is WEAKER (only applies when A is "doubly" true)

  -- Actually in classical logic:
  -- ¬¬A → ¬B = ¬¬¬B ∨ ¬¬A = ¬B ∨ ¬¬A = ¬A → ¬B ∨ A
  -- Hmm, this is getting complex

  -- Let me use a direct deduction theorem approach:
  -- From context [¬¬A → ¬B, A → ¬B, A, B], derive ⊥
  -- Then use deduction theorem multiple times

  -- Step 1: [¬¬A → ¬B, A → ¬B] ⊢ ¬(A ∧ B)
  -- Which is: [¬¬A → ¬B, A → ¬B] ⊢ (A → ¬B) → ⊥
  -- We have A → ¬B in context already!
  -- So we need [¬¬A → ¬B, A → ¬B] ⊢ ⊥
  -- ... but that's not derivable unless there's a contradiction

  -- The issue: in intuitionistic logic, (¬¬A → ¬B) ↔ (A → ¬B) DOES NOT HOLD
  -- The backward direction (¬A ∨ ¬B) → ¬(A ∧ B) requires classical reasoning

  -- Classical reasoning: use LEM or equivalent

  -- Key insight: ¬(A ∧ B) = ¬¬((A → ¬B))
  -- From (¬¬A → ¬B), we can derive ¬(A ∧ B) via:
  -- Assume (A ∧ B) = ¬(A → ¬B)
  -- From A ∧ B, extract A (by lce) and B (by rce)
  -- From A, derive ¬¬A by DNI
  -- From ¬¬A and (¬¬A → ¬B), derive ¬B
  -- But we also have B from conjunction
  -- From B and ¬B, derive ⊥
  -- So (A ∧ B) → ⊥, i.e., ¬(A ∧ B)

  -- Implement using deduction theorem:
  -- Context: [A ∧ B, ¬¬A → ¬B]
  have h_in_ctx :
    [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
    Formula.bot := by
    -- Get A ∧ B from context
    have h_conj :
      [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
      A.and B := by
      apply DerivationTree.assumption
      simp

    -- Get ¬¬A → ¬B from context
    have h_hyp : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        ((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot) := by
      apply DerivationTree.assumption
      simp

    -- Extract A from conjunction using lce
    have lce_inst : ⊢ (A.and B).imp A := lce_imp A B
    have lce_ctx : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        (A.and B).imp A :=
      DerivationTree.weakening [] _ _ lce_inst (List.nil_subset _)
    have h_a : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢ A :=
      DerivationTree.modus_ponens _ _ _ lce_ctx h_conj

    -- Extract B from conjunction using rce
    have rce_inst : ⊢ (A.and B).imp B := rce_imp A B
    have rce_ctx : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        (A.and B).imp B :=
      DerivationTree.weakening [] _ _ rce_inst (List.nil_subset _)
    have h_b : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢ B :=
      DerivationTree.modus_ponens _ _ _ rce_ctx h_conj

    -- From A, derive ¬¬A using DNI (theorem_app1)
    have dni_inst : ⊢ A.imp ((A.imp Formula.bot).imp Formula.bot) :=
      @theorem_app1 A Formula.bot
    have dni_ctx : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        A.imp ((A.imp Formula.bot).imp Formula.bot) :=
      DerivationTree.weakening [] _ _ dni_inst (List.nil_subset _)
    have h_nna : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        (A.imp Formula.bot).imp Formula.bot :=
      DerivationTree.modus_ponens _ _ _ dni_ctx h_a

    -- From ¬¬A and (¬¬A → ¬B), derive ¬B
    have h_nb : [(A.and B), (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
        B.imp Formula.bot :=
      DerivationTree.modus_ponens _ _ _ h_hyp h_nna

    -- From B and ¬B, derive ⊥
    exact DerivationTree.modus_ponens _ _ _ h_nb h_b

  -- Apply deduction theorem: [¬¬A → ¬B] ⊢ (A ∧ B) → ⊥
  have step1 :
    [(((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))] ⊢
    (A.and B).imp Formula.bot :=
    Bimodal.Metalogic_v2.Core.deduction_theorem
      [(((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))]
      (A.and B) Formula.bot h_in_ctx

  -- Apply deduction theorem: [] ⊢ (¬¬A → ¬B) → ((A ∧ B) → ⊥)
  have step2 :
    ⊢ (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot)).imp
      ((A.and B).imp Formula.bot) :=
    Bimodal.Metalogic_v2.Core.deduction_theorem []
      (((A.imp Formula.bot).imp Formula.bot).imp (B.imp Formula.bot))
      ((A.and B).imp Formula.bot) step1

  -- (A ∧ B).neg = (A.and B).imp Formula.bot by definition
  -- and Formula.and unfolds to the right type
  unfold Formula.and at step2
  exact step2

/--
De Morgan Law 1 (Biconditional): `⊢ ¬(A ∧ B) ↔ (¬A ∨ ¬B)`.

Negated conjunction is equivalent to disjunction of negations.

**Proof Strategy**: Combine forward and backward directions using iff_intro.
-/
def demorgan_conj_neg (A B : Formula) :
    ⊢ ((A.and B).neg.imp (A.neg.or B.neg)).and ((A.neg.or B.neg).imp (A.and B).neg) := by
  -- iff_intro takes Formulas A B and proofs of A→B and B→A
  -- Here A = (A.and B).neg, B = (A.neg.or B.neg)
  exact iff_intro (A.and B).neg (A.neg.or B.neg)
    (demorgan_conj_neg_forward A B) (demorgan_conj_neg_backward A B)

/--
De Morgan Law 2 (Forward Direction): `⊢ ¬(A ∨ B) → (¬A ∧ ¬B)`.

From negated disjunction, derive conjunction of negations.

**Recall**: `A ∨ B = ¬A → B` and `¬A ∧ ¬B = ¬(¬A → ¬¬B)`

So goal: `¬(¬A → B) → ¬(¬A → ¬¬B)`

**Proof Strategy**: Use the fact that B → ¬¬B (DNI) and contraposition.
-/
def demorgan_disj_neg_forward (A B : Formula) :
    ⊢ (A.or B).neg.imp (A.neg.and B.neg) := by
  unfold Formula.or Formula.and Formula.neg

  -- Goal: (((A.imp Formula.bot).imp B).imp Formula.bot).imp
  --       (((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot)).imp Formula.bot)

  -- This is: ¬(¬A → B) → ¬(¬A → ¬¬B)

  -- We need to show: if ¬A → B leads to contradiction, then ¬A → ¬¬B also leads to contradiction
  -- This uses the fact that B → ¬¬B, so (¬A → B) → (¬A → ¬¬B)
  -- Contraposing: ¬(¬A → ¬¬B) → ¬(¬A → B)
  -- So we need the reverse direction! The forward should be easy via composition

  -- Actually, (¬A → B) → (¬A → ¬¬B) by composing with DNI
  -- So ¬(¬A → ¬¬B) → ¬(¬A → B) by contraposition
  -- But we want the other direction: ¬(¬A → B) → ¬(¬A → ¬¬B)

  -- Key: if B → ¬¬B (DNI), then (¬A → B) → (¬A → ¬¬B)
  -- So (¬A → ¬¬B) is WEAKER than (¬A → B)
  -- And ¬(¬A → ¬¬B) is STRONGER than ¬(¬A → B)

  -- Wait, I need to think more carefully:
  -- If (¬A → B) implies (¬A → ¬¬B), then ¬(¬A → B) does NOT imply ¬(¬A → ¬¬B)
  -- It's the reverse: ¬(¬A → ¬¬B) implies ¬(¬A → B)

  -- So the forward direction I want might not be derivable in standard logic!

  -- Let me reconsider: in classical logic, ¬(A ∨ B) ↔ (¬A ∧ ¬B)
  -- ¬(A ∨ B) = ¬(¬A → B)
  -- ¬A ∧ ¬B = ¬(¬A → ¬¬B) (by definition)

  -- Classically: ¬B ↔ ¬¬¬B, so ¬A ∧ ¬B ↔ ¬A ∧ ¬¬¬B
  -- And ¬(¬A → B) ↔ ¬A ∧ ¬B (by De Morgan)
  -- So ¬(¬A → B) ↔ ¬(¬A → ¬¬B) should work via triple negation

  -- Use DNE: ¬¬B → B
  -- So (¬A → ¬¬B) → (¬A → B) by composition with DNE
  -- Contrapose: ¬(¬A → B) → ¬(¬A → ¬¬B)

  -- Build: (¬A → ¬¬B) → (¬A → B)
  have dne_b : ⊢ ((B.imp Formula.bot).imp Formula.bot).imp B :=
    double_negation B

  -- b_combinator: (C → D) → (A → C) → (A → D)
  -- With A = ¬A, C = ¬¬B, D = B
  have bc : ⊢ (((B.imp Formula.bot).imp Formula.bot).imp B).imp
               (((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot)).imp
                ((A.imp Formula.bot).imp B)) :=
    b_combinator

  have impl : ⊢ ((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot)).imp
                 ((A.imp Formula.bot).imp B) :=
    DerivationTree.modus_ponens [] _ _ bc dne_b

  -- Contrapose: ¬(¬A → B) → ¬(¬A → ¬¬B)
  exact contraposition impl

/--
De Morgan Law 2 (Backward Direction): `⊢ (¬A ∧ ¬B) → ¬(A ∨ B)`.

From conjunction of negations, derive negated disjunction.

**Recall**: `¬A ∧ ¬B = ¬(¬A → ¬¬B)` and `A ∨ B = ¬A → B`

So goal: `¬(¬A → ¬¬B) → ¬(¬A → B)`

**Proof Strategy**: Use DNI and contraposition.
-/
def demorgan_disj_neg_backward (A B : Formula) :
    ⊢ (A.neg.and B.neg).imp (A.or B).neg := by
  unfold Formula.or Formula.and Formula.neg

  -- Goal: (((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot)).imp Formula.bot).imp
  --       (((A.imp Formula.bot).imp B).imp Formula.bot)

  -- This is: ¬(¬A → ¬¬B) → ¬(¬A → B)

  -- Use DNI: B → ¬¬B
  -- So (¬A → B) → (¬A → ¬¬B) by composition with DNI
  -- Contrapose: ¬(¬A → ¬¬B) → ¬(¬A → B)

  -- Build: (¬A → B) → (¬A → ¬¬B)
  have dni_b : ⊢ B.imp ((B.imp Formula.bot).imp Formula.bot) :=
    @theorem_app1 B Formula.bot

  -- b_combinator: (C → D) → (A → C) → (A → D)
  -- With A = ¬A, C = B, D = ¬¬B
  have bc : ⊢ (B.imp ((B.imp Formula.bot).imp Formula.bot)).imp
               (((A.imp Formula.bot).imp B).imp
                ((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot))) :=
    b_combinator

  have impl : ⊢ ((A.imp Formula.bot).imp B).imp
                 ((A.imp Formula.bot).imp ((B.imp Formula.bot).imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ bc dni_b

  -- Contrapose: ¬(¬A → ¬¬B) → ¬(¬A → B)
  exact contraposition impl

/--
De Morgan Law 2 (Biconditional): `⊢ ¬(A ∨ B) ↔ (¬A ∧ ¬B)`.

Negated disjunction is equivalent to conjunction of negations.

**Proof Strategy**: Combine forward and backward directions using iff_intro.
-/
def demorgan_disj_neg (A B : Formula) :
    ⊢ ((A.or B).neg.imp (A.neg.and B.neg)).and ((A.neg.and B.neg).imp (A.or B).neg) := by
  -- iff_intro takes Formulas A B and proofs of A→B and B→A
  -- Here A = (A.or B).neg, B = (A.neg.and B.neg)
  exact iff_intro (A.or B).neg (A.neg.and B.neg)
    (demorgan_disj_neg_forward A B) (demorgan_disj_neg_backward A B)

/-!
## Phase 5: Natural Deduction Style Rules

Negation Introduction (NI), Negation Elimination (NE), Disjunction Elimination (DE),
and Biconditional Introduction (BI_IMP) in Hilbert-style proof calculus.

These theorems provide natural deduction style inference patterns.
-/

/--
Negation Introduction (NI): If `Γ, A ⊢ B` and `Γ, A ⊢ ¬B`, then `Γ ⊢ ¬A`.

This is the standard proof-by-contradiction pattern: if assuming A leads to a
contradiction (both B and ¬B), then ¬A holds.

**Proof Strategy**:
1. From `h1 : (A :: Γ) ⊢ ¬B` and `h2 : (A :: Γ) ⊢ B`, derive `(A :: Γ) ⊢ ⊥` using modus ponens
2. Apply deduction_theorem: `Γ ⊢ A → ⊥` = `Γ ⊢ ¬A`

**Complexity**: Medium

**Dependencies**: `DerivationTree.modus_ponens`, `deduction_theorem`
-/
def ni (Γ : Context) (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg := by
  -- From h1 and h2, derive (A :: Γ) ⊢ ⊥
  -- ¬B = B → ⊥, so modus ponens gives ⊥
  have h_bot : (A :: Γ) ⊢ Formula.bot :=
    DerivationTree.modus_ponens (A :: Γ) B Formula.bot h1 h2
  -- Apply deduction theorem: Γ ⊢ A → ⊥ = Γ ⊢ ¬A
  exact Bimodal.Metalogic_v2.Core.deduction_theorem Γ A Formula.bot h_bot

/--
Negation Elimination (NE): If `Γ, ¬A ⊢ B` and `Γ, ¬A ⊢ ¬B`, then `Γ ⊢ A`.

This is classical proof by contradiction (indirect proof): if assuming ¬A leads to
a contradiction, then A holds.

**Proof Strategy**:
1. From `h1 : (A.neg :: Γ) ⊢ ¬B` and `h2 : (A.neg :: Γ) ⊢ B`, derive `(A.neg :: Γ) ⊢ ⊥`
2. Apply deduction_theorem: `Γ ⊢ ¬A → ⊥` = `Γ ⊢ ¬¬A`
3. Apply DNE (double_negation axiom): `Γ ⊢ A`

**Complexity**: Medium

**Dependencies**: `DerivationTree.modus_ponens`, `DerivationTree.weakening`,
`double_negation` (derived theorem), `deduction_theorem`
-/
def ne (Γ : Context) (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A := by
  -- From h1 and h2, derive (A.neg :: Γ) ⊢ ⊥
  have h_bot : (A.neg :: Γ) ⊢ Formula.bot :=
    DerivationTree.modus_ponens (A.neg :: Γ) B Formula.bot h1 h2
  -- Apply deduction theorem: Γ ⊢ ¬A → ⊥ = Γ ⊢ ¬¬A
  have h_neg_neg : Γ ⊢ A.neg.neg :=
    Bimodal.Metalogic_v2.Core.deduction_theorem Γ A.neg Formula.bot h_bot
  -- Apply DNE: ¬¬A → A
  have dne : ⊢ A.neg.neg.imp A :=
    double_negation A
  have dne_ctx : Γ ⊢ A.neg.neg.imp A :=
    DerivationTree.weakening [] Γ _ dne (List.nil_subset Γ)
  exact DerivationTree.modus_ponens Γ A.neg.neg A dne_ctx h_neg_neg

/--
Biconditional Introduction (Implication Form): `⊢ (A → B) → ((B → A) → (A ↔ B))`.

This is the curried form of biconditional introduction for compositional proofs.
The context-based `iff_intro` already exists; this provides the pure implication form.

**Recall**: `A ↔ B = (A → B) ∧ (B → A)`

**Proof Strategy**:
1. From context `[(A → B), (B → A)]`, derive both by assumption
2. Apply `pairing` to get `(A → B) ∧ (B → A)`
3. Apply deduction_theorem twice to lift to pure implication form

**Complexity**: Medium

**Dependencies**: `deduction_theorem`, `pairing`, `DerivationTree.assumption`, `DerivationTree.weakening`
-/
def bi_imp (A B : Formula) :
    ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) := by
  -- First, derive [(A → B), (B → A)] ⊢ (A → B) ∧ (B → A)
  have h_in_ctx : [(B.imp A), (A.imp B)] ⊢ (A.imp B).and (B.imp A) := by
    -- Get (A → B) from context
    have h_ab : [(B.imp A), (A.imp B)] ⊢ A.imp B := by
      apply DerivationTree.assumption
      simp
    -- Get (B → A) from context
    have h_ba : [(B.imp A), (A.imp B)] ⊢ B.imp A := by
      apply DerivationTree.assumption
      simp
    -- Use pairing: X → Y → (X ∧ Y)
    have pair_inst : ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      pairing (A.imp B) (B.imp A)
    -- Weaken to context
    have pair_ctx : [(B.imp A), (A.imp B)] ⊢
        (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      DerivationTree.weakening [] _ _ pair_inst (List.nil_subset _)
    -- Apply modus ponens twice
    have step1 : [(B.imp A), (A.imp B)] ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
      DerivationTree.modus_ponens _ _ _ pair_ctx h_ab
    exact DerivationTree.modus_ponens _ _ _ step1 h_ba

  -- Apply deduction theorem: [(A → B)] ⊢ (B → A) → ((A → B) ∧ (B → A))
  have step1 : [(A.imp B)] ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
    Bimodal.Metalogic_v2.Core.deduction_theorem [(A.imp B)] (B.imp A) _ h_in_ctx

  -- Apply deduction theorem: [] ⊢ (A → B) → ((B → A) → ((A → B) ∧ (B → A)))
  exact Bimodal.Metalogic_v2.Core.deduction_theorem [] (A.imp B) _ step1

/--
Disjunction Elimination (DE): If `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`.

This is case analysis: if we can derive C from either A or B (separately),
then from A ∨ B we can derive C.

**Recall**: `A ∨ B = ¬A → B`

**Proof Strategy**:
1. Apply deduction_theorem to get `Γ ⊢ A → C` and `Γ ⊢ B → C`
2. Weaken both to `((A.or B) :: Γ)`
3. Get `A ∨ B = ¬A → B` from context via assumption
4. Apply `classical_merge`: `(A → C) → ((¬A → C) → C)`
5. Compose `A ∨ B` with `B → C` via b_combinator to get `¬A → C`
6. Apply modus_ponens chain to derive C

**Complexity**: Complex

**Dependencies**: `deduction_theorem`, `DerivationTree.weakening`, `classical_merge`,
               `b_combinator`, `DerivationTree.assumption`
-/
noncomputable def de (Γ : Context) (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) :
    ((A.or B) :: Γ) ⊢ C := by
  -- Apply deduction theorem to get Γ ⊢ A → C
  have ac : Γ ⊢ A.imp C :=
    Bimodal.Metalogic_v2.Core.deduction_theorem Γ A C h1

  -- Apply deduction theorem to get Γ ⊢ B → C
  have bc : Γ ⊢ B.imp C :=
    Bimodal.Metalogic_v2.Core.deduction_theorem Γ B C h2

  -- Weaken A → C to context ((A.or B) :: Γ)
  have ac_ctx : ((A.or B) :: Γ) ⊢ A.imp C :=
    DerivationTree.weakening Γ _ _ ac (by intro x hx; simp; right; exact hx)

  -- Weaken B → C to context ((A.or B) :: Γ)
  have bc_ctx : ((A.or B) :: Γ) ⊢ B.imp C :=
    DerivationTree.weakening Γ _ _ bc (by intro x hx; simp; right; exact hx)

  -- Get A ∨ B from context
  have h_disj : ((A.or B) :: Γ) ⊢ A.or B := by
    apply DerivationTree.assumption
    simp

  -- A ∨ B = ¬A → B (by definition)
  -- We need ¬A → C from (¬A → B) and (B → C) via b_combinator

  -- b_combinator: (B → C) → (¬A → B) → (¬A → C)
  have b_inst : ⊢ (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    b_combinator

  have b_ctx : ((A.or B) :: Γ) ⊢ (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    DerivationTree.weakening [] _ _ b_inst (List.nil_subset _)

  have step1 : ((A.or B) :: Γ) ⊢ (A.neg.imp B).imp (A.neg.imp C) :=
    DerivationTree.modus_ponens _ _ _ b_ctx bc_ctx

  -- h_disj : ((A.or B) :: Γ) ⊢ A.or B
  -- A.or B unfolds to ¬A → B
  have h_disj_unf : ((A.or B) :: Γ) ⊢ A.neg.imp B := by
    unfold Formula.or at h_disj
    exact h_disj

  -- Get ¬A → C
  have nac : ((A.or B) :: Γ) ⊢ A.neg.imp C :=
    DerivationTree.modus_ponens _ _ _ step1 h_disj_unf

  -- Now use classical_merge: (A → C) → ((¬A → C) → C)
  have cm : ⊢ (A.imp C).imp ((A.neg.imp C).imp C) :=
    classical_merge A C

  have cm_ctx : ((A.or B) :: Γ) ⊢ (A.imp C).imp ((A.neg.imp C).imp C) :=
    DerivationTree.weakening [] _ _ cm (List.nil_subset _)

  have step2 : ((A.or B) :: Γ) ⊢ (A.neg.imp C).imp C :=
    DerivationTree.modus_ponens _ _ _ cm_ctx ac_ctx

  exact DerivationTree.modus_ponens _ _ _ step2 nac

end -- noncomputable section

end Bimodal.Theorems.Propositional
