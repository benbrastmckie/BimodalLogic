/-!
# ARCHIVED: Modal Proof Strategies Exercise File

**Archived from**: `Theories/Bimodal/Examples/ModalProofStrategies.lean`
**Archived by**: Task 760
**Date**: 2026-01-29
**Reason**: Contains 5 `sorry` placeholders for exercises
**Status**: Proofs are straightforward to complete if needed

These exercises demonstrate S5 modal proof construction patterns:
- Possibility distribution over disjunction (line ~204)
- Curried modal modus ponens (line ~252)
- S5 characteristic theorem (line ~295)
- S5 diamond iteration (line ~325)
- Conjunction distribution under necessity (line ~430)

To restore: Move back to `Theories/Bimodal/Examples/` and update imports in
`Bimodal/Examples.lean`.
-/

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

1. **Necessity Chains**: Iterating `[]phi -> [][]phi -> [][][]phi` using axiom M4
2. **Possibility Proofs**: Converting between `<>phi` and `not [] not phi` definitions
3. **Modal Modus Ponens**: Deriving `[]psi` from `[](phi -> psi)` and `[]phi` using modal K rule
4. **S5 Theorems**: Proving characteristic S5 properties like `phi -> []<>phi` (Brouwer B)

## Proof Patterns

This module demonstrates:
- **Axiom composition**: Chaining multiple axiom applications
- **Helper lemma usage**: Using perpetuity helpers like `imp_trans`
- **Modal K rule**: Distributing `[]` over derivations
- **Identity construction**: Building `phi -> phi` from K and S combinators

## Pedagogical Focus

Each example includes:
- Clear documentation of proof strategy (50%+ comment density)
- Explicit step-by-step derivations
- References to helper lemmas and axioms
- Explanation of why each step is necessary

## Notation

- `phi.box` = `[]phi` (necessity - true in all possible worlds)
- `phi.diamond` = `<>phi` = `not [] not phi` (possibility - true in some possible world)
- `|- phi` means `Derivable [] phi` (phi is a theorem)
- `Gamma |- phi` means `Derivable Gamma phi` (phi derivable from context Gamma)

## Exercises

This module contains 5 exercises marked with `-- EXERCISE:` comments:

1. **Possibility distribution**: Over disjunction using De Morgan laws (line ~190)
2. **Curried modal MP**: Building `[]phi -> ([](phi -> psi) -> []psi)` (line ~237)
3. **S5 characteristic**: `<>[]phi -> phi` using contraposition (line ~281)
4. **S5 diamond iteration**: `<><>phi -> <>phi` using M4 contraposition (line ~311)
5. **Conjunction distribution**: Under [] using K distribution (line ~414)

## References

* [ModalProofs.lean](ModalProofs.lean) - Basic modal axiom examples
* [Perpetuity.lean](../Logos/Core/Theorems/Perpetuity.lean) - Helper lemmas (imp_trans, etc.)
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Boneyard.Examples.ModalProofStrategies

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators
open Bimodal.Theorems

/-!
## Strategy 1: Necessity Chains (Iterating M4)

The M4 axiom (`[]phi -> [][]phi`) allows building arbitrarily long necessity chains.
This demonstrates how to compose axiom applications using implication transitivity.

**Key Technique**: Use `imp_trans` from Perpetuity.lean to chain implications.
-/

/--
Two-step necessity chain: `[]phi -> [][][]phi`

**Proof Strategy**:
1. Apply M4 to `phi`: gives `[]phi -> [][]phi`
2. Apply M4 to `[]phi`: gives `[][]phi -> [][][]phi`
3. Use `imp_trans` to chain: `[]phi -> [][]phi -> [][][]phi`

This demonstrates the basic pattern for chaining modal axioms.
-/
example (phi : Formula) : |- phi.box.imp phi.box.box.box := by
  -- Step 1: First M4 application ([]phi -> [][]phi)
  have h1 : |- phi.box.imp phi.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi)

  -- Step 2: Second M4 application ([][]phi -> [][][]phi)
  have h2 : |- phi.box.box.imp phi.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi.box)

  -- Step 3: Compose using transitivity ([]phi -> [][]phi -> [][][]phi)
  exact imp_trans h1 h2

/--
Three-step necessity chain: `[]phi -> [][][][]phi`

**Proof Strategy**:
Extend the two-step pattern to three steps, showing how to build longer chains.
This uses the same `imp_trans` pattern iteratively.
-/
example (phi : Formula) : |- phi.box.imp phi.box.box.box.box := by
  -- Build the chain step by step
  have h1 : |- phi.box.imp phi.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi)
  have h2 : |- phi.box.box.imp phi.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi.box)
  have h3 : |- phi.box.box.box.imp phi.box.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 phi.box.box)

  -- Compose: []phi -> [][]phi -> [][][]phi -> [][][][]phi
  exact imp_trans (imp_trans h1 h2) h3

/--
Backward necessity chain: `[][][]phi -> []phi` using MT

**Proof Strategy**:
The MT axiom (`[]phi -> phi`) can be applied to nested boxes to "collapse" them.
This shows the inverse pattern to M4 iteration.

1. Apply MT to `[][]phi`: gives `[][][]phi -> [][]phi`
2. Apply MT to `[]phi`: gives `[][]phi -> []phi`
3. Chain with `imp_trans`: `[][][]phi -> [][]phi -> []phi`
-/
example (phi : Formula) : |- phi.box.box.box.imp phi.box := by
  -- Step 1: Apply MT to outermost box ([][][]phi -> [][]phi)
  have h1 : |- phi.box.box.box.imp phi.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi.box.box)

  -- Step 2: Apply MT to next box ([][]phi -> []phi)
  have h2 : |- phi.box.box.imp phi.box :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi.box)

  -- Step 3: Chain the implications ([][][]phi -> [][]phi -> []phi)
  exact imp_trans h1 h2

/-!
## Strategy 2: Possibility Proofs (Definitional Conversions)

Possibility `<>phi` is defined as `not [] not phi`. This section demonstrates how to work
with this definition and convert between the two forms.

**Key Technique**: Use definitional equality (`rfl`) when the formula structure
matches exactly, or use propositional reasoning when manipulation is needed.
-/

/--
Diamond is definitionally equal to `not [] not phi`

**Strategy**: This is a direct definitional equality, verified by `rfl`.
No proof construction needed - the formula types are identical.
-/
example (phi : Formula) : phi.diamond = phi.neg.box.neg := rfl

/--
Necessity implies possibility: `[]phi -> <>phi`

**Proof Strategy**:
1. Use MB axiom: `phi -> []<>phi` (what's true is necessarily possible)
2. Apply MT to `<>phi`: gives `[]<>phi -> <>phi` (what's necessarily true is true)
3. Chain: `phi -> []<>phi -> <>phi`, giving `phi -> <>phi`
4. Apply modal K rule to lift to `[]phi -> <>phi`

Note: This demonstrates combining axioms with modal reasoning.
-/
example (phi : Formula) : |- phi.box.imp phi.diamond := by
  -- Step 1: Get MB axiom (phi -> []<>phi)
  have h1 : |- phi.imp phi.diamond.box :=
    DerivationTree.axiom [] _ (Axiom.modal_b phi)

  -- Step 2: Get MT axiom ([]<>phi -> <>phi)
  have h2 : |- phi.diamond.box.imp phi.diamond :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi.diamond)

  -- Step 3: Compose (phi -> []<>phi -> <>phi)
  have h3 : |- phi.imp phi.diamond := imp_trans h1 h2

  -- Step 4: Lift to modal context ([]phi -> <>phi)
  -- We use MT axiom ([]phi -> phi) and compose with h3 (phi -> <>phi)
  have mt : |- phi.box.imp phi :=
    DerivationTree.axiom [] _ (Axiom.modal_t phi)

  -- Compose: []phi -> phi -> <>phi, giving []phi -> <>phi
  exact imp_trans mt h3

/--
Possibility distribution: `<>(phi or psi) -> <>phi or <>psi` pattern

**Strategy**: This demonstrates the direction that IS valid in S5.
The reverse direction `<>phi or <>psi -> <>(phi or psi)` is not valid in general.

Note: Full proof requires propositional disjunction rules not yet in the system.
This is shown for pedagogical completeness to illustrate the pattern.
-/
example (phi psi : Formula) : |- (phi.or psi).diamond.imp (phi.diamond.or psi.diamond) := by
  -- EXERCISE: Complete this proof (possibility distribution over disjunction)
  -- Technique: Use De Morgan laws from Propositional and modal distribution
  -- Hint: <>(phi or psi) = not [] not (phi or psi); use demorgan_disj_neg to get not [](not phi and not psi)
  sorry

/-!
## Strategy 3: Modal Modus Ponens (Modal K Rule)

The modal K rule states: if `[[]Gamma] |- phi` then `Gamma |- []phi`.
This is the key rule for distributing necessity over derivations.

**Key Technique**: Build derivations in boxed context `[[]phi, []psi, ...]`, then
use the generalized necessitation lemma to lift the conclusion to `[]phi`.
-/

/--
Modal modus ponens pattern: From `[]phi` and `[](phi -> psi)`, derive `[]psi`

**Proof Strategy**:
1. Start with context `[phi, phi -> psi]` (non-boxed assumptions)
2. Derive `psi` from this context using modus ponens
3. Apply modal K rule: if `[phi, phi -> psi] |- psi` then `[[]phi, [](phi -> psi)] |- []psi`
4. Use weakening to lift from boxed context to theorem (empty context)

This demonstrates the core modal reasoning pattern for deriving boxed conclusions.
-/
example (phi psi : Formula) (h1 : |- phi.box) (h2 : |- (phi.imp psi).box) : |- psi.box := by
  -- We have: |- []phi and |- [](phi -> psi)
  -- Goal: |- []psi

  -- Use modal K distribution: [](phi -> psi) -> ([]phi -> []psi)
  have k_dist : |- (phi.imp psi).box.imp (phi.box.imp psi.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist phi psi)

  -- Apply K distribution to h2: [](phi -> psi) gives []phi -> []psi
  have h3 : |- phi.box.imp psi.box := mp h2 k_dist

  -- Apply to h1: []phi gives []psi
  exact mp h1 h3

/--
Simplified modal modus ponens: Using `DerivationTree.modus_ponens` directly

**Strategy**: When hypotheses are theorems (empty context), the pattern is simpler.
This shows the streamlined version without explicit context management.
-/
example (phi psi : Formula) : |- phi.box.imp ((phi.imp psi).box.imp psi.box) := by
  -- EXERCISE: Complete this proof (curried modal modus ponens)
  -- Technique: Use `Axiom.modal_k_dist` and `imp_trans` from Combinators
  -- Hint: This is the curried form of []phi and [](phi -> psi) -> []psi
  --       Start with modal K: [](phi -> psi) -> ([]phi -> []psi), then curry
  sorry

/-!
## Strategy 4: S5 Characteristic Theorems

S5 is characterized by axioms T (reflexivity), 4 (transitivity), and B (symmetry).
This section proves theorems that are specific to S5 and distinguish it from
weaker modal logics.

**Key Technique**: Combine multiple axioms using `imp_trans` and helper lemmas.
-/

/--
Brouwer B axiom: `phi -> []<>phi` (truths are necessarily possible)

**Strategy**: This is axiom MB directly. We show it as a theorem pattern.
The key insight: what's actually true must be possible in all worlds accessible
from the current world.
-/
example (phi : Formula) : |- phi.imp phi.diamond.box := by
  -- This is exactly the MB axiom
  exact DerivationTree.axiom [] _ (Axiom.modal_b phi)

/--
S5 theorem: `<>[]phi -> phi` (possible necessity implies truth)

**Proof Strategy**:
This is a characteristic S5 theorem that fails in weaker logics like K or T.

1. From `<>[]phi` (it's possible that phi is necessary)
2. By S5 axioms, we can derive phi

Steps:
- `<>[]phi = not [] not []phi` (definition of `<>`)
- By S5: if `<>[]phi` holds, then `[]phi` is possible
- By accessibility symmetry (B) and reflexivity (T): this implies `phi`

Note: Full proof requires classical negation reasoning.
-/
example (phi : Formula) : |- phi.box.diamond.imp phi := by
  -- EXERCISE: Complete this proof (S5 characteristic theorem)
  -- Technique: Use `contraposition` and S5 axioms (T, 4, B)
  -- Hint: Contrapose B: not []<>phi -> not phi, then use <>[]phi with accessibility symmetry
  sorry

/--
S5 positive introspection iteration: `[]phi -> [][][]phi` in one step

**Strategy**: Combine M4 twice using transitivity.
This demonstrates a common proof compression technique: instead of applying
axioms step by step, pre-compose them using `imp_trans`.
-/
example (phi : Formula) : |- phi.box.imp phi.box.box.box := by
  -- Compressed version of the necessity chain from Strategy 1
  exact imp_trans
    (DerivationTree.axiom [] _ (Axiom.modal_4 phi))
    (DerivationTree.axiom [] _ (Axiom.modal_4 phi.box))

/--
S5 idempotence of possibility: `<><>phi -> <>phi`

**Proof Strategy**:
In S5, nested possibilities collapse. This is because:
1. `<><>phi = not [] not <>phi = not [] not not [] not phi`
2. By double negation: `not [] not not [] not phi -> not [][] not phi`
3. By M4 contrapositive: `not [][] not phi -> not [] not phi = <>phi`

This theorem is specific to S5 (the reverse `<>phi -> <><>phi` is also true).
-/
example (phi : Formula) : |- phi.diamond.diamond.imp phi.diamond := by
  -- EXERCISE: Complete this proof (S5 diamond iteration)
  -- Technique: Use `contraposition` on modal 4 axiom
  -- Hint: <><>phi = not [][] not phi; contrapose [] not phi -> [][] not phi to get not [][] not phi -> not [] not phi = <>phi
  sorry

/-!
## Strategy 5: Identity and Self-Reference

The identity formula `phi -> phi` is derivable from K and S axioms using the
SKK combinator construction. This demonstrates how propositional axioms
provide a complete base.

**Key Technique**: Use the `identity` helper from Perpetuity.lean, or
construct it from scratch using K and S combinators.
-/

/--
Identity via helper: `phi -> phi` using `identity` from Perpetuity

**Strategy**: The `identity` theorem is already proven in Perpetuity.lean
using the SKK combinator construction. This shows direct usage.
-/
example (phi : Formula) : |- phi.imp phi := identity phi

/--
Modal identity: `[]phi -> []phi`

**Strategy**: Apply `identity` to the formula `[]phi`.
This demonstrates that identity works for any formula, including modal ones.
-/
example (phi : Formula) : |- phi.box.imp phi.box := identity phi.box

/--
Diamond identity: `<>phi -> <>phi`

**Strategy**: Same pattern - `identity` applies to all formulas.
-/
example (phi : Formula) : |- phi.diamond.imp phi.diamond := identity phi.diamond

/--
Self-reference in modal context: `[](phi -> phi)`

**Strategy**: Necessitation rule pattern.
1. Derive `phi -> phi` (by identity)
2. Apply modal K rule with empty context: if `|- phi` then `|- []phi`
3. Result: `|- [](phi -> phi)`

This demonstrates the "necessitation" principle: theorems are necessary.
-/
example (phi : Formula) : |- (phi.imp phi).box := by
  -- Step 1: Get identity
  have h : |- phi.imp phi := identity phi

  -- Step 2: Apply necessitation: If |- phi then |- []phi
  exact DerivationTree.necessitation (phi.imp phi) h

/-!
## Strategy 6: Combining Modal and Propositional Reasoning

Many proofs require both modal axioms (T, 4, B) and propositional axioms (K, S).
This section demonstrates how to weave them together.

**Key Technique**: Use `imp_trans` to chain modal and propositional implications.
-/

/--
Weakening under necessity: `[]phi -> [](psi -> phi)` pattern

**Proof Strategy**:
This demonstrates the pattern for lifting propositional reasoning into modal context.
The full derivation requires:
1. Propositional S: `phi -> (psi -> phi)` (weakening)
2. Derive `[phi] |- psi -> phi` from propositional S
3. Apply modal K: `[[]phi] |- [](psi -> phi)`
4. Build implication: `[]phi -> [](psi -> phi)`

Note: Full proof requires deriving implication from context membership, which
requires additional infrastructure. Shown here as a pedagogical pattern.
-/
example (phi psi : Formula) : |- phi.box.imp (psi.imp phi).box := by
  -- Step 1: Get propositional S axiom: phi -> (psi -> phi)
  have prop_s : |- phi.imp (psi.imp phi) :=
    DerivationTree.axiom [] _ (Axiom.prop_s phi psi)

  -- Step 2: Apply necessitation: |- [](phi -> (psi -> phi))
  have box_prop_s : |- (phi.imp (psi.imp phi)).box :=
    DerivationTree.necessitation _ prop_s

  -- Step 3: Apply modal K distribution: [](phi -> (psi -> phi)) -> ([]phi -> [](psi -> phi))
  have k_dist : |- (phi.imp (psi.imp phi)).box.imp (phi.box.imp (psi.imp phi).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist phi (psi.imp phi))

  -- Step 4: Apply modus ponens to get []phi -> [](psi -> phi)
  exact mp box_prop_s k_dist

/--
Distribution pattern: `[]phi and []psi -> [](phi and psi)` structure

**Strategy**: This demonstrates the pattern for distributing `[]` over conjunction.
Note: Full proof requires the modal K axiom `[](A -> B) -> ([]A -> []B)` which
is not currently in the system. Shown here for pedagogical illustration.
-/
example (phi psi : Formula) : |- (phi.box.and psi.box).imp (phi.and psi).box := by
  -- EXERCISE: Complete this proof (conjunction distribution under [])
  -- Technique: Use `lce_imp`, `rce_imp` from Propositional, and `Axiom.modal_k_dist`
  -- Hint: 1. Extract []phi and []psi from []phi and []psi using conjunction elimination
  --       2. Derive |- [](phi -> psi -> phi and psi) using necessitation on conjunction intro
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
example : |- (Formula.atom "2+2=4").box.imp (Formula.atom "2+2=4").box.box := by
  exact DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "2+2=4"))

/--
Example: Logical truth is necessarily possible

**Intuition**: True statements are necessarily possible (Brouwer B axiom).
This demonstrates MB with a concrete example.
-/
example : |- (Formula.atom "law_of_identity").imp
    (Formula.atom "law_of_identity").diamond.box := by
  exact DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "law_of_identity"))

/--
Example: Necessitation of theorems

**Intuition**: If something is a theorem (provable), it's necessarily true.
This demonstrates the necessitation pattern.
-/
example : |- ((Formula.atom "theorem").imp (Formula.atom "theorem")).box := by
  have h : |- (Formula.atom "theorem").imp (Formula.atom "theorem") :=
    identity (Formula.atom "theorem")
  exact DerivationTree.necessitation _ h

/-!
## Summary of Proof Strategies

This module demonstrated six key proof strategies for S5 modal logic:

1. **Necessity Chains**: Iterating M4 with `imp_trans` to build `[]phi -> [][][]phi`
2. **Possibility Proofs**: Working with `<>phi = not [] not phi` definitional equality
3. **Modal Modus Ponens**: Using modal K rule to derive `[]psi` from `[]phi` and `[](phi -> psi)`
4. **S5 Theorems**: Proving characteristic properties like `phi -> []<>phi` (Brouwer B)
5. **Identity Construction**: Using K and S combinators to derive `phi -> phi`
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

end Bimodal.Boneyard.Examples.ModalProofStrategies
