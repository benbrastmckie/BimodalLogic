import Bimodal.Automation.ProofSearch.Core
import Bimodal.Automation.Tactics.Commands

/-!
# Weakening-Aware Search Tests (Task 188)

Tests for weakening-aware proof search across both layers:

1. **Tactic layer** (task 187's `tryLemmaMatchCore` weakening fallback):
   `modal_search` closes non-empty-context goals whose formula matches a
   registered `@[tm_lemma]` derived theorem by reducing to the empty context
   via `DerivationTree.weakening` + `List.nil_subset`.

2. **Computable layer** (task 188): `bounded_search_with_proof` recognizes
   additional derived-theorem shapes via the extended `matchDerived`
   (identity, dni, box_to_future, box_to_past), lifted into non-empty
   contexts through the `weakening [] Γ` wrapper, and a `matchAxiom`
   frame-class or formula mismatch no longer short-circuits the strategy
   chain (completeness fix).
-/

namespace BimodalTest.Automation.WeakeningSearch

open Bimodal.Syntax Bimodal.Automation Bimodal.ProofSystem

abbrev p : Formula := Formula.atom_s "p"
abbrev q : Formula := Formula.atom_s "q"

/-! ## Tactic layer (`modal_search`) -/

-- Headline (task 188 acceptance criterion): weakened identity in a non-empty
-- context. Previously required manual
-- `DerivationTree.weakening [] [p, q] _ ... (List.nil_subset _)`.
example (p q : Formula) : [p, q] ⊢ (p.imp p) := by modal_search

-- Weakened derived theorem under recursion: MP subgoal in non-empty context.
example (p q : Formula) : [(p.imp p).imp q] ⊢ q := by modal_search 3

-- Tier-2 case: `□p → Gp` via `box_to_future` (`@[tm_lemma]`) in a non-empty
-- context.
example (p q : Formula) : [q] ⊢ ((Formula.box p).imp (Formula.all_future p)) := by
  modal_search

/-! ## Computable layer (`bounded_search_with_proof`) -/

-- Headline mirror: the identity arm of `matchDerived` fires through the
-- `weakening [] Γ` wrapper in a non-empty context.
#guard (bounded_search_with_proof [p, q] (p.imp p) 3).1.isSome

-- box_to_future arm in a non-empty context.
#guard (bounded_search_with_proof [q]
  ((Formula.box p).imp (Formula.all_future p)) 3).1.isSome

-- box_to_past arm in a non-empty context.
#guard (bounded_search_with_proof [q]
  ((Formula.box p).imp (Formula.all_past p)) 3).1.isSome

-- dni arm: `p → ¬¬p` in a non-empty context.
#guard (bounded_search_with_proof [q] (p.imp p.neg.neg) 3).1.isSome

-- Regression: the pre-existing TF arm (`□p → G(□p)`) still fires (empty
-- context, no weakening involved).
#guard (bounded_search_with_proof []
  ((Formula.box p).imp (Formula.all_future (Formula.box p))) 3).1.isSome

/-! ## `matchAxiom` fall-through (completeness fix) -/

-- A density-shaped formula (`GGp → Gp`) matches `Axiom.density`, whose
-- `minFrameClass` is `Dense` (not `≤ Base`). Before the task 188 fix, the
-- frame-class mismatch made `bounded_search_with_proof` return `none`
-- outright; now the search falls through to the assumption strategy and
-- closes the goal from the context.
#guard (bounded_search_with_proof
  [(Formula.all_future (Formula.all_future p)).imp (Formula.all_future p)]
  ((Formula.all_future (Formula.all_future p)).imp (Formula.all_future p))
  3).1.isSome

/-! ## Negative fast-fail guard -/

-- An atomic goal in the empty context is unprovable; the search returns
-- `none` quickly (no strategy applies, no search-space blow-up).
#guard (bounded_search_with_proof [] (Formula.atom_s "z") 5).1.isNone

end BimodalTest.Automation.WeakeningSearch
