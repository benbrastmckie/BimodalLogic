import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Modal Proof Strategies

This module provides pedagogical examples demonstrating S5 modal proof construction
patterns, focusing on proof techniques and derivation strategies rather than just
axiom applications.

## Learning Objectives

1. **Necessity Chains**: Iterating `□φ → □□φ → □□□φ` using axiom M4
2. **Possibility Proofs**: Converting between `◇φ` and `¬□¬φ` definitions
3. **Modal Modus Ponens**: Deriving `□ψ` from `□(φ → ψ)` and `□φ` using modal K rule
4. **S5 Theorems**: Proving characteristic S5 properties like `φ → □◇φ` (Brouwer B)

## Proof Patterns

This module demonstrates:
- **Axiom composition**: Chaining multiple axiom applications
- **Helper lemma usage**: Using perpetuity helpers like `imp_trans`
- **Modal K rule**: Distributing `□` over derivations
- **Identity construction**: Building `φ → φ` from K and S combinators

## Pedagogical Focus

Each example includes:
- Clear documentation of proof strategy (50%+ comment density)
- Explicit step-by-step derivations
- References to helper lemmas and axioms
- Explanation of why each step is necessary

## Notation

- `φ.box` = `□φ` (necessity - true in all possible worlds)
- `φ.diamond` = `◇φ` = `¬□¬φ` (possibility - true in some possible world)
- `⊢ φ` means `Derivable [] φ` (φ is a theorem)
- `Γ ⊢ φ` means `Derivable Γ φ` (φ derivable from context Γ)

## Exercises

This module contains 5 exercises marked with `-- EXERCISE:` comments:

1. **Possibility distribution**: Over disjunction using De Morgan laws (line ~190)
2. **Curried modal MP**: Building `□φ → (□(φ → ψ) → □ψ)` (line ~237)
3. **S5 characteristic**: `◇□φ → φ` using contraposition (line ~281)
4. **S5 diamond iteration**: `◇◇φ → ◇φ` using M4 contraposition (line ~311)
5. **Conjunction distribution**: Under □ using K distribution (line ~414)

## References

* [ModalProofs.lean](ModalProofs.lean) - Basic modal axiom examples
* [Perpetuity.lean](../Logos/Core/Theorems/Perpetuity.lean) - Helper lemmas (imp_trans, etc.)
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Examples.ModalProofStrategies

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators
open Bimodal.Theorems

/-!
## Strategy 1: Necessity Chains (Iterating M4)

The M4 axiom (`□φ → □□φ`) allows building arbitrarily long necessity chains.
This demonstrates how to compose axiom applications using implication transitivity.

**Key Technique**: Use `imp_trans` from Perpetuity.lean to chain implications.
-/

/--
Two-step necessity chain: `□φ → □□□φ`

**Proof Strategy**:
1. Apply M4 to `φ`: gives `□φ → □□φ`
2. Apply M4 to `□φ`: gives `□□φ → □□□φ`
3. Use `imp_trans` to chain: `□φ → □□φ → □□□φ`

This demonstrates the basic pattern for chaining modal axioms.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.box.box.box := by
  -- Step 1: First M4 application (□φ → □□φ)
  have h1 : ⊢ φ.box.imp φ.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ)

  -- Step 2: Second M4 application (□□φ → □□□φ)
  have h2 : ⊢ φ.box.box.imp φ.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.box)

  -- Step 3: Compose using transitivity (□φ → □□φ → □□□φ)
  exact imp_trans h1 h2

/--
Three-step necessity chain: `□φ → □□□□φ`

**Proof Strategy**:
Extend the two-step pattern to three steps, showing how to build longer chains.
This uses the same `imp_trans` pattern iteratively.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.box.box.box.box := by
  -- Build the chain step by step
  have h1 : ⊢ φ.box.imp φ.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ)
  have h2 : ⊢ φ.box.box.imp φ.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.box)
  have h3 : ⊢ φ.box.box.box.imp φ.box.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.box.box)

  -- Compose: □φ → □□φ → □□□φ → □□□□φ
  exact imp_trans (imp_trans h1 h2) h3

/--
Backward necessity chain: `□□□φ → □φ` using MT

**Proof Strategy**:
The MT axiom (`□φ → φ`) can be applied to nested boxes to "collapse" them.
This shows the inverse pattern to M4 iteration.

1. Apply MT to `□□φ`: gives `□□□φ → □□φ`
2. Apply MT to `□φ`: gives `□□φ → □φ`
3. Chain with `imp_trans`: `□□□φ → □□φ → □φ`
-/
example (φ : Formula) : ⊢ φ.box.box.box.imp φ.box := by
  -- Step 1: Apply MT to outermost box (□□□φ → □□φ)
  have h1 : ⊢ φ.box.box.box.imp φ.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.box.box)

  -- Step 2: Apply MT to next box (□□φ → □φ)
  have h2 : ⊢ φ.box.box.imp φ.box :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.box)

  -- Step 3: Chain the implications (□□□φ → □□φ → □φ)
  exact imp_trans h1 h2

/-!
## Strategy 2: Possibility Proofs (Definitional Conversions)

Possibility `◇φ` is defined as `¬□¬φ`. This section demonstrates how to work
with this definition and convert between the two forms.

**Key Technique**: Use definitional equality (`rfl`) when the formula structure
matches exactly, or use propositional reasoning when manipulation is needed.
-/

/--
Diamond is definitionally equal to `¬□¬φ`

**Strategy**: This is a direct definitional equality, verified by `rfl`.
No proof construction needed - the formula types are identical.
-/
example (φ : Formula) : φ.diamond = φ.neg.box.neg := rfl

/--
Necessity implies possibility: `□φ → ◇φ`

**Proof Strategy**:
1. Use MB axiom: `φ → □◇φ` (what's true is necessarily possible)
2. Apply MT to `◇φ`: gives `□◇φ → ◇φ` (what's necessarily true is true)
3. Chain: `φ → □◇φ → ◇φ`, giving `φ → ◇φ`
4. Apply modal K rule to lift to `□φ → ◇φ`

Note: This demonstrates combining axioms with modal reasoning.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.diamond := by
  -- Step 1: Get MB axiom (φ → □◇φ)
  have h1 : ⊢ φ.imp φ.diamond.box :=
    DerivationTree.axiom [] _ (Axiom.modal_b φ)

  -- Step 2: Get MT axiom (□◇φ → ◇φ)
  have h2 : ⊢ φ.diamond.box.imp φ.diamond :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.diamond)

  -- Step 3: Compose (φ → □◇φ → ◇φ)
  have h3 : ⊢ φ.imp φ.diamond := imp_trans h1 h2

  -- Step 4: Lift to modal context (□φ → ◇φ)
  -- We use MT axiom (□φ → φ) and compose with h3 (φ → ◇φ)
  have mt : ⊢ φ.box.imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)

  -- Compose: □φ → φ → ◇φ, giving □φ → ◇φ
  exact imp_trans mt h3

/--
Possibility distribution: `◇(φ ∨ ψ) → ◇φ ∨ ◇ψ` pattern

**Strategy**: This demonstrates the direction that IS valid in S5.
The reverse direction `◇φ ∨ ◇ψ → ◇(φ ∨ ψ)` is not valid in general.

Note: Full proof requires propositional disjunction rules not yet in the system.
This is shown for pedagogical completeness to illustrate the pattern.
-/
example (φ ψ : Formula) : ⊢ (φ.or ψ).diamond.imp (φ.diamond.or ψ.diamond) := by
  -- EXERCISE: Complete this proof (possibility distribution over disjunction)
  -- Technique: Use De Morgan laws from Propositional and modal distribution
  -- Hint: ◇(φ ∨ ψ) = ¬□¬(φ ∨ ψ); use demorgan_disj_neg to get ¬□(¬φ ∧ ¬ψ)
  sorry

/-!
## Strategy 3: Modal Modus Ponens (Modal K Rule)

The modal K rule states: if `[□Γ] ⊢ φ` then `Γ ⊢ □φ`.
This is the key rule for distributing necessity over derivations.

**Key Technique**: Build derivations in boxed context `[□φ, □ψ, ...]`, then
use the generalized necessitation lemma to lift the conclusion to `□φ`.
-/

/--
Modal modus ponens pattern: From `□φ` and `□(φ → ψ)`, derive `□ψ`

**Proof Strategy**:
1. Start with context `[φ, φ → ψ]` (non-boxed assumptions)
2. Derive `ψ` from this context using modus ponens
3. Apply modal K rule: if `[φ, φ → ψ] ⊢ ψ` then `[□φ, □(φ → ψ)] ⊢ □ψ`
4. Use weakening to lift from boxed context to theorem (empty context)

This demonstrates the core modal reasoning pattern for deriving boxed conclusions.
-/
example (φ ψ : Formula) (h1 : ⊢ φ.box) (h2 : ⊢ (φ.imp ψ).box) : ⊢ ψ.box := by
  -- We have: ⊢ □φ and ⊢ □(φ → ψ)
  -- Goal: ⊢ □ψ

  -- Use modal K distribution: □(φ → ψ) → (□φ → □ψ)
  have k_dist : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)

  -- Apply K distribution to h2: □(φ → ψ) gives □φ → □ψ
  have h3 : ⊢ φ.box.imp ψ.box := mp h2 k_dist

  -- Apply to h1: □φ gives □ψ
  exact mp h1 h3

/--
Simplified modal modus ponens: Using `DerivationTree.modus_ponens` directly

**Strategy**: When hypotheses are theorems (empty context), the pattern is simpler.
This shows the streamlined version without explicit context management.
-/
example (φ ψ : Formula) : ⊢ φ.box.imp ((φ.imp ψ).box.imp ψ.box) := by
  -- EXERCISE: Complete this proof (curried modal modus ponens)
  -- Technique: Use `Axiom.modal_k_dist` and `imp_trans` from Combinators
  -- Hint: This is the curried form of □φ ∧ □(φ → ψ) → □ψ
  --       Start with modal K: □(φ → ψ) → (□φ → □ψ), then curry
  sorry

/-!
## Strategy 4: S5 Characteristic Theorems

S5 is characterized by axioms T (reflexivity), 4 (transitivity), and B (symmetry).
This section proves theorems that are specific to S5 and distinguish it from
weaker modal logics.

**Key Technique**: Combine multiple axioms using `imp_trans` and helper lemmas.
-/

/--
Brouwer B axiom: `φ → □◇φ` (truths are necessarily possible)

**Strategy**: This is axiom MB directly. We show it as a theorem pattern.
The key insight: what's actually true must be possible in all worlds accessible
from the current world.
-/
example (φ : Formula) : ⊢ φ.imp φ.diamond.box := by
  -- This is exactly the MB axiom
  exact DerivationTree.axiom [] _ (Axiom.modal_b φ)

/--
S5 theorem: `◇□φ → φ` (possible necessity implies truth)

**Proof Strategy**:
This is a characteristic S5 theorem that fails in weaker logics like K or T.

1. From `◇□φ` (it's possible that φ is necessary)
2. By S5 axioms, we can derive φ

Steps:
- `◇□φ = ¬□¬□φ` (definition of `◇`)
- By S5: if `◇□φ` holds, then `□φ` is possible
- By accessibility symmetry (B) and reflexivity (T): this implies `φ`

Note: Full proof requires classical negation reasoning.
-/
example (φ : Formula) : ⊢ φ.box.diamond.imp φ := by
  -- EXERCISE: Complete this proof (S5 characteristic theorem)
  -- Technique: Use `contraposition` and S5 axioms (T, 4, B)
  -- Hint: Contrapose B: ¬□◇φ → ¬φ, then use ◇□φ with accessibility symmetry
  sorry

/--
S5 positive introspection iteration: `□φ → □□□φ` in one step

**Strategy**: Combine M4 twice using transitivity.
This demonstrates a common proof compression technique: instead of applying
axioms step by step, pre-compose them using `imp_trans`.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.box.box.box := by
  -- Compressed version of the necessity chain from Strategy 1
  exact imp_trans
    (DerivationTree.axiom [] _ (Axiom.modal_4 φ))
    (DerivationTree.axiom [] _ (Axiom.modal_4 φ.box))

/--
S5 idempotence of possibility: `◇◇φ → ◇φ`

**Proof Strategy**:
In S5, nested possibilities collapse. This is because:
1. `◇◇φ = ¬□¬◇φ = ¬□¬¬□¬φ`
2. By double negation: `¬□¬¬□¬φ → ¬□□¬φ`
3. By M4 contrapositive: `¬□□¬φ → ¬□¬φ = ◇φ`

This theorem is specific to S5 (the reverse `◇φ → ◇◇φ` is also true).
-/
example (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := by
  -- EXERCISE: Complete this proof (S5 diamond iteration)
  -- Technique: Use `contraposition` on modal 4 axiom
  -- Hint: ◇◇φ = ¬□□¬φ; contrapose □¬φ → □□¬φ to get ¬□□¬φ → ¬□¬φ = ◇φ
  sorry

/-!
## Strategy 5: Identity and Self-Reference

The identity formula `φ → φ` is derivable from K and S axioms using the
SKK combinator construction. This demonstrates how propositional axioms
provide a complete base.

**Key Technique**: Use the `identity` helper from Perpetuity.lean, or
construct it from scratch using K and S combinators.
-/

/--
Identity via helper: `φ → φ` using `identity` from Perpetuity

**Strategy**: The `identity` theorem is already proven in Perpetuity.lean
using the SKK combinator construction. This shows direct usage.
-/
example (φ : Formula) : ⊢ φ.imp φ := identity φ

/--
Modal identity: `□φ → □φ`

**Strategy**: Apply `identity` to the formula `□φ`.
This demonstrates that identity works for any formula, including modal ones.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.box := identity φ.box

/--
Diamond identity: `◇φ → ◇φ`

**Strategy**: Same pattern - `identity` applies to all formulas.
-/
example (φ : Formula) : ⊢ φ.diamond.imp φ.diamond := identity φ.diamond

/--
Self-reference in modal context: `□(φ → φ)`

**Strategy**: Necessitation rule pattern.
1. Derive `φ → φ` (by identity)
2. Apply modal K rule with empty context: if `⊢ φ` then `⊢ □φ`
3. Result: `⊢ □(φ → φ)`

This demonstrates the "necessitation" principle: theorems are necessary.
-/
example (φ : Formula) : ⊢ (φ.imp φ).box := by
  -- Step 1: Get identity
  have h : ⊢ φ.imp φ := identity φ

  -- Step 2: Apply necessitation: If ⊢ φ then ⊢ □φ
  exact DerivationTree.necessitation (φ.imp φ) h

/-!
## Strategy 6: Combining Modal and Propositional Reasoning

Many proofs require both modal axioms (T, 4, B) and propositional axioms (K, S).
This section demonstrates how to weave them together.

**Key Technique**: Use `imp_trans` to chain modal and propositional implications.
-/

/--
Weakening under necessity: `□φ → □(ψ → φ)` pattern

**Proof Strategy**:
This demonstrates the pattern for lifting propositional reasoning into modal context.
The full derivation requires:
1. Propositional S: `φ → (ψ → φ)` (weakening)
2. Derive `[φ] ⊢ ψ → φ` from propositional S
3. Apply modal K: `[□φ] ⊢ □(ψ → φ)`
4. Build implication: `□φ → □(ψ → φ)`

Note: Full proof requires deriving implication from context membership, which
requires additional infrastructure. Shown here as a pedagogical pattern.
-/
example (φ ψ : Formula) : ⊢ φ.box.imp (ψ.imp φ).box := by
  -- Step 1: Get propositional S axiom: φ → (ψ → φ)
  have prop_s : ⊢ φ.imp (ψ.imp φ) :=
    DerivationTree.axiom [] _ (Axiom.prop_s φ ψ)

  -- Step 2: Apply necessitation: ⊢ □(φ → (ψ → φ))
  have box_prop_s : ⊢ (φ.imp (ψ.imp φ)).box :=
    DerivationTree.necessitation _ prop_s

  -- Step 3: Apply modal K distribution: □(φ → (ψ → φ)) → (□φ → □(ψ → φ))
  have k_dist : ⊢ (φ.imp (ψ.imp φ)).box.imp (φ.box.imp (ψ.imp φ).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ (ψ.imp φ))

  -- Step 4: Apply modus ponens to get □φ → □(ψ → φ)
  exact mp box_prop_s k_dist

/--
Distribution pattern: `□φ ∧ □ψ → □(φ ∧ ψ)` structure

**Strategy**: This demonstrates the pattern for distributing `□` over conjunction.
Note: Full proof requires the modal K axiom `□(A → B) → (□A → □B)` which
is not currently in the system. Shown here for pedagogical illustration.
-/
example (φ ψ : Formula) : ⊢ (φ.box.and ψ.box).imp (φ.and ψ).box := by
  -- EXERCISE: Complete this proof (conjunction distribution under □)
  -- Technique: Use `lce_imp`, `rce_imp` from Propositional, and `Axiom.modal_k_dist`
  -- Hint: 1. Extract □φ and □ψ from □φ ∧ □ψ using conjunction elimination
  --       2. Derive ⊢ □(φ → ψ → φ ∧ ψ) using necessitation on conjunction intro
  --       3. Apply modal K twice to distribute over the curried form
  sorry

/-!
## Teaching Examples with Concrete Formulas

These examples use meaningful atom names to illustrate modal reasoning
in intuitive contexts.
-/

/--
Example: Mathematical necessity chain

**Intuition**: If mathematical facts are necessary, they are necessarily necessary.
This demonstrates M4 with a concrete example.
-/
example : ⊢ (Formula.atom "2+2=4").box.imp (Formula.atom "2+2=4").box.box := by
  exact DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "2+2=4"))

/--
Example: Logical truth is necessarily possible

**Intuition**: True statements are necessarily possible (Brouwer B axiom).
This demonstrates MB with a concrete example.
-/
example : ⊢ (Formula.atom "law_of_identity").imp
    (Formula.atom "law_of_identity").diamond.box := by
  exact DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "law_of_identity"))

/--
Example: Necessitation of theorems

**Intuition**: If something is a theorem (provable), it's necessarily true.
This demonstrates the necessitation pattern.
-/
example : ⊢ ((Formula.atom "theorem").imp (Formula.atom "theorem")).box := by
  have h : ⊢ (Formula.atom "theorem").imp (Formula.atom "theorem") :=
    identity (Formula.atom "theorem")
  exact DerivationTree.necessitation _ h

/-!
## Summary of Proof Strategies

This module demonstrated six key proof strategies for S5 modal logic:

1. **Necessity Chains**: Iterating M4 with `imp_trans` to build `□φ → □□□φ`
2. **Possibility Proofs**: Working with `◇φ = ¬□¬φ` definitional equality
3. **Modal Modus Ponens**: Using modal K rule to derive `□ψ` from `□φ` and `□(φ → ψ)`
4. **S5 Theorems**: Proving characteristic properties like `φ → □◇φ` (Brouwer B)
5. **Identity Construction**: Using K and S combinators to derive `φ → φ`
6. **Combined Reasoning**: Weaving modal and propositional axioms together

**Key Techniques Used**:
- `imp_trans` for chaining implications
- `identity` for self-reference
- `DerivationTree.necessitation` for necessitation
- `DerivationTree.axiom` for explicit axiom application
- `DerivationTree.modus_ponens` for rule application

**Helper Lemmas from Perpetuity.lean**:
- `imp_trans`: Implication transitivity
- `identity`: Identity combinator (SKK)
- `mp`: Modus ponens restatement

**Future Extensions**:
- Modal K axiom for full distribution proofs
- Classical negation for contrapositive reasoning
- Disjunction rules for possibility distribution
-/

end Bimodal.Examples.ModalProofStrategies
