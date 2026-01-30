import Bimodal.Syntax.Formula
import Bimodal.ProofSystem
import Bimodal.Syntax.Subformulas
import Bimodal.Boneyard.Metalogic_v2.Representation.Closure

/-!
# Signed Formula and Branch Types for Tableau Decidability (Metalogic_v2)

This module defines the core types for tableau-based decision procedures:
- `Sign`: Positive (asserted true) or negative (asserted false)
- `SignedFormula`: A formula with a sign
- `Branch`: A list of signed formulas representing a tableau branch

## Main Definitions

- `Sign`: Inductive type with `pos` and `neg` constructors
- `SignedFormula`: Structure combining sign and formula
- `Branch`: Type alias for `List SignedFormula`
- `subformulaClosure`: Compute the subformula closure (integrates with Metalogic_v2)

## Implementation Notes

This is a port from `Bimodal.Metalogic.Decidability.SignedFormula` to the
Metalogic_v2 architecture. Key changes:
- Uses `Bimodal.Syntax.Subformulas` for `Formula.subformulas` instead of local definition
- Integrates with `Bimodal.Metalogic_v2.Representation.Closure` for Finset-based closure
- Removes duplicate definitions

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)
-/

namespace Bimodal.Metalogic_v2.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic_v2.Representation

/-!
## Sign Type
-/

/--
Sign for signed formulas in tableau calculus.

- `pos`: Formula is asserted to be true
- `neg`: Formula is asserted to be false
-/
inductive Sign : Type where
  | pos : Sign
  | neg : Sign
  deriving Repr, DecidableEq, BEq, Hashable, Inhabited

namespace Sign

/-- Flip the sign. -/
def flip : Sign → Sign
  | pos => neg
  | neg => pos

@[simp]
theorem flip_flip (s : Sign) : s.flip.flip = s := by
  cases s <;> rfl

@[simp]
theorem flip_pos : Sign.pos.flip = Sign.neg := rfl

@[simp]
theorem flip_neg : Sign.neg.flip = Sign.pos := rfl

end Sign

/-!
## Signed Formula Type
-/

/--
A signed formula is a formula with a sign indicating truth assertion.

- `sign = pos`: The formula is asserted to be true
- `sign = neg`: The formula is asserted to be false

In tableau calculus, we start with the negation of the goal (sign = neg)
and expand until all branches close or we find an open saturated branch.
-/
structure SignedFormula : Type where
  /-- The sign indicating truth or falsity assertion. -/
  sign : Sign
  /-- The formula being signed. -/
  formula : Formula
  deriving Repr, DecidableEq, BEq, Hashable

namespace SignedFormula

/-- Create a positive signed formula (asserted true). -/
def pos (φ : Formula) : SignedFormula := ⟨.pos, φ⟩

/-- Create a negative signed formula (asserted false). -/
def neg (φ : Formula) : SignedFormula := ⟨.neg, φ⟩

/-- Flip the sign of a signed formula. -/
def flip (sf : SignedFormula) : SignedFormula := ⟨sf.sign.flip, sf.formula⟩

@[simp]
theorem flip_flip (sf : SignedFormula) : sf.flip.flip = sf := by
  simp [flip, Sign.flip_flip]

/-- Check if this is a positive signed formula. -/
def isPos (sf : SignedFormula) : Bool := sf.sign = .pos

/-- Check if this is a negative signed formula. -/
def isNeg (sf : SignedFormula) : Bool := sf.sign = .neg

/-- Get the complexity of the signed formula (same as formula complexity). -/
def complexity (sf : SignedFormula) : Nat := sf.formula.complexity

end SignedFormula

/-!
## Branch Type
-/

/--
A branch is a list of signed formulas in a tableau.

Branches grow as tableau rules are applied. A branch is closed if it
contains a contradiction (both T(φ) and F(φ) for some formula φ, or T(⊥)).
A branch is open if it is saturated (all rules applied) and not closed.
-/
abbrev Branch := List SignedFormula

namespace Branch

/-- Empty branch. -/
def empty : Branch := []

/-- Check if branch contains a specific signed formula. -/
def contains (b : Branch) (sf : SignedFormula) : Bool :=
  b.any (· == sf)

/-- Check if branch contains a positive formula. -/
def hasPos (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.pos φ)

/-- Check if branch contains a negative formula. -/
def hasNeg (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.neg φ)

/-- Check if branch contains T(⊥), an immediate contradiction. -/
def hasBotPos (b : Branch) : Bool :=
  b.contains (SignedFormula.pos .bot)

/--
Check if branch has a direct contradiction: both T(φ) and F(φ) for some φ.
Returns `some φ` if contradiction found, `none` otherwise.
-/
def findContradiction (b : Branch) : Option Formula :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then some sf.formula
    else none

/-- Check if branch has any contradiction (T(⊥) or complementary pair). -/
def hasContradiction (b : Branch) : Bool :=
  b.hasBotPos || b.findContradiction.isSome

/-- Get all positive formulas in the branch. -/
def positives (b : Branch) : List Formula :=
  b.filterMap fun sf => if sf.isPos then some sf.formula else none

/-- Get all negative formulas in the branch. -/
def negatives (b : Branch) : List Formula :=
  b.filterMap fun sf => if sf.isNeg then some sf.formula else none

/-- Extend branch with a signed formula. -/
def extend (b : Branch) (sf : SignedFormula) : Branch := sf :: b

/-- Extend branch with multiple signed formulas. -/
def extendMany (b : Branch) (sfs : List SignedFormula) : Branch := sfs ++ b

/-- Total complexity of all formulas in branch. -/
def totalComplexity (b : Branch) : Nat :=
  b.foldl (fun acc sf => acc + sf.complexity) 0

end Branch

/-!
## Subformula Closure

Note: This module uses `Formula.subformulas` from `Bimodal.Syntax.Subformulas`
which was factored out from the old Decidability module.

For Finset-based closure operations (used in FMP and completeness),
use `Bimodal.Metalogic_v2.Representation.Closure.closure`.
-/

/--
Compute the subformula closure for a branch (List-based).

The subformula closure contains all subformulas of all formulas in the branch.
This bounds the size of the tableau and ensures termination.
-/
def subformulaClosure (b : Branch) : List Formula :=
  (b.flatMap (fun sf => Formula.subformulas sf.formula)).eraseDups

/--
Signed subformula closure: all signed versions of the subformula closure.

This is the maximum set of signed formulas that can appear in the tableau.
-/
def signedSubformulaClosure (b : Branch) : List SignedFormula :=
  let subs := subformulaClosure b
  subs.flatMap (fun φ => [SignedFormula.pos φ, SignedFormula.neg φ])

/-!
## Finset-Based Closure (Metalogic_v2 Integration)

These functions integrate with the Metalogic_v2 Finset-based closure from
`Representation/Closure.lean` for use with FMP bounds.
-/

/--
Get the closure of a formula as a Finset (from Metalogic_v2.Representation).

This provides the Finset-based closure used in FMP and completeness proofs.
-/
def closureFinset (φ : Formula) : Finset Formula :=
  Representation.closure φ

/--
Get the size of the closure (number of distinct subformulas).

This is used to compute FMP-based fuel bounds.
-/
def closureSizeOf (φ : Formula) : Nat :=
  Representation.closureSize φ

/-!
## Complexity Measures for Termination
-/

/--
Unexpanded complexity of a signed formula.

This measures how much "work" remains to fully expand the formula.
Atomic formulas and bot have 0 unexpanded complexity (nothing to expand).
-/
def unexpandedComplexity (sf : SignedFormula) : Nat :=
  match sf.formula with
  | .atom _ => 0
  | .bot => 0
  | .imp _ _ => sf.formula.complexity
  | .box _ => sf.formula.complexity
  | .all_past _ => sf.formula.complexity
  | .all_future _ => sf.formula.complexity

/--
Total unexpanded complexity of a branch.

This decreases with each tableau expansion step, ensuring termination.
-/
def branchUnexpandedComplexity (b : Branch) : Nat :=
  b.foldl (fun acc sf => acc + unexpandedComplexity sf) 0

/-!
## FMP-Based Fuel Calculation

These functions compute tableau expansion fuel based on the Finite Model Property
bounds from Metalogic_v2.
-/

/--
Compute FMP-based fuel for tableau expansion.

The FMP guarantees that any satisfiable formula has a model with at most
2^|closure(φ)| world states. This bounds the tableau exploration space.

We use a factor of 2 to account for signed formulas (both positive and negative
versions of each subformula may appear).
-/
def fmpBasedFuel (φ : Formula) : Nat :=
  2 ^ closureSizeOf φ * 2

/--
Conservative fuel estimate based on formula complexity.

This is a simpler bound that may be looser than FMP but faster to compute.
-/
def conservativeFuel (φ : Formula) : Nat :=
  10 * φ.complexity + 100

/--
Recommended fuel for tableau expansion.

Uses FMP-based fuel when the closure is small enough, falls back to
conservative estimate for very large formulas to avoid exponential blowup.
-/
def recommendedFuel (φ : Formula) : Nat :=
  let closureSize := closureSizeOf φ
  if closureSize ≤ 20 then
    fmpBasedFuel φ
  else
    conservativeFuel φ

end Bimodal.Metalogic_v2.Decidability
