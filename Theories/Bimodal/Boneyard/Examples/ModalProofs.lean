/-!
# ARCHIVED: Modal Logic Exercise File

**Archived from**: `Theories/Bimodal/Examples/ModalProofs.lean`
**Archived by**: Task 760
**Date**: 2026-01-29
**Reason**: Contains 5 `sorry` placeholders for exercises
**Status**: Proofs are straightforward to complete if needed

These exercises demonstrate S5 modal proof techniques but were moved to Boneyard
to reduce the sorry count in the main codebase. The exercises cover:
- Modal modus ponens (line ~168)
- S5 characteristic theorem (line ~183)
- Generalized modal K rule (line ~196)
- Possibility of conjunction distribution (line ~249)
- Modal duality (line ~256)

To restore: Move back to `Theories/Bimodal/Examples/` and update imports in
`Bimodal/Examples.lean` and `Logos/Examples.lean`.
-/

import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional
-- import Bimodal.Automation.ProofSearch  -- TODO: Re-enable when Task 260 (ProofSearch) is unblocked

/-!
# Modal Logic Proof Examples

This module demonstrates S5 modal logic reasoning in the ProofChecker system,
focusing on the modal operators necessity (`[]`) and possibility (`<>`).

## S5 Modal Logic

S5 is characterized by three axioms beyond propositional logic:
- **T** (reflexivity): `[]phi -> phi` - necessary truths are true
- **4** (transitivity): `[]phi -> [][]phi` - necessary truths are necessarily necessary
- **B** (symmetry): `phi -> []<>phi` - truths are necessarily possible

These axioms make the accessibility relation reflexive, transitive, and symmetric,
which is appropriate for metaphysical necessity (truth in all possible worlds).

## Examples Categories

1. **Basic Axiom Usage**: Direct axiom applications
2. **Derived Theorems**: Results provable from the axioms
3. **Modal Distribution**: Using modal K rule
4. **Complex Formulas**: Modal operators on compound formulas

## Notation

- `phi.box` = `[]phi` (necessity - true in all possible worlds)
- `phi.diamond` = `<>phi` (possibility - true in some possible world)
- `<>phi` is defined as `not [] not phi`

## Exercises

This module contains 5 exercises marked with `-- EXERCISE:` comments. Each exercise
includes technique hints referencing the appropriate theorem modules:

1. **Modal modus ponens**: Using `Axiom.modal_k_dist` (line ~153)
2. **S5 characteristic**: Using S5 axioms T, 4, B and contraposition (line ~168)
3. **Generalized modal K**: Using `generalized_modal_k` (line ~181)
4. **Modal distribution**: Using conjunction elimination (line ~234)
5. **Modal duality**: Using `dni` from Combinators (line ~241)

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Modal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Inference rules
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Boneyard.Examples.ModalProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Propositional
-- open Bimodal.Automation (ProofSearch)  -- TODO: Re-enable when Task 260 (ProofSearch) is unblocked

/-!
## Axiom T: Reflexivity (`[]phi -> phi`)

If something is necessarily true (true in all possible worlds),
then it is true in the actual world.
-/

/-- Axiom T on atomic formula -/
example : |- (Formula.atom "p").box.imp (Formula.atom "p") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))

/-- Axiom T on implication -/
example (p q : Formula) : |- (p.imp q).box.imp (p.imp q) :=
  DerivationTree.axiom [] _ (Axiom.modal_t (p.imp q))

/-- Axiom T on nested box: `[][]phi -> []phi` -/
example (phi : Formula) : |- phi.box.box.imp phi.box :=
  DerivationTree.axiom [] _ (Axiom.modal_t phi.box)

/-- Axiom T demonstrates that necessity implies truth -/
example : |- (Formula.atom "necessary").box.imp (Formula.atom "necessary") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "necessary"))

/-!
## Axiom 4: Transitivity (`[]phi -> [][]phi`)

If something is necessary, then it is necessarily necessary.
This expresses that the accessibility relation is transitive.
-/

/-- Axiom 4 on atomic formula -/
example : |- (Formula.atom "p").box.imp (Formula.atom "p").box.box :=
  DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "p"))

/-- Axiom 4 on complex formula -/
example (p q : Formula) : |- (p.and q).box.imp (p.and q).box.box :=
  DerivationTree.axiom [] _ (Axiom.modal_4 (p.and q))

/-- Axiom 4 on negation: `[]not phi -> [][]not phi` -/
example (phi : Formula) : |- phi.neg.box.imp phi.neg.box.box :=
  DerivationTree.axiom [] _ (Axiom.modal_4 phi.neg)

/-- Axiom 4 demonstrates positive introspection -/
example : |- (Formula.atom "known").box.imp (Formula.atom "known").box.box :=
  DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "known"))

/-!
## Axiom B: Symmetry (`phi -> []<>phi`)

If something is true, then it is necessarily possible.
This expresses that the accessibility relation is symmetric.
-/

/-- Axiom B on atomic formula -/
example : |- (Formula.atom "p").imp (Formula.atom "p").diamond.box :=
  DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "p"))

/-- Axiom B on implication -/
example (p q : Formula) : |- (p.imp q).imp (p.imp q).diamond.box :=
  DerivationTree.axiom [] _ (Axiom.modal_b (p.imp q))

/-- Axiom B with explicit diamond definition: `phi -> []not []not phi` -/
example (phi : Formula) : |- phi.imp phi.diamond.box := by
  -- diamond phi = not [] not phi, so this is phi -> [](not [] not phi)
  exact DerivationTree.axiom [] _ (Axiom.modal_b phi)

/-- Axiom B demonstrates negative introspection -/
example : |- (Formula.atom "actual").imp (Formula.atom "actual").diamond.box :=
  DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "actual"))

/-!
## Propositional Axioms K and S

The propositional axioms support reasoning within the modal logic.
-/

/-- Propositional K (distribution): `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))` -/
example (phi psi chi : Formula) :
    |- (phi.imp (psi.imp chi)).imp ((phi.imp psi).imp (phi.imp chi)) :=
  DerivationTree.axiom [] _ (Axiom.prop_k phi psi chi)

/-- Propositional K with modal formulas -/
example (phi : Formula) :
    |- (phi.box.imp ((phi.diamond).imp phi)).imp
      ((phi.box.imp phi.diamond).imp (phi.box.imp phi)) :=
  DerivationTree.axiom [] _ (Axiom.prop_k phi.box phi.diamond phi)

/-- Propositional S (weakening): `phi -> (psi -> phi)` -/
example (phi psi : Formula) : |- phi.imp (psi.imp phi) :=
  DerivationTree.axiom [] _ (Axiom.prop_s phi psi)

/-- Propositional S with modal formulas -/
example (phi psi : Formula) : |- phi.box.imp (psi.diamond.imp phi.box) :=
  DerivationTree.axiom [] _ (Axiom.prop_s phi.box psi.diamond)

/-!
## Derived Theorems

Using modus ponens and axioms to derive new modal theorems.
-/

/-- Derived: From `[]phi` and `[](phi -> psi)`, derive `[]psi` (modal modus ponens pattern) -/
example (phi psi : Formula) (h1 : |- phi.box) (h2 : |- (phi.imp psi).box) : |- psi.box := by
  -- EXERCISE: Complete this proof using modal K distribution
  -- Technique: Use `Axiom.modal_k_dist` to distribute [] over implication
  -- Hint: Apply modal K: [](phi -> psi) -> ([]phi -> []psi), then use modus ponens twice
  sorry

/-- Combining T and 4: `[]phi -> phi` and `[]phi -> [][]phi` for iteration -/
example (phi : Formula) : |- phi.box.imp phi.box := by
  -- Trivial identity - can be proven directly via identity combinator
  -- Or by composing T and 4: []phi -> [][]phi -> []phi
  have h1 := DerivationTree.axiom [] _ (Axiom.modal_4 phi)       -- []phi -> [][]phi
  have h2 := DerivationTree.axiom [] _ (Axiom.modal_t phi.box)   -- [][]phi -> []phi
  exact imp_trans h1 h2

/-- S5 characteristic: `<>[]phi -> phi` (possibility of necessity implies truth) -/
example (phi : Formula) : |- phi.box.diamond.imp phi := by
  -- EXERCISE: Complete this proof (S5-specific)
  -- Technique: Use S5 axioms T, 4, B and `contraposition` from Propositional
  -- Hint: <>[]phi = not [] not []phi; use B axiom (phi -> []<>phi) contraposed, then T axiom
  sorry

/-!
## Modal Distribution (Modal K Rule)

The modal K rule allows distributing `[]` over derivations.
-/

/-- Using modal K rule: if `[]Gamma |- phi` then `Gamma |- []phi` -/
example (p : Formula) : [p] |- p.box := by
  -- EXERCISE: Complete this proof using generalized necessitation
  -- Technique: Use `generalized_modal_k` from Bimodal.Theorems.GeneralizedNecessitation
  -- Hint: First derive [[]p] |- p via assumption, then apply generalized modal K
  sorry

/-!
## Complex Modal Formulas

Demonstrating modal operators on compound formulas.
-/

/-- Necessity distributes over implication (using modal axioms) -/
noncomputable example (p q : Formula) : |- (p.box.and (p.imp q).box).imp q.box := by
  -- Goal: []p and [](p -> q) -> []q

  -- Step 1: Get conjunction eliminations as implications
  have left_elim : |- (p.box.and (p.imp q).box).imp p.box :=
    lce_imp p.box (p.imp q).box
  have right_elim : |- (p.box.and (p.imp q).box).imp (p.imp q).box :=
    rce_imp p.box (p.imp q).box

  -- Step 2: Modal K distribution: [](p -> q) -> ([]p -> []q)
  have k_dist : |- (p.imp q).box.imp (p.box.imp q.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist p q)

  -- Step 3: From [](p -> q), derive []p -> []q
  -- We need: ([]p and [](p -> q)) -> ([]p -> []q)
  -- Compose right_elim with k_dist
  have step3 : |- (p.box.and (p.imp q).box).imp (p.box.imp q.box) :=
    imp_trans right_elim k_dist

  -- Step 4: Combine to get final result
  -- We have: ([]p and [](p -> q)) -> []p  (from left_elim)
  -- We have: ([]p and [](p -> q)) -> ([]p -> []q)  (from step3)
  -- We need: ([]p and [](p -> q)) -> []q
  -- This is the S combinator pattern applied to our context

  -- Use prop_k: (A -> (B -> C)) -> ((A -> B) -> (A -> C))
  -- With A = ([]p and [](p -> q)), B = []p, C = []q
  have prop_k_inst : |- ((p.box.and (p.imp q).box).imp (p.box.imp q.box)).imp
                       (((p.box.and (p.imp q).box).imp p.box).imp
                        ((p.box.and (p.imp q).box).imp q.box)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k (p.box.and (p.imp q).box) p.box q.box)

  -- Apply modus ponens with step3 to get (([]p and [](p -> q)) -> []p) -> (([]p and [](p -> q)) -> []q)
  have step4 : |- ((p.box.and (p.imp q).box).imp p.box).imp ((p.box.and (p.imp q).box).imp q.box) :=
    mp step3 prop_k_inst

  -- Apply modus ponens with left_elim to get final result
  exact mp left_elim step4

/-- Possibility of conjunction example -/
example (p q : Formula) : |- (p.and q).diamond.imp (p.diamond.or q.diamond) := by
  -- EXERCISE: Complete this proof (modal distribution over disjunction)
  -- Technique: Use `lce_imp`, `rce_imp` for conjunction elimination, and disjunction intro
  -- Hint: <>(p and q) -> <>p follows from (p and q) -> p lifted through <>
  sorry

/-- Duality between necessity and possibility -/
example (phi : Formula) : |- phi.box.imp phi.diamond.neg.neg := by
  -- EXERCISE: Complete this proof (modal duality)
  -- Technique: Use `dni` (double negation introduction) from Combinators
  -- Hint: Since <>phi = not [] not phi, this is []phi -> not not not [] not phi; use modal 4 and dni
  sorry

/-!
## Modal Tautologies

Examples of formulas that are valid in all S5 models.
-/

/-- Double negation of possibility: `<>phi <-> not [] not phi` (definitional) -/
example (phi : Formula) : phi.diamond = phi.neg.box.neg := rfl

/-- Necessity of tautology: if `|- phi` then `|- []phi` (necessitation rule pattern) -/
example (phi : Formula) (h : |- phi) : |- phi.box := by
  -- Necessitation rule: from |- phi derive |- []phi
  -- Direct application of necessitation constructor
  exact DerivationTree.necessitation phi h

/-!
## Teaching Examples

Clear examples for learning modal logic concepts.
-/

/-- Example: Something necessarily true is true -/
example : |- (Formula.atom "2+2=4").box.imp (Formula.atom "2+2=4") :=
  DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "2+2=4"))

/-- Example: Mathematical truths are necessarily necessary -/
example : |- (Formula.atom "prime_infinity").box.imp (Formula.atom "prime_infinity").box.box :=
  DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.atom "prime_infinity"))

/-- Example: Actual facts are necessarily possible -/
example : |- (Formula.atom "I_exist").imp (Formula.atom "I_exist").diamond.box :=
  DerivationTree.axiom [] _ (Axiom.modal_b (Formula.atom "I_exist"))

/-!
## Automated Proof Search

NOTE: The following examples are commented out pending completion of Task 260 (ProofSearch).
The bounded proof search capabilities will demonstrate automatic proof discovery.

These examples will demonstrate the bounded proof search capabilities.
The `bounded_search` function attempts to automatically find derivations within a
specified depth limit, using heuristics to prioritize promising search branches.

TODO: Re-enable when Task 260 (ProofSearch) is unblocked.
-/

-- ProofSearch examples commented out - Task 260 is BLOCKED
-- See: specs/260_proof_search/plans/implementation-001.md

end Bimodal.Boneyard.Examples.ModalProofs
