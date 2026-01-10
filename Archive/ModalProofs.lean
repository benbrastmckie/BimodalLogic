import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Automation.ProofSearch

/-!
# Modal Logic Proof Examples

This module demonstrates S5 modal logic reasoning in the ProofChecker system,
focusing on the modal operators necessity (`□`) and possibility (`◇`).

## S5 Modal Logic

S5 is characterized by three axioms beyond propositional logic:
- **T** (reflexivity): `□φ → φ` - necessary truths are true
- **4** (transitivity): `□φ → □□φ` - necessary truths are necessarily necessary
- **B** (symmetry): `φ → □◇φ` - truths are necessarily possible

These axioms make the accessibility relation reflexive, transitive, and symmetric,
which is appropriate for metaphysical necessity (truth in all possible worlds).

## Examples Categories

1. **Basic Axiom Usage**: Direct axiom applications
2. **Derived Theorems**: Results provable from the axioms
3. **Modal Distribution**: Using modal K rule
4. **Complex Formulas**: Modal operators on compound formulas

## Notation

- `φ.box` = `□φ` (necessity - true in all possible worlds)
- `φ.diamond` = `◇φ` (possibility - true in some possible world)
- `◇φ` is defined as `¬□¬φ`

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Modal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Inference rules
* [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Archive.ModalProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation (ProofSearch)

/-!
## Axiom T: Reflexivity (`□φ → φ`)

If something is necessarily true (true in all possible worlds),
then it is true in the actual world.
-/

/-- Axiom T on atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))

/-- Axiom T on implication -/
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.imp q) :=
  Derivable.axiom [] _ (Axiom.modal_t (p.imp q))

/-- Axiom T on nested box: `□□φ → □φ` -/
example (φ : Formula) : ⊢ φ.box.box.imp φ.box :=
  Derivable.axiom [] _ (Axiom.modal_t φ.box)

/-- Axiom T demonstrates that necessity implies truth -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "necessary"))

/-!
## Axiom 4: Transitivity (`□φ → □□φ`)

If something is necessary, then it is necessarily necessary.
This expresses that the accessibility relation is transitive.
-/

/-- Axiom 4 on atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "p"))

/-- Axiom 4 on complex formula -/
example (p q : Formula) : ⊢ (p.and q).box.imp (p.and q).box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (p.and q))

/-- Axiom 4 on negation: `□¬φ → □□¬φ` -/
example (φ : Formula) : ⊢ φ.neg.box.imp φ.neg.box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 φ.neg)

/-- Axiom 4 demonstrates positive introspection -/
example : ⊢ (Formula.atom "known").box.imp (Formula.atom "known").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "known"))

/-!
## Axiom B: Symmetry (`φ → □◇φ`)

If something is true, then it is necessarily possible.
This expresses that the accessibility relation is symmetric.
-/

/-- Axiom B on atomic formula -/
example : ⊢ (Formula.atom "p").imp (Formula.atom "p").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "p"))

/-- Axiom B on implication -/
example (p q : Formula) : ⊢ (p.imp q).imp (p.imp q).diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (p.imp q))

/-- Axiom B with explicit diamond definition: `φ → □¬□¬φ` -/
example (φ : Formula) : ⊢ φ.imp φ.diamond.box := by
  -- diamond φ = ¬□¬φ, so this is φ → □(¬□¬φ)
  exact Derivable.axiom [] _ (Axiom.modal_b φ)

/-- Axiom B demonstrates negative introspection -/
example : ⊢ (Formula.atom "actual").imp (Formula.atom "actual").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "actual"))

/-!
## Propositional Axioms K and S

The propositional axioms support reasoning within the modal logic.
-/

/-- Propositional K (distribution): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
example (φ ψ χ : Formula) :
    ⊢ (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)) :=
  Derivable.axiom [] _ (Axiom.prop_k φ ψ χ)

/-- Propositional K with modal formulas -/
example (φ : Formula) :
    ⊢ (φ.box.imp ((φ.diamond).imp φ)).imp
      ((φ.box.imp φ.diamond).imp (φ.box.imp φ)) :=
  Derivable.axiom [] _ (Axiom.prop_k φ.box φ.diamond φ)

/-- Propositional S (weakening): `φ → (ψ → φ)` -/
example (φ ψ : Formula) : ⊢ φ.imp (ψ.imp φ) :=
  Derivable.axiom [] _ (Axiom.prop_s φ ψ)

/-- Propositional S with modal formulas -/
example (φ ψ : Formula) : ⊢ φ.box.imp (ψ.diamond.imp φ.box) :=
  Derivable.axiom [] _ (Axiom.prop_s φ.box ψ.diamond)

/-!
## Derived Theorems

Using modus ponens and axioms to derive new modal theorems.
-/

/-- Derived: From `□φ` and `□(φ → ψ)`, derive `□ψ` (modal modus ponens pattern) -/
example (φ ψ : Formula) (h1 : ⊢ φ.box) (h2 : ⊢ (φ.imp ψ).box) : ⊢ ψ.box := by
  -- This would require modal K rule and weakening to derive properly
  -- For now, demonstrating the pattern via axioms
  sorry

/-- Combining T and 4: `□φ → φ` and `□φ → □□φ` for iteration -/
example (φ : Formula) : ⊢ φ.box.imp φ.box := by
  -- Trivial identity, but shows combining T and 4
  have h1 := Derivable.axiom [] _ (Axiom.modal_t φ.box)  -- □□φ → □φ
  have h2 := Derivable.axiom [] _ (Axiom.modal_4 φ)      -- □φ → □□φ
  -- Would compose these to get □φ → □φ (identity)
  sorry

/-- S5 characteristic: `◇□φ → φ` (possibility of necessity implies truth) -/
example (φ : Formula) : ⊢ φ.box.diamond.imp φ := by
  -- This is derivable in S5 from T, 4, B
  -- ◇□φ = ¬□¬□φ → φ
  sorry

/-!
## Modal Distribution (Modal K Rule)

The modal K rule allows distributing `□` over derivations.
-/

/-- Using modal K rule: if `□Γ ⊢ φ` then `Γ ⊢ □φ` -/
example (p : Formula) : [p] ⊢ p.box := by
  -- To derive p.box from assumption p, use modal K:
  -- We need [□p] ⊢ p, which follows from assumption
  apply Derivable.modal_k [p] p
  -- Now need to show: [□p] ⊢ p
  -- This follows from modal T axiom and modus ponens
  apply Derivable.modus_ponens [p.box] p.box p
  · exact Derivable.axiom [p.box] _ (Axiom.modal_t p)
  · exact Derivable.assumption [p.box] p.box (by simp)

/-!
## Complex Modal Formulas

Demonstrating modal operators on compound formulas.
-/

/-- Necessity distributes over implication (using modal axioms) -/
example (p q : Formula) : ⊢ (p.box.and (p.imp q).box).imp q.box := by
  -- Would use: □p ∧ □(p → q) → □q
  -- This requires modal K axiom and propositional reasoning
  sorry

/-- Possibility of conjunction example -/
example (p q : Formula) : ⊢ (p.and q).diamond.imp (p.diamond.or q.diamond) := by
  -- ◇(p ∧ q) → (◇p ∨ ◇q) is a valid modal theorem
  sorry

/-- Duality between necessity and possibility -/
example (φ : Formula) : ⊢ φ.box.imp φ.diamond.neg.neg := by
  -- □φ → ¬¬◇φ (using ◇φ = ¬□¬φ)
  -- This is: □φ → ¬¬¬□¬φ
  sorry

/-!
## Modal Tautologies

Examples of formulas that are valid in all S5 models.
-/

/-- Double negation of possibility: `◇φ ↔ ¬□¬φ` (definitional) -/
example (φ : Formula) : φ.diamond = φ.neg.box.neg := rfl

/-- Necessity of tautology: if `⊢ φ` then `⊢ □φ` (necessitation rule pattern) -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  -- Necessitation rule: from ⊢ φ derive ⊢ □φ
  -- This uses modal K with empty context
  apply Derivable.modal_k [] φ
  exact h

/-!
## Teaching Examples

Clear examples for learning modal logic concepts.
-/

/-- Example: Something necessarily true is true -/
example : ⊢ (Formula.atom "2+2=4").box.imp (Formula.atom "2+2=4") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "2+2=4"))

/-- Example: Mathematical truths are necessarily necessary -/
example : ⊢ (Formula.atom "prime_infinity").box.imp (Formula.atom "prime_infinity").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "prime_infinity"))

/-- Example: Actual facts are necessarily possible -/
example : ⊢ (Formula.atom "I_exist").imp (Formula.atom "I_exist").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "I_exist"))

/-!
## Automated Proof Search

These examples demonstrate the bounded proof search capabilities added in Task 126.
The `bounded_search` function attempts to automatically find derivations within a
specified depth limit, using heuristics to prioritize promising search branches.
-/

/-- Basic automated proof discovery: Modal T axiom -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 3
  found  -- Returns true (axiom match)

/-- Automated proof of modal 4 axiom -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p").box.box
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 3
  found  -- Returns true (axiom match)

/-- Compare manual vs automated proof approaches -/
example (p : Formula) : ⊢ p.box.imp p := by
  -- Manual approach: directly apply axiom
  exact Derivable.axiom [] _ (Axiom.modal_t p)
  -- Automated approach would use: bounded_search [] (p.box.imp p) 3

/-!
## Search Performance Analysis

These examples show how to analyze proof search performance using `SearchStats`.
The statistics track cache hits/misses, nodes visited, and pruning events.
-/

/-- Demonstrate search statistics collection -/
example : Automation.ProofSearch.SearchStats :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let (_, _, _, stats, _) := Automation.ProofSearch.search_with_heuristics [] goal 10
  stats  -- Shows: hits, misses, visited, prunedByLimit

/-- Compare search depths: depth=3 vs depth=5 -/
example : Nat × Nat :=
  let goal := (Formula.atom "p").box.box.imp (Formula.atom "p")
  let (_, _, _, stats3, _) := Automation.ProofSearch.bounded_search [] goal 3
  let (_, _, _, stats5, _) := Automation.ProofSearch.bounded_search [] goal 5
  (stats3.visited, stats5.visited)  -- Compare node counts

/-- Search with insufficient depth returns false -/
example : Bool :=
  let goal := (Formula.atom "p").box.box.box.imp (Formula.atom "p")
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 1
  found  -- Returns false (depth too low for nested boxes)

/-!
## Custom Heuristic Strategies

These examples demonstrate configurable heuristic weights for proof search.
Lower scores indicate higher priority branches.
-/

/-- Compare heuristic strategies: axiom-first vs MP-first -/
example : Nat × Nat :=
  let weights_axiom_first : Automation.ProofSearch.HeuristicWeights :=
    { axiomWeight := 0, mpBase := 10 }
  let weights_mp_first : Automation.ProofSearch.HeuristicWeights :=
    { axiomWeight := 10, mpBase := 0 }
  let goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let score1 := Automation.ProofSearch.heuristic_score weights_axiom_first [] goal
  let score2 := Automation.ProofSearch.heuristic_score weights_mp_first [] goal
  (score1, score2)  -- (0, 10) - axiom-first prefers this goal

/-- Demonstrate heuristic weight configuration -/
example : Automation.ProofSearch.HeuristicWeights :=
  { axiomWeight := 0
  , assumptionWeight := 1
  , mpBase := 2
  , mpComplexityWeight := 1
  , modalBase := 5
  , temporalBase := 5
  , contextPenaltyWeight := 1
  , deadEnd := 100 }

/-!
## Context Transformation Utilities

These examples demonstrate context transformation functions used in modal
and temporal K rules.
-/

/-- Demonstrate modal K context transformation -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  Automation.ProofSearch.box_context Γ  -- Returns [□p, □q]

/-- Show temporal K context transformation -/
example : Context :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  Automation.ProofSearch.future_context Γ  -- Returns [Gp, Gq]

/-- Context transformation preserves length -/
example : Nat :=
  let Γ := [Formula.atom "p", Formula.atom "q", Formula.atom "r"]
  let boxed := Automation.ProofSearch.box_context Γ
  boxed.length  -- Returns 3 (same as Γ.length)

end Archive.ModalProofs
