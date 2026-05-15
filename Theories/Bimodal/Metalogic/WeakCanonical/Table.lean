import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Table Translation: Temporal Formulas to Monadic FO

Defines the standard translation from temporal formulas to monadic first-order
formulas with one free variable. This is the "table method" mapping temporal
formulas to their first-order equivalents, following Reynolds 1994 Section 6.

The key function `table` translates a temporal formula `φ` to a monadic FO
formula `C_φ(t)` with one free variable `t` (represented as `MonadicFormula sig 1`).
This follows Reynolds' convention: `C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))`.

## Status
- `table` definition: sorried body (requires predicate mapping) -- Task 140
- `table_depth_bound`: sorried (requires proper complexity measure + table induction) -- Task 140

## Design
The standard translation sends each temporal atom to a distinct monadic predicate.
The signature's `preds` type is indexed by formulas, providing the finite set
of predicates needed for a given formula's translation.
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## Helper: Formula Complexity -/

/--
Formula complexity: a natural number bounding the quantifier depth
of the table translation. Defined as the number of temporal operators
(modal + temporal) in the formula.
-/
def Formula.complexity : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max φ.complexity ψ.complexity
  | .box φ => φ.complexity + 1
  | .all_future φ => φ.complexity + 1
  | .all_past φ => φ.complexity + 1
  | .untl φ ψ => max φ.complexity ψ.complexity + 1
  | .snce φ ψ => max φ.complexity ψ.complexity + 1

/-! ## Standard Translation Table -/

/--
The standard translation "table" from temporal formulas to monadic
first-order formulas with one free variable over signature `sig`.

Returns `MonadicFormula sig 1` — a formula with one free variable `t`
(De Bruijn index 0), following Reynolds 1994 Section 6: `C_φ(t)`.

**Status**: Sorried body. The full definition requires:
1. A mapping from subformula atoms to predicate symbols in sig.preds
2. Translation of G/H as bounded universal quantifiers over the order relation
3. Translation of Until/Since using existential quantifiers with order bounds

-- TODO: Implement table body in Task 140.
-/
def table (sig : MonadicSignature) (_φ : Formula) : MonadicFormula sig 1 := by
  sorry

/--
The quantifier depth of the table translation is bounded by the complexity
of the source formula.

**Status**: Sorried. Follows by structural induction on φ using the
table definition. Each temporal operator adds at most 1 quantifier
(all_future → bounded ∀, all_past → bounded ∀).

-- TODO: Prove table_depth_bound in Task 140.
-/
theorem table_depth_bound (sig : MonadicSignature) (φ : Formula) :
    (table sig φ).quantifier_depth ≤ φ.complexity := by
  sorry


end Bimodal.Metalogic.WeakCanonical
